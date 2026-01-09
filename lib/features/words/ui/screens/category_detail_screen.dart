import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/mode_toggle.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/category_detail_controller.dart';
import 'package:talvori/features/words/application/category_detail_state.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
// removed srs_mode_provider import to avoid SrsSystem conflicts; we use controller enum
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle_with_hint.dart';
import 'package:talvori/features/words/application/learn_navigation_origin.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';



// ===== KONSTANTEN =====
const kAccentBlue = Color(0xFFB1CCFE);

/// ==============================
/// SCREEN
/// ==============================
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String title;              // z.B. "Health & Fitness"
  final String? categoryId;        // Supabase UUID (word_categories.id); kann null sein
  final String? categorySlug;    // fallback:
  final WordListFilter listFilter; // Fallback/Anzeige-Liste

  const CategoryDetailScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.categorySlug,
    required this.listFilter,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> with WidgetsBindingObserver {
  ProviderSubscription<CategoryDetailState>? _controllerSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Controller-Listener ohne ref in dispose
    _controllerSub = ref.listenManual<CategoryDetailState>(
      categoryDetailControllerProvider,
      (prev, next) {
        // Optional: auf State-Änderungen reagieren
      },
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryDetailControllerProvider.notifier).init(
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    final s = ref.watch(categoryDetailControllerProvider);
    final loading = s.loading;
    final stages = s.progress?.stages ?? const [0,0,0,0,0,0];
    final mode = ref.watch(levelSelectionProvider);
    final selecting = ref.watch(selectingSingleProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));

    final dailyTotal = s.dailyNew + s.dailyRepeats;
    const dailyTarget = 20;
    final dailyPercent = dailyTarget == 0 ? 0.0 : (dailyTotal / dailyTarget).clamp(0.0,1.0);

    final totalWords = s.progress?.total ?? stages.fold<int>(0, (a,b)=>a+b);
    final learnedWords = stages.skip(1).fold<int>(0,(a,b)=>a+b);
    final overallPercent = totalWords == 0 ? 0.0 : (learnedWords/totalWords).clamp(0.0,1.0);
    final overallLabel = '$learnedWords/$totalWords';

    final cats = s.categories;
    final selIndex = s.selectedIndex;
    // Sicherstellen, dass selIndex gültig ist
    final validSelIndex = cats.isNotEmpty && selIndex >= 0 && selIndex < cats.length 
        ? selIndex 
        : 0;
    final currentId = cats.isNotEmpty && validSelIndex < cats.length 
        ? cats[validSelIndex].id 
        : (widget.categoryId ?? '');

    // Fix 4: Loader nur zeigen, wenn wirklich leer
    if (loading && s.categories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    final srs = ref.watch(srsModeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // FIX: fester Header
                SizedBox(
                  height: WordsLayout.topCapsuleH,
                  child: CategoryHeaderCapsule(
                    height: WordsLayout.topCapsuleH,
                    title: cats.isNotEmpty && validSelIndex < cats.length ? cats[validSelIndex].name : widget.title,
                    vocabsCount: s.vocabsTotal,
                    categories: cats.map((e)=>e.name).toList(),
                    selectedIndex: cats.isEmpty ? 0 : validSelIndex.clamp(0, cats.length - 1),
                    onWheelChanged: (idx, _) => ref.read(categoryDetailControllerProvider.notifier).switchTo(idx),
                    onBack: () => Navigator.of(context).pop(),
                    onVocabs: () {
                      if (currentId.isEmpty) return;
                      final currentName = cats.isNotEmpty && validSelIndex < cats.length ? cats[validSelIndex].name : widget.title;
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings tapped')),
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
                    trailingRightBelow: const SrsModeToggleWithHint(),
                  ),
                ),

                const SizedBox(height: WordsLayout.gapBelowTop),

                // Daily Progress - mit reduziertem Padding
                Flexible(
                  child: LearningStatusPanel(
                    percent: dailyPercent,
                    percentLabel: '${(dailyPercent*100).round()}%',
                    newCount: s.dailyNew,
                    repeatsCount: s.dailyRepeats,
                    repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
                    overallPercent: overallPercent,
                    overallLabel: overallLabel,
                  ),
                ),

                // Reduzierter Abstand zwischen Overall Progress und Level-Selection-Buttons
                const SizedBox(height: 17),

                // Levels Card mit Start-Button - ohne Transform.translate, damit es besser passt
                SizedBox(
                  height: WordsLayout.levelsCardH,
                  child: LevelsCard(
                    height: WordsLayout.levelsCardH,
                    stages: stages,
                    goalPerStage: 100,
                    mode: mode,
                    selectingSingle: selecting,
                    visibleMask: mask,
                    categoryId: currentId.isEmpty ? null : currentId, // Für Dialog
                    onSelectSingleStage: (stg) {
                      ref.read(singleStageProvider.notifier).state = stg;
                      ref.read(selectingSingleProvider.notifier).state = false;
                    },
                    onModeChanged: (m) async {
                      ref.read(levelSelectionProvider.notifier).state = m;
                      if (m == LevelSelectionMode.single) {
                        ref.read(selectingSingleProvider.notifier).state = true;
                      } else {
                        ref.read(selectingSingleProvider.notifier).state = false;
                      }
                    },
                    titleOffsetY: -15,
                    onStartPressed: () async {
                      if (currentId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kategorie konnte nicht geladen werden')),
                        );
                        return;
                      }
                      try {
                        await ref.read(categoryDetailControllerProvider.notifier).seedForStart(currentId);
                        if (mounted) {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => LearnModeScreen(
                              categoryId: currentId,
                              title: cats.isNotEmpty && validSelIndex < cats.length 
                                  ? cats[validSelIndex].name 
                                  : widget.title,
                              navigationOrigin: LearnNavigationOrigin.category(
                                categoryId: currentId,
                                categoryTitle: cats.isNotEmpty && validSelIndex < cats.length 
                                    ? cats[validSelIndex].name 
                                    : widget.title,
                              ),
                            ),
                          ));
                          if (mounted) {
                            await ref.read(categoryDetailControllerProvider.notifier).reload();
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fehler beim Starten: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
                
                // Minimales Padding am Ende
                const SizedBox(height: 5),
              ],
            ),

            if (srs.counting) Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  alignment: const Alignment(0, -1.0),
        child: Column(
                    mainAxisSize: MainAxisSize.min,
          children: [
                      const Text(
                        'System wird auf Hybrid umgestellt',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${srs.count}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}