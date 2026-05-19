import 'translation_client.dart';

typedef SupabaseFunctionCaller =
    Future<Map<String, Object?>> Function(
      String functionName,
      Map<String, Object?> payload,
    );

class SupabaseTranslationClient implements TranslationClient {
  const SupabaseTranslationClient({
    required SupabaseFunctionCaller functionCaller,
    this.functionName = 'translate-word',
  }) : _functionCaller = functionCaller;

  final SupabaseFunctionCaller _functionCaller;
  final String functionName;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final text = request.text.trim();
    if (text.isEmpty) {
      throw const TranslationException('Translation text must not be empty.');
    }

    final targetLanguage = request.targetLanguage.trim().toUpperCase();
    if (targetLanguage.isEmpty) {
      throw const TranslationException('Target language must not be empty.');
    }

    final payload = <String, Object?>{
      'text': text,
      'targetLang': targetLanguage,
    };
    final sourceLanguage = request.sourceLanguage.trim();
    if (sourceLanguage.isNotEmpty) {
      payload['sourceLang'] = sourceLanguage.toUpperCase();
    }

    late final Map<String, Object?> response;
    try {
      response = await _functionCaller(functionName, payload);
    } on Object catch (error) {
      throw TranslationException('Supabase translation request failed: $error');
    }

    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      throw TranslationException('Supabase translation failed: $error');
    }

    final translation = response['translation'];
    if (translation is! String || translation.trim().isEmpty) {
      throw const TranslationException(
        'Supabase translation response is missing translation.',
      );
    }

    return TranslationResult(translatedText: translation);
  }
}
