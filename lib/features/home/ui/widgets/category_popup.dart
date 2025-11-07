import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';

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
        fixedSize: const Size(110, 48),
        minimumSize: const Size(110, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

  Widget content(BuildContext context, {required VoidCallback onBeginOpen}) => Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: gold, width: 1.6),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Category',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OpenContainer(
                    transitionDuration: const Duration(milliseconds: 350),
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedElevation: 0,
                    openElevation: 0,
                    useRootNavigator: true, // ⬅️ wichtig: öffnet oberhalb des Dialogs
                    closedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    openColor: Theme.of(context).scaffoldBackgroundColor,
                    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    tappable: false,
                    closedBuilder: (c, open) => FilledButton.tonal(
                      onPressed: () {
                        // 1) Popup optisch ausblenden, aber im Tree lassen
                        onBeginOpen();          // (dein lokales _hidden = true)

                        // 2) OpenContainer starten
                        open();
                      },
                      style: pill(context),
                      child: const Text('All words'),
                    ),
                    openBuilder: (_, __) => const QuickSetsDetailScreen(initialIndex: 0),
                  ),
              OpenContainer(
                transitionDuration: const Duration(milliseconds: 350),
                transitionType: ContainerTransitionType.fadeThrough,
                closedElevation: 0,
                openElevation: 0,
                useRootNavigator: true,
                closedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                openColor: Theme.of(context).scaffoldBackgroundColor,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tappable: false,
                onClosed: (_) => onRefreshMyWords(),
                closedBuilder: (c, open) => FilledButton.tonal(
                  onPressed: () {
                    onBeginOpen();
                    open();
                  },
                  style: pill(context),
                  child: const Text('My words'),
                ),
                openBuilder: (_, __) => const QuickSetsDetailScreen(initialIndex: 1),
              ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              OpenContainer(
                transitionDuration: const Duration(milliseconds: 350),
                transitionType: ContainerTransitionType.fadeThrough,
                closedElevation: 0,
                openElevation: 0,
                useRootNavigator: true,
                closedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                openColor: Theme.of(context).scaffoldBackgroundColor,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tappable: false,
                closedBuilder: (c, open) => FilledButton.tonal(
                  onPressed: () {
                    onBeginOpen();
                    open();
                  },
                  style: pill(context),
                  child: const Text('Favorites'),
                ),
                openBuilder: (_, __) => const QuickSetsDetailScreen(initialIndex: 2),
              ),
              OpenContainer(
                transitionDuration: const Duration(milliseconds: 350),
                transitionType: ContainerTransitionType.fadeThrough,
                closedElevation: 0,
                openElevation: 0,
                useRootNavigator: true,
                closedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                openColor: Theme.of(context).scaffoldBackgroundColor,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tappable: false,
                closedBuilder: (c, open) => FilledButton.tonal(
                  onPressed: () {
                    onBeginOpen();
                    open();
                  },
                  style: pill(context),
                  child: const Text('Words I know'),
                ),
                openBuilder: (_, __) => const QuickSetsDetailScreen(initialIndex: 3),
              ),
                ],
              ),

              const SizedBox(height: 20),

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
              closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              tappable: false,
              closedBuilder: (c, open) => InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  onBeginOpen();
                  open();
                },
                child: Container(
                  width: 232,
                  height: 103,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Word hub',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9)),
                  ),
                ),
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
                            navigationOrigin: MixNavigationOrigin.categoryPopup(),
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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

      final screen = MediaQuery.of(ctx).size;
      final safeLeft = posLeft.clamp(0.0, screen.width - 280);
      final safeBottom = posBottom.clamp(8.0, screen.height - 415 - 8);

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
                      width: 280,
                      height: 415,
                      child: content(ctx, onBeginOpen: () {
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
                      }),
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
