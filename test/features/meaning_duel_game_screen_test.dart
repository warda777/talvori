import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/meaning_duel_game_screen.dart';

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
        child: const MaterialApp(home: MeaningDuelGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  test('buildMeaningDuelPairs keeps only complete unique pairs', () {
    final pairs = buildMeaningDuelPairs([
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

  test('buildMeaningDuelQuestion creates one correct answer by id', () {
    final pairs = buildMeaningDuelPairs(sampleWords());
    final question = buildMeaningDuelQuestion(pairs: pairs, questionIndex: 0);

    expect(question.prompt, 'emergency');
    expect(question.correctAnswerText, 'Notfall');
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
        'Füge mindestens vier Wörter mit Übersetzung hinzu, um Bedeutungs-Duell zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows prompt counter and four answer options', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Bedeutungs-Duell'), findsOneWidget);
    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('meaning-duel-prompt')), findsOneWidget);
    expect(find.text('emergency'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('meaning-duel-answer-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('meaning-duel-answer-shelter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('meaning-duel-answer-rescue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('meaning-duel-answer-water')),
      findsOneWidget,
    );
  });

  testWidgets('correct answer is accepted', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(
      find.byKey(const ValueKey('meaning-duel-answer-emergency')),
    );
    await tester.pump();

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Richtige Bedeutung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.text('Nächste Frage'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback and correct answer', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('meaning-duel-answer-shelter')));
    await tester.pump();

    expect(find.text('Nicht ganz.'), findsOneWidget);
    expect(find.text('Richtige Bedeutung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
  });

  testWidgets('reveal shows the correct answer', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('meaning-duel-reveal-button')));
    await tester.pump();

    expect(find.text('Aufgelöst.'), findsOneWidget);
    expect(find.text('Richtige Bedeutung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.text('Nächste Frage'), findsOneWidget);
  });

  testWidgets('next question advances to the next prompt', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    await tester.tap(
      find.byKey(const ValueKey('meaning-duel-answer-emergency')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('meaning-duel-next-button')));
    await tester.pump();

    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('shelter'), findsOneWidget);
    expect(find.text('Richtig!'), findsNothing);
  });

  testWidgets('finishes after all questions', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    for (final id in ['emergency', 'shelter', 'rescue', 'water']) {
      await tester.tap(find.byKey(ValueKey('meaning-duel-answer-$id')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('meaning-duel-next-button')));
      await tester.pump();
    }

    expect(find.text('Duell beendet'), findsOneWidget);
    expect(
      find.text('Du hast 4 von 4 Bedeutungen richtig erkannt.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
