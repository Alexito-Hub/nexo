import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:ui';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/l10n/quechua_fallback.dart';
import 'package:nexo/core/festivity/festivity.dart';
import 'package:nexo/features/festivity/widgets/fiestas_patrias_effects.dart';
import 'package:nexo/core/win_setup_service.dart';
import 'package:nexo/features/settings/setup_view.dart';
import 'package:nexo/features/settings/install_dialog.dart';
import 'package:nexo/widgets/custom_title_bar.dart';
import 'package:nexo/app/shell.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/core/error_handler.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/api_client.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/cache_manager.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/data/home_widget_service.dart';
import 'package:nexo/data/notification_service.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/data/sigma_repository.dart';
import 'package:nexo/core/shortcuts.dart';
import 'package:nexo/data/teacher_repository.dart';
import 'package:nexo/data/intranet_client.dart';
import 'package:nexo/data/intranet_repository.dart';
import 'package:nexo/data/graph_client.dart';
import 'package:nexo/data/ms_auth_service.dart';
import 'package:nexo/data/secure_http.dart';
import 'package:nexo/data/teams_repository.dart';
import 'package:nexo/data/update_service.dart';
import 'package:nexo/features/auth/login_screen.dart';
import 'package:nexo/features/legal/terms_screen.dart';
import 'package:nexo/features/onboarding/onboarding_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await AppStorage.init();
  bool isSetup = false;
  bool isUninstall = false;
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    // En la build de Store, la instalación la gestiona Windows: no hay
    // asistente propio ni desinstalador embebido.
    isUninstall = !StoreBuild.isStore && args.contains('--uninstall');
    final isInstalled = WinSetupService.isInstalledInstance;
    final isPortable = AppStorage.instance.runPortable;
    isSetup =
        !StoreBuild.isStore && (isUninstall || (!isInstalled && !isPortable));
    final themeMode = AppStorage.instance.themeMode ?? 'system';
    bool isDark = false;
    if (themeMode == 'system') {
      isDark =
          PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    } else {
      isDark = NexoColors.byId(themeMode).isDark;
    }
    final initialBg = isDark ? NexoColors.dark.bg : NexoColors.light.bg;
    if (isSetup) {
      final windowOptions = WindowOptions(
        size: const Size(480, 380),
        minimumSize: const Size(480, 340),
        maximumSize: const Size(480, 700),
        titleBarStyle: TitleBarStyle.hidden,
        center: true,
        backgroundColor: initialBg,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
      });
    } else {
      final windowOptions = WindowOptions(
        size: const Size(1280, 800),
        minimumSize: const Size(800, 600),
        titleBarStyle: TitleBarStyle.hidden,
        center: true,
        backgroundColor: initialBg,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
      });
    }
  }
  if (isUninstall) {
    final mode = AppStorage.instance.themeMode ?? 'system';
    final NexoColors palette;
    if (mode == 'system') {
      final isDark =
          !kIsWeb &&
          PlatformDispatcher.instance.platformBrightness == Brightness.dark;
      palette = isDark ? NexoColors.dark : NexoColors.light;
    } else {
      palette = NexoColors.byId(mode);
    }
    runApp(_UninstallApp(palette: palette));
    return;
  }
  final secureHttp = await createSecureClient();
  final api = ApiClient(transport: secureHttp);
  final repo = SigmaRepository(api);
  final session = SessionService(apiClient: api, repo: repo);
  final connectivity = ConnectivityService(httpClient: secureHttp);
  final cache = CacheManager();
  await cache.init();
  await connectivity.start();
  final errorHandler = ErrorHandler(
    connectivity: connectivity,
    session: session,
  );
  final intranet = IntranetRepository(IntranetClient(transport: secureHttp));
  final graph = GraphClient(transport: secureHttp);
  final msAuth = MsAuthService(graph);
  final teams = TeamsRepository(graph);
  final teacher = TeacherRepository(api);
  final store = AppStore(
    repo,
    cache: cache,
    errorHandler: errorHandler,
    intranet: intranet,
    teams: teams,
    teacher: teacher,
  );
  final theme = ThemeController()..load();
  final widgets = HomeWidgetService();
  await widgets.init();
  ShortcutService.instance.init();
  await NotificationService.instance.init();
  final updater = UpdateService(httpClient: secureHttp);
  // La Store se encarga de las actualizaciones: no arrancamos el updater propio.
  if (!StoreBuild.isStore) {
    NotificationService.instance.onInstallUpdateTap = updater.installDownloaded;
    unawaited(updater.bootstrap());
  }
  store.onGradeChange = (course, grade) =>
      NotificationService.instance.showGradeChanged(course, grade);
  session.addListener(() {
    if (!session.isAuthenticated) store.clear();
  });
  store.addListener(() {
    if (!store.profile.loading && !store.schedule.loading) {
      widgets.sync(store);
      if (NotificationService.instance.prefs.enabled &&
          !store.pendingInstallments.loading) {
        NotificationService.instance.reschedule(
          clases: store.schedule.value,
          installments: store.pendingInstallments.value,
        );
      }
    }
  });
  await session.bootstrap();
  await msAuth.bootstrap();
  if (session.isAuthenticated) await store.hydrateFromCache();
  runApp(
    NexoApp(
      session: session,
      store: store,
      theme: theme,
      msAuth: msAuth,
      connectivity: connectivity,
      isSetup: isSetup,
      isUninstall: isUninstall,
    ),
  );
}

