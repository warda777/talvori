import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze_city_arrival_and_parcel_visit_preview.dart'
    as preview;
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/core/firenze_preview_camera.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/core/firenze_preview_navigation_graph.dart';
import 'package:talvori/features/world/local_world/ui/widgets/previews/firenze/core/firenze_preview_world.dart';

void main() {
  const expectedSourceSha =
      '58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3';

  test('Firenze preview navigation data matches the master SVG source', () {
    expect(firenzePreviewSourceSha256, expectedSourceSha);
    expect(firenzePreviewNavigationNodeCount, 181);
    expect(firenzePreviewNavigationNodes, hasLength(181));
    expect(firenzePreviewNavigationEdgeCount, 221);
    expect(firenzePreviewNavigationEdges, hasLength(221));
    expect(firenzePreviewRiverMaskSourceSha256, expectedSourceSha);
    expect(firenzePreviewRiverMaskCanvasWidth, 1672);
    expect(firenzePreviewRiverMaskCanvasHeight, 941);
    expect(firenzePreviewAnchorPoints, contains('city_spawn_start'));
    expect(
      firenzePreviewParcelEntries.values.expand((ids) => ids),
      hasLength(28),
    );
    expect(
      firenzePreviewParcelAccess.values.expand((ids) => ids),
      hasLength(28),
    );

    final graphNodeIds = {
      ...firenzePreviewNavigationNodes.keys,
      'city_spawn_start',
    };
    for (var index = 1; index <= 14; index++) {
      final parcelId = 'P${index.toString().padLeft(2, '0')}';
      expect(firenzePreviewParcelEntries, contains(parcelId));
      expect(firenzePreviewParcelAccess, contains(parcelId));
      for (final entryId in firenzePreviewParcelEntries[parcelId]!) {
        expect(graphNodeIds, contains(entryId), reason: entryId);
      }
      for (final accessId in firenzePreviewParcelAccess[parcelId]!) {
        expect(graphNodeIds, contains(accessId), reason: accessId);
      }
    }
  });

  test('river mask preview asset matches the source canvas dimensions', () {
    final file = File(firenzePreviewRiverMaskAssetPath);
    expect(file.existsSync(), isTrue);

    final bytes = file.readAsBytesSync();
    expect(bytes.length, greaterThan(24));
    expect(String.fromCharCodes(bytes.sublist(1, 4)), 'PNG');
    final data = bytes.buffer.asByteData();
    expect(data.getUint32(16), firenzePreviewRiverMaskCanvasWidth);
    expect(data.getUint32(20), firenzePreviewRiverMaskCanvasHeight);
  });

  test('Firenze world core contracts keep assets and layers stable', () {
    expect(
      firenzePreviewWorldMapOnlyAssetPath,
      'assets/images/world/previews/firenze_city_entry/'
      'firenze_city_entry_map_only_preview_v1.png',
    );
    expect(
      firenzePreviewWorldRiverMaskAssetPath,
      'assets/images/world/previews/firenze_city_entry/'
      'firenze_city_river_mask_preview_v1.png',
    );
    expect(
      firenzePreviewWorldRiverMaskAssetPath,
      firenzePreviewRiverMaskAssetPath,
    );
    expect(File(firenzePreviewWorldMapOnlyAssetPath).existsSync(), isTrue);
    expect(File(firenzePreviewWorldRiverMaskAssetPath).existsSync(), isTrue);

    expect(firenzePreviewCityCanvasWidth, 1672);
    expect(firenzePreviewCityCanvasHeight, 941);
    expect(firenzePreviewScenicPaddingX, 260);
    expect(firenzePreviewScenicPaddingY, 170);
    expect(firenzePreviewWorldWidth, 2192);
    expect(firenzePreviewWorldHeight, 1281);
    expect(firenzePreviewWorldRect, const Rect.fromLTWH(0, 0, 2192, 1281));
    expect(firenzePreviewCityRect, const Rect.fromLTWH(260, 170, 1672, 941));
    expect(firenzePreviewCityRectIsInsideWorldRect(), isTrue);

    expect(
      firenzePreviewWorldMapOnlyContract.coordinateSpace,
      FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    );
    expect(firenzePreviewMapOnlyUsesCityCoordinateSpace(), isTrue);
    expect(
      firenzePreviewWorldRiverMaskContract.coordinateSpace,
      FirenzePreviewWorldCoordinateSpace.cityCoordinateSpace,
    );
    expect(firenzePreviewRiverMaskUsesCityCoordinateSpace(), isTrue);
    expect(firenzePreviewWorldRiverMaskContract.maskOnly, isTrue);
    expect(firenzePreviewWorldRiverAnimationContract.usesRiverMask, isTrue);
    expect(
      firenzePreviewWorldRiverAnimationContract.cityCoordinateSpaceOnly,
      isTrue,
    );
    expect(
      firenzePreviewWorldRiverAnimationContract.noNavigationMutation,
      isTrue,
    );
    expect(firenzePreviewWorldRiverAnimationContract.noHitboxMutation, isTrue);

    expect(firenzePreviewScenicRingContract.scenicOnly, isTrue);
    expect(firenzePreviewScenicRingContract.notWalkable, isTrue);
    expect(firenzePreviewScenicRingContract.notSelectable, isTrue);
    expect(firenzePreviewScenicRingContract.notBuildable, isTrue);
    expect(firenzePreviewScenicRingIsPlanningOnly(), isTrue);

    expect(firenzePreviewWorldLayerOrderLabels(), [
      'scenic background',
      'city map',
      'river animation/mask',
      'route effects',
      'beacons/markers',
      'character layer placeholder',
      'world effects',
      'hud overlays outside the World',
    ]);
    expect(firenzePreviewWorldLayerOrder.last.insideWorldTransform, isFalse);
  });

  test('all navigation edge endpoints resolve to source graph nodes', () {
    final graphNodeIds = {
      ...firenzePreviewNavigationNodes.keys,
      'city_spawn_start',
    };

    for (final edge in firenzePreviewNavigationEdges) {
      expect(graphNodeIds, contains(edge.from), reason: edge.id);
      expect(graphNodeIds, contains(edge.to), reason: edge.id);
      expect(edge.points.length, greaterThanOrEqualTo(2), reason: edge.id);
      expect(edge.length, greaterThan(0), reason: edge.id);
    }
  });

  test('city_spawn_start is connected to the preview graph', () {
    final spawnEdges = firenzePreviewNavigationEdges.where(
      (edge) =>
          edge.from == 'city_spawn_start' || edge.to == 'city_spawn_start',
    );

    expect(spawnEdges, isNotEmpty);
  });

  test(
    'P01-P14 routes use only real graph edges and end at parcel entries',
    () {
      final graph = FirenzePreviewNavigationGraph();
      final graphNodeIds = {
        ...firenzePreviewNavigationNodes.keys,
        'city_spawn_start',
      };
      final edgeById = {
        for (final edge in firenzePreviewNavigationEdges) edge.id: edge,
      };

      for (var index = 1; index <= 14; index++) {
        final parcelId = 'P${index.toString().padLeft(2, '0')}';
        final route = graph.routeToParcel(parcelId);
        final expectedEntries = firenzePreviewParcelEntries[parcelId]!;

        expect(route.nodeIds.first, 'city_spawn_start', reason: parcelId);
        expect(expectedEntries, contains(route.entryId), reason: parcelId);
        expect(route.nodeIds.last, route.entryId, reason: parcelId);
        expect(
          route.accessId,
          route.entryId.replaceFirst('_entry_', '_access_'),
        );
        expect(
          route.nodeIds[route.nodeIds.length - 2],
          route.accessId,
          reason: '$parcelId must enter through its matching access node',
        );
        expect(route.nodeIds, isNot(contains('${parcelId}_anchor')));
        expect(route.edgeIds, hasLength(route.nodeIds.length - 1));
        expect(route.points, isNotEmpty, reason: parcelId);

        for (final nodeId in route.nodeIds) {
          expect(graphNodeIds, contains(nodeId), reason: '$parcelId $nodeId');
        }

        for (var edgeIndex = 0; edgeIndex < route.edgeIds.length; edgeIndex++) {
          final edgeId = route.edgeIds[edgeIndex];
          final edge = edgeById[edgeId];
          expect(edge, isNotNull, reason: '$parcelId $edgeId');
          final from = route.nodeIds[edgeIndex];
          final to = route.nodeIds[edgeIndex + 1];
          final connectsForward = edge!.from == from && edge.to == to;
          final connectsReverse = edge.from == to && edge.to == from;
          expect(
            connectsForward || connectsReverse,
            isTrue,
            reason: '$parcelId $edgeId must connect $from -> $to',
          );
        }

        _expectBridgeUseIsACompleteChain(route);
      }
    },
  );

  test('active first-fun targets report graph-authentic route choices', () {
    final graph = FirenzePreviewNavigationGraph();
    const expectedNodeSequences = {
      'P01': [
        'city_spawn_start',
        'N044_crossroad',
        'N042_crossroad',
        'P01_access_1',
        'P01_entry_1',
      ],
      'P03': [
        'city_spawn_start',
        'N001_crossroad',
        'N002_crossroad',
        'P02_access_1',
        'N006_crossroad',
        'P03_access_1',
        'P03_entry_1',
      ],
      'P09': [
        'city_spawn_start',
        'N001_crossroad',
        'N043_crossroad',
        'N045_crossroad',
        'P14_access_2',
        'N052_crossroad',
        'N047_crossroad',
        'N071_crossroad',
        'B08_N',
        'B08_M',
        'B08_S',
        'N070_crossroad',
        'N069_crossroad',
        'N028_crossroad',
        'P09_access_2',
        'P09_entry_2',
      ],
    };

    for (final parcelId in ['P01', 'P03', 'P09']) {
      final route = graph.routeToParcel(parcelId);
      // Keep this output visible in the check log: it is the compact
      // route evidence requested for the first-fun proof.
      // ignore: avoid_print
      print(
        '$parcelId entry=${route.entryId} '
        'nodes=${route.nodeIds.join(' -> ')} '
        'edges=${route.edgeIds.join(' -> ')} '
        'bridges=${route.bridgeChains.isEmpty ? 'keine' : route.bridgeChains.join(',')}',
      );

      expect(route.nodeIds.first, 'city_spawn_start');
      expect(route.nodeIds.last, route.entryId);
      expect(route.nodeIds[route.nodeIds.length - 2], route.accessId);
      expect(route.nodeIds, expectedNodeSequences[parcelId]);
    }

    final p09Route = graph.routeToParcel('P09');
    expect(p09Route.bridgeChains, contains('B08'));
    expect(p09Route.nodeIds, containsAllInOrder(['B08_N', 'B08_M', 'B08_S']));
  });

  test('active first-fun targets use constant preview travel speed', () {
    final graph = FirenzePreviewNavigationGraph();
    final durations = <int>{};
    const expectedLengths = {'P01': 86.37, 'P03': 368.90, 'P09': 593.29};

    for (final parcelId in ['P01', 'P03', 'P09']) {
      final route = graph.routeToParcel(parcelId);
      final length = firenzePreviewRouteCanvasLength(route);
      final duration = firenzePreviewTravelDurationForRoute(route);
      final speed = length / duration.inMilliseconds * 1000;
      durations.add(duration.inMilliseconds);

      // ignore: avoid_print
      print(
        '$parcelId lengthPx=${length.toStringAsFixed(2)} '
        'durationMs=${duration.inMilliseconds} '
        'speedPxPerSecond=${speed.toStringAsFixed(2)}',
      );

      expect(length, greaterThan(0), reason: parcelId);
      expect(
        length,
        closeTo(expectedLengths[parcelId]!, 0.01),
        reason: '$parcelId route length should stay unchanged',
      );
      expect(duration.inMilliseconds, greaterThan(0), reason: parcelId);
      expect(
        speed,
        closeTo(firenzePreviewWorkerTravelSpeedPxPerSecond, 0.5),
        reason: parcelId,
      );
    }

    expect(
      durations,
      hasLength(3),
      reason: 'P01, P03 and P09 should have route-specific travel durations',
    );
  });

  test('travel glow samples only real route segments', () {
    final graph = FirenzePreviewNavigationGraph();

    for (final parcelId in ['P01', 'P03', 'P09']) {
      final route = graph.routeToParcel(parcelId);

      for (final progress in const [0.0, 0.18, 0.5, 0.83, 1.0]) {
        final glowPoint = firenzePreviewRoutePointAtProgress(route, progress);

        expect(
          _pointIsOnRoutePolyline(glowPoint, route.points),
          isTrue,
          reason: '$parcelId progress=$progress',
        );
      }

      final start = firenzePreviewRoutePointAtProgress(route, 0);
      final end = firenzePreviewRoutePointAtProgress(route, 1);
      expect(start.x, closeTo(route.points.first.x, 0.0000001));
      expect(start.y, closeTo(route.points.first.y, 0.0000001));
      expect(end.x, closeTo(route.points.last.x, 0.0000001));
      expect(end.y, closeTo(route.points.last.y, 0.0000001));
      expect(route.nodeIds.last, route.entryId, reason: parcelId);
      expect(route.nodeIds.last, isNot(contains('${parcelId}_anchor')));
    }
  });

  test('camera bounds cover viewport and clamp empty space away', () {
    const worldSize = Size(2192, 1281);
    const viewportSize = Size(852, 393);
    final minScale = FirenzePreviewCameraMath.minScaleFor(
      viewportSize: viewportSize,
      worldSize: worldSize,
    );
    final maxScale = minScale * 4.2;

    expect(
      worldSize.width * minScale,
      greaterThanOrEqualTo(viewportSize.width),
    );
    expect(
      worldSize.height * minScale,
      greaterThanOrEqualTo(viewportSize.height),
    );

    final loose = Matrix4.identity()
      ..setEntry(0, 0, maxScale * 3)
      ..setEntry(1, 1, maxScale * 3)
      ..setEntry(0, 3, 900)
      ..setEntry(1, 3, -5000);
    final clamped = FirenzePreviewCameraMath.clampMatrix(
      loose,
      viewportSize: viewportSize,
      worldSize: worldSize,
      minScale: minScale,
      maxScale: maxScale,
    );
    final scale = clamped.storage[0];
    final dx = clamped.storage[12];
    final dy = clamped.storage[13];

    expect(scale, inInclusiveRange(minScale, maxScale));
    expect(
      dx,
      inInclusiveRange(viewportSize.width - worldSize.width * scale, 0),
    );
    expect(
      dy,
      inInclusiveRange(viewportSize.height - worldSize.height * scale, 0),
    );
  });

  test('initial landscape camera fills the viewport with the world scene', () {
    const viewportSize = Size(1805, 832);
    final layout = FirenzePreviewCameraLayout.fromViewport(viewportSize);
    final initial = layout.overviewTransform();

    expect(layout.worldRect, const Rect.fromLTWH(0, 0, 2192, 1281));
    expect(layout.cityRect, const Rect.fromLTWH(260, 170, 1672, 941));
    expect(firenzePreviewCityCanvasWidth, 1672);
    expect(firenzePreviewCityCanvasHeight, 941);
    expect(firenzePreviewScenicPaddingX, 260);
    expect(firenzePreviewScenicPaddingY, 170);
    expect(firenzePreviewWorldWidth, 2192);
    expect(firenzePreviewWorldHeight, 1281);
    expect(layout.hardMinScale, closeTo(1805 / 2192, 0.000001));
    expect(layout.overviewScale, greaterThanOrEqualTo(layout.hardMinScale));
    expect(initial.storage[0], layout.overviewScale);
    expect(initial.storage[0], greaterThanOrEqualTo(layout.hardMinScale));
    _expectMatrixCoversViewport(initial, layout);

    final cityCenter = _worldToViewport(layout.cityRect.center, initial);
    expect(cityCenter.dx, closeTo(viewportSize.width / 2, 0.000001));
    expect(cityCenter.dy, closeTo(viewportSize.height / 2, 0.000001));
    expect(
      layout.initialTranslation,
      Offset(initial.storage[12], initial.storage[13]),
    );

    // ignore: avoid_print
    print(
      'landscape hardMin=${layout.hardMinScale.toStringAsFixed(6)} '
      'overview=${layout.overviewScale.toStringAsFixed(6)} '
      'translation=${layout.initialTranslation.dx.toStringAsFixed(2)},'
      '${layout.initialTranslation.dy.toStringAsFixed(2)}',
    );
  });

  test('portrait to landscape recomputes the camera layout', () {
    final portrait = FirenzePreviewCameraLayout.fromViewport(
      const Size(393, 852),
    );
    final landscape = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );
    final transition = FirenzePreviewCameraViewportTransition.fromViewports(
      previousViewportSize: const Size(393, 852),
      nextViewportSize: const Size(1805, 832),
    );

    expect(portrait.viewportSize, isNot(landscape.viewportSize));
    expect(portrait.initialTranslation, isNot(landscape.initialTranslation));
    expect(transition.previousLayout.viewportSize, portrait.viewportSize);
    expect(transition.nextLayout.viewportSize, landscape.viewportSize);
    expect(transition.nextMatrix.storage[0], landscape.overviewScale);
    final landscapeInitial = landscape.overviewTransform();
    expect(landscapeInitial.storage[0], landscape.overviewScale);
    _expectMatrixCoversViewport(landscapeInitial, landscape);
  });

  test('arrival camera animation stays clamped for every sampled frame', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );
    final tween = Matrix4Tween(
      begin: layout.arrivalStartTransform(),
      end: layout.overviewTransform(),
    );

    for (final t in const [0.0, 0.12, 0.25, 0.5, 0.75, 0.88, 1.0]) {
      final frame = layout.clampMatrix(tween.transform(t));
      expect(
        frame.storage[0],
        inInclusiveRange(layout.hardMinScale, layout.maxScale),
        reason: 't=$t',
      );
      _expectMatrixCoversViewport(frame, layout, reason: 't=$t');
    }
  });

  test('camera core focus travel and return transforms stay clamped', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );
    final overview = layout.overviewTransform();
    final returnToOverview = layout.returnToOverviewTransform();
    _expectSameMatrix(returnToOverview, overview);

    final targetFocus = layout.targetFocusTransform(
      const Offset(0.33, 0.42),
      scale: layout.maxScale * 8,
    );
    expect(targetFocus.storage[0], layout.maxScale);
    _expectMatrixCoversViewport(targetFocus, layout);

    final travelFollow = layout.travelFollowTransform(
      const Offset(0.62, 0.58),
      scale: layout.hardMinScale / 10,
    );
    expect(travelFollow.storage[0], layout.hardMinScale);
    _expectMatrixCoversViewport(travelFollow, layout);

    final worldFocus = layout.transformForWorldPoint(
      layout.cityRect.center,
      scale: layout.hardMinScale / 4,
    );
    expect(worldFocus.storage[0], layout.hardMinScale);
    _expectMatrixCoversViewport(worldFocus, layout);
  });

  test('city image river mask agents and navigation share one world space', () {
    final layout = FirenzePreviewCameraLayout.fromViewport(
      const Size(1805, 832),
    );
    expect(layout.cityRect.left, 260);
    expect(layout.cityRect.top, 170);
    expect(layout.cityRect.width, firenzePreviewRiverMaskCanvasWidth);
    expect(layout.cityRect.height, firenzePreviewRiverMaskCanvasHeight);

    final graph = FirenzePreviewNavigationGraph();
    for (final parcelId in ['P01', 'P03', 'P09']) {
      final route = graph.routeToParcel(parcelId);
      for (final point in route.points) {
        final worldPoint = Offset(
          layout.cityRect.left + point.x * layout.cityRect.width,
          layout.cityRect.top + point.y * layout.cityRect.height,
        );
        expect(layout.cityRect.contains(worldPoint), isTrue);
      }
    }

    final routes = preview.buildFirenzePreviewAmbientRoutes(
      preview.firenzeAmbientRoutePlans,
    );
    for (final route in routes) {
      for (final point in route.points) {
        final worldPoint = Offset(
          layout.cityRect.left + point.x * layout.cityRect.width,
          layout.cityRect.top + point.y * layout.cityRect.height,
        );
        expect(layout.cityRect.contains(worldPoint), isTrue);
      }
    }
  });

  test('camera gesture clamps scale and translation during live updates', () {
    const viewportSize = Size(852, 393);
    final layout = FirenzePreviewCameraLayout.fromViewport(viewportSize);
    final startScale = layout.hardMinScale * 2.2;
    final start = Matrix4.identity()
      ..setEntry(0, 0, startScale)
      ..setEntry(1, 1, startScale)
      ..setEntry(0, 3, -420)
      ..setEntry(1, 3, -180);

    final tiny = FirenzePreviewCameraGesture.update(
      startMatrix: start,
      startFocalPoint: const Offset(320, 190),
      currentFocalPoint: const Offset(324, 194),
      scaleFactor: 0.001,
      layout: layout,
    );
    expect(tiny.storage[0], greaterThanOrEqualTo(layout.hardMinScale));
    _expectMatrixCoversViewport(tiny, layout);

    final huge = FirenzePreviewCameraGesture.update(
      startMatrix: start,
      startFocalPoint: const Offset(320, 190),
      currentFocalPoint: const Offset(260, 160),
      scaleFactor: 80,
      layout: layout,
    );
    expect(huge.storage[0], lessThanOrEqualTo(layout.maxScale));
    _expectMatrixCoversViewport(huge, layout);
  });

  test(
    'ambient route families use only real graph edges and bridge chains',
    () {
      final routes = preview.buildFirenzePreviewAmbientRoutes(
        preview.firenzeAmbientRoutePlans,
      );
      final edgeIds = {
        for (final edge in firenzePreviewNavigationEdges) edge.id,
      };

      expect(routes, hasLength(greaterThanOrEqualTo(5)));
      expect(
        routes.map((route) => route.id),
        containsAll([
          'north_loop',
          'center_loop',
          'south_loop',
          'river_bank_loop',
          'bridge_loop',
        ]),
      );

      for (final route in routes) {
        expect(route.points, isNotEmpty, reason: route.id);
        expect(route.lengthPx, greaterThan(0), reason: route.id);
        expect(route.nodeIds.first, route.nodeIds.last, reason: route.id);
        for (final edgeId in route.edgeIds) {
          expect(edgeIds, contains(edgeId), reason: '${route.id} $edgeId');
        }
        for (final nodeId in route.nodeIds) {
          expect(nodeId, isNot(contains('_entry_')), reason: route.id);
          expect(nodeId, isNot(contains('_anchor')), reason: route.id);
        }
        _expectAmbientBridgeUseIsACompleteChain(route.nodeIds, route.id);
      }
    },
  );

  test(
    'activity anchors remain graph-authentic while characters are blocked',
    () {
      final graphNodeIds = {
        ...firenzePreviewNavigationNodes.keys,
        'city_spawn_start',
      };

      for (final entry in preview.firenzePreviewActivityAnchors.entries) {
        expect(graphNodeIds, contains(entry.value), reason: entry.key);
        expect(entry.value, isNot(contains('_entry_')), reason: entry.key);
        expect(entry.value, isNot(contains('_anchor')), reason: entry.key);
      }

      expect(
        preview.firenzePreviewCharacterAssetStatus,
        'CHARACTER_ASSET_BLOCKER',
      );
      expect(preview.firenzePreviewCharacterRenderingEnabled, isFalse);
      expect(preview.firenzePreviewProceduralCharactersRemoved, isTrue);
    },
  );

  test(
    'character direction buckets map route vectors without root rotation',
    () {
      expect(
        preview.previewCharacterDirectionForVector(const Offset(1, 0)),
        preview.PreviewCharacterDirection.e,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(1, 1)),
        preview.PreviewCharacterDirection.se,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(0, 1)),
        preview.PreviewCharacterDirection.s,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(-1, 1)),
        preview.PreviewCharacterDirection.sw,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(-1, 0)),
        preview.PreviewCharacterDirection.w,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(-1, -1)),
        preview.PreviewCharacterDirection.nw,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(0, -1)),
        preview.PreviewCharacterDirection.n,
      );
      expect(
        preview.previewCharacterDirectionForVector(const Offset(1, -1)),
        preview.PreviewCharacterDirection.ne,
      );

      final graph = FirenzePreviewNavigationGraph();
      final route = graph.routeToParcel('P01');
      final footPoint = Offset(route.points.first.x, route.points.first.y);
      final placement = preview.PreviewCharacterVisualPlacement(
        footPosition: footPoint,
        direction: preview.PreviewCharacterDirection.e,
        motionState: preview.PreviewCharacterMotionState.walk,
      );

      expect(placement.footPosition, footPoint);
      expect(placement.anchor, preview.PreviewCharacterAnchor.bottomCenter);
      expect(placement.visualRootRotationRadians, 0);
      expect(placement.isUpright, isTrue);
    },
  );

  test(
    'character state and walk cycle are deterministic without route scaling',
    () {
      expect(
        preview.previewCharacterMotionStateFor(
          role: preview.PreviewCharacterRole.pedestrian,
          isMoving: false,
        ),
        preview.PreviewCharacterMotionState.idle,
      );
      expect(
        preview.previewCharacterMotionStateFor(
          role: preview.PreviewCharacterRole.worker,
          isMoving: false,
          isAtWorkAnchor: true,
        ),
        preview.PreviewCharacterMotionState.work,
      );
      expect(
        preview.previewCharacterMotionStateFor(
          role: preview.PreviewCharacterRole.worker,
          isMoving: true,
          isCarrying: true,
          isAtWorkAnchor: true,
        ),
        preview.PreviewCharacterMotionState.carry,
      );

      final before = preview.previewCharacterWalkCyclePhase(
        elapsedSeconds: 2,
        speedPxPerSecond: firenzePreviewWorkerTravelSpeedPxPerSecond.toDouble(),
      );
      final after = preview.previewCharacterWalkCyclePhase(
        elapsedSeconds: 2.1,
        speedPxPerSecond: firenzePreviewWorkerTravelSpeedPxPerSecond.toDouble(),
      );

      expect(
        before,
        closeTo(
          (2 * firenzePreviewWorkerTravelSpeedPxPerSecond / 42).remainder(1),
          0.000001,
        ),
      );
      expect(
        after,
        closeTo(
          (2.1 * firenzePreviewWorkerTravelSpeedPxPerSecond / 42).remainder(1),
          0.000001,
        ),
      );
      expect(after, isNot(before));
    },
  );
}

