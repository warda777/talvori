# 426: Firenze Master Technical Layout Readiness Check

Stand: 2026-06-18

Status: `documentation_only` / `readiness_check` / `planning_only` /
`not_runtime_data` / `no_json_yaml` / `no_flutter` / `no_app_integration` /
`no_assets` / `no_commit`

## 1. Ziel

Dieser Slice prueft, ob die bereinigte Florenz-Master-SVG als technische
Quelle fuer den naechsten engen Firenze-Schritt stabil genug ist.

Quelle:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg
```

Nicht-Ziele:

- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine Collision-/Pathfinding-Implementierung,
- keine Area-Specification-JSON,
- keine YAML-/JSON-/YML-Dateien,
- kein Flutter-Code,
- keine App-Integration,
- keine Dateien unter `assets/`,
- keine Aenderungen an `lib/` oder `pubspec.yaml`,
- kein Commit.

## 2. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_final_object_id_cleanup_report.md`
- `docs/world_design/previews/firenze_master_technical_layout/firenze_final_qa_preview_rerun_report.md`

## 3. Start- und Stop-Gate

| Check | Ergebnis |
| --- | --- |
| `git status --short` vor Start | sauber |
| Master-SVG vorhanden | YES |
| Erwartete Layer-Struktur auffindbar | YES |
| Aenderungen an `lib/` erforderlich | NO |
| Aenderungen an `pubspec.yaml` erforderlich | NO |
| Aenderungen unter `assets/` erforderlich | NO |
| JSON/YAML erforderlich | NO |

Der Slice durfte fortgesetzt werden, weil der Arbeitsbaum vor Start sauber war
und die Master-SVG existiert.

## 4. SVG-Quellstatus

| Feld | Wert |
| --- | --- |
| Datei | `docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg` |
| SHA-256 | `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3` |
| SVG `width` | `1672` |
| SVG `height` | `941` |
| SVG `viewBox` | `0 0 442.38333 248.97292` |
| Duplicate IDs | `0` |
| Sichtbare Standard-IDs | `0` |
| Offene `E_needs_manual_review` | `0` |

Bewertung:

```text
Die Master-SVG ist als technische Planungsquelle stabil genug fuer den
naechsten Docs-/Extraction-Slice. Sie ist noch keine Runtime-Quelle.
```

## 5. Erwartete Layer und Zaehler

| Familie | Layer | Erwartet | Gefunden | Status |
| --- | --- | ---: | ---: | --- |
| Boundary | `01_boundary` | 1 | 1 | PASS |
| River | `02_river_area` | 1 | 1 | PASS |
| Bridges | `03_bridge_decks` | 8 | 8 | PASS |
| Main Roads | `04_main_roads` | 7 | 7 | PASS |
| Side Roads | `05_side_roads` | 42 | 42 | PASS |
| Parcels | `06_parcels` | 14 | 14 | PASS |
| Landmarks | `07_landmarks` | 6 | 6 | PASS |
| Green Areas | `08_green_areas` | 48 | 48 | PASS |
| Urban Blocks | `09_urban_blocks` | 37 | 37 | PASS |
| Anchor Points | `10_anchor_points` | 48 | 48 | PASS |
| Navigation Nodes | `11_navigation_nodes` | 181 | 181 | PASS |
| Navigation Edges | `12_navigation_edges` | 221 | 221 | PASS |

Weitere bestaetigte Struktur:

- Navigation-Edges aufloesbar: `221/221`.
- B01-B08 Bridge-Ketten: OK.
- P01-P14 Access-/Entry-Verbindungen: `28/28` OK.
- `city_spawn_start` angebunden: YES.
- `D001_internal_road_end` angebunden: YES.
- `P02_anchor` vorhanden: YES.

## 6. Spaeter erlaubte Reads aus der SVG

Ein spaeterer, explizit freigegebener Extraktions-Slice darf diese Familien
aus der Master-SVG lesen:

| Familie | Erlaubte Read-Felder | Zweck |
| --- | --- | --- |
| Boundary | Layer, Objekt-ID, Label, Quellenhash, Review-Canvas | Abgrenzung der Planungsflaeche |
| River | Layer, Objekt-ID, Label, Beziehung zu No-Walk/No-Build | Arno als Barriere und Strukturgeber |
| Bridges | `bridge_B01`-`bridge_B08`, Bridge-Anker, Bridge-Node-Ketten | erlaubte Querungen und Connectivity |
| Roads | `main_road_*`, `side_road_*`, Layerfamilie | Wegfamilien und spaetere Walkability-Pruefung |
| Parcels | `P01`-`P14`, Parcel-Anker, Access-/Entry-IDs | Grundstuecksportale und Review-Zonen |
| Landmarks | `L01`-`L06`, Landmark-Kerne und Anker | protected cores und Identitaetsanker |
| Green Areas | `G01`-`G48` | Vegetations-/Spacing-Kontext |
| Urban Blocks | `U01`-`U37` | blocked/no_build-Kontext |
| Navigation Nodes | Crossroads, Road-Ends, Bridge-Nodes, Access-/Entry-Nodes | Topologie-Review |
| Navigation Edges | `E_<from>_<to>` | reine Graph-Topologie fuer Review |

Diese Reads sind nur Planung. Sie duerfen nicht automatisch zu Engine-Daten,
Runtime-Koordinaten, Collision-Masks oder produktiven Map-Polygonen werden.

## 7. Was planning_only bleibt

Auch nach diesem Readiness-Check bleiben planning-only:

