import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/local_category_detail_group_resolver.dart';
import '../local_database_schema.dart';
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
      final categoryRepository =
          bootstrapResult.repositoryFactory.categoryRepository;
      final wordRepository = bootstrapResult.repositoryFactory.wordRepository;
      final categories = await categoryRepository.loadCategories();
      final categoryIdsByName = {
        for (final category in categories)
          _categoryKey(category.name): category.id,
      };

      final resolvedItems = <LocalCategoryDetailGroupItem>[];
      for (final item in items) {
        if (!LocalDatabaseSchema.isThematicWordWorldName(item.displayLabel)) {
          continue;
        }

        final localCategoryId = _resolveLocalCategoryId(
          item,
          categoryIdsByName,
        );
        if (localCategoryId == null) {
          resolvedItems.add(item.copyWith(vocabsCount: 0));
          continue;
        }

        final words = await wordRepository.loadWordsForWordWorld(
          categoryId: localCategoryId,
        );
        resolvedItems.add(
          item.copyWith(
            localCategoryId: localCategoryId,
            vocabsCount: words.length,
          ),
        );
      }

      return resolvedItems;
    });

String? _resolveLocalCategoryId(
  LocalCategoryDetailGroupItem item,
  Map<String, String> categoryIdsByName,
) {
  final dynamicId = categoryIdsByName[_categoryKey(item.displayLabel)]?.trim();
  if (dynamicId != null && dynamicId.isNotEmpty) {
    return dynamicId;
  }

  final mappedId = item.localCategoryId?.trim();
  if (mappedId != null && mappedId.isNotEmpty) {
    return mappedId;
  }

  return null;
}

String _categoryKey(String name) {
  return name
      .trim()
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
