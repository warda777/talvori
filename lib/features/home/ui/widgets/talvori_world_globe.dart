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
      _TalvoriNodeKind.hub => 7.4,
      _TalvoriNodeKind.city => 5.2,
      _TalvoriNodeKind.spark => 3.8,
    };
    final color = switch (kind) {
      _TalvoriNodeKind.hub => const Color(0xFFFFD9A0),
      _TalvoriNodeKind.city => const Color(0xFFFFB86A),
      _TalvoriNodeKind.spark => const Color(0xFFE8A85F),
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
                color: color.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.58),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 30,
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
      center,
      radius * 1.01,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.01
        ..color = const Color(0xFFFFC47A).withValues(alpha: 0.3),
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
  _TalvoriConnection('london', 'newyork'),
  _TalvoriConnection('london', 'paris', width: 0.55),
  _TalvoriConnection('paris', 'cairo'),
  _TalvoriConnection('cairo', 'dubai'),
  _TalvoriConnection('dubai', 'delhi'),
  _TalvoriConnection('dubai', 'singapore', width: 0.92),
  _TalvoriConnection('singapore', 'tokyo'),
  _TalvoriConnection('singapore', 'sydney', color: Color(0x78FFD08A)),
  _TalvoriConnection('newyork', 'mexico', color: Color(0x70F0B36B)),
  _TalvoriConnection('mexico', 'rio'),
  _TalvoriConnection('rio', 'capetown', width: 0.62),
  _TalvoriConnection('lagos', 'capetown'),
  _TalvoriConnection('reykjavik', 'london', color: Color(0x66E8A85F)),
];
