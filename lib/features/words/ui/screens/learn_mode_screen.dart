import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/widgets.dart';
import 'package:talvori/features/words/ui/widgets/single_mode_switch_row.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/srs_visuals.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/application/word_list_controller.dart' show WordListFilter, WordFilterKind;
import 'package:talvori/features/words/application/learn_navigation_origin.dart';
import 'package:talvori/features/words/ui/screens/quick_sets_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/widgets/plasma_link_painter.dart';
import 'package:talvori/features/words/ui/widgets/switch_pulse_painter.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart' show WordUserView;


class LearnModeScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title; // z. B. "Money & Shopping"
  
  // ⬇️ NEU: Custom Wheel für QuickSets
  final List<String>? customWheelLabels;
  final int? customWheelInitialIndex;
  
  // ⬇️ NEU: Navigation-Herkunft für Back-Button-Logik
  final LearnNavigationOrigin? navigationOrigin;

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.customWheelLabels,        // <— NEU
    this.customWheelInitialIndex,  // <— NEU
    this.navigationOrigin,        // <— NEU
  });

  @override
  ConsumerState<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends ConsumerState<LearnModeScreen>
    with TickerProviderStateMixin {
  // Controller (Business-Logik)
  late final LearnModeController _controller;
  // Controller für Switch-Row Blink-Effekte
  final _switchCtrl = StageSwitchRowController();

  // Plasma-Link Keys und State
  final stackKey = GlobalKey();
  final cardKey = GlobalKey();
  final Map<int, GlobalKey> switchKeys = {
    0: GlobalKey(),
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
    4: GlobalKey(),
    5: GlobalKey(),
  };

  Rect? cardRect;
  Rect? switchRect;
  bool linkVisible = false;

  late final AnimationController fx;
  late final AnimationController pulse;
  int? pulseStage;

  // Koordinaten-Helper: Global → Stack-lokal
  Offset _centerInStack(GlobalKey key) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    final global = box.localToGlobal(box.size.center(Offset.zero));
    return stackBox.globalToLocal(global);
  }

  /// Karte: Bottom-Edge exakt (und optional 2–6 px unter die Karte)
  Offset _cardBottomEdgeInStack(GlobalKey key, {double yOutset = 3}) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    // exakt bottom-center, leicht nach außen (unter die Karte)
    final local = Offset(box.size.width / 2, box.size.height + yOutset);
    final global = box.localToGlobal(local);
    return stackBox.globalToLocal(global);
  }

  /// Switch: Top-Edge der großen Pill (nicht das schwarze Inlay)
  Offset _switchTopEdgeInStack(GlobalKey key, {double yOutset = 2}) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    // top-center, leicht nach außen (über den Switch hinaus)
    final local = Offset(box.size.width / 2, -yOutset);
    final global = box.localToGlobal(local);
    return stackBox.globalToLocal(global);
  }

  Rect _rectInStack(GlobalKey key) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final box = key.currentContext!.findRenderObject() as RenderBox;

    final globalTopLeft = box.localToGlobal(Offset.zero);
    final localTopLeft = stackBox.globalToLocal(globalTopLeft);

    return localTopLeft & box.size;
  }

  void _updateLink(int targetStage) {
    final targetKey = switchKeys[targetStage];
    if (cardKey.currentContext == null || targetKey?.currentContext == null) return;
    setState(() {
      cardRect = _rectInStack(cardKey);
      final raw = _rectInStack(targetKey!);
      // Kein deflate - der Key ist bereits auf dem Container ohne Glow
      // Falls nötig, können wir später ein kleines deflate hinzufügen
      switchRect = raw; // Kein deflate, da Key bereits auf Container ohne Glow liegt
      linkVisible = true;
    });
  }

  void _hideLink() => setState(() => linkVisible = false);

  void triggerPulse(int stage) {
    setState(() => pulseStage = stage);
    pulse.forward(from: 0);
  }

  void _handleDragUpdate(double dx) {
    final threshold = MediaQuery.of(context).size.width * 0.35;
    if (dx.abs() < threshold) {
      _hideLink();
      return;
    }

    final current = ref.read(currentWordProvider);
    if (current == null) return;

    int targetStage;
    if (dx > threshold) {
      // Rechts = Correct = Stage hoch
      targetStage = (current.srsStage + 1).clamp(0, 5);
    } else {
      // Links = Incorrect = Stage runter
      targetStage = (current.srsStage - 1).clamp(0, 5);
    }

    _updateLink(targetStage);
  }

  void _handleDragEnd() {
    _hideLink();
    // Pulse wird beim Swipe-Commit getriggert (in onSwipe)
  }

  void _handleDragReturn() {
    // Karte kommt zurück - Link wieder anzeigen nach kurzer Animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _showLinkForCurrentCard();
      }
    });
  }

  void _handleSwipeCommit(bool correct) {
    final current = ref.read(currentWordProvider);
    if (current == null) return;

    int targetStage;
    if (correct) {
      // Rechts = Correct = Stage hoch
      targetStage = (current.srsStage + 1).clamp(0, 5);
    } else {
      // Links = Incorrect = Stage runter
      targetStage = (current.srsStage - 1).clamp(0, 5);
    }

    // Link sofort verstecken, weil Karte fliegt raus
    _hideLink();

    // Pulse-Animation beim Commit
    triggerPulse(targetStage);

    // Nach dem Swipe-Commit: Link für neue Karte aktivieren, NACH der Karten-Animation
    // Karten-Animation: 300ms (raus) + 50ms (delay) + 400ms (rein) = 750ms
    // Wir warten bis die Karte in Position ist (500ms nach dem Swipe-Commit)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLinkForCurrentCard();
        });
      }
    });
  }

  /// Ziel-Stage für Idle-Karte (noch nicht geswiped)
  /// Zeigt auf die aktuelle Stage des Wortes (S0..S5)
  int _targetStageForIdleCard() {
    final current = ref.read(currentWordProvider);
    return current?.srsStage ?? 0; // Fallback: Stage 0
  }

  /// Link für aktuelle Karte anzeigen
  void _showLinkForCurrentCard() {
    final targetStage = _targetStageForIdleCard();
    _updateLink(targetStage);
  }

  @override
  void dispose() {
    fx.dispose();
    pulse.dispose();
    super.dispose();
  }

  // ⬇️ NEU: State für Custom Wheel
  late List<String> _wheelLabels;
  late int _wheelIndex;
  
  // ⬇️ NEU: Track ob Wheel gedreht wurde (für Back-Button-Logik)
  bool _wheelChanged = false;

  @override
  void initState() {
    super.initState();
    
    // Animation Controller initialisieren - sehr langsame Animation
    fx = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10 Sekunden Animation (3x schneller)
    )..repeat();
    
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Doppelt so langer Bounce-Effekt
    );
    
    // ⬇️ NEU: Wheel-Labels initialisieren (ganz am Anfang)
    // Wenn übergeben, nutze die QuickSets-Wheel, sonst die bisherigen Kategorien
    if (widget.customWheelLabels != null && widget.customWheelLabels!.isNotEmpty) {
      _wheelLabels = widget.customWheelLabels!;
      _wheelIndex = (widget.customWheelInitialIndex ?? 0)
          .clamp(0, _wheelLabels.length - 1);
    } else {
      // Behalte die bestehende Logik für die normale Kategorie-Wheel
      // Die Labels werden später aus categoriesProvider geholt
      _wheelLabels = [];
      _wheelIndex = 0;
    }
    
    _controller = ref.read(learnModeControllerProvider.notifier);

    // Init nach 1. Frame (damit Provider hängt)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(
        categoryId: widget.categoryId,
        title: widget.title,
        initialQuickSetsIndex: widget.categoryId == 'quicksets' ? _wheelIndex : null,
      );
      
      // Link für erste Karte nach Layout aktivieren - warte bis Karte in Position ist
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLinkForCurrentCard();
          });
        }
      });
    });
  }

  // ⬇️ NEU: Helper-Funktion für QuickSets-Filter
  WordListFilter _quicksetsFilterFor(int idx) {
    // nur aktiv, wenn wir im QuickSets-Modus sind
    if (widget.categoryId != 'quicksets') {
      return const WordListFilter(WordFilterKind.query, '');
    }
    switch (idx) {
      case 0: return const WordListFilter(WordFilterKind.query, '');
      case 1: return const WordListFilter(WordFilterKind.about, 'my-words');
      case 2: return const WordListFilter(WordFilterKind.about, 'favorites');
      case 3: return const WordListFilter(WordFilterKind.about, 'known-words');
      case 4: return const WordListFilter(WordFilterKind.about, 'my-mix');
      default: return const WordListFilter(WordFilterKind.query, '');
    }
  }

  // ⬇️ NEU: Back-Button-Logik basierend auf Herkunft und Wheel-Status
  void _handleBackNavigation(BuildContext context) {
    final origin = widget.navigationOrigin;
    
    // Wenn keine Herkunft definiert → Standard-Navigation (pop)
    if (origin == null) {
      Navigator.of(context).pop();
      return;
    }
    
    // Wenn von Category kommt → zur aktuell ausgewählten Kategorie navigieren
    if (origin.isFromCategory) {
      // QuickSets-Sonderbehandlung
      if (origin.isQuickSets) {
        final originalIndex = origin.initialIndex ?? _wheelIndex;
        final currentIndex = _wheelIndex;
        
        // Wenn sich der Index geändert hat → zur neuen QuickSets Detail Screen navigieren
        if (currentIndex != originalIndex) {
          // Pop LearnMode und die alte QuickSets Detail Screen
          Navigator.of(context).pop(); // Pop LearnMode
          Navigator.of(context).pop(); // Pop alte QuickSets Detail Screen
          // Push neue QuickSets Detail Screen mit neuem Index
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuickSetsDetailScreen(initialIndex: currentIndex),
            ),
          );
          return;
        }
        
        // Fallback: Wenn keine Änderung → einfach zurück (pop)
        Navigator.of(context).pop();
        return;
      }
      
      // Normale Category-Navigation (nicht QuickSets)
      final state = ref.read(learnModeControllerProvider);
      final categories = state.categories;
      final selectedIndex = state.selectedCategoryIndex;
      
      // Wenn Kategorien vorhanden sind und Index gültig ist
      if (categories.isNotEmpty && selectedIndex >= 0 && selectedIndex < categories.length) {
        final currentCat = categories[selectedIndex];
        final originalCatId = origin.categoryId;
        
        // Wenn die aktuelle Kategorie anders ist als die ursprüngliche → zur neuen Kategorie navigieren
        if (originalCatId != null && currentCat.id != originalCatId) {
          // Pop LearnMode und die alte Category Detail Screen
          Navigator.of(context).pop(); // Pop LearnMode
          Navigator.of(context).pop(); // Pop alte Category Detail Screen
          // Push neue Category Detail Screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(
                title: currentCat.name,
                categoryId: currentCat.id,
                categorySlug: currentCat.slug,
                listFilter: WordListFilter(WordFilterKind.category, currentCat.id),
              ),
            ),
          );
          return;
        }
      }
      
      // Fallback: Wenn keine Änderung oder gleiche Kategorie → einfach zurück (pop)
      Navigator.of(context).pop();
      return;
    }
    
    // Wenn von Home kommt (nur für QuickSets relevant)
    if (origin.isFromHome && widget.categoryId == 'quicksets') {
      // Wenn Wheel auf "My words" (Index 1) UND nicht gedreht → zurück zu Home
      if (_wheelIndex == 1 && !_wheelChanged) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      
      // Wenn Wheel gedreht wurde oder nicht auf "My words" → zurück zu QuickSets-Detail
      // Pop LearnMode, dann navigiere zu QuickSetsDetailScreen mit aktuellem Index
      Navigator.of(context).pop(); // Pop LearnMode
      // Nach pop sollten wir auf Home sein, dann navigiere zu QuickSetsDetailScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuickSetsDetailScreen(initialIndex: _wheelIndex),
        ),
      );
      return;
    }
    
    // Fallback: Standard pop
    Navigator.of(context).pop();
  }


  // === Build ===

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(levelSelectionProvider);
    final allowed = ref.watch(allowedStagesProvider);
    final mask = List<bool>.generate(6, (i) => allowed.contains(i));
    final state = ref.watch(learnModeControllerProvider);
    final s = state.stages; // [S0..S5]
    
    // Link aktualisieren, wenn sich die Karte ändert (nur wenn nicht gerade gedragt wird)
    // ABER: Warte bis die Karten-Animation fertig ist
    ref.listen<WordUserView?>(currentWordProvider, (previous, next) {
      if (previous?.id != next?.id && !linkVisible) {
        // Karte hat sich geändert und Link ist nicht sichtbar (kein aktiver Drag)
        // Warte bis die Karte in Position ist (500ms)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLinkForCurrentCard();
            });
          }
        });
      }
    });

    Widget switchesRow;
    if (mode == LevelSelectionMode.single) {
      final st = ref.watch(singleStageProvider);                 // z.B. 2
      final counts = ref.watch(singleSessionCountsProvider);     // (src, sr1, sr2)

      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF162743);
          case SrsKind.neutral:
            return const Color(0xFF2D2D2F);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => '', // Hybrid
      };
      final stageLabelText = prefix.isEmpty ? 'S$st' : '$prefix$st';
      final srPrefix = prefix; // '' => Hybrid zeigt 'R1/R2'

      switchesRow = SingleModeSwitchRow(
        stageLabel: stageLabelText,
        srcCount: counts.src,
        sr1Count: counts.sr1,
        sr2Count: counts.sr2,
        srPrefix: srPrefix,               // ← NEU
        innerStrokeColor: stroke,         // ← NEU
        innerFillColor: innerFill,        // ← NEU
      );
    } else {
      // Non-Single: S0–S5 / S1–S5
      // Modus → Stroke & Prefix ableiten
      final srsMode = ref.watch(srsModeControllerProvider);
      final kind = switch (srsMode.mode) {
        SrsSystem.time => SrsKind.tSrs,
        SrsSystem.adaptive => SrsKind.aSrs,
        SrsSystem.hybrid => SrsKind.neutral,
      };
      final t = Theme.of(context);
      // Stroke: T/A ausblenden, Hybrid beibehalten
      final stroke = () {
        switch (kind) {
          case SrsKind.tSrs:
          case SrsKind.aSrs:
            return Colors.transparent;
          case SrsKind.neutral:
            return innerCapsuleStrokeColor(t, kind);
        }
      }();
      // Inner-Fill je Modus
      final innerFill = () {
        switch (kind) {
          case SrsKind.tSrs:
            return const Color(0xFF1A1A1A);
          case SrsKind.aSrs:
            return const Color(0xFF162743);
          case SrsKind.neutral:
            return const Color(0xFF2D2D2F);
        }
      }();
      final prefix = switch (kind) {
        SrsKind.tSrs => 'T',
        SrsKind.aSrs => 'A',
        SrsKind.neutral => '',
      };

      switchesRow = StageSwitchRow(
        controller: _switchCtrl,
        counts: s, 
        goalPerStage: 100, 
        gap: 12, // kSwitchGap
        sizes: const StageSwitchSizes(width: 42, height: 75, knobTop: 2, knobBottom: 18),
        colors: StageSwitchColors(
          newOuter: const Color(0xFFA05260),
          stageOuter: const Color(0xFFE4B866),
          inner: innerFill,
          disabledOuter: Colors.white,
          innerStroke: stroke,
        ),
        labels: StageSwitchLabels(newLabel: 'New', newNote: '0', stagePrefix: prefix),
        visibleMask: mask,                        // ⚠️ KEINE visibleMask hier für Single – diese Branch rendert nur für non-Single
        s0Locked: ref.watch(s0LockedProvider),
        onTapS0: null, // Icon ist im Category Detail Screen, hier nicht benötigt
        switchKeys: switchKeys, // ← NEU: Keys für Plasma-Link
    );
  }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          key: stackKey,
          children: [
            // Normaler Screen
            Column(
              children: [
                HeaderBar(
                  // ⬇️ NEU: Custom Wheel Labels übergeben, wenn vorhanden
                  customWheelLabels: widget.customWheelLabels != null && widget.customWheelLabels!.isNotEmpty
                      ? _wheelLabels
                      : null,
                  customWheelInitialIndex: widget.customWheelLabels != null && widget.customWheelLabels!.isNotEmpty
                      ? _wheelIndex
                      : null,
                  customOnWheelChanged: widget.customWheelLabels != null && widget.customWheelLabels!.isNotEmpty
                      ? (idx, label) {
                          setState(() {
                            _wheelIndex = idx;
                            _wheelChanged = true; // ⬇️ NEU: Markiere dass Wheel gedreht wurde
                          });
                          // ⬇️ NEU: Bei QuickSets Wörter neu laden mit neuem Filter
                          if (widget.categoryId == 'quicksets') {
                            _controller.loadWordsForQuickSets(idx);
                          }
                        }
                      : null,
                  // ⬇️ NEU: Custom Back-Button-Handler mit Navigation-Logik
                  onBack: () => _handleBackNavigation(context),
                ),
                CardArea(
                  cardKey: cardKey, // ← NEU
                  onDragUpdate: _handleDragUpdate, // ← NEU
                  onDragEnd: _handleDragEnd, // ← NEU
                  onDragReturn: _handleDragReturn, // ← NEU: Link wieder anzeigen wenn Karte zurückkommt
                  onSwipeCommit: _handleSwipeCommit, // ← NEU: Pulse-Animation
                ),
                switchesRow,
                const SizedBox(height: WordsUIConstants.sectionSpacing), // Mehr Luft zwischen Switches und Buttons
                const BottomControls(),
              ],
            ),

            // FX Overlay: Plasma-Link
            IgnorePointer(
              child: AnimatedBuilder(
                animation: fx,
                builder: (_, __) => CustomPaint(
                  painter: PlasmaBandPainter(
                    cardRect: cardRect,
                    switchRect: switchRect,
                    phase: fx.value,
                    visible: linkVisible,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),

            // FX Overlay: Switch-Pulse (Corona beim Commit)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  if (pulseStage == null) return const SizedBox.shrink();
                  final k = switchKeys[pulseStage!];
                  if (k?.currentContext == null) return const SizedBox.shrink();

                  return CustomPaint(
                    painter: SwitchPulsePainter(
                      rect: _rectInStack(k!),
                      t: Curves.easeOutCubic.transform(pulse.value), // Sanfterer, längerer Effekt
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



