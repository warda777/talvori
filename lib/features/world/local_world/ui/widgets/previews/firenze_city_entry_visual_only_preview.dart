import 'dart:math' as math;

import 'package:flutter/material.dart';

const _previewAssetPath =
    'assets/images/world/previews/firenze_city_entry/'
    'firenze_city_entry_planning_preview_v1.png';

const _previewWidth = 1600.0;
const _previewHeight = 1000.0;
const _background = Color(0xFF02080D);
const _mint = Color(0xFF73FFE0);
const _bridgeAccent = Color(0xFFFFB84D);
const _panel = Color(0xE606141C);
const _panelBorder = Color(0x6636E7B7);

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/previews/firenze_city_entry_visual_only_preview.dart -d macos
//
// This file is intentionally standalone. It displays an app-bundled
// documentation preview image and overlays preview-only UI hitboxes. It does
// not parse SVG, export geometry, register routes, or create runtime map data.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirenzeCityEntryVisualOnlyPreviewApp());
}

class FirenzeCityEntryVisualOnlyPreviewApp extends StatelessWidget {
  const FirenzeCityEntryVisualOnlyPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _mint,
          brightness: Brightness.dark,
        ),
      ),
      home: const FirenzeCityEntryVisualOnlyPreview(),
    );
  }
}

class FirenzeCityEntryVisualOnlyPreview extends StatefulWidget {
  const FirenzeCityEntryVisualOnlyPreview({super.key});

  @override
  State<FirenzeCityEntryVisualOnlyPreview> createState() =>
      _FirenzeCityEntryVisualOnlyPreviewState();
}

class _FirenzeCityEntryVisualOnlyPreviewState
    extends State<FirenzeCityEntryVisualOnlyPreview> {
  final TransformationController _controller = TransformationController();
  Size? _lastViewportSize;
  double _lastFitScale = 0.1;
  _FirenzeHotspot? _selectedHotspot;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            final fitScale = _fitScaleFor(viewportSize);
            _lastFitScale = fitScale;
            _scheduleInitialTransform(viewportSize, fitScale);

            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.16),
                        radius: 1.08,
                        colors: [
                          Color(0xFF0E3038),
                          Color(0xFF061923),
                          _background,
                        ],
                        stops: [0, 0.58, 1],
                      ),
                    ),
                    child: ClipRect(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: () =>
                            _resetView(viewportSize, fitScale, enlarged: true),
                        child: InteractiveViewer(
                          transformationController: _controller,
                          constrained: false,
                          minScale: fitScale * 0.96,
                          maxScale: fitScale * 18,
                          boundaryMargin: const EdgeInsets.all(2400),
                          panEnabled: true,
                          scaleEnabled: true,
                          panAxis: PanAxis.free,
                          clipBehavior: Clip.none,
                          child: SizedBox(
                            width: _previewWidth,
                            height: _previewHeight,
                            child: _FirenzePreviewMap(
                              selectedHotspot: _selectedHotspot,
                              onHotspotTap: _selectHotspot,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(left: 18, top: 16, child: _TitleOverlay()),
                const Positioned(right: 18, top: 18, child: _PlanningBadge()),
                _SelectionPanel(selectedHotspot: _selectedHotspot),
              ],
            );
          },
        ),
      ),
    );
  }

  double _fitScaleFor(Size viewportSize) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      return 0.1;
    }

    final horizontalFit = viewportSize.width / _previewWidth;
    final verticalFit = viewportSize.height / _previewHeight;
    return math.min(horizontalFit, verticalFit) * 0.94;
  }

  void _scheduleInitialTransform(Size viewportSize, double fitScale) {
    if (_lastViewportSize == viewportSize) {
      return;
    }

    _lastViewportSize = viewportSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _resetView(viewportSize, fitScale, enlarged: true);
    });
  }

  void _resetView(
    Size viewportSize,
    double fitScale, {
    required bool enlarged,
  }) {
    final scale = enlarged ? fitScale * 1.12 : fitScale;
    _controller.value = _matrixFor(viewportSize, scale);
  }

  void _selectHotspot(_FirenzeHotspot hotspot) {
    setState(() {
      _selectedHotspot = hotspot;
    });

    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    final scale = math.max(_lastFitScale * 2.45, _lastFitScale + 0.01);
    _controller.value = _matrixFor(
      viewportSize,
      scale,
      focus: hotspot.focus,
      verticalBias: hotspot.type == _FirenzeHotspotType.parcel ? 0.06 : 0.02,
    );
  }

  Matrix4 _matrixFor(
    Size viewportSize,
    double scale, {
    Offset focus = const Offset(0.5, 0.5),
    double verticalBias = 0,
  }) {
    final canvasFocus = Offset(
      focus.dx * _previewWidth,
      focus.dy * _previewHeight,
    );
    final viewportFocus = Offset(
      viewportSize.width / 2,
      viewportSize.height * (0.48 - verticalBias),
    );
    final dx = viewportFocus.dx - canvasFocus.dx * scale;
    final dy = viewportFocus.dy - canvasFocus.dy * scale;

    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, dx)
      ..setEntry(1, 3, dy);
  }
}

