#!/usr/bin/env python3
"""Generate Firenze preview-only navigation data from the master SVG.

This is a development-time tool. It creates preview runtime data for the
standalone Firenze first-fun proof, but it does not create production runtime
geometry, Area-Spec JSON/YAML, collision masks, or app integration data.
"""

from __future__ import annotations

import hashlib
import math
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_SVG = (
    REPO_ROOT
    / "docs/world_design/previews/firenze_master_technical_layout/"
    / "firenze_city_exploration_master.svg"
)
OUTPUT_DART = (
    REPO_ROOT
    / "lib/features/world/local_world/ui/widgets/previews/data/"
    / "firenze_city_preview_navigation_data.dart"
)
OUTPUT_PNG = (
    REPO_ROOT
    / "assets/images/world/previews/firenze_city_entry/"
    / "firenze_city_entry_map_only_preview_v1.png"
)
OUTPUT_RIVER_MASK_PNG = (
    REPO_ROOT
    / "assets/images/world/previews/firenze_city_entry/"
    / "firenze_city_river_mask_preview_v1.png"
)

EXPECTED_SHA256 = (
    "58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3"
)
EXPECTED_CANVAS_WIDTH = 1672
EXPECTED_CANVAS_HEIGHT = 941
EXPECTED_VIEW_BOX = (0.0, 0.0, 442.38333, 248.97292)
EXPECTED_NAVIGATION_NODES = 181
EXPECTED_NAVIGATION_EDGES = 221
WORKER_TRAVEL_SPEED_PX_PER_SECOND = 230.0

SVG_NS = "{http://www.w3.org/2000/svg}"
INKSCAPE_LABEL = "{http://www.inkscape.org/namespaces/inkscape}label"


@dataclass(frozen=True)
class Point:
    x: float
    y: float

    def distance_to(self, other: "Point") -> float:
        return math.hypot(self.x - other.x, self.y - other.y)


@dataclass(frozen=True)
class Edge:
    edge_id: str
    from_id: str
    to_id: str
    points: tuple[Point, ...]
    length: float


class ExtractionError(RuntimeError):
    pass


def _read_source_sha() -> str:
    return hashlib.sha256(SOURCE_SVG.read_bytes()).hexdigest()


def _parse_float(value: str | None, *, name: str) -> float:
    if value is None:
        raise ExtractionError(f"Missing numeric value: {name}")
    return float(value)


def _layer_by_label(root: ET.Element, label: str) -> ET.Element:
    for child in root:
        if child.tag == f"{SVG_NS}g" and (
            child.get(INKSCAPE_LABEL) == label or child.get("id") == label
        ):
            return child
    raise ExtractionError(f"Missing SVG layer: {label}")


def _assert_no_transforms(layer: ET.Element, label: str) -> None:
    if layer.get("transform"):
        raise ExtractionError(f"Layer {label} has unsupported transform")
    for element in layer.iter():
        if element is layer:
            continue
        if element.get("transform"):
            element_id = element.get("id", "<missing-id>")
            raise ExtractionError(
                f"Element {element_id} in {label} has unsupported transform"
            )


def _ellipse_position(element: ET.Element) -> Point:
    return Point(
        _parse_float(element.get("cx"), name=f"{element.get('id')}.cx"),
        _parse_float(element.get("cy"), name=f"{element.get('id')}.cy"),
    )


def _read_ellipse_points(layer: ET.Element) -> dict[str, Point]:
    points: dict[str, Point] = {}
    for element in layer:
        if element.tag != f"{SVG_NS}ellipse":
            raise ExtractionError(
                f"Expected ellipse in {layer.get(INKSCAPE_LABEL)}, "
                f"got {element.tag}"
            )
        element_id = element.get("id")
        if not element_id:
            raise ExtractionError("Ellipse without id")
        if element_id in points:
            raise ExtractionError(f"Duplicate point id: {element_id}")
        points[element_id] = _ellipse_position(element)
    return points


PATH_TOKEN_RE = re.compile(
    r"[A-Za-z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?"
)


def _is_command(token: str) -> bool:
    return bool(re.fullmatch(r"[A-Za-z]", token))


def _read_number(tokens: list[str], index: int, edge_id: str) -> tuple[float, int]:
    if index >= len(tokens) or _is_command(tokens[index]):
        raise ExtractionError(f"Path {edge_id} expected number at token {index}")
    return float(tokens[index]), index + 1


