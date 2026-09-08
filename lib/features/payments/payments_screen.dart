import 'package:flutter/material.dart';
import 'package:nexo/core/design/breakpoints.dart';
import 'package:nexo/core/design/theme.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/reports/pdf_export.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';
import 'package:nexo/features/payments/payment_detail_screen.dart';
import 'package:nexo/shared/widgets/empty_state.dart';
import 'package:nexo/shared/widgets/page_scaffold.dart';
import 'package:nexo/shared/widgets/reveal.dart';
import 'package:nexo/shared/widgets/skeleton.dart';
import 'package:nexo/shared/widgets/status_chip.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<PaymentsScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      if (!widget.store.pendingInstallments.hasValue)
        widget.store.loadCuotasPendientes(),
      if (!widget.store.intranetInstallments.hasValue)
        widget.store.loadCuotasIntranet(),
      if (!widget.store.tasas.hasValue) widget.store.loadTasas(),
      if (!widget.store.historico.hasValue) widget.store.loadHistorico(),
    ]);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final list = RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              widget.store.loadCuotasPendientes(),
              widget.store.loadCuotasIntranet(),
              widget.store.loadTasas(),
              widget.store.loadHistorico(),
            ]);
          },
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            headerSliverBuilder: (_, _) => [
              SliverToBoxAdapter(
                child: PageHeader(
                  title: AppLocalizations.of(context).titlePayments,
                  subtitle: AppLocalizations.of(context).subtitlePayments,
                  actions: [
                    IconButton(
                      tooltip: AppLocalizations.of(
                        context,
                      ).paymentsDownloadSchedulePdf,
                      icon: const Icon(Icons.download_rounded),
                      onPressed: () =>
                          PdfExport.schedule(context, widget.store),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Reveal(
                  index: 0,
                  child: _SummaryCards(store: widget.store),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: PageBody(child: _TabBar(controller: _tab)),
              ),
            ],
            body: PageBody(
              child: TabBarView(
                controller: _tab,
                children: [
                  _PendientesTab(
                    state: widget.store.pendingInstallments,
                    onRetry: () => widget.store.loadCuotasPendientes(),
                  ),
                  _VencidasTab(
                    state: widget.store.intranetInstallments,
                    onRetry: () => widget.store.loadCuotasIntranet(),
                  ),
                  _TasasTab(
                    state: widget.store.tasas,
                    onRetry: () => widget.store.loadTasas(),
                  ),
                  _HistorialTab(
                    state: widget.store.historico,
                    onRetry: () => widget.store.loadHistorico(),
                  ),
                ],
              ),
            ),
          ),
        );
        return list;
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final AppStore store;
  const _SummaryCards({required this.store});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pending = store.pendingInstallments.value ?? const <Payment>[];
    final vencidas = store.intranetInstallments.value ?? const <Payment>[];
    final tasas = store.tasas.value ?? const <Fee>[];
    final totalPend = pending.fold<double>(0, (a, c) => a + c.total);
    final totalVenc = vencidas.fold<double>(0, (a, c) => a + c.total);
    final totalTasas = tasas.fold<double>(0, (a, t) => a + t.amount);
    return PageBody(
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: l.paymentsTabPending,
              total: totalPend,
              count: pending.length,
              icon: Icons.schedule_rounded,
              color: NexoTheme.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              title: l.paymentsTabOverdue,
              total: totalVenc,
              count: vencidas.length,
              icon: Icons.warning_amber_rounded,
              color: NexoTheme.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              title: l.paymentsTabFees,
              total: totalTasas,
              count: tasas.length,
              icon: Icons.receipt_long_rounded,
              color: NexoTheme.info,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double total;
  final int count;
  final IconData icon;
  final Color color;
  const _SummaryCard({
    required this.title,
    required this.total,
    required this.count,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NexoTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Fmt.currency(total),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: NexoTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: NexoTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NexoTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexoTheme.border),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicator: BoxDecoration(
          color: NexoTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: NexoTheme.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: NoSplash.splashFactory,
        dividerHeight: 0,
        tabs: [
          Tab(text: l.paymentsTabPending),
          Tab(text: l.paymentsTabOverdue),
          Tab(text: l.paymentsTabFees),
          Tab(text: l.paymentsTabHistory),
        ],
      ),
    );
  }
}

Widget _cardList(BuildContext context, List<Widget> cards) {
  if (!context.isDesktop) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 14),
      itemBuilder: (_, i) => cards[i],
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemCount: cards.length,
    );
  }
  final rows = <Widget>[];
  for (var i = 0; i < cards.length; i += 2) {
    rows.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cards[i]),
          const SizedBox(width: 12),
          Expanded(
            child: i + 1 < cards.length ? cards[i + 1] : const SizedBox(),
          ),
        ],
      ),
    );
  }
  return ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 14),
    itemBuilder: (_, i) => rows[i],
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemCount: rows.length,
  );
}

