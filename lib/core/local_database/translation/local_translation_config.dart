import 'fake_translation_client.dart';
import 'supabase_translation_client.dart';
import 'translation_client.dart';

enum LocalTranslationClientMode { fake, deepl, supabase }

const talvoriTranslationModeDefineName = 'TALVORI_TRANSLATION_MODE';
const talvoriTranslationModeDefine = String.fromEnvironment(
  talvoriTranslationModeDefineName,
);

LocalTranslationConfig localTranslationConfigFromEnvironment({
  String mode = talvoriTranslationModeDefine,
}) {
  final normalizedMode = mode.trim().toLowerCase();
  if (normalizedMode.isEmpty || normalizedMode == 'supabase') {
    return const LocalTranslationConfig.developmentSupabase();
  }
  if (normalizedMode == 'fake') {
    return const LocalTranslationConfig.fake();
  }

  return LocalTranslationConfig.defaultConfig;
}

class LocalTranslationConfig {
  const LocalTranslationConfig({
    required this.mode,
    this.apiKey,
    this.baseUri,
    this.targetLanguage = defaultTargetLanguage,
    this.sourceLanguage,
  });

  static const defaultTargetLanguage = 'DE';
  static const defaultConfig = LocalTranslationConfig.supabase();

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
    return false;
  }

  bool get wantsSupabase {
    return mode == LocalTranslationClientMode.supabase &&
        resolvedTargetLanguage.isNotEmpty;
  }
}

class LocalTranslationClientFactory {
  const LocalTranslationClientFactory({
    SupabaseFunctionCaller? supabaseFunctionCaller,
  }) : _supabaseFunctionCaller = supabaseFunctionCaller;

  final SupabaseFunctionCaller? _supabaseFunctionCaller;

  TranslationClient create(LocalTranslationConfig config) {
    if (config.wantsSupabase && _supabaseFunctionCaller != null) {
      return SupabaseTranslationClient(functionCaller: _supabaseFunctionCaller);
    }
    if (config.wantsSupabase) {
      return const UnavailableTranslationClient(
        'Supabase translate-word client is not available.',
      );
    }
    if (config.mode == LocalTranslationClientMode.fake) {
      return FakeTranslationClient();
    }

    return const UnavailableTranslationClient(
      'No production translation client is configured.',
    );
  }
}

class UnavailableTranslationClient implements TranslationClient {
  const UnavailableTranslationClient(this.message);

  final String message;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    throw TranslationException(message);
  }
}

TranslationClient buildDevelopmentSupabaseTranslationClient({
  required SupabaseFunctionCaller functionCaller,
}) {
  return LocalTranslationClientFactory(
    supabaseFunctionCaller: functionCaller,
  ).create(const LocalTranslationConfig.developmentSupabase());
}
