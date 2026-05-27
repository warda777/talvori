import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/features/companion/application/companion_controller.dart';
import 'package:talvori/features/companion/application/companion_discovery_tip_resolver.dart';
import 'package:talvori/features/companion/domain/companion_discovery_context.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';
import 'package:talvori/features/home/ui/theme/theme.dart';
import 'package:talvori/features/home/ui/strings/strings.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_controller.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';
import 'package:talvori/features/common/widgets/fireball_bounce_animation.dart';
import 'package:talvori/features/local_learning_debug/ui/local_debug_hub_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _companionRestDelay = Duration(seconds: 6);

  ProviderSubscription<HomeState>? _homeSub;
  Timer? _companionRestTimer;
  bool _didShowInitialCompanionDiscoveryTip = false;
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
      unawaited(_showInitialCompanionDiscoveryTip());
      _restartCompanionRestTimer();
    });
  }

  @override
  void dispose() {
    _companionRestTimer?.cancel();
    _companionRestTimer = null;
    // ✅ Subscription ohne ref schließen
    _homeSub?.close();
    _homeSub = null;
    super.dispose();
  }

  void _restartCompanionRestTimer() {
    _companionRestTimer?.cancel();
    _companionRestTimer = Timer(_companionRestDelay, () {
      if (!mounted) return;
      ref.read(companionControllerProvider.notifier).compact();
    });
  }

  void _cancelCompanionRestTimer() {
    _companionRestTimer?.cancel();
    _companionRestTimer = null;
  }

  void _toggleCompanion() {
    final wasExpanded = ref.read(companionControllerProvider).isExpanded;
    ref.read(companionControllerProvider.notifier).toggleExpanded();
    if (wasExpanded) {
      _cancelCompanionRestTimer();
    } else {
      _restartCompanionRestTimer();
    }
  }

  Future<void> _showInitialCompanionDiscoveryTip() async {
    if (_didShowInitialCompanionDiscoveryTip) return;
    _didShowInitialCompanionDiscoveryTip = true;
    try {
      final myWordsCount = await ref.read(
        localWordCountProvider(localMyWordsCategoryId).future,
      );
      if (!mounted) return;
      final discoveryContext = CompanionDiscoveryContext(
        myWordsCount: myWordsCount,
        favoritesCount: 0,
        hasUsedBrowserShare: myWordsCount > 0,
        hasUsedWordGames: false,
        hasCreatedDailyImpulse: false,
        hasOpenedLearningLevels: false,
        hasOpenedLanguageTools: false,
        hasOpenedWordWorlds: false,
      );
      final tip = const CompanionDiscoveryTipResolver().resolve(
        discoveryContext,
      );
      if (tip == null) return;
      ref.read(companionControllerProvider.notifier).showDiscoveryTip(tip);
      _restartCompanionRestTimer();
    } catch (error, stackTrace) {
      debugPrint('Companion discovery tip skipped: $error');
      debugPrint('$stackTrace');
    }
  }

  void _todo(String what) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what${HomeStrings.todo}')));
  }

  Future<void> _showLearningSourcesPopup() async {
    ref.read(homeControllerProvider.notifier).setCategoriesActive(true);
    await showCategoryPopup(
      context: context,
      onRefreshMyWords: () async {
        await ref.read(homeControllerProvider.notifier).refreshMyWordsCount();
      },
      onTodo: (s) => _todo(s),
    );
    if (!mounted) return;
    ref.read(homeControllerProvider.notifier).setCategoriesActive(false);
  }

  void _openImpulseInbox() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ImpulsPostfachScreen()));
  }

  Future<void> _speakHomeWord(WordUserView? word) async {
    final text = word?.text.trim() ?? '';
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Noch kein Wort ausgewählt.')),
      );
      return;
    }

    HapticFeedback.selectionClick();
    final result = await ref
        .read(wordPronunciationServiceProvider)
        .speakWord(text, languageCode: 'en');
    if (!mounted || result.isSuccess) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Aussprache nicht verfügbar.')),
    );
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
    final tagesimpulsSelection = ref.watch(
      tagesimpulsSelectionControllerProvider,
    );
    final impulseInboxState = ref.watch(impulseInboxControllerProvider);
    final impulseUnreadCount = impulseInboxState.chats.fold<int>(
      0,
      (sum, chat) => sum + chat.unreadCount,
    );
    final companionState = ref.watch(companionControllerProvider);

    return Scaffold(
      backgroundColor: HomeTheme.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand, // wichtig: voller Bereich für die Animation
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF07101A),
                      Color(0xFF02050A),
                      Color(0xFF000000),
                    ],
                  ),
                ),
              ),
            ),
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
            LayoutBuilder(
              builder: (context, viewport) {
                final showCompanion = viewport.maxHeight >= 640;
                final disableHomeScroll = viewport.maxHeight >= 640;
                final companionMascotSize = viewport.maxWidth < 380
                    ? 150.0
                    : 164.0;
                final companionWidth = (viewport.maxWidth - 28)
                    .clamp(280.0, 340.0)
                    .toDouble();
                final companionTop = (viewport.maxHeight * 0.49)
                    .clamp(
                      250.0,
                      viewport.maxHeight - companionMascotSize - 110,
                    )
                    .toDouble();
                final companionLeft = (viewport.maxWidth * 0.08)
                    .clamp(24.0, 40.0)
                    .toDouble();

                return Stack(
                  children: [
                    Padding(
                      padding: HomeTheme.horizontal,
                      child: SingleChildScrollView(
                        physics: disableHomeScroll
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeTopBar(
                              buttonKey: _rightButtonKey,
                              progressPillKey: _progressPillKey,
                              counterKey: _counterKey, // <-- NEU: Counter Key
                              crownButtonKey: _crownButtonKey,
                              fireballKey: _fireballKey,
                              onAllWords: () {
                                // Navigation wird jetzt von OpenContainer in top_bar.dart gehandhabt
                              },
                              onRewards: () =>
                                  _todo('Rewards/Leaderboard/Stats'),
                              onProgressTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CourseScreen(),
                                  ),
                                );
                              },
                              selected: tagesimpulsSelection.count,
                              max: tagesimpulsSelection.maxCount,
                              showProgress:
                                  tagesimpulsSelection.count <
                                      tagesimpulsSelection.maxCount ||
                                  _progressAnimationRunning,
                              onProgressAnimationStart: () {
                                // Animation gestartet - verzögere setState
                                if (mounted) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
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
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      setState(() {
                                        _progressAnimationRunning = false;
                                      });
                                    }
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 360,
                                ),
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
                                        counterKey:
                                            _counterKey, // <-- NEU: Counter Key
                                        initialWord:
                                            null, // lastSharedWordProvider regelt das
                                        onQuickSend: (word) async {
                                          // Füge nur das aktuell ausgewählte Wort hinzu
                                          final res = await ref
                                              .read(
                                                tagesimpulsSelectionControllerProvider
                                                    .notifier,
                                              )
                                              .add(
                                                TagesimpulsSelectionItem(
                                                  wordId: word.id,
                                                  text: word.text,
                                                  translation: word.translation,
                                                  addedAt: DateTime.now(),
                                                ),
                                              );

                                          if (!context.mounted) return res;

                                          switch (res) {
                                            case TagesimpulsSelectionAddResult
                                                .ok:
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Wort wurde zum Tagesimpuls hinzugefügt.',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case TagesimpulsSelectionAddResult
                                                .duplicate:
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Wort ist bereits im Tagesimpuls.',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case TagesimpulsSelectionAddResult
                                                .full:
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Tagesimpuls ist voll.',
                                                  ),
                                                ),
                                              );
                                              break;
                                            case TagesimpulsSelectionAddResult
                                                .invalid:
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Ungültiges Wort',
                                                  ),
                                                ),
                                              );
                                              break;
                                          }

                                          return res; // Gib das Ergebnis zurück
                                        },
                                        onImpulseInboxTap: null,
                                        impulseInboxUnreadCount:
                                            impulseUnreadCount,
                                        isImageExpanded: state.imageExpanded,
                                        onToggleImage: () => ref
                                            .read(
                                              homeControllerProvider.notifier,
                                            )
                                            .toggleImage(),
                                        isImageDark: state.imageIsDark,
                                        onImageBrightnessChanged: (isDark) =>
                                            ref
                                                .read(
                                                  homeControllerProvider
                                                      .notifier,
                                                )
                                                .setImageDark(isDark),
                                        contentPadding:
                                            HomeTheme.contentPadding,
                                        userWordCount: state.myWordsCount,
                                        onCountTap: () async {
                                          final nav = Navigator.of(context);
                                          await nav.push(
                                            MaterialPageRoute(
                                              settings: const RouteSettings(
                                                name: 'local-vocabs-my_words',
                                              ),
                                              builder: (_) =>
                                                  const LocalWordListScreen(
                                                    categoryId:
                                                        localMyWordsCategoryId,
                                                    title:
                                                        localMyWordsCategoryLabel,
                                                  ),
                                            ),
                                          );
                                          if (!context.mounted) return;
                                        },
                                        onSpeak: _speakHomeWord,
                                        onMarkWords: () =>
                                            _todo('Wörter markieren'),
                                        onGo: _showLearningSourcesPopup,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 96),
                          ],
                        ),
                      ),
                    ),
                    if (showCompanion)
                      Positioned(
                        top: companionTop,
                        left: companionLeft,
                        child: SizedBox(
                          width: companionWidth,
                          child: TalvoriCompanionCard(
                            mascotMood: companionState.mascotMood,
                            title: companionState.title,
                            message: companionState.message,
                            bubbleVisible: companionState.bubbleVisible,
                            isExpanded: companionState.isExpanded,
                            mascotSize: companionMascotSize,
                            onMascotTap: _toggleCompanion,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: HomeTheme.bottomPadding,
          child: HomeBottomNav(
            onImpulseInbox: _openImpulseInbox,
            onPractice: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const VocabScreen())),
            onProfile: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            impulseUnreadCount: impulseUnreadCount,
            practiceButtonKey:
                _practiceButtonKey, // <-- NEU: Practice-Button Key
          ),
        ),
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              tooltip: 'Local Learning Debug',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocalDebugHubScreen()),
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
