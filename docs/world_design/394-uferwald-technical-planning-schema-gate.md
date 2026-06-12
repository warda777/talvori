# M16-DK: Uferwald Technical Planning Schema Gate

Stand: 2026-06-12

Status: `docs_only_slice`, `schema_gate`, `field_definitions_only`,
`not_json_yaml_file`, `not_runtime_data`, `not_asset`, `not_engine_ready`

## 1. Zweck

M16-DK definiert ein reines Markdown-Schema fuer spaetere Uferwald-
Planungsstrukturen. Das Schema beschreibt Feldgruppen, Pflichtfelder,
optionale Felder, Rollen-/Statuswerte, QA-Felder, offene Messfragen und
Blockerstatus, damit ein spaeterer enger JSON/YAML-Planning-Format-Gate nicht
bei null beginnt.

M16-DK erzeugt keine echte JSON/YAML-Datei, keine Runtime-Mapdaten, keine
finalen Koordinaten, keine Polygone, keine Bilder, keine SVG/PNG, keine Assets
und keinen Code.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
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

Fuehrende Regel:

> M16-DK beschreibt Felder, aber keine Werte.

## 3. Schema-Gate-Regel

M16-DK ist ein Vertrag fuer spaetere Planungsdaten. Es darf nur festlegen:

- welche Feldgruppen spaeter gebraucht werden,
- welche Felder Pflicht sind,
- welche Felder optional sind,
- welche Wertebereiche als Rollen-/Status-Enums erlaubt sind,
- welche Felder nie aus Pixeln abgeleitet werden duerfen,
- welche Felder manuell oder vektorbasiert gemessen werden muessen,
- welche Felder vor Runtime separat reviewed werden muessen.

M16-DK darf nicht festlegen:

- echte Koordinaten,
- echte Polygonpunkte,
- echte Path-Nodes,
- echte Runtime-Pfade,
- echte Build-Zonen-Geometrien,
- echte No-Walk-/No-Build-Geometrien,
- echte JSON/YAML-Dateien,
- echte Runtime-Mapdaten.

## 4. Schema-Ebenen

Das spaetere Planungsformat sollte diese Markdown-Schema-Ebenen vorbereiten:

| Ebene | Zweck | Status in M16-DK |
| --- | --- | --- |
| Map Header | Identitaet, Scope, Koordinatenkonvention und Statusschutz einer spaeteren Planungsdatei. | Felddefinition |
| Layer Definition | Layer-ID, Rolle, erlaubte Datenform, Modi, Blocker und Messpflicht. | Felddefinition |
| Role / Enum Definition | Begrenzte Werte fuer Walkability, Buildability, Obstacles, Occlusion, Anchors, Sort-Bands, Path Corridor und Water/Buffer. | Felddefinition |
| Geometry Placeholder | Platzhalter fuer spaetere Geometrie ohne Werte. | Felddefinition, keine Geometrie |
| QA Record | Prueffragen, Pass/Fail-Status und Blocker vor Runtime. | Felddefinition |
| Open Measurement Record | Noch offene Messfragen mit Ziel-Layer und Folge-Gate. | Felddefinition |
| Review Decision Record | Review-Ergebnis, Freigabegrenze und naechster Gate-Bedarf. | Felddefinition |

## 5. Layer-IDs

Das Schema muss mindestens diese Layer-IDs kennen:

| Layer-ID | Layer-Rolle | Spaetere Datenform erlaubt | Pixelableitung erlaubt |
| --- | --- | --- | --- |
| `base_rock_shape` | Insel-Silhouette, harte Landmasse, Rand-/Klippenkoerper. | Polygon, Multi-Polygon, SVG/Figma-Vector, Raster-Mask-Plan. | Nein |
| `grass_terrain_mask` | Wiesen-, Boden- und weiche Terrainflaechen. | Polygon, Multi-Polygon, Terrain-Region, Raster-Mask-Plan. | Nein |
| `water_river_mask` | Meer, Flussarm, Uferarm, River Entry/Exit, Wasserbarriere. | Wasser-Polygon, River-Polyline mit Breite, Mask-Plan. | Nein |
| `walkable_path_layer` | Planungskorridore, spaetere Pfade, Stationen, Besucherbewegung. | Path-Corridor-Polygone, Polyline-Netz, spaeter Graph. | Nein |
| `tree_obstacle_layer` | Hain, Baumblocker, weiche Waldkante, Occlusion-Kante. | Obstacle-Polygone, Bauminstanzen mit Radius, Edge-Linien. | Nein |
| `rock_cliff_obstacle_layer` | Felsen, Klippen, harte Hoehenkanten, Felsblocker. | Obstacle-Polygone, Cliff-Polyline mit Puffer, Edge-Linien. | Nein |
| `buildable_zone_layer` | Organische Eignungsraeume fuer freie Baukapazitaet. | Soft-Zone-Polygone, Eignungsregionen. | Nein |
| `plot_footprint_layer` | Spaetere Footprint-Klassen, Attachments und No-Overlap. | Footprint-Templates, Groessenklassen, Placement-Zonen. | Nein |
| `no_walk_mask` | Harte Bewegungs-Sperre fuer Visit/Wander. | Composite-Mask aus technischen Source-Layern. | Nein |
| `no_build_mask` | Harte Bausperre fuer Build/Map und Object Focus. | Composite-Mask aus technischen Source-Layern. | Nein |
| `depth_sort_bands` | Vorder-/Mittel-/Hintergrund und Sort-/Occlusion-Review. | Sort-Band-Regionen, Sort-Anker, Edge-Linien. | Nein |
| `landmark_anchor_layer` | Benannte Landmark-, Path-, Build- und Object-Focus-Bezugspunkte. | Manuell gesetzte Anchor-Records, spaeter Koordinaten nach Gate. | Nein |

## 6. Gemeinsame Pflichtfelder

Jede spaetere Planungsstruktur braucht diese gemeinsamen Felder:

| Feld | Pflicht | Zweck | Erlaubter Status in M16-DK |
| --- | --- | --- | --- |
| `schema_id` | Ja | Eindeutige ID der spaeteren Planungsstruktur. | Feldname definiert |
| `slice_id` | Ja | Herkunfts-Slice der Planungsstruktur. | Feldname definiert |
| `map_id` | Ja | Kartenidentitaet, fuer Uferwald `uferwald_starter_island`. | Feldname definiert, kein Datenfile |
| `schema_status` | Ja | Statusschutz wie `planning_schema`, `not_runtime_data`. | Enum definiert |
| `coordinate_space` | Ja | Erwartete Koordinatenkonvention, frueh `normalized_0_1`. | Feldname definiert, keine Werte |
| `canvas_origin` | Ja | Erwarteter Ursprung, frueh `top_left_normalized_0_0`. | Feldname definiert, keine Messung |
| `world_origin_reference` | Ja | Bezugspunkt, frueh `hub_center_anchor`. | Referenzname, keine Koordinate |
| `source_docs` | Ja | Welche Docs gelesen wurden. | Feldname definiert |
| `visual_references` | Optional | Welche Visuals nur Review-Kontext sind. | Feldname definiert |
| `blocked_scope` | Ja | Was diese Struktur nicht freigibt. | Feldname definiert |
| `next_review_gate` | Ja | Welcher Review vor technischen Daten noetig ist. | Feldname definiert |

## 7. Layer-Definition-Felder

Jede Layer-Definition braucht spaeter:

