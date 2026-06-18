import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firenze/core/firenze_preview_camera.dart';
import 'firenze/core/firenze_preview_navigation_graph.dart';
import 'firenze/core/firenze_preview_world.dart';

const _showTechnicalPreviewBadge = kDebugMode;
const firenzePreviewCharacterAssetStatus = 'CHARACTER_ASSET_BLOCKER';
const firenzePreviewCharacterRenderingEnabled = false;
const firenzePreviewProceduralCharactersRemoved = true;

const _background = Color(0xFF02080D);
const _mint = Color(0xFF73FFE0);
const _gold = Color(0xFFFFD66D);
const _panel = Color(0xE606141C);
const _panelBorder = Color(0x6636E7B7);

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/previews/firenze_city_arrival_and_parcel_visit_preview.dart -d macos
//
// This file is intentionally standalone. It displays an app-bundled
// map-only planning image and overlays preview-runtime interaction generated
// from the Firenze master SVG. It does not parse SVG at runtime, export
// production geometry, create app navigation, or persist game state.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const FirenzeCityArrivalAndParcelVisitPreviewApp());
}

class FirenzeCityArrivalAndParcelVisitPreviewApp extends StatelessWidget {
  const FirenzeCityArrivalAndParcelVisitPreviewApp({super.key});

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
      home: const FirenzeCityArrivalAndParcelVisitPreview(),
    );
  }
}

class FirenzeCityArrivalAndParcelVisitPreview extends StatefulWidget {
  const FirenzeCityArrivalAndParcelVisitPreview({super.key});

  @override
  State<FirenzeCityArrivalAndParcelVisitPreview> createState() =>
      _FirenzeCityArrivalAndParcelVisitPreviewState();
}

