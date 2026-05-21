import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';
import 'package:talvori/features/home/ui/widgets/category_popup.dart';
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
      expect(find.text('Mix erstellen'), findsOneWidget);

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
