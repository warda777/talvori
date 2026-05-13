import '../controllers/local_learning_controller.dart';
import 'local_learning_view_model_state.dart';

class LocalLearningViewModelAdapter {
  const LocalLearningViewModelAdapter();

  LocalLearningViewModelState map(
    LocalLearningControllerState controllerState,
  ) {
    final readState = controllerState.readState;

    return LocalLearningViewModelState(
      isLoading: controllerState.isLoading,
      errorMessage: controllerState.errorMessage,
      hasSession: readState != null,
      sessionId: readState?.sessionId,
      categoryId: readState?.categoryId,
      mode: readState?.mode,
      trainingArea: readState?.trainingArea,
      status: readState?.status,
      currentWordId: readState?.currentWordId,
      term: readState?.currentTerm,
      translation: readState?.currentTranslation,
      exampleSentence: readState?.currentExampleSentence,
      notes: readState?.currentNotes,
      currentStage: readState?.currentStage,
      currentPosition: readState?.currentPosition ?? 0,
      totalItems: readState?.totalItems ?? 0,
      answeredCount: readState?.answeredCount ?? 0,
      remainingCount: readState?.remainingCount ?? 0,
      canSubmitAnswer: readState?.canSubmitAnswer ?? false,
      canCompleteSession: readState?.canCompleteSession ?? false,
      lastAction: controllerState.lastAction,
    );
  }
}