class _FirenzeCityArrivalAndParcelVisitPreviewState
    extends State<FirenzeCityArrivalAndParcelVisitPreview>
    with TickerProviderStateMixin {
  final TransformationController _mapController = TransformationController();
  final FirenzePreviewNavigationGraph _navigationGraph =
      FirenzePreviewNavigationGraph();

  late final AnimationController _cameraController;
  late final AnimationController _travelController;
  late final AnimationController _pulseController;
  late final AnimationController _ambientController;
  late final List<_ParcelTarget> _activeTargets;

  Animation<Matrix4>? _cameraAnimation;
  Matrix4? _gestureStartMatrix;
  Offset? _gestureStartFocalPoint;
  ui.Image? _riverMaskImage;
  Timer? _companionBubbleTimer;
  Size? _lastViewportSize;
  FirenzePreviewCameraLayout? _lastCameraLayout;
  int _cameraAnimationToken = 0;
  bool _arrivalStarted = false;
  bool _cameraWasUserAdjusted = false;
  bool _portraitPaused = false;
  bool _resumeTravelAfterLandscape = false;
  bool _showCompanionBubble = false;
  bool _showCameraDebug = false;
  final Set<String> _discoveredParcelIds = <String>{};

  _PreviewMode _mode = _PreviewMode.arrival;
  _ParcelTarget? _selectedParcel;
  FirenzePreviewResolvedRoute? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _activeTargets = _buildActiveTargets(_navigationGraph);
    _loadRiverMask();
    _cameraController = AnimationController(vsync: this)
      ..addListener(_applyCameraAnimation);
    _travelController = AnimationController(vsync: this)
      ..addListener(_handleTravelTick)
      ..addStatusListener(_handleTravelStatus);
    _pulseController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1800),
          )
          ..addListener(_handlePulseTick)
          ..repeat();
    _ambientController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..addListener(_handlePulseTick)
          ..repeat();
  }

  @override
  void dispose() {
    _companionBubbleTimer?.cancel();
    _riverMaskImage?.dispose();
    _pulseController.dispose();
    _ambientController.dispose();
    _travelController.dispose();
    _cameraController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadRiverMask() async {
    final data = await rootBundle.load(firenzePreviewWorldRiverMaskAssetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() {
      _riverMaskImage?.dispose();
      _riverMaskImage = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            final isPortrait = viewportSize.height > viewportSize.width;
            _syncOrientationPause(isPortrait);
            if (isPortrait) {
              return const _RotateDeviceOverlay();
            }

            final cameraLayout = FirenzePreviewCameraLayout.fromViewport(
              viewportSize,
            );
            _scheduleViewportCamera(cameraLayout);

            final mapGesturesEnabled = _mode == _PreviewMode.overview;

            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.2),
                        radius: 1.12,
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
                        onDoubleTap: _returnToOverview,
                        onScaleStart: mapGesturesEnabled
                            ? (details) => _handleCameraScaleStart(details)
                            : null,
                        onScaleUpdate: mapGesturesEnabled
                            ? (details) => _handleCameraScaleUpdate(
                                details,
                                cameraLayout,
                              )
                            : null,
                        onScaleEnd: mapGesturesEnabled
                            ? (_) => _handleCameraScaleEnd()
                            : null,
                        child: AnimatedBuilder(
                          animation: _mapController,
                          builder: (context, child) {
                            return OverflowBox(
                              alignment: Alignment.topLeft,
                              minWidth: firenzePreviewWorldWidth,
                              maxWidth: firenzePreviewWorldWidth,
                              minHeight: firenzePreviewWorldHeight,
                              maxHeight: firenzePreviewWorldHeight,
                              child: Transform(
                                transform: _mapController.value,
                                alignment: Alignment.topLeft,
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: firenzePreviewWorldWidth,
                            height: firenzePreviewWorldHeight,
                            child: _FirenzeMapStage(
                              activeTargets: _activeTargets,
                              selectedParcel: _selectedParcel,
                              selectedRoute: _selectedRoute,
                              discoveredParcelIds: _discoveredParcelIds,
                              mode: _mode,
                              pulse: _pulseController.value,
                              ambientTimeSeconds: _ambientController.value * 60,
                              riverMaskImage: _riverMaskImage,
                              travelProgress: _travelProgress,
                              spawn: _toOffset(_navigationGraph.citySpawnStart),
                              onParcelTap: _focusParcel,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(left: 16, top: 14, child: _TitleOverlay()),
                if (_showTechnicalPreviewBadge)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showCameraDebug = !_showCameraDebug;
                        });
                      },
                      child: const _PlanningBadge(),
                    ),
                  ),
                if (_showTechnicalPreviewBadge)
                  const Positioned(
                    right: 16,
                    top: 50,
                    child: _CharacterAssetBlockerBadge(),
                  ),
                if (_showTechnicalPreviewBadge && _showCameraDebug)
                  Positioned(
                    right: 16,
                    top: 116,
                    child: _CameraDebugPanel(
                      layout: cameraLayout,
                      matrix: _mapController.value,
                    ),
                  ),
                if (_shouldShowOverviewButton)
                  Positioned(
                    right: 16,
                    top: _showTechnicalPreviewBadge ? 82 : 58,
                    child: _SmallHudButton(
                      label: 'Zur Übersicht',
                      onTap: _returnToOverview,
                    ),
                  ),
                _MissionAndActionPanel(
                  mode: _mode,
                  selectedParcel: _selectedParcel,
                  hasDiscovery: _discoveredParcelIds.isNotEmpty,
                  onVisit: _startTravel,
                  onOpenDetail: _openParcelDetail,
                ),
                if (_mode == _PreviewMode.overview &&
                    _discoveredParcelIds.isEmpty &&
                    _showCompanionBubble)
                  const Positioned(
                    left: 18,
                    top: 126,
                    child: _CompanionBubble(text: 'Drei Orte könnten passen.'),
                  ),
                if (_mode == _PreviewMode.parcelDetail &&
                    _selectedParcel != null)
                  _ParcelDetailOverlay(
                    parcel: _selectedParcel!,
                    onBack: _returnToOverview,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get _shouldShowOverviewButton {
    return _cameraWasUserAdjusted ||
        _mode == _PreviewMode.targetFocus ||
        _mode == _PreviewMode.arrived;
  }

  double? get _travelProgress {
    if (_mode == _PreviewMode.traveling) {
      return _travelController.value;
    }
    if (_mode == _PreviewMode.arrived) {
      return 1;
    }
    return null;
  }

  void _handleCameraScaleStart(ScaleStartDetails details) {
    if (_mode != _PreviewMode.overview) {
      return;
    }
    _cameraController.stop();
    _gestureStartMatrix = Matrix4.copy(_mapController.value);
    _gestureStartFocalPoint = details.localFocalPoint;
    if (!_cameraWasUserAdjusted) {
      setState(() {
        _cameraWasUserAdjusted = true;
      });
    }
  }

  void _handleCameraScaleUpdate(
    ScaleUpdateDetails details,
    FirenzePreviewCameraLayout layout,
  ) {
    if (_mode != _PreviewMode.overview) {
      return;
    }
    final startMatrix = _gestureStartMatrix;
    final startFocalPoint = _gestureStartFocalPoint;
    if (startMatrix == null || startFocalPoint == null) {
      return;
    }

    _mapController.value = FirenzePreviewCameraGesture.update(
      startMatrix: startMatrix,
      startFocalPoint: startFocalPoint,
      currentFocalPoint: details.localFocalPoint,
      scaleFactor: details.scale,
      layout: layout,
    );
  }

  void _handleCameraScaleEnd() {
    _gestureStartMatrix = null;
    _gestureStartFocalPoint = null;
    _snapCameraIntoBounds();
  }

  double _targetScaleFor(FirenzePreviewCameraLayout layout) {
    return layout.clampScale(layout.overviewScale * 1.72);
  }

  void _scheduleViewportCamera(FirenzePreviewCameraLayout layout) {
    if (_lastViewportSize == layout.viewportSize) {
      return;
    }

    _lastViewportSize = layout.viewportSize;
    _lastCameraLayout = layout;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_arrivalStarted) {
        _runArrival(_lastCameraLayout ?? layout);
        return;
      }

      if (_mode == _PreviewMode.overview) {
        _mapController.value = (_lastCameraLayout ?? layout)
            .overviewTransform();
        return;
      }

      _snapCameraIntoBounds();
    });
  }

  void _runArrival(FirenzePreviewCameraLayout layout) {
    _arrivalStarted = true;
    setState(() {
      _mode = _PreviewMode.arrival;
      _selectedParcel = null;
      _selectedRoute = null;
      _cameraWasUserAdjusted = false;
    });

    _mapController.value = layout.arrivalStartTransform();

    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) {
        return;
      }
      final activeLayout = _lastCameraLayout ?? layout;
      _animateCameraTo(
        activeLayout.overviewTransform(),
        duration: const Duration(milliseconds: 1450),
        curve: Curves.easeOutCubic,
        onDone: () {
          if (!mounted) {
            return;
          }
          setState(() {
            _mode = _PreviewMode.overview;
          });
          _showIntroBubbleBriefly();
        },
      );
    });
  }

  void _showIntroBubbleBriefly() {
    _companionBubbleTimer?.cancel();
    setState(() {
      _showCompanionBubble = true;
    });
    _companionBubbleTimer = Timer(const Duration(milliseconds: 4200), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showCompanionBubble = false;
      });
    });
  }

  void _focusParcel(_ParcelTarget parcel) {
    if (_mode == _PreviewMode.arrival ||
        _mode == _PreviewMode.traveling ||
        _mode == _PreviewMode.parcelDetail) {
      return;
    }

    final layout = _lastCameraLayout;
    if (layout == null) {
      return;
    }

    _cameraController.stop();
    _travelController.stop();
    final route = _navigationGraph.routeToParcel(parcel.id);
    setState(() {
      _mode = _PreviewMode.targetFocus;
      _selectedParcel = parcel;
      _selectedRoute = route;
      _cameraWasUserAdjusted = false;
      _showCompanionBubble = false;
    });

    _animateCameraTo(
      layout.targetFocusTransform(
        parcel.focus,
        scale: _targetScaleFor(layout),
        verticalBias: 0.06,
      ),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
    );
  }

  void _startTravel() {
    final parcel = _selectedParcel;
    final route = _selectedRoute;
    if (parcel == null || route == null || _lastCameraLayout == null) {
      return;
    }

    _cameraController.stop();
    _travelController.duration = firenzePreviewTravelDurationForRoute(route);
    setState(() {
      _mode = _PreviewMode.traveling;
      _cameraWasUserAdjusted = false;
      _showCompanionBubble = false;
    });
    _travelController.forward(from: 0);
  }

  void _handleTravelTick() {
    if (_mode != _PreviewMode.traveling || _selectedParcel == null) {
      return;
    }

    final layout = _lastCameraLayout;
    if (layout != null) {
      final t = _travelController.value;
      final route = _selectedRoute;
      if (route == null) {
        return;
      }
      final workerPosition = _toOffset(
        firenzePreviewRoutePointAtProgress(route, t),
      );
      _mapController.value = layout.travelFollowTransform(
        _cityToWorld(workerPosition),
        scale: math.max(layout.overviewScale * 1.86, _targetScaleFor(layout)),
        verticalBias: 0.02,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleTravelStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _selectedParcel == null) {
      return;
    }

    final route = _selectedRoute;
    HapticFeedback.lightImpact();
    setState(() {
      _mode = _PreviewMode.arrived;
      _discoveredParcelIds.add(_selectedParcel!.id);
    });

    final layout = _lastCameraLayout;
    if (layout != null) {
      _animateCameraTo(
        layout.targetFocusTransform(
          route == null || route.points.isEmpty
              ? _selectedParcel!.focus
              : _cityToWorld(_toOffset(route.points.last)),
          scale: _targetScaleFor(layout),
          verticalBias: 0.06,
        ),
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openParcelDetail() {
    if (_selectedParcel == null) {
      return;
    }

    _cameraController.stop();
    _travelController.stop();
    setState(() {
      _mode = _PreviewMode.parcelDetail;
      _cameraWasUserAdjusted = false;
    });
  }

  void _returnToOverview() {
    final layout = _lastCameraLayout;
    if (layout == null) {
      return;
    }

    _cameraController.stop();
    _travelController.stop();
    setState(() {
      _mode = _PreviewMode.overview;
      _selectedParcel = null;
      _selectedRoute = null;
      _cameraWasUserAdjusted = false;
      _showCompanionBubble = false;
    });

    _animateCameraTo(
      layout.returnToOverviewTransform(),
      duration: const Duration(milliseconds: 680),
      curve: Curves.easeOutCubic,
    );
  }

  void _snapCameraIntoBounds() {
    final layout = _lastCameraLayout;
    if (layout == null) {
      return;
    }
    final clamped = layout.clampMatrix(_mapController.value);
    if (_mapController.value != clamped) {
      _mapController.value = clamped;
    }
  }

  void _syncOrientationPause(bool isPortrait) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _portraitPaused == isPortrait) {
        return;
      }
      if (isPortrait) {
        _resumeTravelAfterLandscape = _travelController.isAnimating;
        _cameraController.stop();
        _travelController.stop();
        _pulseController.stop();
        _ambientController.stop();
        setState(() {
          _portraitPaused = true;
        });
        return;
      }

      _pulseController.repeat();
      _ambientController.repeat();
      if (_mode == _PreviewMode.traveling && _resumeTravelAfterLandscape) {
        _travelController.forward();
      }
      setState(() {
        _portraitPaused = false;
        _resumeTravelAfterLandscape = false;
      });
    });
  }

  void _animateCameraTo(
    Matrix4 target, {
    required Duration duration,
    required Curve curve,
    VoidCallback? onDone,
  }) {
    final token = ++_cameraAnimationToken;
    _cameraController.stop();
    _cameraController.duration = duration;
    _cameraAnimation = Matrix4Tween(
      begin: Matrix4.copy(_mapController.value),
      end: target,
    ).chain(CurveTween(curve: curve)).animate(_cameraController);
    _cameraController.forward(from: 0).whenComplete(() {
      if (mounted && token == _cameraAnimationToken) {
        onDone?.call();
      }
    });
  }

  void _applyCameraAnimation() {
    final animation = _cameraAnimation;
    if (animation != null) {
      _mapController.value =
          _lastCameraLayout?.clampMatrix(animation.value) ?? animation.value;
    }
  }

  void _handlePulseTick() {
    if (mounted && _mode != _PreviewMode.parcelDetail) {
      setState(() {});
    }
  }
}

