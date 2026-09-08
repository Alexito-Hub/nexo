import 'package:flutter/material.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/domain/idiomas_models.dart';
import 'package:nexo/features/auth/change_password_screen.dart';
import 'package:nexo/features/legal/about_screen.dart';
import 'package:nexo/features/legal/developer_screen.dart';
import 'package:nexo/features/legal/terms_screen.dart';
import 'package:nexo/features/legal/support_screen.dart';
import 'package:nexo/features/reports/pdf_export.dart';
import 'package:nexo/features/settings/settings_screen.dart';
import 'package:nexo/features/profile/wifi_dialog.dart';
import 'package:nexo/shared/util/clipboard_helper.dart';
import 'package:nexo/shared/widgets/logout_dialog.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/student_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.store,
    required this.session,
    required this.theme,
  });
  final AppStore store;
  final SessionService session;
  final ThemeController theme;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final p = store.profile.value;
        return RefreshIndicator(
          onRefresh: () => store.loadProfile().then((_) {}),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: l.titleProfile,
                  actions: [
                    IconButton(
                      tooltip: l.wifiTitle,
                      icon: const Icon(Icons.wifi_rounded),
                      onPressed: () => showWifiDialog(context, store),
                    ),
                    IconButton(
                      tooltip: l.profileDownloadEnrollmentPdf,
                      icon: const Icon(Icons.file_download_outlined),
                      onPressed: () => PdfExport.certificate(context, store),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: PageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Reveal(
                        index: 0,
                        child: _HeroCard(
                          profile: p,
                          average: store.promedioAcumulado,
                          creditsApprov: store.approvedCredits,
                          creditsTotal: store.totalCredits,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Reveal(index: 1, child: _AcademicCard(profile: p)),
                      if (store.idiomasVigentes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Reveal(
                          index: 2,
                          child: _IdiomasCard(courses: store.idiomasVigentes),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Reveal(
                        index: 3,
                        child: _ActionsCard(
                          onLogout: session.logout,
                          store: store,
                          theme: theme,
                        ),
                      ),
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

class _HeroCard extends StatelessWidget {
  final Student? profile;
  final double? average;
  final int? creditsApprov;
  final int? creditsTotal;
  const _HeroCard({
    required this.profile,
    required this.average,
    required this.creditsApprov,
    required this.creditsTotal,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NexoTheme.primary, NexoTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: NexoTheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(
                code: profile?.id,
                name: profile?.fullName ?? '',
                size: 72,
                radius: 22,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile == null ? '...' : profile!.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        if (profile?.id != null) {
                          ClipboardHelper.copyAndShow(
                            context,
                            profile!.id,
                            label: l.profileStudentCode,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile?.id ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
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
          const SizedBox(height: 24),
          Row(
            children: [
              _heroStat(
                context,
                l.homeMetricPromedio.toUpperCase(),
                average == null ? '—' : average!.toStringAsFixed(2),
              ),
              _heroDivider(),
              _heroStat(
                context,
                l.homeMetricCreditos.toUpperCase(),
                creditsApprov == null
                    ? '—'
                    : creditsTotal != null && creditsTotal! > 0
                    ? '$creditsApprov/$creditsTotal'
                    : '$creditsApprov',
              ),
              _heroDivider(),
              _heroStat(
                context,
                l.detailLevel.toUpperCase(),
                profile?.level ?? '—',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(BuildContext context, String label, String value) =>
      Expanded(
        child: GestureDetector(
          onTap: () {
            if (value != '—') {
              ClipboardHelper.copyAndShow(context, value, label: label);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      );
  Widget _heroDivider() => Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.18),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

class _AcademicCard extends StatelessWidget {
  final Student? profile;
  const _AcademicCard({required this.profile});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = profile;
    final items = <_InfoItem>[
      _InfoItem(
        icon: Icons.menu_book_outlined,
        label: l.profileCareer,
        value: p?.career ?? '—',
        wide: true,
        color: NexoTheme.primary,
      ),
      _InfoItem(
        icon: Icons.account_balance_outlined,
        label: l.profileFaculty,
        value: p?.faculty ?? '—',
        wide: true,
      ),
      _InfoItem(
        icon: Icons.location_city_outlined,
        label: l.profileCampus,
        value: p?.campus ?? '—',
      ),
      _InfoItem(
        icon: Icons.video_camera_back_outlined,
        label: l.profileMode,
        value: p?.modality ?? '—',
      ),
      _InfoItem(
        icon: Icons.bookmark_outline,
        label: l.profileStudyPlan,
        value: p?.studyPlan ?? '—',
      ),
      _InfoItem(
        icon: Icons.layers_outlined,
        label: l.profileLevel,
        value: p?.level ?? '—',
      ),
      _InfoItem(
        icon: Icons.event_available_outlined,
        label: l.profileLastEnrollment,
        value: p?.lastEnrollment ?? '—',
      ),
      _InfoItem(
        icon: p?.isEnrolled == true
            ? Icons.check_circle_outline
            : Icons.cancel_outlined,
        label: l.profileStatus,
        value: p?.isEnrolled == true
            ? l.profileStatusEnrolled
            : l.profileStatusNotEnrolled,
        color: p?.isEnrolled == true ? NexoTheme.success : NexoTheme.danger,
      ),
    ];
    return SectionCard(
      title: l.profileAcademicInfo,
      icon: Icons.school_outlined,
      child: LayoutBuilder(
        builder: (ctx, c) {
          final twoCols = c.maxWidth >= 540;
          final tiles = <Widget>[];
          for (var i = 0; i < items.length; i++) {
            final item = items[i];
            tiles.add(_InfoTile(item: item));
          }
          if (!twoCols) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  tiles[i],
                  if (i < tiles.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          }
          final rows = <Widget>[];
          var i = 0;
          while (i < items.length) {
            final current = items[i];
            if (current.wide) {
              rows.add(_InfoTile(item: current));
              i++;
            } else if (i + 1 < items.length && !items[i + 1].wide) {
              rows.add(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _InfoTile(item: items[i])),
                      const SizedBox(width: 8),
                      Expanded(child: _InfoTile(item: items[i + 1])),
                    ],
                  ),
                ),
              );
              i += 2;
            } else {
              rows.add(_InfoTile(item: items[i]));
              i++;
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var k = 0; k < rows.length; k++) ...[
                rows[k],
                if (k < rows.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _IdiomasCard extends StatelessWidget {
  final List<IdiomasCourse> courses;
  const _IdiomasCard({required this.courses});

  @override
  Widget build(BuildContext context) {
    String monthName(int mes) {
      const meses = [
        'ENERO',
        'FEBRERO',
        'MARZO',
        'ABRIL',
        'MAYO',
        'JUNIO',
        'JULIO',
        'AGOSTO',
        'SETIEMBRE',
        'OCTUBRE',
        'NOVIEMBRE',
        'DICIEMBRE',
      ];
      if (mes >= 1 && mes <= 12) return meses[mes - 1];
      return mes.toString();
    }

    return SectionCard(
      title: 'Centro de Idiomas',
      icon: Icons.translate_rounded,
      iconColor: Colors.orange.shade400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < courses.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _InfoTile(
              item: _InfoItem(
                icon: Icons.language_rounded,
                label: 'Idioma',
                value: courses[i].idiomaNombre,
                wide: true,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 8),
            _InfoTile(
              item: _InfoItem(
                icon: Icons.calendar_month_outlined,
                label: 'Periodo',
                value: '${courses[i].anio}-${monthName(courses[i].mes)}',
              ),
            ),
            const SizedBox(height: 8),
            _InfoTile(
              item: _InfoItem(
                icon: Icons.school_outlined,
                label: 'Modalidad',
                value: '${courses[i].modalidad} ${courses[i].tipoEstudio}',
                wide: true,
              ),
            ),
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
  final bool wide;
  final Color? color;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.wide = false,
    this.color,
  });
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;
  const _InfoTile({required this.item});
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
                        color: item.color ?? NexoTheme.textPrimary,
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
  final Future<void> Function() onLogout;
  final AppStore store;
  final ThemeController theme;
  const _ActionsCard({
    required this.onLogout,
    required this.store,
    required this.theme,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: NexoTheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              l.settingsTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SettingsScreen(store: store, theme: theme),
              ),
            ),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: NexoTheme.warning,
                size: 20,
              ),
            ),
            title: Text(
              l.titleChangePassword,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChangePasswordScreen(store: store),
              ),
            ),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: NexoTheme.success,
                size: 20,
              ),
            ),
            title: Text(
              l.supportTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
            onTap: () => SupportScreen.open(context),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: NexoTheme.info,
                size: 20,
              ),
            ),
            title: Text(
              l.titleAbout,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: NexoTheme.info,
                size: 20,
              ),
            ),
            title: Text(
              l.titleTerms,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
            ),
          ),
          const Divider(height: 1, indent: 70),
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: NexoTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.code_rounded,
                color: NexoTheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              l.titleDeveloper,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
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
}
