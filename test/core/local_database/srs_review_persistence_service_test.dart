import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/services/srs_review_persistence_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/requeue_decision.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/review_input.dart';
import 'package:talvori/core/srs/models/review_result.dart';
import 'package:talvori/core/srs/models/session_context.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/models/word_progress.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);
  final reviewedAt = now.add(const Duration(minutes: 5));

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<void> seedBaseData(Database db) async {
    await db.insert('categories', {
      'id': 'category-1',
      'name': 'Basics',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    await db.insert('words', {
      'id': 'word-1',
      'category_id': 'category-1',
      'term': 'hello',
      'translation': 'hallo',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    await db.insert('word_progress', {
      'id': 'progress-1',
      'word_id': 'word-1',
      'category_id': 'category-1',
      'mode_id': LearningMode.time.name,
      'stage': SrsStage.s0.name,
      'pass_count': 0,
      'wrong_count': 0,
      'next_due_at': null,
      'last_reviewed_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    await db.insert('learning_sessions', {
      'id': 'session-1',
      'category_id': 'category-1',
      'mode_id': LearningMode.time.name,
      'training_area_id': TrainingArea.all.name,
      'status': 'active',
      'session_size': 20,
      'current_position': 0,
      'started_at': now.toIso8601String(),
      'last_activity_at': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    await db.insert('session_items', {
      'id': 'item-1',
      'session_id': 'session-1',
      'word_id': 'word-1',
      'category_id': 'category-1',
      'mode_id': LearningMode.time.name,
      'stage_at_enqueue': SrsStage.s0.name,
      'position': 0,
      'status': 'queued',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  ReviewInput reviewInput({
    ReviewAnswer answer = ReviewAnswer.correct,
    int currentPosition = 0,
    Map<String, int> wrongCounts = const {},
    DateTime? oldNextDueAt,
  }) {
    return ReviewInput(
      progress: WordProgress(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        stage: SrsStage.s0,
        passCount: 0,
        wrongCount: 0,
        nextDueAt: oldNextDueAt,
      ),
      answer: answer,
      trainingArea: TrainingArea.all,
      reviewedAt: reviewedAt,
      sessionContext: SessionContext(
        sessionId: 'session-1',
        currentPosition: currentPosition,
        recentAnswers: const [],
        sameSessionWrongCountsByWordId: wrongCounts,
        remainingQueueSize: 12,
      ),
    );
  }

  ReviewResult reviewResult({
    SrsStage newStage = SrsStage.s1,
    int newPassCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    RequeueDecision? requeueDecision,
  }) {
    return ReviewResult(
      updatedProgress: WordProgress(
        wordId: 'word-1',
        categoryId: 'category-1',
        mode: LearningMode.time,
        stage: newStage,
        passCount: newPassCount,
        wrongCount: wrongCount,
        nextDueAt: nextDueAt,
        lastReviewedAt: reviewedAt,
      ),
      oldStage: SrsStage.s0,
      newStage: newStage,
      oldPassCount: 0,
      newPassCount: newPassCount,
      stageChanged: newStage != SrsStage.s0,
      nextDueAt: nextDueAt,
      requeueDecision: requeueDecision,
    );
  }

  group('SrsReviewPersistenceService', () {
    test('persist_review_result_updates_progress_and_writes_history', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedBaseData(db);
      final service = SrsReviewPersistenceService(database: db);
      final nextDueAt = reviewedAt.add(const Duration(days: 1));

      await service.persistReviewResult(
        reviewInput: reviewInput(),
        reviewResult: reviewResult(nextDueAt: nextDueAt),
        sessionItemId: 'item-1',
        nextPosition: 1,
      );

      final progress = (await db.query('word_progress')).single;
      expect(progress['stage'], SrsStage.s1.name);
      expect(progress['pass_count'], 0);
      expect(progress['wrong_count'], 0);
      expect(progress['next_due_at'], nextDueAt.toIso8601String());
      expect(progress['last_reviewed_at'], reviewedAt.toIso8601String());

      final history = (await db.query('review_history')).single;
      expect(history['word_id'], 'word-1');
      expect(history['category_id'], 'category-1');
      expect(history['mode_id'], LearningMode.time.name);
      expect(history['training_area_id'], TrainingArea.all.name);
      expect(history['session_id'], 'session-1');
      expect(history['answer'], ReviewAnswer.correct.name);
      expect(history['old_stage'], SrsStage.s0.name);
      expect(history['new_stage'], SrsStage.s1.name);
      expect(history['new_next_due_at'], nextDueAt.toIso8601String());
    });

    test('persist_review_result_marks_session_item_answered', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedBaseData(db);
      final service = SrsReviewPersistenceService(database: db);

      await service.persistReviewResult(
        reviewInput: reviewInput(),
        reviewResult: reviewResult(),
        sessionItemId: 'item-1',
        nextPosition: 1,
      );

      final item = (await db.query('session_items')).single;
      expect(item['status'], 'answered');
      expect(item['answered_at'], reviewedAt.toIso8601String());
      expect(item['updated_at'], reviewedAt.toIso8601String());
    });

    test('persist_review_result_adds_requeue_item_when_needed', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedBaseData(db);
      final service = SrsReviewPersistenceService(database: db);
      const requeueDecision = RequeueDecision(
        shouldRequeue: true,
        reason: RequeueReason.repeatedWrongAnswer,
        targetOffset: 5,
        effectiveOffset: 5,
        moveToQueueEnd: false,
        markDifficult: false,
        shouldRemoveFromReview: false,
      );

      await service.persistReviewResult(
        reviewInput: reviewInput(
          answer: ReviewAnswer.wrong,
          wrongCounts: const {'word-1': 1},
        ),
        reviewResult: reviewResult(
          newStage: SrsStage.s1,
          wrongCount: 1,
          requeueDecision: requeueDecision,
        ),
        sessionItemId: 'item-1',
        nextPosition: 1,
      );

      final items = await db.query('session_items', orderBy: 'position ASC');
      expect(items, hasLength(2));
      expect(items.first['status'], 'answered');
      expect(items.last['position'], 1);
      expect(items.last['status'], 'retryPending');
      expect(items.last['word_id'], 'word-1');
      expect(items.last['stage_at_enqueue'], SrsStage.s1.name);
      expect(
        items.last['requeue_reason'],
        RequeueReason.repeatedWrongAnswer.name,
      );
      expect(items.last['same_session_wrong_count'], 2);
      expect(items.last['retry_after_position'], 5);
    });

    test('persist_review_result_updates_current_position', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedBaseData(db);
      final service = SrsReviewPersistenceService(database: db);

      await service.persistReviewResult(
        reviewInput: reviewInput(),
        reviewResult: reviewResult(),
        sessionItemId: 'item-1',
        nextPosition: 3,
      );

      final session = (await db.query('learning_sessions')).single;
      expect(session['current_position'], 3);
      expect(session['last_activity_at'], reviewedAt.toIso8601String());
      expect(session['updated_at'], reviewedAt.toIso8601String());
    });

    test('persist_review_result_is_atomic_when_failure_occurs', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedBaseData(db);
      final service = SrsReviewPersistenceService(database: db);

      await expectLater(
        service.persistReviewResult(
          reviewInput: reviewInput(),
          reviewResult: reviewResult(),
          sessionItemId: 'missing-item',
          nextPosition: 1,
        ),
        throwsA(isA<StateError>()),
      );

      final progress = (await db.query('word_progress')).single;
      final history = await db.query('review_history');
      final item = (await db.query('session_items')).single;
      final session = (await db.query('learning_sessions')).single;

      expect(progress['stage'], SrsStage.s0.name);
      expect(progress['last_reviewed_at'], isNull);
      expect(history, isEmpty);
      expect(item['status'], 'queued');
      expect(item['answered_at'], isNull);
      expect(session['current_position'], 0);
    });
  });
}
