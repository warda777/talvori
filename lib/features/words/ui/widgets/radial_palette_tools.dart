import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/radial_palette_controller.dart';
import 'rotary_color_ring.dart';

class RadialTools extends ConsumerWidget {
  const RadialTools({
    super.key,
    required this.ringKey,
    required this.discSize,
  });

  final GlobalKey<RotaryColorRingState> ringKey;
  final double discSize;

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
          : _buildActiveToolMode(context, palette, ctrl, ringKey, discSize),
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
    GlobalKey<RotaryColorRingState> ringKey,
    double discSize,
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

    return Center(
      child: SizedBox(
        width: discSize,
        height: discSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 🔹 Dünner Ring mit Kugel, der durch die Targets steppt
            _FocusSelectorRing(size: discSize),

            // 🔹 Mittleres Tool-Icon zum Abwählen
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ctrl.selectTool(tool), // Tool wieder schließen
              child: _RoundIcon(
                icon: icon,
                isActive: true,
                onTap: () => ctrl.selectTool(tool), // doppelt ist okay
                ringKey: ringKey,
              ),
            ),
          ],
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

class _FocusSelectorRing extends ConsumerStatefulWidget {
  const _FocusSelectorRing({
    super.key,
    required this.size,
  });

  // size: normalerweise die Größe deines Wheels (z. B. discSize)
  final double size;

  @override
  ConsumerState<_FocusSelectorRing> createState() => _FocusSelectorRingState();
}

class _FocusSelectorRingState extends ConsumerState<_FocusSelectorRing> {
  double? _dragAngle; // Winkel während des Drags (null = kein Drag)

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(radialPaletteProvider);
    final ctrl = ref.read(radialPaletteProvider.notifier);

    final total = state.targets.length;
    final effectiveTotal = total == 0 ? 12 : total; // 🔹 Fallback, damit sich die Kugel auch
                                                   //    ohne Targets schon sichtbar bewegt

    final ringRadius = widget.size / 2 - 80;

    // Während des Drags: verwende _dragAngle, sonst berechne aus Index
    double angle;
    if (_dragAngle != null) {
      angle = _dragAngle!;
    } else {
      final index = state.focusedIndex;
      final normalizedIndex = index % effectiveTotal;
      final angleStep = (2 * math.pi) / effectiveTotal;
      // Start: oben (–90°), im Uhrzeigersinn
      angle = -math.pi / 2 + angleStep * normalizedIndex;
    }

    final ballOffset = Offset(
      ringRadius * math.cos(angle),
      ringRadius * math.sin(angle),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        // Berechne Winkel basierend auf Startposition
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, box.size.height / 2);
        final offset = localPos - center;
        final distance = offset.distance;
        
        // Nur starten, wenn Finger nahe am Ring ist (Toleranz: ±30px)
        final minRadius = ringRadius - 30;
        final maxRadius = ringRadius + 30;
        if (distance < minRadius || distance > maxRadius) return;
        
        final startAngle = math.atan2(offset.dy, offset.dx);
        setState(() {
          _dragAngle = startAngle;
        });
      },
      onPanUpdate: (details) {
        // Nur updaten, wenn Drag bereits gestartet wurde
        if (_dragAngle == null) return;
        
        // Berechne Winkel basierend auf aktueller Fingerposition
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, box.size.height / 2);
        final offset = localPos - center;
        final currentAngle = math.atan2(offset.dy, offset.dx);
        setState(() {
          _dragAngle = currentAngle;
        });
      },
      onPanEnd: (details) {
        // Setze finalen Index basierend auf Winkel
        if (_dragAngle == null) return;
        
        final currentState = ref.read(radialPaletteProvider);
        final effectiveTotal = currentState.targets.isEmpty ? 12 : currentState.targets.length;
        final angleStep = (2 * math.pi) / effectiveTotal;
        
        // Normalisiere Winkel auf [0, 2*pi) und verschiebe um -90° (Start oben)
        var normalizedAngle = (_dragAngle! + math.pi / 2) % (2 * math.pi);
        if (normalizedAngle < 0) normalizedAngle += 2 * math.pi;
        
        // Berechne Index aus Winkel
        final newIndex = ((normalizedAngle / angleStep) % effectiveTotal).round();
        
        ref.read(radialPaletteProvider.notifier).moveFocusToIndex(newIndex);
        setState(() {
          _dragAngle = null;
        });
      },
      onPanCancel: () {
        setState(() {
          _dragAngle = null;
        });
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _FocusRingPainter(ringRadius: ringRadius),
          child: Center(
            child: Transform.translate(
              offset: ballOffset,
              child: Container(
                // 🔹 Kugel 4× so groß wie vorher (14 → 56)
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter({required this.ringRadius});

  final double ringRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.35);

    canvas.drawCircle(center, ringRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) =>
      oldDelegate.ringRadius != ringRadius;
}
