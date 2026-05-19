import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pending_translation_processor.dart';
import '../translation/local_translation_config.dart';
import '../translation/translation_client.dart';
import 'local_bootstrap_provider.dart';

typedef PendingTranslationRunner =
    Future<PendingTranslationProcessorResult> Function({String? categoryId});

final localTranslationConfigProvider = Provider<LocalTranslationConfig>((ref) {
  return const LocalTranslationConfig.fake();
});

final localTranslationClientFactoryProvider =
    Provider<LocalTranslationClientFactory>((ref) {
      return const LocalTranslationClientFactory();
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

      return PendingTranslationProcessor(
        wordRepository: repositories.wordRepository,
        translationClient: ref.watch(translationClientProvider),
      );
    });

final pendingTranslationRunnerProvider =
    FutureProvider<PendingTranslationRunner>((ref) async {
      final processor = await ref.watch(
        pendingTranslationProcessorProvider.future,
      );
      return processor.processPendingTranslations;
    });
