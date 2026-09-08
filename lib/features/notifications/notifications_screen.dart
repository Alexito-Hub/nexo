import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/design/tokens.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/notification_service.dart';
import 'package:nexo/domain/notification_prefs.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _svc = NotificationService.instance;
  late NotificationPrefs _p = _svc.prefs;
  Future<void> _save(NotificationPrefs next) async {
    setState(() => _p = next);
    await _svc.updatePrefs(
      next,
      clases: widget.store.schedule.value,
      installments: widget.store.pendingInstallments.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.titleNotifications)),
      body: SafeArea(
        child: ListView(
          children: [
            PageBody(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  l.notificationsIntro,
                  style: TextStyle(
                    fontSize: AppFont.body,
                    color: NexoTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.lg),
            PageBody(
              child: _MasterCard(
                enabled: _p.enabled,
                onChanged: (v) => _save(_p.copyWith(enabled: v)),
              ),
            ),
            AnimatedSize(
              duration: AppDurations.normal,
              curve: Curves.easeOut,
              child: _p.enabled
                  ? PageBody(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CategoryCard(
                              icon: Icons.calendar_today_rounded,
                              color: NexoTheme.primary,
                              title: l.notificationsClassesTitle,
                              subtitle: l.notificationsClassesSubtitle,
                              value: _p.classesEnabled,
                              onToggle: (v) =>
                                  _save(_p.copyWith(classesEnabled: v)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ChipRow(
                                    options:
                                        NotificationPrefs.opcionesLeadMinutes,
                                    selected: {_p.classLeadMinutes},
                                    label: (m) =>
                                        NotificationPrefs.labelLeadMinutes(
                                          context,
                                          m,
                                        ),
                                    onSelect: (m) =>
                                        _save(_p.copyWith(classLeadMinutes: m)),
                                  ),
                                  const Gap(AppSpacing.md),
                                  const _ExactAlarmsBanner(),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            _CategoryCard(
                              icon: Icons.account_balance_wallet_rounded,
                              color: NexoTheme.warning,
                              title: l.notificationsPaymentsTitle,
                              subtitle: l.notificationsPaymentsSubtitle,
                              value: _p.paymentsEnabled,
                              onToggle: (v) =>
                                  _save(_p.copyWith(paymentsEnabled: v)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _MiniLabel(l.notificationsNotifyMe),
                                  const Gap(AppSpacing.sm),
                                  _ChipRow(
                                    multi: true,
                                    options: NotificationPrefs.opcionesLeadDays,
                                    selected: _p.paymentLeadDays.toSet(),
                                    label: (d) =>
                                        NotificationPrefs.labelLeadDays(
                                          context,
                                          d,
                                        ),
                                    onSelect: (d) {
                                      final set = _p.paymentLeadDays.toSet();
                                      if (set.contains(d)) {
                                        set.remove(d);
                                      } else {
                                        set.add(d);
                                      }
                                      final list = set.toList()..sort();
                                      _save(
                                        _p.copyWith(
                                          paymentLeadDays: list.reversed
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                  const Gap(AppSpacing.md),
                                  _MiniLabel(
                                    l.notificationsPaymentHour(
                                      _p.paymentHour.toString().padLeft(2, '0'),
                                    ),
                                  ),
                                  Slider(
                                    value: _p.paymentHour.toDouble(),
                                    min: 6,
                                    max: 21,
                                    divisions: 15,
                                    label:
                                        '${_p.paymentHour.toString().padLeft(2, '0')}:00',
                                    onChanged: (v) => _save(
                                      _p.copyWith(paymentHour: v.round()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            _CategoryCard(
                              icon: Icons.school_rounded,
                              color: NexoTheme.success,
                              title: l.notificationsGradesTitle,
                              subtitle: l.notificationsGradesSubtitle,
                              value: _p.gradesEnabled,
                              onToggle: (v) =>
                                  _save(_p.copyWith(gradesEnabled: v)),
                            ),
                            const Gap(AppSpacing.lg),
                            const _InfoNote(),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const Gap(AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _MasterCard({required this.enabled, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(
                colors: [NexoTheme.primary, NexoTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: enabled ? null : NexoTheme.surface,
        borderRadius: AppRadii.rXl,
        border: enabled ? null : Border.all(color: NexoTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.2)
                  : NexoTheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadii.rMd,
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: enabled ? Colors.white : NexoTheme.primary,
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.notificationsEnableTitle,
                  style: TextStyle(
                    fontSize: AppFont.title,
                    fontWeight: FontWeight.w800,
                    color: enabled ? Colors.white : NexoTheme.textPrimary,
                  ),
                ),
                Text(
                  enabled
                      ? l.notificationsEnabledLabel
                      : l.notificationsDisabledLabel,
                  style: TextStyle(
                    fontSize: AppFont.small,
                    color: enabled
                        ? Colors.white.withValues(alpha: 0.85)
                        : NexoTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onToggle;
  final Widget? child;
  const _CategoryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onToggle,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: AppRadii.rXl,
        border: Border.all(color: NexoTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadii.rMd,
                  ),
                  child: Icon(icon, color: color, size: AppIcon.lg),
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppFont.title,
                          fontWeight: FontWeight.w700,
                          color: NexoTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: AppFont.small,
                          color: NexoTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(value: value, onChanged: onToggle),
              ],
            ),
          ),
          if (child != null)
            AnimatedSize(
              duration: AppDurations.fast,
              child: value
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: child,
                    )
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<int> options;
  final Set<int> selected;
  final String Function(int) label;
  final ValueChanged<int> onSelect;
  final bool multi;
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelect,
    this.multi = false,
  });
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final o in options)
          _Chip(
            text: label(o),
            active: selected.contains(o),
            onTap: () => onSelect(o),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.text, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.rPill,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: active ? NexoTheme.primary : NexoTheme.bg,
          borderRadius: AppRadii.rPill,
          border: Border.all(
            color: active ? NexoTheme.primary : NexoTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const Gap.h(AppSpacing.xs),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: AppFont.small,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : NexoTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: AppFont.small,
      fontWeight: FontWeight.w600,
      color: NexoTheme.textSecondary,
    ),
  );
}

class _InfoNote extends StatelessWidget {
  const _InfoNote();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: NexoTheme.info.withValues(alpha: 0.08),
        borderRadius: AppRadii.rMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: AppIcon.sm,
            color: NexoTheme.info,
          ),
          const Gap.h(AppSpacing.sm),
          Expanded(
            child: Text(
              l.notificationsInfoNote,
              style: TextStyle(
                fontSize: AppFont.caption,
                color: NexoTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExactAlarmsBanner extends StatefulWidget {
  const _ExactAlarmsBanner();
  @override
  State<_ExactAlarmsBanner> createState() => _ExactAlarmsBannerState();
}

class _ExactAlarmsBannerState extends State<_ExactAlarmsBanner> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _check();
    NotificationService.instance.addListener(_check);
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_check);
    super.dispose();
  }

  Future<void> _check() async {
    final has = await NotificationService.instance.hasExactAlarmsPermission();
    if (mounted && _hasPermission != has) {
      setState(() => _hasPermission = has);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: NexoTheme.warning.withValues(alpha: 0.1),
        borderRadius: AppRadii.rMd,
        border: Border.all(color: NexoTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: NexoTheme.warning,
                size: 20,
              ),
              const Gap.h(AppSpacing.sm),
              Expanded(
                child: Text(
                  'Permiso de alarmas exactas',
                  style: TextStyle(
                    fontSize: AppFont.small,
                    fontWeight: FontWeight.w700,
                    color: NexoTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(
            'Sin este permiso, los recordatorios pueden llegar con retraso debido al modo de ahorro de energía del sistema.',
            style: TextStyle(
              fontSize: AppFont.caption,
              color: NexoTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const Gap(AppSpacing.sm),
          OutlinedButton(
            onPressed: () =>
                NotificationService.instance.requestExactAlarmsPermission(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: const BorderSide(color: NexoTheme.warning),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.rMd),
            ),
            child: const Text(
              'Conceder permiso',
              style: TextStyle(
                color: NexoTheme.warning,
                fontWeight: FontWeight.w600,
                fontSize: AppFont.small,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
