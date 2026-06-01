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
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: SizedBox(
          width: 330,
          height: 220,
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
      (left: 36.0, bottom: 98.0),
      (left: 112.0, bottom: 130.0),
      (left: 188.0, bottom: 130.0),
      (left: 264.0, bottom: 98.0),
    ];

    if (!open && animation.value == 0) {
      return const SizedBox(width: 330, height: 220);
    }

    return IgnorePointer(
      ignoring: !open,
      child: SizedBox(
        width: 330,
        height: 220,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final curved = open
                ? 1.0
                : Curves.easeOutCubic.transform(animation.value);
            final fade = open ? 1.0 : Curves.easeOut.transform(animation.value);
            return Stack(
              key: const Key('home-smart-hub-tray'),
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < visibleActions.length; i++)
                  Positioned(
                    left: 165 + (positions[i].left - 165) * curved - 27,
                    bottom: 42 + (positions[i].bottom - 42) * curved,
                    child: Opacity(
                      opacity: fade,
                      child: Transform.scale(
                        scale: 0.72 + 0.28 * curved,
                        child: _HubFloatingIcon(
                          action: visibleActions[i],
                          accent: _accentFor(visibleActions[i].label),
                          onTap: () => onActionTap(visibleActions[i]),
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
    required this.onTap,
    required this.accent,
  });

  final HomeSmartHubAction action;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        key: action.key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 54,
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
                    color: accent.withValues(alpha: 0.48),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: accent.withValues(alpha: 0.32),
                      blurRadius: 20,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(action.icon, color: Colors.white, size: 23),
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
        ),
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
      width: 326,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(326, 76),
            painter: _BottomBarShapePainter(open: open),
          ),
          Positioned(
            left: 46,
            bottom: 21,
            child: _BarIconButton(
              key: const Key('home-impuls-postfach-button'),
              icon: Icons.forum_rounded,
              semanticLabel: 'Freunde und Chat',
              badgeCount: chatBadgeCount,
              onTap: onChatTap,
            ),
          ),
          Positioned(
            right: 46,
            bottom: 21,
            child: _BarIconButton(
              key: const Key('home-profile-button'),
              icon: Icons.person_rounded,
              semanticLabel: 'Profil',
              onTap: onProfileTap,
            ),
          ),
          Positioned(
            bottom: 21,
            child: GestureDetector(
              key: const Key('home-smart-hub-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onHubTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: 66,
                height: 66,
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
                      offset: const Offset(0, 12),
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
                        size: open ? 29 : 34,
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
          dimension: 46,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.82),
                  size: 23,
                ),
              ),
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
    final rect = Rect.fromLTWH(0, 8, size.width, size.height - 8);
    final path = Path()
      ..moveTo(rect.left + 34, rect.top)
      ..lineTo(rect.center.dx - 54, rect.top)
      ..cubicTo(
        rect.center.dx - 33,
        rect.top,
        rect.center.dx - 35,
        rect.top + 32,
        rect.center.dx,
        rect.top + 32,
      )
      ..cubicTo(
        rect.center.dx + 35,
        rect.top + 32,
        rect.center.dx + 33,
        rect.top,
        rect.center.dx + 54,
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

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF050812).withValues(alpha: 0.92)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            const Color(0xFF5DDCFF).withValues(alpha: open ? 0.32 : 0.18),
            Colors.white.withValues(alpha: 0.1),
          ],
        ).createShader(rect),
    );
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.42), 18, false);
  }

  @override
  bool shouldRepaint(covariant _BottomBarShapePainter oldDelegate) {
    return oldDelegate.open != open;
  }
}
