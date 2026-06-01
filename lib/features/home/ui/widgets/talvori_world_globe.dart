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
      ..setFixedLightCoordinates(36, -34)
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
          isDashed: true,
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
                          const Color(0xFFFFC56B).withValues(alpha: 0.2),
                          const Color(0xFF53D7FF).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.48, 1],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(widget.size * 0.015),
                    child: Earth3D(
                      controller: _controller,
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
      _TalvoriNodeKind.hub => 9.0,
      _TalvoriNodeKind.city => 6.0,
      _TalvoriNodeKind.spark => 4.0,
    };
    final color = switch (kind) {
      _TalvoriNodeKind.hub => const Color(0xFFFFD48A),
      _TalvoriNodeKind.city => const Color(0xFFFFB75F),
      _TalvoriNodeKind.spark => const Color(0xFF8EEBFF),
    };

    return IgnorePointer(
      child: SizedBox.square(
        dimension: size * 2.6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 2.4,
              height: size * 2.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 28,
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
                boxShadow: [BoxShadow(color: color, blurRadius: 10)],
              ),
            ),
          ],
        ),
      ),
    );
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
        ..strokeWidth = radius * 0.11
        ..color = const Color(0xFF6BDEFF).withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawArc(
      rect.inflate(radius * 0.03),
      -0.94,
      1.62,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFD08A).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
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
            Colors.black.withValues(alpha: 0.46),
          ],
          stops: const [0, 0.58, 1],
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
    this.color = const Color(0xFFFFC56B),
    this.width = 1.35,
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
  _TalvoriConnection('london', 'newyork'),
  _TalvoriConnection('london', 'paris', width: 1.1),
  _TalvoriConnection('paris', 'cairo'),
  _TalvoriConnection('cairo', 'dubai'),
  _TalvoriConnection('dubai', 'delhi'),
  _TalvoriConnection('dubai', 'singapore', width: 1.7),
  _TalvoriConnection('singapore', 'tokyo'),
  _TalvoriConnection('singapore', 'sydney', color: Color(0xFF86E7FF)),
  _TalvoriConnection('newyork', 'mexico', color: Color(0xFF86E7FF)),
  _TalvoriConnection('mexico', 'rio'),
  _TalvoriConnection('rio', 'capetown', width: 1.2),
  _TalvoriConnection('lagos', 'capetown'),
  _TalvoriConnection('reykjavik', 'london', color: Color(0xFF86E7FF)),
];
