# Firenze Master Technical Layout - Terminal Road-End Pass

Status: documentation_only / planning_svg_cleanup / not_runtime_data / no_area_spec_json / no_flutter / no_commit

## Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_navigation_graph_recheck_after_manual_edges_report.md`

## Geprüfte Datei

- SVG: `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg`
- Backup: `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_before_terminal_road_end_pass.svg`

## Vorgehen

Die verbleibenden `E_needs_manual_review_###`-Edges wurden gegen die bestehende playable Boundary geprüft. Nur Edges, deren freies Ende boundary-nah lag, deren anderes Ende an einem bestehenden Navigation-Node hing und die kein reines Mini-Duplikat am selben Punkt waren, wurden als bewusst endende Straßen akzeptiert. Bestehende Pfade, Straßenflächen, Parcels, River, Bridges und Boundary-Geometrie wurden nicht verschoben oder neu gezeichnet. Es wurden nur Terminal-Node-Ellipsen ergänzt und die zugehörigen Edge-IDs/Labels umbenannt.

## Ergebniszahlen

- Navigation-Nodes nach Pass: 180
- Terminal-/Road-End-Nodes erstellt: 26
- Navigation-Edges gesamt: 221
- Erfolgreich benannte Terminal-Edges: 26
- Verbleibende `needs_manual_review`-Edges: 1
- Duplicate IDs: 0
- `11_navigation_nodes` enthält nur Punkte/Ellipsen: YES
- `12_navigation_edges` enthält nur Linien/Pfade: YES

## Erstellte Terminal-/Road-End-Nodes

| Terminal Node | Ehemalige Edge | Neue Edge | Angeschlossen an | Terminal-Position | Boundary-Distanz | Edge-Länge |
|---|---|---|---|---:|---:|---:|
| `T001_road_end` | `E_needs_manual_review_001` | `E_N001_crossroad_T001_road_end` | `N001_crossroad` | (152.00, 66.89) | 0.66 | 11.30 |
| `T002_road_end` | `E_needs_manual_review_002` | `E_N007_crossroad_T002_road_end` | `N007_crossroad` | (191.91, 23.29) | 0.69 | 18.96 |
| `T003_road_end` | `E_needs_manual_review_004` | `E_N009_crossroad_T003_road_end` | `N009_crossroad` | (246.86, 20.08) | 1.02 | 42.60 |
| `T004_road_end` | `E_needs_manual_review_005` | `E_N040_crossroad_T004_road_end` | `N040_crossroad` | (145.36, 96.02) | 0.79 | 6.34 |
| `T005_road_end` | `E_needs_manual_review_006` | `E_N021_crossroad_T005_road_end` | `N021_crossroad` | (321.33, 200.25) | 0.71 | 32.18 |
| `T006_road_end` | `E_needs_manual_review_007` | `E_N041_crossroad_T006_road_end` | `N041_crossroad` | (128.44, 66.95) | 0.70 | 4.08 |
| `T007_road_end` | `E_needs_manual_review_008` | `E_N050_crossroad_T007_road_end` | `N050_crossroad` | (126.91, 97.50) | 0.83 | 5.47 |
| `T008_road_end` | `E_needs_manual_review_009` | `E_N018_crossroad_T008_road_end` | `N018_crossroad` | (329.96, 134.40) | 0.68 | 6.04 |
| `T009_road_end` | `E_needs_manual_review_010` | `E_N019_crossroad_T009_road_end` | `N019_crossroad` | (336.77, 141.53) | 0.72 | 14.39 |
| `T010_road_end` | `E_needs_manual_review_011` | `E_N028_crossroad_T010_road_end` | `N028_crossroad` | (254.22, 184.66) | 0.95 | 39.56 |
| `T011_road_end` | `E_needs_manual_review_012` | `E_N065_crossroad_T011_road_end` | `N065_crossroad` | (254.25, 189.97) | 0.67 | 18.00 |
| `T012_road_end` | `E_needs_manual_review_013` | `E_N032_crossroad_T012_road_end` | `N032_crossroad` | (186.40, 167.16) | 0.78 | 28.43 |
| `T013_road_end` | `E_needs_manual_review_014` | `E_N020_crossroad_T013_road_end` | `N020_crossroad` | (338.93, 168.62) | 0.77 | 19.92 |
| `T014_road_end` | `E_needs_manual_review_015` | `E_N060_crossroad_T014_road_end` | `N060_crossroad` | (270.81, 44.53) | 0.77 | 12.06 |
| `T015_road_end` | `E_needs_manual_review_016` | `E_N058_crossroad_T015_road_end` | `N058_crossroad` | (245.26, 43.45) | 0.66 | 6.30 |
| `T016_road_end` | `E_needs_manual_review_017` | `E_N007_crossroad_T016_road_end` | `N007_crossroad` | (188.76, 48.94) | 0.90 | 11.25 |
| `T017_road_end` | `E_needs_manual_review_018` | `E_N066_crossroad_T017_road_end` | `N066_crossroad` | (212.23, 28.85) | 0.79 | 3.86 |
| `T018_road_end` | `E_needs_manual_review_019` | `E_N066_crossroad_T018_road_end` | `N066_crossroad` | (215.31, 28.44) | 0.59 | 9.90 |
| `T019_road_end` | `E_needs_manual_review_020` | `E_P05_access_1_T019_road_end` | `P05_access_1` | (303.25, 10.19) | 0.71 | 39.29 |
| `T020_road_end` | `E_needs_manual_review_021` | `E_P07_access_2_T020_road_end` | `P07_access_2` | (326.24, 124.33) | 0.65 | 3.43 |
| `T021_road_end` | `E_needs_manual_review_022` | `E_P10_access_1_T021_road_end` | `P10_access_1` | (190.66, 229.98) | 0.68 | 64.06 |
| `T022_road_end` | `E_needs_manual_review_023` | `E_P10_access_2_T022_road_end` | `P10_access_2` | (243.46, 202.24) | 0.66 | 9.80 |
| `T023_road_end` | `E_needs_manual_review_024` | `E_P12_access_2_T023_road_end` | `P12_access_2` | (159.72, 112.96) | 0.72 | 13.78 |
| `T024_road_end` | `E_needs_manual_review_025` | `E_P04_access_2_T024_road_end` | `P04_access_2` | (261.71, 41.33) | 0.62 | 9.22 |
| `T025_road_end` | `E_needs_manual_review_026` | `E_P11_access_1_T025_road_end` | `P11_access_1` | (173.36, 173.67) | 0.67 | 25.94 |
| `T026_road_end` | `E_needs_manual_review_027` | `E_P11_access_2_T026_road_end` | `P11_access_2` | (158.79, 126.42) | 0.63 | 6.64 |

