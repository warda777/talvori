# M16-DM: Uferwald JSON/YAML Planning Format Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `format_gate`, `markdown_only`,
`not_json_file`, `not_yaml_file`, `not_runtime_data`

## 1. Zweck

M16-DM definiert sehr eng, wie eine spaetere Uferwald-JSON/YAML-
Planungsstruktur aussehen duerfte. Der Slice legt Formatregeln, erlaubte
Feldgruppen, Pflichtstatus, verbotene Werte und QA-Regeln fest.

M16-DM erzeugt keine echte `.json`-, `.yaml`- oder `.yml`-Datei. Es erzeugt
keine Beispiel-Datei, keine Runtime-Daten, keine finalen Koordinaten, keine
Polygone, keine Path-Centerlines, keine Path-Nodes, keine Assets und keinen
Code.

Fuehrende Regel:

> M16-DM beschreibt ein spaeteres Planungsformat, aber keine Planungsdatei.

## 2. Eingangsquellen

Gelesene Pflichtgrundlagen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/395-uferwald-planning-schema-review.md`
- `docs/world_design/394-uferwald-technical-planning-schema-gate.md`
- `docs/world_design/393-uferwald-visual-precision-review.md`
- `docs/world_design/392-uferwald-measurement-visual-precision-pass.md`
- `docs/world_design/391-uferwald-measurement-precision-pass.md`
- `docs/world_design/390-uferwald-technical-measurement-review.md`
- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`

Diese Dokumente definieren die Grenze: Uferwald braucht technische Layer,
Masks, Zonen, Anker, Sort-Bands und Mess-QA, aber technische Werte duerfen
nicht aus Pixelbildern geraten und nicht als Runtime-Daten vorgezogen werden.

## 3. Formatentscheidung

Erstes bevorzugtes Planning-Format:

```text
YAML
```

Begruendung:

- YAML ist fuer Andreas und Review-Slices besser lesbar als JSON.
- YAML kann Feldgruppen, Statusschutz und offene Messfragen kompakter zeigen.
- YAML passt zu fruehen Planning-Skeletons, solange es klar `not_runtime_data`
  bleibt.
- YAML ist leichter als Markdown-Snippet zu diskutieren, ohne sofort wie ein
  App- oder Runtime-Importformat zu wirken.

JSON bleibt spaeter moeglich, aber nicht als erstes Planning-Format. JSON ist
strenger und maschinennaeher; genau deshalb ist das Risiko hoeher, dass eine
fruehe Planungsdatei zu schnell als Runtime-Manifest gelesen wird.

Entscheidung:

| Frage | Entscheidung |
| --- | --- |
| Erstes Planning-Format | YAML |
| JSON als Alternative | Spaeter moeglich, nach Review |
| Echte Datei in M16-DM | NEIN |
| Echte Skeleton-Datei direkt danach | NEIN, zuerst M16-DN Review |
| Runtime-Status | Weiter blockiert |

## 4. Wann eine echte Datei erlaubt waere

Eine echte `.yaml`, `.yml` oder `.json` Datei ist erst erlaubt, wenn ein
spaeterer Slice alle folgenden Punkte ausdruecklich oeffnet:

1. Der Folgeprompt nennt den genauen erlaubten Pfad.
2. Der Folgeprompt nennt den Dateinamen.
3. Der Folgeprompt bestaetigt den Maximalstatus `planning_skeleton`.
4. Der Folgeprompt verbietet weiterhin Runtime-Daten.
5. Der Folgeprompt verbietet weiterhin Geometriewerte.
6. Der Folgeprompt verbietet weiterhin finale Koordinaten.
7. Der Folgeprompt verbietet weiterhin Polygonpunkte.
8. Der Folgeprompt verbietet weiterhin Path-Centerlines und Path-Nodes.
9. Der Folgeprompt verlangt einen Datei-Check gegen neue unerlaubte
   `.json`-, `.yaml`- und `.yml`-Dateien.

Ohne diese ausdrueckliche Freigabe bleiben echte Dateien blockiert.

