import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/models/local_stage_inspector_item.dart';
import 'package:talvori/core/local_database/providers/local_category_progress_reset_provider.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/local_stage_inspector_sheet.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';

class _FakeLocalCategoryProgressResetService
    implements LocalCategoryProgressResetService {
  LocalCategoryProgressResetRequest? lastRequest;

  @override
  Future<void> resetToS0(LocalCategoryProgressResetRequest request) async {
    lastRequest = request;
  }
}

class _ResetInvalidationLocalLearningController
    extends LocalLearningController {
  _ResetInvalidationLocalLearningController({
    required this.initialState,
    required this.startedReadState,
  });

  final LocalLearningControllerState initialState;
  final LocalSessionReadState startedReadState;
  int startOrResumeCalls = 0;

  @override
  LocalLearningControllerState build() => initialState;

  @override
  Future<void> startOrResume({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int? sessionSize,
  }) async {
    startOrResumeCalls += 1;
    state = state.copyWith(
      readState: startedReadState,
      lastAction: LocalLearningControllerAction.startOrResume,
    );
  }
}

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

  List<LocalCategoryDetailGroupItem> localWordHubItems() {
    return const LocalCategoryDetailGroupResolver()
        .resolve('health_fitness')
        .map(
          (item) => item.copyWith(
            vocabsCount: item.wordHubKey == 'health_fitness'
                ? 3
                : item.wordHubKey == 'travel'
                ? 4
                : 0,
          ),
        )
        .toList(growable: false);
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
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final header = tester.widget<CategoryHeaderCapsule>(
        find.byType(CategoryHeaderCapsule),
      );
      expect(header.categories.take(6), [
        'Health & Fitness',
        'Home & Living',
        'Food & Cooking',
        'Style & Fashion',
        'Money & Shopping',
        'Productivity',
      ]);
      expect(header.categories, contains('Travel'));
      expect(header.categories, isNot(contains('Basics')));
      expect(header.categories, isNot(contains('Exam Practice')));
      expect(header.selectedIndex, 0);
      expect(find.text('Health & Fitness'), findsWidgets);
      expect(find.text('Home & Living'), findsWidgets);
      expect(find.text('seed-category-basics'), findsNothing);
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
    'category_detail_screen_local_mode_wheel_change_updates_count_and_start_target',
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
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final header = tester.widget<CategoryHeaderCapsule>(
        find.byType(CategoryHeaderCapsule),
      );
      final travelIndex = header.categories.indexOf('Travel');
      expect(travelIndex, greaterThan(0));
      header.onWheelChanged(travelIndex, 'Travel');
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == '4' &&
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
      expect(screen.localCategoryId, 'seed-category-travel');
      expect(screen.categoryId, 'seed-category-travel');
    },
  );

  testWidgets(
    'category_detail_screen_local_stage_counts_follow_selected_learning_mode',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 3),
            localStageCountsProvider.overrideWith((ref, request) async {
              return switch (request.mode) {
                LearningMode.time => [25, 0, 0, 0, 0, 0],
                LearningMode.adaptive => [20, 3, 2, 0, 0, 0],
                LearningMode.hybrid => [10, 5, 4, 3, 2, 1],
              };
            }),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: const WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<StageSwitchRowView>(find.byType(StageSwitchRowView))
            .counts,
        [25, 0, 0, 0, 0, 0],
      );

      await tester.tap(find.text('Limitlos'));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<StageSwitchRowView>(find.byType(StageSwitchRowView))
            .counts,
        [20, 3, 2, 0, 0, 0],
      );

      await tester.tap(find.text('Kombiniert'));
      await tester.pump();
      await tester.pump();

      expect(
        tester
            .widget<StageSwitchRowView>(find.byType(StageSwitchRowView))
            .counts,
        [10, 5, 4, 3, 2, 1],
      );
    },
  );

  testWidgets(
    'category_detail_screen_local_start_passes_selected_learning_mode',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localLearningViewModelProvider.overrideWithValue(
              const LocalLearningViewModelState(
                isLoading: false,
                hasSession: false,
                currentPosition: 0,
                totalItems: 0,
                answeredCount: 0,
                remainingCount: 0,
                canSubmitAnswer: false,
                canCompleteSession: false,
                lastAction: LocalLearningControllerAction.none,
              ),
            ),
            localWordCountProvider.overrideWith((ref, categoryId) async => 3),
            localStageCountsProvider.overrideWith(
              (ref, request) async => [25, 0, 0, 0, 0, 0],
            ),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: const WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Limitlos'));
      await tester.pump();

      await tester.tap(find.byType(StartButtonPulse));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<LearnModeScreen>(
        find.byType(LearnModeScreen),
      );
      expect(screen.localCategoryId, 'seed-category-basics');
      expect(screen.localLearningMode, LearningMode.adaptive);
    },
  );

  testWidgets(
    'category_detail_screen_local_reset_confirms_and_resets_selected_category_mode',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final resetService = _FakeLocalCategoryProgressResetService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 3),
            localStageCountsProvider.overrideWith(
              (ref, request) async => [20, 3, 2, 0, 0, 0],
            ),
            localCategoryProgressResetServiceProvider.overrideWithValue(
              resetService,
            ),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: const WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Limitlos'));
      await tester.pump();

      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Fortschritt zurücksetzen?'), findsOneWidget);
      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(resetService.lastRequest?.categoryId, 'seed-category-basics');
      expect(resetService.lastRequest?.mode, LearningMode.adaptive);
      expect(find.text('Lernfortschritt wurde zurückgesetzt'), findsOneWidget);
    },
  );

  testWidgets(
    'category_detail_screen_local_reset_clears_stale_learn_mode_state_before_start',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final resetService = _FakeLocalCategoryProgressResetService();
      var controllerCreations = 0;

      const staleReadState = LocalSessionReadState(
        sessionId: 'old-session',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        sessionSize: 4,
        currentPosition: 2,
        totalItems: 4,
        answeredCount: 2,
        remainingCount: 2,
        stageCounts: [0, 0, 2, 0, 0, 0],
        canSubmitAnswer: true,
        canCompleteSession: false,
        currentWordId: 'old-word',
        currentTerm: 'old progress',
        currentTranslation: 'alter Fortschritt',
        currentStage: SrsStage.s2,
      );
      const freshReadState = LocalSessionReadState(
        sessionId: 'fresh-session',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        status: 'active',
        sessionSize: 4,
        currentPosition: 0,
        totalItems: 4,
        answeredCount: 0,
        remainingCount: 4,
        stageCounts: [4, 0, 0, 0, 0, 0],
        canSubmitAnswer: true,
        canCompleteSession: false,
        currentWordId: 'fresh-word',
        currentTerm: 'fresh start',
        currentTranslation: 'frischer Start',
        currentStage: SrsStage.s0,
      );

      final container = ProviderContainer(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 4),
          localStageCountsProvider.overrideWith(
            (ref, request) async => [4, 0, 0, 0, 0, 0],
          ),
          localCategoryProgressResetServiceProvider.overrideWithValue(
            resetService,
          ),
          localLearningControllerProvider.overrideWith(() {
            controllerCreations += 1;
            return _ResetInvalidationLocalLearningController(
              initialState: controllerCreations == 1
                  ? const LocalLearningControllerState(
                      readState: staleReadState,
                    )
                  : const LocalLearningControllerState(),
              startedReadState: freshReadState,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(localLearningViewModelProvider).term,
        'old progress',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: const WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Limitlos'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(resetService.lastRequest?.categoryId, 'seed-category-basics');
      expect(resetService.lastRequest?.mode, LearningMode.adaptive);

      await tester.tap(find.byType(StartButtonPulse));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LearnModeScreen), findsOneWidget);
      expect(find.text('old progress'), findsNothing);
      expect(find.text('Keine aktive lokale Session'), findsOneWidget);

      await tester.tap(find.text('Starten/Fortsetzen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SwipeableWordCard), findsOneWidget);
      expect(find.text('fresh start'), findsOneWidget);
      expect(find.text('old progress'), findsNothing);
      expect(
        tester
            .widget<StageSwitchRowView>(find.byType(StageSwitchRowView))
            .counts,
        [4, 0, 0, 0, 0, 0],
      );
    },
  );

  testWidgets(
    'category_detail_screen_local_vocabs_opens_local_word_list_with_display_label',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
            localWordsForCategoryProvider.overrideWith(
              (ref, categoryId) async => const [],
            ),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Health & Fitness',
              categoryId: 'seed-category-basics',
              listFilter: WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'health_fitness',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Vocabs'));
      await tester.pumpAndSettle();

      final screen = tester.widget<LocalWordListScreen>(
        find.byType(LocalWordListScreen),
      );
      expect(screen.categoryId, 'seed-category-basics');
      expect(screen.title, 'Health & Fitness');
      expect(find.text('Health & Fitness'), findsWidgets);
      expect(find.text('Keine lokalen Wörter verfügbar'), findsOneWidget);
      expect(find.text('seed-category-basics'), findsNothing);
    },
  );

  testWidgets(
    'category_detail_screen_local_mode_unmapped_wheel_item_does_not_start_basics',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: 'Home & Living',
              categoryId: 'seed-category-basics',
              listFilter: const WordListFilter(
                WordFilterKind.category,
                'seed-category-basics',
              ),
              useLocalOfflineFlow: true,
              localCategoryId: 'seed-category-basics',
              localSelectedWordHubKey: 'home_living',
              localCategoryItems: localWordHubItems(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final header = tester.widget<CategoryHeaderCapsule>(
        find.byType(CategoryHeaderCapsule),
      );
      expect(header.categories[header.selectedIndex], 'Home & Living');
      expect(header.vocabsCount, 0);

      await tester.tap(find.byType(StartButtonPulse));
      await tester.pump();

      expect(find.text('Noch nicht lokal verfügbar'), findsOneWidget);
      expect(find.byType(LearnModeScreen), findsNothing);
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

  testWidgets('category_detail_local_stage_switch_opens_stage_inspector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith((ref) async => const []),
          localWordCountProvider.overrideWith((ref, categoryId) async => 1),
          localStageCountsProvider.overrideWith(
            (ref, request) async => [1, 0, 0, 0, 0, 0],
          ),
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
          home: CategoryDetailScreen(
            title: 'Health & Fitness',
            categoryId: 'legacy-basics',
            listFilter: WordListFilter(WordFilterKind.category, 'basics'),
            useLocalOfflineFlow: true,
            localCategoryId: 'seed-category-basics',
          ),
        ),
      ),
    );

    await tester.pump();
    final row = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    row.onTapStage?.call(0);
    await tester.pumpAndSettle();

    expect(find.text('Merkstufe 0'), findsOneWidget);
    expect(find.text('hochgestuft'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
  });

  Future<void> pumpStageInspectorLegend(
    WidgetTester tester,
    SrsStage stage,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showLocalStageInspectorSheet(
                  context: context,
                  categoryId: 'seed-category-basics',
                  mode: LearningMode.adaptive,
                  stage: stage,
                  categoryLabel: 'Health & Fitness',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('stage_inspector_s0_legend_shows_only_possible_entries', (
    tester,
  ) async {
    await pumpStageInspectorLegend(tester, SrsStage.s0);

    expect(find.text('hochgestuft'), findsOneWidget);
    expect(find.text('falsch/zurück'), findsOneWidget);
    expect(find.text('1. Wiederholung'), findsNothing);
    expect(find.text('2. Wiederholung'), findsNothing);
    expect(find.text('3. Wiederholung'), findsNothing);
  });

  testWidgets('stage_inspector_s1_legend_hides_third_repeat', (tester) async {
    await pumpStageInspectorLegend(tester, SrsStage.s1);

    expect(find.text('hochgestuft'), findsOneWidget);
    expect(find.text('falsch/zurück'), findsOneWidget);
    expect(find.text('1. Wiederholung'), findsOneWidget);
    expect(find.text('2. Wiederholung'), findsNothing);
    expect(find.text('3. Wiederholung'), findsNothing);
  });

  testWidgets('stage_inspector_s3_legend_shows_two_repeat_steps', (
    tester,
  ) async {
    await pumpStageInspectorLegend(tester, SrsStage.s3);

    expect(find.text('hochgestuft'), findsOneWidget);
    expect(find.text('falsch/zurück'), findsOneWidget);
    expect(find.text('1. Wiederholung'), findsOneWidget);
    expect(find.text('2. Wiederholung'), findsOneWidget);
    expect(find.text('3. Wiederholung'), findsNothing);
  });
}
