import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/words/ui/screens/vocab_sort_screen.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:talvori/features/words/application/learn_navigation_origin.dart';

import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';
import 'package:talvori/features/home/ui/theme/theme.dart';
import 'package:talvori/features/home/ui/strings/strings.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<HomeState>? _homeSub;

  @override
  void initState() {
    super.initState();
    
    // Controller-Listener ohne ref in dispose
    _homeSub = ref.listenManual<HomeState>(
      homeControllerProvider,
      (prev, next) {
        // Optional: auf State-Änderungen reagieren
      },
    );
    
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$what${HomeStrings.todo}')));
  }



  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    
    return Scaffold(
      backgroundColor: HomeTheme.background,
      body: SafeArea(
        child: Padding(
          padding: HomeTheme.horizontal,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: DailyPicksStore.I,
                builder: (context, _) {
                  final count = DailyPicksStore.I.items.length;
                  final max = DailyPicksStore.I.maxCount;

                  return HomeTopBar(
                    onAllWords: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VocabSortScreen()),
                    ),
                    onRewards: () => _todo('Rewards/Leaderboard/Stats'),
                    onProgressTap: () => _todo('Daily picks settings'),
                    selected: count,
                    max: max,
                    showProgress: count < max,
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
                          key: ValueKey((state.imageIsDark, state.imageExpanded)),
                          initialWord: null, // WordCard verwendet lastSharedWordProvider
                          onQuickSend: () async {
                            // Aktuelles Wort aus dem Provider holen
                            final currentWord = await ref.read(lastSharedWordProvider.future) ?? 'to assume';
                            final res = DailyPicksStore.I.add(currentWord);
                            
                            // Context nach await prüfen
                            if (!context.mounted) return;
                            
                            switch (res) {
                              case AddResult.ok:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.added)),
                                );
                                break;
                              case AddResult.duplicate:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.duplicate)),
                                );
                                break;
                              case AddResult.full:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${HomeStrings.full} (${DailyPicksStore.I.maxCount})')),
                                );
                                break;
                              case AddResult.invalid:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(HomeStrings.invalid)),
                                );
                                break;
                            }
                          },
                          isImageExpanded: state.imageExpanded,
                          onToggleImage: () => ref.read(homeControllerProvider.notifier).toggleImage(),
                          isImageDark: state.imageIsDark,
                          onImageBrightnessChanged: (isDark) => ref.read(homeControllerProvider.notifier).setImageDark(isDark),
                          contentPadding: HomeTheme.contentPadding,

                          userWordCount: state.myWordsCount,
                          onCountTap: () async {
                            
                            final nav = Navigator.of(context); // vor await
                            await nav.push(
                              MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                            );
                            if (!context.mounted) return;
                          },
                          onSpeak: () => _todo('Speak word'),
                          onMarkWords: () => _todo('Open Mark Words (web)'),
                          onGo: () async {
                            // ⬇️ NEU: Direkt in LearnMode "My words" starten (Index 1)
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
                                  customWheelInitialIndex: 1, // My words
                                  navigationOrigin: const LearnNavigationOrigin.home(),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: HomeTheme.bottomPadding,
          child: HomeBottomNav(
            onCategories: () async {
              ref.read(homeControllerProvider.notifier).setCategoriesActive(true);
              await showCategoryPopup(
                context: context,
                onRefreshMyWords: () async {
                  // Refresh My Words count after returning from My Words screen
                  await ref.read(homeControllerProvider.notifier).refreshMyWordsCount();
                },
                onTodo: (s) => _todo(s),
              );
                if (!mounted) return;
              ref.read(homeControllerProvider.notifier).setCategoriesActive(false);
            },
            onPractice: () => showPracticePicker(context),
            onProfile: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            categoriesActive: state.categoriesActive,
          ),
        ),
      ),
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
