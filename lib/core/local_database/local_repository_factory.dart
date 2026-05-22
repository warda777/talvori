import 'package:sqflite/sqflite.dart';

import 'repositories/category_repository.dart';
import 'repositories/learning_session_repository.dart';
import 'repositories/review_history_repository.dart';
import 'repositories/word_progress_repository.dart';
import 'repositories/word_repository.dart';
import 'repositories/word_source_repository.dart';
import 'services/local_learning_session_facade.dart';
import 'services/local_progress_initialization_service.dart';
import 'services/local_session_read_service.dart';
import 'services/local_srs_session_service.dart';
import 'services/srs_review_persistence_service.dart';

class LocalRepositoryFactory {
  LocalRepositoryFactory({required Database database}) {
    categoryRepository = CategoryRepository(database: database);
    wordRepository = WordRepository(database: database);
    wordSourceRepository = WordSourceRepository(database: database);
    wordProgressRepository = WordProgressRepository(database: database);
    reviewHistoryRepository = ReviewHistoryRepository(database: database);
    learningSessionRepository = LearningSessionRepository(database: database);
    reviewPersistenceService = SrsReviewPersistenceService(database: database);
    progressInitializationService = LocalProgressInitializationService(
      wordRepository: wordRepository,
      wordProgressRepository: wordProgressRepository,
    );
    srsSessionService = LocalSrsSessionService(
      wordProgressRepository: wordProgressRepository,
      reviewHistoryRepository: reviewHistoryRepository,
      learningSessionRepository: learningSessionRepository,
      reviewPersistenceService: reviewPersistenceService,
    );
    sessionReadService = LocalSessionReadService(
      wordRepository: wordRepository,
      wordProgressRepository: wordProgressRepository,
    );
    learningSessionFacade = LocalLearningSessionFacade(
      progressInitializationService: progressInitializationService,
      srsSessionService: srsSessionService,
      sessionReadService: sessionReadService,
    );
  }

  late final CategoryRepository categoryRepository;
  late final WordRepository wordRepository;
  late final WordSourceRepository wordSourceRepository;
  late final WordProgressRepository wordProgressRepository;
  late final ReviewHistoryRepository reviewHistoryRepository;
  late final LearningSessionRepository learningSessionRepository;
  late final LocalProgressInitializationService progressInitializationService;
  late final SrsReviewPersistenceService reviewPersistenceService;
  late final LocalSrsSessionService srsSessionService;
  late final LocalSessionReadService sessionReadService;
  late final LocalLearningSessionFacade learningSessionFacade;
}
