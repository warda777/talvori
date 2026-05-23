import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_match_game_screen.dart';

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

  LocalCategory category({required String id, required String name}) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<LocalWord> sampleWords([int count = 8]) {
    const raw = [
      ('emergency', 'emergency', 'Notfall'),
      ('shelter', 'shelter', 'Schutz'),
      ('rescue', 'rescue', 'Rettung'),
      ('water', 'water', 'Wasser'),
      ('flame', 'flame', 'Flamme'),
      ('spark', 'spark', 'Funke'),
      ('ember', 'ember', 'Glut'),
      ('ash', 'ash', 'Asche'),
      ('storm', 'storm', 'Sturm'),
      ('harbor', 'harbor', 'Hafen'),
      ('ticket', 'ticket', 'Ticket'),
      ('train', 'train', 'Zug'),
      ('hotel', 'hotel', 'Hotel'),
      ('map', 'map', 'Karte'),
      ('bridge', 'bridge', 'Brücke'),
      ('market', 'market', 'Markt'),
      ('garden', 'garden', 'Garten'),
    ];
    return [
      for (final entry in raw.take(count))
        word(id: entry.$1, term: entry.$2, translation: entry.$3),
    ];
  }

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
    List<LocalCategory> categories = const <LocalCategory>[],
    Map<String, List<LocalWord>> wordsByCategory =
        const <String, List<LocalWord>>{},
    Map<LocalLearningSource, List<LocalWord>>? wordsBySource,
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
        child: const MaterialApp(home: WordMatchGameScreen()),
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

  Future<void> startGame(WidgetTester tester) async {
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-match-start-button')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> dragFromTo(
    WidgetTester tester, {
    required ValueKey<String> sourceKey,
    required ValueKey<String> targetKey,
  }) async {
    final wordFinder = find.byKey(sourceKey);
    final targetFinder = find.byKey(targetKey);
    await tester.ensureVisible(wordFinder);
    await tester.ensureVisible(targetFinder);
    await tester.pump();
    final start = tester.getCenter(wordFinder);
    final end = tester.getCenter(targetFinder);
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 620));
    await gesture.moveTo(end);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  Future<void> dragPair(WidgetTester tester, String id) async {
    await dragFromTo(
      tester,
      sourceKey: ValueKey('word-match-term-$id'),
      targetKey: ValueKey('word-match-translation-$id'),
    );
  }

  Future<void> dragTranslationPair(WidgetTester tester, String id) async {
    await dragFromTo(
      tester,
      sourceKey: ValueKey('word-match-translation-$id'),
      targetKey: ValueKey('word-match-term-$id'),
    );
  }

  Future<void> dragToWrongPair(
    WidgetTester tester, {
    required String wordId,
    required String targetId,
  }) async {
    await dragFromTo(
      tester,
      sourceKey: ValueKey('word-match-term-$wordId'),
      targetKey: ValueKey('word-match-translation-$targetId'),
    );
  }

  test('buildWordMatchPairs keeps only complete unique pairs', () {
    final pairs = buildWordMatchPairs([
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'duplicate-translation', term: 'single', translation: 'eins'),
      word(id: 'missing-translation', term: 'empty', translation: ''),
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

  testWidgets('shows empty state with fewer than six pairs', (tester) async {
    await pumpGame(tester, words: sampleWords(5));

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortquelle braucht mindestens sechs Wörter mit Übersetzung, um Wort-Match zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('start screen shows source selection with all words default', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Wort-Match'), findsWidgets);
    expect(
      find.text('Ziehe Wörter auf die passende Übersetzung.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-match-source-picker')),
      findsOneWidget,
    );
    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
    expect(find.text('Wortquelle ändern'), findsOneWidget);
    expect(find.text('Wortwelt auswählen'), findsOneWidget);
    expect(find.text('Sound: An'), findsOneWidget);
    expect(find.text('Starten'), findsOneWidget);
  });

  testWidgets('source sheet switches to favorites and uses source words', (
    tester,
  ) async {
    final favoriteWords = [
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'two', term: 'two', translation: 'zwei'),
      word(id: 'three', term: 'three', translation: 'drei'),
      word(id: 'four', term: 'four', translation: 'vier'),
      word(id: 'five', term: 'five', translation: 'fünf'),
      word(id: 'six', term: 'six', translation: 'sechs'),
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      wordsBySource: {
        LocalLearningSource.allWords: sampleWords(),
        LocalLearningSource.favorites: favoriteWords,
      },
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-match-change-source-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Mein Mix'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('word-match-source-local-source-favorites')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favoriten'), findsOneWidget);
    await startGame(tester);
    expect(find.text('one'), findsOneWidget);
    expect(find.text('emergency'), findsNothing);
  });

  testWidgets('word world sheet switches to Travel and uses category words', (
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
      word(
        id: 'bridge',
        term: 'bridge',
        translation: 'Brücke',
        categoryId: travelCategory.id,
      ),
      word(
        id: 'harbor',
        term: 'harbor',
        translation: 'Hafen',
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
      find.byKey(const ValueKey('word-match-select-world-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Music & Entertainment'), findsOneWidget);
    expect(find.text('Top 500 Words'), findsOneWidget);
    expect(find.text('C2'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-match-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('word-match-word-world-travel')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt: Travel'), findsOneWidget);
    await startGame(tester);
    expect(find.text('train'), findsOneWidget);
    expect(find.text('emergency'), findsNothing);
  });

  testWidgets('category with too few pairs shows category empty state', (
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
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {travelCategory.id: travelWords},
    );

    await tester.tap(
      find.byKey(const ValueKey('word-match-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-match-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('word-match-word-world-travel')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortwelt braucht mindestens sechs Wörter mit Übersetzung, um Wort-Match zu spielen.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('sound toggle switches between on and off', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Sound: An'), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-match-sound-toggle')),
    );

    expect(find.text('Sound: Aus'), findsOneWidget);
  });

  testWidgets('start shows draggable word and translation cards', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await startGame(tester);

    expect(find.byKey(const ValueKey('word-match-board')), findsOneWidget);
    expect(find.text('0 / 8 verbunden'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-match-term-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-match-translation-emergency')),
      findsOneWidget,
    );
  });

  testWidgets('translation cards are draggable too', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await dragTranslationPair(tester, 'emergency');

    expect(find.text('Richtig'), findsOneWidget);
    expect(find.text('1 / 8 verbunden', skipOffstage: false), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-match-translation-emergency')),
      findsNothing,
    );
  });

  testWidgets('correct drag and drop resolves pair and replenishes next pair', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords(8));
    await startGame(tester);

    await dragPair(tester, 'emergency');

    expect(find.text('Richtig'), findsOneWidget);
    expect(find.text('1 / 8 verbunden', skipOffstage: false), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-match-term-emergency')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('word-match-term-ember')), findsOneWidget);
  });

  testWidgets('wrong drag and drop keeps pair active', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await dragToWrongPair(tester, wordId: 'emergency', targetId: 'shelter');

    expect(find.text('Falsch'), findsOneWidget);
    expect(find.text('0 / 8 verbunden', skipOffstage: false), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-match-term-emergency')),
      findsOneWidget,
    );
  });

  testWidgets('finishes after all pairs are matched', (tester) async {
    await pumpGame(tester, words: sampleWords(6));
    await startGame(tester);

    for (final id in [
      'emergency',
      'shelter',
      'rescue',
      'water',
      'flame',
      'spark',
    ]) {
      await dragPair(tester, id);
    }

    expect(find.text('Set geschafft'), findsOneWidget);
    expect(find.text('Du hast 6 von 6 Wortpaaren verbunden.'), findsOneWidget);
    expect(find.text('Gleiches Set wiederholen'), findsOneWidget);
    expect(find.text('Neues Set'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });

  testWidgets('same set replay and new set restart the game', (tester) async {
    await pumpGame(tester, words: sampleWords(6));
    await startGame(tester);

    for (final id in [
      'emergency',
      'shelter',
      'rescue',
      'water',
      'flame',
      'spark',
    ]) {
      await dragPair(tester, id);
    }

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-match-replay-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 6 verbunden'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-match-term-emergency')),
      findsOneWidget,
    );

    for (final id in [
      'emergency',
      'shelter',
      'rescue',
      'water',
      'flame',
      'spark',
    ]) {
      await dragPair(tester, id);
    }

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-match-new-set-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 / 6 verbunden'), findsOneWidget);
  });
}
