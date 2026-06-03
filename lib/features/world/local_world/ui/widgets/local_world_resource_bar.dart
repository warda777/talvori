import 'dart:async';

import 'package:flutter/material.dart';

class LocalWorldResourceBar extends StatelessWidget {
  const LocalWorldResourceBar({super.key});

  static const resources = [
    _LocalWorldResource(
      key: Key('local-world-resource-coins'),
      icon: Icons.toll_rounded,
      label: 'Münzen',
      value: '120',
      accent: Color(0xFF5DDCFF),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-wood'),
      icon: Icons.forest_rounded,
      label: 'Holz',
      value: '38',
      accent: Color(0xFF9FF7D5),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-stone'),
      icon: Icons.terrain_rounded,
      label: 'Stein',
      value: '24',
      accent: Color(0xFFB36BFF),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-knowledge-points'),
      icon: Icons.auto_stories_rounded,
      label: 'Wissen',
      value: '7',
      accent: Color(0xFFE7F7FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('local-world-resource-bar'),
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        for (final resource in resources) _ResourceChip(resource: resource),
      ],
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({required this.resource});

  final _LocalWorldResource resource;
  static OverlayEntry? _activeHint;
  static Timer? _activeHintTimer;

  @override
  Widget build(BuildContext context) {
    final link = LayerLink();
    return CompositedTransformTarget(
      link: link,
      child: Semantics(
        label: '${resource.label}: ${resource.value}',
        button: true,
        child: GestureDetector(
          key: resource.key,
          onTap: () => _showResourceLabel(context, link),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF07101A).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: resource.accent.withValues(alpha: 0.34),
              ),
              boxShadow: [
                BoxShadow(
                  color: resource.accent.withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(resource.icon, size: 15, color: resource.accent),
                const SizedBox(width: 5),
                Text(
                  resource.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResourceLabel(BuildContext context, LayerLink link) {
    _activeHintTimer?.cancel();
    _activeHint?.remove();

    _activeHint = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 8),
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: 1,
              child: _ResourceHint(resource: resource),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_activeHint!);
    _activeHintTimer = Timer(const Duration(milliseconds: 1300), () {
      _activeHint?.remove();
      _activeHint = null;
      _activeHintTimer = null;
    });
  }
}

class _ResourceHint extends StatelessWidget {
  const _ResourceHint({required this.resource});

  final _LocalWorldResource resource;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        key: const Key('local-world-resource-inline-hint'),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF07101A).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: resource.accent.withValues(alpha: 0.42)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.36),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: resource.accent.withValues(alpha: 0.16),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Text(
          resource.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationThickness: 0,
          ),
        ),
      ),
    );
  }
}

class _LocalWorldResource {
  const _LocalWorldResource({
    required this.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final Key key;
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
}
