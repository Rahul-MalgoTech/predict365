import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/graf.dart';
import 'package:predict365/market.dart';
import 'package:predict365/money.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Image.asset(
                    isDark
                        ? "assets/images/predictlogowhite.png"
                        : "assets/images/predictlogo.png",
                    height: 22,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: (){
                      predictNavigator.newPage(context, page: DepositScreen());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: Row(
                        children: [
                          AppText("₹0.00", fontSize: 13, fontWeight: FontWeight.w600),
                          const SizedBox(width: 8),
                          GradientContainer(
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.add, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ThemeToggleIcon(),
                  const SizedBox(width: 10),
                  Icon(Icons.notifications_none,
                      color: Theme.of(context).iconTheme.color, size: 22),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/images/myprofile.png"),
                  ),
                ],
              ),
            ),

            // ── CATEGORY TABS ──
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  CategoryItem("Trending", true),
                  CategoryItem("Cricket", false),
                  CategoryItem("Crypto", false),
                  CategoryItem("Politics", false),
                  CategoryItem("Sports", false),
                  CategoryItem("Entertainment", false),
                ],
              ),
            ),

            const SizedBox(height: 4),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 6),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // Quick Cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(child: QuickCard("BTC/USDT", "LIVE", logo: 'assets/images/paircoin.png')),
                              SizedBox(width: 8),
                              Expanded(child: QuickCard("Youtube", "Hot", logo: 'assets/images/youtubelogo.png')),
                              SizedBox(width: 8),
                              Expanded(child: QuickCard("15 M", "", logo: 'assets/images/bitcoin.png')),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(child: QuickCard("T20 WC", "", logo: 'assets/images/circket.png')),
                              SizedBox(width: 8),
                              Expanded(child: QuickCard("Football", "", logo: 'assets/images/game.png')),
                              SizedBox(width: 8),
                              Expanded(child: QuickCard("Gold", "", logo: 'assets/images/gold.png')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // For You header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GradientContainer(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: AppText("For you", fontSize: 13,
                                  fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Icon(Icons.search, size: 20,
                                color: Theme.of(context).iconTheme.color),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Prediction Cards
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: const [
                        PredictionCard(
                          title: "SA vs NZ",
                          team1: "South Africa",
                          team2: "New Zealand",
                          percent1: 60,
                          percent2: 40,
                          amount1: "SA ₹6.0",
                          amount2: "NZ ₹4.0",
                          flag1: 'assets/images/africa.png',
                          flag2: 'assets/images/zealand.png',
                          volume: "₹82.34 L Vol",
                          time: "6h 58m 3s",
                        ),
                        SizedBox(height: 12),
                        PredictionCard(
                          title: "IND vs ENG",
                          team1: "India",
                          team2: "England",
                          percent1: 70,
                          percent2: 30,
                          amount1: "IND ₹7.0",
                          amount2: "ENG ₹3.0",
                          flag1: 'assets/images/india.png',
                          flag2: 'assets/images/england.png',
                          volume: "₹18.41 L Vol",
                          time: "3h 12m 10s",
                        ),
                        SizedBox(height: 12),
                        PredictionCardType2(
                          title: "Who will win the T20 World Cup 2026?",
                          logo: "assets/images/circket.png",
                          team1: "India",
                          team2: "Australia",
                          percent1: "50%",
                          percent2: "5%",
                          volume: "₹2.09 C Vol",
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── LIVE FAB ──
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFe53a3b),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFe53a3b).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: Colors.white),
            SizedBox(width: 5),
            Text("LIVE",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── CATEGORY ITEM ────────────────────────────────────────────────
class CategoryItem extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryItem(this.title, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            title,
            fontSize: 14,
            color: selected
                ? Theme.of(context).textTheme.labelLarge!.color
                : Colors.grey.shade500,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
          if (selected) ...[
            const SizedBox(height: 3),
            Container(
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF977032), Color(0xFFF5A623)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── QUICK CARD ───────────────────────────────────────────────────
class QuickCard extends StatelessWidget {
  final String title;
  final String badge;
  final String logo;

  const QuickCard(this.title, this.badge, {super.key, required this.logo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Image.asset(logo, height: 26, fit: BoxFit.contain),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(title, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -7,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFe53a3b),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

// ── PREDICTION CARD ──────────────────────────────────────────────
class PredictionCard extends StatelessWidget {
  final String title;
  final String team1;
  final String team2;
  final int percent1;
  final int percent2;
  final String amount1;
  final String amount2;
  final String flag1;
  final String flag2;
  final String volume;
  final String time;

  const PredictionCard({
    super.key,
    required this.title,
    required this.team1,
    required this.team2,
    required this.percent1,
    required this.percent2,
    required this.amount1,
    required this.amount2,
    required this.flag1,
    required this.flag2,
    required this.volume,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        predictNavigator.newPage(context, page: MatchScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(title, fontSize: 15, fontWeight: FontWeight.w700),
            const SizedBox(height: 14),

            // Team 1
            Row(
              children: [
                CircleAvatar(radius: 15, backgroundImage: AssetImage(flag1)),
                const SizedBox(width: 10),
                Expanded(child: AppText(team1, fontSize: 14)),
                AppText("$percent1%", fontSize: 14, fontWeight: FontWeight.w600),
              ],
            ),
            const SizedBox(height: 6),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent1 / 100,
                minHeight: 4,
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 10),

            // Team 2
            Row(
              children: [
                CircleAvatar(radius: 15, backgroundImage: AssetImage(flag2)),
                const SizedBox(width: 10),
                Expanded(child: AppText(team2, fontSize: 14)),
                AppText("$percent2%", fontSize: 14, fontWeight: FontWeight.w600),
              ],
            ),
            const SizedBox(height: 14),

            // Bet buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3), width: 1),
                    ),
                    child: AppText(amount1,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Text(amount2,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(Icons.bar_chart, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                AppText(volume, fontSize: 12, color: Colors.grey),
                const Spacer(),
                const Icon(Icons.access_time, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                AppText(time, fontSize: 12, color: Colors.grey),
                const SizedBox(width: 12),
                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── PREDICTION CARD TYPE 2 ───────────────────────────────────────
class PredictionCardType2 extends StatelessWidget {
  final String title;
  final String logo;
  final String team1;
  final String team2;
  final String percent1;
  final String percent2;
  final String volume;

  const PredictionCardType2({
    super.key,
    required this.title,
    required this.logo,
    required this.team1,
    required this.team2,
    required this.percent1,
    required this.percent2,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        predictNavigator.newPage(context, page: PredikDetailScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(logo, height: 34, width: 34, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppText(title, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Team 1
            Row(
              children: [
                Expanded(child: AppText(team1, fontSize: 14)),
                AppText(percent1,
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.green),
                const SizedBox(width: 10),
                _betBtn("Yes", Colors.green),
                const SizedBox(width: 6),
                _betBtn("No", Colors.red),
              ],
            ),
            const SizedBox(height: 10),

            // Team 2
            Row(
              children: [
                Expanded(child: AppText(team2, fontSize: 14)),
                AppText(percent2, fontSize: 14, fontWeight: FontWeight.w700),
              ],
            ),
            const SizedBox(height: 14),

            // Footer
            Row(
              children: [
                Icon(Icons.bar_chart, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                AppText(volume, fontSize: 12, color: Colors.grey),
                const Spacer(),
                const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _betBtn(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}