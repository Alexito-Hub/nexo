import 'package:flutter/material.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/payments/payment_detail_screen.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/shared/widgets/section_card.dart';
import 'package:nexo/l10n/app_localizations.dart';

class PendingPaymentsWidget extends StatelessWidget {
  final List<Payment> installments;
  final DateTime? nowOverride;
  final bool isCompact;
  const PendingPaymentsWidget({
    super.key,
    required this.installments,
    this.nowOverride,
    this.isCompact = false,
  });
  DateTime get now => nowOverride ?? DateTime.now();
  @override
  Widget build(BuildContext context) {
    final sorted = [...installments]
      ..sort((a, b) {
        final da = a.dueDate;
        final db = b.dueDate;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    final total = sorted.fold<double>(0, (acc, c) => acc + c.total);
    final next = sorted.firstOrNull;
    final hoy = DateTime(now.year, now.month, now.day);
    final vencidas = sorted
        .where((c) => (c.dueDate?.isBefore(hoy) ?? false))
        .length;
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.homePendingPaymentsTitle,
      subtitle: vencidas > 0
          ? l10n.homePendingPaymentsOverdueCount(vencidas)
          : next == null
          ? l10n.widgetNoPendingDebts
          : next.dueDateRaw.trim().isEmpty
          ? next.description
          : l10n.paymentVenceEl(next.dueDateRaw),
      icon: Icons.payments_outlined,
      iconColor: vencidas > 0 ? NexoTheme.danger : NexoTheme.warning,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: NexoTheme.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          Fmt.currency(total),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: NexoTheme.textPrimary,
          ),
        ),
      ),
      child: sorted.isEmpty
          ? _empty(context)
          : Column(
              children: [
                for (var i = 0; i < sorted.length.clamp(0, isCompact ? 2 : 4); i++) ...[
                  _CuotaRow(cuota: sorted[i], now: now),
                  if (i < sorted.length.clamp(0, isCompact ? 2 : 4) - 1)
                    const SizedBox(height: 10),
                ],
                if (sorted.length > (isCompact ? 2 : 4)) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).homePendingPaymentsMore(sorted.length - (isCompact ? 2 : 4)),
                      style: TextStyle(
                        color: NexoTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _empty(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 28),
    alignment: Alignment.center,
    child: Column(
      children: [
        const Icon(Icons.verified_outlined, size: 36, color: NexoTheme.success),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).paymentsUpToDateTitle,
          style: TextStyle(
            fontSize: 14,
            color: NexoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _CuotaRow extends StatelessWidget {
  final Payment cuota;
  final DateTime now;
  const _CuotaRow({required this.cuota, required this.now});
  @override
  Widget build(BuildContext context) {
    final days = cuota.daysUntilDue(now);
    final isOverdue = days != null && days < 0;
    final isSoon = days != null && days >= 0 && days <= 3;
    final tagColor = isOverdue
        ? NexoTheme.danger
        : isSoon
        ? NexoTheme.warning
        : NexoTheme.textSecondary;
    final l10n = AppLocalizations.of(context);
    // Sin fecha de vencimiento no hay etiqueta relativa ("En null días").
    final String? tagText = days == null
        ? null
        : isOverdue
        ? l10n.paymentDaysOverdue((-days).toString())
        : days == 0
        ? l10n.paymentVenceHoy
        : days == 1
        ? l10n.paymentVenceManana
        : l10n.paymentDaysLeft(days.toString());
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PaymentDetailScreen.openCuota(context, cuota),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isOverdue
                ? NexoTheme.danger.withValues(alpha: 0.04)
                : NexoTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOverdue
                  ? NexoTheme.danger.withValues(alpha: 0.3)
                  : NexoTheme.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cuota.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 14,
                              color: NexoTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cuota.dueDateRaw,
                              style: TextStyle(
                                fontSize: 12,
                                color: NexoTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (tagText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tagText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: tagColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${cuota.currency} ${cuota.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: NexoTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
