// lib/Services/OrderBookService.dart
//
// Connects to the same WebSocket the website uses.
// URL: wss://<host>?userId=<id>&token=<jwt>
// Handles:
//   snapshot        → full L2 book per market
//   market_event    → L2Snapshot / BookTop / TradeCreated per market
//   account_state   → balance updates (ignored here)

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/Models/OrderBookModel.dart';

typedef OrderBookCallback = void Function(OrderBook book);

class OrderBookService {
  static const String _wsBase =
      'wss://staging-api.predict365.com'; // same host, ws scheme

  WebSocketChannel?     _channel;
  StreamSubscription?   _sub;
  Timer?                _reconnectTimer;
  int                   _reconnectAttempts = 0;
  bool                  _disposed = false;

  final String            marketId;
  final OrderBookCallback onBook;

  // Raw maps kept in sync with incoming events
  final Map<String, double> _bids = {};
  final Map<String, double> _asks = {};
  double? _bestBid;
  double? _bestAsk;
  double? _ltp;

  OrderBookService({required this.marketId, required this.onBook});

  // ── Public API ────────────────────────────────────────────────
  Future<void> connect() async {
    _disposed = false;
    _reconnectAttempts = 0;
    await _connect();
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
  }

  // ── Internal ──────────────────────────────────────────────────
  Future<void> _connect() async {
    if (_disposed) return;
    try {
      final token  = await AuthStorage.instance.getToken() ?? '';
      // userId stored in token claims — the server also accepts it as query param
      // We pass token; userId is optional but helps the server filter events
      final uri = Uri.parse('$_wsBase/socket/?token=$token');
      debugPrint('🔌 WS connecting: $uri');

      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone:  ()  => _scheduleReconnect(),
        cancelOnError: false,
      );
      _reconnectAttempts = 0;
    } catch (e) {
      debugPrint('🔴 WS connect error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _sub?.cancel();
    _channel?.sink.close();
    final delay = Duration(
      milliseconds: (1000 * (1 << _reconnectAttempts.clamp(0, 5))).clamp(1000, 30000),
    );
    _reconnectAttempts++;
    debugPrint('🔄 WS reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    _reconnectTimer = Timer(delay, _connect);
  }

  void _onMessage(dynamic raw) {
    try {
      final parsed = raw is String ? jsonDecode(raw) : raw;
      if (parsed is! Map<String, dynamic>) return;

      final type = parsed['type'] as String?;

      if (type == 'snapshot') {
        // Full snapshot: markets map keyed by marketId
        final markets = parsed['markets'] as Map<String, dynamic>? ?? {};
        final mkt = markets[marketId] as Map<String, dynamic>?;
        if (mkt != null) _applyMarketSnapshot(mkt);

      } else if (type == 'market_event') {
        final payload = parsed['payload'] as Map<String, dynamic>?;
        if (payload == null) return;
        if (payload['marketId'] != marketId) return;
        _applyMarketEvent(payload);
      }
    } catch (e) {
      debugPrint('🔴 WS parse error: $e');
    }
  }

  void _applyMarketSnapshot(Map<String, dynamic> mkt) {
    _bids.clear();
    _asks.clear();
    _parseSide(mkt['bids'], _bids);
    _parseSide(mkt['asks'], _asks);
    _bestBid = _toDouble(mkt['bestBid']);
    _bestAsk = _toDouble(mkt['bestAsk']);
    _ltp     = _toDouble(mkt['ltp']);
    _emit();
  }

  void _applyMarketEvent(Map<String, dynamic> payload) {
    final evType = payload['type'] as String?;

    if (evType == 'L2Snapshot') {
      _bids.clear();
      _asks.clear();
      _parseSide(payload['bids'], _bids);
      _parseSide(payload['asks'], _asks);
      // recompute best
      _bestBid = _bids.isEmpty
          ? null
          : _bids.keys.map(double.parse).reduce((a, b) => a > b ? a : b);
      _bestAsk = _asks.isEmpty
          ? null
          : _asks.keys.map(double.parse).reduce((a, b) => a < b ? a : b);
      _emit();

    } else if (evType == 'BookTop') {
      _bestBid = _toDouble(payload['bestBid']) ?? _bestBid;
      _bestAsk = _toDouble(payload['bestAsk']) ?? _bestAsk;
      _emit();

    } else if (evType == 'TradeCreated') {
      _ltp = _toDouble(payload['price']) ?? _ltp;
      _emit();
    }
  }

  /// Accepts both Array and Object formats for bids/asks
  void _parseSide(dynamic raw, Map<String, double> out) {
    if (raw == null) return;
    if (raw is List) {
      for (final row in raw) {
        double? price, shares;
        if (row is List && row.length >= 2) {
          price  = _toDouble(row[0]);
          shares = _toDouble(row[1]);
        } else if (row is Map) {
          price  = _toDouble(row['price']);
          shares = _toDouble(row['shares'] ?? row['qty']);
        }
        if (price != null && shares != null && shares > 0) {
          out[price.toString()] = shares;
        }
      }
    } else if (raw is Map) {
      for (final e in raw.entries) {
        final p = double.tryParse(e.key.toString());
        final s = _toDouble(e.value);
        if (p != null && s != null && s > 0) out[p.toString()] = s;
      }
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  void _emit() {
    if (_disposed) return;
    final book = OrderBook.fromMaps(
      bidsMap: Map.of(_bids),
      asksMap: Map.of(_asks),
      bestBid: _bestBid,
      bestAsk: _bestAsk,
      ltp:     _ltp,
    );
    onBook(book);
  }
}