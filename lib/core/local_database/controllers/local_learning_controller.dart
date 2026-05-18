import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/review_answer.dart';
import '../../srs/models/training_area.dart';
import '../models/local_review_visual_feedback.dart';
import '../models/local_session_read_state.dart';
import '../providers/local_bootstrap_provider.dart';

enum LocalLearningControllerAction {
  none,
  startOrResume,
  submitCorrect,
  submitWrong,
  completeIfFinished,
  resetAndStart,
}

class LocalLearningControllerState {
  const LocalLearningControllerState({
    this.isLoading = false,
    this.errorMessage,
    this.readState,
    this.lastReviewFeedback,
    this.lastAction = LocalLearningControllerAction.none,
  });

  final bool isLoading;
  final String? errorMessage;
  final LocalSessionReadState? readState;
  final LocalReviewVisualFeedback? lastReviewFeedback;
  final LocalLearningControllerAction lastAction;

  LocalLearningControllerState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    LocalSessionReadState? readState,
    LocalReviewVisualFeedback? lastReviewFeedback,
    bool clearLastReviewFeedback = false,
    LocalLearningControllerAction? lastAction,
  }) {
    return LocalLearningControllerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      readState: readState ?? this.readState,
      lastReviewFeedback: clearLastReviewFeedback
          ? null
          : (lastReviewFeedback ?? this.lastReviewFeedback),
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

final localLearningControllerProvider =
    NotifierProvider<LocalLearningController, LocalLearningControllerState>(
      LocalLearningController.new,
    );

class LocalLearningController extends Notifier<LocalLearningControllerState> {
  @override
  LocalLearningControllerState build() {
    return const LocalLearningControllerState();
  }

  Future<void> startOrResume({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final facade = await ref.read(localLearningSessionFacadeProvider.future);
      final readState = await facade.startOrResumeLearning(
        categoryId: categoryId,
        mode: mode,
        trainingArea: trainingArea,
        now: now,
        sessionSize: sessionSize,
      );

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        clearLastReviewFeedback: true,
        lastAction: LocalLearningControllerAction.startOrResume,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> resetAndStart({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final facade = await ref.read(localLearningSessionFacadeProvider.future);
      final readState = await facade.resetAndStartLearning(
        categoryId: categoryId,
        mode: mode,
        trainingArea: trainingArea,
        now: now,
        sessionSize: sessionSize,
      );

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        clearLastReviewFeedback: true,
        lastAction: LocalLearningControllerAction.resetAndStart,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> submitCorrect({required DateTime now}) async {
    final sessionId = state.readState?.sessionId;
    final reviewedWordId = state.readState?.currentWordId;
    if (sessionId == null) {
      state = state.copyWith(errorMessage: 'No active local session.');
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final facade = await ref.read(localLearningSessionFacadeProvider.future);
      final readState = await facade.submitAnswerAndReadNext(
        sessionId: sessionId,
        answer: ReviewAnswer.correct,
        now: now,
      );
      final feedback = reviewedWordId == null
          ? null
          : await _loadLatestFeedbackForWord(reviewedWordId);

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        lastReviewFeedback: feedback,
        lastAction: LocalLearningControllerAction.submitCorrect,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> submitWrong({required DateTime now}) async {
    final sessionId = state.readState?.sessionId;
    final reviewedWordId = state.readState?.currentWordId;
    if (sessionId == null) {
      state = state.copyWith(errorMessage: 'No active local session.');
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final facade = await ref.read(localLearningSessionFacadeProvider.future);
      final readState = await facade.submitAnswerAndReadNext(
        sessionId: sessionId,
        answer: ReviewAnswer.wrong,
        now: now,
      );
      final feedback = reviewedWordId == null
          ? null
          : await _loadLatestFeedbackForWord(reviewedWordId);

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        lastReviewFeedback: feedback,
        lastAction: LocalLearningControllerAction.submitWrong,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> completeIfFinished({required DateTime now}) async {
    final sessionId = state.readState?.sessionId;
    if (sessionId == null) {
      state = state.copyWith(errorMessage: 'No active local session.');
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final facade = await ref.read(localLearningSessionFacadeProvider.future);
      final readState = await facade.completeIfFinished(
        sessionId: sessionId,
        now: now,
      );

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        clearLastReviewFeedback: true,
        lastAction: LocalLearningControllerAction.completeIfFinished,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void clearForContext({
    required String categoryId,
    required LearningMode mode,
  }) {
    final readState = state.readState;
    if (readState == null) return;
    if (readState.categoryId != categoryId || readState.mode != mode) return;
    state = const LocalLearningControllerState();
  }

  Future<LocalReviewVisualFeedback?> _loadLatestFeedbackForWord(
    String wordId,
  ) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final events = await bootstrap.repositoryFactory.reviewHistoryRepository
        .loadHistoryForWord(wordId);
    if (events.isEmpty) {
      return null;
    }
    final event = events.last;
    final outcomeType = event.newStage.index > event.oldStage.index
        ? LocalReviewOutcomeType.promoted
        : event.newStage.index < event.oldStage.index
        ? LocalReviewOutcomeType.demoted
        : event.answer == ReviewAnswer.wrong
        ? LocalReviewOutcomeType.unchangedWrong
        : LocalReviewOutcomeType.repeatedSameStage;

    return LocalReviewVisualFeedback(
      wordId: event.wordId,
      sourceStage: event.oldStage,
      targetStage: event.newStage,
      outcomeType: outcomeType,
      repeatIndex: event.oldStage == event.newStage ? event.newPassCount : 0,
      wasPromoted: event.newStage.index > event.oldStage.index,
      wasDemoted: event.newStage.index < event.oldStage.index,
      timestamp: event.reviewedAt,
    );
  }
}
