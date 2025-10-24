import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final String? level;

  const LevelBadge({
    super.key,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    if (level == null || level!.isEmpty) return const SizedBox.shrink();

    final levelText = level!.toUpperCase();
    final levelColor = _getLevelColor(level!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: levelColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        levelText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return Colors.red.shade600;
      case 'A2':
        return Colors.orange.shade600;
      case 'B1':
        return Colors.yellow.shade600;
      case 'B2':
        return Colors.green.shade600;
      case 'C1':
        return Colors.blue.shade600;
      case 'C2':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
