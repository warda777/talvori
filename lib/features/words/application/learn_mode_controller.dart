// lib/features/words/application/learn_mode_controller.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_logic.dart';
import 'package:talvori/features/words/application/srs_config.dart';
import 'package:talvori/features/words/services/sfx_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/events/events.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/application/category_detail_controller.dart';
import 'package:talvori/features/words/application/category_controller.dart';
import 'package:talvori/features/words/application/word_providers.dart';

/// ---------- State ----------

class LearnModeState {
  final String categoryId;
  final String title;

  final bool loading;
  final List<CategoryInfo> categories;
  final int selectedCategoryIndex;

  final List<int> stages; // [S0..S5] - Gesamt-Counts aus CategoryProgress
  final List<int> deckStages; // [S0..S5] - Counts nur aus aktuell geladenem Deck (shuffledWordIds)
  final int totalWordsInCategory;
  final int activeStage; // A-SRS: Aktuelle Stage (0..5), wird für Navigation verwendet
  final int masteredCount; // Kapsel unter A5 (gelernt, streak>=3)

  final List<WordUserView> wordQueue;      // Originale Wortliste (Objekte)
  final List<String> shuffledWordIds;      // Reihenfolge (nur IDs)
  final int index;                         // Zeiger in shuffledWordIds

  final bool showTranslation;

  // Timer
  final bool running;          // Timer läuft (nicht pausiert)
  final bool timerActive;      // Timer wurde gestartet (Play gedrückt)
  final bool timerPaused;      // explizit pausiert
  final double remainingMillis;
  final int timeLimit;         // Sekunden pro Karte

  // Hybrid: Tages-Lernzeit pro Stage (S1-S5). -1 = keine Anzeige/kein Budget.
  // Wird nur im Hybrid genutzt, in anderen Modi bleibt es [-1..].
  final List<int> hybridStageRemainingSec; // Länge 6 (S0..S5)
  // Hybrid: Stage ist für HEUTE eingefroren (Budget aufgebraucht) -> bis morgen.
  final List<bool> hybridStageFrozen; // Länge 6 (S0..S5)
  // Hybrid: ab erstem "echten Start" (1. Swipe) gilt die Session als gestartet -> Timer/Grün-Status.
  final bool hybridSessionStarted;
  // UI: LearnModeScreen ist gerade sichtbar/aktiv (wichtig für CategoryDetail/Hub-UI, damit nicht "stale" Live-Counts weiter genutzt werden).
  final bool inLearnScreen;

  // Reviews
  final List<String> recentlySwiped; // IDs der Karten, die in dieser Session korrekt geswipet wurden
  final int cardsSwipedInSession;
  final bool hasLoadedReviews;
  /// Verhindert doppelte Swipe/Commit während RPC läuft
  final bool isSubmitting;
  final bool isSubmittingReview;

  /// Sichtbare Diagnose wenn Queue leer (für Gerät ohne Terminal)
  final String? emptyQueueHint;

  /// Alle Wörter in S5 (A5) – zeige "Final Start"-Button statt Deck
  final bool showFinalStartButton;

  /// Finale Phase aktiv (nach Klick auf Final Round)
  final bool finalPassActive;

  /// Kategorie vollständig absolviert (letztes Wort in S5 mastered) – Glückwunsch-UI, Feuerwerk, Restart
  final bool categoryMastered;
  /// Nach Feuerwerk: Restart-Button anzeigen (erst dann Reset möglich)
  final bool categoryMasteredRestartReady;

  /// A-SRS: Frische Runde noch nicht gestartet (kein erster Swipe).
  /// Bei false: _ensureA_SrsRefill darf nicht automatisch enrollen (S0=total, S1-S5=0).
  /// Wird beim ersten echten Swipe auf true gesetzt.
  final bool hasStartedAdaptiveRound;

  /// A-SRS: Nächsten Refill einmalig überspringen (nach erstem S0→S1 Enroll).
  final bool skipNextAdaptiveRefill;

  const LearnModeState({
    this.categoryId = '',
    this.title = '',

    this.loading = false,
    this.categories = const [],
    this.selectedCategoryIndex = 0,

    this.stages = const [0, 0, 0, 0, 0, 0],
    this.deckStages = const [0, 0, 0, 0, 0, 0],
    this.totalWordsInCategory = 0,
    this.activeStage = 0,
    this.masteredCount = 0,

    this.wordQueue = const [],
    this.shuffledWordIds = const [],
    this.index = 0,

    this.showTranslation = false,

    this.running = false,
    this.timerActive = false,
    this.timerPaused = false,
    this.remainingMillis = 10000.0,
    this.timeLimit = 10,

    // Default: im Hybrid sollen H1/H2 direkt eine sinnvolle Anzeige haben,
    // selbst bevor SharedPreferences geladen sind.
    // (wird nach _loadHybridBudgetsIfNeeded() ggf. überschrieben)
    this.hybridStageRemainingSec = const [-1, 60 * 60, 90 * 60, -1, -1, -1],
    this.hybridStageFrozen = const [false, false, false, false, false, false],
    this.hybridSessionStarted = false,
    this.inLearnScreen = false,

    this.recentlySwiped = const [],
    this.cardsSwipedInSession = 0,
    this.hasLoadedReviews = false,
    this.isSubmitting = false,
    this.isSubmittingReview = false,
    this.emptyQueueHint,
    this.showFinalStartButton = false,
    this.finalPassActive = false,
    this.categoryMastered = false,
    this.categoryMasteredRestartReady = false,
    this.hasStartedAdaptiveRound = false,
    this.skipNextAdaptiveRefill = false,
  });

  factory LearnModeState.initial() => const LearnModeState();

  LearnModeState copyWith({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    List<int>? deckStages,
    int? totalWordsInCategory,
    int? activeStage,
    int? masteredCount,

    List<WordUserView>? wordQueue,
    List<String>? shuffledWordIds,
    int? index,

    bool? showTranslation,

    bool? running,
    bool? timerActive,
    bool? timerPaused,
    double? remainingMillis,
    int? timeLimit,

    List<int>? hybridStageRemainingSec,
    List<bool>? hybridStageFrozen,
    bool? hybridSessionStarted,
    bool? inLearnScreen,

    List<String>? recentlySwiped,
    int? cardsSwipedInSession,
    bool? hasLoadedReviews,
    bool? isSubmitting,
    bool? isSubmittingReview,
    String? emptyQueueHint,
    bool clearEmptyQueueHint = false,
    bool? showFinalStartButton,
    bool? finalPassActive,
    bool? categoryMastered,
    bool? categoryMasteredRestartReady,
    bool? hasStartedAdaptiveRound,
    bool? skipNextAdaptiveRefill,
  }) {
    return LearnModeState(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,

      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,

      stages: stages ?? this.stages,
      deckStages: deckStages ?? this.deckStages,
      totalWordsInCategory: totalWordsInCategory ?? this.totalWordsInCategory,
      activeStage: activeStage ?? this.activeStage,
      masteredCount: masteredCount ?? this.masteredCount,

      wordQueue: wordQueue ?? this.wordQueue,
      shuffledWordIds: shuffledWordIds ?? this.shuffledWordIds,
      index: index ?? this.index,

      showTranslation: showTranslation ?? this.showTranslation,

      running: running ?? this.running,
      timerActive: timerActive ?? this.timerActive,
      timerPaused: timerPaused ?? this.timerPaused,
      remainingMillis: remainingMillis ?? this.remainingMillis,
      timeLimit: timeLimit ?? this.timeLimit,

      hybridStageRemainingSec: hybridStageRemainingSec ?? this.hybridStageRemainingSec,
      hybridStageFrozen: hybridStageFrozen ?? this.hybridStageFrozen,
      hybridSessionStarted: hybridSessionStarted ?? this.hybridSessionStarted,
      inLearnScreen: inLearnScreen ?? this.inLearnScreen,

      recentlySwiped: recentlySwiped ?? this.recentlySwiped,
      cardsSwipedInSession: cardsSwipedInSession ?? this.cardsSwipedInSession,
      hasLoadedReviews: hasLoadedReviews ?? this.hasLoadedReviews,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      emptyQueueHint: clearEmptyQueueHint ? null : (emptyQueueHint ?? this.emptyQueueHint),
      showFinalStartButton: showFinalStartButton ?? this.showFinalStartButton,
      finalPassActive: finalPassActive ?? this.finalPassActive,
      categoryMastered: categoryMastered ?? this.categoryMastered,
      categoryMasteredRestartReady: categoryMasteredRestartReady ?? this.categoryMasteredRestartReady,
      hasStartedAdaptiveRound: hasStartedAdaptiveRound ?? this.hasStartedAdaptiveRound,
      skipNextAdaptiveRefill: skipNextAdaptiveRefill ?? this.skipNextAdaptiveRefill,
    );
  }
}

/// ---------- Provider ----------

final learnModeControllerProvider =
    NotifierProvider<LearnModeController, LearnModeState>(() {
  return LearnModeController();
});

/// ---------- Controller ----------

class LearnModeController extends Notifier<LearnModeState> {
  int _answerRunId = 0;
  int _progressRequestId = 0;

  @override
  LearnModeState build() {
    _didReset = false; // Reset-Flag zurücksetzen bei neuer Session
    ref.onDispose(() {
      _wordTimer?.cancel();
      _hybridBudgetTimer?.cancel();
    });
    return LearnModeState.initial();
  }

  String _hybridBudgetKey({
    required String userId,
    required String categoryId,
    required DateTime dayStartLocal,
    required int stage,
  }) {
    final y = dayStartLocal.year.toString().padLeft(4, '0');
    final m = dayStartLocal.month.toString().padLeft(2, '0');
    final d = dayStartLocal.day.toString().padLeft(2, '0');
    return 'hybrid_stage_budget_used_ms:$userId:$categoryId:$y$m$d:s$stage';
  }

  DateTime _localDayStart(DateTime now) => DateTime(now.year, now.month, now.day);

  Future<void> _loadHybridBudgetsIfNeeded() async {
    final srs = ref.read(srsModeControllerProvider).mode;
    if (srs != SrsSystem.hybrid) {
      // reset UI-only hybrid fields when leaving hybrid
      if (state.hybridStageRemainingSec.any((v) => v != -1) ||
          state.hybridStageFrozen.any((v) => v)) {
        state = state.copyWith(
          hybridStageRemainingSec: const [-1, -1, -1, -1, -1, -1],
          hybridStageFrozen: const [false, false, false, false, false, false],
          hybridSessionStarted: false,
        );
      }
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    if (state.categoryId.isEmpty) return;

    final now = DateTime.now();
    final dayStart = _localDayStart(now);
    if (_hybridBudgetDayStartLocal == dayStart && _hybridUsedMsByStage.isNotEmpty) {
      return; // already loaded for today
    }

    _hybridBudgetDayStartLocal = dayStart;
    _hybridUsedMsByStage.clear();
    _hybridPersistAccumulatorMs = 0;
    _hybridUiAccumulatorMs = 0;

    final prefs = await SharedPreferences.getInstance();
    for (final stage in _hybridDailyBudgetSecByStage.keys) {
      final key = _hybridBudgetKey(
        userId: userId,
        categoryId: state.categoryId,
        dayStartLocal: dayStart,
        stage: stage,
      );
      _hybridUsedMsByStage[stage] = prefs.getInt(key) ?? 0;
    }

    _recomputeHybridBudgetState(now: now, forceEmit: true);
  }

  void _recomputeHybridBudgetState({required DateTime now, bool forceEmit = false}) {
    if (ref.read(srsModeControllerProvider).mode != SrsSystem.hybrid) return;

    final dayStart = _localDayStart(now);
    if (_hybridBudgetDayStartLocal == null || _hybridBudgetDayStartLocal != dayStart) {
      _hybridBudgetDayStartLocal = dayStart;
      _hybridUsedMsByStage.clear();
    }

    final remaining = List<int>.filled(6, -1);
    final frozen = List<bool>.filled(6, false);

    for (final entry in _hybridDailyBudgetSecByStage.entries) {
      final stage = entry.key;
      final budgetSec = entry.value;
      final usedMs = _hybridUsedMsByStage[stage] ?? 0;
      final usedSec = (usedMs / 1000).floor();
      final rem = (budgetSec - usedSec).clamp(0, budgetSec);
      remaining[stage] = rem;
      frozen[stage] = rem == 0;
    }

    if (forceEmit) {
      state = state.copyWith(hybridStageRemainingSec: remaining, hybridStageFrozen: frozen);
      return;
    }

    if (remaining.toString() != state.hybridStageRemainingSec.toString() ||
        frozen.toString() != state.hybridStageFrozen.toString()) {
      state = state.copyWith(hybridStageRemainingSec: remaining, hybridStageFrozen: frozen);
    }
  }

  Future<void> _persistHybridBudgetsMaybe({
    required String userId,
    required String categoryId,
  }) async {
    if (ref.read(srsModeControllerProvider).mode != SrsSystem.hybrid) return;
    if (_hybridBudgetDayStartLocal == null) return;
    if (_hybridPersistAccumulatorMs < 1000) return; // write max ~1/sec
    _hybridPersistAccumulatorMs = 0;

    final prefs = await SharedPreferences.getInstance();
    for (final stage in _hybridDailyBudgetSecByStage.keys) {
      final used = _hybridUsedMsByStage[stage] ?? 0;
      final key = _hybridBudgetKey(
        userId: userId,
        categoryId: categoryId,
        dayStartLocal: _hybridBudgetDayStartLocal!,
        stage: stage,
      );
      await prefs.setInt(key, used);
    }
  }

  Timer? _wordTimer;
  SfxService? _sfx;
  Timer? _hybridBudgetTimer;
  DateTime? _hybridLastInteractionAt;
  
  // ---- Hybrid Stage Daily Budgets (Client-seitig) ----
  // Ziel: z.B. H1 max 60min/Tag, H2 max 90min/Tag. Wenn Budget = 0 => Stage bis morgen einfrieren.
  static const Map<int, int> _hybridDailyBudgetSecByStage = {
    1: 60 * 60,
    2: 90 * 60,
    // 3..5: aktuell kein Tagesbudget (werden eher durch Zeitlocks/Intervals geregelt)
  };
  DateTime? _hybridBudgetDayStartLocal; // lokaler "Tag" (00:00)
  final Map<int, int> _hybridUsedMsByStage = {}; // stage -> usedMs today
  int _hybridPersistAccumulatorMs = 0;
  int _hybridUiAccumulatorMs = 0;
  
  // ⬇️ NEU: QuickSets-Index für Filter-Mapping
  int? _quickSetsIndex;
  final _repo = SupabaseWordRepository();

  // ---- SRS-Einstellungen und Konstanten ----
  
  // Stage-Daten für Switches (s0..s5)
  int _goalPerStage = 100;
  
  // Kartenbasiertes Wiederholungssystem
  static const int _newCardsBeforeReview = 4; // Nach X neuen Karten → Wiederholungen
  static const double _reviewRatio = 0.8; // 80% der neuen Karten wiederholen (anpassbar)
  
  // SRS Stats für adaptive Konfiguration
  double _rollingAccuracy = 0.8; // Rolling accuracy (0..1)
  double _avgSwipeMs = 3000.0; // Durchschnittliche Antwortzeit in ms
  int _recentTimeouts = 0; // Anzahl der letzten Timeouts
  
  // --- S0 Cooldown: wie viele andere Karten MINDESTENS dazwischen liegen müssen
  static const int _s0MinOthers = 3; // ← gern auf 5 erhöhen, wenn gewünscht
  final Map<String, int> _cooldown = {}; // wordId -> verbleibende "andere Karten"
  
  // ✅ A-SRS Stage-Limits (kein S0 mehr im Deck)
  static const Map<int, int> _stageLimits = {
    1: 10, // S1: 10 Karten
    2: 5,  // S2: 5 Karten
    3: 3,  // S3: 3 Karten
    4: 1,  // S4: 1 Karte
    5: 1,  // S5: 1 Karte
  };
  
  // ✅ FIX: Lokale Stage-Queues für Word-ID-Verwaltung
  final List<List<String>> _stageQueues = List.generate(6, (_) => <String>[]);
  
  // Guard gegen Doppelausführung beim Reset
  bool _isResetRunning = false;
  bool _didReset = false;

  // Refill-Lock: verhindert parallele Refill-Ausführung
  bool _isAdaptiveRefillRunning = false;
  static const int _refillTargetMinCards = 20; // Refill wenn enrolled < target
  
  // Getter für Reset-Status (für Navigation Result)
  bool get didReset => _didReset;
  
  // --- Queue-Steuerung: wie viele Karten vorn „gesteuert" werden

  String get _currentCatId {
    final cats = state.categories;
    final i = state.selectedCategoryIndex;
    if (cats.isEmpty || i >= cats.length) return state.categoryId;
    return cats[i].id;
  }

  String get _stageStoreKey => 'learn_stages_$_currentCatId';

  // ⬇️ NEU: Prüfe ob virtuelle Kategorie (z.B. QuickSets)
  bool _isVirtualCategory(String catId) {
    return catId == 'quicksets' || catId.isEmpty;
  }
  
  // ⬇️ NEU: Helper-Funktion für QuickSets-Filter (identisch zum Screen)
  WordListFilter _quicksetsFilterFor(int idx) {
    switch (idx) {
      case 0: return const WordListFilter(WordFilterKind.query, '');
      case 1: return const WordListFilter(WordFilterKind.about, 'my-words');
      case 2: return const WordListFilter(WordFilterKind.about, 'favorites');
      case 3: return const WordListFilter(WordFilterKind.about, 'known-words');
      case 4: return const WordListFilter(WordFilterKind.about, 'my-mix');
      default: return const WordListFilter(WordFilterKind.query, '');
    }
  }

  // ---- Public API (Screen ruft das auf) ----

  Future<void> init({
    required String categoryId,
    required String title,
    int? initialQuickSetsIndex,
  }) async {
    print('🚀 init() aufgerufen: categoryId=$categoryId, title=$title, initialQuickSetsIndex=$initialQuickSetsIndex');
    
    // 1) Progress holen (die echten Stages, nicht die Learn-Default-Nullen)
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    final progAsync = ref.read(categoryProgressProvider((catId: categoryId, srs: srsSystem)));
    final prog = progAsync.valueOrNull;
    
    final progStages = prog?.stages;
    final progTotal = prog?.total ?? 0;
    
    print('📊 init() Progress geladen: stages=$progStages, total=$progTotal');
    
    // 2) Learn-State NICHT mit [0,0,0,0,0,0] initialisieren,
    //    sondern mit den echten Stages (falls vorhanden)
    //    Deck leeren bei Kategorie-Eintritt, damit _loadWords nicht skippt (kein altes Deck von anderer Kategorie)
    _set(
      categoryId: categoryId,
      title: title,
      stages: progStages ?? const [0, 0, 0, 0, 0, 0],
      totalWordsInCategory: progStages != null ? progTotal : 0,
      wordQueue: const [],
      shuffledWordIds: const [],
      index: 0,
      deckStages: const [0, 0, 0, 0, 0, 0],
    );
    // LearnModeScreen ist jetzt aktiv.
    state = state.copyWith(inLearnScreen: true);
    
    // 2b) Single-Modus: singleSessionCountsProvider sofort mit Stage-Wert aus Category Detail initialisieren
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single && progStages != null && !_isVirtualCategory(categoryId)) {
      final stages = progStages;
      final singleStage = ref.read(singleStageProvider).clamp(1, 5);
      final src = singleStage < stages.length ? stages[singleStage] : 0;
      ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(src, 0, 0);
      print('📊 init() Single-Modus: src=$src aus Category Detail (stage $singleStage)');
    }
    
    _quickSetsIndex = initialQuickSetsIndex;
    _sfx = ref.read(sfxProvider);
    
    // 3) Kategorien und Wörter laden
    await _loadCategories();
    
    // 4) Erst jetzt ist Learn-Mode wirklich aktiv (Stages sind gesetzt)
    print('🚀 init() abgeschlossen, state.shuffledWordIds.length=${state.shuffledWordIds.length}, stages=${state.stages}');
  }

  /// UI-Hook: LearnModeScreen mount/unmount.
  void setInLearnScreen(bool value) {
    if (state.inLearnScreen == value) return;
    state = state.copyWith(inLearnScreen: value);
  }
  
  // ⬇️ NEU: Wörter für QuickSets mit Filter laden
  Future<void> loadWordsForQuickSets(int index) async {
    _quickSetsIndex = index;
    await _loadWords();
  }

  void setSubmitting(bool value) {
    _set(isSubmitting: value);
  }

