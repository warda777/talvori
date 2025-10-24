import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;

  const CounterBadge({
    super.key,
    required this.count,
    this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
