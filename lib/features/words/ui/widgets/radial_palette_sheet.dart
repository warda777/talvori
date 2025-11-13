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
    // WICHTIG:
    // coreSize bleibt 280 -> Center + Tool-Buttons bleiben exakt wie jetzt
    const double coreSize = 280.0;

    // Tool-Buttons sind bei radiusFactor 0.35
    // → Radius der Button-Mitte ~ 98, mit 28er Radius → 70–126 px
    const double toolsRadiusFactor = 0.35;

    // NEU: große schwarze Scheibe (deutlich größer als 280)
    const double discRadius = 180.0; // 360 px Durchmesser
    const double discSize = discRadius * 2;

    // NEU: Farbring außerhalb der Tool-Buttons, aber noch im Rad
    // Tool-Buttons gehen bis ~126px, also Ring z.B. 135–169px
    const double ringInnerRadius = 135.0;
    const double trapezDepth = 34.0;

    // etwas Extra-Platz für den Ring-Widget-Rahmen
    const double overshoot = 24.0;
    const double bubbleSize = 30.0;

    return SizedBox(
      width: discSize,   // Groß genug für die Scheibe
      height: discSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // GROßE SCHWARZE SCHEIBE (nur visuell)
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

          // TOOL-BUTTONS -> in coreSize-Container für ursprüngliche Position
          SizedBox(
            width: coreSize,
            height: coreSize,
            child: Consumer(
              builder: (context, ref, _) {
                final active = ref.watch(
                  paletteControllerProvider.select((s) => s.target),
                );
                return _RadialTools(
                  ringKey: ringKey,
                  radiusFactor: toolsRadiusFactor,
                  activeTarget: active,
                  onTap: (tool, target) {
                    if (tool == RadialTool.scope) {
                      onToggleScope();
                    } else if (tool == RadialTool.palette) {
                      onSwitchPalette();
                    } else if (target != null) {
                      ref
                          .read(paletteControllerProvider.notifier)
                          .setTarget(target);
                    }
                  },
                );
              },
            ),
          ),

          // MITTLERER BUTTON -> unverändert
          Center(
            child: ScopeSwitchButton(
              diameter: 112,
              ringColor: activeColor,
              isAll: isAll,
              onTapToggle: onCenterToggleScope,
              onConfirmHold: onCenterReset,
            ),
          ),

          // FARB-RING: komplett im Rad, mit Luft zu den Tool-Buttons
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: discSize + overshoot * 2,
              height: discSize + overshoot * 2,
              child: _RotaryColorRing(
                key: ringKey,
                absoluteRadius: ringInnerRadius, // <- Start-Radius des Rings
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
      behavior: HitTestBehavior.deferToChild, // Nur Events im eigenen Bereich abfangen
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
    required this.activeTarget,
    this.radiusFactor = 0.35,
  });

  final GlobalKey<_RotaryColorRingState> ringKey;
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

class _RotaryColorRing extends StatefulWidget {
  const _RotaryColorRing({
    super.key,
    required this.onPick,
    required this.onActiveColorChanged,
    this.count = 36,
    this.bubbleSize = 22,
    required this.absoluteRadius,
    this.ringLift = 0.0,
    this.hitPadInner = 0.0,
    this.hitPadOuter = 0.0,
  });

  final ValueChanged<Color> onPick;
  final ValueChanged<Color> onActiveColorChanged;
  final int count;
  final double bubbleSize;
  final double absoluteRadius;
  final double ringLift;
  final double hitPadInner;
  final double hitPadOuter;

  @override
  State<_RotaryColorRing> createState() => _RotaryColorRingState();
}

