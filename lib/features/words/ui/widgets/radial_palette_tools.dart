import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/radial_palette_controller.dart';
import 'rotary_color_ring.dart';

class RadialTools extends ConsumerWidget {
  const RadialTools({
    super.key,
    required this.ringKey,
  });

  final GlobalKey<RotaryColorRingState> ringKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(radialPaletteProvider);
    final ctrl = ref.read(radialPaletteProvider.notifier);

    // NEU: RadialTools nimmt die ganze Fläche des Wheels ein
    return SizedBox.expand(
      child: palette.activeTool == null
          ? Stack(
              children: [
                _toolAtAngle(
                  context,
                  icon: Icons.border_all,
                  tool: PaletteTool.stroke,
                  angleDeg: -90,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.crop_square,
                  tool: PaletteTool.fill,
                  angleDeg: -38,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.text_fields,
                  tool: PaletteTool.text,
                  angleDeg: 14,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.layers,
                  tool: PaletteTool.hubBackground,
                  angleDeg: 66,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.brightness_5,
                  tool: PaletteTool.glow,
                  angleDeg: 118,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.star,
                  tool: PaletteTool.icon,
                  angleDeg: 170,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
                _toolAtAngle(
                  context,
                  icon: Icons.image,
                  tool: PaletteTool.image,
                  angleDeg: 222,
                  palette: palette,
                  ctrl: ctrl,
                  ringKey: ringKey,
                ),
              ],
            )
          : _buildActiveToolMode(context, palette, ctrl),
    );
  }

  Widget _toolAtAngle(
    BuildContext context, {
    required IconData icon,
    required PaletteTool tool,
    required double angleDeg,
    required RadialPaletteState palette,
    required RadialPaletteController ctrl,
    required GlobalKey<RotaryColorRingState> ringKey,
  }) {
    final rad = angleDeg * 3.1415926535 / 180;
    const r = 110.0;

    final offset = Offset(
      r * math.cos(rad),
      r * math.sin(rad),
    );

    return Align(
      alignment: Alignment.center, // 🔹 Basis ist die Mitte
      child: Transform.translate(
        offset: offset, // 🔹 von der Mitte weg verschieben
        child: _RoundIcon(
          icon: icon,
          isActive: palette.activeTool == tool,
          onTap: () => ctrl.selectTool(tool),
          ringKey: ringKey,
        ),
      ),
    );
  }

  Widget _buildActiveToolMode(
    BuildContext context,
    RadialPaletteState palette,
    RadialPaletteController ctrl,
  ) {
    final tool = palette.activeTool!;

    final icon = switch (tool) {
      PaletteTool.stroke => Icons.border_all,
      PaletteTool.fill => Icons.crop_square,
      PaletteTool.text => Icons.text_fields,
      PaletteTool.hubBackground => Icons.layers,
      PaletteTool.glow => Icons.brightness_5,
      PaletteTool.icon => Icons.star,
      PaletteTool.image => Icons.image,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ctrl.selectTool(tool), // 🔹 Tool wieder ausschalten
      onVerticalDragUpdate: (details) {
        final d = details.primaryDelta;
        if (d == null || d.abs() < 4) return;
        ctrl.moveFocus(d > 0 ? 1 : -1);
      },
      child: IgnorePointer(
        ignoring: false,
        child: Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: IgnorePointer(
                ignoring: true, // 🔹 _RoundIcon blockiert keine Taps mehr
                child: _RoundIcon(
                  icon: icon,
                  isActive: true,
                  onTap: () => ctrl.selectTool(tool), // Wird nicht mehr aufgerufen
                  ringKey: ringKey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.ringKey,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final GlobalKey<RotaryColorRingState>? ringKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanStart: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanStart(d)
          : null,
      onPanUpdate: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanUpdate(d)
          : null,
      onPanEnd: ringKey != null
          ? (d) => ringKey!.currentState?.handleExternalPanEnd(d)
          : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          radius: 28,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isActive ? const Color(0x33FFFFFF) : const Color(0x151FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.white70 : Colors.white24,
                width: isActive ? 1.6 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      const BoxShadow(
                        color: Colors.white24,
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(child: Icon(icon, color: Colors.white, size: 24)),
            ),
          ),
        ),
      ),
    );
  }
}
