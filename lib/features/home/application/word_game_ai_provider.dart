import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/ai/supabase_ai_chat_client.dart';
import 'package:talvori/core/local_database/translation/supabase_function_caller.dart';

final wordGameAiClientProvider = Provider<AiChatClient>((ref) {
  try {
    return SupabaseAiChatClient(
      functionCaller: supabaseFunctionCallerFromClient(
        Supabase.instance.client,
      ),
    );
  } on Object {
    return const _UnavailableWordGameAiClient();
  }
});

class _UnavailableWordGameAiClient implements AiChatClient {
  const _UnavailableWordGameAiClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('ai_not_configured');
  }
}
