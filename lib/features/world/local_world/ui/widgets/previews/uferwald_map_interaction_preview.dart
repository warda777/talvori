import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';

const _uferwaldImagePath =
    'docs/world_design/previews/m16_cp_uferwald_layer_candidate_intake_and_qa/'
    'talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png';
const _uferwaldOverlayImagePath =
    'docs/world_design/previews/m16_cr_uferwald_anchor_zone_layer_overlay_plan/'
    'talvori_uferwald_free_build_capacity_overlay_1x.png';
const _docsHost = String.fromEnvironment(
  'TALVORI_DOCS_HOST',
  defaultValue: '127.0.0.1',
);
const _docsPort = 8765;

const _mapSize = 1254.0;
const _background = Color(0xFF06101A);
const _panel = Color(0xE60C1722);
const _panelBorder = Color(0x6636E7B7);
const _mint = Color(0xFF66E5B4);
const _cyan = Color(0xFF69D7FF);
const _rose = Color(0xFFFF8F9E);
const _violet = Color(0xFFC493FF);

const _reviewZones = [
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
    extends State<UferwaldMapInteractionPreview>
    with SingleTickerProviderStateMixin {
  final TransformationController _mapController = TransformationController();
  late final AnimationController _cameraReturnController;
  Animation<Matrix4>? _cameraReturnAnimation;
  bool _showOverlay = true;
  bool _viewWasInitialized = false;
  String? _selectedZoneLabel;
  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
    _cameraReturnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_handleCameraReturnTick);
  }

  @override
  void dispose() {
    _cameraReturnController
      ..removeListener(_handleCameraReturnTick)
      ..dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(_uferwaldImagePath);
    final overlayImageFile = File(_uferwaldOverlayImagePath);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            final cameraMetrics = _UferwaldCameraMetrics.forViewport(
              viewportSize,
            );
            _scheduleInitialView(viewportSize);

            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.1, -0.2),
                          radius: 1.2,
                          colors: [
                            Color(0xFF1C5162),
                            Color(0xFF0B2637),
                            _background,
                          ],
                          stops: [0, 0.48, 1],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _InteractiveUferwaldMap(
                            imageFile: imageFile,
                            overlayImageFile: overlayImageFile,
                            controller: _mapController,
                            showOverlay: _showOverlay,
                            selectedZoneLabel: _selectedZoneLabel,
                            minScale: cameraMetrics.minScale,
                            maxScale: cameraMetrics.maxScale,
                            onInteractionStart: _handleInteractionStart,
                            onInteractionEnd: _handleInteractionEnd,
                            onZoneSelected: _selectZone,
                          ),
                          const IgnorePointer(child: _MapEdgeMask()),
                        ],
                      ),
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
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _BottomPreviewNote(
                    selectedZoneLabel: _selectedZoneLabel,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _scheduleInitialView(Size viewportSize) {
    final previousViewportSize = _lastViewportSize;
    final viewportChanged = previousViewportSize != viewportSize;
    _lastViewportSize = viewportSize;
    if (_viewWasInitialized && !viewportChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_viewWasInitialized) {
        _mapController.value = _playableCoverMapMatrix(viewportSize);
        _viewWasInitialized = true;
        return;
      }

      _mapController.value = _clampedMapMatrix(
        viewportSize,
        _mapController.value,
      );
    });
  }

  void _resetView() {
    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    _animateCameraTo(_playableCoverMapMatrix(viewportSize));
  }

  void _selectZone(String? label) {
    setState(() {
      _selectedZoneLabel = label;
    });
  }

  void _handleInteractionStart(ScaleStartDetails details) {
    _cameraReturnController.stop();
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    final clampedMatrix = _clampedMapMatrix(viewportSize, _mapController.value);
    if (_matrixCloseEnough(_mapController.value, clampedMatrix)) {
      return;
    }

    _animateCameraTo(clampedMatrix);
  }

  void _handleCameraReturnTick() {
    final value = _cameraReturnAnimation?.value;
    if (value != null) {
      _mapController.value = value;
    }
  }

  void _animateCameraTo(Matrix4 targetMatrix) {
    _cameraReturnController.stop();
    _cameraReturnAnimation =
        Matrix4Tween(begin: _mapController.value, end: targetMatrix).animate(
          CurvedAnimation(
            parent: _cameraReturnController,
            curve: Curves.easeOutCubic,
          ),
        );
    _cameraReturnController.forward(from: 0);
  }

  Matrix4 _playableCoverMapMatrix(Size viewportSize) {
    final metrics = _UferwaldCameraMetrics.forViewport(viewportSize);
    return _centeredMapMatrix(viewportSize, metrics.initialScale);
  }

  Matrix4 _clampedMapMatrix(Size viewportSize, Matrix4 matrix) {
    final metrics = _UferwaldCameraMetrics.forViewport(viewportSize);
    final scale = matrix
        .getMaxScaleOnAxis()
        .clamp(metrics.minScale, metrics.maxScale)
        .toDouble();
    final scaledMapSize = _mapSize * scale;
    final storage = matrix.storage;
    final dx = _clampedAxisOffset(
      storage[12],
      viewportSize.width,
      scaledMapSize,
    );
    final dy = _clampedAxisOffset(
      storage[13],
      viewportSize.height,
      scaledMapSize,
    );

    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  Matrix4 _centeredMapMatrix(Size viewportSize, double scale) {
    final dx = (viewportSize.width - (_mapSize * scale)) / 2;
    final dy = (viewportSize.height - (_mapSize * scale)) / 2;

    return Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  double _clampedAxisOffset(
    double offset,
    double viewportExtent,
    double scaledMapExtent,
  ) {
    if (scaledMapExtent <= viewportExtent) {
      return (viewportExtent - scaledMapExtent) / 2;
    }

    final minOffset = viewportExtent - scaledMapExtent;
    return offset.clamp(minOffset, 0).toDouble();
  }

  bool _matrixCloseEnough(Matrix4 a, Matrix4 b) {
    final aStorage = a.storage;
    final bStorage = b.storage;
    for (var i = 0; i < 16; i++) {
      if ((aStorage[i] - bStorage[i]).abs() > 0.01) {
        return false;
      }
    }

    return true;
  }
}

class _UferwaldCameraMetrics {
  const _UferwaldCameraMetrics({
    required this.coverScale,
    required this.containScale,
    required this.minScale,
    required this.initialScale,
    required this.overviewScale,
    required this.maxScale,
  });

  factory _UferwaldCameraMetrics.forViewport(Size viewportSize) {
    final coverScale = math.max(
      viewportSize.width / _mapSize,
      viewportSize.height / _mapSize,
    );
    final containScale = math.min(
      viewportSize.width / _mapSize,
      viewportSize.height / _mapSize,
    );

    return _UferwaldCameraMetrics(
      coverScale: coverScale,
      containScale: containScale,
      minScale: coverScale * 1.02,
      initialScale: coverScale * 1.12,
      overviewScale: containScale * 0.94,
      maxScale: coverScale * 3.0,
    );
  }

  final double coverScale;
  final double containScale;
  final double minScale;
  final double initialScale;
  final double overviewScale;
  final double maxScale;
}

class _InteractiveUferwaldMap extends StatelessWidget {
  const _InteractiveUferwaldMap({
    required this.imageFile,
    required this.overlayImageFile,
    required this.controller,
    required this.showOverlay,
    required this.selectedZoneLabel,
    required this.minScale,
    required this.maxScale,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.onZoneSelected,
  });

  final File imageFile;
  final File overlayImageFile;
  final TransformationController controller;
  final bool showOverlay;
  final String? selectedZoneLabel;
  final double minScale;
  final double maxScale;
  final GestureScaleStartCallback onInteractionStart;
  final GestureScaleEndCallback onInteractionEnd;
  final ValueChanged<String?> onZoneSelected;

  @override
  Widget build(BuildContext context) {
    final baseImageUrl = _docsImageUrl(_uferwaldImagePath);
    final overlayImageUrl = _docsImageUrl(_uferwaldOverlayImagePath);
    final baseImageProvider = _docsImageProvider(imageFile, baseImageUrl);
    final overlayImageProvider = _docsImageProvider(
      overlayImageFile,
      overlayImageUrl,
    );

    return InteractiveViewer(
      transformationController: controller,
      constrained: false,
      minScale: minScale,
      maxScale: maxScale,
      boundaryMargin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      panEnabled: true,
      scaleEnabled: true,
      panAxis: PanAxis.free,
      onInteractionStart: onInteractionStart,
      onInteractionEnd: onInteractionEnd,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          onZoneSelected(_zoneAt(details.localPosition)?.label);
        },
        child: SizedBox(
          width: _mapSize,
          height: _mapSize,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: baseImageProvider,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _MissingImageNotice(imageUrl: baseImageUrl);
                },
              ),
              if (showOverlay) ...[
                _ImageLoadProbe(
                  imageProvider: overlayImageProvider,
                  imageUrl: overlayImageUrl,
                  label: 'Overlay-Bild',
                ),
                CustomPaint(
                  painter: _UferwaldFreeBuildOverlayPainter(
                    selectedZoneLabel: selectedZoneLabel,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _ReviewZone? _zoneAt(Offset localPosition) {
    for (final zone in _reviewZones.reversed) {
      if (zone.contains(localPosition, const Size(_mapSize, _mapSize))) {
        return zone;
      }
    }

    return null;
  }
}

class _MapEdgeMask extends StatelessWidget {
  const _MapEdgeMask();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.04),
              radius: 0.92,
              colors: [Color(0x0006101A), Color(0x0006101A), Color(0x9906101A)],
              stops: [0, 0.70, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x7706101A),
                Color(0x0006101A),
                Color(0x0006101A),
                Color(0x8806101A),
              ],
              stops: [0, 0.16, 0.78, 1],
            ),
          ),
        ),
      ],
    );
  }
}

