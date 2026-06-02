import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeSmartHubAction {
  const HomeSmartHubAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final Key key;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;
}

class HomeSmartHubMenu extends StatefulWidget {
  const HomeSmartHubMenu({
    super.key,
    required this.actions,
    this.chatBadgeCount = 0,
  });

  final List<HomeSmartHubAction> actions;
  final int chatBadgeCount;

  @override
  State<HomeSmartHubMenu> createState() => _HomeSmartHubMenuState();
}

class _HomeSmartHubMenuState extends State<HomeSmartHubMenu>
    with SingleTickerProviderStateMixin {
  static const _wheelHeight = 290.0;
  static const _wheelCenterY = 246.0;
  static const _wheelRadius = 144.0;

  late final AnimationController _controller;
  double _rotation = math.pi;
  double? _lastPanAngle;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _run(HomeSmartHubAction action) {
    if (_open) {
      setState(() => _open = false);
      _controller.reverse();
    }
    action.onTap();
  }

  double _angleFromCenter(Offset position, Offset center) {
    final delta = position - center;
    return math.atan2(delta.dy, delta.dx);
  }

  double _normalizeAngleDelta(double value) {
    var delta = value;
    while (delta > math.pi) {
      delta -= math.pi * 2;
    }
    while (delta < -math.pi) {
      delta += math.pi * 2;
    }
    return delta;
  }

  void _startWheelRotation(DragStartDetails details, Offset center) {
    if (!_open) return;
    _lastPanAngle = _angleFromCenter(details.localPosition, center);
  }

  void _rotateWheel(DragUpdateDetails details, Offset center) {
    if (!_open) return;
    final nextAngle = _angleFromCenter(details.localPosition, center);
    final previousAngle = _lastPanAngle ?? nextAngle;
    final delta = _normalizeAngleDelta(nextAngle - previousAngle);
    setState(() {
      _rotation += delta;
    });
    _lastPanAngle = nextAngle;
  }

  void _endWheelRotation() {
    _lastPanAngle = null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final wheelWidth = MediaQuery.sizeOf(context).width;
    final wheelCenter = Offset(wheelWidth / 2, _wheelCenterY);
    return Semantics(
      label: 'Talvori Welt Hub',
      child: Padding(
        padding: EdgeInsets.only(bottom: math.max(0, bottomInset * 0.12)),
        child: SizedBox(
          width: wheelWidth,
          height: _wheelHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) => _startWheelRotation(details, wheelCenter),
            onPanUpdate: (details) => _rotateWheel(details, wheelCenter),
            onPanCancel: _endWheelRotation,
            onPanEnd: (_) => _endWheelRotation(),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                _RotatingActionWheel(
                  actions: widget.actions,
                  animation: _controller,
                  width: wheelWidth,
                  height: _wheelHeight,
                  center: wheelCenter,
                  radius: _wheelRadius,
                  rotation: _rotation,
                  open: _open,
                  onActionTap: _run,
                ),
                Positioned(
                  left: wheelCenter.dx - 43,
                  top: wheelCenter.dy - 43,
                  child: _HubCenterButton(open: _open, onTap: _toggle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RotatingActionWheel extends StatelessWidget {
  const _RotatingActionWheel({
    required this.actions,
    required this.animation,
    required this.width,
    required this.height,
    required this.center,
    required this.radius,
    required this.rotation,
    required this.open,
    required this.onActionTap,
  });

  final List<HomeSmartHubAction> actions;
  final Animation<double> animation;
  final double width;
  final double height;
  final Offset center;
  final double radius;
  final double rotation;
  final bool open;
  final ValueChanged<HomeSmartHubAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.take(8).toList(growable: false);
    if (!open && animation.value == 0) {
      return SizedBox(width: width, height: height);
    }

    return IgnorePointer(
      ignoring: !open,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = animation.value.clamp(0.0, 1.0);
            final fly = Curves.easeOutBack.transform(value);
            final fade = Curves.easeOutCubic.transform(value);
            final baseSize = 66.0;
            return Stack(
              key: const Key('home-smart-hub-tray'),
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < visibleActions.length; i++)
                  _WheelActionButton(
                    action: visibleActions[i],
                    accent: _accentFor(i, visibleActions[i].label),
                    center: center,
                    angle:
                        rotation + ((math.pi * 2) / visibleActions.length) * i,
                    radius: radius,
                    fly: fly,
                    fade: fade,
                    size: baseSize,
                    onTap: () => onActionTap(visibleActions[i]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Color _accentFor(int index, String label) {
    if (label.contains('Satz')) return const Color(0xFFB36BFF);
    if (label.contains('Stat')) return const Color(0xFF5DDCFF);
    if (label.contains('Welt')) return const Color(0xFF5DDCFF);
    if (label.contains('Profil')) return const Color(0xFFB36BFF);
    if (label.contains('Spiel')) return const Color(0xFFB36BFF);
    return index.isEven ? const Color(0xFF5DDCFF) : const Color(0xFFB36BFF);
  }
}

class _WheelActionButton extends StatelessWidget {
  const _WheelActionButton({
    required this.action,
    required this.accent,
    required this.center,
    required this.angle,
    required this.radius,
    required this.fly,
    required this.fade,
    required this.size,
    required this.onTap,
  });

  final HomeSmartHubAction action;
  final Color accent;
  final Offset center;
  final double angle;
  final double radius;
  final double fly;
  final double fade;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final target = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    final position = Offset.lerp(center, target, fly)!;
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: Opacity(
        opacity: fade,
        child: Semantics(
          button: true,
          label: action.label,
          child: GestureDetector(
            key: action.key,
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox.square(
              dimension: size,
              child: _WheelIconShell(
                action: action,
                accent: accent,
                size: size * (0.72 + 0.28 * fly),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelIconShell extends StatelessWidget {
  const _WheelIconShell({
    required this.action,
    required this.accent,
    required this.size,
  });

  final HomeSmartHubAction action;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.24),
                    const Color(0xFF080B14).withValues(alpha: 0.96),
                    const Color(0xFF03050A).withValues(alpha: 0.99),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.68),
                  width: 1.35,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.56),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  action.icon,
                  color: Colors.white,
                  size: size * 0.43,
                ),
              ),
            ),
            if (action.badgeCount > 0)
              Positioned(
                key: const Key('home-impuls-postfach-unread-badge'),
                right: -1,
                top: -2,
                child: _Badge(count: action.badgeCount),
              ),
          ],
        ),
      ),
    );
  }
}

class _HubCenterButton extends StatelessWidget {
  const _HubCenterButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('home-smart-hub-button'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 86,
        height: 86,
        padding: const EdgeInsets.all(2.2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            startAngle: -math.pi * 0.85,
            endAngle: math.pi * 1.15,
            colors: [
              _cyan,
              _cyan.withValues(alpha: open ? 0.62 : 0.78),
              open
                  ? _violet.withValues(alpha: 0.96)
                  : _violet.withValues(alpha: 0.78),
              _violet,
              _violet.withValues(alpha: open ? 0.94 : 0.82),
              _cyan,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _cyan.withValues(alpha: open ? 0.32 : 0.34),
              blurRadius: open ? 34 : 30,
              spreadRadius: open ? -7 : -8,
              offset: const Offset(-10, 7),
            ),
            BoxShadow(
              color: _violet.withValues(alpha: open ? 0.44 : 0.3),
              blurRadius: open ? 44 : 36,
              spreadRadius: open ? -7 : -9,
              offset: const Offset(10, 8),
            ),
            BoxShadow(
              color: _violet.withValues(alpha: open ? 0.32 : 0.24),
              blurRadius: open ? 62 : 54,
              spreadRadius: open ? -18 : -20,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: open
                  ? const Alignment(0.24, -0.18)
                  : const Alignment(-0.2, -0.25),
              radius: 0.9,
              colors: [
                open ? const Color(0xFF111125) : const Color(0xFF131A29),
                open ? const Color(0xFF060817) : const Color(0xFF070B15),
                const Color(0xFF02040A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.62),
                blurRadius: 24,
                spreadRadius: -10,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 560),
              curve: Curves.easeOutCubic,
              turns: open ? 1.125 : 0,
              child: const _GradientHubGlyph(),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientHubGlyph extends StatelessWidget {
  const _GradientHubGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _GradientHubGlyphBar(angle: 0),
          _GradientHubGlyphBar(angle: math.pi / 2),
        ],
      ),
    );
  }
}

class _GradientHubGlyphBar extends StatelessWidget {
  const _GradientHubGlyphBar({required this.angle});

  final double angle;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 38,
        height: 4.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(colors: [_cyan, _violet]),
          boxShadow: [
            BoxShadow(
              color: _cyan.withValues(alpha: 0.34),
              blurRadius: 11,
              spreadRadius: -2,
              offset: const Offset(-4, 0),
            ),
            BoxShadow(
              color: _violet.withValues(alpha: 0.34),
              blurRadius: 11,
              spreadRadius: -2,
              offset: const Offset(4, 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5F7A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF050B14), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
