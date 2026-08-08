import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/domain/grade_calculator.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/grades/grade_widgets.dart';
import 'package:nexo/features/grades/legacy_grades.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/util/clipboard_helper.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

Color _gradeColor(num? n) {
  if (n == null) return NexoTheme.textMuted;
  if (n >= 14) return NexoTheme.success;
  if (n >= 10.5) return NexoTheme.info;
  return NexoTheme.danger;
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _selectedId;
  @override
  void initState() {
    super.initState();
    if (!widget.store.periodos.hasValue) widget.store.loadPeriodos();
    if (!widget.store.promedios.hasValue) widget.store.loadPromedios();
  }

  Term? _currentTerm(List<Term> periodos) {
    if (periodos.isEmpty) return null;
    if (_selectedId != null) {
      try {
        return periodos.firstWhere((p) => p.id == _selectedId);
      } catch (_) {}
    }
    try {
      return periodos.firstWhere((p) => p.isActive);
    } catch (_) {}
    return periodos.first;
  }

  void _load(Term p) {
    if (isNewModel(p.year, p.number)) {
      if (!widget.store.boletaOf(p.year, p.number).hasValue) {
        widget.store.loadBoleta(p.year, p.number);
      }
    } else {
      if (!widget.store.boletaLegacyOf(p.year, p.number).hasValue) {
        widget.store.loadBoletaLegacy(p.year, p.number);
      }
    }
  }

  void _select(Term p) {
    setState(() => _selectedId = p.id);
    _load(p);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final periodos = widget.store.periodos.value ?? const <Term>[];
        final current = _currentTerm(periodos);
        final nuevo =
            current != null && isNewModel(current.year, current.number);
        if (current != null) {
          final st = nuevo
              ? widget.store.boletaOf(current.year, current.number)
              : widget.store.boletaLegacyOf(current.year, current.number);
          if (!st.hasValue && !st.loading && st.error == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _load(current);
            });
          }
        }
        final boleta = current == null
            ? const AsyncValue<List<ReportCardCourse>>.idle()
            : widget.store.boletaOf(current.year, current.number);
        final legacy = current == null
            ? const AsyncValue<List<CourseGrade>>.idle()
            : widget.store.boletaLegacyOf(current.year, current.number);
        final list = RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              widget.store.loadPromedios(),
              widget.store.loadPeriodos(),
              if (current != null) Future(() => _load(current)),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: l.titleGrades,
                  subtitle: current == null
                      ? l.gradesSubtitleNoPeriod
                      : nuevo
                      ? l.gradesSubtitleUnits(current.label)
                      : l.gradesSubtitlePartials(current.label),
                ),
              ),
              SliverToBoxAdapter(
                child: PageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Reveal(
                        index: 0,
                        child: _ResumenCard(store: widget.store),
                      ),
                      const SizedBox(height: 14),
                      if (periodos.isNotEmpty) ...[
                        Reveal(
                          index: 1,
                          child: _PeriodChips(
                            periodos: periodos,
                            selected: current,
                            onSelect: _select,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else if (widget.store.periodos.loading) ...[
                        const Skeleton(height: 40, radius: 999, width: 200),
                        const SizedBox(height: 14),
                      ],
                      if (current == null)
                        SectionCard(
                          title: l.gradesSubjects,
                          icon: Icons.menu_book_rounded,
                          child: EmptyState(
                            icon: Icons.menu_book_rounded,
                            title: l.gradesSelectPeriod,
                          ),
                        )
                      else if (nuevo)
                        Reveal(
                          index: 2,
                          child: _BoletaList(
                            state: boleta,
                            periodo: current,
                            store: widget.store,
                          ),
                        )
                      else
                        Reveal(
                          index: 2,
                          child: LegacyGradesList(
                            state: legacy,
                            periodo: current,
                            store: widget.store,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
        return list;
      },
    );
  }
}

class _BoletaList extends StatelessWidget {
  final AsyncValue<List<ReportCardCourse>> state;
  final Term? periodo;
  final AppStore store;
  const _BoletaList({
    required this.state,
    required this.periodo,
    required this.store,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (periodo == null) {
      return SectionCard(
        title: l.gradesSelectPeriod,
        icon: Icons.menu_book_rounded,
        child: EmptyState(
          icon: Icons.menu_book_rounded,
          title: l.gradesSelectPeriod,
        ),
      );
    }
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
              onPressed: () => store.loadBoleta(periodo!.year, periodo!.number),
              child: Text(l.actionRetry),
            ),
          ],
        ),
      );
    }
    final courses = state.value ?? const <ReportCardCourse>[];
    if (courses.isEmpty) {
      return SectionCard(
        title: l.gradesSubjects,
        icon: Icons.menu_book_rounded,
        child: EmptyState(
          icon: Icons.inbox_rounded,
          title: l.gradesNoNotesTitle,
          subtitle: l.gradesNoNotesSubtitleNewModel,
        ),
      );
    }
    return SectionCard(
      title: l.gradesSubjectsWithPeriod(periodo!.label),
      icon: Icons.menu_book_rounded,
      iconColor: NexoTheme.primary,
      trailing: StatusChip(
        text: l.gradesCoursesCount(courses.length),
        color: NexoTheme.primary,
      ),
      child: gradeTileGrid(context, [
        for (final c in courses)
          _CursoTile(course: c, periodo: periodo!, store: store),
      ]),
    );
  }
}

