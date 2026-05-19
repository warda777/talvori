import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talvori/core/local_database/translation/deepl_translation_client.dart';
import 'package:talvori/core/local_database/translation/translation_client.dart';

void main() {
  group('DeepLTranslationClient', () {
    test('sends_successful_translate_request_and_maps_response', () async {
      late http.Request capturedRequest;
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'translations': [
                {'text': 'Hallo'},
              ],
            }),
            200,
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          );
        }),
      );

      final result = await client.translate(
        const TranslationRequest(
          text: 'hello',
          sourceLanguage: 'en',
          targetLanguage: 'de',
        ),
      );
      final body = jsonDecode(capturedRequest.body) as Map<String, Object?>;

      expect(result.translatedText, 'Hallo');
      expect(capturedRequest.method, 'POST');
      expect(
        capturedRequest.url.toString(),
        'https://api-free.deepl.com/v2/translate',
      );
      expect(
        capturedRequest.headers[HttpHeaders.authorizationHeader],
        'DeepL-Auth-Key test-key',
      );
      expect(
        capturedRequest.headers[HttpHeaders.contentTypeHeader],
        'application/json',
      );
      expect(body['text'], ['hello']);
      expect(body['source_lang'], 'EN');
      expect(body['target_lang'], 'DE');
    });

    test('supports_custom_base_uri_and_omits_empty_source_language', () async {
      late http.Request capturedRequest;
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        baseUri: Uri.parse('https://api.deepl.com'),
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'translations': [
                {'text': 'World'},
              ],
            }),
            200,
          );
        }),
      );

      final result = await client.translate(
        const TranslationRequest(
          text: 'Welt',
          sourceLanguage: '',
          targetLanguage: 'en',
        ),
      );
      final body = jsonDecode(capturedRequest.body) as Map<String, Object?>;

      expect(result.translatedText, 'World');
      expect(
        capturedRequest.url.toString(),
        'https://api.deepl.com/v2/translate',
      );
      expect(body.containsKey('source_lang'), isFalse);
      expect(body['target_lang'], 'EN');
    });

    test('rejects_empty_api_key', () {
      expect(
        () => DeepLTranslationClient(apiKey: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects_empty_text', () async {
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async => http.Response('{}', 200)),
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: '  ',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(isA<TranslationException>()),
      );
    });

    test('handles_deepl_error_status', () async {
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          return http.Response('unauthorized', 403);
        }),
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'hello',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('403'),
          ),
        ),
      );
    });

    test('handles_invalid_json_response', () async {
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          return http.Response('not-json', 200);
        }),
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'hello',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('not valid JSON'),
          ),
        ),
      );
    });

    test('handles_invalid_response_shape', () async {
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode({'translations': []}), 200);
        }),
      );

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

    test('handles_network_failure', () async {
      final client = DeepLTranslationClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          throw const SocketException('offline');
        }),
      );

      expect(
        () => client.translate(
          const TranslationRequest(
            text: 'hello',
            sourceLanguage: 'en',
            targetLanguage: 'de',
          ),
        ),
        throwsA(
          isA<TranslationException>().having(
            (error) => error.toString(),
            'message',
            contains('DeepL request failed'),
          ),
        ),
      );
    });
  });
}
