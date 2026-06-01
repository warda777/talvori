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
      duration: const Duration(seconds: 22),
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

  static const _gold = Color(0xFFFFC56B);
  static const _ice = Color(0xFFE6F7FF);
  static const _cyan = Color(0xFF58DAFF);
  static const _violet = Color(0xFF8266FF);
  static const _ocean = Color(0xFF081A26);
  static const _night = Color(0xFF02050A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.405;
    final sphereRect = Rect.fromCircle(center: center, radius: radius);

    _drawSpace(canvas, size, center, radius);
    _drawOuterAuras(canvas, center, radius);
    _drawOrbitThreads(canvas, center, radius);
    _drawSphere(canvas, center, radius, sphereRect);

    final spherePath = Path()..addOval(sphereRect);
    canvas.save();
    canvas.clipPath(spherePath);

    _drawLandLayer(canvas, center, radius);
    _drawNightLights(canvas, center, radius);
    _drawNetworkArcs(canvas, center, radius);
    _drawCloudVeils(canvas, center, radius);
    _drawDepthShade(canvas, center, radius, sphereRect);

    canvas.restore();

    _drawRim(canvas, center, radius, sphereRect);
    _drawOuterSparkNodes(canvas, center, radius);
  }

  void _drawSpace(Canvas canvas, Size size, Offset center, double radius) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.1, -0.2),
          radius: 0.92,
          colors: [
            _cyan.withValues(alpha: 0.12),
            _violet.withValues(alpha: 0.045),
            Colors.transparent,
          ],
          stops: const [0, 0.46, 1],
        ).createShader(rect),
    );

    for (var i = 0; i < 32; i++) {
      final angle = (i * 97.3 + rotation * 24) * math.pi / 180;
      final distance = radius * (1.1 + (i % 9) * 0.12);
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (!rect.inflate(4).contains(pos)) continue;
      final alpha = 0.08 + (i % 5) * 0.028 + pulse * 0.035;
      canvas.drawCircle(
        pos,
        i % 7 == 0 ? 1.5 : 0.8,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawOuterAuras(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * (1.42 + pulse * 0.02),
      Paint()
        ..shader = RadialGradient(
          colors: [
            _gold.withValues(alpha: 0.13),
            _cyan.withValues(alpha: 0.11),
            _violet.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5)),
    );

    canvas.drawCircle(
      center,
      radius * 1.035,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.12
        ..color = _cyan.withValues(alpha: 0.07 + pulse * 0.018)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
  }

  void _drawOrbitThreads(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..strokeCap = StrokeCap.round
      ..color = _gold.withValues(alpha: 0.2 + pulse * 0.04);

    for (final spec in const [
      (tilt: -0.62, width: 2.72, height: 1.15),
      (tilt: 0.48, width: 2.6, height: 0.92),
      (tilt: -0.08, width: 2.38, height: 1.42),
    ]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(spec.tilt + rotation * math.pi * 0.16);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * spec.width,
          height: radius * spec.height,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawSphere(
    Canvas canvas,
    Offset center,
    double radius,
    Rect sphereRect,
  ) {
    canvas.drawCircle(
      center + Offset(radius * 0.08, radius * 0.1),
      radius * 1.02,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.42, -0.52),
          radius: 1.18,
          colors: const [Color(0xFF294050), Color(0xFF102636), _ocean, _night],
          stops: [0, 0.38, 0.72, 1],
        ).createShader(sphereRect),
    );
  }

  void _drawLandLayer(Canvas canvas, Offset center, double radius) {
    final drift = math.sin(rotation * math.pi * 2) * radius * 0.34;
    final landPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _ice.withValues(alpha: 0.74),
          const Color(0xFF927B58).withValues(alpha: 0.74),
          const Color(0xFF2D5944).withValues(alpha: 0.46),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final darkLandPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF182017).withValues(alpha: 0.5);
    final coastPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.012
      ..strokeJoin = StrokeJoin.round
      ..color = _gold.withValues(alpha: 0.46);
    final icePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _ice.withValues(alpha: 0.58);

    _drawLandMass(
      canvas,
      center + Offset(-0.48 * radius + drift, -0.08 * radius),
      radius,
      landPaint,
      coastPaint,
      1.0,
      const [
        Offset(-0.38, -0.34),
        Offset(-0.1, -0.48),
        Offset(0.16, -0.34),
        Offset(0.32, -0.12),
        Offset(0.22, 0.14),
        Offset(0.08, 0.34),
        Offset(-0.13, 0.46),
        Offset(-0.26, 0.24),
        Offset(-0.44, 0.1),
      ],
    );
    _drawLandMass(
      canvas,
      center + Offset(0.28 * radius + drift * 0.62, 0.03 * radius),
      radius,
      darkLandPaint,
      coastPaint,
      0.92,
      const [
        Offset(-0.24, -0.38),
        Offset(0.04, -0.5),
        Offset(0.33, -0.3),
        Offset(0.42, 0.04),
        Offset(0.2, 0.28),
        Offset(-0.08, 0.24),
        Offset(-0.32, 0.05),
      ],
    );
    _drawLandMass(
      canvas,
      center + Offset(-0.02 * radius - drift * 0.42, 0.44 * radius),
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF62543A).withValues(alpha: 0.42),
      coastPaint,
      0.54,
      const [
        Offset(-0.36, -0.16),
        Offset(-0.08, -0.32),
        Offset(0.26, -0.18),
        Offset(0.34, 0.08),
        Offset(0.1, 0.3),
        Offset(-0.28, 0.18),
      ],
    );
    _drawLandMass(
      canvas,
      center + Offset(-0.02 * radius + drift * 0.25, -0.62 * radius),
      radius,
      icePaint,
      null,
      0.42,
      const [
        Offset(-0.5, -0.04),
        Offset(-0.16, -0.22),
        Offset(0.26, -0.12),
        Offset(0.48, 0.08),
        Offset(0.1, 0.2),
        Offset(-0.32, 0.16),
      ],
    );
  }

  void _drawNightLights(Canvas canvas, Offset center, double radius) {
    final lights = const [
      Offset(-0.48, -0.24),
      Offset(-0.34, -0.18),
      Offset(-0.18, -0.08),
      Offset(-0.3, 0.12),
      Offset(0.06, -0.28),
      Offset(0.22, -0.14),
      Offset(0.38, 0.02),
      Offset(0.18, 0.28),
      Offset(-0.08, 0.42),
      Offset(0.44, 0.35),
    ];
    final drift = math.sin(rotation * math.pi * 2) * radius * 0.06;
    for (var i = 0; i < lights.length; i++) {
      final point = lights[i];
      final pos = center + Offset(point.dx * radius + drift, point.dy * radius);
      final size = radius * (i % 3 == 0 ? 0.025 : 0.018);
      canvas.drawCircle(
        pos,
        size * 2.2,
        Paint()
          ..color = _gold.withValues(alpha: 0.13 + pulse * 0.04)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        pos,
        size,
        Paint()..color = const Color(0xFFFFE1A3).withValues(alpha: 0.82),
      );
    }
  }

  void _drawNetworkArcs(Canvas canvas, Offset center, double radius) {
    final points = <Offset>[
      center + const Offset(-0.48, -0.24) * radius,
      center + const Offset(-0.18, -0.08) * radius,
      center + const Offset(0.06, -0.28) * radius,
      center + const Offset(0.38, 0.02) * radius,
      center + const Offset(0.18, 0.28) * radius,
      center + const Offset(-0.3, 0.12) * radius,
    ];
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.006
      ..strokeCap = StrokeCap.round
      ..color = _gold.withValues(alpha: 0.22 + pulse * 0.05);

    for (var i = 0; i < points.length; i++) {
      final start = points[i];
      final end = points[(i + 2) % points.length];
      final lift = Offset(
        math.sin(rotation * math.pi * 2 + i) * radius * 0.18,
        -radius * (0.12 + (i % 2) * 0.07),
      );
      final control = Offset.lerp(start, end, 0.5)! + lift;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, arcPaint);
    }
  }

  void _drawCloudVeils(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.024
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    for (final spec in const [
      (phase: 0.0, y: -0.34, width: 1.32),
      (phase: 0.42, y: 0.14, width: 1.16),
    ]) {
      final drift =
          math.sin((rotation + spec.phase) * math.pi * 2) * radius * 0.22;
      final path = Path()
        ..moveTo(
          center.dx - radius * spec.width * 0.42 + drift,
          center.dy + radius * spec.y,
        );
      for (var i = 0; i < 4; i++) {
        final x0 = center.dx - radius * spec.width * 0.42 + drift;
        final span = radius * spec.width * 0.84;
        path.cubicTo(
          x0 + span * (i + 0.18) / 4,
          center.dy + radius * (spec.y + (i.isEven ? -0.03 : 0.025)),
          x0 + span * (i + 0.45) / 4,
          center.dy + radius * (spec.y + (i.isEven ? 0.026 : -0.03)),
          x0 + span * (i + 0.78) / 4,
          center.dy + radius * spec.y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawDepthShade(
    Canvas canvas,
    Offset center,
    double radius,
    Rect sphereRect,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.64),
          ],
          stops: const [0, 0.48, 1],
        ).createShader(sphereRect),
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.34, -radius * 0.42),
      radius * 0.58,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.16),
                _cyan.withValues(alpha: 0.04),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: center + Offset(-radius * 0.34, -radius * 0.42),
                radius: radius * 0.58,
              ),
            ),
    );
  }

  void _drawRim(Canvas canvas, Offset center, double radius, Rect sphereRect) {
    canvas.drawCircle(
      center,
      radius * 1.005,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.024
        ..shader = SweepGradient(
          colors: [
            _cyan.withValues(alpha: 0.34),
            _ice.withValues(alpha: 0.78),
            _gold.withValues(alpha: 0.52),
            _violet.withValues(alpha: 0.28),
            _cyan.withValues(alpha: 0.34),
          ],
          transform: GradientRotation(rotation * math.pi * 0.28),
        ).createShader(sphereRect),
    );
  }

  void _drawOuterSparkNodes(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < 14; i++) {
      final angle = (i / 14 * math.pi * 2) + rotation * math.pi * 2;
      final pos =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              radius *
              (1.04 + (i % 4) * 0.035);
      final paint = Paint()
        ..color = _gold.withValues(alpha: i.isEven ? 0.78 : 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(pos, i.isEven ? 2.1 : 1.2, paint);
    }
  }

  void _drawLandMass(
    Canvas canvas,
    Offset anchor,
    double radius,
    Paint fill,
    Paint? stroke,
    double scale,
    List<Offset> points,
  ) {
    if (points.isEmpty) return;
    final path = Path()
      ..moveTo(
        anchor.dx + points.first.dx * radius * scale,
        anchor.dy + points.first.dy * radius * scale,
      );
    for (var i = 1; i < points.length; i++) {
      final current = points[i];
      final previous = points[i - 1];
      final mid = Offset.lerp(previous, current, 0.5)!;
      path.quadraticBezierTo(
        anchor.dx + previous.dx * radius * scale,
        anchor.dy + previous.dy * radius * scale,
        anchor.dx + mid.dx * radius * scale,
        anchor.dy + mid.dy * radius * scale,
      );
    }
    final last = points.last;
    final first = points.first;
    final mid = Offset.lerp(last, first, 0.5)!;
    path.quadraticBezierTo(
      anchor.dx + last.dx * radius * scale,
      anchor.dy + last.dy * radius * scale,
      anchor.dx + mid.dx * radius * scale,
      anchor.dy + mid.dy * radius * scale,
    );
    path.close();
    canvas.drawPath(path, fill);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _TalvoriWorldGlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
