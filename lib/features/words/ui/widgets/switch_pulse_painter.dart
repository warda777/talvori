import 'package:flutter/material.dart';

class SwitchPulsePainter extends CustomPainter {
  final Rect? rect;
  final double t; // 0..1
  final Color color;

  SwitchPulsePainter({
    required this.rect,
    required this.t,
    this.color = const Color(0xFFB16CFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rect == null) return;

    final r = RRect.fromRectAndRadius(
      rect!.inflate(8 + (t * 10)),
      Radius.circular(rect!.height * 0.5 + 18),
    );

    final alpha = (1 - t).clamp(0.0, 1.0);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = color.withValues(alpha: 0.20 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color.withValues(alpha: 0.32 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFEFE9FF).withValues(alpha: 0.55 * alpha);

    canvas.drawRRect(r, glow);
    canvas.drawRRect(r, mid);
    canvas.drawRRect(r, core);
  }

  @override
  bool shouldRepaint(covariant SwitchPulsePainter old) =>
      old.rect != rect || old.t != t || old.color != color;
}
