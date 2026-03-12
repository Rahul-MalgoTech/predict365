import 'package:flutter/material.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:provider/provider.dart';

// ── SHIMMER ANIMATION WRAPPER ────────────────────────────────────
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  const ShimmerWidget({super.key, required this.child});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final base    = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8);
    final shimmer = isDark ? const Color(0xFF3C3C3E) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [base, shimmer, base],
            stops: [
              (_animation.value - 1).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 1).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

// ── SHIMMER BOX helper ───────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── SKELETON: QuickCard row (3 boxes) ───────────────────────────
class QuickCardRowSkeleton extends StatelessWidget {
  const QuickCardRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return ShimmerWidget(
      child: Row(
        children: List.generate(3, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: sw * 0.12,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )),
      ),
    );
  }
}

// ── SKELETON: PredictionCard (type 1) ───────────────────────────
class PredictionCardSkeleton extends StatelessWidget {
  const PredictionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final sw = MediaQuery.of(context).size.width;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final divC = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return ShimmerWidget(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ShimmerBox(width: sw * 0.5, height: sw * 0.04),
            const SizedBox(height: 14),

            // Team 1 row
            Row(children: [
              ShimmerBox(width: sw * 0.08, height: sw * 0.08, radius: sw * 0.04),
              const SizedBox(width: 10),
              ShimmerBox(width: sw * 0.3, height: sw * 0.033),
              const Spacer(),
              ShimmerBox(width: sw * 0.08, height: sw * 0.033),
            ]),
            const SizedBox(height: 8),

            // Progress bar
            ShimmerBox(width: double.infinity, height: 4, radius: 4),
            const SizedBox(height: 10),

            // Team 2 row
            Row(children: [
              ShimmerBox(width: sw * 0.08, height: sw * 0.08, radius: sw * 0.04),
              const SizedBox(width: 10),
              ShimmerBox(width: sw * 0.25, height: sw * 0.033),
              const Spacer(),
              ShimmerBox(width: sw * 0.08, height: sw * 0.033),
            ]),
            const SizedBox(height: 14),

            // Bet buttons
            Row(children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: sw * 0.1)),
              const SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: double.infinity, height: sw * 0.1)),
            ]),
            const SizedBox(height: 12),

            // Footer
            Row(children: [
              ShimmerBox(width: sw * 0.3, height: sw * 0.028),
              const Spacer(),
              ShimmerBox(width: sw * 0.2, height: sw * 0.028),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── SKELETON: PredictionCard Type 2 ─────────────────────────────
class PredictionCardType2Skeleton extends StatelessWidget {
  const PredictionCardType2Skeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeController>().isDarkMode;
    final sw = MediaQuery.of(context).size.width;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final divC = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return ShimmerWidget(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + title
            Row(children: [
              ShimmerBox(width: sw * 0.09, height: sw * 0.09, radius: 6),
              const SizedBox(width: 10),
              ShimmerBox(width: sw * 0.55, height: sw * 0.035),
            ]),
            const SizedBox(height: 14),

            // Team 1
            Row(children: [
              ShimmerBox(width: sw * 0.25, height: sw * 0.033),
              const Spacer(),
              ShimmerBox(width: sw * 0.1, height: sw * 0.033),
              const SizedBox(width: 10),
              ShimmerBox(width: sw * 0.14, height: sw * 0.08, radius: 6),
              const SizedBox(width: 6),
              ShimmerBox(width: sw * 0.12, height: sw * 0.08, radius: 6),
            ]),
            const SizedBox(height: 10),

            // Team 2
            Row(children: [
              ShimmerBox(width: sw * 0.2, height: sw * 0.033),
              const Spacer(),
              ShimmerBox(width: sw * 0.08, height: sw * 0.033),
            ]),
            const SizedBox(height: 14),

            // Footer
            Row(children: [
              ShimmerBox(width: sw * 0.3, height: sw * 0.028),
              const Spacer(),
              ShimmerBox(width: sw * 0.06, height: sw * 0.04, radius: 4),
            ]),
          ],
        ),
      ),
    );
  }
}


class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: sw * 0.02),

            // Quick cards - row 1
            const QuickCardRowSkeleton(),
            SizedBox(height: sw * 0.035),

            // Quick cards - row 2
            const QuickCardRowSkeleton(),
            SizedBox(height: sw * 0.05),

            // "For you" header
            ShimmerWidget(
              child: Row(children: [
                ShimmerBox(width: sw * 0.25, height: sw * 0.08, radius: 20),
                const Spacer(),
                ShimmerBox(width: sw * 0.1, height: sw * 0.08, radius: 8),
              ]),
            ),
            SizedBox(height: sw * 0.04),

            // Prediction card 1
            const PredictionCardSkeleton(),
            SizedBox(height: sw * 0.03),

            // Prediction card 2
            const PredictionCardSkeleton(),
            SizedBox(height: sw * 0.03),

            // Prediction card type 2
            const PredictionCardType2Skeleton(),
            SizedBox(height: sw * 0.06),
          ],
        ),
      ),
    );
  }
}