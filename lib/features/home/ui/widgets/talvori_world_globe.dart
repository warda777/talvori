import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_globe_3d/flutter_globe_3d.dart';

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

class _TalvoriWorldGlobeState extends State<TalvoriWorldGlobe> {
  late final EarthController _controller;

  static const _dayTexture = AssetImage(
    'packages/flutter_globe_3d/assets/images/earth.jpg',
  );
  static const _nightTexture = AssetImage(
    'packages/flutter_globe_3d/assets/images/earth_night.jpg',
  );
  static const _premiumEarthShader =
      'assets/shaders/talvori_premium_earth.frag';

  @override
  void initState() {
    super.initState();
    _controller = EarthController()
      ..enableAutoRotate = true
      ..rotateSpeed = 0.28
      ..lockNorthSouth = true
      ..lockZoom = true
      ..minZoom = 1
      ..maxZoom = 1;
    _controller
      ..setLightMode(EarthLightMode.fixedCoordinates)
      ..setFixedLightCoordinates(34, -44)
      ..setCameraFocus(28, 18);
    _seedTalvoriLights();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _seedTalvoriLights() {
    for (final node in _talvoriNodes) {
      _controller.addNode(
        EarthNode(
          id: node.id,
          latitude: node.latitude,
          longitude: node.longitude,
          child: _GlobeLightNode(kind: node.kind),
        ),
      );
    }

    for (final connection in _talvoriConnections) {
      _controller.connect(
        EarthConnection(
          fromId: connection.fromId,
          toId: connection.toId,
          color: connection.color,
          width: connection.width,
          isDashed: false,
        ),
      );
    }
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
          child: SizedBox.square(
            key: const Key('talvori-world-globe'),
            dimension: widget.size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFC078).withValues(alpha: 0.2),
                          const Color(0xFF29384A).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.12, 0.5, 1],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(widget.size * 0.015),
                    child: Earth3D(
                      controller: _controller,
                      shaderAsset: _premiumEarthShader,
                      texture: _dayTexture,
                      nightTexture: _nightTexture,
                      initialScale: 3.18,
                      initialLatitude: 28,
                      initialLongitude: 18,
                      size: Size.square(widget.size),
                    ),
                  ),
                ),
                const Positioned.fill(child: _GlobeAtmosphereOverlay()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobeLightNode extends StatelessWidget {
  const _GlobeLightNode({required this.kind});

  final _TalvoriNodeKind kind;

  @override
  Widget build(BuildContext context) {
    final size = switch (kind) {
      _TalvoriNodeKind.hub => 8.2,
      _TalvoriNodeKind.city => 5.8,
      _TalvoriNodeKind.spark => 4.2,
    };
    final color = switch (kind) {
      _TalvoriNodeKind.hub => const Color(0xFFFFD9A3),
      _TalvoriNodeKind.city => const Color(0xFFFFBF78),
      _TalvoriNodeKind.spark => const Color(0xFFF0A95D),
    };

    return IgnorePointer(
      child: SizedBox.square(
        dimension: size * 4.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size * 4),
              painter: _GlobeLightStarPainter(color: color, intensity: size),
            ),
            Container(
              width: size * 2.7,
              height: size * 2.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 34,
                  ),
                ],
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.96),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            Container(
              width: size * 0.42,
              height: size * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF6DF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFF3C4).withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobeLightStarPainter extends CustomPainter {
  const _GlobeLightStarPainter({required this.color, required this.intensity});

  final Color color;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final longRay = intensity * 1.75;
    final shortRay = intensity * 1.05;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.45
      ..color = color.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.72
      ..color = color.withValues(alpha: 0.58);

    void drawRay(double angle, double length, Paint paint) {
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center - direction * (length * 0.36),
        center + direction * length,
        paint,
      );
    }

    for (final angle in const [0.0, math.pi / 2]) {
      drawRay(angle, longRay, glowPaint);
      drawRay(angle, longRay, corePaint);
    }
    for (final angle in const [math.pi / 4, -math.pi / 4]) {
      drawRay(angle, shortRay, glowPaint);
      drawRay(angle, shortRay, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlobeLightStarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.intensity != intensity;
  }
}

class _GlobeAtmosphereOverlay extends StatelessWidget {
  const _GlobeAtmosphereOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GlobeAtmospherePainter()),
    );
  }
}

class _GlobeAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.43;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius * 1.03,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.085
        ..color = const Color(0xFFA7CCD7).withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawArc(
      rect.inflate(radius * 0.03),
      -0.94,
      1.62,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.032
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFBE73).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.5),
    );

    canvas.drawCircle(
      center + Offset(-radius * 0.28, -radius * 0.22),
      radius * 0.82,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.22),
          radius: 0.9,
          colors: [
            const Color(0xFFD9E2E6).withValues(alpha: 0.08),
            const Color(0xFF7F8D92).withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );

    canvas.drawCircle(
      center + Offset(radius * 0.26, radius * 0.22),
      radius * 0.98,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.36, 0.3),
          radius: 0.92,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.48),
          ],
          stops: const [0, 0.56, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _GlobeAtmospherePainter oldDelegate) => false;
}