## 5. Spaeter erlaubter Pfad

Vorgeschlagener spaeterer Pfad, noch nicht anzulegen:

```text
docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml
```

Dieser Pfad waere nur fuer ein spaeteres Planning-Skeleton erlaubt, nicht fuer
Runtime-Daten.

Pfadregeln:

- nur unter `docs/world_design/planning/`,
- keine Dateien unter `assets/`,
- keine App-/Flutter-Pfade,
- keine generierten Runtime-Artefakte,
- kein Importpfad fuer produktive Logik,
- kein BuildState,
- keine Persistenz.

Wenn spaeter JSON statt YAML gewaehlt wird, muss ein Review-Slice das vorher
neu entscheiden. Ein paralleles YAML- und JSON-Doppelmodell ist bis dahin
blockiert.

## 6. Pflichtstatuswerte

Jede spaetere Planungsdatei muss diese Statuswerte oder sinngleiche harte
Schutzfelder enthalten:

| Feld | Pflichtwert / erlaubter Wert | Zweck |
| --- | --- | --- |
| `format_status` | `planning_skeleton` | Maximalstatus einer ersten echten Datei. |
| `runtime_status` | `not_runtime_data` | Kein Runtime-Manifest. |
| `asset_status` | `not_asset` | Kein Asset, keine Datei unter `assets/`. |
| `engine_status` | `not_engine_ready` | Kein Engine-ready Candidate. |
| `geometry_status` | `no_geometry_values` | Keine echten Werte. |
| `coordinate_status` | `no_final_coordinates` | Keine finalen Koordinaten. |
| `pixel_derivation_policy` | `pixel_derivation_forbidden` | Keine Ableitung aus Pixelbildern. |
| `measurement_status` | `manual_measurement_required` | Echte Messung bleibt offen. |
| `runtime_review_requirement` | `runtime_review_required_before_use` | Runtime braucht eigenes Gate. |
| `source_truth_policy` | `technical_layers_not_art_pixels` | Sichtbares Bild bleibt Review-Kontext. |

Diese Statuswerte sind Pflicht, damit ein spaeteres Skeleton nicht als
Produktionsdaten missverstanden wird.

## 7. Erlaubte Feldgruppen

Eine spaetere YAML-Planning-Skeleton-Datei duerfte nur Feldgruppen enthalten,
die Struktur, Status, offene Messfragen und QA beschreiben.

Erlaubte Feldgruppen:

| Feldgruppe | Erlaubt | Zweck |
| --- | --- | --- |
| `schema_header` | Ja | ID, Slice, Map-ID, Statusschutz, Source Docs. |
| `format_contract` | Ja | Format, Version, maximale Freigabegrenze. |
| `status_protection` | Ja | `not_runtime_data`, `not_asset`, `no_geometry_values`. |
| `source_docs` | Ja | Gelesene Pflichtgrundlagen. |
| `visual_references` | Ja | Nur Review-Kontext, keine technische Quelle. |
| `layer_definitions` | Ja | Layer-IDs, Rollen, erlaubte Modi, Blocker. |
| `geometry_placeholders` | Ja | Nur Platzhalter, keine Werte. |
| `qa_requirements` | Ja | Pflicht-QA vor Messung, Skeleton, Runtime. |
| `open_measurements` | Ja | Offene Fragen fuer spaetere manuelle/vectorbasierte Messung. |
| `blocked_scope` | Ja | Verbotene Nutzungen. |
| `next_review_gate` | Ja | Naechster Review vor echter Datei oder Runtime. |

## 8. Erlaubte Layer-Felder

Pro Layer duerften spaeter diese Felder existieren:

