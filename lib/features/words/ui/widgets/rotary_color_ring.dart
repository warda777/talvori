import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RotaryColorRing extends StatefulWidget {
  const RotaryColorRing({
    super.key,
    required this.onPick,
    required this.onActiveColorChanged,
    this.onPickEnd,
    this.count = 36,
    this.bubbleSize = 22,
    required this.absoluteRadius,
    this.ringLift = 0.0,
    this.hitPadInner = 0.0,
    this.hitPadOuter = 0.0,
  });

  final ValueChanged<Color> onPick;
  final ValueChanged<Color> onActiveColorChanged;
  final VoidCallback? onPickEnd;
  final int count;
  final double bubbleSize;
  final double absoluteRadius;
  final double ringLift;
  final double hitPadInner;
  final double hitPadOuter;

  @override
  State<RotaryColorRing> createState() => RotaryColorRingState();
}

class RotaryColorRingState extends State<RotaryColorRing>
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
      })> _paletteModes = [
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
    final ang = math.atan2(p.dy - center.dy, p.dx - center.dx);

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

        final center =
            Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        _center = center;

        const double trapezDepth = 34.0;

        final double innerR = widget.absoluteRadius;
        final double outerR = innerR + trapezDepth;

        // Wie weit die Drehzone nach innen in Richtung Tool-Buttons reichen soll.
        // 20–30 px ist ein guter Startwert.
        const double grabBandWidth = 24.0;

        // Hit-Zone beginnt weiter innen als der sichtbare Ring:
        final double hitInnerR = (innerR - grabBandWidth).clamp(0.0, innerR);
        final double hitOuterR = outerR;

        final step = (2 * math.pi) / colors.length;

        final children = <Widget>[];

        for (int i = 0; i < colors.length; i++) {
          final adjustedAngle = _angle + i * step;
          final angleWidth = step;

          children.add(
            Positioned.fill(
              child: ClipPath(
                clipper: _WedgeClipper(
                  baseAngle: adjustedAngle,
                  angleWidth: angleWidth,
                  innerR: hitInnerR,
                  outerR: hitOuterR,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    if (_picking && _selectedIndex != i) return;

                    final box = _stackKey.currentContext?.findRenderObject()
                        as RenderBox?;
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
                  onPanStart: (d) {
                    final box = _stackKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return;
                    final localPos = box.globalToLocal(d.globalPosition);

                    if (_picking && _selectedIndex == i) {
                      setState(() {
                        _dragPos = localPos;
                      });
                      return;
                    }

                    _onPanStart(
                      DragStartDetails(
                        globalPosition: d.globalPosition,
                        localPosition: localPos,
                        kind: d.kind,
                      ),
                    );
                  },
                  onPanUpdate: (d) {
                    final box = _stackKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return;
                    final localPos = box.globalToLocal(d.globalPosition);

                    if (_picking && _selectedIndex == i) {
                      setState(() {
                        _dragPos = localPos;
                      });
                    } else {
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
                      setState(() {
                        _picking = false;
                        _dragColor = null;
                        _dragPos = null;
                      });
                      // 🔴 Callback für Pick-Ende (Finger losgelassen)
                      widget.onPickEnd?.call();
                    } else {
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
                      // 🔴 Callback für Pick-Ende (auch bei Cancel)
                      widget.onPickEnd?.call();
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
    final c = Offset(size.width / 2, size.height / 2);
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
