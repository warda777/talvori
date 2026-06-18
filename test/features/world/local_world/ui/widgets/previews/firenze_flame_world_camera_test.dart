import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/data/firenze_city_preview_navigation_data.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/core/firenze_preview_camera.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/core/firenze_preview_world.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/flame/firenze_flame_world_camera_game.dart';

void main() {
  test('Flame proof uses the Firenze technical core world values', () {
    expect(FirenzeFlameWorldCameraConfig.worldRect, firenzePreviewWorldRect);
    expect(FirenzeFlameWorldCameraConfig.cityRect, firenzePreviewCityRect);
    expect(FirenzeFlameWorldCameraConfig.worldSize.x, 2192);
    expect(FirenzeFlameWorldCameraConfig.worldSize.y, 1281);
    expect(FirenzeFlameWorldCameraConfig.cityPosition.x, 260);
    expect(FirenzeFlameWorldCameraConfig.cityPosition.y, 170);
    expect(FirenzeFlameWorldCameraConfig.citySize.x, 1672);
    expect(FirenzeFlameWorldCameraConfig.citySize.y, 941);
    expect(
      FirenzeFlameWorldCameraConfig.mapImageCacheKey,
      'world/previews/firenze_city_entry/'
      'firenze_city_entry_map_only_preview_v1.png',
    );
    expect(
      FirenzeFlameWorldCameraConfig.riverMaskImageCacheKey,
      'world/previews/firenze_city_entry/'
      'firenze_city_river_mask_preview_v1.png',
    );
    expect(firenzePreviewMapOnlyUsesCityCoordinateSpace(), isTrue);
    expect(firenzePreviewRiverMaskUsesCityCoordinateSpace(), isTrue);
  });

  test('Flame preview gradients define matching stops', () {
    expect(firenzeFlamePreviewGradientContractsAreValid(), isTrue);
    expect(
      firenzeFlameScenicBackgroundGradientStops,
      hasLength(firenzeFlameScenicBackgroundGradientColors.length),
    );
  });

  test('initial Flame camera state fills viewport with bounded world', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );
    final state = FirenzeFlameCameraBridge.overviewState(layout);
    final visible = FirenzeFlameCameraBridge.visibleWorldRect(
      state,
      layout.viewportSize,
    );

    expect(state.zoom, layout.overviewScale);
    expect(state.zoom, greaterThanOrEqualTo(layout.hardMinScale));
    expect(state.zoom, lessThanOrEqualTo(layout.maxScale));
    expect(state.position.dx, closeTo(layout.cityRect.center.dx, 0.000001));
    expect(state.position.dy, closeTo(layout.cityRect.center.dy, 0.000001));
    _expectVisibleInsideWorld(visible);
  });

  test('Flame camera pan and zoom clamps prevent empty space', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );

    final lowZoom = FirenzeFlameCameraBridge.clampState(
      const FirenzeFlameCameraState(position: Offset(-4000, 9000), zoom: 0.01),
      layout,
    );
    expect(lowZoom.zoom, layout.hardMinScale);
    _expectVisibleInsideWorld(
      FirenzeFlameCameraBridge.visibleWorldRect(lowZoom, layout.viewportSize),
    );

    final highZoom = FirenzeFlameCameraBridge.clampState(
      const FirenzeFlameCameraState(position: Offset(9000, -4000), zoom: 999),
      layout,
    );
    expect(highZoom.zoom, layout.maxScale);
    _expectVisibleInsideWorld(
      FirenzeFlameCameraBridge.visibleWorldRect(highZoom, layout.viewportSize),
    );
  });

  test('Flame gesture bridge clamps live scale updates immediately', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(852, 393),
    );
    final overview = FirenzeFlameCameraBridge.overviewState(layout);
    final startMatrix = FirenzeFlameCameraBridge.coreMatrixFromState(
      overview,
      layout.viewportSize,
    );

    final tiny = FirenzeFlameCameraBridge.updateGesture(
      startMatrix: startMatrix,
      startFocalPoint: const Offset(320, 190),
      currentFocalPoint: const Offset(324, 194),
      scaleFactor: 0.001,
      layout: layout,
    );
    expect(tiny.zoom, greaterThanOrEqualTo(layout.hardMinScale));
    _expectVisibleInsideWorld(
      FirenzeFlameCameraBridge.visibleWorldRect(tiny, layout.viewportSize),
    );

    final huge = FirenzeFlameCameraBridge.updateGesture(
      startMatrix: startMatrix,
      startFocalPoint: const Offset(320, 190),
      currentFocalPoint: const Offset(260, 160),
      scaleFactor: 80,
      layout: layout,
    );
    expect(huge.zoom, lessThanOrEqualTo(layout.maxScale));
    _expectVisibleInsideWorld(
      FirenzeFlameCameraBridge.visibleWorldRect(huge, layout.viewportSize),
    );
  });

  test('Flame proof does not mutate generated navigation source data', () {
    expect(firenzePreviewNavigationNodeCount, 181);
    expect(firenzePreviewNavigationNodes, hasLength(181));
    expect(firenzePreviewNavigationEdgeCount, 221);
    expect(firenzePreviewNavigationEdges, hasLength(221));
  });
}

void _expectVisibleInsideWorld(Rect visible) {
  expect(visible.left, greaterThanOrEqualTo(-0.000001));
  expect(visible.top, greaterThanOrEqualTo(-0.000001));
  expect(
    visible.right,
    lessThanOrEqualTo(firenzePreviewWorldRect.right + 0.000001),
  );
  expect(
    visible.bottom,
    lessThanOrEqualTo(firenzePreviewWorldRect.bottom + 0.000001),
  );
}
