import 'dart:ui';

import 'firenze_preview_camera.dart';

const firenzePreviewWorldMapOnlyAssetPath =
    'assets/images/world/previews/firenze_city_entry/'
    'firenze_city_entry_map_only_preview_v1.png';
const firenzePreviewWorldRiverMaskAssetPath =
    'assets/images/world/previews/firenze_city_entry/'
    'firenze_city_river_mask_preview_v1.png';

enum FirenzePreviewWorldCoordinateSpace {
  cityCoordinateSpace,
  worldCoordinateSpace,
}

enum FirenzePreviewWorldLayer {
  scenicBackground,
  cityMap,
  riverAnimationMask,
  routeEffects,
  beaconsMarkers,
  characterLayerPlaceholder,
  worldEffects,
  hudOverlaysOutsideWorld,
}

class FirenzePreviewWorldLayerDefinition {
  const FirenzePreviewWorldLayerDefinition({
    required this.layer,
    required this.label,
    required this.coordinateSpace,
    required this.insideWorldTransform,
  });

  final FirenzePreviewWorldLayer layer;
  final String label;
  final FirenzePreviewWorldCoordinateSpace coordinateSpace;
  final bool insideWorldTransform;
}

class FirenzePreviewImageLayerContract {
  const FirenzePreviewImageLayerContract({
    required this.assetPath,
    required this.coordinateSpace,
    required this.canvasSize,
    required this.previewOnly,
  });

  final String assetPath;
  final FirenzePreviewWorldCoordinateSpace coordinateSpace;
  final Size canvasSize;
  final bool previewOnly;
}

class FirenzePreviewRiverMaskContract {
  const FirenzePreviewRiverMaskContract({
    required this.assetPath,
    required this.coordinateSpace,
    required this.canvasSize,
    required this.previewOnly,
    required this.maskOnly,
  });

  final String assetPath;
  final FirenzePreviewWorldCoordinateSpace coordinateSpace;
  final Size canvasSize;
  final bool previewOnly;
  final bool maskOnly;
}

class FirenzePreviewRiverAnimationContract {
  const FirenzePreviewRiverAnimationContract({
    required this.usesRiverMask,
    required this.cityCoordinateSpaceOnly,
    required this.noNavigationMutation,
    required this.noHitboxMutation,
  });

  final bool usesRiverMask;
  final bool cityCoordinateSpaceOnly;
  final bool noNavigationMutation;
  final bool noHitboxMutation;
}

class FirenzePreviewScenicRingContract {
  const FirenzePreviewScenicRingContract({
    required this.scenicOnly,
    required this.notWalkable,
    required this.notSelectable,
    required this.notBuildable,
    required this.worldRect,
    required this.cityRect,
  });

  final bool scenicOnly;
  final bool notWalkable;
  final bool notSelectable;
  final bool notBuildable;
  final Rect worldRect;
  final Rect cityRect;
}

const firenzePreviewWorldMapOnlyContract = FirenzePreviewImageLayerContract(
  assetPath: firenzePreviewWorldMapOnlyAssetPath,
  coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
  canvasSize: Size(
    firenzePreviewCityCanvasWidth,
    firenzePreviewCityCanvasHeight,
  ),
  previewOnly: true,
);

const firenzePreviewWorldRiverMaskContract = FirenzePreviewRiverMaskContract(
  assetPath: firenzePreviewWorldRiverMaskAssetPath,
  coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
  canvasSize: Size(
    firenzePreviewCityCanvasWidth,
    firenzePreviewCityCanvasHeight,
  ),
  previewOnly: true,
  maskOnly: true,
);

const firenzePreviewWorldRiverAnimationContract =
    FirenzePreviewRiverAnimationContract(
      usesRiverMask: true,
      cityCoordinateSpaceOnly: true,
      noNavigationMutation: true,
      noHitboxMutation: true,
    );

const firenzePreviewScenicRingContract = FirenzePreviewScenicRingContract(
  scenicOnly: true,
  notWalkable: true,
  notSelectable: true,
  notBuildable: true,
  worldRect: firenzePreviewWorldRect,
  cityRect: firenzePreviewCityRect,
);

const firenzePreviewWorldLayerOrder = <FirenzePreviewWorldLayerDefinition>[
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.scenicBackground,
    label: 'scenic background',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.worldCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.cityMap,
    label: 'city map',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.riverAnimationMask,
    label: 'river animation/mask',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.routeEffects,
    label: 'route effects',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.beaconsMarkers,
    label: 'beacons/markers',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.worldCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.characterLayerPlaceholder,
    label: 'character layer placeholder',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.worldEffects,
    label: 'world effects',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.worldCoordinateSpace,
    insideWorldTransform: true,
  ),
  FirenzePreviewWorldLayerDefinition(
    layer: FirenzePreviewWorldLayer.hudOverlaysOutsideWorld,
    label: 'hud overlays outside the World',
    coordinateSpace: FirenzePreviewWorldCoordinateSpace.worldCoordinateSpace,
    insideWorldTransform: false,
  ),
];

bool firenzePreviewCityRectIsInsideWorldRect() {
  return firenzePreviewCityRect.left >= firenzePreviewWorldRect.left &&
      firenzePreviewCityRect.top >= firenzePreviewWorldRect.top &&
      firenzePreviewCityRect.right <= firenzePreviewWorldRect.right &&
      firenzePreviewCityRect.bottom <= firenzePreviewWorldRect.bottom;
}

bool firenzePreviewRiverMaskUsesCityCoordinateSpace() {
  return firenzePreviewWorldRiverMaskContract.coordinateSpace ==
          FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace &&
      firenzePreviewWorldRiverMaskContract.canvasSize ==
          firenzePreviewCityRect.size;
}

bool firenzePreviewMapOnlyUsesCityCoordinateSpace() {
  return firenzePreviewWorldMapOnlyContract.coordinateSpace ==
          FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace &&
      firenzePreviewWorldMapOnlyContract.canvasSize ==
          firenzePreviewCityRect.size;
}

bool firenzePreviewScenicRingIsPlanningOnly() {
  return firenzePreviewScenicRingContract.scenicOnly &&
      firenzePreviewScenicRingContract.notWalkable &&
      firenzePreviewScenicRingContract.notSelectable &&
      firenzePreviewScenicRingContract.notBuildable;
}

List<String> firenzePreviewWorldLayerOrderLabels() {
  return firenzePreviewWorldLayerOrder
      .map((definition) => definition.label)
      .toList(growable: false);
}
