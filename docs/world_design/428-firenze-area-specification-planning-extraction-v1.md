# 428: Firenze Area-Specification Planning Extraction v1

Stand: 2026-06-18

Status: `documentation_only` / `planning_extraction_v1` / `planning_only` / `not_runtime_data` / `no_json_yaml` / `no_flutter` / `no_collision` / `no_pathfinding` / `no_app_integration` / `no_assets` / `no_commit`

## 1. Ziel

Dieser Slice ist die erste planning-only Extraktion aus der bereinigten Firenze-Master-SVG. Er erzeugt Markdown-Registries fuer Source-Metadaten, Layer, Objekte, Topologie und Review-Flags. Er erzeugt keine Runtime-Area-Spec, keine JSON-/YAML-Datei, keine Flutter-Preview, keine produktiven Koordinaten, keine Polygone, keine Collision- und keine Pathfinding-Daten.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`
- `docs/world_design/427-firenze-area-specification-extraction-plan.md`

## 3. Source Metadata Registry

| field | value | planning_status | blocked_for_runtime |
| --- | --- | --- | --- |
| source_svg_path | docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg | planning_only | true |
| source_svg_sha256 | 58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3 | planning_only | true |
| canvas_width | 1672 | planning_only | true |
| canvas_height | 941 | planning_only | true |
| viewBox | 0 0 442.38333 248.97292 | planning_only | true |

Diese Source-Metadaten sind Review- und Stop-Regel-Werte. Sie sind keine Runtime-Koordinaten und keine Engine-Konfiguration.

## 4. Layer Registry

| family | layer_id | expected_count | found_count | status | planning_status | blocked_for_runtime |
| --- | --- | --- | --- | --- | --- | --- |
| Boundary | 01_boundary | 1 | 1 | PASS | candidate_only | true |
| River | 02_river_area | 1 | 1 | PASS | candidate_only | true |
| Bridges | 03_bridge_decks | 8 | 8 | PASS | candidate_only | true |
| Main Roads | 04_main_roads | 7 | 7 | PASS | candidate_only | true |
| Side Roads | 05_side_roads | 42 | 42 | PASS | candidate_only | true |
| Parcels | 06_parcels | 14 | 14 | PASS | candidate_only | true |
| Landmarks | 07_landmarks | 6 | 6 | PASS | candidate_only | true |
| Green Areas | 08_green_areas | 48 | 48 | PASS | candidate_only | true |
| Urban Blocks | 09_urban_blocks | 37 | 37 | PASS | candidate_only | true |
| Anchor Points | 10_anchor_points | 48 | 48 | PASS | candidate_only | true |
| Navigation Nodes | 11_navigation_nodes | 181 | 181 | PASS | candidate_only | true |
| Navigation Edges | 12_navigation_edges | 221 | 221 | PASS | candidate_only | true |

## 5. Object Registry

Alle Objektzeilen sind planning-only. `source_trace` verweist nur auf Layer und Objekt-ID, nicht auf Koordinaten, Pfadpunkte oder SVG-Geometrie.

### 5.1 Boundary


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 01_boundary | boundary_playable_firenze | boundary_playable_firenze | Boundary | playable_boundary_candidate | candidate_only | false | false | false | true | svg:01_boundary/boundary_playable_firenze; docs:426,427; status:planning_only |

### 5.2 River


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 02_river_area | river_arno_area | river_arno_area | River | water_barrier_candidate | candidate_only | true | true | false | true | svg:02_river_area/river_arno_area; docs:426,427; status:planning_only |

### 5.3 Bridges B01-B08


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 03_bridge_decks | bridge_B01 | bridge_B01 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B01; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B02 | bridge_B02 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B02; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B03 | bridge_B03 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B03; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B04 | bridge_B04 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B04; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B05 | bridge_B05 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B05; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B06 | bridge_B06 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B06; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B07 | bridge_B07 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B07; docs:426,427; status:planning_only |
| 03_bridge_decks | bridge_B08 | bridge_B08 | Bridges | walk_candidate / bridge_deck_candidate | candidate_only | false | true | false | true | svg:03_bridge_decks/bridge_B08; docs:426,427; status:planning_only |

### 5.4 Main Roads


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 04_main_roads | main_road_001 | main_road_001 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_001; docs:426,427; status:planning_only |
| 04_main_roads | main_road_002 | main_road_002 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_002; docs:426,427; status:planning_only |
| 04_main_roads | main_road_003 | main_road_003 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_003; docs:426,427; status:planning_only |
| 04_main_roads | main_road_004 | main_road_004 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_004; docs:426,427; status:planning_only |
| 04_main_roads | main_road_005 | main_road_005 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_005; docs:426,427; status:planning_only |
| 04_main_roads | main_road_006 | main_road_006 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_006; docs:426,427; status:planning_only |
| 04_main_roads | main_road_007 | main_road_007 | Main Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:04_main_roads/main_road_007; docs:426,427; status:planning_only |

### 5.5 Side Roads


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 05_side_roads | side_road_001 | side_road_001 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_001; docs:426,427; status:planning_only |
| 05_side_roads | side_road_002 | side_road_002 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_002; docs:426,427; status:planning_only |
| 05_side_roads | side_road_003 | side_road_003 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_003; docs:426,427; status:planning_only |
| 05_side_roads | side_road_004 | side_road_004 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_004; docs:426,427; status:planning_only |
| 05_side_roads | side_road_005 | side_road_005 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_005; docs:426,427; status:planning_only |
| 05_side_roads | side_road_006 | side_road_006 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_006; docs:426,427; status:planning_only |
| 05_side_roads | side_road_007 | side_road_007 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_007; docs:426,427; status:planning_only |
| 05_side_roads | side_road_008 | side_road_008 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_008; docs:426,427; status:planning_only |
| 05_side_roads | side_road_009 | side_road_009 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_009; docs:426,427; status:planning_only |
| 05_side_roads | side_road_010 | side_road_010 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_010; docs:426,427; status:planning_only |
| 05_side_roads | side_road_011 | side_road_011 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_011; docs:426,427; status:planning_only |
| 05_side_roads | side_road_012 | side_road_012 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_012; docs:426,427; status:planning_only |
| 05_side_roads | side_road_013 | side_road_013 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_013; docs:426,427; status:planning_only |
| 05_side_roads | side_road_014 | side_road_014 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_014; docs:426,427; status:planning_only |
| 05_side_roads | side_road_015 | side_road_015 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_015; docs:426,427; status:planning_only |
| 05_side_roads | side_road_016 | side_road_016 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_016; docs:426,427; status:planning_only |
| 05_side_roads | side_road_017 | side_road_017 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_017; docs:426,427; status:planning_only |
| 05_side_roads | side_road_018 | side_road_018 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_018; docs:426,427; status:planning_only |
| 05_side_roads | side_road_019 | side_road_019 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_019; docs:426,427; status:planning_only |
| 05_side_roads | side_road_020 | side_road_020 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_020; docs:426,427; status:planning_only |
| 05_side_roads | side_road_021 | side_road_021 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_021; docs:426,427; status:planning_only |
| 05_side_roads | side_road_022 | side_road_022 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_022; docs:426,427; status:planning_only |
| 05_side_roads | side_road_023 | side_road_023 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_023; docs:426,427; status:planning_only |
| 05_side_roads | side_road_024 | side_road_024 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_024; docs:426,427; status:planning_only |
| 05_side_roads | side_road_025 | side_road_025 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_025; docs:426,427; status:planning_only |
| 05_side_roads | side_road_026 | side_road_026 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_026; docs:426,427; status:planning_only |
| 05_side_roads | side_road_027 | side_road_027 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_027; docs:426,427; status:planning_only |
| 05_side_roads | side_road_028 | side_road_028 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_028; docs:426,427; status:planning_only |
| 05_side_roads | side_road_029 | side_road_029 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_029; docs:426,427; status:planning_only |
| 05_side_roads | side_road_030 | side_road_030 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_030; docs:426,427; status:planning_only |
| 05_side_roads | side_road_031 | side_road_031 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_031; docs:426,427; status:planning_only |
| 05_side_roads | side_road_032 | side_road_032 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_032; docs:426,427; status:planning_only |
| 05_side_roads | side_road_033 | side_road_033 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_033; docs:426,427; status:planning_only |
| 05_side_roads | side_road_034 | side_road_034 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_034; docs:426,427; status:planning_only |
| 05_side_roads | side_road_035 | side_road_035 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_035; docs:426,427; status:planning_only |
| 05_side_roads | side_road_036 | side_road_036 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_036; docs:426,427; status:planning_only |
| 05_side_roads | side_road_037 | side_road_037 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_037; docs:426,427; status:planning_only |
| 05_side_roads | side_road_038 | side_road_038 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_038; docs:426,427; status:planning_only |
| 05_side_roads | side_road_039 | side_road_039 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_039; docs:426,427; status:planning_only |
| 05_side_roads | side_road_040 | side_road_040 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_040; docs:426,427; status:planning_only |
| 05_side_roads | side_road_041 | side_road_041 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_041; docs:426,427; status:planning_only |
| 05_side_roads | side_road_042 | side_road_042 | Side Roads | walk_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:05_side_roads/side_road_042; docs:426,427; status:planning_only |

### 5.6 Parcels P01-P14


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 06_parcels | P01 | P01 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P01; docs:426,427; status:planning_only |
| 06_parcels | P02 | P02 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P02; docs:426,427; status:planning_only |
| 06_parcels | P03 | P03 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P03; docs:426,427; status:planning_only |
| 06_parcels | P04 | P04 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P04; docs:426,427; status:planning_only |
| 06_parcels | P05 | P05 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P05; docs:426,427; status:planning_only |
| 06_parcels | P06 | P06 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P06; docs:426,427; status:planning_only |
| 06_parcels | P07 | P07 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P07; docs:426,427; status:planning_only |
| 06_parcels | P08 | P08 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P08; docs:426,427; status:planning_only |
| 06_parcels | P09 | P09 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P09; docs:426,427; status:planning_only |
| 06_parcels | P10 | P10 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P10; docs:426,427; status:planning_only |
| 06_parcels | P11 | P11 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P11; docs:426,427; status:planning_only |
| 06_parcels | P12 | P12 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P12; docs:426,427; status:planning_only |
| 06_parcels | P13 | P13 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P13; docs:426,427; status:planning_only |
| 06_parcels | P14 | P14 | Parcels | portal_candidate / detail_map_entry_candidate | candidate_only | false | false | false | true | svg:06_parcels/P14; docs:426,427; status:planning_only |

### 5.7 Landmarks L01-L06


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 07_landmarks | L01 | L01 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L01; docs:426,427; status:planning_only |
| 07_landmarks | L02 | L02 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L02; docs:426,427; status:planning_only |
| 07_landmarks | L03 | L03 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L03; docs:426,427; status:planning_only |
| 07_landmarks | L04 | L04 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L04; docs:426,427; status:planning_only |
| 07_landmarks | L05 | L05 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L05; docs:426,427; status:planning_only |
| 07_landmarks | L06 | L06 | Landmarks | protected_core_candidate | candidate_only | false | true | false | true | svg:07_landmarks/L06; docs:426,427; status:planning_only |

### 5.8 Green Areas G01-G48


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 08_green_areas | G01 | G01 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G01; docs:426,427; status:planning_only |
| 08_green_areas | G02 | G02 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G02; docs:426,427; status:planning_only |
| 08_green_areas | G03 | G03 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G03; docs:426,427; status:planning_only |
| 08_green_areas | G04 | G04 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G04; docs:426,427; status:planning_only |
| 08_green_areas | G05 | G05 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G05; docs:426,427; status:planning_only |
| 08_green_areas | G06 | G06 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G06; docs:426,427; status:planning_only |
| 08_green_areas | G07 | G07 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G07; docs:426,427; status:planning_only |
| 08_green_areas | G08 | G08 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G08; docs:426,427; status:planning_only |
| 08_green_areas | G09 | G09 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G09; docs:426,427; status:planning_only |
| 08_green_areas | G10 | G10 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G10; docs:426,427; status:planning_only |
| 08_green_areas | G11 | G11 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G11; docs:426,427; status:planning_only |
| 08_green_areas | G12 | G12 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G12; docs:426,427; status:planning_only |
| 08_green_areas | G13 | G13 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G13; docs:426,427; status:planning_only |
| 08_green_areas | G14 | G14 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G14; docs:426,427; status:planning_only |
| 08_green_areas | G15 | G15 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G15; docs:426,427; status:planning_only |
| 08_green_areas | G16 | G16 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G16; docs:426,427; status:planning_only |
| 08_green_areas | G17 | G17 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G17; docs:426,427; status:planning_only |
| 08_green_areas | G18 | G18 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G18; docs:426,427; status:planning_only |
| 08_green_areas | G19 | G19 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G19; docs:426,427; status:planning_only |
| 08_green_areas | G20 | G20 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G20; docs:426,427; status:planning_only |
| 08_green_areas | G21 | G21 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G21; docs:426,427; status:planning_only |
| 08_green_areas | G22 | G22 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G22; docs:426,427; status:planning_only |
| 08_green_areas | G23 | G23 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G23; docs:426,427; status:planning_only |
| 08_green_areas | G24 | G24 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G24; docs:426,427; status:planning_only |
| 08_green_areas | G25 | G25 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G25; docs:426,427; status:planning_only |
| 08_green_areas | G26 | G26 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G26; docs:426,427; status:planning_only |
| 08_green_areas | G27 | G27 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G27; docs:426,427; status:planning_only |
| 08_green_areas | G28 | G28 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G28; docs:426,427; status:planning_only |
| 08_green_areas | G29 | G29 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G29; docs:426,427; status:planning_only |
| 08_green_areas | G30 | G30 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G30; docs:426,427; status:planning_only |
| 08_green_areas | G31 | G31 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G31; docs:426,427; status:planning_only |
| 08_green_areas | G32 | G32 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G32; docs:426,427; status:planning_only |
| 08_green_areas | G33 | G33 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G33; docs:426,427; status:planning_only |
| 08_green_areas | G34 | G34 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G34; docs:426,427; status:planning_only |
| 08_green_areas | G35 | G35 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G35; docs:426,427; status:planning_only |
| 08_green_areas | G36 | G36 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G36; docs:426,427; status:planning_only |
| 08_green_areas | G37 | G37 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G37; docs:426,427; status:planning_only |
| 08_green_areas | G38 | G38 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G38; docs:426,427; status:planning_only |
| 08_green_areas | G39 | G39 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G39; docs:426,427; status:planning_only |
| 08_green_areas | G40 | G40 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G40; docs:426,427; status:planning_only |
| 08_green_areas | G41 | G41 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G41; docs:426,427; status:planning_only |
| 08_green_areas | G42 | G42 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G42; docs:426,427; status:planning_only |
| 08_green_areas | G43 | G43 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G43; docs:426,427; status:planning_only |
| 08_green_areas | G44 | G44 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G44; docs:426,427; status:planning_only |
| 08_green_areas | G45 | G45 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G45; docs:426,427; status:planning_only |
| 08_green_areas | G46 | G46 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G46; docs:426,427; status:planning_only |
| 08_green_areas | G47 | G47 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G47; docs:426,427; status:planning_only |
| 08_green_areas | G48 | G48 | Green Areas | context_candidate | candidate_only | false | false | false | true | svg:08_green_areas/G48; docs:426,427; status:planning_only |

### 5.9 Urban Blocks U01-U37


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 09_urban_blocks | U01 | U01 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U01; docs:426,427; status:planning_only |
| 09_urban_blocks | U02 | U02 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U02; docs:426,427; status:planning_only |
| 09_urban_blocks | U03 | U03 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U03; docs:426,427; status:planning_only |
| 09_urban_blocks | U04 | U04 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U04; docs:426,427; status:planning_only |
| 09_urban_blocks | U05 | U05 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U05; docs:426,427; status:planning_only |
| 09_urban_blocks | U06 | U06 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U06; docs:426,427; status:planning_only |
| 09_urban_blocks | U07 | U07 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U07; docs:426,427; status:planning_only |
| 09_urban_blocks | U08 | U08 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U08; docs:426,427; status:planning_only |
| 09_urban_blocks | U09 | U09 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U09; docs:426,427; status:planning_only |
| 09_urban_blocks | U10 | U10 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U10; docs:426,427; status:planning_only |
| 09_urban_blocks | U11 | U11 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U11; docs:426,427; status:planning_only |
| 09_urban_blocks | U12 | U12 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U12; docs:426,427; status:planning_only |
| 09_urban_blocks | U13 | U13 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U13; docs:426,427; status:planning_only |
| 09_urban_blocks | U14 | U14 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U14; docs:426,427; status:planning_only |
| 09_urban_blocks | U15 | U15 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U15; docs:426,427; status:planning_only |
| 09_urban_blocks | U16 | U16 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U16; docs:426,427; status:planning_only |
| 09_urban_blocks | U17 | U17 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U17; docs:426,427; status:planning_only |
| 09_urban_blocks | U18 | U18 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U18; docs:426,427; status:planning_only |
| 09_urban_blocks | U19 | U19 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U19; docs:426,427; status:planning_only |
| 09_urban_blocks | U20 | U20 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U20; docs:426,427; status:planning_only |
| 09_urban_blocks | U21 | U21 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U21; docs:426,427; status:planning_only |
| 09_urban_blocks | U22 | U22 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U22; docs:426,427; status:planning_only |
| 09_urban_blocks | U23 | U23 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U23; docs:426,427; status:planning_only |
| 09_urban_blocks | U24 | U24 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U24; docs:426,427; status:planning_only |
| 09_urban_blocks | U25 | U25 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U25; docs:426,427; status:planning_only |
| 09_urban_blocks | U26 | U26 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U26; docs:426,427; status:planning_only |
| 09_urban_blocks | U27 | U27 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U27; docs:426,427; status:planning_only |
| 09_urban_blocks | U28 | U28 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U28; docs:426,427; status:planning_only |
| 09_urban_blocks | U29 | U29 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U29; docs:426,427; status:planning_only |
| 09_urban_blocks | U30 | U30 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U30; docs:426,427; status:planning_only |
| 09_urban_blocks | U31 | U31 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U31; docs:426,427; status:planning_only |
| 09_urban_blocks | U32 | U32 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U32; docs:426,427; status:planning_only |
| 09_urban_blocks | U33 | U33 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U33; docs:426,427; status:planning_only |
| 09_urban_blocks | U34 | U34 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U34; docs:426,427; status:planning_only |
| 09_urban_blocks | U35 | U35 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U35; docs:426,427; status:planning_only |
| 09_urban_blocks | U36 | U36 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U36; docs:426,427; status:planning_only |
| 09_urban_blocks | U37 | U37 | Urban Blocks | blocked_context_candidate / no_build_candidate | candidate_only | false | true | false | true | svg:09_urban_blocks/U37; docs:426,427; status:planning_only |

### 5.10 Anchor Points


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10_anchor_points | P01_anchor_ring | P01_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P01_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P01_anchor | P01_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P01_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P02_anchor_ring | P02_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P02_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P02_anchor | P02_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P02_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P03_anchor_ring | P03_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P03_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P03_anchor | P03_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P03_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P04_anchor_ring | P04_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P04_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P04_anchor | P04_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P04_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P05_anchor_ring | P05_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P05_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P05_anchor | P05_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P05_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P06_anchor_ring | P06_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P06_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P06_anchor | P06_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P06_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P07_anchor_ring | P07_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P07_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P07_anchor | P07_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P07_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P08_anchor_ring | P08_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P08_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P08_anchor | P08_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P08_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P09_anchor_ring | P09_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P09_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P09_anchor | P09_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P09_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P10_anchor_ring | P10_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P10_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P10_anchor | P10_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P10_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P11_anchor_ring | P11_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P11_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P11_anchor | P11_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P11_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P12_anchor_ring | P12_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P12_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P12_anchor | P12_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P12_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P13_anchor_ring | P13_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P13_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P13_anchor | P13_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P13_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | P14_anchor_ring | P14_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P14_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | P14_anchor | P14_anchor | Anchor Points | parcel_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/P14_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B01_anchor_ring | B01_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B01_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B01_anchor | B01_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B01_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B02_anchor_ring | B02_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B02_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B02_anchor | B02_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B02_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B03_anchor_ring | B03_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B03_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B03_anchor | B03_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B03_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B04_anchor_ring | B04_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B04_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B04_anchor | B04_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B04_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B05_anchor_ring | B05_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B05_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B05_anchor | B05_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B05_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B06_anchor_ring | B06_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B06_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B06_anchor | B06_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B06_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B07_anchor_ring | B07_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B07_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B07_anchor | B07_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B07_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | B08_anchor_ring | B08_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B08_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | B08_anchor | B08_anchor | Anchor Points | bridge_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/B08_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | city_center_anchor_ring | city_center_anchor_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/city_center_anchor_ring; docs:426,427; status:planning_only |
| 10_anchor_points | city_center_anchor | city_center_anchor | Anchor Points | camera_or_city_center_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/city_center_anchor; docs:426,427; status:planning_only |
| 10_anchor_points | city_spawn_start_ring | city_spawn_start_ring | Anchor Points | anchor_visual_ring_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/city_spawn_start_ring; docs:426,427; status:planning_only |
| 10_anchor_points | city_spawn_start | city_spawn_start | Anchor Points | start_anchor_candidate | candidate_only | false | false | false | true | svg:10_anchor_points/city_spawn_start; docs:426,427; status:planning_only |

### 5.11 Navigation Nodes


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 11_navigation_nodes | B01_N | B01_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B01_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B01_S | B01_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B01_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B01_M | B01_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B01_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B02_N | B02_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B02_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B02_M | B02_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B02_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B02_S | B02_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B02_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B03_N | B03_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B03_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B03_M | B03_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B03_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B03_S | B03_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B03_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B04_N | B04_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B04_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B04_M | B04_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B04_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B04_S | B04_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B04_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B05_N | B05_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B05_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B05_M | B05_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B05_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B05_S | B05_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B05_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B06_N | B06_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B06_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B06_M | B06_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B06_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B06_S | B06_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B06_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B07_N | B07_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B07_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B07_M | B07_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B07_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B07_S | B07_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B07_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | B08_N | B08_N | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B08_N; docs:426,427; status:planning_only |
| 11_navigation_nodes | B08_M | B08_M | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B08_M; docs:426,427; status:planning_only |
| 11_navigation_nodes | B08_S | B08_S | Navigation Nodes | bridge_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/B08_S; docs:426,427; status:planning_only |
| 11_navigation_nodes | P01_entry_1 | P01_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P01_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P01_entry_2 | P01_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P01_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P02_entry_1 | P02_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P02_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P02_entry_2 | P02_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P02_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P03_entry_1 | P03_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P03_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P03_entry_2 | P03_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P03_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P04_entry_1 | P04_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P04_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P04_entry_2 | P04_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P04_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P05_entry_1 | P05_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P05_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P05_entry_2 | P05_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P05_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P06_entry_1 | P06_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P06_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P06_entry_2 | P06_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P06_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P07_entry_1 | P07_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P07_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P07_entry_2 | P07_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P07_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P08_entry_1 | P08_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P08_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P08_entry_2 | P08_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P08_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P09_entry_1 | P09_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P09_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P09_entry_2 | P09_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P09_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P10_entry_1 | P10_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P10_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P10_entry_2 | P10_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P10_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P11_entry_1 | P11_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P11_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P11_entry_2 | P11_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P11_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P12_entry_1 | P12_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P12_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P12_entry_2 | P12_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P12_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P13_entry_1 | P13_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P13_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P13_entry_2 | P13_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P13_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P14_entry_1 | P14_entry_1 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P14_entry_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P14_entry_2 | P14_entry_2 | Navigation Nodes | parcel_entry_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P14_entry_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | N001_crossroad | N001_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N001_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N002_crossroad | N002_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N002_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N003_crossroad | N003_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N003_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N004_crossroad | N004_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N004_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N005_crossroad | N005_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N005_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N006_crossroad | N006_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N006_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N007_crossroad | N007_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N007_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N008_crossroad | N008_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N008_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N009_crossroad | N009_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N009_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N010_crossroad | N010_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N010_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N011_crossroad | N011_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N011_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N012_crossroad | N012_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N012_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N013_crossroad | N013_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N013_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N014_crossroad | N014_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N014_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N015_crossroad | N015_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N015_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N016_crossroad | N016_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N016_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N017_crossroad | N017_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N017_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N018_crossroad | N018_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N018_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N019_crossroad | N019_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N019_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N020_crossroad | N020_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N020_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N021_crossroad | N021_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N021_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N022_crossroad | N022_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N022_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N023_crossroad | N023_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N023_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N024_crossroad | N024_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N024_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N025_crossroad | N025_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N025_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N026_crossroad | N026_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N026_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N027_crossroad | N027_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N027_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N028_crossroad | N028_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N028_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N029_crossroad | N029_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N029_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N030_crossroad | N030_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N030_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N031_crossroad | N031_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N031_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N032_crossroad | N032_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N032_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N033_crossroad | N033_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N033_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N034_crossroad | N034_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N034_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N035_crossroad | N035_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N035_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N036_crossroad | N036_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N036_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N037_crossroad | N037_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N037_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N038_crossroad | N038_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N038_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N039_crossroad | N039_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N039_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N040_crossroad | N040_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N040_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N041_crossroad | N041_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N041_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N042_crossroad | N042_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N042_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N043_crossroad | N043_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N043_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N044_crossroad | N044_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N044_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N045_crossroad | N045_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N045_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N046_crossroad | N046_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N046_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N047_crossroad | N047_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N047_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N048_crossroad | N048_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N048_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N049_crossroad | N049_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N049_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N050_crossroad | N050_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N050_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N051_crossroad | N051_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N051_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N052_crossroad | N052_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N052_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N053_crossroad | N053_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N053_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N054_crossroad | N054_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N054_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N055_crossroad | N055_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N055_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N056_crossroad | N056_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N056_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N057_crossroad | N057_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N057_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N058_crossroad | N058_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N058_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N059_crossroad | N059_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N059_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N060_crossroad | N060_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N060_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N061_crossroad | N061_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N061_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N062_crossroad | N062_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N062_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N063_crossroad | N063_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N063_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N064_crossroad | N064_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N064_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N065_crossroad | N065_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N065_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N066_crossroad | N066_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N066_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N067_crossroad | N067_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N067_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N068_crossroad | N068_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N068_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N069_crossroad | N069_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N069_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N070_crossroad | N070_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N070_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N071_crossroad | N071_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N071_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N072_crossroad | N072_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N072_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N073_crossroad | N073_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N073_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | N074_crossroad | N074_crossroad | Navigation Nodes | crossroad_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/N074_crossroad; docs:426,427; status:planning_only |
| 11_navigation_nodes | P01_access_1 | P01_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P01_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P02_access_1 | P02_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P02_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P02_access_2 | P02_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P02_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P03_access_1 | P03_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P03_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P03_access_2 | P03_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P03_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P04_access_1 | P04_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P04_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P04_access_2 | P04_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P04_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P05_access_1 | P05_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P05_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P05_access_2 | P05_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P05_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P06_access_1 | P06_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P06_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P06_access_2 | P06_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P06_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P07_access_1 | P07_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P07_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P07_access_2 | P07_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P07_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P08_access_1 | P08_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P08_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P08_access_2 | P08_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P08_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P09_access_1 | P09_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P09_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P09_access_2 | P09_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P09_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P10_access_1 | P10_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P10_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P10_access_2 | P10_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P10_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P11_access_1 | P11_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P11_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P11_access_2 | P11_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P11_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P12_access_1 | P12_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P12_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P12_access_2 | P12_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P12_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P13_access_1 | P13_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P13_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P13_access_2 | P13_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P13_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P14_access_1 | P14_access_1 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P14_access_1; docs:426,427; status:planning_only |
| 11_navigation_nodes | P14_access_2 | P14_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P14_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | P01_access_2 | P01_access_2 | Navigation Nodes | parcel_access_node_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/P01_access_2; docs:426,427; status:planning_only |
| 11_navigation_nodes | T001_road_end | T001_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T001_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T002_road_end | T002_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T002_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T003_road_end | T003_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T003_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T004_road_end | T004_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T004_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T005_road_end | T005_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T005_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T006_road_end | T006_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T006_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T007_road_end | T007_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T007_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T008_road_end | T008_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T008_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T009_road_end | T009_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T009_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T010_road_end | T010_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T010_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T011_road_end | T011_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T011_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T012_road_end | T012_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T012_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T013_road_end | T013_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T013_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T014_road_end | T014_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T014_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T015_road_end | T015_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T015_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T016_road_end | T016_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T016_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T017_road_end | T017_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T017_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T018_road_end | T018_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T018_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T019_road_end | T019_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T019_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T020_road_end | T020_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T020_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T021_road_end | T021_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T021_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T022_road_end | T022_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T022_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T023_road_end | T023_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T023_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T024_road_end | T024_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T024_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T025_road_end | T025_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T025_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | T026_road_end | T026_road_end | Navigation Nodes | boundary_road_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/T026_road_end; docs:426,427; status:planning_only |
| 11_navigation_nodes | D001_internal_road_end | D001_internal_road_end | Navigation Nodes | internal_dead_end_candidate | candidate_only | false | false | false | true | svg:11_navigation_nodes/D001_internal_road_end; docs:426,427; status:planning_only |

### 5.12 Navigation Edges


| layer_id | object_id | label | family | role | planning_status | no_walk_candidate | no_build_candidate | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 12_navigation_edges | E_city_spawn_start_N001_crossroad | E_city_spawn_start_N001_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_city_spawn_start_N001_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N001_crossroad_N002_crossroad | E_N001_crossroad_N002_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N001_crossroad_N002_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N002_crossroad_N045_crossroad | E_N002_crossroad_N045_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N002_crossroad_N045_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N001_crossroad_N043_crossroad | E_N001_crossroad_N043_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N001_crossroad_N043_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N001_crossroad_T001_road_end | E_N001_crossroad_T001_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N001_crossroad_T001_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N007_crossroad_T002_road_end | E_N007_crossroad_T002_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N007_crossroad_T002_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N006_crossroad_N004_crossroad | E_N006_crossroad_N004_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N006_crossroad_N004_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N004_crossroad_N005_crossroad | E_N004_crossroad_N005_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N004_crossroad_N005_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N005_crossroad_N047_crossroad | E_N005_crossroad_N047_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N005_crossroad_N047_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N010_crossroad_N012_crossroad | E_N010_crossroad_N012_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N010_crossroad_N012_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N012_crossroad_N013_crossroad | E_N012_crossroad_N013_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N012_crossroad_N013_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N013_crossroad_N014_crossroad | E_N013_crossroad_N014_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N013_crossroad_N014_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N014_crossroad_N015_crossroad | E_N014_crossroad_N015_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N014_crossroad_N015_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N013_crossroad_N059_crossroad | E_N013_crossroad_N059_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N013_crossroad_N059_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N008_crossroad_N009_crossroad | E_N008_crossroad_N009_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N008_crossroad_N009_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N005_crossroad_D001_internal_road_end | E_N005_crossroad_D001_internal_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N005_crossroad_D001_internal_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N009_crossroad_T003_road_end | E_N009_crossroad_T003_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N009_crossroad_T003_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N043_crossroad_B01_N | E_N043_crossroad_B01_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N043_crossroad_B01_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N040_crossroad_T004_road_end | E_N040_crossroad_T004_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N040_crossroad_T004_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N045_crossroad_B02_N | E_N045_crossroad_B02_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N045_crossroad_B02_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N037_crossroad_N038_crossroad | E_N037_crossroad_N038_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N037_crossroad_N038_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N038_crossroad_N034_crossroad | E_N038_crossroad_N034_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N038_crossroad_N034_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N034_crossroad_N033_crossroad | E_N034_crossroad_N033_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N034_crossroad_N033_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N052_crossroad_B03_N | E_N052_crossroad_B03_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N052_crossroad_B03_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N036_crossroad_N035_crossroad | E_N036_crossroad_N035_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N036_crossroad_N035_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N035_crossroad_N033_crossroad | E_N035_crossroad_N033_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N035_crossroad_N033_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N033_crossroad_N032_crossroad | E_N033_crossroad_N032_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N033_crossroad_N032_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N032_crossroad_N031_crossroad | E_N032_crossroad_N031_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N032_crossroad_N031_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N031_crossroad_N030_crossroad | E_N031_crossroad_N030_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N031_crossroad_N030_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N015_crossroad_B05_N | E_N015_crossroad_B05_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N015_crossroad_B05_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N027_crossroad_N026_crossroad | E_N027_crossroad_N026_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N027_crossroad_N026_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N028_crossroad_N029_crossroad | E_N028_crossroad_N029_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N028_crossroad_N029_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N029_crossroad_N030_crossroad | E_N029_crossroad_N030_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N029_crossroad_N030_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N047_crossroad_B04_N | E_N047_crossroad_B04_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N047_crossroad_B04_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N016_crossroad_B06_N | E_N016_crossroad_B06_N | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N016_crossroad_B06_N; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N025_crossroad_N024_crossroad | E_N025_crossroad_N024_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N025_crossroad_N024_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N022_crossroad_N021_crossroad | E_N022_crossroad_N021_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N022_crossroad_N021_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N021_crossroad_T005_road_end | E_N021_crossroad_T005_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N021_crossroad_T005_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N021_crossroad_N020_crossroad | E_N021_crossroad_N020_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N021_crossroad_N020_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B07_N_N018_crossroad | E_B07_N_N018_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B07_N_N018_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N044_crossroad_N041_crossroad | E_N044_crossroad_N041_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N044_crossroad_N041_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N041_crossroad_T006_road_end | E_N041_crossroad_T006_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N041_crossroad_T006_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N044_crossroad_N042_crossroad | E_N044_crossroad_N042_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N044_crossroad_N042_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N041_crossroad_N042_crossroad | E_N041_crossroad_N042_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N041_crossroad_N042_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N042_crossroad_N051_crossroad | E_N042_crossroad_N051_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N042_crossroad_N051_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N051_crossroad_P01_access_2 | E_N051_crossroad_P01_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N051_crossroad_P01_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N050_crossroad_T007_road_end | E_N050_crossroad_T007_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N050_crossroad_T007_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N051_crossroad_N043_crossroad | E_N051_crossroad_N043_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N051_crossroad_N043_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N043_crossroad_N045_crossroad | E_N043_crossroad_N045_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N043_crossroad_N045_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N052_crossroad_N047_crossroad | E_N052_crossroad_N047_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N052_crossroad_N047_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N047_crossroad_N071_crossroad | E_N047_crossroad_N071_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N047_crossroad_N071_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N071_crossroad_N015_crossroad | E_N071_crossroad_N015_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N071_crossroad_N015_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N015_crossroad_N016_crossroad | E_N015_crossroad_N016_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N015_crossroad_N016_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N016_crossroad_N018_crossroad | E_N016_crossroad_N018_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N016_crossroad_N018_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N018_crossroad_T008_road_end | E_N018_crossroad_T008_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N018_crossroad_T008_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N019_crossroad_T009_road_end | E_N019_crossroad_T009_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N019_crossroad_T009_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N019_crossroad_N074_crossroad | E_N019_crossroad_N074_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N019_crossroad_N074_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N074_crossroad_N023_crossroad | E_N074_crossroad_N023_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N074_crossroad_N023_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N074_crossroad_N025_crossroad | E_N074_crossroad_N025_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N074_crossroad_N025_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N025_crossroad_N027_crossroad | E_N025_crossroad_N027_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N025_crossroad_N027_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N027_crossroad_N070_crossroad | E_N027_crossroad_N070_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N027_crossroad_N070_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B08_N_N071_crossroad | E_B08_N_N071_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B08_N_N071_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N070_crossroad_N069_crossroad | E_N070_crossroad_N069_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N070_crossroad_N069_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N069_crossroad_N028_crossroad | E_N069_crossroad_N028_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N069_crossroad_N028_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N028_crossroad_T010_road_end | E_N028_crossroad_T010_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N028_crossroad_T010_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N069_crossroad_N072_crossroad | E_N069_crossroad_N072_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N069_crossroad_N072_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N072_crossroad_N048_crossroad | E_N072_crossroad_N048_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N072_crossroad_N048_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N048_crossroad_N029_crossroad | E_N048_crossroad_N029_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N048_crossroad_N029_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N029_crossroad_N065_crossroad | E_N029_crossroad_N065_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N029_crossroad_N065_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N065_crossroad_T011_road_end | E_N065_crossroad_T011_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N065_crossroad_T011_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N048_crossroad_N049_crossroad | E_N048_crossroad_N049_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N048_crossroad_N049_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N049_crossroad_N031_crossroad | E_N049_crossroad_N031_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N049_crossroad_N031_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N049_crossroad_N072_crossroad | E_N049_crossroad_N072_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N049_crossroad_N072_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N032_crossroad_T012_road_end | E_N032_crossroad_T012_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N032_crossroad_T012_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N038_crossroad_N035_crossroad | E_N038_crossroad_N035_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N038_crossroad_N035_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N046_crossroad_N070_crossroad | E_N046_crossroad_N070_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N046_crossroad_N070_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N046_crossroad_N036_crossroad | E_N046_crossroad_N036_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N046_crossroad_N036_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N036_crossroad_N037_crossroad | E_N036_crossroad_N037_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N036_crossroad_N037_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N037_crossroad_N040_crossroad | E_N037_crossroad_N040_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N037_crossroad_N040_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N040_crossroad_N050_crossroad | E_N040_crossroad_N050_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N040_crossroad_N050_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N022_crossroad_N020_crossroad | E_N022_crossroad_N020_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N022_crossroad_N020_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N020_crossroad_T013_road_end | E_N020_crossroad_T013_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N020_crossroad_T013_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N024_crossroad_N026_crossroad | E_N024_crossroad_N026_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N024_crossroad_N026_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N052_crossroad_N003_crossroad | E_N052_crossroad_N003_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N052_crossroad_N003_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N003_crossroad_N004_crossroad | E_N003_crossroad_N004_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N003_crossroad_N004_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N004_crossroad_N053_crossroad | E_N004_crossroad_N053_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N004_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N005_crossroad_N053_crossroad | E_N005_crossroad_N053_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N005_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N061_crossroad_N060_crossroad | E_N061_crossroad_N060_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N061_crossroad_N060_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N060_crossroad_T014_road_end | E_N060_crossroad_T014_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N060_crossroad_T014_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N062_crossroad_N064_crossroad | E_N062_crossroad_N064_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N062_crossroad_N064_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N062_crossroad_N063_crossroad | E_N062_crossroad_N063_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N062_crossroad_N063_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N063_crossroad_N013_crossroad | E_N063_crossroad_N013_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N063_crossroad_N013_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N063_crossroad_N064_crossroad | E_N063_crossroad_N064_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N063_crossroad_N064_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N064_crossroad_N014_crossroad | E_N064_crossroad_N014_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N064_crossroad_N014_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N064_crossroad_N017_crossroad | E_N064_crossroad_N017_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N064_crossroad_N017_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N053_crossroad_N054_crossroad | E_N053_crossroad_N054_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N053_crossroad_N054_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N054_crossroad_N012_crossroad | E_N054_crossroad_N012_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N054_crossroad_N012_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N012_crossroad_N055_crossroad | E_N012_crossroad_N055_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N012_crossroad_N055_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N055_crossroad_N059_crossroad | E_N055_crossroad_N059_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N055_crossroad_N059_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N055_crossroad_N056_crossroad | E_N055_crossroad_N056_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N055_crossroad_N056_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N056_crossroad_N010_crossroad | E_N056_crossroad_N010_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N056_crossroad_N010_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N010_crossroad_N011_crossroad | E_N010_crossroad_N011_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N010_crossroad_N011_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N008_crossroad_N011_crossroad | E_N008_crossroad_N011_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N008_crossroad_N011_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N008_crossroad_N068_crossroad | E_N008_crossroad_N068_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N008_crossroad_N068_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N068_crossroad_N053_crossroad | E_N068_crossroad_N053_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N068_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N068_crossroad_N067_crossroad | E_N068_crossroad_N067_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N068_crossroad_N067_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N067_crossroad_N054_crossroad | E_N067_crossroad_N054_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N067_crossroad_N054_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N011_crossroad_N067_crossroad | E_N011_crossroad_N067_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N011_crossroad_N067_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N009_crossroad_N057_crossroad | E_N009_crossroad_N057_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N009_crossroad_N057_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N056_crossroad_N057_crossroad | E_N056_crossroad_N057_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N056_crossroad_N057_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N057_crossroad_N058_crossroad | E_N057_crossroad_N058_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N057_crossroad_N058_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N058_crossroad_T015_road_end | E_N058_crossroad_T015_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N058_crossroad_T015_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N007_crossroad_T016_road_end | E_N007_crossroad_T016_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N007_crossroad_T016_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N066_crossroad_T017_road_end | E_N066_crossroad_T017_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N066_crossroad_T017_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N066_crossroad_T018_road_end | E_N066_crossroad_T018_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N066_crossroad_T018_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B01_S_N040_crossroad | E_B01_S_N040_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B01_S_N040_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B01_N_B01_M | E_B01_N_B01_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B01_N_B01_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B01_M_B01_S | E_B01_M_B01_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B01_M_B01_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B02_N_B02_M | E_B02_N_B02_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B02_N_B02_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B02_M_B02_S | E_B02_M_B02_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B02_M_B02_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B02_S_N037_crossroad | E_B02_S_N037_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B02_S_N037_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B03_N_B03_M | E_B03_N_B03_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B03_N_B03_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B03_M_B03_S | E_B03_M_B03_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B03_M_B03_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B03_S_N036_crossroad | E_B03_S_N036_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B03_S_N036_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B04_N_B04_M | E_B04_N_B04_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B04_N_B04_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B04_M_B04_S | E_B04_M_B04_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B04_M_B04_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B04_S_N046_crossroad | E_B04_S_N046_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B04_S_N046_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B05_N_B05_M | E_B05_N_B05_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B05_N_B05_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B05_M_B05_S | E_B05_M_B05_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B05_M_B05_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B05_S_N027_crossroad | E_B05_S_N027_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B05_S_N027_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B06_N_B06_M | E_B06_N_B06_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B06_N_B06_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B06_M_B06_S | E_B06_M_B06_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B06_M_B06_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B06_S_N025_crossroad | E_B06_S_N025_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B06_S_N025_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B07_N_B07_M | E_B07_N_B07_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B07_N_B07_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B07_M_B07_S | E_B07_M_B07_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B07_M_B07_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B07_S_N019_crossroad | E_B07_S_N019_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B07_S_N019_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B08_N_B08_M | E_B08_N_B08_M | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B08_N_B08_M; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B08_M_B08_S | E_B08_M_B08_S | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B08_M_B08_S; docs:426,427; status:planning_only |
| 12_navigation_edges | E_B08_S_N070_crossroad | E_B08_S_N070_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_B08_S_N070_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N044_crossroad_city_spawn_start | E_N044_crossroad_city_spawn_start | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N044_crossroad_city_spawn_start; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P02_access_1_N006_crossroad | E_P02_access_1_N006_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P02_access_1_N006_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N042_crossroad_P01_access_1 | E_N042_crossroad_P01_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N042_crossroad_P01_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P01_access_1_P01_entry_1 | E_P01_access_1_P01_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P01_access_1_P01_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P01_access_2_N050_crossroad | E_P01_access_2_N050_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P01_access_2_N050_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P01_access_2_P01_entry_2 | E_P01_access_2_P01_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P01_access_2_P01_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P02_access_1_P02_entry_1 | E_P02_access_1_P02_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P02_access_1_P02_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P02_access_1_N002_crossroad | E_P02_access_1_N002_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P02_access_1_N002_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N007_crossroad_P02_access_2 | E_N007_crossroad_P02_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N007_crossroad_P02_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P02_access_2_P02_entry_2 | E_P02_access_2_P02_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P02_access_2_P02_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P02_access_2_N006_crossroad | E_P02_access_2_N006_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P02_access_2_N006_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N008_crossroad_P03_access_1 | E_N008_crossroad_P03_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N008_crossroad_P03_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P03_access_1_P03_entry_1 | E_P03_access_1_P03_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P03_access_1_P03_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P03_access_1_N006_crossroad | E_P03_access_1_N006_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P03_access_1_N006_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N066_crossroad_P03_access_2 | E_N066_crossroad_P03_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N066_crossroad_P03_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P03_access_2_P03_entry_2 | E_P03_access_2_P03_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P03_access_2_P03_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N007_crossroad_P03_access_2 | E_N007_crossroad_P03_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N007_crossroad_P03_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N059_crossroad_P04_access_1 | E_N059_crossroad_P04_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N059_crossroad_P04_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P04_access_1_P04_entry_1 | E_P04_access_1_P04_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P04_access_1_P04_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P04_access_1_N060_crossroad | E_P04_access_1_N060_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P04_access_1_N060_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N060_crossroad_P05_access_1 | E_N060_crossroad_P05_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N060_crossroad_P05_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P05_access_1_P05_entry_1 | E_P05_access_1_P05_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P05_access_1_P05_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P05_access_1_T019_road_end | E_P05_access_1_T019_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P05_access_1_T019_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N061_crossroad_P05_access_2 | E_N061_crossroad_P05_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N061_crossroad_P05_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P05_access_2_P05_entry_2 | E_P05_access_2_P05_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P05_access_2_P05_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P05_access_2_N073_crossroad | E_P05_access_2_N073_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P05_access_2_N073_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N062_crossroad_P06_access_2 | E_N062_crossroad_P06_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N062_crossroad_P06_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P06_access_2_P06_entry_2 | E_P06_access_2_P06_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P06_access_2_P06_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P06_access_2_N061_crossroad | E_P06_access_2_N061_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P06_access_2_N061_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N017_crossroad_P06_access_1 | E_N017_crossroad_P06_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N017_crossroad_P06_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P06_access_1_P06_entry_1 | E_P06_access_1_P06_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P06_access_1_P06_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P06_access_1_N073_crossroad | E_P06_access_1_N073_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P06_access_1_N073_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N017_crossroad_P07_access_1 | E_N017_crossroad_P07_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N017_crossroad_P07_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P07_access_1_P07_entry_1 | E_P07_access_1_P07_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P07_access_1_P07_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P07_access_1_N016_crossroad | E_P07_access_1_N016_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P07_access_1_N016_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N018_crossroad_P07_access_2 | E_N018_crossroad_P07_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N018_crossroad_P07_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P07_access_2_P07_entry_2 | E_P07_access_2_P07_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P07_access_2_P07_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P07_access_2_T020_road_end | E_P07_access_2_T020_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P07_access_2_T020_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N019_crossroad_P08_access_1 | E_N019_crossroad_P08_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N019_crossroad_P08_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P08_access_1_P08_entry_1 | E_P08_access_1_P08_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P08_access_1_P08_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P08_access_1_N020_crossroad | E_P08_access_1_N020_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P08_access_1_N020_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N023_crossroad_P08_access_2 | E_N023_crossroad_P08_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N023_crossroad_P08_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P08_access_2_P08_entry_2 | E_P08_access_2_P08_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P08_access_2_P08_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P08_access_2_N022_crossroad | E_P08_access_2_N022_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P08_access_2_N022_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N028_crossroad_P09_access_2 | E_N028_crossroad_P09_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N028_crossroad_P09_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P09_access_2_P09_entry_2 | E_P09_access_2_P09_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P09_access_2_P09_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P09_access_2_N026_crossroad | E_P09_access_2_N026_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P09_access_2_N026_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N024_crossroad_P09_access_1 | E_N024_crossroad_P09_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N024_crossroad_P09_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P09_access_1_P09_entry_1 | E_P09_access_1_P09_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P09_access_1_P09_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P09_access_1_N023_crossroad | E_P09_access_1_N023_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P09_access_1_N023_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N030_crossroad_P10_access_1 | E_N030_crossroad_P10_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N030_crossroad_P10_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P10_access_1_P10_entry_1 | E_P10_access_1_P10_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P10_access_1_P10_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P10_access_1_T021_road_end | E_P10_access_1_T021_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P10_access_1_T021_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N065_crossroad_P10_access_2 | E_N065_crossroad_P10_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N065_crossroad_P10_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P10_access_2_P10_entry_2 | E_P10_access_2_P10_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P10_access_2_P10_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P10_access_2_T022_road_end | E_P10_access_2_T022_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P10_access_2_T022_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N039_crossroad_P12_access_1 | E_N039_crossroad_P12_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N039_crossroad_P12_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P12_access_1_P12_entry_1 | E_P12_access_1_P12_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P12_access_1_P12_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P12_access_1_N034_crossroad | E_P12_access_1_N034_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P12_access_1_N034_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N038_crossroad_P12_access_2 | E_N038_crossroad_P12_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N038_crossroad_P12_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P12_access_2_P12_entry_2 | E_P12_access_2_P12_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P12_access_2_P12_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P12_access_2_T023_road_end | E_P12_access_2_T023_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P12_access_2_T023_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N032_crossroad_P13_access_2 | E_N032_crossroad_P13_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N032_crossroad_P13_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P13_access_2_P13_entry_2 | E_P13_access_2_P13_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P13_access_2_P13_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N046_crossroad_P13_access_1 | E_N046_crossroad_P13_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N046_crossroad_P13_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P13_access_1_P13_entry_1 | E_P13_access_1_P13_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P13_access_1_P13_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P13_access_1_N035_crossroad | E_P13_access_1_N035_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P13_access_1_N035_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N002_crossroad_P14_access_1 | E_N002_crossroad_P14_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N002_crossroad_P14_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P14_access_1_P14_entry_1 | E_P14_access_1_P14_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P14_access_1_P14_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P14_access_1_N003_crossroad | E_P14_access_1_N003_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P14_access_1_N003_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N058_crossroad_P04_access_2 | E_N058_crossroad_P04_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N058_crossroad_P04_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P04_access_2_P04_entry_2 | E_P04_access_2_P04_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P04_access_2_P04_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P04_access_2_T024_road_end | E_P04_access_2_T024_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P04_access_2_T024_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N052_crossroad_P14_access_2 | E_N052_crossroad_P14_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N052_crossroad_P14_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P14_access_2_P14_entry_2 | E_P14_access_2_P14_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P14_access_2_P14_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P14_access_2_N045_crossroad | E_P14_access_2_N045_crossroad | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P14_access_2_N045_crossroad; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P11_access_2_P11_entry_2 | E_P11_access_2_P11_entry_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P11_access_2_P11_entry_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P11_access_1_P11_entry_1 | E_P11_access_1_P11_entry_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P11_access_1_P11_entry_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N039_crossroad_P11_access_1 | E_N039_crossroad_P11_access_1 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N039_crossroad_P11_access_1; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P11_access_1_T025_road_end | E_P11_access_1_T025_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P11_access_1_T025_road_end; docs:426,427; status:planning_only |
| 12_navigation_edges | E_N039_crossroad_P11_access_2 | E_N039_crossroad_P11_access_2 | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_N039_crossroad_P11_access_2; docs:426,427; status:planning_only |
| 12_navigation_edges | E_P11_access_2_T026_road_end | E_P11_access_2_T026_road_end | Navigation Edges | topology_edge_candidate | candidate_only | false | false | false | true | svg:12_navigation_edges/E_P11_access_2_T026_road_end; docs:426,427; status:planning_only |

## 6. Topology Registry

Edge-Endpunkte werden ausschliesslich aus `E_<from>_<to>`-IDs abgeleitet. Es werden keine Koordinaten, Weglaengen, Gewichte oder Runtime-Adjacency erzeugt.

### 6.1 Edge Endpoint Registry

| edge_id | graph_from | graph_to | planning_status | needs_review | blocked_for_runtime | source_trace |
| --- | --- | --- | --- | --- | --- | --- |
| E_city_spawn_start_N001_crossroad | city_spawn_start | N001_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_city_spawn_start_N001_crossroad; docs:426,427; status:planning_only |
| E_N001_crossroad_N002_crossroad | N001_crossroad | N002_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N001_crossroad_N002_crossroad; docs:426,427; status:planning_only |
| E_N002_crossroad_N045_crossroad | N002_crossroad | N045_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N002_crossroad_N045_crossroad; docs:426,427; status:planning_only |
| E_N001_crossroad_N043_crossroad | N001_crossroad | N043_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N001_crossroad_N043_crossroad; docs:426,427; status:planning_only |
| E_N001_crossroad_T001_road_end | N001_crossroad | T001_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N001_crossroad_T001_road_end; docs:426,427; status:planning_only |
| E_N007_crossroad_T002_road_end | N007_crossroad | T002_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N007_crossroad_T002_road_end; docs:426,427; status:planning_only |
| E_N006_crossroad_N004_crossroad | N006_crossroad | N004_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N006_crossroad_N004_crossroad; docs:426,427; status:planning_only |
| E_N004_crossroad_N005_crossroad | N004_crossroad | N005_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N004_crossroad_N005_crossroad; docs:426,427; status:planning_only |
| E_N005_crossroad_N047_crossroad | N005_crossroad | N047_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N005_crossroad_N047_crossroad; docs:426,427; status:planning_only |
| E_N010_crossroad_N012_crossroad | N010_crossroad | N012_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N010_crossroad_N012_crossroad; docs:426,427; status:planning_only |
| E_N012_crossroad_N013_crossroad | N012_crossroad | N013_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N012_crossroad_N013_crossroad; docs:426,427; status:planning_only |
| E_N013_crossroad_N014_crossroad | N013_crossroad | N014_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N013_crossroad_N014_crossroad; docs:426,427; status:planning_only |
| E_N014_crossroad_N015_crossroad | N014_crossroad | N015_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N014_crossroad_N015_crossroad; docs:426,427; status:planning_only |
| E_N013_crossroad_N059_crossroad | N013_crossroad | N059_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N013_crossroad_N059_crossroad; docs:426,427; status:planning_only |
| E_N008_crossroad_N009_crossroad | N008_crossroad | N009_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N008_crossroad_N009_crossroad; docs:426,427; status:planning_only |
| E_N005_crossroad_D001_internal_road_end | N005_crossroad | D001_internal_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N005_crossroad_D001_internal_road_end; docs:426,427; status:planning_only |
| E_N009_crossroad_T003_road_end | N009_crossroad | T003_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N009_crossroad_T003_road_end; docs:426,427; status:planning_only |
| E_N043_crossroad_B01_N | N043_crossroad | B01_N | candidate_only | false | true | svg:12_navigation_edges/E_N043_crossroad_B01_N; docs:426,427; status:planning_only |
| E_N040_crossroad_T004_road_end | N040_crossroad | T004_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N040_crossroad_T004_road_end; docs:426,427; status:planning_only |
| E_N045_crossroad_B02_N | N045_crossroad | B02_N | candidate_only | false | true | svg:12_navigation_edges/E_N045_crossroad_B02_N; docs:426,427; status:planning_only |
| E_N037_crossroad_N038_crossroad | N037_crossroad | N038_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N037_crossroad_N038_crossroad; docs:426,427; status:planning_only |
| E_N038_crossroad_N034_crossroad | N038_crossroad | N034_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N038_crossroad_N034_crossroad; docs:426,427; status:planning_only |
| E_N034_crossroad_N033_crossroad | N034_crossroad | N033_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N034_crossroad_N033_crossroad; docs:426,427; status:planning_only |
| E_N052_crossroad_B03_N | N052_crossroad | B03_N | candidate_only | false | true | svg:12_navigation_edges/E_N052_crossroad_B03_N; docs:426,427; status:planning_only |
| E_N036_crossroad_N035_crossroad | N036_crossroad | N035_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N036_crossroad_N035_crossroad; docs:426,427; status:planning_only |
| E_N035_crossroad_N033_crossroad | N035_crossroad | N033_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N035_crossroad_N033_crossroad; docs:426,427; status:planning_only |
| E_N033_crossroad_N032_crossroad | N033_crossroad | N032_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N033_crossroad_N032_crossroad; docs:426,427; status:planning_only |
| E_N032_crossroad_N031_crossroad | N032_crossroad | N031_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N032_crossroad_N031_crossroad; docs:426,427; status:planning_only |
| E_N031_crossroad_N030_crossroad | N031_crossroad | N030_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N031_crossroad_N030_crossroad; docs:426,427; status:planning_only |
| E_N015_crossroad_B05_N | N015_crossroad | B05_N | candidate_only | false | true | svg:12_navigation_edges/E_N015_crossroad_B05_N; docs:426,427; status:planning_only |
| E_N027_crossroad_N026_crossroad | N027_crossroad | N026_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N027_crossroad_N026_crossroad; docs:426,427; status:planning_only |
| E_N028_crossroad_N029_crossroad | N028_crossroad | N029_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N028_crossroad_N029_crossroad; docs:426,427; status:planning_only |
| E_N029_crossroad_N030_crossroad | N029_crossroad | N030_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N029_crossroad_N030_crossroad; docs:426,427; status:planning_only |
| E_N047_crossroad_B04_N | N047_crossroad | B04_N | candidate_only | false | true | svg:12_navigation_edges/E_N047_crossroad_B04_N; docs:426,427; status:planning_only |
| E_N016_crossroad_B06_N | N016_crossroad | B06_N | candidate_only | false | true | svg:12_navigation_edges/E_N016_crossroad_B06_N; docs:426,427; status:planning_only |
| E_N025_crossroad_N024_crossroad | N025_crossroad | N024_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N025_crossroad_N024_crossroad; docs:426,427; status:planning_only |
| E_N022_crossroad_N021_crossroad | N022_crossroad | N021_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N022_crossroad_N021_crossroad; docs:426,427; status:planning_only |
| E_N021_crossroad_T005_road_end | N021_crossroad | T005_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N021_crossroad_T005_road_end; docs:426,427; status:planning_only |
| E_N021_crossroad_N020_crossroad | N021_crossroad | N020_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N021_crossroad_N020_crossroad; docs:426,427; status:planning_only |
| E_B07_N_N018_crossroad | B07_N | N018_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B07_N_N018_crossroad; docs:426,427; status:planning_only |
| E_N044_crossroad_N041_crossroad | N044_crossroad | N041_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N044_crossroad_N041_crossroad; docs:426,427; status:planning_only |
| E_N041_crossroad_T006_road_end | N041_crossroad | T006_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N041_crossroad_T006_road_end; docs:426,427; status:planning_only |
| E_N044_crossroad_N042_crossroad | N044_crossroad | N042_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N044_crossroad_N042_crossroad; docs:426,427; status:planning_only |
| E_N041_crossroad_N042_crossroad | N041_crossroad | N042_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N041_crossroad_N042_crossroad; docs:426,427; status:planning_only |
| E_N042_crossroad_N051_crossroad | N042_crossroad | N051_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N042_crossroad_N051_crossroad; docs:426,427; status:planning_only |
| E_N051_crossroad_P01_access_2 | N051_crossroad | P01_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N051_crossroad_P01_access_2; docs:426,427; status:planning_only |
| E_N050_crossroad_T007_road_end | N050_crossroad | T007_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N050_crossroad_T007_road_end; docs:426,427; status:planning_only |
| E_N051_crossroad_N043_crossroad | N051_crossroad | N043_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N051_crossroad_N043_crossroad; docs:426,427; status:planning_only |
| E_N043_crossroad_N045_crossroad | N043_crossroad | N045_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N043_crossroad_N045_crossroad; docs:426,427; status:planning_only |
| E_N052_crossroad_N047_crossroad | N052_crossroad | N047_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N052_crossroad_N047_crossroad; docs:426,427; status:planning_only |
| E_N047_crossroad_N071_crossroad | N047_crossroad | N071_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N047_crossroad_N071_crossroad; docs:426,427; status:planning_only |
| E_N071_crossroad_N015_crossroad | N071_crossroad | N015_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N071_crossroad_N015_crossroad; docs:426,427; status:planning_only |
| E_N015_crossroad_N016_crossroad | N015_crossroad | N016_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N015_crossroad_N016_crossroad; docs:426,427; status:planning_only |
| E_N016_crossroad_N018_crossroad | N016_crossroad | N018_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N016_crossroad_N018_crossroad; docs:426,427; status:planning_only |
| E_N018_crossroad_T008_road_end | N018_crossroad | T008_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N018_crossroad_T008_road_end; docs:426,427; status:planning_only |
| E_N019_crossroad_T009_road_end | N019_crossroad | T009_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N019_crossroad_T009_road_end; docs:426,427; status:planning_only |
| E_N019_crossroad_N074_crossroad | N019_crossroad | N074_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N019_crossroad_N074_crossroad; docs:426,427; status:planning_only |
| E_N074_crossroad_N023_crossroad | N074_crossroad | N023_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N074_crossroad_N023_crossroad; docs:426,427; status:planning_only |
| E_N074_crossroad_N025_crossroad | N074_crossroad | N025_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N074_crossroad_N025_crossroad; docs:426,427; status:planning_only |
| E_N025_crossroad_N027_crossroad | N025_crossroad | N027_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N025_crossroad_N027_crossroad; docs:426,427; status:planning_only |
| E_N027_crossroad_N070_crossroad | N027_crossroad | N070_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N027_crossroad_N070_crossroad; docs:426,427; status:planning_only |
| E_B08_N_N071_crossroad | B08_N | N071_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B08_N_N071_crossroad; docs:426,427; status:planning_only |
| E_N070_crossroad_N069_crossroad | N070_crossroad | N069_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N070_crossroad_N069_crossroad; docs:426,427; status:planning_only |
| E_N069_crossroad_N028_crossroad | N069_crossroad | N028_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N069_crossroad_N028_crossroad; docs:426,427; status:planning_only |
| E_N028_crossroad_T010_road_end | N028_crossroad | T010_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N028_crossroad_T010_road_end; docs:426,427; status:planning_only |
| E_N069_crossroad_N072_crossroad | N069_crossroad | N072_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N069_crossroad_N072_crossroad; docs:426,427; status:planning_only |
| E_N072_crossroad_N048_crossroad | N072_crossroad | N048_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N072_crossroad_N048_crossroad; docs:426,427; status:planning_only |
| E_N048_crossroad_N029_crossroad | N048_crossroad | N029_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N048_crossroad_N029_crossroad; docs:426,427; status:planning_only |
| E_N029_crossroad_N065_crossroad | N029_crossroad | N065_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N029_crossroad_N065_crossroad; docs:426,427; status:planning_only |
| E_N065_crossroad_T011_road_end | N065_crossroad | T011_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N065_crossroad_T011_road_end; docs:426,427; status:planning_only |
| E_N048_crossroad_N049_crossroad | N048_crossroad | N049_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N048_crossroad_N049_crossroad; docs:426,427; status:planning_only |
| E_N049_crossroad_N031_crossroad | N049_crossroad | N031_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N049_crossroad_N031_crossroad; docs:426,427; status:planning_only |
| E_N049_crossroad_N072_crossroad | N049_crossroad | N072_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N049_crossroad_N072_crossroad; docs:426,427; status:planning_only |
| E_N032_crossroad_T012_road_end | N032_crossroad | T012_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N032_crossroad_T012_road_end; docs:426,427; status:planning_only |
| E_N038_crossroad_N035_crossroad | N038_crossroad | N035_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N038_crossroad_N035_crossroad; docs:426,427; status:planning_only |
| E_N046_crossroad_N070_crossroad | N046_crossroad | N070_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N046_crossroad_N070_crossroad; docs:426,427; status:planning_only |
| E_N046_crossroad_N036_crossroad | N046_crossroad | N036_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N046_crossroad_N036_crossroad; docs:426,427; status:planning_only |
| E_N036_crossroad_N037_crossroad | N036_crossroad | N037_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N036_crossroad_N037_crossroad; docs:426,427; status:planning_only |
| E_N037_crossroad_N040_crossroad | N037_crossroad | N040_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N037_crossroad_N040_crossroad; docs:426,427; status:planning_only |
| E_N040_crossroad_N050_crossroad | N040_crossroad | N050_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N040_crossroad_N050_crossroad; docs:426,427; status:planning_only |
| E_N022_crossroad_N020_crossroad | N022_crossroad | N020_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N022_crossroad_N020_crossroad; docs:426,427; status:planning_only |
| E_N020_crossroad_T013_road_end | N020_crossroad | T013_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N020_crossroad_T013_road_end; docs:426,427; status:planning_only |
| E_N024_crossroad_N026_crossroad | N024_crossroad | N026_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N024_crossroad_N026_crossroad; docs:426,427; status:planning_only |
| E_N052_crossroad_N003_crossroad | N052_crossroad | N003_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N052_crossroad_N003_crossroad; docs:426,427; status:planning_only |
| E_N003_crossroad_N004_crossroad | N003_crossroad | N004_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N003_crossroad_N004_crossroad; docs:426,427; status:planning_only |
| E_N004_crossroad_N053_crossroad | N004_crossroad | N053_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N004_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| E_N005_crossroad_N053_crossroad | N005_crossroad | N053_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N005_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| E_N061_crossroad_N060_crossroad | N061_crossroad | N060_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N061_crossroad_N060_crossroad; docs:426,427; status:planning_only |
| E_N060_crossroad_T014_road_end | N060_crossroad | T014_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N060_crossroad_T014_road_end; docs:426,427; status:planning_only |
| E_N062_crossroad_N064_crossroad | N062_crossroad | N064_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N062_crossroad_N064_crossroad; docs:426,427; status:planning_only |
| E_N062_crossroad_N063_crossroad | N062_crossroad | N063_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N062_crossroad_N063_crossroad; docs:426,427; status:planning_only |
| E_N063_crossroad_N013_crossroad | N063_crossroad | N013_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N063_crossroad_N013_crossroad; docs:426,427; status:planning_only |
| E_N063_crossroad_N064_crossroad | N063_crossroad | N064_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N063_crossroad_N064_crossroad; docs:426,427; status:planning_only |
| E_N064_crossroad_N014_crossroad | N064_crossroad | N014_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N064_crossroad_N014_crossroad; docs:426,427; status:planning_only |
| E_N064_crossroad_N017_crossroad | N064_crossroad | N017_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N064_crossroad_N017_crossroad; docs:426,427; status:planning_only |
| E_N053_crossroad_N054_crossroad | N053_crossroad | N054_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N053_crossroad_N054_crossroad; docs:426,427; status:planning_only |
| E_N054_crossroad_N012_crossroad | N054_crossroad | N012_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N054_crossroad_N012_crossroad; docs:426,427; status:planning_only |
| E_N012_crossroad_N055_crossroad | N012_crossroad | N055_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N012_crossroad_N055_crossroad; docs:426,427; status:planning_only |
| E_N055_crossroad_N059_crossroad | N055_crossroad | N059_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N055_crossroad_N059_crossroad; docs:426,427; status:planning_only |
| E_N055_crossroad_N056_crossroad | N055_crossroad | N056_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N055_crossroad_N056_crossroad; docs:426,427; status:planning_only |
| E_N056_crossroad_N010_crossroad | N056_crossroad | N010_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N056_crossroad_N010_crossroad; docs:426,427; status:planning_only |
| E_N010_crossroad_N011_crossroad | N010_crossroad | N011_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N010_crossroad_N011_crossroad; docs:426,427; status:planning_only |
| E_N008_crossroad_N011_crossroad | N008_crossroad | N011_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N008_crossroad_N011_crossroad; docs:426,427; status:planning_only |
| E_N008_crossroad_N068_crossroad | N008_crossroad | N068_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N008_crossroad_N068_crossroad; docs:426,427; status:planning_only |
| E_N068_crossroad_N053_crossroad | N068_crossroad | N053_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N068_crossroad_N053_crossroad; docs:426,427; status:planning_only |
| E_N068_crossroad_N067_crossroad | N068_crossroad | N067_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N068_crossroad_N067_crossroad; docs:426,427; status:planning_only |
| E_N067_crossroad_N054_crossroad | N067_crossroad | N054_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N067_crossroad_N054_crossroad; docs:426,427; status:planning_only |
| E_N011_crossroad_N067_crossroad | N011_crossroad | N067_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N011_crossroad_N067_crossroad; docs:426,427; status:planning_only |
| E_N009_crossroad_N057_crossroad | N009_crossroad | N057_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N009_crossroad_N057_crossroad; docs:426,427; status:planning_only |
| E_N056_crossroad_N057_crossroad | N056_crossroad | N057_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N056_crossroad_N057_crossroad; docs:426,427; status:planning_only |
| E_N057_crossroad_N058_crossroad | N057_crossroad | N058_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_N057_crossroad_N058_crossroad; docs:426,427; status:planning_only |
| E_N058_crossroad_T015_road_end | N058_crossroad | T015_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N058_crossroad_T015_road_end; docs:426,427; status:planning_only |
| E_N007_crossroad_T016_road_end | N007_crossroad | T016_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N007_crossroad_T016_road_end; docs:426,427; status:planning_only |
| E_N066_crossroad_T017_road_end | N066_crossroad | T017_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N066_crossroad_T017_road_end; docs:426,427; status:planning_only |
| E_N066_crossroad_T018_road_end | N066_crossroad | T018_road_end | candidate_only | false | true | svg:12_navigation_edges/E_N066_crossroad_T018_road_end; docs:426,427; status:planning_only |
| E_B01_S_N040_crossroad | B01_S | N040_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B01_S_N040_crossroad; docs:426,427; status:planning_only |
| E_B01_N_B01_M | B01_N | B01_M | candidate_only | false | true | svg:12_navigation_edges/E_B01_N_B01_M; docs:426,427; status:planning_only |
| E_B01_M_B01_S | B01_M | B01_S | candidate_only | false | true | svg:12_navigation_edges/E_B01_M_B01_S; docs:426,427; status:planning_only |
| E_B02_N_B02_M | B02_N | B02_M | candidate_only | false | true | svg:12_navigation_edges/E_B02_N_B02_M; docs:426,427; status:planning_only |
| E_B02_M_B02_S | B02_M | B02_S | candidate_only | false | true | svg:12_navigation_edges/E_B02_M_B02_S; docs:426,427; status:planning_only |
| E_B02_S_N037_crossroad | B02_S | N037_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B02_S_N037_crossroad; docs:426,427; status:planning_only |
| E_B03_N_B03_M | B03_N | B03_M | candidate_only | false | true | svg:12_navigation_edges/E_B03_N_B03_M; docs:426,427; status:planning_only |
| E_B03_M_B03_S | B03_M | B03_S | candidate_only | false | true | svg:12_navigation_edges/E_B03_M_B03_S; docs:426,427; status:planning_only |
| E_B03_S_N036_crossroad | B03_S | N036_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B03_S_N036_crossroad; docs:426,427; status:planning_only |
| E_B04_N_B04_M | B04_N | B04_M | candidate_only | false | true | svg:12_navigation_edges/E_B04_N_B04_M; docs:426,427; status:planning_only |
| E_B04_M_B04_S | B04_M | B04_S | candidate_only | false | true | svg:12_navigation_edges/E_B04_M_B04_S; docs:426,427; status:planning_only |
| E_B04_S_N046_crossroad | B04_S | N046_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B04_S_N046_crossroad; docs:426,427; status:planning_only |
| E_B05_N_B05_M | B05_N | B05_M | candidate_only | false | true | svg:12_navigation_edges/E_B05_N_B05_M; docs:426,427; status:planning_only |
| E_B05_M_B05_S | B05_M | B05_S | candidate_only | false | true | svg:12_navigation_edges/E_B05_M_B05_S; docs:426,427; status:planning_only |
| E_B05_S_N027_crossroad | B05_S | N027_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B05_S_N027_crossroad; docs:426,427; status:planning_only |
| E_B06_N_B06_M | B06_N | B06_M | candidate_only | false | true | svg:12_navigation_edges/E_B06_N_B06_M; docs:426,427; status:planning_only |
| E_B06_M_B06_S | B06_M | B06_S | candidate_only | false | true | svg:12_navigation_edges/E_B06_M_B06_S; docs:426,427; status:planning_only |
| E_B06_S_N025_crossroad | B06_S | N025_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B06_S_N025_crossroad; docs:426,427; status:planning_only |
| E_B07_N_B07_M | B07_N | B07_M | candidate_only | false | true | svg:12_navigation_edges/E_B07_N_B07_M; docs:426,427; status:planning_only |
| E_B07_M_B07_S | B07_M | B07_S | candidate_only | false | true | svg:12_navigation_edges/E_B07_M_B07_S; docs:426,427; status:planning_only |
| E_B07_S_N019_crossroad | B07_S | N019_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B07_S_N019_crossroad; docs:426,427; status:planning_only |
| E_B08_N_B08_M | B08_N | B08_M | candidate_only | false | true | svg:12_navigation_edges/E_B08_N_B08_M; docs:426,427; status:planning_only |
| E_B08_M_B08_S | B08_M | B08_S | candidate_only | false | true | svg:12_navigation_edges/E_B08_M_B08_S; docs:426,427; status:planning_only |
| E_B08_S_N070_crossroad | B08_S | N070_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_B08_S_N070_crossroad; docs:426,427; status:planning_only |
| E_N044_crossroad_city_spawn_start | N044_crossroad | city_spawn_start | candidate_only | false | true | svg:12_navigation_edges/E_N044_crossroad_city_spawn_start; docs:426,427; status:planning_only |
| E_P02_access_1_N006_crossroad | P02_access_1 | N006_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P02_access_1_N006_crossroad; docs:426,427; status:planning_only |
| E_N042_crossroad_P01_access_1 | N042_crossroad | P01_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N042_crossroad_P01_access_1; docs:426,427; status:planning_only |
| E_P01_access_1_P01_entry_1 | P01_access_1 | P01_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P01_access_1_P01_entry_1; docs:426,427; status:planning_only |
| E_P01_access_2_N050_crossroad | P01_access_2 | N050_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P01_access_2_N050_crossroad; docs:426,427; status:planning_only |
| E_P01_access_2_P01_entry_2 | P01_access_2 | P01_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P01_access_2_P01_entry_2; docs:426,427; status:planning_only |
| E_P02_access_1_P02_entry_1 | P02_access_1 | P02_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P02_access_1_P02_entry_1; docs:426,427; status:planning_only |
| E_P02_access_1_N002_crossroad | P02_access_1 | N002_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P02_access_1_N002_crossroad; docs:426,427; status:planning_only |
| E_N007_crossroad_P02_access_2 | N007_crossroad | P02_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N007_crossroad_P02_access_2; docs:426,427; status:planning_only |
| E_P02_access_2_P02_entry_2 | P02_access_2 | P02_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P02_access_2_P02_entry_2; docs:426,427; status:planning_only |
| E_P02_access_2_N006_crossroad | P02_access_2 | N006_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P02_access_2_N006_crossroad; docs:426,427; status:planning_only |
| E_N008_crossroad_P03_access_1 | N008_crossroad | P03_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N008_crossroad_P03_access_1; docs:426,427; status:planning_only |
| E_P03_access_1_P03_entry_1 | P03_access_1 | P03_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P03_access_1_P03_entry_1; docs:426,427; status:planning_only |
| E_P03_access_1_N006_crossroad | P03_access_1 | N006_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P03_access_1_N006_crossroad; docs:426,427; status:planning_only |
| E_N066_crossroad_P03_access_2 | N066_crossroad | P03_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N066_crossroad_P03_access_2; docs:426,427; status:planning_only |
| E_P03_access_2_P03_entry_2 | P03_access_2 | P03_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P03_access_2_P03_entry_2; docs:426,427; status:planning_only |
| E_N007_crossroad_P03_access_2 | N007_crossroad | P03_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N007_crossroad_P03_access_2; docs:426,427; status:planning_only |
| E_N059_crossroad_P04_access_1 | N059_crossroad | P04_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N059_crossroad_P04_access_1; docs:426,427; status:planning_only |
| E_P04_access_1_P04_entry_1 | P04_access_1 | P04_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P04_access_1_P04_entry_1; docs:426,427; status:planning_only |
| E_P04_access_1_N060_crossroad | P04_access_1 | N060_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P04_access_1_N060_crossroad; docs:426,427; status:planning_only |
| E_N060_crossroad_P05_access_1 | N060_crossroad | P05_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N060_crossroad_P05_access_1; docs:426,427; status:planning_only |
| E_P05_access_1_P05_entry_1 | P05_access_1 | P05_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P05_access_1_P05_entry_1; docs:426,427; status:planning_only |
| E_P05_access_1_T019_road_end | P05_access_1 | T019_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P05_access_1_T019_road_end; docs:426,427; status:planning_only |
| E_N061_crossroad_P05_access_2 | N061_crossroad | P05_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N061_crossroad_P05_access_2; docs:426,427; status:planning_only |
| E_P05_access_2_P05_entry_2 | P05_access_2 | P05_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P05_access_2_P05_entry_2; docs:426,427; status:planning_only |
| E_P05_access_2_N073_crossroad | P05_access_2 | N073_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P05_access_2_N073_crossroad; docs:426,427; status:planning_only |
| E_N062_crossroad_P06_access_2 | N062_crossroad | P06_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N062_crossroad_P06_access_2; docs:426,427; status:planning_only |
| E_P06_access_2_P06_entry_2 | P06_access_2 | P06_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P06_access_2_P06_entry_2; docs:426,427; status:planning_only |
| E_P06_access_2_N061_crossroad | P06_access_2 | N061_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P06_access_2_N061_crossroad; docs:426,427; status:planning_only |
| E_N017_crossroad_P06_access_1 | N017_crossroad | P06_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N017_crossroad_P06_access_1; docs:426,427; status:planning_only |
| E_P06_access_1_P06_entry_1 | P06_access_1 | P06_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P06_access_1_P06_entry_1; docs:426,427; status:planning_only |
| E_P06_access_1_N073_crossroad | P06_access_1 | N073_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P06_access_1_N073_crossroad; docs:426,427; status:planning_only |
| E_N017_crossroad_P07_access_1 | N017_crossroad | P07_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N017_crossroad_P07_access_1; docs:426,427; status:planning_only |
| E_P07_access_1_P07_entry_1 | P07_access_1 | P07_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P07_access_1_P07_entry_1; docs:426,427; status:planning_only |
| E_P07_access_1_N016_crossroad | P07_access_1 | N016_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P07_access_1_N016_crossroad; docs:426,427; status:planning_only |
| E_N018_crossroad_P07_access_2 | N018_crossroad | P07_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N018_crossroad_P07_access_2; docs:426,427; status:planning_only |
| E_P07_access_2_P07_entry_2 | P07_access_2 | P07_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P07_access_2_P07_entry_2; docs:426,427; status:planning_only |
| E_P07_access_2_T020_road_end | P07_access_2 | T020_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P07_access_2_T020_road_end; docs:426,427; status:planning_only |
| E_N019_crossroad_P08_access_1 | N019_crossroad | P08_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N019_crossroad_P08_access_1; docs:426,427; status:planning_only |
| E_P08_access_1_P08_entry_1 | P08_access_1 | P08_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P08_access_1_P08_entry_1; docs:426,427; status:planning_only |
| E_P08_access_1_N020_crossroad | P08_access_1 | N020_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P08_access_1_N020_crossroad; docs:426,427; status:planning_only |
| E_N023_crossroad_P08_access_2 | N023_crossroad | P08_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N023_crossroad_P08_access_2; docs:426,427; status:planning_only |
| E_P08_access_2_P08_entry_2 | P08_access_2 | P08_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P08_access_2_P08_entry_2; docs:426,427; status:planning_only |
| E_P08_access_2_N022_crossroad | P08_access_2 | N022_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P08_access_2_N022_crossroad; docs:426,427; status:planning_only |
| E_N028_crossroad_P09_access_2 | N028_crossroad | P09_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N028_crossroad_P09_access_2; docs:426,427; status:planning_only |
| E_P09_access_2_P09_entry_2 | P09_access_2 | P09_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P09_access_2_P09_entry_2; docs:426,427; status:planning_only |
| E_P09_access_2_N026_crossroad | P09_access_2 | N026_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P09_access_2_N026_crossroad; docs:426,427; status:planning_only |
| E_N024_crossroad_P09_access_1 | N024_crossroad | P09_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N024_crossroad_P09_access_1; docs:426,427; status:planning_only |
| E_P09_access_1_P09_entry_1 | P09_access_1 | P09_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P09_access_1_P09_entry_1; docs:426,427; status:planning_only |
| E_P09_access_1_N023_crossroad | P09_access_1 | N023_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P09_access_1_N023_crossroad; docs:426,427; status:planning_only |
| E_N030_crossroad_P10_access_1 | N030_crossroad | P10_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N030_crossroad_P10_access_1; docs:426,427; status:planning_only |
| E_P10_access_1_P10_entry_1 | P10_access_1 | P10_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P10_access_1_P10_entry_1; docs:426,427; status:planning_only |
| E_P10_access_1_T021_road_end | P10_access_1 | T021_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P10_access_1_T021_road_end; docs:426,427; status:planning_only |
| E_N065_crossroad_P10_access_2 | N065_crossroad | P10_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N065_crossroad_P10_access_2; docs:426,427; status:planning_only |
| E_P10_access_2_P10_entry_2 | P10_access_2 | P10_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P10_access_2_P10_entry_2; docs:426,427; status:planning_only |
| E_P10_access_2_T022_road_end | P10_access_2 | T022_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P10_access_2_T022_road_end; docs:426,427; status:planning_only |
| E_N039_crossroad_P12_access_1 | N039_crossroad | P12_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N039_crossroad_P12_access_1; docs:426,427; status:planning_only |
| E_P12_access_1_P12_entry_1 | P12_access_1 | P12_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P12_access_1_P12_entry_1; docs:426,427; status:planning_only |
| E_P12_access_1_N034_crossroad | P12_access_1 | N034_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P12_access_1_N034_crossroad; docs:426,427; status:planning_only |
| E_N038_crossroad_P12_access_2 | N038_crossroad | P12_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N038_crossroad_P12_access_2; docs:426,427; status:planning_only |
| E_P12_access_2_P12_entry_2 | P12_access_2 | P12_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P12_access_2_P12_entry_2; docs:426,427; status:planning_only |
| E_P12_access_2_T023_road_end | P12_access_2 | T023_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P12_access_2_T023_road_end; docs:426,427; status:planning_only |
| E_N032_crossroad_P13_access_2 | N032_crossroad | P13_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N032_crossroad_P13_access_2; docs:426,427; status:planning_only |
| E_P13_access_2_P13_entry_2 | P13_access_2 | P13_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P13_access_2_P13_entry_2; docs:426,427; status:planning_only |
| E_N046_crossroad_P13_access_1 | N046_crossroad | P13_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N046_crossroad_P13_access_1; docs:426,427; status:planning_only |
| E_P13_access_1_P13_entry_1 | P13_access_1 | P13_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P13_access_1_P13_entry_1; docs:426,427; status:planning_only |
| E_P13_access_1_N035_crossroad | P13_access_1 | N035_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P13_access_1_N035_crossroad; docs:426,427; status:planning_only |
| E_N002_crossroad_P14_access_1 | N002_crossroad | P14_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N002_crossroad_P14_access_1; docs:426,427; status:planning_only |
| E_P14_access_1_P14_entry_1 | P14_access_1 | P14_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P14_access_1_P14_entry_1; docs:426,427; status:planning_only |
| E_P14_access_1_N003_crossroad | P14_access_1 | N003_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P14_access_1_N003_crossroad; docs:426,427; status:planning_only |
| E_N058_crossroad_P04_access_2 | N058_crossroad | P04_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N058_crossroad_P04_access_2; docs:426,427; status:planning_only |
| E_P04_access_2_P04_entry_2 | P04_access_2 | P04_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P04_access_2_P04_entry_2; docs:426,427; status:planning_only |
| E_P04_access_2_T024_road_end | P04_access_2 | T024_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P04_access_2_T024_road_end; docs:426,427; status:planning_only |
| E_N052_crossroad_P14_access_2 | N052_crossroad | P14_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N052_crossroad_P14_access_2; docs:426,427; status:planning_only |
| E_P14_access_2_P14_entry_2 | P14_access_2 | P14_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P14_access_2_P14_entry_2; docs:426,427; status:planning_only |
| E_P14_access_2_N045_crossroad | P14_access_2 | N045_crossroad | candidate_only | false | true | svg:12_navigation_edges/E_P14_access_2_N045_crossroad; docs:426,427; status:planning_only |
| E_P11_access_2_P11_entry_2 | P11_access_2 | P11_entry_2 | candidate_only | false | true | svg:12_navigation_edges/E_P11_access_2_P11_entry_2; docs:426,427; status:planning_only |
| E_P11_access_1_P11_entry_1 | P11_access_1 | P11_entry_1 | candidate_only | false | true | svg:12_navigation_edges/E_P11_access_1_P11_entry_1; docs:426,427; status:planning_only |
| E_N039_crossroad_P11_access_1 | N039_crossroad | P11_access_1 | candidate_only | false | true | svg:12_navigation_edges/E_N039_crossroad_P11_access_1; docs:426,427; status:planning_only |
| E_P11_access_1_T025_road_end | P11_access_1 | T025_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P11_access_1_T025_road_end; docs:426,427; status:planning_only |
| E_N039_crossroad_P11_access_2 | N039_crossroad | P11_access_2 | candidate_only | false | true | svg:12_navigation_edges/E_N039_crossroad_P11_access_2; docs:426,427; status:planning_only |
| E_P11_access_2_T026_road_end | P11_access_2 | T026_road_end | candidate_only | false | true | svg:12_navigation_edges/E_P11_access_2_T026_road_end; docs:426,427; status:planning_only |

### 6.2 Bridge Chain Review

| bridge | status | N_to_M | M_to_S | north_connection | south_connection | blocked_for_runtime |
| --- | --- | --- | --- | --- | --- | --- |
| B01 | OK | True | True | True | True | true |
| B02 | OK | True | True | True | True | true |
| B03 | OK | True | True | True | True | true |
| B04 | OK | True | True | True | True | true |
| B05 | OK | True | True | True | True | true |
| B06 | OK | True | True | True | True | true |
| B07 | OK | True | True | True | True | true |
| B08 | OK | True | True | True | True | true |

### 6.3 Parcel Access / Entry Review

| parcel | graph_from | graph_to | status | blocked_for_runtime |
| --- | --- | --- | --- | --- |
| P01 | P01_access_1 | P01_entry_1 | OK | true |
| P01 | P01_access_2 | P01_entry_2 | OK | true |
| P02 | P02_access_1 | P02_entry_1 | OK | true |
| P02 | P02_access_2 | P02_entry_2 | OK | true |
| P03 | P03_access_1 | P03_entry_1 | OK | true |
| P03 | P03_access_2 | P03_entry_2 | OK | true |
| P04 | P04_access_1 | P04_entry_1 | OK | true |
| P04 | P04_access_2 | P04_entry_2 | OK | true |
| P05 | P05_access_1 | P05_entry_1 | OK | true |
| P05 | P05_access_2 | P05_entry_2 | OK | true |
| P06 | P06_access_1 | P06_entry_1 | OK | true |
| P06 | P06_access_2 | P06_entry_2 | OK | true |
| P07 | P07_access_1 | P07_entry_1 | OK | true |
| P07 | P07_access_2 | P07_entry_2 | OK | true |
| P08 | P08_access_1 | P08_entry_1 | OK | true |
| P08 | P08_access_2 | P08_entry_2 | OK | true |
| P09 | P09_access_1 | P09_entry_1 | OK | true |
| P09 | P09_access_2 | P09_entry_2 | OK | true |
| P10 | P10_access_1 | P10_entry_1 | OK | true |
| P10 | P10_access_2 | P10_entry_2 | OK | true |
| P11 | P11_access_1 | P11_entry_1 | OK | true |
| P11 | P11_access_2 | P11_entry_2 | OK | true |
| P12 | P12_access_1 | P12_entry_1 | OK | true |
| P12 | P12_access_2 | P12_entry_2 | OK | true |
| P13 | P13_access_1 | P13_entry_1 | OK | true |
| P13 | P13_access_2 | P13_entry_2 | OK | true |
| P14 | P14_access_1 | P14_entry_1 | OK | true |
| P14 | P14_access_2 | P14_entry_2 | OK | true |

### 6.4 Special Navigation Anchors

| anchor | status | blocked_for_runtime |
| --- | --- | --- |
| city_spawn_start | connected | true |
| D001_internal_road_end | connected | true |

## 7. Review Flags

| family | review_flag | meaning | blocked_for_runtime |
| --- | --- | --- | --- |
| River | no_walk_candidate + no_build_candidate | Arno is a planning-only movement/build blocker | true |
| Roads | walk_candidate + no_build_candidate | main and side roads are candidate walk surfaces, not build areas | true |
| Bridges | walk_candidate + no_build_candidate | bridge decks are candidate crossings, not build areas | true |
| Parcels | portal_candidate / detail_map_entry_candidate | parcels are entry portals into later detail maps, not direct city-build state | true |
| Landmarks | protected_core_candidate | landmark cores remain protected and no-build in planning | true |
| Urban Blocks | blocked_context_candidate / no_build_candidate | urban blocks are planning blockers/context, not runtime collision | true |
| Green Areas | context_candidate | vegetation/spacing context only | true |
| All entries | blocked_for_runtime | nothing in this report may be used as runtime data | true |

## 8. Stop- / Blocker-Ergebnis

| check | result |
| --- | --- |
| Master-SVG vorhanden | PASS |
| SHA erwartet | PASS |
| Layer vorhanden | PASS |
| Counts passend | PASS |
| Duplicate IDs | PASS |
| sichtbare Standard-IDs | PASS |
| Edge-Endpunkte aufloesbar | 221/221 |
| offene E_needs_manual_review | 0 |
| P01-P14 vollstaendig | PASS |
| B01-B08 vollstaendig | PASS |
| Bridge-Ketten B01-B08 | 8/8 |
| Parcel Access/Entry | 28/28 |
| city_spawn_start | connected |
| D001_internal_road_end | connected |
| vollstaendige planning-only Extraktion | PASS |

## 9. Forbidden Data Confirmation

Nicht erzeugt und nicht dokumentiert:

- keine produktiven Koordinaten,
- keine finalen Polygone,
- keine SVG-`path d`-Werte,
- keine Punktlisten,
- keine Transform-Werte als Runtime-Daten,
- keine Collision-Daten,
- keine Pathfinding-Gewichte,
- keine Runtime-Adjacency,
- keine Flutter-/Dart-Daten,
- keine JSON-/YAML-/YML-Datei,
- keine Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`.

