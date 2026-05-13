import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_adapter.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  group('LocalLearningViewModelAdapter', () {
    test(
      'local_learning_view_model_adapter_maps_read_state_to_view_model_state',
      () {
        const readState = LocalSessionReadState(
          sessionId: 'session-1',
          categoryId: 'category-1',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          status: 'active',
          sessionSize: 20,
          currentPosition: 3,
          totalItems: 20,
          answeredCount: 3,
          remainingCount: 17,
          canSubmitAnswer: true,
          canCompleteSession: false,
          currentWordId: 'word-1',
          currentTerm: 'hello',
          currentTranslation: 'hallo',
          currentExampleSentence: 'Hello there.',
          currentNotes: 'Greeting',
          currentStage: SrsStage.s2,
        );
        const controllerState = LocalLearningControllerState(
          isLoading: false,
          errorMessage: null,
          readState: readState,
          lastAction: LocalLearningControllerAction.startOrResume,
        );

        const adapter = LocalLearningViewModelAdapter();

        final viewModelState = adapter.map(controllerState);

        expect(viewModelState.hasSession, isTrue);
        expect(viewModelState.isLoading, isFalse);
        expect(viewModelState.errorMessage, isNull);
        expect(viewModelState.sessionId, readState.sessionId);
        expect(viewModelState.categoryId, readState.categoryId);
        expect(viewModelState.mode, readState.mode);
        expect(viewModelState.trainingArea, readState.trainingArea);
        expect(viewModelState.status, readState.status);
        expect(viewModelState.currentWordId, readState.currentWordId);
        expect(viewModelState.term, readState.currentTerm);
        expect(viewModelState.translation, readState.currentTranslation);
        expect(
          viewModelState.exampleSentence,
          readState.currentExampleSentence,
        );
        expect(viewModelState.notes, readState.currentNotes);
        expect(viewModelState.currentStage, readState.currentStage);
        expect(viewModelState.currentPosition, readState.currentPosition);
        expect(viewModelState.totalItems, readState.totalItems);
        expect(viewModelState.answeredCount, readState.answeredCount);
        expect(viewModelState.remainingCount, readState.remainingCount);
        expect(viewModelState.canSubmitAnswer, readState.canSubmitAnswer);
        expect(viewModelState.canCompleteSession, readState.canCompleteSession);
        expect(
          viewModelState.lastAction,
          LocalLearningControllerAction.startOrResume,
        );
      },
    );

    test(
      'local_learning_view_model_adapter_handles_missing_read_state',
      () {
        const controllerState = LocalLearningControllerState(
          isLoading: true,
          errorMessage: 'No active local session.',
          readState: null,
          lastAction: LocalLearningControllerAction.submitCorrect,
        );

        const adapter = LocalLearningViewModelAdapter();

        final viewModelState = adapter.map(controllerState);

        expect(viewModelState.hasSession, isFalse);
        expect(viewModelState.sessionId, isNull);
        expect(viewModelState.categoryId, isNull);
        expect(viewModelState.mode, isNull);
        expect(viewModelState.trainingArea, isNull);
        expect(viewModelState.status, isNull);
        expect(viewModelState.currentWordId, isNull);
        expect(viewModelState.term, isNull);
        expect(viewModelState.translation, isNull);
        expect(viewModelState.exampleSentence, isNull);
        expect(viewModelState.notes, isNull);
        expect(viewModelState.currentStage, isNull);
        expect(viewModelState.currentPosition, 0);
        expect(viewModelState.totalItems, 0);
        expect(viewModelState.answeredCount, 0);
        expect(viewModelState.remainingCount, 0);
        expect(viewModelState.canSubmitAnswer, isFalse);
        expect(viewModelState.canCompleteSession, isFalse);
        expect(viewModelState.isLoading, controllerState.isLoading);
        expect(viewModelState.errorMessage, controllerState.errorMessage);
        expect(viewModelState.lastAction, controllerState.lastAction);
      },
    );

    test(
      'local_learning_view_model_adapter_exposes_loading_and_error',
      () {
        const controllerState = LocalLearningControllerState(
          isLoading: true,
          errorMessage: 'Local bootstrap failed.',
          lastAction: LocalLearningControllerAction.none,
        );

        const adapter = LocalLearningViewModelAdapter();

        final viewModelState = adapter.map(controllerState);

        expect(viewModelState.isLoading, isTrue);
        expect(viewModelState.errorMessage, controllerState.errorMessage);
      },
    );

    test(
      'local_learning_view_model_adapter_exposes_progress_counters_and_flags',
      () {
        const readState = LocalSessionReadState(
          sessionId: 'session-progress',
          categoryId: 'category-progress',
          mode: LearningMode.hybrid,
          trainingArea: TrainingArea.reviewOnly,
          status: 'active',
          sessionSize: 20,
          currentPosition: 7,
          totalItems: 18,
          answeredCount: 7,
          remainingCount: 11,
          canSubmitAnswer: false,
          canCompleteSession: true,
          currentWordId: 'word-progress',
          currentTerm: 'train',
          currentTranslation: 'Zug',
          currentStage: SrsStage.s4,
        );
        const controllerState = LocalLearningControllerState(
          readState: readState,
          lastAction: LocalLearningControllerAction.submitWrong,
        );

        const adapter = LocalLearningViewModelAdapter();

        final viewModelState = adapter.map(controllerState);

        expect(viewModelState.currentPosition, readState.currentPosition);
        expect(viewModelState.totalItems, readState.totalItems);
        expect(viewModelState.answeredCount, readState.answeredCount);
        expect(viewModelState.remainingCount, readState.remainingCount);
        expect(viewModelState.canSubmitAnswer, readState.canSubmitAnswer);
        expect(viewModelState.canCompleteSession, readState.canCompleteSession);
      },
    );

    test(
      'local_learning_view_model_adapter_does_not_require_supabase_or_word_user_view',
      () {
        const readState = LocalSessionReadState(
          sessionId: 'local-only-session',
          categoryId: 'local-only-category',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          status: 'active',
          sessionSize: 20,
          currentPosition: 0,
          totalItems: 3,
          answeredCount: 0,
          remainingCount: 3,
          canSubmitAnswer: true,
          canCompleteSession: false,
          currentWordId: 'local-only-word',
          currentTerm: 'book',
          currentTranslation: 'Buch',
          currentExampleSentence: 'The book is new.',
          currentNotes: 'Local model only',
          currentStage: SrsStage.s1,
        );
        const controllerState = LocalLearningControllerState(
          readState: readState,
          lastAction: LocalLearningControllerAction.startOrResume,
        );

        const adapter = LocalLearningViewModelAdapter();

        final viewModelState = adapter.map(controllerState);

        expect(viewModelState.hasSession, isTrue);
        expect(viewModelState.sessionId, readState.sessionId);
        expect(viewModelState.currentWordId, readState.currentWordId);
        expect(viewModelState.term, readState.currentTerm);
        expect(viewModelState.translation, readState.currentTranslation);
        expect(viewModelState.currentStage, readState.currentStage);
        expect(viewModelState.canSubmitAnswer, isTrue);
      },
    );
  });
}
