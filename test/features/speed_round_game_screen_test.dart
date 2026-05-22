import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/speed_round_game_screen.dart';

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

  List<LocalWord> manyWords() {
    return List<LocalWord>.generate(12, (index) {
      final number = index + 1;
      return word(
        id: 'word-$number',
        term: 'word$number',
        translation: 'Wort $number',
      );
    });
  }

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
    Duration roundDuration = const Duration(seconds: 60),
    Random? random,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
        ],
        child: MaterialApp(
          home: SpeedRoundGameScreen(
            roundDuration: roundDuration,
            random: random ?? Random(7),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  test('buildSpeedRoundPairs keeps only complete unique pairs', () {
    final pairs = buildSpeedRoundPairs([
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

  test('buildSpeedRoundQuestion creates one correct answer by id', () {
    final pairs = buildSpeedRoundPairs(sampleWords());
    final question = buildSpeedRoundQuestion(pairs: pairs, questionIndex: 0);

    expect(question.prompt, 'emergency');
    expect(question.answers, hasLength(4));
    expect(question.answers.where((answer) => answer.isCorrect), hasLength(1));
    expect(
      question.answers.singleWhere((answer) => answer.isCorrect).pairId,
      'emergency',
    );
  });

  test('selectSpeedRoundRoundPairs shuffles and limits to ten questions', () {
    final pairs = buildSpeedRoundPairs(manyWords());
    final random = Random(3);

    final firstRound = selectSpeedRoundRoundPairs(pairs, random: random);
    final secondRound = selectSpeedRoundRoundPairs(pairs, random: random);

    expect(firstRound, hasLength(10));
    expect(secondRound, hasLength(10));
    expect(
      firstRound.map((pair) => pair.id),
      isNot(pairs.take(10).map((pair) => pair.id)),
    );
    expect(
      firstRound.map((pair) => pair.id),
      isNot(secondRound.map((pair) => pair.id)),
    );
  });

  test(
    'buildSpeedRoundQuestion can place the correct answer at another position',
    () {
      final pairs = buildSpeedRoundPairs(sampleWords());
      final question = buildSpeedRoundQuestion(
        pairs: pairs,
        questionIndex: 0,
        answerShift: 2,
      );

      expect(question.answers, hasLength(4));
      expect(question.answers.indexWhere((answer) => answer.isCorrect), 2);
      expect(
        question.answers.singleWhere((answer) => answer.isCorrect).pairId,
        'emergency',
      );
    },
  );

  testWidgets('shows empty state with fewer than four pairs', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords().take(3).toList(growable: false),
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge mindestens vier Wörter mit Übersetzung hinzu, um Blitzrunde zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card when enough words are available', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Bereit für die Blitzrunde?'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('start shows timer score prompt and answers', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();

    expect(find.text('Zeit: 60s'), findsOneWidget);
    expect(find.text('Richtig: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('speed-round-prompt')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('speed-round-answer-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('speed-round-answer-shelter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('speed-round-answer-rescue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('speed-round-answer-water')),
      findsOneWidget,
    );
  });

  testWidgets('correct answer increases local score', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();
    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('speed-round-prompt')))
        .data!;
    await tester.tap(find.byKey(ValueKey('speed-round-answer-$prompt')));
    await tester.pump();

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Richtig: 1'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();
    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('speed-round-prompt')))
        .data!;
    final wrongId = sampleWords()
        .map((word) => word.id)
        .firstWhere((id) => id != prompt);
    await tester.tap(find.byKey(ValueKey('speed-round-answer-$wrongId')));
    await tester.pump();

    expect(find.text('Nicht ganz.'), findsOneWidget);
    expect(find.text('Richtig: 0'), findsOneWidget);
  });

  testWidgets('finishes when test duration expires', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords(),
      roundDuration: const Duration(seconds: 1),
    );

    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Zeit vorbei'), findsOneWidget);
    expect(find.text('Du hast 0 Wörter richtig erkannt.'), findsOneWidget);
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });

  testWidgets('restart returns to a fresh start card', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords(),
      roundDuration: const Duration(seconds: 1),
      random: Random(11),
    );

    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('speed-round-restart-button')));
    await tester.pump();

    expect(find.text('Bereit für die Blitzrunde?'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
    expect(find.text('Zeit vorbei'), findsNothing);
  });
}
