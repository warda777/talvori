import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/palette_controller.dart';
import '../../application/palette_state.dart';

enum RadialTool { stroke, glow, background, icons, scope, palette, image }

class RadialPaletteSheet extends ConsumerStatefulWidget {
  const RadialPaletteSheet({
    super.key,
    required this.onClose,
    required this.heroTag,
  });
  final VoidCallback onClose;
  final String heroTag;

  @override
  ConsumerState<RadialPaletteSheet> createState() => _RadialPaletteSheetState();
}

class _RadialPaletteSheetState extends ConsumerState<RadialPaletteSheet> {
  Color _activeColor = const Color(0xFFFFC66A);
  final GlobalKey<_RotaryColorRingState> _ringKey =
      GlobalKey<_RotaryColorRingState>();

  @override
  void initState() {
    super.initState();
    _activeColor = ref.read(paletteControllerProvider).selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ModalBarrier(
            color: Colors.black54,
            dismissible: true,
            onDismiss: widget.onClose,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Hero(
                tag: widget.heroTag,
                child: _WheelCore(
                  ringKey: _ringKey,
                  activeColor: _activeColor,
                  onActiveColorChanged: (c) => setState(() => _activeColor = c),
                  onPickColor: (c) {
                    final ctrl = ref.read(paletteControllerProvider.notifier);
                    ctrl.setSelectedColor(c);
                    if (ref.read(paletteControllerProvider).scope ==
                        ApplyScope.all) {
                      ctrl.dropOn();
                    }
                  },
                  onToggleScope: () => ref
                      .read(paletteControllerProvider.notifier)
                      .toggleScope(),
                  onSwitchPalette: () => _ringKey.currentState?.switchPalette(),
                  onClose: widget.onClose,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelCore extends StatelessWidget {
  const _WheelCore({
    required this.ringKey,
    required this.activeColor,
    required this.onActiveColorChanged,
    required this.onPickColor,
    required this.onToggleScope,
    required this.onSwitchPalette,
    required this.onClose,
  });

  final GlobalKey<_RotaryColorRingState> ringKey;
  final Color activeColor;
  final ValueChanged<Color> onActiveColorChanged;
  final ValueChanged<Color> onPickColor;
  final VoidCallback onToggleScope;
  final VoidCallback onSwitchPalette;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    const coreSize = 280.0;
    final coreRadius = coreSize / 2 - 1;
    const bubbleSize = 30.0;
    const gapOutside = 4.0;
    final ringRadius = coreRadius + gapOutside + bubbleSize / 2;

    return Container(
      width: coreSize,
      height: coreSize,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D),
        shape: BoxShape.circle,
        border: Border.all(color: activeColor.withOpacity(.85), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.55), blurRadius: 24),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: _RotaryColorRing(
              key: ringKey,
              absoluteRadius: ringRadius,
              bubbleSize: bubbleSize,
              count: 24,
              onActiveColorChanged: onActiveColorChanged,
              onPick: onPickColor,
            ),
          ),
          _RadialTools(
            radiusFactor: 0.35,
            onTap: (tool) {
              if (tool == RadialTool.scope) {
                onToggleScope();
              } else if (tool == RadialTool.palette) {
                onSwitchPalette();
              }
            },
          ),
          Center(
            child: SizedBox(
              width: 112,
              height: 112,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.color_lens_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: onSwitchPalette,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialTools extends StatelessWidget {
  const _RadialTools({
    required this.onTap,
    this.radiusFactor = 0.35,
  });

  final void Function(RadialTool tool) onTap;
  final double radiusFactor;

  final List<(RadialTool, IconData)> items = const [
    (RadialTool.stroke, Icons.border_style_rounded),
    (RadialTool.glow, Icons.waves_rounded),
    (RadialTool.background, Icons.layers_rounded),
    (RadialTool.icons, Icons.brush_rounded),
    (RadialTool.scope, Icons.groups_2_rounded),
    (RadialTool.palette, Icons.color_lens_rounded),
    (RadialTool.image, Icons.add_photo_alternate),
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
              child: _ToolButton(
                tool: items[i].$1,
                icon: items[i].$2,
                onTap: () => onTap(items[i].$1),
              ),
            ),
          );
        }

        return Stack(children: children);
      },
    );
  }
}

class _ToolButton extends ConsumerWidget {
  const _ToolButton({
    required this.tool,
    required this.icon,
    required this.onTap,
  });

