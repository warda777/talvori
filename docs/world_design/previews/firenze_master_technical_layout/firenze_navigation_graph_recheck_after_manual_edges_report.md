# Firenze Navigation Graph Recheck After Manual Edges Report

Stand: 2026-06-17

Status: `documentation_only` / `planning_svg_cleanup` / `navigation_graph_recheck` / `not_runtime_data` / `not_asset` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Gelesene Dokumente

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_navigation_graph_cleanup_report.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_navigation_manual_review_checklist.md`

## 2. Geprüfte SVG-Datei

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg
```

Die SVG wurde erneut gegen die manuell ergänzten Access-/Entry-Pfade geprüft. Es wurden keine Pfadpunkte, Koordinaten, Transforms, Styles oder sichtbaren Flächen verändert.

## 3. Sicherungskopie

Vor der ID-/Label-Bereinigung wurde diese Sicherungskopie angelegt bzw. verwendet:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_before_manual_edges_recheck.svg
```

## 4. Durchgeführte Bereinigung

- `12_navigation_graph` enthielt wieder gemischt Graph-Nodes, Access-Nodes und Edges. Die vorhandenen Ellipsen wurden ohne Geometrieänderung in `11_navigation_nodes` geführt; der Edge-Layer heißt wieder `12_navigation_edges`.
- Parcel-Entry-Nodes wurden von `P##_entry` / `P##_2_entry` auf `P##_entry_1` / `P##_entry_2` normalisiert.
- Die doppelte Bridge-Node-Benennung an B02 wurde auf `B02_S` korrigiert.
- Die manuell ergänzten Access-Entry-Pfade wie `P02_access_2_path_P02_2_entry` wurden bei eindeutig passenden Endpunkten auf `E_<from>_<to>` normalisiert.
- Nicht eindeutig auf zwei Nodes auflösbare Kanten wurden als `E_needs_manual_review_###` markiert.

Geometrie-/Style-/Textschutz gegen die Backup-SVG: `OK`.

## 5. Objektzählung

| Kategorie | Anzahl |
| --- | --- |
| Navigation-Nodes gesamt | 154 |
| Navigation-Edges gesamt | 221 |
| Eindeutig benannte Edges | 194 |
| Verbleibende `needs_manual_review`-Edges | 27 |
| Bridge-/City-Anker zusätzlich geprüft | 2 |

## 6. Nodes nach Typ

| Typ | Anzahl |
| --- | --- |
| Crossroads / Road-Nodes | 74 |
| Bridge Nodes | 24 |
| Parcel Entries | 28 |
| Road Access Nodes | 28 |

Zusätzlich geprüft: `city_spawn_start` und `city_center_anchor` im Anchor-Layer.

## 7. Access-Entry-Verbindungen

| Verbindung | Status |
| --- | --- |
| P01_access_1 -> P01_entry_1 | OK |
| P01_access_2 -> P01_entry_2 | OK |
| P02_access_1 -> P02_entry_1 | OK |
| P02_access_2 -> P02_entry_2 | OK |
| P03_access_1 -> P03_entry_1 | OK |
| P03_access_2 -> P03_entry_2 | OK |
| P04_access_1 -> P04_entry_1 | OK |
| P04_access_2 -> P04_entry_2 | OK |
| P05_access_1 -> P05_entry_1 | OK |
| P05_access_2 -> P05_entry_2 | OK |
| P06_access_1 -> P06_entry_1 | OK |
| P06_access_2 -> P06_entry_2 | OK |
| P07_access_1 -> P07_entry_1 | OK |
| P07_access_2 -> P07_entry_2 | OK |
| P08_access_1 -> P08_entry_1 | OK |
| P08_access_2 -> P08_entry_2 | OK |
| P09_access_1 -> P09_entry_1 | OK |
| P09_access_2 -> P09_entry_2 | OK |
| P10_access_1 -> P10_entry_1 | OK |
| P10_access_2 -> P10_entry_2 | OK |
| P11_access_1 -> P11_entry_1 | OK |
| P11_access_2 -> P11_entry_2 | OK |
| P12_access_1 -> P12_entry_1 | OK |
| P12_access_2 -> P12_entry_2 | OK |
| P13_access_1 -> P13_entry_1 | OK |
| P13_access_2 -> P13_entry_2 | OK |
| P14_access_1 -> P14_entry_1 | OK |
| P14_access_2 -> P14_entry_2 | OK |

Die neun zuvor offenen Access-Entry-Verbindungen sind damit als direkte Kurz-Edges eindeutig benannt.

