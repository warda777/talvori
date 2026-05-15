import 'local_learn_mode_ui_adapter.dart';

class LearnModeCardPresenterState {
  const LearnModeCardPresenterState({
    required this.hasCard,
    required this.progressLabel,
    required this.canSubmitAnswer,
    required this.isCompleted,
    this.frontText,
    this.backText,
    this.exampleSentence,
    this.notes,
    this.stageLabel,
  });

  final bool hasCard;
  final String? frontText;
  final String? backText;
  final String? exampleSentence;
  final String? notes;
  final String? stageLabel;
  final String progressLabel;
  final bool canSubmitAnswer;
  final bool isCompleted;
}

class LearnModeCardPresenter {
  const LearnModeCardPresenter();

  LearnModeCardPresenterState map(LocalLearnModeUiState state) {
    return LearnModeCardPresenterState(
      hasCard: state.hasCard,
      frontText: state.term,
      backText: state.translation,
      exampleSentence: state.exampleSentence,
      notes: state.notes,
      stageLabel: state.currentStage?.name,
      progressLabel: state.progressLabel,
      canSubmitAnswer: state.canSubmitAnswer,
      isCompleted: state.isCompleted,
    );
  }
}
