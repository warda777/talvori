import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pending_translation_processor.dart';
import '../translation/fake_translation_client.dart';
import '../translation/translation_client.dart';
import 'local_bootstrap_provider.dart';

final translationClientProvider = Provider<TranslationClient>((ref) {
  return FakeTranslationClient();
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
