// lib/features/words/application/learn_mode_controller.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

/// ---------- State ----------

class LearnModeState {
  final String categoryId;
  final String title;

  final bool loading;
  final List<CategoryInfo> categories;
  final int selectedCategoryIndex;

  final List<int> stages; // [S0..S5]
  final int totalWordsInCategory;

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

  // Reviews
  final List<String> recentlySwiped; // IDs der Karten, die in dieser Session korrekt geswipet wurden
  final int cardsSwipedInSession;
  final bool hasLoadedReviews;

  const LearnModeState({
    this.categoryId = '',
    this.title = '',

    this.loading = false,
    this.categories = const [],
    this.selectedCategoryIndex = 0,

    this.stages = const [0, 0, 0, 0, 0, 0],
    this.totalWordsInCategory = 0,

    this.wordQueue = const [],
    this.shuffledWordIds = const [],
    this.index = 0,

    this.showTranslation = false,

    this.running = false,
    this.timerActive = false,
    this.timerPaused = false,
    this.remainingMillis = 10000.0,
    this.timeLimit = 10,

    this.recentlySwiped = const [],
    this.cardsSwipedInSession = 0,
    this.hasLoadedReviews = false,
  });

  factory LearnModeState.initial() => const LearnModeState();

  LearnModeState copyWith({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    int? totalWordsInCategory,

    List<WordUserView>? wordQueue,
    List<String>? shuffledWordIds,
    int? index,

    bool? showTranslation,

    bool? running,
    bool? timerActive,
    bool? timerPaused,
    double? remainingMillis,
    int? timeLimit,

    List<String>? recentlySwiped,
    int? cardsSwipedInSession,
    bool? hasLoadedReviews,
  }) {
    return LearnModeState(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,

      loading: loading ?? this.loading,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,

      stages: stages ?? this.stages,
      totalWordsInCategory: totalWordsInCategory ?? this.totalWordsInCategory,

      wordQueue: wordQueue ?? this.wordQueue,
      shuffledWordIds: shuffledWordIds ?? this.shuffledWordIds,
      index: index ?? this.index,

      showTranslation: showTranslation ?? this.showTranslation,

      running: running ?? this.running,
      timerActive: timerActive ?? this.timerActive,
      timerPaused: timerPaused ?? this.timerPaused,
      remainingMillis: remainingMillis ?? this.remainingMillis,
      timeLimit: timeLimit ?? this.timeLimit,

      recentlySwiped: recentlySwiped ?? this.recentlySwiped,
      cardsSwipedInSession: cardsSwipedInSession ?? this.cardsSwipedInSession,
      hasLoadedReviews: hasLoadedReviews ?? this.hasLoadedReviews,
    );
  }
}

/// ---------- Provider ----------

final learnModeControllerProvider = NotifierProvider<LearnModeController, LearnModeState>(() {
  return LearnModeController();
});

/// ---------- Controller ----------

class LearnModeController extends Notifier<LearnModeState> {
  @override
  LearnModeState build() => LearnModeState.initial();

  Timer? _wordTimer;

  String get _currentCatId {
    final cats = state.categories;
    final i = state.selectedCategoryIndex;
    if (cats.isEmpty || i >= cats.length) return state.categoryId;
    return cats[i].id;
  }

  String get _stageStoreKey => 'learn_stages_$_currentCatId';

  // ---- Public API (Screen ruft das auf) ----

  Future<void> init({required String categoryId, required String title}) async {
    _set(categoryId: categoryId, title: title);
    await _loadCategories();
  }

  void onSwipeRight() {
    if (!_canInteract()) return;
    _handleAnswer(correct: true);
  }
  
  void onSwipeLeft() {
    if (!_canInteract()) return;
    _handleAnswer(correct: false);
  }
  
  void toggleFlip() {
    if (!_canInteract()) return;
    _set(showTranslation: !state.showTranslation);
  }
  
  /// Prüft, ob Interaktionen erlaubt sind (nicht pausiert)
  bool _canInteract() {
    return !state.timerPaused;
  }

  void startTimer() => _startWordTimer(forceActive: true);
  void pauseTimer() => _set(timerPaused: true, running: false);
  void resumeTimer() {
    if (!state.timerActive) return; // nur wenn Timer aktiv ist
    _set(timerPaused: false, running: true);
  }
  void cancelTimer() => _stopTimer();

  Future<void> selectCategoryIndex(int idx) async {
    _set(selectedCategoryIndex: idx, index: 0);
    _resetCardBasedSystem();
    await _loadStageData();
    await _loadWords();
  }

  Future<void> performReset() async => _performReset();

  // ---- Loading ----

  Future<void> _loadCategories() async {
    _set(loading: true);
    try {
      final cats = await fetchAllCategories();
      final sel = _findInitialIndex(cats);
      _set(categories: cats, selectedCategoryIndex: sel);
      await _loadStageData();
      await _loadWords();
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
    bool hasLocal = false;

    try {
      // 1) Schnell lokal
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_stageStoreKey);
      if (stored != null) {
        try {
          final parsed = stored.split(',').map(int.parse).toList();
          if (parsed.length == 6) {
            _set(stages: parsed);
            hasLocal = true;
          }
        } catch (_) {}
      }

      // 2) Backend
      final prog = await fetchCategoryProgress(_currentCatId);
      if (!hasLocal) {
        _set(stages: prog.stages);
      }
      _set(totalWordsInCategory: prog.total);

      // 3) Lokal sichern
      await _persistStageData();

    } catch (_) {
      if (state.stages.every((s) => s == 0)) {
        _set(stages: const [0, 0, 0, 0, 0, 0]);
      }
    }
  }

