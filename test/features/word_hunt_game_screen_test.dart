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
import 'package:talvori/features/home/ui/screens/word_hunt_game_screen.dart';

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
    Duration waveDuration = const Duration(milliseconds: 1000),
    int maxWavesPerTarget = 4,
    int maxTargets = 20,
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
          home: WordHuntGameScreen(
            random: random ?? Random(7),
            waveDuration: waveDuration,
            maxWavesPerTarget: maxWavesPerTarget,
            maxTargets: maxTargets,
          ),
        ),
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
    await tester.pump();
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

  test('selectWordHuntRoundPairs shuffles and limits to twenty targets', () {
    final pairs = buildWordHuntPairs(manyWords());
    final firstRound = selectWordHuntRoundPairs(
      pairs,
      random: Random(3),
      maxTargets: 10,
    );

    expect(firstRound, hasLength(10));
    expect(
      firstRound.map((pair) => pair.id),
      isNot(pairs.take(10).map((pair) => pair.id)),
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
        'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Wort-Jagd zu spielen.\n\nWähle eine andere Wortquelle oder füge neue Wörter hinzu.',
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
      find.text('Tippe die richtige Bedeutung, sobald sie auftaucht.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-hunt-source-picker')),
      findsOneWidget,
    );
    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-hunt-speed-picker')),
      findsOneWidget,
    );
    expect(find.text('Geschwindigkeit'), findsOneWidget);
    expect(find.text('Entspannt'), findsOneWidget);
    expect(find.text('Langsam'), findsOneWidget);
    expect(find.text('Mittel'), findsOneWidget);
    expect(find.text('Schnell'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('speed selection defaults to medium and can switch to relaxed', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    final mediumChip = tester.widget<Ink>(
      find
          .descendant(
            of: find.byKey(const ValueKey('word-hunt-speed-medium')),
            matching: find.byType(Ink),
          )
          .first,
    );
    expect(
      (mediumChip.decoration! as BoxDecoration).border!.top.color,
      const Color(0xFFFF7AB6),
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-speed-relaxed')),
    );

    final relaxedChip = tester.widget<Ink>(
      find
          .descendant(
            of: find.byKey(const ValueKey('word-hunt-speed-relaxed')),
            matching: find.byType(Ink),
          )
          .first,
    );
    expect(
      (relaxedChip.decoration! as BoxDecoration).border!.top.color,
      const Color(0xFFFF7AB6),
    );
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
      find.byKey(const ValueKey('word-hunt-change-source-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wortquelle ändern'), findsWidgets);
    expect(find.text('Alle Wörter'), findsWidgets);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Mein Mix'), findsOneWidget);
    expect(find.text('Wörter, die ich kenne'), findsOneWidget);
    expect(find.text('Lernlevel'), findsAtLeastNWidgets(1));
    expect(find.text('Sprachwerkzeuge'), findsAtLeastNWidgets(1));

    await tester.tap(
      find.byKey(
        ValueKey('word-hunt-source-${LocalLearningSource.favorites.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Favoriten'), findsWidgets);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );

    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
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
      find.byKey(const ValueKey('word-hunt-select-world-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt auswählen'), findsWidgets);
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

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-hunt-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('word-hunt-word-world-travel')));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Wortwelt: Travel'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );

    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
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
      find.byKey(const ValueKey('word-hunt-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-hunt-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('word-hunt-word-world-travel')));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortwelt braucht mindestens vier Wörter mit Übersetzung, um Wort-Jagd zu spielen.\n\nWähle eine andere Auswahl oder füge neue Wörter hinzu.',
      ),
      findsOneWidget,
    );
    expect(find.text('Wortwelt: Travel'), findsOneWidget);
  });

  testWidgets('start shows target lives hits round and answer fields', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );

    expect(find.text('Leben: 10'), findsOneWidget);
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

  testWidgets('answer fields change over time', (tester) async {
    await pumpGame(
      tester,
      words: manyWords(),
      waveDuration: const Duration(milliseconds: 10),
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    List<String> visibleAnswerIds() {
      return manyWords()
          .map((word) => word.id)
          .where(
            (id) => find
                .byKey(ValueKey('word-hunt-answer-$id'))
                .evaluate()
                .isNotEmpty,
          )
          .toList();
    }

    final before = visibleAnswerIds();

    await tester.pump(const Duration(milliseconds: 10));
    final after = visibleAnswerIds();

    expect(after, isNot(before));
  });

  testWidgets('correct answer increases local hits and advances', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
        .data!;
    await tester.tap(find.byKey(ValueKey('word-hunt-answer-$prompt')));
    await tester.pump();

    expect(find.text('Treffer!'), findsOneWidget);
    expect(find.text('Treffer: 1'), findsOneWidget);
    expect(find.text('Leben: 10'), findsOneWidget);
    expect(find.text('2 / 4'), findsOneWidget);
  });

  testWidgets('correct answer raises lives only up to ten', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    var prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
        .data!;
    final wrongId = sampleWords()
        .map((word) => word.id)
        .firstWhere((id) => id != prompt);
    await tester.tap(find.byKey(ValueKey('word-hunt-answer-$wrongId')));
    await tester.pump();

    expect(find.text('Leben: 9'), findsOneWidget);

    prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
        .data!;
    await tester.tap(find.byKey(ValueKey('word-hunt-answer-$prompt')));
    await tester.pump();

    expect(find.text('Treffer: 1'), findsOneWidget);
    expect(find.text('Leben: 10'), findsOneWidget);
  });

  testWidgets('wrong answer reduces lives and advances', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    final prompt = tester
        .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
        .data!;
    final wrongId = sampleWords()
        .map((word) => word.id)
        .firstWhere((id) => id != prompt);
    await tester.tap(find.byKey(ValueKey('word-hunt-answer-$wrongId')));
    await tester.pump();

    expect(find.text('Daneben.'), findsOneWidget);
    expect(find.text('Treffer: 0'), findsOneWidget);
    expect(find.text('Leben: 9'), findsOneWidget);
    expect(find.text('2 / 4'), findsOneWidget);
  });

  testWidgets('too slow reduces lives and shows escaped feedback', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: sampleWords(),
      waveDuration: const Duration(milliseconds: 10),
      maxWavesPerTarget: 2,
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Entwischt.'), findsOneWidget);
    expect(find.text('Leben: 9'), findsOneWidget);
    expect(find.text('2 / 4'), findsOneWidget);
  });

  testWidgets('finishes as completed after the last target', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    for (var index = 0; index < sampleWords().length; index += 1) {
      final prompt = tester
          .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
          .data!;
      await tester.tap(find.byKey(ValueKey('word-hunt-answer-$prompt')));
      await tester.pump();
    }

    expect(find.text('Jagd geschafft'), findsOneWidget);
    expect(find.text('Du hast 4 von 4 Wörtern getroffen.'), findsOneWidget);
    expect(find.text('Nochmal jagen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });

  testWidgets('finishes when lives reach zero', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: manyWords(), random: Random(1));

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    for (var index = 0; index < 10; index += 1) {
      final prompt = tester
          .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
          .data!;
      final correctId = manyWords()
          .singleWhere((word) => word.term == prompt)
          .id;
      final wrongId = manyWords()
          .map((word) => word.id)
          .firstWhere(
            (id) =>
                id != correctId &&
                find
                    .byKey(ValueKey('word-hunt-answer-$id'))
                    .evaluate()
                    .isNotEmpty,
          );
      await tester.tap(find.byKey(ValueKey('word-hunt-answer-$wrongId')));
      await tester.pump();
    }

    expect(find.text('Jagd beendet'), findsOneWidget);
    expect(
      find.text(
        'Du hast 0 Wörter getroffen, bevor dir die Leben ausgegangen sind.',
      ),
      findsOneWidget,
    );
    expect(find.text('Nochmal jagen'), findsOneWidget);
  });

  testWidgets('restart starts a new hunt', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords(),
      waveDuration: const Duration(milliseconds: 10),
      maxWavesPerTarget: 2,
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );
    for (var index = 0; index < sampleWords().length; index += 1) {
      final prompt = tester
          .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
          .data!;
      await tester.tap(find.byKey(ValueKey('word-hunt-answer-$prompt')));
      await tester.pump();
    }

    await tester.tap(find.byKey(const ValueKey('word-hunt-restart-button')));
    await tester.pump();

    expect(find.text('Bereit für die Wort-Jagd?'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('restart keeps selected source and speed', (tester) async {
    final favoriteWords = sampleWords()
        .map(
          (word) => LocalWord(
            id: 'favorite-${word.id}',
            categoryId: LocalLearningSource.favorites.id,
            term: 'fav-${word.term}',
            translation: word.translation,
            sourceLanguage: word.sourceLanguage,
            targetLanguage: word.targetLanguage,
            sortOrder: word.sortOrder,
            isArchived: word.isArchived,
            createdAt: word.createdAt,
            updatedAt: word.updatedAt,
          ),
        )
        .toList(growable: false);

    await pumpGame(
      tester,
      words: sampleWords(),
      wordsBySource: {
        LocalLearningSource.allWords: sampleWords(),
        LocalLearningSource.favorites: favoriteWords,
      },
      waveDuration: const Duration(milliseconds: 10),
      maxWavesPerTarget: 2,
    );

    await tester.tap(
      find.byKey(const ValueKey('word-hunt-change-source-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        ValueKey('word-hunt-source-${LocalLearningSource.favorites.id}'),
      ),
    );
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-speed-relaxed')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-hunt-start-button')),
    );

    for (var index = 0; index < favoriteWords.length; index += 1) {
      final prompt = tester
          .widget<Text>(find.byKey(const ValueKey('word-hunt-prompt')))
          .data!;
      final correctId = favoriteWords
          .singleWhere((word) => word.term == prompt)
          .id;
      await tester.tap(find.byKey(ValueKey('word-hunt-answer-$correctId')));
      await tester.pump();
    }

    await tester.tap(find.byKey(const ValueKey('word-hunt-restart-button')));
    await tester.pump();

    expect(find.text('Favoriten'), findsWidgets);
    final relaxedChip = tester.widget<Ink>(
      find
          .descendant(
            of: find.byKey(const ValueKey('word-hunt-speed-relaxed')),
            matching: find.byType(Ink),
          )
          .first,
    );
    expect(
      (relaxedChip.decoration! as BoxDecoration).border!.top.color,
      const Color(0xFFFF7AB6),
    );
  });
}
