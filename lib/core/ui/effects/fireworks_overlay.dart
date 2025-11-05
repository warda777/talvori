import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Fireworks {
  Fireworks._();

  static void show(BuildContext context, {Duration duration = const Duration(seconds: 5)}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FireworksLayer(
        duration: duration,
        onFinished: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _FireworksLayer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onFinished;
  const _FireworksLayer({required this.duration, required this.onFinished});

  @override
  State<_FireworksLayer> createState() => _FireworksLayerState();
}

class _FireworksLayerState extends State<_FireworksLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final _Show _show;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onFinished(); })
      ..forward();

    _show = _Show.random(
      rocketsMin: 6,
      rocketsMax: 9,
      rng: math.Random(),
      duration: widget.duration,
    );
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: size,
          painter: _FireworksPainter(
            t: _c.value,
            show: _show,
          ),
        ),
      ),
    );
  }
}

class _Show {
  final List<_Rocket> rockets;
  _Show(this.rockets);

  factory _Show.random({
    required int rocketsMin,
    required int rocketsMax,
    required math.Random rng,
    required Duration duration,
  }) {
    final n = rocketsMin + rng.nextInt((rocketsMax - rocketsMin + 1).clamp(0, 12));
    final rockets = <_Rocket>[];
    for (var i = 0; i < n; i++) {
      final launchX = rng.nextDouble() * 0.9 + 0.05; // 5%–95% Breite
      final launchDelay = rng.nextDouble() * 0.4;     // Start in den ersten 40% der Show
      final ascentFrac = 0.18 + rng.nextDouble() * 0.12; // 0.18..0.30 der Gesamtdauer
      final burstFrac = launchDelay + ascentFrac;
      final hueBase = [0.0, 30.0, 60.0, 200.0, 260.0, 300.0][rng.nextInt(6)];
      rockets.add(_Rocket.random(
        rng: rng,
        launchX: launchX,
        launchDelay: launchDelay,
        burstAt: burstFrac.clamp(0.05, 0.85),
        hueBase: hueBase,
      ));
    }
    // Weiße Rakete am Ende hinzufügen
    final ascentFracW = 0.18 + rng.nextDouble() * 0.12;
    final launchDelayW = rng.nextDouble() * 0.35;
    final burstFracW = (launchDelayW + ascentFracW).clamp(0.05, 0.85);
    rockets.add(_Rocket.random(
      rng: rng,
      launchX: rng.nextDouble() * 0.9 + 0.05,
      launchDelay: launchDelayW,
      burstAt: burstFracW,
      hueBase: 0,         // ignoriert bei white=true
      white: true,        // ⬅️ weiße Rakete
    ));
    return _Show(rockets);
  }
}

class _Rocket {
  final double launchX;    // 0..1 relativ
  final double launchDelay; // 0..1 Show-Zeit
  final double burstAt;     // 0..1 Show-Zeit
  final double peakY;       // 0.25..0.55 Höhe (relativ)
  final List<_Particle> particles;
  final Color trailColor;

  _Rocket({
    required this.launchX,
    required this.launchDelay,
    required this.burstAt,
    required this.peakY,
    required this.particles,
    required this.trailColor,
  });

  factory _Rocket.random({
    required math.Random rng,
    required double launchX,
    required double launchDelay,
    required double burstAt,
    required double hueBase,
    bool white = false,
  }) {
    final peakY = 0.25 + rng.nextDouble() * 0.3; // 25–55% Bildschirmhöhe
    final pCount = 120 + rng.nextInt(120);
    final parts = List.generate(pCount, (_) => _Particle.random(rng, hueBase, white: white));
    final tCol = white ? Colors.white : HSVColor.fromAHSV(1, hueBase, 0.9, 1.0).toColor();
    return _Rocket(
      launchX: launchX,
      launchDelay: launchDelay,
      burstAt: burstAt,
      peakY: peakY,
      particles: parts,
      trailColor: tCol,
    );
  }
}

class _Particle {
  final double angle;   // 0..2π
  final double speed;   // px/relative-second
  final double life;    // 0.6..1.0 Anteil Show
  final double drag;    // 0.92..0.98
  final Color color;
  _Particle(this.angle, this.speed, this.life, this.drag, this.color);

