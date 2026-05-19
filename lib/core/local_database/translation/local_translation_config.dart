import 'package:http/http.dart' as http;

import 'deepl_translation_client.dart';
import 'fake_translation_client.dart';
import 'translation_client.dart';

enum LocalTranslationClientMode { fake, deepl }

class LocalTranslationConfig {
  const LocalTranslationConfig({required this.mode, this.apiKey, this.baseUri});

  const LocalTranslationConfig.fake()
    : mode = LocalTranslationClientMode.fake,
      apiKey = null,
      baseUri = null;

  const LocalTranslationConfig.deepl({required this.apiKey, this.baseUri})
    : mode = LocalTranslationClientMode.deepl,
      assert(apiKey != null);

  final LocalTranslationClientMode mode;
  final String? apiKey;
  final Uri? baseUri;

  bool get hasValidDeepLConfig {
    return mode == LocalTranslationClientMode.deepl &&
        apiKey != null &&
        apiKey!.trim().isNotEmpty;
  }
}

class LocalTranslationClientFactory {
  const LocalTranslationClientFactory({http.Client? httpClient})
    : _httpClient = httpClient;

  final http.Client? _httpClient;

  TranslationClient create(LocalTranslationConfig config) {
    if (config.hasValidDeepLConfig) {
      return DeepLTranslationClient(
        apiKey: config.apiKey!,
        baseUri: config.baseUri,
        httpClient: _httpClient,
      );
    }

    return FakeTranslationClient();
  }
}
