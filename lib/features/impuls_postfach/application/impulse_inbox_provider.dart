import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';
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

final impulseVoiceInputServiceProvider = Provider<ImpulseVoiceInputService>((
  ref,
) {
  return SpeechToTextImpulseVoiceInputService();
});

final impulseInboxControllerProvider =
    StateNotifierProvider<ImpulseInboxController, ImpulseInboxState>((ref) {
      final repository = ref.watch(impulseInboxRepositoryProvider);
      final aiChatClient = ref.watch(impulseInboxAiChatClientProvider);
      final controller = ImpulseInboxController(
        repository: repository,
        aiChatClient: aiChatClient,
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
