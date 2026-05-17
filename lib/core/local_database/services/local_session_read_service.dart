import '../models/local_session_read_state.dart';
import '../models/local_srs_session_state.dart';
import '../repositories/word_progress_repository.dart';
import '../repositories/word_repository.dart';
import '../../srs/models/srs_stage.dart';

class LocalSessionReadService {
  const LocalSessionReadService({
    required WordRepository wordRepository,
    required WordProgressRepository wordProgressRepository,
  }) : _wordRepository = wordRepository,
       _wordProgressRepository = wordProgressRepository;

  final WordRepository _wordRepository;
  final WordProgressRepository _wordProgressRepository;

  Future<LocalSessionReadState> buildReadState(
    LocalSrsSessionState sessionState,
  ) async {
    final currentWordId = sessionState.currentWordId;
    final stageCounts = await _wordProgressRepository.countByStage(
      categoryId: sessionState.categoryId,
      mode: sessionState.mode,
    );

    if (currentWordId == null) {
      return _fromSessionState(
        sessionState,
        stageCounts: stageCounts,
        canSubmitAnswer: false,
      );
    }

    final word = await _wordRepository.loadWordById(currentWordId);
    final progress = await _wordProgressRepository.loadProgress(
      wordId: currentWordId,
      categoryId: sessionState.categoryId,
      mode: sessionState.mode,
    );

    return _fromSessionState(
      sessionState,
      stageCounts: stageCounts,
      currentTerm: word?.term,
      currentTranslation: word?.translation,
      currentExampleSentence: word?.exampleSentence,
      currentNotes: word?.notes,
      currentStage: progress?.stage,
      canSubmitAnswer:
          sessionState.status == 'active' && sessionState.remainingCount > 0,
    );
  }

  LocalSessionReadState _fromSessionState(
    LocalSrsSessionState sessionState, {
    required List<int> stageCounts,
    String? currentTerm,
    String? currentTranslation,
    String? currentExampleSentence,
    String? currentNotes,
    SrsStage? currentStage,
    required bool canSubmitAnswer,
  }) {
    return LocalSessionReadState(
      sessionId: sessionState.sessionId,
      categoryId: sessionState.categoryId,
      mode: sessionState.mode,
      trainingArea: sessionState.trainingArea,
      status: sessionState.status,
      sessionSize: sessionState.sessionSize,
      currentPosition: sessionState.currentPosition,
      totalItems: sessionState.totalItems,
      answeredCount: sessionState.answeredCount,
      remainingCount: sessionState.remainingCount,
      stageCounts: stageCounts,
      currentWordId: sessionState.currentWordId,
      currentTerm: currentTerm,
      currentTranslation: currentTranslation,
      currentExampleSentence: currentExampleSentence,
      currentNotes: currentNotes,
      currentStage: currentStage,
      canSubmitAnswer: canSubmitAnswer,
      canCompleteSession: sessionState.canCompleteSession,
    );
  }
}
