import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/providers/local_category_progress_reset_provider.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/local_database/models/local_stage_due_summary.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_due_summary_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_review_history_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/local_database/adapters/category_detail_debug_local_button_presenter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_category_adapter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_start_path.dart';
import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';
import 'package:talvori/features/words/application/local_learning_mode_mapper.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/widgets/learning_mode_selector.dart';
import 'package:talvori/features/words/ui/widgets/local_stage_inspector_sheet.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/category_detail_controller.dart';
import 'package:talvori/features/words/application/category_detail_state.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
// removed srs_mode_provider import to avoid SrsSystem conflicts; we use controller enum
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle_with_hint.dart';
import 'package:talvori/features/words/application/learn_navigation_origin.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/category_settings_dialog.dart';
import 'package:talvori/features/words/ui/widgets/category_detail_hint_bubble.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/application/tooltip_settings_provider.dart'
    show
        showTooltipsAlwaysProvider,
        hasSeenLockTooltipProvider,
        hasSeenSingleTooltipProvider,
        hasSeenTrainingTooltipProvider,
        hasSeenVocabsTooltipProvider,
        hasSeenWheelTooltipProvider,
        hasSeenAutoTooltipProvider,
        resetCategoryDetailTooltipFlags;
import 'package:talvori/features/words/ui/widgets/contextual_tooltip.dart';

// ===== KONSTANTEN =====
const kAccentBlue = Color(0xFFB1CCFE);
const _levelsCardWithLearningModeH = WordsLayout.levelsCardH + 100;
const _localLevelsCardWithLearningModeH = WordsLayout.levelsCardH + 220;

