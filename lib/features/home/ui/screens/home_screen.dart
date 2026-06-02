import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/core/ui/talvori_snackbar.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/features/companion/application/companion_ai_service.dart';
import 'package:talvori/features/companion/application/companion_controller.dart';
import 'package:talvori/features/companion/application/companion_discovery_tip_resolver.dart';
import 'package:talvori/features/companion/domain/companion_ai_context.dart';
import 'package:talvori/features/companion/domain/companion_discovery_context.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';
import 'package:talvori/features/companion/domain/companion_state.dart';
import 'package:talvori/features/home/application/profile_preferences_controller.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/words/ui/screens/local_known_review_screen.dart';

import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/home/application/application.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/widgets/widgets.dart';
import 'package:talvori/features/home/ui/theme/theme.dart';
import 'package:talvori/features/home/ui/strings/strings.dart';
import 'package:talvori/features/world/ui/screens/world_region_screen.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_provider.dart';

const _homeSystemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: HomeTheme.background,
  systemNavigationBarIconBrightness: Brightness.light,
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _companionRestDelay = Duration(seconds: 6);

  ProviderSubscription<HomeState>? _homeSub;
  Timer? _companionRestTimer;
  final TextEditingController _companionInputController =
      TextEditingController();
  final FocusNode _companionInputFocusNode = FocusNode();
  int _companionInputLineCount = 1;
  bool _didShowInitialCompanionDiscoveryTip = false;
  bool _wasKeyboardVisibleForCompanionChat = false;
  int _companionChatRequestId = 0;
  bool _progressAnimationRunning =
      false; // Verfolgt ob Progressbar-Animation noch läuft

  @override
  void initState() {
    super.initState();
    _companionInputController.addListener(_syncCompanionInputLineCount);

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
    _companionInputController.removeListener(_syncCompanionInputLineCount);
    _companionInputController.dispose();
    _companionInputFocusNode.dispose();
    super.dispose();
  }

  void _syncCompanionInputLineCount() {
    final text = _companionInputController.text;
    final nextLineCount = text.isEmpty
        ? 1
        : text.split('\n').length.clamp(1, 5).toInt();
    if (nextLineCount == _companionInputLineCount) return;
    setState(() => _companionInputLineCount = nextLineCount);
  }

  void _restartCompanionRestTimer() {
    _companionRestTimer?.cancel();
    _companionRestTimer = Timer(_companionRestDelay, () {
      if (!mounted) return;
      final companionState = ref.read(companionControllerProvider);
      if (companionState.inputVisible || companionState.isThinking) return;
      ref.read(companionControllerProvider.notifier).compact();
    });
  }

  void _cancelCompanionRestTimer() {
    _companionRestTimer?.cancel();
    _companionRestTimer = null;
  }

  void _toggleCompanion() {
    final current = ref.read(companionControllerProvider);
    if (current.inputVisible) {
      _closeCompanionChatInput();
      return;
    }
    final wasExpanded = current.isExpanded;
    if (current.isThinking) {
      _companionChatRequestId++;
    }
    ref.read(companionControllerProvider.notifier).toggleExpanded();
    if (wasExpanded) {
      _cancelCompanionRestTimer();
    } else {
      _restartCompanionRestTimer();
    }
  }

  void _openCompanionChatInput() {
    unawaited(
      ref
          .read(profilePreferencesControllerProvider.notifier)
          .markHomeChatHintSeen(),
    );
    ref.read(companionControllerProvider.notifier).openChatInput();
    _cancelCompanionRestTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _companionInputFocusNode.requestFocus();
    });
  }

  void _closeCompanionChatInput() {
    _companionInputFocusNode.unfocus();
    _companionInputController.clear();
    _companionInputLineCount = 1;
    _wasKeyboardVisibleForCompanionChat = false;
    ref.read(companionControllerProvider.notifier).compact();
    _cancelCompanionRestTimer();
  }

  void _dismissCompanionKeyboard() {
    if (!_companionInputFocusNode.hasFocus) return;
    _companionInputFocusNode.unfocus();
  }

  void _syncCompanionKeyboardVisibility({
    required bool inputVisible,
    required double keyboardInset,
  }) {
    if (!inputVisible) {
      _wasKeyboardVisibleForCompanionChat = false;
      return;
    }

    if (keyboardInset > 0) {
      _wasKeyboardVisibleForCompanionChat = true;
      return;
    }

    if (!_wasKeyboardVisibleForCompanionChat) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(companionControllerProvider).inputVisible) return;
      if (MediaQuery.viewInsetsOf(context).bottom > 0) return;
      _closeCompanionChatInput();
    });
  }

  Future<void> _submitCompanionMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    _companionInputController.clear();
    _companionInputLineCount = 1;
    final requestId = ++_companionChatRequestId;
    final companionController = ref.read(companionControllerProvider.notifier);
    companionController.submitUserMessage(trimmed);
    _cancelCompanionRestTimer();
    _refocusCompanionInput();

    var shouldPersistAiResponse = false;
    String? persistedCompanionChatId;
    try {
      final inboxController = ref.read(impulseInboxControllerProvider.notifier);
      final mascotStyle = _currentMascotStyle();
      final chat = await inboxController.ensureCompanionChat(
        style: mascotStyle,
      );
      await inboxController.addUserMessage(chat.id, trimmed);
      persistedCompanionChatId = chat.id;
      shouldPersistAiResponse = true;
    } catch (error) {
      debugPrint('Companion chat persistence failed for user message: $error');
    }

    try {
      final myWordsCount = await ref.read(
        localWordCountProvider(localMyWordsCategoryId).future,
      );
      if (!mounted || requestId != _companionChatRequestId) return;
      final stateBeforeReply = ref.read(companionControllerProvider);
      final response = await ref
          .read(companionAiServiceProvider)
          .reply(
            message: trimmed,
            context: CompanionAiContext(
              myWordsCount: myWordsCount,
              lastCompanionMessage: stateBeforeReply.message,
              learningStatus: myWordsCount == 0
                  ? 'Noch keine eigenen Wörter gespeichert.'
                  : '$myWordsCount eigene Wörter lokal verfügbar.',
            ),
          );
      if (!mounted || requestId != _companionChatRequestId) return;
      companionController.showAiResponse(response);
      final responseChatId = persistedCompanionChatId;
      if (shouldPersistAiResponse && responseChatId != null) {
        try {
          await ref
              .read(impulseInboxControllerProvider.notifier)
              .addAiMessage(responseChatId, response);
        } catch (error) {
          debugPrint(
            'Companion chat persistence failed for AI response: $error',
          );
        }
      }
      _refocusCompanionInput();
    } catch (error) {
      if (!mounted || requestId != _companionChatRequestId) return;
      companionController.showError(
        'Das hat gerade nicht geklappt. Versuch es gleich noch einmal.',
      );
      _refocusCompanionInput();
    }
  }

  void _refocusCompanionInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final companionState = ref.read(companionControllerProvider);
      if (!companionState.inputVisible) return;
      _companionInputFocusNode.requestFocus();
    });
  }

  TalvoriMascotStyle _currentMascotStyle() {
    return ref.read(profilePreferencesControllerProvider).mascotStyle;
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
      final companionName = TalvoriMascotAssets.companionDisplayNameFor(
        _currentMascotStyle(),
      );
      ref
          .read(companionControllerProvider.notifier)
          .showDiscoveryTip(
            CompanionDiscoveryTip(
              type: tip.type,
              title: companionName,
              message: tip.message.replaceAll('Talvori', companionName),
              mood: tip.mood,
              priority: tip.priority,
            ),
          );
      _restartCompanionRestTimer();
    } catch (error, stackTrace) {
      debugPrint('Companion discovery tip skipped: $error');
      debugPrint('$stackTrace');
    }
  }

  void _todo(String what) {
    if (!mounted) return;
    TalvoriSnackBar.show(context, message: '$what${HomeStrings.todo}');
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

  void _openWorldRegion() {
    HapticFeedback.selectionClick();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WorldRegionScreen()));
  }

  void _openWorldHub() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LocalKnownReviewScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _openProgressHub() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RewardsCenterScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<void> _openExternalWordImport() {
    return wc.onChromeButtonTap(context, ref);
  }

  void _openSentenceSparks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'sentence-sparks-course'),
        builder: (_) => const CourseScreen(),
      ),
    );
  }

  // GlobalKey für Progress Pill (für Flug-Animation)
  final GlobalKey _progressPillKey = GlobalKey();
  final GlobalKey _counterKey =
      GlobalKey(); // <-- NEU: Für Counter in Progress Pill
  final GlobalKey _rightButtonKey = GlobalKey(); // Für den rechten Button

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
    final showHomeChatHint = ref.watch(
      profilePreferencesControllerProvider.select(
        (preferences) => !preferences.hasSeenHomeChatHint,
      ),
    );
    final mascotStyle = ref.watch(
      profilePreferencesControllerProvider.select(
        (preferences) => preferences.mascotStyle,
      ),
    );
    final companionDisplayName = TalvoriMascotAssets.companionDisplayNameFor(
      mascotStyle,
    );
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final chatOverlayOpen =
        companionState.inputVisible || companionState.isThinking;
    final chatInputBottom = keyboardInset > 0
        ? keyboardInset + 2.0
        : mediaQuery.padding.bottom + 24.0;
    final companionKeyboardMaxBottom =
        companionState.inputVisible && keyboardInset > 0
        ? mediaQuery.size.height -
              chatInputBottom -
              _HomeCompanionChatInput.estimatedHeight -
              mediaQuery.viewPadding.top -
              16.0
        : null;
    final homeLayoutMediaQuery = mediaQuery.copyWith(
      padding: mediaQuery.padding.copyWith(
        bottom: mediaQuery.viewPadding.bottom,
      ),
      viewInsets: mediaQuery.viewInsets.copyWith(bottom: 0),
    );

    _syncCompanionKeyboardVisibility(
      inputVisible: companionState.inputVisible,
      keyboardInset: keyboardInset,
    );

    final homeHubActions = [
      HomeSmartHubAction(
        key: const Key('home-impuls-postfach-button'),
        icon: Icons.forum_rounded,
        label: 'Chat und Freunde',
        badgeCount: impulseUnreadCount,
        onTap: _openImpulseInbox,
      ),
      HomeSmartHubAction(
        key: const Key('home-browser-return-button'),
        icon: Icons.travel_explore_rounded,
        label: 'Wörter sammeln',
        onTap: _openExternalWordImport,
      ),
      HomeSmartHubAction(
        key: const Key('home-my-words-play-button'),
        icon: Icons.menu_book_rounded,
        label: 'Lernen',
        onTap: _showLearningSourcesPopup,
      ),
      HomeSmartHubAction(
        key: const Key('home-sentence-sparks-button'),
        icon: Icons.auto_awesome_rounded,
        label: 'Satzfunken',
        onTap: _openSentenceSparks,
      ),
      HomeSmartHubAction(
        key: const Key('home-practice-button'),
        icon: Icons.sports_esports_rounded,
        label: 'Wortspiele',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const VocabScreen())),
      ),
      HomeSmartHubAction(
        key: const Key('home-profile-button'),
        icon: Icons.person_rounded,
        label: 'Profil',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
      ),
      HomeSmartHubAction(
        key: const Key('home-progress-hub-button'),
        icon: Icons.insights_rounded,
        label: 'Statistik und Fortschritt',
        onTap: _openProgressHub,
      ),
      HomeSmartHubAction(
        key: const Key('home-known-review-button'),
        icon: Icons.public_rounded,
        label: 'Welt Hub',
        onTap: _openWorldHub,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _homeSystemUiOverlayStyle,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Scaffold(
            backgroundColor: HomeTheme.background,
            extendBody: true,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            body: MediaQuery(
              data: homeLayoutMediaQuery,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: _HomeAmbientBackground()),
                  ),
                  SafeArea(
                    child: Stack(
                      fit: StackFit
                          .expand, // wichtig: voller Bereich für die Animation
                      children: [
                        LayoutBuilder(
                          builder: (context, viewport) {
                            final compactHome = viewport.maxHeight < 760;
                            final showCompanion =
                                viewport.maxHeight >= 640 || chatOverlayOpen;
                            final disableHomeScroll = viewport.maxHeight >= 820;

                            return Stack(
                              children: [
                                Padding(
                                  padding: HomeTheme.horizontal,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: disableHomeScroll
                                        ? const NeverScrollableScrollPhysics()
                                        : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Opacity(
                                          opacity: 0.78,
                                          child: HomeTopBar(
                                            buttonKey: _rightButtonKey,
                                            progressPillKey: _progressPillKey,
                                            counterKey: _counterKey,
                                            onAllWords: () {
                                              // Navigation wird jetzt von OpenContainer in top_bar.dart gehandhabt
                                            },
                                            onRewards: () => _todo(
                                              'Rewards/Leaderboard/Stats',
                                            ),
                                            onProgressTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CourseScreen(),
                                                ),
                                              );
                                            },
                                            selected:
                                                tagesimpulsSelection.count,
                                            max: tagesimpulsSelection.maxCount,
                                            showProgress:
                                                tagesimpulsSelection.count <
                                                    tagesimpulsSelection
                                                        .maxCount ||
                                                _progressAnimationRunning,
                                            onProgressAnimationStart: () {
                                              if (mounted) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _progressAnimationRunning =
                                                              true;
                                                        });
                                                      }
                                                    });
                                              }
                                            },
                                            onProgressAnimationComplete: () {
                                              if (mounted) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      if (mounted) {
                                                        setState(() {
                                                          _progressAnimationRunning =
                                                              false;
                                                        });
                                                      }
                                                    });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: _HomeWorldHero(
                                            wordCount: state.myWordsCount,
                                            compact: compactHome,
                                            onGlobeTap: _openWorldRegion,
                                          ),
                                        ),
                                        const SizedBox(height: 102),
                                      ],
                                    ),
                                  ),
                                ),
                                if (showCompanion)
                                  _HomeCompanionOverlay(
                                    viewportHeight: viewport.maxHeight,
                                    compact: compactHome,
                                    companionState: companionState,
                                    keyboardSafeMaxBottom:
                                        companionKeyboardMaxBottom,
                                    companionDisplayName: companionDisplayName,
                                    mascotStyle: mascotStyle,
                                    showHomeChatHint: showHomeChatHint,
                                    onCompanionTap: _toggleCompanion,
                                    onCompanionBubbleTap:
                                        _openCompanionChatInput,
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: HomeSmartHubMenu(actions: homeHubActions),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
          if (companionState.inputVisible)
            Positioned.fill(
              key: const Key('talvori-companion-chat-dismiss-layer'),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeCompanionChatInput,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0.8) {
                    _dismissCompanionKeyboard();
                  }
                },
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 80) {
                    _dismissCompanionKeyboard();
                  }
                },
              ),
            ),
          if (companionState.inputVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: chatInputBottom,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Listener(
                    onPointerMove: (event) {
                      if (event.delta.dy > 0.8) {
                        _dismissCompanionKeyboard();
                      }
                    },
                    child: _HomeCompanionChatInput(
                      key: const Key('talvori-companion-chat-input'),
                      controller: _companionInputController,
                      focusNode: _companionInputFocusNode,
                      companionDisplayName: companionDisplayName,
                      onSubmitMessage: _submitCompanionMessage,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeCompanionOverlay extends StatelessWidget {
  const _HomeCompanionOverlay({
    required this.viewportHeight,
    required this.compact,
    required this.companionState,
    required this.keyboardSafeMaxBottom,
    required this.companionDisplayName,
    required this.mascotStyle,
    required this.showHomeChatHint,
    required this.onCompanionTap,
    required this.onCompanionBubbleTap,
  });

  final double viewportHeight;
  final bool compact;
  final CompanionState companionState;
  final double? keyboardSafeMaxBottom;
  final String companionDisplayName;
  final TalvoriMascotStyle mascotStyle;
  final bool showHomeChatHint;
  final VoidCallback onCompanionTap;
  final VoidCallback onCompanionBubbleTap;

  @override
  Widget build(BuildContext context) {
    final mascotExpanded = companionState.isExpanded;
    final mascotSize = mascotExpanded
        ? (compact ? 116.0 : 136.0)
        : (compact ? 110.0 : 128.0);
    const compactMascotScale = 0.84;
    final effectiveMascotSize = mascotExpanded
        ? mascotSize
        : mascotSize * compactMascotScale;
    final cardHeight =
        (companionState.bubbleVisible
            ? TalvoriCompanionCard.estimatedBubbleHeight
            : 0.0) +
        effectiveMascotSize +
        18.0;
    final anchorBottom = _safeClampDouble(
      viewportHeight * (compact ? 0.72 : 0.74),
      compact ? 500.0 : 620.0,
      viewportHeight - (compact ? 132.0 : 164.0),
    );
    final baseTop = _safeClampDouble(
      anchorBottom - cardHeight,
      0.0,
      viewportHeight - effectiveMascotSize - 24.0,
    );
    final top = keyboardSafeMaxBottom == null
        ? baseTop
        : _safeClampDouble(baseTop, 0.0, keyboardSafeMaxBottom! - cardHeight);
    final width = companionState.isExpanded
        ? (compact ? 336.0 : 460.0)
        : mascotSize + 10.0;

    return Positioned(
      left: 16,
      top: top,
      child: SizedBox(
        width: width,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onCompanionBubbleTap,
          child: Material(
            type: MaterialType.transparency,
            child: TalvoriCompanionCard(
              mascotMood: companionState.mascotMood,
              emotion: companionState.emotion,
              title: companionDisplayName,
              message: _HomeWorldHero._companionMessage(companionState.message),
              bubbleVisible: companionState.bubbleVisible,
              isExpanded: mascotExpanded,
              inputVisible: companionState.inputVisible,
              isThinking: companionState.isThinking,
              showChatHint: showHomeChatHint && companionState.bubbleVisible,
              mascotStyle: mascotStyle,
              mascotSize: mascotSize,
              compactMascotScale: compactMascotScale,
              onMascotTap: onCompanionTap,
              onBubbleTap: onCompanionBubbleTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeWorldHero extends StatelessWidget {
  const _HomeWorldHero({
    required this.wordCount,
    required this.compact,
    required this.onGlobeTap,
  });

  final int wordCount;
  final bool compact;
  final VoidCallback onGlobeTap;

  static const _cyan = Color(0xFF5DDCFF);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final globeSize = (screenWidth * (compact ? 1.06 : 1.1))
        .clamp(compact ? 348.0 : 390.0, compact ? 440.0 : 650.0)
        .toDouble();
    final haloSize = globeSize + (compact ? 26.0 : 36.0);
    final topGap = compact ? 4.0 : 6.0;
    final globeGap = compact ? 10.0 : 14.0;
    final statusMessage = HomeStatusMessage.fromWordCount(wordCount);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 590),
      child: Column(
        key: const Key('talvori-world-home-hero'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusMessage.headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _cyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: topGap),
          Text(
            statusMessage.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.52),
              height: 1.18,
            ),
          ),
          SizedBox(height: globeGap),
          SizedBox(
            width: double.infinity,
            height: haloSize,
            child: OverflowBox(
              maxWidth: haloSize,
              minWidth: haloSize,
              maxHeight: haloSize,
              minHeight: haloSize,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: haloSize,
                height: haloSize,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: (haloSize - globeSize) / 2,
                      child: TalvoriWorldGlobe(
                        key: const ValueKey('talvori-world-globe-host'),
                        onTap: onGlobeTap,
                        size: globeSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: globeGap),
        ],
      ),
    );
  }

  static String _companionMessage(String current) {
    final trimmed = current.trim();
    if (trimmed.isEmpty || trimmed == 'Bereit für dein nächstes Wort?') {
      return 'Wollen wir deine Welt weiterbauen?';
    }
    return trimmed;
  }

  static String _compactWordCount(int count) {
    if (count >= 100000) return '${count ~/ 1000}k';
    if (count >= 10000) return '${count ~/ 1000}k';
    return '$count';
  }
}

enum HomeStatusMessageType { fallback, wordsAvailable }

class HomeStatusMessage {
  const HomeStatusMessage({
    required this.type,
    required this.headline,
    required this.subtitle,
  });

  final HomeStatusMessageType type;
  final String headline;
  final String subtitle;

  static HomeStatusMessage fromWordCount(int wordCount) {
    if (wordCount <= 0) {
      return const HomeStatusMessage(
        type: HomeStatusMessageType.fallback,
        headline: 'Deine Welt wartet',
        subtitle: 'Sammle dein erstes Wort aus der echten Welt',
      );
    }

    return HomeStatusMessage(
      type: HomeStatusMessageType.wordsAvailable,
      headline: '${_HomeWorldHero._compactWordCount(wordCount)} Wörter warten',
      subtitle: 'Starte eine kurze Runde oder sammle neue Wörter',
    );
  }
}

class _HomeAmbientBackground extends StatefulWidget {
  const _HomeAmbientBackground();

  @override
  State<_HomeAmbientBackground> createState() => _HomeAmbientBackgroundState();
}

class _HomeAmbientBackgroundState extends State<_HomeAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _HomeAmbientBackgroundPainter(phase: _controller.value),
        );
      },
    );
  }
}

