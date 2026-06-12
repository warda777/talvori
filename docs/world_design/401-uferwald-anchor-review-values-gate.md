# M16-DR: Uferwald Anchor Review Values Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `anchor_review_values_gate`, `markdown_only`,
`no_yaml_change`, `no_real_values`, `not_runtime_data`

## 1. Zweck und Non-Goals

M16-DR definiert den engen Markdown-Vertrag fuer die erste Uferwald-
Wertfamilie:

```text
anchor_review_values
```

Ziel ist nicht, Werte zu erzeugen. Ziel ist, exakt festzulegen, welche
Felder, Rollen, Modusbezuege und QA-/Statuswerte ein spaeterer M16-DS-Slice
maximal fuer diese Wertfamilie oeffnen duerfte.

M16-DR bleibt Markdown-only. Die bestehende Skeleton-YAML wird nicht
geaendert.

Non-Goals:

- keine Aenderung an
  `docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml`,
- keine neue `.yaml`-Datei,
- keine neue `.yml`-Datei,
- keine neue `.json`-Datei,
- keine echten Werte,
- keine Koordinaten,
- keine Koordinatenbeispiele,
- keine Pixelwerte,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Path-Edges,
- keine Build-Zonen-Polygone,
- keine Plot-Footprint-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine Runtime-Mapdaten,
- keine Assets oder Dateien unter `assets/`,
- keine Bilder, SVGs, PNGs oder Preview-Ordner,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- kein Code,
- kein Commit.

## 2. Eingangsquellen

