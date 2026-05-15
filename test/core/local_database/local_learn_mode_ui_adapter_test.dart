import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';

void main() {
  group('LocalLearnModeUiAdapter', () {
    test('local_learnmode_ui_adapter_maps_active_card', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        currentWordId: 'word-1',
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello there.',
        notes: 'Greeting',
        currentStage: SrsStage.s0,
        currentPosition: 1,
        totalItems: 3,
        answeredCount: 1,
        remainingCount: 2,
        canSubmitAnswer: true,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.startOrResume,
      );

      const adapter = LocalLearnModeUiAdapter();

      final uiState = adapter.map(viewModelState);

      expect(uiState.hasCard, isTrue);
      expect(uiState.term, viewModelState.term);
      expect(uiState.translation, viewModelState.translation);
      expect(uiState.exampleSentence, viewModelState.exampleSentence);
      expect(uiState.notes, viewModelState.notes);
      expect(uiState.currentStage, SrsStage.s0);
      expect(uiState.progressLabel, '1 / 3');
      expect(uiState.canSubmitAnswer, isTrue);
      expect(uiState.isCompleted, isFalse);
    });

    test('local_learnmode_ui_adapter_maps_loading_and_error', () {
      const loadingState = LocalLearningViewModelState(
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
      const errorState = LocalLearningViewModelState(
        isLoading: false,
        errorMessage: 'Local read failed.',
        hasSession: false,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.none,
      );

      const adapter = LocalLearnModeUiAdapter();

      final loadingUiState = adapter.map(loadingState);
      final errorUiState = adapter.map(errorState);

      expect(loadingUiState.isLoading, isTrue);
      expect(loadingUiState.hasCard, isFalse);
      expect(loadingUiState.canSubmitAnswer, isFalse);

      expect(errorUiState.errorMessage, errorState.errorMessage);
      expect(errorUiState.hasCard, isFalse);
      expect(errorUiState.canSubmitAnswer, isFalse);
    });

    test('local_learnmode_ui_adapter_maps_completed_state', () {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        currentPosition: 3,
        totalItems: 3,
        answeredCount: 3,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: true,
        lastAction: LocalLearningControllerAction.submitCorrect,
      );

      const adapter = LocalLearnModeUiAdapter();

      final uiState = adapter.map(viewModelState);

      expect(uiState.hasCard, isFalse);
      expect(uiState.canSubmitAnswer, isFalse);
      expect(uiState.isCompleted, isTrue);
      expect(uiState.progressLabel, '3 / 3');
      expect(uiState.term, isNull);
      expect(uiState.translation, isNull);
    });
  });
}
