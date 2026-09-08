import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nexo/core/app_locale.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/l10n/app_localizations.dart';

class InstallOptions {
  final bool desktopShortcut;
  final bool startMenuShortcut;
  final bool autoStart;
  const InstallOptions({
    required this.desktopShortcut,
    required this.startMenuShortcut,
    required this.autoStart,
  });
}

/// Envuelve un subárbol del instalador/desinstalador para que TODOS sus botones
/// se ajusten a su contenido (mismo alto, sin mínimos forzados). Antes convivían
/// OutlinedButton (con mínimo por defecto ~64x36) y ElevatedButton (Size.zero),
/// y se veían "uno grande y otro pequeño". Aquí se uniforman sin tocar cada
/// botón, y solo dentro de estas pantallas.
Widget installerButtonScope(BuildContext context, Widget child) {
  const shrink = MaterialTapTargetSize.shrinkWrap;
  final base = Theme.of(context);
  return Theme(
    data: base.copyWith(
      materialTapTargetSize: shrink,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: shrink,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: shrink,
        ),
      ),
    ),
    child: child,
  );
}

class SetupWizard extends StatefulWidget {
  final void Function(InstallOptions options) onInstall;
  final VoidCallback onRunPortable;
  final ThemeController theme;
  const SetupWizard({
    super.key,
    required this.onInstall,
    required this.onRunPortable,
    required this.theme,
  });
  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  int _step = 0;
  bool _isPortable = false;
  bool _termsAccepted = false;
  bool _termsError = false;
  bool _desktopShortcut = true;
  bool _startMenuShortcut = true;
  bool _autoStart = false;
  int get _totalSteps => _isPortable ? 3 : 4;
  static const double _w = 480;
  static const Map<int, double> _heights = {0: 380, 1: 580, 2: 420, 3: 530};
  @override
  void initState() {
    super.initState();
    _resizeWindow(_step);
  }

  Future<void> _resizeWindow(int step) async {
    if (kIsWeb || !Platform.isWindows) return;
    final double h;
    if (_isPortable && step == 2) {
      h = _heights[3]!;
    } else {
      h = _heights[step] ?? 500;
    }
    final size = Size(_w, h);
    await windowManager.setMinimumSize(const Size(_w, 340));
    await windowManager.setMaximumSize(const Size(_w, 700));
    await windowManager.setSize(size);
  }

  void _nextStep() {
    if (_step == 1 && !_termsAccepted) {
      setState(() => _termsError = true);
      return;
    }
    if (_step < _totalSteps - 1) {
      final next = _step + 1;
      setState(() {
        _step = next;
        _termsError = false;
      });
      _resizeWindow(next);
    } else {
      _finish();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      final prev = _step - 1;
      setState(() => _step = prev);
      _resizeWindow(prev);
    }
  }

  void _selectMode(bool portable) {
    setState(() => _isPortable = portable);
    _nextStep();
  }

