import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_screen_contract.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_screen_contract_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  group('localLearningScreenContractProvider', () {
    test(
      'local_learning_screen_contract_provider_maps_view_model_state',
      () {
        const viewModelState = LocalLearningViewModelState(
          isLoading: false,
          hasSession: true,
          sessionId: 'contract-provider-session',
          categoryId: 'contract-provider-category',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          status: 'active',
          currentWordId: 'contract-provider-word',
          term: 'house',
          translation: 'Haus',
          currentStage: SrsStage.s2,
          currentPosition: 1,
          totalItems: 20,
          answeredCount: 1,
          remainingCount: 19,
          canSubmitAnswer: true,
          canCompleteSession: false,
          lastAction: LocalLearningControllerAction.startOrResume,
        );
        final container = ProviderContainer(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
          ],
        );

        addTearDown(container.dispose);

        final contract = container.read(localLearningScreenContractProvider);

        expect(contract, isA<LocalLearningScreenContract>());
        expect(contract.hasActiveCard, isTrue);
        expect(contract.canShowSubmitActions, isTrue);
        expect(contract.isInitial, isFalse);
        expect(contract.isCompleted, isFalse);
        expect(contract.isLoading, isFalse);
        expect(contract.hasError, isFalse);
      },
    );

    test(
      'local_learning_screen_contract_provider_does_not_start_session_or_submit',
      () {
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
        final container = ProviderContainer(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
          ],
        );

        addTearDown(container.dispose);

        final contract = container.read(localLearningScreenContractProvider);

        expect(contract.isInitial, isTrue);
        expect(contract.hasActiveCard, isFalse);
        expect(contract.canShowSubmitActions, isFalse);
        expect(contract.isLoading, isFalse);
        expect(contract.hasError, isFalse);
        expect(contract.isCompleted, isFalse);
      },
    );
  });
}
