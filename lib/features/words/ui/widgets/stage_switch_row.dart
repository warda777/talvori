// lib/features/words/ui/widgets/stage_switch_row.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'vertical_stage_switch.dart';

const _kHybridTimerGreen = Color(0xFF2EE56C);

// Knopf-Anker: Finger sitzt leicht UNTER dem Knopf, damit der Knopf sichtbar VOR dem Finger ist.
Offset knobDragAnchorStrategy(
  Draggable<Object> draggable,
  BuildContext context,
  Offset globalPosition,
) {
  // Knopfgröße: 38x52 -> Anker unten bei ~75% Höhe
  return const Offset(19.0, 80.0);
}

class StageDrag {
  final int fromStage; // 0..5
  final int count; // vorerst 1
  const StageDrag(this.fromStage, {this.count = 1});
}

class StageSwitchRowController {
  _StageSwitchRowState? _state;
  void _attach(_StageSwitchRowState s) => _state = s;

  Future<void> blinkS0toS5() async =>
      _state?._blinkIndices([0, 1, 2, 3, 4, 5], repeats: 2);
  Future<void> blinkS1toS5() async =>
      _state?._blinkIndices([1, 2, 3, 4, 5], repeats: 2);
  Future<void> blinkSequentialS1toS5() async =>
      _state?._blinkIndices([1, 2, 3, 4, 5], repeats: 1, sequential: true);

  // NEU: nur S0 einmal aufglühen lassen
  Future<void> blinkS0Once() async => _state?._blinkIndices([0], repeats: 1);
}

