import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/features/directory/widgets/directory_widgets.dart';
import 'package:nexo/features/grades/grade_widgets.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';
import 'package:nexo/shared/widgets/student_avatar.dart';

/// Ficha del estudiante.
///
/// Todo llega en una sola petición y se ordena en bloques: primero quién es,
/// después lo académico. En escritorio los bloques se reparten en dos
/// columnas —lo estable a la izquierda, lo que se consulta a la derecha— para
/// no dejar una columna de texto de mil píxeles de ancho.
///
/// Abrirla queda auditada en el backend: es el acceso a los datos de una
/// persona concreta.
class StudentRecordScreen extends StatefulWidget {
  const StudentRecordScreen({
    super.key,
    required this.fetch,
    required this.code,
    this.preview,
  });

  /// De dónde sale la ficha. El directorio y el acceso de apoderados usan
  /// endpoints distintos —y permisos distintos— pero se ven igual, así que la
  /// pantalla recibe la consulta en vez de decidirla.
  final Future<StudentRecord> Function(String code) fetch;
  final String code;

  /// Lo que ya se sabía desde la lista, para pintar la cabecera sin esperar.
  final StudentSummary? preview;

  /// El nombre va en `RouteSettings` para que la miga de pan del panel
  /// lateral de escritorio diga a quién estás viendo.
  static Future<void> open(
    BuildContext context,
    BackendClient client,
    StudentSummary student,
  ) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StudentRecordScreen(
        fetch: client.student,
        code: student.code,
        preview: student,
      ),
      settings: RouteSettings(name: student.fullName),
    ),
  );

  @override
  State<StudentRecordScreen> createState() => _StudentRecordScreenState();
}

class _StudentRecordScreenState extends State<StudentRecordScreen> {
  bool _loading = true;
  String? _errorCode;
  StudentRecord? _record;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });
    try {
      final record = await widget.fetch(widget.code);
      if (!mounted) return;
      setState(() {
        _record = record;
        _loading = false;
      });
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCode = e.code;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // El nombre vive en la cabecera de la ficha (y en la miga de pan del
    // escritorio, vía `RouteSettings`); repetirlo aquí sería decirlo dos veces
    // en la misma pantalla.
    return Scaffold(
      backgroundColor: NexoTheme.bg,
      appBar: AppBar(title: Text(l.directoryRecordTitle)),
      body: SafeArea(child: _body(l)),
    );
  }

  Widget _body(AppLocalizations l) {
    if (_errorCode != null) {
      final notFound = _errorCode == 'no_encontrado';
      return SingleChildScrollView(
        child: EmptyState(
          icon: notFound ? Icons.person_off_outlined : Icons.cloud_off_outlined,
          title: notFound
              ? l.directoryRecordMissing
              : l.directoryUnavailableTitle,
          subtitle: notFound
              ? l.directoryRecordMissingHint
              : l.directoryUnavailableHint,
          color: notFound ? NexoTheme.warning : NexoTheme.danger,
          onRetry: notFound ? null : _load,
          retryLabel: l.actionRetry,
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.responsive(mobile: 760.0, desktop: 1240.0),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.contentPadding,
            AppSpacing.xl,
            context.contentPadding,
            AppSpacing.huge,
          ),
          children: [
            _Hero(student: _record ?? widget.preview, loading: _loading),
            const Gap(AppSpacing.lg),
            if (_loading) const _LoadingBlocks() else _blocks(l, _record!),
          ],
        ),
      ),
    );
  }

  /// Dos columnas en escritorio, una en móvil. El reparto no es estético:
  /// a la izquierda lo que se lee de un vistazo, a la derecha lo que se
  /// explora.
  Widget _blocks(AppLocalizations l, StudentRecord r) {
    final left = <Widget>[_IdentityCard(record: r), _ProgressCard(record: r)];
    final right = <Widget>[
      _GradesCard(record: r),
      _ScheduleCard(record: r),
      _PaymentsCard(record: r),
    ];

    if (!context.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final block in [...left, ...right]) ...[
            block,
            const Gap(AppSpacing.lg),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final block in left) ...[block, const Gap(AppSpacing.lg)],
            ],
          ),
        ),
        const Gap.h(AppSpacing.lg),
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final block in right) ...[block, const Gap(AppSpacing.lg)],
            ],
          ),
        ),
      ],
    );
  }
}

