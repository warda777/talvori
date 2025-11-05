import 'dart:math' as math;
import 'package:flutter/material.dart';

const int _kMaxParticles = 140;   // harte Obergrenze

class _Particle {
  Offset pos;
  Offset vel;
  double life;      // Sek.
  final double maxLife;
  final double size;
  final double thickness;
  final Color color;

  _Particle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.thickness,
    required this.color,
  });
}

class ChromeSparks {
  final List<_Particle> _parts = [];
  final math.Random _rnd = math.Random();

  List<_Particle> get particles => _parts;
  bool get isActive => _parts.isNotEmpty;

  /// Gibt true zurück, wenn sich etwas geändert hat (für repaint)
  bool tick(double dt) {
    if (_parts.isEmpty) return false;
    dt = dt.clamp(0.0, 0.033); // max ~33 ms (Frame-Drops abfangen)
    bool changed = false;
    for (int i = _parts.length - 1; i >= 0; i--) {
      final p = _parts[i];
      // simple Physik
      p.vel = Offset(p.vel.dx, p.vel.dy + 100 * dt); // gravity px/s² (reduziert für höhere Flugbahn)
      p.pos += p.vel * dt;
      p.life -= dt;
      if (p.life <= 0) {
        _parts.removeAt(i);
        changed = true;
      } else {
        changed = true;
      }
    }
    return changed;
  }

  void emitBurst({
    required Offset center,
    int count = 120,                   // viel dichter
    double baseSpeed = 420,            // hohe Tangentialgeschwindigkeit
    double gravity = 500,              // reduzierte Schwerkraft für höhere Flugbahn
    Duration life = const Duration(milliseconds: 900),
  }) {
    int available = (_kMaxParticles - _parts.length).clamp(0, 9999);
    if (available <= 0) return;
    count = count.clamp(0, available);
    
    for (int i = 0; i < count; i++) {
      // Tangentialrichtung (im Kreis)
      final angle = (i / count) * 2 * math.pi;
      final spread = (_rnd.nextDouble() - 0.5) * 0.2; // leicht unregelmäßig
      final a = angle + spread;

      final speed = baseSpeed * (0.8 + _rnd.nextDouble() * 0.4);
      final vx = speed * math.cos(a);
      final vy = speed * math.sin(a) * 0.7; // leicht nach unten geneigt

      _parts.add(_Particle(
        pos: center,
        vel: Offset(vx, vy),
        life: life.inMilliseconds / 1000.0,
        maxLife: life.inMilliseconds / 1000.0,
        size: 1.5 + _rnd.nextDouble() * 1.5,
        thickness: 1.0 + _rnd.nextDouble() * 1.0,
        color: _sparkColor(),
      ));
    }
  }

  void emitSideJets({
    required Offset center,
    required double radius,              // Rand des Icons
    int countPerSide = 70,
    double baseSpeed = 480,
    double gravity = 500,
    Duration life = const Duration(milliseconds: 900),
  }) {
    int totalCount = countPerSide * 2; // Links + Rechts
    int available = (_kMaxParticles - _parts.length).clamp(0, 9999);
    if (available <= 0) return;
    totalCount = totalCount.clamp(0, available);
    countPerSide = (totalCount / 2).round();
    
    // Links (-1) & Rechts (+1)
    for (final side in const [-1, 1]) {
      final origin = center + Offset(side * radius, 0);
      for (int i = 0; i < countPerSide; i++) {
        // Tangente am Rand: links => nach oben (-pi/2), rechts => nach unten (+pi/2)
        final baseAngle = side < 0 ? -math.pi / 2 : math.pi / 2;
        final jitter = (_rnd.nextDouble() - 0.5) * 0.35; // leichte Streuung
        final a = baseAngle + jitter;

        // Geschwindigkeit: tangential + minimale radiale Streuung
        final speed = baseSpeed * (0.8 + _rnd.nextDouble() * 0.4);
        // Tangential:
        double vx = speed * math.cos(a);
        double vy = speed * math.sin(a);
        // kleine radiale Streuung (vom Rand weg):
        final radialJitter = 40 * (_rnd.nextDouble() - 0.5);
        vx += radialJitter * side; // nur x radial
        // Startwerte
        _parts.add(_Particle(
          pos: origin,
          vel: Offset(vx, vy),
          life: life.inMilliseconds / 1000.0,
          maxLife: life.inMilliseconds / 1000.0,
          size: 1.2 + _rnd.nextDouble() * 1.2,      // Größe für Glut
          thickness: 1.0 + _rnd.nextDouble() * 1.0, // Strichstärke
          color: _sparkColor(),
        ));
      }
    }
  }

