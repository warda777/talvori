import 'dart:convert';

import '../import/local_json_import_models.dart';
import '../repositories/category_repository.dart';
import '../repositories/word_repository.dart';

class LocalJsonImportService {
  const LocalJsonImportService({
    required CategoryRepository categoryRepository,
    required WordRepository wordRepository,
  }) : _categoryRepository = categoryRepository,
       _wordRepository = wordRepository;

  final CategoryRepository _categoryRepository;
  final WordRepository _wordRepository;

  Future<void> importFromJsonString({
    required String json,
    required DateTime now,
  }) async {
    final decoded = jsonDecode(json);
    final categories = _parseCategories(decoded);
    _validateUniqueIds(categories);

    for (final category in categories) {
      await _categoryRepository.upsertCategory(
        id: category.id,
        name: category.name,
        description: category.description,
        sortOrder: category.sortOrder,
        isArchived: category.isArchived,
        now: now,
      );

      for (final word in category.words) {
        await _wordRepository.upsertWord(
          id: word.id,
          categoryId: category.id,
          term: word.term,
          translation: word.translation,
          exampleSentence: word.exampleSentence,
          notes: word.notes,
          sortOrder: word.sortOrder,
          isArchived: word.isArchived,
          now: now,
        );
      }
    }
  }

  List<LocalJsonImportCategory> _parseCategories(Object? decoded) {
    if (decoded is! List<Object?>) {
      throw const FormatException('Expected top-level category list.');
    }

    return decoded
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Expected category object.');
          }
          return LocalJsonImportCategory.fromJson(item);
        })
        .toList(growable: false);
  }

  void _validateUniqueIds(List<LocalJsonImportCategory> categories) {
    final categoryIds = <String>{};
    final wordIds = <String>{};

    for (final category in categories) {
      if (!categoryIds.add(category.id)) {
        throw FormatException('Duplicate category id "${category.id}".');
      }

      for (final word in category.words) {
        if (!wordIds.add(word.id)) {
          throw FormatException('Duplicate word id "${word.id}".');
        }
      }
    }
  }
}