  void onSwipeRight() {
    print('✅ UI SwipeRight angekommen | paused=${state.timerPaused} active=${state.timerActive} running=${state.running}');
    // _canInteract() Prüfung entfernt: gesturesEnabled in SwipeableWordCard prüft bereits
    _sfx?.correct();
    _markHybridInteraction();
    _handleAnswer(correct: true);
  }

  void onSwipeLeft() {
    print('✅ UI SwipeLeft angekommen | paused=${state.timerPaused} active=${state.timerActive} running=${state.running}');
    // _canInteract() Prüfung entfernt: gesturesEnabled in SwipeableWordCard prüft bereits
    _sfx?.wrong();
    _markHybridInteraction();
    _handleAnswer(correct: false);
  }

  void _markHybridInteraction() {
    if (ref.read(srsModeControllerProvider).mode != SrsSystem.hybrid) return;
    _hybridLastInteractionAt = DateTime.now();
    // ✅ ab erstem Swipe zählt Hybrid "Übungszeit" (auch wenn man danach nur liest)
    if (!state.hybridSessionStarted) {
      state = state.copyWith(hybridSessionStarted: true);
    }
    // budgets ggf. erst jetzt laden (falls Swipe schneller als Stage-Load war)
    unawaited(_loadHybridBudgetsIfNeeded());
    _ensureHybridBudgetTickerRunning();
  }

