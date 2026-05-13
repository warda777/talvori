import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/learning_session_repository.dart';
import 'package:talvori/core/local_database/repositories/review_history_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_progress_initialization_service.dart';
import 'package:talvori/core/local_database/services/local_srs_session_service.dart';
import 'package:talvori/core/local_database/services/srs_review_persistence_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
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

  LocalSrsSessionService sessionService(Database db) {
    return LocalSrsSessionService(
      wordProgressRepository: WordProgressRepository(database: db),
      reviewHistoryRepository: ReviewHistoryRepository(database: db),
      learningSessionRepository: LearningSessionRepository(database: db),
      reviewPersistenceService: SrsReviewPersistenceService(database: db),
    );
  }

  group('Local progress to session integration', () {
    test('initialized_progress_can_start_session_with_new_s0_cards', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final wordProgressRepository = WordProgressRepository(database: db);
      final progressInitializationService = LocalProgressInitializationService(
        wordRepository: wordRepository,
        wordProgressRepository: wordProgressRepository,
      );
      final localSessionService = sessionService(db);

      await categoryRepository.upsertCategory(
        id: categoryId,
        name: 'Basics',
        now: now,
      );
      for (var index = 1; index <= 5; index++) {
        await wordRepository.upsertWord(
          id: 'word-$index',
          categoryId: categoryId,
          term: 'Word $index',
          translation: 'Translation $index',
          sortOrder: index,
          now: now,
        );
      }

      await progressInitializationService.initializeProgressForCategoryAndMode(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        now: now,
      );

      final state = await localSessionService.startOrResumeSession(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now,
      );
      final resumed = await localSessionService.startOrResumeSession(
        categoryId: categoryId,
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        now: now.add(const Duration(minutes: 5)),
      );

      final sessions = await db.query('learning_sessions');
      final items = await db.query('session_items', orderBy: 'position ASC');
      final progressRows = await db.query(
        'word_progress',
        where: 'category_id = ? AND mode_id = ?',
        whereArgs: [categoryId, LearningMode.adaptive.name],
      );

      expect(sessions, hasLength(1));
      expect(sessions.single['status'], 'active');
      expect(state.sessionId, sessions.single['id']);
      expect(resumed.sessionId, state.sessionId);
      expect(state.status, 'active');
      expect(state.categoryId, categoryId);
      expect(state.mode, LearningMode.adaptive);
      expect(state.trainingArea, TrainingArea.all);
      expect(state.sessionSize, 20);
      expect(state.totalItems, greaterThan(0));
      expect(state.totalItems, lessThanOrEqualTo(20));
      expect(state.totalItems, items.length);
      expect(state.currentWordId, isNotNull);
      expect(state.remainingCount, greaterThan(0));
      expect(state.canCompleteSession, isFalse);

      expect(progressRows, hasLength(5));
      expect(items, isNotEmpty);
      expect(items.every((row) => row['category_id'] == categoryId), isTrue);
      expect(
        items.every((row) => row['mode_id'] == LearningMode.adaptive.name),
        isTrue,
      );
      expect(
        items.every((row) => row['stage_at_enqueue'] == SrsStage.s0.name),
        isTrue,
      );
      expect(items.every((row) => row['is_new_card'] == 1), isTrue);
      expect(
        items.every((row) => row['status'] == QueueItemStatus.queued.name),
        isTrue,
      );
      final progressWordIds = progressRows.map((row) => row['word_id']).toSet();
      final itemWordIds = items.map((row) => row['word_id']).toSet();
      expect(itemWordIds.every(progressWordIds.contains), isTrue);
      expect(
        progressRows.every((row) => row['stage'] == SrsStage.s0.name),
        isTrue,
      );
    });
  });
}
