import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

/// Auswahl-Modi für die Levels-Schaltung
enum LevelSelectionMode { s0toS5, s1toS5, single }

/// Drei schlanke Buttons: [AUTO] [T1–T5/A1–A5/H1–H5] [SINGLE]
/// - Aktiv: Füllung #2D2C2E, weißer Rand + Glow, Text weiß
/// - Inaktiv: nur Rand #2D2C2E, Innen transparent, Text ausgegraut
class LevelSelectorButtons extends ConsumerWidget {
  const LevelSelectorButtons({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.spacing = 20, // Mehr Abstand zwischen den Buttons
    this.autoButtonKey,
    this.trainingButtonKey,
    this.singleButtonKey,
  });

  final LevelSelectionMode mode;
  final ValueChanged<LevelSelectionMode> onModeChanged;
  final double spacing;
  final GlobalKey? autoButtonKey;
  final GlobalKey? trainingButtonKey;
  final GlobalKey? singleButtonKey;

  /// Gibt das Label für S1-S5 basierend auf dem SRS-Modus zurück
  String _getS1ToS5Label(SrsSystem srsMode) {
    switch (srsMode) {
      case SrsSystem.time:
        return 'T1–T5';
      case SrsSystem.adaptive:
        return 'A1–A5';
      case SrsSystem.hybrid:
        return 'H1–H5';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final srsMode = ref.watch(srsModeControllerProvider).mode;
    final s1ToS5Label = _getS1ToS5Label(srsMode);

    return LevelSelectorButtonsView(
      mode: mode,
      s1ToS5Label: s1ToS5Label,
      onModeChanged: onModeChanged,
      spacing: spacing,
      autoButtonKey: autoButtonKey,
      trainingButtonKey: trainingButtonKey,
      singleButtonKey: singleButtonKey,
    );
  }
}

class LevelSelectorButtonsView extends StatelessWidget {
  const LevelSelectorButtonsView({
    super.key,
    required this.mode,
    required this.s1ToS5Label,
    required this.onModeChanged,
    this.spacing = 20,
    this.autoButtonKey,
    this.trainingButtonKey,
    this.singleButtonKey,
  });

  final LevelSelectionMode mode;
  final String s1ToS5Label;
  final ValueChanged<LevelSelectionMode> onModeChanged;
  final double spacing;
  final GlobalKey? autoButtonKey;
  final GlobalKey? trainingButtonKey;
  final GlobalKey? singleButtonKey;

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
          key: autoButtonKey,
          label: 'AUTO',
          selected: mode == LevelSelectionMode.s0toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s0toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          key: trainingButtonKey,
          label: s1ToS5Label,
          selected: mode == LevelSelectionMode.s1toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s1toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          key: singleButtonKey,
          label: 'SINGLE',
          selected: mode == LevelSelectionMode.single,
          onTap: () => onModeChanged(LevelSelectionMode.single),
        ),
      ],
    );
  }
}

class _ModeButton extends StatefulWidget {
  const _ModeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton>
    with SingleTickerProviderStateMixin {
  static const _w = LevelSelectorButtonsView._w;
  static const _h = LevelSelectorButtonsView._h;
  static const _r = LevelSelectorButtonsView._r;

  late AnimationController _ctrl;
  late Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowScale = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selected) _ctrl.forward();
      });
    }
  }

  @override
  void didUpdateWidget(_ModeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _ctrl.forward(from: 0);
      } else {
        _ctrl.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowScale,
        builder: (context, child) {
          final v = _glowScale.value;
          final glowOpacity = 0.6 * v;
          final scale = 1.0 + 0.04 * v;

          final decoration = BoxDecoration(
            color: selected
                ? LevelSelectorButtonsView._activeFill
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_r),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : LevelSelectorButtonsView._inactiveStroke,
              width: selected ? 1.5 : 1.0,
            ),
            boxShadow: _glowScale.value > 0.01
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: glowOpacity),
                      blurRadius: 16 + 4 * v,
                      spreadRadius: 1 + v,
                    ),
                  ]
                : null,
          );

          return Transform.scale(
            scale: scale.clamp(1.0, 1.04),
            child: Container(
              width: _w,
              height: _h,
              alignment: Alignment.center,
              decoration: decoration,
              child: Text(widget.label, style: textStyle),
            ),
          );
        },
      ),
    );
  }
}
