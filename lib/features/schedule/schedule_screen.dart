import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/schedule/schedule_detail_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<ScheduleScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<ScheduleScreen> {
  bool _weekView = true;
  @override
  void initState() {
    super.initState();
    if (!widget.store.schedule.hasValue) {
      widget.store.loadHorarioActual();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final state = widget.store.schedule;
        final finished = widget.store.finishedSubjectsThisTerm;
        final agrupadas = ScheduleClassGroup.groupBy(
          state.value ?? const [],
          finishedSubjects: finished,
        ).length;
        final list = RefreshIndicator(
          onRefresh: () => widget.store.loadHorarioActual(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: AppLocalizations.of(context).titleSchedule,
                  subtitle: state.hasValue
                      ? AppLocalizations.of(
                          context,
                        ).schedulePeriodActiveCount(agrupadas)
                      : AppLocalizations.of(context).schedulePeriodActive,
                  actions: [
                    _ViewToggle(
                      weekView: _weekView,
                      onChanged: (v) => setState(() => _weekView = v),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: PageBody(
                  child: AnimatedSwitcher(
                    duration: AppDurations.normal,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_weekView),
                      child: _buildBody(context, state),
                    ),
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

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<ScheduleClass>> state,
  ) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) {
      return const _Loading();
    }
    if (state.error != null && !state.hasValue) {
      return SectionCard(
        title: l.scheduleErrorTitle,
        icon: Icons.cloud_off_outlined,
        iconColor: NexoTheme.danger,
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l.scheduleLoadError,
          subtitle: humanizeError(state.error),
          color: NexoTheme.danger,
          onRetry: () => widget.store.loadHorarioActual(),
        ),
      );
    }
    final allClases = state.value ?? const <ScheduleClass>[];
    final clases = allClases.where((c) {
      if (c.startTime.isEmpty || c.endTime.isEmpty) return false;
      return true;
    }).toList();
    if (clases.isEmpty) {
      return SectionCard(
        title: l.scheduleNoClassesTitle,
        icon: Icons.calendar_today_outlined,
        child: EmptyState(
          icon: Icons.event_busy_rounded,
          title: l.scheduleNoClassesSubtitle,
        ),
      );
    }
    return _weekView ? _WeekView(clases: clases) : _DayListView(clases: clases);
  }
}

class _ViewToggle extends StatelessWidget {
  final bool weekView;
  final ValueChanged<bool> onChanged;
  const _ViewToggle({required this.weekView, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexoTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggle(l.scheduleToggleWeek, weekView, () => onChanged(true)),
          _toggle(l.scheduleToggleList, !weekView, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? NexoTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedDefaultTextStyle(
        duration: AppDurations.fast,
        style: TextStyle(
          color: active ? Colors.white : NexoTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        child: Text(label),
      ),
    ),
  );
}

class _WeekView extends StatelessWidget {
  final List<ScheduleClass> clases;
  const _WeekView({required this.clases});
  @override
  Widget build(BuildContext context) {
    final byDay = <int, List<ScheduleClass>>{};
    for (final c in clases) {
      byDay.putIfAbsent(c.weekday, () => []).add(c);
    }
    for (final list in byDay.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    final today = DateTime.now().weekday;
    final daysOrder = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ].where((d) => byDay.containsKey(d)).toList();
    if (daysOrder.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_rounded,
        title: AppLocalizations.of(context).scheduleNoClassesScheduled,
      );
    }
    final cards = [
      for (var i = 0; i < daysOrder.length; i++)
        Reveal(
          index: i,
          child: _DaySection(
            day: daysOrder[i],
            clases: byDay[daysOrder[i]]!,
            isToday: daysOrder[i] == today,
          ),
        ),
    ];
    if (context.isDesktop) {
      const spacing = 14.0;
      return LayoutBuilder(
        builder: (ctx, c) {
          final w = (c.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final card in cards) SizedBox(width: w, child: card),
            ],
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final card in cards) ...[card, const SizedBox(height: 14)],
      ],
    );
  }
}

class _DayListView extends StatelessWidget {
  final List<ScheduleClass> clases;
  const _DayListView({required this.clases});
  @override
  Widget build(BuildContext context) {
    final store = context.findAncestorWidgetOfExactType<ScheduleScreen>()?.store;
    final finished = store?.finishedSubjectsThisTerm ?? const {};
    final byDay = <int, List<ScheduleClass>>{};
    for (final c in clases) {
      byDay.putIfAbsent(c.weekday, () => []).add(c);
    }
    final gruposTotales = <ScheduleClassGroup>[];
    final days = byDay.keys.toList()..sort();
    for (final d in days) {
      gruposTotales.addAll(ScheduleClassGroup.groupBy(byDay[d]!, finishedSubjects: finished));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var i = 0; i < gruposTotales.length; i++) ...[
              Reveal(
                index: i,
                child: _GrupoTile(grupo: gruposTotales[i], showDay: true, store: store),
              ),
              if (i < gruposTotales.length - 1) const Divider(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final int day;
  final List<ScheduleClass> clases;
  final bool isToday;
  const _DaySection({
    required this.day,
    required this.clases,
    required this.isToday,
  });
  @override
  Widget build(BuildContext context) {
    final store = context.findAncestorWidgetOfExactType<ScheduleScreen>()?.store;
    final finished = store?.finishedSubjectsThisTerm ?? const {};
    final grupos = ScheduleClassGroup.groupBy(clases, finishedSubjects: finished);
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isToday ? NexoTheme.primary : NexoTheme.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  Fmt.dayLabel(day),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: NexoTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 10),
                if (isToday)
                  StatusChip(text: l.detailToday, color: NexoTheme.primary),
                const Spacer(),
                Text(
                  l.gradesCoursesCount(grupos.length),
                  style: TextStyle(
                    fontSize: 12,
                    color: NexoTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < grupos.length; i++) ...[
              _GrupoTile(grupo: grupos[i], store: store),
              if (i < grupos.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrupoTile extends StatefulWidget {
  final ScheduleClassGroup grupo;
  final bool showDay;
  final AppStore? store;
  const _GrupoTile({required this.grupo, this.showDay = false, this.store});
  @override
  State<_GrupoTile> createState() => _GrupoTileState();
}

class _GrupoTileState extends State<_GrupoTile> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(_isHovered ? 6.0 : 0.0, 0.0, 0.0),
        decoration: BoxDecoration(
          color: _isHovered ? NexoTheme.card : NexoTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? NexoTheme.primary : NexoTheme.border,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: NexoTheme.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ScheduleDetailScreen.open(context, widget.grupo, store: widget.store),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 80,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? NexoTheme.primary.withValues(alpha: 0.06)
                          : NexoTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isHovered
                            ? NexoTheme.primary.withValues(alpha: 0.4)
                            : NexoTheme.border,
                      ),
                    ),
                    child: Builder(
                      builder: (_) {
                        final h24 = AppStorage.instance.use24h;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Fmt.time(widget.grupo.startTime, h24: h24),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: NexoTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 20,
                              height: 1.5,
                              color: _isHovered
                                  ? NexoTheme.primary.withValues(alpha: 0.3)
                                  : NexoTheme.border,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              Fmt.time(widget.grupo.endTime, h24: h24),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: NexoTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.grupo.subject,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: NexoTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        if (widget.grupo.isSequentialWorkshop) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              StatusChip(
                                text: 'Bloque Secuencial',
                                color: NexoTheme.primary,
                                icon: Icons.sync_alt_rounded,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            if (widget.showDay)
                              _meta(
                                Icons.calendar_today_outlined,
                                Fmt.dayLabel(widget.grupo.weekday),
                              ),

                            if (widget.grupo.room.isNotEmpty)
                              _meta(
                                Icons.location_on_outlined,
                                Fmt.formatAula(widget.grupo.room),
                              ),
                            if (widget.grupo.sessions.isNotEmpty)
                              Builder(builder: (_) {
                                var s = widget.grupo.sessions.first.section.trim();
                                if (s.toLowerCase().startsWith('sec')) {
                                  s = s.replaceFirst(RegExp(r'sec\.?\s*', caseSensitive: false), '');
                                }
                                return _meta(
                                  Icons.tag_rounded,
                                  'Sección $s',
                                );
                              }),
                          ],
                        ),
                        if (widget.grupo.teacher.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: NexoTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.grupo.teacher,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: NexoTheme.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        for (final s in widget.grupo.sessions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Icon(
                                  s.typeCode.toUpperCase() == 'T'
                                      ? Icons.menu_book_outlined
                                      : Icons.science_outlined,
                                  size: 13,
                                  color: NexoTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  () {
                                    final h24 = AppStorage.instance.use24h;
                                    return '${s.typeName} '
                                        '(${Fmt.time(s.startTime, h24: h24)} '
                                        '- ${Fmt.time(s.endTime, h24: h24)})';
                                  }(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NexoTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text, {Color? color}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color ?? NexoTheme.textSecondary),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontSize: 12,
            color: color ?? NexoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 3; i++) ...[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Skeleton(height: 18, width: 120),
                  SizedBox(height: 16),
                  Skeleton(height: 64, radius: 14),
                  SizedBox(height: 10),
                  Skeleton(height: 64, radius: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
