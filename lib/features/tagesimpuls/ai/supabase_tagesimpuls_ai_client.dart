import 'tagesimpuls_ai_client.dart';

typedef TagesimpulsFunctionCaller =
    Future<Map<String, Object?>> Function(
      String functionName,
      Map<String, Object?> payload,
    );

class SupabaseTagesimpulsAiClient implements TagesimpulsAiClient {
  const SupabaseTagesimpulsAiClient({
    required TagesimpulsFunctionCaller functionCaller,
    this.functionName = 'generate-daily-impulses',
  }) : _functionCaller = functionCaller;

  final TagesimpulsFunctionCaller _functionCaller;
  final String functionName;

  @override
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  ) async {
    if (request.words.isEmpty) {
      throw const TagesimpulsAiException('words_required');
    }
    if (request.count < 1 || request.count > 5) {
      throw const TagesimpulsAiException('invalid_count');
    }

    final payload = <String, Object?>{
      'words': [for (final word in request.words) word.toJson()],
      'count': request.count,
      'language': request.language,
      'style': request.style,
    };

    late final Map<String, Object?> response;
    try {
      response = await _functionCaller(functionName, payload);
    } on Object catch (error) {
      throw TagesimpulsAiException('function_call_failed: $error');
    }

    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      throw TagesimpulsAiException(error.trim());
    }

    final rawImpulses = response['impulses'];
    if (rawImpulses is! List) {
      throw const TagesimpulsAiException('ai_invalid_response');
    }

    final impulses = rawImpulses
        .map(_parseImpulse)
        .whereType<TagesimpulsGeneratedImpulse>()
        .toList(growable: false);
    if (impulses.isEmpty) {
      throw const TagesimpulsAiException('ai_invalid_response');
    }

    return TagesimpulsGenerateResult(impulses: impulses);
  }

  TagesimpulsGeneratedImpulse? _parseImpulse(Object? raw) {
    if (raw is! Map) return null;

    final slot = raw['slot'];
    final message = raw['message'];
    final usedWords = raw['usedWords'];
    if (message is! String || message.trim().isEmpty) return null;

    return TagesimpulsGeneratedImpulse(
      slot: slot is String && slot.trim().isNotEmpty ? slot.trim() : 'day',
      message: message.trim(),
      usedWords: usedWords is List
          ? usedWords
                .whereType<String>()
                .map((word) => word.trim())
                .where((word) => word.isNotEmpty)
                .toList(growable: false)
          : const [],
    );
  }
}
