import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/features/words/application/category_vocabulary/category_word_suggestion_service.dart';

void main() {
  test('category word suggestions parse json and filter duplicates', () async {
    final service = CategoryWordSuggestionService(
      aiChatClient: _FakeAiChatClient(
        reply: '''
[
  {"term":"journey","translation":"Reise"},
  {"term":"ticket","translation":"Ticket"},
  {"term":"journey","translation":"Reise"}
]
''',
      ),
    );

    final suggestions = await service.suggestWords(
      categoryName: 'Travel',
      existingWords: [
        _word(id: 'word-ticket', term: 'ticket', translation: 'Ticket'),
      ],
    );

    expect(suggestions, hasLength(1));
    expect(suggestions.single.term, 'journey');
  });

  test('category word suggestions do not run without explicit call', () {
    final client = _FakeAiChatClient(reply: '[]');

    CategoryWordSuggestionService(aiChatClient: client);

    expect(client.calls, 0);
  });
}

LocalWord _word({
  required String id,
  required String term,
  required String translation,
}) {
  final now = DateTime(2026, 1, 1);
  return LocalWord(
    id: id,
    categoryId: 'category-travel',
    term: term,
    translation: translation,
    sortOrder: 0,
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeAiChatClient implements AiChatClient {
  _FakeAiChatClient({required this.reply});

  final String reply;
  int calls = 0;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    calls += 1;
    return AiChatResult(reply: reply);
  }
}
