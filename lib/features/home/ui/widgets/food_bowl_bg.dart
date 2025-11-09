import 'dart:math' as math;
import 'package:flutter/material.dart';

class FoodBowlBackground extends StatefulWidget {
  const FoodBowlBackground({
    super.key,
    this.gold = const Color(0xFFFFC66A),
    this.glow = 28.0,
    this.speed = 1.0,     // 0.6–1.2 ruhig
    this.scale = 0.38,    // 0.32–0.45 für kleine Kacheln
    this.yAlign = 0.60,   // 0..1 (Tiefe der Schale)
  });

  final Color gold;
  final double glow;
  final double speed;
  final double scale;
  final double yAlign;

  @override
  State<FoodBowlBackground> createState() => _FoodBowlBackgroundState();
}

class _FoodBowlBackgroundState extends State<FoodBowlBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..repeat();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _BowlPainter(
          t: _c.value * widget.speed,
          gold: widget.gold,
          glow: widget.glow,
            scale: widget.scale,
            yAlign: widget.yAlign,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BowlPainter extends CustomPainter {
  final double t;
  final Color gold;
  final double glow;
  final double scale;
  final double yAlign;

  _BowlPainter({
    required this.t,
    required this.gold,
    required this.glow,
    required this.scale,
    required this.yAlign,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // tief schwarz
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final cx = size.width * 0.5;
    final cy = size.height * yAlign;
    final w = size.width * scale;     // Schalenbreite
    final h = w * 0.5;                // Ellipsenhöhe des Rands
    final bodyH = w * 0.55;           // Körperhöhe

    // Bodenlicht
    final floor = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [gold.withOpacity(0.32), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy + bodyH * 0.48), radius: w * 1.05))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 1.1);
    canvas.drawCircle(Offset(cx, cy + bodyH * 0.48), w * 0.95, floor);

    // Schalenkörper – weicher Verlauf
    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy + bodyH * 0.18), width: w, height: bodyH),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gold.withOpacity(0.95),
          gold.withOpacity(0.55),
          gold.withOpacity(0.1),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(bodyRect.outerRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 0.45);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Oberer Rand – helle Ellipse
    final rimRect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final rimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = gold.withOpacity(0.95)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glow * 1.05);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..color = gold.withOpacity(0.98);
    canvas.drawOval(rimRect.inflate(2.5), rimGlow);
    canvas.drawOval(rimRect, rim);

    // Innenfläche (Deckel) – sanfter Glow
    final inner = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 0.9,
        colors: [gold.withOpacity(0.6), gold.withOpacity(0.1)],
        stops: const [0.0, 1.0],
      ).createShader(rimRect);
    canvas.drawOval(rimRect.deflate(1.2), inner);

    // Vertiefung / Innenschale
    final innerDepthRect = Rect.fromCenter(
      center: Offset(cx, cy - h * 0.08),
      width: w * 0.72,
      height: h * 0.55,
    );
    final innerDepthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gold.withOpacity(0.25),
          gold.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(innerDepthRect);
    canvas.drawOval(innerDepthRect, innerDepthPaint);

    final innerDepthStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = gold.withOpacity(0.65);
    canvas.drawOval(innerDepthRect, innerDepthStroke);

    // Dampf – kräftig bis nach oben
    final baseStroke = 2.6;
    final count = 4;
    for (int i = 0; i < count; i++) {
      final seed = i * 1.45;
      final phase = t * 2 * math.pi + seed;
      final baseX = cx + (i - (count - 1) / 2) * w * 0.22;
      final baseY = cy - h * 0.35;
      final height = size.height * 1.1;
      final steps = 70;

      Offset? prev;
      for (int s = 0; s <= steps; s++) {
        final p = s / steps;
        final y = baseY - p * height;
        final amp = (1 - p) * (w * 0.18);
        final lateral = math.sin(phase + s / 6.4) * amp
                      + 0.35 * math.sin(phase * 2.0 + s / 2.8) * amp;
        final x = baseX + lateral;

        if (prev != null) {
          final flicker = 0.72 + 0.28 * math.sin(phase * 2.4 + p * 10.0);
          final opacity = (0.32 + 0.55 * (1 - p)) * flicker;
          final sw = baseStroke * (0.9 + 0.55 * flicker) * (1 - p * 0.4);

          final segPaint = Paint()
      ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = sw
            ..color = gold.withOpacity(opacity.clamp(0.0, 1.0))
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              glow * (0.4 * (1 - p) + 0.85),
            );

          final seg = Path()
            ..moveTo(prev.dx, prev.dy)
            ..lineTo(x, y);
          canvas.drawPath(seg, segPaint);
        }
        prev = Offset(x, y);
      }
    }
  }

  @override
  bool shouldRepaint(_BowlPainter o) =>
      o.t != t || o.gold != gold || o.glow != glow || o.scale != scale || o.yAlign != yAlign;
}
