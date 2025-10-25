import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'dart:async';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/events/events.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/ui/widgets/category_header_capsule.dart';
import 'package:talvori/features/words/ui/widgets/learning_status_panel.dart';
import 'package:talvori/features/words/ui/widgets/levels_card.dart';

// ===== Globale Hilfsfunktion für Daily Stats =====
/// Lädt tägliche Lernstatistiken für eine Kategorie
/// Returns: (newCount, repeatCount) für den heutigen Tag
Future<(int, int)> loadDailyLearningStats(String categoryId) async {
  final prefs = await SharedPreferences.getInstance();
  final newToday = prefs.getInt('today_new_$categoryId') ?? 0;
  final repsToday = prefs.getInt('today_repeats_$categoryId') ?? 0;
  return (newToday, repsToday);
}

Timer? _switchDebounce;


const kAccentBlue = Color(0xFFB1CCFE);


/// ==============================
/// LAYOUT-KNOBS – ALLES EINSTELLBAR
/// ==============================

/// --- Globale Größen ---
const double kTopCapsuleH        = 240.0;  // Höhe obere Kachel (grafische Größe)
const double kBottomBlockReserve = 270.0;  // reservierte Höhe für den unteren Block im Layout
const double kLevelsCardH        = 260.0;  // tatsächliche sichtbare Höhe der Level-Kachel im unteren Block

/// --- Block-Offsets (verschieben ganze Blöcke) ---
const double kTopBlockOffsetX    = 0.0;    // verschiebt die gesamte Top-Kachel horizontal
const double kTopBlockOffsetY    = 0.0;    // verschiebt die gesamte Top-Kachel vertikal

const double kMidBlockOffsetX    = 0.0;    // verschiebt den kompletten Mittel-Block (Progress+Counter) X
const double kMidBlockOffsetY    = 34.0;  // verschiebt den kompletten Mittel-Block (Progress+Counter) Y (weiter nach unten)

const double kBottomBlockOffsetX = 0.0;    // verschiebt den ganzen unteren Block (Levels-Kachel) X
const double kBottomBlockOffsetY = -20.0;    // verschiebt den ganzen unteren Block (Levels-Kachel) Y

/// --- Abstände zwischen Blöcken ---
const double kGapBelowTop        = 16.0;   // Abstand unter Top-Kachel bis zum Mittel-Block
const double kGapAboveBottom     = 40.0;   // Abstand zwischen Mittel-Block und Unter-Block (reduziert für Overall-Bar)
const double kPageBottomPadding  = 24.0;   // Abstand ganz unten

/// --- INHALTE: Top-Kachel-Innenleben ---
const double kTopTitleOffsetX    = 0.0;    // verschiebt den Titel (Stack) X
const double kTopTitleOffsetY    = 0.0;    // verschiebt den Titel (Stack) Y
const double kTopBackBtnOffsetX  = 0.0;    // verschiebt den Back-Button X
const double kTopBackBtnOffsetY  = 0.0;    // verschiebt den Back-Button Y
const double kTopRowOffsetX      = 0.0;    // verschiebt die Zeile (Vocabs + Buttons) X
const double kTopRowOffsetY      = 50.0;    // verschiebt die Zeile (Vocabs + Buttons) Y
const double kTopVocabsTileOffsetX = 20.0;  // verschiebt nur die Vocabs-Kachel X
const double kTopVocabsTileOffsetY = 0.0;  // verschiebt nur die Vocabs-Kachel Y
const double kTopRightBtnsOffsetX  = -10.0;  // verschiebt den rechten Button-Cluster X
const double kTopRightBtnsOffsetY  = 0.0;  // verschiebt den rechten Button-Cluster Y

/// --- INHALTE: Mittel-Block (Progress + Counter) ---
const double kMidPaddingH        = 25.0;   // horizontaler Innenabstand im Mittel-Block
const double kMidRingOffsetX     = 0.0;    // verschiebt den Progress-Ring X
const double kMidRingOffsetY     = 10.0;    // verschiebt den Progress-Ring Y
const double kMidCountersOffsetX = 0.0;    // verschiebt den rechten Counter-Block X
const double kMidCountersOffsetY = 40.0;    // verschiebt den rechten Counter-Block Y
const double kMidInnerGap        = 0.0;   // Abstand zwischen Ring und Countern
const double kOverallBarGap      = 24.0;   // Abstand zwischen Ring/Counter und Overall-Bar
const double kOverallBarHeight   = 8.0;    // Höhe des Overall-Progress-Balkens