class _FirenzePreviewMap extends StatelessWidget {
  const _FirenzePreviewMap({
    required this.selectedHotspot,
    required this.onHotspotTap,
  });

  final _FirenzeHotspot? selectedHotspot;
  final ValueChanged<_FirenzeHotspot> onHotspotTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _previewAssetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        CustomPaint(
          painter: _FirenzeHotspotPainter(
            hotspots: _hotspots,
            selectedHotspot: selectedHotspot,
          ),
        ),
        for (final hotspot in _hotspots)
          Positioned.fromRect(
            rect: _toCanvasRect(hotspot.hitbox),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onHotspotTap(hotspot),
              child: const SizedBox.expand(),
            ),
          ),
        const _SpawnStartMarker(),
      ],
    );
  }

  Rect _toCanvasRect(Rect normalizedRect) {
    return Rect.fromLTWH(
      normalizedRect.left * _previewWidth,
      normalizedRect.top * _previewHeight,
      normalizedRect.width * _previewWidth,
      normalizedRect.height * _previewHeight,
    );
  }
}

class _FirenzeHotspotPainter extends CustomPainter {
  const _FirenzeHotspotPainter({
    required this.hotspots,
    required this.selectedHotspot,
  });

  final List<_FirenzeHotspot> hotspots;
  final _FirenzeHotspot? selectedHotspot;

  @override
  void paint(Canvas canvas, Size size) {
    for (final hotspot in hotspots) {
      final center = Offset(
        hotspot.focus.dx * size.width,
        hotspot.focus.dy * size.height,
      );
      final isSelected = selectedHotspot?.id == hotspot.id;
      final isBridge = hotspot.type == _FirenzeHotspotType.bridge;
      final color = isBridge ? _bridgeAccent : _mint;
      final dotRadius = isBridge ? 7.0 : 8.0;

      if (isSelected) {
        final rect = Rect.fromLTWH(
          hotspot.hitbox.left * size.width,
          hotspot.hitbox.top * size.height,
          hotspot.hitbox.width * size.width,
          hotspot.hitbox.height * size.height,
        );
        final fill = Paint()
          ..color = color.withValues(alpha: isBridge ? 0.12 : 0.1)
          ..style = PaintingStyle.fill;
        final stroke = Paint()
          ..color = color.withValues(alpha: 0.86)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isBridge ? 3 : 4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(isBridge ? 18 : 28)),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(isBridge ? 18 : 28)),
          stroke,
        );
      }

      final glow = Paint()
        ..color = color.withValues(alpha: isSelected ? 0.28 : 0.1)
        ..style = PaintingStyle.fill;
      final dot = Paint()
        ..color = color.withValues(alpha: isSelected ? 1 : 0.68)
        ..style = PaintingStyle.fill;
      final ring = Paint()
        ..color = Colors.white.withValues(alpha: isSelected ? 0.9 : 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.4;

      canvas.drawCircle(center, dotRadius * (isSelected ? 3.2 : 2.2), glow);
      canvas.drawCircle(center, dotRadius, dot);
      canvas.drawCircle(center, dotRadius + 5, ring);
    }
  }

  @override
  bool shouldRepaint(covariant _FirenzeHotspotPainter oldDelegate) {
    return oldDelegate.selectedHotspot?.id != selectedHotspot?.id ||
        oldDelegate.hotspots != hotspots;
  }
}

class _SpawnStartMarker extends StatelessWidget {
  const _SpawnStartMarker();

  static const _spawn = Offset(0.344, 0.358);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _spawn.dx * _previewWidth - 38,
      top: _spawn.dy * _previewHeight - 48,
      width: 76,
      height: 72,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xD9071721),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _mint.withValues(alpha: 0.75)),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _mint.withValues(alpha: 0.55),
                    blurRadius: 18,
                    spreadRadius: 4,
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

