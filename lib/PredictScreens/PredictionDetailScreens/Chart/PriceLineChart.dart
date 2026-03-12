// lib/Reusable_Widgets/PriceLineChart/PriceLineChart.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:predict365/Models/MarketChartModel.dart';

/// Dark teal line chart matching the Predict365 website chart style.
/// Pass [candles] from MarketDataViewModel.
class PriceLineChart extends StatelessWidget {
  final List<CandleData> candles;
  final double height;

  const PriceLineChart({
    super.key,
    required this.candles,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return _emptyChart(height);
    }

    return Container(
      width:  double.infinity,
      height: height,
      decoration: BoxDecoration(
        color:   Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: _LinePainter(candles: candles),
        ),
      ),
    );
  }

  Widget _emptyChart(double h) {
    return Container(
      width: double.infinity, height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          'No chart data available',
          style: TextStyle(color: Color(0xFF4A6670), fontSize: 13),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<CandleData> candles;

  const _LinePainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // ── Margins ───────────────────────────────────────────────
    const double leftPad   = 8;
    const double rightPad  = 48; // Y-axis labels on right
    const double topPad    = 12;
    const double bottomPad = 28; // X-axis timestamps

    final chartW = size.width  - leftPad - rightPad;
    final chartH = size.height - topPad  - bottomPad;

    // ── Data range ────────────────────────────────────────────
    double minY = candles.map((c) => c.low).reduce(min);
    double maxY = candles.map((c) => c.high).reduce(max);

    // Add 5% padding so line doesn't hug edges
    final range = maxY - minY;
    if (range < 0.01) {
      minY = max(0, minY - 0.05);
      maxY = min(1, maxY + 0.05);
    } else {
      minY = max(0, minY - range * 0.08);
      maxY = min(1, maxY + range * 0.08);
    }
    final yRange = maxY - minY;

    // ── Helpers ───────────────────────────────────────────────
    double xOf(int i) =>
        leftPad + (i / (candles.length - 1).clamp(1, 9999)) * chartW;
    double yOf(double v) =>
        topPad + (1 - (v - minY) / yRange.clamp(0.001, 1)) * chartH;

    // ── Horizontal grid lines ─────────────────────────────────
    final gridPaint = Paint()
      ..color  = const Color(0xFF1E2A30)
      ..strokeWidth = 0.8;

    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final v = minY + (yRange * i / gridCount);
      final y = yOf(v);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad + 4, y),
        gridPaint,
      );
    }

    // ── Y-axis labels (right side) ────────────────────────────
    final yLabelStyle = TextStyle(
      color:    const Color(0xFF6B8E9A),
      fontSize: 10,
      fontFamily: 'monospace',
    );
    for (int i = 0; i <= gridCount; i++) {
      final v    = minY + (yRange * i / gridCount);
      final y    = yOf(v);
      final text = v.toStringAsFixed(2);
      _drawText(canvas, text, yLabelStyle,
          Offset(size.width - rightPad + 8, y - 6));
    }

    // ── X-axis labels ─────────────────────────────────────────
    final xLabelStyle = TextStyle(
      color:    const Color(0xFF6B8E9A),
      fontSize: 9,
      fontFamily: 'monospace',
    );
    // Show ~4 labels evenly spaced
    final xLabelCount = min(4, candles.length);
    for (int li = 0; li < xLabelCount; li++) {
      final idx  = (li * (candles.length - 1) / (xLabelCount - 1).clamp(1, 9999)).round();
      final x    = xOf(idx);
      final dt   = candles[idx].intervalStart.toLocal();
      final label = _fmtTime(dt);
      _drawText(canvas, label, xLabelStyle,
          Offset(x - 16, size.height - bottomPad + 8));
    }

    // ── Line path ─────────────────────────────────────────────
    final linePaint = Paint()
      ..color       = const Color(0xFF4DD9E0)   // teal/cyan
      ..strokeWidth = 1.6
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < candles.length; i++) {
      final x = xOf(i);
      final y = yOf(candles[i].close);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // ── Last price dot ────────────────────────────────────────
    final last  = candles.last;
    final lastX = xOf(candles.length - 1);
    final lastY = yOf(last.close);

    // Glow
    canvas.drawCircle(
      Offset(lastX, lastY),
      6,
      Paint()..color = const Color(0xFF4DD9E0).withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()..color = const Color(0xFF4DD9E0),
    );
  }

  String _fmtTime(DateTime dt) {
    final h  = dt.hour.toString().padLeft(2, '0');
    final m  = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'AM' : 'PM';
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    return '${h12.toString().padLeft(2, '0')}:$m $suffix';
  }

  void _drawText(Canvas canvas, String text, TextStyle style, Offset offset) {
    final tp = TextPainter(
      text:            TextSpan(text: text, style: style),
      textDirection:   TextDirection.ltr,
      textAlign:       TextAlign.left,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.candles != candles;
}

/// Loading skeleton for the chart
class PriceLineChartSkeleton extends StatefulWidget {
  final double height;
  const PriceLineChartSkeleton({super.key, this.height = 200});

  @override
  State<PriceLineChartSkeleton> createState() => _PriceLineChartSkeletonState();
}

class _PriceLineChartSkeletonState extends State<PriceLineChartSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.6).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF0F1419),
            const Color(0xFF1A2530),
            _anim.value,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
              color: Color(0xFF4DD9E0),
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}