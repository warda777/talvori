// lib/features/words/application/learn_mode_controller.dart
import 'dart:async';
import 'dart:math' as math;
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
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';

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

final learnModeControllerProvider =
    NotifierProvider<LearnModeController, LearnModeState>(() {
  return LearnModeController();
});

/// ---------- Controller ----------

class LearnModeController extends Notifier<LearnModeState> {
  @override
  LearnModeState build() => LearnModeState.initial();

  Timer? _wordTimer;
  SfxService? _sfx;
  
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
    _set(categoryId: categoryId, title: title);
    _quickSetsIndex = initialQuickSetsIndex;
    _sfx = ref.read(sfxProvider);
    await _loadCategories();
  }
  
  // ⬇️ NEU: Wörter für QuickSets mit Filter laden
  Future<void> loadWordsForQuickSets(int index) async {
    _quickSetsIndex = index;
    await _loadWords();
  }

  void onSwipeRight() {
    if (!_canInteract()) return;
    _sfx?.correct();
    _handleAnswer(correct: true);
  }

  void onSwipeLeft() {
    if (!_canInteract()) return;
    _sfx?.wrong();
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
    _set(selectedCategoryIndex: idx, index: 0);
    _resetCardBasedSystem();
    await _loadStageData();
    await _loadWords();
  }

  Future<void> performReset() async {
    // Single-Session Reset falls im Single-Modus
    final mode = ref.read(levelSelectionProvider);
    if (mode == LevelSelectionMode.single) {
      await resetSingleSession();
    } else {
      await _performReset();
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
            _set(stages: parsed);
            hasLocal = true;
          }
        } catch (_) {}
      }

      // 2) Backend
      final prog = await fetchCategoryProgress(catId);
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
      
      // ⬇️ NEU: Guard für virtuelle Kategorien mit Filter-Logik
      if (_isVirtualCategory(catId)) {
        // Bei virtuellen Kategorien (QuickSets) verwende fetchByFilter
        if (_quickSetsIndex == null) {
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }
        
        // Filter basierend auf Wheel-Index erstellen
        final filter = _quicksetsFilterFor(_quickSetsIndex!);
        final wordsList = await _repo.fetchByFilter(filter, limit: 200);
        
        if (wordsList == null || wordsList.isEmpty) {
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
        )).toList();
        
        // Client-seitige Filterung
        final allowed = ref.read(allowedStagesProvider);
        final filteredWords = wordViews.where((w) => allowed.contains(w.srsStage)).toList();
        
        if (filteredWords.isEmpty) {
          _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
          return;
        }
        
        final queue = _buildQueueDueFirst(filteredWords);
        final ids = queue.map((w) => w.id).toList();
        _set(wordQueue: queue, shuffledWordIds: ids, index: 0);
        return;
      }
      
      final mode = ref.read(levelSelectionProvider);
      final singleStage = ref.read(singleStageProvider); // 1..5, nur für Single relevant
      
      print('🧪 RPC: fn_user_learn_queue_mode(catId=$catId, mode=$mode, singleStage=$singleStage)');
      final words = await fetchLearnQueueForMode(
        catId,
        mode: mode,
        singleStage: singleStage,
      );

        // Client-seitige Filterung als zusätzliche Absicherung
        final allowed = ref.read(allowedStagesProvider);
        final filteredWords = words.where((w) => allowed.contains(w.srsStage)).toList();

        // Session-Buckets für Single-Modus initialisieren
        if (mode == LevelSelectionMode.single) {
          final cnt = filteredWords.length;
          ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(src: cnt);
          
          // Single-Session seeden
          try {
            await singleSeed(catId, singleStage);
            final counts = await singleCounts(catId, singleStage);
            print('🔢 SingleCounts for $catId (stage $singleStage): src=${counts.$1}, sr1=${counts.$2}, sr2=${counts.$3}');
            ref.read(singleSessionBucketsProvider.notifier).state = SingleSessionBuckets(
              src: counts.$1, 
              sx: counts.$2, 
              sy: counts.$3,
            );
            // Auch die neuen Counts setzen
            ref.read(singleSessionCountsProvider.notifier).state = SingleSessionCounts(
              counts.$1, counts.$2, counts.$3,
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
        _set(wordQueue: const [], shuffledWordIds: const [], index: 0);
        return;
      }

      final queue = _buildQueueDueFirst(filteredWords);
      
      // Sofort prüfen: Queue-Stages analysieren
      final hist = <int,int>{};
      for (final w in queue.take(50)) {
        hist[w.srsStage] = (hist[w.srsStage] ?? 0) + 1;
      }
      print('🔎 Queue first50 stages: $hist');
      
      // Config berechnen und übergeben
      final now = DateTime.now();
      final dueCount = queue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;

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

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(queue);
      final order = buildSmartCardOrder(queue, config: cfg, allowedMaxStage: allowedMaxStage);

      // Debug-Log für Gate-Logik
      final s1Count = queue.where((w) => w.srsStage == 1).length;
      final s2Count = queue.where((w) => w.srsStage == 2).length;
      final s3Count = queue.where((w) => w.srsStage == 3).length;
      final s4Count = queue.where((w) => w.srsStage == 4).length;
      print('🚪 Gate: allowedMaxStage=$allowedMaxStage (Queue: S1:$s1Count, S2:$s2Count, S3:$s3Count, S4:$s4Count)');

      // Debug-Log für SRS-Ratio Verifikation
      final headSizePreview = order.take(40).map((ix) => queue[ix]).toList();
      final newCount = headSizePreview.where((w) => w.srsStage == 0).length;
      final dueCountHead = headSizePreview.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(DateTime.now())).length;
      print('🧠 Head[40]: new=$newCount, due=$dueCountHead, total=${headSizePreview.length}');

      _set(
        wordQueue: queue,
        shuffledWordIds: [for (final i in order) queue[i].id],
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
    final mode = ref.read(levelSelectionProvider);
    final srsSystem = ref.read(srsModeControllerProvider).mode;
    
        // Progress-Update basierend auf Modus
        if (mode == LevelSelectionMode.single) {
          // Single-Modus: Server-Session updaten
          try {
            final st = ref.read(singleStageProvider);     // 1..5
            final catId = _currentCatId;                  // wie bei Seed
            
            // Aktuelles Wort aus wordQueue und index ableiten
            final currentWord = state.wordQueue.isNotEmpty && state.index < state.wordQueue.length
                ? state.wordQueue[state.index]
                : null;
            
            if (currentWord == null) return; // Kein aktuelles Wort verfügbar

            // 1) in Session-Bucket verschieben
            await singleMove(catId, st, currentWord.id, correct);

            // 2) nächste Karte aus SRC holen
            final nextId = await singleNextWordId(catId, st);

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
              _set(shuffledWordIds: ids, index: newIdx);
            }

            // 3) Zähler aktualisieren (S{n}, SR1, SR2)
            final c = await singleCounts(catId, st);
            ref.read(singleSessionCountsProvider.notifier).state =
                SingleSessionCounts(c.$1, c.$2, c.$3);
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
      
      final oldStage = current.srsStage;
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
      _set(stages: stages);
      
      // Server-Update
      try {
        final result = await submitReview(
          currentId,
          correct,
          srsSystem: srsSystem,
        );
        final serverStage = result.$1;
        final serverDue = result.$2;
        
        // Server-Response verwenden
        final q = List<WordUserView>.from(state.wordQueue);
        final pos = q.indexWhere((w) => w.id == currentId);
        if (pos != -1) {
          q[pos] = q[pos].copyWith(srsStage: serverStage, nextDueAt: serverDue);
          _set(wordQueue: q);
        }
        
        // Stages mit Server-Response synchronisieren
        if (serverStage != newStage) {
          final updatedStages = [...state.stages];
          if (newStage >= 1 && newStage < updatedStages.length) {
            updatedStages[newStage] = (updatedStages[newStage] - 1).clamp(0, 1 << 30);
          }
          if (serverStage >= 1 && serverStage < updatedStages.length) {
            updatedStages[serverStage] = updatedStages[serverStage] + 1;
          }
          _set(stages: updatedStages);
        }
      } catch (e) {
        print('❌ Review submission failed: $e');
      }
      
      // Nächste Karte
      final nextIndex = (i + 1) % ids.length;
      _set(index: nextIndex);
      
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
    
    // Debug-Log für Karten-Bewertung
    final nowUtc = DateTime.now().toUtc();
    final isDueNow = current.nextDueAt != null && !current.nextDueAt!.isAfter(nowUtc);
    print('🎯 Bewerte Karte: ${current.text} (Stage: ${current.srsStage}, Due: $isDueNow) - $correct');

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

    // 4) Review an Backend schicken und Server-Response verwenden
    int serverStage = newStage; // Fallback auf lokale Schätzung
    DateTime? serverDue;
    try {
      final result = await submitReview(
        currentId,
        correct,
        srsSystem: srsSystem,
      );
      serverStage = result.$1;
      serverDue = result.$2;
      print('🗂 Server says: word=$currentId -> stage=$serverStage, due=$serverDue (old=$oldStage, correct=$correct)');

      // aktuelles Word-Objekt im Cache updaten
      final q = List<WordUserView>.from(state.wordQueue);
      final pos = q.indexWhere((w) => w.id == currentId);
      if (pos != -1) {
        q[pos] = q[pos].copyWith(srsStage: serverStage, nextDueAt: serverDue);
        _set(wordQueue: q);
      }

      // Stages mit Server-Response synchronisieren (falls abweichend)
      if (serverStage != newStage) {
        final updatedStages = [...state.stages];
        // Alte lokale Schätzung rückgängig machen
        if (newStage >= 0 && newStage < updatedStages.length) {
          updatedStages[newStage] = (updatedStages[newStage] - 1).clamp(0, 1 << 30);
        }
        // Server-Stage hinzufügen
        if (serverStage >= 0 && serverStage < updatedStages.length) {
          updatedStages[serverStage] = updatedStages[serverStage] + 1;
        }
        _set(stages: updatedStages);
        print('🔄 Stages korrigiert: lokale Schätzung $newStage -> Server $serverStage');
      }

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(state.wordQueue);
      final now = DateTime.now();
      final isNowDue = serverDue != null && !serverDue.isAfter(now);

      // ⛔️ Entfernen, wenn:
      // 1) Gate überschritten (z.B. S2 bei allowed=1)
      // 2) oder S1+ und nicht (mehr) fällig – ABER NICHT, wenn es gerade S0→S1 wurde (Echo bleibt)
      final bool justLearnedToS1 = (oldStage == 0 && serverStage == 1);

      final shouldRemoveFromSession =
          (serverStage > allowedMaxStage) ||
          ((serverStage >= 1) && !isNowDue && !justLearnedToS1);

      if (shouldRemoveFromSession) {
        final newIds = List<String>.from(state.shuffledWordIds);
        final pos = newIds.indexOf(currentId);
        if (pos != -1) {
          newIds.removeAt(pos);
          var nextIndex = state.index;
          if (pos <= state.index && nextIndex > 0) nextIndex -= 1;
          _set(shuffledWordIds: newIds, index: newIds.isEmpty ? 0 : nextIndex);
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
    } catch (e) {
      // optional loggen
      print('❌ Review submission failed: $e');
    }

    // 5) Nächste Karte
    final nextIndex = (i + 1) % ids.length;

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
      // Config für Re-Shuffle berechnen
      final now = DateTime.now();
      final dueCount = queue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;
      
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

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(queue);
      final shuffled = buildSmartCardOrder(queue, config: cfg, allowedMaxStage: allowedMaxStage);
      
      // Debug-Log für Re-Shuffle
      final reshufflePreview = shuffled.take(40).map((ix) => queue[ix]).toList();
      final reshuffleNewCount = reshufflePreview.where((w) => w.srsStage == 0).length;
      final reshuffleDueCount = reshufflePreview.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(DateTime.now())).length;
      print('🔄 Re-Shuffle[40]: new=$reshuffleNewCount, due=$reshuffleDueCount, total=${reshufflePreview.length}');
      
      _set(shuffledWordIds: [for (final k in shuffled) queue[k].id]);
    }

    // 7b) Mini-Reshuffle nach dem „Burst" (z. B. nach 10 Swipes)
    final shouldMiniReshuffle = state.cardsSwipedInSession == 10 ||
                                (state.cardsSwipedInSession > 10 &&
                                 state.cardsSwipedInSession % 8 == 0); // danach regelmäßig

    if (shouldMiniReshuffle) {
      final now = DateTime.now();
      final dueCount = state.wordQueue.where((w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now)).length;

      final cfg = computeSrsConfig(
        totalWordsInCategory: state.totalWordsInCategory,
        dueCount: dueCount,
        stats: SrsStats(
          rollingAccuracy: _rollingAccuracy,
          avgSwipeMs: _avgSwipeMs,
          recentTimeouts: _recentTimeouts,
        ),
      );

      final allowedMaxStage = _computeAllowedMaxStageFromQueue(state.wordQueue);
      final newOrderIdx = buildSmartCardOrder(state.wordQueue, config: cfg, allowedMaxStage: allowedMaxStage);
      final newIds = [for (final i in newOrderIdx) state.wordQueue[i].id];

      // Index auf gleiche Karte (per id) abbilden, damit kein Sprung sichtbar ist
      final currentId = state.shuffledWordIds[state.index];
      final newIndex = newIds.indexOf(currentId);
      _set(shuffledWordIds: newIds, index: newIndex >= 0 ? newIndex : 0);
      
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

    // 11) Stage-Transition Event feuern
    print('🎯 EMIT StageEvent cat=${state.categoryId} word=$currentId from=$oldStage to=$serverStage due=$isDueNow');
    StageTransitionEvent.emit(StageTransitionEvent(
      categoryId: state.categoryId,
      wordId: currentId,
      fromStage: oldStage,
      toStage: serverStage,
      wasDueBefore: isDueNow,
    ));

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
      });
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
    // Zähle Stufen in der aktuell aktiven Menge (kannst auch _capActivePool-Spiegel nutzen)
    int s1 = 0, s2 = 0, s3 = 0, s4 = 0;
    for (final w in queue) {
      switch (w.srsStage) {
        case 1: s1++; break;
        case 2: s2++; break;
        case 3: s3++; break;
        case 4: s4++; break;
      }
    }

    // Gate-Stufen NUR anhand der real verfügbaren Karten in der Queue öffnen
    if (s1 < 12) return 1;  // erst S1 aufbauen
    if (s2 < 20) return 2;  // dann S2
    if (s3 < 25) return 3;  // dann S3
    if (s4 < 30) return 4;  // dann S4
    return 5;
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
    // === Im Reset-Handler EINSETZEN (bestehende lokale-only-Resets ersetzen) ===
    final sb = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final catId = state.categoryId; // oder deine aktuelle Category-ID

    try {
      // 1) Server-Reset
      await sb.rpc('fn_reset_user_category', params: {'p_category_id': catId});

      // 2) Sofort für LearnMode wieder befüllen (volle S0)
      await sb.rpc('fn_seed_user_category', params: {'p_category_id': catId});

      // 3) Category-Ansicht soll 0 zeigen → just_reset setzen
      await prefs.setString('learn_stages_$catId', '0,0,0,0,0,0');
      await prefs.setInt('today_new_$catId', 0);
      await prefs.setInt('today_repeats_$catId', 0);
      await prefs.setBool('just_reset_$catId', true);

      // 4) Event feuern (damit Category neu lädt – sie zeigt 0 dank Marker)
      ResetEvent.notifyReset(catId);

      // 5) Laufende Session/Queues leeren
      _cooldown.clear();
      _wordTimer?.cancel();
      _set(
        wordQueue: const [],
        shuffledWordIds: const [],
        index: 0,
        recentlySwiped: const [],
        cardsSwipedInSession: 0,
      );

      // 6) LearnMode danach NICHT aus den lokalen Prefs lesen, sondern Backend neu laden
      final prog = await fetchCategoryProgress(catId);   // <- zieht S0 voll vom Server
      _set(stages: prog.stages); // <- nutze hier prog.stages (NICHT localStages)
      
      // 7) Frisch laden
      await _loadWords();

    } catch (e) {
      // optional: SnackBar/Log
      print('⚠️ Reset failed: $e');
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
