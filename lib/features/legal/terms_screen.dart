import 'package:flutter/material.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/app_logo.dart';

class _Item {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Item(this.icon, this.title, this.body, this.color);
}

/// El orden importa: primero qué es Nexo, luego a dónde van tus datos, luego
/// lo que implica ver los de otras personas, y al final lo formal.
List<_Item> _items(AppLocalizations l) => <_Item>[
  _Item(
    Icons.info_outline,
    l.termsItemWhatTitle,
    l.termsItemWhatBody,
    NexoTheme.primary,
  ),
  _Item(
    Icons.lock_outline,
    l.termsItemPrivacyTitle,
    l.termsItemPrivacyBody,
    NexoTheme.accent,
  ),
  _Item(
    Icons.devices_outlined,
    l.termsItemDeviceTitle,
    l.termsItemDeviceBody,
    NexoTheme.accent,
  ),
  _Item(
    Icons.how_to_reg_outlined,
    l.termsItemRightsTitle,
    l.termsItemRightsBody,
    NexoTheme.accent,
  ),
  _Item(
    Icons.shield_outlined,
    l.termsItemSecurityTitle,
    l.termsItemSecurityBody,
    NexoTheme.info,
  ),
  _Item(
    Icons.gavel_outlined,
    l.termsItemResponsibleTitle,
    l.termsItemResponsibleBody,
    NexoTheme.success,
  ),
  _Item(
    Icons.warning_amber_outlined,
    l.termsItemDisclaimerTitle,
    l.termsItemDisclaimerBody,
    NexoTheme.warning,
  ),
  _Item(
    Icons.update_outlined,
    l.termsItemChangesTitle,
    l.termsItemChangesBody,
    NexoTheme.textMuted,
  ),
];

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, this.onAccept, this.isUpdate = false});
  final VoidCallback? onAccept;

  /// El usuario ya había aceptado una versión anterior: conviene decírselo en
  /// vez de darle la bienvenida como si fuera la primera vez.
  final bool isUpdate;

  bool get _isGate => onAccept != null;
  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final l = AppLocalizations.of(context);
    final content = _Content(
      isGate: _isGate,
      isUpdate: isUpdate,
      onAccept: onAccept,
    );
    if (isDesktop && _isGate) {
      return Scaffold(
        body: Row(
          children: [
            const Expanded(flex: 5, child: _BrandPane()),
            Expanded(
              flex: 6,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: content,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: _isGate ? null : AppBar(title: Text(l.titleTerms)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final bool isGate;
  final bool isUpdate;
  final VoidCallback? onAccept;
  const _Content({
    required this.isGate,
    required this.isUpdate,
    required this.onAccept,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final showHeader = isGate && !context.isDesktop;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.xxl,
              AppSpacing.lg,
            ),
            children: [
              if (showHeader) ...[
                const Gap(AppSpacing.sm),
                const Center(child: AppLogo(size: 60)),
                const Gap(AppSpacing.lg),
                Center(
                  child: Text(
                    isUpdate ? l.termsHeaderUpdatedPre : l.termsHeaderPre,
                    style: const TextStyle(
                      fontSize: AppFont.h1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const Gap(AppSpacing.xs),
                Center(
                  child: Text(
                    l.termsHeaderTitle,
                    style: TextStyle(
                      fontSize: AppFont.body,
                      color: NexoTheme.textSecondary,
                    ),
                  ),
                ),
                const Gap(AppSpacing.xxl),
              ] else if (context.isDesktop && isGate) ...[
                Text(
                  l.termsHeaderTitle,
                  style: TextStyle(
                    fontSize: AppFont.h1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Text(
                  l.termsHeaderSubtitle,
                  style: TextStyle(
                    fontSize: AppFont.body,
                    color: NexoTheme.textSecondary,
                  ),
                ),
                const Gap(AppSpacing.xxl),
              ],
              if (isGate && isUpdate) ...[
                _UpdatedBanner(text: l.termsUpdatedNotice),
                const Gap(AppSpacing.lg),
              ],
              for (final it in _items(l)) ...[
                _SectionCard(item: it),
                const Gap(AppSpacing.md),
              ],
              const Gap(AppSpacing.sm),
              Center(
                child: Text(
                  l.termsVersionLine(
                    '${LegalTerms.version}',
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(LegalTerms.updatedAt),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFont.small,
                    color: NexoTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isGate)
          Container(
            padding: EdgeInsets.all(
              context.responsive(
                mobile: AppSpacing.lg,
                desktop: AppSpacing.xxl,
              ),
            ),
            decoration: BoxDecoration(
              color: NexoTheme.surface,
              border: Border(top: BorderSide(color: NexoTheme.border)),
            ),
            child: context.isWide
                ? Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: AppIcon.lg,
                        color: NexoTheme.textSecondary,
                      ),
                      const Gap.h(AppSpacing.md),
                      Expanded(
                        child: Text(
                          l.termsAcceptNote,
                          style: TextStyle(
                            fontSize: AppFont.small,
                            color: NexoTheme.textSecondary,
                          ),
                        ),
                      ),
                      const Gap.h(AppSpacing.lg),
                      ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                        ),
                        child: Text(l.termsAcceptButton),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: AppIcon.md,
                            color: NexoTheme.textSecondary,
                          ),
                          const Gap.h(AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l.termsAcceptNote,
                              style: TextStyle(
                                fontSize: AppFont.small,
                                color: NexoTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onAccept,
                          child: Text(l.termsAcceptButton),
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}

/// Aviso de que los términos cambiaron. Solo se muestra a quien ya había
/// aceptado una versión anterior.
class _UpdatedBanner extends StatelessWidget {
  const _UpdatedBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: NexoTheme.info.withValues(alpha: 0.10),
        borderRadius: AppRadii.rXl,
        border: Border.all(color: NexoTheme.info.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_outlined,
            size: AppIcon.lg,
            color: NexoTheme.info,
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFont.small,
                height: 1.45,
                color: NexoTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Item item;
  const _SectionCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: NexoTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: AppRadii.rMd,
            ),
            child: Icon(item.icon, size: AppIcon.lg, color: item.color),
          ),
          const Gap.h(AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: AppFont.title,
                    fontWeight: FontWeight.w800,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Text(
                  item.body,
                  style: TextStyle(
                    fontSize: AppFont.body,
                    height: 1.5,
                    color: NexoTheme.textSecondary,
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

class _BrandPane extends StatelessWidget {
  const _BrandPane();
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
            top: -90,
            left: -70,
            child: _c(260, NexoTheme.accent.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: -110,
            right: -60,
            child: _c(280, Colors.white.withValues(alpha: 0.07)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.huge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 80),
                const Gap(AppSpacing.xxxl),
                Text(
                  l.termsBrandTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppFont.display,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1.05,
                  ),
                ),
                const Gap(AppSpacing.lg),
                Text(
                  l.termsBrandBody,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: AppFont.h3,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _c(double s, Color c) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );
}
