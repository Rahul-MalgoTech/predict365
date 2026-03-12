import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:provider/provider.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int topTab = 0;
  int subTab = 0;
  int selectedAmount = 500;
  int selectedMethod = 0;

  final List<Map<String, dynamic>> amounts = [
    {'value': 200, 'bonus': null},
    {'value': 500, 'bonus': '+3%'},
    {'value': 1000, 'bonus': '+3%'},
    {'value': 5000, 'bonus': null},
  ];

  final List<Map<String, String>> methods = [
    {'name': 'Best UPI', 'range': '₹200.00-₹500.00'},
    {'name': 'Fast UPI 2', 'range': '₹200.00-₹3,000.00'},
    {'name': 'YYPay 200 - 10000', 'range': '₹200.00-₹10,000.00'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color, size: 22),
                  ),
                  const SizedBox(width: 45),
                  SizedBox(
                    width: 190,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Theme.of(context).primaryColorDark : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _topToggle(context, isDark, 'Deposit', 0),
                          _topToggle(context, isDark, 'Withdraw', 1),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ThemeToggleIcon(),
                ],
              ),
            ),

            // ── SUB TABS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _subTab(context, 'Deposit', 0),
                  const SizedBox(width: 48),
                  _subTab(context, 'Crypto', 1),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),

            // ── CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    AppText(
                      'Deposit Amount',
                fontSize: 16, color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '₹ ${_formatAmount(selectedAmount)}',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),

                    AppText(
                      'Extra +₹15.00',

                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,

                    ),
                    const SizedBox(height: 20),

                    // Amount chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: amounts.map((a) {
                        final isSelected = selectedAmount == a['value'];
                        return GestureDetector(
                          onTap: () => setState(() => selectedAmount = a['value']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.transparent : (isDark ? Theme.of(context).primaryColorDark : Colors.grey[200]),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.green : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                                      width: isSelected ? 1 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    '₹${a['value']}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? Colors.green : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ),
                                if (a['bonus'] != null)
                                  Positioned(
                                    top: -8,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        a['bonus'],
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Bonus banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFE08A)),
                      ),
                      child: Row(
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 20, color: Colors.red)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                                children: [
                                  TextSpan(text: 'Complete your first deposit and get a ',
                                    style: TextStyle( fontSize: 14),

                                  ),
                                  TextSpan(
                                    text: '3% bonus.',
                                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment methods
                    ...methods.asMap().entries.map((e) {
                      final idx = e.key;
                      final m = e.value;
                      final isSelected = selectedMethod == idx;
                      return GestureDetector(
                        onTap: () => setState(() => selectedMethod = idx),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? Theme.of(context).primaryColorDark : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'UPI\nLogo',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      m['name']!,

                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black,

                                    ),
                                    const SizedBox(height: 3),
                                    AppText(
                                      m['range']!,
                                      fontSize: 14, color: Colors.grey.shade500,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── CONTINUE BUTTON ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
              child: ReuseElevatedButton(
                onTap: (){},

                text: "Continue",gradientColors: [
                Color(0xFF977032), Color(0xFFF5A623),

              ],)
          ),
        ),
      ),
    );
  }

  Widget _topToggle(BuildContext context, bool isDark, String label, int idx) {
    final isActive = topTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => topTab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? (isDark ? Colors.black : Colors.white) : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _subTab(BuildContext context, String label, int idx) {
    final isActive = subTab == idx;
    return GestureDetector(
      onTap: () => setState(() => subTab = idx),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AppText(
              label,

                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Theme.of(context).textTheme.labelLarge!.color : Colors.grey,

            ),
          ),
          if (isActive)
            Container(
              height: 2,
              width: 60,
              color: Theme.of(context).textTheme.labelLarge!.color,
            ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)},000.00';
    }
    return '$amount.00';
  }
}