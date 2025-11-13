import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'rotary_color_ring.dart';
import '../../application/palette_state.dart';

enum RadialTool { stroke, glow, background, icons, scope, palette, image }

class RadialTools extends StatelessWidget {
  const RadialTools({
    super.key,
    required this.ringKey,
    required this.onTap,
    required this.activeTarget,
    this.radiusFactor = 0.35,
  });

  final GlobalKey<RotaryColorRingState> ringKey;
  final void Function(RadialTool tool, PaletteTarget? target) onTap;
  final double radiusFactor;
  final PaletteTarget activeTarget;

  final List<(RadialTool, IconData, PaletteTarget?)> items = const [
    (RadialTool.stroke, Icons.border_style_rounded, PaletteTarget.stroke),
    (RadialTool.glow, Icons.waves_rounded, PaletteTarget.glow),
    (RadialTool.background, Icons.layers_rounded, PaletteTarget.tileBg),
    (RadialTool.icons, Icons.brush_rounded, PaletteTarget.icons),
    (RadialTool.scope, Icons.groups_2_rounded, null),
    (RadialTool.palette, Icons.color_lens_rounded, null),
    (RadialTool.image, Icons.add_photo_alternate, PaletteTarget.image),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final minSize = math.min(c.maxWidth, c.maxHeight);
        final r = minSize * radiusFactor;
        final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
        final angleStep = (2 * math.pi) / items.length;

        final children = <Widget>[];

        for (int i = 0; i < items.length; i++) {
          final angle = i * angleStep - math.pi / 2;
          final posBtn = Offset(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          );

          children.add(
            Positioned(
              left: posBtn.dx - 28,
              top: posBtn.dy - 28,
              width: 56,
              height: 56,
              child: _ToolHitCircle(
                onTap: () => onTap(items[i].$1, items[i].$3),
                onPanStart: (d) =>
                    ringKey.currentState?.handleExternalPanStart(d),
                onPanUpdate: (d) =>
                    ringKey.currentState?.handleExternalPanUpdate(d),
                onPanEnd: (d) => ringKey.currentState?.handleExternalPanEnd(d),
                child: _ToolButton(
                  icon: items[i].$2,
                  active: items[i].$3 != null && items[i].$3 == activeTarget,
                ),
              ),
            ),
          );
        }

        return Stack(children: children);
      },
    );
  }
}

class _ToolHitCircle extends StatelessWidget {
  const _ToolHitCircle({
    required this.child,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final Widget child;
  final VoidCallback onTap;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          radius: 28,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? const Color(0x33FFFFFF) : const Color(0x151FFFFFF),
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? Colors.white70 : Colors.white24,
          width: active ? 1.6 : 1.0,
        ),
        boxShadow: active
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
    );
  }
}
