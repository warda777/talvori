import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';

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

    await tester.tap(find.byType(SwipeableWordCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('hallo'), findsOneWidget);
  });
}
