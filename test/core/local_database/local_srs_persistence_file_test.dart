import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_factory.dart';
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
  databaseFactory = databaseFactoryFfi;

  final now = DateTime(2026, 5, 13, 10);

  Future<Directory> createTempDatabaseDir() {
    return Directory.systemTemp.createTemp('talvori_srs_file_persistence_');
  }

  String databasePathFor(Directory directory) {
    return '${directory.path}/talvori_local_v1.db';
  }

  Future<Database> openFileDatabase(String path) {
    return const LocalDatabaseFactory().openAtPath(path);
  }

  LocalSrsSessionService service(Database db) {
    return LocalSrsSessionService(
      wordProgressRepository: WordProgressRepository(database: db),
      reviewHistoryRepository: ReviewHistoryRepository(database: db),
      learningSessionRepository: LearningSessionRepository(database: db),
      reviewPersistenceService: SrsReviewPersistenceService(database: db),
    );
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

  Future<Map<String, Object?>> progressRow(
    Database db, {
    required String wordId,
    required LearningMode mode,
  }) async {
    return (await db.query(
      'word_progress',
      where: 'word_id = ? AND category_id = ? AND mode_id = ?',
      whereArgs: [wordId, 'category-1', mode.name],
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

  group('Local SRS file persistence', () {
    test('active_session_survives_database_close_and_reopen', () async {
      final tempDir = await createTempDatabaseDir();
      final databasePath = databasePathFor(tempDir);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var db = await openFileDatabase(databasePath);
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
      state = await localService.submitAnswer(
        sessionId: state.sessionId,
        answer: ReviewAnswer.correct,
        now: now.add(const Duration(minutes: 1)),
      );
      final sessionId = state.sessionId;
      final queueAfterAnswer = queueOrder(await sessionItemRows(db, sessionId));
      final currentPositionAfterAnswer = state.currentPosition;

      await db.close();
      db = await openFileDatabase(databasePath);
      addTearDown(db.close);
      localService = service(db);
      final resumed = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 2)),
      );

      expect(resumed.sessionId, sessionId);
      expect(resumed.currentPosition, currentPositionAfterAnswer);
      expect(resumed.currentWordId, 'word-2');
      expect(
        queueOrder(await sessionItemRows(db, sessionId)),
        queueAfterAnswer,
      );
      expect(await sessionRows(db), hasLength(1));
    });

    test('wrong_requeue_survives_database_close_and_reopen', () async {
      final tempDir = await createTempDatabaseDir();
      final databasePath = databasePathFor(tempDir);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var db = await openFileDatabase(databasePath);
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
      final requeueBeforeReopen = (await db.query(
        'session_items',
        where: 'session_id = ? AND word_id = ? AND requeue_reason = ?',
        whereArgs: [
          started.sessionId,
          'word-1',
          RequeueReason.wrongAnswer.name,
        ],
      )).single;

      await db.close();
      db = await openFileDatabase(databasePath);
      addTearDown(db.close);
      localService = service(db);
      final resumed = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 2)),
      );
      final requeueAfterReopen = (await db.query(
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
      expect(requeueAfterReopen['position'], requeueBeforeReopen['position']);
      expect(requeueAfterReopen['status'], requeueBeforeReopen['status']);
      expect(
        requeueAfterReopen['same_session_wrong_count'],
        requeueBeforeReopen['same_session_wrong_count'],
      );
      expect(openWordOneItems, hasLength(1));
      expect(resumed.remainingCount, greaterThan(0));
      expect(resumed.canCompleteSession, isFalse);
      expect(await sessionRows(db), hasLength(1));
    });

    test('progress_values_survive_database_close_and_reopen', () async {
      final tempDir = await createTempDatabaseDir();
      final databasePath = databasePathFor(tempDir);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var db = await openFileDatabase(databasePath);
      await insertCategory(db);
      await insertWord(db, 'word-1');
      await insertProgress(db, wordId: 'word-1', mode: LearningMode.time);
      var localService = service(db);
      final started = await localService.startOrResumeSession(
        categoryId: 'category-1',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        now: now,
      );
      await localService.submitAnswer(
        sessionId: started.sessionId,
        answer: ReviewAnswer.correct,
        now: now.add(const Duration(minutes: 1)),
      );
      final progressBeforeReopen = await progressRow(
        db,
        wordId: 'word-1',
        mode: LearningMode.time,
      );

      await db.close();
      db = await openFileDatabase(databasePath);
      addTearDown(db.close);
      final progressAfterReopen = await progressRow(
        db,
        wordId: 'word-1',
        mode: LearningMode.time,
      );

      expect(progressAfterReopen['stage'], progressBeforeReopen['stage']);
      expect(
        progressAfterReopen['pass_count'],
        progressBeforeReopen['pass_count'],
      );
      expect(
        progressAfterReopen['wrong_count'],
        progressBeforeReopen['wrong_count'],
      );
      expect(
        progressAfterReopen['next_due_at'],
        progressBeforeReopen['next_due_at'],
      );
      expect(progressAfterReopen['stage'], SrsStage.s1.name);
    });

    test(
      'completed_session_survives_reopen_until_explicit_reset_starts_new_session',
      () async {
        final tempDir = await createTempDatabaseDir();
        final databasePath = databasePathFor(tempDir);
        addTearDown(() async {
          await databaseFactoryFfi.deleteDatabase(databasePath);
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        var db = await openFileDatabase(databasePath);
        await insertCategory(db);
        await insertWord(db, 'word-1');
        await insertProgress(db, wordId: 'word-1', mode: LearningMode.adaptive);
        var localService = service(db);
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
        final completed = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 20)),
        );
        expect(completed.status, 'completed');
        final completedSessionId = completed.sessionId;

        await db.close();
        db = await openFileDatabase(databasePath);
        addTearDown(db.close);
        localService = service(db);
        final completedRows = await db.query(
          'learning_sessions',
          where: 'id = ?',
          whereArgs: [completedSessionId],
        );
        expect(completedRows.single['status'], 'completed');

        final stillCompleted = await localService.startOrResumeSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 21)),
        );
        expect(stillCompleted.sessionId, completedSessionId);
        expect(stillCompleted.status, 'completed');

        final newSession = await localService.resetAndStartSession(
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 22)),
        );
        final rows = await sessionRows(db);

        expect(newSession.sessionId, isNot(completedSessionId));
        expect(newSession.status, 'active');
        expect(newSession.currentWordId, 'word-1');
        expect(rows, hasLength(2));
        expect(rows.where((row) => row['status'] == 'completed'), hasLength(1));
        expect(rows.where((row) => row['status'] == 'active'), hasLength(1));
      },
    );
  });
}
