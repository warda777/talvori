import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_word_package_definition.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

typedef VoidSnack = void Function(String);

void _openLocalSource(
  BuildContext context,
  String sourceKey, {
  Future<void> Function()? onReturn,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    navigator
        .push(
          MaterialPageRoute(
            settings: RouteSettings(name: 'local-source-detail-$sourceKey'),
            builder: (_) =>
                LocalLearningSourceDetailScreen(initialSourceKey: sourceKey),
          ),
        )
        .then((_) => onReturn?.call()),
  );
}

Future<void> showCategoryPopup({
  required BuildContext context,
  required Future<void> Function() onRefreshMyWords,
  required VoidSnack onTodo,
}) {
  const surface = Color(0xFF070B12);
  const surfaceAlt = Color(0xFF0C1220);
  const cyan = Color(0xFF5DDCFF);
  const violet = Color(0xFFB36BFF);
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
    String? countLabel,
    double width = double.infinity,
    double height = 132,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.42),
                                ),
                              ),
                              child: Icon(icon, color: accentColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: textPrimary,
                                          fontWeight: FontWeight.w900,
                                          height: 1.08,
                                        ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: textSecondary,
                                            fontWeight: FontWeight.w600,
                                            height: 1.18,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (countLabel != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.42),
                                ),
                              ),
                              child: Text(
                                countLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                          ),
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

  void openSyntheticLocalCategory({
    required BuildContext context,
    required String title,
    required String categoryId,
  }) {
    final navigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!navigator.mounted) return;
        navigator.push(
          MaterialPageRoute(
            settings: RouteSettings(name: 'local-category-$categoryId'),
            builder: (_) => CategoryDetailScreen(
              title: title,
              categoryId: categoryId,
              listFilter: WordListFilter(WordFilterKind.about, title),
              useLocalOfflineFlow: true,
              localCategoryId: categoryId,
            ),
          ),
        );
      }),
    );
  }

  String formatCount(AsyncValue<int> count) {
    return count.maybeWhen(
      data: (value) => value == 1 ? '1 Wort' : '$value Wörter',
      loading: () => 'Lädt...',
      orElse: () => 'Noch nicht verfügbar',
    );
  }

  Widget countedTile({
    Key? key,
    required BuildContext context,
    required String countId,
    required FutureOr<void> Function() onTapAfter,
    VoidCallback? onTapBefore,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final count = ref.watch(localWordCountProvider(countId));
        return buildTile(
          key: key,
          context: context,
          onTapBefore: onTapBefore,
          onTapAfter: onTapAfter,
          holdDelay: Duration.zero,
          title: title,
          subtitle: subtitle,
          countLabel: formatCount(count),
          icon: icon,
          accentColor: accentColor,
        );
      },
    );
  }

  String levelSubtitle(String level) {
    return switch (level) {
      'A1' => 'Einstieg und einfache Alltagssprache',
      'A2' => 'Alltag sicher erweitern',
      'B1' => 'Meinungen und Alltagssituationen',
      'B2' => 'Diskussion und komplexere Themen',
      'C1' => 'Präzise und gehobene Sprache',
      'C2' => 'Nuancen und sehr präziser Ausdruck',
      _ => 'Kleine Lernpakete',
    };
  }

  Widget content(
    BuildContext context, {
    required String view,
    LocalLevelPackageGroup? selectedLevel,
    required ValueChanged<String> onViewChanged,
    required ValueChanged<LocalLevelPackageGroup> onLevelSelected,
  }) {
    final canGoBack = view != 'main';
    final title = switch (view) {
      'levels' => 'Lernlevel',
      'levelPackages' => selectedLevel?.level ?? 'Lernlevel',
      'languageTools' => 'Sprachwerkzeuge',
      _ => 'Kategorie',
    };
    final subtitle = switch (view) {
      'levels' => 'Wähle zuerst ein Level, dann ein kleines Paket.',
      'levelPackages' => 'Wähle ein kleines Paket statt ein ganzes Level.',
      'languageTools' => 'Übe besondere Wortgruppen und Sprachmuster.',
      _ => null,
    };

    Widget header() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              key: Key(
                canGoBack
                    ? 'category-popup-back-button'
                    : 'category-popup-close-button',
              ),
              onPressed: () {
                if (!canGoBack) {
                  Navigator.pop(context);
                  return;
                }
                if (view == 'levelPackages') {
                  onViewChanged('levels');
                } else {
                  onViewChanged('main');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    Widget mainTiles() {
      return Column(
        children: [
          buildTile(
            key: const Key('category-popup-word-worlds-tile'),
            context: context,
            onTapBefore: () {
              final navigator = Navigator.of(context, rootNavigator: true);
              unawaited(
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const WordHubScreen(useLocalOfflineFlow: true),
                  ),
                ),
              );
            },
            onTapAfter: () async {},
            holdDelay: Duration.zero,
            title: 'Wortwelten',
            subtitle: 'Themen wie Reisen und Alltag',
            countLabel: 'Themen öffnen',
            icon: Icons.public_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'word_worlds',
            ),
          ),
          const SizedBox(height: 12),
          buildTile(
            key: const Key('category-popup-level-packages-tile'),
            context: context,
            onTapAfter: () => onViewChanged('levels'),
            holdDelay: Duration.zero,
            title: 'Lernlevel',
            subtitle: 'Kleine Pakete von A1 bis C2',
            countLabel: 'Pakete öffnen',
            icon: Icons.school_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'learning_levels',
            ),
          ),
          const SizedBox(height: 12),
          countedTile(
            key: const Key('category-popup-my-words-tile'),
            context: context,
            countId: localMyWordsCategoryId,
            onTapBefore: () => _openLocalSource(
              context,
              'my_words',
              onReturn: onRefreshMyWords,
            ),
            onTapAfter: () async {},
            title: 'Meine Wörter',
            subtitle: 'Importierte und selbst gespeicherte Wörter',
            icon: Icons.edit_note_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'my_words',
            ),
          ),
          const SizedBox(height: 12),
          countedTile(
            key: const Key('category-popup-favorites-tile'),
            context: context,
            countId: 'local-source-favorites',
            onTapBefore: () => _openLocalSource(context, 'favorites'),
            onTapAfter: () async {},
            title: 'Favoriten',
            subtitle: 'Wörter, die du markiert hast',
            icon: Icons.favorite_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'favorites',
            ),
          ),
          const SizedBox(height: 12),
          countedTile(
            key: const Key('category-popup-known-words-tile'),
            context: context,
            countId: 'local-source-known-words',
            onTapBefore: () => _openLocalSource(context, 'known_words'),
            onTapAfter: () async {},
            title: 'Wörter, die ich kenne',
            subtitle: 'Gemeisterte Wörter aus deinem Fortschritt',
            icon: Icons.verified_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'known_words',
            ),
          ),
          const SizedBox(height: 12),
          countedTile(
            key: const Key('category-popup-my-mix-tile'),
            context: context,
            countId: 'local-source-my-mix',
            onTapBefore: () => _openLocalSource(context, 'my_mix'),
            onTapAfter: () async {},
            title: 'Mein Mix',
            subtitle: 'Favoriten, frische Wörter und Wiederholung',
            icon: Icons.auto_awesome_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource('my_mix'),
          ),
          const SizedBox(height: 12),
          buildTile(
            key: const Key('category-popup-language-tools-tile'),
            context: context,
            onTapAfter: () => onViewChanged('languageTools'),
            holdDelay: Duration.zero,
            title: 'Sprachwerkzeuge',
            subtitle: 'Phrasen, Grammatik und Verben',
            countLabel: 'Sammlungen öffnen',
            icon: Icons.construction_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'language_tools',
            ),
          ),
          const SizedBox(height: 12),
          countedTile(
            key: const Key('category-popup-all-words-tile'),
            context: context,
            countId: 'local-source-all-words',
            onTapBefore: () => _openLocalSource(context, 'all_words'),
            onTapAfter: () async {},
            title: 'Alle Wörter',
            subtitle: 'Dein gesamter lokaler Wortschatz',
            icon: Icons.auto_stories_rounded,
            accentColor: CategoryStrokeColors.colorForMainWordSource(
              'all_words',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
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
        ],
      );
    }

    Widget levelTiles() {
      return Column(
        children: [
          for (final group in localLevelPackageGroups) ...[
            Builder(
              builder: (context) {
                final levelColor = CategoryStrokeColors.colorForLevel(
                  group.level,
                );
                return buildTile(
                  key: Key('category-popup-level-${group.level.toLowerCase()}'),
                  context: context,
                  onTapAfter: () {
                    onLevelSelected(group);
                    onViewChanged('levelPackages');
                  },
                  holdDelay: Duration.zero,
                  title: group.level,
                  subtitle: levelSubtitle(group.level),
                  countLabel: '${group.packages.length} Pakete',
                  icon: Icons.layers_rounded,
                  accentColor: levelColor,
                  height: 108,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    Widget packageTiles(LocalLevelPackageGroup group) {
      return Column(
        children: [
          for (final package in group.packages) ...[
            countedTile(
              key: Key('category-popup-package-${package.key}'),
              context: context,
              countId: '$localLevelPackageCategoryPrefix${package.key}',
              onTapAfter: () async {
                openSyntheticLocalCategory(
                  context: context,
                  title: package.label,
                  categoryId: '$localLevelPackageCategoryPrefix${package.key}',
                );
              },
              title: package.label,
              subtitle: 'Kleines Paket für ${package.level}',
              icon: Icons.school_rounded,
              accentColor: CategoryStrokeColors.colorForLevelPackage(
                package.key,
              )!,
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    Widget languageToolTiles() {
      const subtitles = {
        'top_500': 'Häufige Wörter als kompakte Sammlung',
        'phrases_idioms': 'Phrasen und feste Ausdrücke',
        'irregular_verbs': 'Wichtige unregelmäßige Verben',
        'grammar_syntax': 'Muster für Grammatik und Satzbau',
      };
      return Column(
        children: [
          for (final tool in localLanguageToolDefinitions) ...[
            countedTile(
              key: Key('category-popup-language-tool-${tool.key}'),
              context: context,
              countId: '$localLanguageToolCategoryPrefix${tool.key}',
              onTapAfter: () async {
                openSyntheticLocalCategory(
                  context: context,
                  title: tool.label,
                  categoryId: '$localLanguageToolCategoryPrefix${tool.key}',
                );
              },
              title: tool.label,
              subtitle: subtitles[tool.key] ?? 'Besondere Wortgruppe',
              icon: Icons.construction_rounded,
              accentColor: CategoryStrokeColors.colorForMainWordSource(
                'language_tools',
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    final body = switch (view) {
      'levels' => levelTiles(),
      'levelPackages' when selectedLevel != null => packageTiles(selectedLevel),
      'languageTools' => languageToolTiles(),
      _ => mainTiles(),
    };

    return Material(
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [header(), const SizedBox(height: 18), body],
          ),
        ),
      ),
    );
  }

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (ctx) {
      const double navBtn = 52;
      const double navPad = 12;
      const double gap = 10;
      const double offsetY = 32;
      const double horizontalMargin = 10;

      final bottomInset = MediaQuery.of(ctx).padding.bottom;
      final double baseBottom = bottomInset + navPad + navBtn + gap;

      final double posBottom = baseBottom + offsetY;

      final screen = MediaQuery.of(ctx).size;
      final double popupWidth = (screen.width - horizontalMargin * 2).clamp(
        280.0,
        screen.width,
      );
      final double popupHeight = (screen.height - 16).clamp(500.0, 620.0);
      final safeLeft = ((screen.width - popupWidth) / 2).clamp(
        0.0,
        screen.width - popupWidth,
      );
      final safeBottom = posBottom.clamp(8.0, screen.height - popupHeight - 8);

      var view = 'main';
      LocalLevelPackageGroup? selectedLevel;

      return StatefulBuilder(
        builder: (ctx, setLocalState) {
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
                child: SizedBox(
                  key: const Key('category-popup-frame'),
                  width: popupWidth,
                  height: popupHeight,
                  child: SingleChildScrollView(
                    key: Key('category-popup-scroll-view-$view'),
                    child: content(
                      ctx,
                      view: view,
                      selectedLevel: selectedLevel,
                      onViewChanged: (nextView) {
                        setLocalState(() {
                          view = nextView;
                        });
                      },
                      onLevelSelected: (level) {
                        setLocalState(() {
                          selectedLevel = level;
                        });
                      },
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