/// --- INHALTE: Unterer Block (Levels-Kachel) ---
const double kLevelsOuterPadL    = 20.0;   // Innenabstand links der Levels-Kachel
const double kLevelsOuterPadT    = 8.0;    // Innenabstand oben der Levels-Kachel
const double kLevelsOuterPadR    = 20.0;   // Innenabstand rechts
const double kLevelsOuterPadB    = 0.0;    // Innenabstand unten

const double kLevelsTitleOffsetX = 0.0;    // verschiebt die Überschrift "Levels" X
const double kLevelsTitleOffsetY = 0.0;    // verschiebt die Überschrift "Levels" Y

const double kSwitchesOffsetX    = 0.0;    // verschiebt die gesamte Switch-Reihe X
const double kSwitchesOffsetY    = -12.0;  // verschiebt die gesamte Switch-Reihe Y
const double kSwitchGap          = 12.0;    // Abstand zwischen einzelnen Switches

const double kStartBtnOffsetX    = 0.0;    // verschiebt den Start-Button X
const double kStartBtnOffsetY    = 0.0;    // verschiebt den Start-Button Y

// ===== Category Wheel Knobs (alles einstellbar) =====
const double kWheelWidth            = 280.0; // Gesamtbreite des Wheels
const double kWheelHeight           = 72.0; // Gesamthöhe (sichtbares Fenster)
const double kWheelItemExtent       = 34.0;  // Höhe je Pill-Item (Snapping-Schritt)
const double kWheelPillWidth        = 240.0; // Breite einer Pill (Text passt sich an)
const double kWheelPillRadius       = 14.0;  // Pill-Radius

const double kWheelActiveOpacity    = 1.0;   // aktive Pill
const double kWheelNeighborOpacity  = 0.55;  // direkte Nachbarn
const double kWheelFarOpacity       = 0.30;  // der Rest

const double kWheelActiveScale      = 1.00;  // aktive Pill
const double kWheelNeighborScale    = 0.94;  // direkte Nachbarn
const double kWheelFarScale         = 0.88;  // der Rest

const double kWheelGlowBlur         = 18.0;  // Glow der aktiven Pill (0 = aus)
const double kWheelGlowOpacity      = 0.35;  // Intensität des Glows

const double kWheelEdgeFadeHeight   = 24.0;  // weiche Kanten oben/unten

// --- Arrow-Position: außerhalb nach rechts rausziehen ---
const double kWheelArrowRightOut = 22.0;   // >0 = weiter rechts außerhalb
const int    kWheelArrowAutoHideMs  = 800;   // Pfeile nach Inaktivität verstecken (schneller)
const double kWheelArrowNudge       = 0.0;   // Pfeile minimal nach innen/außen versetzen

// Position im Header
const double kWheelOffsetX          = 0.0;   // Wheel im Header horizontal verschieben
const double kWheelOffsetY          = 0.0;   // Wheel im Header vertikal verschieben


/// ==============================
/// SCREEN
/// ==============================
class CategoryDetailScreen extends StatefulWidget {
  final String title;              // z.B. "Health & Fitness"
  final String? categoryId;        // Supabase UUID (word_categories.id); kann null sein
  final String? categorySlug;    // fallback:
  final WordListFilter listFilter; // Fallback/Anzeige-Liste

