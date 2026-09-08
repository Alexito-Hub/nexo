import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/shared/util/clipboard_helper.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/features/teacher/teacher_student_sheet.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/domain/passing_rule.dart';

class TeacherCourseDetailScreen extends StatefulWidget {
  const TeacherCourseDetailScreen({
    super.key,
    required this.store,
    required this.course,
  });
  final AppStore store;
  final TeacherSubject course;
  @override
  State<TeacherCourseDetailScreen> createState() =>
      _TeacherCourseDetailScreenState();
}

class _TeacherCourseDetailScreenState extends State<TeacherCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    if (!widget.store.alumnosDe(widget.course.id).hasValue) {
      widget.store.loadDocenteAlumnos(widget.course.id);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: NexoTheme.bg,
      appBar: AppBar(
        title: Text(
          widget.course.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(course: widget.course),
            ColoredBox(
              color: NexoTheme.surface,
              child: TabBar(
                controller: _tabs,
                tabs: [
                  Tab(text: l.docenteTabAlumnos),
                  Tab(text: l.docenteTabAsistencia),
                  Tab(text: l.docenteTabNotas),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.store,
                builder: (context, _) {
                  return TabBarView(
                    controller: _tabs,
                    children: [
                      _AlumnosTab(store: widget.store, course: widget.course),
                      _AsistenciaTab(
                        store: widget.store,
                        course: widget.course,
                      ),
                      _NotasTab(store: widget.store, course: widget.course),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TeacherSubject course;
  const _Header({required this.course});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      color: NexoTheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code.isEmpty ? l.docenteNoCode : course.code,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: NexoTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.docenteSectionPeriod(course.section, course.periodo),
                  style: TextStyle(
                    fontSize: AppFont.body,
                    fontWeight: FontWeight.w700,
                    color: NexoTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: NexoTheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadii.rPill,
            ),
            child: Text(
              l.docenteMetricAlumnosCount(course.enrolledCount ?? 0),
              style: TextStyle(
                fontSize: AppFont.small,
                fontWeight: FontWeight.w700,
                color: NexoTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlumnosTab extends StatelessWidget {
  final AppStore store;
  final TeacherSubject course;
  const _AlumnosTab({required this.store, required this.course});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = store.alumnosDe(course.id);
    if (state.loading && !state.hasValue) {
      return const _SkeletonList();
    }
    final alumnos = state.value ?? const <TeacherStudent>[];
    if (alumnos.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.groups_outlined,
          title: l.docenteNoAlumnosRegistered,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: alumnos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = alumnos[i];
        return _AlumnoTile(
          student: a,
          onTap: () => showTeacherStudentSheet(
            context: context,
            store: store,
            course: course,
            student: a,
          ),
        );
      },
    );
  }
}

class _AlumnoTile extends StatelessWidget {
  final TeacherStudent student;
  final VoidCallback onTap;
  const _AlumnoTile({required this.student, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final asis = int.tryParse(student.attendance ?? '');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: NexoTheme.card,
            borderRadius: AppRadii.rLg,
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: NexoTheme.primary.withValues(alpha: 0.14),
                child: Text(
                  _initials(student),
                  style: TextStyle(
                    fontSize: 14,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.body,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.code,
                      style: TextStyle(
                        fontSize: AppFont.small,
                        color: NexoTheme.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if ((student.grade ?? '').isNotEmpty)
                    _gradePill(student.grade!),
                  if (asis != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l.docenteAsisPercent(asis.toString()),
                      style: TextStyle(
                        fontSize: 10,
                        color: NexoTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(TeacherStudent a) {
    final first = (a.firstName.split(' ').firstOrNull ?? '').trim();
    final last = (a.lastName.split(' ').firstOrNull ?? '').trim();
    String pick(String s) => s.isEmpty ? '' : s[0].toUpperCase();
    final ini = pick(first) + pick(last);
    return ini.isEmpty ? '?' : ini;
  }

  Widget _gradePill(String grade) {
    final color = gradeColor(grade);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.rPill,
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: AppFont.small,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _AsistenciaTab extends StatefulWidget {
  final AppStore store;
  final TeacherSubject course;
  const _AsistenciaTab({required this.store, required this.course});
  @override
  State<_AsistenciaTab> createState() => _AsistenciaTabState();
}

class _AsistenciaTabState extends State<_AsistenciaTab> {
  DateTime _fecha = DateTime.now();
  Map<String, String> _estados = {};
  bool _loading = true;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final estados = await widget.store.docenteAsistenciaDia(
      cleAuto: widget.course.id,
      date: _fecha,
    );
    if (!mounted) return;
    setState(() {
      _estados = Map.of(estados);
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await widget.store.guardarAsistenciaDia(
      cleAuto: widget.course.id,
      date: _fecha,
      estados: _estados,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final l = AppLocalizations.of(context);
    if (err == null) {
      ClipboardHelper.showSuccess(context, l.docenteAttendanceSaved);
    } else {
      ClipboardHelper.showError(
        context,
        err,
        fallback: l.docenteAttendanceError(err),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final alumnos =
        widget.store.alumnosDe(widget.course.id).value ??
        const <TeacherStudent>[];
    final fmt =
        '${_fecha.day.toString().padLeft(2, '0')}/'
        '${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: NexoTheme.surface,
          child: Row(
            children: [
              Icon(Icons.event_outlined, color: NexoTheme.primary),
              const Gap.h(AppSpacing.sm),
              Expanded(
                child: Text(
                  fmt,
                  style: TextStyle(
                    fontSize: AppFont.body,
                    fontWeight: FontWeight.w700,
                    color: NexoTheme.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    _fecha = picked;
                    await _load();
                  }
                },
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: Text(l.docenteChangeDate),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const _SkeletonList()
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: alumnos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final a = alumnos[i];
                    final state = _estados[a.code] ?? 'P';
                    return _AsistenciaRow(
                      student: a,
                      state: state,
                      onChange: (s) => setState(() => _estados[a.code] = s),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saving || _loading ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(l.docenteSaveAttendance),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AsistenciaRow extends StatelessWidget {
  final TeacherStudent student;
  final String state;
  final ValueChanged<String> onChange;
  const _AsistenciaRow({
    required this.student,
    required this.state,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
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
                  student.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFont.body,
                    fontWeight: FontWeight.w600,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                Text(
                  student.code,
                  style: TextStyle(
                    fontSize: 10,
                    color: NexoTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          _stateChip('P', l.docenteAttendancePresentShort, NexoTheme.success),
          const SizedBox(width: 4),
          _stateChip('T', l.docenteAttendanceTardanzaShort, NexoTheme.warning),
          const SizedBox(width: 4),
          _stateChip('F', l.docenteAttendanceFaltaShort, NexoTheme.danger),
        ],
      ),
    );
  }

  Widget _stateChip(String code, String label, Color color) {
    final active = state == code;
    return GestureDetector(
      onTap: () => onChange(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: AppRadii.rPill,
          border: Border.all(color: active ? color : NexoTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : NexoTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NotasTab extends StatelessWidget {
  final AppStore store;
  final TeacherSubject course;
  const _NotasTab({required this.store, required this.course});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = store.alumnosDe(course.id);
    if (state.loading && !state.hasValue) return const _SkeletonList();
    final alumnos = state.value ?? const <TeacherStudent>[];
    if (alumnos.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.assignment_outlined,
          title: l.docenteNoAlumnosInCourse,
        ),
      );
    }
    final approved = alumnos.where((a) {
      final n = double.tryParse((a.grade ?? '').replaceAll(',', '.'));
      return PassingRule.standard.passes(n);
    }).length;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: NexoTheme.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.docenteAprobadosCount(
                    approved.toString(),
                    alumnos.length.toString(),
                  ),
                  style: TextStyle(
                    fontSize: AppFont.small,
                    fontWeight: FontWeight.w700,
                    color: NexoTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                l.docenteTapToEdit,
                style: TextStyle(
                  fontSize: AppFont.small,
                  color: NexoTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: alumnos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final a = alumnos[i];
              return _AlumnoTile(
                student: a,
                onTap: () => showTeacherStudentSheet(
                  context: context,
                  store: store,
                  course: course,
                  student: a,
                  initialTab: 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) => const Skeleton(height: 64, radius: 14),
    );
  }
}

Color gradeColor(String? raw) {
  final n = double.tryParse((raw ?? '').trim().replaceAll(',', '.'));
  if (n == null) return NexoTheme.textMuted;
  if (n >= 14) return NexoTheme.success;
  if (n >= PassingRule.standard.threshold) return NexoTheme.info;
  return NexoTheme.danger;
}
