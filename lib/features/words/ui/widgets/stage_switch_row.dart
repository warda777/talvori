// lib/features/words/ui/widgets/stage_switch_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

// Knopf-Anker: Finger sitzt leicht UNTER dem Knopf, damit der Knopf sichtbar VOR dem Finger ist.
Offset knobDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset globalPosition) {
  // Knopfgröße: 38x52 -> Anker unten bei ~75% Höhe
  return const Offset(19.0, 80.0);
}

class StageDrag {
  final int fromStage; // 0..5
  final int count;     // vorerst 1
  const StageDrag(this.fromStage, {this.count = 1});
}

class StageSwitchRowController {
  _StageSwitchRowState? _state;
  void _attach(_StageSwitchRowState s) => _state = s;

  Future<void> blinkS0toS5() async => _state?._blinkIndices([0,1,2,3,4,5], repeats: 2);
  Future<void> blinkS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 2);
  Future<void> blinkSequentialS1toS5() async => _state?._blinkIndices([1,2,3,4,5], repeats: 1, sequential: true);

  // NEU: nur S0 einmal aufglühen lassen
  Future<void> blinkS0Once() async => _state?._blinkIndices([0], repeats: 1);
}

class _KnobFeedback extends StatelessWidget {
  final int count;
  final Color innerColor;
  final Color? stroke;
  const _KnobFeedback({required this.count, required this.innerColor, this.stroke});
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 38, height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: (stroke ?? Colors.white24), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class StageSwitchRow extends StatefulWidget {
  final List<int>? counts;
  final int? goalPerStage;
  final double? gap;
  final StageSwitchSizes? sizes;
  final StageSwitchColors? colors;
  final StageSwitchLabels? labels;
  final StageSwitchRowController? controller;
  final bool selectable;                 // ← NEU: Tippen erlaubt?
  final ValueChanged<int>? onSelectStage; // ← NEU: Callback bei Tap
  final bool idlePulse;                  // ← NEU: sanftes Pulsieren aller
  final List<bool>? visibleMask;         // ← NEU: List<bool> mit Länge 6
  final int? selectedStageHighlight;     // ← NEU: 1..5 (nur Single), null = keiner
  final void Function(int fromStage, int toStage, int count)? onStageDrop; // NEW
  final bool? s0Locked;                // ← NEU
  final VoidCallback? onTapS0;          // ← NEU
  final void Function(int stage)? onTapStage; // ← NEU: Callback bei Tap auf Switch (außer S0)
  final Map<int, GlobalKey>? switchKeys; // ← NEU: Keys für Plasma-Link

  const StageSwitchRow({
    super.key,
    this.counts,
    this.goalPerStage,
    this.gap,
    this.sizes,
    this.colors,
    this.labels,
    this.controller,
    this.selectable = false,                 // ← NEU: Tippen erlaubt?
    this.onSelectStage,                      // ← NEU: Callback bei Tap
    this.idlePulse = false,                  // ← NEU: sanftes Pulsieren aller
    this.visibleMask,                        // ← NEU: List<bool> mit Länge 6
    this.selectedStageHighlight,             // ← NEU: 1..5 (nur Single), null = keiner
    this.onStageDrop,
    this.s0Locked,
    this.onTapS0,
    this.onTapStage,                         // ← NEU
    this.switchKeys,                         // ← NEU
  });

  @override
  State<StageSwitchRow> createState() => _StageSwitchRowState();
}

class _StageSwitchRowState extends State<StageSwitchRow> with SingleTickerProviderStateMixin {
  final Set<int> _blinking = {}; // Indizes die kurz glühen
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse; // 0..1

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _maybeRunPulse();
  }

