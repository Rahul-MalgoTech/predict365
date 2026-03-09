import 'package:flutter/material.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/acc.dart';
import 'package:predict365/chat.dart';
import 'package:predict365/money.dart';
import 'package:predict365/wach.dart';
import 'package:predict365/wachlist.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── PROFILE HEADER ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/myprofile.png"),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("User557234", fontSize: 17, fontWeight: FontWeight.w600),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AppText("ID: 379212", fontSize: 13, color: Colors.grey),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_outlined, size: 15, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 15),
                  ],
                ),
              ),

              // ── BALANCE ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("₹0.00", fontSize: 30, fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    AppText("Available balance", fontSize: 13, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── DEPOSIT CARD ──
              GestureDetector(
                onTap: (){
                  predictNavigator.newPage(context, page: DepositScreen());

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _actionCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Deposit",
                    amount: "₹0.00",
                    buttonText: "Add money",
                    buttonColor: const Color(0xff19a970),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── WINNING CARD ──
              GestureDetector(
                onTap: (){
                  // predictNavigator.newPage(context, page: )
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _actionCard(
                    context,
                    icon: Icons.emoji_events_outlined,
                    title: "Winnings",
                    amount: "₹0.00",
                    buttonText: "Withdraw",
                    buttonColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(context,
                    icon: Icons.person_add_alt_1_outlined,
                    title: "Invite",
                    subtitle: "Invite Friends, Both Get Rewards"),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: (){
                  predictNavigator.newPage(context, page: TransactionScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _menuTile(context,
                      icon: Icons.receipt_long_outlined,
                      title: "Transaction History",
                      subtitle: "For all balance debits & credits"),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: (){
                  predictNavigator.newPage(context, page: WatchlistEmptyScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _menuTile(context,
                      icon: Icons.favorite_border,
                      title: "Watchlist",
                      subtitle: "Your Exclusive Tracking Panel"),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: (){
                  predictNavigator.newPage(context, page: ChatsScreen());

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _menuTile(context,
                      icon: Icons.headset_mic_outlined,
                      title: "Customer Service",
                      subtitle: "Confident Trade, On-Demand Support",
                      badge: "2"),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(context,
                    icon: Icons.help_outline,
                    title: "Help center",
                    subtitle: "Learn about market rules-related information"),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Center(child: AppText("Logout", fontSize: 15)),
                ),
              ),

              const SizedBox(height: 4),

              AppText("Version 1.0.1", fontSize: 12, color: Colors.grey),

              const SizedBox(height: 20),

              // ── FOOTER ──
              Container(
                width: double.infinity,
                color: theme.primaryColorDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("FAQ for Finance & Professionals", fontSize: 13, color: Colors.grey),
                    const SizedBox(height: 16),
                    AppText("Privacy Policy", fontSize: 13, color: Colors.grey),
                    const SizedBox(height: 16),
                    AppText("Data Terms of Service", fontSize: 13, color: Colors.grey),
                    const SizedBox(height: 20),
                    Divider(color: theme.dividerColor),
                    const SizedBox(height: 16),
                    AppText("© 2026 Predict365 Inc.", fontSize: 13, fontWeight: FontWeight.w600),
                    const SizedBox(height: 10),
                    AppText(
                      "Trading on Predict365 involves risk and may not be appropriate for all. "
                          "Members risk losing their cost to enter any transaction, including fees. "
                          "You should carefully consider whether trading on Predik is appropriate "
                          "for you in light of your investment experience and financial resources. "
                          "Any trading decisions you make are solely your responsibility and at "
                          "your own risk. Information is provided for convenience only on an "
                          "\"AS IS\" basis. Past performance is not necessarily indicative of "
                          "future results. Predik is subject to U.S. regulatory oversight by "
                          "the CFTC.",
                      fontSize: 12,
                      color: Colors.grey,
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String amount,
    required String buttonText,
    required Color buttonColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 15),
              const SizedBox(height: 4),
              AppText(amount, fontSize: 13, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppText(buttonText, fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColorDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontSize: 14, fontWeight: FontWeight.w500),
                const SizedBox(height: 4),
                AppText(subtitle, fontSize: 12, color: Colors.grey),
              ],
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: AppText(badge, fontSize: 11, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}