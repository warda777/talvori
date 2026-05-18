import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_review_visual_feedback.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/models/local_stage_inspector_item.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/plasma_link_painter.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';
import 'package:talvori/features/words/ui/widgets/switch_pulse_painter.dart';
import 'package:talvori/features/words/ui/widgets/vertical_stage_switch.dart';

class _TestLocalLearningController extends LocalLearningController {
  _TestLocalLearningController(
    this.initialState, {
    this.startedReadState,
    this.correctReadState,
    this.wrongReadState,
    this.correctFeedback,
    this.wrongFeedback,
  });

  final LocalLearningControllerState initialState;
  final LocalSessionReadState? startedReadState;
  final LocalSessionReadState? correctReadState;
  final LocalSessionReadState? wrongReadState;
  final LocalReviewVisualFeedback? correctFeedback;
  final LocalReviewVisualFeedback? wrongFeedback;
  int startOrResumeCalls = 0;
  int resetAndStartCalls = 0;
  String? capturedCategoryId;
  LearningMode? capturedMode;
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
    capturedMode = mode;
    state = state.copyWith(
      readState: startedReadState,
      lastAction: LocalLearningControllerAction.startOrResume,
    );
  }

  @override
  Future<void> resetAndStart({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    resetAndStartCalls += 1;
    capturedCategoryId = categoryId;
    capturedMode = mode;
    state = state.copyWith(
      readState: startedReadState,
      lastAction: LocalLearningControllerAction.resetAndStart,
    );
  }

  @override
  Future<void> submitCorrect({required DateTime now}) async {
    submitCorrectCalls += 1;
    if (correctReadState != null) {
      state = state.copyWith(
        readState: correctReadState,
        lastReviewFeedback: correctFeedback,
        lastAction: LocalLearningControllerAction.submitCorrect,
      );
    }
  }

  @override
  Future<void> submitWrong({required DateTime now}) async {
    submitWrongCalls += 1;
    if (wrongReadState != null) {
      state = state.copyWith(
        readState: wrongReadState,
        lastReviewFeedback: wrongFeedback,
        lastAction: LocalLearningControllerAction.submitWrong,
      );
    }
  }
}

void _expectActiveSwitchPulse(
  WidgetTester tester, {
  required int stage,
  required Color color,
}) {
  final row = tester.widget<StageSwitchRowView>(
    find.byType(StageSwitchRowView),
  );
  expect(row.activePulseStage, stage);
  expect(row.activePulseColor, color);
  final highlightedSwitches = tester
      .widgetList<VerticalStageSwitch>(find.byType(VerticalStageSwitch))
      .where((switchWidget) => switchWidget.pulseColor == color);
  expect(highlightedSwitches, hasLength(1));
}

