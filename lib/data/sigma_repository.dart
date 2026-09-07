import 'dart:convert';
import 'package:nexo/core/errors.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/data/api_client.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';

class SigmaRepository {
  SigmaRepository(this._api);
  final ApiClient _api;
  Future<LoginResult> login(String usuarioId, String password) async {
    final clave = base64.encode(utf8.encode(password));
    final res = await _api.post<LoginResult>(
      'Login/SesionV1',
      authorize: false,
      body: {
        'usuarioId': usuarioId,
        'clave': clave,
        'nomSys': AppConfig.nomSys,
      },
      decode: (raw) => _safeDecode(
        raw: raw,
        modelName: 'LoginResult',
        fromJson: LoginResult.fromJson,
      ),
    );
    // El servidor procesó el login y lo rechazó (success:false). Es una señal
    // POSITIVA de credenciales inválidas — distinta de un fallo de red/servidor,
    // que _send() ya habría lanzado como Network/Timeout/ServerException. Esta
    // distinción es la que permite NO cerrar sesión ante caídas transitorias.
    if (!res.success || res.data == null) {
      throw InvalidCredentialsException(res.mensaje ?? 'No se pudo iniciar sesión.');
    }
    _api.setToken(res.data!.token);
    return res.data!;
  }

  Future<Student> infoEstudiante() async {
    final res = await _api.get<Student>(
      'Estudiante/MostrarInfoEstudiante',
      decode: (raw) => _safeDecode(
        raw: raw,
        modelName: 'Student',
        fromJson: Student.fromSigmaJson,
      ),
    );
    return res.data!;
  }

  Future<UserProfile?> datosEntidad() async {
    final res = await _api.get<UserProfile>(
      'Login/GetDatosEntidad',
      decode: (raw) => _safeDecode(
        raw: raw,
        modelName: 'UserProfile',
        fromJson: UserProfile.fromJson,
      ),
    );
    return res.data;
  }