def _parse_path_points(d: str, edge_id: str) -> tuple[Point, ...]:
    tokens = PATH_TOKEN_RE.findall(d)
    if not tokens:
        raise ExtractionError(f"Path {edge_id} has empty d attribute")

    index = 0
    command: str | None = None
    current = Point(0.0, 0.0)
    start: Point | None = None
    points: list[Point] = []

    while index < len(tokens):
        if _is_command(tokens[index]):
            command = tokens[index]
            if command not in "MmLlHhVvCcZz":
                raise ExtractionError(
                    f"Path {edge_id} uses unsupported command {command}"
                )
            index += 1
            if command in "Zz":
                if start is None:
                    raise ExtractionError(f"Path {edge_id} closes before move")
                current = start
                points.append(current)
                command = None
                continue

        if command is None:
            raise ExtractionError(f"Path {edge_id} has numbers without command")

        if command in "Mm":
            first = True
            while index < len(tokens) and not _is_command(tokens[index]):
                x, index = _read_number(tokens, index, edge_id)
                y, index = _read_number(tokens, index, edge_id)
                next_point = Point(
                    current.x + x if command == "m" else x,
                    current.y + y if command == "m" else y,
                )
                current = next_point
                if first:
                    start = current
                    points.append(current)
                    first = False
                else:
                    points.append(current)
            command = "l" if command == "m" else "L"
            continue

        if command in "Ll":
            while index < len(tokens) and not _is_command(tokens[index]):
                x, index = _read_number(tokens, index, edge_id)
                y, index = _read_number(tokens, index, edge_id)
                current = Point(
                    current.x + x if command == "l" else x,
                    current.y + y if command == "l" else y,
                )
                points.append(current)
            continue

        if command in "Hh":
            while index < len(tokens) and not _is_command(tokens[index]):
                x, index = _read_number(tokens, index, edge_id)
                current = Point(current.x + x if command == "h" else x, current.y)
                points.append(current)
            continue

        if command in "Vv":
            while index < len(tokens) and not _is_command(tokens[index]):
                y, index = _read_number(tokens, index, edge_id)
                current = Point(current.x, current.y + y if command == "v" else y)
                points.append(current)
            continue

        if command in "Cc":
            while index < len(tokens) and not _is_command(tokens[index]):
                x1, index = _read_number(tokens, index, edge_id)
                y1, index = _read_number(tokens, index, edge_id)
                x2, index = _read_number(tokens, index, edge_id)
                y2, index = _read_number(tokens, index, edge_id)
                x, index = _read_number(tokens, index, edge_id)
                y, index = _read_number(tokens, index, edge_id)
                control_1 = Point(
                    current.x + x1 if command == "c" else x1,
                    current.y + y1 if command == "c" else y1,
                )
                control_2 = Point(
                    current.x + x2 if command == "c" else x2,
                    current.y + y2 if command == "c" else y2,
                )
                end = Point(
                    current.x + x if command == "c" else x,
                    current.y + y if command == "c" else y,
                )
                start_point = current
                for step in range(1, 13):
                    t = step / 12
                    inv = 1 - t
                    points.append(
                        Point(
                            inv * inv * inv * start_point.x
                            + 3 * inv * inv * t * control_1.x
                            + 3 * inv * t * t * control_2.x
                            + t * t * t * end.x,
                            inv * inv * inv * start_point.y
                            + 3 * inv * inv * t * control_1.y
                            + 3 * inv * t * t * control_2.y
                            + t * t * t * end.y,
                        )
                    )
                current = end
            continue

    if len(points) < 2:
        raise ExtractionError(f"Path {edge_id} must contain at least two points")
    return tuple(points)


def _path_length(points: tuple[Point, ...]) -> float:
    return sum(
        points[index].distance_to(points[index + 1])
        for index in range(len(points) - 1)
    )


def _resolve_edge_endpoints(
    edge_id: str,
    known_ids: set[str],
) -> tuple[str, str]:
    if not edge_id.startswith("E_"):
        raise ExtractionError(f"Navigation edge id does not start with E_: {edge_id}")
    body = edge_id[2:]
    ordered = sorted(known_ids, key=len, reverse=True)
    for from_id in ordered:
        prefix = f"{from_id}_"
        if not body.startswith(prefix):
            continue
        to_id = body[len(prefix) :]
        if to_id in known_ids:
            return from_id, to_id
    raise ExtractionError(f"Could not resolve edge endpoints from id: {edge_id}")


