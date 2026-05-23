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

LocalWord arcadeTestWord({
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

LocalCategory arcadeTestCategory(String id, String name) {
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

List<LocalWord> arcadeTestWords() {
  return [
    arcadeTestWord(id: 'travel', term: 'travel', translation: 'reisen, fahren'),
    arcadeTestWord(id: 'ticket', term: 'ticket', translation: 'Fahrkarte'),
    arcadeTestWord(id: 'airport', term: 'airport', translation: 'Flughafen'),
    arcadeTestWord(id: 'hotel', term: 'hotel', translation: 'Hotel'),
    arcadeTestWord(id: 'train', term: 'train', translation: 'Zug'),
    arcadeTestWord(id: 'water', term: 'water', translation: 'Wasser'),
  ];
}

Future<void> pumpArcadeGame(
  WidgetTester tester,
  Widget screen, {
  AiChatClient? aiClient,
}) async {
  SharedPreferences.setMockInitialValues({});
  ArcadeFakeAiChatClient.lastContext = null;
  ArcadeFakeAiChatClient.lastSynonymWord = null;
  ArcadeFakeWordPronunciationService.lastSpokenWord = null;
  ArcadeFakeWordPronunciationService.spokenWords = <String>[];
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final allWords = arcadeTestWords();
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
        localCategoriesProvider.overrideWith(
          (ref) async => [arcadeTestCategory('seed-category-travel', 'Travel')],
        ),
        wordGameAiClientProvider.overrideWithValue(
          aiClient ?? const ArcadeFakeAiChatClient(),
        ),
        wordPronunciationServiceProvider.overrideWithValue(
          ArcadeFakeWordPronunciationService(),
        ),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));
}

Future<void> startArcadeGame(WidgetTester tester, String gameId) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey('$gameId-start-button')),
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('$gameId-start-button')));
  await tester.pump();
}

class ArcadeFakeAiChatClient implements AiChatClient {
  const ArcadeFakeAiChatClient();

  static Map<dynamic, dynamic>? lastContext;
  static String? lastSynonymWord;

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

class ArcadeFailingAiChatClient implements AiChatClient {
  const ArcadeFailingAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('test_failure');
  }
}

class ArcadeFakeWordPronunciationService implements WordPronunciationService {
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