class _FirenzeMapStage extends StatelessWidget {
  const _FirenzeMapStage({
    required this.activeTargets,
    required this.selectedParcel,
    required this.selectedRoute,
    required this.discoveredParcelIds,
    required this.mode,
    required this.pulse,
    required this.ambientTimeSeconds,
    required this.riverMaskImage,
    required this.travelProgress,
    required this.spawn,
    required this.onParcelTap,
  });

  final List<_ParcelTarget> activeTargets;
  final _ParcelTarget? selectedParcel;
  final FirenzePreviewResolvedRoute? selectedRoute;
  final Set<String> discoveredParcelIds;
  final _PreviewMode mode;
  final double pulse;
  final double ambientTimeSeconds;
  final ui.Image? riverMaskImage;
  final double? travelProgress;
  final Offset spawn;
  final ValueChanged<_ParcelTarget> onParcelTap;

  @override
  Widget build(BuildContext context) {
    final beaconsEnabled =
        mode == _PreviewMode.overview ||
        mode == _PreviewMode.targetFocus ||
        mode == _PreviewMode.arrived;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _FirenzeScenicWorldPainter(
            pulse: pulse,
            ambientTimeSeconds: ambientTimeSeconds,
          ),
        ),
        Positioned(
          left: firenzePreviewScenicPaddingX,
          top: firenzePreviewScenicPaddingY,
          width: firenzePreviewCityCanvasWidth,
          height: firenzePreviewCityCanvasHeight,
          child: Image.asset(
            firenzePreviewWorldMapOnlyAssetPath,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (riverMaskImage != null)
          Positioned(
            left: firenzePreviewScenicPaddingX,
            top: firenzePreviewScenicPaddingY,
            width: firenzePreviewCityCanvasWidth,
            height: firenzePreviewCityCanvasHeight,
            child: CustomPaint(
              painter: _FirenzeRiverPainter(
                maskImage: riverMaskImage!,
                pulse: pulse,
                flow: ambientTimeSeconds,
              ),
            ),
          ),
        CustomPaint(
          painter: _FirenzeGamePainter(
            activeTargets: activeTargets,
            selectedParcel: selectedParcel,
            selectedRoute: selectedRoute,
            discoveredParcelIds: discoveredParcelIds,
            mode: mode,
            pulse: pulse,
            ambientTimeSeconds: ambientTimeSeconds,
            travelProgress: travelProgress,
            spawn: spawn,
          ),
        ),
        for (final target in activeTargets)
          Positioned.fromRect(
            rect: _toCanvasRect(target.hitbox),
            child: IgnorePointer(
              ignoring: !beaconsEnabled,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => onParcelTap(target),
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }

  Rect _toCanvasRect(Rect normalizedRect) {
    return Rect.fromLTWH(
      normalizedRect.left * firenzePreviewWorldWidth,
      normalizedRect.top * firenzePreviewWorldHeight,
      normalizedRect.width * firenzePreviewWorldWidth,
      normalizedRect.height * firenzePreviewWorldHeight,
    );
  }
}

class _FirenzeScenicWorldPainter extends CustomPainter {
  const _FirenzeScenicWorldPainter({
    required this.pulse,
    required this.ambientTimeSeconds,
  });

  final double pulse;
  final double ambientTimeSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF183D38), Color(0xFF23482E), Color(0xFF18351F)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    _drawField(
      canvas,
      size,
      const Offset(0.06, 0.18),
      const Size(0.34, 0.24),
      const Color(0xFF5F9D52),
    );
    _drawField(
      canvas,
      size,
      const Offset(0.72, 0.08),
      const Size(0.24, 0.28),
      const Color(0xFF7DAE58),
    );
    _drawField(
      canvas,
      size,
      const Offset(0.03, 0.72),
      const Size(0.34, 0.2),
      const Color(0xFF867B3E),
    );
    _drawField(
      canvas,
      size,
      const Offset(0.7, 0.72),
      const Size(0.28, 0.2),
      const Color(0xFF589C64),
    );

    final arnoContext = Paint()
      ..color = const Color(0xFF2478BA).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final arnoLine = Path()
      ..moveTo(0, size.height * 0.52)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.46,
        size.width * 0.72,
        size.height * 0.58,
        size.width,
        size.height * 0.49,
      );
    canvas.drawPath(arnoLine, arnoContext);

    final hill = Paint()
      ..color = const Color(0xFF315C36).withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;
    for (final hillData in const [
      (0.14, 0.06, 250.0, 80.0),
      (0.38, 0.04, 310.0, 95.0),
      (0.77, 0.05, 360.0, 110.0),
      (0.18, 0.93, 340.0, 90.0),
      (0.58, 0.94, 360.0, 100.0),
      (0.86, 0.88, 300.0, 82.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * hillData.$1, size.height * hillData.$2),
          width: hillData.$3,
          height: hillData.$4,
        ),
        hill,
      );
    }

