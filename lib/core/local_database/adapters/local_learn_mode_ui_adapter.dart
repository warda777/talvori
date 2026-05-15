import '../../srs/models/srs_stage.dart';
import 'local_learning_view_model_state.dart';

class LocalLearnModeUiState {
  const LocalLearnModeUiState({
    required this.isLoading,
    required this.hasCard,
    required this.progressLabel,
    required this.canSubmitAnswer,
    required this.isCompleted,
    this.errorMessage,
    this.term,
    this.translation,
    this.exampleSentence,
    this.notes,
    this.currentStage,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasCard;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final String? notes;
  final SrsStage? currentStage;
  final String progressLabel;
  final bool canSubmitAnswer;
  final bool isCompleted;
}

class LocalLearnModeUiAdapter {
  const LocalLearnModeUiAdapter();

  LocalLearnModeUiState map(LocalLearningViewModelState state) {
    final hasCard = state.currentWordId != null && state.term != null;
    final isCompleted =
        state.hasSession &&
        state.currentWordId == null &&
        state.totalItems > 0 &&
        state.remainingCount == 0;

    return LocalLearnModeUiState(
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      hasCard: hasCard,
      term: state.term,
      translation: state.translation,
      exampleSentence: state.exampleSentence,
      notes: state.notes,
      currentStage: state.currentStage,
      progressLabel: '${state.answeredCount} / ${state.totalItems}',
      canSubmitAnswer: state.canSubmitAnswer,
      isCompleted: isCompleted,
    );
  }
}
