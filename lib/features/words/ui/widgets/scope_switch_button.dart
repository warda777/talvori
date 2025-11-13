import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScopeSwitchButton extends StatefulWidget {
  const ScopeSwitchButton({
    super.key,
    required this.diameter,
    required this.ringColor,
    required this.isAll,
    required this.onTapToggle,
    required this.onConfirmHold,
    this.holdDuration = const Duration(milliseconds: 2500),
  });

  final double diameter;
  final Color ringColor;
  final bool isAll;
  final VoidCallback onTapToggle;
  final VoidCallback onConfirmHold;
  final Duration holdDuration;

  @override
  State<ScopeSwitchButton> createState() => _ScopeSwitchButtonState();
}

class _ScopeSwitchButtonState extends State<ScopeSwitchButton>
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
    HapticFeedback.selectionClick();
  }

  Future<void> _endHold([_]) async {
    if (!_holding) return;
    _holding = false;
    if (_hold.status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      widget.onConfirmHold();
    } else {
      await _hold.reverse();
    }
  }

  Future<void> _tap() async {
    if (_holding) return;
    HapticFeedback.selectionClick();
    _angleTurns += 0.25;
    await _spin.forward(from: 0);
    widget.onTapToggle();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: _tap,
      onLongPressStart: _startHold,
      onLongPressUp: _endHold,
      onLongPressEnd: _endHold,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: widget.ringColor.withOpacity(.35),
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
                  color: widget.ringColor,
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
                    painter: _SpinnerPainter(color: widget.ringColor),
                  ),
                ),
              );
            },
          ),
          Container(
            width: d * 0.58,
            height: d * 0.58,
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              widget.isAll
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: Colors.white,
              size: d * 0.28,
            ),
          ),
          Positioned(
            top: 10,
            child: Text(
              'ALL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Text(
              'ONE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
            ),
          ),
        ],
      ),
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
