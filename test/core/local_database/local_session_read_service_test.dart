import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/models/local_srs_session_state.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_session_read_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);
  const categoryId = 'category-basics';
  const wordId = 'word-house';

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  LocalSrsSessionState sessionState({
    String? currentWordId = wordId,
    String status = 'active',
    int remainingCount = 1,
    bool canCompleteSession = false,
  }) {
    return LocalSrsSessionState(
      sessionId: 'session-1',
      categoryId: categoryId,
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: status,
      sessionSize: 20,
      currentPosition: 0,
      totalItems: 1,
      answeredCount: 0,
      remainingCount: remainingCount,
      currentWordId: currentWordId,
      canCompleteSession: canCompleteSession,
    );
  }

  Future<LocalSessionReadService> seedService(Database db) async {
    final categoryRepository = CategoryRepository(database: db);
    final wordRepository = WordRepository(database: db);
    final progressRepository = WordProgressRepository(database: db);

    await categoryRepository.upsertCategory(
      id: categoryId,
      name: 'Basics',
      now: now,
    );
    await wordRepository.upsertWord(
      id: wordId,
      categoryId: categoryId,
      term: 'Haus',
      translation: 'house',
      exampleSentence: 'Das Haus ist klein.',
      notes: 'Noun',
      now: now,
    );
    await progressRepository.ensureProgressForWord(
      wordId: wordId,
      categoryId: categoryId,
      mode: LearningMode.adaptive,
      now: now,
    );

    return LocalSessionReadService(
      wordRepository: wordRepository,
      wordProgressRepository: progressRepository,
    );
  }

  Future<void> seedAdditionalWordAtStage(
    Database db, {
    required String wordId,
    required SrsStage stage,
  }) async {
    final wordRepository = WordRepository(database: db);
    final progressRepository = WordProgressRepository(database: db);

    await wordRepository.upsertWord(
      id: wordId,
      categoryId: categoryId,
      term: wordId,
      translation: 'translation-$wordId',
      now: now,
    );
    await progressRepository.ensureProgressForWord(
      wordId: wordId,
      categoryId: categoryId,
      mode: LearningMode.adaptive,
      now: now,
    );
    final progress = await progressRepository.loadProgress(
      wordId: wordId,
      categoryId: categoryId,
      mode: LearningMode.adaptive,
    );
    await progressRepository.saveProgress(
      updatedProgress: progress!.copyWith(stage: stage),
      updatedAt: now.add(const Duration(minutes: 1)),
    );
  }

  group('LocalSessionReadService', () {
    test('read_state_contains_current_word_data', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);

      final readState = await service.buildReadState(sessionState());

      expect(readState.sessionId, 'session-1');
      expect(readState.categoryId, categoryId);
      expect(readState.mode, LearningMode.adaptive);
      expect(readState.trainingArea, TrainingArea.all);
      expect(readState.currentWordId, wordId);
      expect(readState.currentTerm, 'Haus');
      expect(readState.currentTranslation, 'house');
      expect(readState.currentExampleSentence, 'Das Haus ist klein.');
      expect(readState.currentNotes, 'Noun');
      expect(readState.canSubmitAnswer, isTrue);
      expect(readState.canCompleteSession, isFalse);
    });

    test('read_state_contains_current_stage', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);

      final readState = await service.buildReadState(sessionState());

      expect(readState.currentStage, SrsStage.s0);
    });

    test('read_state_contains_stage_counts', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);
      await seedAdditionalWordAtStage(
        db,
        wordId: 'word-stage-0',
        stage: SrsStage.s0,
      );
      await seedAdditionalWordAtStage(
        db,
        wordId: 'word-stage-2',
        stage: SrsStage.s2,
      );

      final readState = await service.buildReadState(sessionState());

      expect(readState.stageCounts, [2, 0, 1, 0, 0, 0]);
    });

    test(
      'read_state_returns_null_word_fields_when_session_has_no_current_item',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final service = await seedService(db);

        final readState = await service.buildReadState(
          sessionState(
            currentWordId: null,
            remainingCount: 0,
            canCompleteSession: true,
          ),
        );

        expect(readState.currentWordId, isNull);
        expect(readState.currentTerm, isNull);
        expect(readState.currentTranslation, isNull);
        expect(readState.currentExampleSentence, isNull);
        expect(readState.currentNotes, isNull);
        expect(readState.currentStage, isNull);
        expect(readState.canSubmitAnswer, isFalse);
        expect(readState.canCompleteSession, isTrue);
      },
    );

    test('read_state_does_not_modify_progress_or_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final service = await seedService(db);
      await db.insert('learning_sessions', {
        'id': 'session-1',
        'category_id': categoryId,
        'mode_id': LearningMode.adaptive.name,
        'training_area_id': TrainingArea.all.name,
        'status': 'active',
        'session_size': 20,
        'current_position': 0,
        'started_at': now.toIso8601String(),
        'last_activity_at': now.toIso8601String(),
        'completed_at': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      await db.insert('session_items', {
        'id': 'session-item-1',
        'session_id': 'session-1',
        'word_id': wordId,
        'category_id': categoryId,
        'mode_id': LearningMode.adaptive.name,
        'stage_at_enqueue': SrsStage.s0.name,
        'position': 0,
        'status': 'queued',
        'is_new_card': 1,
        'due_at_enqueue': null,
        'retry_after_position': null,
        'requeue_reason': null,
        'same_session_wrong_count': 0,
        'shown_at': null,
        'answered_at': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final progressBefore = await db.query('word_progress');
      final sessionsBefore = await db.query('learning_sessions');
      final itemsBefore = await db.query('session_items');
      final historyBefore = await db.query('review_history');

      await service.buildReadState(sessionState());

      final progressAfter = await db.query('word_progress');
      final sessionsAfter = await db.query('learning_sessions');
      final itemsAfter = await db.query('session_items');
      final historyAfter = await db.query('review_history');

      expect(progressAfter, progressBefore);
      expect(sessionsAfter, sessionsBefore);
      expect(itemsAfter, itemsBefore);
      expect(historyAfter, historyBefore);
    });
  });
}
