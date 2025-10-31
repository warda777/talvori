import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/ui/widgets/srs_mode_toggle_with_hint.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/application/quick_sets_providers.dart';
import 'package:talvori/features/words/application/learn_navigation_origin.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_origin.dart';
import 'package:talvori/features/words/application/mix/mix_navigation_controller.dart';

/// “Schnellzugriff”-Detailseite:
/// Gleiche Optik wie CategoryDetailScreen, aber die Wheel hat NUR diese 5 Einträge:
/// [All words, My words, Favorites, Words I know, My mix]
///
/// - Start -> LearnMode nur mit diesen 5 Kategorien im Wheel
/// - Vocabs -> WordList mit zum Tab passenden Filter (so gut wie derzeit möglich)
///
/// WICHTIG: “Words I know” ersetzt “Daily Picks”.
class QuickSetsDetailScreen extends ConsumerStatefulWidget {
  /// Optional: Welcher Tab zuerst ausgewählt sein soll (0..4)
  final int initialIndex;
  
  /// Navigation-Herkunft für Back-Button-Logik
  final MixNavigationOrigin? navigationOrigin;

  const QuickSetsDetailScreen({
    super.key,
    this.initialIndex = 0,
    this.navigationOrigin,
  });

  @override
  ConsumerState<QuickSetsDetailScreen> createState() => _QuickSetsDetailScreenState();
}

class _QuickSetsDetailScreenState extends ConsumerState<QuickSetsDetailScreen> {
  static const _labels = <String>[
    'All words',
    'My words',
    'Favorites',
    'Words I know',
    'My mix',
  ];

