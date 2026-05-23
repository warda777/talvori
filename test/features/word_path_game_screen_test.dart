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

  Future<void> pumpPath(
    WidgetTester tester,
    List<LocalWord> words, {
    Random? random,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
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
          home: WordPathGameScreen(random: random ?? Random(1)),
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

  List<int> findTermIndexes(WidgetTester tester, String term) {
    final letters = [
      for (var i = 0; i < 64; i += 1)
        tester
            .widget<Text>(
              find.descendant(
                of: find.byKey(ValueKey('word-path-cell-$i')),
                matching: find.byType(Text),
              ),
            )
            .data!
            .toLowerCase(),
    ];
    for (var row = 0; row < 8; row += 1) {
      final line = [
        for (var col = 0; col < 8; col += 1) letters[row * 8 + col],
      ].join();
      final forward = line.indexOf(term);
      if (forward >= 0) {
        return [
          for (var offset = 0; offset < term.length; offset += 1)
            row * 8 + forward + offset,
        ];
      }
      final reversed = line.indexOf(term.split('').reversed.join());
      if (reversed >= 0) {
        return [
          for (var offset = term.length - 1; offset >= 0; offset -= 1)
            row * 8 + reversed + offset,
        ];
      }
    }
    fail('No visible horizontal term found for $term');
  }

  test('builds a horizontal box and avoids extra active words', () {
    final travel = word(id: 'travel', term: 'travel');
    final ticket = word(id: 'ticket', term: 'ticket');
    final hotel = word(id: 'hotel', term: 'hotel');
    final box = buildWordPathBox(
      [travel, ticket],
      allRoundWords: [travel, ticket, hotel],
      random: Random(1),
    );

    expect(box.placements, hasLength(2));
    for (final placement in box.placements) {
      final row = placement.indexes.first ~/ box.columns;
      expect(
        placement.indexes.every((index) => index ~/ box.columns == row),
        isTrue,
      );
      expect(box.matchSelection(placement.indexes)?.word.id, placement.word.id);
      expect(
        box.matchSelection(placement.indexes.reversed.toList())?.word.id,
        placement.word.id,
      );
    }
    for (var row = 0; row < box.rows; row += 1) {
      final line = [
        for (var col = 0; col < box.columns; col += 1)
          box.cells[row * box.columns + col],
      ].join();
      expect(line.contains('hotel'), isFalse);
      expect(line.split('').reversed.join().contains('hotel'), isFalse);
    }
  });

  testWidgets('Wortpfad opens from the hub', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('word-game-word_path')),
    );
    await tester.tap(find.byKey(const ValueKey('word-game-word_path')));
    await tester.pumpAndSettle();

    expect(find.byType(WordPathGameScreen), findsOneWidget);
    expect(find.text('Wortpfad'), findsWidgets);
  });

  testWidgets('startscreen shows selection and words per round', (
    tester,
  ) async {
    await pumpPath(tester, [word(id: 'travel', term: 'travel')]);

    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Wörter pro Runde'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
  });

  testWidgets('board hides multiple words without visible target list', (
    tester,
  ) async {
    await pumpPath(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-path-start-button')),
    );

    expect(find.byKey(const ValueKey('word-path-board')), findsOneWidget);
    expect(find.text('Tippe Buchstaben in einer Zeile an.'), findsOneWidget);
    expect(find.text('Leeren'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-path-box-progress')),
      findsOneWidget,
    );
    expect(find.textContaining(RegExp(r'Gefunden: 0 / [2-3]')), findsOneWidget);
    expect(find.text('Suche: travel'), findsNothing);
    expect(find.text('travel'), findsNothing);
    expect(find.text('ticket'), findsNothing);
  });

  testWidgets('tapping letters checks words and keeps the same box', (
    tester,
  ) async {
    await pumpPath(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-path-start-button')),
    );

    final firstIndexes = findTermIndexes(tester, 'travel');
    for (final index in firstIndexes) {
      await tester.tap(find.byKey(ValueKey('word-path-cell-$index')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('word-path-check-button')));
    await tester.pump();

    expect(find.text('Gefunden'), findsOneWidget);
    expect(find.text('Gefunden: 1 / 2'), findsOneWidget);
    expect(find.byKey(const ValueKey('word-path-board')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-path-next-box-button')),
      findsNothing,
    );

    final firstCell = tester.widget<Container>(
      find.descendant(
        of: find.byKey(ValueKey('word-path-cell-${firstIndexes.first}')),
        matching: find.byType(Container),
      ),
    );
    expect(firstCell.decoration, isA<BoxDecoration>());

    for (final index in firstIndexes) {
      await tester.tap(find.byKey(ValueKey('word-path-cell-$index')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('word-path-clear-button')));
    await tester.pump();
    expect(find.text('Bereits gefunden'), findsNothing);
    expect(find.text('Nicht gefunden'), findsNothing);

    final secondIndexes = findTermIndexes(tester, 'ticket');
    for (final index in secondIndexes) {
      await tester.tap(find.byKey(ValueKey('word-path-cell-$index')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('word-path-check-button')));
    await tester.pump();

    expect(find.text('Kasten gelöst'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-path-next-box-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('word-path-next-box-button')));
    await tester.pump();

    expect(find.text('Wortpfad geschafft'), findsOneWidget);
    expect(find.textContaining('Du hast 2 Wörter gefunden.'), findsOneWidget);
  });
}
