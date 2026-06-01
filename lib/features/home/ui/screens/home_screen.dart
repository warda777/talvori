import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
import 'package:talvori/features/home/application/profile_preferences_controller.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart' as wc;
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

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
import 'package:talvori/features/common/widgets/fireball_bounce_animation.dart';
import 'package:talvori/features/local_learning_debug/ui/local_debug_hub_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  Future<void> _openMyWordsList() async {
    final nav = Navigator.of(context);
    await nav.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'local-vocabs-my_words'),
        builder: (_) => const LocalWordListScreen(
          categoryId: localMyWordsCategoryId,
          title: localMyWordsCategoryLabel,
        ),
      ),
    );
    if (!mounted) return;
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

  Future<void> _openExternalWordImport() {
    return wc.onChromeButtonTap(context, ref);
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _homeSystemUiOverlayStyle,
      child: Stack(
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
                      // 🔥 Fireball HINTER dem Button
                      FireballBounceAnimation(
                        key: _fireballKey,
                        anchorKey: _crownButtonKey,
                        practiceKey:
                            _practiceButtonKey, // <-- NEU: Practice-Button Key
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
                          final compactHome = viewport.maxHeight < 760;
                          final showCompanion =
                              viewport.maxHeight >= 820 || chatOverlayOpen;
                          final disableHomeScroll = viewport.maxHeight >= 820;
                          final companionLeft = _safeClampDouble(
                            viewport.maxWidth * 0.08,
                            24.0,
                            40.0,
                          );
                          const compactCompanionScale = 0.34;
                          final companionMascotSize = viewport.maxWidth < 380
                              ? 150.0
                              : 164.0;
                          final compactCompanionMascotSize =
                              companionMascotSize * compactCompanionScale;
                          final companionEffectiveMascotSize =
                              companionState.isExpanded
                              ? companionMascotSize
                              : compactCompanionMascotSize;
                          final companionWidth = _safeClampDouble(
                            viewport.maxWidth - companionLeft - 16,
                            280.0,
                            560.0,
                          );
                          final companionHeight =
                              (companionState.bubbleVisible ? 88.0 : 0.0) +
                              companionEffectiveMascotSize +
                              18.0;
                          final companionTopBase = companionState.isExpanded
                              ? viewport.maxHeight * 0.68
                              : viewport.maxHeight * 0.72;
                          final companionTop = _safeClampDouble(
                            companionTopBase,
                            12.0,
                            viewport.maxHeight - companionHeight - 8,
                          );

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
                                      HomeTopBar(
                                        buttonKey: _rightButtonKey,
                                        progressPillKey: _progressPillKey,
                                        counterKey:
                                            _counterKey, // <-- NEU: Counter Key
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
                                              builder: (_) =>
                                                  const CourseScreen(),
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
                                          // Animation fertig - jetzt kann die Pill ausgeblendet werden
                                          // Verzögere setState, damit es nicht während des Builds aufgerufen wird
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
                                      const SizedBox(height: 16),
                                      Center(
                                        child: _HomeWorldHero(
                                          wordCount: state.myWordsCount,
                                          compact: compactHome,
                                          onGlobeTap: _openWorldRegion,
                                          onLearnTap: _showLearningSourcesPopup,
                                          onImportTap: _openExternalWordImport,
                                          onWordsTap: _openMyWordsList,
                                        ),
                                      ),
                                      const SizedBox(height: 96),
                                    ],
                                  ),
                                ),
                              ),
                              if (showCompanion && !chatOverlayOpen)
                                Positioned(
                                  top: companionTop,
                                  left: companionLeft,
                                  child: SizedBox(
                                    width: companionWidth,
                                    child: TalvoriCompanionCard(
                                      mascotMood: companionState.mascotMood,
                                      emotion: companionState.emotion,
                                      title: companionDisplayName,
                                      message: companionState.message,
                                      bubbleVisible:
                                          companionState.bubbleVisible,
                                      isExpanded: companionState.isExpanded,
                                      inputVisible: companionState.inputVisible,
                                      isThinking: companionState.isThinking,
                                      showChatHint:
                                          showHomeChatHint &&
                                          companionState.bubbleVisible,
                                      mascotStyle: mascotStyle,
                                      mascotSize: companionMascotSize,
                                      compactMascotScale: compactCompanionScale,
                                      onMascotTap: _toggleCompanion,
                                      onBubbleTap: _openCompanionChatInput,
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
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: HomeTheme.bottomPadding,
                child: HomeBottomNav(
                  onImpulseInbox: _openImpulseInbox,
                  onWords: _showLearningSourcesPopup,
                  onPractice: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VocabScreen()),
                  ),
                  onProfile: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
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
                      MaterialPageRoute(
                        builder: (_) => const LocalDebugHubScreen(),
                      ),
                    ),
                    child: const Icon(Icons.bug_report_outlined),
                  )
                : null,
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
    required this.onGlobeTap,
    required this.onLearnTap,
    required this.onImportTap,
    required this.onWordsTap,
  });

  final int wordCount;
  final bool compact;
  final VoidCallback onGlobeTap;
  final VoidCallback onLearnTap;
  final VoidCallback onImportTap;
  final VoidCallback onWordsTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);

  @override
  Widget build(BuildContext context) {
    final globeSize = compact ? 210.0 : 286.0;
    final haloSize = compact ? 228.0 : 306.0;
    final actionHeight = compact ? 64.0 : 68.0;
    final topGap = compact ? 6.0 : 8.0;
    final globeGap = compact ? 10.0 : 16.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(
        key: const Key('talvori-world-home-hero'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Talvori-Welt-Zentrale',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _cyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: topGap),
          Text(
            'Meine Wörter bauen eine Welt.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1.04,
            ),
          ),
          SizedBox(height: topGap),
          Text(
            'Sammle Wörter aus der echten Welt. Lerne sie im Kontext.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.28,
            ),
          ),
          SizedBox(height: globeGap),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: haloSize,
                height: haloSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _cyan.withValues(alpha: 0.16),
                      _violet.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              TalvoriWorldGlobe(onTap: onGlobeTap, size: globeSize),
              Positioned(
                bottom: compact ? 10 : 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07101A).withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _mint.withValues(alpha: 0.36)),
                    boxShadow: [
                      BoxShadow(
                        color: _cyan.withValues(alpha: 0.12),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 15, color: _mint),
                      SizedBox(width: 6),
                      Text(
                        'Welt öffnen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _WorldStatusPill(
                icon: Icons.auto_stories_rounded,
                label: 'Wörter',
                value: _compactWordCount(wordCount),
                onTap: onWordsTap,
                key: const Key('home-my-words-counter-button'),
              ),
              const _WorldStatusPill(
                icon: Icons.landscape_rounded,
                label: 'Startregion',
                value: 'Prototyp',
              ),
              const _WorldStatusPill(
                icon: Icons.bolt_rounded,
                label: 'Rohstoffe',
                value: 'bald',
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Row(
            children: [
              Expanded(
                child: _WorldHeroAction(
                  height: actionHeight,
                  actionKey: const Key('home-my-words-play-button'),
                  icon: Icons.psychology_rounded,
                  label: 'Lernen',
                  subtitle: 'Wörter werden später Rohstoffe',
                  onTap: onLearnTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WorldHeroAction(
                  height: actionHeight,
                  icon: Icons.public_rounded,
                  label: 'Region',
                  subtitle: 'Startregion ansehen',
                  onTap: onGlobeTap,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          _WorldHeroAction(
            height: actionHeight,
            actionKey: const Key('home-browser-return-button'),
            icon: Icons.travel_explore_rounded,
            label: 'Wörter aus der Welt sammeln',
            subtitle: 'Browser öffnen und echte Wörter importieren',
            onTap: onImportTap,
          ),
        ],
      ),
    );
  }

  static String _compactWordCount(int count) {
    if (count >= 100000) return '${count ~/ 1000}k';
    if (count >= 10000) return '${count ~/ 1000}k';
    return '$count';
  }
}

class _WorldStatusPill extends StatelessWidget {
  const _WorldStatusPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  static const _cyan = Color(0xFF5DDCFF);

  @override
  Widget build(BuildContext context) {
    final child = Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _cyan.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _cyan),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _WorldHeroAction extends StatelessWidget {
  const _WorldHeroAction({
    required this.height,
    this.actionKey,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final double height;
  final Key? actionKey;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  static const _violet = Color(0xFFB36BFF);

  @override
  Widget build(BuildContext context) {
    final compact = height < 66;
    return GestureDetector(
      key: actionKey,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF07101A).withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _violet.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
