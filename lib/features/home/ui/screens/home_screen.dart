import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'package:talvori/features/world/local_world/ui/screens/local_world_screen.dart';
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
  double _companionInputHeight = _HomeCompanionChatInput.estimatedHeight;
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

  void _updateCompanionInputHeight(double height) {
    final safeHeight = height.isFinite && height > 0
        ? height
        : _HomeCompanionChatInput.estimatedHeight;
    if ((safeHeight - _companionInputHeight).abs() < 0.5) return;
    setState(() => _companionInputHeight = safeHeight);
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
    _companionInputHeight = _HomeCompanionChatInput.estimatedHeight;
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
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LocalWorldScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final fade = Curves.easeOutCubic.transform(animation.value);
          final scale = 0.98 + (0.02 * fade);
          return FadeTransition(
            opacity: animation,
            child: Transform.scale(scale: scale, child: child),
          );
        },
      ),
    );
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
    final companionKeyboardMaxBottom = companionState.inputVisible
        ? mediaQuery.size.height -
              chatInputBottom -
              _companionInputHeight -
              mediaQuery.padding.top -
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
                                if (companionState.inputVisible)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      key: const Key(
                                        'talvori-companion-chat-home-barrier',
                                      ),
                                      behavior: HitTestBehavior.opaque,
                                      onTap: _closeCompanionChatInput,
                                      child: const SizedBox.expand(),
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
            floatingActionButton: GestureDetector(
              key: const Key('talvori-companion-chat-hub-barrier'),
              behavior: HitTestBehavior.translucent,
              onTap: companionState.inputVisible
                  ? _closeCompanionChatInput
                  : null,
              child: AbsorbPointer(
                absorbing: companionState.inputVisible,
                child: HomeSmartHubMenu(actions: homeHubActions),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
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
                    child: _HomeCompanionChatInput(
                      key: const Key('talvori-companion-chat-input'),
                      controller: _companionInputController,
                      focusNode: _companionInputFocusNode,
                      companionDisplayName: companionDisplayName,
                      onSubmitMessage: _submitCompanionMessage,
                      onHeightChanged: _updateCompanionInputHeight,
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
        : _keyboardSafeTop(
            baseTop: baseTop,
            cardHeight: cardHeight,
            keyboardSafeMaxBottom: keyboardSafeMaxBottom!,
          );
    final width = companionState.isExpanded
        ? (compact ? 336.0 : 460.0)
        : mascotSize + 10.0;

    return Positioned(
      left: 16,
      top: top,
      child: SizedBox(
        width: width,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
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

  double _keyboardSafeTop({
    required double baseTop,
    required double cardHeight,
    required double keyboardSafeMaxBottom,
  }) {
    final keyboardSafeTop = keyboardSafeMaxBottom - cardHeight;
    final lowerLimit = math.min(0.0, keyboardSafeTop);
    return _safeClampDouble(baseTop, lowerLimit, keyboardSafeTop);
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HomeAmbientBackgroundPainter(phase: _controller.value),
          );
        },
      ),
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
  static const _accentStars = <_HomeBackgroundStar>[
    _HomeBackgroundStar(0.07, 0.2, 1.35, 0.44, 0.0),
    _HomeBackgroundStar(0.15, 0.78, 1.08, 0.38, 0.18),
    _HomeBackgroundStar(0.21, 0.49, 0.92, 0.34, 0.46),
    _HomeBackgroundStar(0.32, 0.1, 1.18, 0.42, 0.74),
    _HomeBackgroundStar(0.39, 0.86, 0.86, 0.33, 0.12),
    _HomeBackgroundStar(0.48, 0.24, 1.0, 0.36, 0.62),
    _HomeBackgroundStar(0.58, 0.58, 1.24, 0.4, 0.34),
    _HomeBackgroundStar(0.67, 0.13, 0.94, 0.35, 0.88),
    _HomeBackgroundStar(0.76, 0.72, 1.16, 0.4, 0.28),
    _HomeBackgroundStar(0.84, 0.34, 0.88, 0.34, 0.8),
    _HomeBackgroundStar(0.91, 0.09, 1.32, 0.45, 0.52),
    _HomeBackgroundStar(0.94, 0.91, 1.04, 0.38, 0.08),
  ];
  static const _shootingStarEvents = <_HomeShootingStarEvent>[
    _HomeShootingStarEvent(
      windowStart: 0.06,
      windowLength: 0.095,
      start: Offset(0.12, -0.04),
      travel: Offset(0.28, 0.18),
      tailLength: 0.2,
      brightness: 0.86,
    ),
    _HomeShootingStarEvent(
      windowStart: 0.31,
      windowLength: 0.08,
      start: Offset(1.05, 0.17),
      travel: Offset(-0.3, 0.16),
      tailLength: 0.18,
      brightness: 0.74,
    ),
    _HomeShootingStarEvent(
      windowStart: 0.52,
      windowLength: 0.11,
      start: Offset(0.72, -0.05),
      travel: Offset(-0.24, 0.24),
      tailLength: 0.22,
      brightness: 0.9,
    ),
    _HomeShootingStarEvent(
      windowStart: 0.76,
      windowLength: 0.085,
      start: Offset(-0.06, 0.55),
      travel: Offset(0.32, 0.13),
      tailLength: 0.17,
      brightness: 0.68,
    ),
    _HomeShootingStarEvent(
      windowStart: 0.91,
      windowLength: 0.07,
      start: Offset(1.04, 0.72),
      travel: Offset(-0.26, -0.16),
      tailLength: 0.15,
      brightness: 0.62,
    ),
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

    _drawGalaxyDust(canvas, size);
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

  void _drawGalaxyDust(Canvas canvas, Size size) {
    final bandStart = Offset(size.width * -0.08, size.height * 0.88);
    final bandEnd = Offset(size.width * 1.08, size.height * 0.22);
    final cyanBand = Paint()
      ..color = _cyan.withValues(alpha: 0.055)
      ..strokeWidth = size.shortestSide * 0.18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    canvas.drawLine(bandStart, bandEnd, cyanBand);

    final violetBand = Paint()
      ..color = _violet.withValues(alpha: 0.045)
      ..strokeWidth = size.shortestSide * 0.13
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.94),
      Offset(size.width * 1.08, size.height * 0.34),
      violetBand,
    );

    final dustPaint = Paint();
    for (var i = 0; i < 80; i++) {
      final t = _unitNoise(i, 9.2);
      final drift = (_unitNoise(i, 13.7) - 0.5) * 0.18;
      final x = (-0.04 + t * 1.12 + drift * 0.36) * size.width;
      final y = (0.86 - t * 0.58 + drift) * size.height;
      final alpha = 0.08 + _unitNoise(i, 17.1) * 0.14;
      final radius = 0.35 + _unitNoise(i, 21.4) * 0.75;
      dustPaint.color = const Color(0xFF93E8FF).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, dustPaint);
    }
  }

  void _drawStarField(Canvas canvas, Size size) {
    _drawGeneratedStarLayer(
      canvas,
      size,
      count: 96,
      seed: 1.7,
      minRadius: 0.28,
      maxRadius: 0.72,
      minAlpha: 0.16,
      maxAlpha: 0.34,
      twinkleDepth: 0.14,
      twinkleSpeed: 0.42,
    );
    _drawGeneratedStarLayer(
      canvas,
      size,
      count: 56,
      seed: 4.9,
      minRadius: 0.55,
      maxRadius: 1.08,
      minAlpha: 0.24,
      maxAlpha: 0.48,
      twinkleDepth: 0.22,
      twinkleSpeed: 0.68,
    );

    for (final star in _accentStars) {
      final twinkle =
          0.64 + 0.36 * math.sin((phase + star.twinkleOffset) * math.pi * 2);
      final alpha = star.alpha * twinkle;
      final center = Offset(star.x * size.width, star.y * size.height);
      final glowPaint = Paint()
        ..color = const Color(0xFF8BE8FF).withValues(alpha: alpha * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.2);
      canvas.drawCircle(center, star.radius * 3.8, glowPaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.56));
      canvas.drawCircle(center, star.radius, corePaint);

      final flarePaint = Paint()
        ..strokeWidth = 0.75
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: alpha * 0.2);
      canvas.drawLine(
        center.translate(-star.radius * 3.2, 0),
        center.translate(star.radius * 3.2, 0),
        flarePaint,
      );
      canvas.drawLine(
        center.translate(0, -star.radius * 3.2),
        center.translate(0, star.radius * 3.2),
        flarePaint,
      );
    }
  }

  void _drawGeneratedStarLayer(
    Canvas canvas,
    Size size, {
    required int count,
    required double seed,
    required double minRadius,
    required double maxRadius,
    required double minAlpha,
    required double maxAlpha,
    required double twinkleDepth,
    required double twinkleSpeed,
  }) {
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final corePaint = Paint();

    for (var i = 0; i < count; i++) {
      final x = _unitNoise(i, seed);
      final y = _unitNoise(i, seed + 31.0);
      final sizeMix = _unitNoise(i, seed + 71.0);
      final alphaMix = _unitNoise(i, seed + 109.0);
      final twinkleOffset = _unitNoise(i, seed + 173.0);
      final twinkle =
          1 -
          twinkleDepth / 2 +
          twinkleDepth *
              math.sin((phase * twinkleSpeed + twinkleOffset) * math.pi * 2);
      final alpha = (minAlpha + (maxAlpha - minAlpha) * alphaMix) * twinkle;
      final radius = minRadius + (maxRadius - minRadius) * sizeMix;
      final center = Offset(x * size.width, y * size.height);

      if (radius > 0.82) {
        glowPaint.color = const Color(
          0xFF74DFFF,
        ).withValues(alpha: alpha * 0.18);
        canvas.drawCircle(center, radius * 2.5, glowPaint);
      }

      corePaint.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.52));
      canvas.drawCircle(center, radius, corePaint);
    }
  }

  void _drawShootingStars(Canvas canvas, Size size) {
    for (final event in _shootingStarEvents) {
      if (_drawShootingStar(canvas, size, event)) {
        return;
      }
    }
  }

  bool _drawShootingStar(
    Canvas canvas,
    Size size,
    _HomeShootingStarEvent event,
  ) {
    final elapsed = phase >= event.windowStart
        ? phase - event.windowStart
        : phase + 1 - event.windowStart;
    if (elapsed > event.windowLength) return false;
    final progress = elapsed / event.windowLength;

    final ease = Curves.easeInOut.transform(progress);
    final opacity = math.sin(progress * math.pi) * 0.42 * event.brightness;
    final head = Offset(
      (event.start.dx + event.travel.dx * ease) * size.width,
      (event.start.dy + event.travel.dy * ease) * size.height,
    );
    final travelVector = Offset(
      event.travel.dx * size.width,
      event.travel.dy * size.height,
    );
    final travelDistance = travelVector.distance;
    if (travelDistance == 0) return true;

    final direction = Offset(
      travelVector.dx / travelDistance,
      travelVector.dy / travelDistance,
    );
    final tail = head.translate(
      -direction.dx * size.shortestSide * event.tailLength,
      -direction.dy * size.shortestSide * event.tailLength,
    );
    final diffuseTail = Paint()
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..shader = ui.Gradient.linear(
        tail,
        head,
        [
          _transparent,
          const Color(0xFF6FD9FF).withValues(alpha: opacity * 0.2),
          const Color(0xFFD8F6FF).withValues(alpha: opacity * 0.34),
        ],
        const [0.0, 0.62, 1.0],
      );
    canvas.drawLine(tail, head, diffuseTail);

    final coreTail = Paint()
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        tail,
        head,
        [
          _transparent,
          const Color(0xFFBEEBFF).withValues(alpha: opacity * 0.56),
          Colors.white.withValues(alpha: opacity * 0.72),
        ],
        const [0.0, 0.68, 1.0],
      );
    canvas.drawLine(tail, head, coreTail);

    final headGlow = Paint()
      ..color = const Color(0xFF8FE7FF).withValues(alpha: opacity * 0.34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5);
    canvas.drawCircle(head, 5.8, headGlow);

    final headHalo = Paint()
      ..color = const Color(0xFFD7F5FF).withValues(alpha: opacity * 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawCircle(head, 2.6, headHalo);

    final headCore = Paint()
      ..color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.86));
    canvas.drawCircle(head, 1.45, headCore);

    return true;
  }

  double _unitNoise(int index, double seed) {
    final raw = math.sin(index * 12.9898 + seed * 78.233) * 43758.5453;
    return raw - raw.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _HomeAmbientBackgroundPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _HomeShootingStarEvent {
  const _HomeShootingStarEvent({
    required this.windowStart,
    required this.windowLength,
    required this.start,
    required this.travel,
    required this.tailLength,
    required this.brightness,
  });

  final double windowStart;
  final double windowLength;
  final Offset start;
  final Offset travel;
  final double tailLength;
  final double brightness;
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

class _HomeCompanionChatInput extends StatefulWidget {
  const _HomeCompanionChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.companionDisplayName,
    required this.onSubmitMessage,
    required this.onHeightChanged,
  });

  static const _accent = Color(0xFF9FCED0);
  static const estimatedHeight = 64.0;

  final TextEditingController controller;
  final FocusNode focusNode;
  final String companionDisplayName;
  final ValueChanged<String> onSubmitMessage;
  final ValueChanged<double> onHeightChanged;

  @override
  State<_HomeCompanionChatInput> createState() =>
      _HomeCompanionChatInputState();
}