  @override
  void didUpdateWidget(covariant StageSwitchRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?._attach(this);
    }
    _maybeRunPulse();
  }

  void _maybeRunPulse() {
    if (widget.idlePulse) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
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

  // NEU: nur eine Stufe blinken (z. B. nach Auswahl)
  Future<void> _blinkOnly(int s) async => _blinkIndices([s], repeats: 1, sequential: false);

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
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
    
    // 6er-Default wenn keine Maske übergeben
    final mask = widget.visibleMask ??
        const [true, true, true, true, true, true];

    // Welche Indizes sollen wirklich sichtbar sein?
    final visibleIndices = <int>[];
    for (var i = 0; i < 6; i++) {
      final show = i < mask.length ? mask[i] : true;
      if (show) visibleIndices.add(i);
    }

    final children = <Widget>[];

    for (var vi = 0; vi < visibleIndices.length; vi++) {
      final i = visibleIndices[vi];
      final isLast = vi == visibleIndices.length - 1;

      // Switch-Body für Index i
      Widget switchBody;
      
      if (i == 0) {
        // S0 (New) Switch: nur Drop-Ziel
        final bool locked = widget.s0Locked ?? false;
        switchBody = DragTarget<StageDrag>(
          onWillAccept: (data) => data != null && data.fromStage != 0,
          onAccept: (data) => widget.onStageDrop?.call(data.fromStage, 0, data.count),
          builder: (_, __, ___) => VerticalStageSwitch(
            containerKey: widget.switchKeys?[0],
            count: s[0],
            outerColor: s[0] > 0 ? (widget.colors?.newOuter ?? const Color(0xFFA05260))
                         : (widget.colors?.disabledOuter ?? Colors.grey),
            innerColor: widget.colors?.inner ?? const Color(0xFF2D2C2C),
            innerStrokeColor: widget.colors?.innerStroke,
            highlight: s[0] > 0,
            completed: false,
            label: widget.labels?.newLabel ?? 'New',
            note: widget.labels?.newNote ?? '0',
            isFirst: true,
            glow: _blinking.contains(0),
            isLocked: locked,           // ← Switch ausgrauen wenn gelockt
          ),
        );
      } else {
        // S1-S5 Switches
        final stage = i;
        final prefix = widget.labels?.stagePrefix ?? 'S';
        
        // Bestimme, ob gerade Blink (hart) oder Idle-Pulse (soft) greift
        final bool hardGlow = _blinking.contains(stage);
        final bool softGlow = widget.idlePulse && (stage >= 1);
        final bool isSelected = (widget.selectedStageHighlight != null) && (stage == widget.selectedStageHighlight);

        Widget knobbed = VerticalStageSwitch(
          containerKey: widget.switchKeys?[stage],
          count: s[stage],
          outerColor: s[stage] > 0 ? (widget.colors?.stageOuter ?? Colors.yellow) : (widget.colors?.disabledOuter ?? Colors.white),
          innerColor: widget.colors?.inner ?? Colors.grey,
          innerStrokeColor: widget.colors?.innerStroke,
          highlight: s[stage] > 0 && s[stage] < goal,
          completed: s[stage] >= goal,
          label: '$prefix$stage',
          note: '$prefix$stage',
          glow: hardGlow || softGlow || isSelected,
          pulseAnimation: softGlow ? _pulse : null,
          selectedHighlight: isSelected,
          knobWrapper: (knob) => LongPressDraggable<StageDrag>(
            data: StageDrag(stage, count: 1),
            child: knob,
            childWhenDragging: Opacity(opacity: 0.35, child: knob),
            feedback: _KnobFeedback(count: s[stage], innerColor: widget.colors?.inner ?? Colors.grey, stroke: widget.colors?.innerStroke),
            dragAnchorStrategy: knobDragAnchorStrategy,
            feedbackOffset: Offset.zero,
            maxSimultaneousDrags: s[stage] > 0 ? 1 : 0,
          ),
        );

        switchBody = DragTarget<StageDrag>(
          onWillAccept: (d) => d != null && d.fromStage != stage,
          onAccept: (d) => widget.onStageDrop?.call(d.fromStage, stage, d.count),
          builder: (_, __, ___) => knobbed,
        );
      }

      // Tap-Handler für Switches
      if (widget.selectable && i >= 1) {
        // Single-Mode: Tap wählt Stage (nur S1-S5)
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            widget.onSelectStage?.call(i);
            await _blinkOnly(i);
          },
          onLongPress: () {
            // TODO: später Karten verschieben
          },
          child: switchBody,
        );
      } else if (widget.onTapStage != null) {
        // Normal-Mode: Tap öffnet Dialog mit Wörtern (alle Stages inkl. S0)
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            widget.onTapStage?.call(i);
          },
          child: switchBody,
        );
      }

      children.add(
        Container(
          margin: EdgeInsets.only(right: isLast ? 0 : switchGap),
          child: switchBody,
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
    // 6er-Default wenn keine Maske übergeben
    final mask = widget.visibleMask ??
        const [true, true, true, true, true, true];

    // Welche Indizes sollen wirklich sichtbar sein?
    final visibleIndices = <int>[];
    for (var i = 0; i < 6; i++) {
      final show = i < mask.length ? mask[i] : true;
      if (show) visibleIndices.add(i);
    }

    final children = <Widget>[];

    for (var vi = 0; vi < visibleIndices.length; vi++) {
      final i = visibleIndices[vi];
      final isLast = vi == visibleIndices.length - 1;

      // Switch-Body für Index i
      Widget switchBody;
      
      if (i == 0) {
        // S0 (New) Switch: nur Drop-Ziel
        final bool locked = widget.s0Locked ?? false;
        switchBody = DragTarget<StageDrag>(
          onWillAccept: (data) => data != null && data.fromStage != 0,
          onAccept: (data) => widget.onStageDrop?.call(data.fromStage, 0, data.count),
          builder: (_, __, ___) => VerticalStageSwitch(
            containerKey: widget.switchKeys?[0],
            count: stages[0],
            outerColor: stages[0] > 0 ? WordsUIConstants.stageInnerRed : WordsUIConstants.stageInactive,
            innerColor: WordsUIConstants.stageInnerDark,
            highlight: stages[0] > 0,
            completed: false,
            label: 'New',
            note: '0',
            isFirst: true,
            glow: _blinking.contains(0),
            isLocked: locked,           // ← Switch ausgrauen wenn gelockt
          ),
        );
      } else {
        // S1-S5 Switches
        final stage = i;
        Widget knobbed = VerticalStageSwitch(
          containerKey: widget.switchKeys?[stage],
          count: stages[stage],
          outerColor: stages[stage] > 0 ? WordsUIConstants.stageOuter : WordsUIConstants.stageInactive,
          innerColor: WordsUIConstants.stageInner,
          highlight: stages[stage] > 0 && stages[stage] < WordsUIConstants.stageGoal,
          completed: stages[stage] >= WordsUIConstants.stageGoal,
          label: 'S$stage',
          note: '$stage',
          glow: _blinking.contains(stage),
          knobWrapper: (knob) => LongPressDraggable<StageDrag>(
            data: StageDrag(stage, count: 1),
            child: knob,
            childWhenDragging: Opacity(opacity: 0.35, child: knob),
            feedback: const _KnobFeedback(count: 0, innerColor: WordsUIConstants.stageInner, stroke: null),
            dragAnchorStrategy: knobDragAnchorStrategy,
            feedbackOffset: Offset.zero,
            maxSimultaneousDrags: stages[stage] > 0 ? 1 : 0,
          ),
        );

        switchBody = DragTarget<StageDrag>(
          onWillAccept: (d) => d != null && d.fromStage != stage,
          onAccept: (d) => widget.onStageDrop?.call(d.fromStage, stage, d.count),
          builder: (_, __, ___) => knobbed,
        );
      }

      // Tap-Handler für Switches
      if (widget.selectable && i >= 1) {
        // Single-Mode: Tap wählt Stage (nur S1-S5)
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            widget.onSelectStage?.call(i);
            await _blinkOnly(i);
          },
          onLongPress: () {
            // TODO: später Karten verschieben
          },
          child: switchBody,
        );
      } else if (widget.onTapStage != null) {
        // Normal-Mode: Tap öffnet Dialog mit Wörtern (alle Stages inkl. S0)
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            widget.onTapStage?.call(i);
          },
          child: switchBody,
        );
      }

      children.add(
        Container(
          margin: EdgeInsets.only(right: isLast ? 0 : WordsUIConstants.switchGap),
          child: switchBody,
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
  final Color? innerStroke; // NEU

  const StageSwitchColors({
    required this.newOuter,
    required this.stageOuter,
    required this.inner,
    required this.disabledOuter,
    this.innerStroke,
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
