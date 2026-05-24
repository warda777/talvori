import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_puzzle_game_screen.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    String translation = 'Notfall',
    String categoryId = 'local-category-my-words',
    bool isArchived = false,
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalWord(
      id: id,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocalCategory category({required String id, required String name}) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalCategory(
      id: id,
      name: name,
      description: null,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
    Map<String, List<LocalWord>> sourceWords = const {},
    List<LocalCategory> categories = const <LocalCategory>[],
    Map<String, List<LocalWord>> categoryWords = const {},
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return sourceWords[source.id] ?? words;
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return categoryWords[categoryId] ?? const <LocalWord>[];
          }),
          localCategoriesProvider.overrideWith((ref) async {
            return categories;
          }),
        ],
        child: const MaterialApp(home: WordPuzzleGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    try {
      await tester.scrollUntilVisible(finder, 120);
    } catch (_) {
      await tester.ensureVisible(finder);
    }
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapSheetOption(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapScrolledSheetOption(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> startGame(WidgetTester tester) async {
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-puzzle-start-button')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAnswer(WidgetTester tester, String term, {int? limit}) async {
    final letters = buildWordPuzzleLetters(term);
    final used = <int>{};
    final chars = term.trim().split('');
    final count = limit ?? chars.length;
    for (final char in chars.take(count)) {
      final index = letters.indexWhere(
        (letter) =>
            letter.char == char && !used.contains(letters.indexOf(letter)),
      );
      used.add(index);
      await tester.tap(find.byKey(ValueKey('word-puzzle-letter-$index')));
      await tester.pump();
    }
  }

  test('buildWordPuzzleRoundWords keeps only stable puzzle terms', () {
    final words = buildWordPuzzleRoundWords([
      word(id: 'no', term: 'no'),
      word(id: 'cat', term: 'cat'),
      word(id: 'two-parts', term: 'ice-cold'),
      word(id: 'space', term: 'ice cold'),
      word(id: 'same', term: 'CAT'),
      word(id: 'archived', term: 'rescue', isArchived: true),
    ]);

    expect(words.map((word) => word.id), ['cat']);
  });

  test('buildWordPuzzleLetters shuffles longer words and keeps duplicates', () {
    final letters = buildWordPuzzleLetters('level');

    expect(letters.map((letter) => letter.char).join(), isNot('level'));
    expect(letters.map((letter) => letter.char).toList()..sort(), [
      'e',
      'e',
      'l',
      'l',
      'v',
    ]);
  });

  test('normalizes simple answer comparison', () {
    expect(normalizeWordPuzzleAnswer('  Hello   World  '), 'hello world');
  });

  testWidgets('shows empty state when no matching words are available', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [
        word(id: 'no', term: 'no'),
        word(id: 'with-space', term: 'ice cold'),
      ],
    );

    expect(find.text('Noch keine passenden Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortquelle braucht Wörter mit mindestens drei Buchstaben, um Wort-Puzzle zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('start screen shows active source with all words default', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );

    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
    expect(find.text('Wortquelle ändern'), findsOneWidget);
    expect(find.text('Wortwelt auswählen'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('source sheet switches to favorites', (tester) async {
    final allWords = [word(id: 'cat', term: 'cat')];
    final favoriteWords = [word(id: 'sun', term: 'sun', translation: 'Sonne')];
    await pumpGame(
      tester,
      words: allWords,
      sourceWords: {LocalLearningSource.favorites.id: favoriteWords},
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-puzzle-change-source-button')),
    );
    expect(find.text('Favoriten'), findsOneWidget);
    await tapSheetOption(
      tester,
      find.byKey(const ValueKey('word-puzzle-source-local-source-favorites')),
    );

    expect(find.text('Favoriten'), findsOneWidget);
    await startGame(tester);
    expect(find.text('Hinweis: Sonne'), findsOneWidget);
  });

  testWidgets('word world sheet shows full names and switches travel', (
    tester,
  ) async {
    final travelCategory = category(id: 'seed-category-travel', name: 'Travel');
    final travelWords = [
      word(
        id: 'map',
        term: 'map',
        translation: 'Karte',
        categoryId: travelCategory.id,
      ),
    ];
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
      categories: [travelCategory],
      categoryWords: {travelCategory.id: travelWords},
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-puzzle-select-world-button')),
    );

    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Music & Entertainment'), findsOneWidget);
    expect(find.text('Top 500 Words'), findsNothing);
    expect(find.text('A1'), findsNothing);
    expect(find.text('A2'), findsNothing);
    expect(find.text('B1'), findsNothing);
    expect(find.text('B2'), findsNothing);
    expect(find.text('C1'), findsNothing);
    expect(find.text('C2'), findsNothing);

    await tapScrolledSheetOption(
      tester,
      find.byKey(const ValueKey('word-puzzle-word-world-travel')),
    );

    expect(find.text('Wortwelt: Travel'), findsOneWidget);
    await startGame(tester);
    expect(find.text('Hinweis: Karte'), findsOneWidget);
  });

  testWidgets('category with no puzzle words shows category empty state', (
    tester,
  ) async {
    final travelCategory = category(id: 'seed-category-travel', name: 'Travel');
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
      categories: [travelCategory],
      categoryWords: {
        travelCategory.id: [
          word(id: 'no', term: 'no', categoryId: travelCategory.id),
        ],
      },
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-puzzle-select-world-button')),
    );
    await tapScrolledSheetOption(
      tester,
      find.byKey(const ValueKey('word-puzzle-word-world-travel')),
    );

    expect(find.text('Noch keine passenden Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortwelt braucht Wörter mit mindestens drei Buchstaben, um Wort-Puzzle zu spielen.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows mixed letter chips and hint', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    expect(find.text('Wort-Puzzle'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-puzzle-letter-wrap')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('word-puzzle-letter-0')), findsOneWidget);
    expect(find.text('Hinweis: Notfall'), findsOneWidget);
    expect(find.text('Tippe Buchstaben an'), findsOneWidget);
  });

  testWidgets('tapping letters builds the answer', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat', limit: 2);

    expect(find.text('ca'), findsOneWidget);
  });

  testWidgets('undo removes the last selected letter', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat', limit: 2);
    await tester.tap(find.byKey(const ValueKey('word-puzzle-undo-button')));
    await tester.pump();

    final answerText = tester.widget<Text>(
      find.byKey(const ValueKey('word-puzzle-answer-text')),
    );
    expect(answerText.data, 'c');
    expect(find.text('ca'), findsNothing);
  });

  testWidgets('reset clears the current answer', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat', limit: 2);
    await tester.tap(find.byKey(const ValueKey('word-puzzle-reset-button')));
    await tester.pump();

    expect(find.text('Tippe Buchstaben an'), findsOneWidget);
    expect(find.text('ca'), findsNothing);
  });

  testWidgets('correct answer is accepted and reveals word', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat');
    await tester.tap(find.byKey(const ValueKey('word-puzzle-check-button')));
    await tester.pump();

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Vollständiges Wort'), findsOneWidget);
    expect(find.text('cat'), findsWidgets);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat', limit: 2);
    await tester.tap(find.byKey(const ValueKey('word-puzzle-check-button')));
    await tester.pump();

    expect(find.text('Nicht ganz. Versuch es nochmal.'), findsOneWidget);
    expect(find.text('Vollständiges Wort'), findsNothing);
  });

  testWidgets('reveal shows full word', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tester.tap(find.byKey(const ValueKey('word-puzzle-reveal-button')));
    await tester.pump();

    expect(find.text('Aufgelöst: cat'), findsOneWidget);
    expect(find.text('Vollständiges Wort'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('finishes after the last word', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );
    await startGame(tester);

    await tapAnswer(tester, 'cat');
    await tester.tap(find.byKey(const ValueKey('word-puzzle-check-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('word-puzzle-next-button')));
    await tester.pump();

    expect(find.text('Puzzle geschafft'), findsOneWidget);
    expect(
      find.text('Du hast 1 von 1 Wörtern richtig zusammengesetzt.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
