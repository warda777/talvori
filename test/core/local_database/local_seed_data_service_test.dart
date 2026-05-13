import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/local_repository_factory.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_seed_data_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  group('LocalSeedDataService', () {
    test('seed_data_can_create_categories_and_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final seedService = LocalSeedDataService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );

      await seedService.seedDefaults(now: now);

      final categories = await categoryRepository.loadCategories();
      final basics = await categoryRepository.loadCategoryById(
        'seed-category-basics',
      );
      final travel = await categoryRepository.loadCategoryById(
        'seed-category-travel',
      );
      final examPractice = await categoryRepository.loadCategoryById(
        'seed-category-exam-practice',
      );
      final basicsWords = await wordRepository.loadWordsForCategory(
        categoryId: 'seed-category-basics',
      );
      final travelWords = await wordRepository.loadWordsForCategory(
        categoryId: 'seed-category-travel',
      );
      final examPracticeWords = await wordRepository.loadWordsForCategory(
        categoryId: 'seed-category-exam-practice',
      );
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categories.map((category) => category.name), contains('Basics'));
      expect(categories.map((category) => category.name), contains('Travel'));
      expect(
        categories.map((category) => category.name),
        contains('Exam Practice'),
      );
      expect(basics, isNotNull);
      expect(travel, isNotNull);
      expect(examPractice, isNotNull);
      expect(basicsWords, isNotEmpty);
      expect(travelWords, isNotEmpty);
      expect(examPracticeWords, isNotEmpty);
      for (final word in [
        ...basicsWords,
        ...travelWords,
        ...examPracticeWords,
      ]) {
        expect(word.term, isNotEmpty);
        expect(word.translation, isNotEmpty);
        expect(word.isArchived, isFalse);
      }
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('seed_data_is_idempotent', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final seedService = LocalSeedDataService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );

      await seedService.seedDefaults(now: now);
      final categoriesAfterFirstRun = await categoryRepository.loadCategories();
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category.id)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id'] as String)
          .toSet();

      await seedService.seedDefaults(now: now.add(const Duration(minutes: 5)));
      final categoriesAfterSecondRun = await categoryRepository.loadCategories();
      final wordsAfterSecondRun = await db.query('words');
      final categoryIdsAfterSecondRun = categoriesAfterSecondRun
          .map((category) => category.id)
          .toSet();
      final wordIdsAfterSecondRun = wordsAfterSecondRun
          .map((word) => word['id'] as String)
          .toSet();
      final basics = await categoryRepository.loadCategoryById(
        'seed-category-basics',
      );
      final travel = await categoryRepository.loadCategoryById(
        'seed-category-travel',
      );
      final examPractice = await categoryRepository.loadCategoryById(
        'seed-category-exam-practice',
      );
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(
        categoriesAfterSecondRun,
        hasLength(categoriesAfterFirstRun.length),
      );
      expect(wordsAfterSecondRun, hasLength(wordsAfterFirstRun.length));
      expect(categoryIdsAfterSecondRun, categoryIdsAfterFirstRun);
      expect(wordIdsAfterSecondRun, wordIdsAfterFirstRun);
      expect(basics, isNotNull);
      expect(travel, isNotNull);
      expect(examPractice, isNotNull);
      expect(categoryIdsAfterSecondRun, hasLength(categoriesAfterSecondRun.length));
      expect(wordIdsAfterSecondRun, hasLength(wordsAfterSecondRun.length));
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('seeded_words_can_initialize_progress_and_start_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repositoryFactory = LocalRepositoryFactory(database: db);
      final seedService = LocalSeedDataService(
        categoryRepository: repositoryFactory.categoryRepository,
        wordRepository: repositoryFactory.wordRepository,
      );

      await seedService.seedDefaults(now: now);
      final progressRowsBeforeInitialization = await db.query('word_progress');
      final basics = await repositoryFactory.categoryRepository
          .loadCategoryById('seed-category-basics');

      await repositoryFactory.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: basics!.id,
            mode: LearningMode.adaptive,
            now: now,
          );
      final progressRowsAfterInitialization = await db.query('word_progress');
      final readState = await repositoryFactory.learningSessionFacade
          .startOrResumeLearning(
            categoryId: basics.id,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final activeSessions = await db.query(
        'learning_sessions',
        where:
            'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
        whereArgs: [
          basics.id,
          LearningMode.adaptive.name,
          TrainingArea.all.name,
          'active',
        ],
      );
      final sessionItems = await db.query('session_items');

      expect(progressRowsBeforeInitialization, isEmpty);
      expect(progressRowsAfterInitialization, isNotEmpty);
      expect(readState.sessionId, isNotEmpty);
      expect(readState.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentTranslation, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(readState.canSubmitAnswer, isTrue);
      expect(activeSessions, hasLength(1));
      expect(sessionItems, isNotEmpty);
    });
  });
}
