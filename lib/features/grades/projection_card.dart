import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/domain/grade_projection.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/passing_rule.dart';
import 'package:nexo/features/grades/grade_widgets.dart';
import 'package:nexo/l10n/app_localizations.dart';

/// «¿Cuánto necesito sacar?».
///
/// Aparece sola en cuanto hay al menos una unidad rendida y otra pendiente:
/// justo el momento (tercera, cuarta unidad) en que la pregunta empieza a
/// tener respuesta útil.
///
/// Si queda más de una evaluación por rendir deja mover la primera con un
/// deslizador, porque la pregunta real no es «cuánto necesito en todo» sino
/// «si en el reto de la unidad saco tanto, cuánto me queda para la integral».
class ProjectionCard extends StatefulWidget {
  const ProjectionCard({super.key, required this.detail});
  final CourseGradeDetail detail;

  @override
  State<ProjectionCard> createState() => _ProjectionCardState();
}

class _ProjectionCardState extends State<ProjectionCard> {
  double? _assumed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rule = PassingRule.current;
    final p = GradeProjection.of(widget.detail);
    final status = p.statusFor(rule.threshold);

    if (status == ProjectionStatus.sinDatos ||
        status == ProjectionStatus.cerrado) {
      return const SizedBox.shrink();
    }

    // Con dos o más pendientes se puede simular la primera y ver el efecto
    // sobre la última; con una sola no hay nada que mover.
    final simulable = p.pending.length > 1;
    final first = p.pending.first;
    final rest = p.pending.skip(1).toList();
    final assumed = _assumed ?? rule.minimumGrade.toDouble();

    final required = simulable
        ? p.requiredAssuming({first.name: assumed}, rule.threshold)
        : p.requiredUniform(rule.threshold);
    final practical = GradeProjection.practical(required);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: AppRadii.rXxl,
        border: Border.all(color: NexoTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: NexoTheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadii.rSm,
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  size: AppIcon.lg,
                  color: NexoTheme.primary,
                ),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.projectionTitle,
                      style: TextStyle(
                        fontSize: AppFont.title,
                        fontWeight: FontWeight.w800,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                    Text(
                      l.projectionMinimum('${rule.minimumGrade}'),
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
          const Gap(AppSpacing.lg),
          switch (status) {
            ProjectionStatus.yaAprobado => _Verdict(
              icon: Icons.verified_rounded,
              color: NexoTheme.success,
              text: l.projectionAlreadyPassed,
            ),
            ProjectionStatus.imposible => _Verdict(
              icon: Icons.info_outline_rounded,
              color: NexoTheme.warning,
              text: l.projectionOutOfReach,
            ),
            _ => _Needed(
              value: practical,
              exact: required,
              units: simulable ? rest : p.pending,
            ),
          },
          if (status == ProjectionStatus.alcanzable && simulable) ...[
            const Gap(AppSpacing.lg),
            Divider(height: 1, color: NexoTheme.border),
            const Gap(AppSpacing.md),
            Text(
              l.projectionAssume(first.name, assumed.round().toString()),
              style: TextStyle(
                fontSize: AppFont.small,
                color: NexoTheme.textSecondary,
              ),
            ),
            Slider(
              value: assumed,
              min: 0,
              max: 20,
              divisions: 20,
              label: assumed.round().toString(),
              onChanged: (v) => setState(() => _assumed = v),
            ),
          ],
        ],
      ),
    );
  }
}

class _Needed extends StatelessWidget {
  const _Needed({
    required this.value,
    required this.exact,
    required this.units,
  });
  final int? value;
  final double? exact;
  final List<UnitGrades> units;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nombres = units.map((u) => u.name).join(' · ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GradeBadge(text: '${value ?? '—'}', size: 58, fontSize: 22),
        const Gap.h(AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                units.length > 1
                    ? l.projectionNeedEach
                    : l.projectionNeedSingle,
                style: TextStyle(
                  fontSize: AppFont.body,
                  fontWeight: FontWeight.w700,
                  color: NexoTheme.textPrimary,
                  height: 1.3,
                ),
              ),
              const Gap(AppSpacing.xxs),
              Text(
                nombres,
                style: TextStyle(
                  fontSize: AppFont.small,
                  color: NexoTheme.textSecondary,
                ),
              ),
              if (exact != null) ...[
                const Gap(AppSpacing.xxs),
                Text(
                  l.projectionExact(exact!.toStringAsFixed(2)),
                  style: TextStyle(
                    fontSize: AppFont.caption,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadii.rSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIcon.lg, color: color),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.small,
                height: 1.4,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
