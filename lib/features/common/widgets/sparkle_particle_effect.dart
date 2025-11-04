import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Zauberpulver-Effekt: Sparkles/Particles die von einer Position ausstrahlen
class SparkleParticleEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final int particleCount;
  final Duration duration;
  final double spreadRadius;
  final VoidCallback? onComplete;

  const SparkleParticleEffect({
    super.key,
    required this.position,
    this.color = Colors.white,
    this.particleCount = 20,
    this.duration = const Duration(milliseconds: 1000),
    this.spreadRadius = 60.0,
    this.onComplete,
  });

  @override
  State<SparkleParticleEffect> createState() => _SparkleParticleEffectState();
}

class _SparkleParticleEffectState extends State<SparkleParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Erstelle zufällige Partikel
    final random = math.Random();
    _particles = List.generate(
      widget.particleCount,
      (index) => _Particle(
        angle: random.nextDouble() * 2 * math.pi, // Zufälliger Winkel
        distance: widget.spreadRadius * (0.3 + random.nextDouble() * 0.7), // Zufällige Distanz
        size: 2.0 + random.nextDouble() * 4.0, // Zufällige Größe
        speed: 0.5 + random.nextDouble() * 0.5, // Zufällige Geschwindigkeit
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Die Position ist die Mitte, aber Positioned verwendet die obere linke Ecke
    // Daher müssen wir die Hälfte der CustomPaint-Größe abziehen
    final paintSize = widget.spreadRadius * 2;
    final offset = paintSize / 2;
    
    return Positioned(
      left: widget.position.dx - offset,
      top: widget.position.dy - offset,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(paintSize, paintSize),
              painter: _SparklePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double speed;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.speed,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _SparklePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // Berechne die aktuelle Position basierend auf dem Fortschritt
      final currentDistance = particle.distance * progress * particle.speed;
      final x = center.dx + math.cos(particle.angle) * currentDistance;
      final y = center.dy + math.sin(particle.angle) * currentDistance;

      // Berechne die Opacity (fade out)
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      // Zeichne den Partikel
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Zeichne einen kleinen Stern/Sparkle
      _drawSparkle(canvas, Offset(x, y), particle.size * (1.0 - progress * 0.5), paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    // Zeichne einen kleinen Stern mit 8 Strahlen (wie Zauberpulver)
    final path = Path();
    final halfSize = size * 0.5;
    
    // 8 Strahlen in alle Richtungen
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final x1 = center.dx + math.cos(angle) * size;
      final y1 = center.dy + math.sin(angle) * size;
      final x2 = center.dx + math.cos(angle) * halfSize;
      final y2 = center.dy + math.sin(angle) * halfSize;
      
      path.moveTo(center.dx, center.dy);
      path.lineTo(x1, y1);
      path.moveTo(center.dx, center.dy);
      path.lineTo(x2, y2);
    }
    
    canvas.drawPath(path, paint);
    
    // Zeichne einen kleinen leuchtenden Kreis in der Mitte
    canvas.drawCircle(center, size * 0.4, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

