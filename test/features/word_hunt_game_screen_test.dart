import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_hunt_game_screen.dart';
import 'package:flutter/material.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    required String translation,
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
      word(id: 'emergency', term: 'emergency', translation: 'Notfall'),
      word(id: 'shelter', term: 'shelter', translation: 'Schutz'),
      word(id: 'rescue', term: 'rescue', translation: 'Rettung'),
      word(id: 'water', term: 'water', translation: 'Wasser'),
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
        child: const MaterialApp(home: WordHuntGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  test('buildWordHuntPairs keeps only complete unique pairs', () {
    final pairs = buildWordHuntPairs([
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'duplicate-translation', term: 'single', translation: 'eins'),
      word(id: 'empty-translation', term: 'empty', translation: ''),
      word(
        id: 'archived',
        term: 'archived',
        translation: 'archiviert',
        isArchived: true,
      ),
      word(id: 'two', term: 'two', translation: 'zwei'),
    ]);

    expect(pairs.map((pair) => pair.id), ['one', 'two']);
  });

  test('buildWordHuntQuestion creates one correct answer by id', () {
    final pairs = buildWordHuntPairs(sampleWords());
    final question = buildWordHuntQuestion(pairs: pairs, questionIndex: 0);

    expect(question.prompt, 'emergency');
    expect(question.answers, hasLength(4));
    expect(question.answers.where((answer) => answer.isCorrect), hasLength(1));
    expect(
      question.answers.singleWhere((answer) => answer.isCorrect).pairId,
      'emergency',
    );
  });

  testWidgets('shows empty state with fewer than four pairs', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords().take(3).toList(growable: false),
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge mindestens vier Wörter mit Übersetzung hinzu, um Wort-Jagd zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card when enough words are available', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Bereit für die Wort-Jagd?'), findsOneWidget);
    expect(
      find.text('Tippe schnell die richtige Bedeutung an.'),
      findsOneWidget,
    );
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('start shows progress hits prompt and answers', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-hunt-start-button')));
    await tester.pump();

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('Treffer: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('word-hunt-prompt')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-hunt-answer-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-hunt-answer-shelter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-hunt-answer-rescue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-hunt-answer-water')),
      findsOneWidget,
    );
  });

  testWidgets('correct answer increases local hits and advances', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-hunt-start-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('word-hunt-answer-emergency')));
    await tester.pump();

    expect(find.text('Treffer!'), findsOneWidget);
    expect(find.text('Treffer: 1'), findsOneWidget);
    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('shelter'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback and advances', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-hunt-start-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('word-hunt-answer-shelter')));
    await tester.pump();

    expect(find.text('Daneben.'), findsOneWidget);
    expect(find.text('Treffer: 0'), findsOneWidget);
    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('shelter'), findsOneWidget);
  });

  testWidgets('finishes after the last question', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-hunt-start-button')));
    await tester.pump();
    for (final id in ['emergency', 'shelter', 'rescue', 'water']) {
      await tester.tap(find.byKey(ValueKey('word-hunt-answer-$id')));
      await tester.pump();
    }

    expect(find.text('Jagd beendet'), findsOneWidget);
    expect(
      find.text('Du hast 4 von 4 Bedeutungen richtig getroffen.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