String _docsImageUrl(String path) {
  return 'http://$_docsHost:$_docsPort/$path';
}

ImageProvider _docsImageProvider(File file, String imageUrl) {
  if (file.existsSync()) {
    return FileImage(file);
  }

  return NetworkImage(imageUrl);
}

class _ImageLoadProbe extends StatefulWidget {
  const _ImageLoadProbe({
    required this.imageProvider,
    required this.imageUrl,
    required this.label,
  });

  final ImageProvider imageProvider;
  final String imageUrl;
  final String label;

  @override
  State<_ImageLoadProbe> createState() => _ImageLoadProbeState();
}

class _ImageLoadProbeState extends State<_ImageLoadProbe> {
  ImageStream? _imageStream;
  late ImageStreamListener _imageListener;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _imageListener = ImageStreamListener(
      (_, _) {
        if (mounted && _error != null) {
          setState(() {
            _error = null;
          });
        }
      },
      onError: (error, _) {
        if (mounted) {
          setState(() {
            _error = error;
          });
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _ImageLoadProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 18,
      right: 18,
      bottom: 18,
      child: _ImageLoadError(label: widget.label, imageUrl: widget.imageUrl),
    );
  }

  void _resolveImage() {
    _imageStream?.removeListener(_imageListener);
    final imageStream = widget.imageProvider.resolve(
      createLocalImageConfiguration(context),
    );
    _imageStream = imageStream;
    imageStream.addListener(_imageListener);
  }
}

class _ImageLoadError extends StatelessWidget {
  const _ImageLoadError({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF20A111A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rose),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '$label nicht gefunden:\n$imageUrl',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
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
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _CompactCapacityChip()),
              const SizedBox(width: 8),
              _CompactToolPanel(
                showOverlay: showOverlay,
                onOverlayChanged: onOverlayChanged,
                onResetView: onResetView,
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

class _CompactCapacityChip extends StatelessWidget {
  const _CompactCapacityChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Text(
              '6 frei',
              style: TextStyle(
                color: _mint,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(width: 9),
            Expanded(child: _TinyCapacityDots()),
          ],
        ),
      ),
    );
  }
}

