import 'package:flutter/material.dart';

class HomeSmartHubAction {
  const HomeSmartHubAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badgeCount = 0,
  });

  final Key key;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;
}

class HomeSmartHubMenu extends StatefulWidget {
  const HomeSmartHubMenu({super.key, required this.actions});

  final List<HomeSmartHubAction> actions;

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
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IgnorePointer(
              ignoring: !_open,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                ),
                child: Transform.scale(
                  scale: _open ? 1 : 0.96,
                  alignment: Alignment.bottomCenter,
                  child: _HubActionTray(
                    actions: widget.actions,
                    onActionTap: _run,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _HubButton(open: _open, onTap: _toggle),
          ],
        ),
      ),
    );
  }
}

class _HubActionTray extends StatelessWidget {
  const _HubActionTray({required this.actions, required this.onActionTap});

  final List<HomeSmartHubAction> actions;
  final ValueChanged<HomeSmartHubAction> onActionTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-smart-hub-tray'),
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF050B14).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _cyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: _violet.withValues(alpha: 0.14),
            blurRadius: 36,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final action in actions)
            _HubActionPill(
              action: action,
              onTap: () => onActionTap(action),
              accent: _accentFor(action.label),
            ),
        ],
      ),
    );
  }

  static Color _accentFor(String label) {
    if (label.contains('Satz')) return _violet;
    if (label.contains('Welt')) return _cyan;
    if (label.contains('Wörter')) return _mint;
    return Colors.white;
  }
}

class _HubActionPill extends StatelessWidget {
  const _HubActionPill({
    required this.action,
    required this.onTap,
    required this.accent,
  });

  final HomeSmartHubAction action;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: action.key,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46, maxWidth: 190),
          padding: const EdgeInsets.fromLTRB(11, 7, 13, 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.15),
                      border: Border.all(color: accent.withValues(alpha: 0.32)),
                    ),
                    child: Icon(action.icon, color: Colors.white, size: 17),
                  ),
                  if (action.badgeCount > 0)
                    Positioned(
                      key: const Key('home-impuls-postfach-unread-badge'),
                      right: -3,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5F7A),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF050B14),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          action.badgeCount > 9
                              ? '9+'
                              : action.badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubButton extends StatelessWidget {
  const _HubButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _gold = Color(0xFFFFC96B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('home-smart-hub-button'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 74,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: open
                ? const [Color(0xFF26305E), Color(0xFF12203A)]
                : const [Color(0xFF46D9FF), Color(0xFF7668FF)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: open ? 0.18 : 0.34),
          ),
          boxShadow: [
            BoxShadow(
              color: _cyan.withValues(alpha: open ? 0.18 : 0.34),
              blurRadius: open ? 24 : 32,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _violet.withValues(alpha: 0.24),
              blurRadius: 42,
              spreadRadius: -14,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!open)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(alpha: 0.16),
                  border: Border.all(color: _gold.withValues(alpha: 0.24)),
                ),
              ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 220),
              turns: open ? 0.125 : 0,
              child: Icon(
                open ? Icons.close_rounded : Icons.add_rounded,
                color: Colors.white,
                size: open ? 28 : 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
