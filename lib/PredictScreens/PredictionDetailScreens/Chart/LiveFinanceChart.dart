// lib/PredictScreens/PredictionDetailScreens/Chart/LiveFinanceChart.dart
//
// Live chart for finance markets (forex / stocks / commodities).
// WS: wss://staging-api.predict365.com/api/finance-data/ws?symbols=USDJPY
//
// Message shape expected:
//   { type: "finance_tick", quotes: [{ symbol, price, timestamp, currency }] }

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:predict365/AuthStorage/authStorage.dart';

// ── Data model ────────────────────────────────────────────────────
class _Tick {
  final int    time;
  final double value;
  const _Tick(this.time, this.value);
}

// ═════════════════════════════════════════════════════════════════
// PUBLIC WIDGET
// ═════════════════════════════════════════════════════════════════
class LiveFinanceChart extends StatefulWidget {
  final String symbol;   // e.g. "USDJPY", "EURUSD"
  final double height;

  const LiveFinanceChart({
    super.key,
    required this.symbol,
    this.height = 200,
  });

  @override
  State<LiveFinanceChart> createState() => _LiveFinanceChartState();
}

class _LiveFinanceChartState extends State<LiveFinanceChart>
    with TickerProviderStateMixin {

  static const _gold    = Color(0xFFF5A623);
  static const _wsBase  =
      'wss://staging-api.predict365.com/api/finance-data/ws';
  static const _restBase =
      'https://staging-api.predict365.com/api/finance-data/history';

  final List<_Tick> _data   = [];
  bool  _loading             = true;

  // Crosshair
  _Tick?  _hoverTick;
  double? _hoverX;

  // Ripple — single controller, phase2 offset applied in painter
  late AnimationController _ripple;
  // WS throttle — don't setState more than once per second
  int _lastWsUpdateMs = 0;

  // WS
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _attempts = 0;
  bool _disposed = false;

  String get _sym => widget.symbol.trim().toUpperCase();

  /// Yahoo Finance format: USDJPY → USDJPY=X, XAUUSD → GC=F, etc.
  String get _yahooSym {
    final s = _sym;
    // Already has suffix
    if (s.contains('=') || s.contains('.')) return s;
    // Commodities
    if (s == 'XAUUSD' || s == 'GOLD') return 'GC=F';
    if (s == 'XAGUSD' || s == 'SILVER') return 'SI=F';
    if (s == 'CRUDEOIL' || s == 'OIL') return 'CL=F';
    // Forex pairs (6 chars, no digits) → append =X
    if (s.length == 6 && RegExp(r'^[A-Z]+$').hasMatch(s)) return '$s=X';
    // Indices
    if (s == 'SPX' || s == 'SP500') return '^GSPC';
    if (s == 'NDX' || s == 'NASDAQ') return '^IXIC';
    if (s == 'DJI' || s == 'DOW') return '^DJI';
    // Default: return as-is
    return s;
  }

  @override
  void initState() {
    super.initState();
    _ripple = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _fetchHistory();
    _connectWs();
  }

  @override
  void didUpdateWidget(LiveFinanceChart old) {
    super.didUpdateWidget(old);
    if (old.symbol != widget.symbol) {
      _data.clear();
      setState(() { _loading = true; });
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

  // ── History ───────────────────────────────────────────────────
  Future<void> _fetchHistory() async {
    try {
      final token = await AuthStorage.instance.getToken() ?? '';
      final uri   = Uri.parse(
          '$_restBase/${Uri.encodeComponent(_yahooSym)}?interval=5m&timeframe=1d');
      debugPrint('=== LiveFinanceChart FETCH sym=$_sym yahoo=$_yahooSym uri=$uri');
      final res   = await http.get(uri, headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 10));

      debugPrint('=== LiveFinanceChart HTTP ${res.statusCode}');
      debugPrint('=== body preview: ${res.body.substring(0, res.body.length.clamp(0, 200))}');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final body    = jsonDecode(res.body) as Map<String, dynamic>;
        final candles = (body['candles'] as List<dynamic>? ?? []);
        final ticks   = candles.map((c) {
          final t = c['time'];
          final v = double.tryParse(c['close']?.toString() ?? '') ?? 0.0;
          int epoch;
          if (t is int) {
            epoch = t > 1e10 ? (t ~/ 1000) : t; // ms → s
          } else {
            epoch = DateTime.tryParse(t.toString())
                !.millisecondsSinceEpoch ~/ 1000 ?? 0;
          }
          return _Tick(epoch, v);
        }).where((t) => t.value > 0).toList();

        if (mounted) setState(() { _data.addAll(ticks); _loading = false; });
      } else {
        if (mounted) setState(() { _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // ── WebSocket ─────────────────────────────────────────────────
  Future<void> _connectWs() async {
    if (_disposed) return;
    try {
      final token = await AuthStorage.instance.getToken() ?? '';
      final uri   = Uri.parse(
          '$_wsBase?symbols=${Uri.encodeComponent(_yahooSym)}'
              '${token.isNotEmpty ? '&token=$token' : ''}');
      debugPrint('=== LiveFinanceChart WS: $uri');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onMsg,
        onError: (_) => _scheduleReconnect(),
        onDone:  ()  => _scheduleReconnect(),
        cancelOnError: false,
      );
      _attempts = 0;
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
    final ms = min(30000, (1000 * pow(2, _attempts)).toInt());
    _attempts++;
    _reconnectTimer = Timer(Duration(milliseconds: ms), _connectWs);
  }

  void _onMsg(dynamic raw) {
    try {
      final msg  = raw is String ? jsonDecode(raw) : raw as Map<String, dynamic>;
      if (msg['type'] != 'finance_tick') return;
      final quotes = msg['quotes'] as List<dynamic>? ?? [];
      // Match on either the raw sym OR the yahoo sym (server echoes back yahoo format)
      final q = quotes.firstWhere(
            (q) {
          final s = (q['symbol'] as String?)?.toUpperCase() ?? '';
          return s == _sym || s == _yahooSym;
        },
        orElse: () => null,
      );
      if (q == null) return;
      // Check for server-side error
      if (q['error'] != null) {
        debugPrint('=== LiveFinanceChart price error: ${q['error']}');
        return;
      }
      final price = double.tryParse(q['price']?.toString() ?? '');
      if (price == null || price <= 0) return;
      final tsRaw = q['timestamp'];
      int ts;
      if (tsRaw is int) {
        ts = tsRaw > 1e10 ? (tsRaw ~/ 1000) : tsRaw;
      } else {
        ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      if (!mounted) return;
      // Throttle setState to max once per second to avoid buffer overflow
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - _lastWsUpdateMs < 1000 && _data.isNotEmpty) {
        // Update in place without setState — just update last tick value
        if (_data.last.time == ts) {
          _data[_data.length - 1] = _Tick(ts, price);
        }
        return;
      }
      _lastWsUpdateMs = nowMs;
      setState(() {
        if (_data.isNotEmpty && _data.last.time == ts) {
          _data[_data.length - 1] = _Tick(ts, price);
        } else {
          _data.add(_Tick(ts, price));
          if (_data.length > 300) _data.removeAt(0);
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint('=== LiveFinanceChart _onMsg error: $e');
    }
  }

  // ── Crosshair ─────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails d, double chartW, double leftPad) {
    final x = d.localPosition.dx - leftPad;
    if (_data.isEmpty) return;
    final idx = ((x / chartW) * (_data.length - 1))
        .round().clamp(0, _data.length - 1);
    setState(() {
      _hoverTick = _data[idx];
      _hoverX    = leftPad + (idx / (_data.length - 1).clamp(1, 99999)) * chartW;
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
    // Show skeleton until at least one price tick arrives (handles PRE market empty history)
    if (_data.isEmpty) return _skeleton();

    return Container(
      width: double.infinity, height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(builder: (ctx, box) {
          final w      = box.maxWidth;
          final h      = box.maxHeight;
          final chartW = w - leftPad - rightPad;
          final chartH = h - topPad - bottomPad;

          return GestureDetector(
            onPanUpdate: (d) => _onPanUpdate(d, chartW, leftPad),
            onPanEnd:    _onPanEnd,
            onTapUp:     (_) => _onPanEnd(null),
            child: Stack(children: [
              CustomPaint(
                size: Size(w, h),
                painter: _ChartPainter(
                  data: _data, hoverX: _hoverX,
                  leftPad: leftPad, rightPad: rightPad,
                  topPad: topPad, bottomPad: bottomPad,
                ),
              ),
              AnimatedBuilder(
                animation: _ripple,
                builder: (_, __) {
                  if (_data.isEmpty) return const SizedBox.shrink();
                  final last = _data.last;
                  final vals = _data.map((d) => d.value).toList();
                  var minV = vals.reduce(min);
                  var maxV = vals.reduce(max);
                  final rng = (maxV - minV);
                  if (rng < 0.00001) { minV -= 0.01; maxV += 0.01; }
                  else { minV -= rng * 0.08; maxV += rng * 0.08; }
                  final yRng = maxV - minV;
                  final dotX = leftPad + chartW;
                  final dotY = topPad + (1 - (last.value - minV) / yRng) * chartH;
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
    // More decimals for forex (values like 159.25)
    final dec   = tick.value > 100 ? 2 : tick.value > 1 ? 4 : 6;
    final price = tick.value.toStringAsFixed(dec);
    final time  = '${_pad(dt.hour % 12 == 0 ? 12 : dt.hour % 12)}:'
        '${_pad(dt.minute)} ${dt.hour < 12 ? 'AM' : 'PM'}';
    double left = x - 50;
    left = left.clamp(8.0, totalW - 108.0);

    return Positioned(
      top: 4, left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          border: Border.all(color: const Color(0x4DF5A623)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(price,
                  style: const TextStyle(color: Color(0xFFF3F4F6),
                      fontSize: 12, fontWeight: FontWeight.w700)),
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
        color: Theme.of(context).primaryColorDark, borderRadius: BorderRadius.circular(10)),
    child: const Center(child: SizedBox(width: 24, height: 24,
        child: CircularProgressIndicator(color: Color(0xFFF5A623), strokeWidth: 2))),
  );

  Widget _empty() => Container(
    width: double.infinity, height: widget.height,
    decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark, borderRadius: BorderRadius.circular(10)),
    child: const Center(child: Text('No live data available',
        style: TextStyle(color: Color(0xFF4A6670), fontSize: 13))),
  );
}

// ─── Shared painter classes (same as LiveCryptoChart) ─────────────
class _ChartPainter extends CustomPainter {
  final List<_Tick> data;
  final double? hoverX;
  final double leftPad, rightPad, topPad, bottomPad;

  const _ChartPainter({
    required this.data, required this.hoverX,
    required this.leftPad, required this.rightPad,
    required this.topPad, required this.bottomPad,
  });

  static const _gold = Color(0xFFF5A623);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final chartW = size.width  - leftPad - rightPad;
    final chartH = size.height - topPad  - bottomPad;

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

    // Grid
    final gridPaint = Paint()..color = const Color(0xFF1A2530)..strokeWidth = 0.7;
    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = yOf(minV + yRng * i / gridCount);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
    }

    // Y labels
    final lStyle = const TextStyle(color: Color(0xFF6B7280), fontSize: 9.5, fontFamily: 'monospace');
    for (int i = 0; i <= gridCount; i++) {
      final v = minV + yRng * i / gridCount;
      final dec = v > 100 ? 2 : v > 1 ? 3 : 5;
      _txt(canvas, v.toStringAsFixed(dec), lStyle,
          Offset(size.width - rightPad + 6, yOf(v) - 6));
    }

    // X labels
    final xStyle = const TextStyle(color: Color(0xFF6B7280), fontSize: 9, fontFamily: 'monospace');
    const xCount = 4;
    for (int li = 0; li < xCount; li++) {
      final idx = (li * (data.length - 1) / (xCount - 1).clamp(1, 9999)).round();
      final dt  = DateTime.fromMillisecondsSinceEpoch(data[idx].time * 1000).toLocal();
      final lbl = '${_pad(dt.hour % 12 == 0 ? 12 : dt.hour % 12)}:${_pad(dt.minute)}'
          ' ${dt.hour < 12 ? 'AM' : 'PM'}';
      _txt(canvas, lbl, xStyle, Offset(xOf(idx) - 18, size.height - bottomPad + 7));
    }

    // Area fill
    final fillPath = Path()..moveTo(xOf(0), yOf(data[0].value));
    for (int i = 1; i < data.length; i++) fillPath.lineTo(xOf(i), yOf(data[i].value));
    fillPath
      ..lineTo(xOf(data.length - 1), topPad + chartH)
      ..lineTo(xOf(0), topPad + chartH)
      ..close();
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_gold.withValues(alpha: 0.18), _gold.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH)));

    // Line
    final linePath = Path()..moveTo(xOf(0), yOf(data[0].value));
    for (int i = 1; i < data.length; i++) linePath.lineTo(xOf(i), yOf(data[i].value));
    canvas.drawPath(linePath, Paint()
      ..color = _gold..strokeWidth = 1.8..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    // Dashed baseline
    final bp   = Paint()..color = _gold.withValues(alpha: 0.35)..strokeWidth = 0.8;
    final byY  = yOf(data.first.value);
    double bx  = leftPad;
    while (bx < size.width - rightPad) {
      canvas.drawLine(Offset(bx, byY), Offset(bx + 6, byY), bp);
      bx += 10;
    }

    // Crosshair
    if (hoverX != null) {
      canvas.drawLine(Offset(hoverX!, topPad), Offset(hoverX!, topPad + chartH),
          Paint()..color = Colors.white.withValues(alpha: 0.3)..strokeWidth = 1);
    }
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  void _txt(Canvas canvas, String text, TextStyle style, Offset offset) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data.length != data.length || old.hoverX != hoverX ||
          (data.isNotEmpty && old.data.isNotEmpty && old.data.last.value != data.last.value);
}

class _RipplePainter extends CustomPainter {
  final double cx, cy, phase1, phase2;
  const _RipplePainter({required this.cx, required this.cy,
    required this.phase1, required this.phase2});

  static const _gold  = Color(0xFFF5A623);
  static const dotR   = 4.5;
  static const ringMax = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (final phase in [phase1, phase2]) {
      canvas.drawCircle(Offset(cx, cy), dotR + (ringMax - dotR) * phase,
          Paint()..color = _gold.withValues(alpha: (1 - phase) * 0.5)
            ..strokeWidth = 1.5..style = PaintingStyle.stroke);
    }
    canvas.drawCircle(Offset(cx, cy), dotR + 2,
        Paint()..color = const Color(0xAA0D1117));
    canvas.drawCircle(Offset(cx, cy), dotR, Paint()..color = _gold);
    canvas.drawCircle(Offset(cx, cy), 1.8, Paint()..color = const Color(0xFF111111));
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.phase1 != phase1 || old.phase2 != phase2 || old.cx != cx || old.cy != cy;
}