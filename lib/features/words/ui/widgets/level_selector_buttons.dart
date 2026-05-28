import 'package:flutter/material.dart';

/// Auswahl-Modi für die Levels-Schaltung
enum LevelSelectionMode { s0toS5, s1toS5, single }

/// Wiederholungsauswahl: [Alle Stufen] [Einzelstufe].
/// - Aktiv: Füllung #2D2C2E, weißer Rand + Glow, Text weiß
/// - Inaktiv: nur Rand #2D2C2E, Innen transparent, Text ausgegraut
class LevelSelectorButtons extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return LevelSelectorButtonsView(
      mode: mode,
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
    required this.onModeChanged,
    this.spacing = 20,
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

  static const _w = 112.0;
  static const _h = 38.0;
  static const _r = 19.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          key: trainingButtonKey,
          label: 'Alle Stufen',
          selected: mode == LevelSelectionMode.s1toS5,
          onTap: () => onModeChanged(LevelSelectionMode.s1toS5),
        ),
        SizedBox(width: spacing),
        _ModeButton(
          key: singleButtonKey,
          label: 'Einzelstufe',
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
  bool _isDisposed = false;

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
        if (!_isDisposed && mounted && widget.selected) _ctrl.forward();
      });
    }
  }

  @override
  void didUpdateWidget(_ModeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDisposed || !mounted) return;
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
    _isDisposed = true;
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.82),
      letterSpacing: 0.1,
      shadows: [
        Shadow(
          color: const Color(
            0xFF8DBBFF,
          ).withValues(alpha: selected ? 0.48 : 0.24),
          blurRadius: selected ? 12 : 8,
        ),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowScale,
        builder: (context, child) {
          final v = _glowScale.value;
          final glowOpacity = 0.2 + (0.14 * v);

          final decoration = BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? const [Color(0xFF202129), Color(0xFF050505)]
                  : const [Color(0xFF151519), Color(0xFF030303)],
            ),
            borderRadius: BorderRadius.circular(_r),
            border: Border.all(
              color: selected
                  ? const Color(0xFFA8C7FF)
                  : const Color(0xFF8A5CFF),
              width: selected ? 1.7 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8DBBFF).withValues(alpha: glowOpacity),
                blurRadius: 12 + 4 * v,
                spreadRadius: selected ? 0.8 : 0,
              ),
              BoxShadow(
                color: const Color(
                  0xFF8A5CFF,
                ).withValues(alpha: selected ? 0.34 : 0.16),
                blurRadius: selected ? 20 : 12,
                spreadRadius: selected ? 0.5 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          );

          return Container(
            width: _w,
            height: _h,
            alignment: Alignment.center,
            decoration: decoration,
            child: Container(
              margin: const EdgeInsets.all(3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_r - 3),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.42)
                      : const Color(0xFF8DBBFF).withValues(alpha: 0.22),
                  width: 0.8,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(widget.label, style: textStyle, maxLines: 1),
              ),
            ),
          );
        },
      ),
    );
  }
}