| Feld | Pflicht | Zweck |
| --- | --- | --- |
| `layer_id` | Ja | Eine der Pflicht-Layer-IDs aus Abschnitt 5. |
| `layer_role` | Ja | Fachliche Rolle des Layers. |
| `layer_status` | Ja | Planungsstatus, noch kein Runtime-Status. |
| `allowed_modes` | Ja | Build/Map, Visit/Wander, Object Focus, Overview. |
| `data_form_candidates` | Ja | Erlaubte spaetere Formen wie Polygon, Polyline, Vector-Plan, Raster-Mask-Plan. |
| `source_of_truth_policy` | Ja | Technische Quelle fuehrend, sichtbares Bild nur Review-Kontext. |
| `pixel_derivation_policy` | Ja | Muss bei technischen Layern `pixel_derivation_forbidden` sein. |
| `manual_measurement_requirement` | Ja | Was spaeter manuell/vectorbasiert gemessen werden muss. |
| `runtime_review_requirement` | Ja | Welcher Review vor Runtime noetig ist. |
| `qa_fields` | Ja | Verknuepfte QA-Records. |
| `open_measurements` | Ja | Offene Messfragen. |
| `blocked_uses` | Ja | Nutzungen, die noch verboten sind. |
| `notes` | Optional | Erklaerung oder Review-Kontext. |

## 8. Geometry-Placeholder-Felder

M16-DK erlaubt nur Platzhalterfelder, keine Geometrie. Spaetere
Planungsstrukturen duerfen diese Felder vorbereiten:

| Feld | Pflicht | Regel |
| --- | --- | --- |
| `geometry_kind_candidate` | Ja | Erlaubt sind nur Kandidatentypen wie Polygon, Polyline, Corridor, Mask, Band, Anchor. |
| `geometry_status` | Ja | Muss vor echter Messung `not_measured` oder `manual_measurement_required` sein. |
| `geometry_source_policy` | Ja | Muss Pixelableitung blockieren. |
| `geometry_values` | Nein | In M16-DK verboten; spaeter erst nach eigenem Gate. |
| `coordinate_values` | Nein | In M16-DK verboten; spaeter erst nach eigenem Gate. |
| `polygon_points` | Nein | In M16-DK verboten; spaeter erst nach eigenem Gate. |
| `runtime_export_status` | Ja | Muss `not_runtime_data` bleiben. |

## 9. Rollen- und Status-Enums

Diese Enums sind Feldwerte fuer spaetere Planung. Sie sind noch keine
technischen Daten.

### 9.1 Walkability

| Wert | Bedeutung | Vor Runtime Review noetig |
| --- | --- | --- |
| `walkable_candidate` | Flaeche oder Korridor koennte spaeter begehbar werden. | Ja |
| `planning_path_corridor` | Breiter Review-Korridor, keine Centerline. | Ja |
| `no_walk` | Harte Bewegungs-Sperre. | Ja |
| `water_no_walk_buffer` | Uferpuffer fuer Bewegung. | Ja |
| `hard_obstacle_no_walk` | Baum/Fels/Klippe blockiert Bewegung. | Ja |
| `blocked_path_candidate` | Pfadkandidat faellt durch QA. | Ja |
| `unknown_until_measurement` | Noch nicht entscheidbar. | Ja |

### 9.2 Buildability

| Wert | Bedeutung | Vor Runtime Review noetig |
| --- | --- | --- |
| `buildable_candidate` | Organischer Eignungsraum, kein Slot. | Ja |
| `soft_build_candidate` | Weicher Eignungsraum mit Unsicherheit. | Ja |
| `no_build` | Harte Bausperre. | Ja |
| `water_no_build_buffer` | Uferpuffer fuer Bauen. | Ja |
| `path_protection` | Weg bleibt frei, obwohl begehbar. | Ja |
| `hub_anchor_protection` | Hub-/Anchor-Schutzbereich. | Ja |
| `attachment_expansion_protection` | Reserve fuer Garage, Garten, Terrasse, Vorhof oder Erweiterungen. | Ja |
| `unknown_until_measurement` | Noch nicht entscheidbar. | Ja |

### 9.3 Obstacles

| Wert | Bedeutung | Darf automatisch aus Pixeln kommen |
| --- | --- | --- |
| `decorative_tree` | Deko-Baum, kein automatischer Blocker. | Nein |
| `soft_forest_edge` | Weiche Waldkante, Review noetig. | Nein |
| `hard_tree_blocker` | Harte Vegetationssperre. | Nein |
| `decorative_rock` | Deko-Fels, kein automatischer Blocker. | Nein |
| `hard_rock_blocker` | Harte Fels-Sperre. | Nein |
| `cliff_edge` | Klippen-/Hoehenkante mit Pufferbedarf. | Nein |
| `terrain_sensitive_edge` | Terrain braucht Sonderreview. | Nein |
| `unknown_until_measurement` | Noch nicht entschieden. | Nein |

