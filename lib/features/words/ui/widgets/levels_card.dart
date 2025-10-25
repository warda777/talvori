import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';

class LevelsCard extends StatelessWidget {
  final double height;
  final List<int> stages;
  final int goalPerStage;
  final Future<void> Function() onStartPressed;

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

  const LevelsCard({
    super.key,
    required this.height,
    required this.stages,
    required this.goalPerStage,
    required this.onStartPressed,
    this.outerPadL = 20.0,
    this.outerPadT = 8.0,
    this.outerPadR = 20.0,
    this.outerPadB = 0.0,
    this.titleOffsetX = 0.0,
    this.titleOffsetY = 0.0,
    this.switchesOffsetX = 0.0,
    this.switchesOffsetY = -12.0,
    this.startBtnOffsetX = 0.0,
    this.startBtnOffsetY = 0.0,
    this.switchGap = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = (stages.length >= 6) ? stages : [0, 0, 0, 0, 0, 0];

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(outerPadL, outerPadT, outerPadR, outerPadB),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Transform.translate(
              offset: Offset(titleOffsetX, titleOffsetY),
              child: Center(
                child: Text('Levels',
                    style: t.textTheme.titleMedium?.copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: Offset(switchesOffsetX, switchesOffsetY),
                  child: StageSwitchRow(
                    counts: s,
                    goalPerStage: goalPerStage,
                    gap: switchGap,
                    sizes: const StageSwitchSizes(
                        width: 42, height: 75, knobTop: 2, knobBottom: 18),
                    colors: StageSwitchColors(
                      newOuter: Color(0xFFA05260),
                      stageOuter: Color(0xFFE4B866),
                      inner: Color(0xFF2D2C2C),
                      disabledOuter: Colors.grey,
                    ),
                    labels: const StageSwitchLabels(
                        newLabel: 'New', newNote: '0', stagePrefix: 'S'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Transform.translate(
              offset: Offset(startBtnOffsetX, startBtnOffsetY),
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
