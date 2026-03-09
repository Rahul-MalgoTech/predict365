import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:provider/provider.dart';

class WatchlistEmptyScreen extends StatelessWidget {
  const WatchlistEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final txt    = isDark ? Colors.white : Colors.black87;
    final sub    = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final div    = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ──
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: div, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: txt, size: 22),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: txt,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            // ── Empty state ──
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: 28,
                        color: sub,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No Events followed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: sub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}