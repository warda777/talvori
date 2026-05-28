import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/adapters/local_learning_view_model_state.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_practice_card.dart';
import 'package:talvori/core/local_database/models/local_session_read_state.dart';
import 'package:talvori/core/local_database/models/local_stage_due_summary.dart';
import 'package:talvori/core/local_database/models/local_stage_inspector_item.dart';
import 'package:talvori/core/local_database/models/local_word_package_definition.dart';
import 'package:talvori/core/local_database/providers/local_category_progress_reset_provider.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/providers/local_practice_cards_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_due_summary_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/application/category_design_preferences.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/category_design_color_panel.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';
import 'package:talvori/features/words/ui/widgets/learning_mode_selector.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/local_stage_inspector_sheet.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';

const _healthWordWorldId = 'word-world-health-and-fitness';

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
            localCategoryId: item.wordHubKey == 'health_fitness'
                ? _healthWordWorldId
                : item.localCategoryId,
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

  testWidgets('category_detail_add_button_opens_vocabulary_menu', (
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
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Wörter verwalten'), findsOneWidget);
    expect(find.text('Wort hinzufügen'), findsOneWidget);
    expect(find.text('KI-Vorschläge'), findsOneWidget);
  });

  testWidgets('category_detail_settings_button_opens_visual_preview_editor', (
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
    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt gestalten'), findsOneWidget);
    expect(find.text('Kategorie'), findsOneWidget);
    expect(find.text('Lernmodus'), findsAtLeastNWidgets(1));
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Kategorie-Vorschau'), findsOneWidget);
    expect(find.byKey(const Key('category-real-preview')), findsOneWidget);
    expect(
      find.byKey(const Key('design-element-categoryWheelFade')),
      findsOneWidget,
    );
    expect(find.text('Header-Kapsel'), findsNothing);
    expect(find.text('Home & Living'), findsNothing);
    expect(find.text('Basics'), findsWidgets);
    expect(find.text('Vocabs'), findsWidgets);
    expect(find.text('Wiederholungsauswahl'), findsWidgets);
    expect(find.text('Alle Stufen'), findsWidgets);
    expect(find.text('Einzelstufe'), findsWidgets);
    expect(find.text('Merkstufen'), findsWidgets);
    for (final stage in ['0', '1', '2', '3', '4', '5']) {
      expect(find.text(stage), findsWidgets);
    }
    expect(find.text('Zeitplan'), findsWidgets);
    expect(find.text('Limitlos'), findsWidgets);
    expect(find.text('Kombiniert'), findsWidgets);
    expect(find.text('Start'), findsWidgets);
    expect(find.byKey(const Key('design-color-panel')), findsNothing);
    expect(
      find.byKey(const Key('selected-design-element-label')),
      findsNothing,
    );
    expect(find.text('Palette'), findsNothing);

    await tester.tap(
      find.byKey(const Key('design-element-repeatSingleStageButton')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-subtarget-chooser')), findsOneWidget);
    expect(find.text('Einzelstufe-Button'), findsOneWidget);
    expect(find.text('Rahmen'), findsOneWidget);
    expect(find.text('Innenfläche'), findsOneWidget);
    expect(find.text('Schrift'), findsOneWidget);
    expect(find.text('Einzelstufe-Innenfläche'), findsNothing);

    await tester.tap(find.byKey(const Key('design-element-vocabsTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-subtarget-chooser')), findsOneWidget);
    expect(
      find.byKey(const Key('design-subtarget-vocabsTile')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('design-subtarget-vocabsTile')));
    await tester.pumpAndSettle();

    expect(find.text('Vocabs-Kachel'), findsWidgets);
    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);
    expect(
      find.byKey(const Key('design-selection-vocabsTile')),
      findsOneWidget,
    );
    expect(find.text('Palette'), findsOneWidget);
    expect(find.text('Glow'), findsOneWidget);
    expect(find.text('Puls'), findsOneWidget);
    expect(find.byKey(const Key('design-swatch-scroll-area')), findsOneWidget);
    expect(CategoryDesignColorPanel.swatchCount, greaterThanOrEqualTo(200));
    expect(find.byKey(const Key('design-swatch-Neonblau')), findsOneWidget);
    expect(find.byKey(const Key('design-swatch-Cyan')), findsOneWidget);
    expect(find.byKey(const Key('design-swatch-Neonrot')), findsOneWidget);
    expect(find.text('Element zurücksetzen'), findsOneWidget);
    expect(find.text('Werkseinstellung'), findsNothing);
    expect(find.text('Alles zurücksetzen'), findsNothing);
    expect(find.text('Anwenden'), findsNothing);

    await tester.tap(find.byKey(const Key('design-section-Glow')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-glow-section')), findsOneWidget);
    expect(find.byKey(const Key('design-glow-strong')), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-section-Puls')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-pulse-section')), findsOneWidget);
    expect(find.byKey(const Key('design-pulse-normal')), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-section-Palette')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('design-color-panel-close')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-color-panel')), findsNothing);

    await tester.tap(find.byKey(const Key('design-element-vocabsTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-vocabsTile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('design-swatch-Neonblau')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-swatch-Neonblau')));
    await tester.pumpAndSettle();

    expect(find.text('#2E7DFF'), findsOneWidget);
    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);
    expect(find.byKey(const Key('design-selection-vocabsTile')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const Key('design-factory-defaults-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-factory-defaults-button')));
    await tester.pumpAndSettle();
    expect(find.text('Element zurücksetzen?'), findsOneWidget);
    expect(
      find.text('Vocabs-Kachel wird auf die Werkseinstellung zurückgesetzt.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('design-factory-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('#2E7DFF'), findsOneWidget);

    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final autoPositionedPanelRect = tester.getRect(
      find.byKey(const Key('design-color-panel-positioned')),
    );
    expect(autoPositionedPanelRect.left, greaterThanOrEqualTo(0));
    expect(autoPositionedPanelRect.right, lessThanOrEqualTo(screenWidth));

    final rightPanelDragHandleCenter = tester.getCenter(
      find.byKey(const Key('design-color-panel-drag-handle')),
    );
    final leftOverflowDrag = await tester.startGesture(
      rightPanelDragHandleCenter,
    );
    await tester.pump(const Duration(milliseconds: 650));
    await leftOverflowDrag.moveBy(const Offset(-500, 0));
    await leftOverflowDrag.up();
    await tester.pumpAndSettle();
    expect(
      tester
          .getRect(find.byKey(const Key('design-color-panel-positioned')))
          .left,
      lessThan(0),
    );

    await tester.tap(find.byKey(const Key('design-element-addButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-addButton')));
    await tester.pumpAndSettle();
    expect(find.text('Add-Button'), findsWidgets);
    expect(find.text('#2E7DFF'), findsNothing);
    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);
    expect(find.byKey(const Key('design-selection-addButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-color-panel-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-element-stageSwitch1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-stageSwitch1')));
    await tester.pumpAndSettle();
    expect(find.text('Merkstufe 1'), findsWidgets);
    expect(
      find.byKey(const Key('design-selection-stageSwitch1')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('design-color-panel-close')));
    await tester.pumpAndSettle();
    final repeatTitleRect = tester.getRect(
      find.byKey(const Key('design-element-sectionTitleRepeat')),
    );
    expect(repeatTitleRect.width, lessThan(260));

    await tester.ensureVisible(
      find.byKey(const Key('design-element-startButton')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-element-startButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-startButton')));
    await tester.pumpAndSettle();
    expect(find.text('Start-Button'), findsWidgets);

    await tester.drag(
      find.byKey(const Key('design-color-field')),
      const Offset(80, -48),
    );
    await tester.pumpAndSettle();
    expect(find.text('#2E7DFF'), findsNothing);

    final hexBeforeSlider = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('design-hex-value')),
            matching: find.byType(Text),
          ),
        )
        .data;

    await tester.drag(
      find.byKey(const Key('design-hue-slider')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    final hexAfterSlider = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('design-hex-value')),
            matching: find.byType(Text),
          ),
        )
        .data;
    expect(hexAfterSlider, isNot(hexBeforeSlider));

    final panelTopLeftBeforeDrag = tester.getTopLeft(
      find.byKey(const Key('design-color-panel-positioned')),
    );
    final dragHandleCenter = tester.getCenter(
      find.byKey(const Key('design-color-panel-drag-handle')),
    );
    final panelDrag = await tester.startGesture(dragHandleCenter);
    await tester.pump(const Duration(milliseconds: 650));
    await panelDrag.moveBy(const Offset(60, 0));
    await panelDrag.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('design-color-panel-positioned'))),
      isNot(panelTopLeftBeforeDrag),
    );

    await tester.tapAt(const Offset(22, 180));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('design-color-panel')), findsNothing);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-tab-Lernmodus')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('learn-real-preview')), findsOneWidget);
    expect(find.text('Lernmodus-Vorschau'), findsOneWidget);
    expect(
      find.text('Wähle ein Element und passe Farbe, Glow oder Pulsieren an.'),
      findsOneWidget,
    );
    expect(find.text('Talvori'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byKey(const Key('design-element-learnStages')), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byKey(const Key('design-element-resetButton')), findsNothing);

    final learnCardRect = tester.getRect(
      find.byKey(const Key('design-element-learnCard')),
    );
    await tester.tapAt(learnCardRect.topLeft + const Offset(150, 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-learnCard')));
    await tester.pumpAndSettle();
    expect(find.text('Lernkarte'), findsWidgets);

    await tester.tap(find.byKey(const Key('design-color-panel-close')));
    await tester.pumpAndSettle();

    final learnCardGlowRect = tester.getRect(
      find.byKey(const Key('design-element-learnCardGlow')),
    );
    await tester.tapAt(learnCardGlowRect.topLeft + const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Karten-Glow'), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-section-Glow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('design-glow-strong')), findsOneWidget);
    expect(find.byKey(const Key('design-color-panel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-section-Puls')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('design-pulse-off')), findsOneWidget);
    expect(find.text('Karten-Glow'), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-section-Palette')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('design-swatch-Orange')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-swatch-Orange')));
    await tester.pumpAndSettle();
    expect(find.text('#FFB255'), findsOneWidget);

    await tester.tap(find.byKey(const Key('design-color-panel-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-tab-Info')));
    await tester.pumpAndSettle();

    expect(find.text('Info & Hilfe'), findsOneWidget);
    expect(find.text('Lernmodi verstehen'), findsOneWidget);
    expect(find.text('Merkstufen 0–5'), findsOneWidget);
    expect(find.text('Antippbare Stufen'), findsOneWidget);
    expect(find.text('Vocabs & pausierte Wörter'), findsOneWidget);

    await tester.tap(find.text('Lernmodi verstehen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Alle Stufen mischt alles'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-design-sheet-close')));
    await tester.pumpAndSettle();

    expect(find.text('Änderungen übernehmen?'), findsOneWidget);
    expect(
      find.text('Möchtest du die Gestaltung für Basics übernehmen?'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('design-close-keep-editing')));
    await tester.pumpAndSettle();
    expect(find.text('Wortwelt gestalten'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-design-sheet-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-close-discard')));
    await tester.pumpAndSettle();
    expect(find.text('Wortwelt gestalten'), findsNothing);
  });

  testWidgets('category_design_color_panel_updates_glow_and_pulse_callbacks', (
    tester,
  ) async {
    var glow = CategoryDesignGlowStrength.normal;
    var pulse = CategoryDesignPulseStrength.normal;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: CategoryDesignColorPanel(
                  selectedElementLabel: 'Karten-Glow',
                  selectedColor: const Color(0xFFFFB255),
                  selectedGlowStrength: glow,
                  selectedPulseStrength: pulse,
                  onMove: (_) {},
                  onClose: () {},
                  onColorChanged: (_) {},
                  onGlowChanged: (value) => setState(() => glow = value),
                  onPulseChanged: (value) => setState(() => pulse = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('design-section-Glow')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('design-glow-strong')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-glow-strong')));
    await tester.pumpAndSettle();
    expect(glow, CategoryDesignGlowStrength.strong);

    await tester.tap(find.byKey(const Key('design-section-Puls')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('design-pulse-off')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-pulse-off')));
    await tester.pumpAndSettle();
    expect(pulse, CategoryDesignPulseStrength.off);
  });

  testWidgets('category_detail_settings_applies_saved_category_design', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith(
            (ref) async => [localCategory('basics', 'Basics')],
          ),
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

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-element-vocabsTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-vocabsTile')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('design-swatch-Neonblau')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-swatch-Neonblau')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-design-sheet-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-close-apply')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-element-vocabsTile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-subtarget-vocabsTile')));
    await tester.pumpAndSettle();

    expect(find.text('#2E7DFF'), findsOneWidget);
  });

  testWidgets('category_detail_applies_saved_design_to_real_controls', (
    tester,
  ) async {
    await const CategoryDesignPreferencesRepository().save(
      'basics',
      const CategoryDesignPreferences(
        overrides: {
          CategoryDesignElement.categoryHeader: CategoryDesignElementStyle(
            color: Color(0xFF12D6FF),
          ),
          CategoryDesignElement.repeatAllStagesButton:
              CategoryDesignElementStyle(color: Color(0xFFFF5EA8)),
          CategoryDesignElement.repeatSingleStageButtonFill:
              CategoryDesignElementStyle(color: Color(0xFF143C54)),
          CategoryDesignElement.repeatSingleStageButtonText:
              CategoryDesignElementStyle(color: Color(0xFFFFF04A)),
          CategoryDesignElement.learningModeTimeButton:
              CategoryDesignElementStyle(color: Color(0xFF63F58F)),
          CategoryDesignElement.learningModeTimeButtonFill:
              CategoryDesignElementStyle(color: Color(0xFF183919)),
          CategoryDesignElement.learningModeTimeButtonText:
              CategoryDesignElementStyle(color: Color(0xFFFFE2ED)),
          CategoryDesignElement.sectionTitleStages: CategoryDesignElementStyle(
            color: Color(0xFF00E5FF),
          ),
          CategoryDesignElement.stageSwitch1: CategoryDesignElementStyle(
            color: Color(0xFFFFB000),
          ),
          CategoryDesignElement.addButtonFill: CategoryDesignElementStyle(
            color: Color(0xFF102A44),
          ),
          CategoryDesignElement.settingsButtonFill: CategoryDesignElementStyle(
            color: Color(0xFF221044),
          ),
          CategoryDesignElement.categoryBackground: CategoryDesignElementStyle(
            color: Color(0xFF111B2E),
          ),
        },
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith(
            (ref) async => [localCategory('basics', 'Basics')],
          ),
          localWordCountProvider.overrideWith((ref, categoryId) async => 12),
          localStageCountsProvider.overrideWith((ref, request) async {
            return const [8, 4, 0, 0, 0, 0];
          }),
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

    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CategoryWheel>(find.byType(CategoryWheel))
          .activeStrokeColor,
      const Color(0xFF12D6FF),
    );
    expect(
      tester
          .widget<LevelSelectorButtonsView>(
            find.byType(LevelSelectorButtonsView),
          )
          .allStagesAccentColor,
      const Color(0xFFFF5EA8),
    );
    expect(
      tester
          .widget<LevelSelectorButtonsView>(
            find.byType(LevelSelectorButtonsView),
          )
          .singleStageFillColor,
      const Color(0xFF143C54),
    );
    expect(
      tester
          .widget<LevelSelectorButtonsView>(
            find.byType(LevelSelectorButtonsView),
          )
          .singleStageTextColor,
      const Color(0xFFFFF04A),
    );
    expect(
      tester
          .widget<LearningModeSelectorView>(
            find.byType(LearningModeSelectorView),
          )
          .timeAccentColor,
      const Color(0xFF63F58F),
    );
    expect(
      tester
          .widget<LearningModeSelectorView>(
            find.byType(LearningModeSelectorView),
          )
          .timeFillColor,
      const Color(0xFF183919),
    );
    expect(
      tester
          .widget<LearningModeSelectorView>(
            find.byType(LearningModeSelectorView),
          )
          .timeTextColor,
      const Color(0xFFFFE2ED),
    );
    expect(
      tester
          .widget<CategoryHeaderCapsule>(find.byType(CategoryHeaderCapsule))
          .backgroundColor,
      const Color(0xFF111B2E),
    );
    expect(
      tester
          .widget<CategoryHeaderCapsule>(find.byType(CategoryHeaderCapsule))
          .addButtonFillColor,
      const Color(0xFF102A44),
    );
    expect(
      tester
          .widget<CategoryHeaderCapsule>(find.byType(CategoryHeaderCapsule))
          .settingsButtonFillColor,
      const Color(0xFF221044),
    );
    expect(
      tester
          .widget<LevelsCardView>(find.byType(LevelsCardView))
          .stageSectionAccentColor,
      const Color(0xFF00E5FF),
    );
    expect(
      tester
          .widget<StageSwitchRowView>(find.byType(StageSwitchRowView))
          .colors
          .stageOuterOverrides[1],
      const Color(0xFFFFB000),
    );
  });

  testWidgets('category_design_reset_only_clears_current_category_area', (
    tester,
  ) async {
    const repository = CategoryDesignPreferencesRepository();
    await repository.save(
      'basics',
      const CategoryDesignPreferences(
        overrides: {
          CategoryDesignElement.categoryHeader: CategoryDesignElementStyle(
            color: Color(0xFF12D6FF),
          ),
          CategoryDesignElement.learnCard: CategoryDesignElementStyle(
            color: Color(0xFF2E7DFF),
          ),
        },
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith(
            (ref) async => [localCategory('basics', 'Basics')],
          ),
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

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('design-reset-Kategorie')),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('design-reset-Kategorie')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('design-factory-confirm')));
    await tester.pumpAndSettle();

    final saved = await repository.load('basics');
    expect(
      saved.overrides.containsKey(CategoryDesignElement.categoryHeader),
      isFalse,
    );
    expect(
      saved.overrides[CategoryDesignElement.learnCard]?.color,
      const Color(0xFF2E7DFF),
    );
  });

  testWidgets('category_detail_settings_closes_without_prompt_when_unchanged', (
    tester,
  ) async {
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
    await tester.tap(find.byIcon(Icons.tune_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Wortwelt gestalten'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-design-sheet-close')));
    await tester.pumpAndSettle();

    expect(find.text('Änderungen übernehmen?'), findsNothing);
    expect(find.text('Wortwelt gestalten'), findsNothing);
  });

  testWidgets('level package detail wheel shows packages from the same level', (
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
          localWordCountProvider.overrideWith((ref, categoryId) async {
            if (categoryId == '${localLevelPackageCategoryPrefix}a1_alltag') {
              return 7;
            }
            return 0;
          }),
        ],
        child: const MaterialApp(
          home: CategoryDetailScreen(
            title: 'A1 Starter',
            listFilter: WordListFilter(WordFilterKind.about, 'A1 Starter'),
            useLocalOfflineFlow: true,
            localCategoryId: '${localLevelPackageCategoryPrefix}a1_starter',
          ),
        ),
      ),
    );

    await tester.pump();

    final wheel = tester.widget<CategoryWheel>(find.byType(CategoryWheel));
    expect(wheel.initialIndex, 0);
    expect(wheel.categories, const [
      'A1 Starter',
      'A1 Alltag',
      'A1 Verben',
      'A1 Nomen',
      'A1 Adjektive',
      'A1 Reisen & Orientierung',
      'A1 Essen & Einkaufen',
    ]);
    expect(wheel.categories, isNot(contains('A2 Alltag')));
    expect(wheel.categories, isNot(contains('B2 Diskussion')));

    final header = tester.widget<CategoryHeaderCapsule>(
      find.byType(CategoryHeaderCapsule),
    );
    expect(header.accentColor, const Color(0xFFB1CCFE));

    wheel.onChanged(1, 'A1 Alltag');
    await tester.pump();

    final updatedWheel = tester.widget<CategoryWheel>(
      find.byType(CategoryWheel),
    );
    expect(updatedWheel.initialIndex, 1);
  });

  testWidgets('level package detail wheel is scoped to A2 and B2 groups', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<List<String>> pumpFor(String title, String categoryId) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoriesProvider.overrideWith((ref) async => const []),
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: MaterialApp(
            home: CategoryDetailScreen(
              title: title,
              listFilter: WordListFilter(WordFilterKind.about, title),
              useLocalOfflineFlow: true,
              localCategoryId: categoryId,
            ),
          ),
        ),
      );
      await tester.pump();
      return tester
          .widget<CategoryWheel>(find.byType(CategoryWheel))
          .categories;
    }

    final a2Categories = await pumpFor(
      'A2 Alltag',
      '${localLevelPackageCategoryPrefix}a2_alltag',
    );
    expect(a2Categories, containsAll(['A2 Alltag', 'A2 Arbeit & Schule']));
    expect(a2Categories, isNot(contains('A1 Starter')));
    expect(a2Categories, isNot(contains('B2 Diskussion')));

    final b2Categories = await pumpFor(
      'B2 Diskussion',
      '${localLevelPackageCategoryPrefix}b2_diskussion',
    );
    expect(b2Categories, containsAll(['B2 Diskussion', 'B2 Beruf & Studium']));
    expect(b2Categories, isNot(contains('A2 Alltag')));
    expect(b2Categories, isNot(contains('C1 Argumentation')));
  });

  test('learning level package colors use distinct package accents', () {
    final a1 = CategoryStrokeColors.getWheelStrokeColor('A1 Starter');
    final a1Alltag = CategoryStrokeColors.getWheelStrokeColor('A1 Alltag');
    final a1Verben = CategoryStrokeColors.getWheelStrokeColor('A1 Verben');
    final a1Nouns = CategoryStrokeColors.getWheelStrokeColor('A1 Nomen');
    final a2 = CategoryStrokeColors.getWheelStrokeColor('A2 Alltag');
    final a2Travel = CategoryStrokeColors.getWheelStrokeColor('A2 Reisen');
    final b1 = CategoryStrokeColors.getWheelStrokeColor('B1 Redemittel');
    final c2 = CategoryStrokeColors.getWheelStrokeColor('C2 Redemittel');
    final c1 = CategoryStrokeColors.getWheelStrokeColor('C1 Argumentation');
    final b2Discussion = CategoryStrokeColors.getWheelStrokeColor(
      'B2 Diskussion',
    );
    final b2Nouns = CategoryStrokeColors.getWheelStrokeColor('B2 Nomen');

    expect(a1, isNot(a2));
    expect(a1, isNot(c2));
    expect(a1, isNot(a1Alltag));
    expect(a1Alltag, isNot(a1Verben));
    expect(a1Verben, isNot(a1Nouns));
    expect(a2, isNot(a2Travel));
    expect(b1, isNot(b2Discussion));
    expect(c1, isNot(c2));
    expect(b2Discussion, isNot(b2Nouns));
    expect(CategoryStrokeColors.colorForLevel('A1'), isNot(a1));
    expect(CategoryStrokeColors.colorForLevel('A2'), isNot(a2));
    expect(
      CategoryStrokeColors.getStrokeColor('A1 Starter'),
      isNot(CategoryStrokeColors.getWheelStrokeColor('A1 Starter')),
    );
  });

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

  testWidgets('category_detail_local_all_stages_opens_neutral_practice_mode', (
    tester,
  ) async {
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
          localCategoriesProvider.overrideWith((ref) async => const []),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          localPracticeCardsProvider(
            const LocalPracticeCardsRequest(
              categoryId: 'basics',
              mode: LearningMode.time,
              selection: LocalPracticeSelection.allStages(),
            ),
          ).overrideWith(
            (ref) async => const [
              LocalPracticeCard(
                wordId: 'word-1',
                term: 'hello',
                translation: 'hallo',
                stage: SrsStage.s1,
              ),
            ],
          ),
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
    await tester.tap(find.text('Alle Stufen'));
    await tester.pump();
    expect(find.text('Alle Stufen aktiviert'), findsOneWidget);

    await tester.tap(find.byType(StartButtonPulse));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Übungsmodus'), findsOneWidget);
    expect(
      find.text('Ohne Einfluss auf deinen Lernfortschritt'),
      findsOneWidget,
    );
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('category_detail_local_single_stage_selects_stage_for_practice', (
    tester,
  ) async {
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
          localCategoriesProvider.overrideWith((ref) async => const []),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          localPracticeCardsProvider(
            const LocalPracticeCardsRequest(
              categoryId: 'basics',
              mode: LearningMode.time,
              selection: LocalPracticeSelection.singleStage(SrsStage.s2),
            ),
          ).overrideWith(
            (ref) async => const [
              LocalPracticeCard(
                wordId: 'word-2',
                term: 'water',
                translation: 'Wasser',
                stage: SrsStage.s2,
              ),
            ],
          ),
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
    await tester.tap(find.text('Einzelstufe'));
    await tester.pump();
    expect(find.text('Wähle eine Stufe aus'), findsOneWidget);

    final stageRow = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    stageRow.onSelectStage!(2);
    await tester.pump();
    expect(find.text('Drücke Start, um zu beginnen'), findsOneWidget);

    await tester.tap(find.byType(StartButtonPulse));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Übungsmodus'), findsOneWidget);
    expect(find.text('water'), findsOneWidget);
  });

  testWidgets('category_detail_single_stage_pulse_dispose_does_not_throw', (
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
    await tester.tap(find.text('Einzelstufe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1200));

    expect(tester.takeException(), isNull);
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
      expect(screen.localCategoryId, _healthWordWorldId);
      expect(screen.categoryId, _healthWordWorldId);
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

  testWidgets('category_detail_time_mode_marks_waiting_stages_as_blocked', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 3),
          localStageCountsProvider.overrideWith(
            (ref, request) async => [0, 2, 1, 0, 0, 0],
          ),
          localStageDueSummaryProvider.overrideWith(
            (ref, request) async => [
              const LocalStageDueSummary(stage: 0, totalCount: 0, dueCount: 0),
              LocalStageDueSummary(
                stage: 1,
                totalCount: 2,
                dueCount: 0,
                nextDueAt: DateTime(2026, 1, 2),
              ),
              const LocalStageDueSummary(stage: 2, totalCount: 1, dueCount: 1),
              const LocalStageDueSummary(stage: 3, totalCount: 0, dueCount: 0),
              const LocalStageDueSummary(stage: 4, totalCount: 0, dueCount: 0),
              const LocalStageDueSummary(stage: 5, totalCount: 0, dueCount: 0),
            ],
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

    final row = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    expect(row.blockedMask?[1], isTrue);
    expect(row.blockedMask?[2], isFalse);
  });

  testWidgets('category_detail_hybrid_mode_marks_waiting_stages_as_blocked', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 3),
          localStageCountsProvider.overrideWith(
            (ref, request) async => [0, 0, 0, 2, 1, 0],
          ),
          localStageDueSummaryProvider.overrideWith((ref, request) async {
            if (request.mode != LearningMode.hybrid) {
              return const <LocalStageDueSummary>[];
            }
            return [
              const LocalStageDueSummary(stage: 0, totalCount: 0, dueCount: 0),
              const LocalStageDueSummary(stage: 1, totalCount: 0, dueCount: 0),
              const LocalStageDueSummary(stage: 2, totalCount: 0, dueCount: 0),
              LocalStageDueSummary(
                stage: 3,
                totalCount: 2,
                dueCount: 0,
                nextDueAt: DateTime(2026, 1, 2),
              ),
              const LocalStageDueSummary(stage: 4, totalCount: 1, dueCount: 1),
              const LocalStageDueSummary(stage: 5, totalCount: 0, dueCount: 0),
            ];
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
    await tester.tap(find.text('Kombiniert'));
    await tester.pump();
    await tester.pump();

    final row = tester.widget<StageSwitchRowView>(
      find.byType(StageSwitchRowView),
    );
    expect(row.blockedMask?[3], isTrue);
    expect(row.blockedMask?[4], isFalse);
  });

  testWidgets(
    'category_detail_screen_local_start_passes_time_mode_by_default',
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
      await tester.tap(find.byType(StartButtonPulse));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<LearnModeScreen>(
        find.byType(LearnModeScreen),
      );
      expect(screen.localCategoryId, _healthWordWorldId);
      expect(screen.localLearningMode, LearningMode.time);
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
      expect(screen.localCategoryId, _healthWordWorldId);
      expect(screen.localLearningMode, LearningMode.adaptive);
    },
  );

  testWidgets('category_detail_screen_local_reset_defaults_to_time_mode', (
    tester,
  ) async {
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
            (ref, request) async => [25, 0, 0, 0, 0, 0],
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
    await tester.tap(find.byIcon(Icons.restart_alt_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen'));
    await tester.pumpAndSettle();

    expect(resetService.lastRequest?.categoryId, _healthWordWorldId);
    expect(resetService.lastRequest?.mode, LearningMode.time);
  });

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

      expect(resetService.lastRequest?.categoryId, _healthWordWorldId);
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
        categoryId: _healthWordWorldId,
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

      expect(resetService.lastRequest?.categoryId, _healthWordWorldId);
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
      expect(screen.categoryId, _healthWordWorldId);
      expect(screen.title, 'Health & Fitness');
      expect(find.text('Health & Fitness'), findsWidgets);
      expect(find.text('Noch keine Wörter'), findsOneWidget);
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
    SrsStage stage, {
    LearningMode mode = LearningMode.adaptive,
    DateTime? nextDueAt,
  }) async {
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
                nextDueAt: nextDueAt,
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
                  mode: mode,
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

  testWidgets('stage_inspector_time_mode_shows_due_wait_and_word_countdown', (
    tester,
  ) async {
    await pumpStageInspectorLegend(
      tester,
      SrsStage.s2,
      mode: LearningMode.time,
      nextDueAt: DateTime.now().add(const Duration(days: 3, hours: 2)),
    );

    expect(
      find.textContaining('Zeitplan: Merkstufe 2 hat 3 Tage'),
      findsOneWidget,
    );
    expect(find.textContaining('Nächster Termin:'), findsOneWidget);
    expect(find.textContaining('in 3T'), findsOneWidget);
  });

  testWidgets('stage_inspector_hybrid_mode_shows_due_wait_from_s3', (
    tester,
  ) async {
    await pumpStageInspectorLegend(
      tester,
      SrsStage.s3,
      mode: LearningMode.hybrid,
      nextDueAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
    );

    expect(
      find.textContaining('Kombination: Merkstufe 3 hat 1 Tag'),
      findsOneWidget,
    );
    expect(find.textContaining('Nächster Termin:'), findsOneWidget);
    expect(find.textContaining('in 1T'), findsOneWidget);
  });
}