class _TinyCapacityDots extends StatelessWidget {
  const _TinyCapacityDots();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var i = 0; i < 6; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              color: _mint,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: const SizedBox(width: 12, height: 12),
          ),
      ],
    );
  }
}

class _CompactToolPanel extends StatelessWidget {
  const _CompactToolPanel({
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
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: showOverlay ? 'Overlay ausblenden' : 'Overlay anzeigen',
              child: IconButton(
                onPressed: () => onOverlayChanged(!showOverlay),
                icon: Icon(
                  showOverlay ? Icons.layers : Icons.layers_clear,
                  color: showOverlay ? _mint : Colors.white70,
                ),
              ),
            ),
            Tooltip(
              message: 'Ansicht zurücksetzen',
              child: IconButton(
                onPressed: onResetView,
                icon: const Icon(Icons.center_focus_strong, color: _cyan),
              ),
            ),
          ],
        ),
      ),
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

class _BottomPreviewNote extends StatelessWidget {
  const _BottomPreviewNote({required this.selectedZoneLabel});

  final String? selectedZoneLabel;

  @override
  Widget build(BuildContext context) {
    final selectedZoneLabel = this.selectedZoneLabel;
    final text = selectedZoneLabel == null
        ? 'Karte schieben, näher ran. Keine Speicherung, keine Bebauung.'
        : '$selectedZoneLabel ausgewählt · Auswahlraum, kein fester Slot · keine Bebauung.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE60A111A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
  const _MissingImageNotice({required this.imageUrl});

  final String imageUrl;

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
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Uferwald-Bild nicht gefunden. Starte die Preview vom Repo-Root, '
              'oder starte einen lokalen Docs-Server auf Port 8765.\n\n'
              '$imageUrl',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
  const _UferwaldFreeBuildOverlayPainter({required this.selectedZoneLabel});

  final String? selectedZoneLabel;

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
    final selectedFillPaint = Paint()
      ..color = const Color(0x88FFD36E)
      ..style = PaintingStyle.fill;
    final selectedStrokePaint = Paint()
      ..color = const Color(0xFFFFF2A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final selectedGlowPaint = Paint()
      ..color = const Color(0x66FFD36E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    for (final zone in _reviewZones) {
      final rect = zone.toRect(size);
      final isSelected = zone.label == selectedZoneLabel;
      final attachmentRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width * 1.32,
        height: rect.height * 1.32,
      );
      canvas.drawOval(attachmentRect, attachmentPaint);
      if (isSelected) {
        canvas.drawOval(
          Rect.fromCenter(
            center: rect.center,
            width: rect.width * 1.58,
            height: rect.height * 1.58,
          ),
          selectedGlowPaint,
        );
        canvas.drawOval(rect, selectedFillPaint);
        canvas.drawOval(rect, selectedStrokePaint);
      } else {
        canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
      }
      _drawZoneLabel(canvas, zone.label, rect.center, isSelected: isSelected);
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

  void _drawZoneLabel(
    Canvas canvas,
    String label,
    Offset center, {
    required bool isSelected,
  }) {
    final chipRect = Rect.fromCenter(
      center: center,
      width: isSelected ? 56 : 46,
      height: isSelected ? 36 : 30,
    );
    final chipPaint = Paint()
      ..color = isSelected ? const Color(0xFFF5C758) : const Color(0xEE07131B)
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
      Offset(chipRect.left + (isSelected ? 12 : 9), chipRect.top + 6),
      TextStyle(
        color: isSelected ? const Color(0xFF07131B) : Colors.white,
        fontSize: isSelected ? 18 : 15,
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
    return oldDelegate.selectedZoneLabel != selectedZoneLabel;
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

  bool contains(Offset point, Size size) {
    final rect = toRect(size);
    final dx = (point.dx - rect.center.dx) / (rect.width / 2);
    final dy = (point.dy - rect.center.dy) / (rect.height / 2);
    return dx * dx + dy * dy <= 1;
  }
}
