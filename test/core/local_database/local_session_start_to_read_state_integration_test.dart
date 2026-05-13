import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/learning_session_repository.dart';
import 'package:talvori/core/local_database/repositories/review_history_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_progress_initialization_service.dart';
import 'package:talvori/core/local_database/services/local_session_read_service.dart';
import 'package:talvori/core/local_database/services/local_srs_session_service.dart';
import 'package:talvori/core/local_database/services/srs_review_persistence_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
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

  group('Local session start to read state integration', () {
    test(
      'started_session_can_build_read_state_with_word_data_and_stage',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final categoryRepository = CategoryRepository(database: db);
        final wordRepository = WordRepository(database: db);
        final wordProgressRepository = WordProgressRepository(database: db);
        final progressInitializationService =
            LocalProgressInitializationService(
              wordRepository: wordRepository,
              wordProgressRepository: wordProgressRepository,
            );
        final localSessionService = sessionService(db);
        final readService = LocalSessionReadService(
          wordRepository: wordRepository,
          wordProgressRepository: wordProgressRepository,
        );

        await categoryRepository.upsertCategory(
          id: categoryId,
          name: 'Basics',
          now: now,
        );
        for (var index = 1; index <= 3; index++) {
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

        await progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              now: now,
            );
        final sessionState = await localSessionService.startOrResumeSession(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          now: now,
        );

        final progressBefore = await db.query(
          'word_progress',
          orderBy: 'word_id ASC, mode_id ASC',
        );
        final sessionsBefore = await db.query(
          'learning_sessions',
          orderBy: 'id ASC',
        );
        final itemsBefore = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final historyBefore = await db.query('review_history');

        final readState = await readService.buildReadState(sessionState);

        final progressAfter = await db.query(
          'word_progress',
          orderBy: 'word_id ASC, mode_id ASC',
        );
        final sessionsAfter = await db.query(
          'learning_sessions',
          orderBy: 'id ASC',
        );
        final itemsAfter = await db.query(
          'session_items',
          orderBy: 'position ASC',
        );
        final historyAfter = await db.query('review_history');

        expect(readState.sessionId, sessionState.sessionId);
        expect(readState.currentWordId, isNotNull);
        expect(readState.currentTerm, isNotNull);
        expect(readState.currentTranslation, isNotNull);
        expect(readState.currentExampleSentence, isNotNull);
        expect(readState.currentNotes, isNotNull);
        expect(readState.currentStage, SrsStage.s0);
        expect(readState.canSubmitAnswer, isTrue);
        expect(readState.canCompleteSession, isFalse);

        final sessions = await db.query('learning_sessions');
        expect(sessions, hasLength(1));
        expect(progressAfter, progressBefore);
        expect(sessionsAfter, sessionsBefore);
        expect(itemsAfter, itemsBefore);
        expect(historyAfter, historyBefore);
      },
    );
  });
}
