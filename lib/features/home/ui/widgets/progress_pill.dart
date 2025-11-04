import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/application.dart';

class ProgressPill extends ConsumerWidget {
  final int selected;          // z.B. 1
  final int max;               // z.B. 5 (später 1–20)
  final double barWidth;       // Breite des Balkens
  final VoidCallback? onTap;   // öffnet später dein Einstellungs-Sheet
  final Widget? leading;       // optional eigenes Icon/SVG
  final GlobalKey? counterKey; // <-- NEU: Key für den Counter-Text

  const ProgressPill({
    super.key,
    required this.selected,
    required this.max,
    this.barWidth = 140,
    this.onTap,
    this.leading,
    this.counterKey, // <-- NEU
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final glowEnabled = ref.watch(homeControllerProvider.select((s) => s.glowEnabled));
    const wheelBlue = Color(0xFFB0CCFE); // Blau aus Word Wheel
    const buttonColor = Color(0xFF2D2D2E); // Button-Hintergrundfarbe
    const gold = Color(0xFFF1C86B); // Gold für Progress Pill
    final value = (selected / max).clamp(0.0, 1.0);

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 2), // Goldener Rand
        boxShadow: glowEnabled ? [
          // Durchgehender goldener Glow
          BoxShadow(
            color: gold.withValues(alpha: 0.55),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? const Icon(Icons.system_update_alt_rounded,
              size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            key: counterKey, // <-- NEU: Key für den Counter
            '$selected/$max',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor:
                    AlwaysStoppedAnimation<Color>(wheelBlue), // Blau statt SecondaryContainer
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
