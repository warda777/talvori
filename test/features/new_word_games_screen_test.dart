import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_service.dart';
import 'package:talvori/features/home/application/word_game_ai_provider.dart';
import 'package:talvori/features/home/ui/screens/audio_catch_game_screen.dart';
import 'package:talvori/features/home/ui/screens/odd_word_game_screen.dart';
import 'package:talvori/features/home/ui/screens/syllable_rain_game_screen.dart';
import 'package:talvori/features/home/ui/screens/synonym_riddle_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_game_arcade_screen.dart';
import 'package:talvori/features/home/ui/screens/word_path_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_search_game_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _FakeAiChatClient.lastSynonymWord = null;
    _FakeAiChatClient.lastContext = null;
    _FakeWordPronunciationService.lastSpokenWord = null;
    _FakeWordPronunciationService.spokenWords = <String>[];
  });

  LocalWord word({
    required String id,
    required String term,
    required String translation,
    String categoryId = 'seed-category-travel',
  }) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalWord(
      id: id,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocalCategory category(String id, String name) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  final categories = [
    category('seed-category-travel', 'Travel'),
    category('seed-category-basics', 'Health & Fitness'),
  ];

  List<LocalWord> words() {
    return [
      word(id: 'travel', term: 'travel', translation: 'reisen, fahren'),
      word(id: 'ticket', term: 'ticket', translation: 'Fahrkarte'),
      word(id: 'airport', term: 'airport', translation: 'Flughafen'),
      word(id: 'hotel', term: 'hotel', translation: 'Hotel'),
      word(id: 'train', term: 'train', translation: 'Zug'),
      word(id: 'water', term: 'water', translation: 'Wasser'),
      word(
        id: 'pulse',
        term: 'pulse',
        translation: 'Puls',
        categoryId: 'seed-category-basics',
      ),
      word(
        id: 'sleep',
        term: 'sleep',
        translation: 'Schlaf',
        categoryId: 'seed-category-basics',
      ),
      word(
        id: 'heart',
        term: 'heart',
        translation: 'Herz',
        categoryId: 'seed-category-basics',
      ),
    ];
  }

  Future<void> pumpGame(
    WidgetTester tester,
    Widget screen, {
    AiChatClient? aiClient,
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final allWords = words();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return allWords;
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return allWords
                .where((word) => word.categoryId == categoryId)
                .toList(growable: false);
          }),
          localCategoriesProvider.overrideWith((ref) async => categories),
          wordGameAiClientProvider.overrideWithValue(
            aiClient ?? const _FakeAiChatClient(),
          ),
          wordPronunciationServiceProvider.overrideWithValue(
            _FakeWordPronunciationService(),
          ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> start(WidgetTester tester, String gameId) async {
    await tester.scrollUntilVisible(
      find.byKey(ValueKey('$gameId-start-button')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('$gameId-start-button')));
    await tester.pump();
  }

  test('splits words into stable two-part chunks', () {
    expect(splitArcadeWordParts('travel'), ['tra', 'vel']);
  });

  testWidgets('Silben-Regen starts with picker and falling field', (
    tester,
  ) async {
    await pumpGame(tester, const SyllableRainGameScreen());

    expect(find.text('Silben-Regen'), findsWidgets);
    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Wörter pro Runde'), findsOneWidget);

    await start(tester, 'syllable-rain');
    await tester.pump();

    expect(find.byKey(const ValueKey('syllable-rain-field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('syllable-rain-bubble-0')),
      findsOneWidget,
    );
  });

  testWidgets('Hör-Fang starts and accepts the heard word card', (
    tester,
  ) async {
    await pumpGame(tester, const AudioCatchGameScreen());

    expect(find.text('Hör-Fang'), findsWidgets);
    expect(find.text('Geschwindigkeit'), findsOneWidget);

    await start(tester, 'audio-catch');
    await tester.pump();
    final heardWord = _FakeWordPronunciationService.lastSpokenWord;
    expect(heardWord, isNotNull);
    await tester.tap(
      find
          .ancestor(of: find.text(heardWord!), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Gefangen'), findsOneWidget);
  });

  testWidgets('Hör-Fang cards keep moving and missed target advances', (
    tester,
  ) async {
    await pumpGame(tester, const AudioCatchGameScreen());

    await start(tester, 'audio-catch');
    await tester.pump();
    final card = find.byKey(const ValueKey('arcade-answer-0'));
    final topBefore = tester.getTopLeft(card).dy;

    await tester.pump(const Duration(milliseconds: 650));
    final topAfter = tester.getTopLeft(card).dy;

    expect(topAfter, greaterThan(topBefore));
    expect(_FakeWordPronunciationService.spokenWords.length, 1);

    await tester.pump(const Duration(milliseconds: 5600));

    expect(find.text('Verpasst: 1'), findsOneWidget);
    expect(_FakeWordPronunciationService.spokenWords.length, greaterThan(1));
  });

  testWidgets('Hör-Fang shows feedback in the title above the play field', (
    tester,
  ) async {
    await pumpGame(tester, const AudioCatchGameScreen());

    await start(tester, 'audio-catch');
    await tester.pump(const Duration(milliseconds: 5600));

    final fieldTop = tester
        .getTopLeft(find.byKey(const ValueKey('audio-catch-field')))
        .dy;
    final feedbackTop = tester.getTopLeft(find.text('Verpasst')).dy;

    expect(feedbackTop, lessThan(fieldTop));
    expect(find.text('Verpasst: 1'), findsOneWidget);
  });

  testWidgets('Gegenwort shows KI hint and recognizes the outsider', (
    tester,
  ) async {
    await pumpGame(tester, const OddWordGameScreen());

    expect(find.text('Gegenwort'), findsWidgets);
    expect(find.text('Anderswort'), findsNothing);
    expect(find.textContaining('KI-Spiel'), findsWidgets);
    expect(find.text('Sprachen'), findsOneWidget);
    expect(find.text('Englisch → Deutsch'), findsOneWidget);
    expect(find.text('Deutsch → Englisch'), findsOneWidget);
    expect(find.text('Englisch → Englisch'), findsOneWidget);
    expect(find.text('Deutsch → Deutsch'), findsNothing);
    expect(find.byKey(const ValueKey('arcade-language-swap')), findsOneWidget);
    await start(tester, 'odd-word');
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(of: find.text('mountain'), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Richtig'), findsOneWidget);
  });

  testWidgets('Gegenwort passes selected language pair to KI request', (
    tester,
  ) async {
    await pumpGame(tester, const OddWordGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-en-en')));
    await tester.pump();

    expect(find.byKey(const ValueKey('arcade-language-swap')), findsNothing);
    await start(tester, 'odd-word');
    await tester.pumpAndSettle();

    expect(
      _FakeAiChatClient.lastContext?['languagePair'],
      'Englisch → Englisch',
    );
    expect(_FakeAiChatClient.lastContext?['sourceLanguage'], 'en');
    expect(_FakeAiChatClient.lastContext?['answerLanguage'], 'en');
    expect(find.text('Deutsch → Deutsch'), findsNothing);
  });

  testWidgets('Gegenwort swaps language direction to Deutsch Englisch', (
    tester,
  ) async {
    await pumpGame(tester, const OddWordGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-swap')));
    await tester.pump();
    await start(tester, 'odd-word');
    await tester.pumpAndSettle();

    expect(
      _FakeAiChatClient.lastContext?['languagePair'],
      'Deutsch → Englisch',
    );
    expect(_FakeAiChatClient.lastContext?['sourceLanguage'], 'de');
    expect(_FakeAiChatClient.lastContext?['answerLanguage'], 'en');
  });

  testWidgets('Gegenwort shows stable KI error state', (tester) async {
    await pumpGame(
      tester,
      const OddWordGameScreen(),
      aiClient: const _FailingAiChatClient(),
    );

    await start(tester, 'odd-word');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('KI-Spiel momentan nicht verfügbar'),
      findsWidgets,
    );
  });

  testWidgets('Wortpfad shows a hidden-word board', (tester) async {
    await pumpGame(tester, const WordPathGameScreen());

    await start(tester, 'word-path');

    expect(find.byKey(const ValueKey('word-path-board')), findsOneWidget);
    expect(find.text('Tippe Buchstaben in einer Zeile an.'), findsOneWidget);
    expect(find.text('Suche: travel'), findsNothing);
  });

  testWidgets('Wortsuche finds the hidden word by tapping letters', (
    tester,
  ) async {
    await pumpGame(tester, const WordSearchGameScreen());

    await start(tester, 'word-search');

    expect(find.byKey(const ValueKey('word-search-board')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('word-search-box-progress')),
      findsOneWidget,
    );
  });

  testWidgets('Synonym-Rätsel accepts the matching word', (tester) async {
    await pumpGame(tester, const SynonymRiddleGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-en-en')));
    await tester.pump();
    await start(tester, 'synonym-riddle');
    await tester.pumpAndSettle();

    expect(find.text('reisen, fahren, unterwegs sein'), findsOneWidget);
    final targetWord = _FakeAiChatClient.lastSynonymWord;
    expect(targetWord, isNotNull);
    await tester.tap(
      find
          .ancestor(of: find.text(targetWord!), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Richtig'), findsOneWidget);
  });

  testWidgets('Synonym-Rätsel shows language selection', (tester) async {
    await pumpGame(tester, const SynonymRiddleGameScreen());

    expect(find.text('Sprachen'), findsOneWidget);
    expect(find.text('Englisch → Deutsch'), findsOneWidget);
    expect(find.text('Deutsch → Englisch'), findsOneWidget);
    expect(find.text('Englisch → Englisch'), findsOneWidget);
    expect(find.text('Deutsch → Deutsch'), findsNothing);
  });

  testWidgets('new games support Travel wordworld selection', (tester) async {
    await pumpGame(tester, const WordPathGameScreen());

    await tester.tap(
      find.byKey(const ValueKey('word-path-select-world-button')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Travel'));
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt: Travel'), findsOneWidget);
  });

  testWidgets('Synonym-Rätsel shows KI error state when generation fails', (
    tester,
  ) async {
    await pumpGame(
      tester,
      const SynonymRiddleGameScreen(),
      aiClient: const _FailingAiChatClient(),
    );

    await start(tester, 'synonym-riddle');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('KI-Spiel momentan nicht verfügbar'),
      findsWidgets,
    );
  });
}

class _FakeAiChatClient implements AiChatClient {
  const _FakeAiChatClient();

  static String? lastSynonymWord;
  static Map<dynamic, dynamic>? lastContext;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    final context = request.context;
    if (context is Map) lastContext = context;
    if (context is Map && context['game'] == 'gegenwort') {
      return const AiChatResult(
        reply: '{"group":["hospital","patient","medicine"],"odd":"mountain"}',
      );
    }
    if (context is Map && context['game'] == 'synonym-riddle') {
      lastSynonymWord = context['word'] as String?;
      return const AiChatResult(reply: 'reisen, fahren, unterwegs sein');
    }
    return const AiChatResult(reply: 'Hinweis');
  }
}

class _FailingAiChatClient implements AiChatClient {
  const _FailingAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('test_failure');
  }
}

class _FakeWordPronunciationService implements WordPronunciationService {
  static String? lastSpokenWord;
  static List<String> spokenWords = <String>[];

  @override
  Future<WordPronunciationResult> speakWord(
    String word, {
    String? languageCode,
  }) async {
    lastSpokenWord = word;
    spokenWords.add(word);
    return const WordPronunciationResult(WordPronunciationStatus.spoken);
  }

  @override
  Future<void> stop() async {}
}
