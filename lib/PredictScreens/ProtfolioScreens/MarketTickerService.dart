// lib/Services/MarketTickerService.dart
//
// Handles market ticks + full portfolio data from the WS.
// Mirrors the JS useWebSocket.js logic exactly.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:predict365/AuthStorage/authStorage.dart';

// ─────────────────────────────────────────────
// Market tick data
// ─────────────────────────────────────────────
class MarketTickData {
  final double? bestBid;
  final double? bestAsk;
  final double? ltp;
  final double  volume;

  const MarketTickData({this.bestBid, this.bestAsk, this.ltp, this.volume = 0});

  String get yesPriceLabel {
    final p = bestAsk ?? bestBid ?? ltp;
    if (p == null) return '';
    return '${(p * 100).toStringAsFixed(0)}¢';
  }
  String get noPriceLabel {
    final p = bestAsk ?? bestBid ?? ltp;
    if (p == null) return '';
    return '${((1 - p) * 100).toStringAsFixed(0)}¢';
  }
  double get yesPercent {
    final p = bestBid ?? bestAsk ?? ltp;
    if (p == null) return 50;
    return (p * 100).clamp(0, 100);
  }
  String get volumeLabel {
    if (volume <= 0) return r'$0.00 Vol';
    if (volume >= 1000000) return '\$${(volume / 1000000).toStringAsFixed(2)}M Vol';
    if (volume >= 1000)    return '\$${(volume / 1000).toStringAsFixed(2)}K Vol';
    return '\$${volume.toStringAsFixed(2)} Vol';
  }
  MarketTickData copyWith({double? bestBid, double? bestAsk, double? ltp, double? volume}) =>
      MarketTickData(
        bestBid: bestBid ?? this.bestBid,
        bestAsk: bestAsk ?? this.bestAsk,
        ltp: ltp ?? this.ltp,
        volume: volume ?? this.volume,
      );
}

