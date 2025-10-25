import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  final double thickness;
  final double percent; // 0..1
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.size,
    required this.thickness,
    required this.percent,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              percent: percent.clamp(0, 1),
              thickness: thickness,
              bgColor: Colors.white.withOpacity(0.12),
              fgColor: Colors.white,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double thickness;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.percent,
    required this.thickness,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - thickness / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Hintergrund
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.1415926535 / 180),
      360 * (3.1415926535 / 180),
      false,
      bgPaint,
    );

    // Fortschritt
    final sweep = 360 * percent;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.1415926535 / 180),
        sweep * (3.1415926535 / 180),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.percent != percent ||
        old.thickness != thickness ||
        old.bgColor != bgColor ||
        old.fgColor != fgColor;
  }
}
