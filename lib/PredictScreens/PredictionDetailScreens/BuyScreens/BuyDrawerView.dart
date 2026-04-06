// lib/PredictScreens/PredictionDetailScreens/BuyScreens/BuyBottomSheet.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Models/OrderBookModel.dart';
import 'package:predict365/Models/OrderModel.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Predict_Utils/ColorHandlers/AppColors.dart';
import 'package:predict365/Predict_Utils/CustomSnackBar/StatusMessage.dart';
import 'package:predict365/Repository/OrderRepository.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

// ── Gold gradient ──────────────────────────────────────────────
const _goldGrad = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF985720), Color(0xFFB6792E), Color(0xFFD3983B)],
);

const Map<String, String> _tifApiValues = {
  'Good Till Cancel': 'GTC',
  'Day': 'DAY',
  'One Hour': 'IOC',
  'One Week': 'GTW',
};

String _makeClientOrderId() {
  final ts  = DateTime.now().millisecondsSinceEpoch;
  final hex = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return 'cid-$ts-$hex';
}

// ── Entry point — call this from Yes/No button taps ────────────
void showBuySheet(
    BuildContext context, {
      required SubMarket subMarket,
      required EventModel event,
      required bool initialIsYes,
      double? initialPrice,       // cents, from order book row tap
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BuySheet(
      subMarket:    subMarket,
      event:        event,
      initialIsYes: initialIsYes,
      initialPrice: initialPrice,
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// SHEET WIDGET
// ══════════════════════════════════════════════════════════════
class _BuySheet extends StatefulWidget {
  final SubMarket  subMarket;
  final EventModel event;
  final bool       initialIsYes;
  final double?    initialPrice;

  const _BuySheet({
    required this.subMarket,
    required this.event,
    required this.initialIsYes,
    required this.initialPrice,
  });

  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  // ── state ──────────────────────────────────────────────────
  late bool   isYes;
  bool        isBuy      = true;
  bool        isMarket   = true;
  int         quantity   = 0;
  double      limitPrice = 0;
  bool        _expirationEnabled = false;
  String      expiration = 'Good Till Cancel';
  bool        _placing   = false;

  final _qtyCtrl   = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController(text: '0');

  static const List<String> _expirationOptions = [
    'Good Till Cancel', 'Day', 'One Hour', 'One Week',
  ];

  @override
  void initState() {
    super.initState();
    isYes = widget.initialIsYes;
    if (widget.initialPrice != null && widget.initialPrice! > 0) {
      isMarket        = false;
      limitPrice      = widget.initialPrice!;
      _priceCtrl.text = widget.initialPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── computed values ────────────────────────────────────────
  double get _total    => isMarket ? 0 : (limitPrice / 100) * quantity;
  double get _toWin    => isMarket ? 0 : quantity * (1 - limitPrice / 100);

  void _adjustQty(int delta) {
    final v = (quantity + delta).clamp(0, 999999);
    setState(() {
      quantity      = v;
      _qtyCtrl.text = v.toString();
      _qtyCtrl.selection =
          TextSelection.fromPosition(TextPosition(offset: _qtyCtrl.text.length));
    });
  }

  void _adjustPrice(int delta) {
    final v = (limitPrice + delta).clamp(1.0, 99.0);
    setState(() {
      limitPrice      = v;
      _priceCtrl.text = v.toStringAsFixed(0);
    });
  }

  Future<void> _placeOrder() async {
    if (quantity <= 0) {
      _showSnack('Please enter a valid number of shares.', isError: true);
      return;
    }
    if (!isMarket && (limitPrice <= 0 || limitPrice > 99)) {
      _showSnack('Price must be between 1¢ and 99¢.', isError: true);
      return;
    }
    setState(() => _placing = true);

    final request = OrderRequest(
      clientOrderId: _makeClientOrderId(),
      marketId:      widget.subMarket.id,
      side:          isBuy  ? 'BUY'  : 'SELL',
      outcome:       isYes  ? 'YES'  : 'NO',
      orderType:     isMarket ? 'MARKET' : 'LIMIT',
      price:         isMarket ? 0.5 : (limitPrice / 100).clamp(0.01, 0.99),
      shares:        quantity.toString(),
      timeInForce:   _tifApiValues[expiration] ?? 'GTC',
    );

    try {
      final response = await OrderRepository().placeOrder(request);
      if (!mounted) return;
      if (response.success) {
        FocusScope.of(context).unfocus();
        Navigator.pop(context);
        Utils.snackBar('Order placed! Status: ${response.order?.status ?? 'ACKED'}',context);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text(
        //     'Order placed! Status: ${response.order?.status ?? 'ACKED'}',
        //     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        //   ),
        //   backgroundColor: Colors.green.shade700,
        //   behavior: SnackBarBehavior.floating,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //   duration: const Duration(seconds: 2),
        // ));
      } else {
        _showSnack(
          response.message.isNotEmpty ? response.message : 'Failed to place order.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(_friendlyError(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    isError?Utils.snackBarErrorMessage(msg,context):Utils.snackBar(msg,context);
  }

  String _friendlyError(String e) {
    if (e.contains('401')) return 'Session expired. Please login again.';
    if (e.contains('403')) return 'Access denied.';
    if (e.contains('400')) return 'Invalid order details.';
    if (e.contains('500')) return 'Server error. Please try again.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final card   = Theme.of(context).primaryColorDark;
    final bg     = Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99);
    final txt    = isDark ? Colors.white : Colors.black87;
    final divC   = Theme.of(context).dividerColor;
    final user   = context.watch<UserViewModel>().user;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── drag handle ───────────────────────────────────────
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── TOP BAR: Buy↓  |  Market⇄ / Limit⇄ ──────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              // Buy / Sell dropdown
              GestureDetector(
                onTap: () => setState(() => isBuy = !isBuy),
                child: Row(children: [
                  Text(isBuy ? 'Buy' : 'Sell',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: txt)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 22, color: txt),
                ]),
              ),
              const Spacer(),
              // Market / Limit toggle
              GestureDetector(
                onTap: () => setState(() => isMarket = !isMarket),
                child: Row(children: [
                  Text(isMarket ? 'Market' : 'Limit',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400)),
                  const SizedBox(width: 4),
                  Icon(Icons.swap_horiz, size: 18, color: Colors.grey.shade400),
                ]),
              ),
            ]),
          ),

          Divider(color: divC, height: 1, thickness: 1),

          // ── Event info row ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.event.eventImage.isNotEmpty
                    ? Image.network(widget.event.eventImage,
                    width: 38, height: 38, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgFallback(card))
                    : _imgFallback(card),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.event.eventTitle,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: txt),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(children: [
                      Expanded(
                        child: Text(widget.subMarket.name,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      // Yes / No pill
                      GestureDetector(
                        onTap: () => setState(() => isYes = !isYes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isYes
                                ? AppColors().greenButton.withValues(alpha: 0.15)
                                : AppColors().redButton.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isYes
                                  ? AppColors().greenButton.withValues(alpha: 0.5)
                                  : AppColors().redButton.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(isYes ? widget.subMarket.side1 : widget.subMarket.side2,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: isYes
                                        ? AppColors().greenButton
                                        : AppColors().redButton)),
                            const SizedBox(width: 4),
                            Icon(Icons.swap_horiz, size: 14,
                                color: isYes
                                    ? AppColors().greenButton
                                    : AppColors().redButton),
                          ]),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // ══════════════════════════════════════════════════════
          // MARKET MODE
          // ══════════════════════════════════════════════════════
          if (isMarket) ...[
            // Big amount display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // minus button
                  GestureDetector(
                    onTap: () => _adjustQty(-1),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: divC),
                      ),
                      child: Icon(Icons.remove, color: txt, size: 20),
                    ),
                  ),

                  // amount field
                  Expanded(
                    child: Center(
                      child: IntrinsicWidth(
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade500),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            prefixText: '₹',
                            prefixStyle: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF888888)),
                          ),
                          onChanged: (v) =>
                              setState(() => quantity = int.tryParse(v) ?? 0),
                        ),
                      ),
                    ),
                  ),

                  // plus button
                  GestureDetector(
                    onTap: () => _adjustQty(1),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: divC),
                      ),
                      child: Icon(Icons.add, color: txt, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick chips: +1 +5 +10 +100 Max
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [1, 5, 10, 100].map((v) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _adjustQty(v),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: divC),
                        ),
                        alignment: Alignment.center,
                        child: Text('+₹$v',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: txt)),
                      ),
                    ),
                  );
                }).followedBy([
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final bal = context.read<UserViewModel>().user?.wallet ?? 0;
                        setState(() {
                          quantity      = bal.toInt();
                          _qtyCtrl.text = quantity.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: divC),
                        ),
                        alignment: Alignment.center,
                        child: Text('Max',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: txt)),
                      ),
                    ),
                  ),
                ]).toList(),
              ),
            ),
          ],

          // ══════════════════════════════════════════════════════
          // LIMIT MODE
          // ══════════════════════════════════════════════════════
          if (!isMarket) ...[
            // Limit Price row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Limit Price',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: txt)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: divC),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    // minus
                    GestureDetector(
                      onTap: () => _adjustPrice(-1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Icon(Icons.remove, size: 18, color: txt),
                      ),
                    ),
                    // price display
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _priceCtrl,
                        keyboardType:  TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: txt),
                        decoration:  InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          suffixText: '¢',
                          suffixStyle: TextStyle(color: Theme.of(context).iconTheme.color)
                        ),
                        onChanged: (v) =>
                            setState(() => limitPrice = double.tryParse(v) ?? 0),
                      ),
                    ),
                    // plus
                    GestureDetector(
                      onTap: () => _adjustPrice(1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Icon(Icons.add, size: 18, color: txt),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Shares row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Shares',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: txt)),
                const Spacer(),
                Container(
                  width: 160,
                  height: 48,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: divC),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: txt),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(

                        vertical: 14,
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => quantity = int.tryParse(v) ?? 0),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Quick chips: -100 -10 +10 +100 +20
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [-100, -10, 10, 100, 20].map((d) {
                  return GestureDetector(
                    onTap: () => _adjustQty(d),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: divC),
                      ),
                      child: Text(d > 0 ? '+$d' : '$d',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: txt)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Set expiration toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Set expiration',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: txt)),
                const Spacer(),
                Switch(
                  value: _expirationEnabled,
                  onChanged: (v) => setState(() => _expirationEnabled = v),
                  activeColor: const Color(0xFFD3983B),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Theme.of(context).dividerColor,
                ),
              ]),
            ),

            // Expiration picker (visible only when toggle is on)
            if (_expirationEnabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: GestureDetector(
                  onTap: () => _showExpirationPicker(context, txt, card, divC),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: divC),
                    ),
                    child: Row(children: [
                      Text(expiration,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: txt)),
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.grey.shade500),
                    ]),
                  ),
                ),
              ),

            Divider(color: divC, height: 1),
            const SizedBox(height: 12),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Total',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500, color: txt)),
                const Spacer(),
                Text('₹${_total.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors().greenButton)),
              ]),
            ),
            const SizedBox(height: 10),

            // To win
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Row(children: [
                  Text('To win',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: txt)),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline,
                      size: 15, color: Colors.grey.shade500),
                ]),
                const Spacer(),
                Text('₹${_toWin.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors().greenButton)),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // ── Available balance ─────────────────────────────────
          Text(
            'Available: ${user?.balanceFormatted ?? '₹0.00'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),

          // ── Trade button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _goldGrad,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _placing
                      ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text('Trade',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback(Color card) => Container(
    width: 38, height: 38,
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(Icons.event, color: Colors.grey.shade400, size: 18),
  );

  void _showExpirationPicker(
      BuildContext ctx, Color txt, Color card, Color divC) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text('Select Expiration',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
            const SizedBox(height: 12),
            ..._expirationOptions.map((opt) {
              final sel = expiration == opt;
              return GestureDetector(
                onTap: () {
                  setState(() => expiration = opt);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFF5A623).withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Text(opt,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? const Color(0xFFF5A623) : txt)),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check,
                          size: 18, color: Color(0xFFF5A623)),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}