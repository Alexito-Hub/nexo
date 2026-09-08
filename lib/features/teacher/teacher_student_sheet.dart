import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/shared/util/clipboard_helper.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/features/teacher/teacher_course_detail.dart'
    show gradeColor;
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/skeleton.dart';

Future<void> showTeacherStudentSheet({
  required BuildContext context,
  required AppStore store,
  required TeacherSubject course,
  required TeacherStudent student,
  int initialTab = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AlumnoSheet(
      store: store,
      course: course,
      student: student,
      initialTab: initialTab,
    ),
  );
}

class _AlumnoSheet extends StatefulWidget {
  final AppStore store;
  final TeacherSubject course;
  final TeacherStudent student;
  final int initialTab;
  const _AlumnoSheet({
    required this.store,
    required this.course,
    required this.student,
    required this.initialTab,
  });
  @override
  State<_AlumnoSheet> createState() => _AlumnoSheetState();
}

class _AlumnoSheetState extends State<_AlumnoSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late Future<List<EvaluationGrade>> _futNotas;
  late Future<List<DailyAttendance>> _futAsis;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _loadAll();
  }

  void _loadAll() {
    _futNotas = widget.store.docenteNotasDetalle(
      cleAuto: widget.course.id,
      codigoAlumno: widget.student.code,
    );
    _futAsis = widget.store.docenteAsistenciaAlumno(
      cleAuto: widget.course.id,
      codigoAlumno: widget.student.code,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => DecoratedBox(
        decoration: BoxDecoration(
          color: NexoTheme.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NexoTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _Header(student: widget.student),
            ColoredBox(
              color: NexoTheme.surface,
              child: TabBar(
                controller: _tabs,
                tabs: [
                  Tab(text: l.docenteTabNotas),
                  Tab(text: l.docenteTabAsistencia),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _NotasTab(
                    future: _futNotas,
                    onEdit: _editEval,
                    scrollController: controller,
                  ),
                  _AsistenciaTab(
                    future: _futAsis,
                    scrollController: controller,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editEval(EvaluationGrade eval) async {
    final ctrl = TextEditingController(text: eval.grade ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dctx) {
        final l = AppLocalizations.of(dctx);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Dialog(
            backgroundColor: NexoTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: NexoTheme.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: NexoTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: NexoTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          eval.description,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: NexoTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autofocus: true,
                      style: TextStyle(color: NexoTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: l.docenteGradeLabel,
                        labelStyle: TextStyle(color: NexoTheme.textSecondary),
                        prefixIcon: Icon(
                          Icons.grade_rounded,
                          color: NexoTheme.textSecondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: NexoTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: NexoTheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: NexoTheme.danger),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: NexoTheme.danger,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim().replaceAll(',', '.');
                        if (t.isEmpty) return l.docenteGradeEnter;
                        final n = double.tryParse(t);
                        if (n == null) return l.docenteGradeInvalidNumber;
                        if (n < 0 || n > 20) return l.docenteGradeRange;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dctx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: NexoTheme.border),
                          ),
                          child: Text(
                            l.actionCancel,
                            style: TextStyle(
                              color: NexoTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(dctx).pop(ctrl.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NexoTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.actionSave,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result == null) return;
    final err = await widget.store.updateDocenteEvaluacion(
      cleAuto: widget.course.id,
      codigoAlumno: widget.student.code,
      codigoEvaluacion: eval.code,
      grade: result,
    );
    if (!mounted) return;
    if (err == null) {
      setState(_loadAll);
      ClipboardHelper.showSuccess(context, '${eval.description}: $result');
    } else {
      ClipboardHelper.showError(context, err);
    }
  }
}

class _Header extends StatelessWidget {
  final TeacherStudent student;
  const _Header({required this.student});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: NexoTheme.primary.withValues(alpha: 0.14),
            child: Text(
              _initials(student),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: NexoTheme.primary,
              ),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: TextStyle(
                    fontSize: AppFont.h3,
                    fontWeight: FontWeight.w800,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      student.code,
                      style: TextStyle(
                        fontSize: AppFont.small,
                        color: NexoTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    IconButton(
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        ClipboardHelper.copyAndShow(
                          context,
                          student.code,
                          label: AppLocalizations.of(context).actionCodeCopied,
                        );
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        color: NexoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(TeacherStudent a) {
    String pick(String s) => s.trim().isEmpty ? '' : s.trim()[0].toUpperCase();
    return (pick(a.firstName) + pick(a.lastName)).ifEmpty('?');
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _NotasTab extends StatelessWidget {
  final Future<List<EvaluationGrade>> future;
  final ValueChanged<EvaluationGrade> onEdit;
  final ScrollController scrollController;
  const _NotasTab({
    required this.future,
    required this.onEdit,
    required this.scrollController,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EvaluationGrade>>(
      future: future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const _SkeletonList();
        }
        final evals = snap.data!;
        var sum = 0.0;
        var pesoTotal = 0.0;
        for (final e in evals) {
          final n = e.gradeNum;
          if (n != null) {
            sum += n * e.weight / 100;
            pesoTotal += e.weight;
          }
        }
        final prom = pesoTotal > 0 ? sum * 100 / pesoTotal : null;
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (prom != null) _PromedioCard(average: prom, weight: pesoTotal),
            const SizedBox(height: 12),
            for (final e in evals)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _EvalRow(eval: e, onEdit: () => onEdit(e)),
              ),
          ],
        );
      },
    );
  }
}

class _PromedioCard extends StatelessWidget {
  final double average;
  final double weight;
  const _PromedioCard({required this.average, required this.weight});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = gradeColor(average.toStringAsFixed(1));
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadii.rXxl,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.docentePromedioParcial,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: NexoTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  average.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l.docenteCoursePercentGraded(weight.toStringAsFixed(0)),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: AppFont.small,
              color: NexoTheme.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvalRow extends StatelessWidget {
  final EvaluationGrade eval;
  final VoidCallback onEdit;
  const _EvalRow({required this.eval, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pending = eval.grade == null || eval.grade!.trim().isEmpty;
    return InkWell(
      borderRadius: AppRadii.rLg,
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: NexoTheme.card,
          borderRadius: AppRadii.rLg,
          border: Border.all(color: NexoTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eval.description,
                    style: TextStyle(
                      fontSize: AppFont.body,
                      fontWeight: FontWeight.w700,
                      color: NexoTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Peso ${eval.weight.toStringAsFixed(0)}% · ${eval.code}',
                    style: TextStyle(
                      fontSize: AppFont.small,
                      color: NexoTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (pending)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NexoTheme.warning.withValues(alpha: 0.14),
                  borderRadius: AppRadii.rPill,
                ),
                child: Text(
                  l.docenteEvalPending,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: NexoTheme.warning,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              Text(
                eval.grade!,
                style: TextStyle(
                  fontSize: AppFont.h3,
                  fontWeight: FontWeight.w900,
                  color: gradeColor(eval.grade),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 16, color: NexoTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _AsistenciaTab extends StatelessWidget {
  final Future<List<DailyAttendance>> future;
  final ScrollController scrollController;
  const _AsistenciaTab({required this.future, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<List<DailyAttendance>>(
      future: future,
      builder: (_, snap) {
        if (!snap.hasData) return const _SkeletonList();
        final list = snap.data!;
        if (list.isEmpty) {
          return Center(
            child: Text(
              l.docenteNoAttendanceRecords,
              style: TextStyle(color: NexoTheme.textMuted),
            ),
          );
        }
        final presentes = list.where((r) => r.isPresent).length;
        final pct = (presentes / list.length * 100).round();
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _AsistenciaResumen(
              total: list.length,
              presentes: presentes,
              pct: pct,
            ),
            const SizedBox(height: 12),
            for (final r in list) _DiaRow(reg: r),
          ],
        );
      },
    );
  }
}

class _AsistenciaResumen extends StatelessWidget {
  final int total;
  final int presentes;
  final int pct;
  const _AsistenciaResumen({
    required this.total,
    required this.presentes,
    required this.pct,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = pct >= 80
        ? NexoTheme.success
        : pct >= 65
        ? NexoTheme.warning
        : NexoTheme.danger;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadii.rXxl,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.docenteAttendanceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: NexoTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l.docenteSessionsRegisteredCount(
              presentes.toString(),
              total.toString(),
            ),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: AppFont.small,
              color: NexoTheme.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaRow extends StatelessWidget {
  final DailyAttendance reg;
  const _DiaRow({required this.reg});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (label, color, icon) = switch (reg.state) {
      'P' => (
        l.docenteAttendancePresent,
        NexoTheme.success,
        Icons.check_circle_rounded,
      ),
      'T' => (
        l.docenteAttendanceTardanza,
        NexoTheme.warning,
        Icons.schedule_rounded,
      ),
      'F' => (l.docenteAttendanceFalta, NexoTheme.danger, Icons.cancel_rounded),
      _ => (
        l.docenteAttendanceJustificada,
        NexoTheme.info,
        Icons.assignment_turned_in_rounded,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Text(
              Fmt.shortDate(reg.date),
              style: TextStyle(
                fontSize: AppFont.body,
                color: NexoTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFont.small,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) => const Skeleton(height: 60, radius: 14),
    );
  }
}