class _PendientesTab extends StatelessWidget {
  final AsyncValue<List<Payment>> state;
  final VoidCallback? onRetry;
  const _PendientesTab({required this.state, this.onRetry});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _CuotaListTab(
      state: state,
      filter: (_) => true,
      emptyTitle: l.paymentsUpToDateTitle,
      emptySubtitle: l.paymentsUpToDateSubtitle,
      emptyIcon: Icons.verified_outlined,
      emptyColor: NexoTheme.success,
      onRetry: onRetry,
    );
  }
}

class _VencidasTab extends StatelessWidget {
  final AsyncValue<List<Payment>> state;
  final VoidCallback? onRetry;
  const _VencidasTab({required this.state, this.onRetry});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _CuotaListTab(
      state: state,
      filter: (_) => true,
      emptyTitle: l.paymentsNoOverdueTitle,
      emptySubtitle: l.paymentsNoOverdueSubtitle,
      emptyIcon: Icons.celebration_outlined,
      emptyColor: NexoTheme.success,
      onRetry: onRetry,
    );
  }
}

class _CuotaListTab extends StatelessWidget {
  final AsyncValue<List<Payment>> state;
  final bool Function(Payment) filter;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final Color emptyColor;
  final VoidCallback? onRetry;
  const _CuotaListTab({
    required this.state,
    required this.filter,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.emptyColor,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) return const _LoadingList();
    if (state.error != null && !state.hasValue) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l.paymentsLoadError,
        subtitle: humanizeError(state.error),
        color: NexoTheme.danger,
        onRetry: onRetry,
      );
    }
    final items = (state.value ?? const <Payment>[]).where(filter).toList()
      ..sort((a, b) {
        final da = a.dueDate;
        final db = b.dueDate;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    if (items.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        color: emptyColor,
      );
    }
    return _cardList(context, [for (final c in items) _CuotaCard(cuota: c)]);
  }
}

class _CuotaCard extends StatelessWidget {
  final Payment cuota;
  const _CuotaCard({required this.cuota});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = cuota.daysUntilDue();
    final isOverdue = days != null && days < 0;
    final isSoon = days != null && days >= 0 && days <= 3;
    final tagColor = isOverdue
        ? NexoTheme.danger
        : isSoon
        ? NexoTheme.warning
        : NexoTheme.textSecondary;
    final tagText = isOverdue
        ? l.paymentDaysOverdue((-days).toString())
        : days == 0
        ? l.paymentVenceHoy
        : days == 1
        ? l.paymentVenceManana
        : days == null
        ? '—'
        : l.paymentDaysLeft(days.toString());
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PaymentDetailScreen.openCuota(context, cuota),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? NexoTheme.danger.withValues(alpha: 0.4)
                  : NexoTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cuota.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${cuota.currency} ${cuota.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: NexoTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
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
                  StatusChip(text: tagText, color: tagColor),
                  if (cuota.lateFee > 0)
                    StatusChip(
                      text: l.paymentMora(
                        cuota.currency,
                        cuota.lateFee.toStringAsFixed(2),
                      ),
                      color: NexoTheme.danger,
                      icon: Icons.warning_amber_rounded,
                    ),
                ],
              ),
              if (cuota.note.trim().isNotEmpty &&
                  cuota.note.trim() != '--') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NexoTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: NexoTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cuota.note,
                          style: TextStyle(
                            fontSize: 11,
                            color: NexoTheme.textSecondary,
                          ),
                        ),
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

