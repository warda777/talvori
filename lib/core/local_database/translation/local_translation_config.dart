import 'package:http/http.dart' as http;

import 'deepl_translation_client.dart';
import 'fake_translation_client.dart';
import 'supabase_translation_client.dart';
import 'translation_client.dart';

enum LocalTranslationClientMode { fake, deepl, supabase }

class LocalTranslationConfig {
  const LocalTranslationConfig({
    required this.mode,
    this.apiKey,
    this.baseUri,
    this.targetLanguage = defaultTargetLanguage,
    this.sourceLanguage,
  });

  static const defaultTargetLanguage = 'DE';
  static const defaultConfig = LocalTranslationConfig.fake();

  const LocalTranslationConfig.fake()
    : mode = LocalTranslationClientMode.fake,
      apiKey = null,
      baseUri = null,
      targetLanguage = defaultTargetLanguage,
      sourceLanguage = null;

  const LocalTranslationConfig.deepl({
    required this.apiKey,
    this.baseUri,
    this.targetLanguage = defaultTargetLanguage,
    this.sourceLanguage,
  }) : mode = LocalTranslationClientMode.deepl,
       assert(apiKey != null);

  const LocalTranslationConfig.supabase({
    this.targetLanguage = defaultTargetLanguage,
    this.sourceLanguage,
  }) : mode = LocalTranslationClientMode.supabase,
       apiKey = null,
       baseUri = null;

  const LocalTranslationConfig.developmentSupabase({
    this.targetLanguage = defaultTargetLanguage,
    this.sourceLanguage,
  }) : mode = LocalTranslationClientMode.supabase,
       apiKey = null,
       baseUri = null;

  final LocalTranslationClientMode mode;
  final String? apiKey;
  final Uri? baseUri;
  final String targetLanguage;
  final String? sourceLanguage;

  String get resolvedTargetLanguage {
    final normalized = targetLanguage.trim().toUpperCase();
    return normalized.isEmpty ? defaultTargetLanguage : normalized;
  }

  String? get resolvedSourceLanguage {
    final normalized = sourceLanguage?.trim().toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  bool get hasValidDeepLConfig {
    return mode == LocalTranslationClientMode.deepl &&
        apiKey != null &&
        apiKey!.trim().isNotEmpty &&
        resolvedTargetLanguage.isNotEmpty;
  }

  bool get wantsSupabase {
    return mode == LocalTranslationClientMode.supabase &&
        resolvedTargetLanguage.isNotEmpty;
  }
}

class LocalTranslationClientFactory {
  const LocalTranslationClientFactory({
    http.Client? httpClient,
    SupabaseFunctionCaller? supabaseFunctionCaller,
  }) : _httpClient = httpClient,
       _supabaseFunctionCaller = supabaseFunctionCaller;

  final http.Client? _httpClient;
  final SupabaseFunctionCaller? _supabaseFunctionCaller;

  TranslationClient create(LocalTranslationConfig config) {
    if (config.hasValidDeepLConfig) {
      return DeepLTranslationClient(
        apiKey: config.apiKey!,
        baseUri: config.baseUri,
        httpClient: _httpClient,
      );
    }
    if (config.wantsSupabase && _supabaseFunctionCaller != null) {
      return SupabaseTranslationClient(functionCaller: _supabaseFunctionCaller);
    }

    return FakeTranslationClient();
  }
}

TranslationClient buildDevelopmentSupabaseTranslationClient({
  required SupabaseFunctionCaller functionCaller,
}) {
  return LocalTranslationClientFactory(
    supabaseFunctionCaller: functionCaller,
  ).create(const LocalTranslationConfig.developmentSupabase());
}
