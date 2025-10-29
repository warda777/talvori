import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/widgets.dart';
import 'package:talvori/features/words/ui/widgets/single_mode_switch_row.dart';


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

      switchesRow = SingleModeSwitchRow(
        stageLabel: 'S$st',
        srcCount: counts.src,    // ⬅ Session-Count statt stageCount
        sr1Count: counts.sr1,
        sr2Count: counts.sr2,
      );
    } else {
      // dein bisheriges StageSwitchRow für S0–S5 / S1–S5
      switchesRow = StageSwitchRow(
        counts: s, 
        goalPerStage: 100, 
        gap: 12, // kSwitchGap
        sizes: const StageSwitchSizes(width: 42, height: 75, knobTop: 2, knobBottom: 18),
        colors: StageSwitchColors(
          newOuter: const Color(0xFFA05260),
          stageOuter: const Color(0xFFE4B866),
          inner: const Color(0xFF2D2C2C),
          disabledOuter: Colors.grey,
        ),
        labels: const StageSwitchLabels(newLabel: 'New', newNote: '0', stagePrefix: 'S'),
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



