import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_category.dart';
import '../models/local_learning_source.dart';
import '../models/local_word.dart';
import '../models/local_word_package_definition.dart';
import '../services/shared_text_import_service.dart';
import 'local_bootstrap_provider.dart';
import 'local_words_for_source_provider.dart';

final localWordsForCategoryProvider =
    FutureProvider.family<List<LocalWord>, String>((ref, categoryId) async {
      if (categoryId.trim().isEmpty) {
        return const <LocalWord>[];
      }

      final source = LocalLearningSource.fromId(categoryId);
      if (source != null) {
        return ref.watch(localWordsForSourceProvider(source).future);
      }

      final bootstrapResult = await ref.watch(localBootstrapProvider.future);
      if (categoryId.startsWith(localLevelPackageCategoryPrefix)) {
        final packageKey = categoryId.substring(
          localLevelPackageCategoryPrefix.length,
        );
        final package = localLevelPackageByKey(packageKey);
        if (package == null) return const <LocalWord>[];
        return _loadWordsForLevelPackage(
          package: package,
          categories: await bootstrapResult.repositoryFactory.categoryRepository
              .loadCategories(),
          allWords: await bootstrapResult.repositoryFactory.wordRepository
              .loadAllWords(),
          loadCategoryWords: bootstrapResult
              .repositoryFactory
              .wordRepository
              .loadWordsForCategory,
          loadWordWorldWords: bootstrapResult
              .repositoryFactory
              .wordRepository
              .loadWordsForWordWorld,
        );
      }

      if (categoryId.startsWith(localLanguageToolCategoryPrefix)) {
        final toolKey = categoryId.substring(
          localLanguageToolCategoryPrefix.length,
        );
        final tool = localLanguageToolByKey(toolKey);
        if (tool == null) return const <LocalWord>[];
        return _loadWordsForLanguageTool(
          tool: tool,
          categories: await bootstrapResult.repositoryFactory.categoryRepository
              .loadCategories(),
          loadCategoryWords: bootstrapResult
              .repositoryFactory
              .wordRepository
              .loadWordsForCategory,
        );
      }

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
          .loadWordsForWordWorld(categoryId: categoryId, includeDisabled: true);
    });

typedef _CategoryWordsLoader =
    Future<List<LocalWord>> Function({
      required String categoryId,
      bool includeArchived,
    });

Future<List<LocalWord>> _loadWordsForLevelPackage({
  required LocalLevelPackageDefinition package,
  required List<LocalCategory> categories,
  required List<LocalWord> allWords,
  required _CategoryWordsLoader loadCategoryWords,
  required _CategoryWordsLoader loadWordWorldWords,
}) async {
  if (package.mode == LocalWordPackageMode.partOfSpeech) {
    // POS is not part of the local word model yet. Returning an empty package is
    // safer than pretending all level words are verbs/nouns/adjectives.
    return const <LocalWord>[];
  }

  final levelWords = allWords
      .where((word) {
        return _normalizePackageValue(word.level ?? '') ==
            _normalizePackageValue(package.level);
      })
      .toList(growable: false);

  if (package.mode == LocalWordPackageMode.topic &&
      package.topicNames.isNotEmpty) {
    final topicIds = _categoryIdsForNames(categories, package.topicNames);
    if (topicIds.isEmpty) return const <LocalWord>[];
    final topicWordIds = <String>{};
    for (final categoryId in topicIds) {
      final words = await loadWordWorldWords(categoryId: categoryId);
      topicWordIds.addAll(words.map((word) => word.id));
    }
    return _limitPackageWords(
      levelWords.where((word) => topicWordIds.contains(word.id)),
      package.maxWords,
    );
  }

  if (package.mode == LocalWordPackageMode.languageTool &&
      package.languageToolCategoryNames.isNotEmpty) {
    final categoryIds = _categoryIdsForNames(
      categories,
      package.languageToolCategoryNames,
    );
    if (categoryIds.isEmpty) return const <LocalWord>[];
    final toolWordIds = <String>{};
    for (final categoryId in categoryIds) {
      final words = await loadCategoryWords(categoryId: categoryId);
      toolWordIds.addAll(words.map((word) => word.id));
    }
    return _limitPackageWords(
      levelWords.where((word) => toolWordIds.contains(word.id)),
      package.maxWords,
    );
  }

  return _limitPackageWords(levelWords, package.maxWords);
}

Future<List<LocalWord>> _loadWordsForLanguageTool({
  required LocalLanguageToolDefinition tool,
  required List<LocalCategory> categories,
  required _CategoryWordsLoader loadCategoryWords,
}) async {
  final categoryIds = _categoryIdsForNames(categories, tool.categoryNames);
  if (categoryIds.isEmpty) return const <LocalWord>[];
  final wordsById = <String, LocalWord>{};
  for (final categoryId in categoryIds) {
    final words = await loadCategoryWords(categoryId: categoryId);
    for (final word in words) {
      wordsById[word.id] = word;
    }
  }
  return _limitPackageWords(wordsById.values, tool.maxWords);
}

List<String> _categoryIdsForNames(
  List<LocalCategory> categories,
  List<String> names,
) {
  final normalizedNames = names.map(_normalizePackageValue).toSet();
  return categories
      .where((category) {
        return normalizedNames.contains(_normalizePackageValue(category.name));
      })
      .map((category) => category.id)
      .toList(growable: false);
}

List<LocalWord> _limitPackageWords(Iterable<LocalWord> words, int maxWords) {
  final sorted = words.toList(growable: false)
    ..sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.term.toLowerCase().compareTo(b.term.toLowerCase());
    });
  if (sorted.length <= maxWords) return sorted;
  return sorted.take(maxWords).toList(growable: false);
}

String _normalizePackageValue(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