  Future<void> _loadWords() async {
    try {
      final catId = _currentCatId;
      final words = await fetchLearnQueueAll(catId); // an Repo-Funktion aus deinem Screen angepasst

      if (words.isEmpty) {
        _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
        return;
      }

      final queue = _buildQueueDueFirst(words);
      final shuffledIdx = await _getSmartCardOrder(queue.length);

      _set(
        wordQueue: queue,
        shuffledWordIds: [for (final i in shuffledIdx) queue[i].id],
        index: 0,
      );
    } catch (_) {
      _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
    }
  }

  /// bevorzugt fällige Karten, Rest zufällig gemischt
  List<WordUserView> _buildQueueDueFirst(List<WordUserView> words) {
    final due = <WordUserView>[];
    final notDue = <WordUserView>[];
    final now = DateTime.now();

    for (final w in words) {
      if (w.nextDueAt != null && !w.nextDueAt!.isAfter(now)) {
        due.add(w);
      } else {
        notDue.add(w);
      }
    }

    due.shuffle();
    notDue.shuffle();
    return [...due, ...notDue];
  }

  /// liefert gemischte Indizes (leichte Zufallsgewichtung möglich)
  Future<List<int>> _getSmartCardOrder(int length) async {
    final rnd = math.Random();
    final idx = List.generate(length, (i) => i);
    idx.shuffle(rnd);
    return idx;
  }

  // ---- Review / Antwort-Handling ----

  Future<void> _handleAnswer({required bool correct}) async {
    final queue = state.wordQueue;
    if (queue.isEmpty) return;

    final i = state.index;
    if (i >= queue.length) return;

    final current = queue[i];
    final currentId = current.id;

    // 1) Timer-Status merken (nicht stoppen!)
    final wasActive = state.timerActive;
    final wasPaused = state.timerPaused;
    final wasRunning = state.running;

    // 2) Stage lokal hoch/runter schätzen (nur für Stufen-Zähler)
    int oldStage = current.srsStage;
    int newStage = oldStage;
    if (correct) {
      newStage = (newStage < 5) ? newStage + 1 : 5;
    } else {
      newStage = (newStage > 0) ? newStage - 1 : 0;
    }

    // 3) Fortschritt updaten (lokal)
    final stages = [...state.stages];
    if (oldStage >= 0 && oldStage < stages.length) {
      stages[oldStage] = (stages[oldStage] - 1).clamp(0, 1 << 30);
    }
    if (newStage >= 0 && newStage < stages.length) {
      stages[newStage] = stages[newStage] + 1;
    }
    _set(stages: stages);

    // 4) Review an Backend schicken (an deine Repo-Signatur angepasst)
    try {
      await submitReview(currentId, correct); // <- (String wordId, bool correct)
    } catch (_) {}

    // 5) Nächste Karte
    final nextIndex = (i + 1) % queue.length;

    // 6) recentlySwiped aktualisieren
    final newSwiped = [...state.recentlySwiped, currentId];
    if (newSwiped.length > 50) newSwiped.removeAt(0);

    _set(
      index: nextIndex,
      recentlySwiped: newSwiped,
      cardsSwipedInSession: state.cardsSwipedInSession + 1,
    );

    // 7) ggf. neu mischen, wenn am Ende
    if (nextIndex == 0) {
      final shuffled = await _getSmartCardOrder(queue.length);
      _set(shuffledWordIds: [for (final k in shuffled) queue[k].id]);
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

    // 9) lokalen Fortschritt speichern
    await _persistStageData();

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
      timerPaused: keepPaused ? true : false,
      timerActive: shouldBeActive ? true : true, // ab jetzt aktiv
      running: keepPaused ? false : true,
    );

    // Nur ticken, wenn nicht pausiert
    const tick = Duration(milliseconds: 16);
    _wordTimer = Timer.periodic(tick, (t) {
      if (state.timerPaused) return;

      final left = state.remainingMillis - 16;
      if (left <= 0) {
        t.cancel();
        HapticFeedback.mediumImpact();
        // Zeit abgelaufen -> als falsch werten,
        // dabei greift _handleAnswer mit der gleichen Restart-Logik
        _handleAnswer(correct: false);
      } else {
        _set(remainingMillis: left);
      }
    });
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

  // ---- Helpers ----

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
    try {
      // Auf 0 setzen: alle Wörter in dieser Kategorie als S0
      final total = state.totalWordsInCategory > 0
          ? state.totalWordsInCategory
          : state.wordQueue.length;

      state = state.copyWith(stages: [total, 0, 0, 0, 0, 0]);
      await _persistStageData();

      // Backend-Reset, falls vorhanden (safe call)
      // TODO: Implement backend reset if needed

      // Neu laden
      await _loadStageData();
      await _loadWords();
    } catch (_) {}
  }

  // ---- State setter (einheitlich) ----
  void _set({
    String? categoryId,
    String? title,

    bool? loading,
    List<CategoryInfo>? categories,
    int? selectedCategoryIndex,

    List<int>? stages,
    int? totalWordsInCategory,

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
  }) {
    state = state.copyWith(
      categoryId: categoryId,
      title: title,

      loading: loading,
      categories: categories,
      selectedCategoryIndex: selectedCategoryIndex,

      stages: stages,
      totalWordsInCategory: totalWordsInCategory,

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
    );
  }
}