/// ==============================
/// SCREEN
/// ==============================
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String title; // z.B. "Health & Fitness"
  final String?
  categoryId; // Supabase UUID (word_categories.id); kann null sein
  final String? categorySlug; // fallback:
  final WordListFilter listFilter; // Fallback/Anzeige-Liste
  final bool useLocalOfflineFlow;
  final String? localCategoryId;
  final List<String>? localCategoryIds;
  final List<LocalCategoryDetailGroupItem>? localCategoryItems;
  final String? localSelectedWordHubKey;

  const CategoryDetailScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.categorySlug,
    required this.listFilter,
    this.useLocalOfflineFlow = false,
    this.localCategoryId,
    this.localCategoryIds,
    this.localCategoryItems,
    this.localSelectedWordHubKey,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen>
    with WidgetsBindingObserver {
  ProviderSubscription<CategoryDetailState>? _controllerSub;

  final _vocabsKey = GlobalKey();
  final _wheelKey = GlobalKey();
  final _lockKey = GlobalKey();
  final _autoButtonKey = GlobalKey();
  final _trainingButtonKey = GlobalKey();
  final _singleButtonKey = GlobalKey();
  int _localSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.useLocalOfflineFlow) {
      return;
    }

    // Controller-Listener ohne ref in dispose
    _controllerSub = ref.listenManual<CategoryDetailState>(
      categoryDetailControllerProvider,
      (prev, next) {
        // Optional: auf State-Änderungen reagieren
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoryDetailControllerProvider.notifier)
          .init(
            categoryId: widget.categoryId,
            categorySlug: widget.categorySlug,
            fallbackTitle: widget.title,
          );
      // Sicherstellen: Toggle startet NICHT im Hybrid-Modus
      final ctrl = ref.read(srsModeControllerProvider.notifier);
      final st = ref.read(srsModeControllerProvider);
      if (st.mode == SrsSystem.hybrid) {
        // per Tap-Logik zurück (setzt auf lastNonHybrid)
        ctrl.tap();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ✅ Subscription ohne ref schließen
    _controllerSub?.close();
    _controllerSub = null;
    super.dispose();
  }

  Future<void> _maybeShowLockTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenLockTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Hier sperrst du das Fach 0.',
        line2: 'Es werden keine Wörter mehr rausgegeben.',
        targetKey: _lockKey,
      );
      await ref.read(hasSeenLockTooltipProvider.notifier).markSeen();
    }
  }

  Future<void> _maybeShowSingleTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenSingleTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Du trainierst gezielt nur eine Stufe.',
        line2: '',
        targetKey: _singleButtonKey,
      );
      await ref.read(hasSeenSingleTooltipProvider.notifier).markSeen();
    }
  }

  Future<void> _maybeShowTrainingTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenTrainingTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Du trainierst gezielt diesen Bereich.',
        line2: 'Drücke Start, um zu beginnen.',
        targetKey: _trainingButtonKey,
      );
      await ref.read(hasSeenTrainingTooltipProvider.notifier).markSeen();
    }
  }

  Future<void> _maybeShowVocabsTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenVocabsTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Hier siehst du alle Wörter dieser Kategorie.',
        line2: 'Tippe auf eine Stufe für Details.',
        targetKey: _vocabsKey,
      );
      await ref.read(hasSeenVocabsTooltipProvider.notifier).markSeen();
    }
  }

  Future<void> _maybeShowAutoTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenAutoTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Zurück im normalen Modus.',
        line2: '',
        targetKey: _autoButtonKey,
      );
      await ref.read(hasSeenAutoTooltipProvider.notifier).markSeen();
    }
  }

  Future<void> _maybeShowWheelTooltip() async {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenWheelTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Hier kannst du zwischen Kategorien wechseln.',
        line2: '',
        targetKey: _wheelKey,
      );
      await ref.read(hasSeenWheelTooltipProvider.notifier).markSeen();
    }
  }

  Widget _buildHintOrProgress({
    required WidgetRef ref,
    required String currentId,
    required double dailyPercent,
    required int dailyTotal,
    required int dailyTarget,
    required CategoryDetailState s,
    required double overallPercent,
    required String overallLabel,
    required List<int> stages,
  }) {
    final showDaily =
        ref.watch(returnedFromLearnSessionProvider) &&
        !ref.watch(userHasInteractedWithModeProvider);
    if (showDaily) {
      return LearningStatusPanel(
        percent: dailyPercent,
        percentLabel: '${(dailyPercent * 100).round()}%',
        newCount: s.dailyNew,
        repeatsCount: s.dailyRepeats,
        repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
        overallPercent: overallPercent,
        overallLabel: overallLabel,
      );
    }
    final s0Locked = currentId.isEmpty
        ? false
        : ref
              .watch(s0LockedProvider(currentId))
              .maybeWhen(data: (v) => v, orElse: () => false);
    return Center(
      child: CategoryDetailHintBubble(
        categoryId: currentId.isEmpty ? null : currentId,
        s0Locked: s0Locked,
        stages: stages,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.useLocalOfflineFlow) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      // Reload über WidgetsBinding, nicht über ref
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(categoryDetailControllerProvider.notifier).reload();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useLocalOfflineFlow) {
      return _buildLocalOfflineFlow(context);
    }

    debugPrint('🔁 CategoryDetail BUILD');
    final s = ref.watch(categoryDetailControllerProvider);
    final loading = s.loading;
    final mode = ref.watch(levelSelectionProvider);
    final selecting = ref.watch(selectingSingleProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));

    final cats = s.categories;
    final selIndex = s.selectedIndex;
    // Sicherstellen, dass selIndex gültig ist
    final validSelIndex =
        cats.isNotEmpty && selIndex >= 0 && selIndex < cats.length
        ? selIndex
        : 0;
    final currentId = cats.isNotEmpty && validSelIndex < cats.length
        ? cats[validSelIndex].id
        : (widget.categoryId ?? '');

    // Fix 4: Loader nur zeigen, wenn wirklich leer
    if (loading && s.categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ⬇️ WICHTIG: Progress aus mode-abhängigem Provider (nicht aus Controller-State)
    // Provider-Key muss (categoryId, mode) sein, damit beim Mode-Wechsel neu geladen wird
    final srs = ref.watch(srsModeControllerProvider);

    // 1️⃣ LearnMode-State abfragen
    final learnState = ref.watch(learnModeControllerProvider);
    final isLearning =
        learnState.inLearnScreen &&
        learnState.categoryId.isNotEmpty &&
        learnState.categoryId == currentId;

    // ✅ Im Learn-Mode: learnState nutzen (wird nach jedem Review aus serverProgress aktualisiert).
    // Ohne Invalidate von categoryProgressProvider bleibt dessen Cache sonst veraltet.
    final useLearnState = isLearning;

    // ✅ Für A-SRS: categoryProgressProvider immer laden (auch wenn isLearning)
    final progAsync = currentId.isNotEmpty
        ? ref.watch(categoryProgressProvider((catId: currentId, srs: srs.mode)))
        : AsyncValue.data(
            CategoryProgress(
              total: 0,
              stages: [0, 0, 0, 0, 0, 0],
              dueToday: 0,
              newTotal: 0,
            ),
          );

    debugPrint(
      '🧭 CategoryDetail: mode=${srs.mode} isLearning=$isLearning useLearnState=$useLearnState progState=${progAsync.runtimeType} loading=${progAsync.isLoading} hasValue=${progAsync.hasValue}',
    );

    // 2️⃣ Stage-Quelle korrekt wählen
    // ✅ Für A-SRS: IMMER Server-Daten verwenden, auch während Learn-Mode
    // ✅ FIX: Bei loading + hasValue die vorhandenen Daten weiter anzeigen (kein Flicker)
    // total = volle Kategoriegröße (nicht Summe der Stages)
    final (stages, totalWords) = useLearnState
        ? (learnState.stages, learnState.totalWordsInCategory)
        : (
            progAsync.valueOrNull?.stages ?? const [-1, -1, -1, -1, -1, -1],
            progAsync.valueOrNull?.total ?? -1,
          );

    debugPrint(
      '✅ CategoryDetail: stages=$stages (isLearning=$isLearning, useLearnState=$useLearnState, source=${useLearnState ? "learnState" : "categoryProgressProvider"})',
    );

    // ⬇️ FIX für A-SRS und Hybrid: Stage 0 = vocabsTotal - learnedWords (TEMPORÄR AUS für Debugging)
    // TODO: Wieder aktivieren nach Backend-Fix
    /*
    final learnedWords = stages.skip(1).fold<int>(0,(a,b)=>a+b);
    if ((srs.mode == SrsSystem.adaptive || srs.mode == SrsSystem.hybrid) && currentId.isNotEmpty) {
      // Bei A-SRS/Hybrid: Stage 0 enthält alle Wörter in der Kategorie, die noch nicht in S1-S5 sind
      final correctedStage0 = (s.vocabsTotal - learnedWords).clamp(0, 1 << 30);
      stages = [correctedStage0, ...stages.skip(1)];
    }
    */
    final learnedWords = stages.skip(1).fold<int>(0, (a, b) => a + b);

    final dailyTotal = s.dailyNew + s.dailyRepeats;
    const dailyTarget = 20;
    final dailyPercent = dailyTarget == 0
        ? 0.0
        : (dailyTotal / dailyTarget).clamp(0.0, 1.0);

    final overallPercent = totalWords == 0
        ? 0.0
        : (learnedWords / totalWords).clamp(0.0, 1.0);
    final overallLabel = '$learnedWords/$totalWords';
    final debugLocalStartPath = CategoryDetailLocalStartPath(
      categoryAdapter: CategoryDetailLocalCategoryAdapter(
        resolver: const LocalCategoryIdResolver(),
      ),
    ).resolve(categorySlug: widget.categorySlug);
    final debugLocalButtonState =
        const CategoryDetailDebugLocalButtonPresenter().present(
          debugLocalStartPath,
        );

    return _buildCategoryDetailFrame(
      onPointerDown: (_) {
        if (ref.read(returnedFromLearnSessionProvider)) {
          ref.read(userHasInteractedWithModeProvider.notifier).state = true;
          ref.read(returnedFromLearnSessionProvider.notifier).state = false;
        }
      },
      children: [
        // FIX: fester Header
        SizedBox(
          height: WordsLayout.topCapsuleH,
          child: CategoryHeaderCapsule(
            height: WordsLayout.topCapsuleH,
            title: cats.isNotEmpty && validSelIndex < cats.length
                ? cats[validSelIndex].name
                : widget.title,
            vocabsCount: s.vocabsTotal,
            categories: cats.map((e) => e.name).toList(),
            selectedIndex: cats.isEmpty
                ? 0
                : validSelIndex.clamp(0, cats.length - 1),
            vocabsKey: _vocabsKey,
            wheelKey: _wheelKey,
            onWheelChanged: (idx, label) {
              _maybeShowWheelTooltip();
              ref.read(categoryDetailControllerProvider.notifier).switchTo(idx);
            },
            onBack: () async {
              await resetCategoryDetailTooltipFlags(ref);
              if (context.mounted) Navigator.of(context).pop();
            },
            onVocabs: () {
              _maybeShowVocabsTooltip();
              if (currentId.isEmpty) return;
              final currentName = cats.isNotEmpty && validSelIndex < cats.length
                  ? cats[validSelIndex].name
                  : widget.title;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WordListScreen(
                    filter: widget.listFilter,
                    overrideCategoryId: currentId,
                    overrideCategoryLabel: currentName,
                  ),
                ),
              );
            },
            onAdd: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Add tapped')));
            },
            onSettings: () {
              showDialog(
                context: context,
                builder: (_) => const CategorySettingsDialog(),
              );
            },
            // Offsets wie im Learn-Mode:
            wheelOffsetX: WordsLayout.wheelOffsetX,
            wheelOffsetY: WordsLayout.wheelOffsetY,
            rowOffsetX: WordsLayout.rowOffsetX,
            rowOffsetY: WordsLayout.rowOffsetY,
            vocabsTileOffsetX: WordsLayout.vocabsTileOffsetX,
            vocabsTileOffsetY: WordsLayout.vocabsTileOffsetY,
            rightBtnsOffsetX: WordsLayout.rightBtnsOffsetX,
            rightBtnsOffsetY: WordsLayout.rightBtnsOffsetY,
            wheelBottomGap: WordsLayout.wheelBottomGap,
            accentColor: kAccentBlue,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            trailingRightBelow: SrsModeToggleWithHint(
              onUserTap: () {
                ref.read(userHasInteractedWithModeProvider.notifier).state =
                    true;
                ref.read(returnedFromLearnSessionProvider.notifier).state =
                    false;
              },
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Daily Progress nur nach Rückkehr aus Learn-Session; sonst Sprechblase
        Flexible(
          child: _buildHintOrProgress(
            ref: ref,
            currentId: currentId,
            dailyPercent: dailyPercent,
            dailyTotal: dailyTotal,
            dailyTarget: dailyTarget,
            s: s,
            overallPercent: overallPercent,
            overallLabel: overallLabel,
            stages: stages,
          ),
        ),

        // Reduzierter Abstand zwischen Overall Progress und Level-Selection-Buttons
        const SizedBox(height: 17),

        // Levels Card mit Start-Button - ohne Transform.translate, damit es besser passt
        SizedBox(
          height: _levelsCardWithLearningModeH,
          child: Builder(
            builder: (context) {
              debugPrint(
                '🧾 UI stages: mode=${srs.mode} cat=$currentId '
                'loading=${progAsync.isLoading} hasValue=${progAsync.valueOrNull != null} '
                'total=$totalWords stages=$stages',
              );

              // Wenn stages -1 enthält, dann Loading-State (während Refresh)
              final displayStages = stages.any((s) => s == -1)
                  ? const [0, 0, 0, 0, 0, 0] // Loading: Zeige 0 statt -1
                  : stages;

              return LevelsCard(
                height: _levelsCardWithLearningModeH,
                stages: displayStages,
                goalPerStage: 100,
                learningModeSelector: const LearningModeSelector(),
                mode: mode,
                selectingSingle: selecting,
                visibleMask: mask,
                categoryId: currentId.isEmpty ? null : currentId, // Für Dialog
                lockKey: _lockKey,
                switchesOffsetY: 0,
                startBtnOffsetY: 8,
                autoButtonKey: _autoButtonKey,
                trainingButtonKey: _trainingButtonKey,
                singleButtonKey: _singleButtonKey,
                onSelectSingleStage: (stg) {
                  ref.read(userHasInteractedWithModeProvider.notifier).state =
                      true;
                  ref.read(returnedFromLearnSessionProvider.notifier).state =
                      false;
                  ref.read(singleStageProvider.notifier).state = stg;
                  ref.read(selectingSingleProvider.notifier).state = false;
                },
                onModeChanged: (m) async {
                  if (m == LevelSelectionMode.s0toS5) {
                    _maybeShowAutoTooltip();
                  } else if (m == LevelSelectionMode.single) {
                    _maybeShowSingleTooltip();
                  } else if (m == LevelSelectionMode.s1toS5) {
                    _maybeShowTrainingTooltip();
                  }
                  ref.read(userHasInteractedWithModeProvider.notifier).state =
                      true;
                  ref.read(returnedFromLearnSessionProvider.notifier).state =
                      false;
                  ref.read(levelSelectionProvider.notifier).state = m;
                  if (m == LevelSelectionMode.single) {
                    ref.read(selectingSingleProvider.notifier).state = true;
                  } else {
                    ref.read(selectingSingleProvider.notifier).state = false;
                  }
                },
                onBeforeLockTap: _maybeShowLockTooltip,
                onS0LockTapped: () {
                  ref.read(userHasInteractedWithModeProvider.notifier).state =
                      true;
                  ref.read(returnedFromLearnSessionProvider.notifier).state =
                      false;
                },
                titleOffsetY: 0,
                onStartPressed: () async {
                  if (currentId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kategorie konnte nicht geladen werden'),
                      ),
                    );
                    return;
                  }
                  final localCategoryId = debugLocalButtonState.localCategoryId;
                  final currentTitle =
                      cats.isNotEmpty && validSelIndex < cats.length
                      ? cats[validSelIndex].name
                      : widget.title;
                  final navigationOrigin = LearnNavigationOrigin.category(
                    categoryId: currentId,
                    categoryTitle: currentTitle,
                  );

                  if (localCategoryId != null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LearnModeScreen(
                          categoryId: currentId,
                          title: currentTitle,
                          useLocalOfflineFlow: true,
                          localCategoryId: localCategoryId,
                          navigationOrigin: navigationOrigin,
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await ref
                        .read(categoryDetailControllerProvider.notifier)
                        .seedForStart(currentId);
                    if (!context.mounted) return;
                    if (mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LearnModeScreen(
                            categoryId: currentId,
                            title: currentTitle,
                            navigationOrigin: navigationOrigin,
                          ),
                        ),
                      );
                      if (mounted) {
                        ref
                                .read(returnedFromLearnSessionProvider.notifier)
                                .state =
                            true;
                        ref
                                .read(
                                  userHasInteractedWithModeProvider.notifier,
                                )
                                .state =
                            false;
                      }
                      if (mounted) {
                        // Progress Provider immer invalidieren bei Rückkehr (Fortschritt wurde im Learn-Mode gespeichert)
                        final srs = ref.read(srsModeControllerProvider).mode;
                        ref.invalidate(
                          categoryProgressProvider((
                            catId: currentId,
                            srs: srs,
                          )),
                        );
                        ref.invalidate(learnedInStage5Provider(currentId));
                        // Controller neu laden (lädt vocabsTotal, categories, progress)
                        await ref
                            .read(categoryDetailControllerProvider.notifier)
                            .reload();
                      }
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Starten: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),

        if (kDebugMode && debugLocalButtonState.isVisible)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                final localCategoryId = debugLocalButtonState.localCategoryId;
                if (localCategoryId == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => buildLocalLearningDebugScreen(
                      categoryId: localCategoryId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report_outlined, size: 18),
              label: const Text('Lokalen Debug-Lernscreen öffnen'),
            ),
          ),

        // Minimales Padding am Ende
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildCategoryDetailFrame({
    required List<Widget> children,
    PointerDownEventListener? onPointerDown,
    bool scrollable = false,
  }) {
    final content = scrollable
        ? LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(children: children),
                ),
              );
            },
          )
        : Column(children: children);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (onPointerDown == null)
              content
            else
              Listener(onPointerDown: onPointerDown, child: content),
          ],
        ),
      ),
    );
  }

  List<String> _localWheelLabelsFromCategoryIds(
    List<String> wheelCategoryIds,
    String title,
  ) {
    final localCategoriesAsync = ref.watch(localCategoriesProvider);
    final localCategoryNamesById = {
      for (final category in localCategoriesAsync.valueOrNull ?? const [])
        category.id: category.name,
    };
    final wheelLabels = <String>[
      for (final categoryId in wheelCategoryIds)
        localCategoryNamesById[categoryId] ??
            (wheelCategoryIds.length == 1 ? title : categoryId),
    ];
    if (wheelLabels.length == 1) {
      wheelLabels[0] = title;
    }
    return wheelLabels;
  }

  Widget _buildLocalOfflineFlow(BuildContext context) {
    final localCategoryItems =
        widget.localCategoryItems
            ?.where((item) => item.displayLabel.trim().isNotEmpty)
            .toList(growable: false) ??
        const <LocalCategoryDetailGroupItem>[];
    if (localCategoryItems.isNotEmpty) {
      final selectedWordHubKey = widget.localSelectedWordHubKey
          ?.trim()
          .toLowerCase();
      if (selectedWordHubKey != null && selectedWordHubKey.isNotEmpty) {
        final selectedItemIndex = localCategoryItems.indexWhere(
          (item) => item.wordHubKey == selectedWordHubKey,
        );
        if (selectedItemIndex >= 0 &&
            _localSelectedIndex >= localCategoryItems.length) {
          _localSelectedIndex = selectedItemIndex;
        } else if (selectedItemIndex >= 0 && _localSelectedIndex == 0) {
          _localSelectedIndex = selectedItemIndex;
        }
      }
    }
    final localCategoryIds =
        widget.localCategoryIds
            ?.where((id) => id.trim().isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    final fallbackLocalCategoryId =
        widget.localCategoryId ??
        widget.categoryId ??
        widget.categorySlug ??
        '';
    final wheelCategoryIds = localCategoryItems.isNotEmpty
        ? localCategoryItems.map((item) => item.localCategoryId ?? '').toList()
        : localCategoryIds.isNotEmpty
        ? localCategoryIds
        : fallbackLocalCategoryId.isEmpty
        ? const <String>[]
        : <String>[fallbackLocalCategoryId];
    final selectedIndex = wheelCategoryIds.isEmpty
        ? 0
        : _localSelectedIndex.clamp(0, wheelCategoryIds.length - 1);
    final selectedCategoryId = wheelCategoryIds.isEmpty
        ? ''
        : wheelCategoryIds[selectedIndex];
    final selectedLocalCategoryItem = localCategoryItems.isEmpty
        ? null
        : localCategoryItems[selectedIndex];
    final title = widget.title;
    final wheelLabels = localCategoryItems.isNotEmpty
        ? localCategoryItems.map((item) => item.displayLabel).toList()
        : _localWheelLabelsFromCategoryIds(wheelCategoryIds, title);
    const visibleMask = [true, true, true, true, true, true];
    final selectedLearningMode = ref.watch(srsModeControllerProvider).mode;
    final selectedLocalLearningMode = localLearningModeFromSrsSystem(
      selectedLearningMode,
    );
    final selectedReviewMode = ref.watch(levelSelectionProvider);
    final stageCountsRequest = LocalStageCountsRequest(
      categoryId: selectedCategoryId,
      mode: selectedLocalLearningMode,
    );
    final localStageCountsAsync = ref.watch(
      localStageCountsProvider(stageCountsRequest),
    );
    final stages =
        localStageCountsAsync.valueOrNull ??
        List<int>.filled(SrsStage.values.length, 0);
    final usesLocalDueSummary =
        selectedLocalLearningMode == LearningMode.time ||
        selectedLocalLearningMode == LearningMode.hybrid;
    final stageDueSummaryAsync = usesLocalDueSummary
        ? ref.watch(
            localStageDueSummaryProvider(
              LocalStageDueSummaryRequest(
                categoryId: selectedCategoryId,
                mode: selectedLocalLearningMode,
              ),
            ),
          )
        : const AsyncValue<List<LocalStageDueSummary>>.data(
            <LocalStageDueSummary>[],
          );
    final stageDueSummaries = stageDueSummaryAsync.valueOrNull;
    final blockedMask = stageDueSummaries == null
        ? null
        : List<bool>.generate(SrsStage.values.length, (index) {
            if (index == 0 || index >= stageDueSummaries.length) return false;
            return stageDueSummaries[index].isBlocked;
          });
    final localVocabsCount = selectedLocalCategoryItem?.vocabsCount;
    final fallbackLocalVocabsCountAsync =
        localVocabsCount != null || selectedCategoryId.isEmpty
        ? const AsyncValue<int>.data(0)
        : ref.watch(localWordCountProvider(selectedCategoryId));
    final resolvedLocalVocabsCount =
        localVocabsCount ?? fallbackLocalVocabsCountAsync.valueOrNull ?? 0;

    Future<void> openLocalLearnMode() async {
      if (selectedCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Noch nicht lokal verfügbar')),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LearnModeScreen(
            categoryId: selectedCategoryId,
            title: selectedLocalCategoryItem?.displayLabel ?? title,
            useLocalOfflineFlow: true,
            localCategoryId: selectedCategoryId,
            localLearningMode: selectedLocalLearningMode,
            navigationOrigin: LearnNavigationOrigin.category(
              categoryId: selectedCategoryId,
              categoryTitle: selectedLocalCategoryItem?.displayLabel ?? title,
            ),
          ),
        ),
      );
      ref.invalidate(localStageCountsProvider(stageCountsRequest));
    }

    Future<void> resetLocalProgress() async {
      if (selectedCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Noch nicht lokal verfügbar')),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Fortschritt zurücksetzen?'),
          content: const Text(
            'Fortschritt für diese Kategorie und diesen Lernmodus '
            'zurücksetzen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Zurücksetzen'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      await ref
          .read(localCategoryProgressResetServiceProvider)
          .resetToS0(
            LocalCategoryProgressResetRequest(
              categoryId: selectedCategoryId,
              mode: selectedLocalLearningMode,
            ),
          );
      ref
          .read(localLearningControllerProvider.notifier)
          .clearForContext(
            categoryId: selectedCategoryId,
            mode: selectedLocalLearningMode,
          );
      ref.invalidate(localLearningViewModelProvider);
      ref.invalidate(localStageCountsProvider(stageCountsRequest));
      ref.invalidate(localStageInspectorProvider);
      ref.invalidate(localWordDetailProvider);
      ref.invalidate(localWordReviewHistoryProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lernfortschritt wurde zurückgesetzt')),
      );
    }

    Future<void> openStageInspector(int stageIndex) async {
      if (selectedCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Noch nicht lokal verfügbar')),
        );
        return;
      }

      await showLocalStageInspectorSheet(
        context: context,
        categoryId: selectedCategoryId,
        mode: selectedLocalLearningMode,
        stage: SrsStage.values[stageIndex],
        categoryLabel: selectedLocalCategoryItem?.displayLabel ?? title,
      );
      ref.invalidate(localStageCountsProvider(stageCountsRequest));
    }

    return _buildCategoryDetailFrame(
      scrollable: true,
      children: [
        SizedBox(
          height: WordsLayout.topCapsuleH,
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(0.65)),
            child: CategoryHeaderCapsule(
              height: WordsLayout.topCapsuleH,
              title: title,
              vocabsCount: resolvedLocalVocabsCount,
              categories: wheelLabels,
              selectedIndex: selectedIndex,
              vocabsKey: _vocabsKey,
              wheelKey: _wheelKey,
              onWheelChanged: (index, _) {
                setState(() => _localSelectedIndex = index);
              },
              onBack: () => Navigator.of(context).pop(),
              onVocabs: () {
                if (selectedCategoryId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Noch nicht lokal verfügbar')),
                  );
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LocalWordListScreen(
                      categoryId: selectedCategoryId,
                      title: selectedLocalCategoryItem?.displayLabel ?? title,
                    ),
                  ),
                );
              },
              onAdd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lokales Hinzufügen noch nicht angebunden'),
                  ),
                );
              },
              onSettings: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lokale Einstellungen noch nicht angebunden'),
                  ),
                );
              },
              wheelOffsetX: WordsLayout.wheelOffsetX,
              wheelOffsetY: WordsLayout.wheelOffsetY,
              rowOffsetX: WordsLayout.rowOffsetX,
              rowOffsetY: WordsLayout.rowOffsetY,
              vocabsTileOffsetX: WordsLayout.vocabsTileOffsetX,
              vocabsTileOffsetY: WordsLayout.vocabsTileOffsetY,
              rightBtnsOffsetX: WordsLayout.rightBtnsOffsetX,
              rightBtnsOffsetY: WordsLayout.rightBtnsOffsetY,
              wheelBottomGap: WordsLayout.wheelBottomGap,
              accentColor: kAccentBlue,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              neonStyle: true,
            ),
          ),
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: _localLevelsCardWithLearningModeH,
          child: LevelsCardView(
            height: _localLevelsCardWithLearningModeH,
            onStartPressed: openLocalLearnMode,
            isHybrid: false,
            s0Locked: false,
            onS0LockTap: () {},
            lockKey: _lockKey,
            showLockControl: false,
            switchesOffsetY: 0,
            startBtnOffsetY: 0,
            titleOffsetY: 0,
            useFixedStageLayout: true,
            learningModeBelowStages: true,
            stageSectionLabel: 'Merkstufen',
            repeatSectionTopGap: 0,
            stageSectionLabelAlignment: Alignment.bottomCenter,
            stageSectionLabelBottomGap: 12,
            stageTopGap: 82,
            startTopGap: 42,
            learningModeSelector: LearningModeSelectorView(
              selectedMode: selectedLearningMode,
              onModeSelected: (mode) {
                ref.read(srsModeControllerProvider.notifier).setMode(mode);
                ref.read(levelSelectionProvider.notifier).state =
                    LevelSelectionMode.s0toS5;
                ref.read(selectingSingleProvider.notifier).state = false;
              },
            ),
            levelSelector: LevelSelectorButtonsView(
              mode: selectedReviewMode,
              onModeChanged: (mode) {
                ref.read(levelSelectionProvider.notifier).state = mode;
                ref.read(selectingSingleProvider.notifier).state =
                    mode == LevelSelectionMode.single;
              },
            ),
            stageSwitchRow: StageSwitchRowView(
              counts: stages,
              goalPerStage: 100,
              visibleMask: visibleMask,
              showLearnedCounterInStage5: true,
              showSwitchNotes: true,
              useNumericSwitchNotes: true,
              blockedMask: blockedMask,
              learnedInStage5: 0,
              s0Locked: false,
              labels: const StageSwitchLabels(
                newLabel: 'New',
                newNote: '0',
                stagePrefix: 'T',
              ),
              colors: const StageSwitchColors(
                newOuter: Color(0xFF8DBBFF),
                stageOuter: Color(0xFF8DBBFF),
                inner: Color(0xFF0B0B0D),
                disabledOuter: Color(0xFFE9F1FF),
                innerStroke: Color(0xFFB36BFF),
              ),
              onTapStage: openStageInspector,
            ),
            startTrailingControl: _LocalResetButton(
              onPressed: resetLocalProgress,
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

class _LocalResetButton extends StatelessWidget {
  const _LocalResetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A1D), Color(0xFF050505)],
            ),
            border: Border.all(color: Color(0xFFF5BFCB), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF5BFCB).withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 0.2,
              ),
            ],
          ),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.34),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.restart_alt_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}
