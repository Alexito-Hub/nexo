import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:nexo/core/data/resolver.dart';
import 'package:nexo/core/error_handler.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/cache_manager.dart';
import 'package:nexo/data/teacher_repository.dart';
import 'package:nexo/data/intranet_repository.dart';
import 'package:nexo/data/sigma_repository.dart';
import 'package:nexo/domain/grade_calculator.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/passing_rule.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/domain/dashboard_widget_config.dart';

class AsyncValue<T> {
  final T? value;
  final bool loading;
  final Object? error;
  const AsyncValue.idle() : value = null, loading = false, error = null;
  const AsyncValue.loading([T? prev])
    : value = prev,
      loading = true,
      error = null;
  const AsyncValue.data(T data) : value = data, loading = false, error = null;
  const AsyncValue.failure(Object e, [T? prev])
    : value = prev,
      loading = false,
      error = e;
  bool get hasValue => value != null;

  /// Aún no se inició ninguna carga: sin valor, sin error y sin loading.
  /// La UI debe tratarlo como "cargando" (esqueleto), no como vacío.
  bool get isIdle => !loading && value == null && error == null;

  /// La UI debe mostrar esqueleto: cargando o todavía sin iniciar.
  bool get showSkeleton => (loading || isIdle) && value == null;
}

class AppStore extends ChangeNotifier {
  AppStore(
    this._repo, {
    required CacheManager cache,
    required ErrorHandler errorHandler,
    IntranetRepository? intranet,
    TeacherRepository? teacher,
  }) : _cache = cache,
       _errorHandler = errorHandler,
       _intranet = intranet,
       _teacher = teacher {
    // El layout del dashboard debe cargarse SIEMPRE (no solo al hidratar):
    // tras un login fresco `hydrateFromCache` no corre y el Home quedaba con
    // spans por defecto rotos (tarjetas aplastadas en móvil).
    _loadDashboardLayout();
  }
  DataSource<T> _sigma<T>(SourceId id, Future<T> Function() fn) =>
      DataSource(id: id, fetch: fn);
  List<DataSource<T>> _intra<T>(Future<T> Function(IntranetRepository) fn) {
    final r = _intranet;
    if (r == null) return const [];
    return [
      DataSource(
        id: 'intranet',
        available: () async {
          final s = AppStorage.instance;
          return s.credUser != null && s.credPass != null;
        },
        fetch: () async {
          final s = AppStorage.instance;
          final ok = await r.ensureSession(s.credUser!, s.credPass!);
          if (!ok) throw const NetworkException('Sesión Intranet falló.');
          return fn(r);
        },
      ),
    ];
  }

