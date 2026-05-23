import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/daily_word_quest_game_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
      word(id: 'level', term: 'level', translation: 'Stufe'),
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
        child: const MaterialApp(home: DailyWordQuestGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapByKey(WidgetTester tester, ValueKey<String> key) async {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -520));
        await tester.pump();
      }
    }
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> startQuest(WidgetTester tester) async {
    await tapByKey(tester, const ValueKey('daily-quest-start-button'));
  }

  Future<void> answerChoice(WidgetTester tester, String id) async {
    await tapByKey(tester, ValueKey('daily-quest-answer-$id'));
  }

  Future<void> tapPuzzleAnswer(WidgetTester tester, String term) async {
    final letters = buildQuestPuzzleLetters(term);
    final used = <int>{};
    for (final char in term.trim().split('')) {
      final index = letters.indexWhere((letter) {
        final currentIndex = letters.indexOf(letter);
        return letter.char == char && !used.contains(currentIndex);
      });
      used.add(index);
      await tapByKey(tester, ValueKey('daily-quest-puzzle-letter-$index'));
    }
  }

  Future<void> reachPuzzleTask(WidgetTester tester) async {
    await startQuest(tester);
    for (final id in ['emergency', 'shelter', 'rescue']) {
      await answerChoice(tester, id);
      await tapByKey(tester, const ValueKey('daily-quest-next-button'));
    }
    await tester.enterText(
      find.byKey(const ValueKey('daily-quest-gap-field')),
      'water',
    );
    await tapByKey(tester, const ValueKey('daily-quest-check-button'));
    await tapByKey(tester, const ValueKey('daily-quest-next-button'));
  }

  test('buildDailyQuestPairs keeps five complete stable unique pairs', () {
    final pairs = buildDailyQuestPairs([
      word(id: 'one', term: 'alarm', translation: 'Alarm'),
      word(id: 'duplicate-term', term: 'ALARM', translation: 'Warnung'),
      word(id: 'duplicate-translation', term: 'signal', translation: 'Alarm'),
      word(id: 'space', term: 'ice cold', translation: 'eiskalt'),
      word(id: 'empty', term: 'empty', translation: ''),
      word(
        id: 'archived',
        term: 'rescue',
        translation: 'Rettung',
        isArchived: true,
      ),
      ...sampleWords(),
    ]);

    expect(pairs, hasLength(5));
    expect(pairs.first.id, 'one');
    expect(pairs.map((pair) => pair.id), [
      'one',
      'emergency',
      'shelter',
      'rescue',
      'water',
    ]);
  });

  test('buildDailyQuestTask creates the expected task sequence', () {
    final pairs = buildDailyQuestPairs(sampleWords());

    expect(
      buildDailyQuestTask(pairs: pairs, taskIndex: 0).type,
      DailyQuestTaskType.choice,
    );
    expect(
      buildDailyQuestTask(pairs: pairs, taskIndex: 3).type,
      DailyQuestTaskType.gap,
    );
    expect(
      buildDailyQuestTask(pairs: pairs, taskIndex: 4).type,
      DailyQuestTaskType.puzzle,
    );
  });

  test('normalizes answer comparison', () {
    expect(normalizeDailyQuestAnswer('  Hello   World  '), 'hello world');
  });

  test('buildDailyQuestHiddenHint reveals letters progressively', () {
    expect(buildDailyQuestHiddenHint('travel', 0), '_ _ _ _ _ _');
    expect(buildDailyQuestHiddenHint('travel', 1), 't _ _ _ _ _');
    expect(buildDailyQuestHiddenHint('travel', 2), 't r _ _ _ _');
    expect(buildDailyQuestHiddenHint('travel', 3), 't r a _ _ _');
    expect(buildDailyQuestHiddenHint('travel', 6), 't r a v e l');
  });

  testWidgets('shows empty state with fewer than five matching words', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: sampleWords().take(4).toList(growable: false),
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortquelle braucht mindestens fünf Wörter, um deine Daily Word Quest zu starten.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card with local quest goals', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Daily Word Quest'), findsOneWidget);
    expect(find.text('Deine heutige Wortmission'), findsOneWidget);
    expect(find.text('3 Bedeutungen erkennen'), findsOneWidget);
    expect(find.text('1 Wort ergänzen'), findsOneWidget);
    expect(find.text('1 Wort zusammensetzen'), findsOneWidget);
    expect(find.text('Quest starten'), findsOneWidget);
  });

  testWidgets('start opens task 1 of 5', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startQuest(tester);

    expect(find.text('Aufgabe 1 / 5'), findsOneWidget);
    expect(find.text('Punkte: 0'), findsOneWidget);
    expect(find.text('Bedeutung erkennen'), findsOneWidget);
    expect(find.text('emergency'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('daily-quest-answer-emergency')),
      findsOneWidget,
    );
  });

  testWidgets('multiple choice accepts correct answer', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startQuest(tester);

    await answerChoice(tester, 'emergency');

    expect(find.text('Quest-Punkt!'), findsOneWidget);
    expect(find.text('Richtige Bedeutung'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });

  testWidgets(
    'multiple choice wrong answer shows neutral feedback and solution',
    (tester) async {
      await pumpGame(tester, words: sampleWords());
      await startQuest(tester);

      await answerChoice(tester, 'shelter');

      expect(find.text('Nicht ganz.'), findsOneWidget);
      expect(find.text('Richtige Bedeutung'), findsOneWidget);
      expect(find.text('Notfall'), findsWidgets);
    },
  );

  testWidgets('gap task accepts correct input', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startQuest(tester);
    for (final id in ['emergency', 'shelter', 'rescue']) {
      await answerChoice(tester, id);
      await tapByKey(tester, const ValueKey('daily-quest-next-button'));
    }

    expect(find.text('Aufgabe 4 / 5'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('daily-quest-gap-field')),
      'water',
    );
    await tapByKey(tester, const ValueKey('daily-quest-check-button'));

    expect(find.text('Quest-Punkt!'), findsOneWidget);
    expect(find.text('Lösung'), findsOneWidget);
    expect(find.text('water'), findsWidgets);
  });

  testWidgets('puzzle task lets letters be tapped', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await reachPuzzleTask(tester);

    expect(find.text('Aufgabe 5 / 5'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('daily-quest-puzzle-letters')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('daily-quest-puzzle-hint')),
      findsOneWidget,
    );
    expect(find.text('_ _ _ _ _'), findsOneWidget);
    expect(find.text('Stufe'), findsNothing);
    expect(find.text('level'), findsNothing);

    await tapPuzzleAnswer(tester, 'level');

    expect(find.text('Quest-Punkt!'), findsOneWidget);
    expect(find.text('level'), findsWidgets);
  });

  testWidgets('puzzle hint reveals one more letter on every tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await reachPuzzleTask(tester);

    final hint = find.byKey(const ValueKey('daily-quest-puzzle-hint'));
    expect(find.text('_ _ _ _ _'), findsOneWidget);
    expect(find.text('level'), findsNothing);

    await tapByKey(tester, const ValueKey('daily-quest-puzzle-hint'));
    expect(find.text('l _ _ _ _'), findsOneWidget);

    await tapByKey(tester, const ValueKey('daily-quest-puzzle-hint'));
    expect(find.text('l e _ _ _'), findsOneWidget);

    await tester.ensureVisible(hint);
    for (var i = 0; i < 3; i += 1) {
      await tester.tap(hint);
      await tester.pump();
    }
    expect(find.text('l e v e l'), findsOneWidget);
  });

  testWidgets('puzzle reveal still shows complete solution separately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await reachPuzzleTask(tester);

    expect(find.text('level'), findsNothing);
    await tapByKey(tester, const ValueKey('daily-quest-reveal-button'));

    expect(find.text('Aufgelöst.'), findsOneWidget);
    expect(find.text('Lösung'), findsOneWidget);
    expect(find.text('level'), findsWidgets);
  });

  testWidgets('finishes after five tasks', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startQuest(tester);
    for (final id in ['emergency', 'shelter', 'rescue']) {
      await answerChoice(tester, id);
      await tapByKey(tester, const ValueKey('daily-quest-next-button'));
    }
    await tester.enterText(
      find.byKey(const ValueKey('daily-quest-gap-field')),
      'water',
    );
    await tapByKey(tester, const ValueKey('daily-quest-check-button'));
    await tapByKey(tester, const ValueKey('daily-quest-next-button'));
    await tapPuzzleAnswer(tester, 'level');
    await tapByKey(tester, const ValueKey('daily-quest-next-button'));

    expect(find.text('Quest abgeschlossen'), findsOneWidget);
    expect(
      find.text('Du hast 5 von 5 Quest-Punkten gesammelt.'),
      findsOneWidget,
    );
    expect(
      find.text('Dein SRS-Fortschritt wurde nicht verändert.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
