import 'package:flutter/material.dart';

/// Animiertes Handy-Icon mit beweglichem Pfeil
/// Der Pfeil wird nur beim Tap animiert und fliegt dann zur Progress Pill
class AnimatedPhoneIcon extends StatefulWidget {
  final String assetPath;
  final double size;
  final Color? colorFilter;
  final Duration duration;
  final VoidCallback?
  onTap; // Callback für Tap (wird die Flug-Animation starten)

  const AnimatedPhoneIcon({
    super.key,
    required this.assetPath,
    this.size = 40,
    this.colorFilter,
    this.duration = const Duration(milliseconds: 1500),
    this.onTap,
  });

  @override
  State<AnimatedPhoneIcon> createState() => _AnimatedPhoneIconState();
}

class _AnimatedPhoneIconState extends State<AnimatedPhoneIcon>
    with SingleTickerProviderStateMixin {
  bool _arrowVisible = true; // Startet sichtbar
  late AnimationController _movementController;
  late Animation<double> _movementAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Bewegungs-Animation für das Icon
    _movementController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Leichte Bewegung (Bounce-Effekt)
    _movementAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -4.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4.0,
          end: 2.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.3,
      ),
    ]).animate(_movementController);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _movementController.dispose();
    super.dispose();
  }

  /// Versteckt den Pfeil (wird beim Start der Flug-Animation aufgerufen)
  void hideArrow() {
    if (!_isDisposed && mounted) {
      setState(() {
        _arrowVisible = false;
      });
    }
  }

  /// Zeigt den Pfeil wieder an (wird nach der Flug-Animation aufgerufen)
  void showArrow() {
    if (!_isDisposed && mounted) {
      setState(() {
        _arrowVisible = true;
      });
    }
  }

  /// Triggert eine leichte Bewegung des Icons (wird aufgerufen, wenn sich das Wort im Wheel ändert)
  void triggerMovement() {
    if (!_isDisposed && mounted && !_movementController.isAnimating) {
      _movementController.reset();
      _movementController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Handy-Icon (Material Icon - komplett ohne Pfeil)
          // Explizit zentriert, damit es auf derselben Höhe wie Chrome-Icon ist
          // Mit Bewegungs-Animation
          AnimatedBuilder(
            animation: _movementAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_movementAnimation.value, 0),
                child: Center(
                  child: Icon(
                    Icons.smartphone,
                    size:
                        widget.size *
                        0.77, // ~40px bei size=52, damit es der ursprünglichen Größe entspricht
                    color: widget.colorFilter ?? Colors.white,
                  ),
                ),
              );
            },
          ),

          // Pfeil (nur wenn sichtbar)
          if (_arrowVisible)
            Positioned(
              top: widget.size * 0.1,
              right: widget.size * 0.1,
              child: Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_downward,
                  size: widget.size * 0.25,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
