import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/schedule/schedule_detail_screen.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/l10n/app_localizations.dart';

class TodayClassesWidget extends StatelessWidget {
  final List<ScheduleClass> all;
  final DateTime? nowOverride;
  final bool isCompact;
  const TodayClassesWidget({super.key, required this.all, this.nowOverride, this.isCompact = false});
  DateTime get now => nowOverride ?? DateTime.now();
  @override
  Widget build(BuildContext context) {
    final today = now.weekday;
    final todayClasses = all
        .where((c) => c.weekday == today)
        .toList(growable: false);
    final groups = ScheduleClassGroup.groupBy(todayClasses);
    final nowHM = _hm(now);
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: l.homeTodayTitle,
      subtitle: Fmt.dayLabel(today),
      icon: Icons.today_outlined,
      iconColor: NexoTheme.primary,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: NexoTheme.primary.withValues(alpha: 0.1),
          borderRadius: AppRadii.rPill,
        ),
        child: Text(
          l.gradesCoursesCount(groups.length),
          style: TextStyle(
            fontSize: AppFont.small,
            fontWeight: FontWeight.w600,
            color: NexoTheme.primary,
          ),
        ),
      ),
      child: groups.isEmpty
          ? const _Empty()
          : Column(
              children: [
                for (var i = 0; i < (isCompact ? 1 : groups.length); i++) ...[
                  _CourseTile(group: groups[i], nowHM: nowHM),
                  if (i < (isCompact ? 1 : groups.length) - 1) const Gap(AppSpacing.sm + 2),
                ],
                if (isCompact && groups.length > 1) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l.homeMoreClassesToday(groups.length - 1),
                      style: TextStyle(
                        color: NexoTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  static String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl + 4),
    alignment: Alignment.center,
    child: Column(
      children: [
        Icon(
          Icons.celebration_outlined,
          size: 36,
          color: NexoTheme.textSecondary,
        ),
        const Gap(AppSpacing.sm),
        Text(
          AppLocalizations.of(context).homeNoClassesToday,
          style: TextStyle(
            fontSize: AppFont.body,
            color: NexoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _CourseTile extends StatelessWidget {
  final ScheduleClassGroup group;
  final String nowHM;
  const _CourseTile({required this.group, required this.nowHM});
  bool _isOngoing(ScheduleClass c) =>
      c.startTime.compareTo(nowHM) <= 0 && nowHM.compareTo(c.endTime) < 0;
  bool _isPast(String endTime) => endTime.compareTo(nowHM) <= 0;
  @override
  Widget build(BuildContext context) {
    final anyOngoing = group.sessions.any(_isOngoing);
    final allPast = group.sessions.every((s) => _isPast(s.endTime));
    final accent = anyOngoing
        ? NexoTheme.success
        : allPast
        ? NexoTheme.textSecondary
        : NexoTheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScheduleDetailScreen.open(context, group),
        borderRadius: AppRadii.rLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg - 2),
          decoration: BoxDecoration(
            color: anyOngoing
                ? NexoTheme.success.withValues(alpha: 0.06)
                : NexoTheme.surface,
            borderRadius: AppRadii.rLg,
            border: Border.all(
              color: anyOngoing
                  ? NexoTheme.success.withValues(alpha: 0.3)
                  : NexoTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.subject,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppFont.subtitle,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: allPast
                                      ? NexoTheme.textSecondary
                                      : NexoTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (anyOngoing) ...[
                              const Gap.h(AppSpacing.sm),
                              _badge(AppLocalizations.of(context).classOngoing, NexoTheme.success),
                            ],
                          ],
                        ),
                        if (group.room.isNotEmpty && !group.hasMixedRooms) ...[
                          const Gap(AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: AppIcon.xs,
                                color: NexoTheme.textSecondary,
                              ),
                              const Gap.h(AppSpacing.xs),
                              Text(
                                Fmt.formatAula(group.room),
                                style: TextStyle(
                                  fontSize: AppFont.small,
                                  color: NexoTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (group.hasMixedRooms) ...[
                          const Gap(AppSpacing.xs),
                          for (final entry in group.roomsByType.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: AppIcon.xs,
                                    color: NexoTheme.textSecondary,
                                  ),
                                  const Gap.h(AppSpacing.xs),
                                  Text(
                                    '${entry.key}: ${Fmt.formatAula(entry.value)}',
                                    style: TextStyle(
                                      fontSize: AppFont.small,
                                      color: NexoTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.md),
              ...group.sessions.map(
                (s) => _SessionRow(
                  session: s,
                  ongoing: _isOngoing(s),
                  past: _isPast(s.endTime),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    decoration: BoxDecoration(color: color, borderRadius: AppRadii.rPill),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _SessionRow extends StatelessWidget {
  final ScheduleClass session;
  final bool ongoing;
  final bool past;
  const _SessionRow({
    required this.session,
    required this.ongoing,
    required this.past,
  });
  @override
  Widget build(BuildContext context) {
    final c = ongoing
        ? NexoTheme.success
        : past
        ? NexoTheme.textMuted
        : NexoTheme.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            session.typeCode.toUpperCase() == 'T'
                ? Icons.menu_book_outlined
                : Icons.science_outlined,
            size: AppIcon.xs,
            color: c,
          ),
          const Gap.h(AppSpacing.sm - 2),
          Text(
            session.typeName,
            style: TextStyle(
              fontSize: AppFont.small,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
          const Gap.h(AppSpacing.sm),
          Builder(
            builder: (_) {
              final h24 = AppStorage.instance.use24h;
              return Text(
                '${Fmt.time(session.startTime, h24: h24)} – '
                '${Fmt.time(session.endTime, h24: h24)}',
                style: TextStyle(
                  fontSize: AppFont.small,
                  color: c,
                  decoration: past
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
