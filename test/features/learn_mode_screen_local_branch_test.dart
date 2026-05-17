import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/plasma_link_painter.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';

class _TestLocalLearningController extends LocalLearningController {
  _TestLocalLearningController(this.initialState, {this.startedReadState});

  final LocalLearningControllerState initialState;
  final LocalSessionReadState? startedReadState;
  int startOrResumeCalls = 0;
  String? capturedCategoryId;
  int submitCorrectCalls = 0;
  int submitWrongCalls = 0;

  @override
  LocalLearningControllerState build() {
    return initialState;
  }

  @override
  Future<void> startOrResume({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    startOrResumeCalls += 1;
    capturedCategoryId = categoryId;
    state = state.copyWith(
      readState: startedReadState,
      lastAction: LocalLearningControllerAction.startOrResume,
    );
  }

  @override
  Future<void> submitCorrect({required DateTime now}) async {
    submitCorrectCalls += 1;
  }

  @override
  Future<void> submitWrong({required DateTime now}) async {
    submitWrongCalls += 1;
  }
}

void main() {
  testWidgets('learn_mode_screen_local_mode_opens_without_starting_old_flow', (
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLearningViewModelProvider.overrideWithValue(viewModelState),
        ],
        child: const MaterialApp(
          home: LearnModeScreen(
            categoryId: 'legacy-category',
            title: 'Basics',
            useLocalOfflineFlow: true,
            localCategoryId: 'basics',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Keine aktive lokale Session'), findsOneWidget);
    expect(find.text('Starten/Fortsetzen'), findsOneWidget);
  });

  testWidgets('learn_mode_screen_local_mode_shows_active_local_word_card', (
    tester,
  ) async {
    const viewModelState = LocalLearningViewModelState(
      isLoading: false,
      hasSession: true,
      currentWordId: 'word-1',
      term: 'hello',
      translation: 'hallo',
      currentStage: SrsStage.s0,
      currentPosition: 1,
      totalItems: 3,
      answeredCount: 0,
      remainingCount: 3,
      canSubmitAnswer: true,
      canCompleteSession: false,
      lastAction: LocalLearningControllerAction.none,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLearningViewModelProvider.overrideWithValue(viewModelState),
        ],
        child: const MaterialApp(
          home: LearnModeScreen(
            categoryId: 'legacy-category',
            title: 'Basics',
            useLocalOfflineFlow: true,
            localCategoryId: 'basics',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Keine aktive lokale Session'), findsNothing);
    expect(find.byType(StageSwitchRowView), findsOneWidget);

    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is PlasmaBandPainter,
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(SwipeableWordCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('hallo'), findsOneWidget);
  });

  testWidgets('learn_mode_screen_local_mode_swipe_right_submits_correct', (
    tester,
  ) async {
    const readState = LocalSessionReadState(
      sessionId: 'session-1',
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'active',
      sessionSize: 3,
      currentPosition: 1,
      totalItems: 3,
      answeredCount: 0,
      remainingCount: 3,
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-1',
      currentTerm: 'hello',
      currentTranslation: 'hallo',
      currentStage: SrsStage.s0,
    );
    final controller = _TestLocalLearningController(
      const LocalLearningControllerState(readState: readState),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLearningControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(
          home: LearnModeScreen(
            categoryId: 'legacy-category',
            title: 'Basics',
            useLocalOfflineFlow: true,
            localCategoryId: 'basics',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('hello'), findsOneWidget);

    await tester.drag(find.byType(SwipeableWordCard), const Offset(500, -40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.submitCorrectCalls, 1);
    expect(controller.submitWrongCalls, 0);

    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets(
    'learn_mode_screen_local_start_button_shows_card_when_local_words_exist',
    (tester) async {
      const readState = LocalSessionReadState(
        sessionId: 'session-1',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        sessionSize: 3,
        currentPosition: 1,
        totalItems: 3,
        answeredCount: 0,
        remainingCount: 3,
        canSubmitAnswer: true,
        canCompleteSession: false,
        currentWordId: 'word-1',
        currentTerm: 'hello',
        currentTranslation: 'hallo',
        currentStage: SrsStage.s0,
      );
      final controller = _TestLocalLearningController(
        const LocalLearningControllerState(),
        startedReadState: readState,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningControllerProvider.overrideWith(() => controller),
          ],
          child: const MaterialApp(
            home: LearnModeScreen(
              categoryId: 'seed-category-basics',
              title: 'Health & Fitness',
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Keine aktive lokale Session'), findsOneWidget);
      expect(find.text('Starten/Fortsetzen'), findsOneWidget);

      await tester.tap(find.text('Starten/Fortsetzen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.startOrResumeCalls, 1);
      expect(controller.capturedCategoryId, 'seed-category-basics');
      expect(find.byType(SwipeableWordCard), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('Keine aktive lokale Session'), findsNothing);
    },
  );

  testWidgets(
    'learn_mode_screen_local_start_button_shows_clear_empty_state_without_local_words',
    (tester) async {
      const readState = LocalSessionReadState(
        sessionId: 'empty-session',
        categoryId: 'basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        sessionSize: 20,
        currentPosition: 0,
        totalItems: 0,
        answeredCount: 0,
        remainingCount: 0,
        canSubmitAnswer: false,
        canCompleteSession: true,
      );
      final controller = _TestLocalLearningController(
        const LocalLearningControllerState(),
        startedReadState: readState,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningControllerProvider.overrideWith(() => controller),
          ],
          child: const MaterialApp(
            home: LearnModeScreen(
              categoryId: 'basics',
              title: 'Basics',
              useLocalOfflineFlow: true,
              localCategoryId: 'basics',
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Starten/Fortsetzen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.startOrResumeCalls, 1);
      expect(controller.capturedCategoryId, 'basics');
      expect(find.text('Keine lokalen Wörter verfügbar'), findsOneWidget);
      expect(find.byType(SwipeableWordCard), findsNothing);
    },
  );
}
