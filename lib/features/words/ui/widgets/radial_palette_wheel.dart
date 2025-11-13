import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scope_switch_button.dart';
import 'rotary_color_ring.dart';
import 'radial_palette_tools.dart';
import '../../application/palette_state.dart';
import '../../application/radial_palette_controller.dart' show radialPaletteProvider;

class RadialPaletteWheel extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);
    final hasActiveTool = palette.activeTool != null;

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
                  onPickColor(activeColor);
                },
                isInteractive: !hasActiveTool, // 🔹 nur ohne aktives Tool klickbar
              ),
            ),
          ),

          // Tools (7 Buttons oder aktive Tool-Fläche) - liegt OBEN, fängt Taps
          SizedBox(
            width: coreSize,
            height: coreSize,
            child: RadialTools(
              ringKey: ringKey,
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
                child: RotaryColorRing(
                  key: ringKey,
                  absoluteRadius: ringInnerRadius,
                  bubbleSize: bubbleSize,
                  count: 24,
                  onActiveColorChanged: onActiveColorChanged,
                  onPick: onPickColor,
                  ringLift: 0.0,
                  hitPadInner: 8.0,
                  hitPadOuter: 8.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
