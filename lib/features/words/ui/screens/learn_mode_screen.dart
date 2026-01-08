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

class _LearnModeScreenState extends ConsumerState<LearnModeScreen> {
  // Controller (Business-Logik)
  late final LearnModeController _controller;
  // Controller für Switch-Row Blink-Effekte
  final _switchCtrl = StageSwitchRowController();

  // ⬇️ NEU: State für Custom Wheel
  late List<String> _wheelLabels;
  late int _wheelIndex;
  
  // ⬇️ NEU: Track ob Wheel gedreht wurde (für Back-Button-Logik)
  bool _wheelChanged = false;

  @override
  void initState() {
    super.initState();
    
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
    );
  }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
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
            const CardArea(),
            switchesRow,
            const SizedBox(height: WordsUIConstants.sectionSpacing), // Mehr Luft zwischen Switches und Buttons
            const BottomControls(),
          ],
        ),
      ),
    );
  }
}



