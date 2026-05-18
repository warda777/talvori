import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/review_history_repository.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
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

  Future<void> insertCategory(Database db, {String id = 'category-1'}) async {
    await db.insert('categories', {
      'id': id,
      'name': id,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertWord(
    Database db, {
    String id = 'word-1',
    String categoryId = 'category-1',
  }) async {
    await db.insert('words', {
      'id': id,
      'category_id': categoryId,
      'term': id,
      'translation': 'translation-$id',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertLearningSession(
    Database db, {
    String id = 'session-1',
    String categoryId = 'category-1',
  }) async {
    await db.insert('learning_sessions', {
      'id': id,
      'category_id': categoryId,
      'mode_id': LearningMode.time.name,
      'training_area_id': TrainingArea.all.name,
      'status': 'active',
      'session_size': 20,
      'started_at': now.toIso8601String(),
      'last_activity_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertReviewEvent(
    ReviewHistoryRepository repository, {
    String wordId = 'word-1',
    String categoryId = 'category-1',
    LearningMode mode = LearningMode.time,
    TrainingArea trainingArea = TrainingArea.all,
    String? sessionId,
    ReviewAnswer answer = ReviewAnswer.correct,
    DateTime? reviewedAt,
    SrsStage oldStage = SrsStage.s0,
    SrsStage newStage = SrsStage.s1,
    int oldPassCount = 0,
    int newPassCount = 0,
    DateTime? oldNextDueAt,
    DateTime? newNextDueAt,
    RequeueReason? requeueReason,
  }) {
    return repository.insertReviewEvent(
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
      sessionId: sessionId,
      answer: answer,
      reviewedAt: reviewedAt ?? now,
      oldStage: oldStage,
      newStage: newStage,
      oldPassCount: oldPassCount,
      newPassCount: newPassCount,
      oldNextDueAt: oldNextDueAt,
      newNextDueAt: newNextDueAt,
      requeueReason: requeueReason,
      createdAt: now,
    );
  }

  group('ReviewHistoryRepository', () {
    test('insert_review_event_stores_all_core_fields', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);
      await insertLearningSession(db);
      final repository = ReviewHistoryRepository(database: db);
      final oldNextDueAt = now.subtract(const Duration(days: 1));
      final newNextDueAt = now.add(const Duration(days: 3));

      final event = await repository.insertReviewEvent(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        sessionId: 'session-1',
        answer: ReviewAnswer.wrong,
        reviewedAt: now,
        oldStage: SrsStage.s5,
        newStage: SrsStage.s3,
        oldPassCount: 2,
        newPassCount: 0,
        oldNextDueAt: oldNextDueAt,
        newNextDueAt: newNextDueAt,
        requeueReason: RequeueReason.wrongAnswer,
        createdAt: now,
      );

      final rows = await db.query('review_history');
      expect(rows, hasLength(1));
      expect(rows.single['id'], event.id);
      expect(rows.single['word_id'], 'word-1');
      expect(rows.single['category_id'], 'category-1');
      expect(rows.single['mode_id'], LearningMode.time.name);
      expect(rows.single['training_area_id'], TrainingArea.all.name);
      expect(rows.single['session_id'], 'session-1');
      expect(rows.single['answer'], ReviewAnswer.wrong.name);
      expect(rows.single['reviewed_at'], now.toIso8601String());
      expect(rows.single['old_stage'], SrsStage.s5.name);
      expect(rows.single['new_stage'], SrsStage.s3.name);
      expect(rows.single['old_pass_count'], 2);
      expect(rows.single['new_pass_count'], 0);
      expect(rows.single['old_next_due_at'], oldNextDueAt.toIso8601String());
      expect(rows.single['new_next_due_at'], newNextDueAt.toIso8601String());
      expect(rows.single['requeue_reason'], RequeueReason.wrongAnswer.name);
      expect(rows.single['created_at'], now.toIso8601String());
    });

    test('load_history_for_word_returns_events_for_only_that_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db, id: 'word-1');
      await insertWord(db, id: 'word-2');
      final repository = ReviewHistoryRepository(database: db);

      await insertReviewEvent(
        repository,
        wordId: 'word-1',
        reviewedAt: now.add(const Duration(minutes: 2)),
      );
      await insertReviewEvent(
        repository,
        wordId: 'word-2',
        reviewedAt: now.add(const Duration(minutes: 1)),
      );
      await insertReviewEvent(repository, wordId: 'word-1', reviewedAt: now);

      final history = await repository.loadHistoryForWord('word-1');

      expect(history, hasLength(2));
      expect(history.every((event) => event.wordId == 'word-1'), isTrue);
      expect(history.map((event) => event.reviewedAt), [
        now,
        now.add(const Duration(minutes: 2)),
      ]);
    });

    test(
      'load_history_for_word_in_context_filters_category_and_mode',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertCategory(db, id: 'category-2');
        await insertWord(db, id: 'word-1');
        await insertWord(db, id: 'word-1-other', categoryId: 'category-2');
        final repository = ReviewHistoryRepository(database: db);

        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          reviewedAt: now,
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          categoryId: 'category-1',
          mode: LearningMode.hybrid,
          reviewedAt: now.add(const Duration(minutes: 1)),
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          categoryId: 'category-2',
          mode: LearningMode.adaptive,
          reviewedAt: now.add(const Duration(minutes: 2)),
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          reviewedAt: now.add(const Duration(minutes: 3)),
        );

        final ascending = await repository.loadHistoryForWordInContext(
          wordId: 'word-1',
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
        );
        final descending = await repository.loadHistoryForWordInContext(
          wordId: 'word-1',
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          descending: true,
        );

        expect(ascending, hasLength(2));
        expect(ascending.map((event) => event.reviewedAt), [
          now,
          now.add(const Duration(minutes: 3)),
        ]);
        expect(descending.map((event) => event.reviewedAt), [
          now.add(const Duration(minutes: 3)),
          now,
        ]);
        expect(
          ascending.every(
            (event) =>
                event.categoryId == 'category-1' &&
                event.mode == LearningMode.adaptive,
          ),
          isTrue,
        );
      },
    );

    test(
      'load_recent_answers_returns_latest_answers_for_category_and_mode',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertCategory(db, id: 'category-2');
        await insertWord(db, id: 'word-1');
        await insertWord(db, id: 'word-2');
        await insertWord(db, id: 'word-3', categoryId: 'category-2');
        final repository = ReviewHistoryRepository(database: db);

        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          answer: ReviewAnswer.correct,
          reviewedAt: now,
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          answer: ReviewAnswer.wrong,
          reviewedAt: now.add(const Duration(minutes: 1)),
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-2',
          answer: ReviewAnswer.correct,
          reviewedAt: now.add(const Duration(minutes: 2)),
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-1',
          mode: LearningMode.hybrid,
          answer: ReviewAnswer.wrong,
          reviewedAt: now.add(const Duration(minutes: 3)),
        );
        await insertReviewEvent(
          repository,
          wordId: 'word-3',
          categoryId: 'category-2',
          answer: ReviewAnswer.wrong,
          reviewedAt: now.add(const Duration(minutes: 4)),
        );

        final recentAnswers = await repository.loadRecentAnswers(
          categoryId: 'category-1',
          mode: LearningMode.time,
          limit: 2,
        );

        expect(recentAnswers, [ReviewAnswer.correct, ReviewAnswer.wrong]);
      },
    );

    test(
      'focused_review_event_can_be_stored_without_progress_change',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db);
        final repository = ReviewHistoryRepository(database: db);
        final nextDueAt = now.add(const Duration(days: 5));

        await insertReviewEvent(
          repository,
          trainingArea: TrainingArea.focused,
          answer: ReviewAnswer.wrong,
          oldStage: SrsStage.s4,
          newStage: SrsStage.s4,
          oldPassCount: 2,
          newPassCount: 2,
          oldNextDueAt: nextDueAt,
          newNextDueAt: nextDueAt,
        );

        final history = await repository.loadHistoryForWord('word-1');

        expect(history, hasLength(1));
        expect(history.single.trainingArea, TrainingArea.focused);
        expect(history.single.answer, ReviewAnswer.wrong);
        expect(history.single.oldStage, SrsStage.s4);
        expect(history.single.newStage, SrsStage.s4);
        expect(history.single.oldPassCount, 2);
        expect(history.single.newPassCount, 2);
        expect(history.single.oldNextDueAt, nextDueAt);
        expect(history.single.newNextDueAt, nextDueAt);
      },
    );
  });
}