  void _ensureHybridBudgetTickerRunning() {
    if (_hybridBudgetTimer != null) return;
    _hybridBudgetTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (ref.read(srsModeControllerProvider).mode != SrsSystem.hybrid) return;
      if (state.categoryId.isEmpty) return;
      if (!state.hybridSessionStarted) return;

      // ✅ Budget zählt als "Session-Zeit" weiter, auch wenn man nur liest/anschaut.
      _tickHybridStageBudget(deltaMs: 1000);
    });
  }
  
  void toggleFlip() {
    if (!_canInteract()) return;
    _set(showTranslation: !state.showTranslation);
  }
  
  /// Setzt showTranslation explizit (z.B. nach Wischen zurück zur Hauptsprache)
  void setShowTranslation(bool value) {
    _set(showTranslation: value);
  }
  
  /// Prüft, ob Interaktionen erlaubt sind (nicht pausiert)
  bool _canInteract() {
    return !state.timerPaused;
  }

  void startTimer() {
    print('🎮 startTimer() aufgerufen');
    _startWordTimer(forceActive: true);
  }
  void pauseTimer() => _set(timerPaused: true, running: false);
  void resumeTimer() {
    if (!state.timerActive) return; // nur wenn Timer aktiv ist
    _set(timerPaused: false, running: true);
  }
  void cancelTimer() => _stopTimer();

  Future<void> selectCategoryIndex(int idx) async {
    if (idx < 0 || idx >= state.categories.length) {
      print('⚠️ selectCategoryIndex: idx out of range: idx=$idx len=${state.categories.length}');
      return;
    }

    final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
        ? state.wordQueue[state.index].srsStage
        : -1;
    print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (new category) at=${StackTrace.current}');
    print('🧨 INDEX-RESET auf 0 in selectCategoryIndex: prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');

    final nextCat = state.categories[idx];

    // Beim Kategorie-Wechsel müssen wir *categoryId* im State aktualisieren.
    // Sonst bleiben Timer/Budgets/ASRS-RPCs/Persistence auf der alten Kategorie hängen,
    // und im A‑SRS greift außerdem der "Deck bereits geladen" Guard.
    _stopTimer();
    _hybridBudgetTimer?.cancel();
    _hybridBudgetTimer = null;
    _hybridBudgetDayStartLocal = null;
    _hybridUsedMsByStage.clear();
    _hybridPersistAccumulatorMs = 0;
    _hybridUiAccumulatorMs = 0;
    _hybridLastInteractionAt = null;
    _cooldown.clear();

    _set(
      selectedCategoryIndex: idx,
      categoryId: nextCat.id,
      title: nextCat.name,
      // Deck/Queue clearen, damit _loadWords() wirklich neu lädt (v.a. A‑SRS lock).
      wordQueue: const [],
      shuffledWordIds: const [],
      index: 0,
      deckStages: const [0, 0, 0, 0, 0, 0],
    );

    // Hybrid UI-State reset (nicht über _set, da _set diese Felder bewusst nicht setzt)
    state = state.copyWith(
      hybridSessionStarted: false,
      hybridStageFrozen: const [false, false, false, false, false, false],
      hybridStageRemainingSec: const [-1, 60 * 60, 90 * 60, -1, -1, -1],
    );
    _resetCardBasedSystem();
    await _loadStageData();
    await _loadWords();
  }

  Future<void> performReset() async {
    try {
      // Single-Session Reset falls im Single-Modus
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      await resetSingleSession();
    } else {
      await _performReset();
      }
    } catch (e, st) {
      print('⚠️ performReset failed: $e');
      print(st);
    }
  }

  /// Nach Feuerwerk: Restart-Button freischalten
  void setCategoryMasteredRestartReady() {
    _set(categoryMasteredRestartReady: true);
  }

  /// A-SRS: Kategorie zurücksetzen (Restart nach Kategorie-Abschluss)
  Future<void> resetAdaptiveCategory() async {
    final catId = state.categoryId;
    if (catId.isEmpty) return;

    try {
      await _repo.resetAdaptiveCategoryProgress(catId);

      _set(
        categoryMastered: false,
        categoryMasteredRestartReady: false,
        showFinalStartButton: false,
        finalPassActive: false,
        hasStartedAdaptiveRound: false,
        skipNextAdaptiveRefill: false,
        wordQueue: const [],
        shuffledWordIds: const [],
        index: 0,
      );

      await _loadWords(forceReload: true);
      ResetEvent.notifyReset(catId);
    } catch (e, st) {
      print('⚠️ resetAdaptiveCategory failed: $e');
      print(st);
    }
  }

  /// A-SRS: Finale Runde starten (Button "Final Round")
  Future<void> startFinalPass() async {
    final catId = _currentCatId;
    if (catId.isEmpty) return;
    try {
      // UI-State hart zurücksetzen, bevor _loadWords
      _set(
        finalPassActive: true,
        showFinalStartButton: false,
        shuffledWordIds: const [],
        wordQueue: const [],
        index: 0,
        isSubmitting: false,
        isSubmittingReview: false,
        timerPaused: false,
        categoryMasteredRestartReady: false,
      );

      await _repo.startAdaptiveFinalPass(categoryId: catId);
      await _loadWords(forceReload: true);
      print('🔥 startFinalPass DONE | finalPassActive=${state.finalPassActive} | '
          'queue=${state.wordQueue.length} | index=${state.index}');
    } catch (e, st) {
      print('⚠️ startFinalPass failed: $e');
      print(st);
    }
  }

  // ---- Loading ----

  Future<void> _loadCategories() async {
    _set(loading: true);
    try {
      // ⬇️ NEU: Guard für virtuelle Kategorien
      if (_isVirtualCategory(state.categoryId)) {
        // Bei virtuellen Kategorien keine echten DB-Kategorien laden
        // Kategorien bleiben leer (Custom Wheel wird vom Screen übergeben)
        _set(categories: const [], selectedCategoryIndex: 0);
        await _loadStageData();
        await _loadWords();
      } else {
        final cats = await fetchAllCategories();
        final sel = _findInitialIndex(cats);
        _set(categories: cats, selectedCategoryIndex: sel);
        await _loadStageData();
        await _loadWords();
      }
    } finally {
      _set(loading: false);
    }
  }

  Future<void> _persistStageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stageStoreKey, state.stages.join(','));
    } catch (_) {}
  }

  Future<void> _loadStageData() async {
    final catId = _currentCatId;
    
    // ⬇️ NEU: Guard für virtuelle Kategorien
    if (_isVirtualCategory(catId)) {
      // Bei virtuellen Kategorien keine DB-RPC aufrufen
      // Defensive Defaults setzen
      _set(
        stages: const [0, 0, 0, 0, 0, 0],
        totalWordsInCategory: 0,
      );
      return;
    }

    bool hasLocal = false;

    try {
      // 1) Schnell lokal
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_stageStoreKey);
      if (stored != null) {
        try {
          final parsed = stored.split(',').map(int.parse).toList();
          if (parsed.length == 6) {
            _setStages(parsed);
            hasLocal = true;
          }
        } catch (_) {}
      }

      // 2) Backend
      // ✅ Ensure Progress-Rows existieren (beim ersten Öffnen)
      await _repo.ensureWordProgressForCategory(
        catId,
        srsSystem: ref.read(srsModeControllerProvider).mode,
      );

      final progressReqId = ++_progressRequestId;
      print('📡 progress fetch START reqId=$progressReqId');
      final prog = await _repo.fetchCategoryProgress(
        catId,
        srsSystem: ref.read(srsModeControllerProvider).mode,
      );
      print('📡 progress fetch DONE reqId=$progressReqId stages=${prog.stages}');
      if (progressReqId != _progressRequestId) {
        print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
        return;
      }
      
      // ⬇️ A-SRS: Server-Stages direkt verwenden (Stage 0 ist bereits korrekt)
      // ⬇️ Hybrid: Stage 0 = vocabsTotal - learnedWords (Legacy-Korrektur)
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      var stagesToSet = prog.stages;
      int vocabsTotal = prog.total;
      
      if (srsSystem == SrsSystem.hybrid) {
        final sb = Supabase.instance.client;
        vocabsTotal = await sb.rpc('fn_category_word_count', params: {'p_category_id': catId}) as int? ?? 0;
        final learnedWords = prog.stages.skip(1).fold<int>(0, (a, b) => a + b);
        final correctedStage0 = (vocabsTotal - learnedWords).clamp(0, 1 << 30);
        stagesToSet = [correctedStage0, ...prog.stages.skip(1)];
      }
      
      if (!hasLocal) {
        _setStages(stagesToSet);
      } else {
        if (srsSystem == SrsSystem.hybrid) {
          final learnedWords = state.stages.skip(1).fold<int>(0, (a, b) => a + b);
          final correctedStage0 = (vocabsTotal - learnedWords).clamp(0, 1 << 30);
          final correctedStages = [correctedStage0, ...state.stages.skip(1)];
          _setStages(correctedStages);
        }
      }
      
      // totalWordsInCategory sollte vocabsTotal sein (nicht prog.total)
      _set(totalWordsInCategory: vocabsTotal);

      // 3) Lokal sichern
      await _persistStageData();

    } catch (_) {
      if (state.stages.every((s) => s == 0)) {
        _setStages(const [0, 0, 0, 0, 0, 0]);
      }
    }
  }

  /// A-SRS Refill: Enrolliert neue Wörter aus S0 nach S1
  /// Gibt den Refill-Counter zurück
  /// [categoryId] optional – wenn nicht gesetzt, wird _currentCatId verwendet (wichtig bei Kategorie-Wechsel im Wheel)
  Future<int> _ensureA_SrsRefill({String? categoryId}) async {
    if (state.skipNextAdaptiveRefill) {
      print('⛔ Refill einmalig übersprungen: nach Reset / frische Runde');
      _set(skipNextAdaptiveRefill: false);
      return 0;
    }
    if (_isAdaptiveRefillRunning) {
      print('⛔ Refill übersprungen: läuft bereits');
      return 0;
    }

    final srsSystem = ref.read(srsModeControllerProvider).mode;
    if (srsSystem != SrsSystem.adaptive) return 0;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('⚠️ _ensureA_SrsRefill: Kein User eingeloggt');
      return 0;
    }

    final catId = categoryId ?? _currentCatId;
    if (catId.isEmpty || _isVirtualCategory(catId)) return 0;

    // Phase 1: Refill nur anhand S1-S4 prüfen.
    // S5 zählt NICHT als aktive Phase-1-Karte.
    final prog = await _repo.fetchCategoryProgress(
      catId,
      srsSystem: SrsSystem.adaptive,
    );

    final s0Count = prog.stages.length >= 1 ? prog.stages[0] : 0;
    final activePhase1Cards = prog.stages.length >= 5
        ? prog.stages.sublist(1, 5).fold<int>(0, (s, n) => s + n) // S1-S4
        : 0;
    final total = prog.total;

    // 🛑 Frische Runde – nur vor dem ersten Swipe blockieren (nicht danach)
    if (!state.hasStartedAdaptiveRound &&
        s0Count == total &&
        activePhase1Cards == 0) {
      print('⛔ Refill übersprungen: frische Runde (noch kein Swipe)');
      return 0;
    }

    // Nur dann abbrechen, wenn Phase 1 bereits voll ist.
    // Sobald S0 noch Karten hat und S1-S4 unter Ziel liegen, weiter refillen.
    if (activePhase1Cards >= _refillTargetMinCards || s0Count <= 0) {
      print(
        '⛔ Refill übersprungen: s0=$s0Count, activePhase1Cards=$activePhase1Cards >= target=$_refillTargetMinCards',
      );
      return 0;
    }

    _isAdaptiveRefillRunning = true;
    try {
      final refillCounter = await _repo.nextRefillCounter(
        userId: userId,
        categoryId: catId,
        mode: 'adaptive',
      );

      await _repo.refillAdaptiveEnroll(
        userId: userId,
        categoryId: catId,
      );

      final progAfter = await _repo.fetchCategoryProgress(catId, srsSystem: SrsSystem.adaptive);
      final enrolledAfter = progAfter.stages.length >= 6
          ? progAfter.stages.sublist(1, 6).fold<int>(0, (s, n) => s + n)
          : 0;

      print(
        '✅ A-SRS Refill: category=$catId, refillCounter=$refillCounter, enrolled=$enrolledAfter (vorher: activePhase1=$activePhase1Cards, s0=$s0Count)',
      );

      return refillCounter;
    } catch (e, st) {
      print('⚠️ A-SRS Refill fehlgeschlagen: $e');
      print('⚠️ Stack: $st');
      return 0;
    } finally {
      _isAdaptiveRefillRunning = false;
    }
  }

  Future<void> _loadWords({bool forceReload = false}) async {
    print('🚀 _loadWords() aufgerufen für catId: ${_currentCatId}');
    final srs = ref.read(srsModeControllerProvider).mode;
    print('🟦 _loadWords START | srs=$srs cat=${_currentCatId}');

    // ✅ Hybrid: Tagesbudgets laden (für Timer unter den Switches)
    if (srs == SrsSystem.hybrid) {
      await _loadHybridBudgetsIfNeeded();
      // Timer soll laufen, sobald der User anfängt zu üben (auch ohne Play)
      _ensureHybridBudgetTickerRunning();
    }
    
    // ✅ Schritt 1: A-SRS frühzeitig "locken" – _loadWords darf NICHT nochmal laufen (außer forceReload)
    // WICHTIG: Nur skippen, wenn das geladene Deck zur aktuellen Kategorie gehört (Kategorienwechsel!)
    if (!forceReload &&
        srs == SrsSystem.adaptive &&
        state.wordQueue.isNotEmpty &&
        state.categoryId == _currentCatId) {
      print('🛑 _loadWords SKIP: A-SRS Deck bereits geladen (cat=${state.categoryId})');
      return;
    }
    
    // ✅ A-SRS Bootstrap: Wird jetzt von ASrsRefillEngine verwaltet
    // (Bootstrap-Logik wurde aus Repository entfernt)
    
    // ✅ A-SRS Refill: IMMER vor Deck-Build ausführen (Enroll + Refill-Counter)
    // Nutzt _currentCatId, damit bei Kategorie-Wechsel im Wheel die richtige Kategorie geseeded wird
    int refillCounter = 0;
    final catId = _currentCatId;
    if (srs == SrsSystem.adaptive && !_isVirtualCategory(catId)) {
      print('A2 before _ensureA_SrsRefill');
      try {
        refillCounter = await _ensureA_SrsRefill(categoryId: catId);
        print('A2 ok: refillCounter=$refillCounter');
      } catch (e, st) {
        print('A2 FAIL: $e');
        print(st);
        rethrow;
      }
    }
    try {
      
      // ⬇️ NEU: Guard für virtuelle Kategorien mit Filter-Logik
      if (_isVirtualCategory(catId)) {
        // Bei virtuellen Kategorien (QuickSets) verwende fetchByFilter
        if (_quickSetsIndex == null) {
          final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
              ? state.wordQueue[state.index].srsStage
              : -1;
          print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (no quickSetsIndex) at=${StackTrace.current}');
          print('🧨 INDEX-RESET auf 0 in _loadWords (no quickSetsIndex): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }
        
        // Filter basierend auf Wheel-Index erstellen
        final filter = _quicksetsFilterFor(_quickSetsIndex!);
        final wordsList = await _repo.fetchByFilter(filter, limit: 10000);
        
        if (wordsList == null || wordsList.isEmpty) {
          final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
              ? state.wordQueue[state.index].srsStage
              : -1;
          print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (empty wordsList) at=${StackTrace.current}');
          print('🧨 INDEX-RESET auf 0 in _loadWords (empty wordsList): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }
        
        // Word-Liste zu WordUserView konvertieren
        // Nutze srsStage aus Word (wurde bereits aus v_words_user gemappt)
        // Hinweis: Word hat kein level-Feld direkt, also null setzen
        final wordViews = wordsList.map((w) => WordUserView(
          id: w.id,
          text: w.text,
          translation: w.translation,
          level: null, // Word hat kein level-Feld
          srsStage: w.srsStage, // Nutze srsStage aus Word
          streak: 0, // QuickSets hat keinen Streak-Tracking
        )).toList();
        
        // Client-seitige Filterung – S0-Lock berücksichtigen
        final allowed = ref.read(allowedStagesProvider);
        final s0Locked = ref.read(s0LockedProvider(_currentCatId)).maybeWhen(data: (v) => v, orElse: () => false);
        final allowedForced = s0Locked ? allowed.where((s) => s != 0).toSet() : {...allowed, 0};
        final filteredWords = wordViews.where((w) => allowedForced.contains(w.srsStage)).toList();
        
        if (filteredWords.isEmpty) {
          final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
              ? state.wordQueue[state.index].srsStage
              : -1;
          print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (filteredWords empty) at=${StackTrace.current}');
          print('🧨 INDEX-RESET auf 0 in _loadWords (filteredWords empty, QuickSets): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }
        
        final queue = _buildQueueDueFirst(filteredWords);
        final ids = queue.map((w) => w.id).toList();
        final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
            ? state.wordQueue[state.index].srsStage
            : -1;
        final nextStage = queue.isNotEmpty ? queue[0].srsStage : -1;
        print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (Stage=$nextStage, loadWords) at=${StackTrace.current}');
        print('🧨 INDEX-RESET auf 0 in _loadWords (normal): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
        _set(wordQueue: queue, shuffledWordIds: ids, index: 0);
        return;
      }
      
      final mode = ref.read(levelSelectionProvider);
      
      // WICHTIG: singleStage nur setzen, wenn Mode == single
      final int? singleStage = (mode == LevelSelectionMode.single)
          ? ref.read(singleStageProvider)
          : null;
      
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      
      // ✅ Ensure Progress-Rows existieren (beim ersten Öffnen, vor Queue-Laden)
      print('A1 before ensureWordProgressForCategory');
      try {
        await _repo.ensureWordProgressForCategory(
          catId,
          srsSystem: srsSystem,
        );
        print('A1 ok');
      } catch (e, st) {
        print('A1 FAIL: $e');
        print(st);
        rethrow;
      }
      
      if (srsSystem == SrsSystem.adaptive) {
        // ✅ A-SRS (Adaptive): IMMER Server-Queue laden (Contract), NICHT komplette Kategorie.
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          print('⚠️ _loadWords: Kein User eingeloggt für A-SRS');
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }

        final progressReqId = ++_progressRequestId;
        print('📡 progress fetch START reqId=$progressReqId');
        final p = await _repo.fetchCategoryProgress(catId, srsSystem: SrsSystem.adaptive);
        print('📡 progress fetch DONE reqId=$progressReqId stages=${p.stages}');
        if (progressReqId != _progressRequestId) {
          print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
          return;
        }
        final stages = p.stages;
        final hasOpenA1ToA4 = stages.length >= 5 &&
            (stages[1] > 0 || stages[2] > 0 || stages[3] > 0 || stages[4] > 0);
        final hasStage5 = stages.length > 5 && stages[5] > 0;

        // ✅ Stages sofort setzen (z.B. nach "Neue Runde" – Zahlen direkt in S0 anzeigen)
        _setStages(stages);
        _set(totalWordsInCategory: p.total);

        if (!hasOpenA1ToA4 && hasStage5 && !state.finalPassActive) {
          print('🏁 _loadWords: Nur S5 übrig → Final Round Button, kein Auto-Deck');
          _set(
            shuffledWordIds: const [],
            index: 0,
            showFinalStartButton: true,
            wordQueue: const [],
            loading: false,
          );
          return;
        }

        var queue = <WordUserView>[];
        print('A3 before fetchAdaptiveQueue');
        try {
          // fn_fetch_adaptive_queue: Phase 1 (S1-S4) oder Phase 2 (nur S5) – Server-seitig
          queue = await _repo.fetchAdaptiveQueue(
            userId: userId,
            categoryId: catId,
            limit: 80,
          );
          // Normale Phase: A5 NICHT laden (nur A1–A4)
          if (!state.finalPassActive) {
            queue = queue.where((w) => (w.srsStage ?? 0) < 5).toList();
          }
          // Deck leer + S5>0 → Final Round Button (nicht automatisch S5 starten)
          if (queue.isEmpty && p.stages.length >= 6 && p.stages[5] > 0) {
            _set(
              showFinalStartButton: true,
              wordQueue: const [],
              shuffledWordIds: const [],
              index: 0,
              loading: false,
            );
            return;
          }
          print('A3 ok: queue.length=${queue.length}');
        } catch (e, st) {
          print('A3 FAIL: $e');
          print(st);
          rethrow;
        }
        int rpcFirst = queue.length;
        int enrolledCount = 0;
        int rpcSecond = 0;
        int bootstrapCount = 0;
        
        // ✅ Fallback: Queue leer (z.B. nach Reset) → fn_enroll_user_category_mode seeden, dann erneut laden
        if (queue.isEmpty && !_isVirtualCategory(catId)) {
          print('A4 before fallback enroll');
          try {
            // ✅ Alle mastered: NUR wenn masteredCount >= total (nicht bei Reset: stages=[0,0,0,0,0,0] + queue leer)
            final progressReqId = ++_progressRequestId;
            print('📡 progress fetch START reqId=$progressReqId');
            final pCheck = await _repo.fetchCategoryProgress(catId, srsSystem: SrsSystem.adaptive);
            print('📡 progress fetch DONE reqId=$progressReqId stages=${pCheck.stages}');
            if (progressReqId != _progressRequestId) {
              print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
              // Stale: mastered-Check überspringen, direkt enroll
            } else {
              final totalWords = pCheck.total;
              final masteredCount = await ref.read(learnedInStage5Provider(catId).future).catchError((_) => 0);
              if (masteredCount >= totalWords && totalWords > 0) {
                _set(
                  categoryMastered: true,
                  categoryMasteredRestartReady: true,
                  showFinalStartButton: false,
                  wordQueue: const [],
                  shuffledWordIds: const [],
                  index: 0,
                  masteredCount: masteredCount,
                  loading: false,
                );
                print('✅ A-SRS: Alle $totalWords Wörter mastered (masteredCount=$masteredCount) → Restart-UI');
                return;
              }
            }

            enrolledCount = await Supabase.instance.client.rpc('fn_enroll_user_category_mode', params: {
              'p_category_id': catId,
              'p_mode': 'adaptive',
              'p_user': userId,
            }) as int? ?? 0;
            // Nach Enroll: erneut laden. Bootstrap NUR wenn leer (kein anderer Codepfad lädt Bootstrap).
            final adaptiveQueue = await _repo.fetchAdaptiveQueue(userId: userId, categoryId: catId, limit: 80);
            final filtered = !state.finalPassActive
                ? adaptiveQueue.where((w) => (w.srsStage ?? 0) < 5).toList()
                : adaptiveQueue;
            if (filtered.isNotEmpty) {
              queue = filtered;
            } else {
              final isFinalRound = state.finalPassActive || state.activeStage == 5;
              if (isFinalRound) {
                queue = [];
              } else {
                queue = await _repo.fetchAdaptiveQueueBootstrap(
                  userId: userId,
                  categoryId: catId,
                  limit: 80,
                );
                if (!state.finalPassActive) {
                  queue = queue.where((w) => (w.srsStage ?? 0) < 5).toList();
                }
                bootstrapCount = queue.length;
              }
            }
            rpcSecond = queue.length;
            // Nach Fallback: Deck leer + S5>0 → Final Round Button
            if (queue.isEmpty && pCheck.stages.length >= 6 && pCheck.stages[5] > 0) {
              _set(
                showFinalStartButton: true,
                wordQueue: const [],
                shuffledWordIds: const [],
                index: 0,
                loading: false,
              );
              return;
            }
            print('A4 ok');
          } catch (e, st) {
            print('A4 FAIL: $e');
            print(st);
            rethrow;
          }
        }
        
        // ✅ S0-Lock: Wenn Schloss aktiv (0 Sperre), Stage-0-Karten aus Queue filtern
        final s0Locked = ref.read(s0LockedProvider(catId)).maybeWhen(data: (v) => v, orElse: () => false);
        // if (s0Locked) {
        //   queue = queue.where((w) => w.srsStage != 0).toList();
        // }
        
        // ⚠️ Kein späterer Bootstrap-Aufruf: fetchAdaptiveQueueBootstrap läuft NUR
        // wenn queue.isEmpty (siehe Fallback-Enroll-Block oben).

        // Phase 1: S5 darf NICHT im normalen Deck landen.
        // Erst nach Klick auf "Final Round" dürfen S5-Wörter aktiv gespielt werden.
        final isFinalRoundActive = state.finalPassActive;

        final filteredQueue = isFinalRoundActive
            ? queue
            : queue.where((w) => (w.srsStage ?? 0) < 5).toList();

        final deckStages = _countStages(filteredQueue);
        final shuffledIds = filteredQueue.map((w) => w.id).toList();

        if (filteredQueue.isEmpty || shuffledIds.isEmpty) {
          _set(
            wordQueue: const [],
            shuffledWordIds: const [],
            index: 0,
            deckStages: const [0, 0, 0, 0, 0, 0],
            clearEmptyQueueHint: true,
          );
          return;
        }

        _set(
          wordQueue: filteredQueue,
          shuffledWordIds: shuffledIds,
          index: 0,
          deckStages: deckStages,
          clearEmptyQueueHint: true,
        );

        print('✅ A-SRS: Server-Queue geladen | queue.length=${filteredQueue.length} | deckStages=$deckStages');
        return; // ✅ A-SRS: Früher Return, kein weiterer Deck-Build
      } else {
        // T-SRS/Hybrid: Normaler Flow
        print('🧪 RPC: fetch_learn_queue_for_mode (T-SRS/Hybrid) catId=$catId, mode=$mode, singleStage=$singleStage');
      }
      final words = await _repo.fetchLearnQueueForMode(
        catId,
        mode: mode,
        srsSystem: srsSystem,
        singleStage: singleStage,
      );
      // ✅ Log: Nach fetchLearnQueueForMode (words enthält WordUserView-Objekte)
      // Die IDs werden später aus words extrahiert (siehe finalIds bei Zeile ~639)
      print('🟦 _loadWords QUEUE ids.length=${words.length} first=${words.isNotEmpty ? words.first.id : "-"}');
      print('🔎 _loadWords: words.length=${words.length}');
      if (words.isEmpty) {
        print('⚠️ _loadWords: KEINE WÖRTER GELADEN! catId=$catId mode=$mode srsSystem=$srsSystem');
      } else {
        print('🔎 _loadWords: Erste 3 Wörter: ${words.take(3).map((w) => '${w.text} (Stage ${w.srsStage})').toList()}');
      }

        // Client-seitige Filterung als zusätzliche Absicherung
        final allowed = ref.read(allowedStagesProvider);
        // ✅ S0-Lock: Wenn Schloss aktiv (0 Sperre), Stage 0 NICHT erlauben
        final s0Locked = ref.read(s0LockedProvider(catId)).maybeWhen(data: (v) => v, orElse: () => false);
        final allowedForced = s0Locked ? allowed.where((s) => s != 0).toSet() : {...allowed, 0};
        print('🔎 _loadWords: allowed (UI)=$allowed, s0Locked=$s0Locked, allowedForced (Deck)=$allowedForced');
        var filteredWords = words.where((w) => allowedForced.contains(w.srsStage)).toList();
        print('🔎 _loadWords: filteredWords.length=${filteredWords.length}');

        // Session-Buckets für Single-Modus initialisieren
        if (mode == LevelSelectionMode.single && singleStage != null) {
          final cnt = filteredWords.length;
          ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(src: cnt);
          
          // Single-Session seeden
          try {
            await singleSeed(catId, singleStage);
            final counts = await singleCounts(catId, singleStage);
            print('🔢 SingleCounts for $catId (stage $singleStage): src=${counts.$1}, sr1=${counts.$2}, sr2=${counts.$3}');
            // Fallback: Wenn Server 0 liefert, Category-Detail-Wert beibehalten (nicht überschreiben)
            final srcFromCategory = singleStage < state.stages.length ? state.stages[singleStage] : 0;
            final src = counts.$1 > 0 ? counts.$1 : srcFromCategory;
            ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(
              src: src,
              sx: counts.$2,
              sy: counts.$3,
            );
            ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
              src, counts.$2, counts.$3,
            );
          } catch (e) {
            print('❌ Single session seed failed: $e');
          }
        }

      // Histogramm ausgeben
      final rpcHist = <int,int>{};
      for (final w in words.take(60)) { rpcHist[w.srsStage] = (rpcHist[w.srsStage] ?? 0) + 1; }
      print('🧪 Words(60) stages: $rpcHist');

      // Ersten 10 Stufen klar loggen
      print('🧪 First10 stages: ${words.take(10).map((w) => w.srsStage).toList()}');

      if (filteredWords.isEmpty) {
        final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
            ? state.wordQueue[state.index].srsStage
            : -1;
        print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (filteredWords empty) at=${StackTrace.current}');
        print('🧨 INDEX-RESET auf 0 in _loadWords (filteredWords empty, Hybrid/T-SRS): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
        _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
        return;
      }

      final queue = _buildQueueDueFirst(filteredWords);
      
      // Debug: Prüfe ob queue leer ist
      print('🔎 _loadWords: queue.length=${queue.length}, filteredWords.length=${filteredWords.length}');
      
      // Sofort prüfen: Queue-Stages analysieren
      final hist = <int,int>{};
      for (final w in queue.take(50)) {
        hist[w.srsStage] = (hist[w.srsStage] ?? 0) + 1;
      }
      print('🔎 Queue first50 stages: $hist');
      
      // Config berechnen und übergeben
      final now = DateTime.now();
      final dueCount = queue.where((w) => isDueNow(w, now, srsSystem: srsSystem)).length;

      // Stats für adaptive Konfiguration
      final stats = SrsStats(
        rollingAccuracy: _rollingAccuracy,
        avgSwipeMs: _avgSwipeMs,
        recentTimeouts: _recentTimeouts,
      );

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: stats,
      );

      final srs = ref.read(srsModeControllerProvider).mode;
      
      int allowedMaxStage;
      int? forbiddenStage; // null = nichts verbieten
      
      switch (srs) {
        case SrsSystem.adaptive:
          allowedMaxStage = 5;     // A-SRS darf bis A5
          forbiddenStage = null;   // Stage 0 NICHT verbieten
          break;
        case SrsSystem.time:
        case SrsSystem.hybrid:
          // bisherige Logik
          allowedMaxStage = _computeAllowedMaxStageFromQueue(queue);
          forbiddenStage = null; // kann später angepasst werden
          break;
      }
      
      // ✅ T-SRS/Hybrid: Deck-Build mit S0-Quota + Interleave
      final List<String> finalIds;
      final List<String> finalShuffledIds;
      final List<int> deckStages;
      final int safeStage;
      
      {
        // T-SRS/Hybrid: Deck-Build mit S0-Quota + Interleave
        final deckSize = queue.length.clamp(0, 200); // Maximal 200 Karten
        finalIds = _buildDeckIdsWithQuota(
          allWords: queue,
          deckSize: deckSize,
        );

        // Debug-Log für Quota-Verifikation
        final quota = _computeQuota(deckSize);
        print('📊 Deck-Quota: $quota (deckSize=$deckSize)');
        
        // Debug-Log für tatsächliche Verteilung im Deck
        final deckWords = <WordUserView>[];
        for (final id in finalIds) {
          final w = _findWordById(id, queue);
          if (w != null) {
            deckWords.add(w);
          } else {
            print('⚠️ missing word in queue: $id');
          }
        }
        final s0Count = deckWords.where((w) => w.srsStage == 0).length;
        final s1Count = deckWords.where((w) => w.srsStage == 1).length;
        final s2Count = deckWords.where((w) => w.srsStage == 2).length;
        final s3Count = deckWords.where((w) => w.srsStage == 3).length;
        final s4Count = deckWords.where((w) => w.srsStage == 4).length;
        final s5Count = deckWords.where((w) => w.srsStage == 5).length;
        print('📊 Deck-Verteilung: S0:$s0Count, S1:$s1Count, S2:$s2Count, S3:$s3Count, S4:$s4Count, S5:$s5Count');
        
        // Berechne deckStages aus den geladenen Karten
        deckStages = _computeDeckStages(finalIds, queue);
        print('📊 deckStages berechnet: $deckStages');
        
        // Safe activeStage wählen: bleib bei aktueller, wenn sie noch Karten hat, sonst erste nicht-leere
        safeStage = (state.activeStage >= 0 &&
            state.activeStage < deckStages.length &&
            deckStages[state.activeStage] > 0)
            ? state.activeStage
            : _firstNonEmptyStage(deckStages, fallback: 0);
        
        print('✅ Safe activeStage gewählt: $safeStage (deckStages: $deckStages)');
        
        // ✅ T-SRS/Hybrid: Deck-Mix aus allen Stages (nicht nur einer) – sonst arbeitet man nur in A1
        finalShuffledIds = List<String>.from(finalIds)..shuffle();
      }
      
      final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
          ? state.wordQueue[state.index].srsStage
          : -1;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (Stage=$safeStage, _loadWords) at=${StackTrace.current}');
      // ✅ Log: Bevor shuffledWordIds gesetzt wird
      print('🟦 _loadWords SET shuffledWordIds.length=${finalShuffledIds.length}');
      // T-SRS/Hybrid: queue verwenden
      final finalQueue = queue;
      
      print('🚀 _loadWords: Setze wordQueue.length=${finalQueue.length}, shuffledWordIds.length=${finalShuffledIds.length}, index=0');
      print('🚀 _loadWords: Erste 3 IDs in shuffledWordIds: ${finalShuffledIds.take(3).toList()}');
      print('🚀 _loadWords: Erste 3 Wörter in queue: ${finalQueue.take(3).map((w) => '${w.id}: ${w.text}').toList()}');

      print('🧨 INDEX-RESET auf 0 in _loadWords (nach Queue-Load): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
      print('✅ queue=${finalQueue.length} | finalShuffledIds=${finalShuffledIds.length} | totalCat=${state.totalWordsInCategory}');
      _set(
        wordQueue: finalQueue,
        shuffledWordIds: finalShuffledIds,
        deckStages: deckStages,
        index: 0,
        activeStage: safeStage,
      );
      print('🚀 _loadWords: State gesetzt, state.shuffledWordIds.length=${state.shuffledWordIds.length}, state.wordQueue.length=${state.wordQueue.length}');
      
      // ✅ FIX: Stage-Queues aus aktuellen Wörtern aufbauen (NUR für T-SRS/Hybrid)
      if (srsSystem != SrsSystem.adaptive) {
        _rebuildStageQueuesFromCurrentWords(finalQueue);
        print('🔧 _loadWords: Stage-Queues aufgebaut. _stageQueues[${safeStage}].length=${_stageQueues[safeStage].length}');
      } else {
        // ❌ A-SRS: KEINE Stage-Queues aufbauen, KEINE Sync
        print('⏭️ _loadWords: A-SRS - Überspringe _rebuildStageQueuesFromCurrentWords und _ensureValidActiveStageAndSync');
      }
      
      // ✅ T-SRS/Hybrid: Deck ist bereits gemischt (finalShuffledIds). Nur activeStage validieren, NICHT auf eine Stage filtern.
      if (srsSystem != SrsSystem.adaptive) {
        _ensureValidActiveStage(); // activeStage auf nicht-leere Stage setzen
        print('✅ _loadWords: activeStage=${state.activeStage}, Deck-Mix aus allen Stages, shuffledWordIds.length=${state.shuffledWordIds.length}');
      } else {
        // ❌ A-SRS: KEINE _ensureValidActiveStageAndSync, KEINE _syncDeckToActiveStage
        // Für T-SRS/Hybrid: shuffledWordIds wurde bereits in _set() gesetzt
        print('✅ _loadWords: A-SRS - Überspringe _ensureValidActiveStageAndSync (shuffledWordIds bereits gesetzt, length=${state.shuffledWordIds.length})');
      }
      
      // ✅ Requeue nach Ausspielung konsumieren (löschen) - beim Initial-Load
      if (finalQueue.isNotEmpty && finalIds.isNotEmpty) {
        final firstId = finalIds[0];
        final firstWord = finalQueue.firstWhere((w) => w.id == firstId, orElse: () => finalQueue.first);
        if (firstWord.isRequeue) {
          try {
            final srsSystem = ref.read(srsModeControllerProvider).mode;
            await _repo.requeueConsume(
              categoryId: _currentCatId,
              wordId: firstId,
              mode: srsSystem.name,
            );
            print('🔄 Requeue konsumiert für word=$firstId (beim Initial-Load)');
          } catch (e) {
            print('⚠️ Requeue-Consume fehlgeschlagen: $e');
          }
        }
      }
    } catch (e, stackTrace) {
      print('🟥 _loadWords ERROR: $e');
      print('🟥 _loadWords STACK: $stackTrace');
      print('❌ _loadWords() Fehler: $e');
      print('❌ StackTrace: $stackTrace');
      final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
          ? state.wordQueue[state.index].srsStage
          : -1;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (error in _loadWords) at=${StackTrace.current}');
      print('🧨 INDEX-RESET auf 0 in _loadWords (error): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
      _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
    }
  }

  /// Berechnet Quotas pro Stage basierend auf prozentualen Targets.
  /// Rundungsdiff wird auf S0 gepackt.
  Map<int, int> _computeQuota(int deckSize) {
    // ✅ Prozentuale Targets pro Stage
    const target = <int, double>{
      0: 0.35, // S0 Anteil (35%)
      1: 0.20, // S1 Anteil (20%)
      2: 0.20, // S2 Anteil (20%)
      3: 0.15, // S3 Anteil (15%)
      4: 0.07, // S4 Anteil (7%)
      5: 0.03, // S5 Anteil (3%)
    };

    final q = <int, int>{};
    int sum = 0;
    for (final e in target.entries) {
      final v = (deckSize * e.value).round();
      q[e.key] = v;
      sum += v;
    }
    // Rundungsdiff auf S0 packen
    q[0] = (q[0] ?? 0) + (deckSize - sum);
    return q;
  }

  /// Baut Deck-IDs mit S0-Quota und Interleave.
  /// Wichtig: S0 wird aktiv gezogen!
  List<String> _buildDeckIdsWithQuota({
    required List<WordUserView> allWords,
    required int deckSize,
  }) {
    // 1) Wörter nach Stage gruppieren
    final byStage = <int, List<WordUserView>>{};
    for (final w in allWords) {
      final stage = w.srsStage.clamp(0, 5);
      byStage.putIfAbsent(stage, () => []).add(w);
    }

    // Shuffle pro Stage für Varianz
    for (final list in byStage.values) {
      list.shuffle();
    }

    // 2) Quotas berechnen
    final quota = _computeQuota(deckSize);

    // 3) Pro Stage "ziehen" (wichtig: S0 wird aktiv gezogen!)
    final pickedByStage = <int, List<WordUserView>>{};
    for (int s = 0; s <= 5; s++) {
      final pool = byStage[s] ?? const [];
      final take = (quota[s] ?? 0).clamp(0, pool.length);
      // ✅ Wichtig: Liste muss mutierbar sein für removeLast()
      pickedByStage[s] = List<WordUserView>.from(pool.take(take));
    }

    // 4) Interleave: round-robin nach Zielgewichten, damit es "gemischt" ist
    final result = <String>[];
    while (result.length < deckSize) {
      bool added = false;
      for (int s = 0; s <= 5; s++) {
        final list = pickedByStage[s];
        if (list != null && list.isNotEmpty) {
          result.add(list.removeLast().id);
          added = true;
          if (result.length == deckSize) break;
        }
      }
      if (!added) break; // nichts mehr verfügbar
    }

    return result;
  }

  /// bevorzugt fällige Karten, Rest zufällig gemischt
  List<WordUserView> _buildQueueDueFirst(List<WordUserView> words) {
    final due = <WordUserView>[];
    final notDue = <WordUserView>[];
    final now = DateTime.now();
    final srsSystem = ref.read(srsModeControllerProvider).mode;

    for (final w in words) {
      if (isDueNow(w, now, srsSystem: srsSystem)) {
        due.add(w);
      } else {
        notDue.add(w);
      }
    }

    due.shuffle();
    notDue.shuffle();
    return [...due, ...notDue];
  }


  // ---- Single Session Reset ----
  
  Future<void> resetSingleSession() async {
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      try {
        final singleStage = ref.read(singleStageProvider);
        await singleReset(_currentCatId, singleStage);
        
        // Counts nachladen und UI aktualisieren
        final counts = await singleCounts(_currentCatId, singleStage);
        ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(
          src: counts.$1, 
          sx: counts.$2, 
          sy: counts.$3,
        );
        ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
          counts.$1, counts.$2, counts.$3,
        );
      } catch (e) {
        print('❌ Single session reset failed: $e');
      }
    }
  }

  // ---- Review / Antwort-Handling ----

  Future<void> _handleAnswer({required bool correct}) async {
    print('🔥 ANSWER CHECK | finalPassActive=${state.finalPassActive} | '
        'queue=${state.wordQueue.length} | index=${state.index}');
    if (state.shuffledWordIds.isEmpty || state.index >= state.shuffledWordIds.length) {
      debugPrint('⛔ _handleAnswer abgebrochen: kein aktives Deck vorhanden');
      return;
    }
    final runId = ++_answerRunId;
    print('🟢 _handleAnswer ENTER runId=$runId correct=$correct isSubmittingReview=${state.isSubmittingReview} index=${state.index}');
    if (state.isSubmittingReview) return;
    _set(
      isSubmittingReview: true,
      hasStartedAdaptiveRound: state.hasStartedAdaptiveRound ? null : true,
    );
    print('🟡 _handleAnswer LOCKED runId=$runId index=${state.index}');
    try {
    developer.log('🎯 Swipe: correct=$correct', name: 'LearnMode');
    final mode = ref.read(levelSelectionProvider);
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    
        // Progress-Update basierend auf Modus
        if (mode == LevelSelectionMode.single) {
          // Single-Modus: Server-Session updaten (oder nur lokal bei noSave)
          try {
            final st = ref.read(singleStageProvider);
            final catId = _currentCatId;
            final noSave = ref.read(noSaveProgressProvider);
            
            final currentWord = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
                ? state.wordQueue[state.index]
                : null;
            
            if (currentWord == null) return;

            if (!noSave) {
              await singleMove(catId, st, currentWord.id, correct);
            }

            // Optimistisches UI-Update: sofort anzeigen (correct: src→sr1)
            final cur = ref.read(singleSessionCountsProvider);
            if (correct) {
              ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
                (cur.src - 1).clamp(0, 1 << 30),
                cur.sr1 + 1,
                cur.sr2,
              );
            }

            String? nextId;
            if (noSave) {
              // Lokale Queue: aktuelle Karte entfernen, Index anpassen
              final ids = List<String>.from(state.shuffledWordIds);
              final i = state.index;
              if (i < ids.length) ids.removeAt(i);
              final newIdx = ids.isEmpty ? 0 : (i % ids.length).clamp(0, ids.length - 1);
              _set(shuffledWordIds: ids, index: newIdx);
              return; // Kein singleCounts bei noSave
            }
            nextId = await singleNextWordId(catId, st);

            // Falls es eine nächste Karte gibt -> IDs & Queue aktualisieren
            final ids = List<String>.from(state.shuffledWordIds);
            final i = state.index;

            if (nextId != null) {
              // IDs auf die nächste Karte setzen
              if (i < ids.length) {
                ids[i] = nextId;
              } else {
                ids.add(nextId);
              }
              // Wortobjekt nachladen (für CardArea)
              final next = await _repo.fetchWordById(nextId);
              if (next != null) {
                final q = List<WordUserView>.from(state.wordQueue);
                if (i < q.length) {
                  q[i] = next;
                } else {
                  q.add(next);
                }
                _set(wordQueue: q, shuffledWordIds: ids);
              } else {
                _set(shuffledWordIds: ids);
              }
            } else {
              // keine SRC-Karte mehr -> aktuelle ID entfernen
              if (i < ids.length) {
                ids.removeAt(i);
              }
              final newIdx = ids.isEmpty ? 0 : (i % ids.length);
          final currentStage = currentWord?.srsStage ?? -1;
          final nextStage = ids.isNotEmpty && newIdx < ids.length && state.wordQueue.isNotEmpty
              ? (_findWordById(ids[newIdx], state.wordQueue)?.srsStage ?? -1)
              : -1;
          print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$newIdx (Stage=$nextStage) at=${StackTrace.current}');
              _set(shuffledWordIds: ids, index: newIdx);
            }

            // 3) Zähler aktualisieren (S{n}, SR1, SR2)
            // Fallback: Wenn Server nur Nullen liefert, optimistic Update (correct: src-1, sr1+1)
            final c = await singleCounts(catId, st);
            final prev = ref.read(singleSessionCountsProvider);
            final useServer = c.$1 > 0 || c.$2 > 0 || c.$3 > 0;
            if (useServer) {
              ref.read(singleSessionCountsProvider.notifier).state =
                  SingleSessionCounts(c.$1, c.$2, c.$3);
            } else if (correct) {
              ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
                (prev.src - 1).clamp(0, 1 << 30),
                prev.sr1 + 1,
                prev.sr2,
              );
            }
          } catch (e) {
            print('❌ Single session move failed: $e');
          }
          return; // ✅ KEIN normales SRS-Update ausführen
        }
    
    if (mode == LevelSelectionMode.s1toS5) {
      // S1-S5: nur in 1..5 bewegen; niemals 0
      final queue = state.wordQueue;
      final ids = state.shuffledWordIds;
      if (queue.isEmpty || ids.isEmpty) return;

      final i = state.index;
      if (i >= ids.length) return;

      final currentId = ids[i];
      final current = queue.firstWhere((w) => w.id == currentId, orElse: () => queue.first);

      // oldStage direkt aus Queue-Karte (gleiche Quelle wie fetchAdaptiveQueue / UI)
      final queueItem = state.wordQueue.firstWhere(
        (w) => w.id == current.id,
      );
      final oldStage = queueItem.srsStage ?? 0;

      final delta = correct ? 1 : -1;
      final newStage = (oldStage + delta).clamp(1, 5); // Niemals unter 1
      
      // Lokale Stage-Update
      final stages = [...state.stages];
      if (oldStage >= 1 && oldStage < stages.length) {
        stages[oldStage] = (stages[oldStage] - 1).clamp(0, 1 << 30);
      }
      if (newStage >= 1 && newStage < stages.length) {
        stages[newStage] = stages[newStage] + 1;
      }
      _setStages(stages);
      
      // Server-Update (nur wenn Fortschritt gespeichert wird)
      if (!ref.read(noSaveProgressProvider)) {
        try {
          print('🔵 _handleAnswer BEFORE submitReview runId=$runId wordId=$currentId index=${state.index}');
          final result = await submitReview(
            _currentCatId,
            currentId,
            correct,
            srsSystem: srsSystem,
            oldStage: oldStage,
          );
          final serverStage = result.stage;
          final serverDue = result.nextDueAt;
          
          try {
            await _repo.fetchCategoryProgress(_currentCatId, srsSystem: srsSystem);
          } catch (_) {}
          
          if (current.isRequeue) {
            try {
              await _repo.requeueConsume(
                categoryId: _currentCatId,
                wordId: currentId,
                mode: srsSystem.name,
              );
            } catch (_) {}
          }
          
          ref.invalidate(categoryProgressProvider((catId: _currentCatId, srs: srsSystem)));
          
          final q = List<WordUserView>.from(state.wordQueue);
          final pos = q.indexWhere((w) => w.id == currentId);
          if (pos != -1) {
            q[pos] = q[pos].copyWith(
              srsStage: result.stage,
              nextDueAt: result.nextDueAt,
              streak: result.streak,
            );
            _set(wordQueue: q);
          }
          
          if (serverStage != newStage) {
            final updatedStages = [...state.stages];
            if (newStage >= 1 && newStage < updatedStages.length) {
              updatedStages[newStage] = (updatedStages[newStage] - 1).clamp(0, 1 << 30);
            }
            if (serverStage >= 1 && serverStage < updatedStages.length) {
              updatedStages[serverStage] = updatedStages[serverStage] + 1;
            }
            _setStages(updatedStages);
          }
        } catch (e) {
          print('❌ Review submission failed: $e');
          _set(isSubmitting: false);
        }
      } else {
        // noSave: Word-Instanz nur lokal aktualisieren
        final q = List<WordUserView>.from(state.wordQueue);
        final pos = q.indexWhere((w) => w.id == currentId);
        if (pos != -1) {
          q[pos] = q[pos].copyWith(
            srsStage: newStage,
            nextDueAt: DateTime.now().add(Duration(hours: 1 << newStage.clamp(0, 5))),
            streak: 0,
          );
          _set(wordQueue: q);
        }
      }
      
      // Nächste Karte
      final nextIndex = (i + 1) % ids.length;
      final currentStage = current.srsStage;
      final nextId = ids[nextIndex];
      final nextWord = queue.firstWhere((w) => w.id == nextId, orElse: () => queue.first);
      final nextStage = nextWord.srsStage;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$nextIndex (Stage=$nextStage) at=${StackTrace.current}');
      _set(index: nextIndex);
      _set(isSubmitting: false);
      
      return;
    }
    
    // S0-S5: normale Logik (inkl. 0 ↔ 1 Übergänge)

    final queue = state.wordQueue;
    final ids   = state.shuffledWordIds;
    if (queue.isEmpty || ids.isEmpty) return;

    final i = state.index;
    if (i >= ids.length) return;

    // 🔑 1) Aktuelle Karte über shuffled IDs auflösen (statt queue[i])
    final currentId = ids[i];
    final current = queue.firstWhere((w) => w.id == currentId, orElse: () => queue.first);
    
    // ✅ Requeue nach Ausspielung konsumieren (löschen) - direkt wenn Wort angezeigt wird
    if (!ref.read(noSaveProgressProvider) && current.isRequeue) {
      try {
        await _repo.requeueConsume(
          categoryId: _currentCatId,
          wordId: currentId,
          mode: srsSystem.name,
        );
        print('🔄 Requeue konsumiert für word=$currentId (beim Anzeigen)');
      } catch (e) {
        print('⚠️ Requeue-Consume fehlgeschlagen: $e');
      }
    }
    
    // Debug-Log für Karten-Bewertung
    final nowUtc = DateTime.now().toUtc();
    final isDueNowValue = isDueNow(current, nowUtc, srsSystem: srsSystem);
    print('🎯 Bewerte Karte: ${current.text} (Stage: ${current.srsStage}, Due: $isDueNowValue) - $correct');

    // 1) Timer-Status merken (nicht stoppen!)
    final wasActive = state.timerActive;
    final wasPaused = state.timerPaused;
    final wasRunning = state.running;

    // oldStage direkt aus Queue-Karte (gleiche Quelle wie fetchAdaptiveQueue / UI)
    final currentWordId = current.id;
    final queueItem = state.wordQueue.firstWhere(
      (w) => w.id == currentWordId,
    );
    final oldStage = queueItem.srsStage ?? 0;

    print('A-HANDLE start: word=${current.id} oldStage=$oldStage correct=$correct srs=$srsSystem');

    // ✅ A‑SRS S0 Sonderfall:
    // S0 ("New") ist kein Review-State. Bei KORREKT wird die Karte pro Karte nach S1 enrolled.
    if (srsSystem == SrsSystem.adaptive && oldStage == 0) {
      print('A-HANDLE branch: S0');
      final sb = Supabase.instance.client;
      final userId = sb.auth.currentUser?.id;
      if (userId == null) {
        _set(isSubmitting: false);
        return;
      }

      final noSave = ref.read(noSaveProgressProvider);
      try {
        if (correct && !noSave) {
          print('A-HANDLE before enroll...');
          final result = await _repo.enrollFromS0ToS1(
            userId: userId,
            categoryId: _currentCatId,
            wordId: currentId,
            mode: 'adaptive',
          );
          final serverStage = result.stage;
          final serverDue = result.nextDueAt;
          print('DB stage: $oldStage -> $serverStage');

          // Queue-Item updaten
          final q = List<WordUserView>.from(state.wordQueue);
          final pos = q.indexWhere((w) => w.id == currentId);
          if (pos != -1) {
            q[pos] = q[pos].copyWith(
              srsStage: serverStage,
              nextDueAt: serverDue,
              streak: 0,
            );
            _set(wordQueue: q);
          }

          // Stage-Counts updaten (S0--, S1++)
          final updatedStages = [...state.stages];
          updatedStages[0] = (updatedStages[0] - 1).clamp(0, 1 << 30);
          if (serverStage >= 1 && serverStage < updatedStages.length) {
            updatedStages[serverStage] = updatedStages[serverStage] + 1;
          }
          _setStages(updatedStages);

          _set(
            hasStartedAdaptiveRound: true,
            skipNextAdaptiveRefill: true,
          );

          // Provider invalidieren (Category Detail / Cards + Kapsel unter A5)
          ref.invalidate(categoryProgressProvider((catId: _currentCatId, srs: srsSystem)));
          ref.invalidate(learnedInStage5Provider(_currentCatId));

          // Queue neu vom Server holen (frisch enrolled S1-Karten nachrücken)
          await _loadWords(forceReload: true);
          _set(isSubmitting: false);
          return;
        } else if (correct && noSave) {
          // noSave: nur lokales UI-Update, kein Backend
          final serverStage = 1;
          final serverDue = DateTime.now().add(const Duration(hours: 1));
          final q = List<WordUserView>.from(state.wordQueue);
          final pos = q.indexWhere((w) => w.id == currentId);
          if (pos != -1) {
            q[pos] = q[pos].copyWith(srsStage: serverStage, nextDueAt: serverDue, streak: 0);
            _set(wordQueue: q);
          }
          final updatedStages = [...state.stages];
          updatedStages[0] = (updatedStages[0] - 1).clamp(0, 1 << 30);
          if (serverStage < updatedStages.length) updatedStages[serverStage] = updatedStages[serverStage] + 1;
          _setStages(updatedStages);
        } else if (!correct && !noSave) {
          // Falsch in S0: in Requeue schieben (keine Stage-Änderung)
          await sb.rpc('fn_requeue_s0_fail', params: {
            'p_user': userId,
            'p_mode': 'adaptive',
            'p_category_id': _currentCatId,
            'p_word_id': currentId,
          });
        }
      } catch (e) {
        print('❌ A-SRS S0 answer failed: $e');
        _set(isSubmitting: false);
      }

      // Nächste Karte (noSave, wrong, oder nach catch)
      final nextIndex = (i + 1) % ids.length;
      final currentStage = current.srsStage;
      final nextId = ids[nextIndex];
      final nextWord = queue.firstWhere((w) => w.id == nextId, orElse: () => queue.first);
      final nextStage = nextWord.srsStage;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$nextIndex (Stage=$nextStage) at=${StackTrace.current}');
      _set(index: nextIndex);
      _set(isSubmitting: false);
      return;
    }
    
      print('A-HANDLE branch: REVIEW');
    // 3) Für A-SRS: KEINE lokale Stage-Mutation, direkt Server-Response abwarten
    // Für T-SRS/Hybrid: lokale Schätzung (wie bisher)
    int newStage = oldStage;
    if (srsSystem != SrsSystem.adaptive) {
      // T-SRS/Hybrid: lokale Schätzung (nur für Fallback, nicht für UI-Update)
    if (correct) {
      newStage = (newStage < 5) ? newStage + 1 : 5;
    } else {
      newStage = (newStage > 0) ? newStage - 1 : 0;
    }
    }

    // ❌ TESTWEISE AUSKOMMENTIERT: Lokale Stage-Mutation VOR RPC-Call
    // Das eigentliche Verschieben/Counts-Update darf ausschließlich nach der RPC-Antwort passieren
    // if (srsSystem != SrsSystem.adaptive) {
    //   // Queue-Item updaten (lokal) - nur für T-SRS/Hybrid
    //   final q = List<WordUserView>.from(state.wordQueue);
    //   final pos = q.indexWhere((w) => w.id == currentId);
    //   if (pos != -1) {
    //     q[pos] = q[pos].copyWith(srsStage: newStage);
    //     // Stages aus aktualisierter Queue neu berechnen (kein Delta!)
    //     final stages = _countStagesFromQueue(q);
    //     _set(wordQueue: q, stages: stages);
    //     print('🔢 Stages aus Queue neu berechnet: $stages (oldStage=$oldStage -> newStage=$newStage)');
    //     
    //     // ✅ FIX: Normalisiere activeStage nach Stages-Update
    //     _normalizeActiveStage();
    //   }
    // }

    // 4) Review an Backend schicken und Server-Response verwenden
    int serverStage = newStage; // Fallback auf lokale Schätzung (nur für T-SRS/Hybrid)
    DateTime? serverDue;
    // ✅ WICHTIG: serverProgress außerhalb des try-catch deklarieren, damit es im gesamten Scope verfügbar ist
    CategoryProgress? serverProgress;
    final noSave = ref.read(noSaveProgressProvider);
    // ✅ A-SRS: Immer speichern wenn User eingeloggt (noSave ignorieren), sonst bleiben Karten in A1
    final shouldSaveToServer = srsSystem == SrsSystem.adaptive
        ? (Supabase.instance.client.auth.currentUser != null)
        : !noSave;

    ReviewResult? reviewResult;
    if (!shouldSaveToServer) {
      // Kein Speichern: nur lokale Werte für UI, Category Detail behält alte Werte
      serverDue = DateTime.now().add(Duration(hours: 1 << serverStage.clamp(0, 5)));
      print('⚠️ Review nicht gespeichert (user=${Supabase.instance.client.auth.currentUser != null})');
    } else {
      try {
        // ✅ Kein ref.read auf currentWordProvider/learnModeController – vermeidet CircularDependency
        final catId = state.categoryId;
        final wordId = current.id;
        final correctValue = correct;
        final srsSystemVal = srsSystem;
        print('SUBMIT CHECK: currentIndex=${state.index} wordId=$wordId catId=$catId');
        print('🔵 _handleAnswer BEFORE submitReview runId=$runId wordId=$wordId index=${state.index}');
        reviewResult = await submitReview(
          catId,
          wordId,
          correctValue,
          srsSystem: srsSystemVal,
          oldStage: oldStage,
        );
        serverStage = reviewResult!.stage;
        serverDue = reviewResult!.nextDueAt;
        print('✅ Review gespeichert: Stage $oldStage → $serverStage');
        // Hinweis: S1→S2 erfolgt erst nach 2 richtigen (pass_count). Erste richtige Antwort bleibt in S1.

        // 🧪 DEBUG: Server-Progress direkt nach submitReview() holen (zum Vergleich mit UI)
        try {
          final progressReqId = ++_progressRequestId;
          print('📡 progress fetch START reqId=$progressReqId');
          serverProgress = await _repo.fetchCategoryProgress(
            _currentCatId,
            srsSystem: srsSystem,
          );
          print('📡 progress fetch DONE reqId=$progressReqId stages=${serverProgress.stages}');
          if (progressReqId != _progressRequestId) {
            print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
            serverProgress = null;
          } else {
            print('🧪 After submitReview: serverProgress stages=${serverProgress.stages} total=${serverProgress.total} (cat=$_currentCatId, word=$currentId, oldStage=$oldStage, newStage=$serverStage)');
          }
        } catch (e) {
          print('⚠️ Konnte Server-Progress nach submitReview nicht holen: $e');
          serverProgress = null;
        }

        // ✅ Requeue nach Ausspielung konsumieren (löschen)
        if (current.isRequeue) {
          try {
            await _repo.requeueConsume(
              categoryId: _currentCatId,
              wordId: currentId,
              mode: srsSystem.name,
            );
            print('🔄 Requeue konsumiert für word=$currentId');
          } catch (e) {
            print('⚠️ Requeue-Consume fehlgeschlagen: $e');
          }
        }
      } catch (e) {
        print('❌ Review submission failed: $e');
        _set(isSubmitting: false);
        return;
      }
    }

    // Ab hier für BEIDE (noSave + else): lokales UI-Update
    // ⚠️ WARNUNG: Prüfe ob Backend-Antwort mit A-SRS-Regeln übereinstimmt
      // ✅ Neue Logik berücksichtigt oldStreak: Stage 1 bleibt bei streak < 1, wird 2 bei streak == 1
      // COMMENTED OUT:
      // if (srs == SrsSystem.adaptive && correct) {
      //   // oldStreak aus DB holen (vor Review)
      //   int? oldStreak;
      //   try {
      //     final sb = Supabase.instance.client;
      //     final userId = sb.auth.currentUser?.id;
      //     if (userId != null) {
      //       final modeStr = srs.name; // 'adaptive', 'hybrid', 'time'
      //       final dbCheck = await sb
      //           .from('user_word_srs')
      //           .select('streak')
      //           .eq('user_id', userId)
      //           .eq('word_id', currentId)
      //           .eq('category_id', _currentCatId)
      //           .eq('mode', modeStr) // ✅ Mode-Filter hinzugefügt
      //           .maybeSingle();
      //       oldStreak = dbCheck?['streak'] as int?;
      //     }
      //   } catch (e) {
      //     print('⚠️ Konnte oldStreak nicht aus DB holen: $e');
      //   }
      //   
      //   // Erwartete Stage basierend auf oldStage und oldStreak
      //   int? expectedStage;
      //   if (oldStage == 1) {
      //     if (oldStreak != null && oldStreak < 1 && correct) {
      //       expectedStage = 1; // Stage bleibt bei streak < 1
      //     } else if (oldStreak != null && oldStreak == 1 && correct) {
      //       expectedStage = 2; // Stage wird 2 bei streak == 1
      //     }
      //   } else if (oldStage < 5) {
      //     expectedStage = oldStage + 1; // Standard: Stage hoch
      //   } else {
      //     expectedStage = 5; // Max Stage
      //   }
      //   
      //   if (expectedStage != null && serverStage != expectedStage) {
      //     print('⚠️ BACKEND-FEHLER: A-SRS-Regel verletzt!');
      //     print('⚠️   Wort in Stage $oldStage, streak=$oldStreak, korrekt beantwortet');
      //     print('⚠️   Erwartet: Stage $expectedStage');
      //     print('⚠️   Backend gibt zurück: Stage $serverStage');
      //     print('⚠️   Die Backend-Funktion fn_user_review_mode implementiert die A-SRS-Regeln nicht korrekt!');
      //   }
      // }
      
      // ✅ Contract-Assertion: Sammle "before"-Werte VOR lokalen Updates
      final stagesBefore = List<int>.from(state.stages);
      final stageQueuesBefore = _stageQueues.map((q) => q.length).toList();
      final masteredBefore = state.masteredCount;
      
      // ✅ DB-Werte für Contract-Assertion holen
      int dbStage = serverStage; // Fallback
      DateTime? dbNextDueAt = serverDue; // Fallback
      try {
        final sb = Supabase.instance.client;
        final userId = sb.auth.currentUser?.id;
        if (userId != null) {
          final modeStr = srsSystem.name;
          final dbRow = await sb
              .from('user_word_srs')
              .select('stage, next_due_at')
              .eq('user_id', userId)
              .eq('word_id', currentId)
              .eq('category_id', _currentCatId)
              .eq('mode', modeStr)
              .maybeSingle();
          
          if (dbRow != null) {
            dbStage = (dbRow['stage'] as int?) ?? serverStage;
            final dbNextDueAtStr = dbRow['next_due_at'] as String?;
            dbNextDueAt = dbNextDueAtStr != null ? DateTime.parse(dbNextDueAtStr) : serverDue;
          }
        }
      } catch (e) {
        print('⚠️ Konnte DB-Werte für Contract-Assertion nicht holen: $e');
      }
      
      // ✅ Queue-Item updaten mit ALLEN Serverwerten (stage, streak, nextDueAt, passCount)
      final displayStreak = shouldSaveToServer ? (reviewResult?.streak ?? 0) : 0;
      final displayPassCount = shouldSaveToServer ? (reviewResult?.passCount ?? 0) : 0;
      final updatedQueue = [
        for (final w in state.wordQueue)
          if (w.id == currentId)
            w.copyWith(
              srsStage: serverStage,
              nextDueAt: serverDue,
              streak: displayStreak,
              passCount: displayPassCount,
            )
          else
            w
      ];
      
      // ✅ NACHDEM der RPC Response geparst wurde (serverStage / serverDue),
      // und BEVOR _advanceIndexAfterReview() aufgerufen wird:

      if (srsSystem == SrsSystem.adaptive) {
        // ✅ A-SRS: KEIN lokales Category-Progress-Mutieren!
        print('📊 A-SRS: Kein lokales Progress-Update (Server ist Source of Truth)');

        // ✅ A‑SRS UI: Switches sollen Category-Counts anzeigen (state.stages).
        // Diese Counts dürfen NUR anhand von Serverdaten aktualisiert werden:
        // - bevorzugt serverProgress.stages (voller Snapshot)
        // - fallback: delta oldStage -> serverStage (auch server-basiert, aus RPC)
        List<int>? updatedStages;
        if (serverProgress != null) {
          updatedStages = serverProgress!.stages;
        } else if (serverStage != oldStage) {
          updatedStages = _applyLocalProgressDelta(
            stages: state.stages,
            oldStage: oldStage,
            newStage: serverStage,
          );
        }

        // deckStages (nur das aktuelle Deck) müssen ebenfalls live aktualisiert werden.
        final updatedDeckStages = _computeDeckStages(state.shuffledWordIds, updatedQueue);
        final masteredCount = await _repo.countLearnedInStage5(_currentCatId, srsSystem: srsSystem).catchError((_) => 0);
        _set(
          wordQueue: updatedQueue,
          deckStages: updatedDeckStages,
          stages: updatedStages,
          masteredCount: masteredCount,
        );
        ref.invalidate(learnedInStage5Provider(_currentCatId));
      } else {
        // ✅ T-SRS / Hybrid: lokales Live-Progress-Update bleibt erlaubt
        List<int>? updatedStages;

        if (serverStage != oldStage) {
          updatedStages = _applyLocalProgressDelta(
            stages: state.stages,
            oldStage: oldStage,
            newStage: serverStage,
          );

          print('📊 Lokales Progress-Update (T-SRS/Hybrid): stages[$oldStage] -= 1, stages[$serverStage] += 1 → $updatedStages');

          // ✅ Word-ID zwischen Stage-Queues verschieben (nur T-SRS/Hybrid)
          _moveWordIdQueue(
            wordId: currentId,
            fromStage: oldStage,
            toStage: serverStage,
          );

          // ✅ Normalisiere activeStage nach Stages-Update
          _normalizeActiveStage();
        }

        // ✅ Ein einziger _set() (atomar)
        _set(
          wordQueue: updatedQueue,
          stages: updatedStages, // nur gesetzt, wenn wirklich geändert
        );
      }
      
      // ✅ Contract-Assertion: Sammle "after"-Werte NACH lokalen Updates
      final stagesAfter = List<int>.from(state.stages);
      final stageQueuesAfter = _stageQueues.map((q) => q.length).toList();
      
      // DEBUG: Provider-Wert direkt vor Assert
      final learnedStage5 = await ref.read(learnedInStage5Provider(_currentCatId).future);
      print('DEBUG learnedInStage5Provider=$_currentCatId -> $learnedStage5');
      
      // ✅ Contract-Assertion aufrufen
      assertSrsContractsAfterReview(
        wordId: currentId,
        oldStage: oldStage,
        rpcStage: serverStage,
        rpcNextDueAt: serverDue,
        dbStage: dbStage,
        dbNextDueAt: dbNextDueAt,
        stagesBefore: stagesBefore,
        stagesAfter: stagesAfter,
        stageQueuesBefore: stageQueuesBefore,
        stageQueuesAfter: stageQueuesAfter,
        totalWordsInCategory: state.totalWordsInCategory,
        masteredBefore: masteredBefore,
        masteredAfter: state.masteredCount,
        skipNextDueAtCheck: reviewResult?.isMastered ?? false, // A-SRS: mastered words – RPC kann next_due_at zurückgeben, DB evtl. nicht aktualisiert
      );
      
      // ⬇️ Provider invalidierten (für T-SRS/Hybrid, damit CategoryDetailScreen aktualisiert wird)
      // ✅ Nur wenn Fortschritt gespeichert wurde (sonst alte Werte beim Zurückkehren)
      if (shouldSaveToServer && srsSystem != SrsSystem.adaptive) {
        ref.invalidate(categoryProgressProvider((catId: _currentCatId, srs: srsSystem)));
      }
      // Kapsel unter A5 (learned count) mit aktualisieren (auch für A-SRS)
      if (shouldSaveToServer) {
        ref.invalidate(learnedInStage5Provider(_currentCatId));
      }
      
      int allowedMaxStage;
      int? forbiddenStage;
      
      switch (srsSystem) {
        case SrsSystem.adaptive:
          allowedMaxStage = 5;
          forbiddenStage = null; // Stage 0 NICHT verbieten
          break;
        case SrsSystem.time:
        case SrsSystem.hybrid:
          allowedMaxStage = _computeAllowedMaxStageFromQueue(state.wordQueue);
          forbiddenStage = null;
          break;
      }
      
      final now = DateTime.now();
      final isNowDue = serverDue != null && !serverDue.isAfter(now);

      // ⛔️ Entfernen, wenn:
      // 1) Gate überschritten (z.B. S2 bei allowed=1) - ABER NICHT für A-SRS Stage 0
      // 2) oder S1+ und nicht (mehr) fällig – ABER NICHT, wenn es gerade S0→S1 wurde (Echo bleibt)
      final bool justLearnedToS1 = (oldStage == 0 && serverStage == 1);

      // Für A-SRS: Stage 0 niemals entfernen + kein due-gating
      final bool isA0 = (srsSystem == SrsSystem.adaptive && serverStage == 0);
      
      bool shouldRemoveFromSession;
      if (srsSystem == SrsSystem.adaptive) {
        // A-SRS: KEIN Entfernen (kein due-gating)
        shouldRemoveFromSession = false;
      } else {
        // T-SRS/Hybrid: bisherige Logik
        shouldRemoveFromSession = !isA0 && (
          (serverStage > allowedMaxStage) ||
            ((serverStage >= 1) && !isNowDue && !justLearnedToS1)
        );
      }

      if (shouldRemoveFromSession) {
        final newIds = List<String>.from(state.shuffledWordIds);
        final pos = newIds.indexOf(currentId);
        if (pos != -1) {
          newIds.removeAt(pos);
          var nextIndex = state.index;
          if (pos <= state.index && nextIndex > 0) nextIndex -= 1;
          final currentStage = oldStage;
          final nextStage = newIds.isNotEmpty && nextIndex < newIds.length && state.wordQueue.isNotEmpty
              ? state.wordQueue.firstWhere((w) => w.id == newIds[nextIndex], orElse: () => state.wordQueue.first).srsStage
              : -1;
          print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$nextIndex (Stage=$nextStage) at=${StackTrace.current}');
          final updatedDeckStages = _computeDeckStages(newIds, state.wordQueue);
          if (newIds.isEmpty) {
            print('🧨 INDEX-RESET auf 0 in _handleAnswer (newIds.isEmpty): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
          }
          _set(shuffledWordIds: newIds, deckStages: updatedDeckStages, index: newIds.isEmpty ? 0 : nextIndex);
          print('🗑️ Karte entfernt: $currentId (Stage: $serverStage, allowed: $allowedMaxStage, due: $isNowDue)');
        }
      }

      // Echo nur, wenn es wirklich S0→S1 war:
      if (correct && justLearnedToS1) {
        _scheduleImmediateReinforce(currentId, after: 10);
        _startCooldownForS0(currentId, minOthers: 8);
      }

      // (optional) auch für S1 bei korrekt einmaliges „Echo":
      if (correct && oldStage == 1) {
        _scheduleImmediateReinforce(currentId, after: 14);
      }

    // 5) Nächste Karte - Navigation basierend auf SRS-Mode
    final currentStageValue = current.srsStage.clamp(0, 5);
    int nextIndex;
    List<int>? aSrsDeckStages; // Für A-SRS: deckStages nach Swipe
    
    if (srsSystem == SrsSystem.adaptive) {
      // A-SRS: Stage-basierte Navigation (KEIN Index-basiertes Hochzählen)
      // Aktualisiere deckStages nach dem Swipe (Karte wurde in andere Stage verschoben)
      aSrsDeckStages = _computeDeckStages(ids, queue);
      
      // ✅ 1) Vor dem lokalen Update: aktuelle Werte merken
      final prevActiveStage = state.activeStage;
      final prevShuffled = state.shuffledWordIds;
      final prevIndex = state.index;
      
      // Bestimme nächste Stage mit _nextStageA (bleib in Stage, wenn count > 0)
      // ✅ WICHTIG: Verwende serverProgress.stages (Source of Truth), nicht state.stages (stale)
      // Falls serverProgress nicht verfügbar ist, Fallback auf state.stages
      final stagesForActiveStage = serverProgress?.stages ?? state.stages;
      final nextStage = _nextStageA(state.activeStage, stagesForActiveStage);
      
      print('✅ A-SRS: activeStage ${state.activeStage} -> $nextStage (stages: $stagesForActiveStage, source: ${serverProgress != null ? "serverProgress" : "state.stages (fallback)"})');
      
      // ✅ A-SRS: Setze activeStage und aktualisiere Session-Daten
      _set(
        activeStage: nextStage,
        recentlySwiped: [...state.recentlySwiped, currentId]..removeRange(
          0, (state.recentlySwiped.length + 1 - 50).clamp(0, 50),
        ),
        cardsSwipedInSession: state.cardsSwipedInSession + 1,
      );

      // ✅ A-SRS Retry-Regel: Bei falsch → Karte an Position (index+1+retry_delay) einfügen
      // retry_delay: 0 (active=1), 1 (2-5), 3 (6+)
      // ✅ Final Round: S5 nicht-mastered → Re-Insert bei index+10 (überschreibt Retry)
      final isFinalRoundS5NotMastered = state.finalPassActive &&
          oldStage == 5 &&
          !(reviewResult?.isMastered ?? true);

      if (isFinalRoundS5NotMastered) {
        // Final Round: Wort war in S5, noch nicht mastered → wieder bei index+8 einfügen
        // (3× richtig nötig für mastered; mit +8 erscheint Wort seltener → erstes mastered ~24+ Swipes)
        final ids = List<String>.from(state.shuffledWordIds);
        final curPos = ids.indexOf(currentId);
        if (curPos != -1) {
          ids.removeAt(curPos);
          final insertAt = (prevIndex + 8).clamp(0, ids.length);
          ids.insert(insertAt, currentId);
          final updatedDeckStages = _computeDeckStages(ids, state.wordQueue);
          _set(shuffledWordIds: ids, deckStages: updatedDeckStages);
          print('🔄 Final Round: $currentId (S5, nicht mastered) an Pos ${prevIndex + 8} eingefügt');
        }
      } else if (reviewResult?.isMastered ?? false) {
        // Final Round: Wort mastered → aus Queue entfernen; wenn leer → categoryMastered
        final ids = List<String>.from(state.shuffledWordIds);
        final curPos = ids.indexOf(currentId);
        if (curPos != -1) {
          ids.removeAt(curPos);
          final updatedDeckStages = _computeDeckStages(ids, state.wordQueue);
          final becameEmpty = ids.isEmpty;
          _set(
            shuffledWordIds: ids,
            deckStages: updatedDeckStages,
            index: ids.isEmpty ? 0 : (prevIndex > ids.length - 1 ? ids.length - 1 : prevIndex),
            categoryMastered: becameEmpty,
          );
          print('✅ Final Round: $currentId mastered, aus Queue entfernt. categoryMastered=$becameEmpty');
        }
      } else if (!correct) {
        final stagesForRetry = serverProgress?.stages ?? state.stages;
        final activeCount = stagesForRetry.length >= 6
            ? stagesForRetry.sublist(1, 6).fold<int>(0, (a, b) => a + b)
            : 0;
        final retryDelay = activeCount <= 1 ? 0 : (activeCount <= 5 ? 1 : 3);
        final ids = List<String>.from(state.shuffledWordIds);
        final curPos = ids.indexOf(currentId);
        if (curPos != -1 && ids.length > 1) {
          ids.removeAt(curPos);
          final insertAt = (prevIndex + 1 + retryDelay).clamp(0, ids.length);
          ids.insert(insertAt, currentId);
          final updatedDeckStages = _computeDeckStages(ids, state.wordQueue);
          _set(shuffledWordIds: ids, deckStages: updatedDeckStages);
          print('🔄 A-SRS Retry: $currentId an Pos ${prevIndex + 1 + retryDelay} (active=$activeCount, delay=$retryDelay)');
        }
      }

      // ✅ A-SRS: Index weiterschalten
      await _advanceIndexAfterReview(fromIndex: prevIndex);

      _set(isSubmitting: false);
      // Früh returnen - keine weitere Navigation-Logik
      return;
    } else {
      // T-SRS/Hybrid: Bestehende Logik (Stage-basiert mit Index-Fallback)
      final currentStageCount = state.deckStages[currentStageValue];
      
      if (currentStageCount == 0 && ids.isNotEmpty) {
        // Aktuelle Stage ist leer → springe zur nächsten Stage mit count > 0
        final nextStage = _nextStage(currentStageValue, state.deckStages);
        
        // Finde nächste Karte in der Queue, die in nextStage ist
        nextIndex = (i + 1) % ids.length;
        bool found = false;
        
        // Suche von aktueller Position vorwärts
        for (var checkIdx = nextIndex; checkIdx < ids.length; checkIdx++) {
          final checkId = ids[checkIdx];
          final checkWord = queue.firstWhere((w) => w.id == checkId, orElse: () => queue.first);
          if (checkWord.srsStage == nextStage) {
            nextIndex = checkIdx;
            found = true;
            break;
          }
        }
        
        // Falls nicht gefunden, suche von Anfang an
        if (!found) {
          for (var checkIdx = 0; checkIdx < nextIndex; checkIdx++) {
            final checkId = ids[checkIdx];
            final checkWord = queue.firstWhere((w) => w.id == checkId, orElse: () => queue.first);
            if (checkWord.srsStage == nextStage) {
              nextIndex = checkIdx;
              found = true;
              break;
            }
          }
        }
        
        if (!found) {
          // Falls keine Karte in nextStage gefunden, bleibe bei Standard-Logik
          nextIndex = (i + 1) % ids.length;
          print('⚠️ Keine Karte in Stage $nextStage gefunden, bleibe bei Standard-Logik');
        } else {
          print('✅ Springe zu Stage $nextStage (Index $nextIndex)');
        }
      } else {
        // Aktuelle Stage hat noch Karten → bleib in der aktuellen Stage
        // Aber: nächste Karte in der Queue (kann auch in derselben Stage sein)
        nextIndex = (i + 1) % ids.length;
      }
    }

    // 6) recentlySwiped aktualisieren
    final newSwiped = [...state.recentlySwiped, currentId];
    if (newSwiped.length > 50) newSwiped.removeAt(0);

    // Debug: Logge Stage-Wechsel
    final nextId = ids[nextIndex];
    final nextWord = queue.firstWhere((w) => w.id == nextId, orElse: () => queue.first);
    final nextStageValue = nextWord.srsStage;
    print('🧨 STAGE SET from=${state.index} (Stage=$currentStageValue) -> to=$nextIndex (Stage=$nextStageValue) at=${StackTrace.current}');

    // WICHTIG: index muss auf gültigen Bereich begrenzt werden (0..len-1)
    // Aktualisiere deckStages nach Swipe (Karte wurde möglicherweise in andere Stage verschoben)
    final clampedIndex = nextIndex.clamp(0, ids.length > 0 ? ids.length - 1 : 0);
    final updatedDeckStages = _computeDeckStages(ids, queue);
    
    // T-SRS/Hybrid: deckStages hier berechnen und index setzen
    _set(
      index: clampedIndex,
      deckStages: updatedDeckStages,
      recentlySwiped: newSwiped,
      cardsSwipedInSession: state.cardsSwipedInSession + 1,
    );

    // 7) ggf. neu mischen, wenn am Ende
    if (nextIndex == 0) {
      // Config für Re-Shuffle berechnen
      final now = DateTime.now();
      final srs = ref.read(srsModeControllerProvider).mode;
      final dueCount = queue.where((w) => isDueNow(w, now, srsSystem: srs)).length;
      
      final stats = SrsStats(
        rollingAccuracy: _rollingAccuracy,
        avgSwipeMs: _avgSwipeMs,
        recentTimeouts: _recentTimeouts,
      );

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: stats,
      );

      final allowedMaxStage = (srs == SrsSystem.adaptive) 
          ? 5 
          : _computeAllowedMaxStageFromQueue(queue);
      final shuffled = buildSmartCardOrder(queue, config: cfg, allowedMaxStage: allowedMaxStage);
      
      // Debug-Log für Re-Shuffle
      final reshufflePreview = shuffled.take(40).map((ix) => queue[ix]).toList();
      final reshuffleNewCount = reshufflePreview.where((w) => w.srsStage == 0).length;
      final reshuffleDueCount = reshufflePreview.where((w) => isDueNow(w, DateTime.now(), srsSystem: srs)).length;
      print('🔄 Re-Shuffle[40]: new=$reshuffleNewCount, due=$reshuffleDueCount, total=${reshufflePreview.length}');
      
      _set(shuffledWordIds: [for (final k in shuffled) queue[k].id]);
    }

    // 7b) Mini-Reshuffle nach dem „Burst" (z. B. nach 10 Swipes)
    final shouldMiniReshuffle = state.cardsSwipedInSession == 10 ||
                                (state.cardsSwipedInSession > 10 &&
                                 state.cardsSwipedInSession % 8 == 0); // danach regelmäßig

    if (shouldMiniReshuffle) {
      final now = DateTime.now();
      final srs = ref.read(srsModeControllerProvider).mode;
      final dueCount = state.wordQueue.where((w) => isDueNow(w, now, srsSystem: srs)).length;

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: SrsStats(
          rollingAccuracy: _rollingAccuracy,
          avgSwipeMs: _avgSwipeMs,
          recentTimeouts: _recentTimeouts,
        ),
      );

      final allowedMaxStage = (srs == SrsSystem.adaptive) 
          ? 5 
          : _computeAllowedMaxStageFromQueue(state.wordQueue);
      final newOrderIdx = buildSmartCardOrder(state.wordQueue, config: cfg, allowedMaxStage: allowedMaxStage);
      final newIds = [for (final i in newOrderIdx) state.wordQueue[i].id];

      // Index auf gleiche Karte (per id) abbilden, damit kein Sprung sichtbar ist
      final currentId = state.shuffledWordIds[state.index];
      final newIndex = newIds.indexOf(currentId);
      final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
          ? state.wordQueue.firstWhere((w) => w.id == currentId, orElse: () => state.wordQueue.first).srsStage
          : -1;
      final finalIndex = newIndex >= 0 ? newIndex : 0;
      final nextStage = newIds.isNotEmpty && finalIndex < newIds.length
          ? state.wordQueue.firstWhere((w) => w.id == newIds[finalIndex], orElse: () => state.wordQueue.first).srsStage
          : -1;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$finalIndex (Stage=$nextStage) at=${StackTrace.current}');
      _set(shuffledWordIds: newIds, index: finalIndex);
      
      print('🔄 Mini-Reshuffle nach ${state.cardsSwipedInSession} Swipes');
    }

    // 8) Timer-Verhalten wie gewünscht:
    //    - Wenn der Timer zuvor aktiv war:
    //        * Wenn pausiert: nur Restzeit für neue Karte setzen, PAUSE bleibt.
    //        * Wenn laufend: Restzeit resetten und weiterlaufen.
    //    - Wenn Timer zuvor NICHT aktiv war: NICHT starten.
    _restartCountdownPreservingState(
      wasActive: wasActive,
      wasPaused: wasPaused,
      wasRunning: wasRunning,
    );

    // 9) S0 Cooldown und Advance Logic
    if (srsSystem == SrsSystem.adaptive) {
      // A-SRS: Keine _advanceToNextEligible, Navigation wurde bereits in Schritt 5 erledigt
      _tickCooldowns();
    } else {
      // T-SRS/Hybrid: Bestehende Logik
    if (correct) {
      // Richtig: normal weiter
      _tickCooldowns();
      _advanceToNextEligible(avoidId: currentId);
    } else {
      // Falsch: aktuelle Karte hinten re-queuen, S0 bekommt Cooldown
      final oldIndex = state.shuffledWordIds.indexOf(currentId);
      if (oldIndex != -1) {
        final newShuffled = List<String>.from(state.shuffledWordIds);
        newShuffled.removeAt(oldIndex);
        newShuffled.add(currentId);
          final updatedDeckStages = _computeDeckStages(newShuffled, state.wordQueue);
          _set(shuffledWordIds: newShuffled, deckStages: updatedDeckStages);
      }

      // Nur bei S0 Cooldown starten
      _startCooldownIfNeeded(currentId);

      // Index auf aktuelle Position clampen
      final newIndex = state.index % state.shuffledWordIds.length;
        final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
            ? state.wordQueue.firstWhere((w) => w.id == state.shuffledWordIds[state.index], orElse: () => state.wordQueue.first).srsStage
            : -1;
        final nextStage = state.wordQueue.isNotEmpty && newIndex < state.wordQueue.length
            ? state.wordQueue.firstWhere((w) => w.id == state.shuffledWordIds[newIndex], orElse: () => state.wordQueue.first).srsStage
            : -1;
        print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=$newIndex (Stage=$nextStage) at=${StackTrace.current}');
      _set(index: newIndex);

      // Eine "andere Karte" wird als nächstes gezeigt → Cooldowns ticken schon JETZT
      _tickCooldowns();

      // Wähle die nächste Karte, die nicht im Cooldown ist
      _advanceToNextEligible(avoidId: currentId);
      }
    }

    // 10) lokalen Fortschritt speichern
    await _persistStageData();

    // 11) Stage-Transition Event feuern
    print('🎯 EMIT StageEvent cat=${state.categoryId} word=$currentId from=$oldStage to=$serverStage due=$isDueNowValue');
    StageTransitionEvent.emit(StageTransitionEvent(
      categoryId: state.categoryId,
      wordId: currentId,
      fromStage: oldStage,
      toStage: serverStage,
      wasDueBefore: isDueNowValue,
    ));

    // ✅ FIX: ActiveStage darf nicht auf eine Queue zeigen, die leer ist (für T-SRS/Hybrid)
    final safeStage = _firstNonEmptyStageOr(state.activeStage);
    if (safeStage != state.activeStage) {
      print('🔧 _handleAnswer (T-SRS/Hybrid): activeStage ${state.activeStage} -> $safeStage (Queue-basiert)');
      _set(activeStage: safeStage);
    }

    _set(isSubmitting: false);
  } finally {
    print('🔴 _handleAnswer FINALLY runId=$runId index=${state.index}');
    _set(isSubmittingReview: false);
  }
  }

  // ---- Timer ----

  /// Startet den Timer explizit (Play-Button).
  /// - forceActive: true => setzt timerActive/running = true
  void _startWordTimer({bool forceActive = false}) {
    _wordTimer?.cancel();

    final shouldBeActive = forceActive || state.timerActive;
    final keepPaused = state.timerPaused && !forceActive;

    _set(
      remainingMillis: state.timeLimit * 1000.0,
      timerPaused: keepPaused,
      timerActive: shouldBeActive,
      running: keepPaused ? false : true,
    );

    // Nur ticken, wenn nicht pausiert UND aktiv
    if (!keepPaused && shouldBeActive) {
      const tick = Duration(milliseconds: 16);
      _wordTimer = Timer.periodic(tick, (t) {
        if (state.timerPaused) return;

        final left = state.remainingMillis - 16;
        if (left <= 0) {
          t.cancel();
          HapticFeedback.mediumImpact();
          // Zeit abgelaufen -> als falsch werten
          _handleAnswer(correct: false);
        } else {
          _set(remainingMillis: left);
        }

        // ✅ Hybrid: Stage-Tagesbudget ticken (nur wenn wirklich "laufend")
        if (ref.read(srsModeControllerProvider).mode == SrsSystem.hybrid && state.running && state.timerActive && !state.timerPaused) {
          _tickHybridStageBudget(deltaMs: 16);
        }
      });
    }
  }

  void _tickHybridStageBudget({required int deltaMs}) {
    // Lazy load budgets once we have a category.
    if (state.categoryId.isEmpty) return;
    // Wichtig: Budget muss an der *aktuellen Karte* hängen, nicht an activeStage.
    // In s0toS5 kann activeStage vom aktuell angezeigten Wort abweichen -> dann würde nie getickt.
    int st = state.activeStage;
    if (state.shuffledWordIds.isNotEmpty &&
        state.index >= 0 &&
        state.index < state.shuffledWordIds.length &&
        state.wordQueue.isNotEmpty) {
      final currentId = state.shuffledWordIds[state.index];
      for (final w in state.wordQueue) {
        if (w.id == currentId) {
          st = w.srsStage;
          break;
        }
      }
    }
    // S0 hat kein Budget. Wir zählen nur Stages, die tatsächlich ein Tagesbudget haben.
    st = st.clamp(0, 5);
    final budgetSec = _hybridDailyBudgetSecByStage[st];
    if (budgetSec == null) return;

    final now = DateTime.now();
    final dayStart = _localDayStart(now);
    if (_hybridBudgetDayStartLocal == null || _hybridBudgetDayStartLocal != dayStart) {
      // day rollover; reset (async reload later)
      _hybridBudgetDayStartLocal = dayStart;
      _hybridUsedMsByStage.clear();
    }

    final used = (_hybridUsedMsByStage[st] ?? 0) + deltaMs;
    _hybridUsedMsByStage[st] = used;
    _hybridPersistAccumulatorMs += deltaMs;
    _hybridUiAccumulatorMs += deltaMs;

    // UI nur ca. 1× pro Sekunde updaten (sonst rebuild spam)
    if (_hybridUiAccumulatorMs >= 1000) {
      _hybridUiAccumulatorMs = 0;
      _recomputeHybridBudgetState(now: now);

      // Wenn Stage eingefroren wurde, wechsle automatisch auf nächste Stage mit Karten
      if (st >= 1 && st < state.hybridStageFrozen.length && state.hybridStageFrozen[st]) {
        // Rebuild stage queues zählen auf state.stages; wir nutzen die vorhandene Validierung + Sync.
        unawaited(_ensureValidActiveStageAndSync(shuffle: false));
      }
    }

    // Persist max 1× pro Sekunde
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      unawaited(_persistHybridBudgetsMaybe(userId: userId, categoryId: state.categoryId));
    }
  }

  /// Für den Kartenwechsel: nur die Restzeit auf neue Karte setzen.
  /// Startet den Ticker nur, wenn der Timer vorher aktiv UND nicht pausiert war.
  void _restartCountdownPreservingState({
    required bool wasActive,
    required bool wasPaused,
    required bool wasRunning,
  }) {
    _wordTimer?.cancel();

    if (!wasActive) {
      // Timer war nicht aktiv -> nur Remaining resetten, aber nicht aktivieren
      _set(
        remainingMillis: state.timeLimit * 1000.0,
        timerActive: false,
        timerPaused: false,
        running: false,
      );
      return;
    }

    // Timer war aktiv -> Restzeit auf neue Karte setzen
    _set(
      remainingMillis: state.timeLimit * 1000.0,
      timerActive: true,
      timerPaused: wasPaused,
      running: wasPaused ? false : wasRunning,
    );

    // Nur tick starten, wenn NICHT pausiert
    if (!wasPaused && wasRunning) {
    const tick = Duration(milliseconds: 16);
    _wordTimer = Timer.periodic(tick, (t) {
      if (state.timerPaused) return;
      final left = state.remainingMillis - 16;
      if (left <= 0) {
        t.cancel();
        HapticFeedback.mediumImpact();
        _handleAnswer(correct: false);
      } else {
        _set(remainingMillis: left);
      }
    });
    }
  }

  void _stopTimer() {
    _wordTimer?.cancel();
    _set(
      timerActive: false,
      timerPaused: false,
      running: false,
      remainingMillis: state.timeLimit * 1000.0,
    );
  }

  // ---- S0 Cooldown Logic ----

  void _startCooldownIfNeeded(String wordId) {
    // Cooldown nur für S0
    final word = state.wordQueue.firstWhere((w) => w.id == wordId, orElse: () => state.wordQueue.first);
    final stage = word.srsStage;
    if (stage == 0) {
      final cur = _cooldown[wordId] ?? 0;
      _cooldown[wordId] = cur > 0 ? (cur > _s0MinOthers ? cur : _s0MinOthers) : _s0MinOthers;
    }
  }

  void _tickCooldowns() {
    if (_cooldown.isEmpty) return;
    final keys = List<String>.from(_cooldown.keys);
    for (final k in keys) {
      final next = (_cooldown[k] ?? 0) - 1;
      
      if (next <= 0) {
        _cooldown.remove(k);
      } else {
        _cooldown[k] = next;
      }
    }
  }

  /// Setzt _index auf die nächste Karte, die nicht im Cooldown ist.
  /// avoidId: die eben geswipte Karte soll nicht sofort wieder kommen.
  /// WICHTIG: Verwendet nur Stages, die tatsächlich in der Queue vorhanden sind.
  void _advanceToNextEligible({String? avoidId}) {
    final len = state.shuffledWordIds.length;
    if (len == 0) {
      final currentStage = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
          ? state.wordQueue[state.index].srsStage
          : -1;
      print('🧨 STAGE SET from=${state.index} (Stage=$currentStage) -> to=0 (empty queue) at=${StackTrace.current}');
      print('🧨 INDEX-RESET auf 0 in _advanceToNextEligible (empty queue): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
      _set(index: 0);
      return;
    }
    
    int currentIndex = state.index % len; // Sicherheit
    final oldIndex = currentIndex;
    
    // Aktuelle Stage aus der aktuellen Karte ableiten
    final currentWord = state.wordQueue.isNotEmpty && oldIndex < state.wordQueue.length
        ? state.wordQueue.firstWhere((w) => w.id == state.shuffledWordIds[oldIndex], orElse: () => state.wordQueue.first)
        : null;
    final currentStage = currentWord?.srsStage.clamp(0, 5) ?? -1;
    
    // Bestimme eligible Stages aus der Queue (nur was wirklich vorhanden ist)
    final srs = ref.read(srsModeControllerProvider).mode;
    final mode = ref.read(levelSelectionProvider);
    
    // allowedMaxStage wie bisher (A-SRS = 5, sonst Gate)
    final allowedMaxStage = (srs == SrsSystem.adaptive) 
        ? 5 
        : _computeAllowedMaxStageFromQueue(state.wordQueue);
    
    final eligibleStages = _eligibleStagesFromQueue(
      queue: state.wordQueue,
      mode: mode,
      allowedMaxStage: allowedMaxStage,
    );
    
    if (eligibleStages.isEmpty) {
      // keine Karten => nichts umschalten
      print('⚠️ Keine eligible Stages in Queue, Session beendet');
      return;
    }
    
    // Wenn aktuelle Stage nicht mehr existiert => auf erste gültige springen
    if (currentStage < 0 || !eligibleStages.contains(currentStage)) {
      // Suche erste Karte in der ersten eligible Stage
      final targetStage = eligibleStages.first;
      int tries = 0;
      bool found = false;
      int startIdx = (currentIndex + 1) % len;
      
      // Suche von aktueller Position vorwärts
      for (var checkIdx = startIdx; checkIdx < len && tries < len; checkIdx++) {
        final checkId = state.shuffledWordIds[checkIdx];
        final checkWord = state.wordQueue.firstWhere((w) => w.id == checkId, orElse: () => state.wordQueue.first);
        final blocked = (_cooldown[checkId] ?? 0) > 0 || (avoidId != null && checkId == avoidId);
        if (!blocked && checkWord.srsStage == targetStage) {
          currentIndex = checkIdx;
          found = true;
          break;
        }
        tries++;
      }
      
      // Falls nicht gefunden, suche von Anfang an
      if (!found) {
        for (var checkIdx = 0; checkIdx < startIdx && tries < len; checkIdx++) {
          final checkId = state.shuffledWordIds[checkIdx];
          final checkWord = state.wordQueue.firstWhere((w) => w.id == checkId, orElse: () => state.wordQueue.first);
          final blocked = (_cooldown[checkId] ?? 0) > 0 || (avoidId != null && checkId == avoidId);
          if (!blocked && checkWord.srsStage == targetStage) {
            currentIndex = checkIdx;
            found = true;
            break;
          }
          tries++;
        }
      }
      
      if (found) {
        print('✅ Springe zu erster eligible Stage $targetStage (Index $currentIndex)');
        print('🧨 STAGE SET from=$oldIndex (Stage=$currentStage) -> to=$currentIndex (Stage=$targetStage) at=${StackTrace.current}');
        _set(index: currentIndex.clamp(0, len - 1));
        return;
      }
    }
    
    // Aktuelle Stage ist eligible → nächste Stage mit Karten finden (zyklisch)
    if (currentStage >= 0 && currentStage <= 5 && eligibleStages.contains(currentStage)) {
      final nextStage = _nextStage(currentStage, state.deckStages);
      
      // Finde nächste Karte in der Queue, die in nextStage ist
      int tries = 0;
      bool found = false;
      int startIdx = (currentIndex + 1) % len;
      
      // Suche von aktueller Position vorwärts
      for (var checkIdx = startIdx; checkIdx < len && tries < len; checkIdx++) {
        final checkId = state.shuffledWordIds[checkIdx];
        final checkWord = state.wordQueue.firstWhere((w) => w.id == checkId, orElse: () => state.wordQueue.first);
        final blocked = (_cooldown[checkId] ?? 0) > 0 || (avoidId != null && checkId == avoidId);
        if (!blocked && checkWord.srsStage == nextStage) {
          currentIndex = checkIdx;
          found = true;
          break;
        }
        tries++;
      }
      
      // Falls nicht gefunden, suche von Anfang an
      if (!found) {
        for (var checkIdx = 0; checkIdx < startIdx && tries < len; checkIdx++) {
          final checkId = state.shuffledWordIds[checkIdx];
          final checkWord = state.wordQueue.firstWhere((w) => w.id == checkId, orElse: () => state.wordQueue.first);
          final blocked = (_cooldown[checkId] ?? 0) > 0 || (avoidId != null && checkId == avoidId);
          if (!blocked && checkWord.srsStage == nextStage) {
            currentIndex = checkIdx;
            found = true;
            break;
          }
          tries++;
        }
      }
      
      if (found) {
        print('✅ Springe zu nächster Stage $nextStage (Index $currentIndex)');
        print('🧨 STAGE SET from=$oldIndex (Stage=$currentStage) -> to=$currentIndex (Stage=$nextStage) at=${StackTrace.current}');
        _set(index: currentIndex.clamp(0, len - 1));
        return;
      }
    }
    
    // Fallback: Normale Cooldown-Logik (nächste nicht-blockierte Karte)
    int tries = 0;
    while (tries < len) {
      final candidateId = state.shuffledWordIds[currentIndex];
      final blocked = (_cooldown[candidateId] ?? 0) > 0 || (avoidId != null && candidateId == avoidId);
      if (!blocked) break;
      currentIndex = (currentIndex + 1) % len;
      tries++;
    }

    final nextWord = state.wordQueue.isNotEmpty && currentIndex < state.wordQueue.length
        ? state.wordQueue.firstWhere((w) => w.id == state.shuffledWordIds[currentIndex], orElse: () => state.wordQueue.first)
        : null;
    final nextStage = nextWord?.srsStage.clamp(0, 5) ?? -1;
    
    print('🧨 STAGE SET from=$oldIndex (Stage=$currentStage) -> to=$currentIndex (Stage=$nextStage) at=${StackTrace.current}');
    _set(index: currentIndex.clamp(0, len - 1));
  }

  void _scheduleImmediateReinforce(String wordId, {int after = 8}) {
    final ids = List<String>.from(state.shuffledWordIds);
    final curPos = ids.indexOf(wordId);
    if (curPos == -1 || ids.isEmpty) return;

    // Karte an Position „index + after" verschieben (wrap-around)
    ids.removeAt(curPos);
    final insertAt = ((state.index + after) % (ids.length + 1)).clamp(0, ids.length);
    ids.insert(insertAt, wordId);

    _set(shuffledWordIds: ids);
  }

  /// Für S0-Karten auch bei KORREKT einen Cooldown zählen,
  /// damit sie NICHT sofort wieder direkt nebenan auftauchen.
  void _startCooldownForS0(String wordId, {int minOthers = 8}) {
    final cur = _cooldown[wordId] ?? 0;
    _cooldown[wordId] = (cur > 0) ? (cur > minOthers ? cur : minOthers) : minOthers;
  }

  int _computeAllowedMaxStageFromQueue(List<WordUserView> queue) {
    // Alle Modi: Keine Sperre, alle Stages T0–T5 / H0–H5 / A0–A5 erlaubt
    return 5;
  }

  // ---- Helpers ----

  /// Berechnet die Stage-Counts aus der aktuellen Queue (nur verfügbare Karten)
  /// Zählt Stages aus einer WordQueue.
  /// Gibt [S0, S1, S2, S3, S4, S5] zurück basierend auf den srsStage-Werten der Wörter.
  List<int> _countStagesFromQueue(List<WordUserView> q) {
    final counts = List<int>.filled(6, 0);
    for (final w in q) {
      final s = w.srsStage.clamp(0, 5);
      counts[s]++;
    }
    return counts;
  }

  /// Helper: Zählt Stages aus einer Liste von Wörtern
  /// Returns: [S0, S1, S2, S3, S4, S5]
  List<int> _countStages(List<WordUserView> words) {
    return _countStagesFromQueue(words);
  }

  /// Wendet ein Stage-Delta auf die bestehenden Stages an.
  /// Für A-SRS: Nur Delta-basierte Updates, keine Queue-Neuberechnung.
  /// oldStages: [S0, S1, S2, S3, S4, S5] - die aktuellen Stages
  /// from: 0..5 - die alte Stage (wird dekrementiert)
  /// to: 0..5 - die neue Stage (wird inkrementiert)
  List<int> _applyStageDelta({
    required List<int> oldStages,
    required int from,
    required int to,
  }) {
    final newStages = List<int>.from(oldStages);
    if (from >= 0 && from <= 5) {
      newStages[from] = (newStages[from] - 1).clamp(0, 1 << 30);
    }
    if (to >= 0 && to <= 5) {
      newStages[to] = newStages[to] + 1;
    }
    return newStages;
  }

  /// Berechnet ein lokales Progress-Delta auf Basis eines gegebenen Stages-Arrays.
  /// Gibt die neue Liste zurück. Setzt NICHT selbst den State.
  List<int> _applyLocalProgressDelta({
    required List<int> stages,
    required int oldStage,
    required int newStage,
  }) {
    final updated = List<int>.from(stages);

    if (oldStage >= 0 && oldStage < updated.length) {
      updated[oldStage] = (updated[oldStage] - 1).clamp(0, 1 << 30);
    }
    if (newStage >= 0 && newStage < updated.length) {
      updated[newStage] = updated[newStage] + 1;
    }

    return updated;
  }

  /// Findet alle eligible Stages aus der Queue basierend auf Mode und allowedMaxStage.
  /// Gibt nur Stages zurück, die tatsächlich in der Queue vorhanden sind.
  List<int> _eligibleStagesFromQueue({
    required List<WordUserView> queue,
    required LevelSelectionMode mode,
    required int allowedMaxStage,
  }) {
    // Welche Stages sind in der Queue wirklich vorhanden?
    final present = <int>{};
    for (final w in queue) {
      final stage = w.srsStage.clamp(0, 5);
      if (stage >= 0 && stage <= 5) {
        present.add(stage);
      }
    }

    // Welche Stages sind laut Mode erlaubt?
    int minStage = 0;
    if (mode == LevelSelectionMode.s1toS5 || mode == LevelSelectionMode.single) {
      minStage = 1;
    }

    final eligible = <int>[];
    for (int st = minStage; st <= allowedMaxStage; st++) {
      if (present.contains(st)) eligible.add(st);
    }

    eligible.sort();
    return eligible;
  }

  /// Helper: Findet ein Wort in der Queue anhand der ID (sicher, gibt null zurück wenn nicht gefunden).
  WordUserView? _findWordById(String id, List<WordUserView> wordQueue) {
    for (final w in wordQueue) {
      if (w.id == id) return w;
    }
    return null;
  }

  /// Berechnet deckStages aus shuffledWordIds und wordQueue.
  /// Gibt [S0, S1, S2, S3, S4, S5] zurück basierend auf den aktuell geladenen Karten.
  List<int> _computeDeckStages(List<String> shuffledWordIds, List<WordUserView> wordQueue) {
    final deckStages = List<int>.filled(6, 0);
    for (final id in shuffledWordIds) {
      final word = _findWordById(id, wordQueue);
      if (word == null) {
        print('⚠️ missing word in wordQueue: $id');
        continue;
      }
      final stage = word.srsStage.clamp(0, 5);
      if (stage >= 0 && stage <= 5) {
        deckStages[stage]++;
      }
    }
    return deckStages;
  }

  List<int> _computeStageCountsFromQueue(List<WordUserView> queue, List<String> ids) {
    final counts = [0, 0, 0, 0, 0, 0];
    for (final id in ids) {
      final word = _findWordById(id, queue);
      if (word == null) {
        print('⚠️ missing word in queue: $id');
        continue;
      }
      final stage = word.srsStage;
      if (stage >= 0 && stage <= 5) {
        counts[stage]++;
      }
    }
    return counts;
  }

  /// Prüft, ob eine Stage Karten im aktuellen Deck hat.
  /// stage: 0..5
  /// Verwendet deckStages (nur geladene Karten), nicht stages (CategoryProgress).
  bool _hasAnyInStage(int stage) {
    if (stage < 0 || stage >= state.deckStages.length) return false;
    return state.deckStages[stage] > 0;
  }

  /// Findet die nächste Stage mit Karten im aktuellen Deck, beginnend von startFrom.
  /// startFrom: 0..5 (die Start-Stage)
  /// Gibt die nächste Stage mit count > 0 zurück, oder null wenn keine gefunden.
  /// Verwendet deckStages (nur geladene Karten), nicht stages (CategoryProgress).
  int? _findNextStageWithCards({required int startFrom}) {
    for (var i = 0; i < 6; i++) {
      final s = (startFrom + i) % 6;
      if (state.deckStages[s] > 0) return s;
    }
    return null;
  }

  /// Findet die nächste nicht-leere Stage ab current (zyklisch).
  /// stages: [S0,S1,S2,S3,S4,S5] => index 0..5
  /// current: 0..5 (die aktuelle Stage)
  /// Gibt die nächste Stage mit count > 0 zurück (zyklisch), oder current wenn nichts gefunden.
  int _nextStage(int current, List<int> stages) {
    for (int i = 1; i <= 6; i++) {
      final s = (current + i) % 6;
      if (stages[s] > 0) return s;
    }
    return current;
  }

  /// A-SRS Stage-Navigation: Bleib in derselben Stage, solange dort Karten > 0 sind.
  /// Wechsle Stage NUR, wenn stages[current] == 0.
  /// current: 0..5 (die aktuelle Stage)
  /// stages: [S0,S1,S2,S3,S4,S5] => index 0..5
  int _nextStageA(int current, List<int> stages) {
    if (stages[current] > 0) return current;

    for (int s = current + 1; s < 6; s++) {
      if (stages[s] > 0) return s;
    }
    return 0; // Fallback
  }

  /// Findet die erste nicht-leere Stage in einer Liste von Counts.
  /// counts: [S0,S1,S2,S3,S4,S5] => index 0..5
  /// fallback: Standard-Wert wenn alle Stages leer sind
  int _firstNonEmptyStage(List<int> counts, {int fallback = 0}) {
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] > 0) return i;
    }
    return fallback;
  }

  /// Findet die erste nicht-leere Stage in einer Liste von Stages (für activeStage-Validierung).
  /// stages: [S0,S1,S2,S3,S4,S5] => index 0..5
  int _firstNonEmptyStageIndex(List<int> stages) {
    for (var i = 0; i < stages.length; i++) {
      if (stages[i] > 0) return i;
    }
    return 0; // fallback
  }

  /// Clampt einen gewünschten Stage-Index auf eine nicht-leere Stage.
  /// wanted: 0..5 (der gewünschte Stage-Index)
  /// stages: [S0,S1,S2,S3,S4,S5] => index 0..5
  int _clampToNonEmptyStage({
    required int wanted,
    required List<int> stages,
  }) {
    if (wanted >= 0 && wanted < stages.length && stages[wanted] > 0) {
      return wanted;
    }
    return _firstNonEmptyStageIndex(stages);
  }

  /// Stellt sicher, dass activeStage immer auf eine Stage mit count > 0 zeigt.
  void _ensureValidActiveStage() {
    final srs = ref.read(srsModeControllerProvider).mode;

    // ✅ A-SRS: activeStage muss zu den Session-Queues passen (nicht zu CategoryProgress)
    if (srs == SrsSystem.adaptive) {
      final current = state.activeStage.clamp(0, 5);

      if (_stageQueues[current].isNotEmpty) return;

      final fallback = _firstNonEmptyStageOr(current);
      if (fallback != current) {
        print('🔧 _ensureValidActiveStage(A): $current -> $fallback (stageQueues: ${_stageQueues.map((q) => q.length).toList()})');
        _set(activeStage: fallback);
      }
      return;
    }

    // ✅ T-SRS/Hybrid: bisherige Logik über state.stages ok
    final stages = state.stages;
    if (stages.isEmpty) return;

    final fixed = _clampToNonEmptyStage(
      wanted: state.activeStage,
      stages: stages,
    );

    if (fixed != state.activeStage) {
      print('🔧 _ensureValidActiveStage(T/H): ${state.activeStage} -> $fixed (stages: $stages)');
      _set(activeStage: fixed);
    }
  }

  /// Setzt Stages und normalisiert activeStage automatisch.
  /// Verhindert Sprung auf leere Stage nach Stages-Update.
  void _setStages(List<int> newStages) {
    _set(stages: newStages);
    
    // ✅ FIX: verhindert Sprung auf leere Stage
    _normalizeActiveStage();
  }

  /// Baut die Stage-Queues aus den aktuellen Wörtern neu auf.
  void _rebuildStageQueuesFromCurrentWords(List<WordUserView> words) {
    for (final q in _stageQueues) {
      q.clear();
    }

    // Nimm DIESELBE Word-Liste, aus der du aktuell auch shuffledWordIds baust
    for (final w in words) {
      final s = w.srsStage.clamp(0, 5);
      _stageQueues[s].add(w.id);
    }

    // Optional: shuffle je Stage, wenn du willst
    for (final q in _stageQueues) {
      q.shuffle();
    }
    print('🔧 _rebuildStageQueuesFromCurrentWords: Stage-Queues gefüllt. Längen: ${_stageQueues.map((q) => q.length).toList()}');
    
    print('🔄 Stage-Queues neu aufgebaut: ${_stageQueues.map((q) => q.length).toList()}');
  }

  /// Verschiebt eine Word-ID zwischen Stage-Queues.
  void _moveWordIdQueue({
    required String wordId,
    required int fromStage,
    required int toStage,
  }) {
    final from = fromStage.clamp(0, 5);
    final to = toStage.clamp(0, 5);

    if (from == to) return;

    _stageQueues[from].remove(wordId);
    if (!_stageQueues[to].contains(wordId)) {
      _stageQueues[to].insert(0, wordId); // vorne rein -> fühlt sich "frisch" an
    }
    
    print('🔄 Word-ID verschoben: $wordId von Stage $from -> Stage $to (Queues: ${_stageQueues.map((q) => q.length).toList()})');
  }

  /// Findet die erste nicht-leere Stage oder gibt den Fallback zurück.
  int _firstNonEmptyStageOr(int fallback) {
    for (var s = 0; s < _stageQueues.length; s++) {
      if (_stageQueues[s].isNotEmpty) return s;
    }
    return fallback.clamp(0, 5);
  }

  /// Normalisiert activeStage, sodass es immer auf eine nicht-leere Stage zeigt.
  /// Verwendet _stageQueues (Deck!) statt state.stages.
  void _normalizeActiveStage() {
    final current = state.activeStage.clamp(0, 5);
    
    // Wenn stageQueues[current] nicht leer ist → nichts ändern
    if (current >= 0 && current < _stageQueues.length && _stageQueues[current].isNotEmpty) {
      return;
    }

    // Sonst: finde kleinsten i mit stageQueues[i] > 0
    int? nextIndex;
    for (var i = 0; i < _stageQueues.length; i++) {
      if (_stageQueues[i].isNotEmpty) {
        nextIndex = i;
        break;
      }
    }

    // Wenn keiner gefunden → activeStage bleibt wie er ist
    if (nextIndex != null && nextIndex != current) {
      print('🔧 _normalizeActiveStage: $current -> $nextIndex (stageQueues: ${_stageQueues.map((q) => q.length).toList()})');
      _set(activeStage: nextIndex);
    }
  }

  /// Validiert die aktive Stage (springt auf erste nicht-leere, falls leer) und synchronisiert das Deck.
  /// Wird beim Start/Refresh in A-SRS aufgerufen, um sicherzustellen, dass activeStage auf einer Stage mit Karten steht.
  Future<void> _ensureValidActiveStageAndSync({bool shuffle = true}) async {
    final counts = state.stages; // [S0,S1,S2,S3,S4,S5]
    if (counts.isEmpty) {
      print('⚠️ _ensureValidActiveStageAndSync: Stages leer, überspringe');
      return;
    }

    // Wenn aktive Stage leer ist -> erste nicht-leere wählen
    final current = state.activeStage;
    int target = current;

    final currentCountRaw = (current >= 0 && current < counts.length) ? counts[current] : 0;
    final isHybrid = ref.read(srsModeControllerProvider).mode == SrsSystem.hybrid;
    final isFrozen = isHybrid &&
        current >= 0 &&
        current < state.hybridStageFrozen.length &&
        state.hybridStageFrozen[current] == true;
    final currentCount = isFrozen ? 0 : currentCountRaw;
    print('🔧 _ensureValidActiveStageAndSync: current=$current, currentCount=$currentCount, counts=$counts');
    
    if (currentCount == 0) {
      target = counts.indexWhere((c) => c > 0);
      // Hybrid: gefrorene Stages überspringen
      if (isHybrid) {
        for (var i = 0; i < counts.length; i++) {
          if (counts[i] > 0 &&
              i < state.hybridStageFrozen.length &&
              state.hybridStageFrozen[i] == false) {
            target = i;
            break;
          }
        }
      }
      if (target == -1) {
        target = 0; // alles leer -> S0 als Default
        print('⚠️ _ensureValidActiveStageAndSync: Alle Stages leer, setze auf S0');
      } else {
        print('🔧 _ensureValidActiveStageAndSync: Stage $current leer, springe zu Stage $target (count=${counts[target]})');
      }
      
      if (target != state.activeStage) {
        _set(activeStage: target);
        print('✅ _ensureValidActiveStageAndSync: activeStage geändert: $current -> $target');
      }
    } else {
      print('✅ _ensureValidActiveStageAndSync: Stage $current hat $currentCount Karten, bleibt aktiv');
    }

    // Deck synchronisieren
    await _syncDeckToActiveStage(shuffle: shuffle);
  }

  /// Setzt den Index nach einem Review fort, wenn die Stage gleich bleibt.
  /// Verhindert, dass der Index wieder bei 0 landet.
  Future<void> _advanceIndexAfterReview({required int fromIndex}) async {
    final deckLen = state.shuffledWordIds.length;
    if (deckLen == 0) return;

    final nextIndex = fromIndex + 1;

    // Normal weiter
    if (nextIndex < deckLen) {
      _set(index: nextIndex);
      print('🔄 _advanceIndexAfterReview: index $fromIndex -> $nextIndex (Deck-Größe: $deckLen)');
      return;
    }

    // ✅ Deck-Ende -> neues Deck bauen (nahtlos)
    print('🏁 Deck finished: index $fromIndex -> $nextIndex (len=$deckLen), baue neues Deck...');
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    
    if (srsSystem == SrsSystem.adaptive) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('⚠️ _advanceIndexAfterReview: Kein User eingeloggt für A-SRS');
        _set(
          running: false,
          timerActive: false,
          timerPaused: false,
          wordQueue: const [],
          shuffledWordIds: const [],
          index: 0,
        );
        return;
      }

      // ✅ VOR dem Laden: Stages prüfen – bei nur S5 KEIN Auto-Deck, sondern Final Round Button
      final progressReqId = ++_progressRequestId;
      print('📡 progress fetch START reqId=$progressReqId');
      final progress = await _repo.fetchCategoryProgress(state.categoryId!, srsSystem: SrsSystem.adaptive);
      print('📡 progress fetch DONE reqId=$progressReqId stages=${progress.stages}');
      if (progressReqId != _progressRequestId) {
        print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
        return;
      }
      final stages = progress.stages;
      final hasOpenA1ToA4 = stages.length >= 5 &&
          (stages[1] > 0 || stages[2] > 0 || stages[3] > 0 || stages[4] > 0);
      final hasStage5 = stages.length > 5 && stages[5] > 0;

      if (!state.finalPassActive && !hasOpenA1ToA4 && hasStage5) {
        // Kein Auto-Deck bauen – Final Round verfügbar
        print('🏁 A-SRS: Nur S5 übrig → Final Round Button, kein Auto-Deck');
        _set(
          showFinalStartButton: true,
          wordQueue: const [],
          shuffledWordIds: const [],
          index: 0,
        );
        return;
      }

      // ✅ Final Round: Kein Deck-Rebuild – wordQueue/shuffledWordIds beibehalten (Re-Inserts bleiben)
      // Nur deckStages und index aktualisieren
      if (state.finalPassActive) {
        final deckStages = _computeDeckStages(state.shuffledWordIds, state.wordQueue);
        _set(deckStages: deckStages, index: 0);
        print('✅ A-SRS Final Round: Deck beibehalten, nur deckStages aktualisiert, index auf 0');
        return;
      }

      if (state.index < state.shuffledWordIds.length - 1) {
        return;
      }

      await _ensureA_SrsRefill();
      
      var queue = await _repo.fetchAdaptiveQueue(
        userId: userId,
        categoryId: state.categoryId!,
        limit: 80,
      );

      // ✅ Normale Phase: S5 NICHT laden (nur A1–A4)
      queue = queue.where((w) => (w.srsStage ?? 0) < 5).toList();
      
      if (queue.isEmpty) {
        // Nach Filter leer: ggf. Final Round (nur S5 übrig)
        if (hasStage5) {
          print('🏁 A-SRS: Queue leer nach Filter → Final Round Button');
          _set(
            showFinalStartButton: true,
            wordQueue: const [],
            shuffledWordIds: const [],
            index: 0,
          );
        } else {
          print('🏁 Keine weiteren Karten verfügbar, Session beendet');
          _set(
            running: false,
            timerActive: false,
            timerPaused: false,
            wordQueue: const [],
            shuffledWordIds: const [],
            index: 0,
          );
        }
        return;
      }
      
      // ✅ Wichtig: Reihenfolge genau wie Server (kein Shuffle!)
      final newIds = queue.map((w) => w.id).toList();
      final deckStages = _countStages(queue);
      _set(
        wordQueue: queue,
        shuffledWordIds: newIds,
        deckStages: deckStages,
        index: 0,
      );
      print('✅ A-SRS Deck-Rebuild: Server-Queue geladen, ${newIds.length} Karten, deckStages=$deckStages');
      return;
    }
    
    // T-SRS/Hybrid: Normaler Flow mit _buildNextDeckIds
    final newIds = await _buildNextDeckIds();

    if (newIds.isEmpty) {
      // Nichts mehr übrig: dann darf es "fertig" sein (oder in Idle laufen)
      print('🏁 Keine weiteren Karten verfügbar, Session beendet');
      _set(
        running: false,
        timerActive: false,
        timerPaused: false,
        wordQueue: const [],
        shuffledWordIds: const [],
        index: 0,
      );
      return;
    }

    // ✅ WICHTIG: Hole die entsprechenden WordUserView Objekte vom Server
    final newDeckWords = await _repo.fetchWordUserViewsByIds(
      categoryId: state.categoryId!,
      ids: newIds,
      srsSystem: srsSystem,
    );

    // Falls nicht alle Wörter gefunden wurden, logge Warnung
    if (newDeckWords.length != newIds.length) {
      print('⚠️ Warnung: Nur ${newDeckWords.length} von ${newIds.length} Wörtern gefunden');
    }

    // Neues Deck erfolgreich gebaut
    final newDeckStages = _computeDeckStages(newIds, newDeckWords);
    final safeIndex = 0.clamp(0, (newIds.length - 1).clamp(0, 1 << 30));
    _set(
      wordQueue: newDeckWords,
      shuffledWordIds: newIds,
      deckStages: newDeckStages,
      index: safeIndex,
    );
    print('✅ Neues Deck gebaut: ${newIds.length} Karten, deckStages=$newDeckStages, wordQueue.length=${newDeckWords.length}, index=$safeIndex');
  }

  /// Baut ein neues Deck aus den aktuellen Stage-Zahlen/Queues.
  /// Wichtig: Muss aus den jetzt aktualisierten Stage-Zahlen/Queues ziehen, nicht aus dem alten Snapshot.
  /// ✅ Refill-Hook: Enrolliert S0→S1 gemäß Contract vor dem Deck-Build (nur A-SRS).
  Future<List<String>> _buildNextDeckIds() async {
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    
    if (srsSystem == SrsSystem.adaptive) {
      // ✅ REFILL-HOOK: Wird jetzt von ASrsRefillEngine verwaltet
      // (enrollFromS0ToS1 wurde aus Repository entfernt, da sie Regeln enthielt)
      print('🔄 A-SRS Deck-Rebuild: Refill wird von Engine verwaltet');
      
      // ✅ A-SRS: IMMER Server-Queue neu laden (Contract), KEINE lokalen Stage-Queues
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('⚠️ _buildNextDeckIds: Kein User eingeloggt für A-SRS');
        return [];
      }
      
      var queue = await _repo.fetchAdaptiveQueue(
        userId: userId,
        categoryId: state.categoryId!,
        limit: 80, // Deck-Größe: S1-S5 können ~62+ Wörter haben, plus S0
      );
      
      // ✅ S0-Lock: Wenn Schloss aktiv (0 Sperre), Stage-0-Karten aus Queue filtern
      final s0Locked = ref.read(s0LockedProvider(state.categoryId!)).maybeWhen(data: (v) => v, orElse: () => false);
      // if (s0Locked) {
      //   queue = queue.where((w) => w.srsStage != 0).toList();
      // }
      
      // ✅ Wichtig: Reihenfolge genau wie Server (kein Shuffle!)
      final ids = queue.map((w) => w.id).toList();
      print('✅ A-SRS Deck-Rebuild: Server-Queue geladen, ${ids.length} IDs (s0Locked=$s0Locked)');
      return ids;
    } else {
      // T-SRS/Hybrid: Aus state.wordQueue mit Quota bauen
      final queue = state.wordQueue;
      if (queue.isEmpty) return [];
      
      // Filtere nach allowed stages – S0-Lock berücksichtigen
      final allowed = ref.read(allowedStagesProvider);
      final catId = state.categoryId;
      final s0Locked = catId != null
          ? ref.read(s0LockedProvider(catId)).maybeWhen(data: (v) => v, orElse: () => false)
          : false;
      final allowedForced = s0Locked ? allowed.where((s) => s != 0).toSet() : {...allowed, 0};
      final filteredWords = queue.where((w) => allowedForced.contains(w.srsStage)).toList();
      
      if (filteredWords.isEmpty) return [];
      
      // Queue mit Due-First sortieren
      final sortedQueue = _buildQueueDueFirst(filteredWords);
      
      // Deck mit Quota bauen
      final deckSize = sortedQueue.length.clamp(0, 200);
      return _buildDeckIdsWithQuota(
        allWords: sortedQueue,
        deckSize: deckSize,
      );
    }
  }

  /// Synchronisiert das Deck mit der aktiven Stage (A-SRS: stage-getrieben).
  /// Baut shuffledWordIds aus _stageQueues[activeStage] und setzt index = 0.
  Future<void> _syncDeckToActiveStage({bool shuffle = true}) async {
    final st = state.activeStage.clamp(0, 5);
    
    print('🔄 _syncDeckToActiveStage: START - activeStage=$st, _stageQueues[$st].length=${_stageQueues[st].length}');

    final ids = List<String>.from(_stageQueues[st]);
    print('🔄 _syncDeckToActiveStage: IDs kopiert: ${ids.length} IDs');
    if (shuffle) {
      ids.shuffle();
      print('🔄 _syncDeckToActiveStage: IDs geshuffelt');
    }

    // Wenn Stage leer -> finde erste nicht-leere Stage aus _stageQueues
    if (ids.isEmpty) {
      print('⚠️ _syncDeckToActiveStage: Stage $st ist leer, suche Fallback...');
      final fallback = _firstNonEmptyStageOr(0);
      print('🔄 _syncDeckToActiveStage: Fallback gefunden: Stage $fallback (${_stageQueues[fallback].length} IDs)');
      if (fallback != st) {
        final fbIds = List<String>.from(_stageQueues[fallback]);
        if (shuffle) fbIds.shuffle();
        
        // ✅ WICHTIG: Hole WordUserView Objekte vom Server
        final srsSystem = ref.read(srsModeControllerProvider).mode;
        final fbWords = await _repo.fetchWordUserViewsByIds(
          categoryId: state.categoryId!,
          ids: fbIds,
          srsSystem: srsSystem,
        );
        final fbDeckStages = _computeDeckStages(fbIds, fbWords);
        final safeIndex = 0.clamp(0, (fbIds.length - 1).clamp(0, 1 << 30));
        print('🔄 _syncDeckToActiveStage: Stage $st leer, wechsle zu Stage $fallback (${fbIds.length} IDs)');
        print('🧨 INDEX-RESET auf 0 in _syncDeckToActiveStage (Fallback): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
        _set(activeStage: fallback, wordQueue: fbWords, shuffledWordIds: fbIds, deckStages: fbDeckStages, index: safeIndex);
        print('✅ _syncDeckToActiveStage: State gesetzt mit Fallback. shuffledWordIds.length=${state.shuffledWordIds.length}, wordQueue.length=${fbWords.length}');
        return;
      } else {
        print('⚠️ _syncDeckToActiveStage: Fallback ist gleich aktiver Stage - alle Stages leer?');
      }
    }

    // ✅ WICHTIG: Hole WordUserView Objekte vom Server
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    final words = await _repo.fetchWordUserViewsByIds(
      categoryId: state.categoryId!,
      ids: ids,
      srsSystem: srsSystem,
    );
    final deckStages = _computeDeckStages(ids, words);
    final safeIndex = 0.clamp(0, (ids.length - 1).clamp(0, 1 << 30));
    
    print('🔄 _syncDeckToActiveStage: Setze shuffledWordIds mit ${ids.length} IDs, deckStages=$deckStages');
    print('🧨 INDEX-RESET auf 0 in _syncDeckToActiveStage (normal): prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
    _set(wordQueue: words, shuffledWordIds: ids, deckStages: deckStages, index: safeIndex);
    print('✅ _syncDeckToActiveStage: State gesetzt. shuffledWordIds.length=${state.shuffledWordIds.length}, wordQueue.length=${words.length}');
  }

  /// Setzt die aktive Stage und baut die shuffledWordIds für diese Stage neu auf.
  /// Blockiert leere Stages automatisch.
  void setActiveStage(int nextStage) {
    // 1) Stage existiert?
    if (nextStage < 0 || nextStage >= state.stages.length) {
      print('⛔ setActiveStage($nextStage) ignored (out of range)');
      return;
    }

    // 2) Leere Stage -> IGNORE (kein Umschalten auf 0)
    if (state.stages[nextStage] == 0) {
      print('⛔ setActiveStage($nextStage) ignored (stages[$nextStage]=0)');
      return;
    }

    // 3) IDs für diese Stage neu bauen
    final ids = <String>[];
    for (final w in state.wordQueue) {
      final stage = w.srsStage.clamp(0, 5);
      if (stage == nextStage) ids.add(w.id);
    }
    ids.shuffle();

    print('✅ setActiveStage($nextStage): ${ids.length} IDs für Stage $nextStage');
    print('🧨 INDEX-RESET auf 0 in setActiveStage: prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
    _set(
      activeStage: nextStage,
      shuffledWordIds: ids,
      index: 0,
    );
  }

  /// Prüft, ob die aktuelle activeStage leer ist und wechselt automatisch zu einer nicht-leeren Stage.
  void _autoFixEmptyStageIfNeeded() {
    final a = state.activeStage;
    if (a < 0 || a >= state.deckStages.length) return;

    // Wenn aktive Stage leer ist, springe auf erste nicht-leere
    if (state.deckStages[a] == 0) {
      final next = _firstNonEmptyStage(state.deckStages, fallback: a);
      if (next != a) {
        print('🛟 AutoSwitch: activeStage $a -> $next (empty stage)');
        setActiveStage(next);
      }
    }
  }

  /// Findet die nächste nicht-leere Stage ab fromStage.
  /// stages: [S0,S1,S2,S3,S4,S5] => index 0..5
  /// fromStage: 0..5 (die aktuelle Stage)
  /// Gibt die nächste Stage mit count > 0 zurück, oder fromStage wenn nichts gefunden.
  int _nextNonEmptyStage({
    required List<int> stages, // [S0,S1,S2,S3,S4,S5]
    required int fromStage, // 0..5
  }) {
    // stages: [S0,S1,S2,S3,S4,S5] => index 0..5
    for (int s = fromStage; s <= 5; s++) {
      if (stages[s] > 0) return s;
    }
    // wenn nichts mehr da ist: bleib wo du bist (oder 0)
    return fromStage.clamp(0, 5);
  }

  /// Alte Version (für allowedStages) - wird noch verwendet
  int _nextNonEmptyStageWithAllowed({
    required int fromStage,
    required List<int> stageCounts, // [s0,s1,s2,s3,s4,s5]
    required Set<int> allowedStages, // z.B. aus LevelSelectionMode
  }) {
    // Suche von fromStage + 1 bis 5
    for (var st = fromStage + 1; st <= 5; st++) {
      if (!allowedStages.contains(st)) continue;
      if (stageCounts[st] > 0) return st;
    }
    // Falls keine höhere Stage gefunden, suche von Anfang an (inkl. fromStage)
    for (var st = 0; st <= fromStage; st++) {
      if (!allowedStages.contains(st)) continue;
      if (stageCounts[st] > 0) return st;
    }
    return fromStage; // nichts verfügbar -> bleib
  }

  int _findInitialIndex(List<CategoryInfo> cats) {
    if (state.categoryId.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == state.categoryId);
      if (i >= 0) return i;
    }
    final i = cats.indexWhere((c) => c.name == state.title);
    return i >= 0 ? i : 0;
  }

  void _resetCardBasedSystem() {
    _set(
      recentlySwiped: const <String>[],
      cardsSwipedInSession: 0,
      hasLoadedReviews: false,
    );
  }

  Future<void> _performReset() async {
    if (_isResetRunning) {
      print('⛔ Reset übersprungen: läuft bereits');
      return;
    }

    _isResetRunning = true;
    try {
      final sb = Supabase.instance.client;
      final catId = state.categoryId;
      final mode = ref.read(srsModeControllerProvider).mode.name; // time|adaptive|hybrid

      print('✅ _performReset CALLED catId=$catId mode=$mode');

      if (mode == 'adaptive') {
        // A-SRS: fn_a_srs_reset_category_progress (setzt stage=0, ever_enrolled=false, etc.)
        await _repo.resetAdaptiveCategoryProgress(catId);
        final userId = sb.auth.currentUser?.id;
        if (userId != null) {
          await sb.rpc('fn_enroll_user_category_mode', params: {
            'p_category_id': catId,
            'p_mode': 'adaptive',
            'p_user': userId,
          });
          print('✅ A-SRS: Nach Reset neu geseeded (fn_enroll_user_category_mode)');
        }
      } else {
        await sb.rpc('fn_reset_category_progress', params: {
          'p_category_id': catId,
          'p_mode': mode,
        });
      }

      // nach erfolgreichem Reset
      _didReset = true;

      // Session lokal leeren
      _cooldown.clear();
      _wordTimer?.cancel();
      print('🧨 INDEX-RESET auf 0 in _performReset: prevIndex=${state.index}, activeStage=${state.activeStage}, deckLen=${state.shuffledWordIds.length}');
      _set(
        wordQueue: const [],
        shuffledWordIds: const [],
        index: 0,
        recentlySwiped: const [],
        cardsSwipedInSession: 0,
        categoryMastered: false,
        categoryMasteredRestartReady: false,
      );

      // Fortschritt neu vom Server holen (zeigt dann Stage0=total)
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      final progressReqId = ++_progressRequestId;
      print('📡 progress fetch START reqId=$progressReqId');
      final prog = await _repo.fetchCategoryProgress(
        catId,
        srsSystem: srsSystem,
      );
      print('📡 progress fetch DONE reqId=$progressReqId stages=${prog.stages}');
      if (progressReqId != _progressRequestId) {
        print('⛔ progress fetch IGNORE stale reqId=$progressReqId latest=$_progressRequestId');
        return;
      }
      
      // ⬇️ Stage 0 für A-SRS/Hybrid korrigieren (vocabsTotal - learnedWords)
      var stagesToSet = prog.stages;
      if (srsSystem == SrsSystem.adaptive || srsSystem == SrsSystem.hybrid) {
        final sb = Supabase.instance.client;
        final vocabsTotal = await sb.rpc('fn_category_word_count', params: {'p_category_id': catId}) as int? ?? 0;
        final learnedWords = prog.stages.skip(1).fold<int>(0, (a, b) => a + b);
        final correctedStage0 = (vocabsTotal - learnedWords).clamp(0, 1 << 30);
        stagesToSet = [correctedStage0, ...prog.stages.skip(1)];
        print('🔄 Reset: A-SRS/Hybrid Stage 0 korrigiert: $correctedStage0 (vocabsTotal=$vocabsTotal, learnedWords=$learnedWords)');
      }
      
      _setStages(stagesToSet);

      if (srsSystem == SrsSystem.adaptive) {
        _set(
          hasStartedAdaptiveRound: false,
          skipNextAdaptiveRefill: true,
          wordQueue: const [],
          shuffledWordIds: const [],
          index: 0,
        );
      }

      // Wörter neu laden
      await _loadWords();

      // Hub/Detail refresh triggern (ohne Prefs-Override!)
      ResetEvent.notifyReset(catId);
      // ref.invalidate(...) erst danach, aber NUR die passenden Provider (wenn nötig)

    } catch (e) {
      print('⚠️ Reset failed: $e');
    } finally {
      _isResetRunning = false;
    }
  }

  // ---- State setter (einheitlich) ----
  void _set({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    List<int>? deckStages,
    int? totalWordsInCategory,
    int? activeStage,
    int? masteredCount,

    List<WordUserView>? wordQueue,
    List<String>? shuffledWordIds,
    int? index,

    bool? showTranslation,

    // timer
    bool? running,
    bool? timerActive,
    bool? timerPaused,
    double? remainingMillis,

    // reviews
    List<String>? recentlySwiped,
    int? cardsSwipedInSession,
    bool? hasLoadedReviews,
    bool? isSubmitting,
    bool? isSubmittingReview,
    String? emptyQueueHint,
    bool clearEmptyQueueHint = false,
    bool? showFinalStartButton,
    bool? finalPassActive,
    bool? categoryMastered,
    bool? categoryMasteredRestartReady,
    bool? hasStartedAdaptiveRound,
    bool? skipNextAdaptiveRefill,
  }) {
    final oldStages = state.stages;
    state = state.copyWith(
      categoryId: categoryId,
      title: title,

      loading: loading,
      categories: categories,
      selectedCategoryIndex: selectedCategoryIndex,

      stages: stages,
      deckStages: deckStages,
      totalWordsInCategory: totalWordsInCategory,
      activeStage: activeStage,
      masteredCount: masteredCount,

      wordQueue: wordQueue,
      shuffledWordIds: shuffledWordIds,
      index: index,

      showTranslation: showTranslation,

      running: running,
      timerActive: timerActive,
      timerPaused: timerPaused,
      remainingMillis: remainingMillis,

      recentlySwiped: recentlySwiped,
      cardsSwipedInSession: cardsSwipedInSession,
      hasLoadedReviews: hasLoadedReviews,
      isSubmitting: isSubmitting,
      isSubmittingReview: isSubmittingReview,
      emptyQueueHint: emptyQueueHint,
      clearEmptyQueueHint: clearEmptyQueueHint,
      showFinalStartButton: showFinalStartButton,
      finalPassActive: finalPassActive,
      categoryMastered: categoryMastered,
      categoryMasteredRestartReady: categoryMasteredRestartReady,
      hasStartedAdaptiveRound: hasStartedAdaptiveRound,
      skipNextAdaptiveRefill: skipNextAdaptiveRefill,
    );
    
    // Debug: Logge wenn Stages geändert wurden
    if (stages != null && stages != oldStages) {
      print('🔄 _set() hat Stages geändert: $oldStages -> $stages');
      print('🔄 Neuer state.stages: ${state.stages}');
      
      // ✅ Schritt 2: _ensureValidActiveStage() für A-SRS deaktivieren
      // A-SRS darf kein lokales Deck-Rebuild, activeStage ist Server-getrieben
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      if (srsSystem != SrsSystem.adaptive) {
        // ✅ WICHTIG: activeStage validieren, wenn Stages geändert wurden (nur T-SRS/Hybrid)
        _ensureValidActiveStage();
      }
    }
  }

  /// Prüft SRS-Contracts nach einem Review
  /// Contract-Regeln:
  /// 1. DB == RPC (Server Source of Truth)
  /// 2. Stages sum must stay stable
  /// 3. If oldStage == newStage, local progress MUST NOT change
  /// 4. If stage changed, we expect exactly one -1/+1 in stages
  void assertSrsContractsAfterReview({
    required String wordId,
    required int oldStage,
    required int rpcStage,
    required DateTime? rpcNextDueAt,
    required int dbStage,
    required DateTime? dbNextDueAt,
    required List<int> stagesBefore,
    required List<int> stagesAfter,
    required List<int> stageQueuesBefore,
    required List<int> stageQueuesAfter,
    required int totalWordsInCategory,
    required int masteredBefore,
    required int masteredAfter,
    bool skipNextDueAtCheck = false, // A-SRS: bei mastered words kann RPC next_due_at zurückgeben, DB evtl. unverändert
  }) {
    // 1) DB == RPC (Server truth)
    assert(dbStage == rpcStage, 'CONTRACT FAIL: dbStage($dbStage) != rpcStage($rpcStage) for $wordId');
    if (!skipNextDueAtCheck) {
      assert(_eqDate(dbNextDueAt, rpcNextDueAt),
          'CONTRACT FAIL: dbNextDueAt($dbNextDueAt) != rpcNextDueAt($rpcNextDueAt) for $wordId');
    }

    // 2) Stages sum must stay stable (mastered = kleine Zahl unter A5)
    final masteredCount = state.masteredCount;
    print('ASSERT CHECK -> totalWordsInCategory=$totalWordsInCategory stagesAfter=$stagesAfter sum=${stagesAfter.fold<int>(0, (a, b) => a + b)} masteredCount=$masteredCount');
    assert(
      stagesAfter.fold<int>(0, (a, b) => a + b) + masteredCount == totalWordsInCategory,
      'CONTRACT FAIL: sum(stagesAfter)+masteredCount != totalWordsInCategory',
    );

    // 3) If oldStage == newStage, local progress MUST NOT change
    // Sonderfall: Stage 5 + Mastered-Übergang erlaubt (stages[5] -1, mastered +1)
    // Sonderfall A-SRS: Server ist Source of Truth – Stages können sich beim Sync ändern (z.B. nach init-Korrektur)
    if (oldStage == rpcStage) {
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      final stageCountsMayChangeBecauseOfMastered =
          oldStage == 5 && (masteredAfter != masteredBefore);
      final aSrsServerSync = srsSystem == SrsSystem.adaptive;

      assert(
        _listEq(stagesBefore, stagesAfter) || stageCountsMayChangeBecauseOfMastered || aSrsServerSync,
        'CONTRACT FAIL: stages changed even though stage stayed same (old=$oldStage new=$rpcStage)',
      );
      assert(_listEq(stageQueuesBefore, stageQueuesAfter),
          'CONTRACT FAIL: stageQueues changed even though stage stayed same (old=$oldStage new=$rpcStage)');
    } else {
      // 4) If stage changed, we expect exactly one -1/+1 in stages
      // ✅ A-SRS: Kein lokales Delta, daher keine Assertion für Stages-Diff
      final srsSystem = ref.read(srsModeControllerProvider).mode;
      if (srsSystem != SrsSystem.adaptive) {
        final diff = List.generate(stagesAfter.length, (i) => stagesAfter[i] - stagesBefore[i]);
        final negCount = diff.where((d) => d == -1).length;
        final posCount = diff.where((d) => d == 1).length;
        assert(negCount == 1 && posCount == 1,
            'CONTRACT FAIL: expected one -1 and one +1 in stages diff, got $diff');
      }
    }
  }

  bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _eqDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.toUtc() == b.toUtc();
  }
}
