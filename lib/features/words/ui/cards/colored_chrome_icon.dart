import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom-painted Chrome-Icon mit mehreren Farben
class ColoredChromeIcon extends StatelessWidget {
  final double size;
  final Color centerColor;      // B1CCFF
  final Color topColor;         // FAD17D (gelb/gold)
  final Color rightColor;       // A05260 (rötlich)
  final Color leftColor;        // Grün (passend)

  const ColoredChromeIcon({
    super.key,
    this.size = 56,
    this.centerColor = const Color(0xFFB1CCFF),
    this.topColor = const Color(0xFFFAD17D),
    this.rightColor = const Color(0xFFA05260),
    this.leftColor = const Color(0xFF34C759), // iOS-Grün als passende Farbe
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChromeIconPainter(
          centerColor: centerColor,
          topColor: topColor,
          rightColor: rightColor,
          leftColor: leftColor,
        ),
      ),
    );
  }
}

class _ChromeIconPainter extends CustomPainter {
  final Color centerColor;
  final Color topColor;
  final Color rightColor;
  final Color leftColor;

  _ChromeIconPainter({
    required this.centerColor,
    required this.topColor,
    required this.rightColor,
    required this.leftColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.85; // Etwas kleiner als der Container
    final centerRadius = radius * 0.35; // Radius des Mittelkreises
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ─── Zentrum (Kreis) ───
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerRadius, centerPaint);

    // ─── Drei Sektoren (wie Chrome-Logo, je 120 Grad) ───
    // Sektor 1: Oben (Gelb/Gold) - Start bei -90 Grad (oben)
    final topPaint = Paint()
      ..color = topColor
      ..style = PaintingStyle.fill;
    final topPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx, center.dy - radius) // Linie nach oben
      ..arcTo(rect, -math.pi / 2, 2 * math.pi / 3, false) // 120 Grad Bogen
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Sektor 2: Rechts unten (Rötlich) - Start bei 30 Grad
    final rightPaint = Paint()
      ..color = rightColor
      ..style = PaintingStyle.fill;
    final rightPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(math.pi / 6),
        center.dy + radius * math.sin(math.pi / 6),
      ) // Linie zu 30 Grad
      ..arcTo(rect, math.pi / 6, 2 * math.pi / 3, false) // 120 Grad Bogen
      ..close();
    canvas.drawPath(rightPath, rightPaint);

    // Sektor 3: Links unten (Grün) - Start bei 150 Grad
    final leftPaint = Paint()
      ..color = leftColor
      ..style = PaintingStyle.fill;
    final leftPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(5 * math.pi / 6),
        center.dy + radius * math.sin(5 * math.pi / 6),
      ) // Linie zu 150 Grad
      ..arcTo(rect, 5 * math.pi / 6, 2 * math.pi / 3, false) // 120 Grad Bogen
      ..close();
    canvas.drawPath(leftPath, leftPaint);

    // ─── Weiße Umrandung für die Sektoren ───
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Umrandung des Mittelkreises
    canvas.drawCircle(center, centerRadius, borderPaint);
    
    // Umrandung des äußeren Kreises
    canvas.drawCircle(center, radius, borderPaint);
    
    // Trennlinien zwischen den Sektoren
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Linie von Mitte nach oben (-90 Grad)
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      linePaint,
    );
    
    // Linie von Mitte nach rechts unten (30 Grad)
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(math.pi / 6),
        center.dy + radius * math.sin(math.pi / 6),
      ),
      linePaint,
    );
    
    // Linie von Mitte nach links unten (150 Grad)
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(5 * math.pi / 6),
        center.dy + radius * math.sin(5 * math.pi / 6),
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_ChromeIconPainter oldDelegate) {
    return oldDelegate.centerColor != centerColor ||
        oldDelegate.topColor != topColor ||
        oldDelegate.rightColor != rightColor ||
        oldDelegate.leftColor != leftColor;
  }
}

