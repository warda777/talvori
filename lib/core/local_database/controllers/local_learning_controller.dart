import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/review_answer.dart';
import '../../srs/models/training_area.dart';
import '../models/local_session_read_state.dart';
import '../providers/local_bootstrap_provider.dart';

enum LocalLearningControllerAction {
  none,
  startOrResume,
  submitCorrect,
  submitWrong,
  completeIfFinished,
}

class LocalLearningControllerState {
  const LocalLearningControllerState({
    this.isLoading = false,
    this.errorMessage,
    this.readState,
    this.lastAction = LocalLearningControllerAction.none,
  });

  final bool isLoading;
  final String? errorMessage;
  final LocalSessionReadState? readState;
  final LocalLearningControllerAction lastAction;

  LocalLearningControllerState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    LocalSessionReadState? readState,
    LocalLearningControllerAction? lastAction,
  }) {
    return LocalLearningControllerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      readState: readState ?? this.readState,
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

final localLearningControllerProvider =
    NotifierProvider<LocalLearningController, LocalLearningControllerState>(
      LocalLearningController.new,
    );

class LocalLearningController
    extends Notifier<LocalLearningControllerState> {
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
        lastAction: LocalLearningControllerAction.startOrResume,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> submitCorrect({required DateTime now}) async {
    final sessionId = state.readState?.sessionId;
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

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        lastAction: LocalLearningControllerAction.submitCorrect,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> submitWrong({required DateTime now}) async {
    final sessionId = state.readState?.sessionId;
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

      state = state.copyWith(
        isLoading: false,
        readState: readState,
        lastAction: LocalLearningControllerAction.submitWrong,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
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
        lastAction: LocalLearningControllerAction.completeIfFinished,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
