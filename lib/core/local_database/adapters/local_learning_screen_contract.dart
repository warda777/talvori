import 'local_learning_view_model_state.dart';

class LocalLearningScreenContract {
  const LocalLearningScreenContract({
    required this.isInitial,
    required this.isLoading,
    required this.hasError,
    required this.hasActiveCard,
    required this.isCompleted,
    required this.canShowSubmitActions,
  });

  final bool isInitial;
  final bool isLoading;
  final bool hasError;
  final bool hasActiveCard;
  final bool isCompleted;
  final bool canShowSubmitActions;

  factory LocalLearningScreenContract.fromViewModelState(
    LocalLearningViewModelState state,
  ) {
    final hasError = state.errorMessage != null;
    final hasActiveCard =
        state.hasSession &&
        state.currentWordId != null &&
        state.status == 'active';

    return LocalLearningScreenContract(
      isInitial: !state.hasSession && !state.isLoading && !hasError,
      isLoading: state.isLoading,
      hasError: hasError,
      hasActiveCard: hasActiveCard,
      isCompleted: state.status == 'completed',
      canShowSubmitActions: state.canSubmitAnswer && hasActiveCard,
    );
  }
}
