import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';

void main() {
  LocalCategory localCategory(String id, String name) {
    final now = DateTime(2026, 1, 1);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  testWidgets(
    'category_detail_screen_local_mode_renders_without_online_progress',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith((ref) async => const []),
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
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
          localCategoriesProvider.overrideWith((ref) async => const []),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
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

  testWidgets(
    'category_detail_screen_local_mode_accepts_group_and_starts_selected_category',
    (tester) async {
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
            localCategoriesProvider.overrideWith(
              (ref) async => [localCategory('seed-category-basics', 'Basics')],
            ),
            localWordCountProvider.overrideWith((ref, categoryId) async => 3),
          ],
          child: const MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localCategoryItems: [
                LocalCategoryDetailGroupItem(
                  displayLabel: 'Health & Fitness',
                  localCategoryId: 'seed-category-basics',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Health & Fitness'), findsWidgets);
      expect(find.text('Basics'), findsNothing);
      expect(find.text('Vocabs'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == '3' &&
              widget.style?.fontSize == 14,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(StartButtonPulse));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<LearnModeScreen>(
        find.byType(LearnModeScreen),
      );
      expect(screen.useLocalOfflineFlow, isTrue);
      expect(screen.localCategoryId, 'seed-category-basics');
      expect(screen.categoryId, 'seed-category-basics');
    },
  );

  testWidgets(
    'category_detail_screen_local_mode_shows_zero_vocabs_when_selected_category_has_no_words',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith((ref) async => const []),
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: const MaterialApp(
            home: CategoryDetailScreen(
              title: 'Empty Local',
              categoryId: 'empty-local',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'empty-local',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'empty-local',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Empty Local'), findsWidgets);
      expect(find.text('Vocabs'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    },
  );

  testWidgets(
    'category_detail_screen_local_mode_falls_back_when_local_category_name_is_missing',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith(
              (ref) async => [localCategory('seed-category-basics', 'Basics')],
            ),
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: const MaterialApp(
            home: CategoryDetailScreen(
              title: 'Fallback Group',
              categoryId: 'missing-local-category',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'missing-local-category',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'missing-local-category',
              localCategoryIds: [
                'seed-category-basics',
                'missing-local-category',
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Basics'), findsWidgets);
      expect(find.text('missing-local-category'), findsWidgets);
    },
  );
}
