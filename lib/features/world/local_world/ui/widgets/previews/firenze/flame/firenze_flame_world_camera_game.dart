import 'dart:ui';

import 'package:flame/components.dart' hide Matrix4;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show Matrix4;

import '../core/firenze_preview_camera.dart';
import '../core/firenze_preview_world.dart';

String firenzeFlameImageCacheKey(String assetPath) {
  const prefix = 'assets/images/';
  if (!assetPath.startsWith(prefix)) {
    throw ArgumentError.value(
      assetPath,
      'assetPath',
      'Firenze Flame proof only accepts app-bundled image assets.',
    );
  }
  return assetPath.substring(prefix.length);
}

class FirenzeFlameWorldCameraConfig {
  const FirenzeFlameWorldCameraConfig._();

  static Vector2 get worldSize =>
      Vector2(firenzePreviewWorldWidth, firenzePreviewWorldHeight);

  static Rect get worldRect => firenzePreviewWorldRect;

  static Rect get cityRect => firenzePreviewCityRect;

  static Vector2 get cityPosition =>
      Vector2(firenzePreviewCityRect.left, firenzePreviewCityRect.top);

  static Vector2 get citySize =>
      Vector2(firenzePreviewCityCanvasWidth, firenzePreviewCityCanvasHeight);

  static String get mapImageCacheKey =>
      firenzeFlameImageCacheKey(firenzePreviewWorldMapOnlyAssetPath);

  static String get riverMaskImageCacheKey =>
      firenzeFlameImageCacheKey(firenzePreviewWorldRiverMaskAssetPath);
}

const firenzeFlameScenicBackgroundGradientColors = <Color>[
  Color(0xFF173A36),
  Color(0xFF24492F),
  Color(0xFF17311F),
];

const firenzeFlameScenicBackgroundGradientStops = <double>[0, 0.56, 1];

bool firenzeFlamePreviewGradientContractsAreValid() {
  return firenzeFlameScenicBackgroundGradientColors.length <= 2 ||
      firenzeFlameScenicBackgroundGradientColors.length ==
          firenzeFlameScenicBackgroundGradientStops.length;
}

class FirenzeFlameCameraState {
  const FirenzeFlameCameraState({required this.position, required this.zoom});

  final Offset position;
  final double zoom;
}

class FirenzeFlameCameraDebugSnapshot {
  const FirenzeFlameCameraDebugSnapshot({
    required this.viewportSize,
    required this.cameraPosition,
    required this.zoom,
    required this.hardMinScale,
    required this.maxScale,
  });

  factory FirenzeFlameCameraDebugSnapshot.empty() {
    return const FirenzeFlameCameraDebugSnapshot(
      viewportSize: Size.zero,
      cameraPosition: Offset.zero,
      zoom: 1,
      hardMinScale: 1,
      maxScale: 1,
    );
  }

  final Size viewportSize;
  final Offset cameraPosition;
  final double zoom;
  final double hardMinScale;
  final double maxScale;
}

class FirenzeFlameCameraBridge {
  const FirenzeFlameCameraBridge._();

  static FirenzeFlameCameraState stateFromCoreMatrix(
    Matrix4 matrix,
    Size viewportSize,
  ) {
    final zoom = matrix.storage[0];
    final translation = Offset(matrix.storage[12], matrix.storage[13]);
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );
    return FirenzeFlameCameraState(
      position: (viewportCenter - translation) / zoom,
      zoom: zoom,
    );
  }

  static Matrix4 coreMatrixFromState(
    FirenzeFlameCameraState state,
    Size viewportSize,
  ) {
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );
    final translation = viewportCenter - state.position * state.zoom;
    return Matrix4.identity()
      ..setEntry(0, 0, state.zoom)
      ..setEntry(1, 1, state.zoom)
      ..setEntry(0, 3, translation.dx)
      ..setEntry(1, 3, translation.dy);
  }

  static FirenzeFlameCameraState clampState(
    FirenzeFlameCameraState state,
    FirenzePreviewCameraLayout layout,
  ) {
    return stateFromCoreMatrix(
      layout.clampMatrix(coreMatrixFromState(state, layout.viewportSize)),
      layout.viewportSize,
    );
  }

  static FirenzeFlameCameraState overviewState(
    FirenzePreviewCameraLayout layout,
  ) {
    return stateFromCoreMatrix(layout.overviewTransform(), layout.viewportSize);
  }

  static FirenzeFlameCameraState updateGesture({
    required Matrix4 startMatrix,
    required Offset startFocalPoint,
    required Offset currentFocalPoint,
    required double scaleFactor,
    required FirenzePreviewCameraLayout layout,
  }) {
    return stateFromCoreMatrix(
      FirenzePreviewCameraGesture.update(
        startMatrix: startMatrix,
        startFocalPoint: startFocalPoint,
        currentFocalPoint: currentFocalPoint,
        scaleFactor: scaleFactor,
        layout: layout,
      ),
      layout.viewportSize,
    );
  }

  static Rect visibleWorldRect(
    FirenzeFlameCameraState state,
    Size viewportSize,
  ) {
    final visibleWidth = viewportSize.width / state.zoom;
    final visibleHeight = viewportSize.height / state.zoom;
    return Rect.fromCenter(
      center: state.position,
      width: visibleWidth,
      height: visibleHeight,
    );
  }
}

class FirenzeFlameWorld extends World {}

