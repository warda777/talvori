import 'dart:math' as math;
import 'package:flutter/material.dart';

class WordHubRisingGlowBackground extends StatefulWidget {
  const WordHubRisingGlowBackground({
    super.key,
    this.cornerRadius = 22,
    this.gold = const Color(0xFFFFC66A),
    this.blue = const Color(0xFF6CB7FF),
    this.period = const Duration(seconds: 18),
  });

  final double cornerRadius;
  final Color gold;
  final Color blue;
  final Duration period;

  @override
  State<WordHubRisingGlowBackground> createState() =>
      _WordHubRisingGlowBackgroundState();
}

class _WordHubRisingGlowBackgroundState
    extends State<WordHubRisingGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _RisingGlowPainter(
          t: Curves.easeInOut.transform(_c.value),
          r: widget.cornerRadius,
          gold: widget.gold,
          blue: widget.blue,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RisingGlowPainter extends CustomPainter {
  final double t; // 0..1
  final double r;
  final Color gold, blue;
  _RisingGlowPainter({required this.t, required this.r, required this.gold, required this.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));

    // Hart clippen, keine AA-Mischung an Ecken => keine hellen Säume
    canvas.save();
    canvas.clipRRect(rr, doAntiAlias: false);

    // 1) Tiefschwarze Basis
    canvas.drawRect(rect, Paint()..color = Colors.black);

    // 2) Rising Glow: sanft vom unteren Rand, Goldkern + blauer Außenhalo
    //    leichte vertikale "Sonnenaufgang"-Bewegung
    final rise = 0.92 - 0.06 * math.sin(t * 2 * math.pi); // 0.86..0.92
    final center = Alignment(0, (rise * 2) - 1); // Alignment für Gradients

    // Blaues Außenlicht (weit, sehr weich)
    final blueGlow = Paint()
      ..shader = RadialGradient(
        center: center,
        radius: 1.25,
        colors: [
          blue.withOpacity(0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, blueGlow);

    // Goldene Hauptaura
    final goldGlow = Paint()
      ..shader = RadialGradient(
        center: center,
        radius: 1.10,
        colors: [
          gold.withOpacity(0.48),
          gold.withOpacity(0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, goldGlow);

    // Goldener Kern nahe Unterkante (größer, intensiver)
    final core = Paint()
      ..shader = RadialGradient(
        center: center,
        radius: 0.62,
        colors: [
          gold.withOpacity(0.68),
          gold.withOpacity(0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, core);

    canvas.restore();

    // 3) Schwarzer Innensaum (1–2 px) killt evtl. Rest-Saumbildung
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black
      ..isAntiAlias = false;
    canvas.drawRRect(rr.deflate(1), seam);
  }

  @override
  bool shouldRepaint(covariant _RisingGlowPainter o) =>
      o.t != t || o.r != r || o.gold != gold || o.blue != blue;
}
