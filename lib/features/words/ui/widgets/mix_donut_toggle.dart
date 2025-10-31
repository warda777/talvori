import 'package:flutter/material.dart';

class MixDonutToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeRing;   // z.B. Theme.of(context).colorScheme.primary
  final Color activeCore;   // z.B. Color(0xFFF1C86B) (Gold)
  final double size;

  const MixDonutToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeRing,
    required this.activeCore,
    this.size = 24,
  });

  @override
  State<MixDonutToggle> createState() => _MixDonutToggleState();
}

class _MixDonutToggleState extends State<MixDonutToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    if (widget.value) _c.value = 1;
  }

  @override
  void didUpdateWidget(covariant MixDonutToggle old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double s = widget.size;
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: s, height: s,
        child: AnimatedBuilder(
          animation: _t,
          builder: (_, __) {
            return CustomPaint(
              painter: _DonutPainter(
                t: _t.value,
                base: cs.outlineVariant,
                ring: widget.activeRing,
                core: widget.activeCore,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double t;
  final Color base;
  final Color ring;
  final Color core;

  _DonutPainter({required this.t, required this.base, required this.ring, required this.core});

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final rOuter = size.width / 2;
    final rInner = rOuter * (0.58 + 0.18 * t); // innerer Kreis wächst bei Aktivierung

    // Outer ring - deutlicher im inaktiven Zustand
    final inactiveColor = base.withValues(alpha: 0.9); // Heller für bessere Sichtbarkeit
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Color.lerp(inactiveColor, ring, t) ?? ring;
    c.drawCircle(Offset(cx, cy), rOuter - 1.5, ringPaint);

    // Core
    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.lerp(Colors.transparent, core, t) ?? core;
    c.drawCircle(Offset(cx, cy), rInner, corePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.t != t || old.base != base || old.ring != ring || old.core != core;
}
