import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/win_setup_service.dart';
import 'package:nexo/features/settings/install_dialog.dart';
import 'package:nexo/l10n/app_localizations.dart';

enum InstallProgressStep {
  preparing,
  copying,
  shortcuts,
  registering,
  autoStart,
  done,
  error,
}

class InstallView extends StatefulWidget {
  final InstallOptions options;
  const InstallView({super.key, required this.options});
  @override
  State<InstallView> createState() => _InstallViewState();
}

class _InstallViewState extends State<InstallView> {
  InstallProgressStep _step = InstallProgressStep.preparing;
  double _progress = 0.0;
  String _errorMessage = "";
  @override
  void initState() {
    super.initState();
    _startInstallation();
  }

  Future<void> _startInstallation() async {
    try {
      await WinSetupService.copyApplicationFiles(
        onProgress: (p) {
          setState(() {
            _step = InstallProgressStep.copying;
            _progress = p * 0.70;
          });
        },
      );
      if (widget.options.desktopShortcut || widget.options.startMenuShortcut) {
        setState(() {
          _step = InstallProgressStep.shortcuts;
          _progress = 0.75;
        });
        await WinSetupService.createShortcuts(
          desktop: widget.options.desktopShortcut,
          startMenu: widget.options.startMenuShortcut,
        );
      }
      setState(() {
        _step = InstallProgressStep.registering;
        _progress = 0.85;
      });
      await WinSetupService.registerUninstall(version: AppConfig.appVersion);
      if (widget.options.autoStart) {
        setState(() {
          _step = InstallProgressStep.autoStart;
          _progress = 0.95;
        });
        await WinSetupService.registerAutoStart();
      }
      setState(() {
        _step = InstallProgressStep.done;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _step = InstallProgressStep.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _launchAppAndExit() {
    Process.start(
      WinSetupService.officialExePath,
      [],
      mode: ProcessStartMode.detached,
    );
    Future<void>.delayed(const Duration(milliseconds: 500), () => exit(0));
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (_step == InstallProgressStep.error) {
      content = _buildErrorView();
    } else if (_step == InstallProgressStep.done) {
      content = _buildSuccessView();
    } else {
      content = _buildProgressView();
    }
    return installerButtonScope(context, content);
  }

  Widget _buildProgressView() {
    final l = AppLocalizations.of(context);
    String stepLabel = "";
    switch (_step) {
      case InstallProgressStep.preparing:
        stepLabel = l.setupProgressCopied;
        break;
      case InstallProgressStep.copying:
        final pct = (_progress / 0.70 * 100).toStringAsFixed(0);
        stepLabel = "${l.setupProgressCopied} ($pct%)";
        break;
      case InstallProgressStep.shortcuts:
        stepLabel = l.setupProgressShortcuts;
        break;
      case InstallProgressStep.registering:
        stepLabel = l.setupProgressRegister;
        break;
      case InstallProgressStep.autoStart:
        stepLabel = l.setupProgressAutoStart;
        break;
      default:
        stepLabel = "";
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NexoTheme.success),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              stepLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NexoTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: NexoTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(NexoTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 56,
              color: NexoTheme.success,
            ),
            const SizedBox(height: 16),
            Text(
              l.setupSuccessTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: NexoTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.setupSuccessDesc,
              style: TextStyle(fontSize: 12, color: NexoTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _launchAppAndExit,
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(l.setupBtnStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexoTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: NexoTheme.danger,
            ),
            const SizedBox(height: 16),
            Text(
              l.setupErrorTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: NexoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Courier',
                  color: NexoTheme.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _step = InstallProgressStep.preparing;
                      _progress = 0.0;
                      _errorMessage = "";
                    });
                    _startInstallation();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NexoTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: NexoTheme.border),
                  ),
                  child: Text(l.setupBtnRetry),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => exit(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexoTheme.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(l.setupBtnExit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UninstallView extends StatefulWidget {
  const UninstallView({super.key});
  @override
  State<UninstallView> createState() => _UninstallViewState();
}

enum UninstallViewState { idle, uninstalling, success, error }

class _UninstallViewState extends State<UninstallView> {
  UninstallViewState _state = UninstallViewState.idle;
  bool _purgeData = true;
  String _currentStep = "";
  String _errorMessage = "";
  static const double _w = 480;
  @override
  void initState() {
    super.initState();
    _resizeWindow(460);
  }

  Future<void> _resizeWindow(double h) async {
    if (kIsWeb || !Platform.isWindows) return;
    await windowManager.setMinimumSize(const Size(_w, 340));
    await windowManager.setMaximumSize(const Size(_w, 700));
    await windowManager.setSize(Size(_w, h));
  }

  Future<void> _startUninstall() async {
    setState(() {
      _state = UninstallViewState.uninstalling;
      _currentStep = "Iniciando desinstalación...";
    });
    try {
      await WinSetupService.removeAutoStart();
      await WinSetupService.performUninstall(
        purgeData: _purgeData,
        onStepProgress: (stepMsg) {
          setState(() {
            _currentStep = stepMsg;
          });
        },
      );
      setState(() {
        _state = UninstallViewState.success;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await WinSetupService.triggerSelfDestruct();
    } catch (e) {
      setState(() {
        _state = UninstallViewState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return installerButtonScope(
      context,
      Scaffold(
      backgroundColor: NexoTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _buildCurrentState(),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: NexoTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: NexoTheme.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: NexoTheme.primary.withValues(alpha: 0.08),
                blurRadius: 16,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Image.asset('assets/icon.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Nexo UPLA',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: NexoTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentState() {
    switch (_state) {
      case UninstallViewState.idle:
        return KeyedSubtree(key: const ValueKey('idle'), child: _buildIdle());
      case UninstallViewState.uninstalling:
        return KeyedSubtree(
          key: const ValueKey('uninstalling'),
          child: _buildUninstalling(),
        );
      case UninstallViewState.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: _buildSuccess(),
        );
      case UninstallViewState.error:
        return KeyedSubtree(key: const ValueKey('error'), child: _buildError());
    }
  }

  Widget _buildIdle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Desinstalar Nexo UPLA',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Se removerá la aplicación y todos sus componentes de tu sistema.',
          style: TextStyle(
            fontSize: 11,
            color: NexoTheme.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => setState(() => _purgeData = !_purgeData),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _purgeData
                  ? NexoTheme.danger.withValues(alpha: 0.08)
                  : NexoTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _purgeData
                    ? NexoTheme.danger.withValues(alpha: 0.4)
                    : NexoTheme.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_sweep_rounded,
                  size: 18,
                  color: _purgeData ? NexoTheme.danger : NexoTheme.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purgar todos mis datos locales',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _purgeData
                              ? NexoTheme.danger
                              : NexoTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Elimina bases de datos locales, historial de grades y sesión.',
                        style: TextStyle(
                          fontSize: 10,
                          color: NexoTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: _purgeData,
                    activeColor: NexoTheme.danger,
                    onChanged: (v) => setState(() => _purgeData = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => exit(0),
              style: OutlinedButton.styleFrom(
                foregroundColor: NexoTheme.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: NexoTheme.border),
              ),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _startUninstall,
              icon: const Icon(Icons.delete_outline_rounded, size: 14),
              label: const Text('Desinstalar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexoTheme.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUninstalling() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(NexoTheme.danger),
          strokeWidth: 3,
        ),
        const SizedBox(height: 20),
        Text(
          _currentStep,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: NexoTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 56,
          color: NexoTheme.success,
        ),
        const SizedBox(height: 14),
        Text(
          '¡Desinstalación exitosa!',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Nexo UPLA ha sido removido. Limpiando directorios...',
          style: TextStyle(
            fontSize: 11,
            color: NexoTheme.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: NexoTheme.danger,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Error al desinstalar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexoTheme.border),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Courier',
                color: NexoTheme.danger,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => exit(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: NexoTheme.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              minimumSize: Size.zero,
            ),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }
}
