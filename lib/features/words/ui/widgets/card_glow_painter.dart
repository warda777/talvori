import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Zeichnet einen nebeligen, pulsierenden Glow-Effekt um die Karte
class CardGlowPainter extends CustomPainter {
  final double phase; // 0.0 - 1.0 für Animation
  final double cardWidth;
  final double cardHeight;
  final double borderRadius;

  CardGlowPainter({
    required this.phase,
    required this.cardWidth,
    required this.cardHeight,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Karte ist zentriert im verfügbaren Bereich
    final center = Offset(size.width / 2, size.height / 2);
    final cardRect = Rect.fromCenter(
      center: center,
      width: cardWidth,
      height: cardHeight,
    );
    final rect = RRect.fromRectAndRadius(cardRect, Radius.circular(borderRadius));

    // Pulsierender Radius (größer und kleiner werdend) - stärkere Variation
    final pulse = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
    final minSpread = 12.0;
    final maxSpread = 48.0; // Größerer Spread für stärkeren Effekt
    final spread = minSpread + (maxSpread - minSpread) * pulse;

    // Mehrere Schichten für nebeligen Bloom-Effekt
    final layers = [
      // Äußerste Schicht - sehr weich, groß und nebelig
      _createGlowLayer(
        color: const Color(0xFFB16CFF),
        opacity: 0.25 * (0.6 + 0.4 * pulse), // Stärkere Opazität
        blur: 60 + spread * 2.0, // Größerer Blur für nebeligen Effekt
        spread: spread * 1.5,
      ),
      // Zweite äußere Schicht
      _createGlowLayer(
        color: const Color(0xFF9B7CFF),
        opacity: 0.30 * (0.5 + 0.5 * pulse),
        blur: 45 + spread * 1.5,
        spread: spread * 1.2,
      ),
      // Mittlere Schicht
      _createGlowLayer(
        color: const Color(0xFF7B5CFF),
        opacity: 0.35 * (0.5 + 0.5 * pulse),
        blur: 35 + spread * 1.2,
        spread: spread * 0.9,
      ),
      // Innere Schicht - intensiver
      _createGlowLayer(
        color: const Color(0xFF8B6CFF),
        opacity: 0.40 * (0.4 + 0.6 * pulse),
        blur: 25 + spread * 0.8,
        spread: spread * 0.6,
      ),
      // Kern-Glow - sehr nah an der Karte, sehr intensiv
      _createGlowLayer(
        color: const Color(0xFFEFE9FF),
        opacity: 0.45 * (0.3 + 0.7 * pulse), // Stärkste Pulsierung
        blur: 18 + spread * 0.5,
        spread: spread * 0.3,
      ),
    ];

    // Zeichne alle Schichten
    for (final layer in layers) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.outerRect.inflate(layer['spread'] as double),
          Radius.circular(borderRadius + layer['spread'] as double),
        ),
        layer['paint'] as Paint,
      );
    }

    // Zusätzliche "Partikel"-Effekte (kleine Glows an den Ecken und entlang der Kante)
    final cornerBlur = (12 + spread * 0.3).clamp(0.0, 100.0);
    final cornerGlow = Paint()
      ..style = PaintingStyle.fill;
    if (cornerBlur > 0) {
      cornerGlow.maskFilter = MaskFilter.blur(BlurStyle.normal, cornerBlur);
    }

    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];

    // Ecken-Glows mit stärkerer Pulsierung
    for (var i = 0; i < corners.length; i++) {
      final corner = corners[i];
      final cornerPhase = phase + (i * 0.25); // Unterschiedliche Phasen für jede Ecke
      final cornerPulse = 0.5 + 0.5 * math.sin(cornerPhase * 2 * math.pi);
      cornerGlow.color = const Color(0xFFB16CFF).withOpacity(0.35 * cornerPulse);
      canvas.drawCircle(
        corner,
        6 + spread * 0.2, // Größere Partikel
        cornerGlow,
      );
    }

    // Zusätzliche kleine Glows entlang der Kante für mehr "Nebel"
    final edgeBlur = (10 + spread * 0.25).clamp(0.0, 100.0);
    final edgeGlow = Paint()
      ..style = PaintingStyle.fill;
    if (edgeBlur > 0) {
      edgeGlow.maskFilter = MaskFilter.blur(BlurStyle.normal, edgeBlur);
    }

    final edgePoints = [
      Offset(rect.left + rect.width * 0.25, rect.top),
      Offset(rect.left + rect.width * 0.75, rect.top),
      Offset(rect.right, rect.top + rect.height * 0.25),
      Offset(rect.right, rect.top + rect.height * 0.75),
      Offset(rect.left + rect.width * 0.75, rect.bottom),
      Offset(rect.left + rect.width * 0.25, rect.bottom),
      Offset(rect.left, rect.top + rect.height * 0.75),
      Offset(rect.left, rect.top + rect.height * 0.25),
    ];

    for (var i = 0; i < edgePoints.length; i++) {
      final point = edgePoints[i];
      final pointPhase = phase + (i * 0.125);
      final pointPulse = 0.4 + 0.6 * math.sin(pointPhase * 2 * math.pi);
      edgeGlow.color = const Color(0xFF9B7CFF).withOpacity(0.25 * pointPulse);
      canvas.drawCircle(
        point,
        4 + spread * 0.15,
        edgeGlow,
      );
    }
  }

  Map<String, dynamic> _createGlowLayer({
    required Color color,
    required double opacity,
    required double blur,
    required double spread,
  }) {
    // Blur-Wert validieren (muss zwischen 0 und 100 sein)
    final validBlur = blur.clamp(0.0, 100.0);
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(opacity.clamp(0.0, 1.0));
    
    // Nur MaskFilter setzen wenn blur > 0
    if (validBlur > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, validBlur);
    }

    return {
      'paint': paint,
      'spread': spread,
    };
  }

  @override
  bool shouldRepaint(CardGlowPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.cardWidth != cardWidth ||
        oldDelegate.cardHeight != cardHeight ||
        oldDelegate.borderRadius != borderRadius;
  }
}

