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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: AppText("My Portfolio", fontSize: 20, fontWeight: FontWeight.w700),
              ),

              Stack(
                children: [
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(height: 1, color: theme.dividerColor),
                  ),
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.surfaceBright.withValues(alpha: 0.8),
                          width: 2,
                        ),
                      ),
                    ),
                    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    labelColor: theme.colorScheme.surfaceBright,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Active Trades"),
                      Tab(text: "Closed Trades"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.primaryColorDark,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("Total Investment", fontSize: 14, color: Colors.grey),
                    const SizedBox(height: 6),
                    AppText("₹0.00", fontSize: 24, fontWeight: FontWeight.bold),
                  ],
                ),
                const Spacer(),
                Container(height: 40, width: 1, color: theme.dividerColor),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("Current Value", fontSize: 14, color: Colors.grey),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        AppText("₹0.00", fontSize: 20, fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_upward, size: 15,
                            color: theme.colorScheme.surfaceBright),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText("Returns: +₹0.00", fontSize: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              GradientContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: AppText("Matched Orders",
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: theme.primaryColorDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText("Unmatched Orders",
                    color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),

        AppText("No positions found", fontSize: 15, color: Colors.grey),
      ],
    );
  }

  Widget _closedTrades(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: theme.primaryColorDark,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText("Total Investment", fontSize: 13, color: Colors.grey),
                          const SizedBox(height: 6),
                          AppText("₹0.00", fontSize: 24, fontWeight: FontWeight.bold),
                        ],
                      ),
                      const Spacer(),
                      Container(height: 40, width: 1, color: theme.dividerColor),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText("Total Returns", fontSize: 13, color: Colors.grey),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              AppText("₹0.00", fontSize: 20, fontWeight: FontWeight.bold),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_upward, size: 15),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AppText("Returns: +₹0.00", fontSize: 12, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      AppText("Today", fontSize: 13, fontWeight: FontWeight.w600),
                      const SizedBox(width: 8),
                      AppText("Investment: ", fontSize: 13, color: Colors.grey),
                      AppText("₹0.00", fontSize: 13),
                      const SizedBox(width: 6),
                      AppText("•", fontSize: 13, color: Colors.grey),
                      const SizedBox(width: 6),
                      AppText("Returns: ", fontSize: 13, color: Colors.grey),
                      AppText("₹0.00", fontSize: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 60),

        AppText("No closed trades found", fontSize: 15, color: Colors.grey),
      ],
    );
  }
}