import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // für HapticFeedback
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
  double? _dragAngle; // aktueller, kontinuierlicher Winkel des Balls

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(radialPaletteProvider.notifier);
    final state = ref.watch(radialPaletteProvider);

    final visible = ctrl.visibleTargets;
    final total = visible.isNotEmpty ? visible.length : 12;

    // sichtbarer Index (nicht globaler Index!)
    final visibleIndex = ctrl.currentVisibleIndex.clamp(0, total - 1);

    final angleStep = (2 * math.pi) / total;

    // Wenn gerade gezogen wird, verwenden wir _dragAngle (smooth),
    // sonst den gesnappten Winkel des aktuellen Fokus.
    final angle = _dragAngle ??
        (-math.pi / 2 + angleStep * visibleIndex); // Start oben (-90°)

    final ringRadius = widget.size / 2 - 80;

    final ballOffset = Offset(
      ringRadius * math.cos(angle),
      ringRadius * math.sin(angle),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        _updateFromPosition(context, details.globalPosition, total, ctrl);
      },
      onPanUpdate: (details) {
        _updateFromPosition(context, details.globalPosition, total, ctrl);
      },
      onPanEnd: (_) {
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

  void _updateFromPosition(
    BuildContext context,
    Offset globalPos,
    int total,
    RadialPaletteController ctrl,
  ) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(globalPos);
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final offset = local - center;

    final ringRadius = widget.size / 2 - 80;
    final distance = offset.distance;
    final minRadius = ringRadius - 40;
    final maxRadius = ringRadius + 40;

    // nur reagieren, wenn Finger in der Nähe des Rings ist
    if (distance < minRadius || distance > maxRadius) return;

    // Winkel berechnen (–PI..PI)
    var angle = math.atan2(offset.dy, offset.dx);

    setState(() {
      _dragAngle = angle; // Ball folgt dem Finger SMOOTH
    });

    // jetzt auf [0, 2*PI) normalisieren und "oben" als Start definieren
    angle += math.pi / 2;
    angle = angle % (2 * math.pi);
    if (angle < 0) angle += 2 * math.pi;

    final angleStep = (2 * math.pi) / total;
    final visibleIndex = (angle / angleStep).round().clamp(0, total - 1);

    ctrl.moveFocusToVisibleIndex(visibleIndex);
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

class RadialDebugBanner extends ConsumerWidget {
  const RadialDebugBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radialPaletteProvider);

    final toolLabel = switch (state.activeTool) {
      PaletteTool.stroke => 'Rahmen',
      PaletteTool.fill => 'Kachel-Hintergrund',
      PaletteTool.text => 'Text',
      PaletteTool.hubBackground => 'WordHub-Background',
      PaletteTool.glow => 'Glow',
      PaletteTool.icon => 'Icon',
      PaletteTool.image => 'Bild',
      null => 'kein Tool aktiv',
    };

    final total = state.targets.length;
    final index = state.focusedIndex.clamp(0, total == 0 ? 0 : total - 1);

    return Positioned(
      left: 16,
      bottom: 16,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Tool: $toolLabel\nFokus: $index / ${total == 0 ? 0 : total - 1}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
