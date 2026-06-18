# Firenze City Exploration Master ID Cleanup Report

Stand: 2026-06-17

Status: `documentation_only` / `planning_svg_cleanup` / `not_runtime_data` /
`not_asset` / `not_engine_ready` / `no_yaml_json` / `no_app_integration`

## 1. Gelesene Dokumente

- `AGENTS.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/415-firenze-playable-city-ground-layer-and-anchors-gate.md`
- `docs/world_design/416-talvori-playable-area-specification-standard-v1.md`
- `docs/world_design/417-firenze-playable-city-layout-blueprint-v5.md`
- `docs/world_design/422-firenze-v5-final-handoff-correction-metadata.md`
- `docs/world_design/425-firenze-v5-final-correction-candidate-layers.md`
- `docs/world_design/previews/firenze_playable_city_layout_blueprint_v5/handoff_layers/README.md`

## 2. Geprüfte SVG-Datei

Geprüft und bereinigt:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master.svg
```

Root-Canvas:

- `width="1672"`
- `height="941"`
- `viewBox="0 0 442.38333 248.97292"`

## 3. Sicherungskopie

Vor der ID-Bereinigung wurde diese Sicherungskopie angelegt:

```text
docs/world_design/previews/firenze_master_technical_layout/firenze_city_exploration_master_before_id_cleanup.svg
```

## 4. Geometrie-Schutz

Die Bereinigung hat nur `id`- und `inkscape:label`-Attribute geändert.

Automatisch geprüft:

- Elementanzahl unverändert.
- Elementreihenfolge unverändert.
- Alle nicht-ID-/nicht-Label-Attribute unverändert.
- Sichtbarer Textinhalt unverändert.
- Keine `d`-Pfadwerte verändert.
- Keine `cx`-/`cy`-/`x`-/`y`-/`width`-/`height`-/`transform`-/`style`-Werte verändert.

Damit wurden keine Koordinaten, Pfadpunkte, Skalierungen, Transformationen,
Styles, Layer-Reihenfolgen oder sichtbaren Geometrien geändert.

## 5. Layer-Prüfung

Vorhandene Layer:

| Layer | Ergebnis |
| --- | --- |
| `00_reference_image` | vorhanden |
| `01_boundary` | vorhanden |
| `02_river_area` | vorhanden |
| `03_bridge_decks` | vorhanden |
| `04_main_roads` | vorhanden |
| `05_side_roads` | vorhanden |
| `06_parcels` | vorhanden |
| `07_landmarks` | vorhanden |
| `08_green_areas` | vorhanden |
| `09_urban_blocks` | vorhanden |
| `10_anchor_points` | vorhanden |
| `11_navigation_nodes` | vorhanden |
| `12_navigation_graph` | vorhanden, aber nicht als reine `12_navigation_edges`-Schicht getrennt |

Hinweis:

`12_navigation_graph` enthält Navigation-Nodes, Road-Access-Nodes und
Navigation-Edges gemeinsam. Das ist für einen manuellen Inkscape-Master
lesbar, aber vor einer späteren Area-Specification-JSON-Ableitung sollte
entschieden werden, ob die Graph-Objekte in getrennte Planungsfamilien
aufgeteilt werden müssen.

## 6. Umbenannte Objekte nach Layern

| Layer | Bereinigung |
| --- | --- |
| `00_reference_image` | Layer-ID auf `layer_00_reference_image`, Referenzbild auf `reference_image_trace` gesetzt. |
| `01_boundary` | Boundary-Pfad `path1` auf `boundary_playable_firenze` gesetzt. |
| `02_river_area` | River-Pfad `path2` auf `river_arno_area` gesetzt. |
| `03_bridge_decks` | 8 Bridge-Deck-Pfade auf `bridge_B01` bis `bridge_B08`; 8 sichtbare Textlabels auf `bridge_B01_label` bis `bridge_B08_label`. |
| `04_main_roads` | 7 Hauptstraßen auf `main_road_001` bis `main_road_007`. |
| `05_side_roads` | 42 Seitenstraßen auf `side_road_001` bis `side_road_042`. |
| `06_parcels` | 14 Parcel-Flächen auf `P01` bis `P14`; sichtbare Labels auf `P01_label` bis `P14_label`. |
| `07_landmarks` | 6 Landmark-Zonen auf `L01` bis `L06`; sichtbare Labels auf `L01_label` bis `L06_label`. |
| `08_green_areas` | 48 Green-Area-Pfade auf `G01` bis `G48`; sichtbare Labels soweit eindeutig auf `Gxx_label`; unklare/duplizierte Textobjekte als `needs_manual_review` markiert. |
| `09_urban_blocks` | 37 Urban-Block-Pfade auf `U01` bis `U37`; sichtbare Labels soweit eindeutig auf `Uxx_label`. |
| `10_anchor_points` | Parcel-Anker auf `P01_anchor` bis `P14_anchor`; Bridge-Anker auf `B01_anchor` bis `B08_anchor`; Ringe separat als `*_anchor_ring`; `city_center_anchor` und `city_spawn_start` erhalten. |
| `11_navigation_nodes` | Bridge-Nodes auf `B01_N/M/S` bis `B08_N/M/S`; Parcel-Entries auf `P01_entry_1/2` bis `P14_entry_1/2`. |
| `12_navigation_graph` | Graph-Nodes anhand vorhandener Labels benannt; Road-Access-Nodes auf `P01_access_1/2` bis `P14_access_1/2`; eindeutig beschriftete Edges auf vorhandene `E_<from>_<to>`-Namen gesetzt; unklare Edges als `E_needs_manual_review_###` markiert. |

Zusätzlich korrigiert:

- Der zweite Parcel-Anker war als weiteres `P01_anchor` gelabelt; er wurde
  gemäß Reihenfolge/Position auf `P02_anchor` gesetzt.
