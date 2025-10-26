import 'package:flutter/material.dart';
import 'package:talvori/features/home/ui/widgets/top_bar.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/vocab_sort_screen.dart';
import 'package:talvori/features/words/ui/screens/my_words_screen.dart';
import 'package:talvori/features/push/data/daily_picks_store.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

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

  // Picker für „Practice“ (Course / Vocab)
  void _showPracticePicker(BuildContext context) {
    const double btnWidth = 140;
    const double btnHeight = 52;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        const navBottomPadding = 12.0;
        const overlapAdjust = 6.0;
        final bottom = bottomInset + navBottomPadding + overlapAdjust;

        final ButtonStyle pillTonal = FilledButton.styleFrom(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          shape: const StadiumBorder(),
          padding: EdgeInsets.zero,
          minimumSize: const Size(btnWidth, btnHeight),
          fixedSize: const Size(btnWidth, btnHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );

        const TextStyle labelStyle =
            TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.2);

        return Stack(
          children: [
            // Tap außerhalb schließt
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            // Buttons unten
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // COURSE (oben)
                  SizedBox(
                    width: btnWidth,
                    height: btnHeight,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CourseScreen()),
                        );
                      },
                      style: pillTonal,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('course', style: labelStyle),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // VOCAB (unten)
                  SizedBox(
                    width: btnWidth,
                    height: btnHeight,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VocabScreen()),
                        );
                      },
                      style: pillTonal,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 22),
                          SizedBox(width: 8),
                          Text('vocab', style: labelStyle),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryPopup(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const gold = Color(0xFFF1C86B);

    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final ButtonStyle pill = FilledButton.styleFrom(
          backgroundColor: cs.surfaceContainerHighest,
          foregroundColor: cs.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: EdgeInsets.zero,
          fixedSize: const Size(110, 48),
          minimumSize: const Size(110, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );

        final Widget content = Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: gold, width: 1.6),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'All words');
                      },
                      style: pill,
                      child: const Text('All words'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final nav = Navigator.of(context);
                        Future.microtask(() async {
                          await nav.push(
                            MaterialPageRoute(builder: (_) => const MyWordsScreen()),
                          );
                          if (!context.mounted) return;
                        });
                      },
                      style: pill,
                      child: const Text('My words'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Favorites');
                      },
                      style: pill,
                      child: const Text('Favorites'),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Daily picks');
                      },
                      style: pill,
                      child: const Text('Daily picks'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Word hub (tap -> WordHubScreen)
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WordHubScreen()),
                      );
                    },
                    child: Container(
                      width: 232,
                      height: 103,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Word hub',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.9)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // CTA
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    height: 40,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _todo(context, 'Make your own mix');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('Make your own mix'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return Stack(
          children: [
            // Tap außerhalb schließt
            PositionedFill(
              onTapOutside: () => Navigator.pop(ctx),
            ),
            Builder(
              builder: (context) {
                const double navBtn = 52;
                const double navPad = 12;
                const double leftPad = 16;
                const double gap = 10;
                const double offsetX = 8;
                const double offsetY = 32;

                final bottomInset = MediaQuery.of(context).padding.bottom;
                final double baseBottom = bottomInset + navPad + navBtn + gap;

                final double posLeft = leftPad + offsetX;
                final double posBottom = baseBottom + offsetY;

                final screen = MediaQuery.of(context).size;
                final safeLeft = posLeft.clamp(0.0, screen.width - 280);
                final safeBottom = posBottom.clamp(8.0, screen.height - 415 - 8);

                return Positioned(
                  left: safeLeft,
                  bottom: safeBottom,
                  child: SizedBox(
                    width: 280,
                    height: 415,
                    child: content,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
              _showCategoryPopup(context).whenComplete(() {
                if (!mounted) return;
                ref.read(homeControllerProvider.notifier).setCategoriesActive(false);
              });
            },
            onPractice: () => _showPracticePicker(context),
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
