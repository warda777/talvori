import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/context_challenge_game_screen.dart';

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
        child: const MaterialApp(home: ContextChallengeGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> startGame(WidgetTester tester) async {
    await tester.tap(
      find.byKey(const ValueKey('context-challenge-start-button')),
    );
    await tester.pump();
  }

  test('buildContextChallengePairs keeps only complete unique pairs', () {
    final pairs = buildContextChallengePairs([
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'duplicate-term', term: 'ONE ', translation: 'einzeln'),
      word(id: 'duplicate-translation', term: 'single', translation: 'EINS'),
      word(id: 'empty-term', term: '', translation: 'leer'),
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

  test(
    'buildContextChallengeTask creates a blank sentence and one correct id',
    () {
      final pairs = buildContextChallengePairs(sampleWords());
      final task = buildContextChallengeTask(pairs: pairs, taskIndex: 0);

      expect(task.sentence, contains('___'));
      expect(task.correctAnswerText, 'emergency');
      expect(task.hintTranslation, 'Notfall');
      expect(task.answers, hasLength(4));
      expect(task.answers.where((answer) => answer.isCorrect), hasLength(1));
      expect(
        task.answers.singleWhere((answer) => answer.isCorrect).pairId,
        'emergency',
      );
    },
  );

  testWidgets('shows empty state with fewer than four word pairs', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: sampleWords().take(3).toList(growable: false),
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge mindestens vier Wörter mit Übersetzung hinzu, um die Kontext-Challenge zu starten.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card with local offline copy', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Kontext-Challenge'), findsWidgets);
    expect(
      find.text(
        'Erkenne Wörter im Zusammenhang. Diese erste Version funktioniert lokal ohne KI.',
      ),
      findsOneWidget,
    );
    expect(find.text('Challenge starten'), findsOneWidget);
  });

  testWidgets('shows context task after start', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('Richtig: 0'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('context-challenge-sentence')),
      findsOneWidget,
    );
    expect(find.textContaining('___'), findsOneWidget);
    expect(find.text('Hinweis: Notfall'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('context-challenge-answer-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('context-challenge-answer-shelter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('context-challenge-answer-rescue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('context-challenge-answer-water')),
      findsOneWidget,
    );
  });

  testWidgets('correct answer increases local score', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tester.tap(
      find.byKey(const ValueKey('context-challenge-answer-emergency')),
    );
    await tester.pump();

    expect(find.text('Passt in den Kontext!'), findsOneWidget);
    expect(find.text('Richtige Lösung'), findsOneWidget);
    expect(find.text('emergency'), findsWidgets);
    expect(find.text('Richtig: 1'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback and solution', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    final wrongAnswer = find.byKey(
      const ValueKey('context-challenge-answer-shelter'),
    );
    await tester.ensureVisible(wrongAnswer);
    await tester.pump();
    await tester.tap(wrongAnswer);
    await tester.pump();

    expect(find.text('Nicht ganz.'), findsOneWidget);
    expect(find.text('Richtige Lösung'), findsOneWidget);
    expect(find.text('emergency'), findsWidgets);
    expect(find.text('Richtig: 0'), findsOneWidget);
  });

  testWidgets('reveal shows the solution without increasing score', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tester.tap(
      find.byKey(const ValueKey('context-challenge-reveal-button')),
    );
    await tester.pump();

    expect(find.text('Aufgelöst.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('context-challenge-solution')),
      findsOneWidget,
    );
    expect(find.text('emergency'), findsWidgets);
    expect(find.text('Richtig: 0'), findsOneWidget);
  });

  testWidgets('finishes after the local round', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    for (final id in ['emergency', 'shelter', 'rescue', 'water']) {
      await tester.tap(find.byKey(ValueKey('context-challenge-answer-$id')));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('context-challenge-next-button')),
      );
      await tester.pump();
    }

    expect(find.text('Challenge beendet'), findsOneWidget);
    expect(
      find.text('Du hast 4 von 4 Kontext-Aufgaben richtig gelöst.'),
      findsOneWidget,
    );
    expect(
      find.text('Dein Lernfortschritt wurde nicht verändert.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
