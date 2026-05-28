import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';
import 'package:talvori/features/words/application/s0_lock_provider.dart';
import 'package:talvori/features/words/application/srs_config.dart';
import 'package:talvori/features/words/application/srs_logic.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';
import 'package:talvori/features/words/ui/widgets/stage_switch_row.dart';
import 'package:talvori/features/words/ui/widgets/stage_words_dialog.dart';

class LevelsCard extends ConsumerStatefulWidget {
  final double height;
  final List<int> stages;
  final int goalPerStage;
  final Future<void> Function() onStartPressed;
  final Widget? learningModeSelector;
  final LevelSelectionMode mode;
  final void Function(LevelSelectionMode) onModeChanged;
  final String? categoryId; // ← NEU: Für Dialog mit Wörtern

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
  final bool selectingSingle; // ← NEU
  final ValueChanged<int>? onSelectSingleStage; // ← NEU
  final List<bool>? visibleMask; // ← NEU
  final VoidCallback? onS0LockTapped; // ← NEU: für userHasInteracted
  final Future<void> Function()?
  onBeforeLockTap; // ← für Tooltip (vor Lock-Aktion)
  final GlobalKey? lockKey; // ← für Tooltip
  final GlobalKey? autoButtonKey; // ← für Tooltip
  final GlobalKey? trainingButtonKey; // ← für Tooltip
  final GlobalKey? singleButtonKey; // ← für Tooltip

  const LevelsCard({
    super.key,
    required this.height,
    required this.stages,
    required this.goalPerStage,
    required this.onStartPressed,
    this.learningModeSelector,
    required this.mode,
    required this.onModeChanged,
    this.categoryId, // ← NEU
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
    this.selectingSingle = false, // ← NEU
    this.onSelectSingleStage, // ← NEU
    this.visibleMask, // ← NEU
    this.onS0LockTapped, // ← NEU
    this.onBeforeLockTap, // ← für Tooltip
    this.lockKey, // ← für Tooltip
    this.autoButtonKey, // ← für Tooltip
    this.trainingButtonKey, // ← für Tooltip
    this.singleButtonKey, // ← für Tooltip
  });

  @override
  ConsumerState<LevelsCard> createState() => _LevelsCardState();
}

class LevelsCardView extends StatelessWidget {
  final double height;
  final Future<void> Function() onStartPressed;
  final Widget? learningModeSelector;
  final Widget levelSelector;
  final Widget stageSwitchRow;
  final bool isHybrid;
  final bool s0Locked;
  final VoidCallback onS0LockTap;
  final GlobalKey? lockKey;
  final bool showLockControl;

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
  final bool useFixedStageLayout;
  final bool learningModeBelowStages;
  final String? stageSectionLabel;
  final double repeatSectionTopGap;
  final AlignmentGeometry stageSectionLabelAlignment;
  final double stageSectionLabelBottomGap;
  final double stageTopGap;
  final double startTopGap;
  final Widget? startTrailingControl;

