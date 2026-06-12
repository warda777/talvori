# M16-DS: Uferwald Anchor Review Values YAML Update Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `yaml_update_gate`, `anchor_review_values`,
`review_values_only`, `not_runtime_data`, `no_geometry_values`,
`no_coordinate_values`

## 1. Zweck und Non-Goals

M16-DS erweitert die bestehende Uferwald-Skeleton-YAML gezielt um die erste
Wertfamilie:

```text
anchor_review_values
```

Diese Erweiterung erzeugt nur Reviewwerte. Sie erzeugt keine Koordinaten,
keine Geometrie, keine Runtime-Daten, keine Assets und keine App-Integration.

Non-Goals:

- keine neue `.yaml`-Datei,
- keine neue `.yml`-Datei,
- keine neue `.json`-Datei,
- keine zweite YAML-Datei,
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
- `docs/world_design/401-uferwald-anchor-review-values-gate.md`
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

> `anchor_review_values` duerfen nur Rollen-, Modus-, Status- und QA-Werte
> sein. Sie sind keine Anchor-Koordinaten und keine Runtime-Interaktionen.

## 3. Warum die YAML-Aenderung jetzt eng erlaubt ist

M16-DQ hat `anchor_review_values` als erste risikoarme Wertfamilie empfohlen.
M16-DR hat danach den Feldvertrag definiert und entschieden, dass M16-DS als
enger YAML-Update-Gate-Slice vorbereitet werden darf.

Die YAML-Aenderung ist deshalb jetzt eng erlaubt, weil:

- der Prompt exakt eine bestehende YAML-Datei nennt,
- keine neue YAML-, YML- oder JSON-Datei erlaubt ist,
- nur die Wertfamilie `anchor_review_values` geoeffnet wird,
- alle Werte `review_values_only` bleiben,
- die Werte keine Koordinaten und keine Geometrie enthalten,
- jeder Eintrag Statusschutz gegen Runtime-, Asset- und Pixelableitung traegt,
- M16-DT als Review-Folgegate notwendig bleibt.

## 4. Exakt geaenderter Pfad

Geaendert wurde nur:

```text
docs/world_design/planning/uferwald/uferwald_starter_island_planning_skeleton.yaml
```

Nicht erzeugt wurden:

- keine neue `.yaml`,
- keine neue `.yml`,
- keine neue `.json`,
- keine Dateien unter `assets/`,
- keine Code-Dateien.

## 5. Ergaenzte YAML-Sektion

In der bestehenden Skeleton-YAML wurde diese neue, klar abgegrenzte Sektion
ergaenzt:

```text
anchor_review_values
```

Die Sektion enthaelt pro Anchor-ID jeweils nur die erlaubten Review-Felder:

- `value_family`
- `value_status`
- `anchor_id`
- `anchor_review_role`
- `mode_relevance`
- `measurement_requirement`
- `coordinate_status`
- `geometry_status`
- `pixel_derivation_policy`
- `runtime_status`
- `anchor_runtime_status`
- `qa_status`
- `blocked_uses`
- `review_note`
- `source_doc_reference`
- `next_gate_requirement`

`anchor_runtime_status` wird nur als Statusschutz verwendet. Der Wert bleibt
`not_runtime_anchor`.

## 6. Warum es weiterhin keine Runtime-Daten sind

Die neue YAML-Sektion bleibt `not_runtime_data`, weil sie keine messbaren
Positions-, Geometrie- oder Interaktionswerte enthaelt.

Jeder Eintrag traegt:

- `value_status: review_values_only`
- `coordinate_status: no_coordinate_values`
- `geometry_status: no_geometry_values`
- `pixel_derivation_policy: pixel_derivation_forbidden`
- `runtime_status: not_runtime_data`
- `anchor_runtime_status: not_runtime_anchor`
- `measurement_requirement: manual_measurement_required`

Die Eintraege beschreiben nur:

- welche bekannte Anchor-ID fachlich welche Review-Rolle hat,
- fuer welche Kamera-/Weltmodi diese Rolle spaeter relevant sein koennte,
- welche Mess- und QA-Pflichten vor weiterer Nutzung bestehen,
- welche Nutzungen ausdruecklich blockiert bleiben.

Sie beschreiben nicht:

- wo ein Anchor liegt,
- wie ein Anchor gemessen wird,
- welche Runtime-Interaktion damit verbunden ist,
- wie ein Pfad verlaeuft,
- wo gebaut werden darf,
- welche Collision- oder No-Walk-/No-Build-Mask gilt.

## 7. Erlaubte Werte

### 7.1 Erlaubte Anchor-IDs