| Feld | Erlaubt | Regel |
| --- | --- | --- |
| `layer_id` | Ja | Nur bekannte Layer-IDs aus 394. |
| `layer_role` | Ja | Fachrolle, keine Runtime-Funktion. |
| `layer_status` | Ja | `planned`, `not_measured`, `manual_measurement_required`. |
| `allowed_modes` | Ja | Build/Map, Visit/Wander, Object Focus, Overview. |
| `data_form_candidates` | Ja | Nur Kandidaten wie Polygon, Corridor, Mask, Anchor. |
| `source_of_truth_policy` | Ja | Technische Planung fuehrend, Bild nur Review. |
| `pixel_derivation_policy` | Ja | Muss `pixel_derivation_forbidden` bleiben. |
| `manual_measurement_requirement` | Ja | Welche Messung spaeter noetig ist. |
| `runtime_review_requirement` | Ja | Welches Gate vor Runtime noetig ist. |
| `qa_requirements` | Ja | QA-Felder, noch keine Ergebnisse mit Runtime-Freigabe. |
| `open_measurements` | Ja | Offene Messfragen. |
| `blocked_uses` | Ja | Verbotene Nutzungen. |
| `notes` | Ja | Erklaerung, keine technischen Werte. |

## 9. Verbotene Felder und Werte

Diese Felder bleiben in M16-DM und in einem ersten Skeleton weiterhin
verboten:

| Feld / Wert | Status | Grund |
| --- | --- | --- |
| `geometry_values` | verboten | Wuerde echte Geometrie oeffnen. |
| `coordinate_values` | verboten | Wuerde Koordinaten als Daten setzen. |
| `polygon_points` | verboten | Wuerde Polygone erzeugen. |
| `path_centerline` | verboten | Wuerde Runtime-Pathing andeuten. |
| `path_nodes` | verboten | Wuerde Bewegungsgraph vorbereiten. |
| `path_edges` | verboten | Wuerde Bewegungsgraph vorbereiten. |
| `build_zone_polygons` | verboten | Wuerde Build-Zonen als echte Geometrie setzen. |
| `plot_footprint_polygons` | verboten | Wuerde Footprints als echte Geometrie setzen. |
| `no_walk_union_values` | verboten | Wuerde Bewegungsmaske als echte Werte setzen. |
| `no_build_union_values` | verboten | Wuerde Bausperre als echte Werte setzen. |
| `runtime_status: runtime_ready` | verboten | Runtime-Freigabe bleibt blockiert. |
| `asset_status: asset` | verboten | Asset-Freigabe bleibt blockiert. |
| `engine_status: engine_ready` | verboten | Engine-ready bleibt blockiert. |
| `source_from_pixels` | verboten | Pixelableitung bleibt blockiert. |

## 10. Erlaubte Platzhalter

Erlaubt sind nur Platzhalter, die keinen Wert vortaeuschen:

| Platzhalter | Erlaubt | Regel |
| --- | --- | --- |
| `geometry_kind_candidate` | Ja | Nur Typidee, zum Beispiel `polygon_candidate` oder `corridor_candidate`. |
| `geometry_status` | Ja | Muss `not_measured` oder `manual_measurement_required` sein. |
| `coordinate_space` | Ja | Konvention wie `normalized_0_1`, aber keine Werte. |
| `anchor_role_candidate` | Ja | Rolle, kein Anchor-Wert. |
| `sort_band_role_candidate` | Ja | Rolle, keine Renderer-Regel. |
| `measurement_question` | Ja | Offene Frage, keine Antwort. |
| `qa_required` | Ja | Pruefpflicht, kein Runtime-Pass. |
| `blocked_until_gate` | Ja | Blockerstatus. |

Platzhalter duerfen nicht mit `todo_x: 0.42` oder aehnlichen Scheinwerten
gefuellt werden.

## 11. Illustrativer Schema-Snippet

Der folgende Block ist kein Dateiinhalt und darf nicht als `.yaml` gespeichert
werden. Er zeigt nur die erlaubte Strukturform.

Status des Blocks:

```text
illustrative_schema_snippet
not_file
not_runtime_data
no_geometry_values
no_final_coordinates
```

