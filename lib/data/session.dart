import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/api_client.dart';
import 'package:nexo/data/sigma_repository.dart';
import 'package:nexo/domain/models.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionService extends ChangeNotifier {
  SessionService({required ApiClient apiClient, required SigmaRepository repo})
    : _api = apiClient,
      _repo = repo {
    _api.onUnauthorized = _onAuthFailed;
    _api.reauthenticate = _reauthenticate;
  }
  final ApiClient _api;
  final SigmaRepository _repo;
  SessionStatus _status = SessionStatus.unknown;
  UserProfile? _user;
  Future<ReauthOutcome>? _inFlightReauth;
  SessionStatus get status => _status;
  UserProfile? get user => _user;
  bool get isAuthenticated => _status == SessionStatus.authenticated;
  Future<void> bootstrap() async {
    final storage = AppStorage.instance;
    final tok = storage.token;
    final hasToken = tok != null && tok.isNotEmpty;
    if (hasToken) {
      _api.setToken(tok);
      _loadUserFromStorage(storage);
      // Token presente y todavía vigente → sesión válida sin tocar la red.
      if (!_isJwtExpired(tok)) {
        _setStatus(SessionStatus.authenticated);
        return;
      }
    }
    // Token ausente o vencido: intentar reautenticar si hay credenciales.
    if (storage.hasCredentials) {
      final outcome = await _reauthenticate();
      if (outcome == ReauthOutcome.refreshed) {
        _setStatus(SessionStatus.authenticated);
        return;
      }
      // Fallo TRANSITORIO al arrancar (p.ej. sin red / SIGMA frío): entramos de
      // forma optimista y mostramos el caché en vez de expulsar a login. Un 401
      // posterior o un refresh manual reintentarán. Solo credenciales
      // confirmadas inválidas caen a la pantalla de login.
      if (outcome == ReauthOutcome.unavailable) {
        _setStatus(SessionStatus.authenticated);
        return;
      }
    }
    _setStatus(SessionStatus.unauthenticated);
  }

  void _loadUserFromStorage(AppStorage storage) {
    final raw = storage.userJson;
    if (raw == null) return;
    try {
      _user = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  /// Lee el `exp` del JWT (sin validar firma — solo para decidir si conviene
  /// reautenticar proactivamente al arrancar). Ante cualquier duda devuelve
  /// `false` (no vencido) para no forzar reautenticaciones innecesarias.
  static bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! int) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Margen de 30 s: no usamos un token a punto de morir.
      return DateTime.now().isAfter(
        expiry.subtract(const Duration(seconds: 30)),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> login(String usuarioId, String password) async {
    final result = await _repo.login(usuarioId, password);
    await _persistSession(result);
    await AppStorage.instance.setCredentials(usuarioId, password);
    _setStatus(SessionStatus.authenticated);
  }

  Future<void> _persistSession(LoginResult result) async {
    await AppStorage.instance.setToken(result.token);
    if (result.info != null) {
      await AppStorage.instance.setUserJson(jsonEncode(result.info!.toJson()));
      _user = result.info;
    }
  }

  Future<ReauthOutcome> _reauthenticate() {
    return _inFlightReauth ??= _doReauth()
      ..whenComplete(() => _inFlightReauth = null);
  }

  Future<ReauthOutcome> _doReauth() async {
    final s = AppStorage.instance;
    final u = s.credUser;
    final p = s.credPass;
    // Sin credenciales guardadas no hay forma de reautenticar en silencio:
    // hay que ir a login.
    if (u == null || p == null || u.isEmpty || p.isEmpty) {
      return ReauthOutcome.invalidCredentials;
    }
    try {
      final result = await _repo.login(u, p);
      await _persistSession(result);
      return ReauthOutcome.refreshed;
    } on InvalidCredentialsException {
      // El servidor rechazó las credenciales: única causa de logout.
      return ReauthOutcome.invalidCredentials;
    } catch (_) {
      // Red / timeout / servidor / HTML: transitorio → conservar la sesión.
      return ReauthOutcome.unavailable;
    }
  }

  Future<void> logout() async {
    await AppStorage.instance.clear(keepCredentials: false);
    _api.setToken(null);
    _user = null;
    _setStatus(SessionStatus.unauthenticated);
  }

  /// Cierra el arranque cuando `bootstrap` no pudo decidir —falló o tardó
  /// demasiado—. Sin esto la app se quedaría en el splash para siempre; la
  /// pantalla de login siempre es recuperable, así que es el destino seguro.
  void resolveUnknownAsUnauthenticated() {
    if (_status == SessionStatus.unknown) {
      _setStatus(SessionStatus.unauthenticated);
    }
  }

  void _onAuthFailed() {
    scheduleMicrotask(() async {
      await AppStorage.instance.clear(keepCredentials: false);
      _api.setToken(null);
      _user = null;
      _setStatus(SessionStatus.unauthenticated);
    });
  }

  void _setStatus(SessionStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }
}
