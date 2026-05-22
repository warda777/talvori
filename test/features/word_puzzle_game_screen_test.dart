import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_puzzle_game_screen.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    String translation = 'Notfall',
    bool isArchived = false,
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
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

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
        ],
        child: const MaterialApp(home: WordPuzzleGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
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
        'Füge Wörter mit mindestens drei Buchstaben hinzu, um Wort-Puzzle zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows mixed letter chips and hint', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );

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

    await tapAnswer(tester, 'cat', limit: 2);

    expect(find.text('ca'), findsOneWidget);
  });

  testWidgets('undo removes the last selected letter', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'cat', term: 'cat')],
    );

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
