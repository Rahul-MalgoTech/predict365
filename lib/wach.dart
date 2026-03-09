import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:provider/provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final List<Map<String, dynamic>> _events = [
    {
      'flag': 'assets/images/india.png',
      'title': 'Will Assam legislative Assembly election polling ?',
      'percent': '60%',
      'yesLabel': 'SA',
      'yesOdds': '₹6.0',
      'noLabel': 'NZ',
      'noOdds': '₹4.0',
      'vol': '₹82.34L Vol',
      'isLive': true,
      'isFav': true,
    },
    {
      'flag': 'assets/images/india.png',
      'title': 'Will Assam legislative Assembly election polling ?',
      'percent': '60%',
      'yesLabel': 'SA',
      'yesOdds': '₹6.0',
      'noLabel': 'NZ',
      'noOdds': '₹4.0',
      'vol': '₹82.34L Vol',
      'isLive': false,
      'isFav': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final sw     = MediaQuery.of(context).size.width;
    final bg     = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final txt    = isDark ? Colors.white : Colors.black87;
    final div    = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Container(
              color: bg,
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
                          fontWeight: FontWeight.w500,
                          color: txt,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.06),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: div),

            // ── Cards list ──
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04,
                  vertical: sw * 0.04,
                ),
                itemCount: _events.length,
                separatorBuilder: (_, __) => SizedBox(height: sw * 0.04),
                itemBuilder: (context, i) => _EventCard(
                  event: _events[i],
                  sw: sw,
                  isDark: isDark,
                  onFavToggle: () => setState(() {
                    _events[i]['isFav'] = !(_events[i]['isFav'] as bool);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event Card ───────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final double sw;
  final bool isDark;
  final VoidCallback onFavToggle;

  const _EventCard({
    required this.event,
    required this.sw,
    required this.isDark,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final txt    = isDark ? Colors.white : Colors.black87;
    final sub    = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final div    = isDark ? Colors.grey.shade700 : Colors.grey.shade200;
    final isLive = event['isLive'] as bool;
    final isFav  = event['isFav'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: div),
      ),
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── flag + title + percent ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.asset(
                  event['flag'] as String,
                  width: sw * 0.1,
                  height: sw * 0.1,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: sw * 0.1, height: sw * 0.1,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flag, size: sw * 0.05, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Text(
                  event['title'] as String,
                  style: TextStyle(
                    fontSize: sw * 0.037,
                    fontWeight: FontWeight.w600,
                    color: txt,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              Text(
                event['percent'] as String,
                style: TextStyle(
                  fontSize: sw * 0.037,
                  fontWeight: FontWeight.w600,
                  color: txt,
                ),
              ),
            ],
          ),

          SizedBox(height: sw * 0.035),

          // ── SA | NZ buttons ──
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.028),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${event['yesLabel']}${event['yesOdds']}',
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: sw * 0.028),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${event['noLabel']}${event['noOdds']}',
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sw * 0.03),

          // ── LIVE badge + vol + heart ──
          Row(
            children: [
              if (isLive) ...[
                Icon(Icons.podcasts, size: sw * 0.04, color: Colors.red),
                SizedBox(width: sw * 0.015),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: sw * 0.02),
              ],
              Text(
                event['vol'] as String,
                style: TextStyle(fontSize: sw * 0.03, color: sub),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onFavToggle,
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: sw * 0.055,
                  color: isFav ? Colors.red : sub,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}