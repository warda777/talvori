import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/screens/word_path_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_search_game_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  LocalWord word({
    required String id,
    required String term,
    String translation = 'Übersetzung',
    String categoryId = 'seed-category-travel',
  }) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalWord(
      id: id,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocalCategory category(String id, String name) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<LocalWord> words() {
    return [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
      word(id: 'train', term: 'train'),
      word(id: 'water', term: 'water'),
      word(id: 'beach', term: 'beach'),
      word(id: 'plane', term: 'plane'),
      word(id: 'route', term: 'route'),
    ];
  }

  List<LocalWord> uniqueStartWords() {
    return [
      word(id: 'apple', term: 'apple'),
      word(id: 'beach', term: 'beach'),
      word(id: 'crane', term: 'crane'),
    ];
  }

  Future<void> pumpSearch(
    WidgetTester tester,
    List<LocalWord> words, {
    Random? random,
  }) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final categories = [category('seed-category-travel', 'Travel')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return words
                .where((word) => word.categoryId == categoryId)
                .toList(growable: false);
          }),
          localCategoriesProvider.overrideWith((ref) async => categories),
        ],
        child: MaterialApp(
          home: WordSearchGameScreen(random: random ?? Random(1)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  List<int> visibleIndexesForTerm(WidgetTester tester, String term) {
    final letters = [
      for (var i = 0; i < 100; i += 1)
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(ValueKey('word-search-cell-$i')),
                matching: find.byType(Text),
              ),
            )
            .data!
            .toLowerCase(),
    ];
    const rows = 10;
    const columns = 10;
    const directions = [
      (0, 1),
      (1, 0),
      (1, 1),
      (0, -1),
      (-1, 0),
      (-1, -1),
      (1, -1),
      (-1, 1),
    ];
    for (var row = 0; row < rows; row += 1) {
      for (var col = 0; col < columns; col += 1) {
        for (final direction in directions) {
          final indexes = <int>[];
          var matches = true;
          for (var i = 0; i < term.length; i += 1) {
            final nextRow = row + direction.$1 * i;
            final nextCol = col + direction.$2 * i;
            if (nextRow < 0 ||
                nextRow >= rows ||
                nextCol < 0 ||
                nextCol >= columns) {
              matches = false;
              break;
            }
            final index = nextRow * columns + nextCol;
            if (letters[index] != term[i]) {
              matches = false;
              break;
            }
            indexes.add(index);
          }
          if (matches) return indexes;
        }
      }
    }
    fail('No visible term found for $term');
  }

  String hintedTermFromFeedback(WidgetTester tester, List<LocalWord> words) {
    final text = tester
        .widget<Text>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data?.startsWith('Beginnt mit ') ?? false),
          ),
        )
        .data!;
    final letter = text.replaceFirst('Beginnt mit ', '').toLowerCase();
    return words
        .singleWhere((word) => word.term.toLowerCase().startsWith(letter))
        .term;
  }

  Future<void> findVisibleTerm(WidgetTester tester, String term) async {
    final indexes = visibleIndexesForTerm(tester, term);
    for (final index in indexes) {
      await tester.tap(find.byKey(ValueKey('word-search-cell-$index')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('word-search-check-button')));
    await tester.pump();
  }

  test('builds a box with horizontal vertical diagonal and reverse words', () {
    final box = buildWordSearchBox([
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
      word(id: 'train', term: 'train'),
    ], random: Random(1));

    expect(box.placements.length, greaterThanOrEqualTo(4));
    final deltas = [
      for (final placement in box.placements.take(4))
        placement.indexes[1] - placement.indexes.first,
    ];
    expect(deltas[0], 1);
    expect(deltas[1], box.columns);
    expect(deltas[2], box.columns + 1);
    expect(deltas[3], -1);
    for (final placement in box.placements) {
      expect(box.matchSelection(placement.indexes)?.word.id, placement.word.id);
      expect(
        box.matchSelection(placement.indexes.reversed.toList())?.word.id,
        placement.word.id,
      );
    }
  });

  testWidgets('Wortsuche opens from the hub with directional subtitle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    expect(
      find.text('Finde Wörter waagerecht, senkrecht und diagonal'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('word-game-word_search')),
    );
    await tester.tap(find.byKey(const ValueKey('word-game-word_search')));
    await tester.pumpAndSettle();

    expect(find.byType(WordSearchGameScreen), findsOneWidget);
    expect(find.text('Wortsuche'), findsWidgets);
  });

  testWidgets('startscreen shows central picker', (tester) async {
    await pumpSearch(tester, words());

    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Wörter pro Runde'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
  });

  testWidgets('board hides solutions and finds words by straight selection', (
    tester,
  ) async {
    await pumpSearch(tester, words());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-search-start-button')),
    );

    expect(find.byKey(const ValueKey('word-search-board')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-search-box-progress')),
      findsOneWidget,
    );
    expect(
      find.text(
        'Tippe Buchstaben waagerecht, senkrecht, diagonal oder rückwärts an.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining(RegExp(r'Gefunden: 0 / [3-6]')), findsOneWidget);
    expect(find.text('Suche: travel'), findsNothing);
    expect(find.text('travel'), findsNothing);
    expect(find.text('ticket'), findsNothing);
    expect(find.text('Hinweis'), findsOneWidget);
    expect(
      find.textContaining('Ohne Hinweis: 0 · Mit Hinweis: 0'),
      findsOneWidget,
    );

    final indexes = visibleIndexesForTerm(tester, 'travel');
    for (final index in indexes) {
      await tester.tap(find.byKey(ValueKey('word-search-cell-$index')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('word-search-check-button')));
    await tester.pump();

    expect(find.text('Gefunden'), findsOneWidget);
    expect(find.textContaining(RegExp(r'Gefunden: 1 / [3-6]')), findsOneWidget);
    expect(find.byKey(const ValueKey('word-search-board')), findsOneWidget);

    final firstCell = tester.widget<Container>(
      find.descendant(
        of: find.byKey(ValueKey('word-search-cell-${indexes.first}')),
        matching: find.byType(Container),
      ),
    );
    expect(firstCell.decoration, isA<BoxDecoration>());

    await tester.tap(find.byKey(ValueKey('word-search-cell-${indexes.first}')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('word-search-clear-button')));
    await tester.pump();
    expect(find.text('Nicht gefunden'), findsNothing);
  });

  testWidgets('hint reveals only first letter and marks the start cell', (
    tester,
  ) async {
    final testWords = uniqueStartWords();
    await pumpSearch(tester, testWords);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-search-start-button')),
    );

    await tester.tap(find.byKey(const ValueKey('word-search-hint-button')));
    await tester.pump();

    final hintedTerm = hintedTermFromFeedback(tester, testWords);
    final firstLetter = hintedTerm[0].toUpperCase();
    expect(find.text('Beginnt mit $firstLetter'), findsOneWidget);
    expect(find.text(hintedTerm), findsNothing);

    final indexes = visibleIndexesForTerm(tester, hintedTerm);
    final startCell = tester.widget<Container>(
      find.descendant(
        of: find.byKey(ValueKey('word-search-cell-${indexes.first}')),
        matching: find.byType(Container),
      ),
    );
    final decoration = startCell.decoration as BoxDecoration;
    expect(decoration.border?.top.width, 2);
  });

  testWidgets('found words are counted with and without hint', (tester) async {
    final testWords = uniqueStartWords();
    await pumpSearch(tester, testWords);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-search-start-button')),
    );

    await tester.tap(find.byKey(const ValueKey('word-search-hint-button')));
    await tester.pump();
    final hintedTerm = hintedTermFromFeedback(tester, testWords);
    await findVisibleTerm(tester, hintedTerm);

    expect(
      find.textContaining('Ohne Hinweis: 0 · Mit Hinweis: 1'),
      findsOneWidget,
    );

    final unhintedTerm = testWords
        .map((word) => word.term)
        .firstWhere((term) => term != hintedTerm);
    await findVisibleTerm(tester, unhintedTerm);

    expect(
      find.textContaining('Ohne Hinweis: 1 · Mit Hinweis: 1'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('word-search-board')), findsOneWidget);
  });

  testWidgets('all used hints show neutral feedback', (tester) async {
    await pumpSearch(tester, uniqueStartWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-search-start-button')),
    );

    for (var i = 0; i < 4; i += 1) {
      await tester.tap(find.byKey(const ValueKey('word-search-hint-button')));
      await tester.pump();
    }

    expect(find.text('Alle Hinweise wurden genutzt.'), findsOneWidget);
  });

  testWidgets('finish card separates clean and hinted finds', (tester) async {
    final testWords = uniqueStartWords();
    await pumpSearch(tester, testWords);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-search-start-button')),
    );

    await tester.tap(find.byKey(const ValueKey('word-search-hint-button')));
    await tester.pump();
    final hintedTerm = hintedTermFromFeedback(tester, testWords);
    await findVisibleTerm(tester, hintedTerm);

    for (final word in testWords) {
      if (word.term != hintedTerm) {
        await findVisibleTerm(tester, word.term);
      }
    }

    expect(find.text('Kasten geschafft'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('word-search-next-box-button')));
    await tester.pump();

    expect(find.text('Wortsuche geschafft'), findsOneWidget);
    expect(find.textContaining('Ohne Hinweis gefunden: 2'), findsOneWidget);
    expect(find.textContaining('Mit Hinweis gefunden: 1'), findsOneWidget);
  });

  testWidgets('Wortpfad still remains the horizontal-only simpler game', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words();
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return words();
          }),
          localCategoriesProvider.overrideWith(
            (ref) async => [category('seed-category-travel', 'Travel')],
          ),
        ],
        child: MaterialApp(home: WordPathGameScreen(random: Random(1))),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-path-start-button')),
    );

    final box = buildWordPathBox(words(), random: Random(1));
    for (final placement in box.placements) {
      final row = placement.indexes.first ~/ box.columns;
      expect(
        placement.indexes.every((index) => index ~/ box.columns == row),
        isTrue,
      );
    }
  });
}