    final housePaint = Paint()
      ..color = const Color(0xFFD8B67C).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final roofPaint = Paint()
      ..color = const Color(0xFF8E5639).withValues(alpha: 0.62)
      ..style = PaintingStyle.fill;
    for (final position in const [
      Offset(0.09, 0.35),
      Offset(0.88, 0.28),
      Offset(0.12, 0.84),
      Offset(0.83, 0.78),
    ]) {
      final base = Offset(size.width * position.dx, size.height * position.dy);
      canvas.drawRect(Rect.fromLTWH(base.dx, base.dy, 24, 16), housePaint);
      final roof = Path()
        ..moveTo(base.dx - 3, base.dy)
        ..lineTo(base.dx + 12, base.dy - 12)
        ..lineTo(base.dx + 27, base.dy)
        ..close();
      canvas.drawPath(roof, roofPaint);

      final smoke = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final drift = math.sin(ambientTimeSeconds * 0.32 + position.dx * 9) * 4;
      final smokePath = Path()
        ..moveTo(base.dx + 18, base.dy - 13)
        ..cubicTo(
          base.dx + 20 + drift,
          base.dy - 24,
          base.dx + 12 + drift,
          base.dy - 29,
          base.dx + 18 + drift * 1.3,
          base.dy - 40,
        );
      canvas.drawPath(smokePath, smoke);
    }

    final treePaint = Paint()
      ..color = const Color(0xFF183F27).withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    for (var index = 0; index < 34; index++) {
      final sway = math.sin(ambientTimeSeconds * 0.55 + index * 0.73) * 2.4;
      final x = (math.sin(index * 17.31) * 0.5 + 0.5) * size.width + sway;
      final y = (math.cos(index * 9.17) * 0.5 + 0.5) * size.height;
      if (x > firenzePreviewScenicPaddingX * 0.75 &&
          x < size.width - firenzePreviewScenicPaddingX * 0.75 &&
          y > firenzePreviewScenicPaddingY * 0.75 &&
          y < size.height - firenzePreviewScenicPaddingY * 0.75) {
        continue;
      }
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8 + sway.abs() * 0.2,
          height: 20,
        ),
        treePaint,
      );
    }

    final birdPaint = Paint()
      ..color = const Color(0xFF08151A).withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 4; index++) {
      final base = Offset(
        size.width *
            (0.2 +
                index * 0.17 +
                math.sin(ambientTimeSeconds * 0.12 + index) * 0.01),
        size.height *
            (0.18 + math.cos(ambientTimeSeconds * 0.15 + index) * 0.025),
      );
      canvas.drawLine(base.translate(-7, 0), base, birdPaint);
      canvas.drawLine(base, base.translate(7, -1.5), birdPaint);
    }

    final mist = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.04 + math.sin(pulse * math.pi * 2) * 0.015,
      )
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.18),
        width: size.width * 0.72,
        height: 78,
      ),
      mist,
    );
  }

  void _drawField(
    Canvas canvas,
    Size size,
    Offset origin,
    Size fieldSize,
    Color color,
  ) {
    final rect = Rect.fromLTWH(
      size.width * origin.dx,
      size.height * origin.dy,
      size.width * fieldSize.width,
      size.height * fieldSize.height,
    );
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(32)),
      paint,
    );
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var offset = 18.0; offset < rect.width; offset += 22) {
      canvas.drawLine(
        Offset(rect.left + offset, rect.top + 8),
        Offset(rect.left + offset - 22, rect.bottom - 8),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FirenzeScenicWorldPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.ambientTimeSeconds != ambientTimeSeconds;
  }
}

class _FirenzeRiverPainter extends CustomPainter {
  const _FirenzeRiverPainter({
    required this.maskImage,
    required this.pulse,
    required this.flow,
  });