  static bool _emptyList(List l) => l.isEmpty;
  late final Resolver<Student> _studentRes = Resolver(
    sources: [
      ..._intra((r) async {
        final p = periodoActivo;
        final now = DateTime.now();
        final s = await r.infoEstudiante(
          year: p?.year ?? now.year,
          periodo: p?.number ?? (now.month <= 7 ? 1 : 2),
        );
        if (s == null) throw const NetworkException('Intranet sin perfil.');
        return s;
      }),
      _sigma('sigma', _repo.infoEstudiante),
    ],
    merge: MergeStrategies.fold<Student>((a, b) => a.mergeWith(b)),
    isEmpty: (s) => s.id.isEmpty && s.fullName.isEmpty,
  );
  late final Resolver<List<Payment>> _cuotasRes = Resolver(
    sources: [..._intra((r) => r.pensionesPendientes())],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  late final Resolver<List<Payment>> _vencidasRes = Resolver(
    sources: [
      ..._intra((r) async {
        final results = await Future.wait([
          r.pensionesVencidas(),
          r.matriculaVencida(),
        ]);
        return results.expand((e) => e).toList();
      }),
    ],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  late final Resolver<List<PaymentRecord>> _historicoRes = Resolver(
    sources: [..._intra((r) => r.historicoPagos())],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  late final Resolver<List<Fee>> _tasasRes = Resolver(
    sources: [..._intra((r) => r.tasasIntranet())],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  late final Resolver<List<Term>> _periodosRes = Resolver(
    sources: [
      ..._intra((r) => r.periodosMatriculados()),
      _sigma('sigma', _repo.periodosEstudiante),
    ],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  late final Resolver<List<ScheduleClass>> _horarioRes = Resolver(
    sources: [
      ..._intra((r) {
        final p = periodoActivo;
        final now = DateTime.now();
        return r.horarioMatriculados(
          p?.year ?? now.year,
          p?.number ?? (now.month <= 7 ? 1 : 2),
        );
      }),
      _sigma('sigma', () => _repo.schedule()),
    ],
    merge: MergeStrategies.firstWins,
    isEmpty: _emptyList,
  );
  final SigmaRepository _repo;
  final CacheManager _cache;
  final ErrorHandler _errorHandler;
  final IntranetRepository? _intranet;
  final TeacherRepository? _teacher;
  void Function(String course, String grade)? onGradeChange;
  void _checkGrades(Iterable<(String, String)> items) {
    final entries = items.where((e) => e.$2.isNotEmpty && e.$2 != '—');
    if (entries.isEmpty) return;
    final s = AppStorage.instance;
    Map<String, dynamic> prev = {};
    final raw = s.gradeSnapshot;
    final firstTime = raw == null;
    if (raw != null) {
      try {
        prev = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    final next = Map<String, dynamic>.from(prev);
    for (final (course, grade) in entries) {
      final before = prev[course] as String?;
      next[course] = grade;
      if (!firstTime && before != grade && onGradeChange != null) {
        onGradeChange!(course, grade);
      }
    }
    s.setGradeSnapshot(jsonEncode(next));
  }

  AsyncValue<Student> profile = const AsyncValue.idle();
  AsyncValue<List<Term>> periodos = const AsyncValue.idle();
  AsyncValue<List<ScheduleClass>> schedule = const AsyncValue.idle();
  AsyncValue<GradesSummary> resumen = const AsyncValue.idle();
  AsyncValue<List<TermAverage>> promedios = const AsyncValue.idle();
  AsyncValue<List<RecordCourse>> record = const AsyncValue.idle();
  AsyncValue<List<Payment>> pendingInstallments = const AsyncValue.idle();
  AsyncValue<List<Payment>> intranetInstallments = const AsyncValue.idle();
  AsyncValue<List<Fee>> tasas = const AsyncValue.idle();
  AsyncValue<List<PaymentRecord>> historico = const AsyncValue.idle();
  AsyncValue<EnrollmentCertificate> certificate = const AsyncValue.idle();
  AsyncValue<PaymentSchedule> paymentSchedule = const AsyncValue.idle();
  AsyncValue<List<Publication>> publications = const AsyncValue.idle();
  AsyncValue<WifiCredential> wifi = const AsyncValue.idle();
  AsyncValue<GradesCount> gradesCount = const AsyncValue.idle();
  AsyncValue<TeacherInfo> teacherInfo = const AsyncValue.idle();
  AsyncValue<List<TeacherSubject>> teacherSubjects = const AsyncValue.idle();
  AsyncValue<List<ScheduleClass>> teacherSchedule = const AsyncValue.idle();
  final Map<String, AsyncValue<List<TeacherStudent>>> _teacherStudents = {};
  AsyncValue<List<TeacherStudent>> alumnosDe(String cleAuto) =>
      _teacherStudents[cleAuto] ?? const AsyncValue.idle();
  final Map<String, AsyncValue<List<CourseGrade>>> _notasByPeriodo = {};
  AsyncValue<List<CourseGrade>> notasOf(int year, int periodo) =>
      _notasByPeriodo['$year-$periodo'] ?? const AsyncValue.idle();
  Term? get periodoActivo {
    final list = periodos.value;
    if (list == null) return null;
    try {
      return list.firstWhere((p) => p.isActive);
    } catch (_) {
      return null;
    }
  }

  double? get promedioAcumulado {
    // Preferimos el promedio oficial del resumen académico (ponderado por
    // créditos, calculado por la universidad). El promedio simple de los
    // promedios por ciclo solo queda como respaldo.
    final oficial = resumen.value?.average;
    if (oficial != null && oficial > 0) return oficial;
    final list = promedios.value;
    if (list == null) return null;
    final activo = periodoActivo;
    return GradeCalculator.promedioAcumulado(
      list,
      activeYear: activo?.year,
      activeNumber: activo?.number,
    );
  }

  double? get promedioCicloActual {
    final activo = periodoActivo;
    if (activo == null) return null;
    if (isNewModel(activo.year, activo.number)) {
      final courses = boletaOf(activo.year, activo.number).value;
      if (courses == null) return null;
      // `realAverageOf` ya devuelve nota vigesimal (los talleres 0-100 caen a
      // su nota vigesimal oficial), así que se pueden promediar directamente.
      return GradeCalculator.promedioPonderadoBoleta(
        courses,
        gradeOf: realAverageOf,
      );
    }
    final courses = boletaLegacyOf(activo.year, activo.number).value;
    if (courses == null) return null;
    return GradeCalculator.promedioPonderadoLegacy(courses);
  }

  /// Promedio a mostrar para un curso de la boleta (modelo nuevo).
  /// El servidor redondea el promedio del curso (11.60 → 12); para cursos en
  /// proceso usamos el promedio real calculado desde sus unidades (si el
  /// detalle ya está cargado) para que lista y detalle muestren lo mismo.
  /// Los cursos cerrados conservan la nota oficial.
  /// Nota a mostrar (y a promediar) para un curso de la boleta, siempre en
  /// escala vigesimal. En proceso: promedio real desde las unidades si está en
  /// rango; cerrado o taller (0-100): la nota vigesimal oficial. Así lista,
  /// detalle y promedio del ciclo muestran exactamente lo mismo.
  double? realAverageOf(ReportCardCourse c) {
    if (c.inProgress) {
      final computed = _detalle[c.enrollmentSubjectId]?.value?.computedAverage;
      if (computed != null && computed >= 0 && computed <= 20.5)
        return computed;
    }
    return c.vigesimalAverage;
  }

  int? get approvedCredits {
    final p = profile.value?.creditsApproved;
    final r = resumen.value?.approvedCredits;
    if (p != null && p > 0) return p;
    if (r != null && r > 0) return r;
    return p ?? r;
  }

  int? get totalCredits => resumen.value?.totalCredits;
  void _notify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<T?> _wrap<T>(
    Future<T> Function() remote,
    AsyncValue<T> Function() get,
    void Function(AsyncValue<T>) set, {
    Future<T?> Function()? cached,
    void Function(T value)? persist,
    required String operationName,
  }) async {
    set(AsyncValue.loading(get().value));
    _notify();
    try {
      final v = await _errorHandler.withFallback<T>(
        remote: remote,
        cached: cached ?? () => Future.value(null),
        operationName: operationName,
      );
      set(AsyncValue.data(v));
      _notify();
      persist?.call(v);
      return v;
    } catch (e) {
      set(AsyncValue.failure(e, get().value));
      _notify();
      return null;
    }
  }

  static const _ckProfile = 'profile';
  static const _ckPeriodos = 'periodos';
  static const _ckHorario = 'schedule';
  static const _ckResumen = 'resumen';
  static const _ckPromedios = 'promedios';
  static const _ckCuotasPend = 'cuotasPend';
  void _setStorageCache(String key, Object data) =>
      AppStorage.instance.setCache(key, data);

  static const List<DashboardWidgetConfig> _defaultDashboardLayout = [
    DashboardWidgetConfig(id: 'stats_promedio', span: 2),
    DashboardWidgetConfig(id: 'stats_creditos', span: 2),
    DashboardWidgetConfig(id: 'stats_clases_hoy', span: 2),
    DashboardWidgetConfig(id: 'stats_pagos', span: 2),
    DashboardWidgetConfig(id: 'next_class', span: 4),
    DashboardWidgetConfig(id: 'today_classes', span: 4),
    DashboardWidgetConfig(id: 'pending_payments', span: 4),
  ];
  List<DashboardWidgetConfig> dashboardLayout = [..._defaultDashboardLayout];

  void _loadDashboardLayout() {
    final s = AppStorage.instance.dashboardConfigJson;
    if (s != null) {
      try {
        final list = (jsonDecode(s) as List)
            .map(
              (e) => DashboardWidgetConfig.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        if (list.isNotEmpty) {
          // Migración automática si existe stats_grid
          final i = list.indexWhere((e) => e.id == 'stats_grid');
          if (i >= 0) {
            list.removeAt(i);
            list.insertAll(i, [
              const DashboardWidgetConfig(id: 'stats_promedio', span: 1),
              const DashboardWidgetConfig(id: 'stats_creditos', span: 1),
              const DashboardWidgetConfig(id: 'stats_clases_hoy', span: 1),
              const DashboardWidgetConfig(id: 'stats_pagos', span: 1),
            ]);
          }
          // Validar que existan
          final defaults = [
            'stats_promedio',
            'stats_creditos',
            'stats_clases_hoy',
            'stats_pagos',
            'next_class',
            'today_classes',
            'pending_payments',
          ];
          for (final d in defaults) {
            if (!list.any((e) => e.id == d)) {
              list.add(
                DashboardWidgetConfig(
                  id: d,
                  span: d.startsWith('stats_') ? 2 : 4,
                ),
              );
            }
          }
          for (var i = 0; i < list.length; i++) {
            if (!list[i].id.startsWith('stats_') && list[i].span < 4) {
              list[i] = list[i].copyWith(span: 4);
            }
          }
          dashboardLayout = list;
          return;
        }
      } catch (_) {}
    }
    dashboardLayout = [..._defaultDashboardLayout];
  }

  void saveDashboardLayout() {
    final s = jsonEncode(dashboardLayout.map((e) => e.toJson()).toList());
    AppStorage.instance.setDashboardConfigJson(s);
    _notify();
  }

  String? editingDashboardWidgetId;
  void setEditingDashboardWidget(String? id) {
    editingDashboardWidgetId = id;
    _notify();
  }

  void reorderDashboard(String oldId, String newId, {bool save = true}) {
    final oldIndex = dashboardLayout.indexWhere((w) => w.id == oldId);
    int newIndex = dashboardLayout.indexWhere((w) => w.id == newId);
    if (oldIndex == -1 || newIndex == -1 || oldIndex == newIndex) return;

    final item = dashboardLayout.removeAt(oldIndex);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    dashboardLayout.insert(newIndex, item);

    if (save) saveDashboardLayout();
    _notify();
  }

  void setDashboardWidgetSpan(String id, int span) {
    final i = dashboardLayout.indexWhere((e) => e.id == id);
    if (i >= 0) {
      if (dashboardLayout[i].span != span) {
        dashboardLayout[i] = dashboardLayout[i].copyWith(span: span);
        saveDashboardLayout();
      }
    }
  }

  Future<void> hydrateFromCache() async {
    final s = AppStorage.instance;
    _loadDashboardLayout();
    try {
      final cached = await _cache.getStudent();
      if (cached != null) {
        profile = AsyncValue.data(cached);
        _notify();
      }
    } catch (_) {}
    final p = s.getCache(_ckProfile);
    if (p is Map && profile.value == null) {
      profile = AsyncValue.data(Student.fromJson(p.cast<String, dynamic>()));
    }
    final per = s.getCache(_ckPeriodos);
    if (per is List) {
      periodos = AsyncValue.data(
        per
            .map((e) => Term.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    }
    final h = s.getCache(_ckHorario);
    if (h is List) {
      schedule = AsyncValue.data(
        h
            .map(
              (e) => ScheduleClass.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );
    }
    final r = s.getCache(_ckResumen);
    if (r is Map) {
      resumen = AsyncValue.data(
        GradesSummary.fromJson(r.cast<String, dynamic>()),
      );
    }
    final pr = s.getCache(_ckPromedios);
    if (pr is List) {
      promedios = AsyncValue.data(
        pr
            .map(
              (e) => TermAverage.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );
    }
    final cp = s.getCache(_ckCuotasPend);
    if (cp is List) {
      pendingInstallments = AsyncValue.data(
        cp
            .map(
              (e) => Payment.fromSigmaJson((e as Map).cast<String, dynamic>()),
            )
            .toList(),
      );
    }
    if (profile.hasValue || schedule.hasValue || pendingInstallments.hasValue) {
      _notify();
    }
  }

  Future<void> loadHomeEssentials() async {
    // Los periodos van primero: `periodoActivo` alimenta al perfil, horario y
    // boleta. Cargarlos en paralelo provocaba que esas fuentes consultaran un
    // periodo adivinado por fecha y a veces volvieran vacías ("no aparecen
    // los datos hasta recargar").
    await loadPeriodos();
    await Future.wait([
      loadProfile(),
      loadHorarioActual(),
      loadCuotasPendientes(),
      loadPromedios(),
    ]);
    final p = profile.value;
    if (p != null && p.studyPlan.isNotEmpty && p.level.isNotEmpty) {
      await loadResumen(p.studyPlan, p.level);
    }
    unawaited(checkActiveBoleta());
  }

  /// Reintenta solo lo que falló (o nunca llegó a cargar) en el Home.
  /// Se invoca al recuperar conectividad para no obligar al usuario a
  /// refrescar manualmente.
  Future<void> retryFailedEssentials() async {
    bool needs(AsyncValue s) => !s.loading && !s.hasValue;
    if (needs(periodos)) await loadPeriodos();
    final tasks = <Future<void>>[
      if (needs(profile)) loadProfile(),
      if (needs(schedule)) loadHorarioActual(),
      if (needs(pendingInstallments)) loadCuotasPendientes(),
      if (needs(promedios)) loadPromedios(),
    ];
    if (tasks.isEmpty) return;
    await Future.wait(tasks);
    final p = profile.value;
    if (needs(resumen) &&
        p != null &&
        p.studyPlan.isNotEmpty &&
        p.level.isNotEmpty) {
      await loadResumen(p.studyPlan, p.level);
    }
    unawaited(checkActiveBoleta());
  }

  Future<void> checkActiveBoleta() async {
    final activo = periodoActivo;
    if (activo == null) return;
    if (isNewModel(activo.year, activo.number)) {
      await loadBoleta(activo.year, activo.number);
    } else {
      await loadBoletaLegacy(activo.year, activo.number);
    }
  }

  Future<Student?> loadProfile() => _wrap(
    () => _studentRes.load(),
    () => profile,
    (v) => profile = v,
    cached: _cache.getStudent,
    persist: _cache.saveStudent,
    operationName: 'loadProfile',
  );
  Future<List<Term>?> loadPeriodos() async {
    final result = await _wrap(
      () => _resolveOrEmpty(_periodosRes),
      () => periodos,
      (v) => periodos = v,
      cached: () => _cache.getPeriodos(),
      persist: (v) => _cache.savePeriodos(v),
      operationName: 'loadPeriodos',
    );
    // El periodo más antiguo es la cohorte de ingreso, y de ahí sale qué nota
    // aprueba para este estudiante.
    PassingRule.resolveFrom(periodos.value);
    return result;
  }
  Future<List<ScheduleClass>?> loadHorarioActual() => _wrap(
    () => _resolveOrEmpty(_horarioRes),
    () => schedule,
    (v) => schedule = v,
    cached: () => _cache.getHorario(),
    persist: (v) => _cache.saveHorario(v),
    operationName: 'loadHorarioActual',
  );
  Future<GradesSummary?> loadResumen(String pesId, String level) => _wrap(
    () => _repo
        .notasResumen(pesId, level)
        .then(
          (v) =>
              v ??
              const GradesSummary(
                average: 0,
                approvedCredits: 0,
                totalCredits: 0,
                enrollmentCount: 0,
              ),
        ),
    () => resumen,
    (v) => resumen = v,
    cached: () async {
      final raw = AppStorage.instance.getCache(_ckResumen);
      if (raw is Map)
        return GradesSummary.fromJson(raw.cast<String, dynamic>());
      return null;
    },
    persist: (v) => _setStorageCache(_ckResumen, v.toJson()),
    operationName: 'loadResumen',
  );
  Future<List<TermAverage>?> loadPromedios() => _wrap(
    _repo.promediosResumen,
    () => promedios,
    (v) => promedios = v,
    cached: () => _cache.getPromedios(),
    persist: (v) => _cache.savePromedios(v),
    operationName: 'loadPromedios',
  );
  final Map<String, AsyncValue<List<ReportCardCourse>>> _boleta = {};
  final Map<String, AsyncValue<CourseGradeDetail>> _detalle = {};
  final Map<String, AsyncValue<List<CourseGrade>>> _boletaLegacy = {};
  AsyncValue<List<ReportCardCourse>> boletaOf(int year, int periodo) =>
      _boleta['$year-$periodo'] ?? const AsyncValue.idle();
  AsyncValue<List<CourseGrade>> boletaLegacyOf(int year, int periodo) =>
      _boletaLegacy['$year-$periodo'] ?? const AsyncValue.idle();
  Future<void> loadBoletaLegacy(int year, int periodo) async {
    final key = '$year-$periodo';
    _boletaLegacy[key] = AsyncValue.loading(_boletaLegacy[key]?.value);
    _notify();
    try {
      final data = await _errorHandler.withFallback<List<CourseGrade>>(
        remote: () => Resolver<List<CourseGrade>>(
          sources: [
            ..._intra((r) => r.boletaLegacy(year, periodo)),
            _sigma('sigma', () => _repo.notasPeriodo(year, periodo)),
          ],
          merge: MergeStrategies.firstWins,
          isEmpty: _emptyList,
        ).load(),
        cached: () =>
            _cache.getBoletaLegacy(year.toString(), periodo.toString()),
        operationName: 'loadBoletaLegacy($year, $periodo)',
      );
      _boletaLegacy[key] = AsyncValue.data(data);
      _checkGrades(data.map((n) => (n.subject, n.currentGradeText)));
      await _cache.saveBoletaLegacy(year.toString(), periodo.toString(), data);
    } catch (e) {
      _boletaLegacy[key] = AsyncValue.failure(e, _boletaLegacy[key]?.value);
    }
    _notify();
  }

  AsyncValue<CourseGradeDetail> detalleOf(String id) =>
      _detalle[id] ?? const AsyncValue.idle();
  Future<void> loadBoleta(int year, int periodo) async {
    final key = '$year-$periodo';
    _boleta[key] = AsyncValue.loading(_boleta[key]?.value);
    _notify();
    try {
      final data = await _errorHandler.withFallback<List<ReportCardCourse>>(
        remote: () => Resolver<List<ReportCardCourse>>(
          sources: _intra((r) => r.boleta(year, periodo)),
          merge: MergeStrategies.firstWins,
          isEmpty: _emptyList,
        ).load(),
        cached: () => _cache.getBoleta(year.toString(), periodo.toString()),
        operationName: 'loadBoleta($year, $periodo)',
      );
      _boleta[key] = AsyncValue.data(data);
      _checkGrades(data.map((c) => (c.name, c.promedioText)));
      await _cache.saveBoleta(year.toString(), periodo.toString(), data);
      // Trae el detalle de los cursos en proceso para poder mostrar el
      // promedio real (con decimales) en la lista, no el redondeado.
      unawaited(_prefetchDetalles(year, periodo, data));
    } catch (e) {
      _boleta[key] = AsyncValue.failure(e, _boleta[key]?.value);
    }
    _notify();
  }

  Future<void> _prefetchDetalles(
    int year,
    int periodo,
    List<ReportCardCourse> courses,
  ) async {
    for (final c in courses.where((c) => c.inProgress)) {
      if (_detalle[c.enrollmentSubjectId]?.hasValue ?? false) continue;
      await loadDetalle(year, periodo, c.enrollmentSubjectId);
    }
  }

  Future<void> loadDetalle(
    int year,
    int periodo,
    String enrollmentSubjectId,
  ) async {
    final id = enrollmentSubjectId;
    if (_detalle[id]?.loading == true) return;
    _detalle[id] = AsyncValue.loading(_detalle[id]?.value);
    _notify();
    try {
      final data = await Resolver<CourseGradeDetail>(
        sources: _intra((r) => r.detalleCurso(year, periodo, id)),
        merge: MergeStrategies.firstWins,
      ).load();
      _detalle[id] = AsyncValue.data(data);
    } catch (e) {
      _detalle[id] = AsyncValue.failure(e, _detalle[id]?.value);
    }
    _notify();
  }

  Future<List<RecordCourse>?> loadRecord() => _wrap<List<RecordCourse>>(
    () {
      final codest = profile.value?.id.isNotEmpty == true
          ? profile.value!.id
          : AppStorage.instance.credUser ?? '';
      return Resolver<List<RecordCourse>>(
        sources: _intra((r) => r.recordAcademico(codest)),
        merge: MergeStrategies.firstWins,
        isEmpty: _emptyList,
      ).load();
    },
    () => record,
    (v) => record = v,
    operationName: 'loadRecord',
  );
  Future<List<T>> _resolveOrEmpty<T>(Resolver<List<T>> r) async {
    try {
      return await r.load();
    } on NoDataAvailableException catch (e) {
      if (e.cause == null) return const [];
      rethrow;
    }
  }

  Future<List<Payment>?> loadCuotasPendientes() => _wrap(
    () => _resolveOrEmpty(_cuotasRes),
    () => pendingInstallments,
    (v) => pendingInstallments = v,
    cached: () => _cache.getPagos(),
    persist: (v) => _cache.savePagos(v),
    operationName: 'loadCuotasPendientes',
  );
  Future<List<Payment>?> loadCuotasIntranet() => _wrap(
    () => _resolveOrEmpty(_vencidasRes),
    () => intranetInstallments,
    (v) => intranetInstallments = v,
    operationName: 'loadCuotasIntranet',
  );
  Future<List<Fee>?> loadTasas() => _wrap(
    () => _resolveOrEmpty(_tasasRes),
    () => tasas,
    (v) => tasas = v,
    operationName: 'loadTasas',
  );
  Future<List<PaymentRecord>?> loadHistorico() => _wrap(
    () => _resolveOrEmpty(_historicoRes),
    () => historico,
    (v) => historico = v,
    operationName: 'loadHistorico',
  );
  Future<EnrollmentCertificate?> loadCertificate({int? year, int? periodo}) {
    final p = periodoActivo;
    final a = year ?? p?.year ?? 0;
    final per = periodo ?? p?.number ?? 0;
    return _wrap(
      () => Resolver<EnrollmentCertificate>(
        sources: _intra((r) => r.constanciaMatricula(a, per)),
        merge: MergeStrategies.firstWins,
      ).load(),
      () => certificate,
      (v) => certificate = v,
      operationName: 'loadCertificate',
    );
  }

  Future<PaymentSchedule?> loadPaymentSchedule() => _wrap(
    () => Resolver<PaymentSchedule>(
      sources: _intra((r) => r.cronogramaPagos()),
      merge: MergeStrategies.firstWins,
    ).load(),
    () => paymentSchedule,
    (v) => paymentSchedule = v,
    operationName: 'loadPaymentSchedule',
  );
  Future<List<Publication>?> loadPublications() => _wrap(
    _repo.publications,
    () => publications,
    (v) => publications = v,
    operationName: 'loadPublications',
  );
  Future<WifiCredential?> loadWifi() => _wrap<WifiCredential>(
    () async {
      final w = await _repo.wifiCredencial();
      return w ?? const WifiCredential(username: '', password: '');
    },
    () => wifi,
    (v) => wifi = v,
    operationName: 'loadWifi',
  );
  Future<GradesCount?> loadGradesCount() async {
    final p = periodoActivo;
    if (p == null) return null;
    return _wrap<GradesCount>(
      () async {
        final c = await _repo.gradesCount(p.year, p.number);
        return c ??
            const GradesCount(
              approved: 0,
              disapproved: 0,
              pending: 0,
              total: 0,
            );
      },
      () => gradesCount,
      (v) => gradesCount = v,
      operationName: 'loadGradesCount',
    );
  }

  TeacherRepository _teacherReady() {
    final d = _teacher;
    if (d == null) {
      throw Exception('Teacher module is not available.');
    }
    return d;
  }

  Future<TeacherInfo?> loadTeacherInfo() => _wrap<TeacherInfo>(
    () async {
      final v = await _teacherReady().infoDocente();
      return v ?? const TeacherInfo(code: '', firstName: '', lastName: '');
    },
    () => teacherInfo,
    (v) => teacherInfo = v,
    cached: () => _cache.getDocenteInfo(),
    persist: (v) => _cache.saveDocenteInfo(v),
    operationName: 'loadTeacherInfo',
  );
  Future<List<TeacherSubject>?> loadTeacherSubjects() => _wrap(
    () => _teacherReady().asignaturas(),
    () => teacherSubjects,
    (v) => teacherSubjects = v,
    cached: () => _cache.getDocenteCursos(),
    persist: (v) => _cache.saveDocenteCursos(v),
    operationName: 'loadTeacherSubjects',
  );
  Future<List<ScheduleClass>?> loadDocenteHorario() => _wrap(
    () => _teacherReady().getHorario(),
    () => teacherSchedule,
    (v) => teacherSchedule = v,
    cached: () => _cache.getDocenteHorario(),
    persist: (v) => _cache.saveDocenteHorario(v),
    operationName: 'loadDocenteHorario',
  );
  Future<void> loadDocenteAlumnos(String cleAuto) async {
    _teacherStudents[cleAuto] = AsyncValue.loading(
      _teacherStudents[cleAuto]?.value,
    );
    _notify();
    try {
      final v = await _errorHandler.withFallback<List<TeacherStudent>>(
        remote: () => _teacherReady().estudiantesSeccion(cleAuto),
        cached: () => _cache.getDocenteAlumnos(cleAuto),
        operationName: 'loadDocenteAlumnos($cleAuto)',
      );
      _teacherStudents[cleAuto] = AsyncValue.data(v);
      await _cache.saveDocenteAlumnos(cleAuto, v);
    } catch (e) {
      _teacherStudents[cleAuto] = AsyncValue.failure(
        e,
        _teacherStudents[cleAuto]?.value,
      );
    }
    _notify();
  }

  Future<String?> updateDocenteNota({
    required String cleAuto,
    required String codigoAlumno,
    required String grade,
  }) async {
    try {
      await _teacherReady().updateNota(
        cleAuto: cleAuto,
        codigoAlumno: codigoAlumno,
        grade: grade,
      );
      await loadDocenteAlumnos(cleAuto);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<EvaluationGrade>> docenteNotasDetalle({
    required String cleAuto,
    required String codigoAlumno,
  }) => _teacherReady().notasDetalle(
    cleAuto: cleAuto,
    codigoAlumno: codigoAlumno,
  );
  Future<String?> updateDocenteEvaluacion({
    required String cleAuto,
    required String codigoAlumno,
    required String codigoEvaluacion,
    required String grade,
  }) async {
    try {
      await _teacherReady().updateEvaluacion(
        cleAuto: cleAuto,
        codigoAlumno: codigoAlumno,
        codigoEvaluacion: codigoEvaluacion,
        grade: grade,
      );
      await loadDocenteAlumnos(cleAuto);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<DailyAttendance>> docenteAsistenciaAlumno({
    required String cleAuto,
    required String codigoAlumno,
  }) => _teacherReady().asistenciaAlumno(
    cleAuto: cleAuto,
    codigoAlumno: codigoAlumno,
  );
  Future<Map<String, String>> docenteAsistenciaDia({
    required String cleAuto,
    required DateTime date,
  }) => _teacherReady().asistenciaDelDia(cleAuto: cleAuto, date: date);
  Future<String?> guardarAsistenciaDia({
    required String cleAuto,
    required DateTime date,
    required Map<String, String> estados,
  }) async {
    try {
      await _teacherReady().guardarAsistenciaDelDia(
        cleAuto: cleAuto,
        date: date,
        estados: estados,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  bool get tieneDocente => _teacher != null;
  Future<void> changePassword(String actual, String nueva) =>
      _repo.changePassword(actual, nueva);
  Future<List<CourseGrade>?> loadNotas(int year, int periodo) async {
    final key = '$year-$periodo';
    final prev = _notasByPeriodo[key]?.value;
    _notasByPeriodo[key] = AsyncValue.loading(prev);
    _notify();
    try {
      final v = await _errorHandler.withFallback<List<CourseGrade>>(
        remote: () => Resolver<List<CourseGrade>>(
          sources: [
            ..._intra((r) => r.boletaLegacy(year, periodo)),
            _sigma('sigma', () => _repo.notasPeriodo(year, periodo)),
          ],
          merge: MergeStrategies.firstWins,
          isEmpty: _emptyList,
        ).load(),
        cached: () =>
            _cache.getBoletaLegacy(year.toString(), periodo.toString()),
        operationName: 'loadNotas($year, $periodo)',
      );
      _notasByPeriodo[key] = AsyncValue.data(v);
      _notify();
      await _cache.saveBoletaLegacy(year.toString(), periodo.toString(), v);
      return v;
    } catch (e) {
      _notasByPeriodo[key] = AsyncValue.failure(e, prev);
      _notify();
      return null;
    }
  }

  void clear() {
    unawaited(_cache.clearAll());
    profile = const AsyncValue.idle();
    periodos = const AsyncValue.idle();
    // Otro estudiante puede tener otra regla de aprobación: no se hereda.
    PassingRule.current = PassingRule.standard;
    schedule = const AsyncValue.idle();
    resumen = const AsyncValue.idle();
    promedios = const AsyncValue.idle();
    pendingInstallments = const AsyncValue.idle();
    intranetInstallments = const AsyncValue.idle();
    tasas = const AsyncValue.idle();
    historico = const AsyncValue.idle();
    _notasByPeriodo.clear();
    _boleta.clear();
    _boletaLegacy.clear();
    _detalle.clear();
    record = const AsyncValue.idle();
    certificate = const AsyncValue.idle();
    schedule = const AsyncValue.idle();
    publications = const AsyncValue.idle();
    wifi = const AsyncValue.idle();
    gradesCount = const AsyncValue.idle();
    teacherInfo = const AsyncValue.idle();
    teacherSubjects = const AsyncValue.idle();
    teacherSchedule = const AsyncValue.idle();
    _teacherStudents.clear();
    _intranet?.invalidate();
    _notify();
  }
}
