import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
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

            const SizedBox(height: 7),


            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                child: QuickCard(
                                  "BTC/USDT",
                                  "LIVE",
                                  logo: 'assets/images/paircoin.png',
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: QuickCard(
                                  "Youtube",
                                  "Hot",
                                  logo: 'assets/images/youtubelogo.png',
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: QuickCard(
                                  "15 M",
                                  "",
                                  logo: 'assets/images/bitcoin.png',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: const [
                              Expanded(
                                child: QuickCard(
                                  "T20 WC",
                                  "",
                                  logo: 'assets/images/circket.png',
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: QuickCard(
                                  "Football",
                                  "",
                                  logo: 'assets/images/game.png',
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: QuickCard(
                                  "Gold",
                                  "",
                                  logo: 'assets/images/gold.png',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GradientContainer(

                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AppText(
                                "For you",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.search, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),


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
                          amount1: "SA₹6.0",
                          amount2: "NZ₹4.0",
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
                          amount1: "SA₹6.0",
                          amount2: "NZ₹4.0",
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




                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0XFFe53a3b),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text("LIVE", style: TextStyle(color: Colors.white)),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              Image.asset(logo, height: 30, fit: BoxFit.contain),

              const SizedBox(width: 8),

              Expanded(
                child: AppText(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (badge.isNotEmpty)
          Positioned(
            top: -6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0XFFe53a3b),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4), // bottom shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title),

          const SizedBox(height: 16),

          Row(
            children: [
              CircleAvatar(radius: 16, backgroundImage: AssetImage(flag1)),

              const SizedBox(width: 8),

              Expanded(child: AppText(team1)),

              AppText("$percent1%"),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              CircleAvatar(radius: 16, backgroundImage: AssetImage(flag2)),

              const SizedBox(width: 8),

              Expanded(child: AppText(team2)),

              AppText("$percent2%"),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(amount1, color: Colors.green),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    amount2,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              /// VOLUME
              AppText(volume, fontSize: 12, color: Colors.grey),

              const Spacer(),

              /// TIMER ICON
              Icon(Icons.access_time, size: 14, color: Colors.grey),

              const SizedBox(width: 4),

              AppText(time, fontSize: 12, color: Colors.grey),

              const SizedBox(width: 10),

              /// FAVORITE ICON
              Icon(Icons.favorite_border, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Row(
            children: [

              Image.asset(
                logo,
                height: 36,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: AppText(
                  title,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// TEAM 1
          Row(
            children: [
              Expanded(child: AppText(team1)),

              AppText(percent1, fontWeight: FontWeight.bold),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.green),
                ),
              ),

              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// TEAM 2
          Row(
            children: [
              Expanded(child: AppText(team2)),

              AppText(percent2, fontWeight: FontWeight.bold),
            ],
          ),

          const SizedBox(height: 12),

          /// FOOTER
          Row(
            children: [
              AppText(
                volume,
                fontSize: 12,
                color: Colors.grey,
              ),

              const Spacer(),

              const Icon(
                Icons.favorite_border,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
