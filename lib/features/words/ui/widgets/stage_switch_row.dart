// lib/features/words/ui/widgets/stage_switch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

class StageSwitchRow extends ConsumerWidget {
  const StageSwitchRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(stagesProvider);

    return Padding(
      padding: WordsUIConstants.screenPadding,
      child: Transform.translate(
        offset: WordsUIConstants.switchOffset,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VerticalStageSwitch(
              count: stages[0],
              outerColor:
                  stages[0] > 0 ? WordsUIConstants.stageInnerRed : WordsUIConstants.stageInactive,
              innerColor: WordsUIConstants.stageInnerDark,
              highlight: stages[0] > 0,
              completed: false,
              label: 'New',
              note: '0',
              isFirst: true,
            ),
            const SizedBox(width: WordsUIConstants.switchGap),
            for (int stage = 1; stage <= 5; stage++) ...[
              VerticalStageSwitch(
                count: stages[stage],
                outerColor:
                    stages[stage] > 0 ? WordsUIConstants.stageOuter : WordsUIConstants.stageInactive,
                innerColor: WordsUIConstants.stageInner,
                highlight:
                    stages[stage] > 0 && stages[stage] < WordsUIConstants.stageGoal,
                completed: stages[stage] >= WordsUIConstants.stageGoal,
                label: 'S$stage',
                note: '$stage',
              ),
              if (stage != 5) const SizedBox(width: WordsUIConstants.switchGap),
            ],
          ],
        ),
      ),
    );
  }
}
