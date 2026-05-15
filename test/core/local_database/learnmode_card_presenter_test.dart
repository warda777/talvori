import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/core/local_database/adapters/local_learn_mode_ui_adapter.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';

void main() {
  group('LearnModeCardPresenter', () {
    test('learnmode_card_presenter_maps_local_active_card', () {
      const uiState = LocalLearnModeUiState(
        isLoading: false,
        hasCard: true,
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello, how are you?',
        notes: 'Common greeting.',
        currentStage: SrsStage.s0,
        progressLabel: '1 / 3',
        canSubmitAnswer: true,
        isCompleted: false,
      );

      const presenter = LearnModeCardPresenter();

      final state = presenter.map(uiState);

      expect(state.hasCard, isTrue);
      expect(state.frontText, 'hello');
      expect(state.backText, 'hallo');
      expect(state.exampleSentence, 'Hello, how are you?');
      expect(state.notes, 'Common greeting.');
      expect(state.stageLabel, 's0');
      expect(state.progressLabel, '1 / 3');
      expect(state.canSubmitAnswer, isTrue);
      expect(state.isCompleted, isFalse);
    });

    test('learnmode_card_presenter_handles_empty_state', () {
      const uiState = LocalLearnModeUiState(
        isLoading: false,
        hasCard: false,
        progressLabel: '0 / 0',
        canSubmitAnswer: false,
        isCompleted: false,
      );

      const presenter = LearnModeCardPresenter();

      final state = presenter.map(uiState);

      expect(state.hasCard, isFalse);
      expect(state.frontText, isNull);
      expect(state.backText, isNull);
      expect(state.stageLabel, isNull);
      expect(state.canSubmitAnswer, isFalse);
      expect(state.isCompleted, isFalse);
    });

    test('learnmode_card_presenter_handles_completed_state', () {
      const uiState = LocalLearnModeUiState(
        isLoading: false,
        hasCard: false,
        progressLabel: '3 / 3',
        canSubmitAnswer: false,
        isCompleted: true,
      );

      const presenter = LearnModeCardPresenter();

      final state = presenter.map(uiState);

      expect(state.hasCard, isFalse);
      expect(state.isCompleted, isTrue);
      expect(state.progressLabel, '3 / 3');
      expect(state.canSubmitAnswer, isFalse);
      expect(state.frontText, isNull);
      expect(state.backText, isNull);
    });
  });
}
