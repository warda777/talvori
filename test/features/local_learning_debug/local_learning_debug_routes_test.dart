import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_screen_contract.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_learning_screen_contract_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learning_test_screen.dart';

void main() {
  group('local learning debug routes', () {
    testWidgets(
      'debug_route_can_build_local_learning_test_screen_with_category_id',
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

        expect(localLearningDebugRoutePath, '/debug/local-learning');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localLearningViewModelProvider.overrideWithValue(viewModelState),
              localLearningScreenContractProvider.overrideWithValue(contract),
            ],
            child: MaterialApp(
              home: buildLocalLearningDebugScreen(categoryId: 'basics'),
            ),
          ),
        );

        final screen = tester.widget<LocalLearningTestScreen>(
          find.byType(LocalLearningTestScreen),
        );

        expect(screen.categoryId, 'basics');
        expect(find.text('Noch keine Session'), findsOneWidget);
        expect(find.text('Intensiv lernen'), findsWidgets);
        expect(find.text('Alles lernen'), findsOneWidget);
        expect(find.text('Starten/Fortsetzen'), findsOneWidget);
        expect(find.text('Richtig'), findsNothing);
        expect(find.text('Falsch'), findsNothing);
      },
    );

    testWidgets('debug_router_builds_local_learning_screen', (tester) async {
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

      expect(localLearningDebugRouteDefinition.path, '/debug/local-learning');
      expect(localLearningDebugRouteDefinition.name, 'debugLocalLearning');
      expect(localLearningDebugRouteDefinition.defaultCategoryId, 'basics');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(viewModelState),
            localLearningScreenContractProvider.overrideWithValue(contract),
          ],
          child: MaterialApp(
            home: localLearningDebugRouteDefinition.builder(
              categoryId: localLearningDebugRouteDefinition.defaultCategoryId,
            ),
          ),
        ),
      );

      final screen = tester.widget<LocalLearningTestScreen>(
        find.byType(LocalLearningTestScreen),
      );

      expect(screen.categoryId, 'basics');
      expect(find.text('Noch keine Session'), findsOneWidget);
      expect(find.text('Intensiv lernen'), findsWidgets);
      expect(find.text('Alles lernen'), findsOneWidget);
      expect(find.text('Starten/Fortsetzen'), findsOneWidget);
      expect(find.text('Richtig'), findsNothing);
      expect(find.text('Falsch'), findsNothing);
    });

    test('debug_gate_exposes_route_only_when_enabled', () {
      final enabledRoutes = getLocalLearningDebugRoutes(enabled: true);
      final disabledRoutes = getLocalLearningDebugRoutes(enabled: false);

      expect(enabledRoutes, hasLength(1));
      expect(enabledRoutes.single, same(localLearningDebugRouteDefinition));
      expect(enabledRoutes.single.path, '/debug/local-learning');
      expect(enabledRoutes.single.name, 'debugLocalLearning');

      expect(disabledRoutes, isEmpty);
    });
  });
}
