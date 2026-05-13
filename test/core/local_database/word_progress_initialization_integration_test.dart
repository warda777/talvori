import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
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

  group('Word progress initialization integration', () {
    test('word_ids_can_be_used_to_initialize_progress_for_all_modes', () async {
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
      await wordRepository.upsertWord(
        id: 'word-archived',
        categoryId: categoryId,
        term: 'Archiviert',
        translation: 'archived',
        sortOrder: 0,
        isArchived: true,
        now: now,
      );

      final wordIds = await wordRepository.loadWordIdsForCategory(
        categoryId: categoryId,
      );

      expect(wordIds, ['word-house', 'word-apple']);

      for (final wordId in wordIds) {
        for (final mode in LearningMode.values) {
          await progressRepository.ensureProgressForWord(
            wordId: wordId,
            categoryId: categoryId,
            mode: mode,
            now: now,
          );
        }
      }

      for (final wordId in wordIds) {
        for (final mode in LearningMode.values) {
          final progress = await progressRepository.loadProgress(
            wordId: wordId,
            categoryId: categoryId,
            mode: mode,
          );

          expect(progress, isNotNull);
          expect(progress!.wordId, wordId);
          expect(progress.categoryId, categoryId);
          expect(progress.mode, mode);
          expect(progress.stage, SrsStage.s0);
          expect(progress.passCount, 0);
          expect(progress.wrongCount, 0);
          expect(progress.nextDueAt, isNull);
          expect(progress.lastReviewedAt, isNull);
        }
      }

      final rowsAfterFirstInitialization = await db.query('word_progress');
      expect(rowsAfterFirstInitialization, hasLength(wordIds.length * 3));
      expect(
        rowsAfterFirstInitialization.where(
          (row) => row['word_id'] == 'word-archived',
        ),
        isEmpty,
      );

      for (final wordId in wordIds) {
        for (final mode in LearningMode.values) {
          await progressRepository.ensureProgressForWord(
            wordId: wordId,
            categoryId: categoryId,
            mode: mode,
            now: now.add(const Duration(minutes: 5)),
          );
        }
      }

      final rowsAfterSecondInitialization = await db.query('word_progress');
      expect(rowsAfterSecondInitialization, hasLength(wordIds.length * 3));

      for (final wordId in wordIds) {
        final rowsForWord = rowsAfterSecondInitialization.where(
          (row) => row['word_id'] == wordId,
        );

        expect(rowsForWord, hasLength(3));
        expect(rowsForWord.map((row) => row['mode_id']).toSet(), {
          LearningMode.time.name,
          LearningMode.adaptive.name,
          LearningMode.hybrid.name,
        });
      }
    });
  });
}
