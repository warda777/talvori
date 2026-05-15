import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_screen_contract.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_screen_contract_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/features/local_learning_debug/ui/local_wordhub_debug_screen.dart';

void main() {
  group('LocalWordHubDebugScreen', () {
    testWidgets(
      'local_wordhub_debug_screen_shows_basics_when_local_category_exists',
      (tester) async {
        final now = DateTime(2026, 5, 15, 12);
        final category = LocalCategory(
          id: 'basics',
          name: 'Basics',
          sortOrder: 1,
          isArchived: false,
          createdAt: now,
          updatedAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localCategoriesProvider.overrideWith((ref) async => [category]),
            ],
            child: const MaterialApp(home: LocalWordHubDebugScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Lokale Kategorien'), findsOneWidget);
        expect(find.text('Basics'), findsOneWidget);
      },
    );

    testWidgets(
      'local_wordhub_debug_screen_shows_empty_state_when_no_local_categories',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localCategoriesProvider.overrideWith((ref) async => const []),
            ],
            child: const MaterialApp(home: LocalWordHubDebugScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Lokale Kategorien'), findsOneWidget);
        expect(find.text('Keine lokalen Kategorien gefunden'), findsOneWidget);
        expect(find.text('Basics'), findsNothing);
      },
    );

    testWidgets(
      'local_wordhub_debug_screen_opens_local_learning_screen_with_category_id',
      (tester) async {
        final now = DateTime(2026, 5, 15, 12);
        final category = LocalCategory(
          id: 'basics',
          name: 'Basics',
          sortOrder: 1,
          isArchived: false,
          createdAt: now,
          updatedAt: now,
        );
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
              localCategoriesProvider.overrideWith((ref) async => [category]),
              localLearningViewModelProvider.overrideWithValue(viewModelState),
              localLearningScreenContractProvider.overrideWithValue(contract),
            ],
            child: const MaterialApp(home: LocalWordHubDebugScreen()),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Basics'));
        await tester.pumpAndSettle();

        expect(find.text('Noch keine Session'), findsOneWidget);
        expect(find.text('Intensiv lernen'), findsWidgets);
        expect(find.text('Alles lernen'), findsOneWidget);
      },
    );
  });
}
