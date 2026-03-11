import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mikro-Animation: Scale 1.0 → peak → 1.0, EaseInOut (für Modus-Wechsel)
class ScalePulseAnimation extends StatefulWidget {
  final Widget child;
  final double peakScale;
  final Duration duration;
  final VoidCallback? onTriggered;

  const ScalePulseAnimation({
    super.key,
    required this.child,
    this.peakScale = 1.03,
    this.duration = const Duration(milliseconds: 220),
    this.onTriggered,
  });

  @override
  State<ScalePulseAnimation> createState() => ScalePulseAnimationState();
}

class ScalePulseAnimationState extends State<ScalePulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.peakScale), weight: 50),
      TweenSequenceItem(tween: Tween(begin: widget.peakScale, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void trigger() {
    if (_ctrl.isAnimating) return;
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}

/// Kurzer Glow-Impuls für Modus-Wechsel (einmalig, 300 ms)
class ModeSwitchGlow extends StatelessWidget {
  const ModeSwitchGlow({
    super.key,
    required this.glowAnimation,
    required this.child,
  });

  final Animation<double> glowAnimation;
  final Widget child;

  static const _gold = Color(0xFFE5B966);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) {
        final v = glowAnimation.value;
        if (v <= 0) return child!;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.45 * v),
                blurRadius: 20 * v,
                spreadRadius: 4 * v,
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Mikro-Animation: Tap-Scale (z.B. Schloss, Vocabs)
class TapScaleAnimation extends StatefulWidget {
  final Widget child;
  final double peakScale;
  final Duration duration;
  final VoidCallback? onTap;

  const TapScaleAnimation({
    super.key,
    required this.child,
    this.peakScale = 1.08,
    this.duration = const Duration(milliseconds: 200),
    this.onTap,
  });

  @override
  State<TapScaleAnimation> createState() => _TapScaleAnimationState();
}

class _TapScaleAnimationState extends State<TapScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.peakScale), weight: 50),
      TweenSequenceItem(tween: Tween(begin: widget.peakScale, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_ctrl.isAnimating) {
      HapticFeedback.lightImpact();
      _ctrl.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Start-Button Puls: 1.0 → 1.035 → 1.0, 2.5s, max 2x (sichtbarer)
class StartButtonPulse extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const StartButtonPulse({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  State<StartButtonPulse> createState() => _StartButtonPulseState();
}

class _StartButtonPulseState extends State<StartButtonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _pulseCount = 0;
  static const _maxPulses = 2;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.035), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.035, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _pulseCount++;
        if (_pulseCount < _maxPulses) {
          _ctrl.forward(from: 0);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pulseCount < _maxPulses) _ctrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPressed() {
    _ctrl.stop();
    _ctrl.reset();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: IgnorePointer(child: widget.child),
      ),
    );
  }
}

/// Final Round Button: Leichtes grünes Pochen (Glow-Pulse)
class FinalRoundButtonPulse extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const FinalRoundButtonPulse({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  State<FinalRoundButtonPulse> createState() => _FinalRoundButtonPulseState();
}

class _FinalRoundButtonPulseState extends State<FinalRoundButtonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  static const _green = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPressed() {
    _ctrl.stop();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onPressed,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final v = _glow.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _green.withOpacity(0.7 * v),
                  blurRadius: 20 * v,
                  spreadRadius: 5 * v,
                ),
                BoxShadow(
                  color: _green.withOpacity(0.5 * v),
                  blurRadius: 36 * v,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: IgnorePointer(child: widget.child),
      ),
    );
  }
}

/// Vocabs-Kachel: Scale 1.0→1.05→1.0 + Elevation (200 ms)
class VocabsTileTapAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const VocabsTileTapAnimation({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<VocabsTileTapAnimation> createState() => _VocabsTileTapAnimationState();
}

class _VocabsTileTapAnimationState extends State<VocabsTileTapAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_ctrl.isAnimating) _ctrl.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final v = _anim.value;
          final scale = 1.0 + 0.05 * v;
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: v > 0.01
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25 * v),
                          blurRadius: 12 * v,
                          offset: Offset(0, 4 * v),
                        ),
                      ],
                    )
                  : null,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