enum _TalvoriNodeKind { hub, city, spark }

class _TalvoriNode {
  const _TalvoriNode(this.id, this.latitude, this.longitude, this.kind);

  final String id;
  final double latitude;
  final double longitude;
  final _TalvoriNodeKind kind;
}

class _TalvoriConnection {
  const _TalvoriConnection(
    this.fromId,
    this.toId, {
    this.color = const Color(0x99FFD08A),
    this.width = 0.72,
  });

  final String fromId;
  final String toId;
  final Color color;
  final double width;
}

const _talvoriNodes = [
  _TalvoriNode('london', 51.5, -0.1, _TalvoriNodeKind.hub),
  _TalvoriNode('paris', 48.9, 2.4, _TalvoriNodeKind.city),
  _TalvoriNode('cairo', 30.0, 31.2, _TalvoriNodeKind.city),
  _TalvoriNode('dubai', 25.2, 55.3, _TalvoriNodeKind.hub),
  _TalvoriNode('delhi', 28.6, 77.2, _TalvoriNodeKind.city),
  _TalvoriNode('singapore', 1.35, 103.8, _TalvoriNodeKind.hub),
  _TalvoriNode('tokyo', 35.7, 139.7, _TalvoriNodeKind.city),
  _TalvoriNode('sydney', -33.9, 151.2, _TalvoriNodeKind.spark),
  _TalvoriNode('newyork', 40.7, -74.0, _TalvoriNodeKind.hub),
  _TalvoriNode('mexico', 19.4, -99.1, _TalvoriNodeKind.city),
  _TalvoriNode('rio', -22.9, -43.2, _TalvoriNodeKind.city),
  _TalvoriNode('capetown', -33.9, 18.4, _TalvoriNodeKind.spark),
  _TalvoriNode('lagos', 6.5, 3.4, _TalvoriNodeKind.city),
  _TalvoriNode('reykjavik', 64.1, -21.9, _TalvoriNodeKind.spark),
];

const _talvoriConnections = [
  _TalvoriConnection('london', 'newyork', color: Color(0x2CFFD28D), width: 2.4),
  _TalvoriConnection(
    'london',
    'newyork',
    color: Color(0xB8FFD28D),
    width: 0.82,
  ),
  _TalvoriConnection('london', 'paris', color: Color(0x88FFD99F), width: 0.58),
  _TalvoriConnection('london', 'cairo', color: Color(0x90FFC87A), width: 0.66),
  _TalvoriConnection('cairo', 'dubai', color: Color(0x30FFD28D), width: 2.1),
  _TalvoriConnection('cairo', 'dubai', color: Color(0xB4FFD28D), width: 0.76),
  _TalvoriConnection('dubai', 'delhi', color: Color(0x92FFC170), width: 0.62),
  _TalvoriConnection(
    'dubai',
    'singapore',
    color: Color(0x32FFD28D),
    width: 2.5,
  ),
  _TalvoriConnection(
    'dubai',
    'singapore',
    color: Color(0xC0FFD28D),
    width: 0.9,
  ),
  _TalvoriConnection('dubai', 'tokyo', color: Color(0x7EFFC170), width: 0.58),
  _TalvoriConnection(
    'singapore',
    'tokyo',
    color: Color(0xA8FFD99F),
    width: 0.72,
  ),
  _TalvoriConnection(
    'singapore',
    'sydney',
    color: Color(0x7CFFC170),
    width: 0.64,
  ),
  _TalvoriConnection(
    'singapore',
    'delhi',
    color: Color(0x74FFD99F),
    width: 0.54,
  ),
  _TalvoriConnection(
    'newyork',
    'mexico',
    color: Color(0x88F0B36B),
    width: 0.64,
  ),
  _TalvoriConnection('newyork', 'rio', color: Color(0x2AFFC170), width: 2),
  _TalvoriConnection('newyork', 'rio', color: Color(0x92FFC170), width: 0.7),
  _TalvoriConnection('mexico', 'rio', color: Color(0x82FFD28D), width: 0.58),
  _TalvoriConnection('rio', 'capetown', color: Color(0x78FFD99F), width: 0.56),
  _TalvoriConnection(
    'lagos',
    'capetown',
    color: Color(0x84FFC170),
    width: 0.62,
  ),
  _TalvoriConnection(
    'reykjavik',
    'london',
    color: Color(0x72E8A85F),
    width: 0.54,
  ),
];
