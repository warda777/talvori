import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

const _kCard = Color(0xFF2D2C2C);
const _kStageOuter = Color(0xFFE4B866);
const _kStageInner = Color(0xFF2D2C2C);
const _kStageInnerRed = Color(0xFFA05260);

// ===== Category Wheel Knobs (kopiert aus category_detail_screen.dart) =====
const double kWheelWidth            = 280.0;
const double kWheelHeight           = 72.0;
const double kWheelItemExtent       = 34.0;
const double kWheelPillWidth        = 240.0;
const double kWheelPillRadius       = 14.0;

const double kWheelActiveOpacity    = 1.0;
const double kWheelNeighborOpacity  = 0.55;
const double kWheelFarOpacity       = 0.30;

const double kWheelActiveScale      = 1.00;
const double kWheelNeighborScale    = 0.94;
const double kWheelFarScale         = 0.88;

const double kWheelGlowBlur         = 18.0;
const double kWheelGlowOpacity      = 0.35;

const double kWheelEdgeFadeHeight   = 24.0;

const double kWheelArrowRightOut = 22.0;
const int    kWheelArrowAutoHideMs  = 800; // Schneller verstecken
const double kWheelArrowNudge       = 0.0;
const double kWheelOffsetX          = 0.0;
const double kWheelOffsetY          = 0.0;

// ===== Switches Knobs =====
const double kSwitchesOffsetX    = 0.0;
const double kSwitchesOffsetY    = -12.0;
const double kSwitchGap          = 12.0;