class _RotaryColorRingState extends State<_RotaryColorRing>
    with SingleTickerProviderStateMixin {
  double _angle = 0.0;
  double _dragStartAngle = 0.0;
  Offset _center = Offset.zero;

  int _paletteIndex = 0;
  double _hueShift = 0.0;
  int _activeIndex = -1;
  int? _selectedIndex;

  bool _picking = false;
  Color? _dragColor;
  Offset? _dragPos;

  final GlobalKey _stackKey = GlobalKey();

  late final AnimationController _momentum;
  Animation<double>? _fling;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _paletteColors(widget.count);
      final idx = (_activeIndex >= 0 && _activeIndex < colors.length)
          ? _activeIndex
          : 0;
      widget.onActiveColorChanged(colors[idx]);
    });
    HapticFeedback.selectionClick();
  }

  void _maybeTick(int idx, List<Color> colors) {
    if (idx != _activeIndex) {
      _activeIndex = idx;
      widget.onActiveColorChanged(colors[idx]);
      HapticFeedback.selectionClick();
    }
  }

  // ---------- Rotation ----------

  void _onPanStart(DragStartDetails d) {
    _momentum.stop();
    _dragStartAngle = math.atan2(
          d.localPosition.dy - _center.dy,
          d.localPosition.dx - _center.dx,
        ) -
        _angle;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _angle = math.atan2(
            d.localPosition.dy - _center.dy,
            d.localPosition.dx - _center.dx,
          ) -
          _dragStartAngle;
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.distance.clamp(0, 2600) / 2600;
    if (v < 0.05) return;
    final start = _angle;
    _fling = Tween(begin: 0.0, end: v * 2 * math.pi).animate(
      CurvedAnimation(parent: _momentum, curve: Curves.decelerate),
    )..addListener(() {
        if (!mounted) return;
        setState(() => _angle = start + _fling!.value);
      });
    _momentum
      ..reset()
      ..forward();
  }

  // Von außen drehbar (Buttons geben Pan weiter)

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

  // ---------- Tap → Farbkeil ----------

  int _indexAt(Offset p, {required Offset center, required double step}) {
    // Winkel des Taps
    final ang = math.atan2(p.dy - center.dy, p.dx - center.dx);

    // Keil i wird mit baseAngle = _angle + i * step gezeichnet und
    // deckt [baseAngle - step/2, baseAngle + step/2] ab.
    // → um step/2 verschieben, damit floor() exakt in die Mitte fällt.
    var rel = ang - _angle + step / 2;
    rel = rel % (2 * math.pi);
    if (rel < 0) rel += 2 * math.pi;

    final idx = (rel / step).floor() % widget.count;
    return idx;
  }

  @override
  void dispose() {
    _momentum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _paletteColors(widget.count);

    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final size = math.min(w, h);

        // Lokales Zentrum des Rings
        final center = Offset(w / 2, h / 2);
        _center = center;

        const double trapezDepth = 34.0;

        // 👉 Ring-Geometrie aus widget.absoluteRadius
        final double innerR = widget.absoluteRadius;
        final double outerR = innerR + trapezDepth;

        final step = (2 * math.pi) / colors.length;

        final children = <Widget>[];

        // Keile mit GestureDetector pro Keil (Rotation + Bubble)
        for (int i = 0; i < colors.length; i++) {
          final adjustedAngle = _angle + i * step;
          final angleWidth = step;

          children.add(
            Positioned.fill(
              child: ClipPath(
                clipper: _WedgeClipper(
                  baseAngle: adjustedAngle,
                  angleWidth: angleWidth,
                  innerR: innerR,
                  outerR: outerR,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,

                  // Tap -> Bubble erscheint sofort
                  onTapDown: (d) {
                    if (_picking && _selectedIndex != i) return;

                    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final localPos = box.globalToLocal(d.globalPosition);

                    setState(() {
                      _picking = true;
                      _selectedIndex = i;
                      _dragColor = colors[i];
                      _dragPos = localPos;
                    });
                    widget.onPick(colors[i]);
                    HapticFeedback.lightImpact();
                  },

                  // Start der Geste: entweder Bubble-Drag ODER Rotation
                  onPanStart: (d) {
                    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final localPos = box.globalToLocal(d.globalPosition);

                    if (_picking && _selectedIndex == i) {
                      // bereits am Picken -> sofort Bubble bewegen können
                      setState(() {
                        _dragPos = localPos;
                      });
                      return;
                    }

                    // noch nicht im Pick-Modus -> Ring drehen
                    _onPanStart(
                      DragStartDetails(
                        globalPosition: d.globalPosition,
                        localPosition: localPos,
                        kind: d.kind,
                      ),
                    );
                  },

                  onPanUpdate: (d) {
                    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final localPos = box.globalToLocal(d.globalPosition);

                    if (_picking && _selectedIndex == i) {
                      // Bubble folgt dem Finger
                      setState(() {
                        _dragPos = localPos;
                      });
                    } else {
                      // Ring drehen
                      _onPanUpdate(
                        DragUpdateDetails(
                          globalPosition: d.globalPosition,
                          localPosition: localPos,
                          delta: d.delta,
                          primaryDelta: d.primaryDelta,
                          sourceTimeStamp: d.sourceTimeStamp,
                        ),
                      );
                    }
                  },

                  onPanEnd: (d) {
                    if (_picking && _selectedIndex == i) {
                      // Pick-Geste fertig -> Bubble weg
                      setState(() {
                        _picking = false;
                        _dragColor = null;
                        _dragPos = null;
                      });
                    } else {
                      // Rotation mit Momentum beenden
                      _onPanEnd(d);
                    }
                  },

                  onPanCancel: () {
                    if (_picking && _selectedIndex == i) {
                      setState(() {
                        _picking = false;
                        _dragColor = null;
                        _dragPos = null;
                      });
                    }
                  },
                  child: CustomPaint(
                    painter: _WedgePainter(
                      baseAngle: adjustedAngle,
                      angleWidth: angleWidth,
                      innerR: innerR,
                      outerR: outerR,
                      color: colors[i],
                      shadow: 10,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // 3) aktiven Keil bestimmen (bei 12 Uhr) → Tick/Haptik beim Drehen
        // NUR wenn nicht am Picken, damit die ausgewählte Farbe nicht geändert wird
        if (!_picking) {
          const twelve = -math.pi / 2;
          int active = 0;
          double minDelta = double.infinity;
          for (int i = 0; i < colors.length; i++) {
            final a = _angle + i * step;
            var delta = (a - twelve) % (2 * math.pi);
            if (delta > math.pi) delta -= 2 * math.pi;
            final d = delta.abs();
            if (d < minDelta) {
              minDelta = d;
              active = i;
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybeTick(active, colors);
          });
        }

        // 4) Bubble vor dem Finger anzeigen
        if (_dragColor != null && _dragPos != null) {
          final v = (_dragPos! - center);
          final len = v.distance == 0 ? 1.0 : v.distance;
          final dir = v / len;
          const ahead = 50.0;
          final p = _dragPos! + dir * ahead;

          children.add(
            Positioned(
              left: p.dx - 18,
              top: p.dy - 18,
              width: 36,
              height: 36,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _dragColor!,
                        _dragColor!.withOpacity(.65),
                      ],
                    ),
                    border: Border.all(color: Colors.white70, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: _dragColor!.withOpacity(.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: children,
        );
      },
    );
  }
}

class _ColorWedge extends StatelessWidget {
  const _ColorWedge({
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
    required this.color,
    this.shadow = 8,
  });

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
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
    required this.color,
    required this.shadow,
  });

  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;
  final Color color;
  final double shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2); // ← lokale Mitte
    final a0 = baseAngle - angleWidth / 2;
    final a1 = baseAngle + angleWidth / 2;

    final rectInner = Rect.fromCircle(center: c, radius: innerR);
    final rectOuter = Rect.fromCircle(center: c, radius: outerR);

    final path = Path()
      ..moveTo(c.dx + innerR * math.cos(a0), c.dy + innerR * math.sin(a0))
      ..arcTo(rectInner, a0, angleWidth, false)
      ..lineTo(c.dx + outerR * math.cos(a1), c.dy + outerR * math.sin(a1))
      ..arcTo(rectOuter, a1, -angleWidth, false)
      ..close();

    if (shadow > 0) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow);
      canvas.drawPath(path, shadowPaint);
    }

    final paint = Paint()
      ..color = color
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
      old.color != color;
}

class _TrapezHitAreaPainter extends CustomPainter {
  _TrapezHitAreaPainter({
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
  });

  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;
  Size _size = Size.zero;

  @override
  void paint(Canvas canvas, Size size) {
    _size = size; // Speichere size für hitTest()
  }

  @override
  bool hitTest(Offset position, {required bool isPointerDown}) {
    final c = Offset(_size.width / 2, _size.height / 2); // ← lokale Mitte
    final dist = (position - c).distance;
    if (dist < innerR || dist > outerR) return false;

    final ang = math.atan2(position.dy - c.dy, position.dx - c.dx);
    var diff = (ang - baseAngle) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    return diff.abs() <= angleWidth / 2;
  }

  @override
  bool shouldRepaint(covariant _TrapezHitAreaPainter old) =>
      old.baseAngle != baseAngle ||
      old.angleWidth != angleWidth ||
      old.innerR != innerR ||
      old.outerR != outerR;
}

class _WedgeClipper extends CustomClipper<Path> {
  _WedgeClipper({
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
  });

  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final a0 = baseAngle - angleWidth / 2;
    final a1 = baseAngle + angleWidth / 2;

    final rectInner = Rect.fromCircle(center: center, radius: innerR);
    final rectOuter = Rect.fromCircle(center: center, radius: outerR);

    final p0 = center + Offset(innerR * math.cos(a0), innerR * math.sin(a0));
    final p2 = center + Offset(outerR * math.cos(a1), outerR * math.sin(a1));

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..arcTo(rectInner, a0, angleWidth, false)
      ..lineTo(p2.dx, p2.dy)
      ..arcTo(rectOuter, a1, -angleWidth, false)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_WedgeClipper old) =>
      old.baseAngle != baseAngle ||
      old.angleWidth != angleWidth ||
      old.innerR != innerR ||
      old.outerR != outerR;
}

class _AnnulusClipper extends CustomClipper<Path> {
  _AnnulusClipper({required this.innerR, required this.outerR});

  final double innerR;
  final double outerR;

  @override
  Path getClip(Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outer = Path()..addOval(Rect.fromCircle(center: c, radius: outerR));
    final inner = Path()..addOval(Rect.fromCircle(center: c, radius: innerR));
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(covariant _AnnulusClipper old) =>
      old.innerR != innerR || old.outerR != outerR;
}