class _CursoTile extends StatelessWidget {
  final ReportCardCourse course;
  final Term periodo;
  final AppStore store;
  const _CursoTile({
    required this.course,
    required this.periodo,
    required this.store,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Promedio real con decimales (desde las unidades) cuando el curso está
    // en proceso; el servidor entrega el promedio redondeado.
    final avg = store.realAverageOf(course);
    final avgText = avg == null ? '—' : avg.toStringAsFixed(2);
    final color = _gradeColor(avg);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          store.loadDetalle(
            periodo.year,
            periodo.number,
            course.enrollmentSubjectId,
          );
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _DetalleSheet(course: course, store: store),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexoTheme.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
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
                    avgText,
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
                      course.name,
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
                          '${l.detailSection} ${course.section}',
                        ),
                        if (course.attendance != null)
                          _meta(
                            Icons.fact_check_outlined,
                            l.docenteAsisPercent(course.attendance.toString()),
                          ),
                        if (course.inProgress)
                          StatusChip(
                            text: l.statusInProcess,
                            color: NexoTheme.warning,
                          )
                        else if (avg != null)
                          StatusChip(
                            text: avg >= GradeCalculator.notaAprobatoria
                                ? l.statusApproved
                                : l.statusFailed,
                            color: avg >= GradeCalculator.notaAprobatoria
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

class _DetalleSheet extends StatelessWidget {
  final ReportCardCourse course;
  final AppStore store;
  const _DetalleSheet({required this.course, required this.store});
  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 12),
            Expanded(
              child: BoletaDetalleBody(
                course: course,
                store: store,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoletaDetalleBody extends StatelessWidget {
  const BoletaDetalleBody({
    super.key,
    required this.course,
    required this.store,
    this.controller,
  });
  final ReportCardCourse course;
  final AppStore store;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final st = store.detalleOf(course.enrollmentSubjectId);
        final det = st.value;
        // Fuente única de verdad: el MISMO promedio que muestra la lista.
        // El promedio final del detalle (tbl4/tbl6) viene redondeado por el
        // servidor (11.60 → 12), así que no se usa: causaba que el número de
        // adentro no coincidiera con el de afuera.
        final avg = store.realAverageOf(course);
        final notaText = avg == null ? course.promedioText : avg.toStringAsFixed(2);
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            GradeHeader(
              titulo: course.name,
              subtitulo:
                  '${course.code} · ${l.detailSection} ${course.section}',
              notaFinalText: notaText,
              inProgress: course.inProgress,
            ),
            const SizedBox(height: 16),
            if (st.loading && det == null)
              const Column(
                children: [
                  Skeleton(height: 90, radius: 16),
                  SizedBox(height: 12),
                  Skeleton(height: 90, radius: 16),
                ],
              )
            else if (st.error != null && det == null)
              EmptyState(
                icon: Icons.cloud_off_outlined,
                title: l.gradesDetailLoadError,
                subtitle: humanizeError(st.error),
                color: NexoTheme.danger,
              )
            else if (det != null) ...[
              for (final u in det.units) ...[
                GradeSectionCard(
                  titulo: u.name,
                  pesoText: u.weight != null
                      ? '${u.weight!.toStringAsFixed(0)}%'
                      : null,
                  rawAverage: u.average?.toStringAsFixed(2) ?? u.rawAverage,
                  rows: [
                    for (var i = 0; i < u.evidences.length; i++)
                      GradeRow(
                        label: _tipoCorto(u.evidences[i].type, l),
                        valueRaw: u.evidences[i].rawGrade,
                        last: i == u.evidences.length - 1,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (det.hasSubstitute)
                _Banner(
                  icon: Icons.replay_rounded,
                  label: l.gradesSustitutorio,
                  valueRaw: det.rawSubstitute,
                  color: NexoTheme.warning,
                ),
              if (det.units.isEmpty)
                EmptyState(
                  icon: Icons.hourglass_empty_rounded,
                  title: l.gradesNoUnitsYetTitle,
                  subtitle: l.gradesNoUnitsYetSubtitle,
                ),
            ],
          ],
        );
      },
    );
  }

  static String _tipoCorto(String t, AppLocalizations l) {
    final u = t.toUpperCase();
    if (u.contains('CONOCIMIENTO')) return l.gradesEvidenciaConocimiento;
    if (u.contains('DESEMPE')) return l.gradesEvidenciaDesempeno;
    if (u.contains('PRODUCTO')) return l.gradesEvidenciaProducto;
    return t;
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueRaw;
  final Color color;
  const _Banner({
    required this.icon,
    required this.label,
    required this.valueRaw,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NexoTheme.textPrimary,
              ),
            ),
          ),
          Text(
            formatGrade(valueRaw),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final AppStore store;
  const _ResumenCard({required this.store});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final promedios = store.promedios.value ?? const <TermAverage>[];
    final acumulado = store.promedioAcumulado;
    final creditosAprob = store.approvedCredits;
    final creditosTotal = store.totalCredits;
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final metric = _BigMetric(
      label: l.gradesPromedioAcumulado,
      value: acumulado == null ? '—' : acumulado.toStringAsFixed(2),
      hint: creditosAprob == null
          ? l.gradesNoCreditsData
          : creditosTotal != null && creditosTotal > 0
          ? l.gradesCreditsSummary(
              creditosAprob.toString(),
              creditosTotal.toString(),
            )
          : l.gradesCreditsApprovedCount(creditosAprob),
    );
    final chart = _PromediosChart(
      items: promedios,
      cicloActual: store.promedioCicloActual,
      periodoActivo: store.periodoActivo,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: metric),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: chart),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [metric, const SizedBox(height: 16), chart],
              ),
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  const _BigMetric({
    required this.label,
    required this.value,
    required this.hint,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (value != '—') {
          ClipboardHelper.copyAndShow(context, value, label: label);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [NexoTheme.primary, NexoTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromediosChart extends StatelessWidget {
  final List<TermAverage> items;
  final double? cicloActual;
  final Term? periodoActivo;
  const _PromediosChart({
    required this.items,
    this.cicloActual,
    this.periodoActivo,
  });
  bool _esActivo(TermAverage t) =>
      periodoActivo != null &&
      t.year == periodoActivo!.year &&
      t.number == periodoActivo!.number;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = [...items];
    if (cicloActual != null && periodoActivo != null) {
      final entry = TermAverage(
        year: periodoActivo!.year,
        number: periodoActivo!.number,
        average: cicloActual!,
      );
      final idx = data.indexWhere(_esActivo);
      if (idx >= 0) {
        // Solo sustituimos el promedio oficial del servidor por el cálculo
        // local cuando el servidor todavía no publicó el promedio del ciclo
        // activo (average 0). Si ya lo tiene, ese es el valor correcto.
        if (data[idx].average == 0) data[idx] = entry;
      } else {
        data.add(entry);
      }
    }
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NexoTheme.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NexoTheme.border),
        ),
        height: 160,
        child: EmptyState(
          icon: Icons.show_chart_rounded,
          title: l.gradesNoHistoryYet,
        ),
      );
    }
    final sorted = [...data]
      ..sort((a, b) {
        final byYear = a.year.compareTo(b.year);
        return byYear != 0 ? byYear : a.number.compareTo(b.number);
      });
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexoTheme.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexoTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.gradesEvolutionByPeriod,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NexoTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final p in sorted)
                  Expanded(
                    child: _BarColumn(p: p, inProgress: _esActivo(p)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final TermAverage p;
  final bool inProgress;
  const _BarColumn({required this.p, this.inProgress = false});
  @override
  Widget build(BuildContext context) {
    final ok = p.average >= GradeCalculator.notaAprobatoria;
    final List<Color> barColors = p.average == 0
        ? [NexoTheme.border, NexoTheme.border]
        : inProgress
        ? [NexoTheme.primary, NexoTheme.primaryDark]
        : ok
        ? [NexoTheme.success, NexoTheme.accent]
        : const [NexoTheme.warning, NexoTheme.danger];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            p.average == 0 ? '—' : p.average.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: inProgress && p.average != 0
                  ? NexoTheme.primary
                  : NexoTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, c) {
                final h = c.maxHeight;
                final value = p.average == 0 ? 4.0 : (p.average / 20.0) * h;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: value.clamp(4.0, h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: barColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.label,
            style: TextStyle(
              fontSize: 10,
              color: inProgress ? NexoTheme.primary : NexoTheme.textMuted,
              fontWeight: inProgress ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  final List<Term> periodos;
  final Term? selected;
  final ValueChanged<Term> onSelect;
  const _PeriodChips({
    required this.periodos,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final p in periodos) ...[
            _Chip(
              text: p.label,
              active: p.id == selected?.id,
              onTap: () => onSelect(p),
              activo: p.isActive,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  final bool activo;
  final VoidCallback onTap;
  const _Chip({
    required this.text,
    required this.active,
    required this.activo,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? NexoTheme.primary : NexoTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? NexoTheme.primary : NexoTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : NexoTheme.textPrimary,
              ),
            ),
            if (activo) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? Colors.white : NexoTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
