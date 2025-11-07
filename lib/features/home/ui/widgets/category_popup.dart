import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
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
    Duration holdDelay = const Duration(milliseconds: 120),
  }) {
    final Color effectiveInnerGlowColor = innerGlowColor ?? glowColor;
    return SizedBox(
      width: width,
      height: height,
      child: TapFlash(
        color: glowColor,
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        maxOpacity: 1.0,
        blur: glowBlur,
        spread: glowSpread,
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
            border: borderWidth > 0
                ? Border.all(color: borderColor ?? glowColor, width: borderWidth)
                : null,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.55),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                background,
                if (innerGlow)
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

  Widget content(BuildContext context, {required VoidCallback onBeginOpen}) =>
      Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
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
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Builder(
              builder: (context) {
                const tileTextColor = Color(0xFFFCD27D);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Category',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800, color: Colors.black),
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
                            overlay: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'All words',
                                  style: Theme.of(c)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                            overlay: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'My words',
                                  style: Theme.of(c)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                            overlay: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'Favorites',
                                  style: Theme.of(c)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                            overlay: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'Words I know',
                                  style: Theme.of(c)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                          overlay: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Word hub',
                                style: Theme.of(c)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
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
                        openBuilder: (_, __) => const WordHubScreen(),
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
                );
              },
            ),
          ),
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
