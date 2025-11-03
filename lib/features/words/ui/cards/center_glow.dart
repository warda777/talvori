import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Statischer Glow-Effekt im Zentrum (keine Rotation)
/// Verwendet den gleichen Fade-In/Out-Zyklus wie GlowOrb
class CenterGlow extends StatefulWidget {
  final double size;           // Größe des Containers
  final double glowSize;       // Größe des Glows
  final Duration duration;     // Dauer der Rotation (für Synchronisation)
  final Color color;           // Farbe des Glows

  const CenterGlow({
    super.key,
    required this.size,
    this.glowSize = 20,
    this.duration = const Duration(milliseconds: 3000),
    this.color = const Color(0xFFF1C86B), // Gold
  });

  @override
  State<CenterGlow> createState() => _CenterGlowState();
}

class _CenterGlowState extends State<CenterGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Gleiche Zeiten wie GlowOrb: Fade-In (800ms) + Rotation (3000ms) + Fade-Out (800ms) + Pause (2000ms)
    final fadeInDuration = const Duration(milliseconds: 800);
    final fadeOutDuration = const Duration(milliseconds: 800);
    final pauseDuration = const Duration(milliseconds: 2000);
    final totalDuration = fadeInDuration + widget.duration + fadeOutDuration + pauseDuration;
    
    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
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
    
    _controller.repeat();
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
        animation: _fadeAnimation,
        builder: (context, child) {
          final centerX = widget.size / 2;
          final centerY = widget.size / 2;
          
          return Opacity(
            opacity: _fadeAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CenterGlowPainter(
                position: Offset(centerX, centerY),
                glowSize: widget.glowSize,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CenterGlowPainter extends CustomPainter {
  final Offset position;
  final double glowSize;
  final Color color;

  _CenterGlowPainter({
    required this.position,
    required this.glowSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Radialer Gradient für den Glow
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.5),
        color.withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    // Haupt-Glow (rund)
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: position, radius: glowSize),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(position, glowSize, paint);

    // Äußerer Glow (subtiler)
    final outerGlowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, glowSize * 1.8, outerGlowPaint);
  }

  @override
  bool shouldRepaint(_CenterGlowPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.glowSize != glowSize ||
        oldDelegate.color != color;
  }
}


