import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learn_mode_screen.dart';

void main() {
  group('LocalLearnModeScreen', () {
    testWidgets('local_learnmode_screen_shows_active_card', (tester) async {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        currentWordId: 'word-1',
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello, how are you?',
        notes: 'Common greeting.',
        currentStage: SrsStage.s0,
        currentPosition: 1,
        totalItems: 3,
        answeredCount: 1,
        remainingCount: 2,
        canSubmitAnswer: true,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.startOrResume,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
          ],
          child: const MaterialApp(home: LocalLearnModeScreen()),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('hallo'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.text('Common greeting.'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('s0'), findsOneWidget);
    });

    testWidgets(
      'local_learnmode_screen_handles_loading_error_empty',
      (tester) async {
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
          errorMessage: 'Local session failed.',
          hasSession: false,
          currentPosition: 0,
          totalItems: 0,
          answeredCount: 0,
          remainingCount: 0,
          canSubmitAnswer: false,
          canCompleteSession: false,
          lastAction: LocalLearningControllerAction.none,
        );
        const emptyState = LocalLearningViewModelState(
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

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(loadingState),
            ],
            child: const MaterialApp(home: LocalLearnModeScreen()),
          ),
        );

        expect(find.text('Lädt...'), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(errorState),
            ],
            child: const MaterialApp(home: LocalLearnModeScreen()),
          ),
        );

        expect(find.text('Fehler'), findsOneWidget);
        expect(find.text('Local session failed.'), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(emptyState),
            ],
            child: const MaterialApp(home: LocalLearnModeScreen()),
          ),
        );

        expect(find.text('Keine aktive lokale Session'), findsOneWidget);
      },
    );

    testWidgets('local_learnmode_screen_handles_completed_state', (
      tester,
    ) async {
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
          ],
          child: const MaterialApp(home: LocalLearnModeScreen()),
        ),
      );

      expect(find.text('Session abgeschlossen'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('hello'), findsNothing);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);
    });
  });
}
