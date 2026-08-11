import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});
  final SessionService session;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();
  bool _loading = false;
  bool _showPass = false;
  bool _capsLock = false;
  String? _error;
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _onKey(KeyEvent e) {
    Future.microtask(() {
      if (!mounted) return;
      final caps = HardwareKeyboard.instance.lockModesEnabled.contains(
        KeyboardLockMode.capsLock,
      );
      if (caps != _capsLock) setState(() => _capsLock = caps);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.session.login(
        _userCtrl.text.trim().toUpperCase(),
        _passCtrl.text,
      );
      if (mounted) TextInput.finishAutofillContext();
    } on UnauthorizedException catch (e) {
      _error = e.message;
    } on BadRequestException catch (e) {
      _error = e.message;
    } on NetworkException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = context.isDesktop;
    final form = _AnimatedIntro(
      controller: _intro,
      child: _FormCard(
        isWide: isWide,
        l: l,
        formKey: _formKey,
        userCtrl: _userCtrl,
        passCtrl: _passCtrl,
        passFocus: _passFocus,
        loading: _loading,
        showPass: _showPass,
        capsLock: _capsLock,
        error: _error,
        onToggleShow: () => setState(() => _showPass = !_showPass),
        onKey: _onKey,
        onSubmit: _submit,
      ),
    );
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: _onKey,
        child: SafeArea(
          child: isWide
              ? Row(
                  children: [
                    const Expanded(child: _BrandPanel()),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: form,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    const _MobileBackdrop(),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.xxxl,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: form,
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

class _AnimatedIntro extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  const _AnimatedIntro({required this.controller, required this.child});
  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isWide;
  final AppLocalizations l;
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final FocusNode passFocus;
  final bool loading;
  final bool showPass;
  final bool capsLock;
  final String? error;
  final VoidCallback onToggleShow;
  final ValueChanged<KeyEvent> onKey;
  final Future<void> Function() onSubmit;
  const _FormCard({
    required this.isWide,
    required this.l,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.passFocus,
    required this.loading,
    required this.showPass,
    required this.capsLock,
    required this.error,
    required this.onToggleShow,
    required this.onKey,
    required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isWide) ...[
            const Center(child: AppLogo(size: 64)),
            const Gap(AppSpacing.xxl),
          ],
          Text(
            l.loginWelcomeBack,
            style: TextStyle(
              fontSize: AppFont.h1,
              fontWeight: FontWeight.w900,
              color: NexoTheme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            l.loginIntro,
            style: TextStyle(
              fontSize: AppFont.body,
              height: 1.45,
              color: NexoTheme.textSecondary,
            ),
          ),
          const Gap(AppSpacing.xxxl),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: userCtrl,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(12),
                    _UpperCaseFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l.loginUserLabel,
                    hintText: 'U00021B',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: NexoTheme.textSecondary,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l.loginUserRequired
                      : null,
                ),
                const Gap(AppSpacing.md),
                TextFormField(
                  controller: passCtrl,
                  focusNode: passFocus,
                  obscureText: !showPass,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: l.loginPasswordLabel,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: NexoTheme.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      tooltip: showPass ? l.actionHide : l.actionShow,
                      icon: Icon(
                        showPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: NexoTheme.textSecondary,
                      ),
                      onPressed: onToggleShow,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l.loginPasswordRequired : null,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppDurations.fast,
            child: capsLock
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.keyboard_capslock,
                          size: AppIcon.sm,
                          color: NexoTheme.warning,
                        ),
                        const Gap.h(AppSpacing.xs),
                        Text(
                          l.loginCapsLockOn,
                          style: const TextStyle(
                            fontSize: AppFont.small,
                            color: NexoTheme.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AnimatedSize(
            duration: AppDurations.fast,
            child: error != null
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: NexoTheme.danger.withValues(alpha: 0.08),
                        borderRadius: AppRadii.rMd,
                        border: Border.all(
                          color: NexoTheme.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: NexoTheme.danger,
                            size: AppIcon.lg,
                          ),
                          const Gap.h(AppSpacing.sm),
                          Expanded(
                            child: Text(
                              error!,
                              style: const TextStyle(
                                color: NexoTheme.danger,
                                fontSize: AppFont.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Gap(AppSpacing.xl),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                child: loading
                    ? const SizedBox(
                        key: ValueKey('l'),
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l.loginSubmit,
                        key: const ValueKey('t'),
                        style: const TextStyle(
                          fontSize: AppFont.title,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const Gap(AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, color: NexoTheme.textMuted),
              const Gap.h(AppSpacing.xs),
              Flexible(
                child: Text(
                  l.loginDeviceOnly,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.small,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _MobileBackdrop extends StatelessWidget {
  const _MobileBackdrop();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: _blob(240, NexoTheme.primary.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _blob(260, NexoTheme.accent.withValues(alpha: 0.14)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NexoTheme.primary, NexoTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _circle(280, NexoTheme.accent.withValues(alpha: 0.20)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _circle(240, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 120,
            left: -40,
            child: _circle(120, Colors.white.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.huge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 76),
                const Gap(AppSpacing.xxxl),
                const Text(
                  'Nexo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFont.display,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const Gap(AppSpacing.md),
                Text(
                  l.loginBrandTagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: AppFont.h2,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(AppSpacing.huge),
                _feature(Icons.schedule_rounded, l.loginFeatureSchedule),
                const Gap(AppSpacing.lg),
                _feature(Icons.payments_outlined, l.loginFeaturePayments),
                const Gap(AppSpacing.lg),
                _feature(Icons.school_outlined, l.loginFeatureGrades),
                const Gap(AppSpacing.lg),
                _feature(Icons.widgets_rounded, l.loginFeatureWidgets),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
  Widget _feature(IconData icon, String text) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: AppRadii.rMd,
        ),
        child: Icon(icon, color: Colors.white, size: AppIcon.lg),
      ),
      const Gap.h(AppSpacing.lg),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppFont.title,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
