import 'package:flutter/material.dart';

class HomeOrbitAction {
  const HomeOrbitAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
}

class HomeOrbitActionSelector extends StatefulWidget {
  const HomeOrbitActionSelector({
    super.key,
    required this.actions,
    this.compact = false,
  });

  final List<HomeOrbitAction> actions;
  final bool compact;

  @override
  State<HomeOrbitActionSelector> createState() =>
      _HomeOrbitActionSelectorState();
}

class _HomeOrbitActionSelectorState extends State<HomeOrbitActionSelector> {
  int _selectedIndex = 0;

  void _selectPrevious() {
    setState(() {
      _selectedIndex =
          (_selectedIndex - 1 + widget.actions.length) % widget.actions.length;
    });
  }

  void _selectNext() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % widget.actions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions;
    final selected = actions[_selectedIndex];

    return Semantics(
      label: 'Talvori Welt Aktionen',
      child: GestureDetector(
        key: const Key('home-orbit-action-selector'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -80) {
            _selectNext();
          } else if (velocity > 80) {
            _selectPrevious();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OrbitSelectedAction(
              action: selected,
              compact: widget.compact,
              onPrevious: _selectPrevious,
              onNext: _selectNext,
            ),
            SizedBox(height: widget.compact ? 8 : 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < actions.length; i++)
                  _OrbitActionDot(
                    action: actions[i],
                    selected: i == _selectedIndex,
                    onTap: () {
                      setState(() => _selectedIndex = i);
                      actions[i].onTap();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitSelectedAction extends StatelessWidget {
  const _OrbitSelectedAction({
    required this.action,
    required this.compact,
    required this.onPrevious,
    required this.onNext,
  });

  final HomeOrbitAction action;
  final bool compact;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 82 : 92),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cyan.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.13),
            blurRadius: 28,
            spreadRadius: -8,
          ),
          BoxShadow(
            color: _violet.withValues(alpha: 0.12),
            blurRadius: 36,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('home-orbit-selected-action'),
          borderRadius: BorderRadius.circular(24),
          onTap: action.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 9 : 12,
            ),
            child: Row(
              children: [
                _OrbitArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: onPrevious,
                ),
                const SizedBox(width: 4),
                Container(
                  width: compact ? 42 : 48,
                  height: compact ? 42 : 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _mint.withValues(alpha: 0.42),
                        _cyan.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(color: _mint.withValues(alpha: 0.42)),
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 23),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        action.subtitle,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.64),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _OrbitArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: onNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitArrowButton extends StatelessWidget {
  const _OrbitArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 42),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white.withValues(alpha: 0.72), size: 24),
    );
  }
}

class _OrbitActionDot extends StatelessWidget {
  const _OrbitActionDot({
    required this.action,
    required this.selected,
    required this.onTap,
  });

  final HomeOrbitAction action;
  final bool selected;
  final VoidCallback onTap;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: action.label,
        child: GestureDetector(
          key: action.key,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: selected ? 40 : 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? _cyan.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: selected
                    ? _cyan.withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _violet.withValues(alpha: 0.22),
                        blurRadius: 18,
                        spreadRadius: -6,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              action.icon,
              size: selected ? 18 : 16,
              color: Colors.white.withValues(alpha: selected ? 0.94 : 0.58),
            ),
          ),
        ),
      ),
    );
  }
}
