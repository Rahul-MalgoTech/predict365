// lib/PredictScreens/PredictionDetailScreens/predictionDetailView.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/PredictScreens/DepositWithdrawScreen/DepositWithdrawScreen.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/BuyScreens/BuyDrawerView.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/Chart/PriceLineChart.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/ViewModel/EventDetailVM.dart';
import 'package:predict365/ViewModel/MarketChartVM.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────
// ENTRY POINT — called from card taps
// ─────────────────────────────────────────────────────────────────
class PredikDetailScreen extends StatelessWidget {
  final String eventId;
  const PredikDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventDetailViewModel()..fetchEvent(eventId),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketDataViewModel()..fetchData(eventId),
        ),
      ],
      child: const _DetailBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────
class _DetailBody extends StatefulWidget {
  const _DetailBody();
  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  String _selectedTimeRange = 'ALL';
  int    _selectedTabIndex  = 0;
  bool   _aboutExpanded     = true;
  bool   _rulesExpanded     = true;

  final List<String> _timeRanges = ['1H', '6H', '1D', '1W', '1M', 'ALL'];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.99),
      body: SafeArea(
        child: Consumer<EventDetailViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildTopBar(context, isDark, vm),
                Divider(color: Theme.of(context).dividerColor, thickness: 1, height: 1),

                if (vm.isLoading)
                  const Expanded(child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF5A623)),
                  ))
                else if (vm.status == EventDetailStatus.error)
                  Expanded(child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        AppText(vm.error, fontSize: 14, color: Colors.grey),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => vm.fetchEvent(vm.event?.id ?? ''),
                          child: GradientContainer(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                            child: AppText('Retry', fontSize: 14, color: Colors.white),
                          )),
                        ),
                      ],
                    ),
                  ))
                else if (vm.event != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVolumeRow(context, vm.event!),
                            _buildQuestionCard(context, vm.event!),
                            _buildTimeRangeSelector(context, vm.event!),
                            _buildBettingOptions(context, vm.event!),
                            _buildAboutSection(context, vm.event!),
                            _buildRulesSection(context, vm.event!),
                            _buildActivitySection(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, bool isDark, EventDetailViewModel vm) {
    final user    = context.watch<UserViewModel>().user;
    final balance = user?.balanceFormatted ?? '₹0.00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => predictNavigator.backPage(context),
            child: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color, size: 20),
          ),
          Image.asset(
            isDark
                ? 'assets/images/predictlogowhite.png'
                : 'assets/images/predictlogo.png',
            height: 20,
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
                  AppText(balance, fontSize: 14, fontWeight: FontWeight.w600),
                  const SizedBox(width: 8),
                  GradientContainer(child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  )),
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
          CircleAvatar(
            radius: 16,
            backgroundImage: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                ? NetworkImage(user.profileImage!) as ImageProvider
                : const AssetImage('assets/images/myprofile.png'),
          ),
        ],
      ),
    );
  }

  // ── VOLUME ROW ────────────────────────────────────────────────
  Widget _buildVolumeRow(BuildContext context, EventModel event) {
    final vol = event.totalPoolInUsd > 0
        ? '₹${event.totalPoolInUsd.toStringAsFixed(2)} Vol'
        : '₹0.00 Vol';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AppText(vol, fontSize: 16, fontWeight: FontWeight.w500),
          const Spacer(),
          Icon(Icons.favorite_border, size: 20, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  // ── QUESTION CARD + CHART ─────────────────────────────────────
  Widget _buildQuestionCard(BuildContext context, EventModel event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: event.eventImage.isNotEmpty
                    ? Image.network(
                  event.eventImage,
                  width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(context),
                )
                    : _imageFallback(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  event.eventTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (event.marketSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppText(
              event.marketSummary,
              fontSize: 13,
              color: Colors.grey.shade500,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 14),

          // ── DYNAMIC CHART ──
          Consumer<MarketDataViewModel>(
            builder: (context, chartVm, _) {
              if (chartVm.isLoading) {
                return PriceLineChartSkeleton(height: 200);
              }
              if (chartVm.status == MarketDataStatus.error) {
                return Container(
                  width: double.infinity, height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1419),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.show_chart,
                            size: 32, color: Colors.grey.shade700),
                        const SizedBox(height: 8),
                        Text('No chart data',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }
              final candles = chartVm.data?.allCandles ?? [];
              return PriceLineChart(candles: candles, height: 200);
            },
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Icon(Icons.event, color: Colors.grey.shade400),
    );
  }

  // ── TIME RANGE ────────────────────────────────────────────────
  Widget _buildTimeRangeSelector(BuildContext context, EventModel event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ..._timeRanges.map((r) {
            final sel = _selectedTimeRange == r;
            return GestureDetector(
              onTap: () {
                if (_selectedTimeRange == r) return;
                setState(() => _selectedTimeRange = r);
                // Re-fetch chart data with new interval
                context.read<MarketDataViewModel>()
                    .fetchData(event.id, timeRange: r);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.only(bottom: 4),
                decoration: sel
                    ? BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: Theme.of(context).textTheme.labelLarge!.color!,
                    width: 2,
                  )),
                )
                    : null,
                child: AppText(r,
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    color: sel ? null : Colors.grey),
              ),
            );
          }),
          const Spacer(),
          Icon(Icons.tune, size: 18, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  // ── BETTING OPTIONS ───────────────────────────────────────────
  Widget _buildBettingOptions(BuildContext context, EventModel event) {
    if (event.subMarkets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: event.subMarkets.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(m.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: m.isOpen
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AppText(
                        m.isOpen ? 'OPEN' : 'CLOSED',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: m.isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                    if (event.regions.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      AppText(event.regions.first.name,
                          fontSize: 12, color: Colors.grey),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => predictNavigator.newPage(context,
                            page: BuyScreen(subMarket: m, initialIsYes: true, event: event)),
                        child: _betBtn(m.side1, Colors.green, context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => predictNavigator.newPage(context,
                            page: BuyScreen(subMarket: m, initialIsYes: false, event: event)),
                        child: _betBtn(m.side2, Colors.red, context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _betBtn(String label, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(label,
          fontSize: 16, fontWeight: FontWeight.w600, color: color),
    );
  }

  // ── ABOUT ─────────────────────────────────────────────────────
  Widget _buildAboutSection(BuildContext context, EventModel event) {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
        GestureDetector(
          onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AppText('About', fontSize: 16, fontWeight: FontWeight.w700),
                const Spacer(),
                Icon(_aboutExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_aboutExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                _aboutRow(context, Icons.bar_chart, 'Volume',
                    '₹${event.totalPoolInUsd.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                _aboutRow(context, Icons.access_time, 'End Date',
                    event.primaryMarket?.endDate != null
                        ? _fmtDate(event.primaryMarket!.endDate!)
                        : '--'),
                const SizedBox(height: 12),
                _aboutRow(context, Icons.access_time_outlined, 'Created At',
                    event.createdAt != null ? _fmtDate(event.createdAt!) : '--'),
                if (event.regions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _aboutRow(context, Icons.public, 'Regions',
                      event.regions.map((r) => r.name).join(', ')),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _aboutRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 10),
        AppText(label, fontSize: 14, color: Colors.grey),
        const Spacer(),
        Flexible(
          child: AppText(value,
              fontSize: 14, fontWeight: FontWeight.w500,
              textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── RULES ─────────────────────────────────────────────────────
  Widget _buildRulesSection(BuildContext context, EventModel event) {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
        GestureDetector(
          onTap: () => setState(() => _rulesExpanded = !_rulesExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AppText('Rules', fontSize: 16, fontWeight: FontWeight.w700),
                const Spacer(),
                Icon(_rulesExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_rulesExpanded && event.rulesSummary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: AppText(event.rulesSummary,
                fontSize: 13, color: Colors.grey.shade500),
          ),
        if (_rulesExpanded && event.settlementSources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Settlement Sources',
                    fontSize: 13, fontWeight: FontWeight.w600),
                const SizedBox(height: 6),
                ...event.settlementSources.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.grey)),
                      Expanded(child: AppText(s,
                          fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }

  // ── ACTIVITY / HOLDERS / COMMENTS ────────────────────────────
  Widget _buildActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Theme.of(context).dividerColor, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: ['Activity', 'Holders', 'Comments']
                .asMap().entries.map((e) {
              final sel = _selectedTabIndex == e.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = e.key),
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: sel
                      ? BoxDecoration(
                    border: Border(bottom: BorderSide(
                      color: Theme.of(context).textTheme.labelLarge!.color!,
                      width: 2,
                    )),
                  )
                      : null,
                  child: AppText(e.value,
                      fontSize: 16,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel ? null : Colors.grey),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: AppText(
              'No ${['activity', 'holders', 'comments'][_selectedTabIndex]} yet.',
              fontSize: 14, color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}