// lib/PredictScreens/ProfileScreens/EditProfileView.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predict365/PredictScreens/ProfileScreens/ChangeProfileView.dart';
import 'package:predict365/PredictScreens/ProfileScreens/ProfileSettingView.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedRange = '1W';
  final List<String> _ranges = ['1D', '1W', '1M', 'ALL'];
  final List<String> _tabs   = ['Positions', 'Trades', 'Posts', 'Replies', 'Likes'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final bg     = Theme.of(context).scaffoldBackgroundColor;
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: bg,
      body: Container(
        color: bg,
        child: SafeArea(
          child: Consumer<UserViewModel>(
            builder: (context, userVm, _) {
              final user = userVm.user;

              // ── Values from API ──
              final username     = user?.displayName      ?? '---';
              final userId       = user?.id               ?? '---';
              final shortId      = userId.length > 8
                  ? userId.substring(userId.length - 8)
                  : userId;
              final bio          = (user?.bio != null && user!.bio!.isNotEmpty)
                  ? user.bio!
                  : 'No description yet.';
              final profileImage = user?.profileImage;

              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      color: bg,
                      child: _buildHeader(
                        context,
                        isDark:       isDark,
                        username:     username,
                        userId:       userId,
                        shortId:      shortId,
                        bio:          bio,
                        profileImage: profileImage,
                        wallet:       user?.wallet      ?? 0,
                        available:    user?.available   ?? 0,
                      ),
                    ),
                  ),
                ],
                body: ColoredBox(
                  color: bg,
                  child: Column(
                    children: [
                      // ── Tab bar ──
                      ColoredBox(
                        color: bg,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: const Color(0xFF2CB67D),
                          indicatorWeight: 2.5,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: const Color(0xFF2CB67D),
                          unselectedLabelColor: Colors.grey.shade500,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 14),
                          dividerColor: Theme.of(context).dividerColor,
                          tabs: _tabs.map((t) => Tab(text: t)).toList(),
                        ),
                      ),
                      // ── Tab views ──
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: _tabs
                              .map((t) => _EmptyTabContent(
                            label: 'No ${t.toLowerCase()} yet.',
                            bg: bg,
                          ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, {
        required bool    isDark,
        required String  username,
        required String  userId,
        required String  shortId,
        required String  bio,
        required String? profileImage,
        required double  wallet,
        required double  available,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top nav
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color, size: 22),
              ),
              const Spacer(),
              ThemeToggleIcon(),
              GestureDetector(
                onTap: () => showProfileSettingsSheet(context),
                child: Icon(Icons.settings_outlined,
                    color: Theme.of(context).iconTheme.color, size: 22),
              ),
            ],
          ),
        ),

        // Avatar + name + ID
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gold-ring avatar
              GestureDetector(
                onTap: () => showChangeProfileSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF977032), Color(0xFFF5A623)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.transparent,
                    backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                        ? NetworkImage(profileImage) as ImageProvider
                        : const AssetImage('assets/images/myprofile.png'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(username, fontSize: 20, fontWeight: FontWeight.w700),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copyId(userId),
                      child: Row(
                        children: [
                          AppText('ID: $shortId',
                              fontSize: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Icon(Icons.copy_rounded,
                              size: 16, color: Colors.grey.shade500),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bio
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AppText(bio, fontSize: 15, color: Colors.grey.shade500),
        ),

        const SizedBox(height: 16),

        // Followers / Following / Views — static for now (no API endpoint)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatItem(value: 0, label: 'Followers'),
              _StatItem(value: 0, label: 'Following'),
              _StatItem(value: 0, label: 'Views'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Metric cards — wallet, available, predictions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _MetricCard(
                icon: Icons.show_chart_rounded,
                iconColor: const Color(0xFF3B82F6),
                bgColor: isDark
                    ? const Color(0xFF111827)
                    : const Color(0xFFEFF6FF),
                borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                label: 'Wallet',
                value: '₹${wallet.toStringAsFixed(2)}',
                valueColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _MetricCard(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFFE53A3B),
                bgColor: isDark
                    ? const Color(0xFF1C0F0F)
                    : const Color(0xFFFFF5F5),
                borderColor: const Color(0xFFE53A3B).withValues(alpha: 0.25),
                label: 'Available',
                value: '₹${available.toStringAsFixed(2)}',
                valueColor: const Color(0xFFE53A3B),
              ),
              const SizedBox(width: 8),
              _MetricCard(
                icon: Icons.diamond_outlined,
                iconColor: const Color(0xFF9333EA),
                bgColor: isDark
                    ? const Color(0xFF130D1C)
                    : const Color(0xFFF5F3FF),
                borderColor: const Color(0xFF9333EA).withValues(alpha: 0.25),
                label: 'Predictions',
                value: '0',
                valueColor: const Color(0xFF9333EA),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Profit/Loss chart card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF2CB67D), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    AppText('Profit/Loss',
                        fontSize: 13, fontWeight: FontWeight.w600),
                    const Spacer(),
                    Row(
                      children: _ranges.map((r) {
                        final sel = _selectedRange == r;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRange = r),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: AppText(
                              r,
                              fontSize: 12,
                              fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel
                                  ? Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color
                                  : Colors.grey.shade500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                              (_) => Divider(
                            color: Theme.of(context).dividerColor,
                            thickness: 0.5,
                            height: 1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            'Predict365',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.withValues(alpha: 0.15),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text('No data available',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Stat Item ──────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final int    value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText('$value', fontSize: 20, fontWeight: FontWeight.w700),
        const SizedBox(height: 2),
        AppText(label, fontSize: 14, color: Colors.grey.shade500),
      ],
    );
  }
}

// ── Metric Card ────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final Color    bgColor;
  final Color    borderColor;
  final String   label;
  final String   value;
  final Color    valueColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 11,
                        color: iconColor,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Tab Content ──────────────────────────────────────────────
class _EmptyTabContent extends StatelessWidget {
  final String label;
  final Color  bg;
  const _EmptyTabContent({required this.label, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }
}