  final RadialTool tool;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x151FFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(child: Icon(icon, color: Colors.white, size: 24)),
        ),
      ),
    );
  }
}

class _RotaryColorRing extends StatefulWidget {
  const _RotaryColorRing({
    super.key,
    required this.onPick,
    required this.onActiveColorChanged,
    this.count = 36,
    this.bubbleSize = 22,
    required this.absoluteRadius,
  });

  final ValueChanged<Color> onPick;
  final ValueChanged<Color> onActiveColorChanged;
  final int count;
  final double bubbleSize;
  final double absoluteRadius;

  @override
  State<_RotaryColorRing> createState() => _RotaryColorRingState();
}

class _RotaryColorRingState extends State<_RotaryColorRing>
    with SingleTickerProviderStateMixin {
  double _angle = 0.0;
  double _dragStartAngle = 0.0;
  late final AnimationController _momentum = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  Animation<double>? _fling;
  int? _selectedIndex;
  int _activeIndex = -1;
  double _hueShift = 0.0;

  List<Color> _vividDistinct(int n) => List<Color>.generate(n, (i) {
    final h = ((i + _hueShift) * 360 / n) % 360;
    return HSLColor.fromAHSL(1, h.toDouble(), 0.85, 0.50).toColor();
  });

  void switchPalette() {
    setState(() => _hueShift = (_hueShift + widget.count / 6) % widget.count);
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _vividDistinct(widget.count);
      final idx = (_activeIndex >= 0 && _activeIndex < colors.length)
          ? _activeIndex
          : 0;
      widget.onActiveColorChanged(colors[idx]);
    });
  }

  void _maybeTick(int idx, List<Color> colors) {
    if (idx != _activeIndex) {
      _activeIndex = idx;
      HapticFeedback.selectionClick();
      widget.onActiveColorChanged(colors[idx]);
    }
  }

  void _onPanStart(DragStartDetails d, Offset c) {
    _momentum.stop();
    _dragStartAngle =
        math.atan2(d.localPosition.dy - c.dy, d.localPosition.dx - c.dx) -
        _angle;
  }

  void _onPanUpdate(DragUpdateDetails d, Offset c) {
    setState(
      () => _angle =
          math.atan2(d.localPosition.dy - c.dy, d.localPosition.dx - c.dx) -
          _dragStartAngle,
    );
  }

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.distance.clamp(0, 2600) / 2600;
    if (v < 0.05) return;
    final start = _angle;
    _fling = Tween(begin: 0.0, end: v * 2 * math.pi).animate(
      CurvedAnimation(parent: _momentum, curve: Curves.decelerate),
    )..addListener(() => setState(() => _angle = start + _fling!.value));
    _momentum
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _momentum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _vividDistinct(widget.count);
    return LayoutBuilder(
      builder: (_, c) {
        final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
        final radius = widget.absoluteRadius;
        final base = widget.bubbleSize;
        const twelve = -math.pi / 2;

        int active = 0;
        double minDelta = double.infinity;
        final children = <Widget>[];

        children.add(
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (d) => _onPanStart(d, center),
              onPanUpdate: (d) => _onPanUpdate(d, center),
              onPanEnd: _onPanEnd,
              child: const SizedBox.expand(),
            ),
          ),
        );

        for (int i = 0; i < colors.length; i++) {
          final step = (2 * math.pi) / colors.length;
          final a = _angle + i * step;

          var delta = (a - twelve) % (2 * math.pi);
          if (delta > math.pi) delta -= 2 * math.pi;

          final absDelta = delta.abs();
          if (absDelta < minDelta) {
            minDelta = absDelta;
            active = i;
          }

          final near = (1.0 - (absDelta / step)).clamp(0, 1);
          final centerScale = 1.0 + 0.25 * near;
          final isSelected = _selectedIndex == i;
          final scale = isSelected ? 1.8 : centerScale;

          final pos = Offset(
            center.dx + radius * math.cos(a),
            center.dy + radius * math.sin(a),
          );
          final size = base * scale;

          children.add(
            Positioned(
              left: pos.dx - size / 2,
              top: pos.dy - size / 2,
              width: size,
              height: size,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  widget.onPick(colors[i]);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [colors[i], colors[i].withOpacity(.65)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors[i].withOpacity(.35),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _maybeTick(active, colors),
        );

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}