class _KnobFeedback extends StatelessWidget {
  final int count;
  final Color innerColor;
  final Color? stroke;
  const _KnobFeedback({
    required this.count,
    required this.innerColor,
    this.stroke,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 38,
        height: 52,
        child: Container(
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: (stroke ?? Colors.white24), width: 1.6),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class StageSwitchRowView extends StatefulWidget {
  final List<int> counts;
  final int goalPerStage;
  final double gap;
  final StageSwitchSizes sizes;
  final StageSwitchColors colors;
  final StageSwitchLabels labels;
  final bool showLearnedCounterInStage5;
  final int learnedInStage5;
  final bool selectable;
  final ValueChanged<int>? onSelectStage;
  final bool idlePulse;
  final List<bool>? visibleMask;
  final int? selectedStageHighlight;
  final bool s0Locked;
  final void Function(int stage)? onTapStage;
  final Map<int, GlobalKey>? switchKeys;
  final int? activePulseStage;
  final Set<int>? activePulseStages;
  final Color? activePulseColor;
  final Animation<double>? activePulseAnimation;
  final bool showSwitchNotes;
  final bool useNumericSwitchNotes;
  final List<bool>? blockedMask;
  final bool selectableAllowsEmptyStages;

  const StageSwitchRowView({
    super.key,
    required this.counts,
    this.goalPerStage = 100,
    this.gap = 8.0,
    this.sizes = const StageSwitchSizes(
      width: 42,
      height: 75,
      knobTop: 2,
      knobBottom: 18,
    ),
    this.colors = const StageSwitchColors(
      newOuter: Color(0xFFA05260),
      stageOuter: Color(0xFFE4B866),
      inner: Color(0xFF1A1A1A),
      disabledOuter: Colors.white,
    ),
    this.labels = const StageSwitchLabels(
      newLabel: 'New',
      newNote: '0',
      stagePrefix: 'T',
    ),
    this.showLearnedCounterInStage5 = false,
    this.learnedInStage5 = 0,
    this.selectable = false,
    this.onSelectStage,
    this.idlePulse = false,
    this.visibleMask,
    this.selectedStageHighlight,
    this.s0Locked = false,
    this.onTapStage,
    this.switchKeys,
    this.activePulseStage,
    this.activePulseStages,
    this.activePulseColor,
    this.activePulseAnimation,
    this.showSwitchNotes = true,
    this.useNumericSwitchNotes = false,
    this.blockedMask,
    this.selectableAllowsEmptyStages = false,
  });

  @override
  State<StageSwitchRowView> createState() => _StageSwitchRowViewState();
}

class _StageSwitchRowViewState extends State<StageSwitchRowView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _maybeRunPulse();
  }

  @override
  void didUpdateWidget(covariant StageSwitchRowView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeRunPulse();
  }

  void _maybeRunPulse() {
    if (widget.idlePulse) {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counts = widget.counts.length >= 6
        ? widget.counts
        : const [0, 0, 0, 0, 0, 0];
    final mask =
        widget.visibleMask ?? const [true, true, true, true, true, true];

    final visibleIndices = <int>[];
    for (var i = 0; i < 6; i++) {
      final show = i < mask.length ? mask[i] : true;
      if (show) visibleIndices.add(i);
    }

    final children = <Widget>[];
    for (var vi = 0; vi < visibleIndices.length; vi++) {
      final i = visibleIndices[vi];
      final isLast = vi == visibleIndices.length - 1;
      final count = counts[i];
      final disabled = count == 0;
      final blocked =
          widget.blockedMask != null &&
          i < widget.blockedMask!.length &&
          widget.blockedMask![i];
      Widget switchBody;

      if (i == 0) {
        final locked = widget.s0Locked;
        final isActivePulse =
            widget.activePulseStage == 0 ||
            (widget.activePulseStages?.contains(0) ?? false);
        switchBody = VerticalStageSwitch(
          containerKey: widget.switchKeys?[0],
          count: counts[0],
          outerColor: locked
              ? widget.colors.disabledOuter
              : blocked
              ? const Color(0xFFFF4B6E)
              : (counts[0] > 0
                    ? widget.colors.newOuter
                    : widget.colors.disabledOuter),
          innerColor: widget.colors.inner,
          innerStrokeColor: blocked
              ? const Color(0xFFFF8AA0)
              : widget.colors.innerStroke,
          highlight: locked || blocked ? false : counts[0] > 0,
          completed: false,
          label: widget.labels.newLabel,
          note: locked ? '' : (widget.useNumericSwitchNotes ? '0' : 'Fach 0'),
          showNote: widget.showSwitchNotes,
          isFirst: true,
          glow: false,
          pulseAnimation: isActivePulse ? widget.activePulseAnimation : null,
          pulseColor: isActivePulse ? widget.activePulseColor : null,
          isLocked: locked,
        );
      } else {
        final stage = i;
        final hardGlow = false;
        final softGlow = widget.idlePulse && stage >= 1;
        final isSelected =
            widget.selectedStageHighlight != null &&
            stage == widget.selectedStageHighlight;
        final learnedCount = widget.showLearnedCounterInStage5 && stage == 5
            ? widget.learnedInStage5
            : null;
        final isActivePulse =
            widget.activePulseStage == stage ||
            (widget.activePulseStages?.contains(stage) ?? false);

        switchBody = VerticalStageSwitch(
          containerKey: widget.switchKeys?[stage],
          count: counts[stage],
          outerColor: counts[stage] > 0
              ? blocked
                    ? const Color(0xFFFF4B6E)
                    : widget.colors.stageOuter
              : widget.colors.disabledOuter,
          innerColor: widget.colors.inner,
          innerStrokeColor: blocked
              ? const Color(0xFFFF8AA0)
              : widget.colors.innerStroke,
          highlight:
              !blocked &&
              counts[stage] > 0 &&
              counts[stage] < widget.goalPerStage,
          completed: counts[stage] >= widget.goalPerStage,
          label: '${widget.labels.stagePrefix}$stage',
          note: widget.useNumericSwitchNotes
              ? '$stage'
              : '${widget.labels.stagePrefix}$stage',
          showNote: widget.showSwitchNotes,
          glow: hardGlow || softGlow || isSelected,
          pulseAnimation: isActivePulse
              ? widget.activePulseAnimation
              : softGlow
              ? _pulse
              : null,
          pulseColor: isActivePulse ? widget.activePulseColor : null,
          selectedHighlight: isSelected,
          showLearnedCount: widget.showLearnedCounterInStage5 && stage == 5,
          learnedCount: learnedCount,
          knobWrapper: (knob) => LongPressDraggable<StageDrag>(
            data: StageDrag(stage, count: 1),
            childWhenDragging: Opacity(opacity: 0.35, child: knob),
            feedback: _KnobFeedback(
              count: counts[stage],
              innerColor: widget.colors.inner,
              stroke: widget.colors.innerStroke,
            ),
            dragAnchorStrategy: knobDragAnchorStrategy,
            feedbackOffset: Offset.zero,
            maxSimultaneousDrags: counts[stage] > 0 ? 1 : 0,
            child: knob,
          ),
        );
      }

      if (widget.selectable && i >= 1) {
        switchBody = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: disabled && !widget.selectableAllowsEmptyStages
              ? null
              : () => widget.onSelectStage?.call(i),
          child: switchBody,
        );
      } else if (widget.onTapStage != null) {
        final isS0Locked = i == 0 && widget.s0Locked;
        if (!isS0Locked) {
          switchBody = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => widget.onTapStage!.call(i),
            child: switchBody,
          );
        }
      }

      children.add(
        Container(
          margin: EdgeInsets.only(right: isLast ? 0 : widget.gap),
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
}

class StageSwitchRow extends StatefulWidget {
  final List<int>? counts;
  final int? goalPerStage;
  final double? gap;
  final StageSwitchSizes? sizes;
  final StageSwitchColors? colors;
  final StageSwitchLabels? labels;
  final StageSwitchRowController? controller;

  /// Shows the "learned words in S5" counter under the S5 switch.
  ///
  /// IMPORTANT: Keep this `false` for `LearnModeScreen` to avoid layout changes there.
  final bool showLearnedCounterInStage5;

  /// Category id used to compute the learned-in-S5 counter.
  ///
  /// If null/empty, the learned counter will show `0`.
  final String? learnedCounterCategoryId;
  final bool selectable; // ← NEU: Tippen erlaubt?
  final ValueChanged<int>? onSelectStage; // ← NEU: Callback bei Tap
  final bool idlePulse; // ← NEU: sanftes Pulsieren aller
  final List<bool>? visibleMask; // ← NEU: List<bool> mit Länge 6
  final int? selectedStageHighlight; // ← NEU: 1..5 (nur Single), null = keiner
  final void Function(int fromStage, int toStage, int count)?
  onStageDrop; // NEW
  final bool? s0Locked; // ← NEU
  final VoidCallback? onTapS0; // ← NEU
  final void Function(int stage)?
  onTapStage; // ← NEU: Callback bei Tap auf Switch (außer S0)
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
    this.showLearnedCounterInStage5 = false,
    this.learnedCounterCategoryId,
    this.selectable = false, // ← NEU: Tippen erlaubt?
    this.onSelectStage, // ← NEU: Callback bei Tap
    this.idlePulse = false, // ← NEU: sanftes Pulsieren aller
    this.visibleMask, // ← NEU: List<bool> mit Länge 6
    this.selectedStageHighlight, // ← NEU: 1..5 (nur Single), null = keiner
    this.onStageDrop,
    this.s0Locked,
    this.onTapS0,
    this.onTapStage, // ← NEU
    this.switchKeys, // ← NEU
  });

  @override
  State<StageSwitchRow> createState() => _StageSwitchRowState();
}

class _StageSwitchRowState extends State<StageSwitchRow>
    with SingleTickerProviderStateMixin {
  final Set<int> _blinking = {}; // Indizes die kurz glühen
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse; // 0..1

  bool _isHybridStageFrozen(LearnModeState s, int stage) {
    if (stage < 0) return false;
    if (stage >= s.hybridStageFrozen.length) return false;
    return s.hybridStageFrozen[stage] == true;
  }

  String _fmtMmSs(int sec) {
    final s = sec.clamp(0, 99 * 60 + 59);
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  String _fmtHhMm(Duration d) {
    final totalMin = d.inMinutes;
    final h = (totalMin ~/ 60).toString().padLeft(2, '0');
    final m = (totalMin % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _hybridStageTimerLabel(LearnModeState s, int stage) {
    if (stage <= 0) return '';
    if (stage >= s.hybridStageRemainingSec.length) return '';
    final rem = s.hybridStageRemainingSec[stage];
    if (rem < 0) return ''; // H3–H5: kein Timer, nichts anzeigen
    if (rem == 0) {
      // bis morgen (lokal)
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      final left = tomorrow.difference(now);
      return 'Morgen ${_fmtHhMm(left)}';
    }
    return _fmtMmSs(rem);
  }

  String _stageSubNote(SrsSystem mode, LearnModeState s, int stage) {
    // ✅ Timer-Anzeige nur im Hybrid (A‑SRS wird nie "getimed", T‑SRS aktuell ohne Timer-UI)
    if (stage <= 0) return '';
    if (mode == SrsSystem.hybrid) return _hybridStageTimerLabel(s, stage);
    return '';
  }

  Color? _stageSubNoteColor(SrsSystem mode, LearnModeState s, int stage) {
    if (mode != SrsSystem.hybrid) return null;
    if (!s.hybridSessionStarted) return null;
    // Farbe soll sich an der *aktuellen Karte* orientieren (nicht an activeStage),
    // damit der Nutzer sieht, dass der Countdown für H1/H2 wirklich läuft.
    int currentStage = s.activeStage;
    if (s.shuffledWordIds.isNotEmpty &&
        s.index >= 0 &&
        s.index < s.shuffledWordIds.length &&
        s.wordQueue.isNotEmpty) {
      final currentId = s.shuffledWordIds[s.index];
      for (final w in s.wordQueue) {
        if (w.id == currentId) {
          currentStage = w.srsStage;
          break;
        }
      }
    }
    if (stage != currentStage) return null;
    if (stage < 1 || stage > 2) {
      return null; // aktuell nur H1/H2 haben Tagesbudgets
    }
    if (_isHybridStageFrozen(s, stage)) return null;
    return _kHybridTimerGreen;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
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

  Future<void> _blinkIndices(
    List<int> indices, {
    int repeats = 2,
    bool sequential = false,
  }) async {
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
  Future<void> _blinkOnly(int s) async =>
      _blinkIndices([s], repeats: 1, sequential: false);

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
    return Consumer(
      builder: (context, ref, _) {
        final s = widget.counts!;
        final goal = widget.goalPerStage ?? 100;
        final switchGap = widget.gap ?? 8.0;

        // Prüfe Bedingungen für Einfrieren
        final learnState = ref.watch(learnModeControllerProvider);
        final srsMode = ref.watch(srsModeControllerProvider);
        final isHybrid = srsMode.mode == SrsSystem.hybrid;

        // 6er-Default wenn keine Maske übergeben
        final mask =
            widget.visibleMask ?? const [true, true, true, true, true, true];

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
              onAccept: (data) =>
                  widget.onStageDrop?.call(data.fromStage, 0, data.count),
              builder: (_, __, ___) => VerticalStageSwitch(
                containerKey: widget.switchKeys?[0],
                count: s[0],
                outerColor: locked
                    ? (widget.colors?.disabledOuter ?? Colors.grey)
                    : (s[0] > 0
                          ? (widget.colors?.newOuter ?? const Color(0xFFA05260))
                          : (widget.colors?.disabledOuter ?? Colors.grey)),
                innerColor: widget.colors?.inner ?? const Color(0xFF2D2C2C),
                innerStrokeColor: widget.colors?.innerStroke,
                highlight: locked ? false : (s[0] > 0),
                completed: false,
                label: widget.labels?.newLabel ?? 'New',
                note: locked ? '' : 'Fach 0',
                isFirst: true,
                glow: _blinking.contains(0),
                isLocked:
                    locked, // ← Bei Lock: großes X statt Count; bei Unlock: Fach 0
              ),
            );
          } else {
            // S1-S5 Switches
            final stage = i;
            final prefix = widget.labels?.stagePrefix ?? 'S';

            // Bestimme, ob gerade Blink (hart) oder Idle-Pulse (soft) greift
            final bool hardGlow = _blinking.contains(stage);
            final bool softGlow = widget.idlePulse && (stage >= 1);
            final bool isSelected =
                (widget.selectedStageHighlight != null) &&
                (stage == widget.selectedStageHighlight);

            final learnedCount =
                (widget.showLearnedCounterInStage5 && stage == 5)
                ? (ref
                          .watch(
                            learnedInStage5Provider(
                              widget.learnedCounterCategoryId ?? '',
                            ),
                          )
                          .valueOrNull ??
                      0)
                : null;

            Widget knobbed = VerticalStageSwitch(
              containerKey: widget.switchKeys?[stage],
              count: s[stage],
              outerColor: s[stage] > 0
                  ? (widget.colors?.stageOuter ?? Colors.yellow)
                  : (widget.colors?.disabledOuter ?? Colors.white),
              innerColor: widget.colors?.inner ?? Colors.grey,
              innerStrokeColor: widget.colors?.innerStroke,
              highlight: s[stage] > 0 && s[stage] < goal,
              completed: s[stage] >= goal,
              label: '$prefix$stage',
              note: '$prefix$stage',
              subNote: _stageSubNote(srsMode.mode, learnState, stage),
              subNoteColor: _stageSubNoteColor(srsMode.mode, learnState, stage),
              glow: hardGlow || softGlow || isSelected,
              pulseAnimation: softGlow ? _pulse : null,
              selectedHighlight: isSelected,
              showLearnedCount: widget.showLearnedCounterInStage5 && stage == 5,
              learnedCount: learnedCount,
              knobWrapper: (knob) => LongPressDraggable<StageDrag>(
                data: StageDrag(stage, count: 1),
                childWhenDragging: Opacity(opacity: 0.35, child: knob),
                feedback: _KnobFeedback(
                  count: s[stage],
                  innerColor: widget.colors?.inner ?? Colors.grey,
                  stroke: widget.colors?.innerStroke,
                ),
                dragAnchorStrategy: knobDragAnchorStrategy,
                feedbackOffset: Offset.zero,
                maxSimultaneousDrags:
                    (s[stage] > 0 &&
                        !(isHybrid && _isHybridStageFrozen(learnState, stage)))
                    ? 1
                    : 0,
                child: knob,
              ),
            );

            switchBody = DragTarget<StageDrag>(
              onWillAccept: (d) => d != null && d.fromStage != stage,
              onAccept: (d) =>
                  widget.onStageDrop?.call(d.fromStage, stage, d.count),
              builder: (_, __, ___) => knobbed,
            );
          }

          // Tap-Handler für Switches
          final count = s[i];
          final disabled = count == 0;

          if (widget.selectable && i >= 1) {
            // Single-Mode: Tap wählt Stage (nur S1-S5)
            // ❗ Block: leere Stages deaktivieren
            switchBody = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: disabled
                  ? null
                  : () async {
                      // ✅ FIX: leere Stage nicht auswählbar (zusätzliche Sicherheit)
                      if (count == 0) return;
                      widget.onSelectStage?.call(i);
                      await _blinkOnly(i);
                    },
              onLongPress: () {
                // TODO: später Karten verschieben
              },
              child: switchBody,
            );
          } else if (widget.onTapStage != null) {
            // Normal-Mode: Tap öffnet Dialog mit Infos (alle Stages, auch leere)
            final bool isS0Locked = (i == 0) && (widget.s0Locked == true);
            if (!isS0Locked) {
              switchBody = GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onTapStage!.call(i),
                child: switchBody,
              );
            }
          }

          children.add(
            Container(
              margin: EdgeInsets.only(right: isLast ? 0 : switchGap),
              child: switchBody,
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Alle Switches oben ausrichten, damit sie auf gleicher Y-Position sind
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      },
    );
  }

  Widget _buildWithStages(List<int> stages) {
    return Consumer(
      builder: (context, ref, _) {
        // Prüfe Bedingungen für Einfrieren
        final learnState = ref.watch(learnModeControllerProvider);
        final srsMode = ref.watch(srsModeControllerProvider);
        final isHybrid = srsMode.mode == SrsSystem.hybrid;

        // 6er-Default wenn keine Maske übergeben
        final mask =
            widget.visibleMask ?? const [true, true, true, true, true, true];

        // Welche Indizes sollen wirklich sichtbar sein?
        // ✅ Im LearnMode nur Stages mit Count > 0 anzeigen
        final visibleIndices = <int>[];
        for (var i = 0; i < 6; i++) {
          final show = i < mask.length ? mask[i] : true;
          if (show && stages[i] > 0) {
            visibleIndices.add(i);
          }
        }

        // Fallback: wenn ALLES 0 (kurzer Reset/Reload-Moment)
        if (visibleIndices.isEmpty) {
          for (var i = 0; i < 6; i++) {
            final show = i < mask.length ? mask[i] : true;
            if (show) visibleIndices.add(i);
          }
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
              onAccept: (data) =>
                  widget.onStageDrop?.call(data.fromStage, 0, data.count),
              builder: (_, __, ___) => VerticalStageSwitch(
                containerKey: widget.switchKeys?[0],
                count: stages[0],
                outerColor: locked
                    ? WordsUIConstants.stageInactive
                    : (stages[0] > 0
                          ? WordsUIConstants.stageInnerRed
                          : WordsUIConstants.stageInactive),
                innerColor: WordsUIConstants.stageInnerDark,
                highlight: locked ? false : (stages[0] > 0),
                completed: false,
                label: 'New',
                note: locked ? '' : 'Fach 0',
                isFirst: true,
                glow: _blinking.contains(0),
                isLocked:
                    locked, // ← Bei Lock: großes X statt Count; bei Unlock: Fach 0
              ),
            );
          } else {
            // S1-S5 Switches
            final stage = i;
            final prefix = widget.labels?.stagePrefix ?? 'S';

            Widget knobbed = VerticalStageSwitch(
              containerKey: widget.switchKeys?[stage],
              count: stages[stage],
              outerColor: stages[stage] > 0
                  ? WordsUIConstants.stageOuter
                  : WordsUIConstants.stageInactive,
              innerColor: WordsUIConstants.stageInner,
              highlight:
                  stages[stage] > 0 &&
                  stages[stage] < WordsUIConstants.stageGoal,
              completed: stages[stage] >= WordsUIConstants.stageGoal,
              label: '$prefix$stage',
              note: '$prefix$stage',
              subNote: _stageSubNote(srsMode.mode, learnState, stage),
              subNoteColor: _stageSubNoteColor(srsMode.mode, learnState, stage),
              glow: _blinking.contains(stage),
              showLearnedCount: widget.showLearnedCounterInStage5 && stage == 5,
              learnedCount: (widget.showLearnedCounterInStage5 && stage == 5)
                  ? (ref
                            .watch(
                              learnedInStage5Provider(
                                widget.learnedCounterCategoryId ?? '',
                              ),
                            )
                            .valueOrNull ??
                        0)
                  : null,
              knobWrapper: (knob) => LongPressDraggable<StageDrag>(
                data: StageDrag(stage, count: 1),
                childWhenDragging: Opacity(opacity: 0.35, child: knob),
                feedback: const _KnobFeedback(
                  count: 0,
                  innerColor: WordsUIConstants.stageInner,
                  stroke: null,
                ),
                dragAnchorStrategy: knobDragAnchorStrategy,
                feedbackOffset: Offset.zero,
                maxSimultaneousDrags:
                    (stages[stage] > 0 &&
                        !(isHybrid && _isHybridStageFrozen(learnState, stage)))
                    ? 1
                    : 0,
                child: knob,
              ),
            );

            switchBody = DragTarget<StageDrag>(
              onWillAccept: (d) => d != null && d.fromStage != stage,
              onAccept: (d) =>
                  widget.onStageDrop?.call(d.fromStage, stage, d.count),
              builder: (_, __, ___) => knobbed,
            );
          }

          // Tap-Handler für Switches
          final count = stages[i];
          final disabled = count == 0;

          if (widget.selectable && i >= 1) {
            // Single-Mode: Tap wählt Stage (nur S1-S5)
            // ❗ Block: leere Stages deaktivieren
            switchBody = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: disabled
                  ? null
                  : () async {
                      // ✅ FIX: leere Stage nicht auswählbar (zusätzliche Sicherheit)
                      if (count == 0) return;
                      widget.onSelectStage?.call(i);
                      await _blinkOnly(i);
                    },
              onLongPress: () {
                // TODO: später Karten verschieben
              },
              child: switchBody,
            );
          } else if (widget.onTapStage != null) {
            // Normal-Mode: Tap öffnet Dialog mit Infos (alle Stages, auch leere)
            final bool isS0Locked = (i == 0) && (widget.s0Locked == true);
            if (!isS0Locked) {
              switchBody = GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onTapStage!.call(i),
                child: switchBody,
              );
            }
          }

          children.add(
            Container(
              margin: EdgeInsets.only(
                right: isLast ? 0 : WordsUIConstants.switchGap,
              ),
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
      },
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
