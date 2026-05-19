class AiChatRequest {
  const AiChatRequest({
    required this.message,
    this.context,
    this.language = '',
  });

  final String message;
  final Object? context;
  final String language;
}

class AiChatResult {
  const AiChatResult({required this.reply});

  final String reply;
}

class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => 'AiChatException: $message';
}

abstract class AiChatClient {
  Future<AiChatResult> sendMessage(AiChatRequest request);
}
