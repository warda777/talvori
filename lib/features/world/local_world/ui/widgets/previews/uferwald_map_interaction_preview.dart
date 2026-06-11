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

const _visitWaypoints = [
  _VisitWaypoint('Start', 0.33, 0.68),
  _VisitWaypoint('Hub', 0.46, 0.58),
  _VisitWaypoint('Lichtung', 0.50, 0.51),
  _VisitWaypoint('Hain', 0.62, 0.43),
  _VisitWaypoint('Blick', 0.68, 0.38),
];

enum _UferwaldCameraMode { buildMap, overview, visitWander, objectFocus }

extension _UferwaldCameraModeLabel on _UferwaldCameraMode {
  String get label {
    switch (this) {
      case _UferwaldCameraMode.buildMap:
        return 'Build/Map';
      case _UferwaldCameraMode.overview:
        return 'Overview';
      case _UferwaldCameraMode.visitWander:
        return 'Visit';
      case _UferwaldCameraMode.objectFocus:
        return 'Object';
    }
  }

  String get shortLabel {
    switch (this) {
      case _UferwaldCameraMode.buildMap:
        return 'Bauen';
      case _UferwaldCameraMode.overview:
        return 'Ueberblick';
      case _UferwaldCameraMode.visitWander:
        return 'Besuch';
      case _UferwaldCameraMode.objectFocus:
        return 'Fokus';
    }
  }

  String get compactLabel {
    switch (this) {
      case _UferwaldCameraMode.buildMap:
        return 'Bau';
      case _UferwaldCameraMode.overview:
        return 'Alle';
      case _UferwaldCameraMode.visitWander:
        return 'Weg';
      case _UferwaldCameraMode.objectFocus:
        return 'Obj';
    }
  }

  IconData get icon {
    switch (this) {
      case _UferwaldCameraMode.buildMap:
        return Icons.map_outlined;
      case _UferwaldCameraMode.overview:
        return Icons.public;
      case _UferwaldCameraMode.visitWander:
        return Icons.directions_walk;
      case _UferwaldCameraMode.objectFocus:
        return Icons.center_focus_strong;
    }
  }

