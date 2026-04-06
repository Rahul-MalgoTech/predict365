import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/CustomSnackBar/StatusMessage.dart';
import 'package:predict365/ViewModel/CancelOrderVM.dart';
import 'package:provider/provider.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'MarketTickerService.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    AppText('My Portfolio', fontSize: 22, fontWeight: FontWeight.w800),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Tab bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // theme.colorScheme.surfaceBright.withValues(alpha: 0.5),
                          // theme.colorScheme.surfaceBright.withValues(alpha: 0.3),
                          Color(0xFF985720),
                          Color(0xFFB6792E),
                          Color(0xFFD3983B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    labelColor:Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Active Trades'),
                      Tab(text: 'Closed Trades'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: TabBarView(
                  children: [
                    _ActiveTab(),
                    _ClosedTab(),
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

// ─────────────────────────────────────────────────────────────────
// ACTIVE TAB
// ─────────────────────────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketTickerService>(
      builder: (context, svc, _) {
        final positions = svc.openPositions;
        final orders    = svc.pendingOrders;
        final totalInv  = positions.fold<double>(0, (s, p) => s + p.avgPrice * p.shares);
        final totalVal  = positions.fold<double>(0, (s, p) => s + p.currValue);
        final totalPL   = positions.fold<double>(0, (s, p) => s + p.profitLoss);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary card ─────────────────────────────
              _SummaryCard(
                leftLabel: 'Total Investment',
                leftValue: _fmtVal(totalInv),
                rightLabel: 'Current Value',
                rightValue: _fmtVal(totalVal),
                pnl: totalPL,
              ),
              const SizedBox(height: 20),

              // ── Open Positions ───────────────────────────
              _SectionLabel(title: 'Open Positions', count: positions.length),
              const SizedBox(height: 10),
              if (positions.isEmpty)
                _EmptyCard(message: 'No open positions')
              else
                Column(
                  children: positions
                      .map((p) => _PositionCard(position: p, service: svc))
                      .toList(),
                ),

              const SizedBox(height: 20),

              // ── Pending Orders ───────────────────────────
              _SectionLabel(title: 'Pending Orders', count: orders.length),
              const SizedBox(height: 10),
              if (orders.isEmpty)
                _EmptyCard(message: 'No pending orders')
              else
                Column(
                  children: orders.map((o) => _OrderCard(order: o)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CLOSED TAB
// ─────────────────────────────────────────────────────────────────
class _ClosedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketTickerService>(
      builder: (context, svc, _) {
        final trades   = svc.closedTrades;
        final totalInv = trades.fold<double>(0, (s, t) => s + t.price * t.shares);
        final totalPL  = trades.fold<double>(0, (s, t) => s + t.pnl);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                leftLabel: 'Total Investment',
                leftValue: _fmtVal(totalInv),
                rightLabel: 'Total Returns',
                rightValue: _fmtVal(totalPL),
                pnl: totalPL,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _SectionLabel(title: 'Closed Trades', count: trades.length),
                  const SizedBox(width: 8),
                  Text('Last 30 days',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 10),
              if (trades.isEmpty)
                _EmptyCard(message: 'No closed trades found')
              else
                Column(
                  children: trades.map((t) => _ClosedCard(trade: t)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// POSITION CARD — mobile card layout, no overflow
// ─────────────────────────────────────────────────────────────────
class _PositionCard extends StatelessWidget {
  final OpenPosition position;
  final MarketTickerService service;
  const _PositionCard({required this.position, required this.service});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final tick   = service.getMarketData(position.marketId);
    final ltp    = tick?.ltp ?? position.currPrice ?? position.avgPrice;
    final cv     = ltp * position.shares;
    final pl     = (ltp - position.avgPrice) * position.shares;
    final plPct  = position.avgPrice > 0
        ? ((ltp - position.avgPrice) / position.avgPrice * 100)
        : 0.0;
    final isPos  = pl >= 0;
    final plColor = isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Row 1: title + badge + P/L
          Row(
            children: [
              Expanded(
                child: Text(
                  position.marketTitle.isNotEmpty
                      ? position.marketTitle : position.marketId,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(side: position.side, action: position.action),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${isPos ? '+' : ''}${_fmtVal(pl)}',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: plColor)),
                  Text('${isPos ? '+' : ''}${plPct.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 10, color: plColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: 4 data pills
          Row(
            children: [
              _DataPill(label: 'Shares', value: '${position.shares}'),
              const SizedBox(width: 8),
              _DataPill(label: 'Avg', value: _fmtVal(position.avgPrice)),
              const SizedBox(width: 8),
              _DataPill(label: 'LTP', value: _fmtVal(ltp)),
              const SizedBox(width: 8),
              _DataPill(label: 'Value', value: _fmtVal(cv)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ORDER CARD — mobile card layout
// ─────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final PendingOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: title + badge + status chip
          Row(
            children: [
              Expanded(
                child: AppText(
                  order.marketTitle.isNotEmpty ? order.marketTitle : order.marketId,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(side: order.side, action: order.action),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: AppText(
                  order.status,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: data pills
          Row(
            children: [
              _DataPill(label: 'Filled', value: '${order.filledQty}/${order.shares}'),
              const SizedBox(width: 8),
              _DataPill(label: 'Price', value: _fmtVal(order.price)),
              const SizedBox(width: 8),
              _DataPill(label: 'Fees',  value: _fmtVal(order.fees)),
              const SizedBox(width: 8),
              _DataPill(label: 'Total', value: _fmtVal(order.total)),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: TIF chip + Modify + Cancel
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppText(
                  order.timeInForce,
                  fontSize: 12, color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              _OutlineBtn(label: 'Modify', onTap: () {}),
              const SizedBox(width: 8),
              // ── Cancel button — uses CancelOrderViewModel ──────────
              _CancelButton(order: order),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ACKED':
      case 'OPEN':
        return const Color(0xFF22C55E);
      case 'PARTIALLY_FILLED':
        return const Color(0xFFF59E0B);
      case 'REJECTED':
      case 'CANCELED':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// CANCEL BUTTON — isolated widget so it manages its own VM state
// ─────────────────────────────────────────────────────────────────
class _CancelButton extends StatelessWidget {
  final PendingOrder order;
  const _CancelButton({required this.order});

  Future<void> _onCancel(BuildContext context) async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _CancelConfirmDialog(order: order),
    );

    if (confirmed != true || !context.mounted) return;

    final vm      = context.read<CancelOrderViewModel>();
    final ticker  = context.read<MarketTickerService>();

    final success = await vm.cancelOrder(
      orderId:  order.orderId,
      marketId: order.marketId,
      outcome:  order.side.toUpperCase(), // "YES" or "NO"
    );

    if (!context.mounted) return;

    if (success) {
      // Remove from local list immediately so UI updates
      ticker.removeOrder(order.orderId);

      Utils.snackBar("Order cancelled successfully", context);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Order cancelled successfully'),
      //     backgroundColor: Color(0xFF22C55E),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
      vm.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<CancelOrderViewModel>(
      builder: (context, vm, _) {
        final loading = vm.isLoading;
        return GestureDetector(
          onTap: loading ? null : () => _onCancel(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: loading
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(20),
            ),
            child: loading
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Add this method to MarketTickerService ─────────────────────────
//
// void removeOrder(String orderId) {
//   _pendingOrders.removeWhere((o) => o.orderId == orderId);
//   notifyListeners();
// }

// ─────────────────────────────────────────────────────────────────
// CLOSED TRADE CARD
// ─────────────────────────────────────────────────────────────────
class _ClosedCard extends StatelessWidget {
  final ClosedTrade trade;
  const _ClosedCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isPos  = trade.pnl >= 0;
    final plColor = isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final date   = trade.timestamp != null
        ? '${trade.timestamp!.day}/${trade.timestamp!.month}/${trade.timestamp!.year}'
        : '--';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trade.marketTitle.isNotEmpty ? trade.marketTitle : trade.marketId,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(side: trade.side, action: trade.action),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${isPos ? '+' : ''}${_fmtVal(trade.pnl)}',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: plColor)),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(trade.status,
                        style: const TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DataPill(label: 'Shares', value: '${trade.shares}'),
              const SizedBox(width: 8),
              _DataPill(label: 'Price', value: _fmtVal(trade.price)),
              const SizedBox(width: 8),
              _DataPill(label: 'Date', value: date),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SUMMARY CARD
// ─────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String leftLabel, leftValue, rightLabel, rightValue;
  final double pnl;
  const _SummaryCard({
    required this.leftLabel, required this.leftValue,
    required this.rightLabel, required this.rightValue,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final isPos   = pnl >= 0;
    final plColor = isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(leftLabel,
                fontSize: 12, color: Colors.grey.shade500),
                const SizedBox(height: 6),
                AppText(leftValue,
                  fontSize: 22, fontWeight: FontWeight.w800),
              ],
            ),
          ),
          Container(height: 44, width: 1, color: theme.dividerColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(rightLabel,
                   fontSize: 12, color: Colors.grey.shade500),
                  const SizedBox(height: 6),
                  AppText(rightValue,
                    fontSize: 22, fontWeight: FontWeight.w800),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(isPos ? Icons.trending_up : Icons.trending_down,
                          size: 13, color: plColor),
                      const SizedBox(width: 3),
                      Text('${isPos ? '+' : ''}${_fmtVal(pnl)}',
                          style: TextStyle(
                              fontSize: 11, color: plColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// REUSABLE SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final int    count;
  const _SectionLabel({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(title,
         fontSize: 15, fontWeight: FontWeight.w700),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppText('$count',

                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.surfaceBright),
          ),
        ],
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 28, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

/// Compact label+value pill used in cards
class _DataPill extends StatelessWidget {
  final String label;
  final String value;
  const _DataPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label,
              fontSize: 10, color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
            const SizedBox(height: 2),
            AppText(value,
                fontSize: 12, fontWeight: FontWeight.w600),

          ],
        ),
      ),
    );
  }
}

/// Coloured position badge: BUY.YES / SELL.NO etc.
class _Badge extends StatelessWidget {
  final String side;
  final String action;
  const _Badge({required this.side, required this.action});

  @override
  Widget build(BuildContext context) {
    final label = '${action.toUpperCase()}.${side.toUpperCase()}';
    final isGreen = (action.toUpperCase() == 'BUY' && side.toUpperCase() == 'YES') ||
        (action.toUpperCase() == 'SELL' && side.toUpperCase() == 'NO');
    final color = isGreen ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade600),
        ),
        child: AppText(label,
        fontSize: 12, color: Colors.grey.shade400,
                fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final Color  color;
  final VoidCallback onTap;
  const _FilledBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Formatting ────────────────────────────────────────────────────
String _fmtVal(double v) {
  if (v == 0) return '\$0.00';
  if (v.abs() >= 1000) return '\$${v.toStringAsFixed(2)}';
  if (v.abs() >= 1)    return '\$${v.toStringAsFixed(3)}';
  return '\$${v.toStringAsFixed(3)}';
}

class _CancelConfirmDialog extends StatelessWidget {
  final PendingOrder order;
  const _CancelConfirmDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final heldFunds = order.price * (order.shares - order.filledQty);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Red header ──────────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text('Cancel order',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    order.marketTitle.isNotEmpty
                        ? order.marketTitle : order.marketId,

                        fontSize: 14, fontWeight: FontWeight.w600),

                  const SizedBox(height: 6),
                  Text(
                    'This will cancel your pending order. Any unfilled shares '
                        'will be released and your held funds returned to your '
                        'available balance.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500,
                        height: 1.6),
                  ),
                ],
              ),
            ),

            // ── Order summary rows ───────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _Row(label: 'Shares',
                      value: '${order.filledQty}/${order.shares} unfilled'),
                  const SizedBox(height: 8),
                  _Row(label: 'Limit price',
                      value: '\$${order.price.toStringAsFixed(3)}'),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Funds to release',
                    value: '+\$${heldFunds.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF22C55E),
                  ),
                ],
              ),
            ),

            // ── Buttons ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Keep order',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Yes, cancel',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
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

class _Row extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white)),
      ],
    );
  }
}