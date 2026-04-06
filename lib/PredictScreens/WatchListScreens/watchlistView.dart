// lib/PredictScreens/WatchlistScreen/WatchlistScreen.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/predictionDetailView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/Reusable_Widgets/ShimmerLoaderWidget/ShimmerWidget.dart';
import 'package:predict365/ViewModel/BookmarkVM.dart';
import 'package:predict365/ViewModel/WatchlistVM.dart';
import 'package:provider/provider.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          WatchlistViewModel()
            ..fetchBookmarks(seeder: ctx.read<BookmarkViewModel>()),
      child: const _WatchlistBody(),
    );
  }
}

class _WatchlistBody extends StatelessWidget {
  const _WatchlistBody();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Watchlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Placeholder to keep title centred
                  const SizedBox(width: 20),
                ],
              ),
            ),

            Divider(
              color: Theme.of(context).dividerColor,
              height: 1,
              thickness: 1,
            ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: Consumer<WatchlistViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) return const _WatchlistSkeleton();

                  if (vm.status == WatchlistStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            vm.error,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: vm.refresh,
                            child: GradientContainer(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 9,
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (vm.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800.withValues(
                                alpha: 0.4,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bookmark_border,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bookmarks yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the ★ icon on any event to\nadd it to your watchlist.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        vm.refresh(seeder: context.read<BookmarkViewModel>()),
                    color: const Color(0xFFF5A623),
                    backgroundColor: Theme.of(context).primaryColorDark,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: vm.events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _WatchlistCard(event: vm.events[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WATCHLIST CARD — matches existing app card style
// ─────────────────────────────────────────────────────────────────
class _WatchlistCard extends StatelessWidget {
  final EventModel event;
  const _WatchlistCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final m = event.primaryMarket;
    final isOpen = m?.isOpen ?? false;
    final isLive = event.isLiveSports;

    // YES price: lastTradedSide1Price as percentage, fallback to 50
    final yesPrice = m?.lastTradedSide1Price != null
        ? '${(m!.lastTradedSide1Price! * 100).toStringAsFixed(0)}¢'
        : '';
    final noPrice = m?.lastTradedSide1Price != null
        ? '${((1 - m!.lastTradedSide1Price!) * 100).toStringAsFixed(0)}¢'
        : '';

    return GestureDetector(
      onTap: () => predictNavigator.newPage(
        context,
        page: PredikDetailScreen(eventId: event.id),
      ),
      child: Container(
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + Title + Bookmark star ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: event.eventImage.isNotEmpty
                      ? Image.network(
                          event.eventImage,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(context),
                        )
                      : _imageFallback(context),
                ),
                const SizedBox(width: 12),

                // Title
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

                // ★ Bookmark star — tapping removes from watchlist
                _WatchlistStar(event: event),
              ],
            ),

            const SizedBox(height: 14),

            // ── YES / NO bet buttons ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: _betButton(
                    context,
                    m?.side1 ?? 'Yes',
                    yesPrice,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _betButton(
                    context,
                    m?.side2 ?? 'No',
                    noPrice,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Footer: LIVE badge + volume + market count ────
            Row(
              children: [
                if (isLive) ...[
                  const Icon(Icons.podcasts, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CLOSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OPEN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '\$${event.totalPoolInUsd.toStringAsFixed(0)} Vol',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                Text(
                  event.hasSubMarkets
                      ? '${event.subMarkets.length} Market${event.subMarkets.length == 1 ? '' : 's'}'
                      : '1 Market',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: Theme.of(context).dividerColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.event, color: Colors.grey.shade400, size: 20),
  );

  Widget _betButton(
    BuildContext context,
    String label,
    String price,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label  $price',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Bookmark star — gold when bookmarked, removes on toggle ──────
class _WatchlistStar extends StatelessWidget {
  final EventModel event;
  const _WatchlistStar({required this.event});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkViewModel>(
      builder: (context, bVm, _) {
        final bookmarked = bVm.isBookmarked(event.id);
        final pending = bVm.isPending(event.id);

        return GestureDetector(
          onTap: pending
              ? null
              : () async {
                  await bVm.toggleBookmark(event.id);
                  // After toggling off, remove from watchlist UI
                  if (!bVm.isBookmarked(event.id)) {
                    context.read<WatchlistViewModel>().removeEvent(event.id);
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bookmarked
                  ? const Color(0xFFF5A623).withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: pending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.grey.shade500,
                    ),
                  )
                : Icon(
                    bookmarked ? Icons.star : Icons.star_border,
                    size: 16,
                    color: bookmarked ? const Color(0xFFF5A623) : Colors.grey,
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHIMMER SKELETON
// ─────────────────────────────────────────────────────────────────
class _WatchlistSkeleton extends StatelessWidget {
  const _WatchlistSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 44, height: 44, radius: 8),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: double.infinity, height: 14),
                              const SizedBox(height: 6),
                              ShimmerBox(width: 200, height: 14),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ShimmerBox(width: 28, height: 28, radius: 8),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 38,
                            radius: 8,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 38,
                            radius: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ShimmerBox(width: 80, height: 12),
                        const Spacer(),
                        ShimmerBox(width: 60, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
