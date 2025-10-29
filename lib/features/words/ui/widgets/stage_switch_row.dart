// lib/features/words/ui/widgets/stage_switch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

class StageSwitchRowController {
  _StageSwitchRowState? _state;
  void _attach(_StageSwitchRowState s) => _state = s;

  Future<void> blinkS0toS5() async => _state?._blinkIndices([0,1,2,3,4,5], repeats: 2);
  Future<void> blinkS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 2);
  Future<void> blinkSequentialS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 1, sequential: true);
}

class StageSwitchRow extends StatefulWidget {
  final List<int>? counts;
  final int? goalPerStage;
  final double? gap;
  final StageSwitchSizes? sizes;
  final StageSwitchColors? colors;
  final StageSwitchLabels? labels;
  final StageSwitchRowController? controller;

  const StageSwitchRow({
    super.key,
    this.counts,
    this.goalPerStage,
    this.gap,
    this.sizes,
    this.colors,
    this.labels,
    this.controller,
  });

  @override
  State<StageSwitchRow> createState() => _StageSwitchRowState();
}

class _StageSwitchRowState extends State<StageSwitchRow> {
  final Set<int> _blinking = {}; // Indizes die kurz glühen

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant StageSwitchRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?._attach(this);
    }
  }

  Future<void> _blinkIndices(List<int> indices, {int repeats = 2, bool sequential = false}) async {
    const on = Duration(milliseconds: 140);
    const off = Duration(milliseconds: 140);

    if (sequential) {
      for (final i in indices) {
        _blinking
          ..clear()
          ..add(i);
        setState(() {});
        await Future.delayed(on);
        _blinking.clear();
        setState(() {});
        await Future.delayed(off);
      }
      return;
    }

    for (int r = 0; r < repeats; r++) {
      _blinking
        ..clear()
        ..addAll(indices);
      setState(() {});
      await Future.delayed(on);
      _blinking.clear();
      setState(() {});
      await Future.delayed(off);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wenn Parameter übergeben wurden, verwende diese (für category_detail_screen)
    if (widget.counts != null) {
      return _buildWithParams();
    }
    
    // Sonst verwende Riverpod (für learn_mode_screen)
    return Consumer(
      builder: (context, ref, child) {
        final stages = ref.watch(stagesProvider);
        return _buildWithStages(stages);
      },
    );
  }

  Widget _buildWithParams() {
    final s = widget.counts!;
    final goal = widget.goalPerStage ?? 100;
    final switchGap = widget.gap ?? 8.0;
    
    List<Widget> children = [];
    
    // S0 (New) Switch
    children.add(
      Padding(
        padding: EdgeInsets.only(right: switchGap),
        child: VerticalStageSwitch(
          count: s[0],
          outerColor: s[0] > 0 ? (widget.colors?.newOuter ?? Colors.red) : (widget.colors?.disabledOuter ?? Colors.grey),
          innerColor: widget.colors?.inner ?? Colors.grey,
          highlight: s[0] > 0,
          completed: false,
          label: widget.labels?.newLabel ?? 'New',
          note: widget.labels?.newNote ?? '0',
          isFirst: true,
          glow: _blinking.contains(0),
        ),
      ),
    );
    
    // S1-S5 Switches
    for (int stage = 1; stage <= 5; stage++) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: stage < 5 ? switchGap : 0),
          child: VerticalStageSwitch(
            count: s[stage],
            outerColor: s[stage] > 0 ? (widget.colors?.stageOuter ?? Colors.yellow) : (widget.colors?.disabledOuter ?? Colors.grey),
            innerColor: widget.colors?.inner ?? Colors.grey,
            highlight: s[stage] > 0 && s[stage] < goal,
            completed: s[stage] >= goal,
            label: '${widget.labels?.stagePrefix ?? 'S'}$stage',
            note: '$stage',
            glow: _blinking.contains(stage),
          ),
        ),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildWithStages(List<int> stages) {
    List<Widget> children = [];
    
    // S0 (New) Switch
    children.add(
      Padding(
        padding: const EdgeInsets.only(right: WordsUIConstants.switchGap),
        child: VerticalStageSwitch(
          count: stages[0],
          outerColor: stages[0] > 0 ? WordsUIConstants.stageInnerRed : WordsUIConstants.stageInactive,
          innerColor: WordsUIConstants.stageInnerDark,
          highlight: stages[0] > 0,
          completed: false,
          label: 'New',
          note: '0',
          isFirst: true,
          glow: _blinking.contains(0),
        ),
      ),
    );
    
    // S1-S5 Switches
    for (int stage = 1; stage <= 5; stage++) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: stage < 5 ? WordsUIConstants.switchGap : 0),
          child: VerticalStageSwitch(
            count: stages[stage],
            outerColor: stages[stage] > 0 ? WordsUIConstants.stageOuter : WordsUIConstants.stageInactive,
            innerColor: WordsUIConstants.stageInner,
            highlight: stages[stage] > 0 && stages[stage] < WordsUIConstants.stageGoal,
            completed: stages[stage] >= WordsUIConstants.stageGoal,
            label: 'S$stage',
            note: '$stage',
            glow: _blinking.contains(stage),
          ),
        ),
      );
    }
    
    return Padding(
      padding: WordsUIConstants.screenPadding,
      child: Transform.translate(
        offset: WordsUIConstants.switchOffset,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
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
