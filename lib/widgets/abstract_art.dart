import 'package:flutter/material.dart';

/// Warm abstract artwork drawn in code. It stands in for each month's
/// photograph until real images are added.
class AbstractArt extends StatelessWidget {
  const AbstractArt({super.key, required this.palette, this.child});

  /// Three colours: light glow, mid tone, deep tone.
  final List<Color> palette;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AbstractArtPainter(palette),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class AbstractArtPainter extends CustomPainter {
  AbstractArtPainter(this.palette) : assert(palette.length >= 3);

  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final light = palette[0];
    final mid = palette[1];
    final deep = palette[2];

    // Base wash.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mid, deep],
        ).createShader(rect),
    );

    // Soft glow, top left.
    final glowCenter = Offset(w * 0.22, h * 0.28);
    final glowRadius = size.longestSide * 0.45;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [light.withValues(alpha: 0.9), light.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );

    // Two layered hills.
    final back = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.22, h * 0.42, w * 0.40, h * 0.92, w * 0.60, h * 0.64)
      ..cubicTo(w * 0.78, h * 0.40, w * 0.92, h * 0.56, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = deep.withValues(alpha: 0.45));

    final front = Path()
      ..moveTo(0, h * 0.86)
      ..cubicTo(w * 0.25, h * 0.66, w * 0.42, h * 1.02, w * 0.68, h * 0.78)
      ..cubicTo(w * 0.84, h * 0.64, w * 0.94, h * 0.76, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()..color = Color.lerp(deep, const Color(0xFF2A160D), 0.25)!.withValues(alpha: 0.55),
    );

    // A couple of faint drawn lines for texture.
    final stroke = Paint()
      ..color = const Color(0xFFF6E6D2).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.10, h * 0.36)
        ..cubicTo(w * 0.28, h * 0.27, w * 0.38, h * 0.42, w * 0.54, h * 0.33),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, h * 0.45)
        ..cubicTo(w * 0.33, h * 0.36, w * 0.46, h * 0.50, w * 0.64, h * 0.41),
      stroke,
    );
  }

  @override
  bool shouldRepaint(AbstractArtPainter oldDelegate) => oldDelegate.palette != palette;
}
