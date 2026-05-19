import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_word.dart';
import '../services/shared_text_import_service.dart';
import 'local_bootstrap_provider.dart';

final localWordsForCategoryProvider =
    FutureProvider.family<List<LocalWord>, String>((ref, categoryId) async {
      if (categoryId.trim().isEmpty) {
        return const <LocalWord>[];
      }

      final bootstrapResult = await ref.watch(localBootstrapProvider.future);
      if (categoryId == localMyWordsCategoryId) {
        await bootstrapResult.repositoryFactory.categoryRepository
            .upsertCategory(
              id: localMyWordsCategoryId,
              name: localMyWordsCategoryLabel,
              description: 'Lokal importierte Wörter.',
              sortOrder: 10000,
              now: DateTime.now(),
            );
      }

      return bootstrapResult.repositoryFactory.wordRepository
          .loadWordsForCategory(categoryId: categoryId);
    });
