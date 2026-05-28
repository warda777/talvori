import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';

class SrsModeToggleWithHint extends ConsumerStatefulWidget {
  const SrsModeToggleWithHint({
    super.key,
    this.toggleHeight = 44, // sichtbare Höhe des Toggles
    this.gap = 6, // Abstand unter dem Toggle
    this.onUserTap,
    this.showPulsatingArrow = false,
  });

  final double toggleHeight;
  final double gap;
  final VoidCallback? onUserTap;
  final bool showPulsatingArrow;

  @override
  ConsumerState<SrsModeToggleWithHint> createState() =>
      _SrsModeToggleWithHintState();
}

class _SrsModeToggleWithHintState extends ConsumerState<SrsModeToggleWithHint>
    with SingleTickerProviderStateMixin {
  final _scalePulseKey = GlobalKey<ScalePulseAnimationState>();
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onModeTap() {
    if (_isDisposed || !mounted) return;
    _scalePulseKey.currentState?.trigger();
    if (!_glowCtrl.isAnimating) _glowCtrl.forward(from: 0);
    widget.onUserTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(srsModeControllerProvider).mode;
    final hintText = (mode == SrsSystem.hybrid)
        ? 'Tap Hybrid to exit'
        : 'Long-press for Hybrid';

    // Fixe Box in Toggle-Höhe; Hint wird darunter GEMALT (ohne Layout-Shift)
    final hintHeight = 22.0; // ca. Höhe des Hint-Texts
    return SizedBox(
      height: widget.toggleHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ScalePulseAnimation(
            key: _scalePulseKey,
            peakScale: 1.06,
            duration: const Duration(milliseconds: 250),
            child: ModeSwitchGlow(
              glowAnimation: _glowAnim,
              child: SrsModeToggle(onUserTap: _onModeTap),
            ),
          ),
          Positioned(
            top: widget.toggleHeight + widget.gap,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          if (widget.showPulsatingArrow)
            Positioned(
              top: widget.toggleHeight + widget.gap + hintHeight + 4,
              left: 0,
              right: 0,
              child: const _PulsatingArrow(),
            ),
        ],
      ),
    );
  }
}

class _PulsatingArrow extends StatefulWidget {
  const _PulsatingArrow();

  @override
  State<_PulsatingArrow> createState() => _PulsatingArrowState();
}

class _PulsatingArrowState extends State<_PulsatingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 8 * (1 - _animation.value)),
          child: Opacity(
            opacity: 0.6 + 0.4 * _animation.value,
            child: Icon(
              Icons.arrow_upward,
              size: 28,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        );
      },
    );
  }
}
