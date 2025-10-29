import 'package:flutter/material.dart';

/// Auswahl-Modi für die Levels-Schaltung
enum LevelSelectionMode { s0toS5, s1toS5, single }

/// Drei schlanke Buttons: [S0–S5] [S1–S5] [Single]
/// - Aktiv: Füllung #2D2C2E, weißer Rand + Glow, Text weiß
/// - Inaktiv: nur Rand #2D2C2E, Innen transparent, Text ausgegraut
class LevelSelectorButtons extends StatelessWidget {
  const LevelSelectorButtons({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.spacing = 20, // Mehr Abstand zwischen den Buttons
  });

  final LevelSelectionMode mode;
  final ValueChanged<LevelSelectionMode> onModeChanged;
  final double spacing;

  static const _w = 87.0;
  static const _h = 27.0;
  static const _r = 13.5;
  static const _activeFill = Color(0xFF2D2C2E);
  static const _inactiveStroke = Color(0xFF2D2C2E);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          label: 'S0–S5',
          selected: mode == LevelSelectionMode.s0toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s0toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          label: 'S1–S5',
          selected: mode == LevelSelectionMode.s1toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s1toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          label: 'Single',
          selected: mode == LevelSelectionMode.single,
          onTap: () => onModeChanged(LevelSelectionMode.single),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _w = LevelSelectorButtons._w;
  static const _h = LevelSelectorButtons._h;
  static const _r = LevelSelectorButtons._r;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.45), // ausgegraut
        );

    final decoration = BoxDecoration(
      color: selected ? LevelSelectorButtons._activeFill : Colors.transparent,
      borderRadius: BorderRadius.circular(_r),
      border: Border.all(
        color: selected ? Colors.white : LevelSelectorButtons._inactiveStroke,
        width: selected ? 1.5 : 1.0,
      ),
      boxShadow: selected
          ? [
              // sanfter weißer Glow
              BoxShadow(
                color: Colors.white.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : null,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _w,
        height: _h,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(label, style: textStyle),
      ),
    );
  }
}
