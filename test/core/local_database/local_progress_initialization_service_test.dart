import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_progress_initialization_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);
  const categoryId = 'category-basics';

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<LocalProgressInitializationService> seedService(
    Database db, {
    bool includeArchivedWord = false,
  }) async {
    final categoryRepository = CategoryRepository(database: db);
    final wordRepository = WordRepository(database: db);
    final progressRepository = WordProgressRepository(database: db);

    await categoryRepository.upsertCategory(
      id: categoryId,
      name: 'Basics',
      now: now,
    );
    await wordRepository.upsertWord(
      id: 'word-house',
      categoryId: categoryId,
      term: 'Haus',
      translation: 'house',
      sortOrder: 1,
      now: now,
    );
    await wordRepository.upsertWord(
      id: 'word-apple',
      categoryId: categoryId,
      term: 'Apfel',
      translation: 'apple',
      sortOrder: 2,
      now: now,
    );

    if (includeArchivedWord) {
      await wordRepository.upsertWord(
        id: 'word-archived',
        categoryId: categoryId,
        term: 'Archiviert',
        translation: 'archived',
        sortOrder: 0,
        isArchived: true,
        now: now,
      );
    }

    return LocalProgressInitializationService(
      wordRepository: wordRepository,
      wordProgressRepository: progressRepository,
    );
  }

  group('LocalProgressInitializationService', () {
    test('initializes_s0_progress_for_all_active_words_in_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);
      final progressRepository = WordProgressRepository(database: db);

      await service.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.time,
        now: now,
      );

      for (final wordId in ['word-house', 'word-apple']) {
        final progress = await progressRepository.loadProgress(
          wordId: wordId,
          categoryId: categoryId,
          mode: LearningMode.time,
        );

        expect(progress, isNotNull);
        expect(progress!.stage, SrsStage.s0);
        expect(progress.passCount, 0);
        expect(progress.wrongCount, 0);
        expect(progress.nextDueAt, isNull);
        expect(progress.lastReviewedAt, isNull);
      }
    });

    test('does_not_initialize_archived_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db, includeArchivedWord: true);
      final progressRepository = WordProgressRepository(database: db);

      await service.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.time,
        now: now,
      );

      final archivedProgress = await progressRepository.loadProgress(
        wordId: 'word-archived',
        categoryId: categoryId,
        mode: LearningMode.time,
      );
      final rows = await db.query('word_progress');

      expect(archivedProgress, isNull);
      expect(rows, hasLength(2));
    });

    test('does_not_create_duplicate_progress_on_second_run', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);

      await service.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.time,
        now: now,
      );
      await service.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.time,
        now: now.add(const Duration(minutes: 5)),
      );

      final rows = await db.query('word_progress');

      expect(rows, hasLength(2));
      expect(rows.map((row) => row['word_id']).toSet(), {
        'word-house',
        'word-apple',
      });
    });

    test('initializes_progress_only_for_requested_learning_mode', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);
      final progressRepository = WordProgressRepository(database: db);

      await service.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.hybrid,
        now: now,
      );

      for (final wordId in ['word-house', 'word-apple']) {
        final hybridProgress = await progressRepository.loadProgress(
          wordId: wordId,
          categoryId: categoryId,
          mode: LearningMode.hybrid,
        );
        final timeProgress = await progressRepository.loadProgress(
          wordId: wordId,
          categoryId: categoryId,
          mode: LearningMode.time,
        );
        final adaptiveProgress = await progressRepository.loadProgress(
          wordId: wordId,
          categoryId: categoryId,
          mode: LearningMode.adaptive,
        );

        expect(hybridProgress, isNotNull);
        expect(hybridProgress!.stage, SrsStage.s0);
        expect(timeProgress, isNull);
        expect(adaptiveProgress, isNull);
      }

      final rows = await db.query('word_progress');
      expect(rows, hasLength(2));
      expect(rows.map((row) => row['mode_id']).toSet(), {
        LearningMode.hybrid.name,
      });
    });

    test('initializes_progress_for_word_world_memberships', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final progressRepository = WordProgressRepository(database: db);
      await categoryRepository.upsertCategory(
        id: categoryId,
        name: 'Basics',
        now: now,
      );
      await categoryRepository.upsertCategory(
        id: 'category-travel',
        name: 'Travel',
        now: now,
      );
      await wordRepository.upsertWord(
        id: 'word-ticket',
        categoryId: categoryId,
        term: 'ticket',
        translation: 'Fahrkarte',
        now: now,
      );
      await wordRepository.upsertWord(
        id: 'word-hotel',
        categoryId: categoryId,
        term: 'hotel',
        translation: 'Hotel',
        now: now,
      );
      await wordRepository.addWordWorldMembership(
        wordId: 'word-ticket',
        categoryId: 'category-travel',
        createdAt: now,
      );
      await wordRepository.addWordWorldMembership(
        wordId: 'word-hotel',
        categoryId: 'category-travel',
        createdAt: now,
      );
      final service = LocalProgressInitializationService(
        wordRepository: wordRepository,
        wordProgressRepository: progressRepository,
      );

      await service.initializeProgressForCategoryAndMode(
        categoryId: 'category-travel',
        mode: LearningMode.time,
        now: now,
      );

      final rows = await db.query('word_progress', orderBy: 'word_id ASC');
      expect(rows.map((row) => row['word_id']), ['word-hotel', 'word-ticket']);
      expect(rows.map((row) => row['category_id']).toSet(), {
        'category-travel',
      });
    });
  });
}
