import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/speed_round_game_screen.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    required String translation,
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

  LocalCategory category({
    required String id,
    required String name,
    int sortOrder = 0,
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: sortOrder,
      isArchived: false,
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
    List<LocalCategory> categories = const <LocalCategory>[],
    Map<String, List<LocalWord>> wordsByCategory =
        const <String, List<LocalWord>>{},
    Map<LocalLearningSource, List<LocalWord>>? wordsBySource,
    Duration roundDuration = const Duration(seconds: 60),
    Random? random,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return wordsBySource?[source] ?? words;
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return wordsByCategory[categoryId] ?? const <LocalWord>[];
          }),
          localCategoriesProvider.overrideWith((ref) async {
            return categories;
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
        'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Blitzrunde zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.',
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

  testWidgets('start card shows word source selection with all words default', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    expect(
      find.byKey(const ValueKey('speed-round-source-picker')),
      findsOneWidget,
    );
    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
    expect(find.text('Wortquelle ändern'), findsOneWidget);
    expect(find.text('Wortwelt auswählen'), findsWidgets);
  });

  testWidgets('source sheet shows standard sources and switches favorites', (
    tester,
  ) async {
    final favoriteWords = [
      word(id: 'favorite-a', term: 'favorite', translation: 'Favorit'),
      word(id: 'favorite-b', term: 'star', translation: 'Stern'),
      word(id: 'favorite-c', term: 'moon', translation: 'Mond'),
      word(id: 'favorite-d', term: 'sun', translation: 'Sonne'),
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      wordsBySource: {
        LocalLearningSource.allWords: sampleWords(),
        LocalLearningSource.favorites: favoriteWords,
      },
    );

    await tester.tap(
      find.byKey(const ValueKey('speed-round-change-source-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wortquelle ändern'), findsWidgets);
    expect(find.text('Alle Wörter'), findsWidgets);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Mein Mix'), findsOneWidget);
    expect(find.text('Wörter, die ich kenne'), findsNothing);

    await tester.tap(
      find.byKey(
        ValueKey('speed-round-source-${LocalLearningSource.favorites.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Favoriten'), findsWidgets);

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();

    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('speed-round-prompt')))
        .data!;
    expect(favoriteWords.map((word) => word.term), contains(prompt));
  });

  testWidgets('word world sheet shows full names and switches travel', (
    tester,
  ) async {
    final travelCategory = category(id: 'seed-category-travel', name: 'Travel');
    final travelWords = [
      word(
        id: 'train',
        term: 'train',
        translation: 'Zug',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'ticket',
        term: 'ticket',
        translation: 'Ticket',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'hotel',
        term: 'hotel',
        translation: 'Hotel',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'map',
        term: 'map',
        translation: 'Karte',
        categoryId: travelCategory.id,
      ),
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {travelCategory.id: travelWords},
    );

    await tester.tap(
      find.byKey(const ValueKey('speed-round-select-world-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt auswählen'), findsWidgets);
    expect(find.text('Alltag & Leben'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Tech & Innovation'), findsOneWidget);
    expect(find.text('Music & Entertainment'), findsOneWidget);
    expect(find.text('Top 500 Words'), findsNothing);
    expect(find.text('A1'), findsNothing);
    expect(find.text('A2'), findsNothing);
    expect(find.text('B1'), findsNothing);
    expect(find.text('B2'), findsNothing);
    expect(find.text('C1'), findsNothing);
    expect(find.text('C2'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('speed-round-word-world-work_careers')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Beruf'), findsOneWidget);
    expect(find.text('Work & Careers'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Wortwelt: Travel'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();

    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('speed-round-prompt')))
        .data!;
    expect(travelWords.map((word) => word.term), contains(prompt));
  });

  testWidgets('category with too few pairs shows category empty state', (
    tester,
  ) async {
    final travelCategory = category(id: 'seed-category-travel', name: 'Travel');

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {
        travelCategory.id: sampleWords().take(3).toList(growable: false),
      },
    );

    await tester.tap(
      find.byKey(const ValueKey('speed-round-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Blitzrunde zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.',
      ),
      findsOneWidget,
    );
    expect(find.text('Wortwelt: Travel'), findsOneWidget);
  });

  testWidgets('start shows timer score prompt and answers', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
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

    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
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

  testWidgets('restart keeps selected category active', (tester) async {
    final travelCategory = category(id: 'seed-category-travel', name: 'Travel');
    final travelWords = [
      word(
        id: 'train',
        term: 'train',
        translation: 'Zug',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'ticket',
        term: 'ticket',
        translation: 'Ticket',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'hotel',
        term: 'hotel',
        translation: 'Hotel',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'map',
        term: 'map',
        translation: 'Karte',
        categoryId: travelCategory.id,
      ),
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {travelCategory.id: travelWords},
      roundDuration: const Duration(seconds: 1),
      random: Random(13),
    );

    await tester.tap(
      find.byKey(const ValueKey('speed-round-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('speed-round-word-world-travel')),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    await tester.ensureVisible(
      find.byKey(const ValueKey('speed-round-start-button')),
    );
    await tester.tap(find.byKey(const ValueKey('speed-round-start-button')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('speed-round-restart-button')));
    await tester.pump();

    expect(find.text('Bereit für die Blitzrunde?'), findsOneWidget);
    expect(find.text('Wortwelt: Travel'), findsOneWidget);
  });
}
