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
                      height: 1.2,
                      color: Colors.grey,
                    )
                  ),

                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.surfaceBright.withOpacity(0.6),
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
              color: theme.primaryColorDark,
              border: Border.all(color: theme.dividerColor)

            ),

            child: Row(
              children: [


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    AppText(
                      "Total Investment",
                      color: Colors.grey,
                    ),

                    SizedBox(height: 6),

                    AppText(
                      "₹0.00",


                        fontSize: 26,
                        fontWeight: FontWeight.bold,

                    ),
                  ],
                ),

                const Spacer(),

                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey,
                ),

                const Spacer(),


                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    AppText(
                      "Current Value",
                      color: Colors.grey,
                    ),

                    SizedBox(height: 6),

                    Row(
                      children: [
                        AppText(
                          "₹0.00",


                            fontSize: 22,
                            fontWeight: FontWeight.bold,

                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_upward,
                            size: 16, color: theme.colorScheme.surfaceBright),
                      ],
                    ),

                    SizedBox(height: 4),

                    AppText(
                      "Returns: +₹0.00",
                      color: Colors.grey,
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
    final theme = Theme.of(context);

    return Column(
      children: [

        /// GRADIENT CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            color: theme.primaryColorDark,
              border: Border.all(color: theme.dividerColor)
            ),

            child: Column(
              children: [

                /// TOP SECTION
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [

                      /// LEFT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          AppText(
                            "Total Investment",
                          color: Colors.grey,
                          ),

                          SizedBox(height: 6),

                          AppText(
                            "₹0.00",
                            fontSize: 26,
                            fontWeight: FontWeight.bold,


                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey,
                      ),

                      const Spacer(),

                      /// RIGHT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           AppText(
                            "Total Returns",
                             color: Colors.grey,
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children:  [
                              AppText(
                                "₹0.00",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,

                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_upward,
                                  size: 16, ),
                            ],
                          ),

                          const SizedBox(height: 4),

                           AppText(
                            "Returns: +₹0.00",
                             color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),

                  child: Row(
                    children:  [


                      AppText(
                        "Today",

                        fontWeight: FontWeight.w600,
                      ),

                      SizedBox(width: 10),

                      AppText(
                        "Investment: ",
                        color: Colors.grey,
                      ),
                      AppText(
                        "₹0.00",

                      ),
                      SizedBox(width: 6),

                      AppText(
                        "•",

                      ),

                      SizedBox(width: 6),

                      AppText(
                        "Returns: ",
                        color: Colors.grey,
                      ),
                      AppText(
                        "₹0.00",

                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 80),

        /// EMPTY STATE
        Center(
          child: AppText(
            "No closed trades found",
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}