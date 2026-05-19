import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_text_import_service.dart';
import 'local_bootstrap_provider.dart';

final localWordCountProvider = FutureProvider.family<int, String>((
  ref,
  categoryId,
) async {
  if (categoryId.trim().isEmpty) {
    return 0;
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

  final words = await bootstrapResult.repositoryFactory.wordRepository
      .loadWordsForCategory(categoryId: categoryId);

  return words.length;
});
