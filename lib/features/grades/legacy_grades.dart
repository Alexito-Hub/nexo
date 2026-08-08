import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/grades/grade_widgets.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

Color _grade(num? n) {
  if (n == null) return NexoTheme.textMuted;
  if (n >= 14) return NexoTheme.success;
  if (n >= 10.5) return NexoTheme.info;
  return NexoTheme.danger;
}

class LegacyGradesList extends StatelessWidget {
  final AsyncValue<List<CourseGrade>> state;
  final Term periodo;
  final AppStore store;
  const LegacyGradesList({
    super.key,
    required this.state,
    required this.periodo,
    required this.store,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Skeleton(height: 18, width: 160),
              SizedBox(height: 16),
              Skeleton(height: 64, radius: 14),
              SizedBox(height: 10),
              Skeleton(height: 64, radius: 14),
            ],
          ),
        ),
      );
    }
    if (state.error != null && !state.hasValue) {
      return SectionCard(
        title: l.gradesSubjects,
        icon: Icons.menu_book_rounded,
        iconColor: NexoTheme.danger,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l.gradesLoadError,
              subtitle: humanizeError(state.error),
              color: NexoTheme.danger,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  store.loadBoletaLegacy(periodo.year, periodo.number),
              child: Text(l.actionRetry),
            ),
          ],
        ),
      );
    }
    final grades = state.value ?? const <CourseGrade>[];
    if (grades.isEmpty) {
      return SectionCard(
        title: l.gradesSubjects,
        icon: Icons.menu_book_rounded,
        child: EmptyState(
          icon: Icons.inbox_rounded,
          title: l.gradesNoNotesTitle,
        ),
      );
    }
    return SectionCard(
      title: l.gradesSubjectsWithPeriod(periodo.label),
      icon: Icons.menu_book_rounded,
      iconColor: NexoTheme.primary,
      trailing: StatusChip(
        text: l.gradesCoursesCount(grades.length),
        color: NexoTheme.primary,
      ),
      child: gradeTileGrid(context, [for (final n in grades) _Tile(grade: n)]),
    );
  }
}

class _Tile extends StatelessWidget {
  final CourseGrade grade;
  const _Tile({required this.grade});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = _grade(grade.currentGradeNum);
    final inProgress = grade.currentGradeNum == null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _Sheet(grade: grade),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexoTheme.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NexoTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        grade.currentGradeText,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NexoTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _meta(
                              Icons.tag_rounded,
                              '${l.detailSection} ${grade.section}',
                            ),
                            if (grade.asistenciaPct != null)
                              _meta(
                                Icons.fact_check_outlined,
                                l.docenteAsisPercent(
                                  grade.asistenciaPct.toString(),
                                ),
                              ),
                            if (grade.rank.isNotEmpty && grade.rank != '0/0')
                              _meta(Icons.emoji_events_outlined, grade.rank),
                            if (inProgress)
                              StatusChip(
                                text: l.statusInProcess,
                                color: NexoTheme.warning,
                              )
                            else
                              StatusChip(
                                text: grade.isApproved
                                    ? l.statusApproved
                                    : l.statusFailed,
                                color: grade.isApproved
                                    ? NexoTheme.success
                                    : NexoTheme.danger,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: NexoTheme.textMuted),
                ],
              ),
              if (grade.pF1.isNotEmpty || grade.pF2.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Badge(
                        label: l.gradesParcial1,
                        value: formatGrade(grade.pF1),
                        color: _grade(parseGrade(grade.pF1)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Badge(
                        label: l.gradesParcial2,
                        value: formatGrade(grade.pF2),
                        color: _grade(parseGrade(grade.pF2)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: NexoTheme.textMuted),
      const SizedBox(width: 3),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: NexoTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Badge({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty || value == '—';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NexoTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: NexoTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            empty ? '—' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: empty ? NexoTheme.textMuted : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  final CourseGrade grade;
  const _Sheet({required this.grade});
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
            const SizedBox(height: 12),
            Expanded(
              child: LegacyNotaDetalleBody(
                grade: grade,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegacyNotaDetalleBody extends StatelessWidget {
  const LegacyNotaDetalleBody({
    super.key,
    required this.grade,
    this.controller,
  });
  final CourseGrade grade;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        GradeHeader(
          titulo: grade.subject,
          subtitulo:
              '${grade.code} · ${l.detailSection} ${grade.section}'
              '${grade.rank.isNotEmpty && grade.rank != '0/0' ? l.gradesRank(grade.rank) : ''}',
          notaFinalText: grade.currentGradeText,
          inProgress: grade.currentGradeNum == null,
        ),
        const SizedBox(height: 16),
        GradeSectionCard(
          titulo: l.gradesSummary,
          rows: [
            GradeRow(label: l.gradesPromedioParcial1, valueRaw: grade.pF1),
            GradeRow(label: l.gradesPromedioParcial2, valueRaw: grade.pF2),
            GradeRow(
              label: l.gradesPromedioFinal,
              valueRaw: grade.pf,
              strong: true,
              last: true,
            ),
          ],
        ),
        if (!grade.firstTerm.isEmpty) ...[
          const SizedBox(height: 12),
          _parcialCard(l.gradesPrimerParcial, grade.firstTerm, l),
        ],
        if (!grade.secondTerm.isEmpty) ...[
          const SizedBox(height: 12),
          _parcialCard(l.gradesSegundoParcial, grade.secondTerm, l),
        ],
        if (grade.complementary.isNotEmpty && grade.complementary != '--') ...[
          const SizedBox(height: 12),
          _ComplementarioBanner(value: grade.complementary),
        ],
      ],
    );
  }

  Widget _parcialCard(String titulo, TermGrades p, AppLocalizations l) {
    final entries = <(String, String)>[];
    void add(String label, String raw) {
      if (raw.trim().isNotEmpty) entries.add((label, raw));
    }

    for (var i = 0; i < p.practices.length; i++) {
      add(l.gradesPractice((i + 1).toString()), p.practices[i]);
    }
    add(l.gradesPromedioPracticas, p.displayPracticesAverage);
    add(l.gradesTrabajoInvestigacion, p.researchWork);
    add(l.gradesProyecto, p.project);
    add(l.gradesPromedioTiPy, p.researchProjectAverage);
    add(l.gradesExamenParcial, p.exam);
    if (entries.isEmpty) return const SizedBox.shrink();
    return GradeSectionCard(
      titulo: titulo,
      rows: [
        for (var i = 0; i < entries.length; i++)
          GradeRow(
            label: entries[i].$1,
            valueRaw: entries[i].$2,
            strong:
                entries[i].$1 == l.gradesPromedioPracticas ||
                entries[i].$1 == l.gradesPromedioTiPy,
            last: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _ComplementarioBanner extends StatelessWidget {
  final String value;
  const _ComplementarioBanner({required this.value});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexoTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexoTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.replay_rounded, color: NexoTheme.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.gradesExamenComplementario,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NexoTheme.textPrimary,
              ),
            ),
          ),
          Text(
            formatGrade(value),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NexoTheme.warning,
            ),
          ),
        ],
      ),
    );
  }
}
