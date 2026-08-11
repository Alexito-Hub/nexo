import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/features/directory/widgets/directory_widgets.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

/// Quién puede ver el directorio. Solo para administradores del sistema.
///
/// Conceder y revocar se hace aquí; los administradores en sí se configuran en
/// el servidor y por eso se muestran pero no se editan: quien reparte permisos
/// no debe poder nombrarse desde dentro de la app.
class AccessAdminScreen extends StatefulWidget {
  const AccessAdminScreen({super.key, required this.client});
  final BackendClient client;

  static Future<void> open(BuildContext context, BackendClient client) {
    final l = AppLocalizations.of(context);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccessAdminScreen(client: client),
        settings: RouteSettings(name: l.directoryManageAccess),
      ),
    );
  }

  @override
  State<AccessAdminScreen> createState() => _AccessAdminScreenState();
}

class _AccessAdminScreenState extends State<AccessAdminScreen> {
  bool _loading = true;
  String? _errorCode;
  List<AccessGrant> _grants = const [];
  List<String> _admins = const [];
  String? _busyCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });
    try {
      final data = await widget.client.grants();
      if (!mounted) return;
      setState(() {
        _grants = data.grants;
        _admins = data.admins;
        _loading = false;
      });
    } on BackendException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCode = e.code;
        _loading = false;
      });
    }
  }

  Future<void> _setStatus(String code, String estado) async {
    setState(() => _busyCode = code);
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    try {
      final updated = await widget.client.setGrant(code, estado: estado);
      if (!mounted) return;
      setState(() {
        _grants = [updated, ..._grants.where((g) => g.code != code)];
        _busyCode = null;
      });
    } on BackendException {
      if (!mounted) return;
      setState(() => _busyCode = null);
      messenger.showSnackBar(SnackBar(content: Text(l.directoryGrantFailed)));
    }
  }

  Future<void> _addGrant() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.directoryGrantAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (v) => Navigator.of(context).pop(v.trim().toUpperCase()),
          decoration: InputDecoration(
            labelText: l.directoryGrantCodeLabel,
            helperText: l.directoryGrantCodeHelp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim().toUpperCase()),
            child: Text(l.directoryGrantConfirm),
          ),
        ],
      ),
    );

    controller.dispose();
    if (code == null || code.isEmpty) return;
    await _setStatus(code, 'activo');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: NexoTheme.bg,
      appBar: AppBar(title: Text(l.directoryManageAccess)),
      floatingActionButton: _loading || _errorCode != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addGrant,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(l.directoryGrantAdd),
            ),
      body: SafeArea(child: _body(l)),
    );
  }

  Widget _body(AppLocalizations l) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_errorCode != null) {
      final denied = _errorCode == 'solo_administradores';
      return SingleChildScrollView(
        child: EmptyState(
          icon: denied ? Icons.lock_outline : Icons.cloud_off_outlined,
          title: denied
              ? l.directoryAdminOnlyTitle
              : l.directoryUnavailableTitle,
          subtitle: denied
              ? l.directoryAdminOnlyHint
              : l.directoryUnavailableHint,
          color: denied ? NexoTheme.warning : NexoTheme.danger,
          onRetry: denied ? null : _load,
          retryLabel: l.actionRetry,
        ),
      );
    }

    final active = _grants.where((g) => g.isActive).toList();
    final revoked = _grants.where((g) => !g.isActive).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              context.contentPadding,
              AppSpacing.xl,
              context.contentPadding,
              // Espacio para que el botón flotante no tape la última fila.
              96,
            ),
            children: [
              SoftNotice(
                text: l.directoryAccessExplainer,
                color: NexoTheme.info,
                icon: Icons.info_outline_rounded,
              ),
              const Gap(AppSpacing.lg),
              SectionCard(
                title: l.directoryAdmins,
                subtitle: l.directoryAdminsHint,
                icon: Icons.admin_panel_settings_outlined,
                iconColor: NexoTheme.warning,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final a in _admins)
                      StatusChip(
                        text: a,
                        color: NexoTheme.warning,
                        icon: Icons.shield_outlined,
                      ),
                  ],
                ),
              ),
              const Gap(AppSpacing.lg),
              SectionCard(
                title: l.directoryGrantsActive(active.length),
                icon: Icons.key_rounded,
                iconColor: NexoTheme.success,
                child: active.isEmpty
                    ? SoftNotice(
                        text: l.directoryNoGrants,
                        color: NexoTheme.textMuted,
                        icon: Icons.inbox_outlined,
                      )
                    : Column(
                        children: [
                          for (final g in active)
                            _GrantRow(
                              grant: g,
                              busy: _busyCode == g.code,
                              onToggle: () => _setStatus(g.code, 'revocado'),
                            ),
                        ],
                      ),
              ),
              if (revoked.isNotEmpty) ...[
                const Gap(AppSpacing.lg),
                SectionCard(
                  title: l.directoryGrantsRevoked,
                  icon: Icons.history_rounded,
                  iconColor: NexoTheme.textMuted,
                  child: Column(
                    children: [
                      for (final g in revoked)
                        _GrantRow(
                          grant: g,
                          busy: _busyCode == g.code,
                          onToggle: () => _setStatus(g.code, 'activo'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GrantRow extends StatelessWidget {
  const _GrantRow({
    required this.grant,
    required this.busy,
    required this.onToggle,
  });
  final AccessGrant grant;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = grant.isActive ? NexoTheme.success : NexoTheme.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadii.rSm,
            ),
            child: Icon(
              grant.isActive ? Icons.key_rounded : Icons.lock_outline,
              size: AppIcon.md,
              color: color,
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grant.code,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: NexoTheme.textPrimary,
                  ),
                ),
                if (grant.grantedBy != null || grant.note != null)
                  Text(
                    grant.note ?? l.directoryGrantedBy(grant.grantedBy!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFont.caption,
                      color: NexoTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: onToggle,
              child: Text(
                grant.isActive ? l.directoryRevoke : l.directoryGrant,
                style: TextStyle(
                  color: grant.isActive ? NexoTheme.danger : NexoTheme.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