class _TitleOverlay extends StatelessWidget {
  const _TitleOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Florenz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Wohin zuerst?',
              style: TextStyle(
                color: _mint,
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanningBadge extends StatelessWidget {
  const _PlanningBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          'planning only / no runtime',
          style: TextStyle(
            color: Color(0xFFD9EEF6),
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel({required this.selectedHotspot});

  final _FirenzeHotspot? selectedHotspot;

  @override
  Widget build(BuildContext context) {
    final hotspot = selectedHotspot;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      left: 18,
      right: 18,
      bottom: hotspot == null ? -150 : math.max(18, bottomPadding + 14),
      child: IgnorePointer(
        ignoring: hotspot == null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: hotspot == null ? 0 : 1,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xF0081822),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _panelBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
                  child: hotspot == null
                      ? const SizedBox.shrink()
                      : _SelectionPanelContent(hotspot: hotspot),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionPanelContent extends StatelessWidget {
  const _SelectionPanelContent({required this.hotspot});

  final _FirenzeHotspot hotspot;

  @override
  Widget build(BuildContext context) {
    final isBridge = hotspot.type == _FirenzeHotspotType.bridge;
    final accent = isBridge ? _bridgeAccent : _mint;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.7)),
          ),
          alignment: Alignment.center,
          child: Text(
            isBridge ? 'B' : 'P',
            style: TextStyle(
              color: accent,
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hotspot.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hotspot.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD0E2E8),
                  fontSize: 13,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _FirenzeHotspotType { parcel, bridge }

class _FirenzeHotspot {
  const _FirenzeHotspot({
    required this.id,
    required this.type,
    required this.hitbox,
    required this.focus,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final _FirenzeHotspotType type;
  final Rect hitbox;
  final Offset focus;
  final String title;
  final String subtitle;
}

_FirenzeHotspot _parcel(
  String id, {
  required double x,
  required double y,
  required double w,
  required double h,
}) {
  return _FirenzeHotspot(
    id: id,
    type: _FirenzeHotspotType.parcel,
    hitbox: Rect.fromLTWH(x, y, w, h),
    focus: Offset(x + w / 2, y + h / 2),
    title: '$id betreten',
    subtitle: 'Grundstücks-Detailkarte später',
  );
}

_FirenzeHotspot _bridge(String id, {required double x, required double y}) {
  const size = 0.04;
  return _FirenzeHotspot(
    id: id,
    type: _FirenzeHotspotType.bridge,
    hitbox: Rect.fromLTWH(x - size / 2, y - size / 2, size, size),
    focus: Offset(x, y),
    title: 'Brücke $id',
    subtitle: 'Arno-Querung',
  );
}

// These normalized rectangles are preview-only UI hitboxes derived by eye from
// the approved planning PNG. They are not runtime geometry, not final
// coordinates, and not exported as Area-Specification data.
final _hotspots = <_FirenzeHotspot>[
  _parcel('P01', x: 0.22, y: 0.37, w: 0.08, h: 0.07),
  _parcel('P02', x: 0.40, y: 0.28, w: 0.055, h: 0.075),
  _parcel('P03', x: 0.46, y: 0.2, w: 0.06, h: 0.085),
  _parcel('P04', x: 0.55, y: 0.25, w: 0.06, h: 0.085),
  _parcel('P05', x: 0.61, y: 0.25, w: 0.06, h: 0.075),
  _parcel('P06', x: 0.6, y: 0.38, w: 0.08, h: 0.1),
  _parcel('P07', x: 0.63, y: 0.45, w: 0.075, h: 0.09),
  _parcel('P08', x: 0.65, y: 0.54, w: 0.07, h: 0.11),
  _parcel('P09', x: 0.55, y: 0.57, w: 0.09, h: 0.13),
  _parcel('P10', x: 0.48, y: 0.63, w: 0.055, h: 0.105),
  _parcel('P11', x: 0.31, y: 0.52, w: 0.09, h: 0.13),
  _parcel('P12', x: 0.38, y: 0.49, w: 0.06, h: 0.075),
  _parcel('P13', x: 0.46, y: 0.51, w: 0.06, h: 0.095),
  _parcel('P14', x: 0.42, y: 0.4, w: 0.055, h: 0.06),
  _bridge('B01', x: 0.342, y: 0.39),
  _bridge('B02', x: 0.422, y: 0.474),
  _bridge('B03', x: 0.462, y: 0.474),
  _bridge('B04', x: 0.502, y: 0.493),
  _bridge('B05', x: 0.572, y: 0.531),
  _bridge('B06', x: 0.62, y: 0.532),
  _bridge('B07', x: 0.694, y: 0.548),
  _bridge('B08', x: 0.532, y: 0.522),
];
