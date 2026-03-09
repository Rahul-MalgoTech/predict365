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

              // ── HEADER ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFc59224), Color(0xFF9b741d), Color(0xFF826219)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ThemeToggleIcon(),
                        const Spacer(),
                        const Text(
                          "Refer & Earn",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Image.asset("assets/images/note.png", height: 18),
                            const SizedBox(width: 5),
                            const Text("Rules",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Invite a Friend and Earn\nLifetime Rewards!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Get a 5% bonus on their first deposit, plus up to 20% commission on every winning.",
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Image.asset("assets/images/referfriend.png", height: 100),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── BONUS CARD ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                      Divider(height: 28, color: theme.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BonusItem("Registration Bonus", "₹0.00"),
                          _BonusItem("Per-Deposit Bonus", "₹0.00"),
                        ],
                      ),
                      Divider(height: 28, color: theme.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _BonusItem("Recharge Bonus", "₹0.00"),
                          _BonusItem("Win Commission", "₹0.00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── INVITE CODE ──
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
                      AppText("My invitation code", fontSize: 14, fontWeight: FontWeight.w600),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText("9FBPOZZI", fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AppText("Copy", fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ReuseElevatedButton(
                        width: double.infinity,
                        gradientColors: const [
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

               SizedBox(height: 16),

              // ── INFO CARDS ──
               _InfoCard(
                title: "First Deposit Bonus",
                desc: "Receive an instant 5% bonus as soon as your referral completes their first recharge.",
              ),
               _InfoCard(
                title: "Recharge Bonus",
                desc: "Earn 5% from your invited friend's recharge (excluding the first deposit). Recharge more, earn more.",
              ),

               SizedBox(height: 16),
               _CommissionBonusCard(),
               SizedBox(height: 16),
               _MilestoneRewardsCard(),
               SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BONUS ITEM ───────────────────────────────────────────────────
class _BonusItem extends StatelessWidget {
  final String title;
  final String value;

  const _BonusItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, fontSize: 12, color: Colors.grey),
        const SizedBox(height: 5),
        AppText(value, fontSize: 14, fontWeight: FontWeight.w600),
      ],
    );
  }
}

// ── INFO CARD ────────────────────────────────────────────────────
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
            AppText(title, fontSize: 14, fontWeight: FontWeight.w600),
            const SizedBox(height: 6),
            AppText(desc, fontSize: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── COMMISSION BONUS CARD ────────────────────────────────────────
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
                AppText("Commission Bonus", fontSize: 14, fontWeight: FontWeight.w600),
                const Spacer(),
                const Icon(Icons.help_outline, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText("Level", fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                AppText("A Level", fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                AppText("B Level", fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                AppText("C Level", fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ],
            ),
            Divider(height: 20, color: theme.dividerColor),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(level, fontSize: 13),
          AppText(a, fontSize: 13),
          AppText(b, fontSize: 13),
          AppText(c, fontSize: 13),
        ],
      ),
    );
  }
}

// ── MILESTONE REWARDS CARD ───────────────────────────────────────
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
                AppText("Milestone Invite Rewards", fontSize: 14, fontWeight: FontWeight.w600),
                const Spacer(),
                const Icon(Icons.help_outline, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              "₹100.00",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.green),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    Image.asset("assets/images/coin.png", height: 28),
                    const SizedBox(height: 4),
                    AppText("₹100.00", fontSize: 10),
                    AppText("0/3", fontSize: 10, color: Colors.grey),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            ReuseElevatedButton(
              width: double.infinity,
              gradientColors: const [
                Color(0xFF985720),
                Color(0xFFB6792E),
                Color(0xFFD3983B),
              ],
              text: 'Start Earning',
            ),
          ],
        ),
      ),
    );
  }
}