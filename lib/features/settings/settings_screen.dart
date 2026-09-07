import 'package:flutter/material.dart';
import 'package:nexo/core/app_locale.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/theme_controller.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/update_service.dart';
import 'package:nexo/features/notifications/notifications_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store, required this.theme});
  final AppStore store;
  final ThemeController theme;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AppearanceCard(theme: theme),
                const SizedBox(height: 14),
                _PreferencesCard(theme: theme),
                const SizedBox(height: 14),
                _NotificationsCard(store: store),
                const SizedBox(height: 14),
                const UpdateCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  final ThemeController theme;
  const _AppearanceCard({required this.theme});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        final selection = theme.selection;
        final l = AppLocalizations.of(context);
        return SectionCard(
          title: l.settingsAppearance,
          icon: Icons.palette_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SystemOption(
                title: l.settingsSystem,
                subtitle: l.settingsSystemDesc,
                selected: selection == 'system',
                onTap: () => theme.setSelection('system'),
              ),
              const SizedBox(height: 12),
              Text(
                l.settingsPalette.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: NexoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (ctx, c) {
                  final cols = c.maxWidth >= 480 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: NexoColors.all.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 96,
                    ),
                    itemBuilder: (_, i) {
                      final palette = NexoColors.all[i];
                      return _PaletteTile(
                        palette: palette,
                        selected: selection == palette.id,
                        activeLabel: l.settingsActive,
                        onTap: () => theme.setSelection(palette.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SystemOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _SystemOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? NexoTheme.primary.withValues(alpha: 0.10)
              : NexoTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.brightness_auto_rounded,
              color: selected ? NexoTheme.primary : NexoTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? NexoTheme.primary
                          : NexoTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: NexoTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: NexoTheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  final NexoColors palette;
  final bool selected;
  final String activeLabel;
  final VoidCallback onTap;
  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.activeLabel,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: NexoTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            _PalettePreview(palette: palette),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    palette.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? NexoTheme.primary
                          : NexoTheme.textPrimary,
                    ),
                  ),
                  if (selected)
                    Text(
                      activeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: NexoTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PalettePreview extends StatelessWidget {
  final NexoColors palette;
  const _PalettePreview({required this.palette});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: palette.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 6,
            top: 22,
            right: 6,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: palette.border),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final ThemeController theme;
  const _PreferencesCard({required this.theme});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        return SectionCard(
          title: '${l.language} / ${l.timeFormat}',
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.language.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: NexoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
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
                    if (loc != AppLocale.values.last) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l.timeFormat.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: NexoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PrefChip(
                      label: l.hours24,
                      selected: theme.use24h,
                      onTap: () => theme.setUse24h(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PrefChip(
                      label: l.hours12,
                      selected: !theme.use24h,
                      onTap: () => theme.setUse24h(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _FestivityToggle(),
            ],
          ),
        );
      },
    );
  }
}

class _FestivityToggle extends StatefulWidget {
  const _FestivityToggle();
  @override
  State<_FestivityToggle> createState() => _FestivityToggleState();
}

class _FestivityToggleState extends State<_FestivityToggle> {
  Future<void> _set(bool v) async {
    await AppStorage.instance.setFestivityDecor(v);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final on = AppStorage.instance.festivityDecor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ADORNOS DE FESTIVIDADES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: NexoTheme.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PrefChip(
                label: 'Activado',
                selected: on,
                onTap: () => _set(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PrefChip(
                label: 'Desactivado',
                selected: !on,
                onTap: () => _set(false),
              ),
            ),
          ],
        ),
      ],
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? NexoTheme.primary.withValues(alpha: 0.12)
              : NexoTheme.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? NexoTheme.primary : NexoTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  final AppStore store;
  const _NotificationsCard({required this.store});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: NexoTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.notifications_active_outlined,
            color: NexoTheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          l.titleNotifications,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          l.settingsNotificationsSubtitle,
          style: TextStyle(color: NexoTheme.textSecondary),
        ),
        trailing: Icon(Icons.chevron_right, color: NexoTheme.textMuted),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NotificationsScreen(store: store),
          ),
        ),
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});
  @override
  Widget build(BuildContext context) {
    // En la Store, Windows gestiona las actualizaciones: sin tarjeta propia.
    if (StoreBuild.isStore) return const SizedBox.shrink();
    final updater = UpdateService.instance;
    if (updater == null || !updater.isSupported) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: updater,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final status = updater.currentStatus();
        final busy = updater.isBusy;
        return SectionCard(
          title: l.updTitle,
          icon: Icons.system_update_alt_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.updInstalledVersion,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: NexoTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nexo ${AppConfig.appVersion}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: NexoTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(status: status, busy: busy),
                ],
              ),
              const SizedBox(height: 14),
              _UpdateAction(updater: updater, status: status, busy: busy),
            ],
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final UpdateStatus status;
  final bool busy;
  const _StatusPill({required this.status, required this.busy});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    late final String label;
    late final Color color;
    late final IconData icon;
    if (busy) {
      label = l.updStatusChecking;
      color = NexoTheme.textSecondary;
      icon = Icons.sync_rounded;
    } else {
      switch (status.state) {
        case UpdateState.ready:
        case UpdateState.available:
          label = l.updStatusAvailable;
          color = NexoTheme.primary;
          icon = Icons.new_releases_rounded;
        case UpdateState.upToDate:
          label = l.updStatusUpToDate;
          color = NexoTheme.success;
          icon = Icons.verified_rounded;
        case UpdateState.unknown:
        case UpdateState.unsupported:
          label = l.updStatusUnknown;
          color = NexoTheme.textMuted;
          icon = Icons.help_outline_rounded;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateAction extends StatelessWidget {
  final UpdateService updater;
  final UpdateStatus status;
  final bool busy;
  const _UpdateAction({
    required this.updater,
    required this.status,
    required this.busy,
  });
  Future<void> _check(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final s = await updater.checkNow();
    if (!context.mounted) return;
    final msg = switch (s.state) {
      UpdateState.upToDate => l.updSnackUpToDate,
      UpdateState.available ||
      UpdateState.ready => l.updSnackAvailable(s.latestVersion ?? ''),
      _ => l.updSnackCheckFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _install(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ok = await updater.installDownloaded();
    if (!context.mounted || ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.updSnackInstallFailed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasUpdate =
        status.state == UpdateState.available ||
        status.state == UpdateState.ready;
    if (hasUpdate) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.updAvailableLine(status.latestVersion ?? ''),
            style: TextStyle(fontSize: 13, color: NexoTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: busy ? null : () => _install(context),
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(
              status.state == UpdateState.ready
                  ? l.updInstallNow
                  : l.updDownloadInstall,
            ),
          ),
        ],
      );
    }
    return OutlinedButton.icon(
      onPressed: busy ? null : () => _check(context),
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded, size: 18),
      label: Text(l.updCheck),
    );
  }
}
