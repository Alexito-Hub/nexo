import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/core/festivity/festivity.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/domain/dashboard_widget_config.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/pending_payments_widget.dart';
import 'package:nexo/shared/widgets/next_class_widget.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/student_avatar.dart';
import 'package:nexo/shared/widgets/today_classes_widget.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/features/legal/support_screen.dart';
import 'package:nexo/features/festivity/widgets/escarapela_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.connectivity,
    required this.onJump,
  });
  final AppStore store;
  final ConnectivityService connectivity;
  final ValueChanged<int> onJump;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: () => store.loadHomeEssentials(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(store: store, connectivity: connectivity),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.contentPadding,
                  vertical: 4,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.isDesktop ? 1600 : 1240,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Reveal(
                            index: 1,
                            child: context.isWide
                                ? _DashboardArea(store: store, onJump: onJump)
                                : _MobileStack(store: store, onJump: onJump),
                          ),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final AppStore store;
  final ConnectivityService connectivity;
  const _Header({required this.store, required this.connectivity});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profile = store.profile.value;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.contentPadding,
        24,
        context.contentPadding,
        16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop ? 1600 : 1240,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: NexoTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: StudentAvatar(
                  code: profile?.id,
                  name: profile?.fullName ?? '',
                  size: 56,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HomeGreeting(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            profile == null ? '...' : Fmt.firstName(profile.fullName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: NexoTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (AppStorage.instance.festivityDecor &&
                            FestivityService.active(DateTime.now())?.festivity.id == 'fiestas_patrias') ...[
                          const SizedBox(width: 8),
                          const EscarapelaWidget(),
                        ],
                      ],
                    ),
                    if (profile != null)
                      Text(
                        profile.career,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: NexoTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              ListenableBuilder(
                listenable: connectivity,
                builder: (context, _) {
                  final isOnline = connectivity.hasInternet;
                  final sigmaOnline =
                      connectivity.sigmaStatus == ServerStatus.online;
                  final intranetOnline =
                      connectivity.intranetStatus == ServerStatus.online;
                  final isFullyOnline =
                      isOnline && sigmaOnline && intranetOnline;
                  final color = isFullyOnline
                      ? NexoTheme.success
                      : NexoTheme.danger;
                  return Tooltip(
                    message: l.homeVerifyConnectivity,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showConnectivityDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectivityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final l = AppLocalizations.of(context);
        return Dialog(
          backgroundColor: NexoTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: NexoTheme.border),
          ),
          child: ListenableBuilder(
            listenable: connectivity,
            builder: (context, _) {
              final isOnline = connectivity.hasInternet;
              final sigma = connectivity.sigmaStatus;
              final intranet = connectivity.intranetStatus;
              Widget buildStatusTile(
                String title,
                bool active,
                ServerStatus? status,
              ) {
                final Color color;
                final String label;
                final IconData icon;
                if (status != null) {
                  switch (status) {
                    case ServerStatus.online:
                      color = NexoTheme.success;
                      label = l.connectivityOnline;
                      icon = Icons.check_circle_outline_rounded;
                      break;
                    case ServerStatus.degraded:
                      color = NexoTheme.warning;
                      label = l.connectivityDegraded;
                      icon = Icons.error_outline_rounded;
                      break;
                    case ServerStatus.offline:
                      color = NexoTheme.danger;
                      label = l.connectivityOffline;
                      icon = Icons.cancel_outlined;
                      break;
                  }
                } else {
                  color = active ? NexoTheme.success : NexoTheme.danger;
                  label = active
                      ? l.connectivityConnected
                      : l.connectivityDisconnected;
                  icon = active ? Icons.wifi_rounded : Icons.wifi_off_rounded;
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: NexoTheme.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NexoTheme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NexoTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [NexoTheme.primary, NexoTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: NexoTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sensors_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.connectivityStatusTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NexoTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.connectivityDiagnosticsSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: NexoTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildStatusTile(l.connectivityInternet, isOnline, null),
                    buildStatusTile(l.connectivitySigma, isOnline, sigma),
                    buildStatusTile(l.connectivityIntranet, isOnline, intranet),
                    const SizedBox(height: 16),
                    Text(
                      l.connectivityBackupNote,
                      style: TextStyle(
                        fontSize: 12,
                        color: NexoTheme.textMuted,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        SupportScreen.open(context);
                      },
                      icon: const Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: NexoTheme.success,
                      ),
                      label: Text(
                        l.supportContactButton,
                        style: const TextStyle(
                          color: NexoTheme.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => connectivity.checkNow(),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(l.actionRetry),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: NexoTheme.border),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NexoTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l.actionClose),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HomeGreeting extends StatefulWidget {
  const _HomeGreeting();
  @override
  State<_HomeGreeting> createState() => _HomeGreetingState();
}

class _HomeGreetingState extends State<_HomeGreeting> {
  late final Timer _timer;
  int _i = 0;
  static const _idlePhrases = <String>[
    'Nos alegra verte',
    'Qué bueno tenerte por aquí',
    'Tu UPLA en un solo lugar',
    'Al día con tu vida académica',
    'Todo tu campus, a la mano',
    '¿Todo listo para hoy?',
    '¿Qué tenemos para hoy?',
    'Qué gusto verte de nuevo',
  ];
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _i++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 14, color: NexoTheme.textSecondary);
    final festive = base.copyWith(
      color: NexoTheme.primary,
      fontWeight: FontWeight.w700,
    );
    final time = '${Fmt.greeting(DateTime.now())},';
    final active = AppStorage.instance.festivityDecor
        ? FestivityService.active(DateTime.now())
        : null;
    if (MediaQuery.of(context).disableAnimations) {
      final txt = active?.greeting ?? time;
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          txt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: active != null ? festive : base,
        ),
      );
    }
    final phrases = active != null
        ? <String>[time, ...active.greetings]
        : <String>[time, ..._idlePhrases];
    final idx = _i % phrases.length;
    final isFest = active != null && idx != 0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Text(
        phrases[idx],
        key: ValueKey(phrases[idx]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isFest ? festive : base,
      ),
    );
  }
}

// _StatsGrid eliminado (ahora las métricas se generan en _DashboardWidgetWrapper)

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool loading;
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.loading = false,
  });
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NexoTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NexoTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: NexoTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                data.loading
                    ? const Skeleton(height: 18, width: 56)
                    : Text(
                        data.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: NexoTheme.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.1,
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

class _DashboardArea extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> onJump;
  const _DashboardArea({required this.store, required this.onJump});
  @override
  Widget build(BuildContext context) {
    final schedule = store.schedule.value ?? const <ScheduleClass>[];
    final leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (schedule.isNotEmpty) ...[
          NextClassWidget(all: schedule),
          const SizedBox(height: 16),
        ],
        _ClasesHoyBlock(
          state: store.schedule,
          onSeeAll: () => onJump(1),
          onRetry: () => store.loadHorarioActual(),
        ),
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: leftCol),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _PagosBlock(
            state: store.pendingInstallments,
            onSeeAll: () => onJump(3),
            onRetry: () => store.loadCuotasPendientes(),
          ),
        ),
      ],
    );
  }
}

