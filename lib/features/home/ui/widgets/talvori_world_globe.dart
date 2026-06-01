import 'dart:math' as math;

import 'package:flutter/material.dart';

class TalvoriWorldGlobe extends StatefulWidget {
  const TalvoriWorldGlobe({
    super.key,
    required this.onTap,
    this.size = 250,
    this.label = 'Talvori Welt öffnen',
  });

  final VoidCallback onTap;
  final double size;
  final String label;

  @override
  State<TalvoriWorldGlobe> createState() => _TalvoriWorldGlobeState();
}

class _TalvoriWorldGlobeState extends State<TalvoriWorldGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        key: const Key('talvori-world-globe-button'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
            return SizedBox.square(
              dimension: widget.size,
              child: CustomPaint(
                key: const Key('talvori-world-globe'),
                painter: _TalvoriWorldGlobePainter(rotation: t, pulse: pulse),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TalvoriWorldGlobePainter extends CustomPainter {
  const _TalvoriWorldGlobePainter({
    required this.rotation,
    required this.pulse,
  });

  final double rotation;
  final double pulse;

  static const _cyan = Color(0xFF5DDCFF);
  static const _violet = Color(0xFFB36BFF);
  static const _mint = Color(0xFF9FF7D5);
  static const _deep = Color(0xFF081321);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.36;
    final glowRadius = radius * (1.55 + pulse * 0.08);
    final sphereRect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _cyan.withValues(alpha: 0.24 + pulse * 0.08),
          _violet.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _cyan.withValues(alpha: 0.22 + pulse * 0.12);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.42);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2.92,
        height: radius * 1.16,
      ),
      orbitPaint,
    );
    canvas.restore();

    final spherePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.42, -0.54),
        radius: 1.05,
        colors: [
          Color(0xFF153D55),
          Color(0xFF0B2036),
          _deep,
          Color(0xFF030712),
        ],
        stops: [0, 0.42, 0.76, 1],
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, spherePaint);

    final clipPath = Path()..addOval(sphereRect);
    canvas.save();
    canvas.clipPath(clipPath);

    final longitudePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _cyan.withValues(alpha: 0.22);
    for (final offset in const [-0.55, -0.25, 0.0, 0.25, 0.55]) {
      final shifted =
          math.sin((rotation + offset) * math.pi * 2) * radius * 0.2;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + shifted, center.dy),
          width: radius * (0.36 + offset.abs()),
          height: radius * 1.96,
        ),
        longitudePaint,
      );
    }

    for (final y in const [-0.48, -0.22, 0.0, 0.22, 0.48]) {
      final widthFactor = math.cos(y.abs() * math.pi / 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + y * radius),
          width: radius * 2 * widthFactor,
          height: radius * 0.18,
        ),
        longitudePaint,
      );
    }

    final landPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _mint.withValues(alpha: 0.58);
    final shadowLandPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _violet.withValues(alpha: 0.28);
    final xShift = math.sin(rotation * math.pi * 2) * radius * 0.32;
    _drawLandMass(
      canvas,
      center + Offset(-radius * 0.38 + xShift, -radius * 0.2),
      radius,
      landPaint,
      scale: 0.72,
    );
    _drawLandMass(
      canvas,
      center + Offset(radius * 0.36 + xShift * 0.7, radius * 0.18),
      radius,
      shadowLandPaint,
      scale: 0.56,
    );
    _drawLandMass(
      canvas,
      center + Offset(-radius * 0.05 - xShift * 0.55, radius * 0.42),
      radius,
      landPaint..color = _cyan.withValues(alpha: 0.34),
      scale: 0.36,
    );

    canvas.restore();

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = SweepGradient(
        colors: [
          _cyan.withValues(alpha: 0.2),
          _mint.withValues(alpha: 0.82),
          _violet.withValues(alpha: 0.64),
          _cyan.withValues(alpha: 0.2),
        ],
        transform: GradientRotation(rotation * math.pi * 2),
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, rimPaint);

    final highlightPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.28), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: center + Offset(-radius * 0.34, -radius * 0.42),
              radius: radius * 0.55,
            ),
          );
    canvas.drawCircle(
      center + Offset(-radius * 0.34, -radius * 0.42),
      radius * 0.55,
      highlightPaint,
    );

    final sparkPaint = Paint()..color = _cyan.withValues(alpha: 0.72);
    for (var i = 0; i < 10; i++) {
      final angle = (i / 10 * math.pi * 2) + rotation * math.pi * 2;
      final sparkRadius = radius * (1.24 + (i.isEven ? 0.06 : -0.02));
      final pos =
          center + Offset(math.cos(angle), math.sin(angle)) * sparkRadius;
      canvas.drawCircle(pos, i.isEven ? 1.7 : 1.1, sparkPaint);
    }
  }

  void _drawLandMass(
    Canvas canvas,
    Offset anchor,
    double radius,
    Paint paint, {
    required double scale,
  }) {
    final path = Path()
      ..moveTo(
        anchor.dx - radius * 0.22 * scale,
        anchor.dy - radius * 0.2 * scale,
      )
      ..cubicTo(
        anchor.dx + radius * 0.12 * scale,
        anchor.dy - radius * 0.34 * scale,
        anchor.dx + radius * 0.34 * scale,
        anchor.dy - radius * 0.14 * scale,
        anchor.dx + radius * 0.28 * scale,
        anchor.dy + radius * 0.08 * scale,
      )
      ..cubicTo(
        anchor.dx + radius * 0.18 * scale,
        anchor.dy + radius * 0.28 * scale,
        anchor.dx - radius * 0.18 * scale,
        anchor.dy + radius * 0.2 * scale,
        anchor.dx - radius * 0.32 * scale,
        anchor.dy + radius * 0.02 * scale,
      )
      ..cubicTo(
        anchor.dx - radius * 0.42 * scale,
        anchor.dy - radius * 0.12 * scale,
        anchor.dx - radius * 0.34 * scale,
        anchor.dy - radius * 0.16 * scale,
        anchor.dx - radius * 0.22 * scale,
        anchor.dy - radius * 0.2 * scale,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TalvoriWorldGlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