class FirenzeFlameWorldCameraGame extends FlameGame<FirenzeFlameWorld> {
  FirenzeFlameWorldCameraGame() : super(world: FirenzeFlameWorld());

  FirenzePreviewCameraLayout? _cameraLayout;
  Matrix4? _gestureStartMatrix;
  Offset? _gestureStartFocalPoint;
  Size _viewportSize = Size.zero;

  final ValueNotifier<FirenzeFlameCameraDebugSnapshot> debugSnapshot =
      ValueNotifier(FirenzeFlameCameraDebugSnapshot.empty());

  FirenzePreviewCameraLayout? get cameraLayout => _cameraLayout;

  FirenzeFlameCameraState get cameraState => FirenzeFlameCameraState(
    position: Offset(
      camera.viewfinder.position.x,
      camera.viewfinder.position.y,
    ),
    zoom: camera.viewfinder.zoom,
  );

  Rect get visibleWorldRect =>
      FirenzeFlameCameraBridge.visibleWorldRect(cameraState, _viewportSize);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;
    await _loadWorldLayers();
    if (canvasSize.x > 0 && canvasSize.y > 0) {
      applyViewport(Size(canvasSize.x, canvasSize.y), resetToOverview: true);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x > 0 && size.y > 0) {
      applyViewport(Size(size.x, size.y), resetToOverview: true);
    }
  }

  Future<void> _loadWorldLayers() async {
    world.add(_FirenzeFlameScenicBackground());

    final mapImage = await images.load(
      FirenzeFlameWorldCameraConfig.mapImageCacheKey,
    );
    world.add(
      SpriteComponent.fromImage(
        mapImage,
        position: FirenzeFlameWorldCameraConfig.cityPosition,
        size: FirenzeFlameWorldCameraConfig.citySize,
        priority: 10,
      ),
    );

    final riverMaskImage = await images.load(
      FirenzeFlameWorldCameraConfig.riverMaskImageCacheKey,
    );
    world.add(
      SpriteComponent.fromImage(
        riverMaskImage,
        position: FirenzeFlameWorldCameraConfig.cityPosition,
        size: FirenzeFlameWorldCameraConfig.citySize,
        paint: Paint()..color = const Color(0x2249D7FF),
        priority: 20,
      ),
    );
  }

  void applyViewport(Size viewportSize, {required bool resetToOverview}) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      return;
    }
    _viewportSize = viewportSize;
    final layout = FirenzePreviewCameraLayout.fromViewport(viewportSize);
    _cameraLayout = layout;

    if (resetToOverview) {
      _applyState(FirenzeFlameCameraBridge.overviewState(layout));
    } else {
      _applyState(FirenzeFlameCameraBridge.clampState(cameraState, layout));
    }
  }

  void resetToOverview() {
    final layout = _cameraLayout;
    if (layout == null) {
      return;
    }
    _applyState(FirenzeFlameCameraBridge.overviewState(layout));
  }

  void handleScaleStart(Offset localFocalPoint) {
    final layout = _cameraLayout;
    if (layout == null) {
      return;
    }
    _gestureStartMatrix = FirenzeFlameCameraBridge.coreMatrixFromState(
      cameraState,
      layout.viewportSize,
    );
    _gestureStartFocalPoint = localFocalPoint;
  }

  void handleScaleUpdate({
    required Offset currentFocalPoint,
    required double scaleFactor,
  }) {
    final layout = _cameraLayout;
    final startMatrix = _gestureStartMatrix;
    final startFocalPoint = _gestureStartFocalPoint;
    if (layout == null || startMatrix == null || startFocalPoint == null) {
      return;
    }
    _applyState(
      FirenzeFlameCameraBridge.updateGesture(
        startMatrix: startMatrix,
        startFocalPoint: startFocalPoint,
        currentFocalPoint: currentFocalPoint,
        scaleFactor: scaleFactor,
        layout: layout,
      ),
    );
  }

  void handleScaleEnd() {
    _gestureStartMatrix = null;
    _gestureStartFocalPoint = null;
    final layout = _cameraLayout;
    if (layout != null) {
      _applyState(FirenzeFlameCameraBridge.clampState(cameraState, layout));
    }
  }

  void _applyState(FirenzeFlameCameraState state) {
    camera.viewfinder.zoom = state.zoom;
    camera.viewfinder.position = Vector2(state.position.dx, state.position.dy);
    final layout = _cameraLayout;
    if (layout != null) {
      debugSnapshot.value = FirenzeFlameCameraDebugSnapshot(
        viewportSize: layout.viewportSize,
        cameraPosition: state.position,
        zoom: state.zoom,
        hardMinScale: layout.hardMinScale,
        maxScale: layout.maxScale,
      );
    }
  }
}

class _FirenzeFlameScenicBackground extends PositionComponent {
  _FirenzeFlameScenicBackground()
    : super(
        position: Vector2.zero(),
        size: FirenzeFlameWorldCameraConfig.worldSize,
        priority: 0,
      );

  @override
  void render(Canvas canvas) {
    final bounds = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(0, size.y),
        firenzeFlameScenicBackgroundGradientColors,
        firenzeFlameScenicBackgroundGradientStops,
      );
    canvas.drawRect(bounds, paint);

    final ringPaint = Paint()
      ..color = const Color(0xFF86B86B).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(42, 64, 560, 310),
        const Radius.circular(68),
      ),
      ringPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x - 610, size.y - 360, 540, 250),
        const Radius.circular(76),
      ),
      ringPaint,
    );
  }
}
