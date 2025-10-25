import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';
import 'package:talvori/features/words/ui/widgets/glow_circle_button.dart';
import 'package:talvori/features/words/ui/widgets/glow_rect_tile.dart';

class CategoryHeaderCapsule extends StatelessWidget {
  final double height;

  final String title;
  final int vocabsCount;

  final List<String> categories;
  final int selectedIndex;
  final void Function(int index, String label) onWheelChanged;

  final VoidCallback onBack;
  final VoidCallback onVocabs;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  // Offsets/Knobs – Defaults wie bisher, aber überschreibbar
  final double wheelOffsetX;
  final double wheelOffsetY;
  final double rowOffsetX;
  final double rowOffsetY;
  final double vocabsTileOffsetX;
  final double vocabsTileOffsetY;
  final double rightBtnsOffsetX;
  final double rightBtnsOffsetY;

  final Color accentColor;

  const CategoryHeaderCapsule({
    super.key,
    required this.height,
    required this.title,
    required this.vocabsCount,
    required this.categories,
    required this.selectedIndex,
    required this.onWheelChanged,
    required this.onBack,
    required this.onVocabs,
    required this.onAdd,
    required this.onSettings,
    this.wheelOffsetX = 0.0,
    this.wheelOffsetY = 0.0,
    this.rowOffsetX = 0.0,
    this.rowOffsetY = 50.0,
    this.vocabsTileOffsetX = 20.0,
    this.vocabsTileOffsetY = 0.0,
    this.rightBtnsOffsetX = -10.0,
    this.rightBtnsOffsetY = 0.0,
    this.accentColor = const Color(0xFFB1CCFE),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + Wheel
            SizedBox(
              height: 72.0, // kWheelHeight
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onBack,
                    child: const SizedBox(
                      width: 44, height: 44,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(wheelOffsetX, wheelOffsetY),
                      child: Center(
                        child: CategoryWheel(
                          categories: categories,
                          initialIndex: selectedIndex,
                          onChanged: onWheelChanged,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Vocabs-Kachel + Buttons
            Transform.translate(
              offset: Offset(rowOffsetX, rowOffsetY),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(vocabsTileOffsetX, vocabsTileOffsetY),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: onVocabs,
                          child: GlowRectTile(
                            width: 84,
                            height: 85,
                            radius: 15,
                            title: 'Vocabs',
                            icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                            outlineColor: accentColor,
                            glowColor: accentColor,
                            badgeText: '$vocabsCount',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Transform.translate(
                    offset: Offset(rightBtnsOffsetX, rightBtnsOffsetY),
                    child: Row(
                      children: [
                        GlowCircleButton(
                          size: 62,
                          onTap: onAdd,
                          child: const Icon(Icons.add, color: Colors.white, size: 28),
                          outlineColor: accentColor,
                          glowColor: accentColor,
                        ),
                        const SizedBox(width: 10),
                        GlowCircleButton(
                          size: 62,
                          onTap: onSettings,
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                          outlineColor: accentColor,
                          glowColor: accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