/// Cabecera con la misma forma que la del perfil propio: degradado, avatar y
/// tres cifras separadas por divisores.
class _Hero extends StatelessWidget {
  const _Hero({required this.student, required this.loading});
  final StudentSummary? student;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = student;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NexoTheme.primary, NexoTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: NexoTheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(
                code: s?.code,
                name: s?.fullName ?? '',
                size: 64,
                radius: 20,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: Colors.white.withValues(alpha: 0.3),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s?.fullName ?? '...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFont.h3,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      [
                        if (s != null) s.code,
                        if (s?.school != null) s!.school!,
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: AppFont.small,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xxl),
          Row(
            children: [
              _stat(
                l.directoryStatAverage.toUpperCase(),
                s?.average?.toStringAsFixed(2) ?? '—',
              ),
              _divider(),
              _stat(
                l.directoryStatCredits.toUpperCase(),
                s?.creditsApproved == null
                    ? '—'
                    : '${s!.creditsApproved}/${s.creditsTotal ?? 0}',
              ),
              _divider(),
              _stat(
                l.directoryFieldCycle.toUpperCase(),
                s?.cycle == null ? '—' : '${s!.cycle}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.18),
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  );
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.record});
  final StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: l.directoryPersonalData,
      icon: Icons.badge_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RecordField(label: l.directoryFieldCode, value: record.code),
          if (record.dni != null) RecordField(label: 'DNI', value: record.dni!),
          if (record.email != null)
            RecordField(label: l.directoryFieldEmail, value: record.email!),
          if (record.phone != null)
            RecordField(label: l.directoryFieldPhone, value: record.phone!),
          if (record.faculty != null)
            RecordField(label: l.directoryFieldFaculty, value: record.faculty!),
          if (record.school != null)
            RecordField(label: l.directoryFieldSchool, value: record.school!),
          if (record.plan != null)
            RecordField(label: l.directoryFieldPlan, value: record.plan!),
          if (record.entryYear != null)
            RecordField(
              label: l.directoryFieldEntry,
              value: '${record.entryYear}',
            ),
          if (record.status != null) ...[
            const Gap(AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                text: record.status!,
                color: record.status == 'regular'
                    ? NexoTheme.success
                    : NexoTheme.warning,
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.record});
  final StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = record.module('avance') ?? const {};
    final terms = (progress['promedios_por_ciclo'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();

    return SectionCard(
      title: l.directoryProgressByTerm,
      icon: Icons.insights_rounded,
      iconColor: NexoTheme.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.school_rounded,
                  color: NexoTheme.success,
                  label: l.directoryCumulativeAverage,
                  value: '${progress['promedio_acumulado'] ?? '—'}',
                ),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: StatTile(
                  icon: Icons.checklist_rounded,
                  color: NexoTheme.info,
                  label: l.directoryApprovedCourses,
                  value:
                      '${progress['cursos_aprobados'] ?? '—'}/${progress['cursos_llevados'] ?? '—'}',
                ),
              ),
            ],
          ),
          if (terms.isNotEmpty) ...[
            const Gap(AppSpacing.lg),
            _TermChart(terms: terms),
          ],
        ],
      ),
    );
  }
}

class _GradesCard extends StatelessWidget {
  const _GradesCard({required this.record});
  final StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final courses =
        ((record.module('notas') ?? const {})['cursos'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();

    return SectionCard(
      title: l.directoryTabGrades,
      subtitle: courses.isEmpty
          ? null
          : l.directoryCoursesCount(courses.length),
      icon: Icons.menu_book_outlined,
      child: courses.isEmpty
          ? SoftNotice(
              text: l.directoryEmptyModule,
              color: NexoTheme.textMuted,
              icon: Icons.inbox_outlined,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < courses.length; i++) ...[
                  _CourseTile(course: courses[i]),
                  if (i < courses.length - 1)
                    Divider(height: AppSpacing.lg, color: NexoTheme.border),
                ],
              ],
            ),
    );
  }
}

class _CourseTile extends StatefulWidget {
  const _CourseTile({required this.course});
  final Map<String, dynamic> course;