class _HomeAmbientBackgroundPainter extends CustomPainter {
  const _HomeAmbientBackgroundPainter({required this.phase});

  final double phase;

  static const _cyan = Color(0xFF00D8FF);
  static const _blue = Color(0xFF2E78FF);
  static const _violet = Color(0xFF9B4DFF);
  static const _purple = Color(0xFFD35BFF);
  static const _transparent = Color(0x00000000);
  static const _stars = <_HomeBackgroundStar>[
    _HomeBackgroundStar(0.05, 0.18, 0.55, 0.16, 0.0),
    _HomeBackgroundStar(0.12, 0.32, 0.75, 0.22, 0.18),
    _HomeBackgroundStar(0.18, 0.08, 0.95, 0.2, 0.46),
    _HomeBackgroundStar(0.23, 0.57, 0.6, 0.14, 0.74),
    _HomeBackgroundStar(0.29, 0.22, 1.15, 0.24, 0.12),
    _HomeBackgroundStar(0.34, 0.42, 0.7, 0.18, 0.62),
    _HomeBackgroundStar(0.41, 0.13, 0.5, 0.13, 0.34),
    _HomeBackgroundStar(0.47, 0.66, 1.05, 0.2, 0.88),
    _HomeBackgroundStar(0.54, 0.25, 0.65, 0.16, 0.28),
    _HomeBackgroundStar(0.59, 0.48, 0.9, 0.18, 0.8),
    _HomeBackgroundStar(0.66, 0.16, 0.75, 0.17, 0.52),
    _HomeBackgroundStar(0.71, 0.61, 1.2, 0.22, 0.08),
    _HomeBackgroundStar(0.78, 0.34, 0.55, 0.14, 0.68),
    _HomeBackgroundStar(0.84, 0.09, 0.9, 0.18, 0.4),
    _HomeBackgroundStar(0.9, 0.51, 0.62, 0.15, 0.96),
    _HomeBackgroundStar(0.96, 0.26, 0.8, 0.16, 0.2),
    _HomeBackgroundStar(0.08, 0.72, 0.65, 0.12, 0.58),
    _HomeBackgroundStar(0.16, 0.83, 1.0, 0.18, 0.84),
    _HomeBackgroundStar(0.27, 0.77, 0.52, 0.11, 0.26),
    _HomeBackgroundStar(0.38, 0.9, 0.82, 0.14, 0.66),
    _HomeBackgroundStar(0.49, 0.81, 0.58, 0.11, 0.04),
    _HomeBackgroundStar(0.61, 0.74, 0.95, 0.15, 0.48),
    _HomeBackgroundStar(0.73, 0.86, 0.62, 0.12, 0.9),
    _HomeBackgroundStar(0.87, 0.71, 1.05, 0.18, 0.3),
    _HomeBackgroundStar(0.94, 0.92, 0.58, 0.11, 0.72),
    _HomeBackgroundStar(0.33, 0.04, 0.72, 0.13, 0.38),
    _HomeBackgroundStar(0.69, 0.03, 0.86, 0.16, 0.78),
    _HomeBackgroundStar(0.52, 0.94, 0.7, 0.12, 0.14),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    void drawSideLight({
      required Alignment begin,
      required Alignment end,
      required List<Color> colors,
      required List<double> stops,
    }) {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ).createShader(rect);
      canvas.drawRect(rect, paint);
    }

