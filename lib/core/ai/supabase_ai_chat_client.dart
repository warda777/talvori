import 'ai_chat_client.dart';

typedef AiChatFunctionCaller =
    Future<Map<String, Object?>> Function(
      String functionName,
      Map<String, Object?> payload,
    );

class SupabaseAiChatClient implements AiChatClient {
  const SupabaseAiChatClient({
    required AiChatFunctionCaller functionCaller,
    this.functionName = 'ai-chat',
  }) : _functionCaller = functionCaller;

  final AiChatFunctionCaller _functionCaller;
  final String functionName;

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    final message = request.message.trim();
    if (message.isEmpty) {
      throw const AiChatException('AI chat message must not be empty.');
    }

    final payload = <String, Object?>{'message': message};
    final language = request.language.trim();
    if (language.isNotEmpty) {
      payload['language'] = language;
    }
    if (request.context != null) {
      payload['context'] = request.context;
    }

    late final Map<String, Object?> response;
    try {
      response = await _functionCaller(functionName, payload);
    } on Object catch (error) {
      throw AiChatException('Supabase AI chat request failed: $error');
    }

    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      throw AiChatException('Supabase AI chat failed: $error');
    }

    final reply = response['reply'];
    if (reply is! String || reply.trim().isEmpty) {
      throw const AiChatException(
        'Supabase AI chat response is missing reply.',
      );
    }

    return AiChatResult(reply: reply);
  }
}
