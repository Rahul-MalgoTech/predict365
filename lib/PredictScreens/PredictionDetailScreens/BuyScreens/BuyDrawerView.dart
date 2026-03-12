// lib/PredictScreens/BuyScreen/BuyScreen.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

class BuyScreen extends StatefulWidget {
  final SubMarket subMarket;
  final bool      initialIsYes;
  final EventModel event;

  const BuyScreen({
    super.key,
    required this.subMarket,
    required this.initialIsYes,
    required this.event,
  });

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  late bool   isYes;
  bool        isBuy        = true;
  bool        isMarket     = true;
  int         quantity     = 0;
  double      limitPrice   = 0;
  String      expiration   = 'Good Till Cancel';

  final TextEditingController _qtyCtrl   = TextEditingController(text: '0');
  final TextEditingController _priceCtrl = TextEditingController(text: '0');

  static const List<String> _expirationOptions = [
    'Good Till Cancel',
    'Day',
    'One Hour',
    'One Week',
  ];

  @override
  void initState() {
    super.initState();
    isYes = widget.initialIsYes;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _adjustQty(int delta) {
    final newVal = (quantity + delta).clamp(0, 999999);
    setState(() {
      quantity = newVal;
      _qtyCtrl.text = newVal.toString();
      _qtyCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyCtrl.text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeController>().isDarkMode;
    final bg      = Theme.of(context).scaffoldBackgroundColor;
    final card    = Theme.of(context).primaryColorDark;
    final txt     = isDark ? Colors.white : Colors.black87;
    final divC    = Theme.of(context).dividerColor;
    final user    = context.watch<UserViewModel>().user;
    final isOpen  = widget.subMarket.isOpen;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP BAR ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => predictNavigator.backPage(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: divC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 16,
                          color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.subMarket.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: txt,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // OPEN / CLOSED badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isOpen ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: divC, thickness: 1, height: 1),

            // ── SCROLLABLE BODY ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── BUY / SELL  +  MARKET / LIMIT ──
                    Row(
                      children: [
                        _modePill(
                          leftLabel: 'Buy',
                          rightLabel: 'Sell',
                          isLeft: isBuy,
                          onLeft:  () => setState(() => isBuy = true),
                          onRight: () => setState(() => isBuy = false),
                          txt: txt, card: card,
                        ),
                        const SizedBox(width: 10),
                        _modePill(
                          leftLabel: 'Market',
                          rightLabel: 'Limit',
                          isLeft: isMarket,
                          onLeft:  () => setState(() => isMarket = true),
                          onRight: () => setState(() => isMarket = false),
                          txt: txt, card: card,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── YES / NO BUTTONS ──
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isYes = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 52,
                              decoration: BoxDecoration(
                                color: isYes
                                    ? Colors.green
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isYes
                                      ? Colors.green
                                      : Colors.grey.shade600,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.subMarket.side1} -',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isYes
                                      ? Colors.white
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isYes = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: !isYes
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.subMarket.side2} -',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: !isYes
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── SHARES ROW ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Row(children: [
                            Text('Shares',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500)),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                size: 18, color: Colors.grey.shade500),
                          ]),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: divC),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: _qtyCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: txt),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (v) => setState(
                                      () => quantity = int.tryParse(v) ?? 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── QUICK ADJUST CHIPS ──
                    Row(
                      children: [-20, -5, 5, 20].map((delta) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _adjustQty(delta),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: divC),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                delta > 0 ? '+$delta' : '$delta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: txt,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ── LIMIT-ONLY FIELDS ──
                    if (!isMarket) ...[
                      const SizedBox(height: 20),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Price',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: divC),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              child: Row(children: [
                                Text('¢ ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500)),
                                Expanded(
                                  child: TextField(
                                    controller: _priceCtrl,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: txt),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (v) => setState(() =>
                                    limitPrice = double.tryParse(v) ?? 0),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Expiration row
                      Row(
                        children: [
                          Text('Expiration',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                _showExpirationPicker(context, txt, card, divC),
                            child: Row(children: [
                              Text(expiration,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: txt)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Colors.grey.shade500),
                            ]),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── AVAILABLE BALANCE ──
                    Center(
                      child: Text(
                        'Available Balance: ${user?.balanceFormatted ?? '₹0.00'}',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── PLACE ORDER BUTTON (pinned bottom) ───────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF977032), Color(0xFFF5A623)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Expiration picker ─────────────────────────────────────────
  void _showExpirationPicker(
      BuildContext context, Color txt, Color card, Color divC) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Select Expiration',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: txt)),
            const SizedBox(height: 12),
            ..._expirationOptions.map((opt) => GestureDetector(
              onTap: () {
                setState(() => expiration = opt);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: expiration == opt
                      ? const Color(0xFFF5A623).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Text(opt,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: expiration == opt
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: expiration == opt
                              ? const Color(0xFFF5A623)
                              : txt)),
                  const Spacer(),
                  if (expiration == opt)
                    const Icon(Icons.check,
                        size: 18, color: Color(0xFFF5A623)),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Mode pill ─────────────────────────────────────────────────
  Widget _modePill({
    required String leftLabel,
    required String rightLabel,
    required bool isLeft,
    required VoidCallback onLeft,
    required VoidCallback onRight,
    required Color txt,
    required Color card,
  }) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLeft
                        ? const Color(0xFFF5A623)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(leftLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isLeft
                              ? Colors.white
                              : Colors.grey.shade500)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  decoration: BoxDecoration(
                    color: !isLeft
                        ? const Color(0xFFF5A623)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(rightLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: !isLeft
                              ? Colors.white
                              : Colors.grey.shade500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}