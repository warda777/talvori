import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'category_popup_settings.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/home/ui/widgets/all_words_neural_bg.dart';
import 'package:talvori/features/home/ui/widgets/my_words_bg.dart';
import 'package:talvori/features/home/ui/widgets/favorites_heart_bg.dart';
import 'package:talvori/features/home/ui/widgets/words_i_know_puzzle_bg.dart';
import 'package:talvori/features/home/ui/widgets/word_hub_rising_glow_bg.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

typedef VoidSnack = void Function(String);

Future<void> showCategoryPopup({
  required BuildContext context,
  required Future<void> Function() onRefreshMyWords,
  required VoidSnack onTodo,
}) {
  final cs = Theme.of(context).colorScheme;
  const gold = Color(0xFFF1C86B);
  final bool initialAnimationsEnabled = CategoryPopupSettings.animationsEnabled;
  final bool initialGlowEnabled = CategoryPopupSettings.glowEnabled;
  bool animationsEnabled = initialAnimationsEnabled;
  bool glowEnabled = initialGlowEnabled;

  ButtonStyle pill(BuildContext ctx) => FilledButton.styleFrom(
    backgroundColor: cs.surfaceContainerHighest,
    foregroundColor: cs.onSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    padding: EdgeInsets.zero,
    fixedSize: const Size(129, 90),
    minimumSize: const Size(129, 90),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  Widget _buildTile({
    required BuildContext context,
    required FutureOr<void> Function() onTapAfter,
    required Widget background,
    required Widget overlay,
    double width = 129,
    double height = 90,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(18)),
    Color glowColor = gold,
    double glowBlur = 28,
    double glowSpread = 6,
    double borderWidth = 0,
    Color? borderColor,
    bool innerGlow = false,
    Color? innerGlowColor,
    bool animationsActive = true,
    bool glowActive = true,
    Duration holdDelay = const Duration(milliseconds: 120),
  }) {
    final Color effectiveInnerGlowColor = innerGlowColor ?? glowColor;
    final bool showGlow = glowActive;
    final Color fallbackBorderColor = const Color(0xFFF1C86B);
    final double fallbackBorderWidth = 1.8;
    final Color effectiveBorderColor = showGlow
        ? (borderColor ?? glowColor)
        : fallbackBorderColor;
    final double effectiveBorderWidth = borderWidth > 0
        ? borderWidth
        : (showGlow ? 0 : fallbackBorderWidth);
    return SizedBox(
      width: width,
      height: height,
      child: TapFlash(
        color: showGlow ? glowColor : Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        maxOpacity: 1.0,
        blur: showGlow ? glowBlur : 0,
        spread: showGlow ? glowSpread : 0,
        duration: const Duration(milliseconds: 220),
        holdForward: true,
        onTapAfter: () async {
          if (holdDelay > Duration.zero) {
            await Future.delayed(holdDelay);
          }
          await onTapAfter();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: borderRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: effectiveBorderWidth,
            ),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.55),
                      blurRadius: glowBlur,
                      spreadRadius: glowSpread,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TickerMode(enabled: animationsActive, child: background),
                if (innerGlow && showGlow)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.95,
                        colors: [
                          effectiveInnerGlowColor.withOpacity(0.45),
                          effectiveInnerGlowColor.withOpacity(0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                overlay,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowToggleButton({
    required bool animationsActive,
    required bool glowActive,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final bool bothActive = animationsActive && glowActive;
    final bool glowOnly = glowActive && !animationsActive;
    final bool animationOnly = animationsActive && !glowActive;
    final bool allOff = !animationsActive && !glowActive;

    final Color borderColor;
    final List<BoxShadow>? shadow;
    final Gradient innerGradient;
    final Color iconColor;

    if (bothActive) {
      borderColor = const Color(0xFFAFCCFE);
      shadow = [
        BoxShadow(
          color: const Color(0xFFAFCCFE).withOpacity(0.45),
          blurRadius: 28,
          spreadRadius: 3,
        ),
      ];
      innerGradient = const RadialGradient(
        center: Alignment.center,
        radius: 0.92,
        colors: [Color(0xFFE7F0FF), Color(0xFFAFCCFE), Color(0x000D1A2E)],
        stops: [0.0, 0.52, 1.0],
      );
      iconColor = const Color(0xFF142746);
    } else if (glowOnly) {
      borderColor = const Color(0xFFFFC66A);
      shadow = [
        BoxShadow(
          color: const Color(0xFFFFC66A).withOpacity(0.45),
          blurRadius: 26,
          spreadRadius: 2,
        ),
      ];
      innerGradient = const RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [Color(0xFFFFF5D6), Color(0xFFFFCB73), Color(0x00FFC66A)],
        stops: [0.0, 0.48, 1.0],
      );
      iconColor = const Color(0xFF4A320B);
    } else if (animationOnly) {
      borderColor = const Color(0xFFA05260);
      shadow = [
        BoxShadow(
          color: const Color(0xFFA05260).withOpacity(0.45),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];
      innerGradient = const RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [Color(0xFFFFDBD0), Color(0xFFA05260), Color(0x00A05260)],
        stops: [0.0, 0.52, 1.0],
      );
      iconColor = const Color(0xFF471821);
    } else {
      borderColor = const Color(0xFF3B2E1A);
      shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 18,
          spreadRadius: -4,
        ),
      ];
      innerGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B140A), Color(0xFF15110A)],
      );
      iconColor = const Color(0xFF8C7A5C);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 78,
        height: 36,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0A05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: shadow,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: innerGradient,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget content(
    BuildContext context, {
    required VoidCallback onBeginOpen,
  }) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: StatefulBuilder(
      builder: (context, setLocalState) {
        const tileTextColor = Color(0xFFFCD27D);

        void toggleMaster() {
          final bool next = !(animationsEnabled && glowEnabled);
          setLocalState(() {
            animationsEnabled = next;
            glowEnabled = next;
          });
          CategoryPopupSettings.animationsEnabled = animationsEnabled;
          CategoryPopupSettings.glowEnabled = glowEnabled;
        }

        void toggleGlowOnly() {
          setLocalState(() {
            glowEnabled = !glowEnabled;
          });
          CategoryPopupSettings.glowEnabled = glowEnabled;
        }

        final bool masterActive = animationsEnabled && glowEnabled;
        final BoxDecoration decoration = glowEnabled
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFFFFE4A8),
                    Color(0xFFF1C86B),
                    Color(0xFF8A5A1E),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                border: Border.all(color: gold.withOpacity(0.85), width: 1.6),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xAAF1C86B),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF060504),
                border: Border.all(color: const Color(0xFFF1C86B), width: 2),
              );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildGlowToggleButton(
                        animationsActive: animationsEnabled,
                        glowActive: glowEnabled,
                        onTap: toggleMaster,
                        onLongPress: toggleGlowOnly,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OpenContainer(
                      transitionDuration: const Duration(milliseconds: 350),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedElevation: 0,
                      openElevation: 0,
                      useRootNavigator: true,
                      closedColor: cs.surfaceContainerHighest,
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tappable: false,
                      closedBuilder: (c, open) => _buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        background: const NeuralGlowBackground(
                          density: 12,
                          nodeCount: 14,
                          speed: 0.20,
                          focus: Alignment.center,
                          spread: 0.24,
                          lineColor: Color(0xFFE6C27A),
                          bgColor: Color(0xFF000000),
                        ),
                        animationsActive: animationsEnabled,
                        glowActive: glowEnabled,
                        overlay: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'All words',
                              style: Theme.of(c).textTheme.titleLarge?.copyWith(
                                color: tileTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        glowBlur: 34,
                        glowSpread: 6,
                        innerGlow: true,
                        innerGlowColor: tileTextColor,
                      ),
                      openBuilder: (_, __) =>
                          const QuickSetsDetailScreen(initialIndex: 0),
                    ),
                    OpenContainer(
                      transitionDuration: const Duration(milliseconds: 350),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedElevation: 0,
                      openElevation: 0,
                      useRootNavigator: true,
                      closedColor: cs.surfaceContainerHighest,
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tappable: false,
                      onClosed: (_) => onRefreshMyWords(),
                      closedBuilder: (c, open) => _buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        background: const MyWordsBackground(),
                        animationsActive: animationsEnabled,
                        glowActive: glowEnabled,
                        overlay: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'My words',
                              style: Theme.of(c).textTheme.titleLarge?.copyWith(
                                color: tileTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        glowBlur: 34,
                        glowSpread: 6,
                      ),
                      openBuilder: (_, __) =>
                          const QuickSetsDetailScreen(initialIndex: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OpenContainer(
                      transitionDuration: const Duration(milliseconds: 350),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedElevation: 0,
                      openElevation: 0,
                      useRootNavigator: true,
                      closedColor: cs.surfaceContainerHighest,
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tappable: false,
                      closedBuilder: (c, open) => _buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        background: const FavoritesHeartBackground(),
                        animationsActive: animationsEnabled,
                        glowActive: glowEnabled,
                        overlay: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Favorites',
                              style: Theme.of(c).textTheme.titleLarge?.copyWith(
                                color: tileTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        glowBlur: 34,
                        glowSpread: 6,
                      ),
                      openBuilder: (_, __) =>
                          const QuickSetsDetailScreen(initialIndex: 2),
                    ),
                    OpenContainer(
                      transitionDuration: const Duration(milliseconds: 350),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedElevation: 0,
                      openElevation: 0,
                      useRootNavigator: true,
                      closedColor: cs.surfaceContainerHighest,
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tappable: false,
                      closedBuilder: (c, open) => _buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        background: const WordsIKnowPuzzleBackground(),
                        animationsActive: animationsEnabled,
                        glowActive: glowEnabled,
                        overlay: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Words I know',
                              style: Theme.of(c).textTheme.titleLarge?.copyWith(
                                color: tileTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        glowBlur: 34,
                        glowSpread: 6,
                      ),
                      openBuilder: (_, __) =>
                          const QuickSetsDetailScreen(initialIndex: 3),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: OpenContainer(
                    transitionDuration: const Duration(milliseconds: 350),
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedElevation: 0,
                    openElevation: 0,
                    useRootNavigator: true,
                    closedColor: cs.surfaceContainerHighest,
                    openColor: Theme.of(context).scaffoldBackgroundColor,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    tappable: false,
                    closedBuilder: (c, open) => _buildTile(
                      context: c,
                      onTapAfter: () async {
                        onBeginOpen();
                        open();
                      },
                      background: const WordHubRisingGlowBackground(),
                      animationsActive: animationsEnabled,
                      glowActive: glowEnabled,
                      overlay: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Word hub',
                            style: Theme.of(c).textTheme.titleLarge?.copyWith(
                              color: tileTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      width: 280,
                      height: 100,
                      borderRadius: BorderRadius.circular(22),
                      glowBlur: 34,
                      glowSpread: 8,
                    ),
                    openBuilder: (_, __) =>
                        const WordHubScreen(useLocalOfflineFlow: true),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    height: 40,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MixBuilderScreen(
                              navigationOrigin:
                                  MixNavigationOrigin.categoryPopup(),
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('Make your own mix'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      const double navBtn = 52;
      const double navPad = 12;
      const double leftPad = 16;
      const double gap = 10;
      const double offsetX = 8;
      const double offsetY = 32;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      final double baseBottom = bottomInset + navPad + navBtn + gap;

      final double posLeft = leftPad + offsetX;
      final double posBottom = baseBottom + offsetY;

      const double popupWidth = 330;
      const double popupHeight = 500;

      final screen = MediaQuery.of(ctx).size;
      final safeLeft = posLeft.clamp(0.0, screen.width - popupWidth);
      final safeBottom = posBottom.clamp(8.0, screen.height - popupHeight - 8);

      bool hidden = false; // lokale Dialog-Transparenz

      return StatefulBuilder(
        builder: (ctx, setLocalState) {
          final nav = Navigator.of(ctx, rootNavigator: true);
          final dialogRoute = ModalRoute.of(ctx);

          Widget popupContent = Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx),
                ),
              ),
              Positioned(
                left: safeLeft,
                bottom: safeBottom,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: hidden ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: hidden,
                    child: SizedBox(
                      width: popupWidth,
                      height: popupHeight,
                      child: content(
                        ctx,
                        onBeginOpen: () {
                          // wird beim Tap auf die Kachel gesetzt (vor open())
                          setLocalState(() => hidden = true);
                          Future.delayed(const Duration(milliseconds: 380), () {
                            if (!nav.mounted) return;
                            if (dialogRoute != null) {
                              if (dialogRoute.isCurrent) {
                                nav.pop();
                              } else {
                                nav.removeRoute(dialogRoute);
                              }
                            } else if (nav.canPop()) {
                              nav.pop();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          return popupContent;
        },
      );
    },
  );
}