class NexoApp extends StatelessWidget {
  const NexoApp({
    super.key,
    required this.session,
    required this.store,
    required this.theme,
    required this.msAuth,
    required this.connectivity,
    required this.isSetup,
    required this.isUninstall,
  });
  final SessionService session;
  final AppStore store;
  final ThemeController theme;
  final MsAuthService msAuth;
  final ConnectivityService connectivity;
  final bool isSetup;
  final bool isUninstall;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return MaterialApp(
          title: 'Nexo · UPLA',
          debugShowCheckedModeBanner: false,
          locale: theme.locale.flutterLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            QuechuaMaterialDelegate(),
            QuechuaCupertinoDelegate(),
            QuechuaWidgetsDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (ctx, child) {
            final palette = theme.resolvedPalette(ctx);
            final isTest = Platform.environment.containsKey('FLUTTER_TEST');
            if (!kIsWeb && Platform.isWindows && !isTest) {
              windowManager.setBackgroundColor(palette.bg);
            }
            return Theme(data: NexoTheme.themeFor(palette), child: child!);
          },
          theme: NexoTheme.light(),
          home: _Gate(
            session: session,
            store: store,
            theme: theme,
            msAuth: msAuth,
            connectivity: connectivity,
            isSetup: isSetup,
            isUninstall: isUninstall,
          ),
        );
      },
    );
  }
}

class _Gate extends StatefulWidget {
  const _Gate({
    required this.session,
    required this.store,
    required this.theme,
    required this.msAuth,
    required this.connectivity,
    required this.isSetup,
    required this.isUninstall,
  });
  final SessionService session;
  final AppStore store;
  final ThemeController theme;
  final MsAuthService msAuth;
  final ConnectivityService connectivity;
  final bool isSetup;
  final bool isUninstall;
  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool _accepted = AppStorage.instance.acceptedTerms;
  bool _seenOnboarding = AppStorage.instance.seenOnboarding;
  late bool _isSetup = widget.isSetup;
  bool _showInstallView = false;
  InstallOptions? _installOptions;
  bool _minSplashDone = false;

