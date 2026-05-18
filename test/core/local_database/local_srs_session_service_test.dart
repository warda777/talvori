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
    LearningMode mode = LearningMode.time,
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
      'mode_id': mode.name,
      'stage': stage.name,
      'pass_count': passCount,
      'wrong_count': wrongCount,
      'next_due_at': nextDueAt?.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedNewWordsAndProgress(
    Database db, {
    required int count,
    LearningMode mode = LearningMode.time,
  }) async {
    await insertCategory(db);
    for (var index = 1; index <= count; index++) {
      final wordId = 'word-$index';
      await insertWord(db, id: wordId);
      await seedWordProgress(
        db,
        id: 'progress-$wordId-${mode.name}',
        wordId: wordId,
        mode: mode,
      );
    }
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
      'start_or_resume_session_replaces_active_session_with_finished_queue',
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

        await db.update(
          'session_items',
          {
            'status': QueueItemStatus.answered.name,
            'answered_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          where: 'session_id = ?',
          whereArgs: [first.sessionId],
        );

        final second = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 5)),
        );
        final sessionRows = await db.query('learning_sessions');

        expect(second.sessionId, isNot(first.sessionId));
        expect(second.status, 'active');
        expect(second.currentWordId, isNotNull);
        expect(sessionRows, hasLength(2));
        expect(
          sessionRows.where((row) => row['status'] == 'completed'),
          hasLength(1),
        );
        expect(
          sessionRows.where((row) => row['status'] == 'active'),
          hasLength(1),
        );
      },
    );

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
      'adaptive_submit_correct_requeues_non_s5_card_until_learning_continues',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-1',
          wordId: 'word-1',
          mode: LearningMode.adaptive,
          stage: SrsStage.s0,
        );
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final state = await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 1)),
        );
        final progressRows = await db.query('word_progress');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final sessionRows = await db.query('learning_sessions');

        expect(progressRows.single['stage'], SrsStage.s1.name);
        expect(itemRows, hasLength(2));
        expect(itemRows.first['status'], QueueItemStatus.answered.name);
        expect(itemRows.last['status'], QueueItemStatus.queued.name);
        expect(itemRows.last['stage_at_enqueue'], SrsStage.s1.name);
        expect(sessionRows.single['status'], 'active');
        expect(state.status, 'active');
        expect(state.currentWordId, 'word-1');
        expect(state.totalItems, 2);
        expect(state.remainingCount, 1);
        expect(state.canCompleteSession, isFalse);
      },
    );

    test(
      'adaptive_correct_continuation_returns_after_short_delay_in_large_queue',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedNewWordsAndProgress(
          db,
          count: 25,
          mode: LearningMode.adaptive,
        );
        final localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
          sessionSize: 25,
        );

        await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 1)),
        );

        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final wordOneRows = itemRows
            .where((row) => row['word_id'] == 'word-1')
            .toList(growable: false);

        expect(itemRows, hasLength(26));
        expect(wordOneRows, hasLength(2));
        expect(wordOneRows.first['status'], QueueItemStatus.answered.name);
        expect(wordOneRows.last['status'], QueueItemStatus.queued.name);
        expect(wordOneRows.last['position'], 9);
        expect(
          itemRows.take(25).map((row) => row['word_id']),
          contains('word-1'),
        );
        expect(itemRows.last['word_id'], isNot('word-1'));
      },
    );

    test('adaptive_correct_continuations_do_not_block_new_s0_cards', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedNewWordsAndProgress(db, count: 25, mode: LearningMode.adaptive);
      final localService = service(db);
      var state = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
        sessionSize: 25,
      );

      for (var index = 0; index < 12; index++) {
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(Duration(minutes: index + 1)),
        );
      }

      final answeredRows = await db.query(
        'session_items',
        where: 'status = ?',
        whereArgs: [QueueItemStatus.answered.name],
      );
      final distinctAnsweredWords = answeredRows
          .map((row) => row['word_id']! as String)
          .toSet();
      final openWordRows = await db.query(
        'session_items',
        where: 'status IN (?, ?, ?, ?)',
        whereArgs: [
          QueueItemStatus.queued.name,
          QueueItemStatus.shown.name,
          QueueItemStatus.retryPending.name,
          QueueItemStatus.difficult.name,
        ],
      );
      final openWordIds = openWordRows
          .map((row) => row['word_id']! as String)
          .toList(growable: false);

      expect(distinctAnsweredWords.length, greaterThan(7));
      expect(distinctAnsweredWords, contains('word-10'));
      expect(openWordIds.toSet(), hasLength(openWordIds.length));
    });

    test(
      'time_first_session_without_history_can_include_twenty_new_s0',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedNewWordsAndProgress(db, count: 25, mode: LearningMode.time);

        final state = await service(db).startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );
        final itemRows = await db.query('session_items');

        expect(state.totalItems, 20);
        expect(itemRows.where((row) => row['is_new_card'] == 1), hasLength(20));
      },
    );

    test('time_later_session_with_history_limits_new_s0_to_five', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedNewWordsAndProgress(db, count: 25, mode: LearningMode.time);
      await db.insert('review_history', {
        'id': 'history-1',
        'word_id': 'word-1',
        'category_id': 'category-1',
        'mode_id': LearningMode.time.name,
        'training_area_id': TrainingArea.all.name,
        'answer': ReviewAnswer.correct.name,
        'reviewed_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'old_stage': SrsStage.s0.name,
        'new_stage': SrsStage.s1.name,
        'old_pass_count': 0,
        'new_pass_count': 0,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      });

      final state = await service(db).startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final itemRows = await db.query('session_items');

      expect(state.totalItems, 5);
      expect(itemRows.where((row) => row['is_new_card'] == 1), hasLength(5));
    });

    test(
      'time_s0_to_s1_gets_same_day_consolidation_without_s2_promotion',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-1',
          wordId: 'word-1',
          mode: LearningMode.time,
          stage: SrsStage.s0,
        );
        final localService = service(db);
        var state = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 1)),
        );
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 2)),
        );

        final progressRows = await db.query('word_progress');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );

        expect(progressRows.single['stage'], SrsStage.s1.name);
        expect(progressRows.single['pass_count'], 1);
        expect(state.currentWordId, isNull);
        expect(state.canCompleteSession, isTrue);
        expect(itemRows, hasLength(2));
        expect(itemRows.last['stage_at_enqueue'], SrsStage.s1.name);
      },
    );

    test('hybrid_correct_continues_inside_session_until_s3', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db, id: 'word-1');
      await seedWordProgress(
        db,
        id: 'progress-1',
        wordId: 'word-1',
        mode: LearningMode.hybrid,
        stage: SrsStage.s0,
      );
      final localService = service(db);
      var state = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
        now: now,
      );

      for (var index = 0; index < 5; index++) {
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(Duration(minutes: index + 1)),
        );
      }

      final progressRows = await db.query('word_progress');
      final itemRows = await db.query('session_items', orderBy: 'position ASC');

      expect(progressRows.single['stage'], SrsStage.s3.name);
      expect(progressRows.single['next_due_at'], isNotNull);
      expect(state.currentWordId, isNull);
      expect(state.canCompleteSession, isTrue);
      expect(itemRows, hasLength(5));
    });

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
      'complete_session_if_finished_keeps_difficult_item_remaining',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-1',
          wordId: 'word-1',
          mode: LearningMode.adaptive,
          stage: SrsStage.s3,
        );
        await db.insert('learning_sessions', {
          'id': 'session-1',
          'category_id': 'category-1',
          'mode_id': LearningMode.adaptive.name,
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
          'mode_id': LearningMode.adaptive.name,
          'stage_at_enqueue': SrsStage.s3.name,
          'position': 0,
          'status': QueueItemStatus.difficult.name,
          'is_new_card': 0,
          'same_session_wrong_count': 3,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        final state = await service(db).completeSessionIfFinished(
          sessionId: 'session-1',
          now: now.add(const Duration(minutes: 1)),
        );
        final sessionRows = await db.query('learning_sessions');

        expect(sessionRows.single['status'], 'active');
        expect(state.status, 'active');
        expect(state.remainingCount, 1);
        expect(state.currentWordId, 'word-1');
        expect(state.canCompleteSession, isFalse);
      },
    );

    test('start_or_resume_session_keeps_difficult_item_open', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db, id: 'word-1');
      await seedWordProgress(
        db,
        id: 'progress-1',
        wordId: 'word-1',
        mode: LearningMode.adaptive,
        stage: SrsStage.s3,
      );
      await db.insert('learning_sessions', {
        'id': 'session-1',
        'category_id': 'category-1',
        'mode_id': LearningMode.adaptive.name,
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
        'mode_id': LearningMode.adaptive.name,
        'stage_at_enqueue': SrsStage.s3.name,
        'position': 0,
        'status': QueueItemStatus.difficult.name,
        'is_new_card': 0,
        'same_session_wrong_count': 3,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final state = await service(db).startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 1)),
      );
      final sessionRows = await db.query('learning_sessions');

      expect(sessionRows.single['status'], 'active');
      expect(state.sessionId, 'session-1');
      expect(state.remainingCount, 1);
      expect(state.currentWordId, 'word-1');
    });

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

    test(
      'finished_active_session_returns_completed_when_all_progress_is_s5',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-1',
          wordId: 'word-1',
          mode: LearningMode.adaptive,
          stage: SrsStage.s5,
          nextDueAt: now,
        );
        final localService = service(db);
        final first = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        await db.update(
          'session_items',
          {
            'status': QueueItemStatus.answered.name,
            'answered_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          where: 'session_id = ?',
          whereArgs: [first.sessionId],
        );

        final second = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 5)),
        );
        final sessionRows = await db.query('learning_sessions');

        expect(second.sessionId, first.sessionId);
        expect(second.status, 'completed');
        expect(second.currentWordId, isNull);
        expect(second.canCompleteSession, isTrue);
        expect(sessionRows, hasLength(1));
        expect(sessionRows.single['status'], 'completed');
      },
    );

    test(
      'reset_and_start_session_resets_s5_progress_and_starts_new_active_session',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, id: 'word-1');
        await seedWordProgress(
          db,
          id: 'progress-1',
          wordId: 'word-1',
          mode: LearningMode.adaptive,
          stage: SrsStage.s5,
          passCount: 5,
          wrongCount: 2,
          nextDueAt: now.add(const Duration(days: 7)),
          lastReviewedAt: now.subtract(const Duration(minutes: 5)),
        );
        final localService = service(db);
        final first = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        await db.update(
          'session_items',
          {
            'status': QueueItemStatus.answered.name,
            'answered_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          where: 'session_id = ?',
          whereArgs: [first.sessionId],
        );

        final restarted = await localService.resetAndStartSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 10)),
        );
        final progressRows = await db.query('word_progress');
        final sessionRows = await db.query('learning_sessions');
        final itemRows = await db.query(
          'session_items',
          where: 'session_id = ?',
          whereArgs: [restarted.sessionId],
        );

        expect(restarted.sessionId, isNot(first.sessionId));
        expect(restarted.status, 'active');
        expect(restarted.currentWordId, 'word-1');
        expect(restarted.remainingCount, 1);
        expect(restarted.canCompleteSession, isFalse);
        expect(progressRows.single['stage'], SrsStage.s0.name);
        expect(progressRows.single['pass_count'], 0);
        expect(progressRows.single['wrong_count'], 0);
        expect(progressRows.single['next_due_at'], isNull);
        expect(progressRows.single['last_reviewed_at'], isNull);
        expect(itemRows.single['stage_at_enqueue'], SrsStage.s0.name);
        expect(itemRows.single['status'], QueueItemStatus.queued.name);
        expect(sessionRows, hasLength(2));
        expect(
          sessionRows.where((row) => row['status'] == 'completed'),
          hasLength(1),
        );
        expect(
          sessionRows.where((row) => row['status'] == 'active'),
          hasLength(1),
        );
      },
    );
  });
}
