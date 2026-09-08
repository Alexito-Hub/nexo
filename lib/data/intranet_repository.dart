import 'package:nexo/core/storage.dart';
import 'package:nexo/data/intranet_client.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';

class IntranetRepository {
  IntranetRepository(this._client);
  final IntranetClient _client;
  bool _ready = false;
  Future<bool>? _loginInFlight;
  String? _currentUser;
  static const _cacheTtl = Duration(seconds: 60);
  final Map<String, _Cached> _cache = {};
  Future<List<dynamic>> _memoPostList(
    String path,
    Map<String, String> body, {
    String? referer,
  }) {
    final key =
        '$path?${body.entries.map((e) => "${e.key}=${e.value}").join("&")}';
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.at) < _cacheTtl) {
      return cached.future;
    }
    final future = _client.postJsonList(path, body, referer: referer);
    _cache[key] = _Cached(future, now);
    future.catchError((_) {
      _cache.remove(key);
      return <dynamic>[];
    });
    return future;
  }

  Future<List<dynamic>> _memoGetList(String path, {String? referer}) {
    final key = 'GET:$path';
    final cached = _cache[key];
    final now = DateTime.now();
    if (cached != null && now.difference(cached.at) < _cacheTtl) {
      return cached.future;
    }
    final future = _client.getJsonList(path, referer: referer);
    _cache[key] = _Cached(future, now);
    future.catchError((_) {
      _cache.remove(key);
      return <dynamic>[];
    });
    return future;
  }

  void clearCache() => _cache.clear();
  String? get currentUser => _currentUser;
  Future<bool> ensureSession(String username, String password) async {
    _armReauth(username, password);
    if (_ready && _client.isLoggedIn && _currentUser == username) return true;
    final inFlight = _loginInFlight;
    if (inFlight != null) return inFlight;
    final s = AppStorage.instance;
    final savedCookies = s.intranetCookies;
    final savedUser = s.intranetUser;
    if (savedCookies != null && savedUser == username && !_client.isLoggedIn) {
      _client.importCookies(savedCookies);
      _currentUser = username;
      _ready = true;
      return true;
    }
    final future = _client.login(username, password);
    _loginInFlight = future;
    try {
      _ready = await future;
      if (_ready) {
        _currentUser = username;
        await s.setIntranetSession(_client.exportCookies(), username);
      }
      return _ready;
    } finally {
      _loginInFlight = null;
    }
  }

  void _armReauth(String username, String password) {
    _client.reauthenticate = () async {
      final ok = await _client.login(username, password);
      if (ok) {
        _currentUser = username;
        _ready = true;
        await AppStorage.instance.setIntranetSession(
          _client.exportCookies(),
          username,
        );
      }
      return ok;
    };
  }

  Future<List<ReportCardCourse>> boleta(int year, int periodo) async {
    final rows = await _memoPostList('consultarconstanciaNotasDetallado', {
      'anio': '$year',
      'periodo': '$periodo',
    }, referer: 'repRankingPromocionalEst');
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 11)
        .map(ReportCardCourse.fromRow)
        .where((c) => c.name.isNotEmpty && c.enrollmentSubjectId.isNotEmpty)
        .toList();
  }

  Future<List<CourseGrade>> boletaLegacy(int year, int periodo) async {
    final rows = await _memoPostList('consultarconstanciaNotasDetallado', {
      'anio': '$year',
      'periodo': '$periodo',
    }, referer: 'repRankingPromocionalEst');
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 24)
        .map(CourseGrade.fromLegacyRow)
        .where((n) => n.subject.isNotEmpty)
        .toList();
  }

  Future<List<ScheduleClass>> horarioMatriculados(int year, int periodo) async {
    final rows = await _memoPostList(
      'verhorariomatriz-matriculados3EstudianteEstudiante',
      {'periodo': '$year-$periodo'},
      referer: 'reportesDelEstudiante',
    );
    final docentesByCurso = <String, String>{};
    final observacionByCurso = <String, String>{};
    try {
      final det = await _memoPostList('verhorarioseleccion-detalleEstudiante', {
        'periodo': '$year-$periodo',
      }, referer: 'reportesDelEstudiante');
      for (final r in det.whereType<List<dynamic>>()) {
        if (r.isEmpty) continue;
        final name = r[0]?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        
        if (r.length >= 10) {
          final teacher = r[9]?.toString().trim() ?? '';
          if (teacher.isNotEmpty) docentesByCurso[name] = teacher;
        }
        
        // Buscar en todas las columnas alguna que parezca una observación de laboratorio o aula
        for (var i = 0; i < r.length; i++) {
          final s = r[i]?.toString().trim() ?? '';
          if (s.toUpperCase().contains('LAB_') || s.toUpperCase().contains('LABORATORIO')) {
            observacionByCurso[name] = s;
          }
        }
      }
    } catch (_) {}
    final seenIds = <String>{};
    final result = <ScheduleClass>[];
    for (final row in rows.whereType<List<dynamic>>()) {
      for (var dayIdx = 3; dayIdx < 10 && dayIdx < row.length; dayIdx++) {
        final raw = row[dayIdx]?.toString().trim() ?? '';
        if (raw.isEmpty) continue;
        final weekday = dayIdx - 2;
        final fields = raw.split('_');
        if (fields.length < 13) continue;
        final ids = fields[0].split(',');
        final n = ids.length;
        for (var i = 0; i < n; i++) {
          String at(int f) {
            if (f >= fields.length) return '';
            final v = fields[f].split(',');
            return (i < v.length ? v[i] : v.last).trim();
          }

          final id = at(0);
          if (id.isEmpty || seenIds.contains(id)) continue;
          seenIds.add(id);
          final type = at(13).toLowerCase();
          final subject = at(2);
          
          var rawLocation = at(12);
          if (type.startsWith('p') && observacionByCurso.containsKey(subject)) {
            final obs = observacionByCurso[subject]!;
            if (obs.isNotEmpty) {
              rawLocation = obs;
            }
          }
          
          final loc = ScheduleClass.parseLocation(rawLocation);
          result.add(
            ScheduleClass(
              id: id,
              nrc: at(1),
              subject: subject,
              section: at(10),
              weekday: weekday,
              dayName: const [
                '',
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
                'Sábado',
                'Domingo',
              ][weekday],
              startTime: at(8),
              endTime: at(9),
              campus: at(11),
              building: loc.building,
              room: loc.room,
              capacity: loc.capacity,
              teacher: docentesByCurso[subject] ?? '',
              typeCode: type.startsWith('p') ? 'P' : 'T',
              modality: '',
              level: '',
              note: '',
            ),
          );
        }
      }
    }
    return result;
  }

  Future<CourseGradeDetail> detalleCurso(
    int year,
    int periodo,
    String enrollmentSubjectId,
  ) async {
    final rows = await _memoPostList('consultarDetalleBoletaNotas', {
      'anio': '$year',
      'periodo': '$periodo',
      'matricula_asignatura_id': enrollmentSubjectId,
    }, referer: 'repRankingPromocionalEst');
    return CourseGradeDetail.fromRows(rows);
  }

  Future<List<RecordCourse>> recordAcademico(String codest) async {
    final rows = await _memoPostList('consultarProgresoCurricular', {
      'codest': codest,
    }, referer: 'repProgresoCurricularEst');
    return rows
        .whereType<List<dynamic>>()
        .map(RecordCourse.fromRow)
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  Future<EnrollmentCertificate> constanciaMatricula(
    int year,
    int periodo,
  ) async {
    final rows = await _memoPostList(
      'consultarConstanciaMatriculaEstudiante',
      {'periodo': '$year-$periodo'},
      referer: 'pg_reportesDelEstudiante',
    );
    return EnrollmentCertificate.fromRows(rows);
  }

  Future<PaymentSchedule> cronogramaPagos({int installments = 5}) async {
    final rows = await _memoGetList(
      'consultarCuotasEstudiante?installments=$installments',
      referer: 'pg_reportesDelEstudiante',
    );
    return PaymentSchedule.fromRows(rows);
  }

  Future<List<Payment>> cuotasPagosLista({
    int installments = 30,
    String? termLabel,
  }) async {
    final rows = await _memoGetList(
      'consultarCuotasEstudiante?installments=$installments',
      referer: 'pg_reportesDelEstudiante',
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 5)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map((r) => Payment.fromIntranetRow(r, termLabel: termLabel))
        .toList();
  }

  Map<String, String> _deudaBody() {
    final u = _currentUser ?? '';
    return {'codEst': u};
  }

  static const _deudaRef = 'consultaEstadoDeuda_Estudiante';
  Future<List<Payment>> pensionesPendientes() async {
    final rows = await _memoPostList(
      'consultarPensiones',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 6)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map(Payment.fromDebtRow)
        .toList();
  }

  Future<List<Payment>> pensionesVencidas() async {
    final rows = await _memoPostList(
      'consultartotalPensiones',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 6)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map(Payment.fromDebtRow)
        .toList();
  }

  Future<List<Fee>> tasasIntranet() async {
    final rows = await _memoPostList(
      'consultarTasas',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 3)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map((r) {
          String at(int i) =>
              (i < r.length ? r[i]?.toString() ?? '' : '').trim();
          return Fee(
            description: at(0),
            currency: at(1),
            amount: double.tryParse(at(2)) ?? 0,
            note: at(3),
          );
        })
        .toList();
  }

  Future<List<Payment>> matriculaVencida() async {
    final rows = await _memoPostList(
      'consultarMatricula',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 3)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .where((r) => r[0]?.toString().trim() != '--')
        .map((r) {
          String at(int i) =>
              (i < r.length ? r[i]?.toString() ?? '' : '').trim();
          final amount = double.tryParse(at(2)) ?? 0;
          return Payment(
            description: at(0),
            currency: at(1),
            amount: amount,
            lateFee: 0,
            total: amount,
            note: 'Matrícula vencida',
            dueDateRaw: '',
          );
        })
        .toList();
  }

  Future<List<PaymentRecord>> historicoPagos() async {
    final rows = await _memoPostList(
      'consultarUltimasOperaciones',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 9)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map(PaymentRecord.fromIntranetRow)
        .toList();
  }

  Future<double> totalPensiones() async {
    final rows = await _memoPostList(
      'consultartotalPensiones',
      const {},
      referer: 'inicio',
    );
    final r = rows.whereType<List<dynamic>>().firstWhere(
      (r) =>
          r.isNotEmpty &&
          !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
      orElse: () => const [],
    );
    if (r.isEmpty) return 0;
    return double.tryParse(r.first?.toString().trim() ?? '') ?? 0;
  }

  Future<List<Term>> periodosMatriculados() async {
    final rows = await _memoPostList(
      'consultarPeriodosMatriculados',
      const {},
      referer: 'inicio',
    );
    final valid = rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 2)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .toList();
    return List.generate(valid.length, (i) {
      final t = Term.fromIntranetRow(valid[i]);
      if (i != valid.length - 1) return t;
      return Term(
        id: t.id,
        label: t.label,
        year: t.year,
        number: t.number,
        isActive: true,
      );
    });
  }

  Future<List<Payment>> reduccionDeuda() async {
    final rows = await _memoPostList(
      'consultarReduccionDeuda',
      _deudaBody(),
      referer: _deudaRef,
    );
    return rows
        .whereType<List<dynamic>>()
        .where((r) => r.length >= 3)
        .where(
          (r) => !(r[0]?.toString().toLowerCase().contains('no hay') ?? false),
        )
        .map((r) {
          String at(int i) =>
              (i < r.length ? r[i]?.toString() ?? '' : '').trim();
          final amount = double.tryParse(at(2)) ?? 0;
          return Payment(
            description: at(1).isNotEmpty ? at(1) : 'Descuento',
            currency: 'S/.',
            amount: -amount,
            lateFee: 0,
            total: -amount,
            note: at(3),
            dueDateRaw: at(0),
          );
        })
        .toList();
  }

  Future<Student?> infoEstudiante({
    required int year,
    required int periodo,
  }) async {
    List<dynamic> basico = const [];
    try {
      final rows = await _memoGetList(
        'datosEstudianteMatriculado',
        referer: 'inicio',
      );
      if (rows.isNotEmpty && rows.first is List) basico = rows.first as List;
    } catch (_) {}
    final certificate = await constanciaMatricula(year, periodo);
    if (certificate.code.isEmpty && basico.isEmpty) return null;
    return Student.fromIntranetData(
      datosBasico: basico,
      certificate: certificate,
    );
  }

  void invalidate() {
    _ready = false;
    _cache.clear();
  }
}

class _Cached {
  _Cached(this.future, this.at);
  final Future<List<dynamic>> future;
  final DateTime at;
}