## Dadurch geklärte ehemalige Needs-Manual-Review-Edges

- `E_needs_manual_review_001` -> `E_N001_crossroad_T001_road_end`
- `E_needs_manual_review_002` -> `E_N007_crossroad_T002_road_end`
- `E_needs_manual_review_004` -> `E_N009_crossroad_T003_road_end`
- `E_needs_manual_review_005` -> `E_N040_crossroad_T004_road_end`
- `E_needs_manual_review_006` -> `E_N021_crossroad_T005_road_end`
- `E_needs_manual_review_007` -> `E_N041_crossroad_T006_road_end`
- `E_needs_manual_review_008` -> `E_N050_crossroad_T007_road_end`
- `E_needs_manual_review_009` -> `E_N018_crossroad_T008_road_end`
- `E_needs_manual_review_010` -> `E_N019_crossroad_T009_road_end`
- `E_needs_manual_review_011` -> `E_N028_crossroad_T010_road_end`
- `E_needs_manual_review_012` -> `E_N065_crossroad_T011_road_end`
- `E_needs_manual_review_013` -> `E_N032_crossroad_T012_road_end`
- `E_needs_manual_review_014` -> `E_N020_crossroad_T013_road_end`
- `E_needs_manual_review_015` -> `E_N060_crossroad_T014_road_end`
- `E_needs_manual_review_016` -> `E_N058_crossroad_T015_road_end`
- `E_needs_manual_review_017` -> `E_N007_crossroad_T016_road_end`
- `E_needs_manual_review_018` -> `E_N066_crossroad_T017_road_end`
- `E_needs_manual_review_019` -> `E_N066_crossroad_T018_road_end`
- `E_needs_manual_review_020` -> `E_P05_access_1_T019_road_end`
- `E_needs_manual_review_021` -> `E_P07_access_2_T020_road_end`
- `E_needs_manual_review_022` -> `E_P10_access_1_T021_road_end`
- `E_needs_manual_review_023` -> `E_P10_access_2_T022_road_end`
- `E_needs_manual_review_024` -> `E_P12_access_2_T023_road_end`
- `E_needs_manual_review_025` -> `E_P04_access_2_T024_road_end`
- `E_needs_manual_review_026` -> `E_P11_access_1_T025_road_end`
- `E_needs_manual_review_027` -> `E_P11_access_2_T026_road_end`

## Weiterhin offene Edges

- `E_needs_manual_review_003`

## Candidate Delete / Manual Review

| Edge | Freies Ende | Boundary-Distanz | Edge-Länge | Empfehlung |
|---|---:|---:|---:|---|
| `E_needs_manual_review_003` | (235.14, 107.20) | 61.86 | 12.99 | not a boundary road-end; candidate_delete_or_manual_review |

`E_needs_manual_review_003` wurde bewusst nicht als `road_end` markiert, weil das freie Ende nicht boundary-nah ist. Es liegt deutlich im Inneren der Spielfläche und muss in Inkscape manuell geprüft werden: entweder löschen, korrekt mit einem vorhandenen Zielnode verbinden oder neu als eindeutige Navigationskante anlegen.

## Zusatzprüfungen

### Bridge-Ketten B01-B08

- `B01`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B02`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B03`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B04`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B05`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B06`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B07`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)
- `B08`: OK (`N-M`: True, `M-S`: True, north road: True, south road: True)

### Access-Entry-Verbindungen

- OK: 28/28
- Fehlend/unklar: Keine

### City-Start / Center

- `city_spawn_start` ist angebunden: NO
- `city_center_anchor` bleibt ein Anchor/Orientierungspunkt und wurde in diesem Pass nicht zur Runtime- oder Area-Spec-Datenquelle gemacht.

### Offensichtliche Linienprobleme

- Es wurden keine bestehenden Edges geometrisch verändert.
- Die neu geklärten Terminal-Edges enden boundary-nah und wurden nicht als Querlinien durch River, Parcels, Urban Blocks oder Grünflächen neu erzeugt.
- `E_needs_manual_review_003` bleibt die einzige in diesem Pass erkannte nicht-boundary-nahe offene Edge und sollte vor einer Freigabe manuell geprüft werden.

## Freigabe-Aussage

- Navigation-Graph bereit für QA-Preview: NO
- Area-Specification-JSON bereit: NO

Begründung: Die Terminal-Road-End-Struktur ist weitgehend geklärt, aber solange `E_needs_manual_review_003` offen ist, bleibt der Graph nicht vollständig bereinigt. Aus diesem SVG entsteht weiterhin keine Runtime-Geometrie und keine finale Area-Specification.
