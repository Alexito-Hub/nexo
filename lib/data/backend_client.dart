import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexo/core/config.dart';
import 'package:nexo/data/secure_http.dart';

/// Cliente del backend propio de Nexo.
///
/// El backend no sustituye a SIGMA ni a la Intranet: es el **intermediario que
/// verifica el acceso** al directorio de estudiantes y quien lo sirve mientras
/// no haya permiso institucional para leer la fuente real. Por eso esta clase
/// solo conoce dos cosas: identificarse y el directorio.
///
/// La sesión vive en memoria a propósito. Da acceso a datos de terceros y no
/// tiene por qué sobrevivir al cierre de la app.
class BackendClient {
  BackendClient({http.Client? transport}) : _given = transport;

  final http.Client? _given;
  http.Client? _http;

  String? _access;
  String? _refresh;

  bool get isConnected => _access != null;

  Future<http.Client> _client() async =>
      _http ??= _given ?? await createSecureClient();

  /// Identifica la cuenta contra el backend, que a su vez la verifica contra
  /// SIGMA. Las credenciales no se guardan allá.
  Future<void> login({
    required String usuario,
    required String clave,
    required bool asTeacher,
  }) async {
    final path = asTeacher ? '/auth/teacher/login' : '/auth/student/login';
    final body = await _send(
      'POST',
      path,
      body: {'usuario': usuario, 'clave': clave},
      authorize: false,
    );
    _access = body['access_token'] as String?;
    _refresh = body['refresh_token'] as String?;
  }

