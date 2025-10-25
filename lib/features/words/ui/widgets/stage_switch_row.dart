// lib/features/words/ui/widgets/stage_switch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

class StageSwitchRow extends ConsumerWidget {
  final List<int>? counts;
  final int? goalPerStage;
  final double? gap;
  final StageSwitchSizes? sizes;
  final StageSwitchColors? colors;
  final StageSwitchLabels? labels;

  const StageSwitchRow({
    super.key,
    this.counts,
    this.goalPerStage,
    this.gap,
    this.sizes,
    this.colors,
    this.labels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wenn Parameter übergeben wurden, verwende diese (für category_detail_screen)
    if (counts != null) {
      return _buildWithParams();
    }
    
    // Sonst verwende Riverpod (für learn_mode_screen)
    final stages = ref.watch(stagesProvider);
    return _buildWithStages(stages);
  }

  Widget _buildWithParams() {
    final s = counts!;
    final goal = goalPerStage ?? 100;
    final switchGap = gap ?? 8.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VerticalStageSwitch(
          count: s[0],
          outerColor: s[0] > 0 ? (colors?.newOuter ?? Colors.red) : (colors?.disabledOuter ?? Colors.grey),
          innerColor: colors?.inner ?? Colors.grey,
          highlight: s[0] > 0,
          completed: false,
          label: labels?.newLabel ?? 'New',
          note: labels?.newNote ?? '0',
          isFirst: true,
        ),
        SizedBox(width: switchGap),
        for (int stage = 1; stage <= 5; stage++) ...[
          VerticalStageSwitch(
            count: s[stage],
            outerColor: s[stage] > 0 ? (colors?.stageOuter ?? Colors.yellow) : (colors?.disabledOuter ?? Colors.grey),
            innerColor: colors?.inner ?? Colors.grey,
            highlight: s[stage] > 0 && s[stage] < goal,
            completed: s[stage] >= goal,
            label: '${labels?.stagePrefix ?? 'S'}$stage',
            note: '$stage',
          ),
          if (stage != 5) SizedBox(width: switchGap),
        ],
      ],
    );
  }

  Widget _buildWithStages(List<int> stages) {
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

// Helper classes für Parameter
class StageSwitchSizes {
  final double width;
  final double height;
  final double knobTop;
  final double knobBottom;

  const StageSwitchSizes({
    required this.width,
    required this.height,
    required this.knobTop,
    required this.knobBottom,
  });
}

class StageSwitchColors {
  final Color newOuter;
  final Color stageOuter;
  final Color inner;
  final Color disabledOuter;

  const StageSwitchColors({
    required this.newOuter,
    required this.stageOuter,
    required this.inner,
    required this.disabledOuter,
  });
}

class StageSwitchLabels {
  final String newLabel;
  final String newNote;
  final String stagePrefix;

  const StageSwitchLabels({
    required this.newLabel,
    required this.newNote,
    required this.stagePrefix,
  });
}
