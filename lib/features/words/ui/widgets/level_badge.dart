import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final String? level;
  final int? stage;

  const LevelBadge({
    super.key,
    this.level,
    this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final text = level ?? _mapStageToLevel(stage ?? 0);
    if (text.isEmpty) return const SizedBox.shrink();

    final color = _getLevelColor(text);
    final textColor = _getTextColor(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
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
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _mapStageToLevel(int s) {
    switch (s) {
      case 0: return 'A1';
      case 1: return 'A2';
      case 2: return 'B1';
      case 3: return 'B2';
      case 4: return 'C1';
      case 5: return 'C2';
      default: return '';
    }
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

  /// Bestimmt die optimale Schriftfarbe basierend auf der Hintergrundfarbe
  Color _getTextColor(Color backgroundColor) {
    // Berechne die relative Helligkeit der Hintergrundfarbe
    final luminance = backgroundColor.computeLuminance();
    
    // Wenn die Hintergrundfarbe hell ist (luminance > 0.5), verwende schwarze Schrift
    // Wenn die Hintergrundfarbe dunkel ist (luminance <= 0.5), verwende weiße Schrift
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
