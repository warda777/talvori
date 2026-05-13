import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_screen_contract.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  group('LocalLearningScreenContract', () {
    test('screen_contract_handles_empty_state', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: false,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.none,
      );

      final contract = LocalLearningScreenContract.fromViewModelState(
        viewModelState,
      );

      expect(contract.isInitial, isTrue);
      expect(contract.isLoading, isFalse);
      expect(contract.hasError, isFalse);
      expect(contract.hasActiveCard, isFalse);
      expect(contract.isCompleted, isFalse);
      expect(contract.canShowSubmitActions, isFalse);
    });

    test('screen_contract_handles_active_card', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        sessionId: 'active-session',
        categoryId: 'active-category',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        currentWordId: 'active-word',
        term: 'hello',
        translation: 'hallo',
        currentStage: SrsStage.s1,
        currentPosition: 2,
        totalItems: 20,
        answeredCount: 2,
        remainingCount: 18,
        canSubmitAnswer: true,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.startOrResume,
      );

      final contract = LocalLearningScreenContract.fromViewModelState(
        viewModelState,
      );

      expect(contract.isInitial, isFalse);
      expect(contract.isLoading, isFalse);
      expect(contract.hasError, isFalse);
      expect(contract.hasActiveCard, isTrue);
      expect(contract.isCompleted, isFalse);
      expect(contract.canShowSubmitActions, isTrue);
    });

    test('screen_contract_handles_completed_state', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        sessionId: 'completed-session',
        categoryId: 'completed-category',
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.reviewOnly,
        status: 'completed',
        currentWordId: null,
        currentPosition: 20,
        totalItems: 20,
        answeredCount: 20,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: true,
        lastAction: LocalLearningControllerAction.completeIfFinished,
      );

      final contract = LocalLearningScreenContract.fromViewModelState(
        viewModelState,
      );

      expect(contract.isInitial, isFalse);
      expect(contract.isLoading, isFalse);
      expect(contract.hasError, isFalse);
      expect(contract.hasActiveCard, isFalse);
      expect(contract.isCompleted, isTrue);
      expect(contract.canShowSubmitActions, isFalse);
    });

    test('screen_contract_handles_loading_state', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: true,
        hasSession: false,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.none,
      );

      final contract = LocalLearningScreenContract.fromViewModelState(
        viewModelState,
      );

      expect(contract.isLoading, isTrue);
      expect(contract.isInitial, isFalse);
      expect(contract.hasError, isFalse);
      expect(contract.hasActiveCard, isFalse);
      expect(contract.isCompleted, isFalse);
      expect(contract.canShowSubmitActions, isFalse);
    });

    test('screen_contract_handles_error_state', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        errorMessage: 'Something went wrong.',
        hasSession: false,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.startOrResume,
      );

      final contract = LocalLearningScreenContract.fromViewModelState(
        viewModelState,
      );

      expect(contract.hasError, isTrue);
      expect(contract.isInitial, isFalse);
      expect(contract.isLoading, viewModelState.isLoading);
      expect(contract.hasActiveCard, isFalse);
      expect(contract.isCompleted, isFalse);
      expect(contract.canShowSubmitActions, isFalse);
    });
  });
}
