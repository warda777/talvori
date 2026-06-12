# M16-DP: Uferwald YAML Planning Skeleton Review

Stand: 2026-06-12

Status: `review_slice`, `yaml_skeleton_review`, `no_new_yaml`,
`not_runtime_data`, `not_asset`, `not_engine_ready`

## 1. Zweck

M16-DP reviewt das M16-DO Uferwald YAML Planning Skeleton Gate und die erste
echte YAML-Planning-Skeleton-Datei:

```text
docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml
```

Ziel ist die Entscheidung, ob M16-DO fachlich und technisch sauber genug ist,
oder ob ein M16-DO-FIX noetig wird.

M16-DP erzeugt keine neue `.yaml`, `.yml` oder `.json` Datei. Der Slice
erzeugt keine Runtime-Daten, keine finalen Koordinaten, keine Polygone, keine
Path-Centerlines, keine Path-Nodes, keine Assets, keine App-Integration und
keinen Code.

## 2. Review-Basis

Gelesene Pflichtgrundlagen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
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

Fuehrende Regel der gesamten Kette:

> Sichtbares Art-Bild ist nicht die technische Spielkarte, und ein
> YAML-Skeleton ist noch keine technische Runtime-Map.

## 3. Gesamturteil

M16-DO ist ausreichend.

Das Gate-Dokument `398` erklaert nachvollziehbar, warum genau eine echte
YAML-Datei erlaubt wurde und warum diese Datei trotzdem nur eine
Planungsstruktur ist. Die YAML-Datei selbst enthaelt die geforderten
Statusschutzfelder, die erlaubten Feldgruppen, alle Pflicht-Layer-IDs,
textuelle Platzhalter, QA-Anforderungen, offene Messfragen, blockierten Scope
und `M16-DP` als naechstes Review-Gate.

Ein M16-DO-FIX ist nicht noetig.

Ein Measurement-/Value-Gate darf danach vorbereitet werden, aber nur als
eigener enger Folge-Slice. M16-DP gibt keine echten Messwerte,
Geometriewerte, Koordinaten, Polygone, Path-Centerlines, Path-Nodes,
No-Walk-/No-Build-Unionen, Runtime-Daten, Assets oder Code frei.

## 4. Datei- und Scope-Review

| Pruefung | Status | Bewertung |
| --- | --- | --- |
| Exakter YAML-Pfad | ausreichend | Die Datei liegt unter `docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml`. |
| Genau eine M16-DO-`.yaml`-Datei | ausreichend | M16-DO hat genau die erwartete Skeleton-Datei geoeffnet. M16-DP erzeugt keine weitere YAML-Datei. |
| Keine `.json`-Datei | ausreichend | Der Review findet keine M16-DO-Folgefreigabe fuer JSON. JSON bleibt blockiert. |
| Keine `.yml`-Datei | ausreichend | Das Format bleibt auf exakt eine `.yaml`-Datei begrenzt. |
| Keine Dateien unter `assets/` | ausreichend | Die Skeleton-Arbeit bleibt im Docs-/Planning-Pfad. |
| Keine Code- oder Plattformdateien | ausreichend | M16-DO/M16-DP bleiben Docs-/Planning-/Review-Arbeit ohne Flutter-/Dart-/Plattformscope. |
| YAML-Syntax | ausreichend | Die Datei ist syntaktisch als YAML parsebar und hat eine Mapping-Wurzel. |

## 5. Pflichtstatuswerte

Die YAML enthaelt alle Pflichtstatuswerte am Anfang der Datei:

| Feld | Pflichtwert | Review |
| --- | --- | --- |
| `format_status` | `planning_skeleton` | vorhanden |
| `runtime_status` | `not_runtime_data` | vorhanden |
| `asset_status` | `not_asset` | vorhanden |
| `engine_status` | `not_engine_ready` | vorhanden |
| `geometry_status` | `no_geometry_values` | vorhanden |
| `coordinate_status` | `no_final_coordinates` | vorhanden |
| `pixel_derivation_policy` | `pixel_derivation_forbidden` | vorhanden |
| `measurement_status` | `manual_measurement_required` | vorhanden |
| `runtime_review_requirement` | `runtime_review_required_before_use` | vorhanden |
| `source_truth_policy` | `technical_layers_not_art_pixels` | vorhanden |

Bewertung: ausreichend.

Diese Felder sind stark genug, um die Datei als Planning-Skeleton und nicht
als Runtime-Map zu lesen.

## 6. Erlaubte Feldgruppen

Die YAML nutzt die erlaubten Feldgruppen aus M16-DO:

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

Bewertung: ausreichend.

Die Feldgruppen beschreiben Status, Quellen, Layer-Rollen, Platzhalter, QA,
offene Fragen und Blocker. Sie erzeugen keine echten Werte.

## 7. Pflicht-Layer-IDs

Die YAML enthaelt alle Pflicht-Layer-IDs:

| Layer-ID | Review |
| --- | --- |
| `base_rock_shape` | vorhanden |
| `grass_terrain_mask` | vorhanden |
| `water_river_mask` | vorhanden |
| `walkable_path_layer` | vorhanden |
| `tree_obstacle_layer` | vorhanden |
| `rock_cliff_obstacle_layer` | vorhanden |
| `buildable_zone_layer` | vorhanden |
| `plot_footprint_layer` | vorhanden |
| `no_walk_mask` | vorhanden |
| `no_build_mask` | vorhanden |
| `depth_sort_bands` | vorhanden |
| `landmark_anchor_layer` | vorhanden |

Bewertung: ausreichend.

Die Layer bleiben `not_measured` und verweisen auf manuelle oder
vectorbasierte Folgearbeit. Kein Layer behauptet Runtime-Reife.

