import 'package:flutter/material.dart';

class LocalWorldResourceBar extends StatelessWidget {
  const LocalWorldResourceBar({super.key});

  static const resources = [
    _LocalWorldResource(
      key: Key('local-world-resource-coins'),
      icon: Icons.toll_rounded,
      label: 'coins',
      value: '120',
      accent: Color(0xFF5DDCFF),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-wood'),
      icon: Icons.forest_rounded,
      label: 'wood',
      value: '38',
      accent: Color(0xFF9FF7D5),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-stone'),
      icon: Icons.terrain_rounded,
      label: 'stone',
      value: '24',
      accent: Color(0xFFB36BFF),
    ),
    _LocalWorldResource(
      key: Key('local-world-resource-knowledge-points'),
      icon: Icons.auto_stories_rounded,
      label: 'knowledgePoints',
      value: '7',
      accent: Color(0xFFE7F7FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('local-world-resource-bar'),
      spacing: 8,
      runSpacing: 8,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      key: resource.key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF07101A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resource.accent.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: resource.accent.withValues(alpha: 0.1),
            blurRadius: 14,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resource.icon, size: 15, color: resource.accent),
          const SizedBox(width: 6),
          Text(
            resource.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            resource.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
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
