import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scope_switch_button.dart';
import 'rotary_color_ring.dart';
import 'radial_palette_tools.dart';
import 'curved_tool_label.dart';
import '../../application/palette_state.dart';
import '../../application/radial_palette_controller.dart' show radialPaletteProvider, PaletteTool;

class RadialPaletteWheel extends ConsumerStatefulWidget {
  const RadialPaletteWheel({
    super.key,
    required this.ringKey,
    required this.activeColor,
    required this.activeTarget,
    required this.isAll,
    required this.onActiveColorChanged,
    required this.onPickColor,
    required this.onToggleScope,
    required this.onSwitchPalette,
    required this.onCenterToggleScope,
    required this.onCenterReset,
    required this.onTargetSelected,
    this.onToolReset,
    this.onToolResetStart,
    this.onToolResetEnd,
    this.onResetAll, // NEU: Callback für kompletten Reset
    this.onResetAllStart, // NEU: Callback für Reset-Start
    this.onResetAllEnd, // NEU: Callback für Reset-Ende
  });

  final GlobalKey<RotaryColorRingState> ringKey;
  final Color activeColor;
  final PaletteTarget activeTarget;
  final bool isAll;

  final ValueChanged<Color> onActiveColorChanged;
  final ValueChanged<Color> onPickColor;
  final VoidCallback onToggleScope;
  final VoidCallback onSwitchPalette;
  final VoidCallback onCenterToggleScope;
  final VoidCallback onCenterReset;
  final ValueChanged<PaletteTarget> onTargetSelected;
  final ValueChanged<PaletteTool>? onToolReset;
  final void Function(VoidCallback)? onToolResetStart; // Callback erhält onComplete-Funktion
  final VoidCallback? onToolResetEnd;
  final VoidCallback? onResetAll; // NEU: Callback für kompletten Reset
  final VoidCallback? onResetAllStart; // NEU: Callback für Reset-Start
  final VoidCallback? onResetAllEnd; // NEU: Callback für Reset-Ende

  @override
  ConsumerState<RadialPaletteWheel> createState() => _RadialPaletteWheelState();
}

class _RadialPaletteWheelState extends ConsumerState<RadialPaletteWheel> {
  final ScopeSwitchButtonController _toolResetController = ScopeSwitchButtonController();

  void handleToolResetStart(VoidCallback onComplete) {
    _toolResetController.startResetAnimation(onComplete);
    widget.onToolResetStart?.call(onComplete);
  }

