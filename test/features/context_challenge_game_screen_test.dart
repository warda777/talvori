import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/application/word_game_ai_provider.dart';
import 'package:talvori/features/home/ui/screens/context_challenge_game_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _FakeContextAiChatClient.lastContext = null;
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
    ];
  }

  LocalCategory category(String id, String name) {
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

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
    AiChatClient aiClient = const _FakeContextAiChatClient(),
  }) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
          localCategoriesProvider.overrideWith(
            (ref) async => [category('seed-category-travel', 'Travel')],
          ),
          wordGameAiClientProvider.overrideWithValue(aiClient),
        ],
        child: const MaterialApp(home: ContextChallengeGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> startGame(WidgetTester tester) async {
    final startButton = find.byKey(
      const ValueKey('context-challenge-start-button'),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pump();
    await tester.pumpAndSettle();
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
      expect(task.correctAnswerText, 'Notfall');
      expect(task.hintTerm, 'emergency');
      expect(task.hintTranslation, 'Notfall');
      expect(task.answers, hasLength(4));
      expect(task.answers.where((answer) => answer.isCorrect), hasLength(1));
      expect(
        task.answers.singleWhere((answer) => answer.isCorrect).pairId,
        'emergency',
      );
    },
  );

  test('buildContextChallengeHiddenHint reveals letters progressively', () {
    expect(buildContextChallengeHiddenHint('travel', 0), '_ _ _ _ _ _');
    expect(buildContextChallengeHiddenHint('travel', 1), 't _ _ _ _ _');
    expect(buildContextChallengeHiddenHint('travel', 2), 't r _ _ _ _');
    expect(buildContextChallengeHiddenHint('travel', 3), 't r a _ _ _');
  });

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
        'Diese Wortquelle braucht mindestens vier Wörter mit Übersetzung, um die Kontext-Challenge zu starten.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows start card with KI copy', (tester) async {
    await pumpGame(tester, words: sampleWords());

    expect(find.text('Kontext-Challenge'), findsWidgets);
    expect(
      find.text('Dieses KI-Spiel erzeugt kurze Kontextsätze mit Talvori KI.'),
      findsOneWidget,
    );
    expect(find.textContaining('KI-Spiel'), findsWidgets);
    expect(find.text('Challenge starten'), findsOneWidget);
    expect(find.text('Sprachen'), findsOneWidget);
    expect(find.text('Englisch → Deutsch'), findsOneWidget);
    expect(find.text('Deutsch → Englisch'), findsOneWidget);
    expect(find.text('Englisch → Englisch'), findsOneWidget);
    expect(find.text('Deutsch → Deutsch'), findsNothing);
    expect(
      find.byKey(const ValueKey('context-challenge-language-swap')),
      findsOneWidget,
    );
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
    final sentence = tester.widget<Text>(
      find.byKey(const ValueKey('context-challenge-sentence')),
    );
    expect(sentence.data, isNot(contains('emergency')));
    expect(
      find.byKey(const ValueKey('context-challenge-hidden-hint')),
      findsOneWidget,
    );
    expect(find.text('_ _ _ _ _ _ _ _ _'), findsOneWidget);
    expect(find.text('Hinweis: Notfall'), findsNothing);
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

  testWidgets('hidden hint reveals one more letter on every tap', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    final hint = find.byKey(const ValueKey('context-challenge-hidden-hint'));
    expect(find.text('_ _ _ _ _ _ _ _ _'), findsOneWidget);

    await tester.tap(hint);
    await tester.pump();
    expect(find.text('e _ _ _ _ _ _ _ _'), findsOneWidget);

    await tester.tap(hint);
    await tester.pump();
    expect(find.text('e m _ _ _ _ _ _ _'), findsOneWidget);

    await tester.tap(hint);
    await tester.pump();
    expect(find.text('e m e _ _ _ _ _ _'), findsOneWidget);
  });

  testWidgets('correct answer increases local score', (tester) async {
    await pumpGame(tester, words: sampleWords());
    await startGame(tester);

    final correctAnswer = find.byKey(
      const ValueKey('context-challenge-answer-emergency'),
    );
    await tester.ensureVisible(correctAnswer);
    await tester.pump();
    await tester.tap(correctAnswer);
    await tester.pump();

    expect(find.text('Passt in den Kontext!'), findsOneWidget);
    expect(find.text('Richtige Lösung'), findsOneWidget);
    expect(find.text('Notfall'), findsWidgets);
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
    expect(find.text('Notfall'), findsWidgets);
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
    expect(find.text('Notfall'), findsWidgets);
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

  testWidgets('shows marked fallback state when KI fails', (tester) async {
    await pumpGame(
      tester,
      words: sampleWords(),
      aiClient: const _FailingContextAiChatClient(),
    );
    await startGame(tester);

    expect(
      find.text('KI-Kontext momentan nicht verfügbar. Lokale Vorlage aktiv.'),
      findsOneWidget,
    );
    expect(find.textContaining('___'), findsOneWidget);
  });

  testWidgets('passes selected language pair to KI request', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(
      find.byKey(const ValueKey('context-challenge-language-en-en')),
    );
    await tester.pump();
    await startGame(tester);

    expect(
      _FakeContextAiChatClient.lastContext?['languagePair'],
      'Englisch → Englisch',
    );
    expect(_FakeContextAiChatClient.lastContext?['sourceLanguage'], 'en');
    expect(_FakeContextAiChatClient.lastContext?['answerLanguage'], 'en');
    expect(find.text('Deutsch → Deutsch'), findsNothing);
  });

  testWidgets('swaps selected language pair direction for KI request', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(
      find.byKey(const ValueKey('context-challenge-language-swap')),
    );
    await tester.pump();
    await startGame(tester);

    expect(
      _FakeContextAiChatClient.lastContext?['languagePair'],
      'Deutsch → Englisch',
    );
    expect(_FakeContextAiChatClient.lastContext?['sourceLanguage'], 'de');
    expect(_FakeContextAiChatClient.lastContext?['answerLanguage'], 'en');
    expect(_FakeContextAiChatClient.lastContext?['sourceTarget'], 'Notfall');
    expect(find.text('Deutsch → Deutsch'), findsNothing);
  });
}

class _FakeContextAiChatClient implements AiChatClient {
  const _FakeContextAiChatClient();

  static Map<dynamic, dynamic>? lastContext;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    final context = request.context;
    if (context is Map) lastContext = context;
    return const AiChatResult(
      reply: 'Wenn schnelle Hilfe noetig ist, passt ___ in diesen Satz.',
    );
  }
}

class _FailingContextAiChatClient implements AiChatClient {
  const _FailingContextAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('test_failure');
  }
}
