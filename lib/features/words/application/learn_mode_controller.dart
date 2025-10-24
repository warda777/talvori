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

  // ---- SRS-Einstellungen und Konstanten ----
  
  // Stage-Daten für Switches (s0..s5)
  int _goalPerStage = 100;
  
  // Kartenbasiertes Wiederholungssystem
  static const int _newCardsBeforeReview = 4; // Nach X neuen Karten → Wiederholungen
  static const double _reviewRatio = 0.8; // 80% der neuen Karten wiederholen (anpassbar)
  
  // --- S0 Cooldown: wie viele andere Karten MINDESTENS dazwischen liegen müssen
  static const int _s0MinOthers = 3; // ← gern auf 5 erhöhen, wenn gewünscht
  final Map<String, int> _cooldown = {}; // wordId -> verbleibende "andere Karten"
  
  // --- Queue-Steuerung: wie viele Karten vorn „gesteuert" werden
  static const int _headSize = 150;
  
  // --- Interleave-Muster (Gewichte) – gern anpassen
  static const int _pS0 = 1; // neue pushen (minimal, aber vorhanden)
  static const int _pS1 = 4; // S1 verstärken
  static const int _pS2 = 5; // S2 verstärken
  static const int _pS3 = 3;
  static const int _pS4 = 2;
  static const int _pS5 = 2;

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
      final shuffledIdx = await _getSmartCardOrder(queue);

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

  /// Intelligente SRS-Kartenauswahl mit gewichteten Mustern
  Future<List<int>> _getSmartCardOrder(List<WordUserView> queue) async {
    final now = DateTime.now();

    // Buckets: due vs wait per stage
    final s0Due = <int>[], s1Due = <int>[], s2Due = <int>[], s3Due = <int>[], s4Due = <int>[], s5Due = <int>[];
    final s0Wait = <int>[], s1Wait = <int>[], s2Wait = <int>[], s3Wait = <int>[], s4Wait = <int>[], s5Wait = <int>[], rest = <int>[];

    bool isDue(WordUserView w) {
      final t = w.nextDueAt;
      return t != null && !t.isAfter(now); // nextDueAt <= now
    }

    for (int i = 0; i < queue.length; i++) {
      final w = queue[i];
      final st = w.srsStage;
      final due = isDue(w);

      switch (st) {
        case 0: (due ? s0Due : s0Wait).add(i); break;
        case 1: (due ? s1Due : s1Wait).add(i); break;
        case 2: (due ? s2Due : s2Wait).add(i); break;
        case 3: (due ? s3Due : s3Wait).add(i); break;
        case 4: (due ? s4Due : s4Wait).add(i); break;
        case 5: (due ? s5Due : s5Wait).add(i); break;
        default: rest.add(i); break;
      }
    }

    void shuf<T>(List<T> x) => x..shuffle();
    for (final b in [s0Due,s1Due,s2Due,s3Due,s4Due,s5Due,
                    s0Wait,s1Wait,s2Wait,s3Wait,s4Wait,s5Wait,rest]) {
      shuf(b);
    }

    // Head pattern (weights are applied as "pull this many from X, then move on")
    int needS0 = _pS0, needS1 = _pS1, needS2 = _pS2, needS3 = _pS3, needS4 = _pS4, needS5 = _pS5;
    void resetPattern() { needS0=_pS0; needS1=_pS1; needS2=_pS2; needS3=_pS3; needS4=_pS4; needS5=_pS5; }

    final head = <int>[];
    while (head.length < _headSize &&
          (s0Due.isNotEmpty||s1Due.isNotEmpty||s2Due.isNotEmpty||s3Due.isNotEmpty||s4Due.isNotEmpty||s5Due.isNotEmpty||
            s0Wait.isNotEmpty||s1Wait.isNotEmpty||s2Wait.isNotEmpty||s3Wait.isNotEmpty||s4Wait.isNotEmpty||s5Wait.isNotEmpty)) {

      // 1) due-first, prioritise higher stages
      while (needS3 > 0 && s3Due.isNotEmpty && head.length < _headSize) { head.add(s3Due.removeLast()); needS3--; }
      while (needS4 > 0 && s4Due.isNotEmpty && head.length < _headSize) { head.add(s4Due.removeLast()); needS4--; }
      while (needS5 > 0 && s5Due.isNotEmpty && head.length < _headSize) { head.add(s5Due.removeLast()); needS5--; }
      while (needS2 > 0 && s2Due.isNotEmpty && head.length < _headSize) { head.add(s2Due.removeLast()); needS2--; }
      while (needS1 > 0 && s1Due.isNotEmpty && head.length < _headSize) { head.add(s1Due.removeLast()); needS1--; }
      while (needS0 > 0 && s0Due.isNotEmpty && head.length < _headSize) { head.add(s0Due.removeLast()); needS0--; }

      // 2) then wait-pools (still give higher stages a nudge)
      while (needS3 > 0 && s3Wait.isNotEmpty && head.length < _headSize) { head.add(s3Wait.removeLast()); needS3--; }
      while (needS4 > 0 && s4Wait.isNotEmpty && head.length < _headSize) { head.add(s4Wait.removeLast()); needS4--; }
      while (needS2 > 0 && s2Wait.isNotEmpty && head.length < _headSize) { head.add(s2Wait.removeLast()); needS2--; }
      while (needS1 > 0 && s1Wait.isNotEmpty && head.length < _headSize) { head.add(s1Wait.removeLast()); needS1--; }
      while (needS0 > 0 && s0Wait.isNotEmpty && head.length < _headSize) { head.add(s0Wait.removeLast()); needS0--; }
      while (needS5 > 0 && s5Wait.isNotEmpty && head.length < _headSize) { head.add(s5Wait.removeLast()); needS5--; }

      if (needS0==0 && needS1==0 && needS2==0 && needS3==0 && needS4==0 && needS5==0) {
        resetPattern();
      } else {
        // if a bucket is empty, soft-reset to keep pulling from what exists
        if ((needS0>0 && s0Due.isEmpty && s0Wait.isEmpty) ||
            (needS1>0 && s1Due.isEmpty && s1Wait.isEmpty) ||
            (needS2>0 && s2Due.isEmpty && s2Wait.isEmpty) ||
            (needS3>0 && s3Due.isEmpty && s3Wait.isEmpty) ||
            (needS4>0 && s4Due.isEmpty && s4Wait.isEmpty) ||
            (needS5>0 && s5Due.isEmpty && s5Wait.isEmpty)) {
          resetPattern();
        }
      }
    }

    // Tail = the rest, shuffled
    final tail = <int>[
      ...s0Due, ...s1Due, ...s2Due, ...s3Due, ...s4Due, ...s5Due,
      ...s0Wait, ...s1Wait, ...s2Wait, ...s3Wait, ...s4Wait, ...s5Wait,
      ...rest,
    ]..shuffle();

    return <int>[...head, ...tail];
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
      final shuffled = await _getSmartCardOrder(queue);
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

    // 9) S0 Cooldown und Advance Logic
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
        _set(shuffledWordIds: newShuffled);
      }

      // Nur bei S0 Cooldown starten
      _startCooldownIfNeeded(currentId);

      // Index auf aktuelle Position clampen
      final newIndex = state.index % state.shuffledWordIds.length;
      _set(index: newIndex);

      // Eine "andere Karte" wird als nächstes gezeigt → Cooldowns ticken schon JETZT
      _tickCooldowns();

      // Wähle die nächste Karte, die nicht im Cooldown ist
      _advanceToNextEligible(avoidId: currentId);
    }

    // 10) lokalen Fortschritt speichern
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
  void _advanceToNextEligible({String? avoidId}) {
    final len = state.shuffledWordIds.length;
    if (len == 0) {
      _set(index: 0);
      return;
    }
    int currentIndex = state.index % len; // Sicherheit

    int tries = 0;
    while (tries < len) {
      final candidateId = state.shuffledWordIds[currentIndex];
      final blocked = (_cooldown[candidateId] ?? 0) > 0 || (avoidId != null && candidateId == avoidId);
      if (!blocked) break;
      currentIndex = (currentIndex + 1) % len;
      tries++;
    }

    _set(index: currentIndex);
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
