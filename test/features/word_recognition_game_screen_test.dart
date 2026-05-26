import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_recognition_game_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
        child: const MaterialApp(home: WordRecognitionGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(
          finder,
          520,
          scrollable: scrollable.first,
        );
      }
    }
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> startGame(WidgetTester tester) async {
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-start-button')),
    );
  }

  test('buildWordRecognitionPairs keeps only complete unique pairs', () {
    final pairs = buildWordRecognitionPairs([
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

  test('buildWordRecognitionQuestion creates one correct answer by id', () {
    final pairs = buildWordRecognitionPairs(sampleWords());
    final question = buildWordRecognitionQuestion(
      pairs: pairs,
      questionIndex: 0,
    );

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
        'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um Wort erkennen zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start screen before answers', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Wort erkennen'), findsWidgets);
    expect(find.text('Wähle die passende Übersetzung.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-recognition-source-picker')),
      findsOneWidget,
    );
    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Alle Wörter'), findsOneWidget);
    expect(find.text('Wörter pro Runde'), findsOneWidget);
    expect(find.text('Gespielt: 0 / 4 Wörter'), findsOneWidget);
    expect(find.text('Diese Runde: 4 Wörter'), findsOneWidget);
    expect(find.text('Fortschritt zurücksetzen'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-recognition-start-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-answer-emergency')),
      findsNothing,
    );
  });

  testWidgets('start opens prompt counter and four answer options', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('word-recognition-hint')), findsOneWidget);
    expect(
      find.text('Welches deutsche Wort passt zu "emergency"?'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-prompt')),
      findsOneWidget,
    );
    expect(find.text('emergency'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-recognition-answer-emergency')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-answer-shelter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-answer-rescue')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-answer-water')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-change-source-button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('word-recognition-select-world-button')),
      findsNothing,
    );
  });

  testWidgets('source sheet switches to favorites and uses source words', (
    tester,
  ) async {
    final favoriteWords = [
      word(id: 'flame', term: 'flame', translation: 'Flamme'),
      word(id: 'spark', term: 'spark', translation: 'Funke'),
      word(id: 'ember', term: 'ember', translation: 'Glut'),
      word(id: 'ash', term: 'ash', translation: 'Asche'),
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
      find.byKey(const ValueKey('word-recognition-change-source-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alle Wörter'), findsWidgets);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Mein Mix'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(
        const ValueKey('word-recognition-source-local-source-favorites'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('Favoriten'), findsOneWidget);
    await startGame(tester);
    expect(find.text('flame'), findsOneWidget);
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
    ];

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {travelCategory.id: travelWords},
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-select-world-button')),
    );
    await tester.pumpAndSettle();

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
      find.byKey(const ValueKey('word-recognition-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('word-recognition-word-world-travel')),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    await tester.scrollUntilVisible(
      find.text('Wortwelt: Travel'),
      520,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Wortwelt: Travel'), findsOneWidget);
    await startGame(tester);
    expect(find.text('train'), findsOneWidget);
  });

  testWidgets('stored word world stays selected after reopening', (
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

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-recognition-word-world-travel')),
      520,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.byKey(const ValueKey('word-recognition-word-world-travel')),
    );
    await tester.pumpAndSettle();

    await pumpGame(
      tester,
      words: sampleWords(),
      categories: [travelCategory],
      wordsByCategory: {travelCategory.id: travelWords},
    );

    expect(find.text('Wortwelt: Travel'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-recognition-answer-train')),
      findsNothing,
    );
  });

  testWidgets('correct answer is accepted', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-answer-emergency')),
    );

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Passende Übersetzung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.text('Nächste Frage'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback and correct answer', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-answer-shelter')),
    );

    expect(find.text('Nicht ganz.'), findsOneWidget);
    expect(find.text('Passende Übersetzung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
  });

  testWidgets('reveal shows the correct answer', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-reveal-button')),
    );

    expect(find.text('Aufgelöst.'), findsOneWidget);
    expect(find.text('Passende Übersetzung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
    expect(find.text('Nächste Frage'), findsOneWidget);
  });

  testWidgets('next question advances to the next prompt', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-answer-emergency')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('word-recognition-next-button')),
    );

    await tester.scrollUntilVisible(
      find.text('2 / 4'),
      -520,
      scrollable: find.byType(Scrollable).first,
    );
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
    await startGame(tester);

    for (final id in ['emergency', 'shelter', 'rescue', 'water']) {
      await tapVisible(
        tester,
        find.byKey(ValueKey('word-recognition-answer-$id')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('word-recognition-next-button')),
      );
    }

    expect(find.text('Runde beendet'), findsOneWidget);
    expect(
      find.text('Du hast 4 von 4 Wörtern richtig erkannt.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
