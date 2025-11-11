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
                  onCenterToggleScope: () => ref
                      .read(paletteControllerProvider.notifier)
                      .toggleScope(),
                  onCenterReset: () => ref
                      .read(paletteControllerProvider.notifier)
                      .resetToDefaults(),
                  isAll:
                      ref.watch(
                        paletteControllerProvider.select((s) => s.scope),
                      ) ==
                      ApplyScope.all,
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
    required this.onCenterToggleScope,
    required this.onCenterReset,
    required this.isAll,
  });

  final GlobalKey<_RotaryColorRingState> ringKey;
  final Color activeColor;
  final ValueChanged<Color> onActiveColorChanged;
  final ValueChanged<Color> onPickColor;
  final VoidCallback onToggleScope;
  final VoidCallback onSwitchPalette;
  final VoidCallback onClose;
  final VoidCallback onCenterToggleScope;
  final VoidCallback onCenterReset;
  final bool isAll;

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
        border: Border.all(color: Colors.white12, width: 1.4),
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
            ringKey: ringKey,
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
            child: ScopeSwitchButton(
              diameter: 112,
              ringColor: activeColor,
              isAll: isAll,
              onTapToggle: onCenterToggleScope,
              onConfirmHold: onCenterReset,
            ),
          ),
        ],
      ),
    );
  }
}

class ScopeSwitchButton extends StatefulWidget {
  const ScopeSwitchButton({
    super.key,
    required this.diameter,
    required this.ringColor,
    required this.isAll,
    required this.onTapToggle,
    required this.onConfirmHold,
    this.holdDuration = const Duration(milliseconds: 2500),
  });

  final double diameter;
  final Color ringColor;
  final bool isAll;
  final VoidCallback onTapToggle;
  final VoidCallback onConfirmHold;
  final Duration holdDuration;

  @override
  State<ScopeSwitchButton> createState() => _ScopeSwitchButtonState();
}

