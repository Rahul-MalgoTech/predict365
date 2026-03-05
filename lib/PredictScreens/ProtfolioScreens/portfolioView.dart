import 'package:flutter/material.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

               Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppText(
                  "My Portfolio",
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),

                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.surfaceBright,
                          width: 2,
                        ),
                      ),
                    ),
                    labelColor: theme.colorScheme.surfaceBright,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Active Trades"),
                      Tab(text: "Closed Trades"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: TabBarView(
                  children: [

                    _activeTrades(context),

                    _closedTrades(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _activeTrades(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.primaryColorDark
            ),

            child: Row(
              children: [


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    AppText(
                      "Total Investment",
                      color: Colors.white70,
                    ),

                    SizedBox(height: 6),

                    AppText(
                      "₹0.00",

                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,

                    ),
                  ],
                ),

                const Spacer(),

                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white70,
                ),

                const Spacer(),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    AppText(
                      "Current Value",
               color: Colors.white70,
                    ),

                    SizedBox(height: 6),

                    Row(
                      children: [
                        AppText(
                          "₹0.00",

                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,

                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_upward,
                            size: 16, color: Colors.white),
                      ],
                    ),

                    SizedBox(height: 4),

                    AppText(
                      "Returns: +₹0.00",
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [

              GradientContainer(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),


                child:  AppText(
                  "Matched Orders",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                decoration: BoxDecoration(
                  color: theme.primaryColorDark,
                  borderRadius: BorderRadius.circular(12),
                ),

                child:  AppText(
                  "Unmatched Orders",
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),


         Center(
          child: AppText(
            "No positions found",

              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,

          ),
        ),
      ],
    );
  }


  Widget _closedTrades(BuildContext context) {
    return  Center(
      child: AppText(
        "No closed trades",
    fontSize: 16,
      ),
    );
  }
}