  int _selected = 0;
  int? _initialQuickSetsIndex; // Track initial index für Back-Button-Logik

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex.clamp(0, _labels.length - 1);
    _initialQuickSetsIndex = widget.initialIndex;
  }

  // Mapping der Tabs auf WordList-Filter.
  // Hinweis:
  // - “All words” => query (kein Filter)
  // - “My words” / “Favorites” / “Words I know” / “My mix”
  //   gehen derzeit über “about”-Slug. Wenn dein Repo andere Keys nutzt,
  //   passe die Slugs unten zentral an.
  WordListFilter _toFilter(int i) {
    switch (i) {
      case 0:
        return const WordListFilter(WordFilterKind.query, '');
      case 1:
        return const WordListFilter(WordFilterKind.about, 'my-words');
      case 2:
        return const WordListFilter(WordFilterKind.about, 'favorites');
      case 3:
        return const WordListFilter(WordFilterKind.about, 'known-words');
      case 4:
        return const WordListFilter(WordFilterKind.about, 'my-mix');
      default:
        return const WordListFilter(WordFilterKind.query, '');
    }
  }

  // Title oberhalb (links) – passend zur bestehenden Optik
  String get _title => _labels[_selected];

  Future<void> _openWordList() async {
    final filter = _toFilter(_selected);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordListScreen(
          filter: filter,
          titleOverride: _title,
          // Hinweis:
          // overrideCategoryId/Label bleiben leer; wir kommen ja nicht aus einer echten DB-Kategorie.
        ),
      ),
    );
  }

  Future<void> _startLearnMode() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearnModeScreen(
          categoryId: 'quicksets',               // stabile, virtuelle ID
          title: _title,
          customWheelLabels: _labels,            // <— NEU
          customWheelInitialIndex: _selected,    // <— NEU
          navigationOrigin: LearnNavigationOrigin.category(
            categoryId: 'quicksets',
            categoryTitle: _title,
            initialIndex: _selected,              // <— Speichere aktuellen Tab-Index
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(levelSelectionProvider);
    final selecting = ref.watch(selectingSingleProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));
    final srs = ref.watch(srsModeControllerProvider);
    
    // ⬇️ NEU: Stats aus Provider laden (für aktuell gewählte Pill)
    final stats = ref.watch(quickSetsStatsProvider(_selected));
    
    const stages = [0, 0, 0, 0, 0, 0]; // TODO: später aus echten Daten

    const kAccentBlue = Color(0xFFB1CCFE);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // FIX: fester Header – kein Flexible
                SizedBox(
                  height: WordsLayout.topCapsuleH,
                  child: CategoryHeaderCapsule(
                    height: WordsLayout.topCapsuleH,
                    title: _title,
                    vocabsCount: 0, // Optional: kann später echt gezählt werden
                    categories: _labels,
                    selectedIndex: _selected,
                    onWheelChanged: (idx, _) => setState(() => _selected = idx),
                    onBack: () {
                      // Wenn Wheel geändert wurde, zurück zur aktuellen Kategorie im Wheel
                      // Sonst zurück zum vorherigen Screen (Mix Builder oder Category Popup)
                      if (widget.navigationOrigin != null) {
                        // Prüfe ob Wheel geändert wurde
                        if (_selected != _initialQuickSetsIndex) {
                          // Wheel wurde geändert: Aktualisiere den Origin mit neuem Index
                          final updatedOrigin = MixNavigationOrigin.mixBuilder(
                            quickSetsIndex: _selected,
                          );
                          MixNavigationController.handleBackNavigation(
                            context,
                            updatedOrigin,
                            _selected,
                          );
                        } else {
                          // Wheel nicht geändert: normale Back-Navigation
                          MixNavigationController.handleBackNavigation(
                            context,
                            widget.navigationOrigin,
                            _selected,
                          );
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    onVocabs: _openWordList,
                    onAdd: () {},
                    onSettings: () {},
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

                // FIX: Mittel + Levels scrollbar machen, damit nix überläuft
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: WordsLayout.pageBottomPadding),
                    child: Column(
                      children: [
                        // ⬇️ NEU: Stats aus Provider verwenden
                        stats.when(
                          data: (s) {
                            final overallPercent = s.total == 0 ? 0.0 : s.learned / s.total;
                            final overallLabel = '${s.learned}/${s.total}';

                            // Daily-Progress
                            final dailyTotal = s.dueToday; // fällige Wiederholungen heute
                            final dailyTarget = s.newTotal + s.dueToday; // grobe Zielanzeige
                            final dailyPercent = dailyTarget == 0 ? 0.0 : dailyTotal / dailyTarget;

                            return LearningStatusPanel(
                              percent: dailyPercent,
                              percentLabel: '${(dailyPercent * 100).round()}%',
                              newCount: s.newTotal,
                              repeatsCount: s.dueToday,
                              repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
                              overallPercent: overallPercent,
                              overallLabel: overallLabel,
                            );
                          },
                          loading: () => const LearningStatusPanel(
                            percent: 0,
                            percentLabel: '0%',
                            newCount: 0,
                            repeatsCount: 0,
                            repeatsOfTargetLabel: '0/0',
                            overallPercent: 0,
                            overallLabel: '0/0',
                          ),
                          error: (_, __) => const LearningStatusPanel(
                            percent: 0,
                            percentLabel: '0%',
                            newCount: 0,
                            repeatsCount: 0,
                            repeatsOfTargetLabel: '0/0',
                            overallPercent: 0,
                            overallLabel: '0/0',
                          ),
                        ),

                        const SizedBox(height: WordsLayout.gapAboveBottom),
                        Transform.translate(
                          offset: const Offset(0, -24), // 🔼 nach oben
                          child: SizedBox(
                            height: WordsLayout.levelsCardH,
                            child: LevelsCard(
                              height: WordsLayout.levelsCardH,
                              stages: stages,
                              goalPerStage: 100,
                              mode: mode,
                              selectingSingle: selecting,
                              visibleMask: mask,
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
                                await _startLearnMode();
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

            // SRS Countdown Overlay (wie in category_detail_screen)
            if (srs.counting)
              Positioned.fill(
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
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${srs.count}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
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