```yaml
schema_header:
  schema_id: illustrative_schema_snippet_only
  slice_id: M16-DM
  map_id: uferwald_starter_island
  format_status: planning_format_documentation_only
  runtime_status: not_runtime_data
  asset_status: not_asset
  geometry_status: no_geometry_values

layer_definitions:
  - layer_id: walkable_path_layer
    layer_role: path_corridor_planning
    layer_status: manual_measurement_required
    pixel_derivation_policy: pixel_derivation_forbidden
    geometry_placeholders:
      geometry_kind_candidate: corridor_candidate
      geometry_status: not_measured
      geometry_values: forbidden
      coordinate_values: forbidden
      polygon_points: forbidden
    qa_requirements:
      - qa_path_vs_water_check_required
      - qa_path_vs_obstacle_check_required
      - qa_runtime_status_check_required
    open_measurements:
      - measure_path_corridor_later_in_separate_gate
    blocked_uses:
      - runtime_pathfinding
      - path_centerline
      - path_nodes
```

Dieser Snippet ist absichtlich unvollstaendig. Er beweist keine Struktur und
ist keine Vorlage zum Kopieren in eine Datei.

## 12. QA-Regeln vor jeder echten Datei

Vor jeder echten `.yaml`, `.yml` oder `.json` Datei muss ein Folge-Slice diese
Fragen mit JA beantworten:

| QA-Frage | Muss JA sein |
| --- | --- |
| Ist der Pfad ausdruecklich freigegeben? | Ja |
| Ist der Dateiname ausdruecklich freigegeben? | Ja |
| Ist der Maximalstatus `planning_skeleton`? | Ja |
| Sind Runtime-Daten blockiert? | Ja |
| Sind finale Koordinaten blockiert? | Ja |
| Sind Polygonpunkte blockiert? | Ja |
| Sind Path-Centerlines blockiert? | Ja |
| Sind Path-Nodes und Path-Edges blockiert? | Ja |
| Sind Build-Zonen-Polygone blockiert? | Ja |
| Sind No-Walk-/No-Build-Unionen als echte Werte blockiert? | Ja |
| Ist Pixelableitung blockiert? | Ja |
| Ist `assets/` blockiert? | Ja |
| Ist App-/Flutter-Integration blockiert? | Ja |
| Gibt es einen Datei-Check gegen unerlaubte `.json`, `.yaml`, `.yml`? | Ja |

Wenn eine Antwort NEIN ist, ist der Folge-Slice nicht commitfaehig.

## 13. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| JSON oder YAML als erstes Planning-Format? | YAML |
| Echte Datei-Erzeugung in M16-DM erlaubt? | NEIN |
| Echte Koordinaten erlaubt? | NEIN |
| Polygonpunkte erlaubt? | NEIN |
| Path-Centerlines erlaubt? | NEIN |
| Path-Nodes erlaubt? | NEIN |
| Build-Zonen-Polygone erlaubt? | NEIN |
| No-Walk-/No-Build-Unionen als echte Werte erlaubt? | NEIN |
| Pixelableitung erlaubt? | NEIN |
| Runtime-Status erlaubt? | NEIN |
| Darf direkt danach ein Skeleton-Slice starten? | NEIN, zuerst Review |

## 14. Folgepfad

Empfohlener naechster Slice:

```text
M16-DN Uferwald JSON/YAML Planning Format Review
```

M16-DN soll M16-DM pruefen und entscheiden, ob die Formatregeln ausreichend
sind. Erst danach kann ein sehr enger Skeleton-Slice vorbereitet werden, zum
Beispiel:

```text
M16-DO Uferwald YAML Planning Skeleton Gate
```

Auch M16-DO duerfte nur dann eine echte Datei erzeugen, wenn der Prompt den
Pfad und Status explizit oeffnet und alle M16-DM-Verbote wiederholt.

## 15. Nicht-Freigaben

M16-DM gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine `.json`-Datei,
- keine `.yaml`-Datei,
- keine `.yml`-Datei,
- keine finale Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Build-Zonen-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine Bilder,
- keine SVG/PNG-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Figma-Writes,
- keine externen Writes,
- keinen Commit.
