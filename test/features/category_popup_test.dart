import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word_package_definition.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';
import 'package:talvori/features/home/ui/widgets/category_popup.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';

void main() {
  testWidgets(
    'category popup uses german dark-neon labels without power button',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
            localFavoritesRepositoryProvider.overrideWith(
              (ref) => _MemoryLocalFavoritesRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      showCategoryPopup(
                        context: context,
                        onRefreshMyWords: () async {},
                        onTodo: (_) {},
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Kategorie'), findsOneWidget);
      expect(find.text('Alle Wörter'), findsOneWidget);
      expect(find.text('Meine Wörter'), findsOneWidget);
      expect(find.text('Favoriten'), findsOneWidget);
      expect(find.text('Wörter, die ich kenne'), findsOneWidget);
      expect(find.text('Mein Mix'), findsOneWidget);
      expect(find.text('Wortwelten'), findsOneWidget);
      expect(find.text('Themen wie Reisen und Alltag'), findsOneWidget);
      expect(find.text('Lernlevel'), findsOneWidget);
      expect(find.text('Kleine Pakete von A1 bis C2'), findsOneWidget);
      expect(find.text('Sprachwerkzeuge'), findsOneWidget);
      expect(find.text('Phrasen, Grammatik und Verben'), findsOneWidget);
      expect(find.text('Mix erstellen'), findsOneWidget);
      expect(find.byType(Scrollable), findsAtLeastNWidgets(1));
      expect(find.text('0 Wörter'), findsAtLeastNWidgets(5));

      expect(find.text('Category'), findsNothing);
      expect(find.text('All words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
      expect(find.text('Word hub'), findsNothing);
      expect(find.text('Make your own mix'), findsNothing);
      expect(find.text('Eigenen Mix erstellen'), findsNothing);
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
    },
  );

  testWidgets('category popup orders source tiles for learning-first flow', (
    tester,
  ) async {
    await _pumpCategoryPopup(tester);

    final expectedKeys = {
      const Key('category-popup-word-worlds-tile'),
      const Key('category-popup-level-packages-tile'),
      const Key('category-popup-my-words-tile'),
      const Key('category-popup-favorites-tile'),
      const Key('category-popup-known-words-tile'),
      const Key('category-popup-my-mix-tile'),
      const Key('category-popup-language-tools-tile'),
      const Key('category-popup-all-words-tile'),
    };
    final orderedKeys = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .map((widget) => widget.key)
        .whereType<Key>()
        .where(expectedKeys.contains)
        .toList();

    expect(orderedKeys, const [
      Key('category-popup-word-worlds-tile'),
      Key('category-popup-level-packages-tile'),
      Key('category-popup-my-words-tile'),
      Key('category-popup-favorites-tile'),
      Key('category-popup-known-words-tile'),
      Key('category-popup-my-mix-tile'),
      Key('category-popup-language-tools-tile'),
      Key('category-popup-all-words-tile'),
    ]);

    final mainTileColors = tester
        .widgetList<TapFlash>(find.byType(TapFlash))
        .take(8)
        .map((tapFlash) => tapFlash.color)
        .toList();
    expect(mainTileColors, [
      CategoryStrokeColors.colorForMainWordSource('word_worlds'),
      CategoryStrokeColors.colorForMainWordSource('learning_levels'),
      CategoryStrokeColors.colorForMainWordSource('my_words'),
      CategoryStrokeColors.colorForMainWordSource('favorites'),
      CategoryStrokeColors.colorForMainWordSource('known_words'),
      CategoryStrokeColors.colorForMainWordSource('my_mix'),
      CategoryStrokeColors.colorForMainWordSource('language_tools'),
      CategoryStrokeColors.colorForMainWordSource('all_words'),
    ]);
    expect(mainTileColors.toSet(), hasLength(mainTileColors.length));
  });

  testWidgets('category popup uses wide frame and main close arrow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpCategoryPopup(tester);

    expect(
      find.byKey(const Key('category-popup-close-button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('category-popup-back-button')), findsNothing);
    final frameSize = tester.getSize(
      find.byKey(const Key('category-popup-frame')),
    );
    expect(frameSize.width, greaterThanOrEqualTo(400));
    expect(frameSize.width, lessThanOrEqualTo(430));

    await tester.tap(find.byKey(const Key('category-popup-close-button')));
    await tester.pumpAndSettle();

    expect(find.text('Kategorie'), findsNothing);
  });

  testWidgets('category popup opens visible learning level package selection', (
    tester,
  ) async {
    await _pumpCategoryPopup(tester);

    await _scrollPopupUntilVisible(
      tester,
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.tap(
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lernlevel'), findsAtLeastNWidgets(1));
    expect(
      find.text('Wähle zuerst ein Level, dann ein kleines Paket.'),
      findsOneWidget,
    );
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    expect(find.text('B1'), findsOneWidget);
    expect(find.text('B2'), findsOneWidget);
    expect(find.text('C1'), findsOneWidget);
    expect(find.text('C2'), findsOneWidget);
    expect(find.text('A1 Starter'), findsNothing);

    await tester.tap(find.byKey(const Key('category-popup-level-a1')));
    await tester.pumpAndSettle();

    expect(find.text('A1'), findsAtLeastNWidgets(1));
    expect(
      find.text('Wähle ein kleines Paket statt ein ganzes Level.'),
      findsOneWidget,
    );
    expect(find.text('A1 Starter'), findsOneWidget);
    expect(find.text('A1 Alltag'), findsOneWidget);
    expect(find.text('A1 Verben'), findsOneWidget);
    expect(find.text('A1 Nomen'), findsOneWidget);
    expect(find.text('A1 Adjektive'), findsOneWidget);
    expect(find.text('A1 Reisen & Orientierung'), findsOneWidget);

    final a1PackageColors = tester
        .widgetList<TapFlash>(find.byType(TapFlash))
        .map((tapFlash) => tapFlash.color)
        .where(
          (color) => localLevelPackageGroups.first.packages.any(
            (package) =>
                color == CategoryStrokeColors.colorForLevelPackage(package.key),
          ),
        )
        .toSet();
    expect(a1PackageColors, hasLength(7));

    await tester.tap(find.byKey(const Key('category-popup-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Lernlevel'), findsAtLeastNWidgets(1));
    expect(find.text('A1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-popup-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Kategorie'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
  });

  testWidgets('B2 package tiles use the B2 level accent', (tester) async {
    await _pumpCategoryPopup(tester);

    await _scrollPopupUntilVisible(
      tester,
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.tap(
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category-popup-level-b2')));
    await tester.pumpAndSettle();

    expect(find.text('B2 Diskussion'), findsOneWidget);
    expect(find.text('B2 Redemittel'), findsOneWidget);
    final b2Group = localLevelPackageGroups.firstWhere(
      (group) => group.level == 'B2',
    );
    final b2PackageColors = tester
        .widgetList<TapFlash>(find.byType(TapFlash))
        .map((tapFlash) => tapFlash.color)
        .where(
          (color) => b2Group.packages.any(
            (package) =>
                color == CategoryStrokeColors.colorForLevelPackage(package.key),
          ),
        )
        .toSet();
    expect(b2PackageColors, hasLength(7));
  });

  testWidgets('C2 package tiles use the C2 level accent', (tester) async {
    await _pumpCategoryPopup(tester);

    await _scrollPopupUntilVisible(
      tester,
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.tap(
      find.byKey(const Key('category-popup-level-packages-tile')),
    );
    await tester.pumpAndSettle();

    await _scrollPopupUntilVisible(
      tester,
      find.byKey(const Key('category-popup-level-c2')),
    );
    await tester.tap(find.byKey(const Key('category-popup-level-c2')));
    await tester.pumpAndSettle();

    expect(find.text('C2 Präziser Ausdruck'), findsOneWidget);
    expect(find.text('C2 Redemittel'), findsOneWidget);
    final c2Group = localLevelPackageGroups.firstWhere(
      (group) => group.level == 'C2',
    );
    final c2PackageColors = tester
        .widgetList<TapFlash>(find.byType(TapFlash))
        .map((tapFlash) => tapFlash.color)
        .where(
          (color) => c2Group.packages.any(
            (package) =>
                color == CategoryStrokeColors.colorForLevelPackage(package.key),
          ),
        )
        .toSet();
    expect(c2PackageColors, hasLength(6));
  });

  testWidgets('category popup opens visible language tools selection', (
    tester,
  ) async {
    await _pumpCategoryPopup(tester);

    await _scrollPopupUntilVisible(
      tester,
      find.byKey(const Key('category-popup-language-tools-tile')),
    );
    await tester.tap(
      find.byKey(const Key('category-popup-language-tools-tile')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sprachwerkzeuge'), findsAtLeastNWidgets(1));
    expect(
      find.text('Übe besondere Wortgruppen und Sprachmuster.'),
      findsOneWidget,
    );
    expect(find.text('Top 500 Wörter'), findsOneWidget);
    expect(find.text('Redewendung'), findsOneWidget);
    expect(find.text('Unregelmäßige Verben'), findsOneWidget);
    expect(find.text('Grammatik & Satzbau'), findsOneWidget);
    expect(find.textContaining('_'), findsNothing);

    await tester.tap(find.byKey(const Key('category-popup-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Kategorie'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
  });

  testWidgets('category popup opens local detail for my words', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          localFavoritesRepositoryProvider.overrideWith(
            (ref) => _MemoryLocalFavoritesRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showCategoryPopup(
                      context: context,
                      onRefreshMyWords: () async {},
                      onTodo: (_) {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byKey(const Key('category-popup-my-words-tile')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(LocalLearningSourceDetailScreen), findsOneWidget);
    expect(find.text('Meine Wörter'), findsWidgets);
    expect(find.text('local-category-my-words'), findsNothing);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    expect(find.text('Kategorie'), findsOneWidget);
    expect(find.text('Meine Wörter'), findsOneWidget);
  });

  testWidgets('local source detail shows only local source wheel', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          localFavoritesRepositoryProvider.overrideWith(
            (ref) => _MemoryLocalFavoritesRepository(),
          ),
        ],
        child: const MaterialApp(
          home: LocalLearningSourceDetailScreen(initialSourceKey: 'my_words'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final wheel = tester.widget<CategoryWheel>(find.byType(CategoryWheel));
    expect(wheel.categories, const [
      'Alle Wörter',
      'Favoriten',
      'Meine Wörter',
      'Wörter, die ich kenne',
      'Mein Mix',
    ]);
    expect(wheel.initialIndex, 2);

    expect(wheel.categories, isNot(contains('Health & Fitness')));
    expect(wheel.categories, isNot(contains('Business & Work')));
    expect(wheel.categories, isNot(contains('Travel & Culture')));
    expect(wheel.categories, isNot(contains('All Words')));
    expect(wheel.categories, isNot(contains('My words')));
    expect(wheel.categories, isNot(contains('Favorites')));
    expect(wheel.categories, isNot(contains('Words I know')));
    expect(wheel.categories, isNot(contains('My mix')));

    wheel.onChanged(1, 'Favoriten');
    await tester.pump();

    expect(find.text('Favoriten'), findsWidgets);
    final updatedWheel = tester.widget<CategoryWheel>(
      find.byType(CategoryWheel),
    );
    expect(updatedWheel.initialIndex, 1);
  });

  testWidgets('category popup source tiles open local details', (tester) async {
    for (final entry in const [
      (Key('category-popup-all-words-tile'), 'Alle Wörter'),
      (Key('category-popup-favorites-tile'), 'Favoriten'),
      (Key('category-popup-known-words-tile'), 'Wörter, die ich kenne'),
      (Key('category-popup-my-mix-tile'), 'Mein Mix'),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
            localFavoritesRepositoryProvider.overrideWith(
              (ref) => _MemoryLocalFavoritesRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      showCategoryPopup(
                        context: context,
                        onRefreshMyWords: () async {},
                        onTodo: (_) {},
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await _scrollPopupUntilVisible(tester, find.byKey(entry.$1));
      await tester.tap(find.byKey(entry.$1));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.byType(LocalLearningSourceDetailScreen), findsOneWidget);
      expect(find.text(entry.$2), findsWidgets);
      expect(find.text('All Words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
      expect(find.text('My mix'), findsNothing);
    }
  });
}

Future<void> _pumpCategoryPopup(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        localFavoritesRepositoryProvider.overrideWith(
          (ref) => _MemoryLocalFavoritesRepository(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showCategoryPopup(
                    context: context,
                    onRefreshMyWords: () async {},
                    onTodo: (_) {},
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _scrollPopupUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).last,
  );
}

class _MemoryLocalFavoritesRepository implements LocalFavoritesRepository {
  _MemoryLocalFavoritesRepository([List<String> initial = const []])
    : _wordIds = [...initial];

  List<String> _wordIds;

  @override
  Future<List<String>> loadWordIds() async => [..._wordIds];

  @override
  Future<void> saveWordIds(List<String> wordIds) async {
    _wordIds = [...wordIds];
  }
}
