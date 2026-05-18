import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

typedef VoidSnack = void Function(String);

Future<void> showCategoryPopup({
  required BuildContext context,
  required Future<void> Function() onRefreshMyWords,
  required VoidSnack onTodo,
}) {
  final cs = Theme.of(context).colorScheme;
  const surface = Color(0xFF070B12);
  const surfaceAlt = Color(0xFF0C1220);
  const cyan = Color(0xFF5DDCFF);
  const violet = Color(0xFFB36BFF);
  const green = Color(0xFF36F58A);
  const pink = Color(0xFFFF4B9A);
  const textPrimary = Color(0xFFF4F8FF);
  const textSecondary = Color(0xFFB8C7D9);

  Widget buildTile({
    Key? key,
    required BuildContext context,
    required FutureOr<void> Function() onTapAfter,
    required String title,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTapBefore,
    String? subtitle,
    double width = 129,
    double height = 90,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(18)),
    Duration holdDelay = const Duration(milliseconds: 120),
  }) {
    return SizedBox(
      key: key,
      width: width,
      height: height,
      child: TapFlash(
        color: accentColor,
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
        maxOpacity: 1.0,
        blur: 18,
        spread: 1,
        duration: const Duration(milliseconds: 220),
        holdForward: true,
        onTapBefore: onTapBefore,
        onTapAfter: () async {
          if (holdDelay > Duration.zero) {
            await Future.delayed(holdDelay);
          }
          await onTapAfter();
        },
        child: Container(
          decoration: BoxDecoration(
            color: surfaceAlt,
            borderRadius: borderRadius,
            border: Border.all(color: accentColor.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 22,
                spreadRadius: -2,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.18),
                    const Color(0xFF07101A),
                    const Color(0xFF05070C),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -18,
                    top: -20,
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: accentColor, size: 22),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context, {required VoidCallback onBeginOpen}) =>
      Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: surface,
            border: Border.all(color: cyan.withValues(alpha: 0.42), width: 1.4),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E1522), Color(0xFF060B12), Color(0xFF030508)],
            ),
            boxShadow: [
              BoxShadow(
                color: cyan.withValues(alpha: 0.16),
                blurRadius: 34,
                spreadRadius: 1,
              ),
              BoxShadow(color: violet.withValues(alpha: 0.10), blurRadius: 42),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Kategorie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: 0.2,
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
                      closedBuilder: (c, open) => buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        title: 'Alle Wörter',
                        icon: Icons.auto_stories_rounded,
                        accentColor: cyan,
                      ),
                      openBuilder: (_, __) =>
                          const QuickSetsDetailScreen(initialIndex: 0),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final count = ref.watch(
                          localWordCountProvider(localMyWordsCategoryId),
                        );
                        final subtitle = count.maybeWhen(
                          data: (value) =>
                              value == 1 ? '1 Wort' : '$value Wörter',
                          orElse: () => null,
                        );
                        return buildTile(
                          key: const Key('category-popup-my-words-tile'),
                          context: context,
                          onTapBefore: () {
                            final navigator = Navigator.of(
                              context,
                              rootNavigator: true,
                            );
                            onBeginOpen();
                            unawaited(
                              navigator
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => const LocalWordListScreen(
                                        categoryId: localMyWordsCategoryId,
                                        title: localMyWordsCategoryLabel,
                                      ),
                                    ),
                                  )
                                  .then((_) => onRefreshMyWords()),
                            );
                          },
                          onTapAfter: () async {},
                          holdDelay: Duration.zero,
                          title: 'Meine Wörter',
                          subtitle: subtitle,
                          icon: Icons.edit_note_rounded,
                          accentColor: violet,
                          height: 106,
                        );
                      },
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
                      closedBuilder: (c, open) => buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        title: 'Favoriten',
                        icon: Icons.favorite_rounded,
                        accentColor: pink,
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
                      closedBuilder: (c, open) => buildTile(
                        context: c,
                        onTapAfter: () async {
                          onBeginOpen();
                          open();
                        },
                        title: 'Wörter, die ich kenne',
                        icon: Icons.verified_rounded,
                        accentColor: green,
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
                    closedBuilder: (c, open) => buildTile(
                      context: c,
                      onTapAfter: () async {
                        onBeginOpen();
                        open();
                      },
                      title: 'Wortwelten',
                      subtitle: 'Themen und Lernbereiche',
                      icon: Icons.public_rounded,
                      accentColor: cyan,
                      width: 280,
                      height: 100,
                      borderRadius: BorderRadius.circular(22),
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
                        backgroundColor: const Color(0xFF0E1A24),
                        foregroundColor: textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: violet.withValues(alpha: 0.74),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 0,
                      ),
                      child: const Text('Mix erstellen'),
                    ),
                  ),
                ),
              ],
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
