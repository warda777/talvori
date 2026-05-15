import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/application/learn_navigation_origin.dart';

import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';
import 'package:talvori/features/home/ui/theme/theme.dart';
import 'package:talvori/features/home/ui/strings/strings.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';
import 'package:talvori/features/common/widgets/fireball_bounce_animation.dart';
import 'package:talvori/features/local_learning_debug/ui/local_debug_hub_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<HomeState>? _homeSub;
  bool _progressAnimationRunning =
      false; // Verfolgt ob Progressbar-Animation noch läuft

  @override
  void initState() {
    super.initState();

    // Controller-Listener ohne ref in dispose
    _homeSub = ref.listenManual<HomeState>(homeControllerProvider, (
      prev,
      next,
    ) {
      // Optional: auf State-Änderungen reagieren
    });

    // Controller initialisieren (kümmert sich um Lifecycle & Share-Listener)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).init(context);
    });
  }

  @override
  void dispose() {
    // ✅ Subscription ohne ref schließen
    _homeSub?.close();
    _homeSub = null;
    super.dispose();
  }

  void _todo(String what) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what${HomeStrings.todo}')));
  }

  // GlobalKey für Progress Pill (für Flug-Animation)
  final GlobalKey _progressPillKey = GlobalKey();
  final GlobalKey _counterKey =
      GlobalKey(); // <-- NEU: Für Counter in Progress Pill
  final GlobalKey _crownButtonKey = GlobalKey(); // Für Fireball Start-Position
  final GlobalKey<FireballBounceAnimationState> _fireballKey =
      GlobalKey<FireballBounceAnimationState>();
  final GlobalKey _rightButtonKey = GlobalKey(); // Für den rechten Button
  final GlobalKey _practiceButtonKey =
      GlobalKey(); // <-- NEU: Für Practice-Button

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: HomeTheme.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand, // wichtig: voller Bereich für die Animation
          children: [
            // 🔥 Fireball HINTER dem Button
            FireballBounceAnimation(
              key: _fireballKey,
              anchorKey: _crownButtonKey,
              practiceKey: _practiceButtonKey, // <-- NEU: Practice-Button Key
              forceColor: const Color(0xFFA05260), // deine Farbe
              iconSize: 48,
              anchorOffset: const Offset(
                0,
                0,
              ), // Feintuning: falls 1-2px links, dann Offset(2, 0)
              child: SvgPicture.asset(
                'assets/icons/fireball_black.svg',
                width: 48,
                height: 48,
              ),
            ),
            Padding(
              padding: HomeTheme.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: DailyPicksStore.I,
                    builder: (context, _) {
                      final count = DailyPicksStore.I.items.length;
                      final max = DailyPicksStore.I.maxCount;

                      // Wenn count >= max, aber Animation noch läuft, zeige Pill weiterhin
                      final shouldShowProgress =
                          count < max || _progressAnimationRunning;

                      return HomeTopBar(
                        buttonKey: _rightButtonKey,
                        progressPillKey: _progressPillKey,
                        counterKey: _counterKey, // <-- NEU: Counter Key
                        crownButtonKey: _crownButtonKey,
                        fireballKey: _fireballKey,
                        onAllWords: () {
                          // Navigation wird jetzt von OpenContainer in top_bar.dart gehandhabt
                        },
                        onRewards: () => _todo('Rewards/Leaderboard/Stats'),
                        onProgressTap: () => _todo('Daily picks settings'),
                        selected: count,
                        max: max,
                        showProgress: shouldShowProgress,
                        onProgressAnimationStart: () {
                          // Animation gestartet - verzögere setState
                          if (mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _progressAnimationRunning = true;
                                });
                              }
                            });
                          }
                        },
                        onProgressAnimationComplete: () {
                          // Animation fertig - jetzt kann die Pill ausgeblendet werden
                          // Verzögere setState, damit es nicht während des Builds aufgerufen wird
                          if (mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _progressAnimationRunning = false;
                                });
                              }
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: LayoutBuilder(
                        builder: (ctx, box) {
                          final w = box.maxWidth;
                          final h = w * (570 / 360);

                          return SizedBox(
                            width: w,
                            height: h,
                            child: wc.WordCard(
                              key: ValueKey((
                                state.imageIsDark,
                                state.imageExpanded,
                              )),
                              progressPillKey: _progressPillKey,
                              counterKey: _counterKey, // <-- NEU: Counter Key
                              initialWord:
                                  null, // lastSharedWordProvider regelt das
                              onQuickSend: (String wordText) {
                                // Füge nur das aktuell ausgewählte Wort hinzu
                                final res = DailyPicksStore.I.add(wordText);

                                if (!context.mounted) return res;

                                switch (res) {
                                  case AddResult.ok:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Wort hinzugefügt'),
                                      ),
                                    );
                                    break;
                                  case AddResult.duplicate:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Bereits in Today\'s Picks',
                                        ),
                                      ),
                                    );
                                    break;
                                  case AddResult.full:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Today\'s Picks ist voll (${DailyPicksStore.I.maxCount})',
                                        ),
                                      ),
                                    );
                                    break;
                                  case AddResult.invalid:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ungültiges Wort'),
                                      ),
                                    );
                                    break;
                                }

                                return res; // Gib das Ergebnis zurück
                              },
                              isImageExpanded: state.imageExpanded,
                              onToggleImage: () => ref
                                  .read(homeControllerProvider.notifier)
                                  .toggleImage(),
                              isImageDark: state.imageIsDark,
                              onImageBrightnessChanged: (isDark) => ref
                                  .read(homeControllerProvider.notifier)
                                  .setImageDark(isDark),
                              contentPadding: HomeTheme.contentPadding,
                              userWordCount: state.myWordsCount,
                              onCountTap: () async {
                                final nav = Navigator.of(context);
                                await nav.push(
                                  MaterialPageRoute(
                                    builder: (_) => const MyWordsScreen(),
                                  ),
                                );
                                if (!context.mounted) return;
                              },
                              onSpeak: () => _todo('Speak word'),
                              onMarkWords: () => _todo('Open Mark Words (web)'),
                              onGo: () async {
                                const quickSetsLabels = [
                                  'All words',
                                  'My words',
                                  'Favorites',
                                  'Words I know',
                                  'My mix',
                                ];
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LearnModeScreen(
                                      categoryId: 'quicksets',
                                      title: 'My words',
                                      customWheelLabels: quickSetsLabels,
                                      customWheelInitialIndex: 1,
                                      navigationOrigin:
                                          const LearnNavigationOrigin.home(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: HomeTheme.bottomPadding,
          child: HomeBottomNav(
            onCategories: () async {
              ref
                  .read(homeControllerProvider.notifier)
                  .setCategoriesActive(true);
              await showCategoryPopup(
                context: context,
                onRefreshMyWords: () async {
                  // Refresh My Words count after returning from My Words screen
                  await ref
                      .read(homeControllerProvider.notifier)
                      .refreshMyWordsCount();
                },
                onTodo: (s) => _todo(s),
              );
              if (!mounted) return;
              ref
                  .read(homeControllerProvider.notifier)
                  .setCategoriesActive(false);
            },
            onPractice: () => showPracticePicker(context),
            onProfile: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            categoriesActive: state.categoriesActive,
            practiceButtonKey:
                _practiceButtonKey, // <-- NEU: Practice-Button Key
          ),
        ),
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              tooltip: 'Local Learning Debug',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LocalDebugHubScreen(),
                ),
              ),
              child: const Icon(Icons.bug_report_outlined),
            )
          : null,
    );
  }
}

/// Kleiner Helfer um „Tap außerhalb“ ohne Boilerplate zu ermöglichen.
class PositionedFill extends StatelessWidget {
  final VoidCallback onTapOutside;
  const PositionedFill({super.key, required this.onTapOutside});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapOutside,
      ),
    );
  }
}
