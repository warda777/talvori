import 'package:flutter/material.dart';
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
import 'package:talvori/features/local_learning_debug/ui/local_learning_test_screen.dart';

void main() {
  group('LocalLearningTestScreen', () {
    testWidgets('local_learning_test_screen_renders_initial_state', (
      tester,
    ) async {
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
      const contract = LocalLearningScreenContract(
        isInitial: true,
        isLoading: false,
        hasError: false,
        hasActiveCard: false,
        isCompleted: false,
        canShowSubmitActions: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: const MaterialApp(
            home: LocalLearningTestScreen(categoryId: 'test-category'),
          ),
        ),
      );

      expect(find.text('Noch keine Session'), findsOneWidget);
      expect(find.text('Intensiv lernen'), findsWidgets);
      expect(find.text('Alles lernen'), findsOneWidget);
      expect(find.text('Starten/Fortsetzen'), findsOneWidget);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);
      expect(find.text('house'), findsNothing);
      expect(find.text('Haus'), findsNothing);
    });

    testWidgets(
      'local_learning_test_screen_start_button_calls_start_or_resume',
      (tester) async {
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
        const contract = LocalLearningScreenContract(
          isInitial: true,
          isLoading: false,
          hasError: false,
          hasActiveCard: false,
          isCompleted: false,
          canShowSubmitActions: false,
        );
        final fixedNow = DateTime(2026, 5, 13, 12);
        var callCount = 0;
        String? capturedCategoryId;
        LearningMode? capturedMode;
        TrainingArea? capturedTrainingArea;
        DateTime? capturedNow;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(viewModelState),
              localLearningScreenContractProvider.overrideWithValue(contract),
            ],
            child: MaterialApp(
              home: LocalLearningTestScreen(
                categoryId: 'test-category',
                nowProvider: () => fixedNow,
                onStartOrResume: ({
                  required categoryId,
                  required mode,
                  required trainingArea,
                  required now,
                }) async {
                  callCount += 1;
                  capturedCategoryId = categoryId;
                  capturedMode = mode;
                  capturedTrainingArea = trainingArea;
                  capturedNow = now;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Starten/Fortsetzen'));
        await tester.pump();

        expect(callCount, 1);
        expect(capturedCategoryId, 'test-category');
        expect(capturedMode, LearningMode.adaptive);
        expect(capturedTrainingArea, TrainingArea.all);
        expect(capturedNow, fixedNow);
      },
    );

    testWidgets('local_learning_test_screen_shows_active_card', (
      tester,
    ) async {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        sessionId: 'test-session',
        categoryId: 'test-category',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        currentWordId: 'test-word',
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello, how are you?',
        notes: 'Begrüßung',
        currentStage: SrsStage.s0,
        currentPosition: 0,
        totalItems: 3,
        answeredCount: 0,
        remainingCount: 3,
        canSubmitAnswer: true,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.startOrResume,
      );
      const contract = LocalLearningScreenContract(
        isInitial: false,
        isLoading: false,
        hasError: false,
        hasActiveCard: true,
        isCompleted: false,
        canShowSubmitActions: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: const MaterialApp(
            home: LocalLearningTestScreen(categoryId: 'test-category'),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('hallo'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.text('Begrüßung'), findsOneWidget);
      expect(find.text('Neu'), findsOneWidget);
      expect(find.text('Fortschritt: 0 / 3'), findsOneWidget);
      expect(find.text('Richtig'), findsOneWidget);
      expect(find.text('Falsch'), findsOneWidget);
    });

    testWidgets(
      'local_learning_test_screen_correct_button_calls_submit_correct',
      (tester) async {
        final fixedNow = DateTime(2026, 5, 13, 12, 30);
        var callCount = 0;
        DateTime? capturedNow;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(
                const LocalLearningViewModelState(
                  isLoading: false,
                  hasSession: true,
                  sessionId: 'test-session',
                  categoryId: 'test-category',
                  mode: LearningMode.adaptive,
                  trainingArea: TrainingArea.all,
                  status: 'active',
                  currentWordId: 'test-word',
                  term: 'hello',
                  translation: 'hallo',
                  currentStage: SrsStage.s0,
                  currentPosition: 0,
                  totalItems: 3,
                  answeredCount: 0,
                  remainingCount: 3,
                  canSubmitAnswer: true,
                  canCompleteSession: false,
                  lastAction: LocalLearningControllerAction.startOrResume,
                ),
              ),
              localLearningScreenContractProvider.overrideWithValue(
                const LocalLearningScreenContract(
                  isInitial: false,
                  isLoading: false,
                  hasError: false,
                  hasActiveCard: true,
                  isCompleted: false,
                  canShowSubmitActions: true,
                ),
              ),
            ],
            child: MaterialApp(
              home: LocalLearningTestScreen(
                categoryId: 'test-category',
                nowProvider: () => fixedNow,
                onSubmitCorrect: ({required now}) async {
                  callCount += 1;
                  capturedNow = now;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Richtig'));
        await tester.pump();

        expect(callCount, 1);
        expect(capturedNow, fixedNow);
      },
    );

    testWidgets(
      'local_learning_test_screen_wrong_button_calls_submit_wrong',
      (tester) async {
        final fixedNow = DateTime(2026, 5, 13, 12, 45);
        var callCount = 0;
        DateTime? capturedNow;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(
                const LocalLearningViewModelState(
                  isLoading: false,
                  hasSession: true,
                  sessionId: 'test-session',
                  categoryId: 'test-category',
                  mode: LearningMode.adaptive,
                  trainingArea: TrainingArea.all,
                  status: 'active',
                  currentWordId: 'test-word',
                  term: 'hello',
                  translation: 'hallo',
                  currentStage: SrsStage.s0,
                  currentPosition: 0,
                  totalItems: 3,
                  answeredCount: 0,
                  remainingCount: 3,
                  canSubmitAnswer: true,
                  canCompleteSession: false,
                  lastAction: LocalLearningControllerAction.startOrResume,
                ),
              ),
              localLearningScreenContractProvider.overrideWithValue(
                const LocalLearningScreenContract(
                  isInitial: false,
                  isLoading: false,
                  hasError: false,
                  hasActiveCard: true,
                  isCompleted: false,
                  canShowSubmitActions: true,
                ),
              ),
            ],
            child: MaterialApp(
              home: LocalLearningTestScreen(
                categoryId: 'test-category',
                nowProvider: () => fixedNow,
                onSubmitWrong: ({required now}) async {
                  callCount += 1;
                  capturedNow = now;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Falsch'));
        await tester.pump();

        expect(callCount, 1);
        expect(capturedNow, fixedNow);
      },
    );

    testWidgets(
      'local_learning_test_screen_buttons_follow_contract_flags',
      (tester) async {
        const viewModelState = LocalLearningViewModelState(
          isLoading: false,
          hasSession: true,
          sessionId: 'test-session',
          categoryId: 'test-category',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          status: 'active',
          currentWordId: 'test-word',
          term: 'hello',
          translation: 'hallo',
          currentStage: SrsStage.s0,
          currentPosition: 0,
          totalItems: 3,
          answeredCount: 0,
          remainingCount: 3,
          canSubmitAnswer: false,
          canCompleteSession: false,
          lastAction: LocalLearningControllerAction.startOrResume,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(viewModelState),
              localLearningScreenContractProvider.overrideWithValue(
                const LocalLearningScreenContract(
                  isInitial: false,
                  isLoading: false,
                  hasError: false,
                  hasActiveCard: true,
                  isCompleted: false,
                  canShowSubmitActions: false,
                ),
              ),
            ],
            child: const MaterialApp(
              home: LocalLearningTestScreen(categoryId: 'test-category'),
            ),
          ),
        );

        final disabledCorrectButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Richtig'),
        );
        final disabledWrongButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Falsch'),
        );

        expect(disabledCorrectButton.onPressed, isNull);
        expect(disabledWrongButton.onPressed, isNull);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(
                const LocalLearningViewModelState(
                  isLoading: false,
                  hasSession: true,
                  sessionId: 'test-session',
                  categoryId: 'test-category',
                  mode: LearningMode.adaptive,
                  trainingArea: TrainingArea.all,
                  status: 'active',
                  currentWordId: 'test-word',
                  term: 'hello',
                  translation: 'hallo',
                  currentStage: SrsStage.s0,
                  currentPosition: 0,
                  totalItems: 3,
                  answeredCount: 0,
                  remainingCount: 3,
                  canSubmitAnswer: true,
                  canCompleteSession: false,
                  lastAction: LocalLearningControllerAction.startOrResume,
                ),
              ),
              localLearningScreenContractProvider.overrideWithValue(
                const LocalLearningScreenContract(
                  isInitial: false,
                  isLoading: false,
                  hasError: false,
                  hasActiveCard: true,
                  isCompleted: false,
                  canShowSubmitActions: true,
                ),
              ),
            ],
            child: const MaterialApp(
              home: LocalLearningTestScreen(categoryId: 'test-category'),
            ),
          ),
        );

        final enabledCorrectButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Richtig'),
        );
        final enabledWrongButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Falsch'),
        );

        expect(enabledCorrectButton.onPressed, isNotNull);
        expect(enabledWrongButton.onPressed, isNotNull);
      },
    );

    testWidgets('local_learning_test_screen_handles_completed_state', (
      tester,
    ) async {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        hasSession: true,
        sessionId: 'test-session',
        categoryId: 'test-category',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'completed',
        currentPosition: 3,
        totalItems: 3,
        answeredCount: 3,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: true,
        lastAction: LocalLearningControllerAction.completeIfFinished,
      );
      const contract = LocalLearningScreenContract(
        isInitial: false,
        isLoading: false,
        hasError: false,
        hasActiveCard: false,
        isCompleted: true,
        canShowSubmitActions: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: const MaterialApp(
            home: LocalLearningTestScreen(categoryId: 'test-category'),
          ),
        ),
      );

      expect(find.text('Session abgeschlossen'), findsOneWidget);
      expect(find.text('Weitere Session starten'), findsOneWidget);
      expect(find.text('hello'), findsNothing);
      expect(find.text('hallo'), findsNothing);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);

      final nextSessionButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Weitere Session starten'),
      );

      expect(nextSessionButton.onPressed, isNull);
    });

    testWidgets(
      'local_learning_test_screen_complete_button_calls_complete_if_finished',
      (tester) async {
        final fixedNow = DateTime(2026, 5, 13, 13);
        var callCount = 0;
        DateTime? capturedNow;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(
                const LocalLearningViewModelState(
                  isLoading: false,
                  hasSession: true,
                  sessionId: 'test-session',
                  categoryId: 'test-category',
                  mode: LearningMode.adaptive,
                  trainingArea: TrainingArea.all,
                  status: 'active',
                  currentPosition: 3,
                  totalItems: 3,
                  answeredCount: 3,
                  remainingCount: 0,
                  canSubmitAnswer: false,
                  canCompleteSession: true,
                  lastAction: LocalLearningControllerAction.submitCorrect,
                ),
              ),
              localLearningScreenContractProvider.overrideWithValue(
                const LocalLearningScreenContract(
                  isInitial: false,
                  isLoading: false,
                  hasError: false,
                  hasActiveCard: false,
                  isCompleted: false,
                  canShowSubmitActions: false,
                ),
              ),
            ],
            child: MaterialApp(
              home: LocalLearningTestScreen(
                categoryId: 'test-category',
                nowProvider: () => fixedNow,
                onCompleteIfFinished: ({required now}) async {
                  callCount += 1;
                  capturedNow = now;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Session abschließen'));
        await tester.pump();

        expect(callCount, 1);
        expect(capturedNow, fixedNow);
      },
    );

    testWidgets('local_learning_test_screen_handles_loading_state', (
      tester,
    ) async {
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
      const contract = LocalLearningScreenContract(
        isInitial: false,
        isLoading: true,
        hasError: false,
        hasActiveCard: false,
        isCompleted: false,
        canShowSubmitActions: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: const MaterialApp(
            home: LocalLearningTestScreen(categoryId: 'test-category'),
          ),
        ),
      );

      expect(find.text('Lädt...'), findsOneWidget);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);
      expect(find.text('Noch keine Session'), findsNothing);
    });

    testWidgets('local_learning_test_screen_handles_error_state', (
      tester,
    ) async {
      const viewModelState = LocalLearningViewModelState(
        isLoading: false,
        errorMessage: 'debug failure',
        hasSession: false,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: false,
        lastAction: LocalLearningControllerAction.none,
      );
      const contract = LocalLearningScreenContract(
        isInitial: false,
        isLoading: false,
        hasError: true,
        hasActiveCard: false,
        isCompleted: false,
        canShowSubmitActions: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: const MaterialApp(
            home: LocalLearningTestScreen(categoryId: 'test-category'),
          ),
        ),
      );

      expect(find.text('Etwas ist schiefgelaufen'), findsOneWidget);
      expect(find.text('debug failure'), findsOneWidget);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);
      expect(find.text('Noch keine Session'), findsNothing);
    });
  });
}
