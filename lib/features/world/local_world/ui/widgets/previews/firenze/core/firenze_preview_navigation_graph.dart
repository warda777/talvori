import 'dart:math' as math;

import '../../data/firenze_city_preview_navigation_data.dart' as data;

export '../../data/firenze_city_preview_navigation_data.dart'
    hide
        FirenzePreviewNavigationGraph,
        firenzePreviewPolylineCanvasLength,
        firenzePreviewRouteCanvasLength,
        firenzePreviewTravelDurationForRoute;

class FirenzePreviewNavigationGraph {
  FirenzePreviewNavigationGraph()
    : _allNodePositions = {
        ...data.firenzePreviewNavigationNodes,
        'city_spawn_start':
            data.firenzePreviewAnchorPoints['city_spawn_start']!,
      } {
    for (final edge in data.firenzePreviewNavigationEdges) {
      _edgeById[edge.id] = edge;
      _adjacency
          .putIfAbsent(edge.from, () => [])
          .add(_GraphStep(edge: edge, nextNode: edge.to));
      _adjacency
          .putIfAbsent(edge.to, () => [])
          .add(_GraphStep(edge: edge, nextNode: edge.from));
    }
  }

  final Map<String, data.FirenzePreviewPoint> _allNodePositions;
  final Map<String, data.FirenzePreviewNavigationEdge> _edgeById = {};
  final Map<String, List<_GraphStep>> _adjacency = {};

  data.FirenzePreviewPoint anchorForParcel(String parcelId) {
    final anchorId = data.firenzePreviewParcelAnchors[parcelId];
    final anchor = anchorId == null
        ? null
        : data.firenzePreviewAnchorPoints[anchorId];
    if (anchor == null) {
      throw StateError('Missing anchor for $parcelId');
    }
    return anchor;
  }

  data.FirenzePreviewPoint get citySpawnStart {
    final point = data.firenzePreviewAnchorPoints['city_spawn_start'];
    if (point == null) {
      throw StateError('Missing city_spawn_start');
    }
    return point;
  }

  data.FirenzePreviewResolvedRoute routeToParcel(String parcelId) {
    final entries = data.firenzePreviewParcelEntries[parcelId];
    if (entries == null) {
      throw StateError('Unknown parcel $parcelId');
    }

    data.FirenzePreviewResolvedRoute? best;
    for (final entryId in entries) {
      final accessId = _accessForEntry(entryId);
      final candidate = _shortestRoute(
        parcelId: parcelId,
        entryId: entryId,
        accessId: accessId,
      );
      if (candidate == null) {
        continue;
      }
      if (candidate.nodeIds.length < 2 ||
          candidate.nodeIds[candidate.nodeIds.length - 2] != accessId) {
        continue;
      }
      if (best == null || candidate.length < best.length) {
        best = candidate;
      }
    }

    if (best == null) {
      throw StateError('No graph-authentic route to $parcelId');
    }
    return best;
  }

  data.FirenzePreviewResolvedRoute? _shortestRoute({
    required String parcelId,
    required String entryId,
    required String accessId,
  }) {
    const startId = 'city_spawn_start';
    final nodeIds = _allNodePositions.keys.toSet();
    if (!nodeIds.contains(entryId) || !nodeIds.contains(accessId)) {
      return null;
    }

    final distances = <String, double>{
      for (final nodeId in nodeIds) nodeId: double.infinity,
    };
    final previousNode = <String, String>{};
    final previousEdge = <String, String>{};
    final unvisited = nodeIds.toSet();
    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      String? current;
      var bestDistance = double.infinity;
      for (final nodeId in unvisited) {
        final distance = distances[nodeId] ?? double.infinity;
        if (distance < bestDistance) {
          bestDistance = distance;
          current = nodeId;
        }
      }
      if (current == null || bestDistance == double.infinity) {
        break;
      }
      unvisited.remove(current);
      if (current == entryId) {
        break;
      }
      for (final step in _adjacency[current] ?? const <_GraphStep>[]) {
        if (!unvisited.contains(step.nextNode)) {
          continue;
        }
        final candidate = bestDistance + step.edge.length;
        if (candidate < (distances[step.nextNode] ?? double.infinity)) {
          distances[step.nextNode] = candidate;
          previousNode[step.nextNode] = current;
          previousEdge[step.nextNode] = step.edge.id;
        }
      }
    }

    if (!previousNode.containsKey(entryId)) {
      return null;
    }

    final routeNodes = <String>[entryId];
    final routeEdges = <String>[];
    var current = entryId;
    while (current != startId) {
      final prevNode = previousNode[current];
      final prevEdge = previousEdge[current];
      if (prevNode == null || prevEdge == null) {
        return null;
      }
      routeEdges.insert(0, prevEdge);
      routeNodes.insert(0, prevNode);
      current = prevNode;
    }

    final routePoints = _routePoints(routeNodes, routeEdges);
    return data.FirenzePreviewResolvedRoute(
      parcelId: parcelId,
      entryId: entryId,
      accessId: accessId,
      nodeIds: routeNodes,
      edgeIds: routeEdges,
      points: routePoints,
      length: firenzePreviewPolylineCanvasLength(routePoints),
      bridgeChains: _bridgeChainsFor(routeNodes),
    );
  }

  List<data.FirenzePreviewPoint> _routePoints(
    List<String> nodeIds,
    List<String> edgeIds,
  ) {
    final points = <data.FirenzePreviewPoint>[];
    for (var index = 0; index < edgeIds.length; index++) {
      final edge = _edgeById[edgeIds[index]];
      if (edge == null) {
        throw StateError('Route references missing edge ${edgeIds[index]}');
      }
      final fromNode = nodeIds[index];
      final edgePoints = edge.from == fromNode
          ? edge.points
          : edge.points.reversed.toList(growable: false);
      for (var pointIndex = 0; pointIndex < edgePoints.length; pointIndex++) {
        if (points.isNotEmpty && pointIndex == 0) {
          continue;
        }
        points.add(edgePoints[pointIndex]);
      }
    }
    return points;
  }

  List<String> _bridgeChainsFor(List<String> nodeIds) {
    final bridgeIds = <String>[];
    for (final entry in data.firenzePreviewBridgeChains.entries) {
      final chain = entry.value;
      final reverse = chain.reversed.toList(growable: false);
      for (var index = 0; index <= nodeIds.length - 3; index++) {
        final window = nodeIds.sublist(index, index + 3);
        if (_sameList(window, chain) || _sameList(window, reverse)) {
          bridgeIds.add(entry.key);
          break;
        }
      }
    }
    return bridgeIds;
  }
}