## 10. Entscheidung

Ergebnis:

```text
planning-only PASS
```

Diese Extraktion ist ausreichend, um die Registries in einem eigenen Review-Slice gegen `416` zu bewerten. Sie gibt weiterhin keine Flutter-Preview frei.

Empfohlener naechster engster Slice:

```text
Firenze Area-Specification Planning Extraction Review v1
```

Ziel dieses Folgeslices waere nur, die in diesem Dokument erzeugten Registries gegen `416` zu reviewen und zu entscheiden, ob danach ein Metrics-/Reachability-/Collision-Review-Gate geplant werden darf. Eine Flutter-Preview bleibt bis nach einem weiteren Gate blockiert.

## 11. Dokumentationsvisual

Erzeugt:

- `docs/world_design/previews/firenze_area_specification_planning_extraction_v1/firenze_area_specification_planning_extraction_v1.svg`
- `docs/world_design/previews/firenze_area_specification_planning_extraction_v1/firenze_area_specification_planning_extraction_v1.png`

Das Visual zeigt nur:

```text
Master-SVG -> Planning Extraction v1 -> Registries -> Review Flags -> Runtime bleibt gesperrt
```

Es ist kein App-Screen, kein Asset und keine Runtime-Map.

## 12. Checks

| check | result |
| --- | --- |
| Start-`git status --short` | sauber |
| Start-HEAD | 861b873e docs: plan firenze area specification extraction |
| Master-SVG parsebar | PASS |
| Markdown-Report erzeugt | PASS |
| SVG-Dokumentationsvisual erzeugt | PASS |
| PNG-Dokumentationsvisual erzeugt | PASS |
| Visual-QA | PASS |
| keine JSON/YAML/YML-Dateien erzeugt | PASS |
| keine Aenderungen an `lib/`, `pubspec.yaml`, `assets/` | PASS |
| `git diff --check` | PASS |
