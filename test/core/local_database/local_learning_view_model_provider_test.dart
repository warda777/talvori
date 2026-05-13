import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

class _TestLocalLearningController extends LocalLearningController {
  _TestLocalLearningController(this.initialState);

  final LocalLearningControllerState initialState;

  @override
  LocalLearningControllerState build() {
    return initialState;
  }
}

void main() {
  group('localLearningViewModelProvider', () {
    test('local_learning_view_model_provider_maps_controller_state', () {
      const readState = LocalSessionReadState(
        sessionId: 'provider-session',
        categoryId: 'provider-category',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        sessionSize: 20,
        currentPosition: 4,
        totalItems: 20,
        answeredCount: 4,
        remainingCount: 16,
        canSubmitAnswer: true,
        canCompleteSession: false,
        currentWordId: 'provider-word',
        currentTerm: 'table',
        currentTranslation: 'Tisch',
        currentExampleSentence: 'The table is here.',
        currentNotes: 'Local provider test',
        currentStage: SrsStage.s3,
      );
      const controllerState = LocalLearningControllerState(
        isLoading: true,
        errorMessage: 'Provider test error.',
        readState: readState,
        lastAction: LocalLearningControllerAction.startOrResume,
      );
      final container = ProviderContainer(
        overrides: [
          localLearningControllerProvider.overrideWith(
            () => _TestLocalLearningController(controllerState),
          ),
        ],
      );

      addTearDown(container.dispose);

      final viewModelState = container.read(localLearningViewModelProvider);

      expect(viewModelState, isA<Object>());
      expect(viewModelState.hasSession, isTrue);
      expect(viewModelState.isLoading, controllerState.isLoading);
      expect(viewModelState.errorMessage, controllerState.errorMessage);
      expect(viewModelState.lastAction, controllerState.lastAction);
      expect(viewModelState.sessionId, readState.sessionId);
      expect(viewModelState.categoryId, readState.categoryId);
      expect(viewModelState.mode, readState.mode);
      expect(viewModelState.trainingArea, readState.trainingArea);
      expect(viewModelState.status, readState.status);
      expect(viewModelState.currentWordId, readState.currentWordId);
      expect(viewModelState.term, readState.currentTerm);
      expect(viewModelState.translation, readState.currentTranslation);
      expect(viewModelState.exampleSentence, readState.currentExampleSentence);
      expect(viewModelState.notes, readState.currentNotes);
      expect(viewModelState.currentStage, readState.currentStage);
      expect(viewModelState.currentPosition, readState.currentPosition);
      expect(viewModelState.totalItems, readState.totalItems);
      expect(viewModelState.answeredCount, readState.answeredCount);
      expect(viewModelState.remainingCount, readState.remainingCount);
      expect(viewModelState.canSubmitAnswer, readState.canSubmitAnswer);
      expect(viewModelState.canCompleteSession, readState.canCompleteSession);
    });

    test(
      'local_learning_view_model_provider_does_not_start_session_or_submit',
      () {
        const controllerState = LocalLearningControllerState(
          isLoading: false,
          readState: null,
          lastAction: LocalLearningControllerAction.none,
        );
        final container = ProviderContainer(
          overrides: [
            localLearningControllerProvider.overrideWith(
              () => _TestLocalLearningController(controllerState),
            ),
          ],
        );

        addTearDown(container.dispose);

        final viewModelState = container.read(localLearningViewModelProvider);

        expect(viewModelState.hasSession, isFalse);
        expect(viewModelState.sessionId, isNull);
        expect(viewModelState.currentWordId, isNull);
        expect(viewModelState.canSubmitAnswer, isFalse);
        expect(viewModelState.canCompleteSession, isFalse);
        expect(viewModelState.lastAction, controllerState.lastAction);
      },
    );
  });
}
