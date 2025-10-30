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


class LearnModeScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title; // z. B. "Money & Shopping"

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  ConsumerState<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends ConsumerState<LearnModeScreen> {
  // Controller (Business-Logik)
  late final LearnModeController _controller;


  @override
  void initState() {
    super.initState();
    _controller = ref.read(learnModeControllerProvider.notifier);

    // Init nach 1. Frame (damit Provider hängt)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(
        categoryId: widget.categoryId,
        title: widget.title,
      );
    });
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
            return Colors.black;
          case SrsKind.aSrs:
            return const Color(0xFF3A3A3A);
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
            return Colors.black;
          case SrsKind.aSrs:
            return const Color(0xFF3A3A3A);
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
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderBar(),
            const CardArea(),
            switchesRow,                          // ← bedingte Row
            const SizedBox(height: WordsUIConstants.sectionSpacing), // Mehr Luft zwischen Switches und Buttons
            const BottomControls(),
          ],
        ),
      ),
    );
  }
}