  @override
  void initState() {
    super.initState();
    final active = FestivityService.active(DateTime.now());
    final isFiestasPatrias = AppStorage.instance.festivityDecor && 
                             active?.festivity.id == 'fiestas_patrias';
    
    if (isFiestasPatrias) {
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (mounted) setState(() => _minSplashDone = true);
      });
    } else {
      _minSplashDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUninstall) {
      return const UninstallView();
    }
    if (_isSetup) {
      if (_showInstallView && _installOptions != null) {
        return Scaffold(
          backgroundColor: NexoTheme.bg,
          body: Column(
            children: [
              const CustomTitleBar(),
              Expanded(child: InstallView(options: _installOptions!)),
            ],
          ),
        );
      }
      return Scaffold(
        backgroundColor: NexoTheme.bg,
        body: Column(
          children: [
            const CustomTitleBar(),
            Expanded(
              child: SetupWizard(
          theme: widget.theme,
          onInstall: (options) async {
            await AppStorage.instance.setAcceptedTerms(true);
            await AppStorage.instance.setSeenOnboarding(true);
            setState(() {
              _installOptions = options;
              _showInstallView = true;
            });
          },
          onRunPortable: () async {
            await AppStorage.instance.setRunPortable(true);
            await AppStorage.instance.setAcceptedTerms(true);
            await AppStorage.instance.setSeenOnboarding(true);
            if (!kIsWeb && Platform.isWindows) {
              await windowManager.setMinimumSize(const Size(800, 600));
              await windowManager.setMaximumSize(const Size(9999, 9999));
              await windowManager.setResizable(true);
              await windowManager.setSize(const Size(1280, 800));
              await windowManager.center();
            }
            setState(() {
              _isSetup = false;
              _accepted = true;
              _seenOnboarding = true;
            });
          },
        ),
      ),
    ],
  ),
);
    }
    Widget gated;
    String key;
    if (!_accepted) {
      key = 'terms';
      gated = TermsScreen(
        onAccept: () async {
          await AppStorage.instance.setAcceptedTerms(true);
          if (mounted) setState(() => _accepted = true);
        },
      );
    } else {
      gated = ListenableBuilder(
        listenable: widget.session,
        builder: (context, _) {
          final isWaiting = widget.session.status == SessionStatus.unknown || !_minSplashDone;
          final showOnboarding =
              !_seenOnboarding &&
              widget.session.status == SessionStatus.unauthenticated;
          final Widget child;
          final String k;
          if (isWaiting) {
            k = 'splash_delay';
            child = const _SplashScreen();
          } else if (showOnboarding) {
            k = 'onboarding';
            child = OnboardingScreen(
              onDone: () async {
                await AppStorage.instance.setSeenOnboarding(true);
                if (mounted) setState(() => _seenOnboarding = true);
              },
            );
          } else {
            k = widget.session.status.name;
            child = switch (widget.session.status) {
              SessionStatus.unknown => const _SplashScreen(),
              SessionStatus.authenticated => AppShell(
                store: widget.store,
                session: widget.session,
                theme: widget.theme,
                msAuth: widget.msAuth,
                connectivity: widget.connectivity,
              ),
              SessionStatus.unauthenticated => LoginScreen(
                session: widget.session,
              ),
            };
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (c, anim) {
              final slide =
                  Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  );
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(position: slide, child: c),
              );
            },
            child: KeyedSubtree(key: ValueKey(k), child: child),
          );
        },
      );
      key = 'app';
    }
    return ListenableBuilder(
      listenable: widget.theme,
      builder: (context, _) {
        NexoTheme.apply(widget.theme.resolvedPalette(context));
        Widget child = AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (c, anim) =>
              FadeTransition(opacity: anim, child: c),
          child: KeyedSubtree(key: ValueKey(key), child: gated),
        );
        final isTest = Platform.environment.containsKey('FLUTTER_TEST');
        if (!kIsWeb && Platform.isWindows && !isTest) {
          child = Scaffold(
            backgroundColor: NexoTheme.bg,
            body: Column(
              children: [
                const CustomTitleBar(),
                Expanded(child: child),
              ],
            ),
          );
        }
        return child;
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  late final Animation<double> _logoScale = Tween(
    begin: 0.9,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
  late final Animation<double> _textOpacity = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
  );
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.nx;
    final startBg = palette.isDark
        ? const Color(0xFF0A0C10)
        : const Color(0xFFFFFFFF);
    final endBg = palette.bg;
    final bgTween = ColorTween(
      begin: startBg,
      end: endBg,
    ).animate(CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.7)));
    final active = FestivityService.active(DateTime.now());
    final isFiestasPatrias = AppStorage.instance.festivityDecor && active?.festivity.id == 'fiestas_patrias';
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = (width * 0.22).clamp(60.0, 120.0);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgTween.value ?? endBg,
          body: Stack(
            children: [
              // Logo de NEXO estrictamente centrado en la pantalla (como siempre ha estado)
              Center(
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Text(
                      'NEXO',
                      style: TextStyle(
                        fontFamily: 'SuperMindset',
                        fontSize: fontSize,
                        height: 0.9,
                        letterSpacing: 1.6,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              // Decoración festiva colgada debajo
              if (isFiestasPatrias)
                Center(
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Transform.translate(
                        offset: Offset(0, fontSize + 120), // Desplaza los elementos hacia abajo libremente
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '¡Felices Fiestas Patrias!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE2432A), // Rojo patrio
                              ),
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 160,
                              height: 80,
                              child: MarcaPeruEffect(color: Color(0xFFE2432A)), // Rojo patrio
                            ),
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

class _UninstallApp extends StatelessWidget {
  const _UninstallApp({required this.palette});
  final NexoColors palette;
  @override
  Widget build(BuildContext context) {
    NexoTheme.apply(palette);
    return MaterialApp(
      title: 'Desinstalar Nexo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: NexoTheme.themeFor(palette),
      home: Scaffold(
        backgroundColor: palette.bg,
        body: const Column(
          children: [
            CustomTitleBar(),
            Expanded(child: UninstallView()),
          ],
        ),
      ),
    );
  }
}
