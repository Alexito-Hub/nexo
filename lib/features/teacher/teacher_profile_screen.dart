import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/shared/util/clipboard_helper.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/features/legal/about_screen.dart';
import 'package:nexo/features/legal/developer_screen.dart';
import 'package:nexo/features/legal/terms_screen.dart';
import 'package:nexo/features/legal/support_screen.dart';
import 'package:nexo/features/settings/settings_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/logout_dialog.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/skeleton.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({
    super.key,
    required this.store,
    required this.session,
    required this.theme,
  });
  final AppStore store;
  final SessionService session;
  final ThemeController theme;
  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.store.teacherInfo.hasValue) {
      widget.store.loadTeacherInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: AppLocalizations.of(context).titleProfile,
              ),
            ),
            SliverToBoxAdapter(
              child: PageBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Reveal(
                      index: 0,
                      child: _HeroCard(infoState: widget.store.teacherInfo),
                    ),
                    const Gap(AppSpacing.lg),
                    Reveal(
                      index: 1,
                      child: _InfoCard(infoState: widget.store.teacherInfo),
                    ),
                    const Gap(AppSpacing.lg),
                    Reveal(
                      index: 2,
                      child: _ActionsCard(
                        store: widget.store,
                        theme: widget.theme,
                        onLogout: widget.session.logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final AsyncValue<TeacherInfo> infoState;
  const _HeroCard({required this.infoState});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (infoState.loading && !infoState.hasValue) {
      return const Skeleton(height: 130, radius: 22);
    }
    final info = infoState.value;
    if (info == null || info.code.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NexoTheme.primary, NexoTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.rXxl,
        boxShadow: [
          BoxShadow(
            color: NexoTheme.primary.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const Gap.h(AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.docenteLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppFont.h2,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => ClipboardHelper.copyAndShow(
                    context,
                    info.code,
                    label: l.docenteCodeLabel,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info.code,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: AppFont.body,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.copy_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 13,
                      ),
                    ],
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

class _InfoCard extends StatelessWidget {
  final AsyncValue<TeacherInfo> infoState;
  const _InfoCard({required this.infoState});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final info = infoState.value;
    if (info == null || info.code.isEmpty) return const SizedBox.shrink();
    final rows = <_InfoItem>[
      _InfoItem(
        icon: Icons.numbers_rounded,
        label: l.docenteCodeLabel,
        value: info.code,
        color: NexoTheme.primary,
      ),
      _InfoItem(
        icon: Icons.badge_outlined,
        label: l.docenteInfoFieldNombres,
        value: info.firstName,
      ),
      _InfoItem(
        icon: Icons.person_outline_rounded,
        label: l.docenteInfoFieldApellidos,
        value: info.lastName,
      ),
      if ((info.faculty ?? '').isNotEmpty)
        _InfoItem(
          icon: Icons.account_balance_outlined,
          label: l.docenteInfoFieldFacultad,
          value: info.faculty!,
        ),
      if ((info.specialty ?? '').isNotEmpty)
        _InfoItem(
          icon: Icons.menu_book_outlined,
          label: l.docenteInfoFieldEspecialidad,
          value: info.specialty!,
        ),
    ];
    return SectionCard(
      title: l.docenteInfoTitle,
      icon: Icons.assignment_ind_outlined,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _InfoRow(item: rows[i]),
            if (i < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  const _InfoRow({required this.item});
  @override
  Widget build(BuildContext context) {
    final color = item.color ?? NexoTheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            ClipboardHelper.copyAndShow(context, item.value, label: item.label),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexoTheme.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textMuted,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                        height: 1.25,
                      ),
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
}

class _ActionsCard extends StatelessWidget {
  final AppStore store;
  final ThemeController theme;
  final Future<void> Function() onLogout;
  const _ActionsCard({
    required this.store,
    required this.theme,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          _tile(
            context,
            icon: Icons.settings_outlined,
            color: NexoTheme.primary,
            title: l.settingsTitle,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(store: store, theme: theme),
              ),
            ),
          ),
          const Divider(height: 1, indent: 70),
          _tile(
            context,
            icon: Icons.help_outline_rounded,
            color: NexoTheme.success,
            title: l.supportTitle,
            onTap: () => SupportScreen.open(context),
          ),
          const Divider(height: 1, indent: 70),
          _tile(
            context,
            icon: Icons.info_outline,
            color: NexoTheme.info,
            title: l.titleAbout,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          const Divider(height: 1, indent: 70),
          _tile(
            context,
            icon: Icons.privacy_tip_outlined,
            color: NexoTheme.info,
            title: l.titleTerms,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
            ),
          ),
          const Divider(height: 1, indent: 70),
          _tile(
            context,
            icon: Icons.code_rounded,
            color: NexoTheme.primary,
            title: l.titleDeveloper,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DeveloperScreen()),
            ),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: NexoTheme.danger,
                size: 20,
              ),
            ),
            title: Text(
              l.actionLogout,
              style: const TextStyle(
                color: NexoTheme.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              final ok = await showLogoutConfirm(context);
              if (ok == true) await onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: TextStyle(color: NexoTheme.textSecondary)),
      trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
      onTap: onTap,
    );
  }
}
