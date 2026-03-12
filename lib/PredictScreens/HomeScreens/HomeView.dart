import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/PredictScreens/DepositWithdrawScreen/DepositWithdrawScreen.dart';
import 'package:predict365/PredictScreens/HomeScreens/SearchView.dart';
import 'package:predict365/PredictScreens/MatchScreens/matchView.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/predictionDetailView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/Reusable_Widgets/ShimmerLoaderWidget/ShimmerWidget.dart';
import 'package:predict365/ViewModel/CategoryVM.dart';
import 'package:predict365/ViewModel/EventVM.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  int  selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<EventViewModel>().fetchEvents(),
      context.read<CategoryViewModel>().fetchCategories(),
      context.read<UserViewModel>().fetchMe(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── TOP BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Consumer<UserViewModel>(
                builder: (context, userVm, _) {
                  final user = userVm.user;
                  final balance = user?.balanceFormatted ?? '₹0.00';
                  return Row(
                    children: [
                      Image.asset(
                        isDark
                            ? "assets/images/predictlogowhite.png"
                            : "assets/images/predictlogo.png",
                        height: 22,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => predictNavigator.newPage(context, page: DepositScreen()),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Row(
                            children: [
                              AppText(balance, fontSize: 13, fontWeight: FontWeight.w600),
                              const SizedBox(width: 8),
                              GradientContainer(
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.add, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ThemeToggleIcon(),
                      const SizedBox(width: 10),
                      Icon(Icons.notifications_none,
                          color: Theme.of(context).iconTheme.color, size: 22),
                      const SizedBox(width: 10),
                      // Profile avatar — network image if available, else asset fallback
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                            ? NetworkImage(user.profileImage!) as ImageProvider
                            : const AssetImage("assets/images/myprofile.png"),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── CATEGORY TABS ──
            SizedBox(
              height: 32,
              child: Consumer<CategoryViewModel>(
                builder: (context, catVm, _) {
                  final cats = catVm.categoryNames; // ['Trending', ...API names]
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cats.length,
                    itemBuilder: (context, i) {
                      final isSelected = selectedCategory == i;
                      return GestureDetector(
                        onTap: () {
                          if (selectedCategory == i) return; // already active
                          setState(() => selectedCategory = i);
                          // i == 0 → "Trending" → show all
                          // i == 1 → "All"      → show all
                          // i >= 2 → API category → filter by _id
                          final categoryId = i < 2
                              ? null
                              : catVm.categories[i - 2].id;
                          context.read<EventViewModel>()
                              .filterByCategory(categoryId);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: AppText(
                            cats[i],
                            fontSize: 16,
                            color: isSelected
                                ? Theme.of(context).textTheme.labelLarge!.color
                                : Colors.grey.shade600,
                            fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 2),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 3),

            // ── BODY ──
            Expanded(
              child: _isLoading
                  ? HomeScreenSkeleton()
                  : Consumer<EventViewModel>(
                builder: (context, vm, _) {
                  // Only show shimmer on initial load, not on category switch
                  if (vm.isLoading) return HomeScreenSkeleton();

                  final events = vm.events; // already filtered client-side

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // ── Quick Cards ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Expanded(child: QuickCard("BTC/USDT", "LIVE", logo: 'assets/images/paircoin.png')),
                                  SizedBox(width: 8),
                                  Expanded(child: QuickCard("Youtube",  "Hot",  logo: 'assets/images/youtubelogo.png')),
                                  SizedBox(width: 8),
                                  Expanded(child: QuickCard("15 M",     "",     logo: 'assets/images/bitcoin.png')),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: const [
                                  Expanded(child: QuickCard("T20 WC",  "", logo: 'assets/images/circket.png')),
                                  SizedBox(width: 8),
                                  Expanded(child: QuickCard("Football","", logo: 'assets/images/game.png')),
                                  SizedBox(width: 8),
                                  Expanded(child: QuickCard("Gold",    "", logo: 'assets/images/gold.png')),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── For You header ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              GradientContainer(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  child: AppText("For you",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => predictNavigator.newPage(
                                    context, page: const SearchScreen()),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Icon(Icons.search,
                                      size: 20,
                                      color: Theme.of(context).iconTheme.color),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Empty State ──
                        if (events.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 36),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.inbox_outlined,
                                      size: 36,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppText(
                                    "No events found",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(height: 6),
                                  AppText(
                                    "There are no predictions in this\ncategory right now.",
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => selectedCategory = 0);
                                      context
                                          .read<EventViewModel>()
                                          .filterByCategory(null);
                                    },
                                    child: GradientContainer(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 9),
                                        child: AppText(
                                          "View All Events",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // ── Prediction Cards ──
                        if (events.isNotEmpty)
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              ...events.map((event) {
                                return Column(children: [
                                  event.hasSubMarkets
                                      ? MultiMarketCard(event: event)
                                      : SingleMarketCard(event: event),
                                  const SizedBox(height: 12),
                                ]);
                              }),
                              const SizedBox(height: 12),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── LIVE FAB ──
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFe53a3b),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFe53a3b).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: Colors.white),
            SizedBox(width: 5),
            Text("LIVE",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _formatPool(double pool) =>
      pool > 0 ? '₹${pool.toStringAsFixed(2)} Vol' : '₹0.00 Vol';

  String _timeLeft(DateTime? endDate) {
    if (endDate == null) return '--';
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h}h ${m}m ${s}s';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXISTING WIDGETS — zero UI changes
// ─────────────────────────────────────────────────────────────────────────────

class CategoryItem extends StatelessWidget {
  final String title;
  final bool selected;
  const CategoryItem(this.title, this.selected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            title,
            fontSize: 14,
            color: selected
                ? Theme.of(context).textTheme.labelLarge!.color
                : Colors.grey.shade500,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
          if (selected) ...[
            const SizedBox(height: 3),
            Container(
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF977032), Color(0xFFF5A623)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
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
              Image.asset(logo, height: 26, fit: BoxFit.contain),
              const SizedBox(width: 6),
              Expanded(
                child: AppText(title, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -7,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFe53a3b),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// SINGLE MARKET CARD  —  matches website left card style
// ─────────────────────────────────────────────────────────────────────────────

class SingleMarketCard extends StatelessWidget {
  final EventModel event;
  const SingleMarketCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final m      = event.primaryMarket;
    final isOpen = m?.isOpen ?? false;

    return GestureDetector(
      onTap: () => predictNavigator.newPage(context, page: PredikDetailScreen(eventId: event.id)),
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

            // ── Title row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    event.eventTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _iconBtn(Icons.star_border),
                const SizedBox(width: 6),
                _iconBtn(Icons.access_time_outlined),
              ],
            ),

            const SizedBox(height: 14),

            // ── Yes / No percentages ──
            Row(
              children: [
                AppText("48%",
                    fontSize: 15, fontWeight: FontWeight.w600),
                const SizedBox(width: 6),
                AppText(m?.side1 ?? 'Yes',
                    fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
                const Spacer(),
                AppText(m?.side2 ?? 'No',
                    fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500),
                const SizedBox(width: 6),
                AppText("52%",
                    fontSize: 15, fontWeight: FontWeight.w600),
              ],
            ),

            const SizedBox(height: 8),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Expanded(
                    flex: 48,
                    child: Container(height: 5, color: Colors.green),
                  ),
                  Expanded(
                    flex: 52,
                    child: Container(height: 5, color: Colors.red),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Yes / No bet buttons ──
            Row(
              children: [
                Expanded(child: _betButton(context, m?.side1 ?? 'Yes', '49¢', Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _betButton(context, m?.side2 ?? 'No',  '53¢', Colors.red)),
              ],
            ),

            const SizedBox(height: 14),

            // ── Footer ──
            Row(
              children: [
                AppText(
                  '\$ ${event.totalPoolInUsd.toStringAsFixed(0)} Vol',
                  fontSize: 13,
                  color: Colors.grey,
                ),
                const Spacer(),
                AppText(
                  '${event.subMarkets.length} Market${event.subMarkets.length == 1 ? '' : 's'}',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }

  Widget _betButton(BuildContext context, String label, String price, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        '$label $price',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MULTI MARKET CARD  —  matches website right card style
// ─────────────────────────────────────────────────────────────────────────────

class MultiMarketCard extends StatelessWidget {
  final EventModel event;
  const MultiMarketCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => predictNavigator.newPage(context, page: PredikDetailScreen(eventId: event.id)),
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

            // ── Title row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    event.eventTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _iconBtn(Icons.star_border),
                const SizedBox(width: 6),
                _iconBtn(Icons.access_time_outlined),
              ],
            ),

            const SizedBox(height: 14),

            // ── Sub-market rows (max 3 shown) ──
            ...event.subMarkets.take(3).map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      m.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _betBtn(context, m.side1, Colors.green),
                  const SizedBox(width: 6),
                  _betBtn(context, m.side2, Colors.red),
                ],
              ),
            )),

            const SizedBox(height: 4),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 8),

            // ── Footer ──
            Row(
              children: [
                AppText(
                  '\$ ${event.totalPoolInUsd.toStringAsFixed(0)} Vol',
                  fontSize: 13,
                  color: Colors.grey,
                ),
                const Spacer(),
                AppText(
                  '${event.subMarkets.length} Market${event.subMarkets.length == 1 ? '' : 's'}',
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }

  Widget _betBtn(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}