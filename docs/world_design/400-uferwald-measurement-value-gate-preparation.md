# M16-DQ: Uferwald Measurement/Value Gate Preparation

Stand: 2026-06-12

Status: `docs_only_slice`, `value_gate_preparation`, `markdown_only`,
`no_runtime_data`, `no_geometry_values`, `no_yaml_change`

## 1. Zweck und Non-Goals

M16-DQ bereitet das erste Uferwald Measurement-/Value-Gate vor. Ziel ist
nicht, echte Werte zu erzeugen, sondern eng zu entscheiden, welche erste
Wertfamilie spaeter ueberhaupt geoeffnet werden darf und welche QA-Regeln vor
echten Messwerten zwingend sind.

M16-DQ bleibt Markdown-only. Der Slice erzeugt keine neue YAML-, JSON- oder
YML-Datei und aendert die bestehende Skeleton-YAML nicht.

Non-Goals:

- keine echten Messwerte,
- keine Koordinatenbeispiele,
- keine finalen Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Path-Nodes,
- keine Path-Edges,
- keine Build-Zonen-Polygone,
- keine Plot-Footprint-Polygone,
- keine No-Walk-/No-Build-Unionen als echte Werte,
- keine Runtime-Mapdaten,
- keine Bilder, SVGs oder PNGs,
- keine Assets oder Dateien unter `assets/`,
- keine App-Integration,
- keine Persistenz,
- kein BuildState,
- kein Code,
- kein Commit.

## 2. Eingangsquellen

Gelesene Pflichtgrundlagen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
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

> Das erste Value-Gate darf keine technische Spielkarte erzeugen. Es darf nur
> die sicherste erste Wertfamilie vorbereiten.

## 3. Warum nach M16-DP ein Value-Gate vorbereitet werden darf

M16-DP hat entschieden:

- M16-DO ist ausreichend.
- Ein M16-DO-FIX ist nicht noetig.
- Das YAML-Skeleton hat die geforderten Statusschutzfelder.
- Alle Pflicht-Layer-IDs sind vorhanden.
- Verbotene Geometrie-, Koordinaten-, Path-, Union-, Runtime-, Asset- und
  App-Werte bleiben blockiert.
- Ein Measurement-/Value-Gate darf vorbereitet werden, aber nur als eigener
  enger Folge-Slice.

Damit darf M16-DQ entscheiden, welche Wertfamilie spaeter zuerst geoeffnet
werden koennte. M16-DQ darf diese Wertfamilie aber noch nicht in die YAML
eintragen und darf keine echten Werte erzeugen.

## 4. Bewertungsmodell

Jede moegliche erste Wertfamilie wird nach diesen Risiken bewertet:

- Gefahr von Runtime-Verwechslung,
- Gefahr von Pixelableitung,
- Gefahr einer falschen Spielkarte,
- Gefahr von No-Walk-/No-Build-Vermischung,
- Nutzen fuer den naechsten technischen Schritt.

Die erste Wertfamilie muss so risikoarm sein, dass sie ohne Koordinaten,
Polygone, Path-Graphen, Union-Masks oder Runtime-Status diskutiert werden
kann.

## 5. Vergleich der moeglichen ersten Wertfamilien

| Wertfamilie | Runtime-Verwechslung | Pixelableitung | Falsche Spielkarte | No-Walk/No-Build-Mix | Nutzen | Bewertung |
| --- | --- | --- | --- | --- | --- | --- |
| `anchor_review_values` | niedrig, wenn ohne Koordinaten | niedrig, wenn nur Rollen/Status | niedrig | niedrig | hoch: klaert Landmark-, Path-, Build- und Object-Focus-Rollen vor Messung | beste erste Familie |
| `path_corridor_review_values` | hoch | mittel bis hoch | hoch: wirkt schnell wie Bewegungsnetz | mittel | hoch, aber zu frueh | spaeter |
| `water_boundary_review_values` | mittel bis hoch | hoch, wenn aus Blauwerten gelesen | mittel | mittel | hoch fuer harte Grenzen | erst nach manuellem Boundary-Gate |
| `no_walk_review_values` | sehr hoch | mittel | sehr hoch: wirkt wie Collision | hoch | hoch, aber abhaengig von Source-Layern | blockiert |
| `no_build_review_values` | sehr hoch | mittel | hoch: wirkt wie Placement-Map | sehr hoch | hoch, aber abhaengig von Source-Layern | blockiert |
| `sort_band_review_values` | mittel | niedrig bis mittel | mittel: wirkt schnell wie Renderer-Regel | niedrig | mittel | spaeter nach Anchor-Rollen |
| `buildable_zone_review_values` | hoch | mittel bis hoch | hoch: wirkt wie Slots/Plots | hoch | hoch fuer Build/Map | blockiert bis No-Build/Footprint-Gates |