    canvas.saveLayer(rect, Paint());
    drawSideLight(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        _cyan.withValues(alpha: 0.24),
        _blue.withValues(alpha: 0.16),
        _blue.withValues(alpha: 0.05),
        _transparent,
      ],
      stops: const [0.0, 0.18, 0.38, 0.7],
    );
    drawSideLight(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        _purple.withValues(alpha: 0.22),
        _violet.withValues(alpha: 0.15),
        _violet.withValues(alpha: 0.05),
        _transparent,
      ],
      stops: const [0.0, 0.18, 0.38, 0.7],
    );

    _drawStarField(canvas, size);
    _drawShootingStars(canvas, size);

    final verticalMask = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _transparent,
          Color(0xAA000000),
          Color(0xEE000000),
          Color(0xAA000000),
          _transparent,
        ],
        stops: [0.0, 0.26, 0.48, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, verticalMask);
    canvas.restore();
  }

  void _drawStarField(Canvas canvas, Size size) {
    for (final star in _stars) {
      final twinkle =
          0.72 + 0.28 * math.sin((phase + star.twinkleOffset) * math.pi * 2);
      final alpha = star.alpha * twinkle;
      final center = Offset(star.x * size.width, star.y * size.height);
      final glowPaint = Paint()
        ..color = const Color(0xFF77DFFF).withValues(alpha: alpha * 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4);
      canvas.drawCircle(center, star.radius * 2.2, glowPaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.32));
      canvas.drawCircle(center, star.radius, corePaint);
    }
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    _drawShootingStar(
      canvas,
      size,
      windowStart: 0.08,
      windowLength: 0.16,
      start: const Offset(0.82, 0.12),
      travel: const Offset(-0.22, 0.13),
    );
    _drawShootingStar(
      canvas,
      size,
      windowStart: 0.58,
      windowLength: 0.14,
      start: const Offset(0.34, 0.28),
      travel: const Offset(0.2, 0.1),
    );
  }

  void _drawShootingStar(
    Canvas canvas,
    Size size, {
    required double windowStart,
    required double windowLength,
    required Offset start,
    required Offset travel,
  }) {
    final progress = ((phase - windowStart) % 1.0) / windowLength;
    if (progress < 0 || progress > 1) return;

    final ease = Curves.easeInOut.transform(progress);
    final opacity = math.sin(progress * math.pi) * 0.2;
    final head = Offset(
      (start.dx + travel.dx * ease) * size.width,
      (start.dy + travel.dy * ease) * size.height,
    );
    final tail = Offset(
      head.dx - travel.dx.sign * size.width * 0.12,
      head.dy - travel.dy.sign * size.height * 0.055,
    );

    final paint = Paint()
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _transparent,
          const Color(0xFFBEEBFF).withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.85),
        ],
      ).createShader(Rect.fromPoints(tail, head));
    canvas.drawLine(tail, head, paint);

    final headPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(head, 1.4, headPaint);
  }

  @override
  bool shouldRepaint(covariant _HomeAmbientBackgroundPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _HomeBackgroundStar {
  const _HomeBackgroundStar(
    this.x,
    this.y,
    this.radius,
    this.alpha,
    this.twinkleOffset,
  );

  final double x;
  final double y;
  final double radius;
  final double alpha;
  final double twinkleOffset;
}

class _HomeCompanionChatInput extends StatelessWidget {
  const _HomeCompanionChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.companionDisplayName,
    required this.onSubmitMessage,
  });

  static const _accent = Color(0xFF9FCED0);
  static const estimatedHeight = 64.0;

  final TextEditingController controller;
  final FocusNode focusNode;
  final String companionDisplayName;
  final ValueChanged<String> onSubmitMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF030811).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accent.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(color: _accent.withValues(alpha: 0.12), blurRadius: 22),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('talvori-companion-chat-text-field'),
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: _accent,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Frag $companionDisplayName kurz ...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: _submit,
              ),
            ),
            IconButton(
              key: const Key('talvori-companion-chat-send'),
              tooltip: 'Senden',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: const Icon(Icons.send_rounded, size: 19, color: _accent),
              onPressed: () => _submit(controller.text),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    onSubmitMessage(trimmed);
  }
}

double _safeClampDouble(double value, double lowerLimit, double upperLimit) {
  if (value.isNaN || lowerLimit.isNaN || upperLimit.isNaN) {
    return lowerLimit.isNaN ? 0.0 : lowerLimit;
  }
  final safeUpperLimit = upperLimit < lowerLimit ? lowerLimit : upperLimit;
  return value.clamp(lowerLimit, safeUpperLimit).toDouble();
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