void _expectBridgeUseIsACompleteChain(FirenzePreviewResolvedRoute route) {
  for (final entry in firenzePreviewBridgeChains.entries) {
    final chain = entry.value;
    final touched = chain.any(route.nodeIds.contains);
    if (!touched) {
      continue;
    }

    final reverse = chain.reversed.toList(growable: false);
    final hasCompleteChain =
        _containsContiguous(route.nodeIds, chain) ||
        _containsContiguous(route.nodeIds, reverse);

    expect(
      hasCompleteChain,
      isTrue,
      reason:
          '${route.parcelId} touches ${entry.key} but does not use '
          'a complete N/M/S bridge chain',
    );
  }
}

bool _containsContiguous(List<String> source, List<String> target) {
  if (target.length > source.length) {
    return false;
  }
  for (var index = 0; index <= source.length - target.length; index++) {
    var matches = true;
    for (var targetIndex = 0; targetIndex < target.length; targetIndex++) {
      if (source[index + targetIndex] != target[targetIndex]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return true;
    }
  }
  return false;
}

void _expectAmbientBridgeUseIsACompleteChain(
  List<String> nodeIds,
  String routeId,
) {
  for (final entry in firenzePreviewBridgeChains.entries) {
    final chain = entry.value;
    final touched = chain.any(nodeIds.contains);
    if (!touched) {
      continue;
    }

    final reverse = chain.reversed.toList(growable: false);
    final hasCompleteChain =
        _containsContiguous(nodeIds, chain) ||
        _containsContiguous(nodeIds, reverse);

    expect(
      hasCompleteChain,
      isTrue,
      reason: '$routeId touches ${entry.key} without a full bridge chain',
    );
  }
}

void _expectMatrixCoversViewport(
  Matrix4 matrix,
  FirenzePreviewCameraLayout layout, {
  String? reason,
}) {
  final scale = matrix.storage[0];
  final dx = matrix.storage[12];
  final dy = matrix.storage[13];
  final transformedWorld = Rect.fromLTWH(
    dx,
    dy,
    layout.worldRect.width * scale,
    layout.worldRect.height * scale,
  );
  expect(transformedWorld.left, lessThanOrEqualTo(0), reason: reason);
  expect(transformedWorld.top, lessThanOrEqualTo(0), reason: reason);
  expect(
    transformedWorld.right,
    greaterThanOrEqualTo(layout.viewportSize.width),
    reason: reason,
  );
  expect(
    transformedWorld.bottom,
    greaterThanOrEqualTo(layout.viewportSize.height),
    reason: reason,
  );
}

void _expectSameMatrix(Matrix4 actual, Matrix4 expected) {
  for (var index = 0; index < 16; index++) {
    expect(actual.storage[index], closeTo(expected.storage[index], 0.000001));
  }
}

bool _pointIsOnRoutePolyline(
  FirenzePreviewPoint point,
  List<FirenzePreviewPoint> routePoints,
) {
  final pointOffset = Offset(point.x, point.y);
  final offsets = routePoints
      .map((routePoint) => Offset(routePoint.x, routePoint.y))
      .toList(growable: false);
  if (offsets.length < 2) {
    return offsets.length == 1 &&
        (pointOffset - offsets.first).distance < 0.000001;
  }

  for (var index = 0; index < offsets.length - 1; index++) {
    if (_distanceToSegment(pointOffset, offsets[index], offsets[index + 1]) <
        0.000001) {
      return true;
    }
  }
  return false;
}

double _distanceToSegment(Offset point, Offset a, Offset b) {
  final ab = b - a;
  final ap = point - a;
  final abLengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
  if (abLengthSquared == 0) {
    return (point - a).distance;
  }
  final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / abLengthSquared)
      .clamp(0, 1)
      .toDouble();
  final projection = a + ab * t;
  return (point - projection).distance;
}

Offset _worldToViewport(Offset worldPoint, Matrix4 matrix) {
  final scale = matrix.storage[0];
  return Offset(
    worldPoint.dx * scale + matrix.storage[12],
    worldPoint.dy * scale + matrix.storage[13],
  );
}
