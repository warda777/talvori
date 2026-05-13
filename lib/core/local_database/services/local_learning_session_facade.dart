import '../../srs/models/learning_mode.dart';
import '../../srs/models/review_answer.dart';
import '../../srs/models/training_area.dart';
import '../models/local_session_read_state.dart';
import 'local_progress_initialization_service.dart';
import 'local_session_read_service.dart';
import 'local_srs_session_service.dart';

class LocalLearningSessionFacade {
  const LocalLearningSessionFacade({
    required LocalProgressInitializationService progressInitializationService,
    required LocalSrsSessionService srsSessionService,
    required LocalSessionReadService sessionReadService,
  }) : _progressInitializationService = progressInitializationService,
       _srsSessionService = srsSessionService,
       _sessionReadService = sessionReadService;

  final LocalProgressInitializationService _progressInitializationService;
  final LocalSrsSessionService _srsSessionService;
  final LocalSessionReadService _sessionReadService;

  Future<LocalSessionReadState> startOrResumeLearning({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    await _progressInitializationService.initializeProgressForCategoryAndMode(
      categoryId: categoryId,
      mode: mode,
      now: now,
    );

    final sessionState = await _srsSessionService.startOrResumeSession(
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
      now: now,
      sessionSize: sessionSize ?? LocalSrsSessionService.defaultSessionSize,
    );

    return _sessionReadService.buildReadState(sessionState);
  }

  Future<LocalSessionReadState> submitAnswerAndReadNext({
    required String sessionId,
    required ReviewAnswer answer,
    required DateTime now,
  }) async {
    final sessionState = await _srsSessionService.submitAnswer(
      sessionId: sessionId,
      answer: answer,
      now: now,
    );

    return _sessionReadService.buildReadState(sessionState);
  }

  Future<LocalSessionReadState> completeIfFinished({
    required String sessionId,
    required DateTime now,
  }) async {
    final sessionState = await _srsSessionService.completeSessionIfFinished(
      sessionId: sessionId,
      now: now,
    );

    return _sessionReadService.buildReadState(sessionState);
  }
}