### 9.4 Occlusion

| Wert | Bedeutung | Collision? |
| --- | --- | --- |
| `no_occlusion` | Keine verdeckende Rolle. | Nein |
| `tree_occlusion_edge` | Figuren/Objekte koennen visuell hinter Hainkante liegen. | Nein |
| `height_occlusion_edge` | Figuren/Objekte koennen durch Hoehenkante verdeckt werden. | Nein |
| `foreground_occluder_candidate` | Vordergrundelement koennte ueberdecken. | Nein |
| `background_context_only` | Nur atmosphaerischer Hintergrund. | Nein |
| `review_required` | Rolle unklar. | Nein |

### 9.5 Anchors

| Wert | Bedeutung | Runtime-Anchor? |
| --- | --- | --- |
| `landmark` | Orientierungspunkt wie Fluss, Hain, Aussicht. | Nein |
| `path_node` | Spaeterer Pfadbezug, noch kein Bewegungsnode. | Nein |
| `build_reference` | Spaeterer Build-Bezug, kein Plot. | Nein |
| `object_focus_reference` | Spaeterer Fokusbereich, kein Interaktionspunkt. | Nein |
| `river_reference` | River Entry/Exit oder Wasserbezug. | Nein |
| `hub_reference` | Hub-/Treffpunkt-Bezug. | Nein |
| `reserve_reference` | Reserve- oder Zukunftsbereich. | Nein |
| `not_runtime_anchor` | Expliziter Statusschutz. | Nein |

### 9.6 Sort-Bands

| Wert | Bedeutung | Renderer-Implementation? |
| --- | --- | --- |
| `background_north` | Grober hinterer Bereich. | Nein |
| `midground_center` | Grober mittlerer Bereich. | Nein |
| `foreground_south` | Grober vorderer Bereich. | Nein |
| `manual_sort_review` | Sortierung braucht manuelles Review. | Nein |
| `occlusion_sort_review` | Sortierung haengt an Occlusion-Kante. | Nein |
| `not_renderer_implementation` | Expliziter Statusschutz. | Nein |

### 9.7 Path Corridor

| Wert | Bedeutung | Runtime-Centerline? |
| --- | --- | --- |
| `planning_path_corridor` | Breiter Review-Korridor. | Nein |
| `normal_width_candidate` | Mindestens `3.0 x visitor_marker_diameter`. | Nein |
| `bottleneck_review` | Zwischen `2.0 x` und `3.0 x`, Review noetig. | Nein |
| `blocked_path_candidate` | Schneidet harte Sperre oder ist zu eng. | Nein |
| `station_candidate` | Moeglicher Stationsbereich, kein Runtime-Node. | Nein |
| `not_runtime_centerline` | Expliziter Statusschutz. | Nein |

### 9.8 Water / Buffer

| Wert | Bedeutung | Freigabe |
| --- | --- | --- |
| `water_river_mask` | Wasserflaeche, No-Walk und No-Build Quelle. | Nur Planung |
| `hard_water_boundary` | Harte Wassergrenze. | Nur Planung |
| `river_entry_reference` | Referenz fuer Wasser-Eintritt. | Keine Koordinate |
| `river_exit_reference` | Referenz fuer Wasser-Austritt. | Keine Koordinate |
| `water_no_walk_buffer` | Bewegungsabstand zu Wasser. | Nur Planung |
| `water_no_build_buffer` | Bauabstand zu Wasser. | Nur Planung |
| `bridge_or_ford_blocked_until_gate` | Querung bleibt blockiert. | Kein Feature |

## 10. QA-Felder

Spaetere Planungsstrukturen brauchen fuer jede relevante Ebene QA-Felder:

| QA-Feld | Pflicht | Blockiert wenn |
| --- | --- | --- |
| `qa_pixel_derivation_check` | Ja | Technische Werte aus Pixeln oder Bildfarben abgeleitet werden. |
| `qa_manual_measurement_check` | Ja | Pflichtmessung fehlt. |
| `qa_runtime_status_check` | Ja | Status hoeher als Planung gesetzt wird. |
| `qa_path_vs_water_check` | Ja fuer Pfade | Pfad Wasser oder Wasserpuffer schneidet. |
| `qa_path_vs_obstacle_check` | Ja fuer Pfade | Pfad harte Baum-/Felsblocker schneidet. |
| `qa_no_walk_union_check` | Ja fuer Bewegung | Union nicht aus technischen Source-Layern begruendet ist. |
| `qa_no_build_union_check` | Ja fuer Build | No-Build nur aus No-Walk kopiert oder nicht begruendet ist. |
| `qa_build_zone_slot_check` | Ja fuer Build | Build-Zonen wie feste Slots oder Kategorieplaetze wirken. |
| `qa_anchor_runtime_check` | Ja fuer Anchors | Anchors als finale Runtime-Koordinaten gelesen werden. |
| `qa_sort_renderer_check` | Ja fuer Sort-Bands | Sort-Bands als Renderer-Code festgeschrieben werden. |
| `qa_scope_check` | Ja | JSON/YAML, Runtime-Daten, Assets, Code oder App-Scope entstehen. |

Erlaubte QA-Statuswerte:

- `not_checked`
- `review_required`
- `passes_for_planning`
- `fails_for_planning`
- `blocked_until_measurement`
- `blocked_until_runtime_gate`
- `not_applicable`

## 11. Offene Messfragen

Jede offene Messfrage braucht spaeter:

| Feld | Pflicht | Zweck |
| --- | --- | --- |
| `question_id` | Ja | Eindeutige Frage-ID. |
| `target_layer_ids` | Ja | Betroffene Layer. |
| `question_text` | Ja | Was noch gemessen oder entschieden werden muss. |
| `why_it_matters` | Ja | Risiko, wenn offen. |
| `allowed_resolution_method` | Ja | Manuell, Vector-Plan, Review, nicht Pixelableitung. |
| `blocked_until` | Ja | Folge-Gate oder Review, der noetig ist. |
| `runtime_relevance` | Ja | Ob die Frage Runtime blockiert. |

Pflichtfragen fuer den naechsten Review bleiben:

- Wo verlaufen echte Pfadkorridore?
- Wo ist Wasser hart gesperrt?
- Wo liegen harte Baum-/Hainblocker?
- Wo liegen harte Fels-/Klippenblocker?
- Welche organischen Build-Zonen bleiben ohne feste Slots plausibel?
- Welche Footprint-Klassen brauchen eigene Abstand-/Attachment-Regeln?
- Welche Anchors brauchen spaeter manuelle Koordinaten?
- Welche Sort-Bands brauchen Occlusion-Beispiele?
- Welche No-Walk-/No-Build-Unionen sind nur geplant und noch nicht messbar?

## 12. Felder, die niemals aus Pixeln abgeleitet werden duerfen

Niemals aus Pixeln oder Bildfarben ableiten:

- Walkability,
- Buildability,
- Collision,
- harte Wassergrenzen,
- Wasserpuffer,
- harte Baumblocker,
- harte Fels-/Klippenblocker,
- No-Walk-Masks,
- No-Build-Masks,
- Runtime-Path-Centerlines,
- Path-Nodes,
- Build-Footprints,
- Anchor-Koordinaten,
- Sort-Bands,
- Occlusion-Kanten,
- Kapazitaetszahlen,
- Kategorieplatzierung.

Sichtbare Uferwald-Bilder und M16-DI-Visuals duerfen diese Felder nur als
Review-Kontext illustrieren.

## 13. Felder mit manueller oder vectorbasierter Messpflicht

Diese Felder brauchen spaeter manuelle oder vektorbasierte Messung:

- `base_rock_shape`-Aussenform,
- `water_river_mask` und harte Wassergrenze,
- `water_no_walk_buffer`,
- `water_no_build_buffer`,
- `planning_path_corridor`,
- Engpassbereiche,
- `hard_tree_blocker`,
- `soft_forest_edge`,
- `tree_occlusion_edge`,
- `hard_rock_blocker`,
- `cliff_edge`,
- `height_occlusion_edge`,
- `buildable_zone_layer`,
- `plot_footprint_layer`,
- `no_walk_mask`,
- `no_build_mask`,
- `depth_sort_bands`,
- `landmark_anchor_layer`.

Die Messung darf spaeter in SVG, Figma, Markdown-Tabellen oder einem
eng freigegebenen JSON/YAML-Planning-Format vorbereitet werden. M16-DK
erzeugt keines dieser Datenformate.

## 14. Felder mit Runtime-Review-Pflicht

Vor jeder Runtime-Nutzung muessen separat reviewed werden:

- alle Geometrie-Werte,
- alle Koordinaten,
- alle Polygone,
- alle Path-Centerlines,
- alle Path-Nodes,
- alle No-Walk-/No-Build-Unionen,
- alle Anchor-Koordinaten,
- alle Build-Footprints,
- alle Sort-Bands,
- alle Occlusion-Kanten,
- alle Datenexporte.

Ohne Review bleibt der Status `not_runtime_data`.

## 15. Blockerstatus

Erlaubte Blockerstatuswerte:

| Wert | Bedeutung |
| --- | --- |
| `blocked_until_measurement` | Feld braucht manuelle/vectorbasierte Messung. |
| `blocked_until_visual_review` | Feld braucht visuelle Pruefung. |
| `blocked_until_schema_review` | Feld braucht M16-DL-Review. |
| `blocked_until_json_yaml_gate` | Feld darf noch nicht in JSON/YAML-Datei entstehen. |
| `blocked_until_runtime_gate` | Feld darf nicht in Runtime genutzt werden. |
| `blocked_until_asset_gate` | Feld darf nicht Asset-/Exportstatus bekommen. |
| `blocked_until_app_integration_gate` | Feld darf nicht App-/Flutter-Integration ausloesen. |

## 16. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Ist das Markdown-Schema fuer Planungsfelder definiert? | JA |
| Erzeugt M16-DK eine JSON/YAML-Datei? | NEIN |
| Erzeugt M16-DK Runtime-Mapdaten? | NEIN |
| Erzeugt M16-DK finale Koordinaten oder Polygone? | NEIN |
| Erlaubt M16-DK direkte App-/Flutter-/Asset-Folgearbeit? | NEIN |
| Ist danach ein M16-DL Uferwald Planning Schema Review noetig? | JA |
| Kann danach direkt JSON/YAML entstehen? | NEIN, erst nach M16-DL und eigenem engen JSON/YAML-Planning-Format-Gate. |

## 17. Empfohlener Folgepfad

Naechster Slice:

```text
M16-DL Uferwald Planning Schema Review
```

M16-DL sollte pruefen, ob die M16-DK-Feldgruppen, Enums, Pflichtfelder,
QA-Felder, Messfragen und Blockerstatus ausreichend sind.

Erst danach sinnvoll:

```text
M16-DM Uferwald JSON/YAML Planning Format Gate
```

M16-DM duerfte nur dann vorbereitet werden, wenn M16-DL bestaetigt, dass das
Schema keine Runtime-Daten, keine Koordinaten, keine Polygone und keine
Pixelableitung einschleust.

## 18. Stop-Regeln

M16-DK gibt nicht frei:

- Code,
- Flutter-/Dart-Dateien,
- App-Integration,
- Route oder Navigation,
- Persistenz,
- `BuildState`,
- Tests,
- Bilder,
- SVG/PNG,
- Preview-Ordner,
- JSON/YAML-Dateien,
- Runtime-Mapdaten,
- finale Koordinaten,
- Polygone,
- Path-Centerlines,
- Path-Nodes,
- Assets,
- Dateien unter `assets/`,
- Engine-ready Candidates,
- Figma-/externe Writes,
- Commit.
