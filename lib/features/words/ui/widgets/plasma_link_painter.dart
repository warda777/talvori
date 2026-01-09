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

    final t = phase * 2 * pi * 2.0; // Doppelt so schnell wie vorher (1.0 -> 2.0)
    final fromPts = cardBottomBand(cardRect!, count: 10, widthFactor: 0.20); // 20% Breite - enger gebündelt am Kartenrand
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
  // Mit sanfterem Bogen nach oben, um Switches nicht zu berühren
  Offset _bundlePoint(Offset a, Offset b, double t, Offset n) {
    final mid = Offset.lerp(a, b, 0.62)!; // näher zur Switch
    
    // Sanftere Bewegung mit mehreren Wellen
    final wobble1 = sin(t) * 3.0;
    final wobble2 = sin(t * 0.9 + 1.5) * 2.0;
    final wobble = (wobble1 + wobble2) / 2.0; // Durchschnitt für sanftere Bewegung
    
    // Sanfterer Bogen nach oben
    final verticalOffset = -20.0;
    final upVector = Offset(0, verticalOffset);
    
    return mid + n * wobble + upVector;
  }

  // Pfad pro Faden (breit → eng → breit) mit zusätzlicher Welle im oberen Bereich
  Path _bundledFlow(Offset a, Offset b, Offset n, double t, int seed, double startSpread, double endSpread) {
    final m = _bundlePoint(a, b, t, n);

    // Startpunkt fächert breit
    final a2 = a + n * startSpread;

    // Endpunkt fächert breit (entlang Arc-Samples kommt sowieso Variation)
    final b2 = b + n * endSpread;

    // Sanfter Bogen nach oben
    final arcHeight = -25.0;
    final upOffset = Offset(0, arcHeight);

    // Sanfte Wellen mit reduzierten Amplituden
    final wave1 = sin(t + seed) * 4.0;
    final wave2 = sin(t * 0.8 + seed * 1.2) * 3.0;
    final wave3 = sin(t * 1.2 + seed * 0.7) * 2.0;
    final combinedWave = (wave1 + wave2 + wave3) / 3.0;

    // Drei Segmente für zusätzliche Welle: a2 -> m1 -> m2 -> b2
    // m1 bei 1/3 (oberer Bereich, wo nach unten geht)
    // m2 bei 2/3 (dann wieder nach oben)
    final m1 = Offset.lerp(a2, b2, 0.33)!; // Bei einem Drittel
    final m2 = Offset.lerp(a2, b2, 0.67)!; // Bei zwei Dritteln

    // Erste Kurve: a2 -> m1 (nach oben)
    final c1a = Offset.lerp(a2, m1, 0.25)! + n * (combinedWave * 0.6) + upOffset * 0.2;
    // Sehr starke Bewegung nach oben in der Mitte
    final c1b = Offset.lerp(a2, m1, 0.75)! + n * (combinedWave * 0.6) + upOffset * 1.0;

    // Zweite Kurve: m1 -> m2 (nach unten, dann wieder nach oben)
    // Tangentialer Übergang: c1b, m1, c2a müssen kollinear sein
    final downOffset = Offset(0, 15.0); // Nach unten für die Welle
    
    // Richtung am Ende der ersten Kurve (von c1b zu m1)
    final dirAtM1 = m1 - c1b;
    final dirAtM1Len = dirAtM1.distance;
    final dirAtM1Norm = dirAtM1Len > 0.001 ? dirAtM1 / dirAtM1Len : Offset(0, -1);
    // c2a liegt auf der Verlängerung von c1b -> m1 für tangentialen Übergang
    // Sehr starke Bewegung nach oben
    final c2a = m1 + dirAtM1Norm * 25.0 + n * (combinedWave * 1.1) + downOffset * 0.3;
    final c2b = Offset.lerp(m1, m2, 0.75)! + n * (combinedWave * 1.1) + upOffset * 0.9;

    // Dritte Kurve: m2 -> b2 (nach oben zur Switch)
    // Tangentialer Übergang: c2b, m2, c3a müssen kollinear sein
    final dirAtM2 = m2 - c2b;
    final dirAtM2Len = dirAtM2.distance;
    final dirAtM2Norm = dirAtM2Len > 0.001 ? dirAtM2 / dirAtM2Len : Offset(0, -1);
    // c3a liegt auf der Verlängerung von c2b -> m2 für tangentialen Übergang
    // Sehr starke Bewegung nach oben
    final c3a = m2 + dirAtM2Norm * 25.0 + n * (combinedWave * 1.0) + upOffset * 1.0;
    
    // Größerer Bogen nach oben kurz vor der Switch
    final largeArcOffset = Offset(0, -40.0); // Größerer Bogen nach oben
    final c3b = Offset.lerp(m2, b2, 0.80)! + n * (combinedWave * 0.6) + largeArcOffset;

    return Path()
      ..moveTo(a2.dx, a2.dy)
      ..cubicTo(c1a.dx, c1a.dy, c1b.dx, c1b.dy, m1.dx, m1.dy)
      ..cubicTo(c2a.dx, c2a.dy, c2b.dx, c2b.dy, m2.dx, m2.dy)
      ..cubicTo(c3a.dx, c3a.dy, c3b.dx, c3b.dy, b2.dx, b2.dy);
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
