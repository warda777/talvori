import 'package:flutter/material.dart';

/// Glow-Ring mit umlaufendem Lichtsektor.
/// - Eine Umdrehung dauert [duration].
/// - Er läuft [cyclesPerBurst] Runden, pausiert dann [idle], und wiederholt das,
///   wenn [loop] = true.
/// - Wenn [loop] = false, läuft er genau [cyclesPerBurst] Runden und blendet
///   sich danach aus (nur wenn [hideWhenDone] = true).
class GlowSweepRing extends StatefulWidget {
  final double size;                 // Außendurchmesser
  final double strokeWidth;          // Ringbreite
  final Duration duration;           // Dauer einer Umdrehung
  final int cyclesPerBurst;          // Runden pro Burst (z.B. 3)
  final Duration idle;               // Pause nach einem Burst (z.B. 5s)
  final bool loop;                   // true = endlos Bursts
  final bool hideWhenDone;           // nur relevant wenn loop=false
  final Color color;                 // Glow-Farbe

  const GlowSweepRing({
    super.key,
    required this.size,
    this.strokeWidth = 4,
    this.duration = const Duration(milliseconds: 900),
    this.cyclesPerBurst = 3,
    this.idle = const Duration(seconds: 5),
    this.loop = true,
    this.hideWhenDone = true,
    this.color = const Color(0xFFF1C86B), // Gold
  });

  @override
  State<GlowSweepRing> createState() => _GlowSweepRingState();
}

class _GlowSweepRingState extends State<GlowSweepRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration);
  int _doneInThisBurst = 0;
  bool _finishedOneShot = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addStatusListener(_onStatus);
    _startNextTurn();
  }

  void _onStatus(AnimationStatus s) async {
    if (s == AnimationStatus.completed) {
      _doneInThisBurst++;

      // Noch Runden in diesem Burst übrig?
      if (_doneInThisBurst < widget.cyclesPerBurst) {
        _startNextTurn();
        return;
      }

      // Burst fertig
      if (widget.loop) {
        // Pause, dann neuer Burst
        await Future.delayed(widget.idle);
        if (!mounted) return;
        _doneInThisBurst = 0;
        _startNextTurn();
      } else {
        // One-shot fertig
        if (widget.hideWhenDone && mounted) {
          setState(() => _finishedOneShot = true);
        }
      }
    }
  }

  void _startNextTurn() {
    // eine Umdrehung
    _ctrl
      ..value = 0
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.removeStatusListener(_onStatus);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finishedOneShot) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = _ctrl.value * 6.283185307179586; // 2π
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _SweepGlowPainter(
            angle: angle,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _SweepGlowPainter extends CustomPainter {
  final double angle;
  final Color color;
  final double strokeWidth;

  _SweepGlowPainter({
    required this.angle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = (size.shortestSide - strokeWidth) / 2;

    // Grundring (dezent)
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.18);
    canvas.drawCircle(rect.center, r, basePaint);

    // Leuchtsektor mit Sweep-Gradient, rotiert
    final sweep = SweepGradient(
      startAngle: 0,
      endAngle: 6.283185307179586,
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.95),
        color.withValues(alpha: 0.0),
        Colors.transparent,
      ],
      stops: const [0.0, 0.40, 0.50, 0.60, 1.0],
      transform: GradientRotation(angle),
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path()..addOval(Rect.fromCircle(center: rect.center, radius: r));
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SweepGlowPainter old) =>
      old.angle != angle || old.color != color || old.strokeWidth != strokeWidth;
}
