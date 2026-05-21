import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/shared_text_platform_receiver.dart';
import '../models/local_learning_source.dart';
import '../services/incoming_shared_text_import_controller.dart';
import 'local_translation_provider.dart';
import 'local_word_count_provider.dart';
import 'local_words_for_category_provider.dart';
import 'local_words_for_source_provider.dart';
import 'shared_text_import_service_provider.dart';
import '../services/shared_text_import_service.dart';

final sharedTextPlatformReceiverProvider = Provider<SharedTextPlatformReceiver>(
  (ref) {
    return SharedTextPlatformReceiver();
  },
);

final incomingSharedTextImportControllerProvider =
    FutureProvider<IncomingSharedTextImportController>((ref) async {
      final importService = await ref.watch(
        sharedTextImportServiceProvider.future,
      );
      final translateWord = await ref.watch(
        singleWordTranslationRunnerProvider.future,
      );
      return IncomingSharedTextImportController(
        receiver: ref.watch(sharedTextPlatformReceiverProvider),
        importText: importService.importRawText,
        translateWord: translateWord,
        onTranslationSettled: (wordId, result) {
          ref
            ..invalidate(localWordsForCategoryProvider(localMyWordsCategoryId))
            ..invalidate(localWordCountProvider(localMyWordsCategoryId));
          for (final source in LocalLearningSource.values) {
            ref.invalidate(localWordsForSourceProvider(source));
          }
        },
      );
    });