## 6. Risikoentscheidung

Die erste spaeter oeffnungsfaehige Wertfamilie soll
`anchor_review_values` sein.

Begruendung:

- Anchors sind bereits als benoetigte Planungsebene dokumentiert.
- Anchor-Rollen koennen als Text-/Enum-Reviewwerte beschrieben werden, ohne
  Koordinaten zu setzen.
- Anchor-Rollen helfen spaeteren Messungen, ohne selbst eine Path-Centerline,
  Wassergrenze, Build-Zone oder No-Walk-/No-Build-Union zu sein.
- Anchors koennen die Folgearbeit ordnen: Landmark, Path-Node-Kandidat,
  Build-Reference und Object-Focus-Reference werden getrennt.
- Die groesste Gefahr, finale Koordinaten zu erzeugen, kann durch ein hartes
  `no_coordinate_values`- und `not_runtime_anchor`-Profil blockiert werden.

Wichtig:

`anchor_review_values` bedeutet in dieser Entscheidung nicht
`anchor_coordinate_values`. Die erste Familie darf keine `normalized_x`,
`normalized_y`, Punktlisten, Pixelmessungen oder finalen Runtime-Anker
enthalten.

## 7. Empfohlene erste Wertfamilie

Empfohlen:

```text
anchor_review_values
```

Maximaler spaeterer Status:

```text
review_values_only
not_runtime_data
not_geometry_values
no_coordinate_values
not_runtime_anchor
```

Zulaessige fachliche Rolle:

`anchor_review_values` duerfen spaeter nur klaeren, welche bekannten
Anchor-IDs welche Review-Rolle haben und welche Mess-/QA-Pflichten spaeter
gelten. Sie duerfen keine technische Position oder Runtime-Interaktion
definieren.

## 8. Felder, die spaeter maximal erlaubt waeren

Ein spaeterer M16-DR-Gate-Slice darf diese Felder als maximale Feldliste
vorbereiten, aber noch nicht in die YAML schreiben:

| Feld | Maximal erlaubte Rolle | Grenze |
| --- | --- | --- |
| `value_family` | muss `anchor_review_values` sein | keine andere Familie in M16-DR |
| `value_status` | `review_values_only` | kein Runtime-Status |
| `anchor_id` | bekannte Anchor-ID als String | keine Koordinate |
| `anchor_review_role` | Enum wie `landmark`, `path_node_candidate`, `build_reference`, `object_focus_reference`, `river_reference`, `hub_reference`, `reserve_reference` | Rolle, kein Runtime-Anchor |
| `mode_relevance` | Build/Map, Visit/Wander, Object Focus, Overview | nur Modusbezug |
| `measurement_requirement` | `manual_measurement_required` oder `blocked_until_measurement_gate` | keine Messung |
| `coordinate_status` | `no_coordinate_values` | keine `x`-/`y`-Werte |
| `geometry_status` | `no_geometry_values` | keine Geometrie |
| `pixel_derivation_policy` | `pixel_derivation_forbidden` | keine Bitmap-Ableitung |
| `runtime_status` | `not_runtime_data` | kein Import |
| `qa_status` | `review_required`, `not_runtime_anchor`, `blocked_until_measurement_gate` | kein Pass fuer Runtime |
| `blocked_uses` | Liste verbotener Nutzungen | kein produktiver Scope |

Bekannte Anchor-IDs duerfen spaeter nur als IDs referenziert werden, zum
Beispiel:

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

Diese ID-Liste ist keine Koordinatenliste.

## 9. Felder und Werte, die weiterhin verboten bleiben

Weiterhin verboten:

- `coordinate_values`
- `normalized_x`
- `normalized_y`
- `x`
- `y`
- `polygon_points`
- `geometry_values`
- `path_centerline`
- `path_nodes`
- `path_edges`
- `build_zone_polygons`
- `plot_footprint_polygons`
- `no_walk_union_values`
- `no_build_union_values`
- `runtime_status: runtime_ready`
- `asset_status: asset`
- `engine_status: engine_ready`
- `source_from_pixels`
- `derived_from_bitmap`
- `runtime_anchor`
- `stored_interaction_point`
- `build_slot`
- `category_plot`

Auch fuer `anchor_review_values` bleiben echte Koordinaten verboten. Ein
Anchor darf in diesem ersten Value-Pfad nur Rollen-, Modus-, Status- und
QA-Werte bekommen.

