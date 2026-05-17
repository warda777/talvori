import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_bootstrap_provider.dart';

final localWordCountProvider = FutureProvider.family<int, String>((
  ref,
  categoryId,
) async {
  if (categoryId.trim().isEmpty) {
    return 0;
  }

  final bootstrapResult = await ref.watch(localBootstrapProvider.future);
  final words = await bootstrapResult.repositoryFactory.wordRepository
      .loadWordsForCategory(categoryId: categoryId);

  return words.length;
});
