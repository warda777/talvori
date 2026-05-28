import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'category_word_suggestion.dart';

final categoryWordSuggestionServiceProvider =
    Provider<CategoryWordSuggestionService>((ref) {
      return CategoryWordSuggestionService(
        aiChatClient: ref.watch(impulseInboxAiChatClientProvider),
      );
    });

class CategoryWordSuggestionService {
  const CategoryWordSuggestionService({required AiChatClient aiChatClient})
    : _aiChatClient = aiChatClient;

  final AiChatClient _aiChatClient;

  Future<List<CategoryWordSuggestion>> suggestWords({
    required String categoryName,
    required List<LocalWord> existingWords,
    int limit = 10,
  }) async {
    final existingTerms = existingWords
        .map((word) => word.term.trim())
        .where((term) => term.isNotEmpty)
        .take(80)
        .toList(growable: false);
    final result = await _aiChatClient.sendMessage(
      AiChatRequest(
        language: 'DE',
        message:
            'Schlage $limit passende englische Vokabeln für die Kategorie '
            '"$categoryName" vor. Antworte ausschließlich als JSON-Array mit '
            'Objekten: term, translation, exampleSentence. Keine Markdown.'
            'Bereits vorhandene Wörter nicht wiederholen.',
        context: {
          'mode': 'category_word_suggestions_mvp',
          'categoryName': categoryName,
          'existingTerms': existingTerms,
          'limit': limit,
        },
      ),
    );

    final decoded = jsonDecode(_stripJsonFence(result.reply));
    if (decoded is! List) {
      throw const AiChatException('suggestions_not_a_list');
    }

    final existingNormalized = existingWords
        .map((word) => _normalize(word.term))
        .where((term) => term.isNotEmpty)
        .toSet();
    final seen = <String>{};
    final suggestions = <CategoryWordSuggestion>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final term = item['term']?.toString().trim() ?? '';
      final translation = item['translation']?.toString().trim() ?? '';
      final normalized = _normalize(term);
      if (term.isEmpty || translation.isEmpty) continue;
      if (existingNormalized.contains(normalized) || !seen.add(normalized)) {
        continue;
      }
      suggestions.add(
        CategoryWordSuggestion(
          term: term,
          translation: translation,
          exampleSentence: item['exampleSentence']?.toString().trim(),
        ),
      );
      if (suggestions.length >= limit) break;
    }

    return List<CategoryWordSuggestion>.unmodifiable(suggestions);
  }

  String _stripJsonFence(String value) {
    return value
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
