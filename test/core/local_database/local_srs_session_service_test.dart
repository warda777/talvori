import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/learning_session_repository.dart';
import 'package:talvori/core/local_database/repositories/review_history_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/services/local_srs_session_service.dart';
import 'package:talvori/core/local_database/services/srs_review_persistence_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
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
      'name': 'Basics',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> insertWord(Database db, {required String id}) async {
    await db.insert('words', {
      'id': id,
      'category_id': 'category-1',
      'term': id,
      'translation': 'translation-$id',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedWordProgress(
    Database db, {
    required String id,
    required String wordId,
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
  }) async {
    await db.insert('word_progress', {
      'id': id,
      'word_id': wordId,
      'category_id': 'category-1',
      'mode_id': LearningMode.time.name,
      'stage': stage.name,
      'pass_count': passCount,
      'wrong_count': wrongCount,
      'next_due_at': nextDueAt?.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedCategoryWordsAndProgress(Database db) async {
    await insertCategory(db);

    for (var index = 1; index <= 3; index++) {
      await insertWord(db, id: 'word-$index');
    }

    await seedWordProgress(
      db,
      id: 'progress-review',
      wordId: 'word-1',
      stage: SrsStage.s2,
      nextDueAt: now,
    );
    await seedWordProgress(db, id: 'progress-new-1', wordId: 'word-2');
    await seedWordProgress(db, id: 'progress-new-2', wordId: 'word-3');
  }

  LocalSrsSessionService service(Database db) {
    return LocalSrsSessionService(
      wordProgressRepository: WordProgressRepository(database: db),
      reviewHistoryRepository: ReviewHistoryRepository(database: db),
      learningSessionRepository: LearningSessionRepository(database: db),
      reviewPersistenceService: SrsReviewPersistenceService(database: db),
    );
  }

  group('LocalSrsSessionService', () {
    test(
      'start_or_resume_session_creates_new_session_when_none_exists',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);

        final state = await service(db).startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final sessions = await db.query('learning_sessions');
        final items = await db.query('session_items', orderBy: 'position ASC');

        expect(sessions, hasLength(1));
        expect(items, hasLength(3));
        expect(state.sessionId, sessions.single['id']);
        expect(state.categoryId, 'category-1');
        expect(state.mode, LearningMode.time);
        expect(state.trainingArea, TrainingArea.all);
        expect(state.status, 'active');
        expect(state.sessionSize, 20);
        expect(state.currentPosition, 0);
        expect(state.totalItems, 3);
        expect(state.answeredCount, 0);
        expect(state.remainingCount, 3);
        expect(state.currentWordId, 'word-1');
        expect(state.canCompleteSession, isFalse);
        expect(items.map((row) => row['word_id']), [
          'word-1',
          'word-2',
          'word-3',
        ]);
      },
    );

    test('start_or_resume_session_reuses_active_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategoryWordsAndProgress(db);
      final localService = service(db);

      final first = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final firstItems = await db.query(
        'session_items',
        orderBy: 'position ASC',
      );

      final second = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 5)),
      );
      final secondItems = await db.query(
        'session_items',
        orderBy: 'position ASC',
      );

      final sessions = await db.query('learning_sessions');

      expect(sessions, hasLength(1));
      expect(second.sessionId, first.sessionId);
      expect(second.totalItems, first.totalItems);
      expect(second.currentWordId, first.currentWordId);
      expect(
        secondItems.map((row) => row['id']),
        firstItems.map((row) => row['id']),
      );
    });

    test(
      'submit_answer_correct_updates_progress_history_item_and_position',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final state = await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 1)),
        );

        final progressRows = await db.query(
          'word_progress',
          where: 'word_id = ?',
          whereArgs: ['word-1'],
        );
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final sessionRows = await db.query('learning_sessions');

        expect(progressRows.single['stage'], SrsStage.s2.name);
        expect(progressRows.single['pass_count'], 1);
        expect(progressRows.single['last_reviewed_at'], isNotNull);
        expect(historyRows, hasLength(1));
        expect(historyRows.single['answer'], ReviewAnswer.correct.name);
        expect(historyRows.single['old_stage'], SrsStage.s2.name);
        expect(historyRows.single['new_stage'], SrsStage.s2.name);
        expect(itemRows, hasLength(3));
        expect(itemRows.first['status'], QueueItemStatus.answered.name);
        expect(itemRows.first['answered_at'], isNotNull);
        expect(sessionRows.single['current_position'], 1);
        expect(state.sessionId, started.sessionId);
        expect(state.currentPosition, 1);
        expect(state.totalItems, 3);
        expect(state.answeredCount, 1);
        expect(state.remainingCount, 2);
        expect(state.currentWordId, 'word-2');
        expect(state.canCompleteSession, isFalse);
      },
    );

    test(
      'submit_answer_wrong_updates_progress_history_item_position_and_adds_requeue_item',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final state = await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );

        final progressRows = await db.query(
          'word_progress',
          where: 'word_id = ?',
          whereArgs: ['word-1'],
        );
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final sessionRows = await db.query('learning_sessions');
        final originalItem = itemRows.first;
        final requeueItem = itemRows.last;

        expect(progressRows.single['stage'], SrsStage.s1.name);
        expect(progressRows.single['pass_count'], 0);
        expect(progressRows.single['wrong_count'], 1);
        expect(progressRows.single['last_reviewed_at'], isNotNull);
        expect(historyRows, hasLength(1));
        expect(historyRows.single['answer'], ReviewAnswer.wrong.name);
        expect(historyRows.single['old_stage'], SrsStage.s2.name);
        expect(historyRows.single['new_stage'], SrsStage.s1.name);
        expect(itemRows, hasLength(4));
        expect(originalItem['word_id'], 'word-1');
        expect(originalItem['status'], QueueItemStatus.answered.name);
        expect(originalItem['answered_at'], isNotNull);
        expect(requeueItem['word_id'], 'word-1');
        expect(requeueItem['position'], 3);
        expect(requeueItem['status'], QueueItemStatus.retryPending.name);
        expect(requeueItem['requeue_reason'], RequeueReason.wrongAnswer.name);
        expect(requeueItem['same_session_wrong_count'], 1);
        expect(sessionRows.single['current_position'], 1);
        expect(state.sessionId, started.sessionId);
        expect(state.currentPosition, 1);
        expect(state.totalItems, 4);
        expect(state.answeredCount, 1);
        expect(state.remainingCount, 3);
        expect(state.currentWordId, 'word-2');
        expect(state.canCompleteSession, isFalse);
      },
    );

    test(
      'submit_answer_focused_writes_history_and_session_without_changing_progress',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-focused',
          wordId: 'word-1',
          stage: SrsStage.s2,
          passCount: 1,
          wrongCount: 2,
          nextDueAt: now,
        );
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.focused,
          now: now,
        );

        final state = await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );

        final progressRows = await db.query(
          'word_progress',
          where: 'word_id = ?',
          whereArgs: ['word-1'],
        );
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final sessionRows = await db.query('learning_sessions');

        expect(progressRows.single['stage'], SrsStage.s2.name);
        expect(progressRows.single['pass_count'], 1);
        expect(progressRows.single['wrong_count'], 2);
        expect(progressRows.single['next_due_at'], now.toIso8601String());
        expect(progressRows.single['last_reviewed_at'], isNull);
        expect(progressRows.single['updated_at'], now.toIso8601String());
        expect(historyRows, hasLength(1));
        expect(historyRows.single['answer'], ReviewAnswer.wrong.name);
        expect(
          historyRows.single['training_area_id'],
          TrainingArea.focused.name,
        );
        expect(historyRows.single['old_stage'], SrsStage.s2.name);
        expect(historyRows.single['new_stage'], SrsStage.s2.name);
        expect(itemRows, hasLength(1));
        expect(itemRows.single['status'], QueueItemStatus.answered.name);
        expect(itemRows.single['answered_at'], isNotNull);
        expect(sessionRows.single['current_position'], 1);
        expect(state.sessionId, started.sessionId);
        expect(state.currentPosition, 1);
        expect(state.totalItems, 1);
        expect(state.answeredCount, 1);
        expect(state.remainingCount, 0);
        expect(state.currentWordId, isNull);
        expect(state.canCompleteSession, isTrue);
      },
    );

    test(
      'complete_session_if_finished_keeps_active_when_open_items_exist',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final state = await localService.completeSessionIfFinished(
          sessionId: started.sessionId,
          now: now.add(const Duration(minutes: 5)),
        );
        final sessionRows = await db.query('learning_sessions');

        expect(sessionRows.single['status'], 'active');
        expect(sessionRows.single['completed_at'], isNull);
        expect(state.status, 'active');
        expect(state.remainingCount, 3);
        expect(state.canCompleteSession, isFalse);
      },
    );

    test(
      'complete_session_if_finished_marks_completed_when_no_open_items_exist',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );
        final completedAt = now.add(const Duration(minutes: 5));

        await db.update('session_items', {
          'status': QueueItemStatus.answered.name,
          'answered_at': completedAt.toIso8601String(),
          'updated_at': completedAt.toIso8601String(),
        });

        final state = await localService.completeSessionIfFinished(
          sessionId: started.sessionId,
          now: completedAt,
        );
        final sessionRows = await db.query('learning_sessions');

        expect(sessionRows.single['status'], 'completed');
        expect(
          sessionRows.single['completed_at'],
          completedAt.toIso8601String(),
        );
        expect(state.status, 'completed');
        expect(state.remainingCount, 0);
        expect(state.canCompleteSession, isTrue);
      },
    );

    test(
      'completed_session_allows_new_active_session_for_same_context',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategoryWordsAndProgress(db);
        final localService = service(db);
        final first = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );
        final completedAt = now.add(const Duration(minutes: 5));

        await db.update('session_items', {
          'status': QueueItemStatus.answered.name,
          'answered_at': completedAt.toIso8601String(),
          'updated_at': completedAt.toIso8601String(),
        });
        final completed = await localService.completeSessionIfFinished(
          sessionId: first.sessionId,
          now: completedAt,
        );
        final second = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: completedAt.add(const Duration(minutes: 1)),
        );
        final sessionRows = await db.query('learning_sessions');

        expect(completed.status, 'completed');
        expect(second.sessionId, isNot(first.sessionId));
        expect(second.status, 'active');
        expect(sessionRows, hasLength(2));
        expect(
          sessionRows.where((row) => row['status'] == 'active'),
          hasLength(1),
        );
        expect(
          sessionRows.where((row) => row['status'] == 'completed'),
          hasLength(1),
        );
      },
    );
  });
}
