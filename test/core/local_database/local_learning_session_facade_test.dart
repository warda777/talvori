import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/learning_session_repository.dart';
import 'package:talvori/core/local_database/repositories/review_history_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_learning_session_facade.dart';
import 'package:talvori/core/local_database/services/local_progress_initialization_service.dart';
import 'package:talvori/core/local_database/services/local_session_read_service.dart';
import 'package:talvori/core/local_database/services/local_srs_session_service.dart';
import 'package:talvori/core/local_database/services/srs_review_persistence_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);
  const categoryId = 'category-basics';

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<LocalLearningSessionFacade> seedFacade(Database db) async {
    final categoryRepository = CategoryRepository(database: db);
    final wordRepository = WordRepository(database: db);
    final wordProgressRepository = WordProgressRepository(database: db);

    await categoryRepository.upsertCategory(
      id: categoryId,
      name: 'Basics',
      now: now,
    );
    for (var index = 1; index <= 4; index++) {
      await wordRepository.upsertWord(
        id: 'word-$index',
        categoryId: categoryId,
        term: 'Term $index',
        translation: 'Translation $index',
        exampleSentence: 'Example sentence $index',
        notes: 'Notes $index',
        sortOrder: index,
        now: now,
      );
    }

    return LocalLearningSessionFacade(
      progressInitializationService: LocalProgressInitializationService(
        wordRepository: wordRepository,
        wordProgressRepository: wordProgressRepository,
      ),
      srsSessionService: LocalSrsSessionService(
        wordProgressRepository: wordProgressRepository,
        reviewHistoryRepository: ReviewHistoryRepository(database: db),
        learningSessionRepository: LearningSessionRepository(database: db),
        reviewPersistenceService: SrsReviewPersistenceService(database: db),
      ),
      sessionReadService: LocalSessionReadService(
        wordRepository: wordRepository,
        wordProgressRepository: wordProgressRepository,
      ),
    );
  }

  group('LocalLearningSessionFacade', () {
    test(
      'start_or_resume_learning_initializes_progress_starts_session_and_returns_read_state',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);

        final readState = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final progressRows = await db.query('word_progress');
        final sessionRows = await db.query('learning_sessions');
        final itemRows = await db.query('session_items');

        expect(progressRows, hasLength(4));
        expect(sessionRows, hasLength(1));
        expect(sessionRows.single['status'], 'active');
        expect(itemRows, isNotEmpty);
        expect(readState.sessionId, sessionRows.single['id']);
        expect(readState.currentWordId, isNotNull);
        expect(readState.currentTerm, isNotNull);
        expect(readState.currentTranslation, isNotNull);
        expect(readState.currentStage, SrsStage.s0);
        expect(readState.canSubmitAnswer, isTrue);
      },
    );

    test('start_or_resume_learning_reuses_existing_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final facade = await seedFacade(db);

      final first = await facade.startOrResumeLearning(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final second = await facade.startOrResumeLearning(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 5)),
      );

      final sessionRows = await db.query('learning_sessions');

      expect(sessionRows, hasLength(1));
      expect(second.sessionId, first.sessionId);
      expect(second.currentWordId, first.currentWordId);
      expect(second.currentTerm, first.currentTerm);
    });

    test(
      'start_or_resume_learning_does_not_create_duplicate_progress',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);

        await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );
        await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 5)),
        );

        final progressRows = await db.query('word_progress');
        final uniqueProgressKeys = progressRows
            .map(
              (row) =>
                  '${row['word_id']}_${row['category_id']}_${row['mode_id']}',
            )
            .toSet();

        expect(progressRows, hasLength(4));
        expect(uniqueProgressKeys, hasLength(4));
      },
    );

    test(
      'submit_answer_and_read_next_correct_returns_updated_read_state',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);
        final started = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final readState = await facade.submitAnswerAndReadNext(
          sessionId: started.sessionId,
          answer: ReviewAnswer.correct,
          now: now.add(const Duration(minutes: 1)),
        );

        final sessionRows = await db.query('learning_sessions');
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final requeueRows = await db.query(
          'session_items',
          where: 'requeue_reason IS NOT NULL',
        );

        expect(readState.sessionId, started.sessionId);
        expect(readState.answeredCount, started.answeredCount + 1);
        expect(readState.currentPosition, started.currentPosition + 1);
        expect(sessionRows, hasLength(1));
        expect(historyRows, hasLength(1));
        expect(historyRows.single['answer'], ReviewAnswer.correct.name);
        expect(itemRows.first['status'], QueueItemStatus.answered.name);
        expect(itemRows.first['answered_at'], isNotNull);
        expect(requeueRows, isEmpty);
      },
    );

    test(
      'submit_answer_and_read_next_wrong_returns_updated_read_state_with_requeue',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);
        final started = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final readState = await facade.submitAnswerAndReadNext(
          sessionId: started.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );

        final sessionRows = await db.query('learning_sessions');
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final requeueRows = await db.query(
          'session_items',
          where: 'requeue_reason IS NOT NULL',
        );

        expect(readState.sessionId, started.sessionId);
        expect(readState.answeredCount, started.answeredCount + 1);
        expect(readState.currentPosition, started.currentPosition + 1);
        expect(readState.remainingCount, greaterThanOrEqualTo(0));
        expect(sessionRows, hasLength(1));
        expect(historyRows, hasLength(1));
        expect(historyRows.single['answer'], ReviewAnswer.wrong.name);
        expect(itemRows.first['status'], QueueItemStatus.answered.name);
        expect(itemRows.first['answered_at'], isNotNull);
        expect(requeueRows, hasLength(1));
        expect(requeueRows.single['status'], QueueItemStatus.retryPending.name);
      },
    );

    test(
      'submit_answer_and_read_next_focused_does_not_change_progress',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);
        await db.insert('word_progress', {
          'id': 'progress-focused-word-1',
          'word_id': 'word-1',
          'category_id': categoryId,
          'mode_id': LearningMode.adaptive.name,
          'stage': SrsStage.s2.name,
          'pass_count': 1,
          'wrong_count': 0,
          'next_due_at': now.toIso8601String(),
          'last_reviewed_at': now
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        final started = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.focused,
          now: now,
        );
        final currentWordId = started.currentWordId!;
        final progressBefore = await db.query(
          'word_progress',
          where: 'word_id = ? AND category_id = ? AND mode_id = ?',
          whereArgs: [currentWordId, categoryId, LearningMode.adaptive.name],
          limit: 1,
        );

        final readState = await facade.submitAnswerAndReadNext(
          sessionId: started.sessionId,
          answer: ReviewAnswer.wrong,
          now: now.add(const Duration(minutes: 1)),
        );

        final progressAfter = await db.query(
          'word_progress',
          where: 'word_id = ? AND category_id = ? AND mode_id = ?',
          whereArgs: [currentWordId, categoryId, LearningMode.adaptive.name],
          limit: 1,
        );
        final sessionRows = await db.query('learning_sessions');
        final historyRows = await db.query('review_history');
        final itemRows = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final requeueRows = await db.query(
          'session_items',
          where: 'requeue_reason IS NOT NULL',
        );

        expect(readState, isA<LocalSessionReadState>());
        expect(readState.sessionId, started.sessionId);
        expect(readState.currentPosition, started.currentPosition + 1);
        expect(progressAfter.single['stage'], progressBefore.single['stage']);
        expect(
          progressAfter.single['pass_count'],
          progressBefore.single['pass_count'],
        );
        expect(
          progressAfter.single['next_due_at'],
          progressBefore.single['next_due_at'],
        );
        expect(sessionRows, hasLength(1));
        expect(historyRows, hasLength(1));
        expect(
          historyRows.single['training_area_id'],
          TrainingArea.focused.name,
        );
        expect(historyRows.single['answer'], ReviewAnswer.wrong.name);
        expect(itemRows.first['status'], QueueItemStatus.answered.name);
        expect(itemRows.first['answered_at'], isNotNull);
        expect(requeueRows, isEmpty);
      },
    );

    test('complete_if_finished_keeps_active_when_open_items_exist', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final facade = await seedFacade(db);
      final started = await facade.startOrResumeLearning(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final sessionRowsBefore = await db.query('learning_sessions');
      final itemRowsBefore = await db.query('session_items');

      final readState = await facade.completeIfFinished(
        sessionId: started.sessionId,
        now: now.add(const Duration(minutes: 1)),
      );

      final sessionRowsAfter = await db.query('learning_sessions');
      final itemRowsAfter = await db.query('session_items');
      final historyRows = await db.query('review_history');

      expect(readState, isA<LocalSessionReadState>());
      expect(readState.sessionId, started.sessionId);
      expect(readState.status, 'active');
      expect(readState.currentWordId, isNotNull);
      expect(readState.canSubmitAnswer, isTrue);
      expect(sessionRowsAfter, hasLength(sessionRowsBefore.length));
      expect(sessionRowsAfter.single['status'], 'active');
      expect(sessionRowsAfter.single['completed_at'], isNull);
      expect(itemRowsAfter, hasLength(itemRowsBefore.length));
      expect(historyRows, isEmpty);
    });

    test(
      'complete_if_finished_marks_completed_when_no_open_items_exist',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);
        final started = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );
        await db.update('session_items', {
          'status': QueueItemStatus.answered.name,
          'answered_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }, where: 'session_id = ?', whereArgs: [started.sessionId]);
        final sessionRowsBefore = await db.query('learning_sessions');
        final itemRowsBefore = await db.query('session_items');

        final readState = await facade.completeIfFinished(
          sessionId: started.sessionId,
          now: now.add(const Duration(minutes: 1)),
        );

        final sessionRowsAfter = await db.query('learning_sessions');
        final itemRowsAfter = await db.query('session_items');
        final historyRows = await db.query('review_history');

        expect(readState, isA<LocalSessionReadState>());
        expect(readState.sessionId, started.sessionId);
        expect(readState.status, 'completed');
        expect(readState.currentWordId, isNull);
        expect(readState.canSubmitAnswer, isFalse);
        expect(sessionRowsAfter, hasLength(sessionRowsBefore.length));
        expect(sessionRowsAfter.single['status'], 'completed');
        expect(sessionRowsAfter.single['completed_at'], isNotNull);
        expect(itemRowsAfter, hasLength(itemRowsBefore.length));
        expect(historyRows, isEmpty);
      },
    );

    test(
      'completed_session_allows_new_active_session_for_same_context',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final facade = await seedFacade(db);
        final firstSession = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );
        await db.update('session_items', {
          'status': QueueItemStatus.answered.name,
          'answered_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }, where: 'session_id = ?', whereArgs: [firstSession.sessionId]);

        final completedSession = await facade.completeIfFinished(
          sessionId: firstSession.sessionId,
          now: now.add(const Duration(minutes: 1)),
        );
        final secondSession = await facade.startOrResumeLearning(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now.add(const Duration(minutes: 2)),
        );

        final oldSessionRows = await db.query(
          'learning_sessions',
          where: 'id = ?',
          whereArgs: [firstSession.sessionId],
        );
        final activeSessionRows = await db.query(
          'learning_sessions',
          where:
              'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
          whereArgs: [
            categoryId,
            LearningMode.adaptive.name,
            TrainingArea.all.name,
            'active',
          ],
        );

        expect(completedSession.status, 'completed');
        expect(secondSession, isA<LocalSessionReadState>());
        expect(secondSession.sessionId, isNot(firstSession.sessionId));
        expect(secondSession.status, 'active');
        expect(secondSession.currentWordId, isNotNull);
        expect(secondSession.canSubmitAnswer, isTrue);
        expect(oldSessionRows.single['status'], 'completed');
        expect(activeSessionRows, hasLength(1));
        expect(activeSessionRows.single['id'], secondSession.sessionId);
      },
    );

    test('complete_if_finished_does_not_create_new_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final facade = await seedFacade(db);
      final started = await facade.startOrResumeLearning(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final sessionRowsBefore = await db.query('learning_sessions');
      final itemRowsBefore = await db.query('session_items');

      final readState = await facade.completeIfFinished(
        sessionId: started.sessionId,
        now: now.add(const Duration(minutes: 1)),
      );

      final sessionRowsAfter = await db.query('learning_sessions');
      final itemRowsAfter = await db.query('session_items');
      final historyRows = await db.query('review_history');

      expect(readState, isA<LocalSessionReadState>());
      expect(readState.sessionId, started.sessionId);
      expect(sessionRowsAfter, hasLength(sessionRowsBefore.length));
      expect(itemRowsAfter, hasLength(itemRowsBefore.length));
      expect(historyRows, isEmpty);
    });
  });
}