  @override
  State<_CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<_CourseTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = widget.course;
    final units = ((c['detalle'] as Map?)?['unidades'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final attendance = (c['asistencia'] as num?)?.toDouble();
    final average = (c['promedio'] as num?)?.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: units.isEmpty ? null : () => setState(() => _open = !_open),
          borderRadius: AppRadii.rSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c['nombre']}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.body,
                          fontWeight: FontWeight.w700,
                          color: NexoTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const Gap(AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          StatusChip(
                            text: '${c['seccion']}',
                            color: NexoTheme.textSecondary,
                          ),
                          if (c['creditos'] != null)
                            StatusChip(
                              text: l.directoryCourseCredits(
                                '${c['creditos']}',
                              ),
                              color: NexoTheme.textSecondary,
                            ),
                          if (attendance != null)
                            StatusChip(
                              text: l.directoryAttendance(
                                attendance.toStringAsFixed(0),
                              ),
                              color: attendance >= 70
                                  ? NexoTheme.info
                                  : NexoTheme.warning,
                              icon: Icons.event_available_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap.h(AppSpacing.md),
                GradeBadge.fromRaw(
                  average?.toStringAsFixed(2) ?? '—',
                  size: 44,
                  fs: 14,
                ),
                if (units.isNotEmpty)
                  Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: NexoTheme.textMuted,
                  ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: AppDurations.fast,
          crossFadeState: _open
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final u in units) _UnitRow(unit: u)],
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.unit});
  final Map<String, dynamic> unit;

  @override
  Widget build(BuildContext context) {
    final average = (unit['promedio'] as num?)?.toDouble();
    final color = gradeColor(average);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${unit['nombre']}',
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    fontWeight: FontWeight.w600,
                    color: NexoTheme.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Text(
                average?.toStringAsFixed(2) ?? '—',
                style: TextStyle(
                  fontSize: AppFont.caption,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          ThinBar(value: (average ?? 0) / 20, color: color, height: 4),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.record});
  final StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final classes =
        ((record.module('horario') ?? const {})['clases'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();

    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final c in classes) {
      byDay.putIfAbsent(c['dia']?.toString() ?? '—', () => []).add(c);
    }
    final days = byDay.keys.toList()
      ..sort((a, b) {
        int order(String day) {
          final n = byDay[day]!.first['dia_num'];
          return n is num ? n.toInt() : 99;
        }

        return order(a).compareTo(order(b));
      });

    return SectionCard(
      title: l.directoryTabSchedule,
      icon: Icons.calendar_today_outlined,
      iconColor: NexoTheme.info,
      child: classes.isEmpty
          ? SoftNotice(
              text: l.directoryEmptyModule,
              color: NexoTheme.textMuted,
              icon: Icons.inbox_outlined,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final day in days) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      day.toUpperCase(),
                      style: TextStyle(
                        fontSize: AppFont.caption,
                        fontWeight: FontWeight.w800,
                        color: NexoTheme.textMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  for (final c in (byDay[day]!..sort(_byStart)))
                    _ClassRow(clase: c),
                  if (day != days.last) const Gap(AppSpacing.md),
                ],
              ],
            ),
    );
  }

  static int _byStart(Map<String, dynamic> a, Map<String, dynamic> b) =>
      '${a['inicio']}'.compareTo('${b['inicio']}');
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.clase});
  final Map<String, dynamic> clase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${clase['inicio']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppFont.small,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                Text(
                  '${clase['fin']}',
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 34,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: NexoTheme.primary.withValues(alpha: 0.35),
              borderRadius: AppRadii.rXs,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${clase['curso']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppFont.small,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                Text(
                  '${clase['tipo']} · ${clase['aula']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.record});
  final StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final payments = record.module('pagos') ?? const {};

    List<Map<String, dynamic>> group(String key) =>
        (payments[key] as List? ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();

    final overdue = group('vencidas');
    final pending = group('pendientes');
    final empty = overdue.isEmpty && pending.isEmpty;

    return SectionCard(
      title: l.directoryTabPayments,
      icon: Icons.account_balance_wallet_outlined,
      iconColor: overdue.isEmpty ? NexoTheme.info : NexoTheme.danger,
      trailing: overdue.isEmpty
          ? null
          : StatusChip(
              text: l.directoryOverdueCount(overdue.length),
              color: NexoTheme.danger,
              icon: Icons.error_outline_rounded,
            ),
      child: empty
          ? SoftNotice(
              text: l.directoryEmptyModule,
              color: NexoTheme.textMuted,
              icon: Icons.inbox_outlined,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in overdue)
                  _PaymentRow(payment: p, color: NexoTheme.danger),
                for (final p in pending)
                  _PaymentRow(payment: p, color: NexoTheme.warning),
              ],
            ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.color});
  final Map<String, dynamic> payment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final total = payment['total'] ?? payment['monto'];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(color: color, borderRadius: AppRadii.rXs),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment['descripcion']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppFont.small,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                if (payment['vencimiento'] != null)
                  Text(
                    '${payment['vencimiento']}',
                    style: TextStyle(
                      fontSize: AppFont.caption,
                      color: NexoTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const Gap.h(AppSpacing.sm),
          Text(
            '${payment['moneda'] ?? ''} $total',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: AppFont.small,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barras de promedio por ciclo, con el mismo lenguaje visual que el gráfico
/// de notas del estudiante.
class _TermChart extends StatelessWidget {
  const _TermChart({required this.terms});
  final List<Map<String, dynamic>> terms;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: NexoTheme.bg,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: NexoTheme.border),
      ),
      child: SizedBox(
        height: 132,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [for (final t in terms) Expanded(child: _bar(t))],
        ),
      ),
    );
  }

  Widget _bar(Map<String, dynamic> term) {
    final value = (term['promedio'] as num?)?.toDouble() ?? 0;
    final color = gradeColor(value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            child: Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: AppFont.caption,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const Gap(AppSpacing.xs),
          Container(
            height: (value / 20 * 78).clamp(4, 78),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.75),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          FittedBox(
            child: Text(
              '${term['anio']}-${term['periodo']}',
              style: TextStyle(
                fontSize: AppFont.caption,
                color: NexoTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloques de carga con la misma silueta que los reales.
class _LoadingBlocks extends StatelessWidget {
  const _LoadingBlocks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 2; i++) ...[
          const Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 160, height: 16),
                  Gap(AppSpacing.lg),
                  Skeleton(height: 12),
                  Gap(AppSpacing.sm),
                  Skeleton(height: 12),
                  Gap(AppSpacing.sm),
                  Skeleton(width: 200, height: 12),
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.lg),
        ],
      ],
    );
  }
}
