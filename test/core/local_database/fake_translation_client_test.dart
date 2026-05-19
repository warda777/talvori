import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/translation/fake_translation_client.dart';
import 'package:talvori/core/local_database/translation/translation_client.dart';

void main() {
  group('FakeTranslationClient', () {
    test('returns_known_translation', () async {
      final client = FakeTranslationClient();

      final result = await client.translate(
        const TranslationRequest(
          text: 'hello',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );

      expect(result.translatedText, 'hallo');
    });

    test('uses_custom_translation_mapping', () async {
      final client = FakeTranslationClient(translations: {'river': 'fluss'});

      final result = await client.translate(
        const TranslationRequest(
          text: 'River',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );

      expect(result.translatedText, 'fluss');
    });

    test('returns_deterministic_fallback_for_unknown_terms', () async {
      final client = FakeTranslationClient();

      final result = await client.translate(
        const TranslationRequest(
          text: 'unknown',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );

      expect(result.translatedText, 'fake-unknown');
    });

    test('can_simulate_term_failure', () async {
      final client = FakeTranslationClient(failingTerms: {'broken'});

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'broken',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(isA<TranslationException>()),
      );
    });

    test('can_simulate_global_failure', () async {
      final client = FakeTranslationClient(failAll: true);

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'hello',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(isA<TranslationException>()),
      );
    });
  });
}
