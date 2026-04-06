// lib/PredictScreens/PredictionDetailScreens/Chart/LiveCryptoChart.dart
//
// Live chart for "continuous" events — mirrors the website's gold line
// chart with Binance WebSocket price feed.
//
// Features:
//   • Fetches last 60 minutes of 1m klines from Binance REST on init
//   • Subscribes to wss://stream.binance.com:9443/ws/{symbol}@trade
//   • Draws gold (#F5A623) area/line chart with CustomPainter
//   • Animated pulsing dot on the latest price point
//   • Crosshair tooltip on long-press
//   • Auto-reconnects on disconnect (exponential back-off)

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

// ── Data model ────────────────────────────────────────────────────
class _Tick {
  final int    time;   // epoch seconds
  final double value;
  const _Tick(this.time, this.value);
}

// ═════════════════════════════════════════════════════════════════
// PUBLIC WIDGET
// ═════════════════════════════════════════════════════════════════
class LiveCryptoChart extends StatefulWidget {
  final String symbol;   // e.g. "USDJPY", "BTCUSDT"
  final double height;

  const LiveCryptoChart({
    super.key,
    required this.symbol,
    this.height = 200,
  });

  @override
  State<LiveCryptoChart> createState() => _LiveCryptoChartState();
}

class _LiveCryptoChartState extends State<LiveCryptoChart>
    with TickerProviderStateMixin {

  static const _gold     = Color(0xFFF5A623);
  static const _wsBase   = 'wss://stream.binance.com:9443/ws';
  static const _restBase = 'https://api.binance.com/api/v3/klines';

  // ── State ─────────────────────────────────────────────────────
  final List<_Tick> _data   = [];
  bool  _loading             = true;
  String? _error;

  // ── Crosshair ─────────────────────────────────────────────────
  _Tick?  _hoverTick;
  double? _hoverX;

  // ── Ripple animation ──────────────────────────────────────────
  late AnimationController _ripple;
  int _lastWsUpdateMs = 0;

  // ── WebSocket ─────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _disposed = false;

  // ── Normalise symbol → Binance format (e.g. BTCUSDT, ETHUSDT) ─
  String get _normalisedSymbol {
    var raw = widget.symbol.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9/]'), '');
    // Handle slash-separated pairs: BTC/USDT → BTCUSDT
    if (raw.contains('/')) {
      final parts = raw.split('/');
      raw = '${parts[0]}${parts[1]}';
    }
    // Already has USDT suffix
    if (raw.endsWith('USDT')) return raw;
    // Has USD suffix — swap to USDT
    if (raw.endsWith('USD')) return '${raw.substring(0, raw.length - 3)}USDT';
    // Bare symbol like BTC, ETH, SOL → append USDT
    return '${raw}USDT';
  }

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    debugPrint('=== LiveCryptoChart INIT raw="${widget.symbol}" normalised="$_normalisedSymbol"');
    _fetchHistory();
    _connectWs();
  }

  @override
  void didUpdateWidget(LiveCryptoChart old) {
    super.didUpdateWidget(old);
    if (old.symbol != widget.symbol) {
      _data.clear();
      setState(() { _loading = true; _error = null; });
      _disconnectWs();
      _fetchHistory();
      _connectWs();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _ripple.dispose();
    _disconnectWs();
    super.dispose();
  }

  // ── History fetch ─────────────────────────────────────────────
  Future<void> _fetchHistory() async {
    debugPrint('=== LiveCryptoChart FETCH sym=${widget.symbol} normalised=$_normalisedSymbol');
    try {
      final now   = DateTime.now().millisecondsSinceEpoch;
      final start = now - const Duration(hours: 1).inMilliseconds;
      final uri   = Uri.parse('$_restBase?symbol=$_normalisedSymbol'
          '&interval=1m&startTime=$start&endTime=$now&limit=60');

      debugPrint('=== LiveCryptoChart REST: $uri');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('=== LiveCryptoChart HTTP ${res.statusCode} body=${res.body.substring(0, res.body.length.clamp(0, 200))}');
      if (!mounted) return;

      if (res.statusCode == 200) {
        final rows = jsonDecode(res.body) as List<dynamic>;
        final ticks = rows.map((r) {
          final time  = ((r[0] as int) / 1000).floor();
          final value = double.parse(r[4].toString()); // close price
          return _Tick(time, value);
        }).toList();
        debugPrint('=== LiveCryptoChart loaded ${ticks.length} ticks');
        if (mounted) setState(() { _data.addAll(ticks); _loading = false; });
      } else {
        if (mounted) setState(() { _loading = false; });
      }
    } catch (e) {
      debugPrint('=== LiveCryptoChart FETCH ERROR: $e');
      if (mounted) setState(() { _loading = false; });
    }
  }

  // ── WebSocket ─────────────────────────────────────────────────
  void _connectWs() {
    if (_disposed) return;
    final sym = _normalisedSymbol.toLowerCase();
    try {
      // Use kline_1m stream — same 1-min candle format as REST history
      final uri = Uri.parse('$_wsBase/${sym}@kline_1m');
      debugPrint('=== LiveCryptoChart WS: $uri');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone:  ()  => _scheduleReconnect(),
        cancelOnError: false,
      );
      _reconnectAttempts = 0;
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _disconnectWs() {
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _sub?.cancel();
    _channel?.sink.close();
    final delay = Duration(
      milliseconds: min(30000, (1000 * pow(2, _reconnectAttempts)).toInt()),
    );
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, _connectWs);
  }

  void _onWsMessage(dynamic raw) {
    // kline_1m message shape:
    // { "e":"kline", "k": { "t": openTimeMs, "c": "closePrice", "x": isClosed } }
    try {
      final msg = raw is String ? jsonDecode(raw) : raw as Map<String, dynamic>;
      final k   = msg['k'] as Map<String, dynamic>?;
      if (k == null) return;

      final price = double.tryParse(k['c']?.toString() ?? ''); // close price
      final tsMs  = k['t'] as int?;                            // candle open time ms
      if (price == null || tsMs == null || price <= 0) return;

      final time = (tsMs / 1000).floor(); // seconds

      if (!mounted) return;
      // Throttle setState to max once per second
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - _lastWsUpdateMs < 1000 && _data.isNotEmpty) {
        // Update silently — upsert the candle in place
        if (_data.isNotEmpty && _data.last.time == time) {
          _data[_data.length - 1] = _Tick(time, price);
        }
        return;
      }
      _lastWsUpdateMs = nowMs;
      setState(() {
        if (_data.isNotEmpty && _data.last.time == time) {
          // Update existing candle (in-progress candle keeps updating)
          _data[_data.length - 1] = _Tick(time, price);
        } else {
          // New candle
          _data.add(_Tick(time, price));
          if (_data.length > 300) _data.removeAt(0);
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint('=== LiveCryptoChart _onWsMessage error: $e');
    }
  }

  // ── Crosshair ─────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails d, double chartW, double leftPad) {
    final x = d.localPosition.dx - leftPad;
    if (_data.isEmpty) return;
    final idx = ((x / chartW) * (_data.length - 1)).round().clamp(0, _data.length - 1);
    setState(() {
      _hoverTick = _data[idx];
      _hoverX    = leftPad + (idx / (_data.length - 1).clamp(1, 9999)) * chartW;
    });
  }

  void _onPanEnd(_) => setState(() { _hoverTick = null; _hoverX = null; });

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const leftPad   = 8.0;
    const rightPad  = 52.0;
    const topPad    = 16.0;
    const bottomPad = 28.0;

    if (_loading) return _skeleton();
    if (_data.isEmpty) return _empty();

    return Container(
      width:  double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color:       Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2A30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(builder: (context, constraints) {
          final w      = constraints.maxWidth;
          final h      = constraints.maxHeight;
          final chartW = w - leftPad - rightPad;
          final chartH = h - topPad - bottomPad;

          return GestureDetector(
            onPanUpdate: (d) => _onPanUpdate(d, chartW, leftPad),
            onPanEnd:    _onPanEnd,
            onTapUp:     (_) => _onPanEnd(null),
            child: Stack(children: [

              // ── Chart painter ──────────────────────────────────
              CustomPaint(
                size: Size(w, h),
                painter: _ChartPainter(
                  data:      _data,
                  hoverX:    _hoverX,
                  leftPad:   leftPad,
                  rightPad:  rightPad,
                  topPad:    topPad,
                  bottomPad: bottomPad,
                ),
              ),

              // ── Ripple dot ─────────────────────────────────────
              AnimatedBuilder(
                animation: _ripple,
                builder: (_, __) {
                  if (_data.isEmpty) return const SizedBox.shrink();
                  final last = _data.last;
                  final vals = _data.map((d) => d.value).toList();
                  final minV = vals.reduce(min);
                  final maxV = vals.reduce(max);
                  final rng  = (maxV - minV).clamp(0.001, double.infinity);
                  final dotX = leftPad + chartW;
                  final dotY = topPad + (1 - (last.value - minV) / rng) * chartH;
                  final phase2 = (_ripple.value + 0.45) % 1.0;
                  return CustomPaint(
                    size: Size(w, h),
                    painter: _RipplePainter(
                      cx: dotX, cy: dotY,
                      phase1: _ripple.value,
                      phase2: phase2,
                    ),
                  );
                },
              ),

              // ── Hover tooltip ──────────────────────────────────
              if (_hoverTick != null && _hoverX != null)
                _buildTooltip(_hoverTick!, _hoverX!, w),
            ]),
          );
        }),
      ),
    );
  }

  Widget _buildTooltip(_Tick tick, double x, double totalW) {
    final dt    = DateTime.fromMillisecondsSinceEpoch(tick.time * 1000).toLocal();
    final price = tick.value.toStringAsFixed(tick.value > 100 ? 2 : 4);
    final time  = '${_pad(dt.hour % 12 == 0 ? 12 : dt.hour % 12)}:'
        '${_pad(dt.minute)} ${dt.hour < 12 ? 'AM' : 'PM'}';

    double left = x - 50;
    left = left.clamp(8.0, totalW - 108.0);

    return Positioned(
      top: 4, left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:  const Color(0xDD141414),
          border: Border.all(color: const Color(0x4DF5A623)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color:  _gold,
                  shape:  BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text('\$$price',
                  style: const TextStyle(
                      color: Color(0xFFF3F4F6), fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
            Text(time,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  Widget _skeleton() => Container(
    width: double.infinity, height: widget.height,
    decoration: BoxDecoration(
      color: const Color(0xFF0D1117),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(
            color: Color(0xFFF5A623), strokeWidth: 2),
      ),
    ),
  );

  Widget _empty() => Container(
    width: double.infinity, height: widget.height,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColorDark,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: Text('No live data available',
          style: TextStyle(color: Color(0xFF4A6670), fontSize: 13)),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════
// CHART PAINTER
// ═════════════════════════════════════════════════════════════════
class _ChartPainter extends CustomPainter {
  final List<_Tick> data;
  final double? hoverX;
  final double leftPad, rightPad, topPad, bottomPad;

  const _ChartPainter({
    required this.data,
    required this.hoverX,
    required this.leftPad,
    required this.rightPad,
    required this.topPad,
    required this.bottomPad,
  });

  static const _gold = Color(0xFFF5A623);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartW = size.width  - leftPad - rightPad;
    final chartH = size.height - topPad  - bottomPad;

    // ── Value range ───────────────────────────────────────────
    var minV = data.map((d) => d.value).reduce(min);
    var maxV = data.map((d) => d.value).reduce(max);
    final rng = maxV - minV;
    if (rng < 0.00001) { minV -= 0.01; maxV += 0.01; }
    else { minV -= rng * 0.08; maxV += rng * 0.08; }
    final yRng = maxV - minV;

    double xOf(int i) =>
        leftPad + (i / (data.length - 1).clamp(1, 99999)) * chartW;
    double yOf(double v) =>
        topPad + (1 - (v - minV) / yRng) * chartH;

    // ── Grid lines ────────────────────────────────────────────
    final gridPaint = Paint()
      ..color       = const Color(0xFF1A2530)
      ..strokeWidth = 0.7;
    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = yOf(minV + yRng * i / gridCount);
      canvas.drawLine(Offset(leftPad, y),
          Offset(size.width - rightPad, y), gridPaint);
    }

    // ── Y labels ──────────────────────────────────────────────
    final labelStyle = const TextStyle(
        color: Color(0xFF6B7280), fontSize: 9.5,
        fontFamily: 'monospace');
    for (int i = 0; i <= gridCount; i++) {
      final v = minV + yRng * i / gridCount;
      final y = yOf(v);
      // choose decimal places based on magnitude
      final decimals = v > 100 ? 2 : v > 1 ? 3 : 4;
      _txt(canvas, v.toStringAsFixed(decimals), labelStyle,
          Offset(size.width - rightPad + 6, y - 6));
    }

    // ── X labels ──────────────────────────────────────────────
    final xStyle = const TextStyle(
        color: Color(0xFF6B7280), fontSize: 9, fontFamily: 'monospace');
    const xCount = 4;
    for (int li = 0; li < xCount; li++) {
      final idx  = (li * (data.length - 1) / (xCount - 1).clamp(1, 9999)).round();
      final x    = xOf(idx);
      final dt   = DateTime.fromMillisecondsSinceEpoch(data[idx].time * 1000).toLocal();
      final lbl  = '${_pad(dt.hour % 12 == 0 ? 12 : dt.hour % 12)}:${_pad(dt.minute)}'
          ' ${dt.hour < 12 ? 'AM' : 'PM'}';
      _txt(canvas, lbl, xStyle, Offset(x - 18, size.height - bottomPad + 7));
    }

    // ── Area fill ─────────────────────────────────────────────
    final fillPath = Path();
    fillPath.moveTo(xOf(0), yOf(data[0].value));
    for (int i = 1; i < data.length; i++) {
      fillPath.lineTo(xOf(i), yOf(data[i].value));
    }
    final lastX = xOf(data.length - 1);
    final baseY = topPad + chartH;
    fillPath.lineTo(lastX, baseY);
    fillPath.lineTo(xOf(0), baseY);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            _gold.withValues(alpha: 0.18),
            _gold.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH)),
    );

    // ── Line ──────────────────────────────────────────────────
    final linePath = Path();
    linePath.moveTo(xOf(0), yOf(data[0].value));
    for (int i = 1; i < data.length; i++) {
      linePath.lineTo(xOf(i), yOf(data[i].value));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color       = _gold
        ..strokeWidth = 1.8
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round,
    );

    // ── Dashed baseline (price to beat) ───────────────────────
    final baselineY = yOf(data.first.value);
    final dashPaint  = Paint()
      ..color       = _gold.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    double dashX = leftPad;
    while (dashX < size.width - rightPad) {
      canvas.drawLine(
          Offset(dashX, baselineY), Offset(dashX + 6, baselineY), dashPaint);
      dashX += 10;
    }

    // ── Crosshair ─────────────────────────────────────────────
    if (hoverX != null) {
      final vline = Paint()
        ..color       = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(
          Offset(hoverX!, topPad),
          Offset(hoverX!, topPad + chartH), vline);
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  void _txt(Canvas canvas, String text, TextStyle style, Offset offset) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data.length != data.length ||
          old.hoverX != hoverX ||
          (data.isNotEmpty && old.data.isNotEmpty &&
              old.data.last.value != data.last.value);
}

// ═════════════════════════════════════════════════════════════════
// RIPPLE PAINTER — animating dot on latest price
// ═════════════════════════════════════════════════════════════════
class _RipplePainter extends CustomPainter {
  final double cx, cy, phase1, phase2;
  const _RipplePainter(
      {required this.cx, required this.cy,
        required this.phase1, required this.phase2});

  static const _gold  = Color(0xFFF5A623);
  static const dotR   = 4.5;
  static const ringMax = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Outer rings
    for (final phase in [phase1, phase2]) {
      canvas.drawCircle(
        Offset(cx, cy),
        dotR + (ringMax - dotR) * phase,
        Paint()
          ..color       = _gold.withValues(alpha: (1 - phase) * 0.5)
          ..strokeWidth = 1.5
          ..style       = PaintingStyle.stroke,
      );
    }
    // Dark halo
    canvas.drawCircle(Offset(cx, cy), dotR + 2,
        Paint()..color = const Color(0xAA0D1117));
    // Gold dot
    canvas.drawCircle(Offset(cx, cy), dotR,
        Paint()..color = _gold);
    // Inner dark centre
    canvas.drawCircle(Offset(cx, cy), 1.8,
        Paint()..color = const Color(0xFF111111));
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.phase1 != phase1 || old.phase2 != phase2 ||
          old.cx != cx || old.cy != cy;
}