class _TasasTab extends StatelessWidget {
  final AsyncValue<List<Fee>> state;
  final VoidCallback? onRetry;
  const _TasasTab({required this.state, this.onRetry});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.showSkeleton) return const _LoadingList();
    if (state.error != null && !state.hasValue) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l.paymentsLoadError,
        subtitle: humanizeError(state.error),
        color: NexoTheme.danger,
        onRetry: onRetry,
      );
    }
    final items = state.value ?? const <Fee>[];
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l.paymentsNoFeesRegistered,
      );
    }
    return _cardList(context, [for (final t in items) _TasaCard(tasa: t)]);
  }
}

class _TasaCard extends StatelessWidget {
  final Fee tasa;
  const _TasaCard({required this.tasa});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PaymentDetailScreen.openTasa(context, tasa),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NexoTheme.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: NexoTheme.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tasa.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                    if (tasa.note.trim().isNotEmpty && tasa.note.trim() != '--')
                      Text(
                        tasa.note,
                        style: TextStyle(
                          fontSize: 12,
                          color: NexoTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${tasa.currency} ${tasa.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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

class _HistorialTab extends StatefulWidget {
  final AsyncValue<List<PaymentRecord>> state;
  final VoidCallback? onRetry;
  const _HistorialTab({required this.state, this.onRetry});
  @override
  State<_HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends State<_HistorialTab> {
  String? _termFilter;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = widget.state;
    if (state.showSkeleton) return const _LoadingList();
    if (state.error != null && !state.hasValue) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l.paymentsLoadError,
        subtitle: humanizeError(state.error),
        color: NexoTheme.danger,
        onRetry: widget.onRetry,
      );
    }
    final items = state.value ?? const <PaymentRecord>[];
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.history_rounded,
        title: l.paymentsNoHistoryRegistered,
      );
    }
    final terms =
        items.map((p) => p.term).where((t) => t.isNotEmpty).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
    final filtered = _termFilter == null
        ? items
        : items.where((p) => p.term == _termFilter).toList();
    final sorted = [...filtered]
      ..sort((a, b) {
        final da = a.dateAsDate;
        final db = b.dateAsDate;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    final byDate = <String, List<PaymentRecord>>{};
    for (final p in sorted) {
      byDate.putIfAbsent(p.date, () => []).add(p);
    }
    return Column(
      children: [
        if (terms.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TermChip(
                    label: l.paymentsFilterAll,
                    selected: _termFilter == null,
                    onTap: () => setState(() => _termFilter = null),
                  ),
                  const SizedBox(width: 6),
                  for (final t in terms) ...[
                    _TermChip(
                      label: t,
                      selected: _termFilter == t,
                      onTap: () => setState(() => _termFilter = t),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        Expanded(
          child: byDate.isEmpty
              ? EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: l.paymentsNoneInPeriod,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: byDate.length,
                  itemBuilder: (_, i) {
                    final date = byDate.keys.elementAt(i);
                    final list = byDate[date]!;
                    final dt = list.first.dateAsDate;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                            child: Text(
                              dt == null ? date : Fmt.fullDate(dt),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NexoTheme.textSecondary,
                              ),
                            ),
                          ),
                          for (var j = 0; j < list.length; j++) ...[
                            _HistTile(item: list[j]),
                            if (j < list.length - 1) const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TermChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? NexoTheme.primary : NexoTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? NexoTheme.primary : NexoTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : NexoTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _HistTile extends StatelessWidget {
  final PaymentRecord item;
  const _HistTile({required this.item});
  @override
  Widget build(BuildContext context) {
    final esDesc = item.isDiscount;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => PaymentDetailScreen.openHistorico(context, item),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexoTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NexoTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (esDesc ? NexoTheme.warning : NexoTheme.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  esDesc ? Icons.discount_outlined : Icons.check_circle_outline,
                  size: 18,
                  color: esDesc ? NexoTheme.warning : NexoTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.concept,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NexoTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        Text(
                          item.term,
                          style: TextStyle(
                            fontSize: 11,
                            color: NexoTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.place.trim().isNotEmpty)
                          Text(
                            '· ${item.place}',
                            style: TextStyle(
                              fontSize: 11,
                              color: NexoTheme.textMuted,
                            ),
                          ),
                        if (item.voucher.trim().isNotEmpty)
                          Text(
                            '· ${item.voucher}',
                            style: TextStyle(
                              fontSize: 11,
                              color: NexoTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.currency} ${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: esDesc ? NexoTheme.warning : NexoTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 14),
      itemBuilder: (_, _) => const Skeleton(height: 80, radius: 16),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemCount: 5,
    );
  }
}
