import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/schedule/schedule_detail_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.store.teacherSchedule.hasValue) {
      widget.store.loadDocenteHorario();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final state = widget.store.teacherSchedule;
        final loading = state.loading && !state.hasValue;
        final clases = state.value ?? const <ScheduleClass>[];
        final byDay = <int, List<ScheduleClass>>{};
        for (final c in clases) {
          byDay.putIfAbsent(c.weekday, () => []).add(c);
        }
        for (final list in byDay.values) {
          list.sort((a, b) => a.startTime.compareTo(b.startTime));
        }
        final today = DateTime.now().weekday;
        final days = byDay.keys.toList()..sort();
        return RefreshIndicator(
          onRefresh: () => widget.store.loadDocenteHorario(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: l.titleSchedule,
                  subtitle: loading
                      ? l.docenteLoadingClasses
                      : l.docenteSessionsWeeklyCount(clases.length),
                ),
              ),
              SliverToBoxAdapter(
                child: PageBody(
                  child: loading
                      ? const Column(
                          children: [
                            Skeleton(height: 120, radius: 22),
                            Gap(AppSpacing.md),
                            Skeleton(height: 120, radius: 22),
                            Gap(AppSpacing.md),
                            Skeleton(height: 120, radius: 22),
                          ],
                        )
                      : clases.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 48,
                                color: NexoTheme.textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l.docenteNoClassesRegistered,
                                style: TextStyle(
                                  fontSize: AppFont.body,
                                  color: NexoTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < days.length; i++) ...[
                              Reveal(
                                index: i,
                                child: _DayCard(
                                  day: days[i],
                                  clases: byDay[days[i]]!,
                                  isToday: days[i] == today,
                                ),
                              ),
                              const Gap(AppSpacing.md + 2),
                            ],
                          ],
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  final int day;
  final List<ScheduleClass> clases;
  final bool isToday;
  const _DayCard({
    required this.day,
    required this.clases,
    required this.isToday,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final grupos = ScheduleClassGroup.groupBy(clases);
    final h24 = AppStorage.instance.use24h;
    return SectionCard(
      title: Fmt.dayLabel(day),
      subtitle: l.docenteCourseCount(grupos.length),
      icon: isToday ? Icons.today_rounded : Icons.calendar_today_outlined,
      iconColor: isToday ? NexoTheme.primary : NexoTheme.accent,
      trailing: isToday
          ? StatusChip(text: l.detailToday, color: NexoTheme.primary)
          : null,
      child: Column(
        children: [
          for (var i = 0; i < grupos.length; i++) ...[
            _GrupoTile(grupo: grupos[i], h24: h24),
            if (i < grupos.length - 1) const Gap(AppSpacing.sm + 2),
          ],
        ],
      ),
    );
  }
}

class _GrupoTile extends StatelessWidget {
  final ScheduleClassGroup grupo;
  final bool h24;
  const _GrupoTile({required this.grupo, required this.h24});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ScheduleDetailScreen.open(context, grupo),
        borderRadius: AppRadii.rLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: AppRadii.rLg,
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: NexoTheme.bg,
                  borderRadius: AppRadii.rMd,
                  border: Border.all(color: NexoTheme.border),
                ),
                child: Column(
                  children: [
                    Text(
                      Fmt.time(grupo.startTime, h24: h24),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: NexoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(width: 14, height: 1, color: NexoTheme.border),
                    const SizedBox(height: 2),
                    Text(
                      Fmt.time(grupo.endTime, h24: h24),
                      style: TextStyle(
                        fontSize: 12,
                        color: NexoTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grupo.subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFont.subtitle,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _meta(
                          Icons.tag_rounded,
                          'Sección ${grupo.sessions.first.section}',
                        ),
                        if (grupo.room.isNotEmpty)
                          _meta(
                            Icons.location_on_outlined,
                            Fmt.formatAula(grupo.room),
                          ),
                      ],
                    ),
                    const Gap(AppSpacing.xs + 2),
                    Row(
                      children: [
                        for (final s in grupo.sessions)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (s.typeCode.toUpperCase() == 'T'
                                            ? NexoTheme.info
                                            : NexoTheme.success)
                                        .withValues(alpha: 0.14),
                                borderRadius: AppRadii.rPill,
                              ),
                              child: Text(
                                s.typeName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: s.typeCode.toUpperCase() == 'T'
                                      ? NexoTheme.info
                                      : NexoTheme.success,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: NexoTheme.textSecondary),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontSize: 12,
            color: NexoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