## 8. Access-Nodes am Straßennetz

| Access-Node | Graph-Anschluss | Nicht-Entry-Nachbar |
| --- | --- | --- |
| P01_access_1 | OK | N042_crossroad |
| P01_access_2 | OK | N050_crossroad, N051_crossroad |
| P02_access_1 | OK | N002_crossroad, N006_crossroad |
| P02_access_2 | OK | N006_crossroad, N007_crossroad |
| P03_access_1 | OK | N006_crossroad, N008_crossroad |
| P03_access_2 | OK | N007_crossroad, N066_crossroad |
| P04_access_1 | OK | N059_crossroad, N060_crossroad |
| P04_access_2 | OK | N058_crossroad |
| P05_access_1 | OK | N060_crossroad |
| P05_access_2 | OK | N061_crossroad, N073_crossroad |
| P06_access_1 | OK | N017_crossroad, N073_crossroad |
| P06_access_2 | OK | N061_crossroad, N062_crossroad |
| P07_access_1 | OK | N016_crossroad, N017_crossroad |
| P07_access_2 | OK | N018_crossroad |
| P08_access_1 | OK | N019_crossroad, N020_crossroad |
| P08_access_2 | OK | N022_crossroad, N023_crossroad |
| P09_access_1 | OK | N023_crossroad, N024_crossroad |
| P09_access_2 | OK | N026_crossroad, N028_crossroad |
| P10_access_1 | OK | N030_crossroad |
| P10_access_2 | OK | N065_crossroad |
| P11_access_1 | OK | N039_crossroad |
| P11_access_2 | OK | N039_crossroad |
| P12_access_1 | OK | N034_crossroad, N039_crossroad |
| P12_access_2 | OK | N038_crossroad |
| P13_access_1 | OK | N035_crossroad, N046_crossroad |
| P13_access_2 | OK | N032_crossroad |
| P14_access_1 | OK | N002_crossroad, N003_crossroad |
| P14_access_2 | OK | N045_crossroad, N052_crossroad |

## 9. Bridge-Ketten

| Bridge | N-M | M-S | Nord-/Road-Anschluss | Süd-/Road-Anschluss |
| --- | --- | --- | --- | --- |
| B01 | OK | OK | N043_crossroad | N040_crossroad |
| B02 | OK | OK | N045_crossroad | N037_crossroad |
| B03 | OK | OK | N052_crossroad | N036_crossroad |
| B04 | OK | OK | N047_crossroad | N046_crossroad |
| B05 | OK | OK | N015_crossroad | N027_crossroad |
| B06 | OK | OK | N016_crossroad | N025_crossroad |
| B07 | OK | OK | N018_crossroad | N019_crossroad |
| B08 | OK | OK | N071_crossroad | N070_crossroad |

## 10. City-Nodes

| Node | Status | Nachbarn |
| --- | --- | --- |
| city_spawn_start | OK | N001_crossroad, N044_crossroad |
| city_center_anchor | bewusst nur Anchor / nicht angebunden | - |

## 11. Weiterhin offene Edges