  void emitWheelBurst({
    required Offset center,
    required double radius,
    int count = 220,
    double baseSpeed = 520,          // Grundenergie
    double radialBias = 1.0,         // 1.0 = stark radial
    double tangentialBias = 0.35,    // leichte Krümmung
    double gravity = 500,
    Duration life = const Duration(milliseconds: 1000),
  }) {
    // Partikelobergrenze respektieren (falls du _kMaxParticles gesetzt hast)
    int available = (_kMaxParticles - _parts.length).clamp(0, 9999);
    if (available <= 0) return;
    count = count.clamp(0, available);

    for (int i = 0; i < count; i++) {
      final theta = _rnd.nextDouble() * 2 * math.pi;
      final n = Offset(math.cos(theta), math.sin(theta));      // radial
      final t = Offset(-n.dy, n.dx);                            // tangential (90°)
      // leichte Zufallsrichtung der Tangente (links/rechts)
      final s = (_rnd.nextBool() ? 1.0 : -1.0);

      // Richtung mischen (überwiegend radial, etwas tangential für Bogen)
      Offset dir = (n * radialBias + t * (tangentialBias * s));
      final len = dir.distance;
      if (len > 0) dir = dir / len;

      final speed = baseSpeed * (0.8 + _rnd.nextDouble() * 0.4);
      final pos = center + n * radius;

      _parts.add(_Particle(
        pos: pos,
        vel: dir * speed,
        life: life.inMilliseconds / 1000.0,
        maxLife: life.inMilliseconds / 1000.0,
        size: 1.2 + _rnd.nextDouble() * 1.2,
        thickness: 1.0 + _rnd.nextDouble() * 1.0,
        color: _sparkColor(),
      ));
    }
  }

  Color _sparkColor() {
    // realistische Glühfarben
    const palette = [
      Color(0xFFFFE79C), // hellgelb
      Color(0xFFFFC66E), // gold
      Color(0xFFFF8C3A), // orange
      Color(0xFFDD5E1E), // rotglut
    ];
    return palette[_rnd.nextInt(palette.length)];
  }
}

class ChromeSparksPainter extends CustomPainter {
  final List<_Particle> parts;
  ChromeSparksPainter(this.parts);

  @override
  void paint(Canvas canvas, Size size) {
    if (parts.isEmpty) return;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final p in parts) {
      final t = (p.life / p.maxLife).clamp(0.0, 1.0);
      final fade = Curves.easeOut.transform(t);

      // Richtung & Länge
      final v = p.vel;
      final speed = v.distance; if (speed < 0.01) continue;
      final dir = Offset(v.dx / speed, v.dy / speed);

      // Schweiflänge abhängig von Energie
      final tailLen = (8 + speed * 0.03).clamp(10, 38).toDouble();
      final start = p.pos - dir * tailLen;

      // Gebogene Bahn: Control-Point leicht angehoben (spiegelverkehrt)
      final mid = Offset((start.dx + p.pos.dx) * 0.5, (start.dy + p.pos.dy) * 0.5);
      final control = mid - Offset(0, tailLen * 0.55); // nach oben biegen (spiegelverkehrt)

      // Farben/Opazitäten
      final col = p.color;
      stroke
        ..color = col.withOpacity(0.85 * fade)
        ..strokeWidth = p.thickness;
      halo
        ..color = col.withOpacity(0.25 * fade)
        ..strokeWidth = p.thickness * 2.2;

      // Halo zuerst, dann Kern
      final pathHalo = Path()..moveTo(start.dx, start.dy);
      pathHalo.quadraticBezierTo(control.dx, control.dy, p.pos.dx, p.pos.dy);
      canvas.drawPath(pathHalo, halo);

      final path = Path()..moveTo(start.dx, start.dy);
      path.quadraticBezierTo(control.dx, control.dy, p.pos.dx, p.pos.dy);
      canvas.drawPath(path, stroke);

      // kleine Glut am Kopf
      final core = Paint()..color = col.withOpacity(0.5 * fade);
      canvas.drawCircle(p.pos, p.size, core);
    }
  }

  @override
  bool shouldRepaint(covariant ChromeSparksPainter oldDelegate) {
    // wir repainten, solange sich Partikel ändern
    return true;
  }
}
