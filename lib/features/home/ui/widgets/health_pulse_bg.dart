import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Golden Pulse Flow – sanfte, goldene EKG-Linie auf schwarzem Grund.
/// Ideal als Kachel-Hintergrund; skaliert automatisch auf die Kachelgröße.
class HealthPulseBackground extends StatefulWidget {
  const HealthPulseBackground({
    super.key,
    this.gold = const Color(0xFFFFC66A), // konsistent mit vorhandenen Gold-Glows
    this.strokeWidth = 2.0,
    this.glow = 18.0,
    this.speed = 0.6, // langsamer Standard
    this.peaks = const [0.52], // Position(en) 0..1 der Hauptspitze(n)
  });

  final Color gold;
  final double strokeWidth;
  final double glow;
  final double speed;
  final List<double> peaks;

  @override
  State<HealthPulseBackground> createState() => _HealthPulseBackgroundState();
}

class _HealthPulseBackgroundState extends State<HealthPulseBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 5));

  int _loops = 0; // <-- NEU

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _loops++;
        _c.forward(from: 0.0);
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _phase() => (((_c.value + _loops) * widget.speed) % 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        painter: _PulsePainter(
          t: _phase(),
          gold: widget.gold,
          stroke: widget.strokeWidth,
          glow: widget.glow,
          peaks: widget.peaks,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double t;
  final Color gold;
  final double stroke;
  final double glow;
  final List<double> peaks;

  _PulsePainter({
    required this.t,
    required this.gold,
    required this.stroke,
    required this.glow,
    required this.peaks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Schwarzer Hintergrund
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black,
    );

    final midY = size.height * 0.56; // leicht unter der Mitte
    final width = size.width;
    final int samples = (width * 2).ceil();

    double samplePulse(double phase) {
      const points = [
        Offset(0.00, 0.00),
        Offset(0.38, 0.00),
        Offset(0.44, 0.06),
        Offset(0.46, -0.05),
        Offset(0.50, -0.34),
        Offset(0.525, 0.18),
        Offset(0.55, 0.08),
        Offset(0.62, 0.00),
        Offset(1.00, 0.00),
      ];

      // Phase 0..1, lineare Interpolation zwischen Stützpunkten
      for (var i = 0; i < points.length - 1; i++) {
        final a = points[i];
        final b = points[i + 1];
        if (phase >= a.dx && phase <= b.dx) {
          final localT = (phase - a.dx) / (b.dx - a.dx);
          return a.dy + (b.dy - a.dy) * localT;
        }
      }
      return 0.0;
    }

    final path = Path();
    for (int i = 0; i <= samples; i++) {
      final double x = i * width / samples;
      double phase = (x / width + t) % 1.0;
      final double offset = samplePulse(phase);
      final double wobble = math.sin(phase * 2 * math.pi) * 0.6;
      final double y = midY + offset * size.height + wobble;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 2.4
      ..color = gold.withOpacity(0.65)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glow * 1.15);
    canvas.drawPath(path, glowPaint);

    final haloPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 1.0
      ..color = gold.withOpacity(0.55)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, glow * 0.55);
    canvas.drawPath(path, haloPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          gold.withOpacity(0.55),
          gold,
          gold.withOpacity(0.55),
        ],
      ).createShader(Rect.fromLTWH(0, midY - 4, size.width, 8));
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.t != t || old.gold != gold || old.stroke != stroke || old.glow != glow || old.peaks != peaks;
}
