# Firenze Final QA Preview Report

Status: documentation_only / final_visual_qa_preview / not_runtime_data / no_area_specification_json / no_flutter / no_commit

## Geprüfte SVG-Datei

- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg`

Die Master-SVG wurde für diesen QA-Slice nur gelesen. Sie wurde nicht verändert.

## Erzeugte QA-Dateien

- `docs/world_design/previews/firenze_master_technical_layout/final_qa_preview/firenze_final_qa_preview.svg`
- `docs/world_design/previews/firenze_master_technical_layout/final_qa_preview/firenze_final_qa_preview.png`

## Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_id_cleanup_report.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_navigation_graph_recheck_after_manual_edges_report.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_terminal_road_end_pass_report.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_internal_road_end_fix_report.md`

## Bestätigte Layer

- `00_reference_image`
- `01_boundary`
- `02_river_area`
- `03_bridge_decks`
- `04_main_roads`
- `05_side_roads`
- `06_parcels`
- `07_landmarks`
- `08_green_areas`
- `09_urban_blocks`
- `10_anchor_points`
- `11_navigation_nodes`
- `12_navigation_edges`

## Anzahl Boundary/River/Bridges/Roads/Parcels/Landmarks/Green/Urban

| Familie | Anzahl |
| --- | ---: |
| Boundary | 1 |
| River | 1 |
| Bridges | 8 |
| Main Roads | 7 |
| Side Roads | 42 |
| Parcels | 14 |
| Landmarks | 6 |
| Green Areas | 48 |
| Urban Blocks | 37 |

## Navigation-Graph

- Navigation-Nodes: 181
- Navigation-Edges: 221
- Benannte Edge-Paare auflösbar: 221 / 221
- Offene `E_needs_manual_review_###`: 0
- Duplicate IDs: 0
- Sichtbare Standard-IDs: 329

## Status B01-B08

| Bridge | Status | N-M | M-S | North/Road | South/Road |
| --- | --- | --- | --- | --- | --- |
| `B01` | OK | True | True | True | True |
| `B02` | OK | True | True | True | True |
| `B03` | OK | True | True | True | True |
| `B04` | OK | True | True | True | True |
| `B05` | OK | True | True | True | True |
| `B06` | OK | True | True | True | True |
| `B07` | OK | True | True | True | True |
| `B08` | OK | True | True | True | True |

## Status P01-P14 Access/Entry

| Verbindung | Status |
| --- | --- |
| `P01_access_1` -> `P01_entry_1` | OK |
| `P01_access_2` -> `P01_entry_2` | OK |
| `P02_access_1` -> `P02_entry_1` | OK |
| `P02_access_2` -> `P02_entry_2` | OK |
| `P03_access_1` -> `P03_entry_1` | OK |
| `P03_access_2` -> `P03_entry_2` | OK |
| `P04_access_1` -> `P04_entry_1` | OK |
| `P04_access_2` -> `P04_entry_2` | OK |
| `P05_access_1` -> `P05_entry_1` | OK |
| `P05_access_2` -> `P05_entry_2` | OK |
| `P06_access_1` -> `P06_entry_1` | OK |
| `P06_access_2` -> `P06_entry_2` | OK |
| `P07_access_1` -> `P07_entry_1` | OK |
| `P07_access_2` -> `P07_entry_2` | OK |
| `P08_access_1` -> `P08_entry_1` | OK |
| `P08_access_2` -> `P08_entry_2` | OK |
| `P09_access_1` -> `P09_entry_1` | OK |
| `P09_access_2` -> `P09_entry_2` | OK |
| `P10_access_1` -> `P10_entry_1` | OK |
| `P10_access_2` -> `P10_entry_2` | OK |
| `P11_access_1` -> `P11_entry_1` | OK |
| `P11_access_2` -> `P11_entry_2` | OK |
| `P12_access_1` -> `P12_entry_1` | OK |
| `P12_access_2` -> `P12_entry_2` | OK |
| `P13_access_1` -> `P13_entry_1` | OK |
| `P13_access_2` -> `P13_entry_2` | OK |
| `P14_access_1` -> `P14_entry_1` | OK |
| `P14_access_2` -> `P14_entry_2` | OK |

