import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ReuseElevateButton/ReuseElevateButton.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, // starts at top
                    end: Alignment.bottomCenter,

                    colors: [
                      Color(0XFFc59224),
                      Color(0XFF9b741d),

                      Color(0XFF826219),
                    ],
                  ),
                ),

                padding: EdgeInsets.all(16),

                child: Column(
                  children: [
                    Row(
                      children: [
                        ThemeToggleIcon(),
                        Spacer(),
                        AppText(
                          "Refer & Earn",
                         color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Image.asset("assets/images/note.png"),
                            SizedBox(width: 5),
                            AppText("rules", fontWeight: FontWeight.w600,color: Colors.white,),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// HERO
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                "Invite a Friend and Earn\nLifetime Rewards!"
                                ,color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 10),
                              AppText(
                                "Get a 5% bonus on their first deposit, plus up to 20% commission on every Winning commission.",
                                  color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ],
                          ),
                        ),

                        Image.asset("assets/images/referfriend.png", height: 110),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// BONUS CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: theme.primaryColorDark,
                    border: Border.all(color: theme.dividerColor),
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BonusItem("Total Bonus", "₹0.00"),
                          _BonusItem("Total Referrals", "0"),
                        ],
                      ),

                      Divider(height: 30, color: theme.dividerColor),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BonusItem("Registration Bonus", "₹0.00"),
                          _BonusItem("Per-Deposit Bonus", "₹0.00"),
                        ],
                      ),

                      Divider(height: 30, color: theme.dividerColor),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BonusItem("Recharge Bonus", "₹0.00"),
                          _BonusItem("Win Commission Bonus", "₹0.00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// INVITE CODE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "My invitation code",
                        fontWeight: FontWeight.w600,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText("9FBPOZZI"),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText("Copy"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ReuseElevatedButton(
                        width: double.infinity,
                        gradientColors: [
                          Color(0xFF985720),
                          Color(0xFFB6792E),
                          Color(0xFFD3983B),
                        ],

                        text: 'Share link',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// INFO CARDS
              const _InfoCard(
                title: "First Deposit Bonus",
                desc:
                    "Receive an instant 5% bonus as soon as your referral completes their first recharge",
              ),

              const _InfoCard(
                title: "Recharge Bonus",
                desc:
                    "Earn 5% From your invited Friend's recharge (Excluding the First deposit). Recharge more, earn more.",
              ),

              const SizedBox(height: 16),
              _CommissionBonusCard(),
              const SizedBox(height: 16),
              _MilestoneRewardsCard(),
              const SizedBox(height: 16),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

    );
  }
}

/// BONUS ITEM
class _BonusItem extends StatelessWidget {
  final String title;
  final String value;

  const _BonusItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, fontSize: 12),
        const SizedBox(height: 6),
        AppText(value, fontWeight: FontWeight.w600),
      ],
    );
  }
}

/// INFO CARD
class _InfoCard extends StatelessWidget {
  final String title;
  final String desc;

  const _InfoCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(title, fontWeight: FontWeight.w600),
            const SizedBox(height: 6),
            AppText(desc, fontSize: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CommissionBonusCard extends StatelessWidget {
  const _CommissionBonusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText("Commission Bonus", fontWeight: FontWeight.w600),
                Spacer(),
                Icon(Icons.help_outline, size: 18),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText("Affiliate Level", fontWeight: FontWeight.w600),
                AppText("A Level"),
                AppText("B Level"),
                AppText("C Level"),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(),

            _CommissionRow("Silver", "6.00%", "4.00%", "1.00%"),
            _CommissionRow("Gold", "8.00%", "4.50%", "2.00%"),
            _CommissionRow("Platinum", "12.00%", "5.00%", "3.00%"),
          ],
        ),
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  final String level;
  final String a;
  final String b;
  final String c;

  const _CommissionRow(this.level, this.a, this.b, this.c);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [AppText(level), AppText(a), AppText(b), AppText(c)],
      ),
    );
  }
}

class _MilestoneRewardsCard extends StatelessWidget {
  const _MilestoneRewardsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),

        child: Column(
          children: [
            Row(
              children: [
                AppText(
                  "Milestone Invite Rewards",
                  fontWeight: FontWeight.w600,
                ),
                Spacer(),
                Icon(Icons.help_outline, size: 18),
              ],
            ),

            const SizedBox(height: 16),

            AppText(
              "₹100.00",
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    Image.asset("assets/images/coin.png", height: 30),
                    const SizedBox(height: 4),
                    AppText("₹100.00", fontSize: 10),
                    AppText("0/3", fontSize: 10, color: Colors.grey),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReuseElevatedButton(
                width: double.infinity,
                gradientColors: [
                  Color(0xFF985720),
                  Color(0xFFB6792E),
                  Color(0xFFD3983B),
                ],

                text: 'Start Earning',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
