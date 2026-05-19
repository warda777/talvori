import 'translation_client.dart';

class FakeTranslationClient implements TranslationClient {
  FakeTranslationClient({
    Map<String, String>? translations,
    Set<String>? failingTerms,
    bool failAll = false,
  }) : _translations = {
         'hello': 'hallo',
         'world': 'welt',
         if (translations != null) ...translations,
       },
       _failingTerms = failingTerms ?? const {},
       _failAll = failAll;

  final Map<String, String> _translations;
  final Set<String> _failingTerms;
  final bool _failAll;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final normalized = request.text.trim().toLowerCase();
    if (_failAll || _failingTerms.contains(normalized)) {
      throw TranslationException('Fake translation failed for $normalized.');
    }
    return TranslationResult(
      translatedText: _translations[normalized] ?? 'fake-$normalized',
    );
  }
}