  void handleToolResetEnd() {
    _toolResetController.endResetAnimation();
    widget.onToolResetEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(radialPaletteProvider);
    final hasActiveTool = palette.activeTool != null;
    final activeColor = widget.activeColor;

    const double coreSize = 280.0;
    const double toolsRadiusFactor = 0.35;

    const double discRadius = 180.0;
    const double discSize = discRadius * 2;

    const double trapezDepth = 34.0;
    const double ringInnerRadius = discRadius - trapezDepth;

    const double overshoot = 24.0;
    const double bubbleSize = 30.0;

    return SizedBox(
      width: discSize,
      height: discSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // große schwarze Scheibe
          Container(
            width: discSize,
            height: discSize,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0B0D),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.55),
                  blurRadius: 24,
                ),
              ],
            ),
          ),

          // Center-Button (vor RadialTools, damit RadialTools darüber liegt)
          IgnorePointer(
            ignoring: hasActiveTool, // 🔹 bei aktivem Tool keine Hit-Tests
            child: Center(
              child: ScopeSwitchButton(
                size: 112,
                ringColor: activeColor,
                onConfirmColor: () {
                  widget.onPickColor(activeColor);
                },
                isInteractive: !hasActiveTool, // 🔹 nur ohne aktives Tool klickbar
                toolResetController: _toolResetController,
                onResetAll: widget.onResetAll, // NEU: Callback für kompletten Reset
                onResetAllStart: widget.onResetAllStart, // NEU: Callback für Reset-Start
                onResetAllEnd: widget.onResetAllEnd, // NEU: Callback für Reset-Ende
              ),
            ),
          ),

          // Tools (7 Buttons oder aktive Tool-Fläche) - liegt OBEN, fängt Taps
          SizedBox(
            width: coreSize,
            height: coreSize,
            child: RadialTools(
              ringKey: widget.ringKey,
              discSize: discSize,
              onPickColor: widget.onPickColor,
              activeColor: activeColor,
              onToolReset: widget.onToolReset,
              onToolResetStart: handleToolResetStart,
              onToolResetEnd: handleToolResetEnd,
            ),
          ),

          // Farbring
          Align(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: SizedBox(
                width: discSize + overshoot * 2,
                height: discSize + overshoot * 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotaryColorRing(
                      key: widget.ringKey,
                      absoluteRadius: ringInnerRadius,
                      bubbleSize: bubbleSize,
                      count: 24,
                      isLocked: palette.isBallLocked, // 🔴 Nur picken wenn gelockt
                      customColor: palette.isCustomPaletteActive && palette.activeCustomBallIndex != null
                          ? palette.customColors[palette.activeCustomBallIndex]
                          : null, // Custom-Farbe für Verlauf nur wenn aktiv
                      selectedIcon: palette.selectedIcon, // Ausgewähltes Icon
                      selectedEmoji: palette.selectedEmoji, // Ausgewähltes Emoji
                      onActiveColorChanged: widget.onActiveColorChanged,
                      onPick: (color) {
                        final ctrl = ref.read(radialPaletteProvider.notifier);
                        
                        // 🔴 Kugel einfärben, solange gelockt
                        ctrl.setBallColor(color);

                        // Farbe auf aktuelles/gelocktes Target anwenden
                        ctrl.applyColorToCurrentTarget(color);
                        
                        // 🔴 Lock sofort lösen nach Farbauswahl
                        ctrl.releaseLockAfterColorPick();
                      },
                      onPickEnd: () {
                        final ctrl = ref.read(radialPaletteProvider.notifier);
                        // 🔴 Finger losgelassen → Lock lösen
                        ctrl.releaseLockAfterColorPick();
                      },
                      onPickIcon: (icon) {
                        final ctrl = ref.read(radialPaletteProvider.notifier);
                        // Icon auf aktuelles/gelocktes Target anwenden
                        ctrl.applyIconToCurrentTarget(icon);
                        // 🔴 Lock lösen nach Icon-Anwendung
                        ctrl.releaseLockAfterColorPick();
                      },
                      onPickEmoji: (emoji) {
                        final ctrl = ref.read(radialPaletteProvider.notifier);
                        // Emoji auf aktuelles/gelocktes Target anwenden
                        ctrl.applyEmojiToCurrentTarget(emoji);
                        // 🔴 Lock lösen nach Emoji-Anwendung
                        ctrl.releaseLockAfterColorPick();
                      },
                      onClearIconEmoji: () {
                        final ctrl = ref.read(radialPaletteProvider.notifier);
                        // Icons/Emojis vom aktuellen/gelockten Target löschen
                        ctrl.clearIconEmojiFromCurrentTarget();
                      },
                      ringLift: 0.0,
                      hitPadInner: 8.0,
                      hitPadOuter: 8.0,
                    ),
                    // 🔴 Gebogener Tool-Label in der schwarzen Scheibe zwischen Farbring und Focus-Ring
                    if (palette.activeTool != null)
                      IgnorePointer(
                        child: CurvedToolLabel(
                          size: discSize + overshoot * 2,
                          // Radius zwischen Farbring-Außenrand und Focus-Ring
                          // Farbring endet bei: discRadius = 180
                          // Focus-Ring ist bei: discSize/2 - 80 = 180 - 80 = 100
                          // Text-Position: näher zum Focus-Ring (30% vom Focus-Ring entfernt statt 50%)
                          radius: (discSize / 2 - 80) + ((discRadius - (discSize / 2 - 80)) * 0.3),
                          tool: palette.activeTool,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