class _DashboardWidgetWrapper extends StatelessWidget {
  final DashboardWidgetConfig config;
  final AppStore store;
  final ValueChanged<int> onJump;

  const _DashboardWidgetWrapper({
    super.key,
    required this.config,
    required this.store,
    required this.onJump,
  });

  Widget _buildChild(BuildContext context) {
    final isCompact = config.span == 1;
    final l = AppLocalizations.of(context);

    switch (config.id) {
      case 'stats_promedio':
        final promCiclo = store.promedioCicloActual;
        return _StatTile(data: _StatData(
          label: l.homeMetricPromedioCiclo,
          value: promCiclo == null ? '—' : promCiclo.toStringAsFixed(2),
          icon: Icons.trending_up_rounded,
          color: NexoTheme.primary,
          loading: store.promedios.showSkeleton && store.resumen.showSkeleton,
        ));
      case 'stats_creditos':
        final p = store.profile.value;
        final creditosAprob = store.approvedCredits ?? p?.creditsApproved;
        final creditosTotal = store.totalCredits;
        final creditosLabel = creditosAprob == null ? '—' : creditosTotal != null && creditosTotal > 0 ? '$creditosAprob/$creditosTotal' : '$creditosAprob';
        return _StatTile(data: _StatData(
          label: l.homeMetricCreditos,
          value: creditosLabel,
          icon: Icons.school_rounded,
          color: NexoTheme.accent,
          loading: store.profile.showSkeleton,
        ));
      case 'stats_clases_hoy':
        final schedule = store.schedule.value ?? const <ScheduleClass>[];
        final today = DateTime.now().weekday;
        final clasesHoy = schedule.where((c) => c.weekday == today).length;
        return _StatTile(data: _StatData(
          label: l.homeMetricClasesHoy,
          value: '$clasesHoy',
          icon: Icons.today_rounded,
          color: NexoTheme.success,
          loading: store.schedule.showSkeleton,
        ));
      case 'stats_pagos':
        final installments = store.pendingInstallments.value ?? const <Payment>[];
        final montoPendiente = installments.fold<double>(0, (acc, c) => acc + c.total);
        return _StatTile(data: _StatData(
          label: l.homeMetricPorPagar,
          value: Fmt.currency(montoPendiente),
          icon: Icons.account_balance_wallet_rounded,
          color: NexoTheme.warning,
          loading: store.pendingInstallments.showSkeleton,
        ));
      case 'next_class':
        final schedule = store.schedule.value ?? const <ScheduleClass>[];
        if (schedule.isEmpty) return const SizedBox.shrink();
        return NextClassWidget(all: schedule);
      case 'today_classes':
        return _ClasesHoyBlock(
          state: store.schedule,
          onSeeAll: () => onJump(1),
          onRetry: () => store.loadHorarioActual(),
          isCompact: isCompact,
        );
      case 'pending_payments':
        return _PagosBlock(
          state: store.pendingInstallments,
          onSeeAll: () => onJump(3),
          onRetry: () => store.loadCuotasPendientes(),
          isCompact: isCompact,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);
    if (child is SizedBox) return child;

    const totalSpacing = 12.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = context.contentPadding * 2;
    final availableWidth = (screenWidth - padding).clamp(160.0, 1600.0);
    final colWidth = (availableWidth - totalSpacing * 3) / 4;

    // Los bloques de contenido (horario, pagos, próxima clase) necesitan al
    // menos media pantalla en móvil; con span 1 el texto colapsa en vertical.
    final minSpan = config.id.startsWith('stats_') ? config.span : 4;
    final span = minSpan > config.span ? minSpan : config.span;
    final itemWidth = (span >= 4
            ? availableWidth
            : (colWidth * span + totalSpacing * (span - 1)) - 0.5)
        .clamp(72.0, availableWidth);

    final isEditing = store.editingDashboardWidgetId == config.id;

    final content = GestureDetector(
      onTap: () {
        if (isEditing) store.setEditingDashboardWidget(null);
      },
      child: SizedBox(
        width: itemWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (isEditing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: NexoTheme.primary, width: 3),
                  ),
                ),
              ),
            if (isEditing && config.id.startsWith('stats_'))
              Positioned(
                right: -6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return GestureDetector(
                        onTap: () {
                          if (config.span == 1) {
                            store.setDashboardWidgetSpan(config.id, 2);
                          } else if (config.span == 2) {
                            store.setDashboardWidgetSpan(config.id, 4);
                          } else {
                            store.setDashboardWidgetSpan(config.id, 1);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: NexoTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                config.span < 4 ? Icons.unfold_more_rounded : Icons.unfold_less_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        if (details.data != config.id) {
          store.reorderDashboard(details.data, config.id, save: false);
          return true;
        }
        return false;
      },
      onAcceptWithDetails: (details) {
        store.saveDashboardLayout();
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: itemWidth,
          margin: EdgeInsets.zero,
          child: LongPressDraggable<String>(
            data: config.id,
            delay: const Duration(milliseconds: 250),
            onDragStarted: () => store.setEditingDashboardWidget(config.id),
            onDragEnd: (_) => store.saveDashboardLayout(),
            feedback: Material(
              color: Colors.transparent,
              elevation: 12,
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: 0.8,
                child: SizedBox(width: itemWidth, child: content),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.2, child: content),
            child: content,
          ),
        );
      },
    );
  }
}

class _MobileStack extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> onJump;
  const _MobileStack({required this.store, required this.onJump});
  @override
  Widget build(BuildContext context) {
    final layout = store.dashboardLayout;
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (store.editingDashboardWidgetId != null) {
          store.setEditingDashboardWidget(null);
        }
      },
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final config in layout)
            _DashboardWidgetWrapper(
              key: ValueKey(config.id),
              config: config,
              store: store,
              onJump: onJump,
            ),
        ],
      ),
    );
  }
}

