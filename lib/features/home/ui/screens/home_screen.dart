import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/widgets/top_bar.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/vocab_sort_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/last_shared_word_provider.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('AUTH USER: ${user?.id}');

    // Initialize controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).init(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Zurück aus Chrome/Share → Wort neu laden
      ref.invalidate(lastSharedWordProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(homeControllerProvider.notifier).dispose();
    super.dispose();
  }

  void _todo(BuildContext ctx, String what) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$what – TODO')));
  }



  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    onRewards: () => _todo(context, 'Rewards/Leaderboard/Stats'),
                    onProgressTap: () => _todo(context, 'Daily picks settings'),
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
                                  const SnackBar(content: Text("Added to today's picks")),
                                );
                                break;
                              case AddResult.duplicate:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Already in today\'s picks')),
                                );
                                break;
                              case AddResult.full:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Limit reached (${DailyPicksStore.I.maxCount})')),
                                );
                                break;
                              case AddResult.invalid:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot add empty word')),
                                );
                                break;
                            }
                          },
                          isImageExpanded: state.imageExpanded,
                          onToggleImage: () => ref.read(homeControllerProvider.notifier).toggleImage(),
                          isImageDark: state.imageIsDark,
                          onImageBrightnessChanged: (isDark) => ref.read(homeControllerProvider.notifier).setImageDark(isDark),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 16),

                          userWordCount: state.myWordsCount,
                          onCountTap: () async {
                            
                            final nav = Navigator.of(context); // vor await
                            await nav.push(
                              MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                            );
                            if (!context.mounted) return;
                          },
                          onSpeak: () => _todo(context, 'Speak word'),
                          onMarkWords: () => _todo(context, 'Open Mark Words (web)'),
                          onGo: () => _todo(context, 'Start: My Words practice'),
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: HomeBottomNav(
            onCategories: () {
              ref.read(homeControllerProvider.notifier).setCategoriesActive(true);
              showCategoryPopup(
                context: context,
                onRefreshMyWords: () async {
                  // Refresh My Words count after returning from My Words screen
                  await ref.read(homeControllerProvider.notifier).refreshMyWordsCount();
                },
                onTodo: (what) => _todo(context, what),
              ).whenComplete(() {
                if (!mounted) return;
                ref.read(homeControllerProvider.notifier).setCategoriesActive(false);
              });
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
