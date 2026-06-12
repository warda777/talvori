# M16-DO: Uferwald YAML Planning Skeleton Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `planning_skeleton_gate`, `yaml_file_allowed`,
`not_runtime_data`, `not_asset`, `not_engine_ready`

## 1. Zweck

M16-DO erzeugt die erste echte Uferwald-YAML-Planning-Skeleton-Datei. Diese
Datei ist bewusst nur Planungsstruktur: Sie sammelt Statusschutz,
Pflicht-Layer, erlaubte Feldgruppen, offene Messfragen und QA-Regeln, ohne
Runtime-Daten, finale Koordinaten, Polygone, Path-Centerlines, Path-Nodes,
Assets oder Code zu erzeugen.

Fuehrende Regel:

> Ein YAML-Skeleton ist keine technische Spielkarte.

## 2. Warum die YAML-Datei erlaubt wurde

M16-DN hat M16-DM fachlich reviewt und entschieden:

- M16-DM ist ausreichend.
- Ein M16-DM-FIX ist nicht noetig.
- M16-DO darf als enges YAML Planning Skeleton Gate vorbereitet werden.
- Eine echte `.yaml`-Datei darf nur entstehen, wenn der Folgeprompt exakten
  Pfad, Dateinamen, Maximalstatus, Statusschutz und Datei-Check ausdruecklich
  oeffnet.

Der M16-DO-Prompt oeffnet genau eine `.yaml`-Datei:

```text
docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml
```

Deshalb darf M16-DO diese eine Datei erzeugen. `.json`, `.yml` und weitere
`.yaml`-Dateien bleiben blockiert.

## 3. Erzeugte Datei

| Datei | Status | Rolle |
| --- | --- | --- |
| `docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml` | `planning_skeleton`, `not_runtime_data`, `not_asset`, `not_engine_ready`, `no_geometry_values`, `no_final_coordinates` | Eine enge Planungsstruktur fuer spaeteres Review, keine Runtime-Map. |

Die Datei steht unter `docs/world_design/planning/uferwald/`, nicht unter
`assets/`, nicht in Flutter-Codepfaden und nicht in einem Runtime- oder
Persistenzpfad.

## 4. Pflichtstatus im YAML-Skeleton

Die YAML-Datei beginnt mit diesen Pflichtstatuswerten:

- `format_status: planning_skeleton`
- `runtime_status: not_runtime_data`
- `asset_status: not_asset`
- `engine_status: not_engine_ready`
- `geometry_status: no_geometry_values`
- `coordinate_status: no_final_coordinates`
- `pixel_derivation_policy: pixel_derivation_forbidden`
- `measurement_status: manual_measurement_required`
- `runtime_review_requirement: runtime_review_required_before_use`
- `source_truth_policy: technical_layers_not_art_pixels`

Diese Statuswerte sind der zentrale Schutz gegen eine falsche Nutzung als
Runtime-Manifest, Asset-Spec, Engine-ready Candidate oder produktive Mapdatei.

## 5. Enthaltene Feldgruppen

Das Skeleton enthaelt nur die in M16-DM/M16-DN erlaubten Gruppen:

- `schema_header`
- `format_contract`
- `status_protection`
- `source_docs`
- `visual_references`
- `layer_definitions`
- `geometry_placeholders`
- `qa_requirements`
- `open_measurements`
- `blocked_scope`
- `next_review_gate`

Die Gruppen beschreiben Struktur und Pruefpflichten. Sie enthalten keine
messbaren Werte, keine Punktlisten und keine Runtime-Geometrie.

## 6. Enthaltene Layer-IDs

Das Skeleton enthaelt alle Pflicht-Layer-IDs aus der Uferwald-
Layer-/Masken-Architektur:

- `base_rock_shape`
- `grass_terrain_mask`
- `water_river_mask`
- `walkable_path_layer`
- `tree_obstacle_layer`
- `rock_cliff_obstacle_layer`
- `buildable_zone_layer`
- `plot_footprint_layer`
- `no_walk_mask`
- `no_build_mask`
- `depth_sort_bands`
- `landmark_anchor_layer`

Jeder Layer bleibt `not_measured` und verlangt spaetere manuelle oder
vectorbasierte Messung. Kein Layer ist Runtime-Quelle.

## 7. Weiterhin verbotene Werte

Das YAML-Skeleton verbietet ausdruecklich:

- `geometry_values`
- `coordinate_values`
- `polygon_points`
- `path_centerline`
- `path_nodes`
- `path_edges`
- `build_zone_polygons`
- `plot_footprint_polygons`
- `no_walk_union_values`
- `no_build_union_values`
- `runtime_status: runtime_ready`
- `asset_status: asset`
- `engine_status: engine_ready`
- `source_from_pixels`

Ausserdem enthaelt das Skeleton keine Scheinwerte wie numerische
Koordinatenbeispiele, keine leeren Geometriecontainer, keine Punktarrays und
keine Pixelableitung.

## 8. Warum es trotzdem keine Runtime-Daten sind

Das Skeleton ist maschinenlesbar, aber nicht produktiv nutzbar. Es enthaelt:

- Layer-IDs,
- Rollen,
- Statusschutz,
- erlaubte Datenform-Kandidaten,
- offene Messfragen,
- QA-Anforderungen,
- blockierte Nutzungen.

Es enthaelt nicht:

- echte Koordinaten,
- Polygonpunkte,
- Path-Centerlines,
- Path-Nodes,
- Path-Edges,
- Build-Zonen-Geometrien,
- No-Walk- oder No-Build-Unionen,
- Asset-Pfade,
- Flutter- oder Runtime-Importhinweise.

Damit kann die Datei spaeter reviewt werden, ohne bereits als technische
Spielkarte zu gelten.

## 9. Grenzen fuer Folgearbeit

Nach M16-DO bleibt blockiert:

- Runtime-Mapdaten,
- finale Koordinaten,
- Polygone,
- Path-Centerlines,
- Path-Nodes,
- Path-Edges,
- Build-Zonen-Polygone,
- Plot-Footprint-Polygone,
- No-Walk-/No-Build-Unionen als echte Werte,
- Pixelableitung,
- Dateien unter `assets/`,
- Flutter-/Dart-Code,
- App-Integration,
- Route oder Navigation,
- Persistenz,
- BuildState,
- Bilder, SVG/PNG oder Visuals,
- `.json` oder `.yml`,
- weitere `.yaml`-Dateien.

## 10. Warum M16-DP noetig ist

M16-DO erzeugt erstmals eine echte YAML-Datei. Genau deshalb braucht es danach
einen Review-Slice:

```text
M16-DP Uferwald YAML Planning Skeleton Review
```

M16-DP sollte pruefen:

- ob die YAML-Datei syntaktisch und fachlich sauber ist,
- ob wirklich nur eine `.yaml`-Datei entstanden ist,
- ob keine `.json` oder `.yml` entstanden ist,
- ob alle Pflichtstatuswerte vorhanden sind,
- ob alle Pflicht-Layer enthalten sind,
- ob keine Schein-Geometrie, Koordinaten, Punktlisten, Path-Centerlines,
  Path-Nodes oder Union-Werte enthalten sind,
- ob das Skeleton weiterhin `planning_skeleton` und `not_runtime_data` bleibt,
- ob danach ein Measurement-/Value-Gate vorbereitet werden darf oder ob
  M16-DO-FIX noetig ist.

## 11. Nicht-Freigaben

M16-DO gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Bilder,
- keine SVG/PNG,
- keine `.json`,
- keine `.yml`,
- keine weitere `.yaml`,
- keine Assets,
- keine Dateien unter `assets/`,
- keine finalen Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Figma-Writes,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.