  final ui.Image maskImage;
  final double pulse;
  final double flow;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());

    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x99235F8F), Color(0xAA3EA8C6), Color(0x882A6E9F)],
      ).createShader(bounds);
    canvas.drawRect(bounds, base);

    _drawFlowLayer(
      canvas,
      size,
      color: const Color(0xFFBFEFFF).withValues(alpha: 0.1),
      strokeWidth: 3.0,
      spacing: 42,
      speed: 18,
      phaseOffset: 0,
    );
    _drawFlowLayer(
      canvas,
      size,
      color: const Color(0xFFE8FFFF).withValues(alpha: 0.07),
      strokeWidth: 1.8,
      spacing: 64,
      speed: -9,
      phaseOffset: 19,
    );

    final shimmer = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.025 + math.sin(pulse * math.pi * 2) * 0.01,
      )
      ..style = PaintingStyle.fill;
    canvas.drawRect(bounds, shimmer);

    canvas.drawImageRect(
      maskImage,
      Rect.fromLTWH(
        0,
        0,
        maskImage.width.toDouble(),
        maskImage.height.toDouble(),
      ),
      bounds,
      Paint()
        ..filterQuality = FilterQuality.low
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();
  }

  void _drawFlowLayer(
    Canvas canvas,
    Size size, {
    required Color color,
    required double strokeWidth,
    required double spacing,
    required double speed,
    required double phaseOffset,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final offset = (flow * speed + phaseOffset).remainder(spacing);
    for (var y = -spacing; y < size.height + spacing; y += spacing) {
      final path = Path();
      var started = false;
      for (var x = -80.0; x <= size.width + 80; x += 34) {
        final waveY =
            y + offset + math.sin((x * 0.016) + flow * 0.75 + phaseOffset) * 5;
        final point = Offset(x, waveY + x * 0.018);
        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FirenzeRiverPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage ||
        oldDelegate.pulse != pulse ||
        oldDelegate.flow != flow;
  }
}

class _FirenzeGamePainter extends CustomPainter {
  const _FirenzeGamePainter({
    required this.activeTargets,
    required this.selectedParcel,
    required this.selectedRoute,
    required this.discoveredParcelIds,
    required this.mode,
    required this.pulse,
    required this.ambientTimeSeconds,
    required this.travelProgress,
    required this.spawn,
  });

  final List<_ParcelTarget> activeTargets;
  final _ParcelTarget? selectedParcel;
  final FirenzePreviewResolvedRoute? selectedRoute;
  final Set<String> discoveredParcelIds;
  final _PreviewMode mode;
  final double pulse;
  final double ambientTimeSeconds;
  final double? travelProgress;
  final Offset spawn;

  @override
  void paint(Canvas canvas, Size size) {
    final selected = selectedParcel;
    final route = selectedRoute;

    if (selected != null &&
        route != null &&
        (mode == _PreviewMode.traveling || mode == _PreviewMode.arrived)) {
      _drawRoute(
        canvas,
        size,
        route,
        progress: mode == _PreviewMode.traveling ? travelProgress ?? 0 : 1,
        opacity: mode == _PreviewMode.arrived ? 0.22 : 1,
      );

      if (mode == _PreviewMode.traveling) {
        _drawTravelGlow(
          canvas,
          size,
          _toOffset(
            firenzePreviewRoutePointAtProgress(route, travelProgress ?? 0),
          ),
        );
      }
    }

    for (final target in activeTargets) {
      if (discoveredParcelIds.contains(target.id)) {
        _drawConstructionMarker(canvas, size, target);
      } else {
        _drawBeacon(
          canvas,
          size,
          target,
          isSelected: target.id == selected?.id,
        );
      }
    }

    _drawSpawn(canvas, size);

    if (selected != null && route != null && mode == _PreviewMode.arrived) {
      final arrivalPoint = route.points.isEmpty
          ? selected.focus
          : _toOffset(route.points.last);
      _drawArrivalImpulse(canvas, size, arrivalPoint);
    }
  }

  void _drawBeacon(
    Canvas canvas,
    Size size,
    _ParcelTarget target, {
    required bool isSelected,
  }) {
    final center = _toWorldCanvas(target.focus, size);
    final pulseWave = (math.sin(pulse * math.pi * 2) + 1) / 2;
    final accent = isSelected ? _gold : _mint;
    final radius = isSelected ? 12.0 : 8.5;

    final glow = Paint()
      ..color = accent.withValues(alpha: isSelected ? 0.23 : 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 9 + pulseWave * 5, glow);

    final stem = Paint()
      ..color = Colors.white.withValues(alpha: isSelected ? 0.78 : 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.2 : 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(0, -radius - 12),
      center.translate(0, radius + 18),
      stem,
    );

    final flagPath = Path()
      ..moveTo(center.dx + 1, center.dy - radius - 13)
      ..lineTo(center.dx + 18, center.dy - radius - 8)
      ..lineTo(center.dx + 1, center.dy - radius - 3)
      ..close();
    final flag = Paint()
      ..color = accent.withValues(alpha: isSelected ? 0.9 : 0.66)
      ..style = PaintingStyle.fill;
    canvas.drawPath(flagPath, flag);

    final diamondPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    final fill = Paint()
      ..color = accent.withValues(alpha: isSelected ? 0.96 : 0.82)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = Colors.white.withValues(alpha: isSelected ? 0.9 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(diamondPath, fill);
    canvas.drawPath(diamondPath, outline);
  }

  void _drawConstructionMarker(Canvas canvas, Size size, _ParcelTarget target) {
    final center = _toWorldCanvas(target.focus, size);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    final crate = Paint()
      ..color = const Color(0xFFC98F43)
      ..style = PaintingStyle.fill;
    final cloth = Paint()
      ..color = _gold.withValues(alpha: 0.94)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 14), width: 42, height: 14),
      shadow,
    );
    final crateRect = Rect.fromCenter(
      center: center.translate(-3, 3),
      width: 28,
      height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(crateRect, const Radius.circular(4)),
      crate,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(crateRect, const Radius.circular(4)),
      outline,
    );
    final flag = Path()
      ..moveTo(center.dx + 9, center.dy - 20)
      ..lineTo(center.dx + 28, center.dy - 15)
      ..lineTo(center.dx + 9, center.dy - 9)
      ..close();
    canvas.drawLine(
      center.translate(8, -21),
      center.translate(8, 5),
      outline..strokeWidth = 2,
    );
    canvas.drawPath(flag, cloth);
  }

  void _drawSpawn(Canvas canvas, Size size) {
    final center = _toCityCanvas(spawn, size);
    final glow = Paint()
      ..color = _mint.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;
    final dot = Paint()
      ..color = _mint
      ..style = PaintingStyle.fill;
    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 17, glow);
    canvas.drawCircle(center, 7, dot);
    canvas.drawCircle(center, 12, ring);
  }

  void _drawRoute(
    Canvas canvas,
    Size size,
    FirenzePreviewResolvedRoute route, {
    required double progress,
    required double opacity,
  }) {
    final points = firenzePreviewRoutePointsUntilProgress(
      route,
      progress,
    ).map(_toOffset).map((point) => _toCityCanvas(point, size)).toList();
    if (points.length < 2) {
      return;
    }

    final pulseWave = (math.sin(pulse * math.pi * 2) + 1) / 2;
    final glow = Paint()
      ..color = _gold.withValues(alpha: (0.1 + pulseWave * 0.05) * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 + pulseWave * 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = Paint()
      ..color = _gold.withValues(alpha: 0.52 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  void _drawTravelGlow(Canvas canvas, Size size, Offset normalizedPosition) {
    final center = _toCityCanvas(normalizedPosition, size);
    final pulseWave = (math.sin(pulse * math.pi * 2) + 1) / 2;
    final halo = Paint()
      ..color = _mint.withValues(alpha: 0.16 + pulseWave * 0.08)
      ..style = PaintingStyle.fill;
    final core = Paint()
      ..color = Colors.white.withValues(alpha: 0.84)
      ..style = PaintingStyle.fill;
    final sparkle = Paint()
      ..color = _mint.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, 8 + pulseWave * 3, halo);
    canvas.drawCircle(center, 2.2, core);
    canvas.drawLine(center.translate(-7, 0), center.translate(7, 0), sparkle);
    canvas.drawLine(center.translate(0, -7), center.translate(0, 7), sparkle);
  }

  void _drawArrivalImpulse(Canvas canvas, Size size, Offset focus) {
    final center = _toCityCanvas(focus, size);
    final pulseWave = (math.sin(pulse * math.pi * 2) + 1) / 2;
    final ring = Paint()
      ..color = _gold.withValues(alpha: 0.44 - pulseWave * 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, 34 + pulseWave * 18, ring);
  }

  Offset _toWorldCanvas(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  Offset _toCityCanvas(Offset normalized, Size size) {
    return Offset(
      firenzePreviewScenicPaddingX +
          normalized.dx * firenzePreviewCityCanvasWidth,
      firenzePreviewScenicPaddingY +
          normalized.dy * firenzePreviewCityCanvasHeight,
    );
  }

  @override
  bool shouldRepaint(covariant _FirenzeGamePainter oldDelegate) {
    return oldDelegate.selectedParcel?.id != selectedParcel?.id ||
        oldDelegate.selectedRoute?.entryId != selectedRoute?.entryId ||
        oldDelegate.discoveredParcelIds.length != discoveredParcelIds.length ||
        oldDelegate.mode != mode ||
        oldDelegate.pulse != pulse ||
        oldDelegate.ambientTimeSeconds != ambientTimeSeconds ||
        oldDelegate.travelProgress != travelProgress;
  }
}

class _RotateDeviceOverlay extends StatelessWidget {
  const _RotateDeviceOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.25),
          radius: 1.1,
          colors: [Color(0xFF0E3038), _background],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RotateGlyph(),
            SizedBox(height: 14),
            Text(
              'Drehe dein Gerät',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Florenz spielt sich im Querformat.',
              style: TextStyle(
                color: Color(0xFFD0E2E8),
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotateGlyph extends StatelessWidget {
  const _RotateGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(86, 58),
      painter: _RotateGlyphPainter(),
    );
  }
}

class _RotateGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final device = Paint()
      ..color = _mint.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = _mint.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final arrow = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.52),
        width: 58,
        height: 32,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, device);
    canvas.drawRRect(rect, border);
    final path = Path()
      ..moveTo(size.width * 0.72, size.height * 0.16)
      ..arcToPoint(
        Offset(size.width * 0.82, size.height * 0.48),
        radius: const Radius.circular(24),
      );
    canvas.drawPath(path, arrow);
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.48),
      Offset(size.width * 0.74, size.height * 0.44),
      arrow,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.48),
      Offset(size.width * 0.83, size.height * 0.38),
      arrow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TitleOverlay extends StatelessWidget {
  const _TitleOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Florenz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Wohin zuerst?',
              style: TextStyle(
                color: _mint,
                fontSize: 12,
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
        color: const Color(0xB8051219),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.5)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'technical prototype',
          style: TextStyle(
            color: Color(0xFFD9EEF6),
            fontSize: 10,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CharacterAssetBlockerBadge extends StatelessWidget {
  const _CharacterAssetBlockerBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x99051219),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _gold.withValues(alpha: 0.34)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          'Character assets missing',
          style: TextStyle(
            color: Color(0xFFFFE7A8),
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CameraDebugPanel extends StatelessWidget {
  const _CameraDebugPanel({required this.layout, required this.matrix});

  final FirenzePreviewCameraLayout layout;
  final Matrix4 matrix;

  @override
  Widget build(BuildContext context) {
    final scale = matrix.storage[0];
    final translation = Offset(matrix.storage[12], matrix.storage[13]);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD8051219),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorder.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xFFD9EEF6),
            fontSize: 9,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'viewport ${layout.viewportSize.width.toStringAsFixed(0)} x '
                '${layout.viewportSize.height.toStringAsFixed(0)}',
              ),
              Text(
                'world ${layout.worldRect.width.toStringAsFixed(0)} x '
                '${layout.worldRect.height.toStringAsFixed(0)}',
              ),
              Text(
                'city ${layout.cityRect.left.toStringAsFixed(0)},'
                '${layout.cityRect.top.toStringAsFixed(0)} '
                '${layout.cityRect.width.toStringAsFixed(0)} x '
                '${layout.cityRect.height.toStringAsFixed(0)}',
              ),
              Text('scale ${scale.toStringAsFixed(3)}'),
              Text('min ${layout.hardMinScale.toStringAsFixed(3)}'),
              Text('overview ${layout.overviewScale.toStringAsFixed(3)}'),
              Text(
                'tx ${translation.dx.toStringAsFixed(1)} '
                'ty ${translation.dy.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionAndActionPanel extends StatelessWidget {
  const _MissionAndActionPanel({
    required this.mode,
    required this.selectedParcel,
    required this.hasDiscovery,
    required this.onVisit,
    required this.onOpenDetail,
  });

  final _PreviewMode mode;
  final _ParcelTarget? selectedParcel;
  final bool hasDiscovery;
  final VoidCallback onVisit;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final hidden =
        mode == _PreviewMode.arrival || mode == _PreviewMode.parcelDetail;
    final alignment = switch (mode) {
      _PreviewMode.overview => Alignment.topLeft,
      _PreviewMode.traveling => Alignment.bottomCenter,
      _ => Alignment.bottomLeft,
    };
    final maxWidth = switch (mode) {
      _PreviewMode.overview => 370.0,
      _PreviewMode.targetFocus => 420.0,
      _PreviewMode.traveling => 245.0,
      _PreviewMode.arrived => 390.0,
      _ => 1.0,
    };
    final panelPadding = switch (mode) {
      _PreviewMode.overview => const EdgeInsets.fromLTRB(12, 9, 12, 10),
      _PreviewMode.traveling => const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      _ => const EdgeInsets.fromLTRB(12, 11, 12, 12),
    };
    final borderRadius = BorderRadius.circular(
      mode == _PreviewMode.traveling ? 999 : 18,
    );

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: hidden,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: hidden ? 0 : 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              mode == _PreviewMode.overview ? 78 : 16,
              16,
              math.max(14, bottomPadding + 10),
            ),
            child: Align(
              alignment: alignment,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mode == _PreviewMode.traveling
                        ? const Color(0xD806141C)
                        : const Color(0xE606141C),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: _panelBorder.withValues(
                        alpha: mode == _PreviewMode.traveling ? 0.55 : 1,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x73000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(padding: panelPadding, child: _panelContent()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelContent() {
    switch (mode) {
      case _PreviewMode.overview:
        return _MissionIntroContent(hasDiscovery: hasDiscovery);
      case _PreviewMode.targetFocus:
        final parcel = selectedParcel;
        if (parcel == null) {
          return _MissionIntroContent(hasDiscovery: hasDiscovery);
        }
        return _ParcelFocusContent(parcel: parcel, onVisit: onVisit);
      case _PreviewMode.traveling:
        return const _TravelContent();
      case _PreviewMode.arrived:
        final parcel = selectedParcel;
        if (parcel == null) {
          return _MissionIntroContent(hasDiscovery: hasDiscovery);
        }
        return _ArrivalRewardContent(
          parcel: parcel,
          onOpenDetail: onOpenDetail,
        );
      case _PreviewMode.arrival:
      case _PreviewMode.parcelDetail:
        return const SizedBox.shrink();
    }
  }
}

class _MissionIntroContent extends StatelessWidget {
  const _MissionIntroContent({required this.hasDiscovery});

  final bool hasDiscovery;

  @override
  Widget build(BuildContext context) {
    final title = hasDiscovery
        ? 'Baustelle vorbereiten.'
        : 'Finde einen Platz für dein erstes Zuhause.';
    final subtitle = hasDiscovery
        ? 'Ein Ort ist entdeckt. Schau dir den Baugrund an.'
        : 'Drei Orte leuchten. Wähle einen und reise hin.';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuestGlyph(done: hasDiscovery),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD0E2E8),
                  fontSize: 10,
                  height: 1.15,
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

class _QuestGlyph extends StatelessWidget {
  const _QuestGlyph({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final accent = done ? _gold : _mint;
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.62)),
      ),
      alignment: Alignment.center,
      child: Icon(
        done ? Icons.flag_rounded : Icons.search_rounded,
        size: 15,
        color: accent,
      ),
    );
  }
}

class _ParcelFocusContent extends StatelessWidget {
  const _ParcelFocusContent({required this.parcel, required this.onVisit});

  final _ParcelTarget parcel;
  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ParcelGlyph(label: parcel.id),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                parcel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                parcel.trait,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFD0E2E8),
                  fontSize: 10.5,
                  height: 1.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _ActionButton(label: 'Ort besuchen', onTap: onVisit),
      ],
    );
  }
}

