import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/radial_palette_controller.dart';

class ScopeSwitchButton extends ConsumerStatefulWidget {
  const ScopeSwitchButton({
    super.key,
    this.size = 72,
    this.holdDuration = const Duration(milliseconds: 2500),
    this.onConfirmColor,
    this.ringColor,
    this.isInteractive = true,
  });

  final double size;
  final Duration holdDuration;
  final VoidCallback? onConfirmColor;
  final Color? ringColor;
  final bool isInteractive;

  @override
  ConsumerState<ScopeSwitchButton> createState() => _ScopeSwitchButtonState();
}

class _ScopeSwitchButtonState extends ConsumerState<ScopeSwitchButton>
    with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  );
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  bool _holding = false;
  double _angleTurns = 0.0;

  @override
  void dispose() {
    _hold.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _startHold(LongPressStartDetails _) {
    _holding = true;
    _hold.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  Future<void> _endHold([_]) async {
    if (!_holding) return;
    _holding = false;
    if (_hold.status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      ref.read(radialPaletteProvider.notifier).resetAll();
    } else {
      await _hold.reverse();
    }
  }

  Future<void> _tap() async {
    if (_holding) return;
    HapticFeedback.selectionClick();
    // 1) Aktuelle Farbe anwenden (z. B. an RotaryColorRing-Callback)
    widget.onConfirmColor?.call();
    // 2) Danach Scope wechseln (ALL/ONE)
    _angleTurns += 0.25;
    await _spin.forward(from: 0);
    ref.read(radialPaletteProvider.notifier).toggleScope();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(radialPaletteProvider);
    final isAll = palette.scope == PaletteScope.all;
    final label = isAll ? 'ALL' : 'ONE';
    final d = widget.size;
    final ringColor = widget.ringColor ?? Colors.white;

    final visual = _buildVisual(context, isAll, label, d, ringColor);

    // 🔹 Wenn nicht interaktiv: nur zeichnen, ohne Gesten
    if (!widget.isInteractive) {
      return visual;
    }

    // 🔹 Wenn interaktiv: ALL/ONE + Reset
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: _tap,
      onLongPressStart: _startHold,
      onLongPressUp: _endHold,
      onLongPressEnd: _endHold,
      child: visual,
    );
  }

  Widget _buildVisual(BuildContext context, bool isAll, String label, double d, Color ringColor) {
    final children = <Widget>[
      Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: ringColor.withOpacity(.35),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
      SizedBox(
        width: d,
        height: d,
        child: AnimatedBuilder(
          animation: _hold,
          builder: (_, __) => CustomPaint(
            painter: _RingPainter(
              progress: _hold.value,
              color: ringColor,
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _spin,
        builder: (_, __) {
          final t = CurvedAnimation(
            parent: _spin,
            curve: Curves.easeOutCubic,
          ).value;
          return Transform.rotate(
            angle: (_angleTurns * 2 * math.pi) * t,
            child: SizedBox(
              width: d * 0.70,
              height: d * 0.70,
              child: CustomPaint(
                painter: _SpinnerPainter(color: ringColor),
              ),
            ),
          );
        },
      ),
    ];

    // Text-Styles für ALL/ONE
    // Wenn Tool aktiv: aktives Element größer und in Goldfarbe, sonst beide gleich groß
    const goldColor = Color(0xFFFFC66A); // Gold wie An/Aus Button unter "Alles freischalten"
    
    // Mittleren Label-Text nur anzeigen, wenn Button interaktiv ist (kein Tool aktiv)
    if (widget.isInteractive) {
      children.add(
        Container(
          width: d * 0.58,
          height: d * 0.58,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Goldener Glow - reduzierter Radius
                  BoxShadow(
                    color: goldColor.withOpacity(0.7),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: goldColor.withOpacity(0.5),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: goldColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: goldColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final allStyle = widget.isInteractive
        ? Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 1.0,
            )
        : TextStyle(
            fontSize: isAll ? 16 : 10, // Größer wenn aktiv
            fontWeight: FontWeight.w600,
            color: isAll ? goldColor : Colors.white70,
            letterSpacing: 1.1,
          );
    final oneStyle = widget.isInteractive
        ? Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              letterSpacing: 1.0,
            )
        : TextStyle(
            fontSize: isAll ? 10 : 16, // Größer wenn aktiv
            fontWeight: FontWeight.w600,
            color: isAll ? Colors.white70 : goldColor,
            letterSpacing: 1.1,
          );

    // Abstand zum mittleren Button: kleiner wenn Tool aktiv (näher am Button)
    final topOffset = widget.isInteractive ? 5.0 : 4.0;
    final bottomOffset = widget.isInteractive ? 5.0 : 4.0;

    // ALL/ONE immer anzeigen (oben/unten)
    children.add(
      Positioned(
        top: topOffset,
        child: Text(
          'ALL',
          style: allStyle,
        ),
      ),
    );
    children.add(
      Positioned(
        bottom: bottomOffset,
        child: Text(
          'ONE',
          style: oneStyle,
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: children,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 3;
    final c = Offset(size.width / 2, size.height / 2);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white12;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(.95);

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white10;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4
      ..color = color.withOpacity(.95);

    const sweep = 2 * math.pi * 0.33;
    const start = -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter old) => old.color != color;
}