- alle Koordinaten und Pfadpunkte in der SVG,
- alle Polygone und Formen,
- alle Flaechenfamilien,
- Navigation-Edges und Nodes,
- No-Walk-/No-Build-Lesarten,
- Bridge-/River-/Road-Beziehungen,
- Parcel- und Landmark-Beziehungen,
- Collision- und Reachability-Aussagen,
- jede spaetere Area-Spec-Tabelle, solange kein eigenes Runtime-Gate folgt.

Die Master-SVG darf als Source-of-Truth fuer Dokumentations-/Planungsarbeit
gelten, aber nicht als Runtime-Map.

## 8. Empfehlung fuer den naechsten Slice

Empfehlung:

```text
B) zuerst Area-Specification-Extraktions-Slice planen
```

Begruendung:

- Die Master-SVG ist ID-, Layer- und Graph-seitig stabil genug, um daraus eine
  saubere Planning-Schicht abzuleiten.
- Eine reine Flutter-Preview wuerde die technische Quelle nur anzeigen oder
  visuell interpretieren. Das Risiko waere hoch, wieder Preview-Logik vor
  Area-Spec-Vertrag zu bauen.
- `416` fordert vor spielbaren City-/Island-/Area-Previews eine
  Area-Spec-Struktur mit Boundary, Metrics, Terrain, Water, Paths, Slots,
  Anchors, No-Walk/No-Build, Collision und Reachability.
- Der naechste produktive Schritt ist deshalb eine kontrollierte Extraktion
  von IDs, Layerfamilien und Topologie als Planning-Review, nicht Flutter.

Nicht empfohlen als naechster Schritt:

```text
A) reine Flutter-Preview zuerst
```

Grund:

Flutter darf erst wieder sinnvoll werden, wenn klar ist, welche Teile der SVG
als Planning-Daten gelesen werden duerfen, welche Werte nur Review-Werte sind
und welche Stop-Regeln die Preview gegen Runtime-Fehlschluesse absichern.

## 9. Minimal erlaubte Daten im naechsten Slice

Ein enger naechster Area-Specification-Extraktions-Slice darf minimal
dokumentieren:

- `source_svg_path`,
- `source_svg_sha256`,
- `source_canvas_width`,
- `source_canvas_height`,
- `source_viewBox`,
- Layernamen und Layerrollen,
- Objekt-IDs und Labels,
- Objektfamilien und Zaehler,
- Graph-Endpunkte aus Edge-IDs,
- Bridge-Kettenstatus,
- Parcel Access-/Entry-Paare,
- planning-only Statusfelder,
- QA-Flags wie `resolved`, `needs_review`, `blocked_for_runtime`.

Nur mit ausdruecklicher Folgefreigabe duerfen spaeter Review-Koordinaten als
Planning-Werte erfasst werden. Auch dann bleiben sie `review_px` oder
`normalized_0_1`, nicht Runtime.

Weiterhin nicht erlaubt:

- JSON/YAML/YML,
- Runtime-Koordinaten,
- produktive Polygone,
- Collision-Masks,
- Pathfinding-Daten,
- Flutter-Loader,
- `assets/`-Eintraege,
- App-Integration.

## 10. Stop-Regeln vor Runtime-Ueberfuehrung

Vor einer Runtime-Ueberfuehrung muessen mindestens diese Gates passieren:

- Area-Specification-Extraktion reviewed und freigegeben.
- Koordinatenraum explizit als Planning- oder Runtime-Koordinatenraum
  entschieden.
- Metrics/Reachability/Collision Review auf Basis der Area-Spec abgeschlossen.
- No-Walk und No-Build getrennt validiert.
- River-Crossing-Regeln und Bridge-Ketten validiert.
- Parcel-Access und Landmark-Protection validiert.
- Source-Traceability fuer jede Shape-/Layer-/Anchor-Familie dokumentiert.
- Visual-QA gegen abgeschnittene Labels, Overlap und falsche Layer-Lesart
  bestanden.
- Eigenes Runtime-/Engine-Gate erlaubt explizit Datenformat, Speicherort,
  Loader und Tests.

Bis dahin gilt:

```text
Keine Master-SVG-Daten als Runtime-Daten verwenden.
```

## 11. Dokumentationsvisual

Erzeugt:

- `docs/world_design/previews/firenze_master_technical_layout_readiness_check/firenze_master_technical_layout_readiness_check.svg`
- `docs/world_design/previews/firenze_master_technical_layout_readiness_check/firenze_master_technical_layout_readiness_check.png`

Das Visual zeigt nur:

```text
Master-SVG -> erlaubte Reads -> verbotene Runtime-Ausgaben -> empfohlener naechster Slice
```

Es ist kein App-Screen, kein Asset und keine Runtime-Map.

## 12. Checks

| Check | Ergebnis |
| --- | --- |
| Master-SVG parsebar | PASS |
| Erwartete Layer/Zaehler | PASS |
| Duplicate IDs | PASS (`0`) |
| Sichtbare Standard-IDs | PASS (`0`) |
| Navigation-Edges aufloesbar | PASS (`221/221`) |
| Visual-SVG erzeugt | PASS |
| Visual-PNG erzeugt | PASS |
| Visual-QA | PASS |
| `git diff --check` | PASS |
| Finaler `git status --short` | nur neue Readiness-Dateien |

## 13. Fazit

Die Firenze-Master-SVG ist stabil genug fuer einen naechsten
Area-Specification-Extraktions-Slice als planning-only Schritt.

Freigabe:

- Master-SVG als technische Planungsquelle: YES
- Reine Flutter-Preview als naechster Schritt: NO
- Area-Specification-Extraktions-Slice als naechster Schritt: YES
- Runtime-/JSON-/YAML-/Flutter-/Asset-Freigabe: NO