// ─────────────────────────────────────────────
// Portfolio models
// ─────────────────────────────────────────────
double _d(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// Deep-converts any Map/List so every nested Map becomes Map<String,dynamic>.
/// jsonDecode on Flutter sometimes returns Map<dynamic,dynamic> for nested objects.
/// Without this, whereType<Map<String,dynamic>>() silently drops every item.
dynamic _deepConvert(dynamic v) {
  if (v is Map) {
    return Map<String, dynamic>.fromEntries(
      v.entries.map((e) => MapEntry(e.key.toString(), _deepConvert(e.value))),
    );
  }
  if (v is List) return v.map(_deepConvert).toList();
  return v;
}

Map<String, dynamic> _toStrMap(dynamic m) {
  final c = _deepConvert(m);
  if (c is Map<String, dynamic>) return c;
  return {};
}

class OpenPosition {
  final String  marketId;
  final String  marketTitle;
  final String  side;
  final String  action;
  final int     shares;
  final double  avgPrice;
  final double? currPrice;
  final double  currValue;
  final double  profitLoss;

  const OpenPosition({
    required this.marketId, required this.marketTitle,
    required this.side, required this.action,
    required this.shares, required this.avgPrice,
    this.currPrice, required this.currValue, required this.profitLoss,
  });

  factory OpenPosition.fromJson(Map<String, dynamic> j) {
    final shares   = _d(j['shares'] ?? j['qty'] ?? 0).toInt();
    final avgPrice = _d(j['avgPrice'] ?? j['avgCost'] ?? j['price'] ?? 0);
    final ltp      = _d(j['ltp'] ?? j['lastPrice'] ?? j['currPrice'] ?? j['currentPrice']);
    final cp       = ltp > 0 ? ltp : avgPrice;
    // side from multiple possible keys
    final side     = (j['side'] ?? j['outcome'] ?? j['userOutcome'] ?? j['position'] ?? 'YES').toString();
    final action   = (j['action'] ?? j['userAction'] ?? j['orderSide'] ?? 'BUY').toString();
    return OpenPosition(
      marketId:    (j['marketId'] ?? j['market_id'] ?? '').toString(),
      marketTitle: (j['marketTitle'] ?? j['market'] ?? j['marketName'] ?? '').toString(),
      side:        side,
      action:      action,
      shares:      shares,
      avgPrice:    avgPrice,
      currPrice:   ltp > 0 ? ltp : null,
      currValue:   shares * cp,
      profitLoss:  (cp - avgPrice) * shares,
    );
  }
}

class PendingOrder {
  final String  orderId;
  final String  marketId;
  final String  marketTitle;
  final String  side;
  final String  action;
  final int     shares;
  final int     filledQty;
  final double  price;
  final double  fees;
  final double  total;
  final String  timeInForce;
  final String  status;

  const PendingOrder({
    required this.orderId, required this.marketId, required this.marketTitle,
    required this.side, required this.action, required this.shares,
    required this.filledQty, required this.price, required this.fees,
    required this.total, required this.timeInForce, required this.status,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> j) {
    final shares = _d(j['shares'] ?? j['qty'] ?? j['remaining'] ?? 0).toInt();
    final price  = _d(j['price'] ?? j['limitPrice'] ?? 0);
    final filled = _d(j['filledQty'] ?? j['filled'] ?? j['executedQty'] ?? 0).toInt();
    final fees   = _d(j['commission'] ?? j['fees'] ?? j['fee'] ?? 0);
    return PendingOrder(
      orderId:    (j['orderId'] ?? j['id'] ?? j['order_id'] ?? '').toString(),
      marketId:   (j['marketId'] ?? j['market_id'] ?? '').toString(),
      marketTitle:(j['marketTitle'] ?? j['market'] ?? j['marketName'] ?? '').toString(),
      side:       (j['side'] ?? j['outcome'] ?? j['position'] ?? 'YES').toString(),
      action:     (j['action'] ?? j['type'] ?? j['orderSide'] ?? j['orderType'] ?? 'BUY').toString(),
      shares:     shares,
      filledQty:  filled,
      price:      price,
      fees:       fees,
      total:      price * shares,
      timeInForce:(j['timeInForce'] ?? j['tif'] ?? 'GTC').toString(),
      status:     (j['status'] ?? 'ACKED').toString(),
    );
  }

  PendingOrder copyWith({int? filledQty, String? status, double? price}) =>
      PendingOrder(
        orderId: orderId, marketId: marketId, marketTitle: marketTitle,
        side: side, action: action, shares: shares,
        filledQty: filledQty ?? this.filledQty,
        price: price ?? this.price, fees: fees, total: total,
        timeInForce: timeInForce, status: status ?? this.status,
      );
}

class ClosedTrade {
  final String    orderId;
  final String    marketId;
  final String    marketTitle;
  final String    side;
  final String    action;
  final int       shares;
  final double    price;
  final double    pnl;
  final String    status;
  final DateTime? timestamp;

  const ClosedTrade({
    required this.orderId, required this.marketId, required this.marketTitle,
    required this.side, required this.action, required this.shares,
    required this.price, required this.pnl, required this.status, this.timestamp,
  });

  factory ClosedTrade.fromJson(Map<String, dynamic> j) {
    DateTime? ts;
    if (j['ts'] != null) {
      ts = DateTime.fromMillisecondsSinceEpoch(_d(j['ts']).toInt());
    } else if (j['timestamp'] != null) {
      ts = DateTime.tryParse(j['timestamp'].toString());
    } else if (j['createdAt'] != null) {
      ts = DateTime.tryParse(j['createdAt'].toString());
    }
    return ClosedTrade(
      orderId:    (j['orderId'] ?? j['id'] ?? '').toString(),
      marketId:   (j['marketId'] ?? j['market_id'] ?? '').toString(),
      marketTitle:(j['marketTitle'] ?? j['market'] ?? j['marketName'] ?? '').toString(),
      side:       (j['side'] ?? j['outcome'] ?? j['position'] ?? 'YES').toString(),
      action:     (j['action'] ?? j['userAction'] ?? 'BUY').toString(),
      shares:     _d(j['shares'] ?? j['filledQty'] ?? j['qty'] ?? 0).toInt(),
      price:      _d(j['price'] ?? j['execPrice'] ?? j['avgFillPrice'] ?? 0),
      pnl:        _d(j['pnl'] ?? j['realizedPnl'] ?? j['profit'] ?? j['profitLoss'] ?? 0),
      status:     (j['status'] ?? 'FILLED').toString(),
      timestamp:  ts,
    );
  }
}

// ─────────────────────────────────────────────
// MarketTickerService
// ─────────────────────────────────────────────
class MarketTickerService extends ChangeNotifier {
  static const String _wsBase = 'wss://staging-api.predict365.com';

  WebSocketChannel?   _channel;
  StreamSubscription? _sub;
  Timer?              _reconnectTimer;
  int                 _reconnectAttempts = 0;
  bool                _disposed          = false;

  final Map<String, MarketTickData> _ticks        = {};
  final Map<String, String>         _marketTitles = {}; // marketId → title

  double _available        = 0;
  double _held             = 0;
  bool   _isTradingEnabled = true;

  List<OpenPosition>         _openPositions = [];
  List<PendingOrder>         _pendingOrders = [];
  List<ClosedTrade>          _closedTrades  = [];
  List<Map<String, dynamic>> _orderHistory  = [];

  // ── Public API ────────────────────────────────────────────────
  double get available        => _available;
  double get held             => _held;
  bool   get isTradingEnabled => _isTradingEnabled;

  List<OpenPosition> get openPositions => List.unmodifiable(_openPositions);
  List<PendingOrder> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<ClosedTrade>  get closedTrades  => List.unmodifiable(_closedTrades);
  List<Map<String, dynamic>> get orderHistory => List.unmodifiable(_orderHistory);

  MarketTickData? getMarketData(String marketId) => _ticks[marketId];
  MarketTickData? getPrimaryMarketData(List<String> ids) {
    for (final id in ids) {
      final d = _ticks[id];
      if (d != null) return d;
    }
    return null;
  }

  /// Called by EventViewModel after loading events — so portfolio rows have titles
  void registerMarketTitles(Map<String, String> titles) {
    _marketTitles.addAll(titles);
    // Backfill any already-loaded positions/orders that have empty titles
    bool changed = false;
    for (int i = 0; i < _openPositions.length; i++) {
      final p = _openPositions[i];
      if (p.marketTitle.isEmpty && _marketTitles.containsKey(p.marketId)) {
        _openPositions[i] = OpenPosition(
          marketId: p.marketId, marketTitle: _marketTitles[p.marketId]!,
          side: p.side, action: p.action, shares: p.shares,
          avgPrice: p.avgPrice, currPrice: p.currPrice,
          currValue: p.currValue, profitLoss: p.profitLoss,
        );
        changed = true;
      }
    }
    for (int i = 0; i < _pendingOrders.length; i++) {
      final o = _pendingOrders[i];
      if (o.marketTitle.isEmpty && _marketTitles.containsKey(o.marketId)) {
        _pendingOrders[i] = PendingOrder(
          orderId: o.orderId, marketId: o.marketId,
          marketTitle: _marketTitles[o.marketId]!,
          side: o.side, action: o.action, shares: o.shares,
          filledQty: o.filledQty, price: o.price, fees: o.fees,
          total: o.total, timeInForce: o.timeInForce, status: o.status,
        );
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  String resolveTitle(String marketId, String fallback) =>
      _marketTitles[marketId] ?? (fallback.isNotEmpty ? fallback : marketId);
  void removeOrder(String orderId) {
    final before = _pendingOrders.length;
    _pendingOrders = _pendingOrders.where((o) => o.orderId != orderId).toList();
    if (_pendingOrders.length != before) notifyListeners();
  }
  // ── Lifecycle ─────────────────────────────────────────────────
  MarketTickerService() { _init(); }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _init() async {
    _disposed = false;
    _reconnectAttempts = 0;
    await _connect();
  }

  /// Extracts the user ID from a JWT token payload (base64 decoded).
  String? _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      // Base64url decode the payload (add padding if needed)
      var payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final padded = payload + '=' * ((4 - payload.length % 4) % 4);
      final decoded = utf8.decode(base64.decode(padded));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      // JWT uses 'id' or 'sub' or 'userId' — try all
      return (json['id'] ?? json['sub'] ?? json['userId'] ?? json['_id'])?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _connect() async {
    if (_disposed) return;
    try {
      final token  = await AuthStorage.instance.getToken() ?? '';
      final userId = _extractUserIdFromJwt(token) ?? '';
      // Mirror the JS client: pass both userId AND token as query params
      // Without userId the server returns account:null and skips portfolio_events
      final uri = Uri.parse('$_wsBase/socket/?userId=$userId&token=$token');
      debugPrint('📡 MarketTicker WS: $uri (userId=$userId)');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone:  ()  => _scheduleReconnect(),
        cancelOnError: false,
      );
      _reconnectAttempts = 0;
    } catch (e) {
      debugPrint('🔴 WS error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _sub?.cancel();
    _channel?.sink.close();
    final ms    = (1000 * (1 << _reconnectAttempts.clamp(0, 5))).clamp(1000, 30000);
    _reconnectAttempts++;
    debugPrint('🔄 WS reconnect in ${ms}ms');
    _reconnectTimer = Timer(Duration(milliseconds: ms), _connect);
  }

  // ── Message dispatch ──────────────────────────────────────────
  int _msgCount = 0;

  void _onMessage(dynamic raw) {
    try {
      final parsed = raw is String ? jsonDecode(raw) : raw;
      if (parsed is! Map) return;
      final msg  = _toStrMap(parsed);
      final type = msg['type'] as String?;
      debugPrint('📨 WS [$type]');

      // ── DIAGNOSTIC: print every non-market_event message in full ──────────
      if (type != 'market_event') {
        _msgCount++;
        final body = raw.toString();
        // Print in 800-char chunks so nothing is truncated
        debugPrint('🔬 MSG#$_msgCount type=$type len=${body.length}');
        for (int i = 0; i < body.length; i += 800) {
          debugPrint('  >${body.substring(i, i + 800 < body.length ? i + 800 : body.length)}');
        }
      }

      switch (type) {
        case 'snapshot':
          _handleSnapshot(msg);
        case 'market_event':
          _handleMarketEvent(_safeMap(msg['payload']));
        case 'account_state':
        // JS: parsed.data (also try parsed.account as some servers nest differently)
          _handleAccount(_safeMap(msg['data']) ?? _safeMap(msg['account']));
        case 'portfolio_events':
        // JS: parsed.payload — Array of {type, payload}
          _handlePortfolioEvents(msg['payload']);
        case 'order_event':
          _handleOrderEvent(_safeMap(msg['payload']));
        case 'order_events':
          final list = msg['payload'];
          if (list is List) {
            for (final ev in list) {
              _handleOrderEvent(_safeMap(ev));
            }
          }
        case 'trade_event':
          _handleTradeEvent(_safeMap(msg['payload']));
        case 'wallet_event':
          _handleWalletEvent(_safeMap(msg['payload']));
        default:
          debugPrint('⚠️  Unhandled WS type: $type | keys: ${msg.keys.toList()}');
      }
    } catch (e, st) {
      debugPrint('🔴 WS parse error: $e\n$st');
    }
  }

  // ── Snapshot ──────────────────────────────────────────────────
  void _handleSnapshot(Map<String, dynamic> msg) {
    // ── Market ticks ──────────────────────────────────────────
    final marketsRaw = msg['markets'];
    if (marketsRaw is Map) {
      for (final entry in marketsRaw.entries) {
        final mkt = _safeMap(entry.value);
        if (mkt == null) continue;
        _ticks[entry.key.toString()] = MarketTickData(
          bestBid: _toDouble(mkt['bestBid']),
          bestAsk: _toDouble(mkt['bestAsk']),
          ltp:     _toDouble(mkt['ltp']),
          volume:  _toDouble(mkt['volume']) ?? 0,
        );
      }
    }

    // ── Account: try msg.account AND msg.data AND msg top-level ──
    // The server may nest under 'account', 'data', or send at root.
    Map<String, dynamic>? account =
        _safeMap(msg['account']) ??
            _safeMap(msg['data']) ??
            _safeMap(msg['user']);

    debugPrint('🔍 snapshot keys: ${msg.keys.toList()}');
    debugPrint('🔍 account keys: ${account?.keys.toList()}');

    if (account != null) {
      _parseAccount(account);
    } else {
      // Try root-level portfolio keys (some servers flatten it)
      _parseAccount(msg);
    }

    notifyListeners();
  }

  // ── Market events ─────────────────────────────────────────────
  void _handleMarketEvent(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final marketId = payload['marketId']?.toString();
    if (marketId == null) return;
    final evType = payload['type'] as String?;
    final prev   = _ticks[marketId] ?? const MarketTickData();
    MarketTickData next = prev;

    if (evType == 'L2Snapshot') {
      final bids    = _parseSideKeys(payload['bids']);
      final asks    = _parseSideKeys(payload['asks']);
      final bestBid = bids.isEmpty ? null : bids.reduce((a, b) => a > b ? a : b);
      final bestAsk = asks.isEmpty ? null : asks.reduce((a, b) => a < b ? a : b);
      next = prev.copyWith(bestBid: bestBid, bestAsk: bestAsk);
    } else if (evType == 'BookTop') {
      next = prev.copyWith(
        bestBid: _toDouble(payload['bestBid']) ?? prev.bestBid,
        bestAsk: _toDouble(payload['bestAsk']) ?? prev.bestAsk,
      );
    } else if (evType == 'TradeCreated') {
      next = prev.copyWith(
        ltp:    _toDouble(payload['price']) ?? prev.ltp,
        volume: prev.volume + (_toDouble(payload['shares']) ?? 0),
      );
    } else if (evType == 'MarketStatusChanged') {
      return; // no tick update needed
    } else {
      return;
    }
    _ticks[marketId] = next;
    notifyListeners();
  }

  // ── Account ───────────────────────────────────────────────────
  void _handleAccount(Map<String, dynamic>? account) {
    if (account == null) return;
    debugPrint('🧾 account_state keys: ${account.keys.toList()}');
    _parseAccount(account);
    notifyListeners();
  }

  void _parseAccount(Map<String, dynamic> account) {
    // Balance
    _available        = _toDouble(account['available'] ?? account['balance'] ?? account['wallet']) ?? _available;
    _held             = _toDouble(account['held'] ?? account['reserved'])   ?? _held;
    _isTradingEnabled = account['isTradingEnabled'] as bool? ?? _isTradingEnabled;

    // ── Open positions ────────────────────────────────────────
    // Server may use: openPositions | positions | open_positions
    final posRaw = account['openPositions'] ?? account['positions'] ?? account['open_positions'];
    debugPrint('🧾 posRaw type=${posRaw.runtimeType} len=${posRaw is List ? posRaw.length : posRaw is Map ? posRaw.length : "null"}');
    if (posRaw is List && posRaw.isNotEmpty) {
      _openPositions = posRaw
          .map(_safeMap)
          .whereType<Map<String, dynamic>>()
          .map(_enrichWithTitle)
          .map(OpenPosition.fromJson)
          .toList();
      debugPrint('✅ openPositions=${_openPositions.length}');
    } else if (posRaw is Map && posRaw.isNotEmpty) {
      // Sometimes positions come as { marketId: { YES: {...}, NO: {...} } }
      _openPositions = posRaw.entries.expand((entry) {
        final marketId = entry.key.toString();
        final byOutcome = _safeMap(entry.value);
        if (byOutcome == null) return <OpenPosition>[];
        return byOutcome.entries.map((outEntry) {
          final posMap = _safeMap(outEntry.value);
          if (posMap == null) return null;
          return OpenPosition.fromJson({
            'marketId': marketId,
            'side': outEntry.key,
            ...posMap,
          });
        }).whereType<OpenPosition>();
      }).where((p) => p.shares > 0).toList();
      debugPrint('✅ openPositions (from Map)=${_openPositions.length}');
    }

    // ── Open orders ───────────────────────────────────────────
    // Server may use: openOrders | pendingOrders | orders | open_orders
    final ordRaw = account['openOrders'] ?? account['pendingOrders'] ?? account['open_orders'];
    debugPrint('🧾 ordRaw type=${ordRaw.runtimeType}');
    if (ordRaw != null) _parsePendingOrders(ordRaw);

    // ── Closed trades ─────────────────────────────────────────
    // Server may use: closedTrades | closed_trades | orderHistory | tradeHistory
    final ctRaw = account['closedTrades'] ?? account['closed_trades'] ?? account['tradeHistory'];
    debugPrint('🧾 ctRaw type=${ctRaw.runtimeType} len=${ctRaw is List ? ctRaw.length : "null"}');
    if (ctRaw is List && ctRaw.isNotEmpty) {
      _closedTrades = ctRaw
          .map(_safeMap)
          .whereType<Map<String, dynamic>>()
          .map(_enrichWithTitle)
          .map(ClosedTrade.fromJson)
          .toList();
      debugPrint('✅ closedTrades=${_closedTrades.length}');
    }

    // ── Order history (fallback for closed trades) ────────────
    final ohRaw = account['orderHistory'] ?? account['order_history'];
    if (ohRaw is List) {
      _orderHistory = ohRaw.map(_safeMap).whereType<Map<String, dynamic>>().toList();
      // If closedTrades is empty but orderHistory has FILLED orders, use those
      if (_closedTrades.isEmpty && _orderHistory.isNotEmpty) {
        final filled = _orderHistory.where((o) {
          final s = o['status']?.toString().toUpperCase() ?? '';
          return s == 'FILLED' || s == 'CLOSED' || s == 'SETTLED';
        }).toList();
        if (filled.isNotEmpty) {
          _closedTrades = filled.map(_enrichWithTitle).map(ClosedTrade.fromJson).toList();
          debugPrint('✅ closedTrades from orderHistory=${_closedTrades.length}');
        }
      }
    }
  }

  void _parsePendingOrders(dynamic raw) {
    if (raw == null) return;
    List<Map<String, dynamic>> maps = [];
    if (raw is Map) {
      // Map<orderId, orderObj> — inject orderId into each entry since it may be missing
      maps = raw.entries
          .map((e) {
        final obj = _safeMap(e.value);
        if (obj == null) return null;
        // Ensure orderId is present inside the order object
        if (obj['orderId'] == null && obj['id'] == null) {
          return {...obj, 'orderId': e.key.toString()};
        }
        return obj;
      })
          .whereType<Map<String, dynamic>>()
          .toList();
    } else if (raw is List) {
      maps = raw
          .map((e) => _safeMap(e))
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    // Always update (even empty list clears stale orders after all are cancelled)
    _pendingOrders = maps.map(_enrichWithTitle).map(PendingOrder.fromJson).toList();
    debugPrint('✅ pendingOrders=${_pendingOrders.length}');
  }

  // ── Portfolio events (JS: portfolio_events) ───────────────────
  void _handlePortfolioEvents(dynamic payload) {
    if (payload is! List) return;
    bool changed = false;

    for (final item in payload) {
      final ev = _safeMap(item);
      if (ev == null) continue;
      final evType = ev['type']?.toString();
      final data   = ev['payload'];
      debugPrint('📦 portfolio_event: $evType | data type: ${data.runtimeType}');

      switch (evType) {
        case 'open_positions':
          if (data is List) {
            _openPositions = data
                .map((e) => _safeMap(e))
                .whereType<Map<String, dynamic>>()
                .map(_enrichWithTitle)
                .map(OpenPosition.fromJson)
                .toList();
            debugPrint('✅ openPositions set: ${_openPositions.length}');
            changed = true;
          }
        case 'open_orders':
          _parsePendingOrders(data);
          changed = true;
        case 'closed_trades':
          if (data is List) {
            _closedTrades = data
                .map((e) => _safeMap(e))
                .whereType<Map<String, dynamic>>()
                .map(_enrichWithTitle)
                .map(ClosedTrade.fromJson)
                .toList();
            debugPrint('✅ closedTrades set: ${_closedTrades.length}');
            changed = true;
          }
        case 'order_history':
          if (data is List) {
            _orderHistory = data
                .map((e) => _safeMap(e))
                .whereType<Map<String, dynamic>>()
                .toList();
            changed = true;
          }
      }
    }
    if (changed) notifyListeners();
  }

  // ── Order event ───────────────────────────────────────────────
  void _handleOrderEvent(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final type    = payload['type']?.toString();
    final orderId = payload['orderId']?.toString();
    if (orderId == null) return;
    debugPrint('📋 order_event: $type orderId=$orderId');

    switch (type) {
      case 'OrderAccepted':
        final order = PendingOrder.fromJson({
          ..._enrichWithTitle(payload),
          'status': payload['status'] ?? 'ACKED',
        });
        final idx = _pendingOrders.indexWhere((o) => o.orderId == orderId);
        if (idx >= 0) {
          _pendingOrders[idx] = order;
        } else {
          _pendingOrders = [order, ..._pendingOrders];
        }
      case 'OrderPartiallyFilled':
        final idx = _pendingOrders.indexWhere((o) => o.orderId == orderId);
        if (idx >= 0) {
          _pendingOrders[idx] = _pendingOrders[idx].copyWith(
            filledQty: (_toDouble(payload['filledQty']) ?? 0).toInt(),
            status:    'PARTIALLY_FILLED',
          );
        }
      case 'OrderFilled':
        final removed = _pendingOrders.where((o) => o.orderId == orderId).firstOrNull;
        _pendingOrders.removeWhere((o) => o.orderId == orderId);
        _closedTrades = [
          ClosedTrade.fromJson({
            ...?removed != null ? {
              'marketId': removed!.marketId,
              'marketTitle': removed.marketTitle,
              'side': removed.side,
              'action': removed.action,
            } : {},
            ..._enrichWithTitle(payload),
            'status': 'FILLED',
          }),
          ..._closedTrades,
        ];
      case 'OrderCanceled':
      case 'OrderRejected':
        _pendingOrders.removeWhere((o) => o.orderId == orderId);
    }
    notifyListeners();
  }

  // ── Trade event ───────────────────────────────────────────────
  void _handleTradeEvent(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final marketId = payload['marketId']?.toString();
    if (marketId != null) {
      final prev = _ticks[marketId] ?? const MarketTickData();
      _ticks[marketId] = prev.copyWith(
        ltp:    _toDouble(payload['price']) ?? prev.ltp,
        volume: prev.volume + (_toDouble(payload['shares']) ?? 0),
      );
    }
    notifyListeners();
  }

  // ── Wallet event ──────────────────────────────────────────────
  void _handleWalletEvent(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final currency = payload['currency']?.toString() ?? 'USD';
    if (currency != 'USD') return;

    if (payload['available'] != null) {
      _available = _toDouble(payload['available']) ?? _available;
    } else if (payload['deltaAvailable'] != null) {
      _available += _toDouble(payload['deltaAvailable']) ?? 0;
    }
    if (payload['held'] != null) {
      _held = _toDouble(payload['held']) ?? _held;
    } else if (payload['deltaHeld'] != null) {
      _held += _toDouble(payload['deltaHeld']) ?? 0;
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Inject marketTitle from cache if the JSON doesn't have it
  Map<String, dynamic> _enrichWithTitle(Map<String, dynamic> j) {
    final mid = j['marketId']?.toString() ?? '';
    if (mid.isNotEmpty && (j['marketTitle'] == null || j['marketTitle'].toString().isEmpty)) {
      final title = _marketTitles[mid];
      if (title != null && title.isNotEmpty) {
        return {...j, 'marketTitle': title};
      }
    }
    return j;
  }

  Map<String, dynamic>? _safeMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<double> _parseSideKeys(dynamic raw) {
    if (raw == null) return [];
    if (raw is Map) {
      return raw.keys.map((k) => double.tryParse(k.toString())).whereType<double>().toList();
    }
    if (raw is List) {
      return raw.map((row) {
        if (row is List && row.isNotEmpty) return _toDouble(row[0]);
        if (row is Map) return _toDouble(row['price']);
        return null;
      }).whereType<double>().toList();
    }
    return [];
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}