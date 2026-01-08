import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';

class LevelsCard extends ConsumerStatefulWidget {
  final double height;
  final List<int> stages;
  final int goalPerStage;
  final Future<void> Function() onStartPressed;
  final LevelSelectionMode mode;
  final void Function(LevelSelectionMode) onModeChanged;

  // Layout-Knobs (standard-Werte wie vorher)
  final double outerPadL;
  final double outerPadT;
  final double outerPadR;
  final double outerPadB;
  final double titleOffsetX;
  final double titleOffsetY;
  final double switchesOffsetX;
  final double switchesOffsetY;
  final double startBtnOffsetX;
  final double startBtnOffsetY;
  final double switchGap;
  final bool selectingSingle;                      // ← NEU
  final ValueChanged<int>? onSelectSingleStage;    // ← NEU
  final List<bool>? visibleMask;                   // ← NEU

  const LevelsCard({
    super.key,
    required this.height,
    required this.stages,
    required this.goalPerStage,
    required this.onStartPressed,
    required this.mode,
    required this.onModeChanged,
    this.outerPadL = 20.0,
    this.outerPadT = 8.0,
    this.outerPadR = 20.0,
    this.outerPadB = 0.0,
    this.titleOffsetX = 0.0,
    this.titleOffsetY = 0.0,
    this.switchesOffsetX = WordsLayout.switchesOffsetX,
    this.switchesOffsetY = WordsLayout.switchesOffsetY,
    this.startBtnOffsetX = WordsLayout.startBtnOffsetX,
    this.startBtnOffsetY = WordsLayout.startBtnOffsetY,
    this.switchGap = WordsLayout.switchGap,
    this.selectingSingle = false,                  // ← NEU
    this.onSelectSingleStage,                      // ← NEU
    this.visibleMask,                              // ← NEU
  });

  @override
  ConsumerState<LevelsCard> createState() => _LevelsCardState();
}

class _LevelsCardState extends ConsumerState<LevelsCard> {
  final _switchCtrl = StageSwitchRowController();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = (widget.stages.length >= 6) ? widget.stages : [0, 0, 0, 0, 0, 0];
    final srs = ref.watch(srsModeControllerProvider);
    // Stroke: in T/A ausblenden, in Hybrid wie gehabt
    final Color stroke = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return Colors.transparent;
        case SrsSystem.adaptive:
          return Colors.transparent;
        case SrsSystem.hybrid:
          return Colors.white24;
      }
    }();
    // Inner-Fill: T = schwarz, A = helleres Grau, Hybrid = 0xFF2D2D2F
    final Color innerFill = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return const Color(0xFF1A1A1A);
        case SrsSystem.adaptive:
          return const Color(0xFF162743);
        case SrsSystem.hybrid:
          return const Color(0xFF2D2D2F);
      }
    }();
    final String prefix = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return 'T';
        case SrsSystem.adaptive:
          return 'A';
        case SrsSystem.hybrid:
          return '';
      }
    }();

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(widget.outerPadL, widget.outerPadT, widget.outerPadR, widget.outerPadB),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Transform.translate(
              offset: Offset(widget.titleOffsetX, widget.titleOffsetY),
              child: Center(
                child: LevelSelectorButtons(
                  mode: widget.mode,
                  onModeChanged: (m) async {
                    widget.onModeChanged(m); // nach außen melden

                    if (m == LevelSelectionMode.s0toS5) {
                      await _switchCtrl.blinkS0toS5();
                    } else if (m == LevelSelectionMode.s1toS5) {
                      await _switchCtrl.blinkS1toS5();
                    } else {
                      await _switchCtrl.blinkSequentialS1toS5();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(widget.switchesOffsetX, widget.switchesOffsetY),
                  child: StageSwitchRow(
                    controller: _switchCtrl,
                    counts: s,
                    goalPerStage: widget.goalPerStage,
                    gap: widget.switchGap,
                    sizes: const StageSwitchSizes(
                        width: 42, height: 75, knobTop: 2, knobBottom: 18),
                    colors: StageSwitchColors(
                      newOuter: Color(0xFFA05260),
                      stageOuter: Color(0xFFE4B866),
                      inner: innerFill,
                      disabledOuter: Colors.white,
                      innerStroke: stroke,
                    ),
                    labels: StageSwitchLabels(
                        newLabel: 'New', newNote: '0', stagePrefix: prefix),
                    selectable: widget.mode == LevelSelectionMode.single,   // ← NEU
                    idlePulse: widget.mode == LevelSelectionMode.single && widget.selectingSingle, // ← NEU
                    selectedStageHighlight: (widget.mode == LevelSelectionMode.single) ? ref.read(singleStageProvider) : null, // ← NEU
                    // ✅ KEINE visibleMask hier im Kategorie-Screen
                    s0Locked: ref.watch(s0LockedProvider),
                    onTapS0: null, // Icon ist jetzt in der LevelsCard, nicht mehr in der Switch
                    onSelectStage: (stg) {
                      // Nutzer hat S1..S5 gewählt:
                      widget.onSelectSingleStage?.call(stg); // ← wir fügen Props hinzu
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            Transform.translate(
              offset: Offset(widget.startBtnOffsetX, widget.startBtnOffsetY),
              child: LayoutBuilder(
                builder: (context, c) {
                  const buttonW = 138.0;
                  const gap = 12.0;          // Abstand zwischen Schloss und Button
                  const iconBoxW = 60.0;     // grob: Padding + Icon

                  final stackW = c.maxWidth;
                  final buttonLeft = (stackW - buttonW) / 2;

                  const stackH = 60.0;
                  const buttonH = 48.0;
                  const buttonTop = (stackH - buttonH) / 2; // Zentriert vertikal: 6
                  
                  return SizedBox(
                    width: stackW,
                    height: stackH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: buttonLeft,
                          top: buttonTop, // Gleiche vertikale Position wie Button
                          child: SizedBox(
                            width: buttonW,
                            height: buttonH,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2D2D2F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              onPressed: widget.onStartPressed,
                              child: const Text('Start'),
                            ),
                          ),
                        ),
                        Positioned(
                          left: buttonLeft - gap - iconBoxW,
                          top: buttonTop + (buttonH - 40) / 2 - 10, // Zentriert vertikal mit Button (Icon ist 40px + 10px padding oben/unten)
                          child: Transform.translate(
                            offset: const Offset(-20, 0), // X nach links
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final notifier = ref.read(s0LockedProvider.notifier);
                                  final wasLocked = notifier.state;
                                  notifier.state = !wasLocked;

                                  // Wenn gerade ENTSPERRT wurde → einmal S0 blinken lassen
                                  if (wasLocked) {
                                    await _switchCtrl.blinkS0Once();
                                  }
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.all(10), // Größerer Tap-Bereich
                                  child: Icon(
                                    ref.watch(s0LockedProvider) ? Icons.lock_rounded : Icons.lock_open_rounded,
                                    size: 40,
                                    color: ref.watch(s0LockedProvider) ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
