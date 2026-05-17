import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/word_progress.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<void> insertCategory(Database db, {String id = 'category-1'}) async {
    await db.insert('categories', {
      'id': id,
      'name': 'Basics',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertWord(
    Database db, {
    String id = 'word-1',
    String categoryId = 'category-1',
    String term = 'hello',
  }) async {
    await db.insert('words', {
      'id': id,
      'category_id': categoryId,
      'term': term,
      'translation': 'hallo',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedWordProgress(
    Database db, {
    required String id,
    required String wordId,
    String categoryId = 'category-1',
    LearningMode mode = LearningMode.time,
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
    DateTime? createdAt,
  }) async {
    await db.insert('word_progress', {
      'id': id,
      'word_id': wordId,
      'category_id': categoryId,
      'mode_id': mode.name,
      'stage': stage.name,
      'pass_count': passCount,
      'wrong_count': wrongCount,
      'next_due_at': nextDueAt?.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  group('WordProgressRepository', () {
    test('ensure_progress_creates_s0_when_missing', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);
      final repository = WordProgressRepository(database: db);

      final progress = await repository.ensureProgressForWord(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        now: now,
      );

      expect(progress.wordId, 'word-1');
      expect(progress.categoryId, 'category-1');
      expect(progress.mode, LearningMode.time);
      expect(progress.stage, SrsStage.s0);
      expect(progress.passCount, 0);
      expect(progress.wrongCount, 0);
      expect(progress.nextDueAt, isNull);
      expect(progress.lastReviewedAt, isNull);

      final rows = await db.query('word_progress');
      expect(rows, hasLength(1));
    });

    test('ensure_progress_reuses_existing_progress', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);
      await seedWordProgress(
        db,
        id: 'progress-1',
        wordId: 'word-1',
        stage: SrsStage.s2,
        passCount: 1,
      );
      final repository = WordProgressRepository(database: db);

      final progress = await repository.ensureProgressForWord(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        now: now,
      );

      expect(progress.stage, SrsStage.s2);
      expect(progress.passCount, 1);

      final rows = await db.query('word_progress');
      expect(rows, hasLength(1));
    });

    test('progress_is_separate_per_learning_mode', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);
      final repository = WordProgressRepository(database: db);

      final time = await repository.ensureProgressForWord(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        now: now,
      );
      final adaptive = await repository.ensureProgressForWord(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.adaptive,
        now: now,
      );
      final hybrid = await repository.ensureProgressForWord(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.hybrid,
        now: now,
      );

      expect(time.mode, LearningMode.time);
      expect(adaptive.mode, LearningMode.adaptive);
      expect(hybrid.mode, LearningMode.hybrid);

      final rows = await db.query('word_progress');
      expect(rows, hasLength(3));
    });

    test(
      'save_progress_updates_stage_pass_count_wrong_count_and_due_dates',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db);
        await seedWordProgress(db, id: 'progress-1', wordId: 'word-1');
        final repository = WordProgressRepository(database: db);
        final nextDueAt = now.add(const Duration(days: 3));

        await repository.saveProgress(
          updatedProgress: WordProgress(
            wordId: 'word-1',
            categoryId: 'category-1',
            mode: LearningMode.time,
            stage: SrsStage.s2,
            passCount: 1,
            wrongCount: 2,
            nextDueAt: nextDueAt,
            lastReviewedAt: now,
          ),
          updatedAt: now.add(const Duration(minutes: 1)),
        );

        final rows = await db.query('word_progress');
        expect(rows.single['stage'], SrsStage.s2.name);
        expect(rows.single['pass_count'], 1);
        expect(rows.single['wrong_count'], 2);
        expect(rows.single['next_due_at'], nextDueAt.toIso8601String());
        expect(rows.single['last_reviewed_at'], now.toIso8601String());
        expect(
          rows.single['updated_at'],
          now.add(const Duration(minutes: 1)).toIso8601String(),
        );
      },
    );

    test('count_by_stage_returns_counts_for_category_and_mode', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertCategory(db, id: 'category-2');
      for (var index = 1; index <= 5; index++) {
        await insertWord(
          db,
          id: 'word-$index',
          categoryId: index == 5 ? 'category-2' : 'category-1',
        );
      }
      await seedWordProgress(
        db,
        id: 'progress-1',
        wordId: 'word-1',
        stage: SrsStage.s0,
      );
      await seedWordProgress(
        db,
        id: 'progress-2',
        wordId: 'word-2',
        stage: SrsStage.s0,
      );
      await seedWordProgress(
        db,
        id: 'progress-3',
        wordId: 'word-3',
        stage: SrsStage.s2,
      );
      await seedWordProgress(
        db,
        id: 'progress-other-mode',
        wordId: 'word-4',
        mode: LearningMode.hybrid,
        stage: SrsStage.s5,
      );
      await seedWordProgress(
        db,
        id: 'progress-other-category',
        wordId: 'word-5',
        categoryId: 'category-2',
        stage: SrsStage.s3,
      );
      final repository = WordProgressRepository(database: db);

      final counts = await repository.countByStage(
        categoryId: 'category-1',
        mode: LearningMode.time,
      );

      expect(counts, [2, 0, 1, 0, 0, 0]);
    });

    test(
      'reset_category_progress_to_s0_resets_only_category_and_mode',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertCategory(db, id: 'category-2');
        for (var index = 1; index <= 4; index++) {
          await insertWord(
            db,
            id: 'word-$index',
            categoryId: index == 4 ? 'category-2' : 'category-1',
            term: 'term-$index',
          );
        }
        final reviewedAt = now.subtract(const Duration(days: 1));
        final dueAt = now.add(const Duration(days: 2));
        final updatedAt = now.add(const Duration(minutes: 7));
        await seedWordProgress(
          db,
          id: 'progress-target',
          wordId: 'word-1',
          mode: LearningMode.adaptive,
          stage: SrsStage.s5,
          passCount: 5,
          wrongCount: 2,
          nextDueAt: dueAt,
          lastReviewedAt: reviewedAt,
        );
        await seedWordProgress(
          db,
          id: 'progress-same-category-other-mode',
          wordId: 'word-2',
          mode: LearningMode.time,
          stage: SrsStage.s4,
          passCount: 4,
          nextDueAt: dueAt,
        );
        await seedWordProgress(
          db,
          id: 'progress-other-category',
          wordId: 'word-4',
          categoryId: 'category-2',
          mode: LearningMode.adaptive,
          stage: SrsStage.s3,
          passCount: 3,
          nextDueAt: dueAt,
        );
        final repository = WordProgressRepository(database: db);

        await repository.resetCategoryProgressToS0(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          updatedAt: updatedAt,
        );

        final targetRows = await db.query(
          'word_progress',
          where: 'id = ?',
          whereArgs: ['progress-target'],
        );
        expect(targetRows.single['stage'], SrsStage.s0.name);
        expect(targetRows.single['pass_count'], 0);
        expect(targetRows.single['wrong_count'], 0);
        expect(targetRows.single['next_due_at'], isNull);
        expect(targetRows.single['last_reviewed_at'], isNull);
        expect(targetRows.single['updated_at'], updatedAt.toIso8601String());

        final otherModeRows = await db.query(
          'word_progress',
          where: 'id = ?',
          whereArgs: ['progress-same-category-other-mode'],
        );
        expect(otherModeRows.single['stage'], SrsStage.s4.name);
        expect(otherModeRows.single['pass_count'], 4);
        expect(otherModeRows.single['next_due_at'], dueAt.toIso8601String());

        final otherCategoryRows = await db.query(
          'word_progress',
          where: 'id = ?',
          whereArgs: ['progress-other-category'],
        );
        expect(otherCategoryRows.single['stage'], SrsStage.s3.name);
        expect(otherCategoryRows.single['pass_count'], 3);
        expect(
          otherCategoryRows.single['next_due_at'],
          dueAt.toIso8601String(),
        );
      },
    );

    test(
      'load_due_progresses_returns_only_due_non_s0_for_category_and_mode',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertCategory(db, id: 'category-2');
        for (var index = 1; index <= 7; index++) {
          await insertWord(
            db,
            id: 'word-$index',
            categoryId: index == 7 ? 'category-2' : 'category-1',
            term: 'term-$index',
          );
        }

        await seedWordProgress(
          db,
          id: 'progress-due',
          wordId: 'word-1',
          stage: SrsStage.s2,
          nextDueAt: now,
        );
        await seedWordProgress(
          db,
          id: 'progress-overdue',
          wordId: 'word-2',
          stage: SrsStage.s3,
          nextDueAt: now.subtract(const Duration(days: 1)),
        );
        await seedWordProgress(
          db,
          id: 'progress-s0',
          wordId: 'word-3',
          stage: SrsStage.s0,
          nextDueAt: now.subtract(const Duration(days: 1)),
        );
        await seedWordProgress(
          db,
          id: 'progress-null-due',
          wordId: 'word-4',
          stage: SrsStage.s2,
        );
        await seedWordProgress(
          db,
          id: 'progress-future',
          wordId: 'word-5',
          stage: SrsStage.s2,
          nextDueAt: now.add(const Duration(days: 1)),
        );
        await seedWordProgress(
          db,
          id: 'progress-other-mode',
          wordId: 'word-6',
          mode: LearningMode.hybrid,
          stage: SrsStage.s2,
          nextDueAt: now,
        );
        await seedWordProgress(
          db,
          id: 'progress-other-category',
          wordId: 'word-7',
          categoryId: 'category-2',
          stage: SrsStage.s2,
          nextDueAt: now,
        );
        final repository = WordProgressRepository(database: db);

        final due = await repository.loadDueProgresses(
          categoryId: 'category-1',
          mode: LearningMode.time,
          now: now,
        );

        expect(due.map((progress) => progress.wordId), ['word-2', 'word-1']);
        expect(due.every((progress) => progress.stage != SrsStage.s0), isTrue);
      },
    );

    test(
      'load_new_progresses_returns_only_s0_for_category_and_mode_with_limit',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertCategory(db, id: 'category-2');
        for (var index = 1; index <= 6; index++) {
          await insertWord(
            db,
            id: 'word-$index',
            categoryId: index == 6 ? 'category-2' : 'category-1',
            term: 'term-$index',
          );
        }

        await seedWordProgress(
          db,
          id: 'progress-new-1',
          wordId: 'word-1',
          stage: SrsStage.s0,
          createdAt: now,
        );
        await seedWordProgress(
          db,
          id: 'progress-new-2',
          wordId: 'word-2',
          stage: SrsStage.s0,
          createdAt: now.add(const Duration(minutes: 1)),
        );
        await seedWordProgress(
          db,
          id: 'progress-new-3',
          wordId: 'word-3',
          stage: SrsStage.s0,
          createdAt: now.add(const Duration(minutes: 2)),
        );
        await seedWordProgress(
          db,
          id: 'progress-review',
          wordId: 'word-4',
          stage: SrsStage.s1,
        );
        await seedWordProgress(
          db,
          id: 'progress-other-mode',
          wordId: 'word-5',
          mode: LearningMode.hybrid,
          stage: SrsStage.s0,
        );
        await seedWordProgress(
          db,
          id: 'progress-other-category',
          wordId: 'word-6',
          categoryId: 'category-2',
          stage: SrsStage.s0,
        );
        final repository = WordProgressRepository(database: db);

        final newProgresses = await repository.loadNewProgresses(
          categoryId: 'category-1',
          mode: LearningMode.time,
          limit: 2,
        );

        expect(newProgresses.map((progress) => progress.wordId), [
          'word-1',
          'word-2',
        ]);
        expect(
          newProgresses.every((progress) => progress.stage == SrsStage.s0),
          isTrue,
        );
      },
    );
  });
}
