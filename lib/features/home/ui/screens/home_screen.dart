import 'dart:async';

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
    final chatClusterBottom = keyboardInset > 0
        ? keyboardInset + 2.0
        : mediaQuery.padding.bottom + 96.0;
    final chatCompanionMascotSize = mediaQuery.size.width < 380 ? 104.0 : 116.0;
    final chatCompanionWidth = _safeClampDouble(
      mediaQuery.size.width - 32,
      280.0,
      560.0,
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
            body: Stack(
              fit: StackFit.expand,
              children: [
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
                                          selected: tagesimpulsSelection.count,
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
                                          companionState: companionState,
                                          companionDisplayName:
                                              companionDisplayName,
                                          mascotStyle: mascotStyle,
                                          showCompanion:
                                              showCompanion && !chatOverlayOpen,
                                          showHomeChatHint: showHomeChatHint,
                                          onGlobeTap: _openWorldRegion,
                                          onCompanionTap: _toggleCompanion,
                                          onCompanionBubbleTap:
                                              _openCompanionChatInput,
                                          onLearnTap: _showLearningSourcesPopup,
                                          onSentenceSparksTap:
                                              _openSentenceSparks,
                                        ),
                                      ),
                                      const SizedBox(height: 102),
                                    ],
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
              ],
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
              ),
            ),
          if (chatOverlayOpen)
            Positioned(
              key: const Key('talvori-companion-chat-cluster'),
              left: 0,
              right: 0,
              bottom: chatClusterBottom,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: chatCompanionWidth,
                          child: TalvoriCompanionCard(
                            mascotMood: companionState.mascotMood,
                            emotion: companionState.emotion,
                            title: companionDisplayName,
                            message: companionState.message,
                            bubbleVisible: companionState.bubbleVisible,
                            isExpanded: true,
                            inputVisible: companionState.inputVisible,
                            isThinking: companionState.isThinking,
                            messageMaxLines: 6,
                            mascotStyle: mascotStyle,
                            mascotSize: chatCompanionMascotSize,
                            onMascotTap: _toggleCompanion,
                            onBubbleTap: _openCompanionChatInput,
                          ),
                        ),
                      ),
                      if (companionState.inputVisible) ...[
                        const SizedBox(height: 8),
                        _HomeCompanionChatInput(
                          key: const Key('talvori-companion-chat-input'),
                          controller: _companionInputController,
                          focusNode: _companionInputFocusNode,
                          companionDisplayName: companionDisplayName,
                          onSubmitMessage: _submitCompanionMessage,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeWorldHero extends StatelessWidget {
  const _HomeWorldHero({
    required this.wordCount,
    required this.compact,
    required this.companionState,
    required this.companionDisplayName,
    required this.mascotStyle,
    required this.showCompanion,
    required this.showHomeChatHint,
    required this.onGlobeTap,
    required this.onCompanionTap,
    required this.onCompanionBubbleTap,
    required this.onLearnTap,
    required this.onSentenceSparksTap,
  });

  final int wordCount;
  final bool compact;
  final CompanionState companionState;
  final String companionDisplayName;
  final TalvoriMascotStyle mascotStyle;
  final bool showCompanion;
  final bool showHomeChatHint;
  final VoidCallback onGlobeTap;
  final VoidCallback onCompanionTap;
  final VoidCallback onCompanionBubbleTap;
  final VoidCallback onLearnTap;
  final VoidCallback onSentenceSparksTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final globeSize = (screenWidth * (compact ? 1.06 : 1.1))
        .clamp(compact ? 348.0 : 390.0, compact ? 440.0 : 650.0)
        .toDouble();
    final haloSize = globeSize + (compact ? 26.0 : 36.0);
    final topGap = compact ? 4.0 : 6.0;
    final globeGap = compact ? 10.0 : 14.0;
    final companionSize = companionState.isExpanded
        ? (compact ? 96.0 : 118.0)
        : (compact ? 72.0 : 84.0);
    final companionWidth = companionState.isExpanded
        ? (compact ? 336.0 : 460.0)
        : companionSize + 10;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 590),
      child: Column(
        key: const Key('talvori-world-home-hero'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Deine Welt wartet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _cyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: topGap),
          Text(
            '${_compactWordCount(wordCount)} Wörter · Talvori-Welt-Zentrale',
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
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -haloSize * 0.16,
                              top: haloSize * 0.08,
                              width: haloSize * 0.72,
                              height: haloSize * 0.78,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      _cyan.withValues(alpha: 0.24),
                                      _cyan.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -haloSize * 0.18,
                              top: haloSize * 0.04,
                              width: haloSize * 0.76,
                              height: haloSize * 0.82,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      _violet.withValues(alpha: 0.22),
                                      _violet.withValues(alpha: 0.09),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: haloSize * 0.1,
                              right: haloSize * 0.1,
                              top: haloSize * 0.18,
                              height: haloSize * 0.6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.06),
                                      _cyan.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: (haloSize - globeSize) / 2,
                      child: TalvoriWorldGlobe(
                        onTap: onGlobeTap,
                        size: globeSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showCompanion) SizedBox(height: compact ? 10 : 54),
          if (showCompanion)
            SizedBox(
              height: companionState.isExpanded
                  ? (compact ? 238 : 264)
                  : (compact ? 52 : 60),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: companionWidth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onCompanionBubbleTap,
                    child: Material(
                      type: MaterialType.transparency,
                      child: TalvoriCompanionCard(
                        mascotMood: companionState.mascotMood,
                        emotion: companionState.emotion,
                        title: companionDisplayName,
                        message: _companionMessage(companionState.message),
                        bubbleVisible: companionState.bubbleVisible,
                        isExpanded: companionState.isExpanded,
                        inputVisible: companionState.inputVisible,
                        isThinking: companionState.isThinking,
                        showChatHint:
                            showHomeChatHint && companionState.bubbleVisible,
                        mascotStyle: mascotStyle,
                        mascotSize: companionSize,
                        compactMascotScale: 0.68,
                        messageMaxLines: compact ? 2 : 3,
                        quickActions: [
                          TalvoriCompanionQuickAction(
                            key: const Key('home-companion-sentence-sparks'),
                            label: 'Satzfunken',
                            icon: Icons.auto_awesome_rounded,
                            onTap: onSentenceSparksTap,
                          ),
                          TalvoriCompanionQuickAction(
                            key: const Key('home-companion-learn'),
                            label: 'Lernen',
                            icon: Icons.psychology_rounded,
                            onTap: onLearnTap,
                          ),
                          TalvoriCompanionQuickAction(
                            key: const Key('home-companion-world'),
                            label: 'Welt',
                            icon: Icons.public_rounded,
                            onTap: onGlobeTap,
                          ),
                        ],
                        onMascotTap: onCompanionTap,
                        onBubbleTap: onCompanionBubbleTap,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
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

class _HomeCompanionChatInput extends StatelessWidget {
  const _HomeCompanionChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.companionDisplayName,
    required this.onSubmitMessage,
  });

  static const _accent = Color(0xFF9FCED0);

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
