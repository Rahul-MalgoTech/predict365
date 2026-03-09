import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:provider/provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int selectedCategory = 0;
  int selectedTab = 0;
  String selectedFilter = '24h';
  bool profitAscending = false;

  final List<Map<String, String>> leaders = [
    {'rank': '1', 'user': 'User185494', 'profit': '59117.54', 'avatar': 'assets/images/rankingprofile.png'},
    {'rank': '2', 'user': 'User695498', 'profit': '53982.10', 'avatar': 'assets/images/rank2.png'},
    {'rank': '3', 'user': 'User933818', 'profit': '46053.93', 'avatar': 'assets/images/rankingprofile.png'},
    {'rank': '4', 'user': 'User933818', 'profit': '46053.93', 'avatar': 'assets/images/rank2.png'},
  ];

  final List<String> categories = ['Trending', 'Cricket', 'Crypto', 'Politics', 'Sports', 'Entertainment'];
  final List<String> filters = ['24h', '7d', '30d', 'All'];

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
                    height: 20,
                  ),
                  const Spacer(),
                  Container(
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
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final isSelected = selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = i),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: AppText(
                        categories[i],
                        fontSize: 14,
                        color: isSelected
                            ? Theme.of(context).textTheme.labelLarge!.color
                            : Colors.grey,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 10),

            // ── LEADERBOARD / FRIENDS TABS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _tabItem("Leaderboard", 0),
                  const SizedBox(width: 24),
                  _tabItem("Friends (0)", 1),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── MY RANK CARD ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("assets/images/myprofile.png"),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("Short of the list", fontSize: 13),
                        const SizedBox(height: 3),
                        AppText("₹11,878.88", fontSize: 12, color: Colors.grey),
                      ],
                    ),
                    const Spacer(),
                    AppText("₹0.00", fontSize: 14, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── TICKER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    AppText("SPYDER placed ", fontSize: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AppText("Btcusd Up or Down-15 Minute",
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── PROFIT FILTER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => profitAscending = !profitAscending);
                    },
                    child: Row(
                      children: [
                        AppText("Profit", fontSize: 14, fontWeight: FontWeight.w600),
                        Icon(
                          profitAscending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: filters.map((f) {
                        final isSelected = selectedFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => selectedFilter = f),
                          child: isSelected
                              ? GradientContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: AppText(f, fontSize: 12, color: Colors.white),
                          )
                              : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: AppText(f, fontSize: 12, color: Colors.grey),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── LEADER LIST ──
            Expanded(
              child: Builder(
                builder: (context) {
                  final sorted = [...leaders];
                  sorted.sort((a, b) {
                    final pa = double.parse(a['profit']!);
                    final pb = double.parse(b['profit']!);
                    return profitAscending ? pa.compareTo(pb) : pb.compareTo(pa);
                  });
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sorted.length,
                    itemBuilder: (context, i) {
                      final item = sorted[i];
                      final displayRank = (i + 1).toString();
                      return LeaderItem(
                        rank: displayRank,
                        user: item['user']!,
                        profit: "+₹${item['profit']}",
                        avatar: item['avatar']!,
                        badgeNumber: displayRank,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _tabItem(String label, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          AppText(
            label,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? null : Colors.grey,
          ),
          const SizedBox(height: 5),
          if (isSelected)
            Container(
              height: 2,
              width: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF977032), Color(0xFFF5A623)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}
class LeaderItem extends StatelessWidget {
  final String rank;
  final String user;
  final String profit;
  final String avatar;
  final String badgeNumber;

  const LeaderItem({
    super.key,
    required this.rank,
    required this.user,
    required this.profit,
    required this.avatar,
    required this.badgeNumber,
  });

  @override
  Widget build(BuildContext context) {
    Widget rankWidget;
    if (rank == "1") {
      rankWidget = Image.asset("assets/images/goldmedal.png", height: 30);
    } else if (rank == "2") {
      rankWidget = Image.asset("assets/images/silver.png", height: 30);
    } else if (rank == "3") {
      rankWidget = Image.asset("assets/images/bronze.png", height: 30);
    } else {
      rankWidget = AppText(rank, fontSize: 15, fontWeight: FontWeight.w600);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 34, child: Center(child: rankWidget)),
          const SizedBox(width: 14),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(radius: 20, backgroundImage: AssetImage(avatar)),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  height: 17, width: 17,
                  decoration: const BoxDecoration(
                      color: Color(0xff0bc187), shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(user, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(profit,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2fc070)),
              const SizedBox(height: 5),
              Container(
                height: 24, width: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: AppText(badgeNumber, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}