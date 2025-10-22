import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'dart:async';
import 'package:talvori/features/words/ui/screens/learn_mode_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Timer? _switchDebounce;

const _kCard = Color(0xFF2D2C2C);
const _kWhiteGlow = Colors.white;

const _kStageOuter = Color(0xFFE4B866);
const _kStageInner = Color(0xFF2D2C2C);
const _kStageInnerRed = Color(0xFFA05260);
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

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  CategoryProgress? _progress;
  WorkloadToday? _workload;

  int _weeklyNew = 0;
  int _weeklyRepeats = 0;
  final int _weeklyTarget = 100;
  
  // Tägliche Lernstatistiken (tatsächlich gelernte Wörter heute)
  int _dailyNewLearned = 0;
  int _dailyRepeatsLearned = 0;

  bool _loading = true;

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
          _weeklyNew      = _workload?.newTotal ?? 0;
          _weeklyRepeats  = _workload?.dueToday ?? 0;
        });
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
        _weeklyNew      = _workload?.newTotal ?? 0;
        _weeklyRepeats  = _workload?.dueToday ?? 0;
        
        _dailyNewLearned = dailyNew;
        _dailyRepeatsLearned = dailyRepeats;
      });
      
      print('✅ Progress reloaded: stages=$localStages (local) vs ${prog.stages} (backend), total=${prog.total}');
      print('📈 Daily stats: new=$dailyNew, repeats=$dailyRepeats');
    } catch (e) {
      print('❌ Failed to reload progress: $e');
      // Fallback: behalte alte Daten
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
  _initAll();
  }

  @override
  void dispose() {
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
      _weeklyNew      = _workload?.newTotal ?? 0;
      _weeklyRepeats  = _workload?.dueToday ?? 0;
      
      _dailyNewLearned = dailyNew;
      _dailyRepeatsLearned = dailyRepeats;
      
      print('📊 Initial load - using stages: ${_progress?.stages} (local: $localStages, backend: ${prog.stages})');
      print('📈 Daily stats: new=$dailyNew, repeats=$dailyRepeats');
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
    
    final weeklyTotal   = (_weeklyNew + _weeklyRepeats).clamp(0, _weeklyTarget);
    final weeklyPercent = _weeklyTarget == 0 ? 0.0 : weeklyTotal / _weeklyTarget;

    final int totalVocabsInCat = stages.fold<int>(0, (sum, v) => sum + v);
    
    // Gesamtfortschritt: Wie viele Wörter wurden bereits gelernt (Stage 1+)?
    final int learnedWords = stages.skip(1).fold<int>(0, (sum, v) => sum + v); // Stage 1-5
    final int totalWords = totalVocabsInCat;
    final double overallPercent = totalWords == 0 ? 0.0 : (learnedWords / totalWords).clamp(0.0, 1.0);
    final String overallLabel = '$learnedWords/$totalWords';

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
                      child: _TopCapsule(
                        title: _categories.isNotEmpty
                            ? _categories[_selectedCategoryIndex].name
                            : widget.title,
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
                        vocabsCount: totalVocabsInCat,
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
                              child: _MidProgress(
                                percent: dailyPercent,
                      percentLabel: '${(dailyPercent * 100).round()}%',
                      newCount: _dailyNewLearned,
                      repeatsCount: _dailyRepeatsLearned,
                      repeatsOfTargetLabel: '$dailyTotal/$dailyTarget',
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
                            child: _PipelineLevelsCard(
                                  height: kLevelsCardH,
                                  stages: stages,
                                  goalPerStage: 100,
                                  onStartPressed: () async {
                                    final currentId = _currentCatId;
                                    final currentName = _categories.isNotEmpty
                                        ? _categories[_selectedCategoryIndex].name
                                        : widget.title;
                                    
                                    // Navigiere zum Learn Mode
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LearnModeScreen(
                                          categoryId: currentId,
                                          title: currentName,
                                        ),
                                      ),
                                    );
                                    
                                    // Lade Daten neu nach Rückkehr
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

// ---------- Top-Kachel ----------
class _TopCapsule extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onVocabs;
  final VoidCallback onAdd;
  final VoidCallback onSettings;

  // NEU:
  final int vocabsCount;

  const _TopCapsule({
    required this.title,
    required this.onBack,
    required this.onVocabs,
    required this.onAdd,
    required this.onSettings,
    required this.vocabsCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: kTopCapsuleH,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Back + Wheel
            SizedBox(
              height: kWheelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onBack,
                    child: const SizedBox(
                      width: 44, height: 44,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(kWheelOffsetX, kWheelOffsetY),
                      child: Center(child: _CategoryWheel(
                        key: null,
                        categories: (context.findAncestorStateOfType<_CategoryDetailScreenState>()?._categories
                                      .map((e) => e.name).toList()) ?? const <String>[],
                        initialIndex: context.findAncestorStateOfType<_CategoryDetailScreenState>()?._selectedCategoryIndex ?? 0,
                        onChanged: (idx, label) {
                          context.findAncestorStateOfType<_CategoryDetailScreenState>()?._switchTo(idx);
                        },
                      )),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Vocabs-Kachel + Buttons
            Transform.translate(
              offset: Offset(kTopRowOffsetX, kTopRowOffsetY),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(kTopVocabsTileOffsetX, kTopVocabsTileOffsetY),
                    child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: onVocabs,
                    child: _GlowRectTile(
                    width: 84,
                    height: 85,
                    radius: 15,
                      title: 'Vocabs',
                    icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),

                            // NEU: Farbe & Badge
                            outlineColor: kAccentBlue,
                            glowColor: kAccentBlue,
                            badgeText: '$vocabsCount',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Transform.translate(
                    offset: Offset(kTopRightBtnsOffsetX, kTopRightBtnsOffsetY),
                    child: Row(
                    children: [
                  _GlowCircleButton(
                    size: 62,
                    onTap: onAdd,
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                          outlineColor: kAccentBlue,
                          glowColor: kAccentBlue,
                  ),
                      const SizedBox(width: 10),
                  _GlowCircleButton(
                    size: 62,
                    onTap: onSettings,
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                          outlineColor: kAccentBlue,
                          glowColor: kAccentBlue,
                      ),
                    ],
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


class _GlowCircleButton extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final Color outlineColor;
  final Color glowColor;

  const _GlowCircleButton({required this.size, required this.child, this.onTap, required this.outlineColor, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(), // → exakte runde Hitbox
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _kCard,
          shape: BoxShape.circle,
          boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: Offset(0, 8)),
          ],
          border: Border.all(color: outlineColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: child,
        ),
      ),
    );
  }

}

class _GlowRectTile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  // NEU:
  final Color outlineColor;
  final Color glowColor;
  final String? badgeText; // zeigt oben-rechts die Zahl

  const _GlowRectTile({
    required this.width,
    required this.height,
    required this.radius,
    required this.title,
    required this.icon,
    this.onTap,
    this.outlineColor = Colors.white,
    this.glowColor = Colors.white,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final borderR = BorderRadius.circular(radius);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _kCard,
            borderRadius: borderR,
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2)),
              BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
              BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 8)),
            ],
            border: Border.all(color: outlineColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderR),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: borderR,
              onTap: onTap,
              child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                    Text(title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            icon,
          ],
        ),
      ),
            ),
          ),
        ),

        // NEU: Badge oben rechts (leicht außerhalb)
        if (badgeText != null && badgeText!.isNotEmpty)
          Positioned(
            top: -8,
            right: -30, // ← hier X verschieben
            child: _CountBadge(text: badgeText!, outlineColor: outlineColor, glowColor: glowColor),
          ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String text;
  final Color outlineColor;
  final Color glowColor;

  const _CountBadge({
    required this.text,
    required this.outlineColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 3, offset: const Offset(0, -1)),
          BoxShadow(color: glowColor.withOpacity(0.7), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


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
    _switchDebounce?.cancel();
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
      // Temporär: Zeige Platzhalter statt unsichtbar zu sein
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
        clipBehavior: Clip.none, // << erlaubt Pfeile außerhalb
        children: [
          // Das Wheel
          _EdgeFade(
            fadeHeight: kWheelEdgeFadeHeight,
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: kWheelItemExtent,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onChanged,
              diameterRatio: 2.2,           // leichtes Rad-Gefühl
              perspective: 0.002,           // sehr subtil
              overAndUnderCenterOpacity: 1, // wir regeln Opacity selbst
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

          // Rechte Pfeilspalte (Up/Down), auto-hide + Flash
          Positioned.fill(
            right: -kWheelArrowRightOut, // << zieht die Pfeile nach rechts ‚raus
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

/// Pill mit adaptiver Schriftgröße (skaliert intern per FittedBox)
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
    final base = Container(
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
          fit: BoxFit.scaleDown, // passt Textgröße nach unten an
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              // Basisgröße – FittedBox skaliert automatisch
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );

    return base;
  }
}

/// Weiche Kanten oben/unten über dem Kind
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

/// Ein einzelner Pfeil (rechts), mit Flash-Animation
class _ArrowIcon extends StatefulWidget {
  final bool up;
  final bool flash;
  final VoidCallback onTap;
  const _ArrowIcon({required this.up, required this.flash, required this.onTap});

  @override
  State<_ArrowIcon> createState() => _ArrowIconState();
}

class _ArrowIconState extends State<_ArrowIcon> with SingleTickerProviderStateMixin {
  double _opacity = 0.7;

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


// ---------- Mittelteil ----------
class _MidProgress extends StatelessWidget {
  final double percent;        // 0..1 (täglicher Fortschritt)
  final String percentLabel;   // z.B. "15%"
  final int newCount;
  final int repeatsCount;
  final String repeatsOfTargetLabel; // z.B. "0/100"
  
  // Gesamtfortschritt (alle Wörter)
  final double overallPercent; // 0..1
  final String overallLabel;   // z.B. "150/263"

  const _MidProgress({
    required this.percent,
    required this.percentLabel,
    required this.newCount,
    required this.repeatsCount,
    required this.repeatsOfTargetLabel,
    required this.overallPercent,
    required this.overallLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kMidPaddingH),
      child: Column(
        children: [
          // Ring + "Daily Progress" + Counter
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Ring links
              Transform.translate(
                offset: Offset(kMidRingOffsetX, kMidRingOffsetY),
                child: _ProgressRing(
                size: 120,
                thickness: 12,
                percent: percent,
                center: Text(
                  percentLabel,
                  style: t.textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              ),
              
              SizedBox(width: kMidInnerGap),
              
              // Spacer um Counter nach rechts zu schieben
              Expanded(child: SizedBox()),
              
              // Counter rechts MIT "Daily Progress" oben in gleicher Column
              Transform.translate(
                offset: Offset(kMidCountersOffsetX, kMidCountersOffsetY),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // "Daily Progress" Label - höher und weiter links
                    Transform.translate(
                      offset: Offset(-100, -30), // Mehr nach links und höher
                      child: Text(
                        'Daily Progress',
                        style: t.textTheme.titleSmall?.copyWith(
                          color: Colors.white,  // Gleiche Größe wie "Overall Progress"
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CounterRow(label: 'new', pill: _Pill(text: '$newCount')),
                    const SizedBox(height: 12),
                    _CounterRow(label: 'Repeats', pill: _Pill(text: repeatsOfTargetLabel)),
                  ],
                ),
              ),
            ],
          ),
          
          // Gesamtfortschritt-Balken
          SizedBox(height: kOverallBarGap),
          _OverallProgressBar(
            percent: overallPercent,
            label: overallLabel,
          ),
        ],
      ),
    );
  }
}

// ---------- Gesamtfortschritt-Balken ----------
class _OverallProgressBar extends StatelessWidget {
  final double percent; // 0..1
  final String label;   // z.B. "150/263"
  
  const _OverallProgressBar({
    required this.percent,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zeile 1: Label "Overall Progress"
        Text(
          'Overall Progress',
          style: t.textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        
        // Zeile 2: Progress-Balken + Counter-Pill rechts
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress-Balken links
            Expanded(
              child: Container(
                height: kOverallBarHeight,
                decoration: BoxDecoration(
                  color: Color(0xFF2D2D2F), // Hintergrund (dunkel)
                  borderRadius: BorderRadius.circular(kOverallBarHeight / 2),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kOverallBarHeight / 2 - 1),
                  child: Stack(
                    children: [
                      // Gefüllter Teil
                      FractionallySizedBox(
                        widthFactor: percent.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE4B866), // Gold (links)
                                Color(0xFFF5D492), // Heller Gold (rechts)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Counter-Pill rechts (aligned mit "new" und "Repeats")
            _Pill(text: label),
          ],
        ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final Widget pill;
  const _CounterRow({required this.label, required this.pill});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: t.textTheme.titleSmall?.copyWith(color: Colors.white)),
        const SizedBox(width: 8),
        pill,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// Ring mit CustomPainter (runde Kappen)
class _ProgressRing extends StatelessWidget {
  final double size;
  final double thickness;
  final double percent; // 0..1
  final Widget? center;

  const _ProgressRing({
    required this.size,
    required this.thickness,
    required this.percent,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              percent: percent.clamp(0, 1),
              thickness: thickness,
              bgColor: Colors.white.withOpacity(0.12),
              fgColor: Colors.white,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double thickness;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.percent,
    required this.thickness,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - thickness / 2;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Hintergrundkreis
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.1415926535 / 180),
      360 * (3.1415926535 / 180),
      false,
      bgPaint,
    );

    // Progressbogen
    final sweep = 360 * percent;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.1415926535 / 180),
        sweep * (3.1415926535 / 180),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.percent != percent ||
        old.thickness != thickness ||
        old.bgColor != bgColor ||
        old.fgColor != fgColor;
  }
}

// ---------- Untere Levels-Kachel (unten verankert) ----------
class _PipelineLevelsCard extends StatelessWidget {
  final double height;     // Kachelhöhe (OBERKANTE bewegt sich)
  final List<int> stages;  // erwartet [s0..s5]
  final int goalPerStage;  // z.B. 100
  final Future<void> Function() onStartPressed; // Callback für Start-Button

  const _PipelineLevelsCard({
    required this.height,
    required this.stages,
    required this.goalPerStage,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = (stages.length >= 6) ? stages : [0, 0, 0, 0, 0, 0];

    return SizedBox(
      width: double.infinity,
      height: height, // nimmt die Höhe vom Aufrufer (unten verankert via Align)
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          kLevelsOuterPadL, kLevelsOuterPadT, kLevelsOuterPadR, kLevelsOuterPadB),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // "Levels"-Titel verschiebbar
            Transform.translate(
              offset: Offset(kLevelsTitleOffsetX, kLevelsTitleOffsetY),
              child: Center(
              child: Text('Levels', style: t.textTheme.titleMedium?.copyWith(color: Colors.white)),
            ),
            ),

            const SizedBox(height: 8),

            // Switches (gesamte Reihe verschiebbar in X/Y, Gap steuerbar)
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(kSwitchesOffsetX, kSwitchesOffsetY),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    _VerticalStageSwitch(
                      count: s[0],
                        outerColor: _kStageInnerRed,
                        innerColor: const Color(0xFF2D2D2F),
                        highlight: s[0] > 0,
                        completed: false,
                      label: 'New',
                      note: '0',
                        isFirst: true,
                    ),
                      SizedBox(width: kSwitchGap),
                    for (int stage = 1; stage <= 5; stage++) ...[
                      _VerticalStageSwitch(
                        count: s[stage],
                        outerColor: _kStageOuter,
                        innerColor: _kStageInner,
                        highlight: s[stage] > 0 && s[stage] < goalPerStage,
                        completed: s[stage] >= goalPerStage,
                        label: 'S$stage',
                        note: '$stage',
                      ),
                        if (stage != 5) SizedBox(width: kSwitchGap),
                    ],
                  ],
                ),
              ),
            ),
            ),

            SizedBox(height: 12),

            // Start-Button verschiebbar
            Transform.translate(
              offset: Offset(kStartBtnOffsetX, kStartBtnOffsetY),
              child: Center(
              child: SizedBox(
                width: 138,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D2D2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  onPressed: onStartPressed,

                  child: const Text('Start'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ein „hochkant Switch“ pro Stufe.
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