void _expectNoActiveSwitchPulse(WidgetTester tester) {
  final row = tester.widget<StageSwitchRowView>(
    find.byType(StageSwitchRowView),
  );
  expect(row.activePulseStage, isNull);
  final highlightedSwitches = tester
      .widgetList<VerticalStageSwitch>(find.byType(VerticalStageSwitch))
      .where((switchWidget) => switchWidget.pulseColor != null);
  expect(highlightedSwitches, isEmpty);
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
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      currentWordId: 'word-1',
      term: 'hello',
      translation: 'hallo',
      currentStage: SrsStage.s0,
      currentPosition: 1,
      totalItems: 3,
      answeredCount: 0,
      remainingCount: 3,
      stageCounts: [3, 0, 0, 0, 0, 0],
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
    expect(find.text('hello'), findsWidgets);
    expect(find.text('Keine aktive lokale Session'), findsNothing);
    expect(find.byType(StageSwitchRowView), findsOneWidget);
    final stageRow = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    expect(stageRow.counts, [3, 0, 0, 0, 0, 0]);

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

    expect(find.text('hello'), findsWidgets);

    await tester.drag(find.byType(SwipeableWordCard), const Offset(500, -40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.submitCorrectCalls, 1);
    expect(controller.submitWrongCalls, 0);

    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('learn_mode_screen_local_mode_swipe_left_submits_wrong', (
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
      stageCounts: [0, 0, 1, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-1',
      currentTerm: 'hello',
      currentTranslation: 'hallo',
      currentStage: SrsStage.s2,
    );
    const wrongReadState = LocalSessionReadState(
      sessionId: 'session-1',
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'active',
      sessionSize: 3,
      currentPosition: 2,
      totalItems: 3,
      answeredCount: 1,
      remainingCount: 2,
      stageCounts: [0, 1, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-2',
      currentTerm: 'water',
      currentTranslation: 'Wasser',
      currentStage: SrsStage.s1,
    );
    final controller = _TestLocalLearningController(
      const LocalLearningControllerState(readState: readState),
      wrongReadState: wrongReadState,
      wrongFeedback: LocalReviewVisualFeedback(
        wordId: 'word-1',
        sourceStage: SrsStage.s2,
        targetStage: SrsStage.s1,
        outcomeType: LocalReviewOutcomeType.demoted,
        repeatIndex: 0,
        wasPromoted: false,
        wasDemoted: true,
        timestamp: DateTime(2026, 1, 1),
      ),
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

    await tester.drag(find.byType(SwipeableWordCard), const Offset(-500, -40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.submitCorrectCalls, 0);
    expect(controller.submitWrongCalls, 1);
    expect(find.text('water'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SwitchPulsePainter,
      ),
      findsOneWidget,
    );
    final wrongPulse = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SwitchPulsePainter,
      ),
    );
    expect(
      (wrongPulse.painter! as SwitchPulsePainter).color,
      const Color(0xFFFF4B6E),
    );
    _expectActiveSwitchPulse(tester, stage: 1, color: const Color(0xFFFF4B6E));

    await tester.pump(const Duration(milliseconds: 2200));
    _expectNoActiveSwitchPulse(tester);
  });

  testWidgets('learn_mode_screen_local_mode_uses_updated_stage_counts', (
    tester,
  ) async {
    const initialReadState = LocalSessionReadState(
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
      stageCounts: [3, 0, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-1',
      currentTerm: 'hello',
      currentTranslation: 'hallo',
      currentStage: SrsStage.s0,
    );
    const updatedReadState = LocalSessionReadState(
      sessionId: 'session-1',
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'active',
      sessionSize: 3,
      currentPosition: 2,
      totalItems: 3,
      answeredCount: 1,
      remainingCount: 2,
      stageCounts: [2, 1, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-2',
      currentTerm: 'water',
      currentTranslation: 'Wasser',
      currentStage: SrsStage.s1,
    );
    final controller = _TestLocalLearningController(
      const LocalLearningControllerState(readState: initialReadState),
      correctReadState: updatedReadState,
      correctFeedback: LocalReviewVisualFeedback(
        wordId: 'word-1',
        sourceStage: SrsStage.s0,
        targetStage: SrsStage.s1,
        outcomeType: LocalReviewOutcomeType.promoted,
        repeatIndex: 0,
        wasPromoted: true,
        wasDemoted: false,
        timestamp: DateTime(2026, 1, 1),
      ),
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

    expect(
      tester.widget<StageSwitchRowView>(find.byType(StageSwitchRowView)).counts,
      [3, 0, 0, 0, 0, 0],
    );

    await tester.drag(find.byType(SwipeableWordCard), const Offset(500, -40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.submitCorrectCalls, 1);
    expect(find.text('water'), findsOneWidget);
    expect(
      tester.widget<StageSwitchRowView>(find.byType(StageSwitchRowView)).counts,
      [2, 1, 0, 0, 0, 0],
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SwitchPulsePainter,
      ),
      findsOneWidget,
    );
    final promotionPulse = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SwitchPulsePainter,
      ),
    );
    expect(
      (promotionPulse.painter! as SwitchPulsePainter).color,
      const Color(0xFF36F58A),
    );
    _expectActiveSwitchPulse(tester, stage: 1, color: const Color(0xFF36F58A));

    await tester.pump(const Duration(milliseconds: 2200));
    _expectNoActiveSwitchPulse(tester);
  });

  testWidgets('learn_mode_screen_local_repeat_pulse_uses_repeat_color', (
    tester,
  ) async {
    const initialReadState = LocalSessionReadState(
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
      stageCounts: [0, 1, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-1',
      currentTerm: 'hello',
      currentTranslation: 'hallo',
      currentStage: SrsStage.s1,
    );
    const updatedReadState = LocalSessionReadState(
      sessionId: 'session-1',
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'active',
      sessionSize: 3,
      currentPosition: 2,
      totalItems: 3,
      answeredCount: 1,
      remainingCount: 2,
      stageCounts: [0, 1, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-2',
      currentTerm: 'water',
      currentTranslation: 'Wasser',
      currentStage: SrsStage.s1,
    );
    final controller = _TestLocalLearningController(
      const LocalLearningControllerState(readState: initialReadState),
      correctReadState: updatedReadState,
      correctFeedback: LocalReviewVisualFeedback(
        wordId: 'word-1',
        sourceStage: SrsStage.s1,
        targetStage: SrsStage.s1,
        outcomeType: LocalReviewOutcomeType.repeatedSameStage,
        repeatIndex: 1,
        wasPromoted: false,
        wasDemoted: false,
        timestamp: DateTime(2026, 1, 1),
      ),
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
    await tester.drag(find.byType(SwipeableWordCard), const Offset(500, -40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final repeatPulse = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is SwitchPulsePainter,
      ),
    );
    expect(
      (repeatPulse.painter! as SwitchPulsePainter).color,
      const Color(0xFF5DDCFF),
    );
    _expectActiveSwitchPulse(tester, stage: 1, color: const Color(0xFF5DDCFF));
    await tester.pump(const Duration(milliseconds: 2200));
    _expectNoActiveSwitchPulse(tester);
  });

  testWidgets('learn_mode_local_stage_switch_opens_stage_inspector', (
    tester,
  ) async {
    const viewModelState = LocalLearningViewModelState(
      isLoading: false,
      hasSession: true,
      categoryId: 'basics',
      mode: LearningMode.adaptive,
      currentWordId: 'word-1',
      term: 'hello',
      translation: 'hallo',
      currentStage: SrsStage.s0,
      currentPosition: 1,
      totalItems: 3,
      answeredCount: 0,
      remainingCount: 3,
      stageCounts: [1, 0, 0, 0, 0, 0],
      canSubmitAnswer: true,
      canCompleteSession: false,
      lastAction: LocalLearningControllerAction.none,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localLearningViewModelProvider.overrideWithValue(viewModelState),
          localStageInspectorProvider.overrideWith(
            (ref, request) async => [
              LocalStageInspectorItem(
                wordId: 'word-1',
                term: 'hello',
                translation: 'hallo',
                categoryId: request.categoryId,
                mode: request.mode,
                currentStage: request.stage,
                passCount: 0,
                wrongCount: 0,
              ),
            ],
          ),
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
    final row = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    row.onTapStage?.call(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Merkstufe 0'), findsOneWidget);
    expect(find.text('hello'), findsWidgets);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('hochgestuft'), findsOneWidget);
  });

  testWidgets(
    'learn_mode_screen_local_start_button_shows_card_when_local_words_exist',
    (tester) async {
      const readState = LocalSessionReadState(
        sessionId: 'session-1',
        categoryId: 'seed-category-basics',
        mode: LearningMode.hybrid,
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
              localLearningMode: LearningMode.hybrid,
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
      expect(controller.capturedMode, LearningMode.hybrid);
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

  testWidgets('learn_mode_screen_local_completed_state_can_start_new_session', (
    tester,
  ) async {
    const completedState = LocalSessionReadState(
      sessionId: 'completed-session',
      categoryId: 'seed-category-basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'completed',
      sessionSize: 4,
      currentPosition: 4,
      totalItems: 4,
      answeredCount: 4,
      remainingCount: 0,
      stageCounts: [0, 0, 0, 0, 0, 4],
      canSubmitAnswer: false,
      canCompleteSession: true,
    );
    const restartedState = LocalSessionReadState(
      sessionId: 'new-session',
      categoryId: 'seed-category-basics',
      mode: LearningMode.adaptive,
      trainingArea: TrainingArea.all,
      status: 'active',
      sessionSize: 4,
      currentPosition: 0,
      totalItems: 4,
      answeredCount: 0,
      remainingCount: 4,
      stageCounts: [0, 0, 0, 0, 0, 4],
      canSubmitAnswer: true,
      canCompleteSession: false,
      currentWordId: 'word-1',
      currentTerm: 'hello',
      currentTranslation: 'hallo',
      currentStage: SrsStage.s5,
    );
    final controller = _TestLocalLearningController(
      const LocalLearningControllerState(readState: completedState),
      startedReadState: restartedState,
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

    expect(find.text('Session abgeschlossen'), findsOneWidget);
    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('Weiterlernen'), findsOneWidget);
    expect(find.byType(SwipeableWordCard), findsNothing);
    expect(controller.startOrResumeCalls, 0);
    expect(controller.resetAndStartCalls, 0);
    expect(
      tester.widget<StageSwitchRowView>(find.byType(StageSwitchRowView)).counts,
      [0, 0, 0, 0, 0, 4],
    );

    await tester.tap(find.text('Weiterlernen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(controller.startOrResumeCalls, 1);
    expect(controller.resetAndStartCalls, 0);
    expect(controller.capturedCategoryId, 'seed-category-basics');
    expect(
      controller.state.lastAction,
      LocalLearningControllerAction.startOrResume,
    );
    expect(find.byType(SwipeableWordCard), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Session abgeschlossen'), findsNothing);
    expect(
      tester.widget<StageSwitchRowView>(find.byType(StageSwitchRowView)).counts,
      [0, 0, 0, 0, 0, 4],
    );
  });
}
