import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animation: Pfeil fliegt von einer Position zur anderen
class ArrowFlyAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback? onComplete;
  final Duration duration;
  final Widget child;

  const ArrowFlyAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.child,
    this.onComplete,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<ArrowFlyAnimation> createState() => _ArrowFlyAnimationState();
}

class _ArrowFlyAnimationState extends State<ArrowFlyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Position: Von Start zu Ende
    _positionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Fade: Am Anfang sichtbar, am Ende ausblenden
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 0.8, // 80% der Zeit sichtbar
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 0.2, // 20% der Zeit ausblenden
      ),
    ]).animate(_controller);

    // Scale: Am Ende kleiner werden (wie es hineinfliegt)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 0.7, // 70% der Zeit normal
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 0.3, // 30% der Zeit kleiner werden
      ),
    ]).animate(_controller);

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
    return AnimatedBuilder(
      animation: Listenable.merge([
        _positionAnimation,
        _fadeAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        // Berechne die aktuelle Position
        final currentX = widget.startPosition.dx +
            (widget.endPosition.dx - widget.startPosition.dx) *
                _positionAnimation.value;
        final currentY = widget.startPosition.dy +
            (widget.endPosition.dy - widget.startPosition.dy) *
                _positionAnimation.value;

        // Berechne den Winkel basierend auf der Flugrichtung
        final dx = widget.endPosition.dx - widget.startPosition.dx;
        final dy = widget.endPosition.dy - widget.startPosition.dy;
        final angle = math.atan2(dy, dx);

        return Positioned(
          left: currentX,
          top: currentY,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: angle,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

