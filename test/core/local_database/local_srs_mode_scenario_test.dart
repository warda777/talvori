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

  Future<void> insertWord(
    Database db,
    String id, {
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

  Future<void> insertProgress(
    Database db, {
    required String wordId,
    required LearningMode mode,
    String categoryId = 'category-1',
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
  }) async {
    await db.insert('word_progress', {
      'id': 'progress-$wordId-${mode.name}',
      'word_id': wordId,
      'category_id': categoryId,
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

  LocalSrsSessionService service(Database db) {
    return LocalSrsSessionService(
      wordProgressRepository: WordProgressRepository(database: db),
      reviewHistoryRepository: ReviewHistoryRepository(database: db),
      learningSessionRepository: LearningSessionRepository(database: db),
      reviewPersistenceService: SrsReviewPersistenceService(database: db),
    );
  }

  Future<Map<String, Object?>> progressRow(
    Database db, {
    required String wordId,
    required LearningMode mode,
    String categoryId = 'category-1',
  }) async {
    return (await db.query(
      'word_progress',
      where: 'word_id = ? AND category_id = ? AND mode_id = ?',
      whereArgs: [wordId, categoryId, mode.name],
    )).single;
  }

  Future<List<Map<String, Object?>>> sessionRows(Database db) {
    return db.query('learning_sessions', orderBy: 'created_at ASC');
  }

  Future<List<Map<String, Object?>>> sessionItemRows(
    Database db,
    String sessionId,
  ) {
    return db.query(
      'session_items',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'position ASC',
    );
  }

  List<String> queueOrder(List<Map<String, Object?>> rows) {
    return rows
        .map((row) => '${row['position']}:${row['word_id']}:${row['status']}')
        .toList(growable: false);
  }

  group('Local SRS mode scenarios', () {
    test('adaptive_session_continues_until_s5_and_can_reset_to_s0', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db, 'word-1');
      await insertProgress(db, wordId: 'word-1', mode: LearningMode.adaptive);

      final localService = service(db);
      var state = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
      );

      for (var index = 0; index < 11; index++) {
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(Duration(minutes: index + 1)),
        );
      }

      var row = await progressRow(
        db,
        wordId: 'word-1',
        mode: LearningMode.adaptive,
      );
      expect(row['stage'], SrsStage.s5.name);
      expect(row['pass_count'], 0);
      expect(state.currentWordId, isNull);
      expect(state.canCompleteSession, isTrue);

      final restarted = await localService.resetAndStartSession(
        categoryId: 'category-1',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 20)),
      );
      row = await progressRow(
        db,
        wordId: 'word-1',
        mode: LearningMode.adaptive,
      );
      expect(row['stage'], SrsStage.s0.name);
      expect(row['pass_count'], 0);
      expect(row['wrong_count'], 0);
      expect(row['next_due_at'], isNull);
      expect(restarted.currentWordId, 'word-1');
    });

    test(
      'hybrid_session_continues_through_s0_to_s3_then_waits_for_due',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, 'word-1');
        await insertProgress(db, wordId: 'word-1', mode: LearningMode.hybrid);

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

        final row = await progressRow(
          db,
          wordId: 'word-1',
          mode: LearningMode.hybrid,
        );
        expect(row['stage'], SrsStage.s3.name);
        expect(row['pass_count'], 0);
        expect(
          row['next_due_at'],
          now.add(const Duration(days: 1, minutes: 5)).toIso8601String(),
        );
        expect(state.currentWordId, isNull);
        expect(state.canCompleteSession, isTrue);

        final beforeDue = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.hybrid,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(hours: 12)),
        );
        expect(beforeDue.currentWordId, isNull);
      },
    );

    test(
      'time_session_respects_due_date_after_same_day_consolidation',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, 'word-1');
        await insertProgress(db, wordId: 'word-1', mode: LearningMode.time);

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

        var row = await progressRow(
          db,
          wordId: 'word-1',
          mode: LearningMode.time,
        );
        expect(row['stage'], SrsStage.s1.name);
        expect(row['pass_count'], 1);
        expect(state.currentWordId, isNull);

        final nextDay = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(days: 1, minutes: 3)),
        );
        expect(nextDay.currentWordId, 'word-1');

        await localService.submitAnswer(
          sessionId: nextDay.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(days: 1, minutes: 4)),
        );
        row = await progressRow(db, wordId: 'word-1', mode: LearningMode.time);
        expect(row['stage'], SrsStage.s2.name);
        expect(row['pass_count'], 0);
        expect(
          row['next_due_at'],
          now.add(const Duration(days: 4, minutes: 4)).toIso8601String(),
        );
      },
    );

    test(
      'requeue_scenario_positions_retries_and_keeps_difficult_open',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        for (var index = 1; index <= 14; index++) {
          await insertWord(db, 'word-$index');
          await insertProgress(
            db,
            wordId: 'word-$index',
            mode: LearningMode.time,
            stage: SrsStage.s2,
            nextDueAt: now,
          );
        }

        final localService = service(db);
        var state = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );

        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );
        var retryItems = await db.query(
          'session_items',
          where: 'word_id = ? AND requeue_reason = ?',
          whereArgs: ['word-1', RequeueReason.wrongAnswer.name],
        );
        expect(retryItems.single['position'], 10);
        expect(state.remainingCount, greaterThan(0));

        await db.update(
          'learning_sessions',
          {'current_position': 10},
          where: 'id = ?',
          whereArgs: [state.sessionId],
        );
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 2)),
        );
        retryItems = await db.query(
          'session_items',
          where: 'word_id = ? AND status IN (?, ?, ?)',
          whereArgs: [
            'word-1',
            QueueItemStatus.queued.name,
            QueueItemStatus.retryPending.name,
            QueueItemStatus.difficult.name,
          ],
        );
        expect(retryItems, hasLength(1));
        expect(
          retryItems.single['requeue_reason'],
          RequeueReason.repeatedWrongAnswer.name,
        );

        await db.update(
          'learning_sessions',
          {'current_position': retryItems.single['position']},
          where: 'id = ?',
          whereArgs: [state.sessionId],
        );
        state = await localService.submitAnswer(
          sessionId: state.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 3)),
        );
        final difficultItems = await db.query(
          'session_items',
          where: 'word_id = ? AND status = ?',
          whereArgs: ['word-1', QueueItemStatus.difficult.name],
        );
        expect(difficultItems, hasLength(1));
        expect(state.remainingCount, greaterThan(0));
        expect(state.canCompleteSession, isFalse);
      },
    );

    group('session manipulation protection', () {
      test(
        'active_session_survives_service_reload_with_same_queue_and_position',
        () async {
          final db = await openSchemaDatabase();
          addTearDown(db.close);
          await insertCategory(db);
          for (var index = 1; index <= 6; index++) {
            await insertWord(db, 'word-$index');
            await insertProgress(
              db,
              wordId: 'word-$index',
              mode: LearningMode.time,
              stage: SrsStage.s2,
              nextDueAt: now,
            );
          }

          var localService = service(db);
          var state = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
            now: now,
          );
          final originalSessionId = state.sessionId;
          final originalQueue = queueOrder(
            await sessionItemRows(db, originalSessionId),
          );

          state = await localService.submitAnswer(
            sessionId: state.sessionId,
            answer: ReviewAnswer.correct,
            now: now.add(const Duration(minutes: 1)),
          );
          expect(state.currentPosition, 1);

          localService = service(db);
          final resumed = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 2)),
          );
          final resumedQueue = queueOrder(
            await sessionItemRows(db, originalSessionId),
          );

          expect(resumed.sessionId, originalSessionId);
          expect(resumed.currentPosition, 1);
          expect(resumed.currentWordId, 'word-2');
          expect(resumedQueue, [
            '0:word-1:${QueueItemStatus.answered.name}',
            ...originalQueue.skip(1),
          ]);
          expect(await sessionRows(db), hasLength(1));
        },
      );

      test(
        'start_or_resume_multiple_times_does_not_create_second_active_session',
        () async {
          final db = await openSchemaDatabase();
          addTearDown(db.close);
          await insertCategory(db);
          for (var index = 1; index <= 4; index++) {
            await insertWord(db, 'word-$index');
            await insertProgress(
              db,
              wordId: 'word-$index',
              mode: LearningMode.adaptive,
            );
          }

          var localService = service(db);
          final first = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
          final firstQueue = queueOrder(
            await sessionItemRows(db, first.sessionId),
          );

          for (var index = 0; index < 3; index++) {
            localService = service(db);
            final resumed = await localService.startOrResumeSession(
              categoryId: 'category-1',
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now.add(Duration(minutes: index + 1)),
            );
            expect(resumed.sessionId, first.sessionId);
            expect(
              queueOrder(await sessionItemRows(db, first.sessionId)),
              firstQueue,
            );
          }

          final rows = await sessionRows(db);
          expect(rows, hasLength(1));
          expect(rows.single['status'], 'active');
        },
      );

      test('wrong_answer_requeue_survives_service_reload', () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        for (var index = 1; index <= 12; index++) {
          await insertWord(db, 'word-$index');
          await insertProgress(
            db,
            wordId: 'word-$index',
            mode: LearningMode.time,
            stage: SrsStage.s2,
            nextDueAt: now,
          );
        }

        var localService = service(db);
        final started = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );
        await localService.submitAnswer(
          sessionId: started.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );

        final requeueBeforeReload = (await db.query(
          'session_items',
          where: 'session_id = ? AND word_id = ? AND requeue_reason = ?',
          whereArgs: [
            started.sessionId,
            'word-1',
            RequeueReason.wrongAnswer.name,
          ],
        )).single;
        expect(requeueBeforeReload['position'], 10);
        expect(
          requeueBeforeReload['status'],
          QueueItemStatus.retryPending.name,
        );

        localService = service(db);
        final resumed = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 2)),
        );
        final requeueAfterReload = (await db.query(
          'session_items',
          where: 'session_id = ? AND word_id = ? AND requeue_reason = ?',
          whereArgs: [
            started.sessionId,
            'word-1',
            RequeueReason.wrongAnswer.name,
          ],
        )).single;
        final openWordOneItems = await db.query(
          'session_items',
          where: 'session_id = ? AND word_id = ? AND status IN (?, ?, ?, ?)',
          whereArgs: [
            started.sessionId,
            'word-1',
            QueueItemStatus.queued.name,
            QueueItemStatus.shown.name,
            QueueItemStatus.retryPending.name,
            QueueItemStatus.difficult.name,
          ],
        );

        expect(resumed.sessionId, started.sessionId);
        expect(requeueAfterReload['position'], requeueBeforeReload['position']);
        expect(requeueAfterReload['status'], requeueBeforeReload['status']);
        expect(openWordOneItems, hasLength(1));
        expect(resumed.remainingCount, greaterThan(0));
        expect(resumed.canCompleteSession, isFalse);
        expect(await sessionRows(db), hasLength(1));
      });

      test('session_context_is_isolated_by_mode_and_training_area', () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);
        await insertWord(db, 'word-1');
        for (final mode in LearningMode.values) {
          await insertProgress(db, wordId: 'word-1', mode: mode);
        }

        final localService = service(db);
        final timeAll = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now,
        );
        final timeAllAgain = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 1)),
        );
        final timeReviewOnly = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.time,
          trainingArea: TrainingArea.reviewOnly,
          now: now.add(const Duration(minutes: 2)),
        );
        final adaptiveAll = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 3)),
        );
        final hybridAll = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.hybrid,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 4)),
        );

        expect(timeAllAgain.sessionId, timeAll.sessionId);
        expect(timeReviewOnly.sessionId, isNot(timeAll.sessionId));
        expect(adaptiveAll.sessionId, isNot(timeAll.sessionId));
        expect(hybridAll.sessionId, isNot(timeAll.sessionId));

        final rows = await sessionRows(db);
        expect(rows, hasLength(4));
        expect(
          rows.map(
            (row) =>
                '${row['category_id']}:${row['mode_id']}:${row['training_area_id']}',
          ),
          containsAll([
            'category-1:${LearningMode.time.name}:${TrainingArea.all.name}',
            'category-1:${LearningMode.time.name}:${TrainingArea.reviewOnly.name}',
            'category-1:${LearningMode.adaptive.name}:${TrainingArea.all.name}',
            'category-1:${LearningMode.hybrid.name}:${TrainingArea.all.name}',
          ]),
        );
      });

      test(
        'completed_session_allows_new_session_but_active_resume_does_not_reset_progress',
        () async {
          final db = await openSchemaDatabase();
          addTearDown(db.close);
          await insertCategory(db);
          await insertWord(db, 'word-1');
          await insertProgress(
            db,
            wordId: 'word-1',
            mode: LearningMode.adaptive,
          );

          var localService = service(db);
          var state = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
          state = await localService.submitAnswer(
            sessionId: state.sessionId,
            answer: ReviewAnswer.correct,
            now: now.add(const Duration(minutes: 1)),
          );

          localService = service(db);
          final resumed = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 2)),
          );
          var row = await progressRow(
            db,
            wordId: 'word-1',
            mode: LearningMode.adaptive,
          );
          expect(resumed.sessionId, state.sessionId);
          expect(row['stage'], SrsStage.s1.name);
          expect(row['pass_count'], 0);

          for (var index = 0; index < 10; index++) {
            state = await localService.submitAnswer(
              sessionId: state.sessionId,
              answer: ReviewAnswer.correct,
              now: now.add(Duration(minutes: index + 3)),
            );
          }
          row = await progressRow(
            db,
            wordId: 'word-1',
            mode: LearningMode.adaptive,
          );
          expect(row['stage'], SrsStage.s5.name);

          final completed = await localService.startOrResumeSession(
            categoryId: 'category-1',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 20)),
          );
          expect(completed.status, 'completed');

          final restarted = await localService.resetAndStartSession(
            categoryId: 'category-1',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 21)),
          );
          row = await progressRow(
            db,
            wordId: 'word-1',
            mode: LearningMode.adaptive,
          );

          expect(restarted.sessionId, isNot(completed.sessionId));
          expect(restarted.currentWordId, 'word-1');
          expect(row['stage'], SrsStage.s0.name);
          expect(row['pass_count'], 0);
          expect(row['wrong_count'], 0);
          expect(row['next_due_at'], isNull);
          expect(await sessionRows(db), hasLength(2));
        },
      );
    });
  });
}