  Future<List<Term>> periodosEstudiante() async {
    final res = await _api.get<List<Term>>(
      'Recursos/ListarPeriodosEstudiante',
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'Term',
        fromJson: Term.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<ScheduleClass>> schedule({
    String year = '*',
    String periodo = '*',
  }) async {
    final res = await _api.get<List<ScheduleClass>>(
      'Intranet/ListarHorariosEstudianteIntranet/$year/$periodo',
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'ScheduleClass',
        fromJson: ScheduleClass.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<CourseGrade>> notasPeriodo(int year, int periodo) async {
    final res = await _api.get<List<CourseGrade>>(
      'Intranet/ListarNotasEstudianteIntranet/$year/$periodo',
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'CourseGrade',
        fromJson: CourseGrade.fromJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<GradesSummary?> notasResumen(String pesId, String level) async {
    final res = await _api.get<GradesSummary>(
      'Estudiante/MostrarNotasResumen/$pesId/$level',
      decode: (raw) => _safeDecode(
        raw: raw,
        modelName: 'GradesSummary',
        fromJson: GradesSummary.fromJson,
      ),
    );
    return res.data;
  }

  Future<List<TermAverage>> promediosResumen() async {
    final res = await _api.get<List<TermAverage>>(
      'Estudiante/ListarPromediosResumen',
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'TermAverage',
        fromJson: TermAverage.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<Payment>> pendingInstallments({
    String tipDI = AppConfig.tipDI,
  }) async {
    final res = await _api.get<List<Payment>>(
      'Estudiante/ListarCoutasNoVencidas',
      query: {'TipDI': tipDI},
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'Payment',
        fromJson: Payment.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<Payment>> intranetInstallments({
    String tipDI = AppConfig.tipDI,
  }) async {
    final res = await _api.get<List<Payment>>(
      'Estudiante/ListarCoutasIntranet',
      query: {'TipDI': tipDI},
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'Payment',
        fromJson: Payment.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<Fee>> tasas({String tipDI = AppConfig.tipDI}) async {
    final res = await _api.get<List<Fee>>(
      'Estudiante/ListarTasaTotal',
      query: {'TipDI': tipDI},
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'Fee',
        fromJson: Fee.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<List<Publication>> publications() async {
    final res = await _api.get<List<Publication>>(
      'Recursos/ListarPublicaciones',
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'Publication',
        fromJson: Publication.fromJson,
      ),
    );
    return res.data ?? const [];
  }

  Future<WifiCredential?> wifiCredencial() async {
    final res = await _api.get<WifiCredential>(
      'Recursos/ObtenerWifiUsuario',
      decode: (raw) {
        try {
          if (raw is Map) {
            return WifiCredential.fromJson(raw.cast<String, dynamic>());
          }
          return const WifiCredential(username: '', password: '');
        } catch (e) {
          throw DataParsingException(
            model: 'WifiCredential',
            rawData: raw,
            innerError: e,
          );
        }
      },
    );
    return res.data;
  }

  Future<GradesCount?> gradesCount(int year, int periodo) async {
    final res = await _api.get<GradesCount>(
      'Estudiante/MostrarConteoNotas/$year/$periodo',
      decode: (raw) {
        try {
          if (raw is Map) {
            return GradesCount.fromJson(raw.cast<String, dynamic>());
          }
          return const GradesCount(
            approved: 0,
            disapproved: 0,
            pending: 0,
            total: 0,
          );
        } catch (e) {
          throw DataParsingException(
            model: 'GradesCount',
            rawData: raw,
            innerError: e,
          );
        }
      },
    );
    return res.data;
  }

  Future<bool> changePassword(String actual, String nueva) async {
    final res = await _api.post<bool>(
      'Login/ChangePassword',
      body: {
        'claveActual': base64.encode(utf8.encode(actual)),
        'claveNueva': base64.encode(utf8.encode(nueva)),
        'nomSys': AppConfig.nomSys,
      },
      decode: (_) => true,
    );
    if (!res.success) {
      throw Exception(res.mensaje ?? 'No se pudo cambiar la contraseña.');
    }
    return true;
  }

  Future<List<PaymentRecord>> historicoPagos({
    String tipDI = AppConfig.tipDI,
  }) async {
    final res = await _api.get<List<PaymentRecord>>(
      'Estudiante/ListarHistorico',
      query: {'TipDI': tipDI},
      decode: (raw) => _safeDecodeList(
        raw: raw,
        modelName: 'PaymentRecord',
        fromJson: PaymentRecord.fromSigmaJson,
      ),
    );
    return res.data ?? const [];
  }

  T _safeDecode<T>({
    required Object? raw,
    required String modelName,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (raw == null) {
      throw DataParsingException(
        model: modelName,
        rawData: raw,
        innerError: 'data nulo',
      );
    }
    Object? unwrapped = raw;
    if (unwrapped is List) {
      if (unwrapped.isEmpty) {
        throw DataParsingException(
          model: modelName,
          rawData: raw,
          innerError: 'data lista vacía',
        );
      }
      unwrapped = unwrapped.first;
      if (unwrapped == null) {
        throw DataParsingException(
          model: modelName,
          rawData: raw,
          innerError: 'firstTerm elemento de la lista es null',
        );
      }
    }
    try {
      final jsonMap = (unwrapped as Map).cast<String, dynamic>();
      return fromJson(jsonMap);
    } catch (e) {
      throw DataParsingException(model: modelName, rawData: raw, innerError: e);
    }
  }

  List<T> _safeDecodeList<T>({
    required Object? raw,
    required String modelName,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (raw == null) return const [];
    if (raw is String && raw.trim().isEmpty) return const [];
    try {
      final list = raw as List;
      return list.map((e) {
        try {
          return fromJson((e as Map).cast<String, dynamic>());
        } catch (inner) {
          throw DataParsingException(
            model: modelName,
            rawData: e,
            innerError: inner,
          );
        }
      }).toList();
    } catch (e) {
      if (e is DataParsingException) rethrow;
      throw DataParsingException(
        model: '${modelName}List',
        rawData: raw,
        innerError: e,
      );
    }
  }
}
