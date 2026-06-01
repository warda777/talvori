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
  late Widget _earthRenderer;

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
    _earthRenderer = _buildEarthRenderer(widget.size);
  }

  @override
  void didUpdateWidget(covariant TalvoriWorldGlobe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _earthRenderer = _buildEarthRenderer(widget.size);
    }
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

  Widget _buildEarthRenderer(double size) {
    return Earth3D(
      key: const ValueKey('talvori-earth3d-renderer'),
      controller: _controller,
      shaderAsset: _premiumEarthShader,
      texture: _dayTexture,
      nightTexture: _nightTexture,
      initialScale: 3.18,
      initialLatitude: 28,
      initialLongitude: 18,
      size: Size.square(size),
    );
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
                    child: _earthRenderer,
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
        dimension: size * 5.6,
        child: CustomPaint(
          painter: _GlobeLightStarPainter(color: color, intensity: size),
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
    final warm = color;
    final hotCore = const Color(0xFFFFF7D8);
    final amberEdge = const Color(0xFFFF8F2C);

    void drawGlowCircle(double radius, double alpha, double blur) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              hotCore.withValues(alpha: alpha * 0.82),
              warm.withValues(alpha: alpha * 0.58),
              amberEdge.withValues(alpha: alpha * 0.18),
              Colors.transparent,
            ],
            stops: const [0, 0.22, 0.58, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    void drawLensRay({
      required double angle,
      required double length,
      required double thickness,
      required double alpha,
      required double blur,
    }) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: length,
        height: thickness,
      );
      final shader = LinearGradient(
        colors: [
          Colors.transparent,
          amberEdge.withValues(alpha: alpha * 0.18),
          warm.withValues(alpha: alpha * 0.68),
          hotCore.withValues(alpha: alpha),
          warm.withValues(alpha: alpha * 0.68),
          amberEdge.withValues(alpha: alpha * 0.18),
          Colors.transparent,
        ],
        stops: const [0, 0.22, 0.42, 0.5, 0.58, 0.78, 1],
      ).createShader(rect);

      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(thickness)),
        Paint()
          ..shader = shader
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
      canvas.restore();
    }

    drawGlowCircle(intensity * 3.2, 0.22, 8);
    drawGlowCircle(intensity * 1.72, 0.5, 5);

    for (final angle in const [0.0, math.pi / 2]) {
      drawLensRay(
        angle: angle,
        length: intensity * 5.0,
        thickness: intensity * 0.34,
        alpha: 0.62,
        blur: 3.4,
      );
      drawLensRay(
        angle: angle,
        length: intensity * 4.45,
        thickness: intensity * 0.12,
        alpha: 0.9,
        blur: 1.25,
      );
    }
    for (final angle in const [math.pi / 4, -math.pi / 4]) {
      drawLensRay(
        angle: angle,
        length: intensity * 3.35,
        thickness: intensity * 0.13,
        alpha: 0.26,
        blur: 2.2,
      );
    }

    canvas.drawCircle(
      center,
      intensity * 0.88,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                hotCore,
                const Color(0xFFFFD178).withValues(alpha: 0.92),
                amberEdge.withValues(alpha: 0.34),
                Colors.transparent,
              ],
              stops: const [0, 0.38, 0.72, 1],
            ).createShader(
              Rect.fromCircle(center: center, radius: intensity * 0.88),
            ),
    );
    canvas.drawCircle(
      center,
      intensity * 0.26,
      Paint()..color = const Color(0xFFFFFBEC).withValues(alpha: 0.96),
    );
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
  _TalvoriNode('istanbul', 41.0, 29.0, _TalvoriNodeKind.city),
  _TalvoriNode('cairo', 30.0, 31.2, _TalvoriNodeKind.city),
  _TalvoriNode('nairobi', -1.3, 36.8, _TalvoriNodeKind.spark),
  _TalvoriNode('dubai', 25.2, 55.3, _TalvoriNodeKind.hub),
  _TalvoriNode('tehran', 35.7, 51.4, _TalvoriNodeKind.spark),
  _TalvoriNode('delhi', 28.6, 77.2, _TalvoriNodeKind.city),
  _TalvoriNode('mumbai', 19.1, 72.9, _TalvoriNodeKind.city),
  _TalvoriNode('bangkok', 13.8, 100.5, _TalvoriNodeKind.city),
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
  _TalvoriConnection('paris', 'istanbul', color: Color(0x26FFD28D), width: 1.9),
  _TalvoriConnection(
    'paris',
    'istanbul',
    color: Color(0x9AFFD28D),
    width: 0.62,
  ),
  _TalvoriConnection(
    'istanbul',
    'tehran',
    color: Color(0xA2FFD99F),
    width: 0.68,
  ),
  _TalvoriConnection('cairo', 'dubai', color: Color(0x30FFD28D), width: 2.1),
  _TalvoriConnection('cairo', 'dubai', color: Color(0xB4FFD28D), width: 0.76),
  _TalvoriConnection('cairo', 'nairobi', color: Color(0x24FFC170), width: 1.85),
  _TalvoriConnection('cairo', 'nairobi', color: Color(0x96FFC170), width: 0.6),
  _TalvoriConnection('dubai', 'delhi', color: Color(0x92FFC170), width: 0.62),
  _TalvoriConnection('tehran', 'delhi', color: Color(0x8CFFD28D), width: 0.56),
  _TalvoriConnection('delhi', 'mumbai', color: Color(0xA8FFD99F), width: 0.7),
  _TalvoriConnection('mumbai', 'nairobi', color: Color(0x22FFD28D), width: 1.8),
  _TalvoriConnection(
    'mumbai',
    'nairobi',
    color: Color(0x8CFFD28D),
    width: 0.58,
  ),
  _TalvoriConnection('delhi', 'bangkok', color: Color(0x2AFFD28D), width: 2.05),
  _TalvoriConnection('delhi', 'bangkok', color: Color(0xA4FFD28D), width: 0.72),
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
    'bangkok',
    'singapore',
    color: Color(0x96FFD99F),
    width: 0.62,
  ),
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
