import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/companion/domain/companion_ai_context.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';

final companionAiServiceProvider = Provider<CompanionAiService>((ref) {
  return CompanionAiService(
    aiChatClient: ref.watch(impulseInboxAiChatClientProvider),
  );
});

class CompanionAiService {
  const CompanionAiService({required AiChatClient aiChatClient})
    : _aiChatClient = aiChatClient;

  final AiChatClient _aiChatClient;

  Future<String> reply({
    required String message,
    required CompanionAiContext context,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const AiChatException('Companion message must not be empty.');
    }

    try {
      final result = await _aiChatClient.sendMessage(
        AiChatRequest(
          message: trimmed,
          language: 'DE',
          context: {
            'mode': 'talvori_companion_home_mvp',
            'style':
                'Kurz, freundlich, leicht frech, hilfreich. Maximal 1-2 Sätze.',
            ...context.toJson(),
          },
        ),
      );
      final reply = _shorten(result.reply);
      if (reply.isNotEmpty) return reply;
    } on Object {
      return _fallbackReply(trimmed, context);
    }

    return _fallbackReply(trimmed, context);
  }

  String _fallbackReply(String message, CompanionAiContext context) {
    final lower = message.toLowerCase();
    if (lower.contains('wort') ||
        lower.contains('wörter') ||
        lower.contains('vokabel')) {
      return context.myWordsCount == 0
          ? 'Starte klein: Speichere ein Wort aus dem Browser, dann bauen wir darauf auf.'
          : 'Such dir ein Wort aus deiner Box und spiel eine kurze Runde damit.';
    }
    if (lower.contains('level') || lower.contains('a1')) {
      return 'Nimm ein kleines Lernlevel-Paket. Eine kurze Runde ist besser als ein riesiger Brocken.';
    }
    if (lower.contains('spiel') || lower.contains('üben')) {
      return 'Probier ein Wortspiel. Fünf Minuten reichen, damit dein Kopf wieder andockt.';
    }
    return 'Gute Frage. Für den MVP gebe ich dir kurz Rückenwind: Wähle ein kleines Paket und starte direkt.';
  }

  String _shorten(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 180) return normalized;
    return '${normalized.substring(0, 177).trimRight()}...';
  }
}
