import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_learning_source.dart';
import '../models/local_word_package_definition.dart';
import '../services/shared_text_import_service.dart';
import 'local_bootstrap_provider.dart';
import 'local_words_for_category_provider.dart';
import 'local_words_for_source_provider.dart';

final localWordCountProvider = FutureProvider.family<int, String>((
  ref,
  categoryId,
) async {
  if (categoryId.trim().isEmpty) {
    return 0;
  }

  final source = LocalLearningSource.fromId(categoryId);
  if (source != null) {
    final words = await ref.watch(localWordsForSourceProvider(source).future);
    return words.length;
  }

  if (categoryId.startsWith(localLevelPackageCategoryPrefix) ||
      categoryId.startsWith(localLanguageToolCategoryPrefix)) {
    final words = await ref.watch(
      localWordsForCategoryProvider(categoryId).future,
    );
    return words.length;
  }

  final bootstrapResult = await ref.watch(localBootstrapProvider.future);
  if (categoryId == localMyWordsCategoryId) {
    await bootstrapResult.repositoryFactory.categoryRepository.upsertCategory(
      id: localMyWordsCategoryId,
      name: localMyWordsCategoryLabel,
      description: 'Lokal importierte Wörter.',
      sortOrder: 10000,
      now: DateTime.now(),
    );
  }

  return bootstrapResult.repositoryFactory.wordRepository
      .countWordsForWordWorld(categoryId: categoryId);
});
