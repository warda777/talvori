import 'dart:math' as math;
import 'package:flutter/material.dart';

class FavoritesHeartBackground extends StatefulWidget {
  const FavoritesHeartBackground({super.key});

  @override
  State<FavoritesHeartBackground> createState() => _FavoritesHeartBackgroundState();
}

class _FavoritesHeartBackgroundState extends State<FavoritesHeartBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_controller.value);
        final pulse = 1 + 0.02 * math.sin(t * math.pi * 2);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: CustomPaint(
            painter: _HeartPainter(pulse),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _HeartPainter extends CustomPainter {
  final double pulse;
  _HeartPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortSide = math.min(size.width, size.height);
    final baseSize = shortSide * 0.42 * pulse; // fast gesamte Kachelgröße

    final glowColor = const Color(0xFFFFC66A); // Gold wie My Words

    // Hintergrund-Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(0.28),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseSize * 2.7));
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Pulsierende Ringe
    for (int i = 0; i < 3; i++) {
      final progress = (pulse * 0.6 + i * 0.25) % 1.0;
      final ringRadius = baseSize * (1.3 + progress * 1.5);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = glowColor.withOpacity(0.14 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Herz-Pfad
    final path = _heartPath(center, baseSize);

    // Leichtes Fülllicht im Herz
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(0.55),
          glowColor.withOpacity(0.08),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseSize * 0.9))
      ..blendMode = BlendMode.plus;
    canvas.drawPath(path, fill);

    // Leuchtender Schein außen
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = glowColor.withOpacity(0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 46)
      ..blendMode = BlendMode.plus;
    canvas.drawPath(path, outer);

    // Herzlinie
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = glowColor.withOpacity(0.95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12)
      ..blendMode = BlendMode.plus;
    canvas.drawPath(path, line);
  }

  Path _heartPath(Offset c, double s) {
    final w = s, h = s;
    final path = Path();
    final top = Offset(c.dx, c.dy - h * 0.3);
    final bottom = Offset(c.dx, c.dy + h * 0.4);

    path.moveTo(top.dx, top.dy);
    path.cubicTo(
      c.dx - w * 0.5, c.dy - h * 0.65,
      c.dx - w * 0.7, c.dy + h * 0.1,
      bottom.dx, bottom.dy,
    );
    path.cubicTo(
      c.dx + w * 0.7, c.dy + h * 0.1,
      c.dx + w * 0.5, c.dy - h * 0.65,
      top.dx, top.dy,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) => oldDelegate.pulse != pulse;
}
