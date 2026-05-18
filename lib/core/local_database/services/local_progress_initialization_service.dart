import '../../srs/models/learning_mode.dart';
import '../repositories/word_progress_repository.dart';
import '../repositories/word_repository.dart';

class LocalProgressInitializationService {
  const LocalProgressInitializationService({
    required WordRepository wordRepository,
    required WordProgressRepository wordProgressRepository,
  }) : _wordRepository = wordRepository,
       _wordProgressRepository = wordProgressRepository;

  final WordRepository _wordRepository;
  final WordProgressRepository _wordProgressRepository;

  Future<void> initializeProgressForCategoryAndMode({
    required String categoryId,
    required LearningMode mode,
    required DateTime now,
  }) async {
    final wordIds = await _wordRepository.loadWordIdsForCategory(
      categoryId: categoryId,
    );

    for (final wordId in wordIds) {
      await _wordProgressRepository.ensureProgressForWord(
        wordId: wordId,
        categoryId: categoryId,
        mode: mode,
        now: now,
      );
    }
  }

  Future<int> countWordsForCategory({required String categoryId}) {
    return _wordRepository.countWordsForCategory(categoryId: categoryId);
  }
}
