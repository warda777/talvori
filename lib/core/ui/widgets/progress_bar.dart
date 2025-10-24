import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final BorderRadius radius;
  final Gradient? gradient;
  final Color? background;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.radius = const BorderRadius.all(Radius.circular(3)),
    this.gradient,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? Colors.white10,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient ?? LinearGradient(
                  colors: [Colors.white30, Colors.white70],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