| Review-ID | Vorheriges Label/ID | Grund | Position | Empfehlung |
| --- | --- | --- | --- | --- |
| E_needs_manual_review_001 | path234 | endpoint_too_far:start=N001_crossroad:0.30, end=N001_crossroad:11.40 | ca. 149.9, 72.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_002 | path236 | endpoint_too_far:start=N007_crossroad:0.32, end=P03_access_2:18.26 | ca. 194.6, 32.3 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_003 | path239 | endpoint_too_far:start=N005_crossroad:0.17, end=N005_crossroad:9.38 | ca. 232.6, 103.8 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_004 | path251 | endpoint_too_far:start=N009_crossroad:0.21, end=P04_access_2:26.85 | ca. 237.9, 39.2 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_005 | path253 | endpoint_too_far:start=N040_crossroad:0.14, end=N040_crossroad:6.34 | ca. 145.9, 93.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_006 | path280 | endpoint_too_far:start=N021_crossroad:0.23, end=N021_crossroad:29.96 | ca. 318.0, 185.8 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_007 | path287 | endpoint_too_far:start=N041_crossroad:0.28, end=N041_crossroad:4.28 | ca. 128.7, 68.9 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_008 | path293 | endpoint_too_far:start=N050_crossroad:0.14, end=N050_crossroad:5.59 | ca. 127.1, 94.8 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_009 | path302 | endpoint_too_far:start=N018_crossroad:0.23, end=B07_N:5.94 | ca. 327.3, 133.1 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_010 | path303 | endpoint_too_far:start=N019_crossroad:0.06, end=N019_crossroad:14.35 | ca. 329.8, 140.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_011 | path312 | endpoint_too_far:start=N028_crossroad:0.18, end=N065_crossroad:13.48 | ca. 251.4, 167.1 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_012 | path317 | endpoint_too_far:start=N065_crossroad:0.15, end=P10_access_2:16.66 | ca. 249.4, 182.8 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_013 | path323 | endpoint_too_far:start=N032_crossroad:0.22, end=N032_crossroad:23.07 | ca. 191.6, 157.8 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_014 | path333 | endpoint_too_far:start=N020_crossroad:0.21, end=N020_crossroad:20.09 | ca. 330.5, 163.4 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_015 | path341 | endpoint_too_far:start=N060_crossroad:0.23, end=N060_crossroad:12.25 | ca. 273.1, 50.1 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_016 | path365 | endpoint_too_far:start=N058_crossroad:0.16, end=N058_crossroad:6.46 | ca. 245.2, 46.6 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_017 | path367 | endpoint_too_far:start=N007_crossroad:0.23, end=N007_crossroad:11.41 | ca. 193.0, 45.3 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_018 | path369 | endpoint_too_far:start=N066_crossroad:0.18, end=N066_crossroad:4.03 | ca. 210.9, 30.2 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_019 | path370 | endpoint_too_far:start=N066_crossroad:0.32, end=N066_crossroad:6.74 | ca. 212.5, 31.2 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_020 | path417 | endpoint_too_far:start=P05_access_1:0.14, end=P05_access_1:38.90 | ca. 294.3, 27.4 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_021 | path432 | endpoint_too_far:start=P07_access_2:0.12, end=P07_entry_2:3.52 | ca. 325.9, 126.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_022 | path447 | endpoint_too_far:start=P10_access_1:0.11, end=P10_entry_2:58.72 | ca. 205.0, 204.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_023 | path450 | endpoint_too_far:start=P10_access_2:0.09, end=P10_entry_2:9.54 | ca. 240.8, 198.2 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_024 | path456 | endpoint_too_far:start=P12_access_2:0.15, end=P12_access_2:13.92 | ca. 166.6, 112.4 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_025 | path468 | endpoint_too_far:start=P04_access_2:0.10, end=P04_access_2:9.21 | ca. 257.8, 43.6 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_026 | path475 | endpoint_too_far:start=P11_access_1:0.08, end=P11_access_1:21.31 | ca. 167.4, 164.0 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |
| E_needs_manual_review_027 | path477 | endpoint_too_far:start=P11_access_2:0.10, end=P11_access_2:6.72 | ca. 159.8, 129.6 | Freien Endpunkt an passenden Node snappen oder fehlenden Node bewusst anlegen/benennen. |

## 12. Auffällige Linien / fachliche Verlaufskandidaten

Es wurde keine produktive Polygon-/Schnittprüfung erzeugt. Die folgende Liste ist eine konservative Review-Hilfe aus Edge-Länge, unklaren Endpunkten und Review-Status.