def _read_edges(
    layer: ET.Element,
    all_node_positions: dict[str, Point],
) -> list[Edge]:
    known_ids = set(all_node_positions)
    edges: list[Edge] = []
    for element in layer:
        if element.tag != f"{SVG_NS}path":
            raise ExtractionError(
                f"Expected path in {layer.get(INKSCAPE_LABEL)}, got {element.tag}"
            )
        edge_id = element.get("id")
        if not edge_id:
            raise ExtractionError("Navigation edge without id")
        from_id, to_id = _resolve_edge_endpoints(edge_id, known_ids)
        d = element.get("d")
        if not d:
            raise ExtractionError(f"Navigation edge {edge_id} has no d attribute")
        points = _parse_path_points(d, edge_id)

        from_point = all_node_positions[from_id]
        to_point = all_node_positions[to_id]
        forward_error = points[0].distance_to(from_point) + points[-1].distance_to(
            to_point
        )
        reverse_error = points[0].distance_to(to_point) + points[-1].distance_to(
            from_point
        )
        if reverse_error < forward_error:
            points = tuple(reversed(points))
            forward_error, reverse_error = reverse_error, forward_error

        if forward_error > 1.0:
            raise ExtractionError(
                f"Navigation edge {edge_id} geometry does not meet its endpoints "
                f"(error={forward_error:.3f})"
            )

        edges.append(
            Edge(
                edge_id=edge_id,
                from_id=from_id,
                to_id=to_id,
                points=points,
                length=_path_length(points),
            )
        )
    return edges


def _format_double(value: float) -> str:
    return f"{value:.8f}".rstrip("0").rstrip(".")


def _normalise(point: Point) -> Point:
    return Point(
        point.x / EXPECTED_VIEW_BOX[2],
        point.y / EXPECTED_VIEW_BOX[3],
    )


