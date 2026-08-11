import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/core/shortcuts.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/ms_auth_service.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/features/festivity/festivity_overlay.dart';
import 'package:nexo/features/teacher/teacher_courses_screen.dart';
import 'package:nexo/features/teacher/teacher_schedule_screen.dart';
import 'package:nexo/features/teacher/teacher_profile_screen.dart';
import 'package:nexo/features/teacher/teacher_screen.dart';
import 'package:nexo/features/grades/grades_screen.dart';
import 'package:nexo/features/home/home_screen.dart';
import 'package:nexo/features/payments/payments_screen.dart';
import 'package:nexo/features/profile/profile_screen.dart';
import 'package:nexo/features/schedule/schedule_screen.dart';
import 'package:nexo/shared/widgets/logout_dialog.dart';
import 'package:nexo/shared/widgets/update_banner.dart';
import 'package:nexo/shared/widgets/whatsapp_invite_dialog.dart';

class _Tab {
  final String label;
  final IconData icon;
  final IconData iconOutlined;
  const _Tab(this.label, this.icon, this.iconOutlined);
}

List<_Tab> _studentTabs(AppLocalizations l) => [
  _Tab(l.tabHome, Icons.home_rounded, Icons.home_outlined),
  _Tab(
    l.tabSchedule,
    Icons.calendar_today_rounded,
    Icons.calendar_today_outlined,
  ),
  _Tab(l.tabGrades, Icons.school_rounded, Icons.school_outlined),
  _Tab(
    l.tabPayments,
    Icons.account_balance_wallet_rounded,
    Icons.account_balance_wallet_outlined,
  ),
  _Tab(l.tabProfile, Icons.person_rounded, Icons.person_outline_rounded),
];
List<_Tab> _teacherTabs(AppLocalizations l) => [
  _Tab(l.tabHome, Icons.dashboard_rounded, Icons.dashboard_outlined),
  _Tab(l.tabCourses, Icons.menu_book_rounded, Icons.menu_book_outlined),
  _Tab(
    l.tabSchedule,
    Icons.calendar_today_rounded,
    Icons.calendar_today_outlined,
  ),
  _Tab(l.tabProfile, Icons.person_rounded, Icons.person_outline_rounded),
];

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.store,
    required this.session,
    required this.theme,
    required this.msAuth,
    required this.connectivity,
  });
  final AppStore store;
  final SessionService session;
  final ThemeController theme;
  final MsAuthService msAuth;
  final ConnectivityService connectivity;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  final List<int> _history = [0];
  DateTime? _lastBoletaCheck;
  bool _railCollapsed = false;
  final List<GlobalKey<NavigatorState>> _tabNavKeys = List.generate(
    7,
    (_) => GlobalKey<NavigatorState>(),
  );
  final List<String?> _breadcrumbs = List.filled(7, null);
  final Set<int> _visitedTabs = {0};
  final List<ScrollController> _scrollControllers = List.generate(
    7,
    (_) => ScrollController(),
  );
  void _setBreadcrumb(int tab, String? title) {
    if (_breadcrumbs[tab] == title) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _breadcrumbs[tab] != title) {
        setState(() => _breadcrumbs[tab] = title);
      }
    });
  }

  bool _wasOnline = false;
  void _onConnectivityChange() {
    final online = widget.connectivity.hasInternet;
    if (online && !_wasOnline) {
      // Volvió la conexión: reintenta lo que quedó sin datos en el Home
      // en lugar de esperar un refresh manual.
      if (!(widget.session.user?.isTeacher ?? false)) {
        widget.store.retryFailedEssentials();
      }
    }
    _wasOnline = online;
  }

  @override
  void initState() {
    super.initState();
    final isTeacher = widget.session.user?.isTeacher ?? false;
    if (!isTeacher) {
      widget.store.loadHomeEssentials();
    }
    _lastBoletaCheck = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    ShortcutService.instance.addListener(_handleShortcut);
    _wasOnline = widget.connectivity.hasInternet;
    widget.connectivity.addListener(_onConnectivityChange);
    _handleShortcut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowWhatsappInvite(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ShortcutService.instance.removeListener(_handleShortcut);
    widget.connectivity.removeListener(_onConnectivityChange);
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (widget.session.user?.isTeacher ?? false) return;
    final now = DateTime.now();
    if (_lastBoletaCheck != null &&
        now.difference(_lastBoletaCheck!) < const Duration(seconds: 60)) {
      return;
    }
    _lastBoletaCheck = now;
    widget.store.checkActiveBoleta();
  }

  void _handleShortcut() {
    final action = ShortcutService.instance.pendingAction;
    if (action != null) {
      final index = switch (action) {
        AppShortcutType.schedule => 1,
        AppShortcutType.grades => 2,
        AppShortcutType.payments => 3,
      };
      _goTo(index);
      ShortcutService.instance.consume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTeacher = widget.session.user?.isTeacher ?? false;
    final l = AppLocalizations.of(context);
    var idx = 0;
    Widget wrap(Widget page) => PrimaryScrollController(
      controller: _scrollControllers[idx++],
      child: page,
    );
    final List<_Tab> tabs;
    final List<Widget> pages;
    if (isTeacher) {
      tabs = _teacherTabs(l);
      pages = <Widget>[
        wrap(TeacherScreen(store: widget.store)),
        wrap(TeacherCoursesScreen(store: widget.store)),
        wrap(TeacherScheduleScreen(store: widget.store)),
        wrap(
          TeacherProfileScreen(
            store: widget.store,
            session: widget.session,
            theme: widget.theme,
          ),
        ),
      ];
    } else {
      tabs = _studentTabs(l);
      pages = <Widget>[
        wrap(
          HomeScreen(
            store: widget.store,
            connectivity: widget.connectivity,
            onJump: _goTo,
          ),
        ),
        wrap(ScheduleScreen(store: widget.store)),
        wrap(GradesScreen(store: widget.store)),
        wrap(PaymentsScreen(store: widget.store)),
        wrap(
          ProfileScreen(
            store: widget.store,
            session: widget.session,
            theme: widget.theme,
          ),
        ),
      ];
    }
    final safeIndex = _index.clamp(0, pages.length - 1);
    Widget child;
    if (isDesktop) {
      final content = IndexedStack(
        index: safeIndex,
        children: [
          for (var i = 0; i < pages.length; i++)
            if (_visitedTabs.contains(i))
              _TabContent(
                navigatorKey: _tabNavKeys[i],
                root: pages[i],
                onBreadcrumb: (title) => _setBreadcrumb(i, title),
              )
            else
              const SizedBox.shrink(),
        ],
      );
      child = CallbackShortcuts(
        bindings: _tabShortcuts(tabs.length),
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  const UpdateBanner(),
                  Expanded(
                    child: Row(
                      children: [
                        _SideRail(
                          tabs: tabs,
                          index: safeIndex,
                          onChange: _goTo,
                          onLogout: () => _confirmLogout(context),
                          collapsed: _railCollapsed,
                          onToggleCollapse: () =>
                              setState(() => _railCollapsed = !_railCollapsed),
                          breadcrumb: _breadcrumbs[safeIndex],
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: content),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      child = Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const UpdateBanner(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(safeIndex),
                    child: pages[safeIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(
          tabs: tabs,
          index: safeIndex,
          onChange: _goTo,
        ),
      );
    }
    return FestivityOverlay(
      child: PopScope(
        canPop: _history.length <= 1,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_history.length > 1) {
            setState(() {
              _history.removeLast();
              _index = _history.last;
            });
          }
        },
        child: child,
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _tabShortcuts(int count) {
    const digits = <LogicalKeyboardKey>[
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    final n = count.clamp(0, digits.length);
    return {
      for (var i = 0; i < n; i++) ...{
        SingleActivator(digits[i], control: true): () => _goTo(i),
        SingleActivator(digits[i], meta: true): () => _goTo(i),
      },
      const SingleActivator(LogicalKeyboardKey.escape): _closeDetail,
    };
  }

  void _closeDetail() {
    final nav = _tabNavKeys[_index].currentState;
    if (nav != null && nav.canPop()) nav.popUntil((r) => r.isFirst);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    if (await showLogoutConfirm(context)) {
      await widget.session.logout();
    }
  }

  void _goTo(int i) {
    if (_index == i) {
      final nav = _tabNavKeys[i].currentState;
      if (nav != null && nav.canPop()) {
        nav.popUntil((r) => r.isFirst);
      } else {
        _scrollToTop(i);
      }
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _visitedTabs.add(i);
      _history.remove(i);
      _history.add(i);
      _index = i;
    });
  }

  void _scrollToTop(int i) {
    final c = _scrollControllers[i];
    if (c.hasClients) {
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _TabContent extends StatefulWidget {
  const _TabContent({
    required this.navigatorKey,
    required this.root,
    required this.onBreadcrumb,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget root;
  final ValueChanged<String?> onBreadcrumb;
  @override
  State<_TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<_TabContent> {
  late final _BreadcrumbObserver _observer = _BreadcrumbObserver(
    (title) => widget.onBreadcrumb(title),
  );
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      observers: [_observer],
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => widget.root,
        settings: settings,
      ),
    );
  }
}

class _BreadcrumbObserver extends NavigatorObserver {
  _BreadcrumbObserver(this.onChange);
  final ValueChanged<String?> onChange;
  String? _titleOf(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty || name == '/') return null;
    return name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChange(_titleOf(route));
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChange(_titleOf(previousRoute));
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      onChange(_titleOf(previousRoute));
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onChange(_titleOf(newRoute));
}

class _BottomBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onChange;
  const _BottomBar({
    required this.tabs,
    required this.index,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        border: Border(top: BorderSide(color: NexoTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChange(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              i == index ? tabs[i].icon : tabs[i].iconOutlined,
                              key: ValueKey(i == index),
                              color: i == index
                                  ? NexoTheme.primary
                                  : NexoTheme.textMuted,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == index
                                  ? NexoTheme.primary
                                  : NexoTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onChange;
  final Future<void> Function() onLogout;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final String? breadcrumb;
  const _SideRail({
    required this.tabs,
    required this.index,
    required this.onChange,
    required this.onLogout,
    required this.collapsed,
    required this.onToggleCollapse,
    this.breadcrumb,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: collapsed ? 68 : 232,
      color: NexoTheme.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed ? 0 : 20,
              18,
              collapsed ? 0 : 10,
              18,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (!collapsed) ...[
                  Image.asset(
                    'assets/icon.png',
                    width: 32,
                    height: 32,
                    cacheWidth: 96,
                    cacheHeight: 96,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: FestivityWordmark()),
                ],
                IconButton(
                  tooltip: collapsed ? 'Expandir' : 'Colapsar',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    collapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                    color: NexoTheme.textMuted,
                  ),
                  onPressed: onToggleCollapse,
                ),
              ],
            ),
          ),
          for (var i = 0; i < tabs.length; i++) ...[
            _RailItem(
              tab: tabs[i],
              active: i == index,
              collapsed: collapsed,
              breadcrumb: i == index ? breadcrumb : null,
              onTap: () => onChange(i),
            ),
            const SizedBox(height: 4),
          ],
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed ? 8 : 16,
              0,
              collapsed ? 8 : 16,
              16,
            ),
            child: collapsed
                ? IconButton(
                    tooltip: l.actionLogout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    color: NexoTheme.textSecondary,
                    onPressed: onLogout,
                  )
                : OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(l.actionLogout),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NexoTheme.textSecondary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: NexoTheme.border),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final bool collapsed;
  final String? breadcrumb;
  final VoidCallback onTap;
  const _RailItem({
    required this.tab,
    required this.active,
    required this.onTap,
    this.collapsed = false,
    this.breadcrumb,
  });
  @override
  Widget build(BuildContext context) {
    final color = active ? NexoTheme.primary : NexoTheme.textSecondary;
    final icon = Icon(
      active ? tab.icon : tab.iconOutlined,
      color: color,
      size: 22,
    );
    final Widget label = breadcrumb == null
        ? Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          )
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: tab.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: '  ›  $breadcrumb',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
    final content = collapsed
        ? Tooltip(
            message: breadcrumb == null
                ? tab.label
                : '${tab.label} › $breadcrumb',
            child: Center(child: icon),
          )
        : Row(
            children: [
              icon,
              const SizedBox(width: 14),
              Expanded(child: label),
            ],
          );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 10 : 12),
      child: Material(
        color: active
            ? NexoTheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 14,
              vertical: 12,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
