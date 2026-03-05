import 'package:flutter/material.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';

class GradientAppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;

  const GradientAppText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.2174, 0.5403, 0.8528],
          colors: [
            Color(0xFF985620),
            Color(0xFFac6d29),
            Color(0xFFc28533),
            Color(0xFFd49b3c),
          ],
        ).createShader(bounds);
      },
      child: AppText(
        text,

          fontSize: fontSize,
          color: Colors.white,
          fontWeight: fontWeight ?? FontWeight.w300,

      ),
    );
  }
}