def _write_dart(
    *,
    sha256: str,
    navigation_nodes: dict[str, Point],
    anchor_points: dict[str, Point],
    edges: list[Edge],
) -> None:
    OUTPUT_DART.parent.mkdir(parents=True, exist_ok=True)

    parcel_anchor_ids = [
        f"P{index:02d}_anchor" for index in range(1, 15)
    ]
    missing_anchors = [
        anchor_id for anchor_id in parcel_anchor_ids if anchor_id not in anchor_points
    ]
    if missing_anchors:
        raise ExtractionError(f"Missing parcel anchors: {missing_anchors}")
    if "city_spawn_start" not in anchor_points:
        raise ExtractionError("Missing city_spawn_start anchor")

    lines: list[str] = []
    lines.extend(
        [
            "// GENERATED FILE. Do not edit by hand.",
            "// Generated by tool/extract_firenze_preview_navigation.py.",
            "// Status: preview_runtime_only / not_production_runtime /",
            "// source_generated / blocked_for_app_integration.",
            "// Source SVG:",
            f"// {SOURCE_SVG.relative_to(REPO_ROOT)}",
            f"// Source SHA-256: {sha256}",
            "// This file contains preview-only graph data for the standalone",
            "// Firenze first-fun proof. It is not an Area-Specification export,",
            "// not production navigation, and not runtime geometry for the app.",
            "",
            "class FirenzePreviewPoint {",
            "  const FirenzePreviewPoint(this.x, this.y);",
            "",
            "  final double x;",
            "  final double y;",
            "",
            "  double distanceTo(FirenzePreviewPoint other) {",
            "    final dx = x - other.x;",
            "    final dy = y - other.y;",
            "    return _sqrt(dx * dx + dy * dy);",
            "  }",
            "}",
            "",
            "class FirenzePreviewNavigationEdge {",
            "  const FirenzePreviewNavigationEdge({",
            "    required this.id,",
            "    required this.from,",
            "    required this.to,",
            "    required this.length,",
            "    required this.points,",
            "  });",
            "",
            "  final String id;",
            "  final String from;",
            "  final String to;",
            "  final double length;",
            "  final List<FirenzePreviewPoint> points;",
            "}",
            "",
            "class FirenzePreviewResolvedRoute {",
            "  const FirenzePreviewResolvedRoute({",
            "    required this.parcelId,",
            "    required this.entryId,",
            "    required this.accessId,",
            "    required this.nodeIds,",
            "    required this.edgeIds,",
            "    required this.points,",
            "    required this.length,",
            "    required this.bridgeChains,",
            "  });",
            "",
            "  final String parcelId;",
            "  final String entryId;",
            "  final String accessId;",
            "  final List<String> nodeIds;",
            "  final List<String> edgeIds;",
            "  final List<FirenzePreviewPoint> points;",
            "  final double length;",
            "  final List<String> bridgeChains;",
            "}",
            "",
            f"const firenzePreviewSourceSvgPath = "
            f"'{SOURCE_SVG.relative_to(REPO_ROOT)}';",
            f"const firenzePreviewSourceSha256 = '{sha256}';",
            "const firenzePreviewRiverMaskAssetPath = "
            "'assets/images/world/previews/firenze_city_entry/"
            "firenze_city_river_mask_preview_v1.png';",
            f"const firenzePreviewRiverMaskSourceSha256 = '{sha256}';",
            f"const firenzePreviewRiverMaskCanvasWidth = "
            f"{EXPECTED_CANVAS_WIDTH};",
            f"const firenzePreviewRiverMaskCanvasHeight = "
            f"{EXPECTED_CANVAS_HEIGHT};",
            f"const firenzePreviewCanvasWidth = {EXPECTED_CANVAS_WIDTH};",
            f"const firenzePreviewCanvasHeight = {EXPECTED_CANVAS_HEIGHT};",
            "const firenzePreviewViewBox = '0 0 442.38333 248.97292';",
            f"const firenzePreviewNavigationNodeCount = "
            f"{EXPECTED_NAVIGATION_NODES};",
            f"const firenzePreviewNavigationEdgeCount = "
            f"{EXPECTED_NAVIGATION_EDGES};",
            f"const firenzePreviewWorkerTravelSpeedPxPerSecond = "
            f"{_format_double(WORKER_TRAVEL_SPEED_PX_PER_SECOND)};",
            "",
            "double firenzePreviewRouteCanvasLength(",
            "  FirenzePreviewResolvedRoute route,",
            ") {",
            "  return firenzePreviewPolylineCanvasLength(route.points);",
            "}",
            "",
            "double firenzePreviewPolylineCanvasLength(",
            "  List<FirenzePreviewPoint> points,",
            ") {",
            "  if (points.length < 2) {",
            "    return 0;",
            "  }",
            "  var length = 0.0;",
            "  for (var index = 0; index < points.length - 1; index++) {",
            "    final from = points[index];",
            "    final to = points[index + 1];",
            "    final dx = (to.x - from.x) * firenzePreviewCanvasWidth;",
            "    final dy = (to.y - from.y) * firenzePreviewCanvasHeight;",
            "    length += _sqrt(dx * dx + dy * dy);",
            "  }",
            "  return length;",
            "}",
            "",
            "Duration firenzePreviewTravelDurationForRoute(",
            "  FirenzePreviewResolvedRoute route,",
            ") {",
            "  final length = firenzePreviewRouteCanvasLength(route);",
            "  final milliseconds =",
            "      (length / firenzePreviewWorkerTravelSpeedPxPerSecond * 1000)",
            "          .round();",
            "  return Duration(milliseconds: milliseconds < 1 ? 1 : milliseconds);",
            "}",
            "",
            "const firenzePreviewNavigationNodes = <String, FirenzePreviewPoint>{",
        ]
    )

    for node_id in sorted(navigation_nodes):
        point = _normalise(navigation_nodes[node_id])
        lines.append(
            f"  '{node_id}': FirenzePreviewPoint("
            f"{_format_double(point.x)}, {_format_double(point.y)}),"
        )
    lines.extend(["};", "", "const firenzePreviewAnchorPoints = <String, FirenzePreviewPoint>{"])
    for anchor_id in sorted(anchor_points):
        if not (
            anchor_id == "city_spawn_start"
            or re.fullmatch(r"P\d{2}_anchor", anchor_id)
        ):
            continue
        point = _normalise(anchor_points[anchor_id])
        lines.append(
            f"  '{anchor_id}': FirenzePreviewPoint("
            f"{_format_double(point.x)}, {_format_double(point.y)}),"
        )
    lines.extend(["};", "", "const firenzePreviewParcelAnchors = <String, String>{"])
    for index in range(1, 15):
        parcel_id = f"P{index:02d}"
        lines.append(f"  '{parcel_id}': '{parcel_id}_anchor',")
    lines.extend(["};", "", "const firenzePreviewParcelEntries = <String, List<String>>{"])
    for index in range(1, 15):
        parcel_id = f"P{index:02d}"
        lines.append(
            f"  '{parcel_id}': ['{parcel_id}_entry_1', '{parcel_id}_entry_2'],"
        )
    lines.extend(["};", "", "const firenzePreviewParcelAccess = <String, List<String>>{"])
    for index in range(1, 15):
        parcel_id = f"P{index:02d}"
        lines.append(
            f"  '{parcel_id}': ['{parcel_id}_access_1', '{parcel_id}_access_2'],"
        )
    lines.extend(["};", "", "const firenzePreviewBridgeChains = <String, List<String>>{"])
    for index in range(1, 9):
        bridge_id = f"B{index:02d}"
        lines.append(
            f"  '{bridge_id}': ['{bridge_id}_N', '{bridge_id}_M', '{bridge_id}_S'],"
        )
    lines.extend(["};", "", "const firenzePreviewNavigationEdges = <FirenzePreviewNavigationEdge>["])
    for edge in sorted(edges, key=lambda item: item.edge_id):
        lines.append("  FirenzePreviewNavigationEdge(")
        lines.append(f"    id: '{edge.edge_id}',")
        lines.append(f"    from: '{edge.from_id}',")
        lines.append(f"    to: '{edge.to_id}',")
        lines.append(f"    length: {_format_double(edge.length)},")
        lines.append("    points: [")
        for point in edge.points:
            normalised = _normalise(point)
            lines.append(
                "      FirenzePreviewPoint("
                f"{_format_double(normalised.x)}, "
                f"{_format_double(normalised.y)}),"
            )
        lines.append("    ],")
        lines.append("  ),")
    lines.extend(
        [
            "];",
            "",
            "class FirenzePreviewNavigationGraph {",
            "  FirenzePreviewNavigationGraph()",
            "      : _allNodePositions = {",
            "          ...firenzePreviewNavigationNodes,",
            "          'city_spawn_start':",
            "              firenzePreviewAnchorPoints['city_spawn_start']!,",
            "        } {",
            "    for (final edge in firenzePreviewNavigationEdges) {",
            "      _edgeById[edge.id] = edge;",
            "      _adjacency.putIfAbsent(edge.from, () => []).add(",
            "            _GraphStep(edge: edge, nextNode: edge.to, reversed: false),",
            "          );",
            "      _adjacency.putIfAbsent(edge.to, () => []).add(",
            "            _GraphStep(edge: edge, nextNode: edge.from, reversed: true),",
            "          );",
            "    }",
            "  }",
            "",
            "  final Map<String, FirenzePreviewPoint> _allNodePositions;",
            "  final Map<String, FirenzePreviewNavigationEdge> _edgeById = {};",
            "  final Map<String, List<_GraphStep>> _adjacency = {};",
            "",
            "  FirenzePreviewPoint anchorForParcel(String parcelId) {",
            "    final anchorId = firenzePreviewParcelAnchors[parcelId];",
            "    final anchor = anchorId == null",
            "        ? null",
            "        : firenzePreviewAnchorPoints[anchorId];",
            "    if (anchor == null) {",
            "      throw StateError('Missing anchor for $parcelId');",
            "    }",
            "    return anchor;",
            "  }",
            "",
            "  FirenzePreviewPoint get citySpawnStart {",
            "    final point = firenzePreviewAnchorPoints['city_spawn_start'];",
            "    if (point == null) {",
            "      throw StateError('Missing city_spawn_start');",
            "    }",
            "    return point;",
            "  }",
            "",
            "  FirenzePreviewResolvedRoute routeToParcel(String parcelId) {",
            "    final entries = firenzePreviewParcelEntries[parcelId];",
            "    if (entries == null) {",
            "      throw StateError('Unknown parcel $parcelId');",
            "    }",
            "",
            "    FirenzePreviewResolvedRoute? best;",
            "    for (final entryId in entries) {",
            "      final accessId = _accessForEntry(entryId);",
            "      final candidate = _shortestRoute(",
            "        parcelId: parcelId,",
            "        entryId: entryId,",
            "        accessId: accessId,",
            "      );",
            "      if (candidate == null) {",
            "        continue;",
            "      }",
            "      if (candidate.nodeIds.length < 2 ||",
            "          candidate.nodeIds[candidate.nodeIds.length - 2] != accessId) {",
            "        continue;",
            "      }",
            "      if (best == null || candidate.length < best.length) {",
            "        best = candidate;",
            "      }",
            "    }",
            "",
            "    if (best == null) {",
            "      throw StateError('No graph-authentic route to $parcelId');",
            "    }",
            "    return best;",
            "  }",
            "",
            "  FirenzePreviewResolvedRoute? _shortestRoute({",
            "    required String parcelId,",
            "    required String entryId,",
            "    required String accessId,",
            "  }) {",
            "    const startId = 'city_spawn_start';",
            "    final nodeIds = _allNodePositions.keys.toSet();",
            "    if (!nodeIds.contains(entryId) || !nodeIds.contains(accessId)) {",
            "      return null;",
            "    }",
            "",
            "    final distances = <String, double>{",
            "      for (final nodeId in nodeIds) nodeId: double.infinity,",
            "    };",
            "    final previousNode = <String, String>{};",
            "    final previousEdge = <String, String>{};",
            "    final unvisited = nodeIds.toSet();",
            "    distances[startId] = 0;",
            "",
            "    while (unvisited.isNotEmpty) {",
            "      String? current;",
            "      var bestDistance = double.infinity;",
            "      for (final nodeId in unvisited) {",
            "        final distance = distances[nodeId] ?? double.infinity;",
            "        if (distance < bestDistance) {",
            "          bestDistance = distance;",
            "          current = nodeId;",
            "        }",
            "      }",
            "      if (current == null || bestDistance == double.infinity) {",
            "        break;",
            "      }",
            "      unvisited.remove(current);",
            "      if (current == entryId) {",
            "        break;",
            "      }",
            "      for (final step in _adjacency[current] ?? const <_GraphStep>[]) {",
            "        if (!unvisited.contains(step.nextNode)) {",
            "          continue;",
            "        }",
            "        final candidate = bestDistance + step.edge.length;",
            "        if (candidate < (distances[step.nextNode] ?? double.infinity)) {",
            "          distances[step.nextNode] = candidate;",
            "          previousNode[step.nextNode] = current;",
            "          previousEdge[step.nextNode] = step.edge.id;",
            "        }",
            "      }",
            "    }",
            "",
            "    if (!previousNode.containsKey(entryId)) {",
            "      return null;",
            "    }",
            "",
            "    final routeNodes = <String>[entryId];",
            "    final routeEdges = <String>[];",
            "    var current = entryId;",
            "    while (current != startId) {",
            "      final prevNode = previousNode[current];",
            "      final prevEdge = previousEdge[current];",
            "      if (prevNode == null || prevEdge == null) {",
            "        return null;",
            "      }",
            "      routeEdges.insert(0, prevEdge);",
            "      routeNodes.insert(0, prevNode);",
            "      current = prevNode;",
            "    }",
            "",
            "    return FirenzePreviewResolvedRoute(",
            "      parcelId: parcelId,",
            "      entryId: entryId,",
            "      accessId: accessId,",
            "      nodeIds: routeNodes,",
            "      edgeIds: routeEdges,",
            "      points: _routePoints(routeNodes, routeEdges),",
            "      length: distances[entryId]!,",
            "      bridgeChains: _bridgeChainsFor(routeNodes),",
            "    );",
            "  }",
            "",
            "  List<FirenzePreviewPoint> _routePoints(",
            "    List<String> nodeIds,",
            "    List<String> edgeIds,",
            "  ) {",
            "    final points = <FirenzePreviewPoint>[];",
            "    for (var index = 0; index < edgeIds.length; index++) {",
            "      final edge = _edgeById[edgeIds[index]];",
            "      if (edge == null) {",
            "        throw StateError('Route references missing edge ${edgeIds[index]}');",
            "      }",
            "      final fromNode = nodeIds[index];",
            "      final edgePoints = edge.from == fromNode",
            "          ? edge.points",
            "          : edge.points.reversed.toList(growable: false);",
            "      for (var pointIndex = 0; pointIndex < edgePoints.length; pointIndex++) {",
            "        if (points.isNotEmpty && pointIndex == 0) {",
            "          continue;",
            "        }",
            "        points.add(edgePoints[pointIndex]);",
            "      }",
            "    }",
            "    return points;",
            "  }",
            "",
            "  List<String> _bridgeChainsFor(List<String> nodeIds) {",
            "    final bridgeIds = <String>[];",
            "    for (final entry in firenzePreviewBridgeChains.entries) {",
            "      final chain = entry.value;",
            "      final reverse = chain.reversed.toList(growable: false);",
            "      for (var index = 0; index <= nodeIds.length - 3; index++) {",
            "        final window = nodeIds.sublist(index, index + 3);",
            "        if (_sameList(window, chain) || _sameList(window, reverse)) {",
            "          bridgeIds.add(entry.key);",
            "          break;",
            "        }",
            "      }",
            "    }",
            "    return bridgeIds;",
            "  }",
            "}",
            "",
            "class _GraphStep {",
            "  const _GraphStep({",
            "    required this.edge,",
            "    required this.nextNode,",
            "    required this.reversed,",
            "  });",
            "",
            "  final FirenzePreviewNavigationEdge edge;",
            "  final String nextNode;",
            "  final bool reversed;",
            "}",
            "",
            "String _accessForEntry(String entryId) {",
            "  return entryId.replaceFirst('_entry_', '_access_');",
            "}",
            "",
            "bool _sameList(List<String> a, List<String> b) {",
            "  if (a.length != b.length) {",
            "    return false;",
            "  }",
            "  for (var index = 0; index < a.length; index++) {",
            "    if (a[index] != b[index]) {",
            "      return false;",
            "    }",
            "  }",
            "  return true;",
            "}",
            "",
            "double _sqrt(double value) {",
            "  if (value <= 0) {",
            "    return 0;",
            "  }",
            "  var estimate = value;",
            "  for (var index = 0; index < 12; index++) {",
            "    estimate = 0.5 * (estimate + value / estimate);",
            "  }",
            "  return estimate;",
            "}",
            "",
        ]
    )

    OUTPUT_DART.write_text("\n".join(lines), encoding="utf-8")


