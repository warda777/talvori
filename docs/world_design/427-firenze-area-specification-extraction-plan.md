# 427: Firenze Area-Specification Extraction Plan

Stand: 2026-06-18

Status: `documentation_only` / `extraction_plan` / `planning_only` /
`not_runtime_data` / `no_json_yaml` / `no_flutter` / `no_app_integration` /
`no_assets` / `no_commit`

## 1. Ziel

Dieser Slice plant den naechsten kontrollierten Schritt nach `426`.

Ziel:

- definieren, wie die bereinigte Florenz-Master-SVG spaeter in eine
  planning-only Area-Spec ueberfuehrt werden darf,
- festlegen, welche Familien und Felder gelesen werden duerfen,
- harte Stop-Regeln fuer den spaeteren Extraktions-Slice setzen,
- verhindern, dass SVG-Geometrie ungeprueft zu Runtime-, Flutter-,
  Collision-, Pathfinding- oder JSON/YAML-Daten wird.

Quelle fuer den spaeteren Extraktions-Slice:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg
```

Dieser Slice extrahiert noch keine Area-Spec.

## 2. Non-Goals

- keine Area-Specification-Extraktion,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine produktiven Polygone,
- keine Collision-Daten,
- keine Pathfinding-Daten,
- keine Flutter-Daten,
- keine JSON-/YAML-/YML-Datei,
- keine Aenderungen an `lib/`,
- keine Aenderungen an `pubspec.yaml`,
- keine Dateien unter `assets/`,
- keine App-Integration,
- kein Commit.

## 3. Gelesene Grundlagen

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`

`328` wurde als uebergeordnete Produkt- und Readiness-Leitplanke geprueft.
Der dort gefuehrte Firenze-/World-Pfad bestaetigt, dass Folgearbeit `416` und
`417` anwenden muss, aendert aber den engen Scope dieses Slices nicht: `427`
bleibt planning-only, ohne Runtime-Daten, ohne JSON/YAML, ohne Flutter-Preview
und ohne Aenderungen an `lib/`, `pubspec.yaml` oder `assets/`.

## 4. Startstatus

| Check | Ergebnis |
| --- | --- |
| `git status --short` vor Start | sauber |
| `git log --oneline -5` HEAD | `5ac941c5 docs: add firenze master readiness check` |
| Master-SVG vorhanden | YES |
| Master-SVG parsebar | YES |
| Erwartete Layer/Counts auffindbar | YES |

## 5. Master-SVG Erwartungswerte

| Familie | Erwartet | Geprueft |
| --- | ---: | ---: |
| Boundary | 1 | 1 |
| River | 1 | 1 |
| Bridges | 8 | 8 |
| Main Roads | 7 | 7 |
| Side Roads | 42 | 42 |
| Parcels | 14 | 14 |
| Landmarks | 6 | 6 |
| Green Areas | 48 | 48 |
| Urban Blocks | 37 | 37 |
| Anchor Points | 48 | 48 |
| Navigation Nodes | 181 | 181 |
| Navigation Edges | 221 | 221 |

Zusatzstatus aus der Pruefung:

- Source-SVG SHA-256:
  `58d7f5cf0d6d09d8d42dbe03f74d0439b7f231787e1d0b8acad84002eaa733d3`
- Canvas: `1672 x 941`
- ViewBox: `0 0 442.38333 248.97292`
- Duplicate IDs: `0`
- sichtbare Standard-IDs: `0`
- Navigation-Edges aufloesbar: `221/221`
- offene `E_needs_manual_review`: `0`

## 6. Ziel des kommenden Extraktions-Slices

Der kommende Slice soll eine planning-only Area-Specification-Extraktion v1
vorbereiten oder erzeugen, ohne Runtime-Daten freizugeben.

Er soll aus der Master-SVG lesen:

- Source-Metadaten der SVG,
- Layer-IDs und Layerrollen,
- Objekt-IDs und Labels,
- Objektfamilien und Zaehler,
- Topologie aus Navigation-Edge-Namen,
- Bridge-, Parcel-, Landmark- und Anchor-Beziehungen als Review-Struktur,
- Review-Flags fuer No-Walk-/No-Build-Kandidaten,
- blockierende Risiken fuer spaetere Runtime-Ueberfuehrung.

Er darf nur planning-only bleiben:

- alle Formen,
- alle Pfadpunkte,
- alle Koordinaten,
- alle Graph-Beziehungen,
- alle No-Walk-/No-Build-Lesarten,
- alle Collision-/Reachability-Aussagen,
- alle Rollen wie Parcel, Landmark, River, Urban Block und Road.

Er darf noch nicht Runtime werden:

- keine Engine-Map,
- keine Flutter-Datenstruktur,
- keine produktive Geometry,
- keine echte Collision-Maske,
- kein Pathfinding-Graph,
- kein Build-Slot-State,
- kein JSON/YAML-Manifest.

## 7. Erlaubte Extraktionsfamilien

| Familie | IDs / Layer | Planungsrolle | Runtime-Status |
| --- | --- | --- | --- |
| Boundary | `01_boundary`, `boundary_playable_firenze` | playable boundary candidate | blocked |
| River | `02_river_area`, `river_arno_area` | no_walk/no_build water candidate | blocked |
| Bridges | `bridge_B01`-`bridge_B08` | crossing/bridge candidate | blocked |
| Main Roads | `main_road_001`-`main_road_007` | primary walk/path candidate | blocked |
| Side Roads | `side_road_001`-`side_road_042` | secondary walk/path candidate | blocked |
| Parcels | `P01`-`P14` | parcel candidate / enterable portal | blocked |
| Landmarks | `L01`-`L06` | protected landmark core candidate | blocked |
| Green Areas | `G01`-`G48` | vegetation / spacing candidate | blocked |
| Urban Blocks | `U01`-`U37` | blocked/no_build context candidate | blocked |
| Anchor Points | `P##_anchor`, `B##_anchor`, city anchors | anchor candidate | blocked |
| Navigation Nodes | crossroads, access, entry, bridge, road-end nodes | topology candidate | blocked |
| Navigation Edges | `E_<from>_<to>` | topology relationship candidate | blocked |

## 8. Minimal erlaubte Felder

Der kommende Extraktions-Slice darf nur diese Feldfamilien planen oder
ausgeben, solange kein eigenes Format-Gate anderes erlaubt.

| Feld | Bedeutung | Grenze |
| --- | --- | --- |
| `source_svg_path` | Pfad zur Master-SVG | Dokumentationsquelle |
| `source_svg_sha256` | erwarteter Quellenhash | Stop-Regel bei Abweichung |
| `canvas_width` | SVG-Breite | Review-Metadatum, nicht Runtime |
| `canvas_height` | SVG-Hoehe | Review-Metadatum, nicht Runtime |
| `viewBox` | SVG-ViewBox | Review-Metadatum, nicht Runtime |
| `layer_id` | Layername aus der SVG | Layer Registry |
| `object_id` | Objekt-ID oder Label | Object Registry |
| `label` | lesbares Label | Object Registry |
| `family` | Boundary, River, Road, Parcel usw. | Review-Klassifikation |
| `role` | Planungsrolle | keine Engine-Rolle |
| `planning_status` | z. B. candidate_only, review_needed | kein BuildState |
| `no_walk_candidate` | Planungsflag | keine Runtime-Maske |
| `no_build_candidate` | Planungsflag | keine Runtime-Maske |
| `graph_from` | Edge-Start aus ID | topology registry |
| `graph_to` | Edge-Ziel aus ID | topology registry |
| `needs_review` | QA-/Review-Flag | keine Runtime-Entscheidung |
| `blocked_for_runtime` | Stop-Flag | schuetzt vor Ueberfuehrung |
| `source_trace` | Herkunft/Herleitung | Pflicht fuer Nachvollziehbarkeit |

Nicht erlaubt:

- produktive Koordinaten,
- finale Polygone,
- Collision-Daten,
- Pathfinding-Daten,
- Flutter-/Dart-Daten,
- JSON-/YAML-/YML-Dateien,
- Asset-Metadaten unter `assets/`.

## 9. Trennung der Datenarten

### 9.1 `source metadata`

Enthaelt nur:

- `source_svg_path`,
- `source_svg_sha256`,
- `canvas_width`,
- `canvas_height`,
- `viewBox`,
- relevante gelesene Dokumente,
- Extraktionsdatum im spaeteren Report.

Zweck:

- sicherstellen, dass der spaetere Slice gegen die erwartete Master-SVG laeuft.

### 9.2 `layer registry`

Enthaelt nur:

- `layer_id`,
- `family`,
- erwartete Zaehler,
- gefundene Zaehler,
- `planning_status`,
- `blocked_for_runtime`.

Zweck:

- pruefen, ob die Master-SVG dieselbe technische Layer-Struktur hat.

### 9.3 `object registry`

Enthaelt nur:

- `object_id`,
- `label`,
- `layer_id`,
- `family`,
- `role`,
- `planning_status`,
- `source_trace`.

Zweck:

- Objekte benennen und Rollen fuer Review dokumentieren.

### 9.4 `topology registry`

Enthaelt nur:

- Navigation-Edge-ID,
- `graph_from`,
- `graph_to`,
- Node-Familie,
- Bridge-/Access-/Entry-Bezug,
- `needs_review`,
- `blocked_for_runtime`.

Zweck:

- Graph-Topologie fuer Walkability-/Reachability-Review vorbereiten.

Keine Weglaengen, keine Pfadgewichte, keine Runtime-Adjacency.

### 9.5 `review flags`

Enthaelt nur:

- `no_walk_candidate`,
- `no_build_candidate`,
- `needs_review`,
- `blocked_for_runtime`,
- `source_trace`,
- optionale Begruendung.

Zweck:

- spaetere Reviews lenken, nicht Runtime-Verhalten erzeugen.

### 9.6 `forbidden runtime data`

Ausdruecklich verboten:

- produktive Koordinaten,
- SVG-Pfadpunkte als Runtime-Polygon,
- Collision-Masks,
- Pathfinding-Graph,
- Build-Slot-State,
- Runtime-No-Walk-/No-Build-Masks,
- Flutter-Loader,
- JSON/YAML-Manifest,
- Dateien unter `assets/`.

## 10. Stop-Regeln fuer den spaeteren Extraktions-Slice

Der spaetere Extraktions-Slice muss sofort stoppen, wenn:

- die Master-SVG fehlt,
- der SHA-256 unerwartet anders ist,
- erwartete Layer fehlen,
- erwartete Counts abweichen,
- IDs doppelt sind,
- sichtbare Standard-IDs wieder auftauchen,
- Edge-Endpunkte nicht aufloesbar sind,
- offene `E_needs_manual_review`-Edges existieren,
- `P01`-`P14` nicht vollstaendig sind,
- `B01`-`B08` nicht vollstaendig sind,
- Access-/Entry-Verbindungen nicht vollstaendig sind,
- JSON/YAML verlangt wird, aber kein eigenes Format-Gate freigegeben ist,
- `lib/`, `pubspec.yaml`, `assets/` oder Runtime-Dateien geaendert werden
  muessten,
- eine Koordinaten-/Collision-/Flutter-Nutzung als Ergebnis erwartet wird.

## 11. Empfohlener naechster Slice

Empfohlene Bezeichnung:

```text
Firenze Area-Specification Planning Extraction v1
```

Scope dieses naechsten Slices:

- planning-only,
- Markdown-Report oder Markdown-Tabellen,
- keine JSON/YAML/YML-Datei,
- keine Runtime-Daten,
- keine finalen Koordinaten,
- keine Flutter-Preview,
- keine App-Integration.

Minimalziel:

- aus der Master-SVG genau die erlaubten Registries als Review-Struktur
  dokumentieren,
- jeden gelesenen Wert mit `blocked_for_runtime: true` oder aequivalenter
  Markdown-Statusmarkierung schuetzen,
- Abweichungen gegen `426` als Blocker berichten.

## 12. Dokumentationsvisual

Erzeugt:

- `docs/world_design/previews/firenze_area_specification_extraction_plan/firenze_area_specification_extraction_plan.svg`
- `docs/world_design/previews/firenze_area_specification_extraction_plan/firenze_area_specification_extraction_plan.png`

Visual-Inhalt:

```text
Master-SVG -> Extraction Plan -> Planning Registries -> Review Gates -> spaeteres Runtime-Gate gesperrt
```

Es ist kein App-Screen, kein Asset und keine Runtime-Map.

## 13. Checks

| Check | Ergebnis |
| --- | --- |
| Start-`git status --short` | sauber |
| `git log --oneline -5` | HEAD `5ac941c5` bestaetigt |
| Master-SVG vorhanden | PASS |
| Master-SVG parsebar | PASS |
| Erwartete Counts | PASS |
| Duplicate IDs | PASS (`0`) |
| sichtbare Standard-IDs | PASS (`0`) |
| Navigation-Edges aufloesbar | PASS (`221/221`) |
| SVG-Dokumentationsvisual erzeugt | PASS |
| PNG-Dokumentationsvisual erzeugt | PASS |
| Visual-QA | PASS |
| `git diff --check` | PASS |

## 14. Entscheidung

Freigabe:

- Extraction Plan fuer Firenze: YES
- Naechster Slice `Firenze Area-Specification Planning Extraction v1`: YES
- Runtime-Daten: NO
- JSON/YAML/YML: NO
- Flutter-Preview: NO
- `lib/`, `pubspec.yaml`, `assets/`: NO

Dieser Slice ist die fachliche Leitplanke fuer den naechsten planning-only
Extraktionsschritt. Er ersetzt keine Area-Spec und gibt keine Runtime frei.