  /// Entrada de un apoderado: DNI + PIN, sin cuenta de la UPLA. Devuelve los
  /// estudiantes que tiene autorizados, que suelen ser uno.
  Future<List<StudentSummary>> guardianLogin({
    required String dni,
    required String pin,
  }) async {
    final body = await _send(
      'POST',
      '/guardian/login',
      body: {'dni': dni, 'pin': pin},
      authorize: false,
    );
    _access = body['access_token'] as String?;
    _refresh = body['refresh_token'] as String?;
    return (body['estudiantes'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => StudentSummary.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Ficha de un hijo o tutelado. El backend comprueba el vínculo.
  Future<StudentRecord> guardianStudent(String codigo) async {
    final body = await _send('GET', '/guardian/students/$codigo');
    return StudentRecord.fromJson(
      (body['estudiante'] as Map).cast<String, dynamic>(),
    );
  }

  /// Si esta cuenta tiene acceso al directorio, y con qué rol.
  Future<DirectoryAccess> access() async {
    final body = await _send('GET', '/directory/access');
    return DirectoryAccess.fromJson(body);
  }

  Future<DirectoryPage> students({
    String? query,
    String? school,
    int? cycle,
    int page = 1,
    int limit = 25,
  }) async {
    final params = <String, String>{
      'pagina': '$page',
      'limite': '$limit',
      if (query != null && query.isNotEmpty) 'q': query,
      if (school != null && school.isNotEmpty) 'escuela': school,
      if (cycle != null) 'ciclo': cycle.toString(),
    };
    final body = await _send('GET', '/directory/students', query: params);
    return DirectoryPage.fromJson(body);
  }

  Future<List<String>> schools() async {
    final body = await _send('GET', '/directory/schools');
    final raw = body['escuelas'];
    return raw is List ? raw.map((e) => e.toString()).toList() : const [];
  }

  Future<StudentRecord> student(String codigo) async {
    final body = await _send('GET', '/directory/students/$codigo');
    return StudentRecord.fromJson(
      (body['estudiante'] as Map).cast<String, dynamic>(),
    );
  }

  // --- Administración del acceso -------------------------------------------

  Future<AccessGrants> grants() async {
    final body = await _send('GET', '/directory/grants');
    return AccessGrants.fromJson(body);
  }

  Future<AccessGrant> setGrant(
    String codigo, {
    required String estado,
    String? nota,
  }) async {
    final body = await _send(
      'PUT',
      '/directory/grants/$codigo',
      body: {'estado': estado, 'nota': ?nota},
    );
    return AccessGrant.fromJson(
      (body['acceso'] as Map).cast<String, dynamic>(),
    );
  }

  void disconnect() {
    _access = null;
    _refresh = null;
  }

  // --- Transporte ----------------------------------------------------------

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool authorize = true,
    bool retried = false,
  }) async {
    final client = await _client();
    final uri = Uri.parse(
      '${BackendConfig.apiBaseUrl}$path',
    ).replace(queryParameters: query);

    late http.Response res;
    try {
      final request = http.Request(method, uri)
        ..headers.addAll({
          'Accept': 'application/json',
          if (body != null) 'Content-Type': 'application/json',
          if (authorize && _access != null) 'Authorization': 'Bearer $_access',
        });
      if (body != null) request.body = jsonEncode(body);
      final streamed = await client
          .send(request)
          .timeout(BackendConfig.timeout);
      res = await http.Response.fromStream(streamed);
    } catch (e) {
      throw BackendException('sin_conexion', e.toString());
    }

    final decoded = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return decoded;

    final error = decoded['error']?.toString() ?? 'error_${res.statusCode}';

    // El token de acceso dura poco: se renueva y se reintenta una sola vez.
    if (res.statusCode == 401 && error == 'no_autenticado' && !retried) {
      if (await _renew()) {
        return _send(
          method,
          path,
          query: query,
          body: body,
          authorize: authorize,
          retried: true,
        );
      }
    }

    throw BackendException(error, decoded['detail']?.toString());
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final raw = jsonDecode(utf8.decode(res.bodyBytes));
      return raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<bool> _renew() async {
    final token = _refresh;
    if (token == null) return false;
    try {
      final body = await _send(
        'POST',
        '/auth/refresh',
        body: {'refresh_token': token},
        authorize: false,
      );
      _access = body['access_token'] as String?;
      _refresh = body['refresh_token'] as String?;
      return _access != null;
    } on BackendException {
      disconnect();
      return false;
    }
  }
}

/// Error del backend, identificado por el código que devuelve la API
/// (`sin_acceso_directorio`, `solo_administradores`, `credenciales_invalidas`,
/// `sigma_no_disponible`, `no_encontrado`, `sin_conexion`…).
class BackendException implements Exception {
  const BackendException(this.code, [this.detail]);
  final String code;
  final String? detail;
  @override
  String toString() => detail ?? code;
}

class DirectoryAccess {
  const DirectoryAccess({
    required this.allowed,
    required this.role,
    required this.code,
  });
  final bool allowed;

  /// `admin` reparte accesos; `autorizado` solo consulta; `null` no entra.
  final String? role;
  final String code;

  bool get isAdmin => role == 'admin';

  factory DirectoryAccess.fromJson(Map<String, dynamic> j) => DirectoryAccess(
    allowed: j['acceso'] == true,
    role: j['rol']?.toString(),
    code: j['codigo']?.toString() ?? '',
  );
}

class DirectoryPage {
  const DirectoryPage({
    required this.students,
    required this.total,
    required this.page,
    required this.pages,
  });
  final List<StudentSummary> students;
  final int total;
  final int page;
  final int pages;

  bool get hasMore => page < pages;

  factory DirectoryPage.fromJson(Map<String, dynamic> j) => DirectoryPage(
    students: (j['estudiantes'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => StudentSummary.fromJson(e.cast<String, dynamic>()))
        .toList(),
    total: _int(j['total']) ?? 0,
    page: _int(j['pagina']) ?? 1,
    pages: _int(j['paginas']) ?? 1,
  );
}

class StudentSummary {
  const StudentSummary({
    required this.code,
    required this.firstName,
    required this.lastName,
    this.school,
    this.cycle,
    this.status,
    this.average,
    this.creditsApproved,
    this.creditsTotal,
  });
  final String code;
  final String firstName;
  final String lastName;
  final String? school;
  final int? cycle;
  final String? status;
  final double? average;
  final int? creditsApproved;
  final int? creditsTotal;

  String get fullName => '$lastName, $firstName';
  bool get atRisk => average != null && average! < 10.5;

  factory StudentSummary.fromJson(Map<String, dynamic> j) => StudentSummary(
    code: j['codigo']?.toString() ?? '',
    firstName: j['nombres']?.toString() ?? '',
    lastName: j['apellidos']?.toString() ?? '',
    school: j['escuela']?.toString(),
    cycle: _int(j['ciclo']),
    status: j['condicion']?.toString(),
    average: _double(j['promedio']),
    creditsApproved: _int(j['creditos_aprobados']),
    creditsTotal: _int(j['creditos_totales']),
  );
}

class StudentRecord extends StudentSummary {
  const StudentRecord({
    required super.code,
    required super.firstName,
    required super.lastName,
    super.school,
    super.cycle,
    super.status,
    super.average,
    super.creditsApproved,
    super.creditsTotal,
    this.dni,
    this.email,
    this.phone,
    this.faculty,
    this.plan,
    this.entryYear,
    this.academic = const {},
    this.modules = const {},
  });
  final String? dni;
  final String? email;
  final String? phone;
  final String? faculty;
  final String? plan;
  final int? entryYear;
  final Map<String, dynamic> academic;
  final Map<String, dynamic> modules;

  Map<String, dynamic>? module(String name) {
    final value = modules[name];
    return value is Map ? value.cast<String, dynamic>() : null;
  }

  factory StudentRecord.fromJson(Map<String, dynamic> j) => StudentRecord(
    code: j['codigo']?.toString() ?? '',
    firstName: j['nombres']?.toString() ?? '',
    lastName: j['apellidos']?.toString() ?? '',
    school: j['escuela']?.toString(),
    cycle: _int(j['ciclo']),
    status: j['condicion']?.toString(),
    average: _double(j['promedio']),
    creditsApproved: _int(j['creditos_aprobados']),
    creditsTotal: _int(j['creditos_totales']),
    dni: j['dni']?.toString(),
    email: j['correo']?.toString(),
    phone: j['telefono']?.toString(),
    faculty: j['facultad']?.toString(),
    plan: j['plan']?.toString(),
    entryYear: _int(j['anio_ingreso']),
    academic: j['academico'] is Map
        ? (j['academico'] as Map).cast<String, dynamic>()
        : const {},
    modules: j['modulos'] is Map
        ? (j['modulos'] as Map).cast<String, dynamic>()
        : const {},
  );
}

class AccessGrants {
  const AccessGrants({required this.grants, required this.admins});
  final List<AccessGrant> grants;

  /// Códigos con potestad para repartir acceso. Vienen del entorno del
  /// servidor, así que la app los muestra pero no los puede cambiar.
  final List<String> admins;

  factory AccessGrants.fromJson(Map<String, dynamic> j) => AccessGrants(
    grants: (j['accesos'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AccessGrant.fromJson(e.cast<String, dynamic>()))
        .toList(),
    admins: (j['administradores'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}

class AccessGrant {
  const AccessGrant({
    required this.code,
    required this.status,
    this.note,
    this.grantedBy,
    this.grantedAt,
    this.revokedAt,
  });
  final String code;
  final String status;
  final String? note;
  final String? grantedBy;
  final String? grantedAt;
  final String? revokedAt;

  bool get isActive => status == 'activo';

  factory AccessGrant.fromJson(Map<String, dynamic> j) => AccessGrant(
    code: j['codigo']?.toString() ?? '',
    status: j['estado']?.toString() ?? 'revocado',
    note: j['nota']?.toString(),
    grantedBy: j['concedido_por']?.toString(),
    grantedAt: j['concedido_en']?.toString(),
    revokedAt: j['revocado_en']?.toString(),
  );
}

int? _int(Object? v) => v is num ? v.toInt() : null;
double? _double(Object? v) => v is num ? v.toDouble() : null;
