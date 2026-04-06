// lib/PredictScreens/PredictionDetailScreens/predictionDetailView.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/EventModel.dart';
import 'package:predict365/Models/OrderBookModel.dart';
import 'package:predict365/PredictScreens/DepositWithdrawScreen/DepositWithdrawScreen.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/ActivityTab/ActivityTabView.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/BuyScreens/BuyDrawerView.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/BuyScreens/OrderBookService.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/Chart/PriceLineChart.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/Chart/LiveCryptoChart.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/Chart/LiveFinanceChart.dart';
import 'package:predict365/PredictScreens/PredictionDetailScreens/CommentTab/CommentTabView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Predict_Utils/ColorHandlers/AppColors.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/BondingNavigator.dart';
import 'package:predict365/Reusable_Widgets/ReuseableGradientContainer/ReusableGradientContainer.dart';
import 'package:predict365/Reusable_Widgets/ShimmerLoaderWidget/ShimmerWidget.dart';
import 'package:predict365/ViewModel/EventDetailVM.dart';
import 'package:predict365/ViewModel/MarketChartVM.dart';
import 'package:predict365/ViewModel/ActivityVM.dart';
import 'package:predict365/ViewModel/BookmarkVM.dart';
import 'package:predict365/ViewModel/ThoughtsVM.dart';
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
        // ActivityViewModel provided here so ActivityTabView can read it
        ChangeNotifierProvider(
          create: (_) => ActivityViewModel(),
        ),
        // ThoughtViewModel provided here so CommentsTabView can read it
        ChangeNotifierProvider(
          create: (_) => ThoughtViewModel(),
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
  final List<String> _tabs       = ['Activity', 'Holders', 'Comments'];

  // ── Order book per sub-market ─────────────────────────────────
  final Map<String, OrderBookService> _obServices = {};
  final Map<String, OrderBook>        _obBooks    = {};
  final Map<String, bool>             _obLoading  = {};

  void _connectOrderBook(SubMarket m) {
    if (_obServices.containsKey(m.id)) return;
    _obLoading[m.id] = true;
    _obServices[m.id] = OrderBookService(
      marketId: m.id,
      onBook: (book) {
        if (!mounted) return;
        setState(() { _obBooks[m.id] = book; _obLoading[m.id] = false; });
      },
    );
    _obServices[m.id]!.connect();
  }

  @override
  void dispose() {
    for (final s in _obServices.values) s.dispose();
    super.dispose();
  }

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
                  const Expanded(
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: _DetailSkeleton(),
                    ),
                  )
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
                      child: CustomScrollView(
                        slivers: [
                          // ── Everything above the tab bar ─────────────
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVolumeRow(context, vm.event!),
                                _buildQuestionCard(context, vm.event!),
                                _buildTimeRangeSelector(context, vm.event!),
                                _buildBettingOptions(context, vm.event!),
                                _buildAboutSection(context, vm.event!),
                                _buildRulesSection(context, vm.event!),
                                Divider(
                                    color: Theme.of(context).dividerColor,
                                    thickness: 1),
                              ],
                            ),
                          ),

                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _PinnedTabBarDelegate(
                              backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                              child: _buildTabBar(context,
                                  backgroundColor: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                          ),

                          // ── Tab content ───────────────────────────────
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTabBody(context, vm.event!),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Consumer<UserViewModel>(
        builder: (context, userVm, _) {
          final user    = userVm.user;
          final balance = user?.balanceFormatted ?? '₹0.00';

          return Row(
            children: [
              GestureDetector(
                onTap: () => predictNavigator.backPage(context),
                child: Icon(Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color, size: 20),
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(balance, fontSize: 13, fontWeight: FontWeight.w600),
                      const SizedBox(width: 6),
                      GradientContainer(
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color, size: 20),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 14,
                backgroundImage: (user?.profileImage != null &&
                    user!.profileImage!.isNotEmpty)
                    ? NetworkImage(user.profileImage!) as ImageProvider
                    : const AssetImage("assets/images/myprofile.png"),
              ),
            ],
          );
        },
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
          _DetailBookmarkStar(eventId: event.id),
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

          // ── Chart: 3 types based on event category + eventType ────
          _buildChart(event),
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
                context.read<MarketDataViewModel>().fetchData(event.id, timeRange: r);
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

    // Detect time-slot events: same name OR >10 sub-markets (e.g. 276x "Bitcoin 15 min").
    final uniqueNames = event.subMarkets.map((m) => m.name.trim().toLowerCase()).toSet();
    final isTimeSlotEvent = uniqueNames.length == 1 || event.subMarkets.length > 10;
    debugPrint('=== subMarkets=${event.subMarkets.length} uniqueNames=${uniqueNames.length} isTimeSlot=$isTimeSlotEvent');

    if (isTimeSlotEvent) {
      // For time-slot markets (e.g. "Bitcoin Up or Down - 15 min"),
      // show only the LAST OPEN sub-market (most recent slot).
      // If none are open, show the very last one.
      final openMarkets = event.subMarkets.where((m) => m.isOpen).toList();
      final m = openMarkets.isNotEmpty
          ? openMarkets.last   // last = most recent open slot
          : event.subMarkets.last;

      // Only connect WS for this single market — disconnect any stale ones
      final staleIds = _obServices.keys.where((id) => id != m.id).toList();
      for (final id in staleIds) {
        _obServices[id]?.dispose();
        _obServices.remove(id);
        _obBooks.remove(id);
        _obLoading.remove(id);
      }
      _connectOrderBook(m);
      final book    = _obBooks[m.id] ?? OrderBook.empty();
      final loading = _obLoading[m.id] ?? true;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(m.name,
                fontSize: 16, fontWeight: FontWeight.w500,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
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
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: m.isOpen ? Colors.green : Colors.red,
                ),
              ),
              if (event.regions.isNotEmpty) ...[
                const SizedBox(width: 8),
                AppText(event.regions.first.name, fontSize: 12, color: Colors.grey),
              ],
            ]),
            const SizedBox(height: 10),
            if (m.isOpen) ...[
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => showBuySheet(context,
                      subMarket: m, event: event, initialIsYes: true),
                  child: _betBtn(m.side1, Colors.green, context),
                )),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () => showBuySheet(context,
                      subMarket: m, event: event, initialIsYes: false),
                  child: _betBtn(m.side2, Colors.red, context),
                )),
              ]),
              const SizedBox(height: 14),
              _DetailOrderBook(
                  book: book, loading: loading,
                  subMarket: m, event: event,
                  lastEntryOnly: false),
            ] else ...[
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(m.status.toUpperCase(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400, letterSpacing: 0.5)),
                ),
              ]),
              const SizedBox(height: 14),
              _DetailOrderBook(
                  book: book, loading: loading,
                  subMarket: m, event: event,
                  readOnly: true, lastEntryOnly: false),
            ],
          ],
        ),
      );
    }

    // ── Multi-market: different market names → show all with full order books ──

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: event.subMarkets.map((m) {
          _connectOrderBook(m);
          final book    = _obBooks[m.id] ?? OrderBook.empty();
          final loading = _obLoading[m.id] ?? true;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
                const SizedBox(height: 10),

                if (m.isOpen) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showBuySheet(context,
                              subMarket: m, event: event, initialIsYes: true),
                          child: _betBtn(m.side1, Colors.green, context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showBuySheet(context,
                              subMarket: m, event: event, initialIsYes: false),
                          child: _betBtn(m.side2, Colors.red, context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailOrderBook(
                    book: book, loading: loading,
                    subMarket: m, event: event,
                    // full order book
                  ),
                ] else ...[
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerColor, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          m.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailOrderBook(
                    book: book, loading: loading,
                    subMarket: m, event: event,
                    readOnly: true,
                    // full order book
                  ),
                ],
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
      child: AppText(label, fontSize: 14, fontWeight: FontWeight.w700, color: color),
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

  // ── CHART — 3 types ───────────────────────────────────────────
  Widget _buildChart(EventModel event) {
    // Debug — remove after confirming
    debugPrint('=== CHART DEBUG ===');
    debugPrint('  eventType    : "${event.eventType}"');
    debugPrint('  category     : "${event.category}"');
    debugPrint('  subCategory  : "${event.subCategory}"');
    debugPrint('  cryptoSymbol : "${event.cryptoSymbol}"');
    debugPrint('  chartType    : "${event.chartType}"');
    debugPrint('  isContinuous : ${event.isContinuous}');
    debugPrint('  isFinance    : ${event.isFinanceMarket}');
    debugPrint('  isCrypto     : ${event.isCryptoMarket}');

    final sym = event.cryptoSymbol.isNotEmpty
        ? event.cryptoSymbol
        : _extractSymbol(event.eventTitle);

    debugPrint('  resolved sym : "$sym"');

    switch (event.chartType) {
      case 'finance':
        return LiveFinanceChart(symbol: sym, height: 200);
      case 'crypto':
        return LiveCryptoChart(symbol: sym, height: 200);
      default:
        return Consumer<MarketDataViewModel>(
          builder: (context, chartVm, _) {
            if (chartVm.isLoading) return PriceLineChartSkeleton(height: 200);
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
                      Icon(Icons.show_chart, size: 32, color: Colors.grey.shade700),
                      const SizedBox(height: 8),
                      Text('No chart data',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }
            final candles = chartVm.data?.allCandles ?? [];
            return PriceLineChart(candles: candles, height: 200);
          },
        );
    }
  }

  /// Extracts a trading symbol from the event title.
  /// Returns the raw symbol — LiveFinanceChart adds =X suffix for Yahoo internally.
  String _extractSymbol(String title) {
    final upper = title.toUpperCase();
    // Forex pairs — return raw pair, LiveFinanceChart converts to Yahoo format
    const forexPairs = ['USDJPY', 'EURUSD', 'GBPUSD', 'USDCHF', 'AUDUSD',
      'USDCAD', 'NZDUSD', 'USDINR', 'USDCNY', 'GBPJPY', 'EURJPY',
      'EURGBP', 'AUDCAD', 'CADJPY', 'CHFJPY', 'NZDJPY'];
    for (final pair in forexPairs) {
      if (upper.contains(pair)) return pair;
    }
    // Commodities
    if (upper.contains('GOLD') || upper.contains('XAU')) return 'XAUUSD';
    if (upper.contains('SILVER') || upper.contains('XAG')) return 'XAGUSD';
    if (upper.contains('OIL') || upper.contains('CRUDE')) return 'CRUDEOIL';
    // Indices
    if (upper.contains('S&P') || upper.contains('SPX') || upper.contains('SP500')) return 'SPX';
    if (upper.contains('NASDAQ') || upper.contains('NDX')) return 'NDX';
    if (upper.contains('DOW') || upper.contains('DJI')) return 'DJI';
    // Crypto → Binance format (used by LiveCryptoChart)
    if (upper.contains('BTC') || upper.contains('BITCOIN')) return 'BTCUSDT';
    if (upper.contains('ETH') || upper.contains('ETHEREUM')) return 'ETHUSDT';
    if (upper.contains('SOL')) return 'SOLUSDT';
    if (upper.contains('BNB')) return 'BNBUSDT';
    if (upper.contains('XRP')) return 'XRPUSDT';
    // Fallback
    return 'USDJPY';
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
                AppText('Settlement Sources', fontSize: 13, fontWeight: FontWeight.w600),
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

  // ── PINNED TAB BAR (extracted for SliverPersistentHeader) ────────
  Widget _buildTabBar(BuildContext context, {Color? backgroundColor}) {
    return Container(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _tabs.asMap().entries.map((e) {
          final sel = _selectedTabIndex == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.only(bottom: 4),
              decoration: sel
                  ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .color!,
                    width: 2,
                  ),
                ),
              )
                  : null,
              child: AppText(
                e.value,
                fontSize: 16,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                color: sel ? null : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── TAB BODY ──────────────────────────────────────────────────
  Widget _buildTabBody(BuildContext context, EventModel event) {
    if (_selectedTabIndex == 0) {
      return ActivityTabView(eventId: event.id);
    } else if (_selectedTabIndex == 2) {
      return CommentsTabView(eventId: event.id);
    }
    // Holders — stub
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: AppText(
          'No ${_tabs[_selectedTabIndex].toLowerCase()} yet.',
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// BOOKMARK STAR — detail screen version (slightly larger)
// Reads BookmarkViewModel from the parent provider tree (injected
// at app root), so state is shared with HomeScreen cards.
// ══════════════════════════════════════════════════════════════════
class _DetailBookmarkStar extends StatelessWidget {
  final String eventId;
  const _DetailBookmarkStar({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkViewModel>(
      builder: (context, bVm, _) {
        final bookmarked = bVm.isBookmarked(eventId);
        final pending    = bVm.isPending(eventId);

        return GestureDetector(
          onTap: pending ? null : () => bVm.toggleBookmark(eventId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bookmarked
                  ? const Color(0xFFF5A623).withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: pending
                ? SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.grey.shade500),
            )
                : Icon(
              bookmarked ? Icons.star : Icons.star_border,
              size: 20,
              color: bookmarked
                  ? const Color(0xFFF5A623)
                  : Colors.grey.shade500,
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// PINNED TAB BAR DELEGATE
// Keeps the Activity / Holders / Comments tab bar stuck to the top
// of the screen while the user scrolls through content below it.
// ══════════════════════════════════════════════════════════════════
class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color  backgroundColor;

  const _PinnedTabBarDelegate({
    required this.child,
    required this.backgroundColor,
  });

  // Tab bar height: 16 top + 20 text + 4 underline pad + 16 bottom = 56
  static const double _height = 56.0;

  @override double get minExtent => _height;
  @override double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_PinnedTabBarDelegate old) =>
      old.child != child || old.backgroundColor != backgroundColor;
}

// ══════════════════════════════════════════════════════════════════
// ORDER BOOK — shown inline on detail screen
// ══════════════════════════════════════════════════════════════════
class _DetailOrderBook extends StatefulWidget {
  final OrderBook  book;
  final bool       loading;
  final SubMarket  subMarket;
  final EventModel event;
  final bool       readOnly;
  final bool       lastEntryOnly; // true = single-market: show only last bid+ask

  const _DetailOrderBook({
    required this.book,
    required this.loading,
    required this.subMarket,
    required this.event,
    this.readOnly      = false,
    this.lastEntryOnly = false,
  });

  @override
  State<_DetailOrderBook> createState() => _DetailOrderBookState();
}

class _DetailOrderBookState extends State<_DetailOrderBook> {
  static const int _pageSize = 5;
  bool _showAllAsks = false;
  bool _showAllBids = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final txt    = isDark ? Colors.white : Colors.black87;
    final divC   = Theme.of(context).dividerColor;
    final book   = widget.book;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Order Book',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
          const Spacer(),
          if (widget.loading)
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.grey.shade500),
            ),
        ]),
        const SizedBox(height: 8),

        Row(children: [
          SizedBox(width: 48,
              child: Text('TOTAL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500))),
          const SizedBox(width: 6),
          Expanded(child: Text('BID',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: Color(0xFF4DD9A0)),
              textAlign: TextAlign.right)),
          SizedBox(width: 52,
              child: Text('PRICE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500),
                  textAlign: TextAlign.center)),
          Expanded(child: Text('ASK',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: Color(0xFFE05252)),
              textAlign: TextAlign.left)),
          const SizedBox(width: 6),
          SizedBox(width: 48,
              child: Text('TOTAL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500),
                  textAlign: TextAlign.right)),
        ]),
        const SizedBox(height: 4),

        if (widget.loading && book.asks.isEmpty && book.bids.isEmpty)
          _buildSkeleton()
        else
          _buildRows(book, divC),
      ],
    );
  }

  Widget _buildRows(OrderBook book, Color divC) {
    final asks = book.asks;
    final bids = book.bids;

    if (asks.isEmpty && bids.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('No order book data yet',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ),
      );
    }

    // Single-market: show only best ask (lowest price) + best bid (highest price)
    List<OrderBookLevel> shownAsks;
    List<OrderBookLevel> shownBids;

    if (widget.lastEntryOnly) {
      // Best ask = lowest price ask
      shownAsks = asks.isNotEmpty
          ? [asks.reduce((a, b) => a.price < b.price ? a : b)]
          : [];
      // Best bid = highest price bid
      shownBids = bids.isNotEmpty
          ? [bids.reduce((a, b) => a.price > b.price ? a : b)]
          : [];
    } else {
      shownAsks = _showAllAsks ? asks : asks.take(_pageSize).toList();
      shownBids = _showAllBids ? bids : bids.take(_pageSize).toList();
    }

    double maxA = 1, maxB = 1;
    for (final l in shownAsks) if (l.shares > maxA) maxA = l.shares;
    for (final l in shownBids) if (l.shares > maxB) maxB = l.shares;

    return Column(children: [
      ...shownAsks.map((a) => GestureDetector(
        onTap: widget.readOnly ? null : () => showBuySheet(context,
            subMarket: widget.subMarket, event: widget.event,
            initialIsYes: true,
            initialPrice: (a.price * 100).roundToDouble()),
        child: _askRow(a, maxA),
      )),
      if (!widget.lastEntryOnly && asks.length > _pageSize)
        _moreBtn(showing: _showAllAsks, total: asks.length,
            onTap: () => setState(() => _showAllAsks = !_showAllAsks), isAsk: true),
      _spreadRow(book, divC),
      ...shownBids.map((b) => GestureDetector(
        onTap: widget.readOnly ? null : () => showBuySheet(context,
            subMarket: widget.subMarket, event: widget.event,
            initialIsYes: false,
            initialPrice: (b.price * 100).roundToDouble()),
        child: _bidRow(b, maxB),
      )),
      if (!widget.lastEntryOnly && bids.length > _pageSize)
        _moreBtn(showing: _showAllBids, total: bids.length,
            onTap: () => setState(() => _showAllBids = !_showAllBids), isAsk: false),
    ]);
  }

  Widget _askRow(OrderBookLevel ask, double maxShares) {
    final frac = (ask.shares / maxShares).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        const SizedBox(width: 48),
        const SizedBox(width: 6),
        const Expanded(child: SizedBox()),
        SizedBox(width: 52,
            child: Text(ask.priceLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFFE05252)),
                textAlign: TextAlign.center)),
        Expanded(child: Stack(alignment: Alignment.centerLeft, children: [
          Align(alignment: Alignment.centerLeft,
              child: FractionallySizedBox(widthFactor: frac,
                child: Container(height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05252).withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    )),
              )),
          Padding(padding: const EdgeInsets.only(left: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE05252).withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(ask.shares.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: Color(0xFFE05252))),
              )),
        ])),
        const SizedBox(width: 6),
        SizedBox(width: 48,
            child: Text(ask.totalLabel,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _bidRow(OrderBookLevel bid, double maxShares) {
    final frac = (bid.shares / maxShares).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 48,
            child: Text(bid.totalLabel,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                textAlign: TextAlign.left)),
        const SizedBox(width: 6),
        Expanded(child: Stack(alignment: Alignment.centerRight, children: [
          Align(alignment: Alignment.centerRight,
              child: FractionallySizedBox(widthFactor: frac,
                child: Container(height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DD9A0).withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    )),
              )),
          Padding(padding: const EdgeInsets.only(right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DD9A0).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(bid.shares.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: Color(0xFF4DD9A0))),
              )),
        ])),
        SizedBox(width: 52,
            child: Text(bid.priceLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Color(0xFF4DD9A0)),
                textAlign: TextAlign.center)),
        const SizedBox(width: 6),
        const SizedBox(width: 48),
      ]),
    );
  }

  Widget _spreadRow(OrderBook book, Color divC) {
    return LayoutBuilder(builder: (context, constraints) {
      final total     = constraints.maxWidth;
      final pillWidth = total * 0.5;
      final lineWidth = (total - pillWidth) / 2 - 4;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: lineWidth, height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade700))),
          const SizedBox(width: 4),
          Container(
            width: pillWidth,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: divC, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Spread  ${book.spreadLabel}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              const SizedBox(width: 8),
              Text('LTP  ${book.ltpLabel}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ]),
          ),
          const SizedBox(width: 4),
          SizedBox(width: lineWidth, height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade700))),
        ]),
      );
    });
  }

  Widget _moreBtn({
    required bool showing, required int total,
    required VoidCallback onTap, required bool isAsk,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child: Text(
            showing ? 'Show less' : '+ ${total - _pageSize} more ${isAsk ? 'asks' : 'bids'}',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: isAsk ? const Color(0xFFE05252) : const Color(0xFF4DD9A0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(5, (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          _sk(48), const SizedBox(width: 6),
          Expanded(child: _sk(20)), const SizedBox(width: 4),
          _sk(48), const SizedBox(width: 4),
          Expanded(child: _sk(20)), const SizedBox(width: 6),
          _sk(48),
        ]),
      )),
    );
  }

  Widget _sk(double w) => Container(
    width: w, height: 20,
    decoration: BoxDecoration(
      color: Colors.grey.shade800.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// ── DETAIL PAGE SHIMMER SKELETON ─────────────────────────────────
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return ShimmerWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Row(children: [
              ShimmerBox(width: sw * 0.35, height: 16),
              const Spacer(),
              ShimmerBox(width: 20, height: 20, radius: 10),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShimmerBox(width: 52, height: 52, radius: 8),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  ShimmerBox(width: sw * 0.55, height: 16),
                ],
              )),
            ]),
            const SizedBox(height: 10),
            ShimmerBox(width: sw * 0.7, height: 13),
            const SizedBox(height: 6),
            ShimmerBox(width: sw * 0.5, height: 13),
            const SizedBox(height: 18),
            ShimmerBox(width: double.infinity, height: 200, radius: 10),
            const SizedBox(height: 18),
            Row(children: List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ShimmerBox(width: 30, height: 14),
            ))),
            const SizedBox(height: 20),
            _subMarketSkeleton(context, sw),
            const SizedBox(height: 14),
            _subMarketSkeleton(context, sw),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _subMarketSkeleton(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: sw * 0.55, height: 16),
        const SizedBox(height: 6),
        ShimmerBox(width: sw * 0.2, height: 12, radius: 4),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ShimmerBox(width: double.infinity, height: 44, radius: 8)),
          const SizedBox(width: 10),
          Expanded(child: ShimmerBox(width: double.infinity, height: 44, radius: 8)),
        ]),
      ],
    );
  }
}