Gelesene Pflichtgrundlagen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/400-uferwald-measurement-value-gate-preparation.md`
- `docs/world_design/399-uferwald-yaml-planning-skeleton-review.md`
- `docs/world_design/398-uferwald-yaml-planning-skeleton-gate.md`
- `docs/world_design/397-uferwald-json-yaml-planning-format-review.md`
- `docs/world_design/396-uferwald-json-yaml-planning-format-gate.md`
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
- `docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml`

Fuehrende Regel:

> `anchor_review_values` sind keine Anchor-Koordinaten, keine Runtime-Anker
> und keine Interaktionspunkte.

## 3. Warum `anchor_review_values` als erste Wertfamilie geeignet ist

M16-DQ empfiehlt `anchor_review_values` als erste spaeter oeffnungsfaehige
Wertfamilie, weil sie die geringste Gefahr hat, versehentlich Runtime-Daten zu
werden.

Die Familie ist geeignet, wenn sie strikt auf Review-Informationen begrenzt
bleibt:

- bekannte Anchor-IDs duerfen klassifiziert werden,
- Rollen duerfen als Enum vorbereitet werden,
- Modusbezuege duerfen als Review-Kontext beschrieben werden,
- Messpflichten duerfen markiert werden,
- QA- und Blockerstatus duerfen vorbereitet werden,
- Koordinaten, Geometrie und Pixelableitung bleiben vollstaendig verboten.

Der Nutzen ist hoch, weil spaetere Messarbeit wissen muss, welche Anchors nur
Orientierung, Build-Bezug, Wasserbezug, Reserve-Bezug oder Object-Focus-
Bezug sind. Diese Rollen koennen vor einer Messung geklaert werden, ohne
bereits eine technische Spielkarte zu erzeugen.

## 4. Maximalstatus fuer diese Wertfamilie

Fuer `anchor_review_values` gilt maximal:

```text
value_status: review_values_only
runtime_status: not_runtime_data
coordinate_status: no_coordinate_values
geometry_status: no_geometry_values
pixel_derivation_policy: pixel_derivation_forbidden
anchor_runtime_status: not_runtime_anchor
measurement_status: manual_measurement_required
```

Diese Statuswerte bedeuten:

- Die Wertfamilie ist nur ein Review-Vertrag.
- Es entstehen keine echten Werte in M16-DR.
- Ein spaeterer M16-DS-Slice duerfte nur mit expliziter Folgefreigabe eine
  YAML-Erweiterung vorbereiten oder vornehmen.
- Auch in M16-DS duerften nur Reviewwerte entstehen, keine Koordinaten und
  keine Runtime-Anker.

## 5. Erlaubte Felder

Ein spaeterer M16-DS-Slice duerfte maximal diese Feldidee oeffnen. M16-DR
schreibt sie nicht in die YAML.

| Feld | Pflicht fuer spaeter? | Erlaubte Rolle | Grenze |
| --- | --- | --- | --- |
| `value_family` | Ja | Muss `anchor_review_values` sein. | Keine zweite Wertfamilie im selben ersten Value-Pfad. |
| `value_status` | Ja | Muss `review_values_only` sein. | Kein Runtime-, Asset- oder Engine-ready-Status. |
| `anchor_id` | Ja | Bekannte Anchor-ID als String. | Keine Position, keine Koordinate, kein Pixel. |
| `anchor_review_role` | Ja | Eine erlaubte Rollen-Enum aus Abschnitt 7. | Rolle, kein Runtime-Verhalten. |
| `mode_relevance` | Ja | Eine oder mehrere erlaubte Modusreferenzen aus Abschnitt 8. | Nur Kontext, keine Kamera- oder Interaktionslogik. |
| `measurement_requirement` | Ja | Messpflicht oder Blockerstatus. | Keine Messung in diesem Feld. |
| `coordinate_status` | Ja | Muss `no_coordinate_values` sein. | Keine `x`-/`y`-Werte. |
| `geometry_status` | Ja | Muss `no_geometry_values` sein. | Keine Geometriecontainer. |
| `pixel_derivation_policy` | Ja | Muss `pixel_derivation_forbidden` sein. | Keine Ableitung aus Bitmap oder Bildpixeln. |
| `runtime_status` | Ja | Muss `not_runtime_data` sein. | Kein Import, kein Runtime-Manifest. |
| `qa_status` | Ja | Review-/Blockerstatus. | Kein Runtime-Pass. |
| `blocked_uses` | Ja | Liste verbotener Nutzungen. | Darf keine erlaubende Produktionsliste sein. |

Optionale Erklaerfelder waeren in einem spaeteren M16-DS nur erlaubt, wenn
sie keine Werte, Koordinaten oder Runtime-Semantik tragen:

- `review_note`
- `source_doc_reference`
- `next_gate_requirement`

## 6. Erlaubte Anchor-IDs ohne Koordinaten

Diese Anchor-IDs duerfen spaeter als reine IDs referenziert werden:

- `hub_center_anchor`
- `main_build_area_anchor`
- `house_primary_anchor`
- `river_entry_anchor`
- `river_exit_anchor`
- `grove_anchor`
- `reserve_zone_anchor_north`
- `reserve_zone_anchor_south`
- `startplatz_anchor`
- `aussichtspunkt_anchor`

Regeln:

- Die Liste ist keine Koordinatenliste.
- Die Reihenfolge der IDs ist keine Prioritaet.
- Eine ID ist kein Runtime-Anchor.
- Eine ID ist kein gespeicherter Interaktionspunkt.
- Eine ID darf nicht automatisch aus Candidate-Bitmap, SVG-Visual oder
  Preview-Pixeln abgeleitet werden.

Neue Anchor-IDs duerfen erst nach einem eigenen Anchor-ID-Review ergaenzt
werden.

## 7. Erlaubte Rollen-Enums

Fuer `anchor_review_role` sind maximal diese Rollen erlaubt:

| Enum | Bedeutung | Harte Grenze |
| --- | --- | --- |
| `landmark` | Orientierungspunkt oder visuelles Merkmal. | Kein Path-Node, kein Runtime-Ziel. |
| `hub_reference` | Bezug zum Treffpunkt, Hub oder zentraler Lichtung. | Keine Hub-Koordinate. |
| `build_reference` | Bezug fuer spaetere Build-Review-Arbeit. | Kein Plot, Slot oder Footprint. |
| `object_focus_reference` | Bezug fuer spaeteren Object-Focus-Kontext. | Kein gespeicherter Fokuspunkt. |
| `river_reference` | Bezug zu River Entry/Exit, Ufer oder Wasserlogik. | Keine Wassergrenze. |
| `grove_reference` | Bezug zum Hain-/Waldkontext. | Kein Baumblocker-Wert. |
| `reserve_reference` | Bezug zu Reserve- oder Zukunftsbereichen. | Keine Build-Zone. |
| `path_orientation_reference` | Orientierung fuer spaetere Pfadplanung. | Kein Path-Node, keine Centerline. |

Nicht erlaubt sind Rollen, die direkt Runtime-Verhalten suggerieren:

- `runtime_anchor`,
- `path_node`,
- `path_edge`,
- `interaction_point`,
- `stored_interaction_point`,
- `build_slot`,
- `category_plot`.

## 8. Erlaubte Modusbezuege

`mode_relevance` darf nur diese Review-Modi referenzieren:

- `Build/Map`
- `Overview`
- `Visit/Wander`
- `Object Focus`

Modusbezug bedeutet:

- Der Anchor ist fuer die spaetere Betrachtung dieses Modus relevant.
- Der Anchor wird dadurch nicht in diesem Modus nutzbar.
- Es entsteht keine Kamera-Regel, keine Pan-/Zoom-Logik, keine Navigation und
  keine Interaktion.

## 9. Erlaubte QA-/Statuswerte

Fuer `measurement_requirement` sind erlaubt:

- `manual_measurement_required`
- `blocked_until_measurement_gate`
- `review_required_before_yaml_values`

Fuer `coordinate_status` ist nur erlaubt:

- `no_coordinate_values`

Fuer `geometry_status` ist nur erlaubt:

- `no_geometry_values`

Fuer `pixel_derivation_policy` ist nur erlaubt:

- `pixel_derivation_forbidden`

Fuer `runtime_status` ist nur erlaubt:

- `not_runtime_data`

Fuer `qa_status` sind erlaubt:

- `review_required`
- `not_runtime_anchor`
- `blocked_until_measurement_gate`
- `blocked_until_yaml_update_gate`

Diese Statuswerte sind Schutzwerte. Sie duerfen nicht als Freigabe fuer
Messwerte, Runtime-Import oder App-Integration gelesen werden.

## 10. Verbotene Felder und Werte

Weiterhin verboten:

- `normalized_x`
- `normalized_y`
- `x`
- `y`
- Koordinatenpaare,
- Pixelwerte,
- `polygon_points`
- `geometry_values`
- `coordinate_values`
- `path_centerline`
- `path_nodes`
- `path_edges`
- `build_zone_polygons`
- `plot_footprint_polygons`
- `no_walk_union_values`
- `no_build_union_values`
- `runtime_anchor`
- `stored_interaction_point`
- `runtime_status: runtime_ready`
- `asset_status: asset`
- `engine_status: engine_ready`
- `source_from_pixels`
- `derived_from_bitmap`

Ebenfalls verboten:

- leere Geometriecontainer wie `points: []`,
- Platzhalter, die wie spaetere Punktlisten wirken,
- numerische Beispielwerte,
- Prozent- oder Pixelbeispiele,
- automatische Ableitung aus dem Uferwald-Bitmap,
- automatische Ableitung aus M16-DI- oder M16-CR-Visuals,
- Runtime-Namen, die wie produktive Engine-Daten wirken.

## 11. QA-Pflichten vor einer spaeteren YAML-Aenderung

Ein spaeterer M16-DS-Slice darf nur vorbereitet werden, wenn diese QA-Fragen
im Prompt oder im Slice selbst mit JA beantwortet werden koennen:

| QA-Frage | Muss JA sein |
| --- | --- |
| Wird genau eine Wertfamilie geoeffnet? | Ja |
| Ist diese Wertfamilie `anchor_review_values`? | Ja |
| Bleibt die bestehende YAML bis zum M16-DS-Prompt unveraendert? | Ja |
| Oeffnet M16-DS exakt eine bestehende YAML-Datei, falls ueberhaupt? | Ja |
| Bleibt `value_status` `review_values_only`? | Ja |
| Bleibt `runtime_status` `not_runtime_data`? | Ja |
| Bleibt `coordinate_status` `no_coordinate_values`? | Ja |
| Bleibt `geometry_status` `no_geometry_values`? | Ja |
| Bleibt `pixel_derivation_policy` `pixel_derivation_forbidden`? | Ja |
| Sind Koordinaten, Pixelwerte und Beispiele verboten? | Ja |
| Sind Polygone, Path-Werte und No-Walk-/No-Build-Unionen verboten? | Ja |
| Bleiben Assets, Code, App-Integration, Persistenz und BuildState blockiert? | Ja |
| Gibt es Datei-Checks gegen neue `.json`, `.yml` und zusaetzliche `.yaml`? | Ja |
| Gibt es einen Scope-Check gegen `lib`, `assets`, Tests und Plattformordner? | Ja |

Wenn eine Antwort NEIN ist, ist M16-DS nicht bereit und es braucht zuerst
einen M16-DR-FIX oder einen engeren Folgeprompt.

## 12. Entscheidung zu M16-DS

| Frage | Entscheidung |
| --- | --- |
| Ist der `anchor_review_values`-Feldvertrag ausreichend? | JA |
| Braucht es zuerst M16-DR-FIX? | NEIN |
| Darf M16-DS als enger YAML-Update-Gate-Slice vorbereitet werden? | JA |
| Darf M16-DS automatisch echte Werte erzeugen? | NEIN |
| Darf M16-DS automatisch Runtime-Daten erzeugen? | NEIN |
| Darf M16-DS automatisch Koordinaten oder Polygone erzeugen? | NEIN |
| Darf M16-DS die bestehende Skeleton-YAML aendern? | Nur mit expliziter M16-DS-Folgefreigabe, exakt einem Pfad, genau einer Wertfamilie und allen Status-/Datei-/Scope-Checks. |

Empfohlener Folge-Slice:

```text
M16-DS Uferwald Anchor Review Values YAML Update Gate
```

M16-DS sollte nur dann die bestehende Skeleton-YAML aendern duerfen, wenn der
Prompt den exakten Pfad, die eine erlaubte Feldfamilie, die erlaubten
Statuswerte, alle verbotenen Felder und den Datei-Check erneut ausdruecklich
oeffnet.

## 13. Nicht-Freigaben

M16-DR gibt nicht frei:

- keine YAML-Aenderung,
- keine neue YAML-/YML-/JSON-Datei,
- keine echten `anchor_review_values`,
- keine Koordinaten,
- keine Koordinatenbeispiele,
- keine Pixelwerte,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Path-Edges,
- keine Build-Zonen-Polygone,
- keine Plot-Footprint-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine Runtime-Mapdaten,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder, SVGs, PNGs oder Preview-Ordner,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine externen Writes,
- kein Commit.

M16-DR ist ein Vertrag. Die erste echte Datei- oder YAML-Naehe bleibt bis
M16-DS blockiert.