  const CategoryDetailScreen({
    super.key,
    required this.title,
    required this.listFilter,
    this.categoryId,
    this.categorySlug,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> with WidgetsBindingObserver {
  CategoryProgress? _progress;
  WorkloadToday? _workload;

  int _weeklyNew = 0;
  int _weeklyRepeats = 0;
  final int _weeklyTarget = 100;
  
  // Tägliche Lernstatistiken (tatsächlich gelernte Wörter heute)
  int _dailyNewLearned = 0;
  int _dailyRepeatsLearned = 0;

  bool _loading = true;
  
  int _vocabsTotal = 0; // echte Gesamtzahl der Wörter in der Kategorie
  
  // Reset-Event Listener
  StreamSubscription<String>? _resetSubscription;
  StreamSubscription<StageTransitionEvent>? _stageSub;

  /// Helper-Funktion: Setzt lokale Stage-Daten auf 0 nach einem Reset
  Future<void> _applyLocalReset(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learn_stages_$categoryId', '0,0,0,0,0,0'); // nur Stages
    await prefs.setInt('today_new_$categoryId', 0);                   // Daily
    await prefs.setInt('today_repeats_$categoryId', 0);               // Daily
    
    // NEU: Marker setzen, damit der nächste Reload ausschließlich lokale Stände nutzt
    await prefs.setBool('just_reset_$categoryId', true);
    
    await _loadVocabsTotal(categoryId); // Badge bleibt echte Gesamtanzahl der Kategorie
    
    print('✅ Applied local reset for category: $categoryId');
  }

  // Kategorien aus DB + aktuelle Auswahl (für das Wheel im Header)
  List<CategoryInfo> _categories = const [];
  int _selectedCategoryIndex = 0;

  // State-Helfer für zentralisierte Kategorie-Verwaltung
  String get _currentCatId =>
      (_categories.isNotEmpty) ? _categories[_selectedCategoryIndex].id : '';

  void _switchTo(int idx) {
    if (idx < 0 || idx >= _categories.length) return;

    // UI sofort umschalten (Titel / Wheel-Markierung)
    setState(() => _selectedCategoryIndex = idx);

    // RPC-Ladung entprellen
    _switchDebounce?.cancel();
    _switchDebounce = Timer(const Duration(milliseconds: 180), () async {
      final selId = _categories[idx].id;
      try {
        final prog = await fetchCategoryProgress(selId);
        final wl   = await fetchWorkloadToday(selId);
        if (!mounted) return;
        setState(() {
          _progress       = prog;
          _workload       = wl;
          // Korrekte Berechnung: newTotal = Stage 0 (neue Wörter)
          _weeklyNew      = prog.stages[0]; // Stage 0 = neue Wörter
          _weeklyRepeats  = _workload?.dueToday ?? 0;
        });
        
        await _loadVocabsTotal(selId);
      } catch (_) {
        // optional: SnackBar / Log
      }
    });
  }

  /// Lädt Progress-Daten für die aktuelle Kategorie neu
  /// (wird aufgerufen, wenn von LearnModeScreen zurückgekommen wird)
  Future<void> _reloadProgress() async {
    if (_categories.isEmpty) return;
    
    final selId = _currentCatId;
    if (selId.isEmpty) return;
    
    await _ensureTodayBucket(_currentCatId.isNotEmpty ? _currentCatId : (widget.categoryId ?? ''));
    
    try {
      print('🔄 Reloading progress for category: $selId');
      
      // WICHTIG: Lade ZUERST lokale Daten (weil Backend kaputt ist: fn_user_review bug)
      final prefs = await SharedPreferences.getInstance();
      final stageKey = 'learn_stages_$selId';
      final storedStages = prefs.getString(stageKey);
      
      List<int>? localStages;
      if (storedStages != null) {
        try {
          final parsed = storedStages.split(',').map(int.parse).toList();
          if (parsed.length == 6) {
            localStages = parsed;
            print('📦 Found local stages: $localStages');
          }
        } catch (e) {
          print('⚠️ Failed to parse local stages: $e');
        }
      }
      
      // NEU: Marker prüfen & Backend-Fetch überspringen (1x)
      final justReset = prefs.getBool('just_reset_$selId') ?? false;
      final justSeeded = prefs.getBool('just_seeded_$selId') ?? false;

      if (justSeeded) {
        // Backendwerte verwenden (kein lokales Override), Flag danach löschen
        final prog  = await fetchCategoryProgress(selId);
        final wl    = await fetchWorkloadToday(selId);
        await prefs.remove('just_seeded_$selId');

        _progress = CategoryProgress(
          total: prog.total,
          stages: prog.stages,     // <- HIER: DB-Stages (S0 jetzt > 0)
          dueToday: prog.dueToday,
          newTotal: prog.newTotal,
        );
        _workload = wl;

        final used = _progress!.stages;
        _weeklyNew     = used[0];
        _weeklyRepeats = _workload?.dueToday ?? 0;

        // Tageswerte NICHT nullen – aus prefs laden:
        final (dailyNew, dailyRepeats) = await loadDailyLearningStats(selId);
        _dailyNewLearned = dailyNew;
        _dailyRepeatsLearned = dailyRepeats;

        await _loadVocabsTotal(selId);  // stellt sicher, dass die Kachel nie 0 zeigt

        if (mounted) setState(() {});
        return; // Wichtig: normale lokale-Override-Logik überspringen
      }

      if (justReset && localStages != null) {
        _progress = CategoryProgress(
          total: 0,
          stages: localStages,
          dueToday: 0,
          newTotal: 0,
        );
        _workload = WorkloadToday(dueToday: 0, newTotal: 0);
        _weeklyNew = 0;
        _weeklyRepeats = 0;
        _dailyNewLearned = 0;
        _dailyRepeatsLearned = 0;

        await _loadVocabsTotal(selId);  // stellt sicher, dass die Kachel nie 0 zeigt

        await prefs.remove('just_reset_$selId');
        if (mounted) setState(() {});
        return;
      }
      
      // Lade vom Backend (für total und workload)
      final prog = await fetchCategoryProgress(selId);
      final wl   = await fetchWorkloadToday(selId);
      
      // Lade tägliche Lernstatistiken
      final (dailyNew, dailyRepeats) = await loadDailyLearningStats(selId);
      
      if (!mounted) return;
      
      setState(() {
        // Bevorzuge lokale Stages (weil Backend nicht aktualisiert wird)
        final stages = localStages ?? prog.stages;
        _progress = CategoryProgress(
          total: prog.total,
          stages: stages,
          dueToday: prog.dueToday,
          newTotal: prog.newTotal,
        );
        _workload       = wl;
        // Korrekte Berechnung: newTotal = Stage 0 (neue Wörter) - IMMER aus lokalen Stages
        _weeklyNew      = stages[0]; // RICHTIG (stages = localStages ?? prog.stages)
        _weeklyRepeats  = _workload?.dueToday ?? 0;
        
        // Korrekte tägliche Statistiken: Verwende lokale Stages (nach Reset sofort 0)
        _dailyNewLearned = dailyNew;
        _dailyRepeatsLearned = dailyRepeats;
      });
      
      print('✅ Progress reloaded: stages=$localStages (local) vs ${prog.stages} (backend), total=${prog.total}');
      print('📈 Daily stats: new=$dailyNew, repeats=$dailyRepeats');
      
      await _loadVocabsTotal(selId);
    } catch (e) {
      print('❌ Failed to reload progress: $e');
      // Fallback: behalte alte Daten
    }
  }

  Future<void> _loadVocabsTotal(String catId) async {
    final sb = Supabase.instance.client;
    final res = await sb.rpc('fn_category_word_count', params: {'p_category_id': catId});
    if (!mounted) return;
    setState(() => _vocabsTotal = (res as int?) ?? 0);
  }

  Future<void> _ensureTodayBucket(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final keyDate = 'today_date_$categoryId';
    final today = DateTime.now().toIso8601String().substring(0,10);
    final last = prefs.getString(keyDate);
    if (last != today) {
      prefs
        ..setString(keyDate, today)
        ..setInt('today_new_$categoryId', 0)
        ..setInt('today_repeats_$categoryId', 0);
    }
  }


  int _findInitialIndex(List<CategoryInfo> cats) {
    // 1) id
    if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
      final i = cats.indexWhere((c) => c.id == widget.categoryId);
      if (i >= 0) return i;
    }
    // 2) slug (falls mitgegeben)
    if (widget.categorySlug != null && widget.categorySlug!.isNotEmpty) {
      final i = cats.indexWhere((c) => c.slug == widget.categorySlug);
      if (i >= 0) return i;
    }
    // 3) name (fallback, case-insensitive)
    final name = widget.title.trim().toLowerCase();
    var i = cats.indexWhere((c) => c.name.trim().toLowerCase() == name);
    if (i >= 0) return i;

    // 4) heuristik: slugify vom Titel
    final tslug = _slugify(widget.title);
    i = cats.indexWhere((c) => c.slug == tslug);
    if (i >= 0) return i;

    return 0;
  }

  String _slugify(String s) {
    return s
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Lausche auf Reset-Events
    _resetSubscription = ResetEvent.stream.listen((categoryId) async {
      if (categoryId == _currentCatId) {
        await _applyLocalReset(categoryId);
        if (mounted) await _initAll();
      }
    });

    // Lausche auf Stage-Transition-Events
    _stageSub = StageTransitionEvent.stream.listen((e) async {
      print('📥 RECV StageEvent cat=${e.categoryId} cur=$_currentCatId word=${e.wordId} from=${e.fromStage} to=${e.toStage} due=${e.wasDueBefore}');
      if (e.categoryId != _currentCatId) return;
      await _ensureTodayBucket(e.categoryId);

      final prefs = await SharedPreferences.getInstance();
      var todayNew = prefs.getInt('today_new_${e.categoryId}') ?? 0;
      var todayRep = prefs.getInt('today_repeats_${e.categoryId}') ?? 0;

      // NEW: +1 bei S0->S1+, -1 bei S1+->S0 (aber nie < 0)
      if (e.fromStage == 0 && e.toStage >= 1) {
        todayNew += 1;
      } else if (e.fromStage >= 1 && e.toStage == 0) {
        todayNew = (todayNew - 1).clamp(0, 1<<30);
      }

      // 👇 WICHTIG: Repeats steigen, wenn die Karte VOR dem Schritt fällig war
      if (e.wasDueBefore == true) {
        todayRep += 1;
      }

      await prefs.setInt('today_new_${e.categoryId}', todayNew);
      await prefs.setInt('today_repeats_${e.categoryId}', todayRep);

      // UI sofort aktualisieren
      if (!mounted) return;
      print('📊 Today before->after new=$todayNew repeats=$todayRep');
      setState(() {
        _dailyNewLearned = todayNew;
        _dailyRepeatsLearned = todayRep;
      });
    });
    
  _initAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Lade Daten neu, wenn die App wieder aktiv wird (z.B. nach Reset im Lernmodus)
    if (state == AppLifecycleState.resumed) {
      _initAll();
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetSubscription?.cancel();
    _stageSub?.cancel();
    _switchDebounce?.cancel();
    _switchDebounce = null;
    super.dispose();
  }

Future<void> _initAll() async {
  setState(() => _loading = true);
  try {
    final cats = await fetchAllCategories();

    _categories = cats;
    _selectedCategoryIndex = cats.isEmpty ? 0 : _findInitialIndex(cats);

    if (_categories.isNotEmpty) {
      final selId = _categories[_selectedCategoryIndex].id;
      
      await _ensureTodayBucket(_currentCatId.isNotEmpty ? _currentCatId : (widget.categoryId ?? ''));
      
      // Lade lokale Stages (falls vorhanden)
      final prefs = await SharedPreferences.getInstance();
      final stageKey = 'learn_stages_$selId';
      final storedStages = prefs.getString(stageKey);
      
      List<int>? localStages;
      if (storedStages != null) {
        try {
          final parsed = storedStages.split(',').map(int.parse).toList();
          if (parsed.length == 6) {
            localStages = parsed;
            print('📦 Initial load - found local stages: $localStages');
          }
        } catch (e) {
          print('⚠️ Failed to parse local stages: $e');
        }
      }
      
      // NEU: Marker prüfen & Backend-Fetch überspringen (1x)
      final justReset = prefs.getBool('just_reset_$selId') ?? false;
      final justSeeded = prefs.getBool('just_seeded_$selId') ?? false;

      if (justSeeded) {
        // Backendwerte verwenden (kein lokales Override), Flag danach löschen
        final prog  = await fetchCategoryProgress(selId);
        final wl    = await fetchWorkloadToday(selId);
        await prefs.remove('just_seeded_$selId');

        _progress = CategoryProgress(
          total: prog.total,
          stages: prog.stages,     // <- HIER: DB-Stages (S0 jetzt > 0)
          dueToday: prog.dueToday,
          newTotal: prog.newTotal,
        );
        _workload = wl;

        final used = _progress!.stages;
        _weeklyNew     = used[0];
        _weeklyRepeats = _workload?.dueToday ?? 0;

        // Tageswerte NICHT nullen – aus prefs laden:
        final (dailyNew, dailyRepeats) = await loadDailyLearningStats(selId);
        _dailyNewLearned = dailyNew;
        _dailyRepeatsLearned = dailyRepeats;

        await _loadVocabsTotal(selId);  // stellt sicher, dass die Kachel nie 0 zeigt

        if (mounted) setState(() {});
        return; // Wichtig: normale lokale-Override-Logik überspringen
      }

      if (justReset && localStages != null) {
        // Lokale 0-Stände einmalig als Quelle der Wahrheit setzen
        _progress = CategoryProgress(
          total: 0,                // falls du total brauchst: 0 oder prog.total bei dir?
          stages: localStages,     // <- bleibt 0,0,0,0,0,0
          dueToday: 0,
          newTotal: 0,
        );
        _workload = WorkloadToday(dueToday: 0, newTotal: 0);

        _weeklyNew = 0;
        _weeklyRepeats = 0;
        _dailyNewLearned = 0;
        _dailyRepeatsLearned = 0;

        // Marker entfernen, damit beim nächsten regulären Load wieder Backend genutzt werden kann
        await prefs.remove('just_reset_$selId');

        if (mounted) setState(() {}); // UI sofort auf 0
        return; // WICHTIG: Diesen Durchlauf kein Backend laden -> verhindert Zurückspringen
      }
      
      // Lade vom Backend
      final prog  = await fetchCategoryProgress(selId);
      final wl    = await fetchWorkloadToday(selId);
      
      // Lade tägliche Lernstatistiken
      final (dailyNew, dailyRepeats) = await loadDailyLearningStats(selId);
      
      // Bevorzuge lokale Stages
      _progress = CategoryProgress(
        total: prog.total,
        stages: localStages ?? prog.stages,
        dueToday: prog.dueToday,
        newTotal: prog.newTotal,
      );
      _workload   = wl;
      
      // Nachdem _progress gesetzt wurde: IMMER aus lokalen Stages ableiten
      final usedStages = _progress!.stages;
      _weeklyNew      = usedStages[0];  // RICHTIG
      _weeklyRepeats  = _workload?.dueToday ?? 0;
      
      _dailyNewLearned = dailyNew;
      _dailyRepeatsLearned = dailyRepeats;
      
      print('📊 Initial load - using stages: ${_progress?.stages} (local: $localStages, backend: ${prog.stages})');
      print('📈 Daily stats: new=$dailyNew, repeats=$dailyRepeats');
      
      await _loadVocabsTotal(selId);
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final stages  = _progress?.stages ?? const [0, 0, 0, 0, 0, 0];

    // Tägliches Ziel und Prozent basierend auf tatsächlich gelernten Wörtern
    final dailyTotal = _dailyNewLearned + _dailyRepeatsLearned;
    final dailyTarget = 20; // Ziel: 20 Wörter pro Tag
    final dailyPercent = dailyTarget == 0 ? 0.0 : (dailyTotal / dailyTarget).clamp(0.0, 1.0);
    
    // Progress Circle: Zeige Gesamtfortschritt (gelernte Wörter / Gesamtwörter)
    final int totalWords = _progress?.total ?? stages.fold<int>(0, (sum, v) => sum + v);
    final int learnedWords = stages.skip(1).fold<int>(0, (sum, v) => sum + v); // Stage 1-5
    final double weeklyPercent = totalWords == 0 ? 0.0 : (learnedWords / totalWords).clamp(0.0, 1.0);
    
    // Gesamtfortschritt: Wie viele Wörter wurden bereits gelernt (Stage 1+)?
    final double overallPercent = weeklyPercent; // Verwende die gleiche Berechnung
    final String overallLabel = '$learnedWords/$totalWords';

    // Werte vorbereiten
    final int s0New = stages[0];                 // neue Wörter (Stage 0)
    final int repeatsDue = _workload?.dueToday ?? 0; // echte Wiederholungen heute

    // Höhe unterhalb der Top-Kachel (inkl. SafeAreas)
    final insets    = MediaQuery.of(context).padding;
    final viewportH = MediaQuery.of(context).size.height - insets.top - insets.bottom;
    final restH     = viewportH - kTopCapsuleH;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeArea(
        top: true,
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, kPageBottomPadding),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- TOP-KACHEL (als Block verschiebbar) ----------
                    Transform.translate(
                      offset: Offset(kTopBlockOffsetX, kTopBlockOffsetY),
                      child: CategoryHeaderCapsule(
                        height: kTopCapsuleH,
                        title: _categories.isNotEmpty
                            ? _categories[_selectedCategoryIndex].name
                            : widget.title,
                        vocabsCount: _vocabsTotal, // bleibt deine echte Kategorie-Gesamtzahl
                        categories: _categories.map((e) => e.name).toList(),
                        selectedIndex: _selectedCategoryIndex,
                        onWheelChanged: (idx, label) => _switchTo(idx),
                      onBack: () => Navigator.of(context).pop(),
                      onVocabs: () {
                        final currentId   = _currentCatId;
                        final currentName = (_categories.isNotEmpty)
                            ? _categories[_selectedCategoryIndex].name
                            : widget.title;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WordListScreen(
                              filter: widget.listFilter,
                              overrideCategoryId: currentId,
                              overrideCategoryLabel: currentName,
                            ),
                          ),
                        );
                      },
                        onAdd: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add tapped')),
                          );
                        },
                        onSettings: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings tapped')),
                          );
                        },

                        // Optional: Offsets wie gehabt
                        wheelOffsetX: kWheelOffsetX,
                        wheelOffsetY: kWheelOffsetY,
                        rowOffsetX: kTopRowOffsetX,
                        rowOffsetY: kTopRowOffsetY,
                        vocabsTileOffsetX: kTopVocabsTileOffsetX,
                        vocabsTileOffsetY: kTopVocabsTileOffsetY,
                        rightBtnsOffsetX: kTopRightBtnsOffsetX,
                        rightBtnsOffsetY: kTopRightBtnsOffsetY,
                        accentColor: kAccentBlue,
                      ),
                    ),