def _remove_matching(parent: ET.Element, predicate) -> None:
    for child in list(parent):
        if predicate(child):
            parent.remove(child)
            continue
        _remove_matching(child, predicate)


def _is_removed_player_facing_layer(element: ET.Element) -> bool:
    if element.tag != f"{SVG_NS}g":
        return False
    label = element.get(INKSCAPE_LABEL) or element.get("id")
    return label in {
        "00_reference_image",
        "10_anchor_points",
        "11_navigation_nodes",
        "12_navigation_edges",
    }


def _soften_debug_colours(element: ET.Element) -> None:
    for key in ("stroke", "fill"):
        value = element.get(key)
        if value and value.lower() in {"#ff0000", "#f00", "red"}:
            element.set(key, "#f3c86f" if key == "stroke" else "#f3c86f")

    style = element.get("style")
    if not style:
        return

    replacements = {
        "stroke:#ff0000": "stroke:#f3c86f",
        "stroke:#f00": "stroke:#f3c86f",
        "stroke:red": "stroke:#f3c86f",
        "fill:#ff0000": "fill:#f3c86f",
        "fill:#f00": "fill:#f3c86f",
        "fill:red": "fill:#f3c86f",
    }
    updated = style
    lowered = updated.lower()
    for old, new in replacements.items():
        while old in lowered:
            index = lowered.index(old)
            updated = updated[:index] + new + updated[index + len(old) :]
            lowered = updated.lower()
    element.set("style", updated)


