import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Kugelförmiger Glow-Effekt, der um einen Punkt rotiert
class GlowOrb extends StatefulWidget {
  final double size;           // Größe des Containers
  final double radius;         // Radius der Rotation (Abstand vom Zentrum)
  final double orbSize;        // Größe der Kugel
  final Duration duration;     // Dauer einer Umdrehung
  final Color color;           // Farbe der Kugel
  final bool loop;             // Endlos wiederholen

  const GlowOrb({
    super.key,
    required this.size,
    this.radius = 45,
    this.orbSize = 8,
    this.duration = const Duration(milliseconds: 3000),
    this.color = const Color(0xFFF1C86B), // Gold
    this.loop = true,
  });

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Gesamtdauer: Fade-In (800ms) + Rotation (3000ms) + Fade-Out (800ms) + Pause (2000ms)
    final fadeInDuration = const Duration(milliseconds: 800);
    final fadeOutDuration = const Duration(milliseconds: 800);
    final pauseDuration = const Duration(milliseconds: 2000);
    final totalDuration = fadeInDuration + widget.duration + fadeOutDuration + pauseDuration;
    
    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );
    
    // Rotation: während des gesamten sichtbaren Zeitraums (Fade-In + voll + Fade-Out)
    // Startet bei 0 und endet bei 1 während der gesamten sichtbaren Phase
    final visibleStart = 0.0;
    final visibleEnd = (fadeInDuration.inMilliseconds + widget.duration.inMilliseconds + fadeOutDuration.inMilliseconds) / totalDuration.inMilliseconds;
    
    // Rotation: während des gesamten sichtbaren Zeitraums (eine vollständige Umdrehung)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(visibleStart, visibleEnd, curve: Curves.linear),
      ),
    );
    
    // Fade-Animation: Fade-In (0-800ms), dann voll (800-3800ms), dann Fade-Out (3800-4600ms), dann Pause (4600-6600ms)
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: fadeInDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: widget.duration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: fadeOutDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: pauseDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
    ]).animate(_controller);
    
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.repeat(); // Wiederholt sich immer (mit Pause)
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation, _fadeAnimation]),
        builder: (context, child) {
          final angle = _animation.value * 2 * math.pi;
          final centerX = widget.size / 2;
          final centerY = widget.size / 2;
          
          // Position der Kugel berechnen
          final x = centerX + widget.radius * math.cos(angle);
          final y = centerY + widget.radius * math.sin(angle);
          
          return Opacity(
            opacity: _fadeAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _OrbPainter(
                position: Offset(x, y),
                orbSize: widget.orbSize,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Offset position;
  final double orbSize;
  final Color color;

  _OrbPainter({
    required this.position,
    required this.orbSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ovaler Glow mit radialem Gradient
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(1.0),
        color.withOpacity(0.8),
        color.withOpacity(0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    // Oval statt Kreis - horizontal gestreckt
    final ovalWidth = orbSize * 2.5; // Breiter als hoch
    final ovalHeight = orbSize * 1.2; // Höhe
    
    final ovalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: ovalWidth,
        height: ovalHeight,
      ),
      Radius.circular(ovalHeight / 2),
    );

    // Haupt-Oval mit Gradient
    final paint = Paint()
      ..shader = gradient.createShader(ovalRect.outerRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRRect(ovalRect, paint);

    // Leichter äußerer Glow (auch oval)
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;

    final glowOvalRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: ovalWidth * 1.5,
        height: ovalHeight * 1.5,
      ),
      Radius.circular(ovalHeight / 2),
    );

    canvas.drawRRect(glowOvalRect, glowPaint);
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.orbSize != orbSize ||
        oldDelegate.color != color;
  }
}