  const LevelsCardView({
    super.key,
    required this.height,
    required this.onStartPressed,
    this.learningModeSelector,
    required this.levelSelector,
    required this.stageSwitchRow,
    required this.isHybrid,
    required this.s0Locked,
    required this.onS0LockTap,
    this.lockKey,
    this.showLockControl = true,
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
    this.useFixedStageLayout = false,
    this.learningModeBelowStages = false,
    this.stageSectionLabel,
    this.repeatSectionTopGap = 6.0,
    this.stageSectionLabelAlignment = Alignment.topCenter,
    this.stageSectionLabelBottomGap = 0,
    this.stageTopGap = 24.0,
    this.startTopGap = 12.0,
    this.startTrailingControl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          outerPadL,
          outerPadT,
          outerPadR,
          outerPadB,
        ),
        child: Column(
          children: [
            SizedBox(height: repeatSectionTopGap),
            if (learningModeSelector != null && !learningModeBelowStages) ...[
              _SectionLabel('Lernmodus'),
              const SizedBox(height: 5),
              Center(child: learningModeSelector),
              const SizedBox(height: 22),
            ] else if (!learningModeBelowStages)
              const SizedBox(height: 22),
            _SectionLabel('Wiederholungsauswahl'),
            const SizedBox(height: 8),
            Transform.translate(
              offset: Offset(titleOffsetX, titleOffsetY),
              child: Center(child: levelSelector),
            ),
            SizedBox(
              height: stageTopGap,
              child: stageSectionLabel == null
                  ? null
                  : Align(
                      alignment: stageSectionLabelAlignment,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: stageSectionLabelBottomGap,
                        ),
                        child: _SectionLabel(stageSectionLabel!),
                      ),
                    ),
            ),
            if (useFixedStageLayout)
              Transform.translate(
                offset: Offset(switchesOffsetX, switchesOffsetY),
                child: stageSwitchRow,
              )
            else
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(switchesOffsetX, switchesOffsetY),
                    child: stageSwitchRow,
                  ),
                ),
              ),
            SizedBox(height: startTopGap),
            if (learningModeSelector != null && learningModeBelowStages) ...[
              _SectionLabel('Lernmodus'),
              const SizedBox(height: 12),
              Center(child: learningModeSelector),
              const SizedBox(height: 28),
            ],
            Transform.translate(
              offset: Offset(startBtnOffsetX, startBtnOffsetY),
              child: LayoutBuilder(
                builder: (context, c) {
                  const buttonW = 138.0;
                  const gap = 12.0;
                  const iconBoxW = 60.0;
                  const trailingControlW = 44.0;

                  final stackW = c.maxWidth;
                  final buttonLeft = (stackW - buttonW) / 2;
                  final minTrailingLeft = buttonLeft + buttonW + gap;
                  final maxTrailingLeft = stackW - trailingControlW - 28;
                  final targetTrailingLeft = buttonLeft + buttonW + 30;
                  final trailingLeft = maxTrailingLeft < minTrailingLeft
                      ? maxTrailingLeft
                      : targetTrailingLeft.clamp(
                          minTrailingLeft,
                          maxTrailingLeft,
                        );

                  const stackH = 60.0;
                  const buttonH = 48.0;
                  const buttonTop = (stackH - buttonH) / 2;

                  return SizedBox(
                    width: stackW,
                    height: stackH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: buttonLeft,
                          top: buttonTop,
                          child: SizedBox(
                            width: buttonW,
                            height: buttonH,
                            child: StartButtonPulse(
                              onPressed: onStartPressed,
                              child: const _NeonStartButtonLabel(),
                            ),
                          ),
                        ),
                        if (!isHybrid && showLockControl)
                          Positioned(
                            left: buttonLeft - gap - iconBoxW,
                            top: buttonTop + (buttonH - 40) / 2 - 10,
                            child: Transform.translate(
                              offset: const Offset(-20, 0),
                              child: TapScaleAnimation(
                                peakScale: 1.12,
                                duration: const Duration(milliseconds: 200),
                                onTap: onS0LockTap,
                                child: Material(
                                  key: lockKey,
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      s0Locked
                                          ? Icons.lock_rounded
                                          : Icons.lock_open_rounded,
                                      size: 40,
                                      color: s0Locked
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (startTrailingControl != null)
                          Positioned(
                            left: trailingLeft,
                            top: buttonTop + (buttonH - 44) / 2,
                            child: startTrailingControl!,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: const Color(0xFF9E9EA6),
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        shadows: [
          Shadow(
            color: const Color(0xFF8A5CFF).withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _NeonStartButtonLabel extends StatelessWidget {
  const _NeonStartButtonLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A1D), Color(0xFF050505)],
        ),
        border: Border.all(color: Color(0xFF7FFFE7), width: 1.7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7FFFE7).withValues(alpha: 0.3),
            blurRadius: 14,
            spreadRadius: 0.6,
          ),
          BoxShadow(
            color: const Color(0xFFF5BFCB).withValues(alpha: 0.2),
            blurRadius: 18,
            spreadRadius: 0.4,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.45),
            width: 0.8,
          ),
        ),
        child: Text(
          'Start',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _LevelsCardState extends ConsumerState<LevelsCard> {
  final _switchCtrl = StageSwitchRowController();

  Future<void> _handleLockTap(WidgetRef r, bool wasLocked) async {
    if (widget.categoryId == null) return;
    await widget.onBeforeLockTap?.call();
    widget.onS0LockTapped?.call();
    final nextLocked = !wasLocked;
    await r
        .read(s0LockServiceProvider)
        .setLocked(categoryId: widget.categoryId!, locked: nextLocked);
    if (wasLocked) await _switchCtrl.blinkS0Once();
  }

  // Adapter-Funktionen: Map interne Enums zu Popup-Enums
  SrsPopupMode _mapPopupMode(SrsSystem mode) {
    switch (mode) {
      case SrsSystem.time:
        return SrsPopupMode.tSrs;
      case SrsSystem.adaptive:
        return SrsPopupMode.aSrs;
      case SrsSystem.hybrid:
        return SrsPopupMode.hybrid;
    }
  }

  SrsPopupRange _mapPopupRange(LevelSelectionMode mode) {
    switch (mode) {
      case LevelSelectionMode.s0toS5:
        return SrsPopupRange.s0toS5;
      case LevelSelectionMode.s1toS5:
        return SrsPopupRange.s1toS5;
      case LevelSelectionMode.single:
        return SrsPopupRange.single;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = (widget.stages.length >= 6) ? widget.stages : [0, 0, 0, 0, 0, 0];
    final srs = ref.watch(srsModeControllerProvider);
    final bool isHybrid = srs.mode == SrsSystem.hybrid;
    final bool s0Locked = (widget.categoryId == null)
        ? false
        : ref
              .watch(s0LockedProvider(widget.categoryId!))
              .maybeWhen(data: (v) => v, orElse: () => false);
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
    // Inner-Fill: T = schwarz, A = 542C78 (Violett), Hybrid = 244B8B (Blau)
    final Color innerFill = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return const Color(0xFF1A1A1A);
        case SrsSystem.adaptive:
          return const Color(0xFF542C78);
        case SrsSystem.hybrid:
          return const Color(0xFF244B8B);
      }
    }();
    final String prefix = () {
      switch (srs.mode) {
        case SrsSystem.time:
          return 'T';
        case SrsSystem.adaptive:
          return 'A';
        case SrsSystem.hybrid:
          return 'H';
      }
    }();

    return LevelsCardView(
      height: widget.height,
      onStartPressed: widget.onStartPressed,
      isHybrid: isHybrid,
      s0Locked: s0Locked,
      lockKey: widget.lockKey,
      onS0LockTap: () => _handleLockTap(ref, s0Locked),
      outerPadL: widget.outerPadL,
      outerPadT: widget.outerPadT,
      outerPadR: widget.outerPadR,
      outerPadB: widget.outerPadB,
      titleOffsetX: widget.titleOffsetX,
      titleOffsetY: widget.titleOffsetY,
      switchesOffsetX: widget.switchesOffsetX,
      switchesOffsetY: widget.switchesOffsetY,
      startBtnOffsetX: widget.startBtnOffsetX,
      startBtnOffsetY: widget.startBtnOffsetY,
      levelSelector: LevelSelectorButtons(
        mode: widget.mode,
        autoButtonKey: widget.autoButtonKey,
        trainingButtonKey: widget.trainingButtonKey,
        singleButtonKey: widget.singleButtonKey,
        onModeChanged: (m) async {
          widget.onModeChanged(m);

          if (m == LevelSelectionMode.s0toS5) {
            await _switchCtrl.blinkS0toS5();
          } else if (m == LevelSelectionMode.s1toS5) {
            await _switchCtrl.blinkS1toS5();
          } else {
            await _switchCtrl.blinkSequentialS1toS5();
          }
        },
      ),
      learningModeSelector: widget.learningModeSelector,
      stageSwitchRow: StageSwitchRow(
        controller: _switchCtrl,
        counts: s,
        goalPerStage: widget.goalPerStage,
        gap: widget.switchGap,
        showLearnedCounterInStage5: true,
        learnedCounterCategoryId: widget.categoryId ?? '',
        sizes: const StageSwitchSizes(
          width: 42,
          height: 75,
          knobTop: 2,
          knobBottom: 18,
        ),
        colors: StageSwitchColors(
          newOuter: const Color(0xFFA05260),
          stageOuter: const Color(0xFFE4B866),
          inner: innerFill,
          disabledOuter: Colors.white,
          innerStroke: stroke,
        ),
        labels: StageSwitchLabels(
          newLabel: 'New',
          newNote: '0',
          stagePrefix: prefix,
        ),
        selectable: widget.mode == LevelSelectionMode.single,
        idlePulse:
            widget.mode == LevelSelectionMode.single && widget.selectingSingle,
        selectedStageHighlight: widget.mode == LevelSelectionMode.single
            ? ref.read(singleStageProvider)
            : null,
        s0Locked: s0Locked,
        onTapS0: null,
        onSelectStage: (stg) {
          widget.onSelectSingleStage?.call(stg);
        },
        onTapStage: widget.categoryId != null
            ? (stage) {
                final stageLabel = prefix.isEmpty ? 'S$stage' : '$prefix$stage';
                final wordCount = stage < s.length ? s[stage] : 0;

                final internalMode = ref.read(srsModeControllerProvider);
                final internalRange = ref.read(levelSelectionProvider);

                final popupMode = _mapPopupMode(internalMode.mode);
                final popupRange = _mapPopupRange(internalRange);

                showDialog(
                  context: context,
                  builder: (context) => StageWordsDialog(
                    categoryId: widget.categoryId!,
                    stage: stage,
                    stageLabel: stageLabel,
                    wordCount: wordCount,
                    popupMode: popupMode,
                    popupRange: popupRange,
                    s0Locked: s0Locked,
                    dailyNewLimit: SrsUiConfig.tSrsDailyNewLimit,
                    learnedTodayFromS0: null,
                  ),
                );
              }
            : null,
      ),
    );
  }
}
