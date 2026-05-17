import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_word.dart';
import 'local_bootstrap_provider.dart';

final localWordsForCategoryProvider =
    FutureProvider.family<List<LocalWord>, String>((ref, categoryId) async {
      if (categoryId.trim().isEmpty) {
        return const <LocalWord>[];
      }

      final bootstrapResult = await ref.watch(localBootstrapProvider.future);
      return bootstrapResult.repositoryFactory.wordRepository
          .loadWordsForCategory(categoryId: categoryId);
    });