def _player_facing_svg_copy() -> Path:
    tree = ET.parse(SOURCE_SVG)
    root = tree.getroot()

    _remove_matching(
        root,
        lambda element: element.tag == f"{SVG_NS}text"
        or _is_removed_player_facing_layer(element),
    )
    for element in root.iter():
        _soften_debug_colours(element)

    temp = tempfile.NamedTemporaryFile(
        mode="wb",
        suffix=".svg",
        prefix="firenze_player_facing_",
        delete=False,
    )
    temp.close()
    output_path = Path(temp.name)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    return output_path


def _force_river_mask_style(element: ET.Element) -> None:
    if element.tag == f"{SVG_NS}text":
        return

    if element.tag != f"{SVG_NS}g":
        element.set("fill", "#ffffff")
        element.set("stroke", "#ffffff")
        element.set("opacity", "1")
        element.set("fill-opacity", "1")
        element.set("stroke-opacity", "1")

    style = element.get("style")
    if not style:
        return

    parts: list[str] = []
    seen_keys: set[str] = set()
    for raw_part in style.split(";"):
        if ":" not in raw_part:
            continue
        key, value = raw_part.split(":", 1)
        key = key.strip()
        if key in {"fill", "stroke"}:
            value = "#ffffff"
        elif key in {"opacity", "fill-opacity", "stroke-opacity"}:
            value = "1"
        parts.append(f"{key}:{value.strip()}")
        seen_keys.add(key)
    for key in ("fill", "stroke", "opacity", "fill-opacity", "stroke-opacity"):
        if key not in seen_keys:
            parts.append(f"{key}:{'#ffffff' if key in {'fill', 'stroke'} else '1'}")
    element.set("style", ";".join(parts))


