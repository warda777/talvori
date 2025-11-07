import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Abstract Home Silhouette – goldene Hauskontur mit dezentem Glow.
/// Ideal als Hintergrund für die "Home & Living" Kachel.
class HomeSilhouetteBackground extends StatefulWidget {
  const HomeSilhouetteBackground({
    super.key,
    this.gold = const Color(0xFFFFC66A),
    this.glow = 25.0,
    this.strokeWidth = 2.0,
    this.scale = 0.55,
  });

  final Color gold;
  final double glow;
  final double strokeWidth;
  final double scale;

  @override
  State<HomeSilhouetteBackground> createState() => _HomeSilhouetteBackgroundState();
}

class _HomeSilhouetteBackgroundState extends State<HomeSilhouetteBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _HomePainter(
          t: _c.value,
          gold: widget.gold,
          glow: widget.glow,
          stroke: widget.strokeWidth,
          scale: widget.scale,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HomePainter extends CustomPainter {
  final double t;
  final Color gold;
  final double glow;
  final double stroke;
  final double scale;

  _HomePainter({
    required this.t,
    required this.gold,
    required this.glow,
    required this.stroke,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Hintergrund
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black,
    );

    // Glow atmen lassen + Haus schweben
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
    final hover = 3.0 * math.sin(t * 2 * math.pi);

    final paintGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 1 + 0.6 * pulse
      ..color = gold.withOpacity(0.35 + 0.55 * pulse)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        glow * (0.6 + 0.8 * pulse),
      );

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = gold.withOpacity(0.8 + 0.2 * pulse);

    final w = size.width * scale;
    final h = size.height * scale * 0.9;
    final cx = size.width / 2;
    final cy = size.height / 2 + 10 + hover;

    final path = Path();

    // Hauskontur
    final roofPeak = Offset(cx, cy - h * 0.7);
    final leftRoof = Offset(cx - w / 2, cy - h * 0.25);
    final rightRoof = Offset(cx + w / 2, cy - h * 0.25);
    final leftBottom = Offset(cx - w / 2, cy + h * 0.45);
    final rightBottom = Offset(cx + w / 2, cy + h * 0.45);

    path.moveTo(leftRoof.dx, leftRoof.dy);
    path.lineTo(roofPeak.dx, roofPeak.dy);
    path.lineTo(rightRoof.dx, rightRoof.dy);
    path.lineTo(rightBottom.dx, rightBottom.dy);
    path.lineTo(leftBottom.dx, leftBottom.dy);
    path.close();

    // Fenster (kleines Quadrat in der Mitte)
    final fw = w * 0.22;
    final fh = fw;
    final fx = cx - fw / 2;
    final fy = cy - fh / 2;
    final windowRect = Rect.fromLTWH(fx, fy, fw, fh);
    final windowLines = Path()
      ..addRect(windowRect)
      ..moveTo(fx + fw / 2, fy)
      ..lineTo(fx + fw / 2, fy + fh)
      ..moveTo(fx, fy + fh / 2)
      ..lineTo(fx + fw, fy + fh / 2);

    // Glow + Linie
    canvas.drawPath(path, paintGlow);
    canvas.drawPath(path, paintLine);
    canvas.drawPath(windowLines, paintGlow);
    canvas.drawPath(windowLines, paintLine);
  }

  @override
  bool shouldRepaint(_HomePainter oldDelegate) => oldDelegate.t != t;
}
