import 'package:flutter/material.dart';

class MiniBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? color;
  final EdgeInsets margin;

  const MiniBadge({
    super.key,
    this.icon,
    required this.label,
    this.color,
    this.margin = const EdgeInsets.only(right: 6),
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? t.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: t.textTheme.labelSmall),
        ],
      ),
    );
  }
}