  String get hint {
    switch (this) {
      case _UferwaldCameraMode.buildMap:
        return '6 freie Baukapazitaeten, Zonen antippbar.';
      case _UferwaldCameraMode.overview:
        return 'Review-Blick auf die ganze Insel.';
      case _UferwaldCameraMode.visitWander:
        return 'Ruhiger Besuchsblick, kein Bau-Overlay.';
      case _UferwaldCameraMode.objectFocus:
        return 'Ausgewaehlten Bereich mit Umgebung zeigen.';
    }
  }
}

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
    with TickerProviderStateMixin {
  final TransformationController _mapController = TransformationController();
  late final AnimationController _cameraReturnController;
  late final AnimationController _walkerMoveController;
  Animation<Matrix4>? _cameraReturnAnimation;
  Animation<Offset>? _walkerMoveAnimation;
  bool _showOverlay = true;
  bool _viewWasInitialized = false;
  _UferwaldCameraMode _cameraMode = _UferwaldCameraMode.buildMap;
  String? _selectedZoneLabel;
  int _walkerWaypointIndex = 0;
  Offset _walkerNormalizedPosition = _visitWaypoints.first.normalizedCenter;
  Size? _lastViewportSize;

  @override
  void initState() {
    super.initState();
    _cameraReturnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(_handleCameraReturnTick);
    _walkerMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addListener(_handleWalkerMoveTick);
  }

  @override
  void dispose() {
    _cameraReturnController
      ..removeListener(_handleCameraReturnTick)
      ..dispose();
    _walkerMoveController
      ..removeListener(_handleWalkerMoveTick)
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
            final cameraSettings = _UferwaldCameraSettings.forMode(
              viewportSize,
              _cameraMode,
            );
            _scheduleInitialView(viewportSize);
            final showFreeBuildOverlay =
                _showOverlay &&
                (_cameraMode == _UferwaldCameraMode.buildMap ||
                    _cameraMode == _UferwaldCameraMode.overview);

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
                            cameraMode: _cameraMode,
                            showFreeBuildOverlay: showFreeBuildOverlay,
                            selectedZoneLabel: _selectedZoneLabel,
                            walkerPosition: _walkerNormalizedPosition,
                            activeVisitWaypointIndex: _walkerWaypointIndex,
                            minScale: cameraSettings.minScale,
                            maxScale: cameraSettings.maxScale,
                            onInteractionStart: _handleInteractionStart,
                            onInteractionEnd: _handleInteractionEnd,
                            onZoneSelected: _selectZone,
                            onVisitWaypointSelected: _moveWalkerToWaypoint,
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
                    cameraMode: _cameraMode,
                    showOverlay: _showOverlay,
                    overlayEnabled:
                        _cameraMode != _UferwaldCameraMode.visitWander,
                    selectedZoneLabel: _selectedZoneLabel,
                    onCameraModeChanged: _setCameraMode,
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
                    cameraMode: _cameraMode,
                    selectedZoneLabel: _selectedZoneLabel,
                  ),
                ),
                if (_cameraMode == _UferwaldCameraMode.visitWander)
                  Positioned(
                    right: 16,
                    bottom: 82,
                    child: _VisitWalkerPanel(
                      currentWaypoint: _currentVisitWaypoint,
                      nextWaypoint: _nextVisitWaypoint,
                      onNextStep: _moveWalkerToNextWaypoint,
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
        _mapController.value = _matrixForMode(viewportSize, _cameraMode);
        _viewWasInitialized = true;
        return;
      }

      _mapController.value = _clampedMapMatrix(
        viewportSize,
        _mapController.value,
        _cameraMode,
      );
    });
  }

  void _resetView() {
    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    _animateCameraTo(_matrixForMode(viewportSize, _cameraMode));
  }

  void _selectZone(String? label) {
    setState(() {
      _selectedZoneLabel = label;
    });

    if (_cameraMode == _UferwaldCameraMode.objectFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewportSize = _lastViewportSize;
        if (mounted && viewportSize != null) {
          _animateCameraTo(_matrixForMode(viewportSize, _cameraMode));
        }
      });
    }
  }

  void _setCameraMode(_UferwaldCameraMode mode) {
    setState(() {
      _cameraMode = mode;
      if (mode == _UferwaldCameraMode.objectFocus) {
        _selectedZoneLabel ??= 'R1';
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewportSize = _lastViewportSize;
      if (mounted && viewportSize != null) {
        _animateCameraTo(_matrixForMode(viewportSize, mode));
      }
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

    final clampedMatrix = _clampedMapMatrix(
      viewportSize,
      _mapController.value,
      _cameraMode,
    );
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

  void _handleWalkerMoveTick() {
    final value = _walkerMoveAnimation?.value;
    if (value != null && mounted) {
      setState(() {
        _walkerNormalizedPosition = value;
      });
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

  Matrix4 _matrixForMode(Size viewportSize, _UferwaldCameraMode mode) {
    final settings = _UferwaldCameraSettings.forMode(viewportSize, mode);
    switch (mode) {
      case _UferwaldCameraMode.buildMap:
      case _UferwaldCameraMode.overview:
        return _centeredMapMatrix(viewportSize, settings.initialScale);
      case _UferwaldCameraMode.visitWander:
        return _focusedMapMatrix(
          viewportSize,
          settings.initialScale,
          _walkerNormalizedPosition,
        );
      case _UferwaldCameraMode.objectFocus:
        return _focusedMapMatrix(
          viewportSize,
          settings.initialScale,
          _selectedReviewZone?.normalizedCenter ?? const Offset(0.40, 0.54),
        );
    }
  }

  Matrix4 _clampedMapMatrix(
    Size viewportSize,
    Matrix4 matrix,
    _UferwaldCameraMode mode,
  ) {
    final metrics = _UferwaldCameraSettings.forMode(viewportSize, mode);
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

  Matrix4 _focusedMapMatrix(
    Size viewportSize,
    double scale,
    Offset normalizedCenter,
  ) {
    final scaledMapSize = _mapSize * scale;
    final dx = _clampedAxisOffset(
      (viewportSize.width / 2) - (normalizedCenter.dx * scaledMapSize),
      viewportSize.width,
      scaledMapSize,
    );
    final dy = _clampedAxisOffset(
      (viewportSize.height / 2) - (normalizedCenter.dy * scaledMapSize),
      viewportSize.height,
      scaledMapSize,
    );

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

  void _moveWalkerToNextWaypoint() {
    _moveWalkerToWaypoint(_nextVisitWaypointIndex);
  }

  void _moveWalkerToWaypoint(int waypointIndex) {
    if (waypointIndex == _walkerWaypointIndex ||
        waypointIndex < 0 ||
        waypointIndex >= _visitWaypoints.length) {
      return;
    }

    final target = _visitWaypoints[waypointIndex].normalizedCenter;
    _walkerMoveController.stop();
    _walkerMoveAnimation =
        Tween<Offset>(begin: _walkerNormalizedPosition, end: target).animate(
          CurvedAnimation(
            parent: _walkerMoveController,
            curve: Curves.easeInOutCubic,
          ),
        );

    setState(() {
      _walkerWaypointIndex = waypointIndex;
    });
    _walkerMoveController.forward(from: 0);
    _followWalker(target);
  }

  void _followWalker(Offset target) {
    if (_cameraMode != _UferwaldCameraMode.visitWander) {
      return;
    }

    final viewportSize = _lastViewportSize;
    if (viewportSize == null) {
      return;
    }

    final settings = _UferwaldCameraSettings.forMode(
      viewportSize,
      _UferwaldCameraMode.visitWander,
    );
    final currentScale = _mapController.value
        .getMaxScaleOnAxis()
        .clamp(settings.minScale, settings.maxScale)
        .toDouble();
    _animateCameraTo(_focusedMapMatrix(viewportSize, currentScale, target));
  }

  _ReviewZone? get _selectedReviewZone {
    final label = _selectedZoneLabel;
    if (label == null) {
      return null;
    }

    for (final zone in _reviewZones) {
      if (zone.label == label) {
        return zone;
      }
    }

    return null;
  }

  int get _nextVisitWaypointIndex {
    return (_walkerWaypointIndex + 1) % _visitWaypoints.length;
  }

  _VisitWaypoint get _currentVisitWaypoint {
    return _visitWaypoints[_walkerWaypointIndex];
  }

  _VisitWaypoint get _nextVisitWaypoint {
    return _visitWaypoints[_nextVisitWaypointIndex];
  }
}

class _UferwaldCameraSettings {
  const _UferwaldCameraSettings({
    required this.coverScale,
    required this.containScale,
    required this.minScale,
    required this.initialScale,
    required this.overviewScale,
    required this.maxScale,
  });

  factory _UferwaldCameraSettings.forMode(
    Size viewportSize,
    _UferwaldCameraMode mode,
  ) {
    final coverScale = math.max(
      viewportSize.width / _mapSize,
      viewportSize.height / _mapSize,
    );
    final containScale = math.min(
      viewportSize.width / _mapSize,
      viewportSize.height / _mapSize,
    );

    switch (mode) {
      case _UferwaldCameraMode.buildMap:
        return _UferwaldCameraSettings(
          coverScale: coverScale,
          containScale: containScale,
          minScale: coverScale * 1.02,
          initialScale: coverScale * 1.12,
          overviewScale: containScale * 0.94,
          maxScale: coverScale * 3.0,
        );
      case _UferwaldCameraMode.overview:
        return _UferwaldCameraSettings(
          coverScale: coverScale,
          containScale: containScale,
          minScale: containScale * 0.84,
          initialScale: containScale * 0.94,
          overviewScale: containScale * 0.94,
          maxScale: coverScale * 2.4,
        );
      case _UferwaldCameraMode.visitWander:
        return _UferwaldCameraSettings(
          coverScale: coverScale,
          containScale: containScale,
          minScale: coverScale * 1.08,
          initialScale: coverScale * 1.42,
          overviewScale: containScale * 0.94,
          maxScale: coverScale * 3.2,
        );
      case _UferwaldCameraMode.objectFocus:
        return _UferwaldCameraSettings(
          coverScale: coverScale,
          containScale: containScale,
          minScale: coverScale * 1.12,
          initialScale: coverScale * 2.05,
          overviewScale: containScale * 0.94,
          maxScale: coverScale * 3.6,
        );
    }
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
    required this.cameraMode,
    required this.showFreeBuildOverlay,
    required this.selectedZoneLabel,
    required this.walkerPosition,
    required this.activeVisitWaypointIndex,
    required this.minScale,
    required this.maxScale,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.onZoneSelected,
    required this.onVisitWaypointSelected,
  });

  final File imageFile;
  final File overlayImageFile;
  final TransformationController controller;
  final _UferwaldCameraMode cameraMode;
  final bool showFreeBuildOverlay;
  final String? selectedZoneLabel;
  final Offset walkerPosition;
  final int activeVisitWaypointIndex;
  final double minScale;
  final double maxScale;
  final GestureScaleStartCallback onInteractionStart;
  final GestureScaleEndCallback onInteractionEnd;
  final ValueChanged<String?> onZoneSelected;
  final ValueChanged<int> onVisitWaypointSelected;

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
          if (cameraMode == _UferwaldCameraMode.visitWander) {
            final waypointIndex = _visitWaypointAt(details.localPosition);
            if (waypointIndex != null) {
              onVisitWaypointSelected(waypointIndex);
            }
            return;
          }

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
              if (showFreeBuildOverlay) ...[
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
              if (cameraMode == _UferwaldCameraMode.objectFocus)
                CustomPaint(
                  painter: _UferwaldObjectFocusPainter(
                    selectedZoneLabel: selectedZoneLabel,
                  ),
                ),
              if (cameraMode == _UferwaldCameraMode.visitWander)
                CustomPaint(
                  painter: _UferwaldVisitPathPainter(
                    walkerPosition: walkerPosition,
                    activeWaypointIndex: activeVisitWaypointIndex,
                  ),
                ),
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

  int? _visitWaypointAt(Offset localPosition) {
    for (var i = 0; i < _visitWaypoints.length; i++) {
      final waypoint = _visitWaypoints[i];
      final center = waypoint.toOffset(const Size(_mapSize, _mapSize));
      if ((localPosition - center).distance <= 40) {
        return i;
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
    required this.cameraMode,
    required this.showOverlay,
    required this.overlayEnabled,
    required this.selectedZoneLabel,
    required this.onCameraModeChanged,
    required this.onOverlayChanged,
    required this.onResetView,
  });

  final _UferwaldCameraMode cameraMode;
  final bool showOverlay;
  final bool overlayEnabled;
  final String? selectedZoneLabel;
  final ValueChanged<_UferwaldCameraMode> onCameraModeChanged;
  final ValueChanged<bool> onOverlayChanged;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CameraModeSelector(
                cameraMode: cameraMode,
                compact: true,
                onCameraModeChanged: onCameraModeChanged,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CompactModeChip(
                      cameraMode: cameraMode,
                      selectedZoneLabel: selectedZoneLabel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CompactToolPanel(
                    showOverlay: showOverlay,
                    overlayEnabled: overlayEnabled,
                    onOverlayChanged: onOverlayChanged,
                    onResetView: onResetView,
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: _CapacityPanel(
                cameraMode: cameraMode,
                showOverlay: showOverlay,
                selectedZoneLabel: selectedZoneLabel,
              ),
            ),
            const Spacer(),
            _CameraModeSelector(
              cameraMode: cameraMode,
              compact: false,
              onCameraModeChanged: onCameraModeChanged,
            ),
            const Spacer(),
            _ToolPanel(
              showOverlay: showOverlay,
              overlayEnabled: overlayEnabled,
              onOverlayChanged: onOverlayChanged,
              onResetView: onResetView,
            ),
          ],
        );
      },
    );
  }
}

class _CameraModeSelector extends StatelessWidget {
  const _CameraModeSelector({
    required this.cameraMode,
    required this.compact,
    required this.onCameraModeChanged,
  });

  final _UferwaldCameraMode cameraMode;
  final bool compact;
  final ValueChanged<_UferwaldCameraMode> onCameraModeChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
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
        child: SegmentedButton<_UferwaldCameraMode>(
          segments: [
            for (final mode in _UferwaldCameraMode.values)
              ButtonSegment(
                value: mode,
                icon: Icon(mode.icon, size: 17),
                label: Text(compact ? mode.compactLabel : mode.shortLabel),
              ),
          ],
          selected: {cameraMode},
          onSelectionChanged: (selection) {
            onCameraModeChanged(selection.first);
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF06101A);
              }

              return Colors.white;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _mint;
              }

              return Colors.transparent;
            }),
            side: const WidgetStatePropertyAll(BorderSide.none),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactModeChip extends StatelessWidget {
  const _CompactModeChip({
    required this.cameraMode,
    required this.selectedZoneLabel,
  });

  final _UferwaldCameraMode cameraMode;
  final String? selectedZoneLabel;

  @override
  Widget build(BuildContext context) {
    final isBuildMode = cameraMode == _UferwaldCameraMode.buildMap;
    final text = isBuildMode
        ? '6 frei'
        : cameraMode == _UferwaldCameraMode.objectFocus
        ? '${selectedZoneLabel ?? 'R1'} Fokus'
        : cameraMode.shortLabel;

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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Icon(cameraMode.icon, color: _mint, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: _mint,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            if (isBuildMode) ...[
              const SizedBox(width: 9),
              const Expanded(child: _TinyCapacityDots()),
            ],
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
    required this.overlayEnabled,
    required this.onOverlayChanged,
    required this.onResetView,
  });

  final bool showOverlay;
  final bool overlayEnabled;
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
              message: overlayEnabled
                  ? showOverlay
                        ? 'Overlay ausblenden'
                        : 'Overlay anzeigen'
                  : 'Im Besuchsmodus ausgeblendet',
              child: IconButton(
                onPressed: overlayEnabled
                    ? () => onOverlayChanged(!showOverlay)
                    : null,
                icon: Icon(
                  showOverlay ? Icons.layers : Icons.layers_clear,
                  color: overlayEnabled
                      ? showOverlay
                            ? _mint
                            : Colors.white70
                      : Colors.white30,
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
  const _CapacityPanel({
    required this.cameraMode,
    required this.showOverlay,
    required this.selectedZoneLabel,
  });

  final _UferwaldCameraMode cameraMode;
  final bool showOverlay;
  final String? selectedZoneLabel;

  @override
  Widget build(BuildContext context) {
    final title = cameraMode == _UferwaldCameraMode.buildMap
        ? 'Uferwald Preview'
        : cameraMode.label;
    final body = _modeBodyText(cameraMode, showOverlay, selectedZoneLabel);

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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 9),
              if (cameraMode == _UferwaldCameraMode.buildMap) ...[
                const _CapacityDots(),
                const SizedBox(height: 8),
              ],
              Text(
                body,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 12,
                  height: 1.28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keine Speicherung. Kein BuildState. Keine App-Integration.',
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

  String _modeBodyText(
    _UferwaldCameraMode mode,
    bool showOverlay,
    String? selectedZoneLabel,
  ) {
    switch (mode) {
      case _UferwaldCameraMode.buildMap:
        return showOverlay
            ? '6 freie Baukapazitaeten. Die gruenen Raeume sind nur Auswahlraeume.'
            : '6 freie Baukapazitaeten. Freie Ortswahl bleibt sichtbar.';
      case _UferwaldCameraMode.overview:
        return '${mode.hint} Nicht der normale Bau-Default.';
      case _UferwaldCameraMode.visitWander:
        return mode.hint;
      case _UferwaldCameraMode.objectFocus:
        return '${selectedZoneLabel ?? 'R1'}: ${mode.hint}';
    }
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
    required this.overlayEnabled,
    required this.onOverlayChanged,
    required this.onResetView,
  });

  final bool showOverlay;
  final bool overlayEnabled;
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
                  onChanged: overlayEnabled ? onOverlayChanged : null,
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
  const _BottomPreviewNote({
    required this.cameraMode,
    required this.selectedZoneLabel,
  });

  final _UferwaldCameraMode cameraMode;
  final String? selectedZoneLabel;

  @override
  Widget build(BuildContext context) {
    final text = _noteText(cameraMode, selectedZoneLabel);

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

  String _noteText(_UferwaldCameraMode mode, String? selectedZoneLabel) {
    switch (mode) {
      case _UferwaldCameraMode.buildMap:
        return selectedZoneLabel == null
            ? 'Karte schieben, naeher ran. 6 freie Baukapazitaeten.'
            : '$selectedZoneLabel ausgewaehlt · Auswahlraum, kein fester Slot.';
      case _UferwaldCameraMode.overview:
        return 'Overview/Review: komplette Insel sichtbar, nicht der normale Bau-Modus.';
      case _UferwaldCameraMode.visitWander:
        return 'Visit/Wander Preview: Wegpunkt antippen oder Weiter nutzen. Kein echtes Movement-System.';
      case _UferwaldCameraMode.objectFocus:
        return '${selectedZoneLabel ?? 'R1'} im Object Focus · Umgebung bleibt sichtbar.';
    }
  }
}

class _VisitWalkerPanel extends StatelessWidget {
  const _VisitWalkerPanel({
    required this.currentWaypoint,
    required this.nextWaypoint,
    required this.onNextStep,
  });

  final _VisitWaypoint currentWaypoint;
  final _VisitWaypoint nextWaypoint;
  final VoidCallback onNextStep;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 245),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE60A111A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x66FFE6A3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_walk, size: 18, color: _mint),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      currentWaypoint.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Naechster Halt: ${nextWaypoint.label}',
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onNextStep,
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  label: const Text('Weiter'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: _mint,
                    foregroundColor: const Color(0xFF06101A),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
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

class _UferwaldVisitPathPainter extends CustomPainter {
  const _UferwaldVisitPathPainter({
    required this.walkerPosition,
    required this.activeWaypointIndex,
  });

  final Offset walkerPosition;
  final int activeWaypointIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0x88FFE6A3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final glowPaint = Paint()
      ..color = const Color(0x44FFE6A3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = Path()
      ..moveTo(
        size.width * _visitWaypoints.first.x,
        size.height * _visitWaypoints.first.y,
      )
      ..cubicTo(
        size.width * 0.41,
        size.height * 0.62,
        size.width * 0.45,
        size.height * 0.56,
        size.width * 0.49,
        size.height * 0.51,
      )
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.46,
        size.width * 0.60,
        size.height * 0.43,
        size.width * 0.66,
        size.height * 0.39,
      );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, pathPaint);
    final nextWaypointIndex =
        (activeWaypointIndex + 1) % _visitWaypoints.length;
    for (var i = 0; i < _visitWaypoints.length; i++) {
      final waypoint = _visitWaypoints[i];
      _drawVisitDot(
        canvas,
        size,
        waypoint.normalizedCenter,
        label: i == activeWaypointIndex
            ? waypoint.label
            : i == nextWaypointIndex
            ? 'Weiter'
            : null,
        isActive: i == activeWaypointIndex,
        isNext: i == nextWaypointIndex,
      );
    }
    _drawWalker(canvas, size);
  }

  void _drawVisitDot(
    Canvas canvas,
    Size size,
    Offset normalized, {
    required String? label,
    required bool isActive,
    required bool isNext,
  }) {
    final center = Offset(
      size.width * normalized.dx,
      size.height * normalized.dy,
    );
    final dotPaint = Paint()
      ..color = isActive
          ? const Color(0xFF66E5B4)
          : isNext
          ? const Color(0xFFFFE6A3)
          : const Color(0xCCFFFFFF)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = isNext ? const Color(0xFFFFE6A3) : const Color(0xFF3B2B16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isNext ? 5 : 3;

    canvas.drawCircle(center, isActive ? 14 : 10, dotPaint);
    canvas.drawCircle(center, isActive ? 14 : 10, borderPaint);

    if (label != null) {
      _drawText(
        canvas,
        label,
        center + const Offset(16, -9),
        const TextStyle(
          color: Colors.white,
          fontSize: 19,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      );
    }
  }

  void _drawWalker(Canvas canvas, Size size) {
    final center = Offset(
      size.width * walkerPosition.dx,
      size.height * walkerPosition.dy,
    );
    final shadowPaint = Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final bodyPaint = Paint()
      ..color = const Color(0xFF12222B)
      ..style = PaintingStyle.fill;
    final coatPaint = Paint()
      ..color = _mint
      ..style = PaintingStyle.fill;
    final headPaint = Paint()
      ..color = const Color(0xFFFFD7A8)
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 21),
        width: 48,
        height: 16,
      ),
      shadowPaint,
    );
    canvas.drawCircle(center, 22, bodyPaint);
    canvas.drawCircle(center, 22, outlinePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 8),
          width: 22,
          height: 24,
        ),
        const Radius.circular(10),
      ),
      coatPaint,
    );
    canvas.drawCircle(center + const Offset(0, -9), 8, headPaint);
    canvas.drawCircle(center + const Offset(0, -9), 8, outlinePaint);

    _drawText(
      canvas,
      'Besuch',
      center + const Offset(-29, -45),
      const TextStyle(
        color: Colors.white,
        fontSize: 17,
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
  bool shouldRepaint(covariant _UferwaldVisitPathPainter oldDelegate) {
    return oldDelegate.walkerPosition != walkerPosition ||
        oldDelegate.activeWaypointIndex != activeWaypointIndex;
  }
}

class _UferwaldObjectFocusPainter extends CustomPainter {
  const _UferwaldObjectFocusPainter({required this.selectedZoneLabel});

  final String? selectedZoneLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final zone = _selectedZone ?? _reviewZones.first;
    final rect = zone.toRect(size);
    final glowPaint = Paint()
      ..color = const Color(0x88FFD36E)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    final fillPaint = Paint()
      ..color = const Color(0x33FFD36E)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFFFF2A6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final contextPaint = Paint()
      ..color = const Color(0x55FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final focusRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 2.0,
      height: rect.height * 1.9,
    );
    canvas.drawOval(focusRect, glowPaint);
    canvas.drawOval(focusRect, fillPaint);
    canvas.drawOval(focusRect, strokePaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.center,
        width: rect.width * 2.65,
        height: rect.height * 2.45,
      ),
      contextPaint,
    );
    _drawFocusLabel(canvas, zone.label, rect.center);
  }

  _ReviewZone? get _selectedZone {
    final label = selectedZoneLabel;
    if (label == null) {
      return null;
    }

    for (final zone in _reviewZones) {
      if (zone.label == label) {
        return zone;
      }
    }

    return null;
  }

  void _drawFocusLabel(Canvas canvas, String label, Offset center) {
    final chipRect = Rect.fromCenter(
      center: center + const Offset(0, -58),
      width: 122,
      height: 36,
    );
    final chipPaint = Paint()
      ..color = const Color(0xF2FFF2A6)
      ..style = PaintingStyle.fill;
    final chipBorderPaint = Paint()
      ..color = const Color(0xFF3B2B16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(18)),
      chipPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chipRect, const Radius.circular(18)),
      chipBorderPaint,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: '$label Fokus',
        style: const TextStyle(
          color: Color(0xFF3B2B16),
          fontSize: 17,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: chipRect.width - 16);
    painter.paint(
      canvas,
      Offset(
        chipRect.center.dx - (painter.width / 2),
        chipRect.center.dy - (painter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _UferwaldObjectFocusPainter oldDelegate) {
    return oldDelegate.selectedZoneLabel != selectedZoneLabel;
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

  Offset get normalizedCenter => Offset(x, y);

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

class _VisitWaypoint {
  const _VisitWaypoint(this.label, this.x, this.y);

  final String label;
  final double x;
  final double y;

  Offset get normalizedCenter => Offset(x, y);

  Offset toOffset(Size size) {
    return Offset(size.width * x, size.height * y);
  }
}
