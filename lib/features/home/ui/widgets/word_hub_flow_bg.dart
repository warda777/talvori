import 'dart:math' as math;
import 'package:flutter/material.dart';

class WordHubFlowBackground extends StatefulWidget {
  final Widget? child;
  const WordHubFlowBackground({super.key, this.child});

  @override
  State<WordHubFlowBackground> createState() => _WordHubFlowBackgroundState();
}

class _WordHubFlowBackgroundState extends State<WordHubFlowBackground>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC66A);

  // sehr langsame, ruhige Animation
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  // weit verteilte, feste Punkte (normierte Koordinaten 0..1)
  late final List<Offset> _dots =
      _makeSpacedDots(seed: 1337, count: 28, minDist: .14);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_c.value); // 0..1
        return Stack(
          children: [
            // wirklich tiefschwarz – kein Overlay/Gradient
            const ColoredBox(color: Colors.black),
            Positioned.fill(
              child: CustomPaint(
                painter: _ThreadsAndDotsPainter(
                  t: t,
                  gold: _gold,
                  normDots: _dots,
                ),
              ),
            ),
            if (widget.child != null) Positioned.fill(child: widget.child!),
          ],
        );
      },
    );
  }

  // einfache, gleichmäßig verteilte Punkte (Poisson-ähnlich)
  List<Offset> _makeSpacedDots({
    required int seed,
    required int count,
    required double minDist,
  }) {
    final rnd = math.Random(seed);
    final pts = <Offset>[];
    int tries = 0;
    while (pts.length < count && tries < 4000) {
      tries++;
      final p = Offset(rnd.nextDouble(), rnd.nextDouble());
      if (pts.every((q) => (p - q).distance >= minDist)) pts.add(p);
    }
    return pts;
  }
}

class _ThreadsAndDotsPainter extends CustomPainter {
  final double t; // 0..1
  final Color gold;
  final List<Offset> normDots;

  _ThreadsAndDotsPainter({
    required this.t,
    required this.gold,
    required this.normDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final baseY = h * 0.74;

    // EINZELNER, feiner Strich je Faden (kein Doppel-Look, kein Nebel)
    final threadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.38
      ..color = gold.withOpacity(.70)
      ..blendMode = BlendMode.srcOver;

    // 6 feine, runde Stränge – je eine Cubic für weichen Auslauf rechts
    const strands = 6;
    for (int i = 0; i < strands; i++) {
      final spread = (i - (strands - 1) / 2) * 8.0;     // kleine vertikale Spreizung
      final amp    = 26.0 + i * 2.5;                    // Bogenhöhe
      final ph     = t * 2 * math.pi * .6 + i * .85;    // sehr langsame Bewegung

      final p0 = Offset(0.02 * w, baseY + spread + _sway(ph + .3, amp * .6));
      final p3 = Offset(0.98 * w, baseY + spread + _sway(ph + 2.2, amp * .35));
      final p1 = Offset(0.32 * w, baseY - 40 + spread + _sway(ph + .9,  amp));
      final p2 = Offset(0.86 * w, baseY + 10 + spread + _sway(ph + 1.6, amp * .7));

      final path = Path()
        ..moveTo(p0.dx, p0.dy)
        ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

      canvas.drawPath(path, threadPaint);
    }

    // Punkte: winzig, weit auseinander, über die GANZE Kachel verteilt
    for (int i = 0; i < normDots.length; i++) {
      final base = Offset(normDots[i].dx * w, normDots[i].dy * h);

      // ganz leichte Drift, sehr langsam
      final drift = 2.0 * math.sin((t + i * .07) * 2 * math.pi);
      final pos = base + Offset(drift * 0.3, drift * 0.15);

      final tw = .5 + .5 * math.sin(i * .9 + t * 2 * math.pi);
      final r  = 0.6 + 0.5 * tw;

      final halo = Paint()
        ..color = gold.withOpacity(.18 * tw)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(pos, r * 1.8, halo);

      final core = Paint()
        ..color = gold.withOpacity(.95)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(pos, r, core);
    }
  }

  // sanfte, breite Bögen
  double _sway(double phase, double amp) =>
      math.sin(phase) * amp * .85 + math.sin(phase * .5) * amp * .15;

  @override
  bool shouldRepaint(covariant _ThreadsAndDotsPainter o) =>
      o.t != t || o.gold != gold || o.normDots != normDots;
}
