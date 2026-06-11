import 'dart:io';

import 'package:flutter/material.dart';

const _uferwaldImagePath =
    'docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/'
    'talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png';
const _uferwaldLoopbackUrl = 'http://127.0.0.1:8765/$_uferwaldImagePath';

const _mapSize = 1254.0;
const _background = Color(0xFF06101A);
const _panel = Color(0xE60C1722);
const _panelBorder = Color(0x6636E7B7);
const _mint = Color(0xFF66E5B4);
const _cyan = Color(0xFF69D7FF);
const _rose = Color(0xFFFF8F9E);
const _violet = Color(0xFFC493FF);

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/previews/uferwald_map_interaction_preview.dart -d macos
//
// This file is intentionally not routed, exported, or connected to any
// productive app surface. It exists only for isolated Uferwald interaction
// checks against documentation imagery.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UferwaldMapInteractionPreviewApp());
}

class UferwaldMapInteractionPreviewApp extends StatelessWidget {
  const UferwaldMapInteractionPreviewApp({super.key});

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
      home: const UferwaldMapInteractionPreview(),
    );
  }
}

class UferwaldMapInteractionPreview extends StatefulWidget {
  const UferwaldMapInteractionPreview({super.key});

  @override
  State<UferwaldMapInteractionPreview> createState() =>
      _UferwaldMapInteractionPreviewState();
}

class _UferwaldMapInteractionPreviewState
    extends State<UferwaldMapInteractionPreview> {
  final TransformationController _mapController = TransformationController();
  bool _showOverlay = true;
  bool _viewWasInitialized = false;
  Size? _lastViewportSize;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(_uferwaldImagePath);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            _scheduleInitialView(viewportSize);

            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0C2130), _background],
                      ),
                    ),
                    child: _InteractiveUferwaldMap(
                      imageFile: imageFile,
                      controller: _mapController,
                      showOverlay: _showOverlay,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: _TopPreviewControls(
                    showOverlay: _showOverlay,
                    onOverlayChanged: (value) {
                      setState(() {
                        _showOverlay = value;
                      });
                    },
                    onResetView: _resetView,
                  ),
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _BoundaryNote(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _scheduleInitialView(Size viewportSize) {
    _lastViewportSize = viewportSize;
    if (_viewWasInitialized) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _viewWasInitialized) {
        return;
      }

      _mapController.value = _fitMapMatrix(viewportSize);
      _viewWasInitialized = true;
    });
  }

  void _resetView() {
    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    _mapController.value = _fitMapMatrix(viewportSize);
  }

  Matrix4 _fitMapMatrix(Size viewportSize) {
    final usableWidth = (viewportSize.width - 32).clamp(320.0, _mapSize);
    final usableHeight = (viewportSize.height - 32).clamp(320.0, _mapSize);
    final scale =
        (usableWidth < usableHeight ? usableWidth : usableHeight) /
        _mapSize *
        0.94;
    final dx = (viewportSize.width - (_mapSize * scale)) / 2;
    final dy = (viewportSize.height - (_mapSize * scale)) / 2;

    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }
}

class _InteractiveUferwaldMap extends StatelessWidget {
  const _InteractiveUferwaldMap({
    required this.imageFile,
    required this.controller,
    required this.showOverlay,
  });

  final File imageFile;
  final TransformationController controller;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final imageProvider = imageFile.existsSync()
        ? FileImage(imageFile) as ImageProvider
        : const NetworkImage(_uferwaldLoopbackUrl);

    return InteractiveViewer(
      transformationController: controller,
      constrained: false,
      minScale: 0.38,
      maxScale: 3.4,
      boundaryMargin: const EdgeInsets.all(420),
      panEnabled: true,
      scaleEnabled: true,
      child: SizedBox(
        width: _mapSize,
        height: _mapSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: imageProvider,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return const _MissingImageNotice();
              },
            ),
            if (showOverlay)
              const CustomPaint(painter: _UferwaldFreeBuildOverlayPainter()),
          ],
        ),
      ),
    );
  }
}

class _TopPreviewControls extends StatelessWidget {
  const _TopPreviewControls({
    required this.showOverlay,
    required this.onOverlayChanged,
    required this.onResetView,
  });

