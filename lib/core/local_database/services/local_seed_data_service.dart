import '../repositories/category_repository.dart';
import '../repositories/word_repository.dart';
import '../seed/local_seed_data.dart';

class LocalSeedDataService {
  const LocalSeedDataService({
    required CategoryRepository categoryRepository,
    required WordRepository wordRepository,
  }) : _categoryRepository = categoryRepository,
       _wordRepository = wordRepository;

  final CategoryRepository _categoryRepository;
  final WordRepository _wordRepository;

  Future<void> seedDefaults({required DateTime now}) async {
    for (final category in localSeedCategories) {
      await _categoryRepository.upsertCategory(
        id: category.id,
        name: category.name,
        description: category.description,
        sortOrder: category.sortOrder,
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
          now: now,
        );
      }
    }
  }
}