  factory _Particle.random(math.Random r, double hueBase, {bool white = false}) {
    final col = white
        ? Colors.white
        : HSVColor.fromAHSV(1, (hueBase + r.nextDouble() * 30 - 15) % 360, 0.9, 1.0).toColor();
    return _Particle(
      r.nextDouble() * math.pi * 2,
      180 + r.nextDouble() * 260,
      0.6 + r.nextDouble() * 0.4,
      0.92 + r.nextDouble() * 0.06,
      col,
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double t; // 0..1 (Show-Zeit)
  final _Show show;
  _FireworksPainter({required this.t, required this.show});

  @override
  void paint(Canvas canvas, Size size) {
    // Additive Glow
    final layerPaint = Paint()..blendMode = BlendMode.plus;
    canvas.saveLayer(Offset.zero & size, layerPaint);

    for (final r in show.rockets) {
      if (t < r.launchDelay) continue;

      // Zeit seit Raketenstart (0..1 bis zum Burst)
      final tr = ((t - r.launchDelay) / (r.burstAt - r.launchDelay)).clamp(0.0, 1.0);
      final cx = r.launchX * size.width;

      if (t < r.burstAt) {
        // AUFSTIEG
        final ease = _easeOutCubic(tr);
        final y = size.height * (1.0 - (1.0 - r.peakY) * ease);
        _drawTrail(canvas, Offset(cx, y), r.trailColor);
        _drawSparkTail(canvas, Offset(cx, y), r.trailColor);
        // optional Knall-Vorschimmer
        if (tr > 0.85) {
          _flash(canvas, Offset(cx, y), r.trailColor.withOpacity((tr - 0.85) * 4));
        }
      } else {
        // BURST
        final tb = ((t - r.burstAt) / (r.particles.first.life)).clamp(0.0, 1.2);
        _drawBurst(canvas, size, cx, r, tb);
      }
    }

    canvas.restore();
  }

  void _drawTrail(Canvas canvas, Offset pos, Color c) {
    final p = Paint()
      ..color = c.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(ui.PointMode.points, [pos], p);
  }

  void _drawSparkTail(Canvas canvas, Offset pos, Color c) {
    final p = Paint()
      ..color = c.withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final tail = [
      pos.translate(0, 8),
      pos.translate(0, 16),
      pos.translate(0, 24),
    ];
    canvas.drawPoints(ui.PointMode.points, tail, p);
  }

  void _flash(Canvas canvas, Offset pos, Color c) {
    final p = Paint()..color = c;
    canvas.drawCircle(pos, 6, p);
  }

  void _drawBurst(Canvas canvas, Size size, double cx, _Rocket r, double tb) {
    // Gravitation
    const g = 260.0; // px/s^2 relativ
    final origin = Offset(cx, size.height * r.peakY);

    // kleine Anfangsexplosion
    if (tb < 0.08) {
      final pulse = (tb / 0.08);
      final pp = Paint()..color = r.trailColor.withOpacity(0.6 * (1 - pulse));
      canvas.drawCircle(origin, 24 * pulse, pp);
    }

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;

    for (final p in r.particles) {
      final lt = (tb / p.life).clamp(0.0, 1.0);
      if (lt <= 0 || lt >= 1.0) continue;

      // radialer Impuls
      final vx0 = math.cos(p.angle) * p.speed;
      final vy0 = math.sin(p.angle) * -p.speed; // nach oben

      // einfacher Luftwiderstand (exponentiell)
      final dragPow = math.pow(p.drag, lt * 60); // 60 ≈ frames/second relativ
      final vx = vx0 * (1.0 / dragPow);
      final vy = vy0 * (1.0 / dragPow) + g * lt;

      final pos = origin + Offset(vx * lt, vy * lt);
      final fade = (1 - lt);
      paint
        ..color = p.color.withOpacity(0.8 * fade)
        ..strokeWidth = 2.0 * (0.5 + 0.5 * fade);
      canvas.drawPoints(ui.PointMode.points, [pos], paint);

      // leichte Schweife
      if (lt > 0.15) {
        final back = origin + Offset(vx * (lt - 0.04), vy * (lt - 0.04));
        final tailPaint = Paint()
          ..color = p.color.withOpacity(0.25 * fade)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.plus;
        canvas.drawLine(back, pos, tailPaint);
      }
    }
  }

  double _easeOutCubic(double x) {
    final t = 1 - x;
    return 1 - t * t * t;
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => old.t != t || old.show != show;
}
