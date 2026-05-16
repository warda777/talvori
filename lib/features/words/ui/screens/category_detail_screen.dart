import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/adapters/category_detail_debug_local_button_presenter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_category_adapter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_start_path.dart';
import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';
import 'package:talvori/features/local_learning_debug/routing/local_learning_debug_routes.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
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

  const CategoryDetailScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.categorySlug,
    required this.listFilter,
    this.useLocalOfflineFlow = false,
    this.localCategoryId,
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Listener(
              onPointerDown: (_) {
                if (ref.read(returnedFromLearnSessionProvider)) {
                  ref.read(userHasInteractedWithModeProvider.notifier).state =
                      true;
                  ref.read(returnedFromLearnSessionProvider.notifier).state =
                      false;
                }
              },
              child: Column(
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
                        ref
                            .read(categoryDetailControllerProvider.notifier)
                            .switchTo(idx);
                      },
                      onBack: () async {
                        await resetCategoryDetailTooltipFlags(ref);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      onVocabs: () {
                        _maybeShowVocabsTooltip();
                        if (currentId.isEmpty) return;
                        final currentName =
                            cats.isNotEmpty && validSelIndex < cats.length
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add tapped')),
                        );
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
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      trailingRightBelow: SrsModeToggleWithHint(
                        onUserTap: () {
                          ref
                                  .read(
                                    userHasInteractedWithModeProvider.notifier,
                                  )
                                  .state =
                              true;
                          ref
                                  .read(
                                    returnedFromLearnSessionProvider.notifier,
                                  )
                                  .state =
                              false;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: WordsLayout.gapBelowTop),

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
                    height: WordsLayout.levelsCardH,
                    child: Builder(
                      builder: (context) {
                        debugPrint(
                          '🧾 UI stages: mode=${srs.mode} cat=$currentId '
                          'loading=${progAsync.isLoading} hasValue=${progAsync.valueOrNull != null} '
                          'total=$totalWords stages=$stages',
                        );

                        // Wenn stages -1 enthält, dann Loading-State (während Refresh)
                        final displayStages = stages.any((s) => s == -1)
                            ? const [
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                              ] // Loading: Zeige 0 statt -1
                            : stages;

                        return LevelsCard(
                          height: WordsLayout.levelsCardH,
                          stages: displayStages,
                          goalPerStage: 100,
                          mode: mode,
                          selectingSingle: selecting,
                          visibleMask: mask,
                          categoryId: currentId.isEmpty
                              ? null
                              : currentId, // Für Dialog
                          lockKey: _lockKey,
                          autoButtonKey: _autoButtonKey,
                          trainingButtonKey: _trainingButtonKey,
                          singleButtonKey: _singleButtonKey,
                          onSelectSingleStage: (stg) {
                            ref
                                    .read(
                                      userHasInteractedWithModeProvider
                                          .notifier,
                                    )
                                    .state =
                                true;
                            ref
                                    .read(
                                      returnedFromLearnSessionProvider.notifier,
                                    )
                                    .state =
                                false;
                            ref.read(singleStageProvider.notifier).state = stg;
                            ref.read(selectingSingleProvider.notifier).state =
                                false;
                          },
                          onModeChanged: (m) async {
                            if (m == LevelSelectionMode.s0toS5) {
                              _maybeShowAutoTooltip();
                            } else if (m == LevelSelectionMode.single) {
                              _maybeShowSingleTooltip();
                            } else if (m == LevelSelectionMode.s1toS5) {
                              _maybeShowTrainingTooltip();
                            }
                            ref
                                    .read(
                                      userHasInteractedWithModeProvider
                                          .notifier,
                                    )
                                    .state =
                                true;
                            ref
                                    .read(
                                      returnedFromLearnSessionProvider.notifier,
                                    )
                                    .state =
                                false;
                            ref.read(levelSelectionProvider.notifier).state = m;
                            if (m == LevelSelectionMode.single) {
                              ref.read(selectingSingleProvider.notifier).state =
                                  true;
                            } else {
                              ref.read(selectingSingleProvider.notifier).state =
                                  false;
                            }
                          },
                          onBeforeLockTap: _maybeShowLockTooltip,
                          onS0LockTapped: () {
                            ref
                                    .read(
                                      userHasInteractedWithModeProvider
                                          .notifier,
                                    )
                                    .state =
                                true;
                            ref
                                    .read(
                                      returnedFromLearnSessionProvider.notifier,
                                    )
                                    .state =
                                false;
                          },
                          titleOffsetY: -15,
                          onStartPressed: () async {
                            if (currentId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Kategorie konnte nicht geladen werden',
                                  ),
                                ),
                              );
                              return;
                            }
                            final localCategoryId =
                                debugLocalButtonState.localCategoryId;
                            final currentTitle =
                                cats.isNotEmpty && validSelIndex < cats.length
                                ? cats[validSelIndex].name
                                : widget.title;
                            final navigationOrigin =
                                LearnNavigationOrigin.category(
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
                                  .read(
                                    categoryDetailControllerProvider.notifier,
                                  )
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
                                          .read(
                                            returnedFromLearnSessionProvider
                                                .notifier,
                                          )
                                          .state =
                                      true;
                                  ref
                                          .read(
                                            userHasInteractedWithModeProvider
                                                .notifier,
                                          )
                                          .state =
                                      false;
                                }
                                if (mounted) {
                                  // Progress Provider immer invalidieren bei Rückkehr (Fortschritt wurde im Learn-Mode gespeichert)
                                  final srs = ref
                                      .read(srsModeControllerProvider)
                                      .mode;
                                  ref.invalidate(
                                    categoryProgressProvider((
                                      catId: currentId,
                                      srs: srs,
                                    )),
                                  );
                                  ref.invalidate(
                                    learnedInStage5Provider(currentId),
                                  );
                                  // Controller neu laden (lädt vocabsTotal, categories, progress)
                                  await ref
                                      .read(
                                        categoryDetailControllerProvider
                                            .notifier,
                                      )
                                      .reload();
                                }
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Fehler beim Starten: $e'),
                                  ),
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
                          final localCategoryId =
                              debugLocalButtonState.localCategoryId;
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalOfflineFlow(BuildContext context) {
    final localCategoryId =
        widget.localCategoryId ??
        widget.categoryId ??
        widget.categorySlug ??
        '';
    final title = widget.title;
    const stages = [0, 0, 0, 0, 0, 0];

    Future<void> openLocalLearnMode() async {
      if (localCategoryId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokale Kategorie konnte nicht geladen werden'),
          ),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LearnModeScreen(
            categoryId: localCategoryId,
            title: title,
            useLocalOfflineFlow: true,
            localCategoryId: localCategoryId,
            navigationOrigin: LearnNavigationOrigin.category(
              categoryId: localCategoryId,
              categoryTitle: title,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: WordsLayout.topCapsuleH,
              child: _LocalCategoryHeader(
                title: title,
                localCategoryId: localCategoryId,
                onBack: () => Navigator.of(context).pop(),
                onVocabs: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lokale Wortliste noch nicht angebunden'),
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
                      content: Text(
                        'Lokale Einstellungen noch nicht angebunden',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: WordsLayout.gapBelowTop),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lokale Kategorie',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localCategoryId.isEmpty ? title : localCategoryId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFB1CCFE),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var i = 0; i < stages.length; i++)
                            _LocalStageBadge(label: 'S$i', count: stages[i]),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 148,
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2D2D2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(
                                color: Color(0xFFB1CCFE),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onPressed: openLocalLearnMode,
                          child: const Text('Start'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class _LocalCategoryHeader extends StatelessWidget {
  const _LocalCategoryHeader({
    required this.title,
    required this.localCategoryId,
    required this.onBack,
    required this.onVocabs,
    required this.onAdd,
    required this.onSettings,
  });

  final String title;
  final String localCategoryId;
  final VoidCallback onBack;
  final VoidCallback onVocabs;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: WordsLayout.topPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: WordsLayout.wheelHeight,
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: kAccentBlue, width: 1.4),
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),
          SizedBox(height: WordsLayout.wheelBottomGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onVocabs,
                  child: Container(
                    width: 84,
                    height: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: kAccentBlue, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentBlue.withValues(alpha: 0.28),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localCategoryId.isEmpty ? '0' : localCategoryId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kAccentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LocalCircleButton(icon: Icons.add, onTap: onAdd),
                    const SizedBox(width: 10),
                    _LocalCircleButton(
                      icon: Icons.tune_rounded,
                      onTap: onSettings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalCircleButton extends StatelessWidget {
  const _LocalCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(31),
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF111111),
          border: Border.all(color: kAccentBlue, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kAccentBlue.withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _LocalStageBadge extends StatelessWidget {
  const _LocalStageBadge({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4B866), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE4B866),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text('$count', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