                    SizedBox(height: kGapBelowTop),

                    // ---------- MITTEL-Block (Progress + Counter) ----------
                    SizedBox(
                      height: restH,
                      child: Column(
                        children: [
                          Expanded(
                            child: Transform.translate(
                              offset: Offset(kMidBlockOffsetX, kMidBlockOffsetY),
                              child: LearningStatusPanel(
                                percent: dailyPercent,
                                percentLabel: '${(dailyPercent * 100).round()}%',
                                newCount: _dailyNewLearned,
                                repeatsCount: _dailyRepeatsLearned,
                                repeatsOfTargetLabel: '${_dailyNewLearned + _dailyRepeatsLearned}/$dailyTarget',
                                overallPercent: overallPercent,
                                overallLabel: overallLabel,
                              ),
                            ),
                          ),

                          // ---------- UNTERER Block (Levels-Kachel) ----------
                          SizedBox(height: kGapAboveBottom),
                          Transform.translate(
                            offset: Offset(kBottomBlockOffsetX, kBottomBlockOffsetY),
                            child: SizedBox(
                              height: kBottomBlockReserve,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                            child: LevelsCard(
                              height: kLevelsCardH,
                              stages: stages,
                              goalPerStage: 100,
                              onStartPressed: () async {
                                final currentId = _currentCatId;
                                final currentName = _categories.isNotEmpty
                                    ? _categories[_selectedCategoryIndex].name
                                    : widget.title;
                                if (currentId.isEmpty) return;

                                final sb = Supabase.instance.client;
                                await sb.rpc('fn_seed_user_category', params: {'p_category_id': currentId});
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('learn_stages_$currentId');
                                await prefs.remove('just_reset_$currentId');
                                await prefs.setBool('just_seeded_$currentId', true);

                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LearnModeScreen(categoryId: currentId, title: currentName),
                                  ),
                                );
                                await _reloadProgress();
                              },
                            ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),

        ],
      ),
    );
  }
}

/* ======================= UI-Bausteine ======================= */












// Ring mit CustomPainter (runde Kappen)


