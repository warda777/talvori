import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/hangman_game_screen.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    String translation = 'Hinweis',
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

  List<LocalWord> sampleWords() {
    return [
      word(id: 'level', term: 'level', translation: 'Ebene'),
      word(id: 'mutter', term: 'mutter', translation: 'mother'),
    ];
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
        child: const MaterialApp(home: HangmanGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  test('buildHangmanRoundWords keeps playable unique words', () {
    final words = buildHangmanRoundWords([
      word(id: 'ok', term: 'level'),
      word(id: 'duplicate', term: 'LEVEL'),
      word(id: 'short', term: 'at'),
      word(id: 'space', term: 'ice cream'),
      word(id: 'hyphen', term: 'ice-cream'),
      word(id: 'special', term: 'word!'),
      word(id: 'umlaut', term: 'Müde'),
      word(id: 'archived', term: 'valid', isArchived: true),
    ]);

    expect(words.map((item) => item.id), ['ok', 'umlaut']);
  });

  test('mask reveals all matching duplicate letters', () {
    expect(buildHangmanMask('level', {'E'}), '_ e _ e _');
    expect(buildHangmanMask('mutter', {'T'}), '_ _ t t _ _');
  });

  testWidgets('shows empty state when no matching words are available', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [word(id: 'tiny', term: 'go')],
    );

    expect(find.text('Noch keine passenden Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge Wörter mit mindestens drei Buchstaben hinzu, um Hangman zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows masked word and attempts', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Hangman'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Versuche übrig: 6'), findsOneWidget);
    expect(find.byKey(const ValueKey('hangman-mask')), findsOneWidget);
    expect(find.text('_ _ _ _ _'), findsOneWidget);
    expect(find.text('level'), findsNothing);
  });

  testWidgets('correct letter reveals matching positions and marks chip', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('hangman-letter-E')));
    await tester.pump();

    expect(find.text('Guter Treffer!'), findsOneWidget);
    expect(find.text('_ e _ e _'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'E'), findsOneWidget);
  });

  testWidgets('wrong letter reduces attempts and disables selected chip', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('hangman-letter-Z')));
    await tester.pump();

    expect(find.text('Der Buchstabe ist nicht dabei.'), findsOneWidget);
    expect(find.text('Versuche übrig: 5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hangman-letter-Z')));
    await tester.pump();
    expect(find.text('Versuche übrig: 5'), findsOneWidget);
  });

  testWidgets('solving word reveals full word and enables next', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    for (final letter in ['L', 'E', 'V']) {
      await tester.tap(find.byKey(ValueKey('hangman-letter-$letter')));
      await tester.pump();
    }

    expect(find.text('Wort gelöst!'), findsOneWidget);
    expect(find.text('level'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('reveal shows the full word', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('hangman-reveal-button')));
    await tester.pump();

    expect(find.text('Aufgelöst: level'), findsOneWidget);
    expect(find.text('level'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('finishes after the round', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    for (final wordLetters in [
      ['L', 'E', 'V'],
      ['M', 'U', 'T', 'E', 'R'],
    ]) {
      for (final letter in wordLetters) {
        await tester.tap(find.byKey(ValueKey('hangman-letter-$letter')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const ValueKey('hangman-next-button')));
      await tester.pump();
    }

    expect(find.text('Runde beendet'), findsOneWidget);
    expect(find.text('Du hast 2 von 2 Wörtern gelöst.'), findsOneWidget);
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