  final bool showOverlay;
  final ValueChanged<bool> onOverlayChanged;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CapacityPanel(showOverlay: showOverlay),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _ToolPanel(
                  showOverlay: showOverlay,
                  onOverlayChanged: onOverlayChanged,
                  onResetView: onResetView,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: _CapacityPanel(showOverlay: showOverlay)),
            const Spacer(),
            _ToolPanel(
              showOverlay: showOverlay,
              onOverlayChanged: onOverlayChanged,
              onResetView: onResetView,
            ),
          ],
        );
      },
    );
  }
}

class _CapacityPanel extends StatelessWidget {
  const _CapacityPanel({required this.showOverlay});

  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _panelBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Uferwald Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 9),
              const _CapacityDots(),
              const SizedBox(height: 8),
              Text(
                showOverlay
                    ? '6 freie Baukapazitäten. Die grünen Räume sind nur Auswahlräume.'
                    : '6 freie Baukapazitäten. Freie Ortswahl bleibt sichtbar.',
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 12,
                  height: 1.28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Keine festen Slots. Keine Kategorieplätze.',
                style: TextStyle(
                  color: Color(0xB8FFFFFF),
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityDots extends StatelessWidget {
  const _CapacityDots();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < 6; i++)
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _mint,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6636E7B7),
                  blurRadius: 9,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        const Text(
          '6 frei',
          style: TextStyle(
            color: _mint,
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ToolPanel extends StatelessWidget {
  const _ToolPanel({
    required this.showOverlay,
    required this.onOverlayChanged,
    required this.onResetView,
  });

  final bool showOverlay;
  final ValueChanged<bool> onOverlayChanged;
  final VoidCallback onResetView;

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
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_outlined, size: 18, color: _cyan),
                const SizedBox(width: 6),
                const Text(
                  'Overlay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                Switch(
                  value: showOverlay,
                  onChanged: onOverlayChanged,
                  activeThumbColor: _mint,
                  activeTrackColor: const Color(0x6636E7B7),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onResetView,
              icon: const Icon(Icons.center_focus_strong, size: 18),
              label: const Text('Ansicht zurücksetzen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xD90A111A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Lokale Dokumentations-Preview: Karte schieben, näher ran, Overlay prüfen. '
              'Es wird nichts gespeichert und nichts gebaut.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xE6FFFFFF),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingImageNotice extends StatelessWidget {
  const _MissingImageNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _rose),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Uferwald-Bild nicht gefunden. Starte die Preview vom Repo-Root, '
              'oder starte einen lokalen Docs-Server auf Port 8765.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UferwaldFreeBuildOverlayPainter extends CustomPainter {
  const _UferwaldFreeBuildOverlayPainter();

  static const _reviewZones = [
    _ReviewZone('R1', 0.40, 0.54, 0.145, 0.092),
    _ReviewZone('R2', 0.50, 0.51, 0.115, 0.075),
    _ReviewZone('R3', 0.33, 0.48, 0.105, 0.070),
    _ReviewZone('R4', 0.57, 0.42, 0.095, 0.064),
    _ReviewZone('R5', 0.61, 0.61, 0.112, 0.072),
    _ReviewZone('R6', 0.47, 0.67, 0.115, 0.071),
    _ReviewZone('R7', 0.29, 0.63, 0.090, 0.060),
    _ReviewZone('R8', 0.66, 0.51, 0.085, 0.056),
    _ReviewZone('R9', 0.46, 0.36, 0.090, 0.058),
    _ReviewZone('R10', 0.70, 0.70, 0.098, 0.062),
    _ReviewZone('R11', 0.55, 0.76, 0.086, 0.055),
    _ReviewZone('R12', 0.24, 0.39, 0.080, 0.052),
    _ReviewZone('R13', 0.74, 0.36, 0.076, 0.050),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawProtectedZones(canvas, size);
    _drawSortBands(canvas, size);
    _drawReviewZones(canvas, size);
    _drawAnchors(canvas, size);
  }

  void _drawProtectedZones(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..color = const Color(0x553EA7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final waterPath = Path()
      ..moveTo(size.width * 0.31, size.height * 0.19)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.28,
        size.width * 0.48,
        size.height * 0.50,
        size.width * 0.58,
        size.height * 0.73,
      );
    canvas.drawPath(waterPath, waterPaint);

    final grovePaint = Paint()
      ..color = const Color(0x3DEE6F84)
      ..style = PaintingStyle.fill;
    final grovePath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.79,
        size.height * 0.18,
        size.width * 0.81,
        size.height * 0.39,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.50,
        size.width * 0.58,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.31,
        size.width * 0.55,
        size.height * 0.18,
      );
    canvas.drawPath(grovePath, grovePaint);

    final terrainPaint = Paint()
      ..color = const Color(0x33FFD36E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.68),
        width: size.width * 0.22,
        height: size.height * 0.16,
      ),
      terrainPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.40),
        width: size.width * 0.18,
        height: size.height * 0.13,
      ),
      terrainPaint,
    );
  }

  void _drawSortBands(Canvas canvas, Size size) {
    final bandPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 2;
    final labelStyle = const TextStyle(
      color: Color(0xB3FFFFFF),
      fontSize: 22,
      height: 1,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );

    for (final y in [0.34, 0.63]) {
      final offsetY = size.height * y;
      canvas.drawLine(
        Offset(0, offsetY),
        Offset(size.width, offsetY),
        bandPaint,
      );
    }

    _drawText(
      canvas,
      'Hintergrund',
      Offset(size.width * 0.035, size.height * 0.30),
      labelStyle,
    );
    _drawText(
      canvas,
      'Mitte',
      Offset(size.width * 0.035, size.height * 0.58),
      labelStyle,
    );
    _drawText(
      canvas,
      'Vordergrund',
      Offset(size.width * 0.035, size.height * 0.86),
      labelStyle,
    );
  }

  void _drawReviewZones(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0x5536E7B7)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xDD66E5B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final attachmentPaint = Paint()
      ..color = const Color(0x4469D7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final zone in _reviewZones) {
      final rect = zone.toRect(size);
      final attachmentRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * 1.32,
        height: rect.height * 1.32,
      );
      canvas.drawOval(attachmentRect, attachmentPaint);
      canvas.drawOval(rect, fillPaint);
      canvas.drawOval(rect, strokePaint);
      _drawZoneLabel(canvas, zone.label, rect.center);
    }
  }

  void _drawAnchors(Canvas canvas, Size size) {
    final anchorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final anchorBorderPaint = Paint()
      ..color = _violet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final anchors = <String, Offset>{
      'Hub': Offset(size.width * 0.49, size.height * 0.51),
      'Fluss': Offset(size.width * 0.31, size.height * 0.19),
      'Hain': Offset(size.width * 0.67, size.height * 0.31),
    };

    for (final entry in anchors.entries) {
      canvas.drawCircle(entry.value, 10, anchorPaint);
      canvas.drawCircle(entry.value, 10, anchorBorderPaint);
      _drawText(
        canvas,
        entry.key,
        entry.value + const Offset(14, -8),
        const TextStyle(
          color: Colors.white,
          fontSize: 20,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      );
    }
  }

  void _drawZoneLabel(Canvas canvas, String label, Offset center) {
    final chipRect = Rect.fromCenter(center: center, width: 46, height: 30);
    final chipPaint = Paint()
      ..color = const Color(0xEE07131B)
      ..style = PaintingStyle.fill;
    final chipBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(15)),
      chipPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(15)),
      chipBorderPaint,
    );
    _drawText(
      canvas,
      label,
      Offset(chipRect.left + 9, chipRect.top + 6),
      const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _UferwaldFreeBuildOverlayPainter oldDelegate) {
    return false;
  }
}

class _ReviewZone {
  const _ReviewZone(this.label, this.x, this.y, this.rx, this.ry);

  final String label;
  final double x;
  final double y;
  final double rx;
  final double ry;

  Rect toRect(Size size) {
    return Rect.fromCenter(
      center: Offset(size.width * x, size.height * y),
      width: size.width * rx,
      height: size.height * ry,
    );
  }
}
