import 'package:flutter/material.dart';

class ProgressPill extends StatelessWidget {
  final int selected;          // z.B. 1
  final int max;               // z.B. 5 (später 1–20)
  final double barWidth;       // Breite des Balkens
  final VoidCallback? onTap;   // öffnet später dein Einstellungs-Sheet
  final Widget? leading;       // optional eigenes Icon/SVG

  const ProgressPill({
    super.key,
    required this.selected,
    required this.max,
    this.barWidth = 140,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = (selected / max).clamp(0.0, 1.0);

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(Icons.system_update_alt_rounded,
              size: 16, color: cs.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            '$selected/$max',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: barWidth,
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: cs.onSecondaryContainer.withValues(alpha: 0.25),
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
    );

    return onTap == null
        ? pill
        : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: pill);
  }
}
