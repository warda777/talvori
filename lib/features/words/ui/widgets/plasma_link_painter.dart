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

    final t = phase * 2 * pi * 1.0; // doppelt so schnell wie vorher (0.50 -> 1.0)
    final fromPts = cardBottomBand(cardRect!, count: 10, widthFactor: 0.40); // 40% Breite - enger gebündelt oben
    final toPts = switchTopArcTight(
      switchRect!,
      count: 10,
      arcPortionOfHalf: 0.15,  // 15% des Halbkreises - extrem eng gebündelt oben
      ringInset: 1,     // Nur 1px nach innen - liegt auf der äußeren farbigen Pill (rot/gold/weiß)
      yOutset: 0,       // Kein yOutset
    );

    Paint glow(Color c, double w, double a, double blur) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w
      ..color = c.withOpacity(a)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final outer = glow(const Color(0xFFB16CFF), 14, 0.10, 18);
    final mid   = glow(const Color(0xFF7B5CFF), 8,  0.14, 12);
    final core  = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0
      ..color = const Color(0xFFEFE9FF).withOpacity(0.60);

    // Richtung und Normalenvektor für Bündelung
    final d = (toPts[toPts.length ~/ 2] - fromPts[fromPts.length ~/ 2]);
    final dist = d.distance.clamp(1.0, 2000.0);
    final dir = d / dist;
    final n = Offset(-dir.dy, dir.dx);

    // Fäden zeichnen (geordnet: i -> i, keine Permutation)
    for (int i = 0; i < fromPts.length; i++) {
      final a = fromPts[i];
      final b = toPts[i]; // match i -> i (geordnet, vermeidet Nachbar-Switches)

      // startSpread = 0, damit alle Punkte exakt auf der Linie bleiben
      final startSpread = 0.0; // Keine seitliche Verschiebung - alle auf einer Linie
      final endSpread = 0.0; // Zielpunkte liegen schon auf Arc, nicht zusätzlich seitlich

      final path = _bundledFlow(a, b, n, t, i, startSpread, endSpread);

      canvas.drawPath(path, outer);
      canvas.drawPath(path, mid);
      canvas.drawPath(path, core..color = const Color(0xFFEFE9FF).withOpacity(0.35 + 0.25 * sin(t + i)));
    }

    // Optional: Dock-Glow als "Fächer" unten und oben
    _dockFan(canvas, cardRect!.bottomCenter, t, strength: 1.0);
    _dockFan(canvas, Offset(switchRect!.center.dx, switchRect!.top), t, strength: 0.7);
  }

  // Bundle-Punkt: liegt zwischen Karte und Switch, etwas näher an der Switch
  Offset _bundlePoint(Offset a, Offset b, double t, Offset n) {
    final mid = Offset.lerp(a, b, 0.62)!; // näher zur Switch
    final wobble = sin(t) * 6.0;          // ganz leichte Bewegung
    return mid + n * wobble;
  }

  // Pfad pro Faden (breit → eng → breit)
  Path _bundledFlow(Offset a, Offset b, Offset n, double t, int seed, double startSpread, double endSpread) {
    final m = _bundlePoint(a, b, t, n);

    // Startpunkt fächert breit
    final a2 = a + n * startSpread;

    // Endpunkt fächert breit (entlang Arc-Samples kommt sowieso Variation)
    final b2 = b + n * endSpread;

    // Kurve 1: a2 -> m
    final c1 = Offset.lerp(a2, m, 0.35)! + n * (sin(t + seed) * 10);
    final c2 = Offset.lerp(a2, m, 0.75)! + n * (sin(t * 0.7 + seed * 1.3) * 6);

    // Kurve 2: m -> b2
    final c3 = Offset.lerp(m, b2, 0.25)! + n * (sin(t * 0.9 + seed * 0.8) * 6);
    final c4 = Offset.lerp(m, b2, 0.70)! + n * (sin(t + seed * 0.6) * 10);

    return Path()
      ..moveTo(a2.dx, a2.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, m.dx, m.dy)
      ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, b2.dx, b2.dy);
  }

  void _dockFan(Canvas canvas, Offset p, double t, {double strength = 1.0}) {
    final pulse = 0.6 + 0.4 * sin(t * 1.1);
    final r = (18 + 16 * pulse) * strength;

    final paint = Paint()
      ..color = const Color(0xFFB16CFF).withOpacity(0.10 * strength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawCircle(p, r, paint);
  }

  @override
  bool shouldRepaint(covariant PlasmaBandPainter old) =>
      old.cardRect != cardRect || old.switchRect != switchRect || old.phase != phase || old.visible != visible;
}

extension RectExtension on Rect {
  Offset get bottomCenter => Offset(center.dx, bottom);
}
