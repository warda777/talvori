import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_controller.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_voice_input_service.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';

final impulseInboxRepositoryProvider = Provider<ImpulseInboxRepository>((ref) {
  return SharedPreferencesImpulseInboxRepository();
});

final impulseInboxAiChatClientProvider = Provider<AiChatClient>((ref) {
  try {
    return SupabaseAiChatClient(
      functionCaller: supabaseFunctionCallerFromClient(
        Supabase.instance.client,
      ),
    );
  } on Object {
    return const _UnavailableImpulseAiChatClient();
  }
});

final impulseVoiceMessageServiceProvider = Provider<ImpulseVoiceMessageService>(
  (ref) {
    final service = LocalImpulseVoiceMessageService();
    ref.onDispose(service.dispose);
    return service;
  },
);

@Deprecated('Use impulseVoiceMessageServiceProvider for local voice messages.')
final impulseVoiceInputServiceProvider = Provider<ImpulseVoiceMessageService>((
  ref,
) {
  return ref.watch(impulseVoiceMessageServiceProvider);
});

final impulseInboxControllerProvider =
    StateNotifierProvider<ImpulseInboxController, ImpulseInboxState>((ref) {
      final repository = ref.watch(impulseInboxRepositoryProvider);
      final aiChatClient = ref.watch(impulseInboxAiChatClientProvider);
      final controller = ImpulseInboxController(
        repository: repository,
        aiChatClient: aiChatClient,
        categoryWordSampler: (categoryId) async {
          try {
            final bootstrap = await ref.read(localBootstrapProvider.future);
            final words = await bootstrap.repositoryFactory.wordRepository
                .loadWordsForCategory(categoryId: categoryId);
            return words
                .take(10)
                .map(
                  (word) => {
                    'word': word.term,
                    if (word.translation.trim().isNotEmpty)
                      'translation': word.translation,
                  },
                )
                .toList(growable: false);
          } on Object {
            return const [];
          }
        },
      );
      unawaited(controller.loadChats());
      return controller;
    });

class _UnavailableImpulseAiChatClient implements AiChatClient {
  const _UnavailableImpulseAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('ai_not_configured');
  }
}
