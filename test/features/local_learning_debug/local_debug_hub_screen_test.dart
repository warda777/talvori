import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_learning_screen_contract.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_screen_contract_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/features/local_learning_debug/ui/local_debug_hub_screen.dart';

void main() {
  group('LocalDebugHubScreen', () {
    testWidgets('debug_hub_shows_local_learning_entry', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocalDebugHubScreen()));

      expect(find.text('Lokaler Debug-Hub'), findsOneWidget);
      expect(find.text('Lokaler Lernscreen'), findsOneWidget);
    });

    testWidgets('debug_hub_shows_local_wordhub_entry', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocalDebugHubScreen()));

      expect(find.text('Lokaler Debug-Hub'), findsOneWidget);
      expect(find.text('Lokaler Lernscreen'), findsOneWidget);
      expect(find.text('Lokale Kategorien'), findsOneWidget);
      expect(find.text('Lokaler WordHub'), findsOneWidget);
      expect(find.text('AI Chat Test'), findsOneWidget);
    });

    testWidgets('debug_hub_opens_local_learnmode_screen', (tester) async {
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
          child: const MaterialApp(home: LocalDebugHubScreen()),
        ),
      );

      await tester.tap(find.text('Lokaler Lernscreen'));
      await tester.pumpAndSettle();

      expect(find.text('Keine aktive lokale Session'), findsOneWidget);
      expect(find.text('Starten/Fortsetzen'), findsOneWidget);
    });

    testWidgets('debug_hub_opens_local_wordhub_debug_screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: LocalDebugHubScreen()),
        ),
      );

      await tester.tap(find.text('Lokale Kategorien'));
      await tester.pumpAndSettle();

      expect(find.text('Lokale Kategorien'), findsWidgets);
      expect(find.text('Keine lokalen Kategorien gefunden'), findsOneWidget);
    });

    testWidgets('debug_hub_opens_local_wordhub_screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: LocalDebugHubScreen()),
        ),
      );

      await tester.tap(find.text('Lokaler WordHub'));
      await tester.pumpAndSettle();

      expect(find.text('Wortwelten'), findsOneWidget);
      expect(find.text('Word Hub'), findsNothing);
      expect(find.text('Alltag & Leben'), findsOneWidget);
      expect(find.text('Gesundheit & Fitness'), findsOneWidget);
    });

    testWidgets('debug_hub_opens_ai_chat_dev_screen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocalDebugHubScreen()));

      await tester.tap(find.text('AI Chat Test'));
      await tester.pumpAndSettle();

      expect(find.text('AI Chat Test'), findsWidgets);
      expect(find.text('KI testen'), findsOneWidget);
      expect(find.text('Nachricht'), findsOneWidget);
    });
  });
}