class _TravelContent extends StatelessWidget {
  const _TravelContent();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.route_rounded, size: 15, color: _mint),
        SizedBox(width: 8),
        Text(
          'Unterwegs zum Bauort...',
          style: TextStyle(
            color: Colors.white,
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

class _ArrivalRewardContent extends StatelessWidget {
  const _ArrivalRewardContent({
    required this.parcel,
    required this.onOpenDetail,
  });

  final _ParcelTarget parcel;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ParcelGlyph(label: parcel.id, discovered: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ort entdeckt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${parcel.name} · 1 neuer Bauort',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _mint,
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _ActionButton(label: 'Grundstück ansehen', onTap: onOpenDetail),
      ],
    );
  }
}

class _ParcelDetailOverlay extends StatelessWidget {
  const _ParcelDetailOverlay({required this.parcel, required this.onBack});

  final _ParcelTarget parcel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF006141C), Color(0xFA02080D)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 86, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      parcel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  _SmallHudButton(label: 'Zurück', onTap: onBack),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xCC0A251F),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _mint.withValues(alpha: 0.38)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 24,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _ParcelDetailPlaceholderPainter(),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Freier Baugrund',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Hier entsteht deine Grundstücks-Detailkarte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD0E2E8),
                                fontSize: 14,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _ParcelDetailPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ground = Paint()
      ..color = _mint.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _mint.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.18,
        size.width * 0.82,
        size.height * 0.34,
      )
      ..lineTo(size.width * 0.76, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.86,
        size.width * 0.22,
        size.height * 0.72,
      )
      ..close();
    canvas.drawPath(path, ground);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompanionBubble extends StatelessWidget {
  const _CompanionBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD806141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _mint.withValues(alpha: 0.34)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withValues(alpha: 0.14),
                border: Border.all(color: _mint.withValues(alpha: 0.55)),
              ),
              alignment: Alignment.center,
              child: const Text(
                'T',
                style: TextStyle(
                  color: _mint,
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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

class _ParcelGlyph extends StatelessWidget {
  const _ParcelGlyph({required this.label, this.discovered = false});

  final String label;
  final bool discovered;

  @override
  Widget build(BuildContext context) {
    final accent = discovered ? _gold : _mint;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 13,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _mint,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF062027),
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallHudButton extends StatelessWidget {
  const _SmallHudButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xD806141C),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _panelBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

enum _PreviewMode {
  arrival,
  overview,
  targetFocus,
  traveling,
  arrived,
  parcelDetail,
}

class _ParcelTarget {
  const _ParcelTarget({
    required this.id,
    required this.name,
    required this.trait,
    required this.hitbox,
    required this.focus,
  });

  final String id;
  final String name;
  final String trait;
  final Rect hitbox;
  final Offset focus;
}

class FirenzePreviewAmbientRoutePlan {
  const FirenzePreviewAmbientRoutePlan({
    required this.id,
    required this.nodeIds,
    this.closed = true,
  });

  final String id;
  final List<String> nodeIds;
  final bool closed;
}

class FirenzePreviewAmbientRoute {
  const FirenzePreviewAmbientRoute({
    required this.id,
    required this.nodeIds,
    required this.edgeIds,
    required this.points,
    required this.lengthPx,
    required this.closed,
  });

  final String id;
  final List<String> nodeIds;
  final List<String> edgeIds;
  final List<FirenzePreviewPoint> points;
  final double lengthPx;
  final bool closed;
}

const firenzeAmbientRoutePlans = <FirenzePreviewAmbientRoutePlan>[
  FirenzePreviewAmbientRoutePlan(
    id: 'north_loop',
    nodeIds: [
      'N008_crossroad',
      'N009_crossroad',
      'N057_crossroad',
      'N056_crossroad',
      'N010_crossroad',
      'N011_crossroad',
      'N008_crossroad',
    ],
  ),
  FirenzePreviewAmbientRoutePlan(
    id: 'center_loop',
    nodeIds: [
      'N003_crossroad',
      'N004_crossroad',
      'N005_crossroad',
      'N047_crossroad',
      'N052_crossroad',
      'N003_crossroad',
    ],
  ),
  FirenzePreviewAmbientRoutePlan(
    id: 'south_loop',
    nodeIds: [
      'N028_crossroad',
      'N029_crossroad',
      'N030_crossroad',
      'N031_crossroad',
      'N049_crossroad',
      'N072_crossroad',
      'N069_crossroad',
      'N028_crossroad',
    ],
  ),
  FirenzePreviewAmbientRoutePlan(
    id: 'river_bank_loop',
    nodeIds: [
      'N071_crossroad',
      'N015_crossroad',
      'N016_crossroad',
      'N018_crossroad',
      'B07_N',
      'B07_M',
      'B07_S',
      'N019_crossroad',
      'N074_crossroad',
      'N025_crossroad',
      'N027_crossroad',
      'N070_crossroad',
      'B08_S',
      'B08_M',
      'B08_N',
      'N071_crossroad',
    ],
  ),
  FirenzePreviewAmbientRoutePlan(
    id: 'bridge_loop',
    nodeIds: [
      'N043_crossroad',
      'B01_N',
      'B01_M',
      'B01_S',
      'N040_crossroad',
      'N037_crossroad',
      'B02_S',
      'B02_M',
      'B02_N',
      'N045_crossroad',
      'N043_crossroad',
    ],
  ),
];

List<FirenzePreviewAmbientRoute> buildFirenzePreviewAmbientRoutes(
  List<FirenzePreviewAmbientRoutePlan> plans,
) {
  final edges = {
    for (final edge in firenzePreviewNavigationEdges) edge.id: edge,
  };
  final routes = <FirenzePreviewAmbientRoute>[];
  for (final plan in plans) {
    final routePoints = <FirenzePreviewPoint>[];
    final routeEdges = <String>[];
    for (var index = 0; index < plan.nodeIds.length - 1; index++) {
      final from = plan.nodeIds[index];
      final to = plan.nodeIds[index + 1];
      final edge = _edgeBetween(from, to, edges.values);
      routeEdges.add(edge.id);
      final points = edge.from == from
          ? edge.points
          : edge.points.reversed.toList(growable: false);
      for (var pointIndex = 0; pointIndex < points.length; pointIndex++) {
        if (routePoints.isNotEmpty && pointIndex == 0) {
          continue;
        }
        routePoints.add(points[pointIndex]);
      }
    }
    routes.add(
      FirenzePreviewAmbientRoute(
        id: plan.id,
        nodeIds: plan.nodeIds,
        edgeIds: routeEdges,
        points: routePoints,
        lengthPx: firenzePreviewPolylineCanvasLength(routePoints),
        closed: plan.closed,
      ),
    );
  }
  return routes;
}

FirenzePreviewNavigationEdge _edgeBetween(
  String from,
  String to,
  Iterable<FirenzePreviewNavigationEdge> edges,
) {
  for (final edge in edges) {
    if ((edge.from == from && edge.to == to) ||
        (edge.from == to && edge.to == from)) {
      return edge;
    }
  }
  throw StateError('Missing ambient edge $from -> $to');
}

const firenzePreviewActivityAnchors = <String, String>{
  'market_activity': 'N003_crossroad',
  'bridge_watch_activity': 'B01_N',
  'construction_activity': 'N005_crossroad',
  'plaza_activity': 'N004_crossroad',
  'river_view_activity': 'N071_crossroad',
};

enum PreviewCharacterRole { pedestrian, worker }

enum PreviewCharacterMotionState { idle, walk, carry, work }

enum PreviewCharacterDirection { n, ne, e, se, s, sw, w, nw }

enum PreviewCharacterAnchor { bottomCenter }

class PreviewCharacterVisualPlacement {
  const PreviewCharacterVisualPlacement({
    required this.footPosition,
    required this.direction,
    required this.motionState,
    this.anchor = PreviewCharacterAnchor.bottomCenter,
    this.visualRootRotationRadians = 0,
    this.isUpright = true,
  });

  final Offset footPosition;
  final PreviewCharacterDirection direction;
  final PreviewCharacterMotionState motionState;
  final PreviewCharacterAnchor anchor;
  final double visualRootRotationRadians;
  final bool isUpright;
}

PreviewCharacterDirection previewCharacterDirectionForVector(Offset vector) {
  if (vector.distanceSquared == 0) {
    return PreviewCharacterDirection.s;
  }

  final degrees =
      (math.atan2(vector.dy, vector.dx) * 180 / math.pi + 360) % 360;
  if (degrees < 22.5 || degrees >= 337.5) {
    return PreviewCharacterDirection.e;
  }
  if (degrees < 67.5) {
    return PreviewCharacterDirection.se;
  }
  if (degrees < 112.5) {
    return PreviewCharacterDirection.s;
  }
  if (degrees < 157.5) {
    return PreviewCharacterDirection.sw;
  }
  if (degrees < 202.5) {
    return PreviewCharacterDirection.w;
  }
  if (degrees < 247.5) {
    return PreviewCharacterDirection.nw;
  }
  if (degrees < 292.5) {
    return PreviewCharacterDirection.n;
  }
  return PreviewCharacterDirection.ne;
}

PreviewCharacterMotionState previewCharacterMotionStateFor({
  required PreviewCharacterRole role,
  required bool isMoving,
  bool isCarrying = false,
  bool isAtWorkAnchor = false,
}) {
  if (isMoving) {
    return isCarrying
        ? PreviewCharacterMotionState.carry
        : PreviewCharacterMotionState.walk;
  }
  if (role == PreviewCharacterRole.worker && isAtWorkAnchor) {
    return PreviewCharacterMotionState.work;
  }
  return PreviewCharacterMotionState.idle;
}

double previewCharacterWalkCyclePhase({
  required double elapsedSeconds,
  required double speedPxPerSecond,
  double cycleLengthPx = 42,
}) {
  assert(cycleLengthPx > 0);
  final travelled = math.max(0, elapsedSeconds) * speedPxPerSecond;
  return (travelled / cycleLengthPx).remainder(1);
}

List<_ParcelTarget> _buildActiveTargets(FirenzePreviewNavigationGraph graph) {
  _ParcelTarget target({
    required String id,
    required String name,
    required String trait,
  }) {
    final focus = _cityToWorld(_toOffset(graph.anchorForParcel(id)));
    return _ParcelTarget(
      id: id,
      name: name,
      trait: trait,
      hitbox: _hitboxAround(focus),
      focus: focus,
    );
  }

  return [
    target(
      id: 'P01',
      name: 'Am Fluss',
      trait: 'Flussnähe, ruhig und gut als erstes Zuhause lesbar.',
    ),
    target(
      id: 'P03',
      name: 'Am Stadtrand',
      trait: 'Nördlicher Stadtbereich mit Luft für einen sanften Anfang.',
    ),
    target(
      id: 'P09',
      name: 'Nahe dem Zentrum',
      trait: 'Südöstlich, gut angebunden und nah an vielen Wegen.',
    ),
  ];
}

Rect _hitboxAround(Offset focus) {
  const width = 0.07;
  const height = 0.08;
  return Rect.fromCenter(center: focus, width: width, height: height);
}

Offset _toOffset(FirenzePreviewPoint point) => Offset(point.x, point.y);

Offset _cityToWorld(Offset city) {
  return Offset(
    (firenzePreviewScenicPaddingX + city.dx * firenzePreviewCityCanvasWidth) /
        firenzePreviewWorldWidth,
    (firenzePreviewScenicPaddingY + city.dy * firenzePreviewCityCanvasHeight) /
        firenzePreviewWorldHeight,
  );
}
