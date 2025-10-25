import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/application/category_detail_controller.dart';

// ===== KONSTANTEN =====
const kAccentBlue = Color(0xFFB1CCFE);
const kTopCapsuleH = 260.0; // vorher 240
const kLevelsCardH = 260.0;
const kGapBelowTop = 16.0;
const kGapAboveBottom = 40.0;
const kPageBottomPadding = 24.0;

// Offsets für Top-Kachel - wie im Learn-Mode
const kTopRowOffsetX = 0.0;
const kTopRowOffsetY = 0.0;
const kWheelOffsetX = 0.0;
const kWheelOffsetY = 0.0;
const kTopVocabsTileOffsetX = 0.0;
const kTopVocabsTileOffsetY = 0.0;
const kTopRightBtnsOffsetX = 0.0;
const kTopRightBtnsOffsetY = 0.0;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryDetailControllerProvider.notifier).init(
        categoryId: widget.categoryId,
        categorySlug: widget.categorySlug,
        fallbackTitle: widget.title,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(categoryDetailControllerProvider.notifier).disposeSubscriptions();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(categoryDetailControllerProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(categoryDetailControllerProvider);
    final loading = s.loading;
    final stages = s.progress?.stages ?? const [0,0,0,0,0,0];

    final dailyTotal = s.dailyNew + s.dailyRepeats;
    const dailyTarget = 20;
    final dailyPercent = dailyTarget == 0 ? 0.0 : (dailyTotal / dailyTarget).clamp(0.0,1.0);

    final totalWords = s.progress?.total ?? stages.fold<int>(0, (a,b)=>a+b);
    final learnedWords = stages.skip(1).fold<int>(0,(a,b)=>a+b);
    final overallPercent = totalWords == 0 ? 0.0 : (learnedWords/totalWords).clamp(0.0,1.0);
    final overallLabel = '$learnedWords/$totalWords';

    final cats = s.categories;
    final selIndex = s.selectedIndex;
    final currentId = cats.isNotEmpty ? cats[selIndex].id : '';

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(
      body: SafeArea(
                child: Column(
                  children: [
            // FIX: fester Header – kein Flexible
            SizedBox(
              height: kTopCapsuleH,
              child: CategoryHeaderCapsule(
                height: kTopCapsuleH,
                title: cats.isNotEmpty ? cats[selIndex].name : widget.title,
                vocabsCount: s.vocabsTotal,
                categories: cats.map((e)=>e.name).toList(),
                selectedIndex: cats.isEmpty ? 0 : selIndex.clamp(0, cats.length - 1),
                onWheelChanged: (idx, _) => ref.read(categoryDetailControllerProvider.notifier).switchTo(idx),
                      onBack: () => Navigator.of(context).pop(),
                      onVocabs: () {
                  final currentName = cats.isNotEmpty ? cats[selIndex].name : widget.title;
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
                wheelOffsetX: kWheelOffsetX,
                wheelOffsetY: kWheelOffsetY,
                rowOffsetX: kTopRowOffsetX,
                rowOffsetY: kTopRowOffsetY,
                vocabsTileOffsetX: kTopVocabsTileOffsetX,
                vocabsTileOffsetY: kTopVocabsTileOffsetY,
                rightBtnsOffsetX: kTopRightBtnsOffsetX,
                rightBtnsOffsetY: kTopRightBtnsOffsetY,
                wheelBottomGap: 28.0,     // sichtbarer Abstand unter dem Wheel
                accentColor: kAccentBlue,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),

            const SizedBox(height: kGapBelowTop),

            // FIX: Mittel + Levels scrollbar machen, damit nix überläuft
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: kPageBottomPadding),
                      child: Column(
                        children: [
                    LearningStatusPanel(
                                percent: dailyPercent,
                      percentLabel: '${(dailyPercent*100).round()}%',
                      newCount: s.dailyNew,
                      repeatsCount: s.dailyRepeats,
                      repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
                      overallPercent: overallPercent,
                      overallLabel: overallLabel,
                          ),

                    const SizedBox(height: kGapAboveBottom),
                          Transform.translate(
                      offset: const Offset(0, -24), // 🔼 nach oben (spiel mit -16…-32)
                            child: SizedBox(
                        height: kLevelsCardH,
                        child: LevelsCard(
                                  height: kLevelsCardH,
                                  stages: stages,
                                  goalPerStage: 100,
                                  onStartPressed: () async {
                            if (currentId.isEmpty) return;
                            await ref.read(categoryDetailControllerProvider.notifier).seedForStart(currentId);
                            if (mounted) {
                              await Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => LearnModeScreen(
                                          categoryId: currentId,
                                  title: cats.isNotEmpty ? cats[selIndex].name : widget.title,
                                ),
                              ));
                              await ref.read(categoryDetailControllerProvider.notifier).reload();
                            }
                          },
                        ),
                      ),
                      ),
                    ],
                  ),
          ),
            ),
          ],
        ),
      ),
    );
  }
}