## 8. Verbotene Werte und Fehlnutzungen

| Thema | Status | Bewertung |
| --- | --- | --- |
| Echte Koordinaten | ausreichend blockiert | Es gibt keine `x`-/`y`-Werte oder Koordinatenpaare als echte Daten. |
| Polygonpunkte | ausreichend blockiert | `polygon_points` erscheint nur als verbotener Begriff, nicht als Werteliste. |
| Path-Centerlines | ausreichend blockiert | Path-Centerlines sind in `blocked_scope`/Verbotslisten blockiert, nicht als Daten enthalten. |
| Path-Nodes / Path-Edges | ausreichend blockiert | Die YAML blockiert diese Begriffe als Werte und nutzt sie nicht als Datencontainer. |
| Build-Zonen-Polygone | ausreichend blockiert | `build_zone_polygons` ist verboten und nicht als echte Geometrie enthalten. |
| Plot-Footprint-Polygone | ausreichend blockiert | `plot_footprint_polygons` ist verboten und nicht als echte Geometrie enthalten. |
| No-Walk-/No-Build-Unionen | ausreichend blockiert | Union-Werte bleiben blockiert; es gibt nur Review-/Planungsfragen. |
| Pixelableitung | ausreichend blockiert | `pixel_derivation_forbidden` steht top-level und pro Layer. |
| Runtime-/Asset-/Engine-ready-Status | ausreichend blockiert | Produktive Statuswerte werden explizit verboten. |
| Leere Geometriecontainer | ausreichend blockiert | Es gibt keine leeren Listen wie `points: []`, die als spaetere Geometriecontainer missverstanden werden koennten. |

Wichtige Review-Notiz:

Verbotene Feldnamen wie `path_nodes`, `polygon_points` oder
`no_walk_union_values` duerfen im Skeleton stehen, wenn sie als verbotene
Felder, blockierter Scope oder QA-Risiko markiert sind. Problematisch waeren
sie nur als echte Werte, Wertelisten oder produktive Container. Das ist in
der M16-DO-YAML nicht der Fall.

## 9. Risiken

Restliche Risiken fuer Folgearbeit:

- Eine YAML-Datei wirkt maschinennaeher als Markdown und koennte trotz
  Statusschutz zu schnell als Import- oder Runtime-Struktur gelesen werden.
- Verbotene Feldnamen koennten in einem Folgeprompt kopiert und versehentlich
  mit echten Werten gefuellt werden.
- Ein Measurement-/Value-Gate koennte zu breit werden und mehrere
  Geometriefamilien gleichzeitig oeffnen.
- Pixelableitung koennte wieder einschleichen, wenn spaetere Messwerte aus
  dem Uferwald-Bitmap statt aus manuell/vectorbasiert geprueften Layern
  entstehen.
- No-Walk und No-Build koennten bei echter Wertearbeit wieder vermischt
  werden.

Diese Risiken sind kein M16-DO-FIX-Blocker. Sie muessen im naechsten
Measurement-/Value-Gate als harte Grenzen gefuehrt werden.

## 10. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Ist M16-DO ausreichend? | JA |
| Ist M16-DO-FIX noetig? | NEIN |
| Ist die YAML-Skeleton-Datei als Planning-Skeleton akzeptabel? | JA |
| Darf danach ein Measurement-/Value-Gate vorbereitet werden? | JA |
| Duerfen danach automatisch echte Werte entstehen? | NEIN |
| Duerfen danach automatisch Runtime-Daten entstehen? | NEIN |
| Duerfen danach automatisch Assets, Code oder App-Integration entstehen? | NEIN |

## 11. Grenzen fuer den naechsten Gate

Ein naechster Measurement-/Value-Gate-Slice muss mindestens diese Grenzen
behalten:

- exakter Slice-Zweck,
- exakter Zielpfad, falls eine Datei betroffen ist,
- keine automatische Pixelableitung,
- keine Runtime-Mapdaten,
- keine Assets oder Dateien unter `assets/`,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Persistenz,
- kein BuildState,
- keine finalen Koordinaten ohne eigenes Review,
- keine Polygone ohne eigenes Review,
- keine Path-Centerlines, Path-Nodes oder Path-Edges ohne eigenes Review,
- No-Walk und No-Build getrennt pruefen,
- Skeleton-Statusschutz bleibt fuehrend.

Wenn ein Folge-Slice echte Werte oeffnet, muss er sehr eng sein und klar
benennen, welche einzelne Wertfamilie, welcher Status und welche QA erlaubt
werden. Ohne diese Oeffnung bleiben alle Werte blockiert.

## 12. Nicht-Freigaben

M16-DP gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine weitere `.yaml`-Datei,
- keine `.json`-Datei,
- keine `.yml`-Datei,
- keine finalen Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Path-Edges,
- keine Build-Zonen-Polygone,
- keine Plot-Footprint-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine Bilder,
- keine SVG/PNG-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Figma-Writes,
- keine externen Writes,
- keinen Commit.

## 13. Empfohlener naechster Slice

Empfohlen:

```text
M16-DQ Uferwald Measurement/Value Gate Preparation
```

M16-DQ sollte noch kein breiter Runtime- oder Geometry-Slice werden. Sinnvoll
ist ein enges Gate, das entscheidet, welche erste Wertfamilie spaeter
ueberhaupt geoeffnet werden darf und welche QA vor echten Messwerten
zwingend ist. M16-DQ muss M16-DP, M16-DO und das Skeleton lesen und weiterhin
`planning_skeleton`, `not_runtime_data`, `no_geometry_values` und
`no_final_coordinates` schuetzen, bis ein Folgeprompt eine konkrete
Wertoeffnung ausdruecklich erlaubt.