class _ScopeSwitchButtonState extends State<ScopeSwitchButton>
    with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  );
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  bool _holding = false;
  double _angleTurns = 0.0;

  @override
  void dispose() {
    _hold.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _startHold(LongPressStartDetails _) {
    _holding = true;
    _hold.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  Future<void> _endHold([_]) async {
    if (!_holding) return;
    _holding = false;
    if (_hold.status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      widget.onConfirmHold();
    } else {
      await _hold.reverse();
    }
  }

  Future<void> _tap() async {
    if (_holding) return;
    HapticFeedback.selectionClick();
    _angleTurns += 0.25;
    await _spin.forward(from: 0);
    widget.onTapToggle();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final arrowIcon = widget.isAll
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: _tap,
      onLongPressStart: _startHold,
      onLongPressUp: _endHold,
      onLongPressEnd: _endHold,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: widget.ringColor.withOpacity(.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(
            width: d,
            height: d,
            child: AnimatedBuilder(
              animation: _hold,
              builder: (_, __) => CustomPaint(
                painter: _RingPainter(
                  progress: _hold.value,
                  color: widget.ringColor,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _spin,
            builder: (_, __) {
              final t = CurvedAnimation(
                parent: _spin,
                curve: Curves.easeOutCubic,
              ).value;
              return Transform.rotate(
                angle: (_angleTurns * 2 * math.pi) * t,
                child: SizedBox(
                  width: d * 0.70,
                  height: d * 0.70,
                  child: CustomPaint(
                    painter: _SpinnerPainter(color: widget.ringColor),
                  ),
                ),
              );
            },
          ),
          Container(
            width: d * 0.58,
            height: d * 0.58,
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              widget.isAll
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: Colors.white,
              size: d * 0.28,
            ),
          ),
          Positioned(
            top: 10,
            child: Text(
              'ALL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Text(
              'ONE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 3;
    final c = Offset(size.width / 2, size.height / 2);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white12;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(.95);

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white10;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = color.withOpacity(.95);

    const sweep = 2 * math.pi * 0.33;
    const start = -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter old) => old.color != color;
}

class _RadialTools extends StatelessWidget {
  const _RadialTools({
    required this.ringKey,
    required this.onTap,
    this.radiusFactor = 0.35,
  });

  final GlobalKey<_RotaryColorRingState> ringKey;
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
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (d) =>
                    ringKey.currentState?.handleExternalPanStart(d),
                onPanUpdate: (d) =>
                    ringKey.currentState?.handleExternalPanUpdate(d),
                onPanEnd: (d) => ringKey.currentState?.handleExternalPanEnd(d),
                onTap: () => onTap(items[i].$1),
                child: _ToolButton(icon: items[i].$2),
              ),
            ),
          );
        }

        return Stack(children: children);
      },
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
  Offset _center = Offset.zero;
  int _paletteIndex = 0;
  late final AnimationController _momentum;
  Animation<double>? _fling;
  int? _selectedIndex;
  int _activeIndex = -1;
  double _hueShift = 0.0;

  @override
  void initState() {
    super.initState();
    _momentum = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  static const List<
    ({
      double saturation,
      double lightness,
      double satJitter,
      double lightJitter,
      double hueOffset,
    })
  >
  _paletteModes = [
    (
      saturation: .92,
      lightness: .52,
      satJitter: .06,
      lightJitter: .05,
      hueOffset: 0,
    ),
    (
      saturation: .72,
      lightness: .66,
      satJitter: .04,
      lightJitter: .08,
      hueOffset: 10,
    ),
    (
      saturation: .64,
      lightness: .44,
      satJitter: .05,
      lightJitter: .06,
      hueOffset: 18,
    ),
    (
      saturation: .48,
      lightness: .76,
      satJitter: .05,
      lightJitter: .07,
      hueOffset: 28,
    ),
  ];

  List<Color> _paletteColors(int n) {
    final mode = _paletteModes[_paletteIndex % _paletteModes.length];
    return List<Color>.generate(n, (i) {
      final t = i / n;
      final hue = ((i + _hueShift + mode.hueOffset) * 360 / n) % 360;
      final sat = (mode.saturation + mode.satJitter * math.sin(t * 2 * math.pi))
          .clamp(0.05, 1.0);
      final light =
          (mode.lightness + mode.lightJitter * math.cos(t * 2 * math.pi)).clamp(
            0.05,
            0.95,
          );
      return HSLColor.fromAHSL(1, hue.toDouble(), sat, light).toColor();
    });
  }

  void switchPalette() {
    setState(() {
      _paletteIndex = (_paletteIndex + 1) % _paletteModes.length;
      _hueShift = (_hueShift + widget.count / 4) % widget.count;
      _selectedIndex = null;
    });
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _paletteColors(widget.count);
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

  void _onPanStart(DragStartDetails d) {
    _momentum.stop();
    _dragStartAngle =
        math.atan2(
          d.localPosition.dy - _center.dy,
          d.localPosition.dx - _center.dx,
        ) -
        _angle;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(
      () => _angle =
          math.atan2(
            d.localPosition.dy - _center.dy,
            d.localPosition.dx - _center.dx,
          ) -
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

  void handleExternalPanStart(DragStartDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    _onPanStart(
      DragStartDetails(
        globalPosition: d.globalPosition,
        localPosition: local,
        kind: d.kind,
      ),
    );
  }

  void handleExternalPanUpdate(DragUpdateDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    _onPanUpdate(
      DragUpdateDetails(
        globalPosition: d.globalPosition,
        localPosition: local,
        delta: d.delta,
        primaryDelta: d.primaryDelta,
        sourceTimeStamp: d.sourceTimeStamp,
      ),
    );
  }

  void handleExternalPanEnd(DragEndDetails d) => _onPanEnd(d);

  @override
  void dispose() {
    _momentum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _paletteColors(widget.count);
    return LayoutBuilder(
      builder: (_, c) {
        final center = Offset(c.maxWidth / 2, c.maxHeight / 2);
        _center = center;
        final radius = widget.absoluteRadius;
        final base = widget.bubbleSize;
        final children = <Widget>[];

        children.add(
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: const SizedBox.expand(),
            ),
          ),
        );

        final trapezDepth = 34.0;
        final gapDeg = 2.0;
        final gapRad = gapDeg * math.pi / 180;
        final step = (2 * math.pi) / colors.length;
        const twelve = -math.pi / 2;

        // Finde das Segment, das sich bei 12 Uhr befindet (aktives Segment)
        int active = 0;
        double minDelta = double.infinity;
        for (int i = 0; i < colors.length; i++) {
          final a = _angle + i * step;
          var delta = (a - twelve) % (2 * math.pi);
          if (delta > math.pi) delta -= 2 * math.pi;
          final absDelta = delta.abs();
          if (absDelta < minDelta) {
            minDelta = absDelta;
            active = i;
          }
        }

        // Segmente sollen außerhalb des inneren Bereichs (Tool Buttons) liegen
        // Näher zum Kreis hin, aber immer noch außerhalb
        final baseInnerR = radius - 15.0;
        final baseOuterR = radius - 15.0 + trapezDepth;

        for (int i = 0; i < colors.length; i++) {
          final a = _angle + i * step;
          final isActive = active == i;
          final isSelected = _selectedIndex == i;

          // Aktives Segment (bei 12 Uhr) hat Vorrang: größer und mit Lücke
          final gapSize = isActive ? gapRad : 0.0;
          final lift = isActive ? 15.0 : (isSelected ? 20.0 : 0.0);

          final innerR = baseInnerR;
          final outerR = baseOuterR + lift;
          final angleWidth = step - gapSize;

          children.add(
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: _ColorWedge(
                  center: center,
                  baseAngle: a,
                  angleWidth: angleWidth,
                  innerR: innerR,
                  outerR: outerR,
                  color: colors[i],
                  shadow: 10,
                ),
              ),
            ),
          );

          final hitR = baseInnerR + trapezDepth / 2;
          final hitPos = Offset(
            center.dx + hitR * math.cos(a),
            center.dy + hitR * math.sin(a),
          );
          children.add(
            Positioned(
              left: hitPos.dx - 24,
              top: hitPos.dy - 24,
              width: 48,
              height: 48,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  widget.onPick(colors[i]);
                },
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
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

class _ColorWedge extends StatelessWidget {
  const _ColorWedge({
    required this.center,
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
    required this.color,
    this.shadow = 8,
  });

  final Offset center;
  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;
  final Color color;
  final double shadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WedgePainter(
        center: center,
        baseAngle: baseAngle,
        angleWidth: angleWidth,
        innerR: innerR,
        outerR: outerR,
        color: color,
        shadow: shadow,
      ),
    );
  }
}

class _WedgePainter extends CustomPainter {
  _WedgePainter({
    required this.center,
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
    required this.color,
    required this.shadow,
  });

  final Offset center;
  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;
  final Color color;
  final double shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final a0 = baseAngle - angleWidth / 2;
    final a1 = baseAngle + angleWidth / 2;

    final rectInner = Rect.fromCircle(center: center, radius: innerR);
    final rectOuter = Rect.fromCircle(center: center, radius: outerR);

    final p0 = center + Offset(innerR * math.cos(a0), innerR * math.sin(a0));
    final p1 = center + Offset(outerR * math.cos(a0), outerR * math.sin(a0));
    final p2 = center + Offset(outerR * math.cos(a1), outerR * math.sin(a1));
    final p3 = center + Offset(innerR * math.cos(a1), innerR * math.sin(a1));

    path.moveTo(p0.dx, p0.dy);
    path.arcTo(rectInner, a0, angleWidth, false);
    path.lineTo(p2.dx, p2.dy);
    path.arcTo(rectOuter, a1, -angleWidth, false);
    path.close();

    if (shadow > 0) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow);
      canvas.drawPath(path, shadowPaint);
    }

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(.75)],
      ).createShader(Rect.fromCircle(center: center, radius: outerR))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final stroke = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _WedgePainter old) =>
      old.baseAngle != baseAngle ||
      old.angleWidth != angleWidth ||
      old.innerR != innerR ||
      old.outerR != outerR ||
      old.color != color ||
      old.center != center;
}
