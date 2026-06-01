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
        child: RepaintBoundary(
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
  static const _gold = Color(0xFFFFC96B);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.405;
    final glowRadius = radius * (1.72 + pulse * 0.1);
    final sphereRect = Rect.fromCircle(center: center, radius: radius);

    _drawSpace(canvas, size, center, radius);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _cyan.withValues(alpha: 0.34 + pulse * 0.1),
          _violet.withValues(alpha: 0.18),
          _mint.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 0.72, 1],
      ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, glowPaint);

    final outerAtmospherePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.22
      ..color = _cyan.withValues(alpha: 0.06 + pulse * 0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, radius * 1.03, outerAtmospherePaint);

    final sunCenter = center + Offset(-radius * 1.15, -radius * 0.62);
    canvas.drawCircle(
      sunCenter,
      radius * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.4),
            _gold.withValues(alpha: 0.22),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: radius)),
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _cyan.withValues(alpha: 0.12 + pulse * 0.06);
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
      ..shader = RadialGradient(
        center: Alignment(-0.42, -0.54),
        radius: 1.08,
        colors: [
          const Color(0xFF185A72),
          const Color(0xFF0B2945),
          _deep,
          const Color(0xFF02050E),
        ],
        stops: const [0, 0.38, 0.74, 1],
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, spherePaint);

    final clipPath = Path()..addOval(sphereRect);
    canvas.save();
    canvas.clipPath(clipPath);

    final longitudePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _cyan.withValues(alpha: 0.055);
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
      ..color = const Color(0xFF72D8A3).withValues(alpha: 0.58);
    final shadowLandPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF776CFF).withValues(alpha: 0.22);
    final coastPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _cyan.withValues(alpha: 0.28);
    final xShift = math.sin(rotation * math.pi * 2) * radius * 0.32;
    _drawLandMass(
      canvas,
      center + Offset(-radius * 0.38 + xShift, -radius * 0.2),
      radius,
      landPaint,
      coastPaint: coastPaint,
      scale: 0.72,
    );
    _drawLandMass(
      canvas,
      center + Offset(radius * 0.36 + xShift * 0.7, radius * 0.18),
      radius,
      shadowLandPaint,
      coastPaint: coastPaint,
      scale: 0.56,
    );
    _drawLandMass(
      canvas,
      center + Offset(-radius * 0.05 - xShift * 0.55, radius * 0.42),
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..color = _cyan.withValues(alpha: 0.36),
      coastPaint: coastPaint,
      scale: 0.36,
    );

    _drawNetworkArcs(canvas, center, radius, rotation, pulse);
    _drawCloudBand(
      canvas,
      center,
      radius,
      rotation,
      yOffset: -0.3,
      widthFactor: 1.55,
    );
    _drawCloudBand(
      canvas,
      center,
      radius,
      rotation + 0.38,
      yOffset: 0.18,
      widthFactor: 1.35,
    );

    final cityPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF3B0).withValues(alpha: 0.74 + pulse * 0.12);
    for (final marker in const [
      Offset(-0.34, -0.12),
      Offset(-0.2, -0.26),
      Offset(0.16, 0.12),
      Offset(0.42, 0.26),
      Offset(-0.06, 0.46),
      Offset(0.04, -0.44),
      Offset(0.31, -0.19),
    ]) {
      final drift = math.sin((rotation + marker.dx) * math.pi * 2) * 0.035;
      final pos = center + Offset(marker.dx + drift, marker.dy) * radius;
      canvas.drawCircle(pos, radius * 0.018, cityPaint);
      canvas.drawCircle(
        pos,
        radius * 0.034,
        Paint()
          ..style = PaintingStyle.fill
          ..color = cityPaint.color.withValues(alpha: 0.14),
      );
    }

    final terminatorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.46),
        ],
        stops: const [0, 0.48, 1],
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, terminatorPaint);

    canvas.restore();

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..shader = SweepGradient(
        colors: [
          _cyan.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.88),
          _mint.withValues(alpha: 0.84),
          _gold.withValues(alpha: 0.42),
          _violet.withValues(alpha: 0.64),
          _cyan.withValues(alpha: 0.22),
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

  void _drawSpace(Canvas canvas, Size size, Offset center, double radius) {
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.18, -0.2),
          radius: 0.95,
          colors: [
            _cyan.withValues(alpha: 0.1),
            _violet.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ).createShader(bgRect),
    );
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (var i = 0; i < 18; i++) {
      final angle = (i * 137.5 + rotation * 18) * math.pi / 180;
      final distance = radius * (1.12 + (i % 5) * 0.15);
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (pos.dx < 0 ||
          pos.dx > size.width ||
          pos.dy < 0 ||
          pos.dy > size.height) {
        continue;
      }
      final alpha = 0.16 + ((i % 4) * 0.06) + pulse * 0.06;
      canvas.drawCircle(
        pos,
        i % 3 == 0 ? 1.6 : 1.0,
        starPaint..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawNetworkArcs(
    Canvas canvas,
    Offset center,
    double radius,
    double phase,
    double pulse,
  ) {
    final points = <Offset>[
      center + Offset(-0.42, -0.12) * radius,
      center + Offset(-0.18, -0.32) * radius,
      center + Offset(0.1, -0.2) * radius,
      center + Offset(0.36, 0.1) * radius,
      center + Offset(0.12, 0.38) * radius,
      center + Offset(-0.22, 0.28) * radius,
    ];
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..color = _gold.withValues(alpha: 0.28 + pulse * 0.08);
    for (var i = 0; i < points.length; i++) {
      final start = points[i];
      final end = points[(i + 2) % points.length];
      final control =
          center +
          Offset(
                math.sin(phase * math.pi * 2 + i) * 0.28,
                math.cos(phase * math.pi * 2 + i * 0.7) * 0.18,
              ) *
              radius;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, arcPaint);
    }

    for (final point in points) {
      canvas.drawCircle(
        point,
        radius * 0.022,
        Paint()..color = Colors.white.withValues(alpha: 0.72),
      );
      canvas.drawCircle(
        point,
        radius * 0.048,
        Paint()
          ..color = _cyan.withValues(alpha: 0.13)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawLandMass(
    Canvas canvas,
    Offset anchor,
    double radius,
    Paint paint, {
    Paint? coastPaint,
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
    if (coastPaint != null) {
      canvas.drawPath(path, coastPaint);
    }
  }

  void _drawCloudBand(
    Canvas canvas,
    Offset center,
    double radius,
    double phase, {
    required double yOffset,
    required double widthFactor,
  }) {
    final cloudPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final path = Path();
    final start = -radius * widthFactor * 0.52;
    final end = radius * widthFactor * 0.52;
    final drift = math.sin(phase * math.pi * 2) * radius * 0.22;
    path.moveTo(center.dx + start + drift, center.dy + yOffset * radius);
    for (var i = 0; i < 4; i++) {
      final x1 = center.dx + start + (end - start) * (i + 0.25) / 4 + drift;
      final x2 = center.dx + start + (end - start) * (i + 0.5) / 4 + drift;
      final x3 = center.dx + start + (end - start) * (i + 0.75) / 4 + drift;
      final wave = (i.isEven ? -0.035 : 0.035) * radius;
      path.cubicTo(
        x1,
        center.dy + yOffset * radius + wave,
        x2,
        center.dy + yOffset * radius - wave,
        x3,
        center.dy + yOffset * radius,
      );
    }
    canvas.drawPath(path, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant _TalvoriWorldGlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
