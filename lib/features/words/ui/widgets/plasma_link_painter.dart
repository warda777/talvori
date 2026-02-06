import 'dart:math';
import 'package:flutter/material.dart';

// Helper: Punkte entlang der unteren Kartenkante
List<Offset> cardBottomBand(Rect cardRect, {int count = 10, double widthFactor = 0.55}) {
  final cx = cardRect.center.dx;
  final half = (cardRect.width * widthFactor) / 2;

  final x0 = cx - half;
  final x1 = cx + half;

  // Exakt auf dem unteren Kartenrand - alle Punkte haben die gleiche Y-Koordinate
  final y = cardRect.bottom;

  return List.generate(count, (i) {
    final t = i / (count - 1);
    final x = x0 + (x1 - x0) * t;
    // Sicherstellen, dass Y exakt gleich ist für alle Punkte
    return Offset(x, y);
  });
}

// Helper: Punkte entlang des oberen Switch-Radius (eng, nur 45% des Halbkreises)
List<Offset> switchTopArcTight(
  Rect r, {
  int count = 10,
  double arcPortionOfHalf = 0.45,
  double ringInset = 0,  // Abstand nach innen von der äußeren Kontur
  double yOutset = 0,
}) {
  final outerR = r.height / 2;
  // Radius = outerR - ringInset (ringInset nach innen von der äußeren Kontur)
  // Für genau auf der Pill: ringInset sollte den Glow kompensieren (z.B. 6-8px)
  final radius = (outerR - ringInset).clamp(2.0, outerR);

  // Kreiszentrum der Pill
  final center = Offset(r.center.dx, r.top + outerR + yOutset);

  // Top = -90° (=-pi/2). Span = arcPortionOfHalf * 180°
  final span = pi * arcPortionOfHalf;      // z.B. 0.45*pi
  final midA = -pi / 2;                    // Top
  final start = midA - span / 2;
  final end   = midA + span / 2;

  return List.generate(count, (i) {
    final t = i / (count - 1);
    final a = start + (end - start) * t;
    return Offset(
      center.dx + cos(a) * radius,
      center.dy + sin(a) * radius,
    );
  });
}

class PlasmaBandPainter extends CustomPainter {
  final Rect? cardRect;        // in Stack coords
  final Rect? switchRect;      // outer pill rect in Stack coords
  final double phase;          // 0..1
  final bool visible;

  PlasmaBandPainter({
    required this.cardRect,
    required this.switchRect,
    required this.phase,
    required this.visible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || cardRect == null || switchRect == null) return;

    final t = phase * 2 * pi * 1.0;

    final fromPts = cardBottomBand(
      cardRect!,
      count: 8,
      widthFactor: 0.06, // slimmer band at the card edge
    );
    final toPts = switchTopArcTight(
      switchRect!,
      count: 8,
      arcPortionOfHalf: 0.12, // tight arc at switch top
      ringInset: 1,
      yOutset: 0,
    );

    Paint glow(Color c, double w, double a, double blur) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w
      ..color = c.withOpacity(a)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // Much slimmer link paints
    final outer = glow(const Color(0xFFB16CFF), 6, 0.10, 12);
    final mid   = glow(const Color(0xFF7B5CFF), 3, 0.14, 9);
    final core  = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.3
      ..color = const Color(0xFFEFE9FF).withOpacity(0.60);

    // Direction + normal for gentle wobble
    final d = (toPts[toPts.length ~/ 2] - fromPts[fromPts.length ~/ 2]);
    final dist = d.distance.clamp(1.0, 2000.0);
    final dir = d / dist;
    final n = Offset(-dir.dy, dir.dx);

    for (int i = 0; i < fromPts.length; i++) {
      final a = fromPts[i];
      final b = toPts[i];
      final path = _wavyStrand(a, b, n, t, seed: i);
      canvas.drawPath(path, outer);
      canvas.drawPath(path, mid);
      canvas.drawPath(path, core..color = const Color(0xFFEFE9FF).withOpacity(0.26 + 0.22 * sin(t + i)));
    }
  }

  Path _wavyStrand(Offset a, Offset b, Offset n, double t, {required int seed}) {
    // Create a smooth, slim, wavy cubic path.
    // The wave "travels" along the link by mixing multiple sinusoids.
    final mid = Offset.lerp(a, b, 0.58)!;

    // traveling wave phase (0 at card -> 1 at switch)
    double wave(double p) {
      final base = t * 1.6 - p * 2 * pi;
      final w1 = sin(base + seed * 0.6) * 5.0;
      final w2 = sin(base * 0.8 + 1.2 + seed * 0.35) * 3.0;
      return (w1 + w2) / 2.0;
    }

    final up = const Offset(0, -22.0);
    final c1 = Offset.lerp(a, mid, 0.60)! + n * (wave(0.22) * 0.35) + up * 0.25;
    final c2 = Offset.lerp(mid, b, 0.45)! + n * (wave(0.72) * 0.45) + up * 1.0;

    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
  }

  // (No knots / dock fans on purpose: user wants a clean slim wavy link.)

  @override
  bool shouldRepaint(covariant PlasmaBandPainter old) =>
      old.cardRect != cardRect || old.switchRect != switchRect || old.phase != phase || old.visible != visible;
}

extension RectExtension on Rect {
  Offset get bottomCenter => Offset(center.dx, bottom);
}
