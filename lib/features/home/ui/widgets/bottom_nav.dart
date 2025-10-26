import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

// Einheitliche Größe für die runden Bottom-Buttons (Category/Profile)
const double kTopBtnSize = 52; // oder 52 – nimm deinen Zielwert

class HomeBottomNav extends StatelessWidget {
  final VoidCallback onCategories;
  final VoidCallback onPractice;
  final VoidCallback onProfile;
  final bool categoriesActive;
  final bool practiceActive;


  const HomeBottomNav({
    super.key,
    required this.onCategories,
    required this.onPractice,
    required this.onProfile,
    this.categoriesActive = false,
    this.practiceActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = Color(0xFFF1C86B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ⬅︎ Category (links) – identische Größe + volle Ausdehnung
          SizedBox.square(
            dimension: kTopBtnSize,
            child: Stack(
              fit: StackFit.expand, // Kinder füllen die ganze Fläche
              children: [
                TapFlash(
                  color: gold,
                  shape: BoxShape.circle,
                  maxOpacity: 1.0,
                  blur: 22,
                  spread: 4,
                  duration: const Duration(milliseconds: 220),
                  onTapAfter: onCategories,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                if (categoriesActive)
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(
            width: 140,
            height: 52,
            child: TapFlash(
              color: gold,                                          // Flash-Farbe
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              onTapAfter: onPractice,                               // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,                     // Button-Farbe
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'practice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ───────── PROFILE (Kreis, 52×52) ─────────
          SizedBox.square(
            dimension: 52,
            child: TapFlash(
              color: cs.primary,                                    // Flash-Farbe
              shape: BoxShape.circle,
              onTapAfter: onProfile,                                // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,                     // Button-Farbe
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.person_rounded, color: cs.onSecondaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
