import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:provider/provider.dart';

// ── BUY DRAWER FUNCTION ──────────────────────────────────────────
void showBuyDrawer(
    BuildContext context, {
      required String team,
      required bool isYes,
      required String yesLabel,
      required String yesOdds,
      required String noLabel,
      required String noOdds,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => BuyDrawer(
        team: team,
        initialIsYes: isYes,
        yesLabel: yesLabel,
        yesOdds: yesOdds,
        noLabel: noLabel,
        noOdds: noOdds,
        scrollController: scrollController,
      ),
    ),
  );
}

// ── BUY DRAWER WIDGET ────────────────────────────────────────────
class BuyDrawer extends StatefulWidget {
  final String team;
  final bool initialIsYes;
  final String yesLabel;
  final String yesOdds;
  final String noLabel;
  final String noOdds;
  final ScrollController scrollController;

  const BuyDrawer({
    super.key,
    required this.team,
    required this.initialIsYes,
    required this.yesLabel,
    required this.yesOdds,
    required this.noLabel,
    required this.noOdds,
    required this.scrollController,
  });

  @override
  State<BuyDrawer> createState() => _BuyDrawerState();
}

class _BuyDrawerState extends State<BuyDrawer> {
  late bool isYes;
  double price = 6.0;
  int quantity = 526;
  bool setExpiration = false;
  bool orderBookExpanded = true;
  bool qtyToggle = true;

  final List<Map<String, dynamic>> hkOrders = [
    {'price': '₹6.5', 'qty': '19,074', 'isHighlight': true},
    {'price': '₹7.0', 'qty': '271',    'isHighlight': false},
    {'price': '₹7.5', 'qty': '150',    'isHighlight': false},
    {'price': '₹8.0', 'qty': '280',    'isHighlight': false},
    {'price': '₹8.5', 'qty': '5',      'isHighlight': false},
  ];

  final List<Map<String, dynamic>> kuwOrders = [
    {'price': '₹4.0', 'qty': '435'},
    {'price': '₹4.5', 'qty': '11,376'},
    {'price': '₹5.0', 'qty': '234'},
    {'price': '₹5.5', 'qty': '200'},
    {'price': '₹6.0', 'qty': '210'},
  ];

  @override
  void initState() {
    super.initState();
    isYes = widget.initialIsYes;
  }

  double get invested => price * quantity;
  double get winnings => quantity * 10.0;

