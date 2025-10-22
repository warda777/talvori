// lib/features/home/ui/widgets/counter_badge.dart
import 'package:flutter/material.dart';

class CounterBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final double horizontalPadding;
  final double verticalPadding;

  /// Optional: Text-/Icon-Farbe (z. B. für hell/dunkel über Bild)
  final Color? color;

  const CounterBadge({
    super.key,
    required this.count,
    this.onTap,
    this.horizontalPadding = 18,
    this.verticalPadding = 10,
    this.color, // <- wichtig: im Konstruktor führen
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.onSurface;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (color ?? cs.primary).withValues(alpha: 0.7), // Rand passt sich an
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.2,
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: badge,
      ),
    );
  }
}