## Status city_spawn_start und D001_internal_road_end

| Element | Status |
| --- | --- |
| `city_spawn_start` | OK / angebunden |
| `D001_internal_road_end` | OK / vorhanden und an N005 angebunden |

## Problem-Check

- Visible standard IDs remain: 329
- Missing P01-P14 parcel object IDs/labels: P01, P02, P03, P04, P05, P06, P07, P08, P09, P10, P11, P12, P13, P14
- Missing L01-L06 landmark object IDs/labels: L01, L02, L03, L04, L05, L06
- Missing bridge_B01-B08 deck IDs/labels: bridge_B01, bridge_B02, bridge_B03, bridge_B04, bridge_B05, bridge_B06, bridge_B07, bridge_B08
- Missing P01-P14 anchor IDs/labels: P02_anchor

### Fehlende erwartete IDs/Labels

- `parcels`: `P01`, `P02`, `P03`, `P04`, `P05`, `P06`, `P07`, `P08`, `P09`, `P10`, `P11`, `P12`, `P13`, `P14`
- `landmarks`: `L01`, `L02`, `L03`, `L04`, `L05`, `L06`
- `parcel_anchors`: `P02_anchor`
- `bridge_decks`: `bridge_B01`, `bridge_B02`, `bridge_B03`, `bridge_B04`, `bridge_B05`, `bridge_B06`, `bridge_B07`, `bridge_B08`

### Sichtbare Standard-ID-Beispiele

- `image1` in `00_reference_image` (image)
- `path1` in `01_boundary` (path)
- `path2` in `02_river_area` (path)
- `path3` in `03_bridge_decks` (path)
- `path4` in `03_bridge_decks` (path)
- `path5` in `03_bridge_decks` (path)
- `path6` in `03_bridge_decks` (path)
- `path7` in `03_bridge_decks` (path)
- `path8` in `03_bridge_decks` (path)
- `path9` in `03_bridge_decks` (path)
- `path10` in `03_bridge_decks` (path)
- `text216` in `03_bridge_decks` (text)
- `text216-6` in `03_bridge_decks` (text)
- `text216-69` in `03_bridge_decks` (text)
- `text216-3` in `03_bridge_decks` (text)
- `text216-68` in `03_bridge_decks` (text)
- `text216-38` in `03_bridge_decks` (text)
- `text216-2` in `03_bridge_decks` (text)
- `text217` in `03_bridge_decks` (text)
- `path11` in `04_main_roads` (path)
- `path12` in `04_main_roads` (path)
- `path13` in `04_main_roads` (path)
- `path14` in `04_main_roads` (path)
- `path15` in `04_main_roads` (path)
- `path16` in `04_main_roads` (path)
- `path17` in `04_main_roads` (path)
- `path226` in `05_side_roads` (path)
- `path18` in `05_side_roads` (path)
- `path19` in `05_side_roads` (path)
- `path20` in `05_side_roads` (path)
- ... plus 299 weitere sichtbare Standard-IDs

## Collision-/Rule-Preview Lesart

- River = `no_walk` + `no_build`.
- Urban Blocks = blocked / `no_build`.
- Roads = walkable + `no_build`.
- Bridges = walkable + `no_build`.
- Parcels = enterable portals, nicht direkte City-Build-Slots.
- Landmarks = protected cores.
- Outside Boundary = blocked.

Diese Lesart ist keine Runtime-Collision, kein Pathfinding und keine Area-Specification-JSON. Eine numerische Polygon-/Schnittprüfung wurde nicht als Runtime-Daten erzeugt.

## Freigabe

- Final SVG QA-Preview: FAIL
- Navigation-Graph QA: PASS
- Area-Specification-JSON bereit: NO

Begründung: Der Navigation-Graph ist QA-sauber. Die finale Master-SVG ist aber noch nicht vollständig objekt-ID-sauber, weil sichtbare Standard-IDs und fehlende erwartete Layer-/Anchor-Objektlabels bestehen. Deshalb bleibt Area-Specification-JSON blockiert.