  String _fmtAmt(double v) {
    final parts = v.toStringAsFixed(1).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}.$decPart';
  }

  Widget _sqBtn(IconData icon, Color fg, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: fg),
    ),
  );

  Widget _toggle(bool val, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 46, height: 26,
      decoration: BoxDecoration(
        color: val ? Colors.green : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: val ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22, height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final sw = MediaQuery.of(context).size.width;
    final hp = sw * 0.045;

    final bottomPad = MediaQuery.of(context).padding.bottom;

    final bg   = Theme.of(context).scaffoldBackgroundColor;
    final card = Theme.of(context).primaryColorDark;
    final txt  = isDark ? Colors.white : Colors.black87;
    final sub  = Colors.grey.shade500;
    final divC = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 38, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(hp, 10, hp, 0),
              children: [

                // "Buy"  ×
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Buy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: txt)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: sub, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // HK / KUW pill toggle
                Container(
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _pillBtn(
                        label: 'HK  ₹${price.toStringAsFixed(1)}',
                        active: isYes,
                        activeBg: Colors.green.withValues(alpha: 0.15),
                        activeFg: Colors.green,
                        inactiveFg: Colors.grey,
                        onTap: () => setState(() => isYes = true),
                      ),
                      _pillBtn(
                        label: 'KUW  ₹${(10 - price).toStringAsFixed(1)}',
                        active: !isYes,
                        activeBg: Colors.red.withValues(alpha: 0.15),
                        activeFg: Colors.red,
                        inactiveFg: Colors.grey,
                        onTap: () => setState(() => isYes = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // PRICE + QTY card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Edit price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Edit price', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('₹${price.toStringAsFixed(1)}', style: TextStyle(fontSize: 13, color: txt)),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // [-] slider [+]
                      Row(
                        children: [
                          _sqBtn(Icons.remove, txt, () => setState(() => price = (price - 0.5).clamp(1.0, 9.5))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.green,
                                inactiveTrackColor: Colors.green.withValues(alpha: 0.18),
                                thumbColor: Colors.green,
                                overlayColor: Colors.green.withValues(alpha: 0.08),
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              ),
                              child: Slider(
                                value: price, min: 1.0, max: 9.5,
                                onChanged: (v) => setState(() => price = v),
                              ),
                            ),
                          ),
                          _sqBtn(Icons.add, txt, () => setState(() => price = (price + 0.5).clamp(1.0, 9.5))),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Row(children: [
                            Text('$quantity', style: TextStyle(fontSize: 13, color: txt)),
                            const SizedBox(width: 5),
                            Icon(Icons.edit, size: sw * 0.055, color: Colors.green),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // [-] toggle [+]
                      Row(
                        children: [
                          _sqBtn(Icons.remove, txt, () => setState(() => quantity = (quantity - 1).clamp(1, 99999))),
                          const SizedBox(width: 10),
                          _toggle(qtyToggle, () => setState(() => qtyToggle = !qtyToggle)),
                          const SizedBox(width: 10),
                          _sqBtn(Icons.add, txt, () => setState(() => quantity = (quantity + 1).clamp(1, 99999))),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Joined Qty / Available Qty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Joined Qty: $quantity', style: TextStyle(fontSize: 14, color: sub)),
                          Text('Available Qty : 0', style: TextStyle(fontSize: 14, color: sub)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick chip row +20 +50 +100 +500 +1000
                      Row(
                        children: [20, 50, 100, 500, 1000].map((q) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => quantity += q),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.white,
                                  border: Border.all(color: divC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(child: Text('+$q', style: TextStyle(fontSize: 14, color: txt))),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Set expiration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Set expiration', style: TextStyle(fontSize: 15, color: txt)),
                          _toggle(setExpiration, () => setState(() => setExpiration = !setExpiration)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Invested | Winnings
                      Container(
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: divC))),
                        padding: const EdgeInsets.only(top: 12),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Invested', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('₹${_fmtAmt(invested)}',
                                        style: TextStyle(fontSize: 14, color: txt)),
                                  ],
                                ),
                              ),
                              VerticalDivider(width: 1, thickness: 1, color: divC),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Winnings', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('₹${_fmtAmt(winnings)}',
                                        style: TextStyle(fontSize: 14, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ORDER BOOK
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: divC),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Text('Order Book', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: txt)),
                            const SizedBox(width: 5),
                            Icon(Icons.help_outline, size: sw * 0.055, color: sub),
                            const Spacer(),
                            Icon(Icons.refresh, size: sw * 0.063, color: sub),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => orderBookExpanded = !orderBookExpanded),
                              child: Icon(
                                orderBookExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                size: sw * 0.07, color: sub,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (orderBookExpanded) ...[
                        Divider(height: 1, thickness: 1, color: divC),
                        _obRow(
                          isDark: isDark, isHeader: true,
                          p1: 'Price',   q1: 'Qty at HK',
                          p2: 'Price',   q2: 'Qty at KUW',
                          p1Color: sub,  q1Color: sub,
                          p2Color: sub,  q2Color: sub,
                          rowBg: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          divColor: divC, txt: txt, sw: sw,
                        ),
                        ...List.generate(hkOrders.length, (i) {
                          final hk  = hkOrders[i];
                          final kuw = kuwOrders[i];
                          final hl  = hk['isHighlight'] as bool;
                          return Column(children: [
                            Divider(height: 1, thickness: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                            _obRow(
                              isDark: isDark, isHeader: false,
                              p1: hk['price'],  q1: hk['qty'],
                              p2: kuw['price'], q2: kuw['qty'],
                              p1Color: hl ? Colors.green : txt,
                              q1Color: txt,
                              p2Color: txt,
                              q2Color: Colors.red,
                              p1Bg: hl ? Colors.green.withValues(alpha: 0.13) : null,
                              p1Bold: hl,
                              rowBg: Colors.transparent,
                              divColor: divC, txt: txt, sw: sw,
                            ),
                          ]);
                        }),
                        const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── FIXED BOTTOM: Deposit button + balance ──
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(hp, 12, hp, bottomPad + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Deposit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available Balance: ₹0.00',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillBtn({
    required String label,
    required bool active,
    required Color activeBg,
    required Color activeFg,
    required Color inactiveFg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? activeFg : inactiveFg,
                )),
          ),
        ),
      ),
    );
  }

  Widget _obRow({
    required bool isDark,
    required bool isHeader,
    required String p1, required String q1,
    required String p2, required String q2,
    required Color p1Color, required Color q1Color,
    required Color p2Color, required Color q2Color,
    Color? p1Bg,
    bool p1Bold = false,
    Color? rowBg,
    required Color divColor,
    required Color txt,
    required double sw,
  }) {
    final fs = isHeader ? 11.0 : 12.0;
    final fw = isHeader ? FontWeight.w600 : FontWeight.w400;
    const vPad = 8.0;
    const hPad = 8.0;

    return Container(
      color: rowBg,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(children: [
                Expanded(
                  child: Container(
                    color: p1Bg,
                    padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    child: Text(p1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: fs,
                            fontWeight: p1Bold ? FontWeight.w700 : fw,
                            color: p1Color)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    child: Text(q1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fs, fontWeight: fw, color: q1Color)),
                  ),
                ),
              ]),
            ),
            Container(width: 1, color: divColor),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    child: Text(p2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fs, fontWeight: fw, color: p2Color)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    child: Text(q2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fs, fontWeight: fw, color: q2Color)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PREDIK DETAIL SCREEN ─────────────────────────────────────────
class PredikDetailScreen extends StatefulWidget {
  const PredikDetailScreen({super.key});

  @override
  State<PredikDetailScreen> createState() => _PredikDetailScreenState();
}

class _PredikDetailScreenState extends State<PredikDetailScreen> {
  String selectedTimeRange = 'ALL';
  int selectedTabIndex = 0;
  int _selectedCategory = 0;
  bool aboutExpanded = true;
  bool rulesExpanded = true;

  final List<String> timeRanges = ['1H', '6H', '1D', '1W', '1M', 'ALL'];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isDark),
            _buildTrendingBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVolumeRow(context),
                    _buildQuestionCard(context),
                    _buildTimeRangeSelector(context),
                    _buildBettingOptions(context),
                    _buildOtherOptions(context),
                    _buildAboutSection(context),
                    _buildRulesSection(context),
                    _buildActivitySection(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
      child: Row(
        children: [
          Image.asset(
            isDark ? "assets/images/predictlogowhite.png" : "assets/images/predictlogo.png",
            height: sw * 0.05,
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.015, vertical: sw * 0.01),
              child: Row(
                children: [
                  AppText("₹0.00", fontWeight: FontWeight.w600),
                  SizedBox(width: sw * 0.025),
                  GradientContainer(
                    child: Padding(
                      padding: EdgeInsets.all(sw * 0.012),
                      child: Icon(Icons.add, size: sw * 0.045, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: sw * 0.025),
          ThemeToggleIcon(),
          SizedBox(width: sw * 0.025),
          Icon(Icons.notifications_none, size: sw * 0.06),
          SizedBox(width: sw * 0.025),
          CircleAvatar(
            radius: sw * 0.04,
            backgroundImage: const AssetImage("assets/images/myprofile.png"),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingBar(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final tabs = ['Trending', 'Cricket', 'Crypto', 'Politics', 'Sports', 'Enter'];
    return Container(
      height: sw * 0.09,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Padding(
              padding: EdgeInsets.only(right: sw * 0.04),
              child: Center(
                child: AppText(
                  tabs[index],
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).textTheme.labelLarge!.color : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVolumeRow(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText('₹2.36 C Vol', fontSize: 15, fontWeight: FontWeight.w500),
          Icon(Icons.favorite_border, size: sw * 0.05, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: sw * 0.12, height: sw * 0.12,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/circket.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: AppText(
                  'Who will win the T20 World Cup 2026?',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: sw * 0.03),
          Row(
            children: [
              _buildLegendItem(const Color(0xFF00A86B), 'India', '55%', sw),
              SizedBox(width: sw * 0.03),
              _buildLegendItem(const Color(0xFF00BCD4), 'New Zealand', '40%', sw),
              SizedBox(width: sw * 0.03),
              _buildLegendItem(const Color(0xFF9C27B0), 'England', '25%', sw),
            ],
          ),
          SizedBox(height: sw * 0.03),
          Container(
            width: double.infinity,
            height: sw * 0.38,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/grafs.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percent, double sw) {
    return Row(
      children: [
        Container(
          width: sw * 0.025, height: sw * 0.025,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: sw * 0.01),
        AppText('$label $percent', fontSize: 14),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
      child: Row(
        children: [
          ...timeRanges.map((range) {
            final isSelected = selectedTimeRange == range;
            return GestureDetector(
              onTap: () => setState(() => selectedTimeRange = range),
              child: Container(
                margin: EdgeInsets.only(right: sw * 0.03),
                padding: EdgeInsets.symmetric(horizontal: sw * 0.015, vertical: sw * 0.008),
                decoration: isSelected
                    ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).textTheme.labelLarge!.color!,
                      width: 2,
                    ),
                  ),
                )
                    : null,
                child: AppText(
                  range,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? null : Colors.grey,
                ),
              ),
            );
          }),
          const Spacer(),
          Icon(Icons.tune, size: sw * 0.045, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildBettingOptions(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Column(
        children: [
          _buildBetRow(context, 'India', '55%', 'Yes', '₹5.5', 'No', '₹4.5'),
          SizedBox(height: sw * 0.03),
          _buildBetRow(context, 'New Zealand', '40%', 'Yes', '₹4.0', 'No', '₹6.0'),
          SizedBox(height: sw * 0.03),
          _buildBetRow(context, 'England', '25%', 'Yes', '₹2.5', 'No', '₹7.5'),
        ],
      ),
    );
  }

  Widget _buildBetRow(BuildContext context, String team, String percent,
      String yesLabel, String yesOdds, String noLabel, String noOdds) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(team, fontSize: 15, fontWeight: FontWeight.w600),
            AppText(percent, fontSize: 15, fontWeight: FontWeight.w600),
          ],
        ),
        SizedBox(height: sw * 0.015),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => showBuyDrawer(context,
                  team: team, isYes: true,
                  yesLabel: yesLabel, yesOdds: yesOdds,
                  noLabel: noLabel, noOdds: noOdds,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: AppText('$yesLabel $yesOdds', color: Colors.green, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: GestureDetector(
                onTap: () => showBuyDrawer(context,
                  team: team, isYes: false,
                  yesLabel: yesLabel, yesOdds: yesOdds,
                  noLabel: noLabel, noOdds: noOdds,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: sw * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: AppText('$noLabel $noOdds', color: Colors.red, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherOptions(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.07, height: sw * 0.07,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset('assets/images/circket.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: AppText('Who will win the T20 World Cup 2026?', fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: sw * 0.025),
          _buildSimpleOptionRow('Australia', '5%', sw),
          Divider(height: sw * 0.04, color: Theme.of(context).dividerColor),
          _buildSimpleOptionRow('South Africa', '5%', sw),
        ],
      ),
    );
  }

  Widget _buildSimpleOptionRow(String team, String percent, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(team, fontSize: 15),
          AppText(percent, fontSize: 15, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => aboutExpanded = !aboutExpanded),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('About', fontSize: 15, fontWeight: FontWeight.bold),
                Icon(aboutExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (aboutExpanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: Column(
              children: [
                _buildAboutRow(Icons.bar_chart, 'Volume', '₹23620413.5', sw),
                SizedBox(height: sw * 0.025),
                _buildAboutRow(Icons.access_time, 'End Date', 'Mar 09,2026', sw),
                SizedBox(height: sw * 0.025),
                _buildAboutRow(Icons.access_time_outlined, 'Created At', 'Feb 06,2026, 12:34 PM GMT+5', sw),
                SizedBox(height: sw * 0.025),
              ],
            ),
          ),
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value, double sw) {
    return Row(
      children: [
        Icon(icon, size: sw * 0.045, color: Colors.green),
        SizedBox(width: sw * 0.025),
        AppText(label, fontSize: 15, color: Colors.grey),
        const Spacer(),
        AppText(value, fontSize: 15, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => rulesExpanded = !rulesExpanded),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Rules', fontSize: 15, fontWeight: FontWeight.bold),
                Icon(rulesExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (rulesExpanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
            child: AppText(
              'The event will be settled after the tournament ends.\nThe event will settle on the winning team from the\n above mentioned teams',
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          child: Row(
            children: ['Activity', 'Holders', 'Comments'].mapIndexed((idx, tab) {
              final isSelected = selectedTabIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => selectedTabIndex = idx),
                child: Container(
                  margin: EdgeInsets.only(right: sw * 0.05),
                  padding: EdgeInsets.only(bottom: sw * 0.02),
                  decoration: isSelected
                      ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).textTheme.labelLarge!.color!,
                        width: 2,
                      ),
                    ),
                  )
                      : null,
                  child: AppText(
                    tab,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? null : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        SizedBox(height: sw * 0.02),
        if (selectedTabIndex == 0) _buildActivityTab(context),
        if (selectedTabIndex == 1) _buildHoldersTab(context),
        if (selectedTabIndex == 2) _buildCommentsTab(context),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.015),
          child: Row(children: [
            _buildFilterChip(context, 'ALL'),
            SizedBox(width: sw * 0.03),
            _buildFilterChip(context, 'Min Amount'),
          ]),
        ),
        SizedBox(height: sw * 0.02),
        _buildActivityItem('Sold Yes: England', '2 shares (₹5.00)', '3m'),
        Divider(indent: 16, endIndent: 16, height: 1, color: Theme.of(context).dividerColor),
        _buildActivityItem('Sold Yes: England', '2 shares (₹5.00)', '3m'),
      ],
    );
  }

  Widget _buildHoldersTab(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final yesHolders = [
      {'name': 'User755622', 'shares': '13,900 shares'},
      {'name': 'Thorfinn', 'shares': '2,000 shares'},
      {'name': 'KK Bhai', 'shares': '685 shares'},
      {'name': 'User589265', 'shares': '586 shares'},
      {'name': 'Amit Kumar 23', 'shares': '555 shares'},
      {'name': 'Shyam', 'shares': '460 shares'},
      {'name': 'User000110', 'shares': '383 shares'},
      {'name': 'User853136', 'shares': '379 shares'},
    ];
    final noHolders = [
      {'name': 'No fear', 'shares': '16,075 shares'},
      {'name': 'User145921', 'shares': '2,872 shares'},
      {'name': 'User387361', 'shares': '2,450 shares'},
      {'name': 'User716300', 'shares': '2,100 shares'},
      {'name': 'Jaybhole29', 'shares': '805 shares'},
      {'name': 'User931129', 'shares': '786 shares'},
      {'name': 'User247896', 'shares': '625 shares'},
      {'name': 'User048981', 'shares': '536 shares'},
    ];

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.02),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AppText('India', fontSize: 16),
              SizedBox(width: sw * 0.015),
              Icon(Icons.keyboard_arrow_down, size: sw * 0.04, color: Colors.grey.shade500),
            ]),
          ),
        ),
        SizedBox(height: sw * 0.03),
        Padding(
          padding: EdgeInsets.only(left: sw * 0.200),
          child: Row(children: [
            Expanded(child: AppText('Yes holders', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            Expanded(child: AppText('No holders', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
          ]),
        ),
        SizedBox(height: sw * 0.025),
        Padding(
          padding: EdgeInsets.only(left: sw * 0.10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: yesHolders.asMap().entries
                      .map((e) => _buildHolderItem(context, rank: e.key + 1, name: e.value['name']!, shares: e.value['shares']!, isYes: true))
                      .toList(),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  children: noHolders.asMap().entries
                      .map((e) => _buildHolderItem(context, rank: e.key + 1, name: e.value['name']!, shares: e.value['shares']!, isYes: false))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sw * 0.04),
      ],
    );
  }

  Widget _buildHolderItem(BuildContext context, {required int rank, required String name, required String shares, required bool isYes}) {
    final sw = MediaQuery.of(context).size.width;
    final color = isYes ? Colors.green : Colors.red;
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.035),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: sw * 0.050,
                backgroundColor: Theme.of(context).primaryColorDark,
                child: Icon(Icons.person, size: sw * 0.045, color: Colors.grey.shade500),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: sw * 0.046, height: sw * 0.046,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$rank', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(name, fontSize: 16, fontWeight: FontWeight.w600),
                AppText(shares, fontSize: 14, color: color, fontWeight: FontWeight.w500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final comments = [
      {'user': 'No fear', 'position': 'No', 'team': 'India', 'isYes': false, 'text': 'Buy yes india win', 'time': '1d', 'bgColor': 0xFF1a1a2e},
      {'user': 'User925016', 'position': 'No Position', 'team': 'Nezland', 'isYes': null, 'text': 'Nezland', 'time': '2d', 'bgColor': 0xFFe67e22},
      {'user': 'User606151', 'position': 'Yes', 'team': 'India', 'isYes': true, 'text': 'Yes india', 'time': '2d', 'bgColor': 0xFF3498db},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(sw * 0.03),
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: sw * 0.025, bottom: sw * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppText('800 left', fontSize: 14, color: Colors.grey),
                      SizedBox(width: sw * 0.03),
                      GradientContainer(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.045, vertical: sw * 0.018),
                          child: AppText('Post', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: sw * 0.01),
        ...comments.map((c) => _buildCommentItem(context, c)),
        SizedBox(height: sw * 0.05),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, Map<String, dynamic> comment) {
    final sw = MediaQuery.of(context).size.width;
    final isYes = comment['isYes'];
    final position = comment['position'] as String;
    final team = comment['team'] as String;
    final bgColor = Color(comment['bgColor'] as int);

    Color chipColor;
    Color chipTextColor;
    if (isYes == true) {
      chipColor = Colors.green.withValues(alpha: 0.15);
      chipTextColor = Colors.green;
    } else if (isYes == false) {
      chipColor = Colors.red.withValues(alpha: 0.15);
      chipTextColor = Colors.red;
    } else {
      chipColor = Colors.grey.withValues(alpha: 0.15);
      chipTextColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.095, height: sw * 0.095,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: AppText(
                (comment['user'] as String).substring(0, 2).toUpperCase(),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  AppText(comment['user'] as String, fontSize: 15, fontWeight: FontWeight.w600),
                  const Spacer(),
                  AppText(comment['time'] as String, fontSize: 14, color: Colors.grey),
                ]),
                SizedBox(height: sw * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.008),
                  decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(4)),
                  child: AppText('$position · $team', fontSize: 14, color: chipTextColor, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: sw * 0.015),
                AppText(comment['text'] as String, fontSize: 15),
                SizedBox(height: sw * 0.02),
                Row(children: [
                  Icon(Icons.chat_bubble_outline, size: sw * 0.04, color: Colors.grey.shade500),
                  SizedBox(width: sw * 0.04),
                  Icon(Icons.favorite_border, size: sw * 0.04, color: Colors.grey.shade500),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.013),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        AppText(label, fontSize: 14),
        SizedBox(width: sw * 0.01),
        Icon(Icons.keyboard_arrow_down, size: sw * 0.035, color: Colors.grey.shade500),
      ]),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time) {
    return Builder(builder: (context) {
      final sw = MediaQuery.of(context).size.width;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppText(title, fontSize: 15, fontWeight: FontWeight.w500),
              SizedBox(height: sw * 0.005),
              AppText(subtitle, fontSize: 14, color: Colors.grey),
            ]),
            AppText(time, fontSize: 14, color: Colors.grey),
          ],
        ),
      );
    });
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}