  void _finish() {
    if (_isPortable) {
      widget.onRunPortable();
    } else {
      widget.onInstall(
        InstallOptions(
          desktopShortcut: _desktopShortcut,
          startMenuShortcut: _startMenuShortcut,
          autoStart: _autoStart,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.theme,
      builder: (context, _) {
        return installerButtonScope(
          context,
          Scaffold(
          backgroundColor: NexoTheme.bg,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  if (_step > 0) ...[
                    _buildStepIndicator(),
                    const SizedBox(height: 16),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    ),
                    child: _buildCurrentStep(),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep() {
    final l = AppLocalizations.of(context);
    switch (_step) {
      case 0:
        return _StepWelcome(
          key: const ValueKey('s0'),
          l: l,
          onSelect: _selectMode,
        );
      case 1:
        return _StepTerms(
          key: const ValueKey('s1'),
          l: l,
          accepted: _termsAccepted,
          showError: _termsError,
          onAcceptChanged: (v) => setState(() {
            _termsAccepted = v;
            if (v) _termsError = false;
          }),
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case 2:
        if (_isPortable) {
          return _StepConfig(
            key: const ValueKey('s2c'),
            l: l,
            theme: widget.theme,
            onBack: _prevStep,
            onFinish: _finish,
          );
        }
        return _StepCustomize(
          key: const ValueKey('s2'),
          l: l,
          desktop: _desktopShortcut,
          startMenu: _startMenuShortcut,
          autoStart: _autoStart,
          onDesktopChanged: (v) => setState(() => _desktopShortcut = v),
          onStartMenuChanged: (v) => setState(() => _startMenuShortcut = v),
          onAutoStartChanged: (v) => setState(() => _autoStart = v),
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case 3:
        return _StepConfig(
          key: const ValueKey('s3'),
          l: l,
          theme: widget.theme,
          onBack: _prevStep,
          onFinish: _finish,
        );
      default:
        return const SizedBox.shrink();
    }
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

  Widget _buildStepIndicator() {
    final int visibleSteps = _totalSteps - 1;
    final int currentVisible = _step - 1;
    return Row(
      children: List.generate(visibleSteps, (i) {
        final isActive = i == currentVisible;
        final isDone = i < currentVisible;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? NexoTheme.primary : NexoTheme.border,
                  ),
                ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? NexoTheme.primary
                      : isActive
                      ? NexoTheme.primary.withValues(alpha: 0.15)
                      : NexoTheme.surface,
                  border: Border.all(
                    color: isDone || isActive
                        ? NexoTheme.primary
                        : NexoTheme.border,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        )
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? NexoTheme.primary
                                : NexoTheme.textMuted,
                          ),
                        ),
                ),
              ),
              if (i < visibleSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? NexoTheme.primary : NexoTheme.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepWelcome extends StatelessWidget {
  final AppLocalizations l;
  final void Function(bool isPortable) onSelect;
  const _StepWelcome({super.key, required this.l, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          l.setupTitle,
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
          l.setupSubtitle,
          style: TextStyle(
            fontSize: 11,
            color: NexoTheme.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _ModeCard(
          icon: Icons.install_desktop_rounded,
          title: l.setupBtnInstall,
          subtitle:
              l.setupProgressShortcuts.replaceAll('...', ', ') +
              l.setupProgressRegister.toLowerCase(),
          color: NexoTheme.primary,
          onTap: () => onSelect(false),
        ),
        const SizedBox(height: 10),
        _ModeCard(
          icon: Icons.folder_open_outlined,
          title: l.setupBtnPortable,
          subtitle: l.setupPortableDesc,
          color: NexoTheme.textSecondary,
          onTap: () => onSelect(true),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NexoTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexoTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NexoTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: NexoTheme.textMuted,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: NexoTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTerms extends StatelessWidget {
  final AppLocalizations l;
  final bool accepted;
  final bool showError;
  final ValueChanged<bool> onAcceptChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _StepTerms({
    super.key,
    required this.l,
    required this.accepted,
    required this.showError,
    required this.onAcceptChanged,
    required this.onNext,
    required this.onBack,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.termsHeaderTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l.termsHeaderSubtitle,
          style: TextStyle(fontSize: 11, color: NexoTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexoTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _termsItem(
                    Icons.info_outline_rounded,
                    l.termsItemWhatTitle,
                    l.termsItemWhatBody,
                  ),
                  const SizedBox(height: 12),
                  _termsItem(
                    Icons.shield_outlined,
                    l.termsItemPrivacyTitle,
                    l.termsItemPrivacyBody,
                  ),
                  const SizedBox(height: 12),
                  _termsItem(
                    Icons.lock_outline_rounded,
                    l.termsItemSecurityTitle,
                    l.termsItemSecurityBody,
                  ),
                  const SizedBox(height: 12),
                  _termsItem(
                    Icons.handshake_outlined,
                    l.termsItemResponsibleTitle,
                    l.termsItemResponsibleBody,
                  ),
                  const SizedBox(height: 12),
                  _termsItem(
                    Icons.warning_amber_rounded,
                    l.termsItemDisclaimerTitle,
                    l.termsItemDisclaimerBody,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => onAcceptChanged(!accepted),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: showError
                  ? NexoTheme.danger.withValues(alpha: 0.08)
                  : accepted
                  ? NexoTheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: showError
                    ? NexoTheme.danger.withValues(alpha: 0.5)
                    : accepted
                    ? NexoTheme.primary.withValues(alpha: 0.4)
                    : NexoTheme.border,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: accepted,
                    activeColor: NexoTheme.primary,
                    onChanged: (v) => onAcceptChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.setupTermsAccept,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: showError
                          ? NexoTheme.danger
                          : NexoTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              l.setupTermsRequired,
              style: const TextStyle(
                fontSize: 10,
                color: NexoTheme.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _NavButtons(
          backLabel: l.setupBtnBack,
          nextLabel: l.setupBtnNext,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }

  Widget _termsItem(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: NexoTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: NexoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(
                  fontSize: 10,
                  color: NexoTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCustomize extends StatelessWidget {
  final AppLocalizations l;
  final bool desktop, startMenu, autoStart;
  final ValueChanged<bool> onDesktopChanged,
      onStartMenuChanged,
      onAutoStartChanged;
  final VoidCallback onNext, onBack;
  const _StepCustomize({
    super.key,
    required this.l,
    required this.desktop,
    required this.startMenu,
    required this.autoStart,
    required this.onDesktopChanged,
    required this.onStartMenuChanged,
    required this.onAutoStartChanged,
    required this.onNext,
    required this.onBack,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.setupCustomization,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NexoTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        _OptionTile(
          icon: Icons.desktop_windows_outlined,
          title: l.setupOptionDesktop,
          value: desktop,
          onChanged: onDesktopChanged,
        ),
        const SizedBox(height: 8),
        _OptionTile(
          icon: Icons.menu_open_rounded,
          title: l.setupOptionStartMenu,
          value: startMenu,
          onChanged: onStartMenuChanged,
        ),
        const SizedBox(height: 8),
        _OptionTile(
          icon: Icons.power_settings_new_rounded,
          title: l.setupOptionAutoStart,
          subtitle: l.setupOptionAutoStartDesc,
          value: autoStart,
          onChanged: onAutoStartChanged,
        ),
        const SizedBox(height: 20),
        _NavButtons(
          backLabel: l.setupBtnBack,
          nextLabel: l.setupBtnNext,
          onBack: onBack,
          onNext: onNext,
        ),
      ],
    );
  }
}

class _StepConfig extends StatelessWidget {
  final AppLocalizations l;
  final ThemeController theme;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  const _StepConfig({
    super.key,
    required this.l,
    required this.theme,
    required this.onBack,
    required this.onFinish,
  });
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.settingsAppearance,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: NexoTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            _sectionLabel(l.settingsPalette),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ThemeChip(
                  label: l.settingsSystem,
                  colors: null,
                  selected: theme.selection == 'system',
                  onTap: () => theme.setSelection('system'),
                ),
                for (final p in NexoColors.all)
                  _ThemeChip(
                    label: p.label,
                    colors: p,
                    selected: theme.selection == p.id,
                    onTap: () => theme.setSelection(p.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _sectionLabel(l.language),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final loc in AppLocale.values) ...[
                  Expanded(
                    child: _PrefChip(
                      label: loc.label,
                      selected: theme.locale == loc,
                      onTap: () => theme.setLocale(loc),
                    ),
                  ),
                  if (loc != AppLocale.values.last) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _sectionLabel(l.timeFormat),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PrefChip(
                    label: l.hours24,
                    selected: theme.use24h,
                    onTap: () => theme.setUse24h(true),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PrefChip(
                    label: l.hours12,
                    selected: !theme.use24h,
                    onTap: () => theme.setUse24h(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 13),
                  label: Text(l.setupBtnBack),
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
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: onFinish,
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: Text(l.setupBtnInstallNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexoTheme.primary,
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
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: NexoTheme.textMuted,
      ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  final String backLabel, nextLabel;
  final VoidCallback onBack, onNext;
  const _NavButtons({
    required this.backLabel,
    required this.nextLabel,
    required this.onBack,
    required this.onNext,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 13),
          label: Text(backLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: NexoTheme.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: NexoTheme.border),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
          label: Text(nextLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: NexoTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? NexoTheme.primary.withValues(alpha: 0.08)
              : NexoTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? NexoTheme.primary.withValues(alpha: 0.4)
                : NexoTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? NexoTheme.primary : NexoTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: value ? NexoTheme.primary : NexoTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
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
                value: value,
                activeColor: NexoTheme.primary,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final NexoColors? colors;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeChip({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? NexoTheme.primary.withValues(alpha: 0.12)
              : NexoTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (colors != null) ...[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors!.primary,
                  border: Border.all(color: colors!.bg, width: 2),
                ),
              ),
              const SizedBox(width: 5),
            ] else ...[
              Icon(
                Icons.brightness_auto_rounded,
                size: 14,
                color: selected ? NexoTheme.primary : NexoTheme.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? NexoTheme.primary : NexoTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrefChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PrefChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? NexoTheme.primary.withValues(alpha: 0.12)
              : NexoTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? NexoTheme.primary : NexoTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