| Edge | Position | Hinweis |
| --- | --- | --- |
| E_needs_manual_review_001 | 149.9, 72.0 | endpoint_too_far:start=N001_crossroad:0.30, end=N001_crossroad:11.40 |
| E_needs_manual_review_002 | 194.6, 32.3 | endpoint_too_far:start=N007_crossroad:0.32, end=P03_access_2:18.26 |
| E_needs_manual_review_003 | 232.6, 103.8 | endpoint_too_far:start=N005_crossroad:0.17, end=N005_crossroad:9.38 |
| E_needs_manual_review_004 | 237.9, 39.2 | endpoint_too_far:start=N009_crossroad:0.21, end=P04_access_2:26.85 |
| E_needs_manual_review_005 | 145.9, 93.0 | endpoint_too_far:start=N040_crossroad:0.14, end=N040_crossroad:6.34 |
| E_needs_manual_review_006 | 318.0, 185.8 | endpoint_too_far:start=N021_crossroad:0.23, end=N021_crossroad:29.96 |
| E_needs_manual_review_007 | 128.7, 68.9 | endpoint_too_far:start=N041_crossroad:0.28, end=N041_crossroad:4.28 |
| E_needs_manual_review_008 | 127.1, 94.8 | endpoint_too_far:start=N050_crossroad:0.14, end=N050_crossroad:5.59 |
| E_needs_manual_review_009 | 327.3, 133.1 | endpoint_too_far:start=N018_crossroad:0.23, end=B07_N:5.94 |
| E_needs_manual_review_010 | 329.8, 140.0 | endpoint_too_far:start=N019_crossroad:0.06, end=N019_crossroad:14.35 |
| E_needs_manual_review_011 | 251.4, 167.1 | endpoint_too_far:start=N028_crossroad:0.18, end=N065_crossroad:13.48 |
| E_needs_manual_review_012 | 249.4, 182.8 | endpoint_too_far:start=N065_crossroad:0.15, end=P10_access_2:16.66 |
| E_needs_manual_review_013 | 191.6, 157.8 | endpoint_too_far:start=N032_crossroad:0.22, end=N032_crossroad:23.07 |
| E_needs_manual_review_014 | 330.5, 163.4 | endpoint_too_far:start=N020_crossroad:0.21, end=N020_crossroad:20.09 |
| E_needs_manual_review_015 | 273.1, 50.1 | endpoint_too_far:start=N060_crossroad:0.23, end=N060_crossroad:12.25 |
| E_needs_manual_review_016 | 245.2, 46.6 | endpoint_too_far:start=N058_crossroad:0.16, end=N058_crossroad:6.46 |
| E_needs_manual_review_017 | 193.0, 45.3 | endpoint_too_far:start=N007_crossroad:0.23, end=N007_crossroad:11.41 |
| E_needs_manual_review_018 | 210.9, 30.2 | endpoint_too_far:start=N066_crossroad:0.18, end=N066_crossroad:4.03 |
| E_needs_manual_review_019 | 212.5, 31.2 | endpoint_too_far:start=N066_crossroad:0.32, end=N066_crossroad:6.74 |
| E_needs_manual_review_020 | 294.3, 27.4 | endpoint_too_far:start=P05_access_1:0.14, end=P05_access_1:38.90 |
| E_needs_manual_review_021 | 325.9, 126.0 | endpoint_too_far:start=P07_access_2:0.12, end=P07_entry_2:3.52 |
| E_needs_manual_review_022 | 205.0, 204.0 | endpoint_too_far:start=P10_access_1:0.11, end=P10_entry_2:58.72 |
| E_needs_manual_review_023 | 240.8, 198.2 | endpoint_too_far:start=P10_access_2:0.09, end=P10_entry_2:9.54 |
| E_needs_manual_review_024 | 166.6, 112.4 | endpoint_too_far:start=P12_access_2:0.15, end=P12_access_2:13.92 |
| E_needs_manual_review_025 | 257.8, 43.6 | endpoint_too_far:start=P04_access_2:0.10, end=P04_access_2:9.21 |
| E_needs_manual_review_026 | 167.4, 164.0 | endpoint_too_far:start=P11_access_1:0.08, end=P11_access_1:21.31 |
| E_needs_manual_review_027 | 159.8, 129.6 | endpoint_too_far:start=P11_access_2:0.10, end=P11_access_2:6.72 |
| E_N001_crossroad_N002_crossroad | 169.9, 83.1 | long_edge_length≈46.7; visual route review recommended |
| E_N014_crossroad_N015_crossroad | 266.8, 111.7 | long_edge_length≈37.5; visual route review recommended |
| E_N043_crossroad_N045_crossroad | 167.8, 91.2 | long_edge_length≈46.0; visual route review recommended |
| E_N016_crossroad_N018_crossroad | 305.5, 129.6 | long_edge_length≈38.7; visual route review recommended |
| E_N037_crossroad_N040_crossroad | 165.9, 96.3 | long_edge_length≈43.7; visual route review recommended |
| E_P05_access_2_N073_crossroad | 297.7, 81.9 | long_edge_length≈35.0; visual route review recommended |

## 13. Manuelle To-do-Liste

- Da mehr als 20 Review-Edges offen sind, zuerst die Node-/Edge-Layer in Inkscape visuell prüfen und nur eindeutige Endpunkt-Snaps setzen.
- Priorität 1: alle `E_needs_manual_review_*` mit `same_node` oder `duplicate_edge_target` löschen oder einem echten zweiten Node zuordnen.
- Priorität 2: alle `endpoint_too_far`-Kanten an den nächstliegenden fachlichen Road-/Bridge-/Access-Node snappen.

## 14. Bereitschaft

```text
Navigation-Graph bereit für QA-Preview: NO
Area-Specification-JSON bereit: NO
```

Begründung: Es bleiben mehr als 20 `needs_manual_review`-Edges oder nicht final bestätigte Verlaufskandidaten. Daraus darf noch keine Area-Specification-JSON oder Runtime-/Walkability-Ableitung entstehen.
