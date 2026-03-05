import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:provider/provider.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          AppText("₹0.00", fontWeight: FontWeight.w600),
                          const SizedBox(width: 10),
                          GradientContainer(
                            child: const Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  ThemeToggleIcon(),
                  const SizedBox(width: 10),
                  const Icon(Icons.notifications_none),
                  const SizedBox(width: 10),

                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage("assets/images/myprofile.png"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 30,
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

            const SizedBox(height: 7),

            Divider(color: Theme.of(context).dividerColor, thickness: 2),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Column(
                    children: [
                      AppText(
                        "Leaderboard",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),

                      const SizedBox(height: 6),

                      Container(
                        height: 2,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 20),
                  Column(
                    children: [
                      AppText("Friends (0)", color: Colors.grey),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        "assets/images/myprofile.png",
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("Short of the list"),
                        AppText("₹11,878.88", color: Colors.grey),
                      ],
                    ),

                    const Spacer(),

                    AppText("₹0.00", fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        AppText(
                          "SPYDER placed ",
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ],
                    ),
                    SizedBox(width: 6),
                    AppText(
                      "Btcusd Up or Down-15 Minute",
                      fontWeight: FontWeight.w600,

                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppText("Profit", fontWeight: FontWeight.w600),

                  const Icon(Icons.keyboard_arrow_down),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        FilterItem("24h", true),
                        FilterItem("7d", false),
                        FilterItem("30d", false),
                        FilterItem("All", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  LeaderItem(
                    rank: "1",
                    user: "User185494",
                    profit: "+₹59,117.54",
                    avatar: "assets/images/rankingprofile.png",
                    badgeNumber: "1",
                  ),

                  SizedBox(height: 18),

                  LeaderItem(
                    rank: "2",
                    user: "User695498",
                    profit: "+₹53,982.10",
                    avatar: "assets/images/rank2.png",
                    badgeNumber: "2",
                  ),

                  SizedBox(height: 18),

                  LeaderItem(
                    rank: "3",
                    user: "User933818",
                    profit: "+₹46,053.93",
                    avatar: "assets/images/rankingprofile.png",
                    badgeNumber: "2",
                  ),

                  SizedBox(height: 18),

                  LeaderItem(
                    rank: "4",
                    user: "User933818",
                    profit: "+₹46,053.93",
                    avatar: "assets/images/rank2.png",
                    badgeNumber: "4",
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

class CategoryItem extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryItem(this.title, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppText(
        title,

        color: selected
            ? Theme.of(context).textTheme.labelLarge!.color
            : Colors.grey,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class FilterItem extends StatelessWidget {
  final String text;
  final bool selected;

  const FilterItem(this.text, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return selected
        ? GradientContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: AppText(text, fontSize: 12),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AppText(text, fontSize: 12),
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
      rankWidget = Image.asset("assets/images/goldmedal.png", height: 32);
    } else if (rank == "2") {
      rankWidget = Image.asset("assets/images/silver.png", height: 32);
    } else if (rank == "3") {
      rankWidget = Image.asset("assets/images/bronze.png", height: 32);
    } else {
      rankWidget = AppText(rank, fontSize: 16, fontWeight: FontWeight.w600);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(width: 36, child: Center(child: rankWidget)),

          const SizedBox(width: 15),

          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(radius: 20, backgroundImage: AssetImage(avatar)),

              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xff0bc187),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: AppText(user, fontSize: 16, fontWeight: FontWeight.w500),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                profit,
                color: const Color(0XFF2fc070),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),

              const SizedBox(height: 6),

              Container(
                height: 26,
                width: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  shape: BoxShape.circle,
                ),
                child: AppText(badgeNumber, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
