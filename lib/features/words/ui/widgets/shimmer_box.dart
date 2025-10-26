import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double height;
  final double borderRadius;
  const ShimmerBox({super.key, this.height = 16, this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final hi = Theme.of(context).colorScheme.surface;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = (math.sin((_c.value * 2 * math.pi)) + 1) / 2; // 0..1
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, Color.lerp(base, hi, 0.5)!, base],
              stops: [0, t.clamp(0.2, 0.8), 1],
            ),
          ),
        );
      },
    );
  }
}
