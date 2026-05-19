import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/word_repository.dart';
import '../services/pending_translation_processor.dart';
import '../translation/local_translation_config.dart';
import '../translation/supabase_function_caller.dart';
import '../translation/supabase_translation_client.dart';
import '../translation/translation_client.dart';
import 'local_bootstrap_provider.dart';

typedef PendingTranslationRunner =
    Future<PendingTranslationProcessorResult> Function({String? categoryId});
typedef SingleWordTranslationRunner =
    Future<PendingTranslationProcessorResult> Function({
      required String wordId,
    });

final localTranslationConfigProvider = Provider<LocalTranslationConfig>((ref) {
  return localTranslationConfigFromEnvironment();
});

final supabaseTranslationFunctionCallerProvider =
    Provider<SupabaseFunctionCaller?>((ref) {
      try {
        return supabaseFunctionCallerFromClient(Supabase.instance.client);
      } catch (_) {
        return null;
      }
    });

final localTranslationClientFactoryProvider =
    Provider<LocalTranslationClientFactory>((ref) {
      return LocalTranslationClientFactory(
        supabaseFunctionCaller: ref.watch(
          supabaseTranslationFunctionCallerProvider,
        ),
      );
    });

final translationClientProvider = Provider<TranslationClient>((ref) {
  final config = ref.watch(localTranslationConfigProvider);
  final factory = ref.watch(localTranslationClientFactoryProvider);
  return factory.create(config);
});

final pendingTranslationProcessorProvider =
    FutureProvider<PendingTranslationProcessor>((ref) async {
      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;

      return buildLocalTranslationProcessorForConfig(
        wordRepository: repositories.wordRepository,
        config: ref.watch(localTranslationConfigProvider),
        supabaseFunctionCaller: ref.watch(
          supabaseTranslationFunctionCallerProvider,
        ),
      );
    });

final pendingTranslationRunnerProvider =
    FutureProvider<PendingTranslationRunner>((ref) async {
      final processor = await ref.watch(
        pendingTranslationProcessorProvider.future,
      );
      return processor.processPendingTranslations;
    });

final pendingAndFailedTranslationRunnerProvider =
    FutureProvider<PendingTranslationRunner>((ref) async {
      final processor = await ref.watch(
        pendingTranslationProcessorProvider.future,
      );
      return processor.processPendingAndRetryFailedTranslations;
    });

final singleWordTranslationRunnerProvider =
    FutureProvider<SingleWordTranslationRunner>((ref) async {
      final processor = await ref.watch(
        pendingTranslationProcessorProvider.future,
      );
      return processor.processWordTranslation;
    });

PendingTranslationProcessor buildLocalTranslationProcessorForConfig({
  required WordRepository wordRepository,
  required LocalTranslationConfig config,
  SupabaseFunctionCaller? supabaseFunctionCaller,
}) {
  final factory = LocalTranslationClientFactory(
    supabaseFunctionCaller: supabaseFunctionCaller,
  );

  return PendingTranslationProcessor(
    wordRepository: wordRepository,
    translationClient: factory.create(config),
  );
}
