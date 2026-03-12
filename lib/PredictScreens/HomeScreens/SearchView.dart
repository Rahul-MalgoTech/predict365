// lib/PredictScreens/SearchScreen/SearchScreen.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/predictionDetailView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/ViewModel/EventVM.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode             _focusNode  = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus keyboard on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() {
      setState(() => _query = _controller.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<EventModel> _filtered(List<EventModel> all) {
    if (_query.isEmpty) return all;
    return all.where((e) =>
    e.eventTitle.toLowerCase().contains(_query) ||
        e.marketSummary.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeController>().isDarkMode;
    final allEvents = context.watch<EventViewModel>().allEvents;
    final results   = _filtered(allEvents);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99),
      body: SafeArea(
        child: Column(
          children: [

            // ── SEARCH BAR ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => predictNavigator.backPage(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 16, color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search,
                              size: 20, color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search events...',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () => _controller.clear(),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.close,
                                    size: 18, color: Colors.grey.shade500),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Theme.of(context).dividerColor, thickness: 1, height: 1),

            // ── RESULTS ─────────────────────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyPrompt(context)
                  : results.isEmpty
                  ? _buildNoResults(context)
                  : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, i) =>
                    _SearchResultCard(event: results[i]),
                                ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY PROMPT (before typing) ──────────────────────────────
  Widget _buildEmptyPrompt(BuildContext context) {
    final allEvents = context.watch<EventViewModel>().allEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('All Events',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500),
          const SizedBox(height: 12),
          ...allEvents.take(10).map((e) => _SearchResultCard(event: e)),
        ],
      ),
    );
  }

  // ── NO RESULTS ────────────────────────────────────────────────
  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          AppText('No results for "$_query"',
              fontSize: 15, fontWeight: FontWeight.w600),
          const SizedBox(height: 6),
          AppText('Try different keywords',
              fontSize: 13, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}

// ── SEARCH RESULT CARD ────────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  final EventModel event;
  const _SearchResultCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final m = event.primaryMarket;

    return GestureDetector(
      onTap: () => predictNavigator.newPage(
          context, page: PredikDetailScreen(eventId: event.id)),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Event image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: event.eventImage.isNotEmpty
                    ? Image.network(
                  event.eventImage,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(context),
                )
                    : _fallback(context),
              ),
              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Title
                    AppText(
                      event.eventTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Status + vol row
                    Row(
                      children: [
                        // Open/closed badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (m?.isOpen ?? false)
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            (m?.isOpen ?? false) ? 'OPEN' : 'CLOSED',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: (m?.isOpen ?? false) ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Volume
                        AppText(
                          '\$${event.totalPoolInUsd.toStringAsFixed(0)} Vol',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        const Spacer(),
                        // Markets count
                        AppText(
                          '${event.subMarkets.length} Market${event.subMarkets.length == 1 ? '' : 's'}',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),

                    if (m != null) ...[
                      const SizedBox(height: 10),
                      // Yes / No buttons
                      Row(
                        children: [
                          Expanded(child: _betBtn(m.side1, Colors.green, context)),
                          const SizedBox(width: 8),
                          Expanded(child: _betBtn(m.side2, Colors.red, context)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _betBtn(String label, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText(label,
          fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.event, color: Colors.grey.shade400, size: 22),
    );
  }
}