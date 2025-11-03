import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlowSweepRing extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final Duration duration;
  final int cyclesPerBurst;
  final Duration idle;
  final bool loop;

  const GlowSweepRing({
    super.key,
    required this.size,
    this.strokeWidth = 3.0,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.cyclesPerBurst = 1,
    this.idle = const Duration(seconds: 5),
    this.loop = true,
  });

  @override
  State<GlowSweepRing> createState() => _GlowSweepRingState();
}

class _GlowSweepRingState extends State<GlowSweepRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    
    // Start animation and repeat
    _startAnimation();
  }

  void _startAnimation() {
    if (!mounted) return;
    
    _controller.forward().then((_) {
      if (mounted && widget.loop) {
        Future.delayed(widget.idle, () {
          if (mounted) {
            _controller.reset();
            _startAnimation();
          }
        });
      }
    });
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
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: GlowSweepPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              color: widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

class GlowSweepPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  GlowSweepPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the full ring background (sehr subtil)
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Subtiler Glow-Effekt: nur 1-2 Layer statt 3
    final glowLayers = strokeWidth < 3 ? 1 : 2; // Kleinere strokeWidth = weniger Layer
    
    for (int i = 0; i < glowLayers; i++) {
      final glowRadius = radius + (i * 1.5); // Kleinerer Radius-Offset
      final glowAlpha = (0.5 - (i * 0.15)).clamp(0.1, 1.0); // Subtileres Alpha
      final glowStrokeWidth = strokeWidth + (i * 1); // Kleinere StrokeWidth-Erweiterung
      
      final paint = Paint()
        ..color = color.withValues(alpha: glowAlpha)
        ..strokeWidth = glowStrokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = i == 0 ? const MaskFilter.blur(BlurStyle.normal, 2) : null; // Leichter Blur nur beim ersten Layer

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: glowRadius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GlowSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
