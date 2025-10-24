import 'package:flutter/material.dart';

class TapFlash extends StatefulWidget {
  final Widget child;
  final Color color;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final VoidCallback? onTapAfter;

  const TapFlash({
    super.key,
    required this.child,
    required this.color,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.onTapAfter,
  });

  @override
  State<TapFlash> createState() => _TapFlashState();
}

class _TapFlashState extends State<TapFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTapAfter?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              shape: widget.shape,
            ),
            child: Stack(
              children: [
                widget.child,
                if (_animation.value > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _animation.value * 0.3),
                      borderRadius: widget.borderRadius,
                      shape: widget.shape,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
