import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';
import 'package:talvori/features/words/ui/widgets/glow_circle_button.dart';
import 'package:talvori/features/words/ui/widgets/glow_rect_tile.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

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
  final double wheelBottomGap; // NEU

  final Color accentColor;
  final Color? backgroundColor;
  final bool neonStyle;

  // Optional: zusätzliches Widget rechts unter den Add/Settings-Buttons (z. B. Toggle)
  final Widget? trailingRightBelow;

  /// Keys für Tooltip-Positionierung (optional)
  final GlobalKey? vocabsKey;
  final GlobalKey? wheelKey;

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
    this.wheelOffsetX = WordsLayout.wheelOffsetX,
    this.wheelOffsetY = WordsLayout.wheelOffsetY,
    this.rowOffsetX = WordsLayout.rowOffsetX,
    this.rowOffsetY = WordsLayout.rowOffsetY,
    this.vocabsTileOffsetX = WordsLayout.vocabsTileOffsetX,
    this.vocabsTileOffsetY = WordsLayout.vocabsTileOffsetY,
    this.rightBtnsOffsetX = WordsLayout.rightBtnsOffsetX,
    this.rightBtnsOffsetY = WordsLayout.rightBtnsOffsetY,
    this.wheelBottomGap = WordsLayout.wheelBottomGap,
    this.accentColor = const Color(0xFFB1CCFE),
    this.backgroundColor,
    this.neonStyle = false,
    this.trailingRightBelow,
    this.vocabsKey,
    this.wheelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: WordsLayout.topPadding,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back + Wheel - mit fester Höhe wie im Learn-Mode
              SizedBox(
                height: WordsLayout.wheelHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: onBack,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: KeyedSubtree(
                          key: wheelKey,
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
              SizedBox(
                height: wheelBottomGap,
              ), // ← statt const SizedBox(height: 10),
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
                          key: vocabsKey,
                          color: Colors.transparent,
                          child: VocabsTileTapAnimation(
                            onTap: onVocabs,
                            child: GlowRectTile(
                              width: 84,
                              height: 85,
                              radius: neonStyle ? 24 : 15,
                              title: 'Vocabs',
                              icon: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              outlineColor: accentColor,
                              glowColor: accentColor,
                              badgeText: '$vocabsCount',
                              neonStyle: neonStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: Offset(rightBtnsOffsetX, rightBtnsOffsetY),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GlowCircleButton(
                                  size: 62,
                                  onTap: onAdd,
                                  outlineColor: accentColor,
                                  glowColor: accentColor,
                                  neonStyle: neonStyle,
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GlowCircleButton(
                                  size: 62,
                                  onTap: onSettings,
                                  outlineColor: accentColor,
                                  glowColor: accentColor,
                                  neonStyle: neonStyle,
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (trailingRightBelow != null) ...[
                            const SizedBox(height: 25), // weiter nach unten
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 70,
                                ), // mehr nach innen
                                child: trailingRightBelow!,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
