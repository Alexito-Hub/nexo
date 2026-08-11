import 'package:flutter/foundation.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/data/session.dart';

enum DirectoryStatus {
  /// Todavía no se preguntó.
  unknown,
  checking,

  /// El backend confirmó el acceso.
  granted,

  /// El backend contestó que esta cuenta no lo tiene.
  denied,

  /// No se pudo preguntar (sin red, backend caído, credenciales rechazadas).
  /// Es distinto de `denied` a propósito: no negamos el acceso por un fallo
  /// de conexión, simplemente no lo mostramos hasta poder confirmarlo.
  unavailable,
}

/// Resuelve si esta cuenta puede ver el directorio de estudiantes.
///
/// Es la pieza que decide si el apartado aparece o no en la barra de la app.
/// La respuesta la da el backend —único juez del acceso—; aquí solo se guarda
/// para no preguntarlo en cada reconstrucción.
class DirectoryService extends ChangeNotifier {
  DirectoryService({required SessionService session, BackendClient? client})
    : _session = session,
      client = client ?? BackendClient();

  final SessionService _session;
  final BackendClient client;

  DirectoryStatus _status = DirectoryStatus.unknown;
  String? _role;
  String? _code;

  DirectoryStatus get status => _status;
  bool get hasAccess => _status == DirectoryStatus.granted;
  bool get isAdmin => _role == 'admin';
  String? get code => _code;

  /// Pregunta una sola vez por sesión. Si falló por algo transitorio se
  /// vuelve a intentar en la siguiente llamada.
  Future<void> ensureResolved() async {
    if (_status == DirectoryStatus.granted ||
        _status == DirectoryStatus.denied ||
        _status == DirectoryStatus.checking) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final storage = AppStorage.instance;
    final user = storage.credUser;
    final pass = storage.credPass;
    if (user == null || pass == null || user.isEmpty || pass.isEmpty) {
      _set(DirectoryStatus.unavailable, null);
      return;
    }

    _set(DirectoryStatus.checking, _role);
    try {
      await client.login(
        usuario: user,
        clave: pass,
        asTeacher: _session.user?.isTeacher ?? false,
      );
      final access = await client.access();
      _code = access.code;
      _set(
        access.allowed ? DirectoryStatus.granted : DirectoryStatus.denied,
        access.role,
      );
    } on BackendException catch (e) {
      // Que el backend no conteste no es lo mismo que negar el acceso.
      _set(
        e.code == 'sin_acceso_directorio'
            ? DirectoryStatus.denied
            : DirectoryStatus.unavailable,
        null,
      );
    }
  }

  void reset() {
    client.disconnect();
    _code = null;
    _set(DirectoryStatus.unknown, null);
  }

  void _set(DirectoryStatus status, String? role) {
    if (_status == status && _role == role) return;
    _status = status;
    _role = role;
    notifyListeners();
  }
}
