// lib/PredictScreens/ProfileScreens/ProfileView.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/PredictScreens/ChatScreens/ChatView.dart';
import 'package:predict365/PredictScreens/DepositWithdrawScreen/DepositWithdrawScreen.dart';
import 'package:predict365/PredictScreens/LoginScreens/LoginView.dart';
import 'package:predict365/PredictScreens/ProfileScreens/EditProfileView.dart';
import 'package:predict365/PredictScreens/TransactionScreens/TransactionView.dart';
import 'package:predict365/PredictScreens/WatchListScreens/watchlistView.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final bool nav;
  const ProfileScreen({super.key, required this.nav});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _LogoutDialog(),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFF5A623)),
      ),
    );

    try {
      await AuthStorage.instance.clearSession();
      context.read<UserViewModel>().clearUser();
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('User ID copied!'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF977032),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<UserViewModel>(
          builder: (context, userVm, _) {
            final user = userVm.user;

            // ── Friendly values from API ──
            final displayName   = user?.displayName   ?? 'Loading...';
            final userId        = user?.id             ?? '---';
            final shortId       = userId.length > 8 ? userId.substring(userId.length - 8) : userId;
            final balance       = user?.balanceFormatted ?? '₹0.00';
            final walletAmt     = user != null ? '₹${user.wallet.toStringAsFixed(2)}'    : '₹0.00';
            final availableAmt  = user != null ? '₹${user.available.toStringAsFixed(2)}' : '₹0.00';
            final profileImage  = user?.profileImage;

            return SingleChildScrollView(
              child: Column(
                children: [

                  // ── PROFILE HEADER ──
                  GestureDetector(
                    onTap: () => predictNavigator.newPage(context, page: EditProfileScreen()),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          widget.nav == true?GestureDetector(
                            onTap: (){
                              predictNavigator.backPage(context);
                            },

                              child: Container(

                                decoration: BoxDecoration(color: theme.primaryColorDark,
                                borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.dividerColor),
                                ),

                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0,top: 6,bottom: 6),
                                    child: Icon(Icons.arrow_back_ios),
                                  ))):SizedBox(),
                          SizedBox(width: 10,),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                ? NetworkImage(profileImage) as ImageProvider
                                : const AssetImage("assets/images/myprofile.png"),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(displayName,
                                  fontSize: 17, fontWeight: FontWeight.w600),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  _copyId(shortId);
                                },
                                child: Row(
                                  children: [
                                    AppText("ID: $shortId",
                                        fontSize: 13, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.copy_outlined,
                                        size: 15, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 15),
                        ],
                      ),
                    ),
                  ),

                  // ── BALANCE ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userVm.isLoading
                            ? Container(
                          width: 120, height: 34,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                            : AppText(balance,
                            fontSize: 30, fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        AppText("Available balance",
                            fontSize: 13, color: Colors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── DEPOSIT ──
                  GestureDetector(
                    onTap: () => predictNavigator.newPage(context, page: DepositScreen()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _actionCard(context,
                          icon: Icons.account_balance_wallet_outlined,
                          title: "Deposit",
                          amount: walletAmt,
                          buttonText: "Add money",
                          buttonColor: const Color(0xff19a970),
                          isGradient: true),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── WINNINGS ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _actionCard(context,
                        icon: Icons.emoji_events_outlined,
                        title: "Winnings",
                        amount: availableAmt,
                        buttonText: "Withdraw",
                        buttonColor: Colors.black,
                        isGradient: false),
                  ),

                  const SizedBox(height: 12),

                  // ── MENU TILES ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _menuTile(context,
                        icon: Icons.person_add_alt_1_outlined,
                        title: "Invite",
                        subtitle: "Invite Friends, Both Get Rewards"),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => predictNavigator.newPage(
                        context, page: TransactionScreen()),
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
                    onTap: () => predictNavigator.newPage(
                        context, page: WatchlistScreen()),
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
                    onTap: () => predictNavigator.newPage(
                        context, page: ChatsScreen()),
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

                  // ── LOGOUT ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _handleLogout(context),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.primaryColorDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            AppText("Logout",
                                fontSize: 15,
                                color: Colors.red,
                                fontWeight: FontWeight.w600),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  AppText("Version 1.0.1", fontSize: 14, color: Colors.grey),
                  const SizedBox(height: 20),

                  // ── FOOTER ──
                  Container(
                    width: double.infinity,
                    color: theme.primaryColorDark,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("FAQ for Finance & Professionals",
                            fontSize: 16, color: Colors.grey),
                        const SizedBox(height: 16),
                        AppText("Privacy Policy",
                            fontSize: 16, color: Colors.grey),
                        const SizedBox(height: 16),
                        AppText("Data Terms of Service",
                            fontSize: 16, color: Colors.grey),
                        const SizedBox(height: 20),
                        Divider(color: theme.dividerColor),
                        const SizedBox(height: 16),
                        AppText("© 2026 Predict365 Inc.",
                            fontSize: 16, fontWeight: FontWeight.w600),
                        const SizedBox(height: 10),
                        AppText(
                          "Trading on Predict365 involves risk and may not be "
                              "appropriate for all. Members risk losing their cost "
                              "to enter any transaction, including fees. You should "
                              "carefully consider whether trading on Predik is "
                              "appropriate for you in light of your investment "
                              "experience and financial resources. Any trading "
                              "decisions you make are solely your responsibility "
                              "and at your own risk. Information is provided for "
                              "convenience only on an \"AS IS\" basis. Past "
                              "performance is not necessarily indicative of future "
                              "results. Predik is subject to U.S. regulatory "
                              "oversight by the CFTC.",
                          fontSize: 13,
                          color: Colors.grey,
                          maxLines: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
    required bool isGradient,
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
              AppText(title, fontSize: 16),
              const SizedBox(height: 4),
              AppText(amount, fontSize: 14, color: Colors.grey),
            ],
          ),
          const Spacer(),
          isGradient
              ? GradientContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: AppText(buttonText,
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppText(buttonText,
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600),
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
                AppText(title, fontSize: 16, fontWeight: FontWeight.w500),
                const SizedBox(height: 4),
                AppText(subtitle, fontSize: 14, color: Colors.grey),
              ],
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
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

// ── Logout Dialog ─────────────────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            AppText("Logout", fontSize: 18, fontWeight: FontWeight.w700),
            const SizedBox(height: 8),
            AppText(
              "Are you sure you want to logout\nfrom your account?",
              fontSize: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.primaryColorDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      alignment: Alignment.center,
                      child: AppText("Cancel",
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: AppText("Logout",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
