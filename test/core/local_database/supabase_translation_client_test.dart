import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/translation/supabase_translation_client.dart';
import 'package:talvori/core/local_database/translation/translation_client.dart';

void main() {
  group('SupabaseTranslationClient', () {
    test('maps_successful_function_response_to_translation', () async {
      String? capturedFunctionName;
      Map<String, Object?>? capturedPayload;
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          capturedFunctionName = functionName;
          capturedPayload = payload;
          return {'translation': 'Haus'};
        },
      );

      final result = await client.translate(
        const TranslationRequest(
          text: 'house',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );

      expect(result.translatedText, 'Haus');
      expect(capturedFunctionName, 'translate-word');
      expect(capturedPayload, {
        'text': 'house',
        'sourceLang': 'EN',
        'targetLang': 'DE',
      });
    });

    test('omits_empty_source_language', () async {
      Map<String, Object?>? capturedPayload;
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          capturedPayload = payload;
          return {'translation': 'World'};
        },
      );

      final result = await client.translate(
        const TranslationRequest(
          text: 'Welt',
          sourceLanguage: ' ',
          targetLanguage: 'en',
        ),
      );

      expect(result.translatedText, 'World');
      expect(capturedPayload, {'text': 'Welt', 'targetLang': 'EN'});
    });

    test('handles_function_error_response', () async {
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          return {'error': 'translation_failed'};
        },
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'house',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('translation_failed'),
          ),
        ),
      );
    });

    test('handles_quota_exceeded_response', () async {
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          return {'error': 'quota_exceeded'};
        },
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'house',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('quota_exceeded'),
          ),
        ),
      );
    });

    test('handles_invalid_response_shape', () async {
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          return {'translation': ''};
        },
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'house',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('missing translation'),
          ),
        ),
      );
    });

    test('handles_function_failure', () async {
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          throw const SocketException('offline');
        },
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'house',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('Supabase translation request failed'),
          ),
        ),
      );
    });

    test('rejects_empty_text_and_target_language', () async {
      final client = SupabaseTranslationClient(
        functionCaller: (functionName, payload) async {
          return {'translation': 'ignored'};
        },
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: ' ',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(isA<TranslationException>()),
      );
      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'house',
            sourceLanguage: 'en',
            targetLanguage: ' ',
          ),
        ),
        throwsA(isA<TranslationException>()),
      );
    });
  });
}
