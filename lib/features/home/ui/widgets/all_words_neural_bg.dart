// lib/features/home/ui/widgets/all_words_neural_bg.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Sehr feines, dezentes, goldenes neuronales Netz – ideal als leiser
/// Hintergrund für eine Kachel. Fokus: dünne, gekrümmte Linien, minimaler Glow.
class NeuralGlowBackground extends StatefulWidget {
  const NeuralGlowBackground({
    super.key,
    this.seed = 11,
    this.speed = 0.22,
    this.density = 14,
    this.nodeCount = 20,
    this.bgColor = const Color(0xFF000000),
    this.lineColor = const Color(0xFFE6C27A),
    this.focus = Alignment.center, // Cluster-Position
    this.spread = 0.34,            // 0..1 – kleinere Werte = enger um den Fokus
  });

  final int seed;
  final double speed;
  final int density;
  final int nodeCount;
  final Color bgColor;
  final Color lineColor;
  final Alignment focus;   // Cluster-Position (z.B. center)
  final double spread;     // 0..1 – kleinere Werte = enger um den Fokus

  @override
  State<NeuralGlowBackground> createState() => _NeuralGlowBackgroundState();
}

class _NeuralGlowBackgroundState extends State<NeuralGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1e9, period: const Duration(days: 1));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
          return ColoredBox(
            color: widget.bgColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
            painter: _NeuralGlowPainter(
              t: t,
              seed: widget.seed,
              speed: widget.speed,
              density: widget.density,
              nodeCount: widget.nodeCount,
              bgColor: widget.bgColor,
              lineColor: widget.lineColor,
              focus: widget.focus,
              spread: widget.spread,
            ),
            isComplex: true,
            willChange: true,
                ),
                Container(color: Colors.black.withOpacity(0.35)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NeuralGlowPainter extends CustomPainter {
  _NeuralGlowPainter({
    required this.t,
    required this.seed,
    required this.speed,
    required this.density,
    required this.nodeCount,
    required this.bgColor,
    required this.lineColor,
    required this.focus,
    required this.spread,
  });

  final double t;
  final int seed;
  final double speed;
  final int density;
  final int nodeCount;
  final Color bgColor;
  final Color lineColor;
  final Alignment focus; // Cluster-Position
  final double spread;   // 0..1 – kleinere Werte = enger um den Fokus

  @override
  void paint(Canvas canvas, Size size) {
    // Hintergrund
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    final rnd = Random(seed);

    // Mal-Objekte (extrem fein, zurückhaltend)
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..color = lineColor.withOpacity(0.18)
      ..isAntiAlias = true;

    final subtleGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = lineColor.withOpacity(0.26)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.4)
      ..isAntiAlias = true;

    final nodeCore = Paint()
      ..style = PaintingStyle.fill
      ..color = lineColor.withOpacity(0.45);

    // Fokuspunkt in der Mitte (oder wo "focus" zeigt)
    final fx = (focus.x + 1) * 0.5;
    final fy = (focus.y + 1) * 0.5;
    final center = Offset(fx * size.width, fy * size.height);

    // 2D-Gauß um den Mittelpunkt -> natürlich „mittig" gruppiert
    Offset gaussian2D(Random r) {
      final u1 = max(1e-6, r.nextDouble());
      final u2 = r.nextDouble();
      final rad = sqrt(-2 * log(u1));
      final ang = 2 * pi * u2;
      final nx = rad * cos(ang);
      final ny = rad * sin(ang);
      final radius = size.shortestSide * spread; // Steuerung der Enge
      return center + Offset(nx, ny) * radius;
    }

    // sanfter Clamp: falls zu nah am Rand -> etwas Richtung Zentrum ziehen
    final safeRect = Rect.fromLTWH(
      size.width * 0.06,
      size.height * 0.10,
      size.width * 0.88,
      size.height * 0.80,
    );

    // Knoten (Gauß-Verteilung um Fokuspunkt)
    final nodes = List.generate(nodeCount, (_) {
      final p = gaussian2D(rnd);
      return safeRect.contains(p) ? p : Offset.lerp(p, center, 0.6)!;
    });

    // Node-Kerne ohne zusätzlichen Glow
    for (var i = 0; i < nodes.length; i++) {
      final p = nodes[i];
      final pulse = 0.45 + 0.3 * sin(t * 0.6 + i * 0.9);
      final r = 1.5 + pulse * 1.4; // größerer Radius
      final halo = ui.Gradient.radial(
        p,
        r * 10,
        [lineColor.withOpacity(0.16), Colors.transparent],
        [0.0, 1.0],
      );
      canvas.drawCircle(
        p,
        r * 10,
        Paint()..shader = halo..blendMode = BlendMode.plus,
      );
      canvas.drawCircle(p, 1.6, nodeCore);
    }

    // ARC-Parameter (fein & dezent) - center wurde bereits oben berechnet
    for (var i = 0; i < density; i++) {
      final baseR = size.shortestSide * (0.28 + rnd.nextDouble() * 0.16);
      final rJit = baseR * (0.08 + rnd.nextDouble() * 0.14);
      final r = baseR + (rnd.nextBool() ? rJit : -rJit);

      final a0 = rnd.nextDouble() * 2 * pi;
      final da = (0.55 + rnd.nextDouble() * 0.85); // Bogenlänge in Radiant

      // Leichte zeitliche Drift -> lebendig, aber ruhig
      final drift = 0.08 * sin(t * speed * 0.9 + i * 1.7);
      final a1 = a0 + da + drift;

      final p0 = center + Offset(cos(a0), sin(a0)) * r;
      final p1 = center + Offset(cos(a1), sin(a1)) * r;

      // Quadratic-Bezier annähert den Kreisbogen sehr sanft
      Offset quadCtrl(Offset c, double r, double aStart, double aEnd) {
        final am = (aStart + aEnd) * 0.5;
        // Controlpunkt leicht nach innen verlegen -> weicher „Bauch"
        final inward = 0.94;
        return c + Offset(cos(am), sin(am)) * (r * inward);
      }

      final ctrl = quadCtrl(center, r, a0, a1);

      final path = Path()
        ..moveTo(p0.dx, p0.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);

      // zeichnen (dezent)
      canvas.drawPath(path, hairline);

      // winziger Laufpunkt entlang des Bogens
      final metrics = path.computeMetrics();
      for (final m in metrics) {
        final localT = (t * speed + i * 0.31) % 1.0;
        final pos = m.getTangentForOffset(m.length * localT)!.position;

        final comet = ui.Gradient.radial(
          pos,
          12,
          [lineColor.withOpacity(0.24), Colors.transparent],
          [0.0, 1.0],
        );
        canvas.drawCircle(
          pos,
          1.6,
          Paint()..color = lineColor.withOpacity(0.32),
        );
        canvas.drawCircle(
          pos,
          12,
          Paint()..shader = comet..blendMode = BlendMode.plus,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralGlowPainter o) =>
      o.t != t ||
      o.seed != seed ||
      o.speed != speed ||
      o.density != density ||
      o.nodeCount != nodeCount ||
      o.bgColor != bgColor ||
      o.lineColor != lineColor ||
      o.focus != focus ||
      o.spread != spread;
}

extension on Offset {
  Offset get normalized {
    final len = distance;
    return len == 0 ? this : this / len;
  }
}
