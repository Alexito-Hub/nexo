import 'package:flutter/material.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/data/update_service.dart';
import 'package:nexo/l10n/app_localizations.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});
  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  bool _dismissed = false;
  @override
  Widget build(BuildContext context) {
    // En la Store, las actualizaciones las gestiona Windows: sin banner propio.
    if (StoreBuild.isStore) return const SizedBox.shrink();
    final updater = UpdateService.instance;
    if (updater == null || !updater.isSupported || _dismissed) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: updater,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final status = updater.currentStatus();
        final visible =
            status.state == UpdateState.available ||
            status.state == UpdateState.ready;
        if (!visible) return const SizedBox.shrink();
        final ready = status.state == UpdateState.ready;
        final version = status.latestVersion ?? '';
        return Material(
          color: NexoTheme.primary.withValues(alpha: 0.12),
          child: InkWell(
            onTap: updater.isBusy ? null : () => updater.installDownloaded(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.system_update_alt_rounded,
                    size: 20,
                    color: NexoTheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ready
                              ? l.updBannerReadyTitle
                              : l.updBannerAvailableTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NexoTheme.textPrimary,
                          ),
                        ),
                        Text(
                          ready
                              ? l.updBannerReadyBody(version)
                              : l.updBannerAvailableBody(version),
                          style: TextStyle(
                            fontSize: 11,
                            color: NexoTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (updater.isBusy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: NexoTheme.textMuted,
                      ),
                      visualDensity: VisualDensity.compact,
                      tooltip: l.updDismiss,
                      onPressed: () => setState(() => _dismissed = true),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
