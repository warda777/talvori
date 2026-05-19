class TranslationRequest {
  const TranslationRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String text;
  final String sourceLanguage;
  final String targetLanguage;
}

class TranslationResult {
  const TranslationResult({required this.translatedText});

  final String translatedText;
}

abstract class TranslationClient {
  Future<TranslationResult> translate(TranslationRequest request);
}

class TranslationException implements Exception {
  const TranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}
