import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';

void main() {
  testWidgets(
    'category_detail_screen_local_mode_renders_without_online_progress',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Basics',
              categoryId: 'legacy-basics',
              categorySlug: 'basics',
              listFilter: WordListFilter(WordFilterKind.category, 'basics'),
              useLocalOfflineFlow: true,
              localCategoryId: 'basics',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Basics'), findsWidgets);
      expect(find.text('Vocabs'), findsOneWidget);
      expect(find.text('Lokale Kategorie'), findsNothing);
      expect(find.text('Lernmodus'), findsOneWidget);
      expect(find.text('Zeitplan'), findsOneWidget);
      expect(find.text('Limitlos'), findsOneWidget);
      expect(find.text('Kombiniert'), findsOneWidget);
      expect(find.text('Wiederholungsauswahl'), findsOneWidget);
      expect(find.text('Alle Stufen'), findsOneWidget);
      expect(find.text('Einzelstufe'), findsOneWidget);
      expect(find.text('AUTO'), findsNothing);
      expect(find.text('Start'), findsOneWidget);
    },
  );

  testWidgets('category_detail_screen_local_start_opens_local_learn_mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
          home: CategoryDetailScreen(
            title: 'Basics',
            categoryId: 'legacy-basics',
            categorySlug: 'basics',
            listFilter: WordListFilter(WordFilterKind.category, 'basics'),
            useLocalOfflineFlow: true,
            localCategoryId: 'basics',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byType(StartButtonPulse));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Keine aktive lokale Session'), findsOneWidget);
    expect(find.text('Starten/Fortsetzen'), findsOneWidget);
  });
}