class _HomeCompanionChatInputState extends State<_HomeCompanionChatInput> {
  final GlobalKey _inputBarKey = GlobalKey();
  late final ScrollController _textScrollController;
  Timer? _inputScrollIndicatorTimer;
  bool _inputScrollIndicatorCheckScheduled = false;
  bool _showInputScrollIndicator = false;

  @override
  void initState() {
    super.initState();
    _textScrollController = ScrollController();
    widget.controller.addListener(_scheduleHeightReport);
    widget.controller.addListener(_syncTextFieldState);
    widget.focusNode.addListener(_syncTextFieldState);
    _scheduleHeightReport();
  }

  @override
  void didUpdateWidget(covariant _HomeCompanionChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleHeightReport);
      oldWidget.controller.removeListener(_syncTextFieldState);
      widget.controller.addListener(_scheduleHeightReport);
      widget.controller.addListener(_syncTextFieldState);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_syncTextFieldState);
      widget.focusNode.addListener(_syncTextFieldState);
    }
    _scheduleHeightReport();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleHeightReport);
    widget.controller.removeListener(_syncTextFieldState);
    widget.focusNode.removeListener(_syncTextFieldState);
    _inputScrollIndicatorTimer?.cancel();
    _textScrollController.dispose();
    super.dispose();
  }

  void _scheduleHeightReport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _inputBarKey.currentContext;
      final renderObject = context?.findRenderObject();
      if (renderObject is! RenderBox) return;
      widget.onHeightChanged(renderObject.size.height);
    });
  }

  void _syncTextFieldState() {
    if (!mounted) return;
    setState(() {});
    _showInputScrollIndicatorForActivity();
    _scheduleHeightReport();
  }

  void _showInputScrollIndicatorForActivity() {
    if (_inputScrollIndicatorCheckScheduled) return;
    _inputScrollIndicatorCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputScrollIndicatorCheckScheduled = false;
      if (!mounted || !widget.focusNode.hasFocus || !_inputCanScroll()) {
        _inputScrollIndicatorTimer?.cancel();
        if (_showInputScrollIndicator) {
          setState(() => _showInputScrollIndicator = false);
        }
        return;
      }

      _inputScrollIndicatorTimer?.cancel();
      if (!_showInputScrollIndicator) {
        setState(() => _showInputScrollIndicator = true);
      }
      _inputScrollIndicatorTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _showInputScrollIndicator = false);
      });
    });
  }

  bool _inputCanScroll() {
    if (!_textScrollController.hasClients) return false;
    final position = _textScrollController.position;
    if (!position.hasContentDimensions) return false;
    return position.maxScrollExtent > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        key: _inputBarKey,
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF030811).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _HomeCompanionChatInput._accent.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _HomeCompanionChatInput._accent.withValues(alpha: 0.12),
              blurRadius: 22,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Listener(
                    onPointerMove: (event) {
                      if (event.delta.dy.abs() > 0.2) {
                        _syncTextFieldState();
                      }
                    },
                    child: TextField(
                      key: const Key('talvori-companion-chat-text-field'),
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      scrollController: _textScrollController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: _HomeCompanionChatInput._accent,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText:
                            'Frag ${widget.companionDisplayName} kurz ...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _submit,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: -2,
                    bottom: 2,
                    child: _InputTextScrollIndicator(
                      key: const Key('talvori-companion-chat-input-scrollbar'),
                      controller: _textScrollController,
                      visible: _showInputScrollIndicator,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('talvori-companion-chat-send'),
              tooltip: 'Senden',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: const Icon(
                Icons.send_rounded,
                size: 19,
                color: _HomeCompanionChatInput._accent,
              ),
              onPressed: () => _submit(widget.controller.text),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    widget.onSubmitMessage(trimmed);
  }
}

class _InputTextScrollIndicator extends StatelessWidget {
  const _InputTextScrollIndicator({
    super.key,
    required this.controller,
    required this.visible,
  });

  final ScrollController controller;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasClients) {
      return const SizedBox(width: 3);
    }

    final position = controller.position;
    if (!position.hasContentDimensions) {
      return const SizedBox(width: 3);
    }

    final maxScrollExtent = position.maxScrollExtent;
    if (maxScrollExtent <= 0) {
      return const SizedBox(width: 3);
    }

    return SizedBox(
      width: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackHeight = constraints.maxHeight;
          if (trackHeight <= 0) return const SizedBox.shrink();

          final visibleRatio =
              position.viewportDimension /
              (position.viewportDimension + maxScrollExtent);
          final thumbHeight = (trackHeight * visibleRatio).clamp(
            18.0,
            trackHeight,
          );
          final scrollProgress = maxScrollExtent <= 0
              ? 0.0
              : (position.pixels / maxScrollExtent).clamp(0.0, 1.0);
          final thumbTop = (trackHeight - thumbHeight) * scrollProgress;

          return AnimatedOpacity(
            key: const Key('talvori-companion-chat-input-scrollbar-opacity'),
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  top: thumbTop,
                  left: 0,
                  right: 0,
                  height: thumbHeight,
                  child: DecoratedBox(
                    key: const Key(
                      'talvori-companion-chat-input-scrollbar-thumb',
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
