import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

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

              /// PROFILE HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 30,
                      backgroundImage:
                      AssetImage("assets/images/myprofile.png"),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         AppText(
                          "User557234",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children:  [
                            AppText(
                              "ID:379212",
                              color: Colors.grey,
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.copy, size: 16, color: Colors.grey),
                          ],
                        )
                      ],
                    ),

                    const Spacer(),

                    const Icon(Icons.arrow_forward_ios, size: 16)
                  ],
                ),
              ),

              /// BALANCE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [

                    AppText(
                      "₹0.00",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),

                    SizedBox(height: 4),

                    AppText(
                      "Available balance",
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DEPOSIT CARD
              Padding(
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

              const SizedBox(height: 12),

              /// WINNING CARD
              Padding(
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

              const SizedBox(height: 12),

              /// INVITE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(
                  context,
                  icon: Icons.person_add_alt_1_outlined,
                  title: "Invite",
                  subtitle: "Invite Friends,Both Get Rewards",
                ),
              ),

              const SizedBox(height: 10),

              /// TRANSACTION HISTORY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: "Transaction History",
                  subtitle: "For all balance debits & credits",
                ),
              ),

              const SizedBox(height: 10),

              /// WATCHLIST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(
                  context,
                  icon: Icons.favorite_border,
                  title: "Watchlist",
                  subtitle: "Your Exclusive Tracking Panel",
                ),
              ),

              const SizedBox(height: 10),

              /// CUSTOMER SERVICE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(
                  context,
                  icon: Icons.headset_mic_outlined,
                  title: "Customer Service",
                  subtitle: "Confident Trade,On-Demand Support",
                  badge: "2",
                ),
              ),

              const SizedBox(height: 10),

              /// HELP CENTER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _menuTile(
                  context,
                  icon: Icons.help_outline,
                  title: "Help center",
                  subtitle: "Learn about market rules-related information",
                ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: AppText("Logout")),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// VERSION
              AppText(
                "Version 1.0.1",
                color: Colors.grey,
              ),

              const SizedBox(height: 20),

              /// INFO SECTION
              Container(
                width: double.infinity,
                color: Theme.of(context).primaryColorDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// LINKS
                    AppText(
                      "FAQ for Finance&Professionals",
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    AppText(
                      "Privacy Policy",
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    AppText(
                      "Data Terms of Service",
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 20),

                    Divider(color: Theme.of(context).dividerColor),

                    const SizedBox(height: 16),

                    /// COPYRIGHT
                     AppText(
                      "© 2026Predict365 Inc.",
                      fontWeight: FontWeight.w600,
                    ),

                    const SizedBox(height: 10),

                    /// DISCLAIMER TEXT
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

  /// ACTION CARD (Deposit / Winnings)
  Widget _actionCard(
      BuildContext context, {
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

          Icon(icon, size: 26),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 16),
              const SizedBox(height: 4),
              AppText(amount, color: Colors.grey),
            ],
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppText(
              buttonText,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  /// MENU TILE
  Widget _menuTile(
      BuildContext context, {
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

          Icon(icon, size: 24),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontWeight: FontWeight.w500),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          if (badge != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: AppText(
                badge,
                color: Colors.white,
                fontSize: 12,
              ),
            ),

          const SizedBox(width: 10),

          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}