## 10. QA-Pflichten vor jeder echten Wertoeffnung

Vor jeder echten Wertoeffnung muss ein Folge-Slice diese Fragen mit JA
beantworten:

| QA-Frage | Muss JA sein |
| --- | --- |
| Ist genau eine Wertfamilie geoeffnet? | Ja |
| Ist die Wertfamilie `anchor_review_values`? | Ja, fuer den ersten Value-Pfad |
| Bleibt die bestehende YAML bis zur ausdruecklichen Wertfreigabe unveraendert? | Ja |
| Sind alle Werte `review_values_only`? | Ja |
| Sind Koordinaten weiter verboten? | Ja |
| Sind Polygone weiter verboten? | Ja |
| Sind Path-Centerlines, Path-Nodes und Path-Edges weiter verboten? | Ja |
| Sind No-Walk-/No-Build-Unionen als echte Werte weiter verboten? | Ja |
| Ist Pixelableitung weiter verboten? | Ja |
| Bleibt `runtime_status` `not_runtime_data`? | Ja |
| Bleiben Assets und `assets/` blockiert? | Ja |
| Bleiben Code, App-Integration, Persistenz und BuildState blockiert? | Ja |
| Gibt es einen Datei-Check gegen neue `.json`, `.yaml` und `.yml`? | Ja |

Wenn eine Antwort NEIN ist, ist der Folge-Slice nicht commitfaehig.

## 11. Entscheidung zu M16-DR

| Frage | Entscheidung |
| --- | --- |
| Welche erste Wertfamilie wird empfohlen? | `anchor_review_values` |
| Darf ein M16-DR erster Value-Gate-Slice vorbereitet werden? | JA |
| Darf M16-DR echte Werte erzeugen? | NEIN |
| Darf M16-DR die bestehende YAML-Datei aendern? | NEIN |
| Muss M16-DR weiterhin Markdown-only bleiben? | JA |
| Darf M16-DR eine spaetere YAML-Aenderung vorbereiten? | JA, als Vertrag fuer einen noch spaeteren, explizit freigegebenen Slice |

M16-DR sollte deshalb ein reines Markdown-Gate werden:

```text
M16-DR Uferwald Anchor Review Values Gate
```

M16-DR sollte nur den exakten Feldvertrag fuer `anchor_review_values`
definieren. Die bestehende Skeleton-YAML darf erst in einem noch spaeteren
Slice geaendert werden, wenn der Prompt Pfad, Feldfamilie, Statusschutz,
Datei-Check und weiterhin verbotene Werte ausdruecklich oeffnet.

## 12. Warum andere Wertfamilien noch warten muessen

`path_corridor_review_values`:

- wuerde schnell nach Centerline, Knoten oder Segmenten aussehen,
- braucht vorher Wasser-/Obstacle-/No-Walk-QA,
- ist fuer Visit/Wander wichtig, aber nicht die erste sichere Wertfamilie.

`water_boundary_review_values`:

- braucht manuelle Boundary-Planung,
- darf nicht aus Blauwerten oder Bildkanten entstehen,
- sollte erst nach einem eigenen Boundary-Gate kommen.

`no_walk_review_values` und `no_build_review_values`:

- sind Unionen aus mehreren Source-Layern,
- wuerden sehr schnell wie Runtime-Masks wirken,
- duerfen erst entstehen, wenn Source-Layer und QA stabil sind.

`sort_band_review_values`:

- sind weniger gefaehrlich als Path- oder Union-Werte,
- koennen aber Renderer-Implementation suggerieren,
- sollten nach Anchor-Rollen folgen.

`buildable_zone_review_values`:

- koennen als Slots, Plots oder Kategorieplaetze missverstanden werden,
- brauchen No-Build-, Footprint- und Attachment-Regeln,
- bleiben fuer den ersten Value-Pfad blockiert.

## 13. Nicht-Freigaben

M16-DQ gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine neue `.yaml`-Datei,
- keine Aenderung an der bestehenden YAML,
- keine `.json`-Datei,
- keine `.yml`-Datei,
- keine finalen Koordinaten,
- keine Koordinatenbeispiele,
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

## 14. Folgepfad

Empfohlen:

```text
M16-DR Uferwald Anchor Review Values Gate
```

M16-DR sollte weiterhin Markdown-only bleiben. Ziel waere, den
`anchor_review_values`-Feldvertrag so eng zu definieren, dass ein spaeterer
M16-DS-Slice die bestehende Skeleton-YAML gezielt und sicher erweitern
koennte. M16-DR selbst darf keine YAML-Aenderung, keine echten Werte und keine
Runtime-Daten erzeugen.