// ===== Globale Hilfsfunktion für Daily Stats =====
/// Lädt tägliche Lernstatistiken für eine Kategorie
/// Returns: (newCount, repeatCount) für den heutigen Tag
Future<(int, int)> loadDailyLearningStats(String categoryId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'daily_stats_$categoryId';
    final stored = prefs.getString(key);
    
    if (stored != null) {
      final parts = stored.split(':');
      if (parts.length == 3) {
        final storedDate = parts[0];
        if (storedDate == today) {
          final newCount = int.tryParse(parts[1]) ?? 0;
          final repeatCount = int.tryParse(parts[2]) ?? 0;
          return (newCount, repeatCount);
        }
      }
    }
    
    return (0, 0); // Keine Daten oder anderer Tag
  } catch (e) {
    print('⚠️ Failed to load daily stats: $e');
    return (0, 0);
  }
}
class LearnModeScreen extends StatefulWidget {
  final String categoryId;
  final String title; // z.B. "Money & Shopping"

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  State<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends State<LearnModeScreen> with TickerProviderStateMixin {
  static const _kStoreKeyPrefix = 'learn_pos_';
  static const _kStageKeyPrefix = 'learn_stages_';
  static const _kDailyStatsPrefix = 'daily_stats_'; // Format: "date:newCount:repeatsCount"
  
  bool _running = true;
  int _index = 0;
  bool _loading = true;
  bool _showTranslation = false; // Zeigt Rückseite (deutsche Übersetzung)
  AnimationController? _flipController;
  Animation<double>? _flipAnimation;
  
  // Swipe-Animation
  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0.0;
  bool _isDragging = false;
  
  // Slide-in Animation
  bool _isSlidingIn = false;
  // Audio Player für Sounds
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Lokale Stage-Overrides für sofortige UI-Updates
  final Map<String, int> _stageOverride = {};
  
  // Timer für Zeitlimit pro Wort
  Timer? _wordTimer;
  double _remainingMillis = 10000.0; // Millisekunden für flüssige Animation
  final int _timeLimit = 10; // Sekunden pro Wort
  bool _timerPaused = false;
  bool _timerActive = false; // Ob Timer überhaupt aktiviert wurde

  // Kategorien aus DB + aktuelle Auswahl (für das Wheel im Header)
  List<CategoryInfo> _categories = const [];
  int _selectedCategoryIndex = 0;
  
  // Aktueller Kategorie-Helper
  String get _currentCatId {
    if (_categories.isNotEmpty && _selectedCategoryIndex < _categories.length) {
      return _categories[_selectedCategoryIndex].id;
    }
    return widget.categoryId;
  }
  
  // Stage-Daten für Switches (s0..s5)
  List<int> _stages = const [0, 0, 0, 0, 0, 0];
  int _goalPerStage = 100;
  int _totalWordsInCategory = 0; // Gesamtzahl der Wörter in dieser Kategorie (aus Backend)
  
  // Kartenbasiertes Wiederholungssystem
  List<String> _recentlySwipedCards = []; // Kürzlich geswipete Karten (für Wiederholung)
  int _cardsSwipedInSession = 0; // Anzahl Karten in aktueller Session geswipet
  bool _hasLoadedReviews = false; // Ob Wiederholungen bereits geladen wurden
  static const int _newCardsBeforeReview = 10; // Nach X neuen Karten → Wiederholungen
  static const double _reviewRatio = 0.5; // 50% der neuen Karten wiederholen (anpassbar)

  // Wörter-Queue aus der Datenbank
  List<WordUserView> _wordQueue = [];
  List<String> _shuffledWordIds = []; // Zufällige Reihenfolge, keine Wiederholungen
  
  String get _storeKey => '$_kStoreKeyPrefix${widget.categoryId}';
  String get _stageStoreKey => '$_kStageKeyPrefix$_currentCatId';

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController!, curve: Curves.easeInOut),
    );
    _restorePosition();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final cats = await fetchAllCategories();
      
      setState(() {
        _categories = cats;
        _selectedCategoryIndex = cats.isEmpty ? 0 : _findInitialIndex(cats);
      });
     // Lade Stage-Daten und Wörter für die aktuelle Kategorie
      if (_categories.isNotEmpty) {
        await _loadStageData();
        await _loadWords();
      }
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Kategorien: $e')),
        );
      }
    }
  }

  Future<void> _loadStageData() async {
    bool hasLocalData = false;
    
    try {
      // 1. Versuche erst lokal gespeicherte Daten zu laden (schnell)
      final prefs = await SharedPreferences.getInstance();
      final storedStages = prefs.getString(_stageStoreKey);
      
      if (storedStages != null) {
        try {
          final List<dynamic> parsed = List.from(storedStages.split(',').map(int.parse));
          if (parsed.length == 6) {
            setState(() {
              _stages = List<int>.from(parsed);
            });
            hasLocalData = true;
            print('📦 Loaded stages from local storage: $_stages');
          }
        } catch (e) {
          print('⚠️ Failed to parse stored stages: $e');
        }
      }
      
      // 2. Lade von Backend (für _totalWordsInCategory, aber NICHT für stages wenn lokal verfügbar)
      final prog = await fetchCategoryProgress(_currentCatId);
      print('📊 Backend stages: ${prog.stages}, total: ${prog.total}');
      
      setState(() {
        // Überschreibe stages NUR wenn keine lokalen Daten vorhanden
        if (!hasLocalData) {
          _stages = prog.stages;
          print('✅ Using backend stages (no local data)');
        } else {
          print('✅ Keeping local stages (more recent than backend)');
        }
        _totalWordsInCategory = prog.total; // Gesamtzahl kommt immer vom Backend
      });
      
      // 3. Speichere aktuelle Daten lokal als Backup
      await _persistStageData();
    } catch (e) {
      print('❌ Error loading stage data from backend: $e');
      print('   → Using local data if available');
      // Fallback: behalte lokale Daten (wurden oben bereits geladen)
      // Nur wenn auch lokal nichts da ist, setze Default
      if (_stages.every((s) => s == 0)) {
        setState(() {
          _stages = const [0, 0, 0, 0, 0, 0];
        });
      }
    }
  }
  
  Future<void> _persistStageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stagesStr = _stages.join(',');
      await prefs.setString(_stageStoreKey, stagesStr);
      print('💾 Persisted stages locally: $stagesStr');
    } catch (e) {
      print('⚠️ Failed to persist stages: $e');
    }
  }

  /// Speichert tägliche Lernstatistiken (resettet automatisch bei neuem Tag)
  Future<void> _incrementDailyStats({required bool isNew}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final key = '$_kDailyStatsPrefix${_currentCatId}';
      final stored = prefs.getString(key);
      
      int newCount = 0;
      int repeatCount = 0;
      
      if (stored != null) {
        final parts = stored.split(':');
        if (parts.length == 3) {
          final storedDate = parts[0];
          if (storedDate == today) {
            // Gleicher Tag - inkrementiere
            newCount = int.tryParse(parts[1]) ?? 0;
            repeatCount = int.tryParse(parts[2]) ?? 0;
          }
          // Anderer Tag - reset automatisch (newCount/repeatCount bleiben bei 0)
        }
      }
      
      // Inkrementiere je nach Typ
      if (isNew) {
        newCount++;
      } else {
        repeatCount++;
      }
      
      final newValue = '$today:$newCount:$repeatCount';
      await prefs.setString(key, newValue);
      print('📊 Daily stats updated: new=$newCount, repeats=$repeatCount');
    } catch (e) {
      print('⚠️ Failed to update daily stats: $e');
    }
  }


  Future<void> _loadWords() async {
    try {
      final catId = _currentCatId;
      print('🔍 Loading words for category: $catId (isEmpty: ${catId.isEmpty})');
      
      if (catId.isEmpty) {
        print('⚠️ Category ID is empty, skipping word load');
        return;
      }
      
      // Lade Wörter aus der Learn-Queue für die aktuelle Kategorie
      // Lade alle verfügbaren Wörter (kein Limit)
      final words = await fetchLearnQueue(catId);
      
      print('🔍 Loaded ${words.length} words for category $catId');
      // Erstelle eine zufällige Liste von IDs (keine Wiederholungen)
      final allWordIds = List<String>.from(words.map((w) => w.id));
      
      // Setze _wordQueue zuerst, damit _getSmartCardOrder() darauf zugreifen kann
      _wordQueue = words;
      
      // Wende intelligente SRS-Auswahl an: 70% Wiederholungen, 30% neue Karten
      final smartOrder = await _getSmartCardOrder();
      List<String> shuffledIds;
      if (smartOrder.isNotEmpty) {
        // Filtere gültige Indizes
        final validIndices = smartOrder.where((i) => i >= 0 && i < allWordIds.length).toList();
        shuffledIds = validIndices.map((i) => allWordIds[i]).toList();
        print('🎯 Smart order applied: ${shuffledIds.length} cards');
        print('🎯 Smart order indices: ${validIndices.take(3).join(", ")}...');
        if (validIndices.length != smartOrder.length) {
          print('⚠️ Filtered out ${smartOrder.length - validIndices.length} invalid indices');
        }
      } else {
        // Fallback: Einfaches Shuffle wenn keine intelligente Auswahl möglich
        shuffledIds = List<String>.from(allWordIds);
        shuffledIds.shuffle();
        print('🎯 Fallback shuffle applied: ${shuffledIds.length} cards');
      }
      
      setState(() {
        _wordQueue = words;
        _shuffledWordIds = shuffledIds;
        
        // Reset Index, wenn neue Kategorie
        if (_index >= _shuffledWordIds.length) {
          _index = 0;
        }
      });
      
      print('🎯 UI updated with ${_shuffledWordIds.length} cards');
      if (_shouldShowReviews()) {
        print('🎯 Reviews should now be visible in UI!');
        print('🎯 First few cards: ${_shuffledWordIds.take(3).join(", ")}');
        print('🎯 Review cards in queue: ${_recentlySwipedCards.take(3).join(", ")}');
        
        // Prüfe ob die ersten Karten in der Queue Wiederholungen sind
        final firstCard = _shuffledWordIds.isNotEmpty ? _shuffledWordIds[0] : 'none';
        final isFirstCardReview = _recentlySwipedCards.contains(firstCard);
        print('🎯 First card is review: $isFirstCardReview (ID: $firstCard)');
        
        // Prüfe ob die ersten 3 Karten Wiederholungen sind
        for (int i = 0; i < 3 && i < _shuffledWordIds.length; i++) {
          final cardId = _shuffledWordIds[i];
          final isReview = _recentlySwipedCards.contains(cardId);
          print('🎯 Card $i: $cardId is review: $isReview');
        }
        
        // Prüfe ob die Wiederholungen korrekt in der Queue sind
        final reviewCount = _shuffledWordIds.where((id) => _recentlySwipedCards.contains(id)).length;
        print('🎯 Review cards in shuffled queue: $reviewCount/${_shuffledWordIds.length}');
        // Prüfe ob die ersten Karten tatsächlich Wiederholungen sind
        if (reviewCount == 0) {
          print('❌ ERROR: No review cards found in shuffled queue!');
        } else {
          print('✅ SUCCESS: Review cards found in shuffled queue!');
        }
      }
      
      // Timer startet nur beim Drücken des Play-Buttons
      
      if (words.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Wörter in dieser Kategorie gefunden.')),
        );
      }
    } catch (e) {
      print('❌ Error loading words: $e');
      // Fallback: leere Liste
      setState(() {
        _wordQueue = [];
        _shuffledWordIds = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Wörter: $e')),
        );
      }
    }
  }

  int _findInitialIndex(List<CategoryInfo> cats) {
    // Suche basierend auf categoryId oder title
    if (widget.categoryId.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == widget.categoryId);
      if (i >= 0) return i;
    }
    
    // Fallback: Suche nach title/name
    final i = cats.indexWhere((c) => c.name == widget.title);
    if (i >= 0) return i;
    
    return 0;
  }

  Future<void> _restorePosition() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _index = sp.getInt(_storeKey) ?? 0);
  }

  Future<void> _persistPosition() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_storeKey, _index);
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    _flipController?.dispose();
    _audioPlayer.dispose(); // AudioPlayer aufräumen
    _persistPosition();
    _persistStageData(); // Speichere Stage-Daten auch beim Verlassen
    super.dispose();
  }
  
  // Timer-Methoden
  void _startWordTimer() {
    _wordTimer?.cancel();
    setState(() {
      _remainingMillis = _timeLimit * 1000.0;
      _timerPaused = false;
      _timerActive = true; // Timer ist jetzt aktiviert
    });
    const tickInterval = 16; // ~60 FPS für flüssige Animation
    _wordTimer = Timer.periodic(const Duration(milliseconds: tickInterval), (timer) {
      if (_timerPaused) return;
      
      setState(() {
        _remainingMillis -= tickInterval;
      });
      
      if (_remainingMillis <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }
  
  void _stopTimer() {
    _wordTimer?.cancel();
    setState(() {
      _timerActive = false;
      _timerPaused = false;
      _running = false; // Auch _running zurücksetzen
      _remainingMillis = _timeLimit * 1000.0;
    });
  }
  
  void _pauseTimer() {
    setState(() {
      _timerPaused = true;
    });
  }
  
  void _resumeTimer() {
    setState(() {
      _timerPaused = false;
    });
  }
  void _resetTimer() {
    setState(() {
      _remainingMillis = _timeLimit * 1000.0; // Zurück auf 10 Sekunden
    });
  }
  
  // Sound-Methoden
  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Sound error: $e');
      // Fallback: System-Sound
      HapticFeedback.lightImpact();
    }
  }
  
  Future<void> _playIncorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      print('Sound error: $e');
      // Fallback: System-Sound
      HapticFeedback.mediumImpact();
    }
  }
  
  Future<void> _playNewCardSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/new_card.mp3'));
    } catch (e) {
      print('Sound error: $e');
      // Fallback: System-Sound
      HapticFeedback.selectionClick();
    }
  }
  void _handleTimeout() {
    // Zeit abgelaufen → als falsch werten
    HapticFeedback.mediumImpact();
    _animateCardAway(false);
  }

  void _onCardTap() {
    if (_shuffledWordIds.isEmpty) return;
    if (_flipController == null) return;
    // Nur blockieren wenn Timer pausiert ist
    if (_timerActive && !_running) return;
    
    HapticFeedback.selectionClick();
    
    // Flip zwischen Vorder- und Rückseite (ohne Wort zu wechseln)
    if (!_showTranslation) {
      setState(() => _showTranslation = true);
      _flipController!.forward();
    } else {
      setState(() => _showTranslation = false);
      _flipController!.reverse();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Nur blockieren wenn Timer pausiert ist
    if (_timerActive && !_running) return;
    setState(() {
      _isDragging = true;
      _cardOffset += details.delta;
      // Rotation basierend auf horizontaler Position (max ±15 Grad)
      _cardRotation = (_cardOffset.dx / 1000).clamp(-0.26, 0.26); // 0.26 rad ≈ 15°
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    // Nur blockieren wenn Timer pausiert ist
    if (_timerActive && !_running) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.35; // 35% des Bildschirms
    
    setState(() => _isDragging = false);
    
    // Swipe nach rechts (richtig) - Karte wird weggeworfen
    if (_cardOffset.dx > threshold) {
      _playCorrectSound();
      _animateCardAway(true);
    }
    // Swipe nach links (falsch) - Karte wird weggeworfen
    else if (_cardOffset.dx < -threshold) {
      _playIncorrectSound();
      _animateCardAway(false);
    }
    // Nicht weit genug geswiped - zurück zur Mitte
    else {
      _resetCardPosition();
    }
  }

  void _resetCardPosition() {
    setState(() {
      _cardOffset = Offset.zero;
      _cardRotation = 0.0;
    });
  }

  Future<void> _animateCardAway(bool correct) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = correct ? screenWidth * 1.5 : -screenWidth * 1.5;
    
    HapticFeedback.mediumImpact();
    // Animiere Karte weg
    setState(() {
      _cardOffset = Offset(endX, _cardOffset.dy - 100);
      _cardRotation = correct ? 0.5 : -0.5;
    });
    
    // Warte auf Animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Sende Review an Backend und update Stages
    final currentWord = _currentWord;
    if (currentWord != null) {
      try {
        // Tracke geswipete Karte für kartenbasiertes System
        await _trackSwipedCard(currentWord.id, correct);
        
        // Merke vorheriges Stage (vom aktuellen Wort)
        final oldStage = _getStageFor(currentWord.id);
        
        // Berechne neues Stage (lokal geschätzt)
        int estimatedNewStage;
        
        // Prüfe ob es eine Wiederholung ist
        final isReview = _recentlySwipedCards.contains(currentWord.id);
        
        if (correct) {
          if (isReview) {
            // Wiederholung richtig: Stage hoch (max 5)
            estimatedNewStage = (oldStage + 1).clamp(0, 5);
            print('🔄 Review correct: Stage $oldStage → $estimatedNewStage');
          } else {
            // Neue Karte richtig: Stage hoch (max 5)
            estimatedNewStage = (oldStage + 1).clamp(0, 5);
            print('🆕 New card correct: Stage $oldStage → $estimatedNewStage');
          }
        } else {
          if (isReview) {
            // Wiederholung falsch: Stage runter (min 0)
            estimatedNewStage = (oldStage - 1).clamp(0, 5);
            print('🔄 Review incorrect: Stage $oldStage → $estimatedNewStage');
          } else {
            // Neue Karte falsch: Stage runter (min 0)
            estimatedNewStage = (oldStage - 1).clamp(0, 5);
            print('🆕 New card incorrect: Stage $oldStage → $estimatedNewStage');
          }
        }
        
        // direkt NACH: int estimatedNewStage = (oldStage + 1/ - 1).clamp(0, 5);
        _setLocalWordStage(currentWord.id, estimatedNewStage);
        
        // Optimistisches UI-Update: Stage-Zähler sofort aktualisieren
        print('🎯 Optimistic update: word="${currentWord.text}", oldStage=$oldStage, estimatedNew=$estimatedNewStage, correct=$correct');
        print('   Stages BEFORE: $_stages');
        
        setState(() {
          final newStages = List<int>.from(_stages);
          
          // Verringere das alte Stage (Wort verlässt diese Stufe)
          if (oldStage >= 0 && oldStage < newStages.length && newStages[oldStage] > 0) {
            newStages[oldStage]--;
            print('   Stage[$oldStage]: ${_stages[oldStage]} → ${newStages[oldStage]}');
          }
          
          // Erhöhe das neue Stage (Wort landet in dieser Stufe)
          if (estimatedNewStage >= 0 && estimatedNewStage < newStages.length) {
            newStages[estimatedNewStage]++;
            print('   Stage[$estimatedNewStage]: ${_stages[estimatedNewStage]} → ${newStages[estimatedNewStage]}');
          }
          
          _stages = newStages;
          print('   Stages AFTER: $_stages');
        });
        
        // Speichere Stage-Daten lokal (persistent)
        await _persistStageData();
        
        // Tracke tägliche Statistiken (nur bei korrekten Antworten)
        if (correct) {
          final isNew = oldStage == 0; // War das Wort neu (Stage 0)?
          await _incrementDailyStats(isNew: isNew);
        }
        
        // Backend-Call (gibt echtes neues Stage zurück)
        final (actualNewStage, _) = await submitReview(currentWord.id, correct);
        
        print('✅ Backend confirmed: Stage $oldStage → $actualNewStage (estimated: $estimatedNewStage)');
        
        // Nach dem Backend-Call (final (actualNewStage, _) = await submitReview(...)) – falls abweichend, korrigieren:
        if (actualNewStage != estimatedNewStage) {
          _setLocalWordStage(currentWord.id, actualNewStage);
        }
        
        // Speichere nächste Wiederholungszeit basierend auf tatsächlichem Stage
        final nextReview = _calculateNextReview(actualNewStage, correct);
        await _setNextReviewTime(currentWord.id, nextReview);
        print('⏰ Next review scheduled: ${nextReview.toIso8601String()}');
        
        // Korrektur falls Backend-Antwort abweicht (z.B. bei spezieller SRS-Logik)
        if (mounted && actualNewStage != estimatedNewStage) {
          setState(() {
            final newStages = List<int>.from(_stages);
            // Korrigiere: verringere geschätztes Stage, erhöhe echtes Stage
            if (estimatedNewStage >= 0 && estimatedNewStage < newStages.length && newStages[estimatedNewStage] > 0) {
              newStages[estimatedNewStage]--;
            }
            if (actualNewStage >= 0 && actualNewStage < newStages.length) {
              newStages[actualNewStage]++;
            }
            _stages = newStages;
            print('🔄 Corrected stages: estimated=$estimatedNewStage, actual=$actualNewStage');
          });
          // Speichere korrigierte Daten
          await _persistStageData();
        }
      } catch (e) {
        print('❌ Review error: $e');
        print('⚠️ Keeping optimistic updates despite error (fix fn_user_review in Supabase!)');
        // NICHT _loadStageData() aufrufen - behalte optimistische Updates
        // TODO: Fix fn_user_review in Supabase (column reference "word_id" is ambiguous)
      }
    }
    
    // Neue Karte vorbereiten (außerhalb des Bildschirms)
    setState(() {
      _cardOffset = const Offset(0, -800);
      _cardRotation = 0.0;
      _showTranslation = false;

      if (correct) {
        // Richtig: normal weiter zur nächsten Karte
        _index = (_index + 1) % _shuffledWordIds.length;
      } else {
        // Falsch: aktuelle Karte ans Ende schieben,
        // Index NICHT erhöhen (damit jetzt die nächste Karte dran ist)
        final id = currentWord?.id;
        if (id == null) return; // Sicherheitscheck
        // erste Vorkommnis entfernen und hinten anhängen
        _shuffledWordIds.remove(id);
        _shuffledWordIds.add(id);

        // sicherstellen, dass sie als Review gilt und später wiederkommt
        if (!_recentlySwipedCards.contains(id)) {
          _recentlySwipedCards.add(id);
        }

        // Index bleibt auf derselben Position, zeigt nun auf die nächste Karte
        _index = _index % _shuffledWordIds.length;
      }

      _isSlidingIn = true;
    });

    // Prüfe ob neue Karten geladen werden müssen (nach Wiederholungen)
    if (_shouldShowReviews() && _index >= _shuffledWordIds.length - 1) {
      print('🔄 Reloading cards for reviews...');
      await _loadWords();
    } else if (_shouldShowReviews()) {
      // Wenn Wiederholungen fällig sind, aber noch Karten in der Queue sind,
      // lade NICHT neue Karten - die Wiederholungen sind bereits in der Queue
      print('🔄 Reviews are ready, but not reloading to avoid overwriting reviews');
    }
    
    // Flip zurück zur Vorderseite
    _flipController?.reset();
    
    _persistPosition();
    
    // Timer zurücksetzen wenn Timer aktiv ist
    if (_timerActive) {
      _resetTimer();
    }
    
    // Kurze Pause, dann Karte sanft hereinsliden lassen
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Jetzt die Animation starten - Karte von oben zur Mitte
    _playNewCardSound(); // Sound für neue Karte
    setState(() {
      _cardOffset = Offset.zero; // Zur Mitte animieren
    });
    
    // Animation beenden nach der Dauer
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _isSlidingIn = false;
    });
  }
  
  // Aktuelles Wort basierend auf Index
  WordUserView? get _currentWord {
    if (_shuffledWordIds.isEmpty || _index >= _shuffledWordIds.length) {
      return null;
    }
    final wordId = _shuffledWordIds[_index];
    return _wordQueue.firstWhere((w) => w.id == wordId, orElse: () => _wordQueue.first);
  }
  
  // SRS-Level in A1-C2 Format konvertieren
  String _getSrsLevelDisplay(int? srsStage) {
    final stage = srsStage ?? 0;
    
    if (stage == 0) return 'A1';
    if (stage == 1) return 'A2';
    if (stage == 2) return 'B1';
    if (stage == 3) return 'B2';
    if (stage == 4) return 'C1';
    if (stage == 5) return 'C2';
    
    // Fallback für unerwartete Werte
    return 'A1';
  }
  
  // SRS-Algorithmus: Berechne nächste Wiederholung basierend auf Anki-Algorithmus
  DateTime _calculateNextReview(int currentStage, bool correct) {
    final now = DateTime.now();
    
    if (correct) {
      // Richtig beantwortet: Stage erhöhen, Intervall verlängern
      switch (currentStage) {
        case 0: return now.add(const Duration(minutes: 1));    // A1 → A2: 1 Min
        case 1: return now.add(const Duration(minutes: 10));   // A2 → B1: 10 Min
        case 2: return now.add(const Duration(hours: 1));      // B1 → B2: 1 Stunde
        case 3: return now.add(const Duration(days: 1));       // B2 → C1: 1 Tag
        case 4: return now.add(const Duration(days: 3));       // C1 → C2: 3 Tage
        case 5: return now.add(const Duration(days: 7));       // C2 → C2: 1 Woche
        default: return now.add(const Duration(minutes: 1));
      }
    } else {
      // Falsch beantwortet: Zurück zu Stage 0, sofort wiederholen
      return now.add(const Duration(seconds: 10));
    }
  }
  
  // Intelligente Karten-Auswahl: Kartenbasiertes System
  Future<List<int>> _getSmartCardOrder() async {
    final reviewCards = <int>[];
    final newCards = <int>[];
    
    print('🎯 Getting smart card order...');
    print('   Session: $_cardsSwipedInSession/$_newCardsBeforeReview');
    print('   Review list: ${_recentlySwipedCards.length} cards');
    print('   Should show reviews: ${_shouldShowReviews()}');
    
    // Kategorisiere Karten (verwende _wordQueue statt _shuffledWordIds)
    for (int i = 0; i < _wordQueue.length; i++) {
      final word = _wordQueue[i];
      final wordId = word.id;
      // Prüfe ob es eine Wiederholung ist (aus kürzlich geswipeten Karten)
      if (_shouldReviewCard(wordId)) {
        reviewCards.add(i);
      } else {
        // Alle anderen Karten sind "neu" für das kartenbasierte System
        newCards.add(i);
      }
    }
    
    print('   Found ${newCards.length} new cards, ${reviewCards.length} review cards');
    
    // Mische die Listen
    reviewCards.shuffle();
    newCards.shuffle();
    
    final result = <int>[];
    
    // Kartenbasiertes System: Prüfe ob Wiederholungen fällig sind
    if (_shouldShowReviews()) {
      // Zeige Wiederholungen aus kürzlich geswipeten Karten
      final reviewIndices = _getReviewIndices(_recentlySwipedCards.length);
      
      for (final index in reviewIndices) {
        result.add(index);
      }
      
      print('🔄 Showing ${reviewIndices.length} reviews from recently swiped cards');
      print('   Review cards: ${_recentlySwipedCards.take(3).join(", ")}...');
      print('   Review indices: ${reviewIndices.take(3).join(", ")}...');
    } else {
      // Zeige neue Karten
      final remainingNewCards = _newCardsBeforeReview - _cardsSwipedInSession;
      final newCount = remainingNewCards > 0 ? remainingNewCards : newCards.length;
      
      // Stelle sicher, dass wir genug Karten haben
      if (newCards.length < newCount) {
        print('⚠️ Not enough new cards available: ${newCards.length} < $newCount');
        // Zeige alle verfügbaren neuen Karten
        for (int i = 0; i < newCards.length; i++) {
          result.add(newCards[i]);
        }
        print('🆕 Showing all ${newCards.length} available new cards');
      } else {
        for (int i = 0; i < newCount && i < newCards.length; i++) {
          result.add(newCards[i]);
        }
        print('🆕 Showing $newCount new cards (${_cardsSwipedInSession}/$_newCardsBeforeReview swiped)');
      }
    }
    
    print('   Final result: ${result.length} cards');
    return result;
  }
  
  // Prüft ob eine Karte wiederholt werden sollte (kartenbasiert)
  bool _shouldReviewCard(String wordId) {
    // Kartenbasiertes System: Wiederhole nur kürzlich geswipete Karten
    return _recentlySwipedCards.contains(wordId);
  }
  
  // Prüft ob Wiederholungen gezeigt werden sollten
  bool _shouldShowReviews() {
    // Zeige Wiederholungen wenn genug neue Karten geswipet wurden
    final shouldShow = _cardsSwipedInSession >= _newCardsBeforeReview && _recentlySwipedCards.isNotEmpty;
    if (shouldShow) {
      print('🎯 Reviews are ready! Showing ${_recentlySwipedCards.length} review cards');
    }
    return shouldShow;
  }
  
  // Gibt Indizes der Karten zurück, die wiederholt werden sollen
  List<int> _getReviewIndices(int reviewCount) {
    final reviewIndices = <int>[];
    
    print('🔍 Looking for review indices: need $reviewCount, have ${_recentlySwipedCards.length} review cards');
    
    // Suche in der aktuellen _wordQueue Liste (nicht in _shuffledWordIds)
    for (int i = 0; i < _wordQueue.length && reviewIndices.length < reviewCount; i++) {
      final wordId = _wordQueue[i].id;
      if (_recentlySwipedCards.contains(wordId)) {
        reviewIndices.add(i);
        print('   Found review card at index $i: $wordId');
      }
    }
    
    print('   Found ${reviewIndices.length} review indices');
    return reviewIndices;
  }
  
  // Trackt eine geswipete Karte für das kartenbasierte System
  Future<void> _trackSwipedCard(String wordId, bool correct) async {
    final currentWord = _wordQueue.firstWhere((w) => w.id == wordId, orElse: () => _wordQueue.first);
    final stage = currentWord.srsStage ?? 0;
    
    print('🔍 Tracking card: $wordId, stage: $stage, correct: $correct');
    print('   Current session: $_cardsSwipedInSession/$_newCardsBeforeReview');
    print('   Review list: ${_recentlySwipedCards.length} cards');
    
    // Prüfe ob es eine Wiederholung ist
    final isReview = _recentlySwipedCards.contains(wordId);
    
    if (isReview) {
      // Wiederholung geswipet - diese Karten sollten in die nächste Switch gehen
      if (correct) {
        // Richtig beantwortet → entferne aus Wiederholungsliste
        _recentlySwipedCards.remove(wordId);
        print('✅ Review correct: $wordId removed from review list');
        
        // WICHTIG: Diese Karte sollte in die nächste Switch gehen (Stage 1 → 2)
        // Das wird in _animateCardAway() behandelt, wo der Stage korrekt aktualisiert wird
      } else {
        // Falsch beantwortet → bleibt in Wiederholungsliste
        print('❌ Review incorrect: $wordId stays in review list');
      }
      
      // Wenn alle Wiederholungen abgeschlossen, starte neuen Zyklus
      if (_recentlySwipedCards.isEmpty) {
        _cardsSwipedInSession = 0;
        _hasLoadedReviews = false;
        print('🎉 All reviews completed! Starting new cycle');
        // Lade neue Karten für den nächsten Zyklus
        await _loadWords();
        print('🔄 New cycle started with fresh cards');
      }
    } else {
      // Alle Karten zählen als "neu" für das kartenbasierte System
      // (unabhängig von ihrem tatsächlichen Stage)
      _cardsSwipedInSession++;
      
      // Füge zur Liste der kürzlich geswipeten Karten hinzu (nur bei korrekten Antworten)
      if (correct && !_recentlySwipedCards.contains(wordId)) {
        _recentlySwipedCards.add(wordId);
        print('📝 Tracked card: $wordId (${_cardsSwipedInSession}/$_newCardsBeforeReview)');
      } else {
        print('⚠️ Card not tracked: correct=$correct, alreadyInList=${_recentlySwipedCards.contains(wordId)}');
      }
      
      // Wenn genug neue Karten geswipet wurden, bereite Wiederholungen vor
      if (_cardsSwipedInSession >= _newCardsBeforeReview) {
        print('🎯 Ready for reviews! ${_recentlySwipedCards.length} cards to review');
        // Lade neue Karten mit Wiederholungen nur einmal
        if (!_hasLoadedReviews) {
          await _loadWords();
          _hasLoadedReviews = true;
          print('🔄 Cards reloaded for reviews (first time)');
        } else {
          print('🔄 Reviews already loaded, skipping reload');
        }
      }
    }
  }
  // Resetet das kartenbasierte System (bei Kategorie-Wechsel oder Reset)
  void _resetCardBasedSystem() {
    _recentlySwipedCards.clear();
    _cardsSwipedInSession = 0;
    _hasLoadedReviews = false;
    print('🔄 Reset card-based system');
  }
  
  // Hilfsmethode: Nächste Wiederholungszeit für ein Wort
  Future<DateTime?> _getNextReviewTime(String wordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'next_review_${_currentCatId}_$wordId';
      final stored = prefs.getString(key);
      
      if (stored != null) {
        return DateTime.parse(stored);
      }
      
      // Fallback: Berechne basierend auf Stage
      final word = _wordQueue.firstWhere((w) => w.id == wordId, orElse: () => _wordQueue.first);
      final stage = word.srsStage ?? 0;
      
      if (stage == 0) return null; // Neue Karten haben keine Wiederholungszeit
      
      // Berechne nächste Wiederholung basierend auf Stage
      final now = DateTime.now();
      switch (stage) {
        case 1: return now.add(const Duration(minutes: 10));   // A2: 10 Min
        case 2: return now.add(const Duration(hours: 1));      // B1: 1 Stunde
        case 3: return now.add(const Duration(days: 1));       // B2: 1 Tag
        case 4: return now.add(const Duration(days: 3));       // C1: 3 Tage
        case 5: return now.add(const Duration(days: 7));       // C2: 1 Woche
        default: return now.add(const Duration(minutes: 1));
      }
    } catch (e) {
      print('⚠️ Error getting next review time: $e');
      return null;
    }
  }
  
  // Speichere nächste Wiederholungszeit für ein Wort
  Future<void> _setNextReviewTime(String wordId, DateTime nextReview) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'next_review_${_currentCatId}_$wordId';
      await prefs.setString(key, nextReview.toIso8601String());
    } catch (e) {
      print('⚠️ Error setting next review time: $e');
    }
  }

  // Helper-Methoden für Stage-Overrides
  int _getStageFor(String wordId) {
    final override = _stageOverride[wordId];
    if (override != null) return override;
    final w = _wordQueue.firstWhere((x) => x.id == wordId, orElse: () => _wordQueue.first);
    return (w.srsStage ?? 0);
  }

  void _setStageFor(String wordId, int newStage) {
    setState(() {
      _stageOverride[wordId] = newStage.clamp(0, 5);
    });
  }

  // Hilfsfunktion zum lokalen Aktualisieren der Stage
  void _setLocalWordStage(String wordId, int newStage) {
    // Da WordUserView immutable ist, nutzen wir das bestehende _stageOverride System
    // Das sorgt für sofortige UI-Updates
    _setStageFor(wordId, newStage);
    print('🔄 Local stage updated: $wordId → Stage $newStage');
  }

  Widget _buildCardFront(String word) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          // Level-Badge (A1–C2) oben rechts – Platzhalter
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _getSrsLevelDisplay(
                  _currentWord == null ? 0 : _getStageFor(_currentWord!.id)
                ),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          // Daily-Pick-Icon oben links – Platzhalter
          const Positioned(
            top: 12, left: 12,
            child: Icon(Icons.rocket_launch_rounded, color: Colors.white70, size: 20),
          ),
          // Wort + Audio-Icon (zentriert)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Intelligente Schriftgröße: Balance zwischen Größe und Lesbarkeit
                      // Einzelne Wörter: größer
                      // Phrasen (mehrere Wörter): etwas kleiner, aber gut lesbar
                      // Sehr lange Einzelwörter: minimal kleiner, mit Umbruch
                      
                      final wordCount = word.split(' ').length;
                      final isPhrase = wordCount > 1;
                      final totalLength = word.length;
                      
                      double fontSize;
                      int maxLines;
                      
                      if (isPhrase) {
                        // Phrasen: komfortabel lesbar, Umbruch erlaubt
                        if (totalLength > 40) {
                          fontSize = 26.0;
                          maxLines = 4;
                        } else if (totalLength > 25) {
                          fontSize = 28.0;
                          maxLines = 3;
                        } else {
                          fontSize = 30.0;
                          maxLines = 2;
                        }
                      } else {
                        // Einzelne Wörter: möglichst groß halten
                        if (totalLength > 18) {
                          fontSize = 28.0;
                          maxLines = 2; // Erlaubt Silbentrennung
                        } else if (totalLength > 12) {
                          fontSize = 30.0;
                          maxLines = 2;
                        } else {
                          fontSize = 34.0;
                          maxLines = 1;
                        }
                      }
                      return Text(
                        word,
                        textAlign: TextAlign.center,
                        maxLines: maxLines,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: play pronunciation here
                    },
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white70,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Timer-Bar unten - zentriert und verkürzt (wegen Radien)
          Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: _buildTimerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(String translation) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3939), // Etwas hellerer Hintergrund für Rückseite
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          // Swipe-Hinweis oben
          Positioned(
            top: 16, left: 0, right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_left, color: Colors.red.withOpacity(0.6), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Falsch',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Richtig',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.swipe_right, color: Colors.green.withOpacity(0.6), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Deutsche Übersetzung (zentriert)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final text = translation.isNotEmpty ? translation : '—';
                  // Intelligente Schriftgröße für deutsche Übersetzungen
                  // Deutsche Wörter sind oft länger (zusammengesetzte Nomen)
                  final wordCount = text.split(' ').length;
                  final isPhrase = wordCount > 1;
                  final totalLength = text.length;
                  
                  double fontSize;
                  int maxLines;
                  
                  if (isPhrase) {
                    // Phrasen: bequem lesbar, mehrzeilig
                    if (totalLength > 50) {
                      fontSize = 24.0;
                      maxLines = 5;
                    } else if (totalLength > 35) {
                      fontSize = 26.0;
                      maxLines = 4;
                    } else if (totalLength > 20) {
                      fontSize = 28.0;
                      maxLines = 3;
                    } else {
                      fontSize = 30.0;
                      maxLines = 2;
                    }
                  } else {
                    // Einzelne deutsche Wörter (oft lang wegen Komposita)
                    if (totalLength > 20) {
                      fontSize = 26.0;
                      maxLines = 3; // Silbentrennung bei langen Komposita
                    } else if (totalLength > 14) {
                      fontSize = 28.0;
                      maxLines = 2;
                    } else if (totalLength > 10) {
                      fontSize = 30.0;
                      maxLines = 2;
                    } else {
                      fontSize = 32.0;
                      maxLines = 1;
                    }
                  }
                  
                  return Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: maxLines,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.35,
                    ),
                  );
                },
              ),
            ),
          ),
          // Timer-Bar unten - zentriert und verkürzt (wegen Radien)
          Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: _buildTimerBar(),
          ),
        ],
      ),
    );
  }
  
  // Timer-Bar Widget
  Widget _buildTimerBar() {
    final progress = (_remainingMillis / (_timeLimit * 1000.0)).clamp(0.0, 1.0);
    final isLowTime = _remainingMillis <= 3000; // 3 Sekunden in Millisekunden
    final isActive = _timerActive; // Timer ist aktiviert (auch wenn pausiert)
    
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.black.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1), // Ausgegraut wenn nicht aktiv
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            // Fortschrittsbalken - sichtbar wenn Timer aktiviert (auch bei Pause)
            if (isActive)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLowTime
                            ? [Colors.red.shade700, Colors.red.shade400]
                            : [const Color(0xFFB1CCFE), const Color(0xFFD0E0FF)], // Hellblau wie Vocab-Kachel
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.75),
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuRow(
                  items: [
                    _MenuItem(icon: Icons.auto_awesome, label: 'ChatGPT', onTap: () {}),
                    _MenuItem(icon: Icons.translate_rounded, label: 'DeepL', onTap: () {}),
                    _MenuItem(icon: Icons.favorite_border, label: 'Favorit', onTap: () {}),
                    _MenuItem(icon: Icons.note_alt_outlined, label: 'Notizen', onTap: () {}),
                    _MenuItem(icon: Icons.settings_rounded, label: 'Einstellungen', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performReset() async {
    try {
      HapticFeedback.heavyImpact();
      
      // Verwende die tatsächliche Gesamtzahl aus dem Backend (nicht nur die Queue)
      final totalWords = _totalWordsInCategory > 0 
          ? _totalWordsInCategory 
          : _wordQueue.length; // Fallback auf Queue-Länge
      
      print('🔄 Resetting with $totalWords total words (from backend: $_totalWordsInCategory, queue: ${_wordQueue.length})');
      
      setState(() {
        // Alle Wörter zurück zu Stage 0
        _stages = [totalWords, 0, 0, 0, 0, 0];
      });
      
      // Speichere Reset lokal
      await _persistStageData();
      
      // Lösche alle gespeicherten Wiederholungszeiten für diese Kategorie
      await _clearAllReviewTimes();
      
      // Reset kartenbasiertes System
      _resetCardBasedSystem();
      
      // 1) Lokale Stage-Overrides wirklich leeren
      _stageOverride.clear();
      
      // 2) Serverseitig zurücksetzen
      try {
        final sb = Supabase.instance.client; // falls du einen Wrapper hast, entsprechend anpassen
        await sb.rpc('fn_reset_category_progress', params: {'cat': _currentCatId});
        print('✅ Server reset done for category: $_currentCatId');
      } catch (e) {
        print('❌ Server reset failed: $e');
      }
      
      // 3) Neu laden (Server ist jetzt auf 0)
      await _loadStageData();
      await _loadWords();
      
      print('🔄 Reset complete: $_stages');
    } catch (e) {
      print('❌ Reset error: $e');
    }
  }
  
  // Lösche alle Wiederholungszeiten für die aktuelle Kategorie
  Future<void> _clearAllReviewTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final prefix = 'next_review_${_currentCatId}_';
      
      for (final key in keys) {
        if (key.startsWith(prefix)) {
          await prefs.remove(key);
        }
      }
      
      print('🗑️ Cleared all review times for category $_currentCatId');
    } catch (e) {
      print('⚠️ Error clearing review times: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWord;
    final word = currentWord?.text ?? (_shuffledWordIds.isEmpty ? 'Keine Wörter\nverfügbar' : '—');
    final translation = currentWord?.translation ?? '';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: Back + Category Wheel
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 44, height: 44,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(kWheelOffsetX, kWheelOffsetY),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: kWheelWidth,
                                height: kWheelHeight,
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white54),
                                ),
                              )
                            : _CategoryWheel(
                                categories: _categories.map((c) => c.name).toList(),
                                initialIndex: _selectedCategoryIndex,
                                onChanged: (idx, label) {
                                  setState(() {
                                    _selectedCategoryIndex = idx;
                                    _index = 0; // Reset Index bei Kategorie-Wechsel
                                  });
                                  _resetCardBasedSystem(); // Reset kartenbasiertes System
                                  _loadStageData(); // Lade Stage-Daten für neue Kategorie
                                  _loadWords(); // Lade neue Wörter für neue Kategorie
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            // Karte in der Mitte (mit Flip-Animation + Swipe)
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    // Swipe-Indikatoren (Links = Falsch, Rechts = Richtig)
                    if (_isDragging) ...[
                      // Rechts = Richtig (Grün)
                      Positioned(
                        right: 40,
                        top: MediaQuery.of(context).size.height * 0.25,
                        child: AnimatedOpacity(
                          opacity: (_cardOffset.dx > 50) ? 0.8 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green, width: 3),
                            ),
                            child: const Icon(Icons.check, color: Colors.green, size: 48),
                          ),
                        ),
                      ),
                      // Links = Falsch (Rot)
                      Positioned(
                        left: 40,
                        top: MediaQuery.of(context).size.height * 0.25,
                        child: AnimatedOpacity(
                          opacity: (_cardOffset.dx < -50) ? 0.8 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red, width: 3),
                            ),
                            child: const Icon(Icons.close, color: Colors.red, size: 48),
                          ),
                        ),
                      ),
                    ],
                    
                    // Die Karte selbst
                    GestureDetector(
                      onTap: _onCardTap,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: AnimatedContainer(
                        duration: _isDragging ? Duration.zero : (_isSlidingIn ? const Duration(milliseconds: 400) : const Duration(milliseconds: 300)),
                        curve: _isSlidingIn ? Curves.easeOutCubic : Curves.easeOut,
                        transform: Matrix4.identity()
                          ..translate(_cardOffset.dx, _cardOffset.dy)
                          ..rotateZ(_isSlidingIn ? 0.0 : _cardRotation),
                        child: _flipAnimation == null
                            ? _buildCardFront(word)
                            : AnimatedBuilder(
                                animation: _flipAnimation!,
                                builder: (context, child) {
                                  final angle = _flipAnimation!.value * 3.14159;
                                  final isFront = angle < 1.5708;
                                  
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(angle),
                                    alignment: Alignment.center,
                                    child: isFront
                                        ? _buildCardFront(word)
                                        : Transform(
                                            transform: Matrix4.identity()..rotateY(3.14159),
                                            alignment: Alignment.center,
                                            child: _buildCardBack(translation),
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

            // Switches (Levels)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 5),
              child: Transform.translate(
                offset: Offset(kSwitchesOffsetX, kSwitchesOffsetY),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _VerticalStageSwitch(
                      count: _stages[0],
                      outerColor: _kStageInnerRed,
                      innerColor: const Color(0xFF2D2D2F),
                      highlight: _stages[0] > 0,
                      completed: false,
                      label: 'New',
                      note: '0',
                      isFirst: true,
                    ),
                    SizedBox(width: kSwitchGap),
                    for (int stage = 1; stage <= 5; stage++) ...[
                      _VerticalStageSwitch(
                        count: _stages[stage],
                        outerColor: _kStageOuter,
                        innerColor: _kStageInner,
                        highlight: _stages[stage] > 0 && _stages[stage] < _goalPerStage,
                        completed: _stages[stage] >= _goalPerStage,
                        label: 'S$stage',
                        note: '$stage',
                      ),
                      if (stage != 5) SizedBox(width: kSwitchGap),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom-Controls: Settings (links), Pause/Start, Reset (rechts)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundIcon(
                    icon: Icons.grid_view_rounded,
                    onTap: _showMenu, // Settings-Menu
                  ),
                  const SizedBox(width: 80), // Fester Abstand Menu → Play
                  _PlayPauseButton(
                    isPlaying: _timerActive && _running, // Nur "Playing" wenn Timer aktiv und läuft
                    onTap: () {
                      if (!_timerActive) {
                        // Timer noch nicht aktiviert → starten
                        setState(() => _running = true);
                        _startWordTimer();
                      } else {
                        // Timer bereits aktiviert → pausieren/fortsetzen
                        setState(() => _running = !_running);
                        if (_running) {
                          _resumeTimer();
                        } else {
                          _pauseTimer();
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 80), // Fester Abstand Play → Reset/X
                  _timerActive 
                    ? _CancelTimerButton(
                        onTap: _stopTimer,
                      )
                    : _ResetButton(
                        onResetComplete: _performReset,
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

// ===== Category Wheel (kopiert aus category_detail_screen.dart) =====

class _CategoryWheel extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final void Function(int index, String label) onChanged;

  const _CategoryWheel({
    super.key,
    required this.categories,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<_CategoryWheel> createState() => _CategoryWheelState();
}

class _CategoryWheelState extends State<_CategoryWheel> with SingleTickerProviderStateMixin {
  Timer? _notifyDebounce;
  late FixedExtentScrollController _ctrl;
  late int _current;
  bool _showArrows = false; // Startet versteckt
  bool _flashUp = false;
  bool _flashDown = false;
  DateTime _lastMove = DateTime.now();
  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    _ctrl = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CategoryWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.categories.length != oldWidget.categories.length) {
      _current = _current.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    }

    if (widget.initialIndex != oldWidget.initialIndex && !_ctrl.position.isScrollingNotifier.value) {
      final newIndex = widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
      _current = newIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.jumpToItem(_current);
      });
    }
  }

  void _onChanged(int idx) {
    if (idx == _current) return;
    // Pfeil-Flash je Richtung
    final oldCurrent = _current;
    setState(() {
      _flashUp = idx < oldCurrent;
      _flashDown = idx > oldCurrent;
      _showArrows = true;
      _current = idx;
      _lastMove = DateTime.now();
    });

    // Haptik
    HapticFeedback.lightImpact();

    // Auto-Hide Pfeile
    Future.delayed(Duration(milliseconds: kWheelArrowAutoHideMs), () {
      if (mounted && DateTime.now().difference(_lastMove).inMilliseconds >= kWheelArrowAutoHideMs) {
        setState(() => _showArrows = false);
      }
    });

    widget.onChanged(idx, widget.categories[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    if (cats.isEmpty) {
      return Container(
        width: kWheelWidth,
        height: kWheelHeight,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: kWheelWidth,
      height: kWheelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Das Wheel
          _EdgeFade(
            fadeHeight: kWheelEdgeFadeHeight,
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: kWheelItemExtent,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onChanged,
              diameterRatio: 2.2,
              perspective: 0.002,
              overAndUnderCenterOpacity: 1,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: cats.length,
                builder: (context, index) {
                  final dist = (index - _current).abs();

                  final opacity = dist == 0
                      ? kWheelActiveOpacity
                      : (dist == 1 ? kWheelNeighborOpacity : kWheelFarOpacity);

                  final scale = dist == 0
                      ? kWheelActiveScale
                      : (dist == 1 ? kWheelNeighborScale : kWheelFarScale);

                  return Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: _AdaptivePill(
                          text: cats[index],
                          width: kWheelPillWidth,
                          height: kWheelItemExtent - 6,
                          radius: kWheelPillRadius,
                          active: dist == 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Rechte Pfeilspalte (Up/Down)
          Positioned.fill(
            right: -kWheelArrowRightOut,
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showArrows ? 1.0 : 0.0,
                  child: Padding(
                    padding: EdgeInsets.only(right: kWheelArrowNudge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ArrowIcon(
                          up: true,
                          flash: _flashUp,
                          onTap: () => _ctrl.animateToItem(
                            (_current - 1).clamp(0, widget.categories.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ArrowIcon(
                          up: false,
                          flash: _flashDown,
                          onTap: () => _ctrl.animateToItem(
                            (_current + 1).clamp(0, widget.categories.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
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

class _AdaptivePill extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final bool active;
  const _AdaptivePill({
    required this.text,
    required this.width,
    required this.height,
    required this.radius,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white24),
        boxShadow: active && kWheelGlowBlur > 0
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(kWheelGlowOpacity),
                  blurRadius: kWheelGlowBlur,
                  spreadRadius: 0,
                ),
              ]
            : const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  final double fadeHeight;
  final Widget child;
  const _EdgeFade({required this.fadeHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Top Fade
        Positioned(
          left: 0, right: 0, top: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Bottom Fade
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatefulWidget {
  final bool up;
  final bool flash;
  final VoidCallback onTap;
  const _ArrowIcon({required this.up, required this.flash, required this.onTap});

  @override
  State<_ArrowIcon> createState() => _ArrowIconState();
}

class _ArrowIconState extends State<_ArrowIcon> with SingleTickerProviderStateMixin {
  final double _opacity = 0.7;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: _opacity,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.up ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ===== Original Widgets =====

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _RoundIcon({required this.icon, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}

// Cancel Timer Button (X) - Rund wie andere Buttons
class _CancelTimerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelTimerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44, 
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.red,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Play/Pause Button - Rund und größer als Reset/Menu
class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 64, 
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138, height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2D2D2F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
// ===== Vertical Stage Switch (kopiert aus category_detail_screen.dart) =====

class _VerticalStageSwitch extends StatelessWidget {
  final int count;
  final Color outerColor;
  final Color innerColor;
  final bool highlight;
  final bool completed;
  final String label; // "S1" / "New"
  final String note;  // "0".."5"
  final bool isFirst;

  const _VerticalStageSwitch({
    required this.count,
    required this.outerColor,
    required this.innerColor,
    required this.highlight,
    required this.completed,
    required this.label,
    required this.note,
    this.isFirst = false,
  });

  double _getSwitchPosition() {
    // Bei 0 unten, bei >0 oben
    return count > 0 ? 2.0 : 18.0;
  }

  @override
  Widget build(BuildContext context) {
    final badgeGlow = highlight
        ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
        : const <BoxShadow>[];

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 6 : 0, right: isFirst ? 4 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Switch
          Container(
            width: 42,
            height: 75,
            decoration: BoxDecoration(
              color: outerColor,
              borderRadius: BorderRadius.circular(21),
              boxShadow: badgeGlow,
              border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 2,
                  right: 2,
                  top: _getSwitchPosition(),
                  child: Container(
                    width: 38,
                    height: 52,
                    decoration: BoxDecoration(
                      color: innerColor,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Zahlen unter den Switches
          SizedBox(
            width: 42,
            child: Text(
              note,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Reset Button mit Hold-to-Confirm =====

class _ResetButton extends StatefulWidget {
  final Future<void> Function() onResetComplete;
  
  const _ResetButton({required this.onResetComplete});
  
  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  int _countdown = 3;
  OverlayEntry? _overlayEntry;
  
  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPressed = true;
      _countdown = 3;
    });
    
    HapticFeedback.mediumImpact();
    print('🔄 Reset hold started');
    
    _showOverlay();
    _startCountdown();
  }
  
  void _onLongPressEnd(LongPressEndDetails details) {
    _cancel();
  }
  
  void _onLongPressCancel() {
    _cancel();
  }
  
  void _cancel() {
    print('❌ Reset canceled (finger released)');
    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
    _removeOverlay();
    HapticFeedback.lightImpact();
  }
  
  void _showOverlay() {
    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: StatefulBuilder(
            builder: (context, setOverlayState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lernfortschritt?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Color(0xFFA05260),
                      fontSize: 80,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Finger gedrückt halten...',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    
    overlay.insert(_overlayEntry!);
  }
  
  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!_isPressed) {
        _removeOverlay();
        return;
      }
      
      setState(() => _countdown = i);
      _updateOverlay();
      
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    if (!_isPressed) {
      _removeOverlay();
      return;
    }
    
    // Countdown abgeschlossen - Reset durchführen
    print('✅ Reset countdown complete - performing reset');
    _removeOverlay();
    
    HapticFeedback.heavyImpact();
    
    await widget.onResetComplete();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lernfortschritt wurde zurückgesetzt'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFA05260),
        ),
      );
    }
    
    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
  }
  
  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFA05260) : const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Icon(
            Icons.refresh_rounded,
            color: _isPressed ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _MenuRow extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((it) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () { Navigator.of(context).pop(); it.onTap(); },
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(it.icon, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(it.label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
