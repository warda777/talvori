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
    required this.onChatTap,
    required this.onProfileTap,
    this.chatBadgeCount = 0,
  });

  final List<HomeSmartHubAction> actions;
  final VoidCallback onChatTap;
  final VoidCallback onProfileTap;
  final int chatBadgeCount;

  @override
  State<HomeSmartHubMenu> createState() => _HomeSmartHubMenuState();
}

class _HomeSmartHubMenuState extends State<HomeSmartHubMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Talvori Welt Hub',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: SizedBox(
          width: 370,
          height: 236,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              _FloatingActionFan(
                actions: widget.actions,
                animation: _controller,
                open: _open,
                onActionTap: _run,
              ),
              _HomeBottomHubBar(
                open: _open,
                chatBadgeCount: widget.chatBadgeCount,
                onChatTap: widget.onChatTap,
                onProfileTap: widget.onProfileTap,
                onHubTap: _toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingActionFan extends StatelessWidget {
  const _FloatingActionFan({
    required this.actions,
    required this.animation,
    required this.open,
    required this.onActionTap,
  });

  final List<HomeSmartHubAction> actions;
  final Animation<double> animation;
  final bool open;
  final ValueChanged<HomeSmartHubAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.take(4).toList(growable: false);
    const positions = [
      (left: 66.0, bottom: 116.0),
      (left: 136.0, bottom: 168.0),
      (left: 234.0, bottom: 168.0),
      (left: 304.0, bottom: 116.0),
    ];

    if (!open && animation.value == 0) {
      return const SizedBox(width: 370, height: 236);
    }

    return IgnorePointer(
      ignoring: !open,
      child: SizedBox(
        width: 370,
        height: 236,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = animation.value.clamp(0.0, 1.0);
            final curved = Curves.easeOutBack.transform(value);
            final fade = Curves.easeOut.transform(value);
            final iconSize = 66.0 * (0.46 + 0.54 * value);
            return Stack(
              key: const Key('home-smart-hub-tray'),
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < visibleActions.length; i++)
                  Positioned(
                    left: positions[i].left - 33,
                    bottom: positions[i].bottom,
                    child: Semantics(
                      button: true,
                      label: visibleActions[i].label,
                      child: GestureDetector(
                        key: visibleActions[i].key,
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onActionTap(visibleActions[i]),
                        child: SizedBox.square(
                          dimension: 66,
                          child: Align(
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: fade,
                              child: Transform.translate(
                                offset: Offset(
                                  (185 - positions[i].left) * (1 - curved),
                                  (positions[i].bottom - 50) * (1 - curved),
                                ),
                                child: _HubFloatingIcon(
                                  action: visibleActions[i],
                                  accent: _accentFor(visibleActions[i].label),
                                  size: iconSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Color _accentFor(String label) {
    if (label.contains('Satz')) return _violet;
    if (label.contains('Wörter')) return _mint;
    if (label.contains('Spiel')) return _gold;
    return Colors.white;
  }

  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);
  static const _gold = Color(0xFFFFC96B);
}

class _HubFloatingIcon extends StatelessWidget {
  const _HubFloatingIcon({
    required this.action,
    required this.accent,
    required this.size,
  });

  final HomeSmartHubAction action;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.26),
                  const Color(0xFF060A12).withValues(alpha: 0.98),
                ],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.58),
                width: 1.35,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.42),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.42),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(action.icon, color: Colors.white, size: size * 0.44),
          ),
          if (action.badgeCount > 0)
            Positioned(
              key: const Key('home-impuls-postfach-unread-badge'),
              right: -2,
              top: -3,
              child: _Badge(count: action.badgeCount),
            ),
        ],
      ),
    );
  }
}

class _HomeBottomHubBar extends StatelessWidget {
  const _HomeBottomHubBar({
    required this.open,
    required this.chatBadgeCount,
    required this.onChatTap,
    required this.onProfileTap,
    required this.onHubTap,
  });

  final bool open;
  final int chatBadgeCount;
  final VoidCallback onChatTap;
  final VoidCallback onProfileTap;
  final VoidCallback onHubTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _gold = Color(0xFFFFC96B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(360, 82),
              painter: _BottomBarShapePainter(open: open),
            ),
          ),
          Positioned(
            left: 68,
            bottom: 14,
            child: _BarIconButton(
              key: const Key('home-impuls-postfach-button'),
              icon: Icons.forum_rounded,
              semanticLabel: 'Freunde und Chat',
              badgeCount: chatBadgeCount,
              onTap: onChatTap,
            ),
          ),
          Positioned(
            right: 68,
            bottom: 14,
            child: _BarIconButton(
              key: const Key('home-profile-button'),
              icon: Icons.person_rounded,
              semanticLabel: 'Profil',
              onTap: onProfileTap,
            ),
          ),
          Positioned(
            bottom: 48,
            child: GestureDetector(
              key: const Key('home-smart-hub-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onHubTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: open
                        ? const [Color(0xFF202433), Color(0xFF090C14)]
                        : const [Color(0xFF46D9FF), Color(0xFF8A5CFF)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: open ? 0.2 : 0.46),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _cyan.withValues(alpha: open ? 0.18 : 0.38),
                      blurRadius: open ? 26 : 34,
                      spreadRadius: -8,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: _violet.withValues(alpha: 0.28),
                      blurRadius: 44,
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!open)
                      Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gold.withValues(alpha: 0.15),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.24),
                          ),
                        ),
                      ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutBack,
                      turns: open ? 1.125 : 0,
                      child: Icon(
                        open ? Icons.close_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: open ? 32 : 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 54,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.84), size: 30),
              if (badgeCount > 0)
                Positioned(
                  key: const Key('home-impuls-postfach-unread-badge'),
                  right: -2,
                  top: -3,
                  child: _Badge(count: badgeCount),
                ),
            ],
          ),
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

class _BottomBarShapePainter extends CustomPainter {
  const _BottomBarShapePainter({required this.open});

  final bool open;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 10, size.width, size.height - 10);
    final center = rect.center.dx;
    final path = Path()
      ..moveTo(rect.left + 34, rect.top)
      ..lineTo(center - 66, rect.top)
      ..cubicTo(
        center - 48,
        rect.top,
        center - 45,
        rect.top + 36,
        center - 20,
        rect.top + 42,
      )
      ..cubicTo(
        center,
        rect.top + 47,
        center + 20,
        rect.top + 42,
        center + 45,
        rect.top + 36,
      )
      ..cubicTo(
        center + 48,
        rect.top,
        center + 48,
        rect.top,
        center + 66,
        rect.top,
      )
      ..lineTo(rect.right - 34, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 34)
      ..lineTo(rect.right, rect.bottom - 30)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right - 34, rect.bottom)
      ..lineTo(rect.left + 34, rect.bottom)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - 30)
      ..lineTo(rect.left, rect.top + 34)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + 34, rect.top)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.52), 20, false);

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF07111B).withValues(alpha: 0.94),
            const Color(0xFF03060E).withValues(alpha: 0.97),
            const Color(0xFF0A0715).withValues(alpha: 0.94),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5DDCFF).withValues(alpha: open ? 0.42 : 0.3),
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFFB36BFF).withValues(alpha: open ? 0.42 : 0.3),
          ],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF5DDCFF).withValues(alpha: open ? 0.78 : 0.62),
            Colors.white.withValues(alpha: 0.16),
            const Color(0xFFB36BFF).withValues(alpha: open ? 0.78 : 0.62),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _BottomBarShapePainter oldDelegate) {
    return oldDelegate.open != open;
  }
}