def _river_mask_svg_copy() -> Path:
    tree = ET.parse(SOURCE_SVG)
    root = tree.getroot()
    river_layer = _layer_by_label(root, "02_river_area")

    for child in list(root):
        if child is not river_layer:
            root.remove(child)

    _remove_matching(river_layer, lambda element: element.tag == f"{SVG_NS}text")
    for element in river_layer.iter():
        _force_river_mask_style(element)

    temp = tempfile.NamedTemporaryFile(
        mode="wb",
        suffix=".svg",
        prefix="firenze_river_mask_",
        delete=False,
    )
    temp.close()
    output_path = Path(temp.name)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    return output_path


def _render_preview_png() -> None:
    converter = shutil.which("rsvg-convert")
    if not converter:
        raise ExtractionError("rsvg-convert is required to render the map preview")
    OUTPUT_PNG.parent.mkdir(parents=True, exist_ok=True)
    player_facing_svg = _player_facing_svg_copy()
    try:
        subprocess.run(
            [
                converter,
                "-w",
                str(EXPECTED_CANVAS_WIDTH),
                "-h",
                str(EXPECTED_CANVAS_HEIGHT),
                str(player_facing_svg),
                "-o",
                str(OUTPUT_PNG),
            ],
            check=True,
        )
    finally:
        player_facing_svg.unlink(missing_ok=True)