Die YAML enthaelt genau diese Anchor-IDs:

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

### 7.2 Erlaubte Rollen

Die YAML nutzt nur Rollen aus dem M16-DR-Vertrag:

- `hub_reference`
- `build_reference`
- `river_reference`
- `grove_reference`
- `reserve_reference`
- `path_orientation_reference`
- `landmark`

Die Rolle `object_focus_reference` bleibt erlaubt, wurde in M16-DS aber noch
nicht als primaere Rolle eines Anchor-Eintrags benoetigt. Object-Focus bleibt
ueber `mode_relevance` sichtbar, ohne eine eigene Runtime-Interaktion zu
erzeugen.

### 7.3 Erlaubte Modusbezuege

Die YAML nutzt nur:

- `Build/Map`
- `Overview`
- `Visit/Wander`
- `Object Focus`

Diese Modusbezuege sind Review-Kontext. Sie sind keine Kamera-Regeln und keine
App-Integration.

### 7.4 Erlaubte QA-/Statuswerte

Die YAML nutzt:

- `review_values_only`
- `manual_measurement_required`
- `no_coordinate_values`
- `no_geometry_values`
- `pixel_derivation_forbidden`
- `not_runtime_data`
- `not_runtime_anchor`
- `review_required`
- `blocked_until_measurement_gate`

Diese Werte schuetzen den Reviewstatus. Sie machen keinen Eintrag
runtimefaehig.

## 8. Weiterhin verbotene Werte

Weiterhin verboten und nicht als echte Wertfelder genutzt:

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
- leere Geometriecontainer wie `points: []`,
- numerische Beispielwerte,
- Prozent- oder Pixelbeispiele.

Verbotene Begriffe duerfen in der YAML nur in Schutzkontexten auftreten:

- `blocked_scope`,
- `forbidden_fields`,
- `forbidden_value_patterns`,
- `blocked_uses`,
- QA-/Review-Kontext.

Sie duerfen nicht als produktive Werte oder Datencontainer auftreten.

## 9. QA-Ergebnis

| Pruefung | Ergebnis |
| --- | --- |
| Bestehende Skeleton-YAML erweitert | JA |
| Nur eine YAML-Datei geaendert | JA |
| Neue `.yaml` erzeugt | NEIN |
| Neue `.yml` erzeugt | NEIN |
| Neue `.json` erzeugt | NEIN |
| Neue Sektion ist `anchor_review_values` | JA |
| Alle Eintraege `value_family: anchor_review_values` | JA |
| Alle Eintraege `value_status: review_values_only` | JA |
| Alle Eintraege `runtime_status: not_runtime_data` | JA |
| Alle Eintraege `coordinate_status: no_coordinate_values` | JA |
| Alle Eintraege `geometry_status: no_geometry_values` | JA |
| Alle Eintraege `pixel_derivation_policy: pixel_derivation_forbidden` | JA |
| Alle Eintraege `anchor_runtime_status: not_runtime_anchor` | JA |
| Echte Koordinaten vorhanden | NEIN |
| Geometriecontainer vorhanden | NEIN |
| Path-Centerlines, Path-Nodes oder Path-Edges vorhanden | NEIN |
| No-Walk-/No-Build-Unionen als echte Werte vorhanden | NEIN |
| Runtime-, Asset-, Code- oder App-Freigabe entstanden | NEIN |

## 10. Entscheidung zu M16-DT

| Frage | Entscheidung |
| --- | --- |
| Wurde die Skeleton-YAML korrekt erweitert? | JA |
| Bleibt alles `review_values_only`? | JA |
| Muss danach M16-DT YAML Anchor Review Values Review erfolgen? | JA |
| Bleiben echte Koordinaten, Geometrie, Runtime-Daten, Assets und Code blockiert? | JA |

Empfohlener Folge-Slice:

```text
M16-DT Uferwald YAML Anchor Review Values Review
```

M16-DT muss die YAML-Sektion fachlich und technisch reviewen, bevor weitere
Wertfamilien, echte Messwerte oder Runtime-naehere Gates vorbereitet werden.

## 11. Nicht-Freigaben

M16-DS gibt nicht frei:

- keine Runtime-Mapdaten,
- keine finalen Koordinaten,
- keine Koordinatenbeispiele,
- keine Pixelwerte,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Path-Edges,
- keine Build-Zonen-Polygone,
- keine Plot-Footprint-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine neuen YAML-/YML-/JSON-Dateien,
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

M16-DS oeffnet nur Reviewwerte fuer Anchor-Rollen und pruefpflichtige
Modusbezuege. Die technische Spielkarte bleibt weiterhin blockiert.
