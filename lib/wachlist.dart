import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:provider/provider.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.rule,               'label': 'Market Rules'},
    {'icon': Icons.airline_stops,      'label': 'Market Outcomes'},
    {'icon': Icons.book_outlined,        'label': 'The Orderbook'},
    {'icon': Icons.wb_sunny_outlined,  'label': 'How are prices determined?'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final sw     = MediaQuery.of(context).size.width;
    final bg     = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final txt    = isDark ? Colors.white : Colors.black87;
    final sub    = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final div    = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top bar: back arrow + title ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sw * 0.035,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: txt, size: sw * 0.06),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: sw * 0.045,
                          fontWeight: FontWeight.w600,
                          color: txt,
                        ),
                      ),
                    ),
                  ),
                  // placeholder to balance the back arrow
                  SizedBox(width: sw * 0.06),
                ],
              ),
            ),

            // ── "Markets" green label ──
            Padding(
              padding: EdgeInsets.only(left: sw * 0.045, top: sw * 0.04),
              child: Row(
                children: [
                  // green bar icon (three horizontal lines)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (_) => Container(
                      width: sw * 0.045,
                      height: sw * 0.008,
                      margin: EdgeInsets.only(bottom: sw * 0.006),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Markets',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // ── "Markets 101" heading with chart icon ──
            Padding(
              padding: EdgeInsets.only(
                left: sw * 0.04,
                top: sw * 0.02,
                bottom: sw * 0.04,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bar-chart icon (three bars: medium, small, large)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(sw, 0.055),
                      SizedBox(width: sw * 0.008),
                      _bar(sw, 0.035),
                      SizedBox(width: sw * 0.008),
                      _bar(sw, 0.065),
                    ],
                  ),
                  SizedBox(width: sw * 0.025),
                  Text(
                    'Markets 101',
                    style: TextStyle(
                      fontSize: sw * 0.07,
                      fontWeight: FontWeight.w800,
                      color: txt,
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu items list ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                child: Column(
                  children: _items.map((item) {
                    final isLast = _items.last == item;
                    return Column(
                      children: [
                        _MenuItem(
                          icon: item['icon'] as IconData,
                          label: item['label'] as String,
                          sw: sw,
                          isDark: isDark,
                          txt: txt,
                          sub: sub,
                        ),
                        if (!isLast)
                          Divider(height: 1, thickness: 1, color: div),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double sw, double heightFactor) => Container(
    width: sw * 0.028,
    height: sw * heightFactor,
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw;
  final bool isDark;
  final Color txt;
  final Color sub;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sw,
    required this.isDark,
    required this.txt,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sw * 0.045),
        child: Row(
          children: [
            Icon(icon, size: sw * 0.055, color: txt),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.w500,
                  color: txt,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: sw * 0.055, color: sub),
          ],
        ),
      ),
    );
  }
}