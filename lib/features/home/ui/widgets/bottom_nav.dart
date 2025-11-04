import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'package:talvori/features/home/application/application.dart';

// Einheitliche Größe für die runden Bottom-Buttons (Category/Profile)
const double kTopBtnSize = 52; // oder 52 – nimm deinen Zielwert

class HomeBottomNav extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final glowEnabled = ref.watch(homeControllerProvider.select((s) => s.glowEnabled));
    const gold = Color(0xFFF1C86B);
    const wheelBlue = Color(0xFFB0CCFE); // Blau aus Word Wheel
    const buttonColor = Color(0xFF2D2D2E); // Button-Hintergrundfarbe

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
                  color: wheelBlue, // Blauer Glow für Category-Button
                  shape: BoxShape.circle,
                  maxOpacity: 1.0,
                  blur: 28,
                  spread: 6,
                  duration: const Duration(milliseconds: 220),
                  onTapAfter: onCategories,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: wheelBlue, width: 2), // Blauer Rand
                      boxShadow: glowEnabled ? [
                        // Durchgehender blauer Glow
                        BoxShadow(
                          color: wheelBlue.withValues(alpha: 0.55),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (categoriesActive)
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: wheelBlue, width: 2), // Blauer Rand
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
              color: wheelBlue,                                          // Blau für Practice-Button
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              maxOpacity: 1.0,
              blur: 28,
              spread: 6,
              duration: const Duration(milliseconds: 220),
              onTapAfter: onPractice,                               // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: buttonColor,                     // Button-Farbe
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  border: Border.all(color: wheelBlue, width: 2), // Blauer Rand
                  boxShadow: glowEnabled ? [
                    // Durchgehender blauer Glow
                    BoxShadow(
                      color: wheelBlue.withValues(alpha: 0.55),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, size: 22, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'practice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
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
              color: wheelBlue,                                    // Blau für Profile-Button
              shape: BoxShape.circle,
              maxOpacity: 1.0,
              blur: 28,
              spread: 6,
              duration: const Duration(milliseconds: 220),
              onTapAfter: onProfile,                                // nach dem Flash ausführen
              child: Container(
                decoration: BoxDecoration(
                  color: buttonColor,                     // Button-Farbe
                  shape: BoxShape.circle,
                  border: Border.all(color: wheelBlue, width: 2), // Blauer Rand
                  boxShadow: glowEnabled ? [
                    // Durchgehender blauer Glow
                    BoxShadow(
                      color: wheelBlue.withValues(alpha: 0.55),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ] : null,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
