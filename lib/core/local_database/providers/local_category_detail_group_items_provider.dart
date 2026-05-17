import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/local_category_detail_group_resolver.dart';
import 'local_bootstrap_provider.dart';

final localCategoryDetailGroupItemsProvider =
    FutureProvider.family<List<LocalCategoryDetailGroupItem>, String>((
      ref,
      wordHubKey,
    ) async {
      final items = const LocalCategoryDetailGroupResolver().resolve(
        wordHubKey,
      );
      if (items.isEmpty) {
        return const [];
      }

      final bootstrapResult = await ref.watch(localBootstrapProvider.future);
      final wordRepository = bootstrapResult.repositoryFactory.wordRepository;

      final resolvedItems = <LocalCategoryDetailGroupItem>[];
      for (final item in items) {
        final localCategoryId = item.localCategoryId;
        if (localCategoryId == null || localCategoryId.trim().isEmpty) {
          resolvedItems.add(item.copyWith(vocabsCount: 0));
          continue;
        }

        final words = await wordRepository.loadWordsForCategory(
          categoryId: localCategoryId,
        );
        resolvedItems.add(item.copyWith(vocabsCount: words.length));
      }

      return resolvedItems;
    });