class _ClasesHoyBlock extends StatelessWidget {
  final AsyncValue<List<ScheduleClass>> state;
  final VoidCallback onSeeAll;
  final VoidCallback? onRetry;
  final bool isCompact;
  const _ClasesHoyBlock({
    required this.state,
    required this.onSeeAll,
    this.onRetry,
    this.isCompact = false,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) {
      return SectionCard(
        title: l.homeTodayTitle,
        icon: Icons.today_outlined,
        child: const Column(
          children: [
            Skeleton(height: 64, radius: 14),
            SizedBox(height: 10),
            Skeleton(height: 64, radius: 14),
          ],
        ),
      );
    }
    if (state.error != null && !state.hasValue) {
      return SectionCard(
        title: l.homeTodayTitle,
        icon: Icons.today_outlined,
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: l.homeScheduleLoadError,
          subtitle: humanizeError(state.error),
          color: NexoTheme.danger,
          onRetry: onRetry,
        ),
      );
    }
    return Column(
      children: [
        TodayClassesWidget(all: state.value ?? const [], isCompact: isCompact),
        if (!isCompact) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onSeeAll,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(l.homeSeeFullWeek),
            ),
          ),
        ],
      ],
    );
  }
}

class _PagosBlock extends StatelessWidget {
  final AsyncValue<List<Payment>> state;
  final VoidCallback onSeeAll;
  final VoidCallback? onRetry;
  final bool isCompact;
  const _PagosBlock({
    required this.state,
    required this.onSeeAll,
    this.onRetry,
    this.isCompact = false,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) {
      return SectionCard(
        title: l.homePendingPaymentsTitle,
        icon: Icons.account_balance_wallet_outlined,
        child: const Column(
          children: [
            Skeleton(height: 60, radius: 14),
            SizedBox(height: 10),
            Skeleton(height: 60, radius: 14),
          ],
        ),
      );
    }
    if (state.error != null && !state.hasValue) {
      return SectionCard(
        title: l.homePendingPaymentsTitle,
        icon: Icons.account_balance_wallet_outlined,
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: l.homePaymentsLoadError,
          subtitle: humanizeError(state.error),
          color: NexoTheme.danger,
          onRetry: onRetry,
        ),
      );
    }
    return Column(
      children: [
        PendingPaymentsWidget(installments: state.value ?? const [], isCompact: isCompact),
        if (!isCompact) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onSeeAll,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(l.homeSeeAllPayments),
            ),
          ),
        ],
      ],
    );
  }
}
