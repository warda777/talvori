import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'translation_client.dart';

class DeepLTranslationClient implements TranslationClient {
  DeepLTranslationClient({
    required String apiKey,
    Uri? baseUri,
    http.Client? httpClient,
  }) : _apiKey = apiKey.trim(),
       _baseUri = baseUri ?? freeApiBaseUri,
       _httpClient = httpClient ?? http.Client() {
    if (_apiKey.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'must not be empty');
    }
  }

  static final Uri freeApiBaseUri = Uri.parse('https://api-free.deepl.com');
  static final Uri proApiBaseUri = Uri.parse('https://api.deepl.com');

  final String _apiKey;
  final Uri _baseUri;
  final http.Client _httpClient;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    final text = request.text.trim();
    if (text.isEmpty) {
      throw const TranslationException('Translation text must not be empty.');
    }

    final uri = _baseUri.resolve('/v2/translate');
    final payload = <String, Object>{
      'text': [text],
      'target_lang': request.targetLanguage.trim().toUpperCase(),
    };
    final sourceLanguage = request.sourceLanguage.trim();
    if (sourceLanguage.isNotEmpty) {
      payload['source_lang'] = sourceLanguage.toUpperCase();
    }

    late final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'DeepL-Auth-Key $_apiKey',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(payload),
      );
    } on Object catch (error) {
      throw TranslationException('DeepL request failed: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TranslationException(
        'DeepL request failed with status ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on Object catch (error) {
      throw TranslationException('DeepL response is not valid JSON: $error');
    }

    if (decoded is! Map<String, Object?>) {
      throw const TranslationException('DeepL response has invalid shape.');
    }
    final translations = decoded['translations'];
    if (translations is! List || translations.isEmpty) {
      throw const TranslationException('DeepL response has no translations.');
    }
    final first = translations.first;
    if (first is! Map<String, Object?>) {
      throw const TranslationException('DeepL translation has invalid shape.');
    }
    final translatedText = first['text'];
    if (translatedText is! String || translatedText.trim().isEmpty) {
      throw const TranslationException('DeepL translation text is missing.');
    }

    return TranslationResult(translatedText: translatedText);
  }
}