def _render_river_mask_png() -> None:
    converter = shutil.which("rsvg-convert")
    if not converter:
        raise ExtractionError("rsvg-convert is required to render the river mask")
    OUTPUT_RIVER_MASK_PNG.parent.mkdir(parents=True, exist_ok=True)
    river_mask_svg = _river_mask_svg_copy()
    try:
        subprocess.run(
            [
                converter,
                "-w",
                str(EXPECTED_CANVAS_WIDTH),
                "-h",
                str(EXPECTED_CANVAS_HEIGHT),
                str(river_mask_svg),
                "-o",
                str(OUTPUT_RIVER_MASK_PNG),
            ],
            check=True,
        )
    finally:
        river_mask_svg.unlink(missing_ok=True)


def main() -> int:
    if not SOURCE_SVG.exists():
        raise ExtractionError(f"Missing source SVG: {SOURCE_SVG}")

    sha256 = _read_source_sha()
    if sha256 != EXPECTED_SHA256:
        raise ExtractionError(
            "Unexpected source SVG SHA-256. Expected "
            f"{EXPECTED_SHA256}, got {sha256}"
        )

    tree = ET.parse(SOURCE_SVG)
    root = tree.getroot()
    if root.get("width") != str(EXPECTED_CANVAS_WIDTH):
        raise ExtractionError(f"Unexpected canvas width: {root.get('width')}")
    if root.get("height") != str(EXPECTED_CANVAS_HEIGHT):
        raise ExtractionError(f"Unexpected canvas height: {root.get('height')}")
    view_box = tuple(float(part) for part in root.get("viewBox", "").split())
    if view_box != EXPECTED_VIEW_BOX:
        raise ExtractionError(f"Unexpected viewBox: {root.get('viewBox')}")

    anchors_layer = _layer_by_label(root, "10_anchor_points")
    nodes_layer = _layer_by_label(root, "11_navigation_nodes")
    edges_layer = _layer_by_label(root, "12_navigation_edges")
    for label, layer in [
        ("10_anchor_points", anchors_layer),
        ("11_navigation_nodes", nodes_layer),
        ("12_navigation_edges", edges_layer),
    ]:
        _assert_no_transforms(layer, label)

    anchor_points = _read_ellipse_points(anchors_layer)
    navigation_nodes = _read_ellipse_points(nodes_layer)
    if len(navigation_nodes) != EXPECTED_NAVIGATION_NODES:
        raise ExtractionError(
            f"Expected {EXPECTED_NAVIGATION_NODES} navigation nodes, "
            f"got {len(navigation_nodes)}"
        )

    graph_positions = dict(navigation_nodes)
    graph_positions["city_spawn_start"] = anchor_points["city_spawn_start"]
    edges = _read_edges(edges_layer, graph_positions)
    if len(edges) != EXPECTED_NAVIGATION_EDGES:
        raise ExtractionError(
            f"Expected {EXPECTED_NAVIGATION_EDGES} navigation edges, "
            f"got {len(edges)}"
        )

    _write_dart(
        sha256=sha256,
        navigation_nodes=navigation_nodes,
        anchor_points=anchor_points,
        edges=edges,
    )
    _render_preview_png()
    _render_river_mask_png()

    print(f"Source SHA-256: {sha256}")
    print(f"Navigation nodes: {len(navigation_nodes)}")
    print(f"Navigation edges: {len(edges)}")
    print(f"Generated Dart: {OUTPUT_DART.relative_to(REPO_ROOT)}")
    print(f"Rendered PNG: {OUTPUT_PNG.relative_to(REPO_ROOT)}")
    print(
        "Rendered river mask: "
        f"{OUTPUT_RIVER_MASK_PNG.relative_to(REPO_ROOT)}"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ExtractionError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)
