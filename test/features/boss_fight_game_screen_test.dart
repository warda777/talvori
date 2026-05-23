import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/boss_fight_game_screen.dart';

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
        child: const MaterialApp(home: BossFightGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapByKey(WidgetTester tester, ValueKey<String> key) async {
    final finder = find.byKey(key);
    try {
      await tester.scrollUntilVisible(finder, 120);
    } catch (_) {
      if (find.byType(ListView).evaluate().isNotEmpty) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -520));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(finder);
    }
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> startFight(WidgetTester tester) async {
    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
    await tapByKey(tester, const ValueKey('boss-fight-start-button'));
  }

  Future<void> answerChoice(WidgetTester tester, String id) async {
    await tapByKey(tester, ValueKey('boss-fight-answer-$id'));
  }

  Future<void> next(WidgetTester tester) async {
    await tapByKey(tester, const ValueKey('boss-fight-next-button'));
  }

  test('buildBossFightPairs keeps complete unique pairs', () {
    final pairs = buildBossFightPairs([
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'duplicate-term', term: 'ONE', translation: 'single'),
      word(id: 'duplicate-translation', term: 'two', translation: 'eins'),
      word(id: 'empty', term: 'empty', translation: ''),
      word(
        id: 'archived',
        term: 'archived',
        translation: 'archiviert',
        isArchived: true,
      ),
      word(id: 'three', term: 'three', translation: 'drei'),
    ]);

    expect(pairs.map((pair) => pair.id), ['one', 'three']);
  });

  test('buildBossFightQuestion rotates through three question types', () {
    final pairs = buildBossFightPairs(sampleWords());

    expect(
      buildBossFightQuestion(pairs: pairs, questionIndex: 0).type,
      BossFightQuestionType.choice,
    );
    expect(
      buildBossFightQuestion(pairs: pairs, questionIndex: 1).type,
      BossFightQuestionType.gap,
    );
    expect(
      buildBossFightQuestion(pairs: pairs, questionIndex: 2).type,
      BossFightQuestionType.input,
    );
  });

  test('normalizes answer comparison', () {
    expect(normalizeBossFightAnswer('  Hello   World  '), 'hello world');
  });

  testWidgets('shows empty state with fewer than four pairs', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords().take(3).toList(growable: false),
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um den Boss-Fight zu starten.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card with no-progress note', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Boss-Fight'), findsWidgets);
    expect(find.text('Kampf starten'), findsOneWidget);
    expect(
      find.text('Dein Lernfortschritt bleibt unverändert.'),
      findsOneWidget,
    );
  });

  testWidgets('start shows boss hp energy and round', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startFight(tester);

    expect(find.text('Boss-HP: 8'), findsOneWidget);
    expect(find.text('Energie: 3'), findsOneWidget);
    expect(find.text('Runde: 1 / 8'), findsOneWidget);
    expect(find.text('Bedeutung treffen'), findsOneWidget);
  });

  testWidgets('correct answer reduces boss hp', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startFight(tester);

    await answerChoice(tester, 'emergency');

    expect(find.text('Treffer!'), findsOneWidget);
    expect(find.text('Boss-HP: 7'), findsOneWidget);
    expect(find.text('Energie: 3'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });

  testWidgets('wrong answer reduces energy and shows solution', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startFight(tester);

    await answerChoice(tester, 'shelter');

    expect(find.text('Der Boss blockt.'), findsOneWidget);
    expect(find.text('Boss-HP: 8'), findsOneWidget);
    expect(find.text('Energie: 2'), findsOneWidget);
    expect(find.text('Richtige Bedeutung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
  });

  testWidgets('reveal shows solution without changing hp or energy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startFight(tester);
    await answerChoice(tester, 'emergency');
    await next(tester);

    expect(find.text('Runde: 2 / 8'), findsOneWidget);
    await tapByKey(tester, const ValueKey('boss-fight-reveal-button'));

    expect(find.text('Aufgelöst.'), findsOneWidget);
    expect(find.text('Boss-HP: 7'), findsOneWidget);
    expect(find.text('Energie: 3'), findsOneWidget);
    expect(find.text('Lösung'), findsOneWidget);
  });

  testWidgets('input question accepts correct answer', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startFight(tester);
    await answerChoice(tester, 'emergency');
    await next(tester);
    await tapByKey(tester, const ValueKey('boss-fight-reveal-button'));
    await next(tester);

    expect(find.text('Runde: 3 / 8'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('boss-fight-input-field')),
      'rescue',
    );
    await tapByKey(tester, const ValueKey('boss-fight-check-button'));

    expect(find.text('Treffer!'), findsOneWidget);
    expect(find.text('Boss-HP: 6'), findsOneWidget);
  });

  testWidgets('boss defeated appears when hp reaches zero', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startFight(tester);
    final correctTerms = [
      'emergency',
      'shelter',
      'rescue',
      'water',
      'emergency',
      'shelter',
      'rescue',
      'water',
    ];
    for (var i = 0; i < correctTerms.length; i += 1) {
      final type = buildBossFightQuestion(
        pairs: buildBossFightPairs(sampleWords()),
        questionIndex: i,
      ).type;
      if (type == BossFightQuestionType.choice) {
        await answerChoice(tester, correctTerms[i]);
      } else {
        await tester.enterText(
          find.byKey(const ValueKey('boss-fight-input-field')),
          correctTerms[i],
        );
        await tapByKey(tester, const ValueKey('boss-fight-check-button'));
      }
      await next(tester);
    }

    expect(find.text('Boss besiegt'), findsOneWidget);
    expect(find.text('Du hast den Boss-Fight geschafft.'), findsOneWidget);
    expect(find.text('Nochmal kämpfen'), findsOneWidget);
  });

  testWidgets('boss escaped appears when energy reaches zero', (tester) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startFight(tester);
    for (var i = 0; i < 3; i += 1) {
      final type = buildBossFightQuestion(
        pairs: buildBossFightPairs(sampleWords()),
        questionIndex: i,
      ).type;
      if (type == BossFightQuestionType.choice) {
        await answerChoice(tester, 'shelter');
      } else {
        await tester.enterText(
          find.byKey(const ValueKey('boss-fight-input-field')),
          'wrong',
        );
        await tapByKey(tester, const ValueKey('boss-fight-check-button'));
      }
      await next(tester);
    }

    expect(find.text('Boss entkommen'), findsOneWidget);
    expect(
      find.text('Keine Sorge: Dein Lernfortschritt wurde nicht verändert.'),
      findsOneWidget,
    );
  });
}