- Der dritte B02-Brückennode war als weiteres `B01_S` gelabelt; er wurde in
  der B02-Triplet-Reihenfolge auf `B02_S` gesetzt.
- Parcel-Entry-Namen wurden von Varianten wie `P01_entry` / `P01_2_entry` auf
  `P01_entry_1` / `P01_entry_2` normalisiert.

## 7. ID-Ergebnis

Nach der Bereinigung:

- Gesamtzahl IDs: 830
- Eindeutige IDs: 830
- Doppelte IDs: 0
- Verbleibende Inkscape-Standard-IDs (`path...`, `text...`, `image...` usw.): 0

## 8. Vollständigkeitsprüfung

| Familie | Ergebnis |
| --- | --- |
| `P01` bis `P14` | vollständig vorhanden |
| `bridge_B01` bis `bridge_B08` | vollständig vorhanden |
| `P01_anchor` bis `P14_anchor` | vollständig vorhanden |
| `B01_anchor` bis `B08_anchor` | vollständig vorhanden |
| `B01_N/M/S` bis `B08_N/M/S` | vollständig vorhanden |
| `P01_entry_1/2` bis `P14_entry_1/2` | vollständig vorhanden |
| `P01_access_1/2` bis `P14_access_1/2` | vollständig vorhanden |
| Navigation-Edges mit eindeutigem `E_<from>_<to>` | teilweise vorhanden |
| Navigation-Edges ohne eindeutigen Ziel-/Quellnamen | weiterhin vorhanden und markiert |

## 9. Objekte mit unklarer Zuordnung

Es wurden keine unklaren Objekte geraten. Unklare Objekte wurden stattdessen
explizit markiert:

| Layer | Anzahl | Markierung | Grund |
| --- | ---: | --- | --- |
| `08_green_areas` | 6 | `green_text_needs_manual_review_01` bis `_05`, plus `G08_label_needs_manual_review_duplicate_2` | Leere Textobjekte und doppelte sichtbare `G08`-Beschriftung. |
| `12_navigation_graph` | 185 | `E_needs_manual_review_001` bis `E_needs_manual_review_185` und einzelne `*_needs_manual_review_duplicate_*`-Nodes | Edge-Pfade ohne eindeutiges `E_<from>_<to>`-Label sowie doppelte Graph-Node-Labels. |

Die meisten offenen Review-Fälle liegen also nicht in Boundary, River, Parcels,
Bridge Decks, Anchors oder Parcel Entries, sondern im Navigation-Graph.

## 10. Erkannte fehlende oder doppelte IDs

Nach der Bereinigung:

- Keine doppelten IDs.
- Keine fehlenden Pflicht-IDs für Parcels, Bridges, Parcel-Anker,
  Bridge-Anker, Bridge-Nodes, Parcel-Entries oder Road-Access-Nodes.
- Keine Inkscape-Standard-IDs mehr.

Weiterhin fachlich offen:

- Navigation-Edges ohne eindeutige From/To-Zuordnung.
- Doppelte ursprüngliche Graph-Node-Namen wurden nicht geraten, sondern mit
  `needs_manual_review_duplicate` markiert.
- `12_navigation_graph` ist noch kein sauber getrenntes reines Edge-Layer.

## 11. Sichtbare Objekte auf falschen Layern

Keine offensichtlichen falschen Layer-Zuweisungen bei:

- Boundary,
- River,
- Bridge Decks,
- Main Roads,
- Side Roads,
- Parcels,
- Landmarks,
- Green Areas,
- Urban Blocks,
- Anchor Points,
- Bridge-/Parcel-Navigation-Nodes.

Zu prüfen:

- `12_navigation_graph` enthält gemischt Navigation-Nodes, Road-Access-Nodes
  und Edge-Pfade. Das ist keine sichtbare Fehlplatzierung, aber eine
  strukturelle Trennungslücke für spätere Datenableitung.

## 12. Offene manuelle Prüfstellen

Vor einer Area-Specification-JSON-Ableitung müssen mindestens diese Punkte
manuell geprüft werden:

1. Die `E_needs_manual_review_###`-Edges im `12_navigation_graph` müssen auf
   echte `E_<from>_<to>`-Namen gebracht werden.
2. Die doppelt markierten Graph-Node-Namen müssen fachlich entschieden werden.
3. Der `12_navigation_graph` sollte optional in logisch getrennte Familien für
   Crossroads, Road Access Nodes und Edges überführt werden.
4. Die 6 unklaren Green-Area-Textobjekte müssen in Inkscape geprüft werden:
   entfernen, sauber zuordnen oder bewusst als Hilfslabel behalten.

## 13. Bereitschaft für den nächsten Schritt

Bewertung:

```text
Area-Specification-JSON: NO
QA-Preview der bereinigten technischen Masterkarte: YES, mit Navigation-Graph-Review-Hinweis
```

Begründung:

- Die Kernfamilien Boundary, River, Bridges, Roads, Parcels, Landmarks,
  Anchors, Bridge-Nodes, Parcel-Entries und Access-Nodes sind jetzt eindeutig
  benannt.
- Die SVG ist geometrisch unverändert und hat keine Standard- oder doppelten
  IDs mehr.
- Für eine Area-Specification-JSON sind die unklaren Navigation-Edges noch zu
  riskant. Diese dürfen nicht geraten werden, weil daraus sonst falsche
  Walkability-/Reachability-Annahmen entstehen könnten.

## 14. Stop-Regel

Diese bereinigte SVG bleibt planning-only. Sie erzeugt keine Runtime-Daten,
keine finalen Koordinaten, keine produktiven Polygone, keine App-Integration,
keine Assets, kein YAML/JSON und keinen BuildState.