double firenzePreviewRouteCanvasLength(data.FirenzePreviewResolvedRoute route) {
  return firenzePreviewPolylineCanvasLength(route.points);
}

double firenzePreviewPolylineCanvasLength(
  List<data.FirenzePreviewPoint> points,
) {
  if (points.length < 2) {
    return 0;
  }
  var length = 0.0;
  for (var index = 0; index < points.length - 1; index++) {
    length += _canvasDistance(points[index], points[index + 1]);
  }
  return length;
}

Duration firenzePreviewTravelDurationForRoute(
  data.FirenzePreviewResolvedRoute route,
) {
  final length = firenzePreviewRouteCanvasLength(route);
  final milliseconds =
      (length / data.firenzePreviewWorkerTravelSpeedPxPerSecond * 1000).round();
  return Duration(milliseconds: milliseconds < 1 ? 1 : milliseconds);
}

data.FirenzePreviewPoint firenzePreviewRoutePointAtDistance(
  List<data.FirenzePreviewPoint> route,
  double distancePx, {
  required data.FirenzePreviewPoint fallback,
}) {
  if (route.isEmpty) {
    return fallback;
  }
  if (route.length == 1) {
    return route.first;
  }

  final segments = <double>[];
  var totalLength = 0.0;
  for (var index = 0; index < route.length - 1; index++) {
    final length = _canvasDistance(route[index], route[index + 1]);
    segments.add(length);
    totalLength += length;
  }

  var remaining = distancePx.clamp(0, totalLength).toDouble();
  for (var index = 0; index < segments.length; index++) {
    final segmentLength = segments[index];
    if (remaining <= segmentLength) {
      final from = route[index];
      final to = route[index + 1];
      final t = segmentLength == 0 ? 0 : remaining / segmentLength;
      return data.FirenzePreviewPoint(
        from.x + (to.x - from.x) * t,
        from.y + (to.y - from.y) * t,
      );
    }
    remaining -= segmentLength;
  }
  return route.last;
}

data.FirenzePreviewPoint firenzePreviewRoutePointAtProgress(
  data.FirenzePreviewResolvedRoute route,
  double progress,
) {
  final routePoints = route.points;
  final fallback = routePoints.isEmpty
      ? const data.FirenzePreviewPoint(0, 0)
      : routePoints.first;
  return firenzePreviewRoutePointAtDistance(
    routePoints,
    firenzePreviewRouteCanvasLength(route) * progress.clamp(0, 1).toDouble(),
    fallback: fallback,
  );
}

List<data.FirenzePreviewPoint> firenzePreviewRoutePointsUntilDistance(
  List<data.FirenzePreviewPoint> route,
  double distancePx, {
  required data.FirenzePreviewPoint fallback,
}) {
  if (route.isEmpty) {
    return [fallback];
  }
  if (route.length == 1) {
    return route;
  }

  final targetPoint = firenzePreviewRoutePointAtDistance(
    route,
    distancePx,
    fallback: fallback,
  );
  if (distancePx <= 0) {
    return [route.first, targetPoint];
  }

  final segments = <double>[];
  var totalLength = 0.0;
  for (var index = 0; index < route.length - 1; index++) {
    final length = _canvasDistance(route[index], route[index + 1]);
    segments.add(length);
    totalLength += length;
  }

  if (distancePx >= totalLength) {
    return route;
  }

  var remaining = distancePx.clamp(0, totalLength).toDouble();
  final partial = <data.FirenzePreviewPoint>[route.first];
  for (var index = 0; index < segments.length; index++) {
    final length = segments[index];
    if (remaining <= length) {
      partial.add(targetPoint);
      return partial;
    }
    partial.add(route[index + 1]);
    remaining -= length;
  }
  return route;
}

List<data.FirenzePreviewPoint> firenzePreviewRoutePointsUntilProgress(
  data.FirenzePreviewResolvedRoute route,
  double progress,
) {
  final routePoints = route.points;
  final fallback = routePoints.isEmpty
      ? const data.FirenzePreviewPoint(0, 0)
      : routePoints.first;
  return firenzePreviewRoutePointsUntilDistance(
    routePoints,
    firenzePreviewRouteCanvasLength(route) * progress.clamp(0, 1).toDouble(),
    fallback: fallback,
  );
}

class _GraphStep {
  const _GraphStep({required this.edge, required this.nextNode});

  final data.FirenzePreviewNavigationEdge edge;
  final String nextNode;
}

String _accessForEntry(String entryId) {
  return entryId.replaceFirst('_entry_', '_access_');
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

double _canvasDistance(
  data.FirenzePreviewPoint from,
  data.FirenzePreviewPoint to,
) {
  final dx = (to.x - from.x) * data.firenzePreviewCanvasWidth;
  final dy = (to.y - from.y) * data.firenzePreviewCanvasHeight;
  return math.sqrt(dx * dx + dy * dy);
}
