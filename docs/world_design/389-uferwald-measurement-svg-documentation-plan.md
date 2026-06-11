# M16-DF: Uferwald Measurement SVG Documentation Plan

Stand: 2026-06-11

Status: `visual_documentation / measurement_overlay_plan`

Template: `docs/world_design/prompt_templates/visual_documentation_slice.md`

## 1. Zweck

M16-DF erzeugt den ersten visuellen Uferwald Measurement SVG Documentation
Plan. Das Visual macht technische Layer, Masks, Zonen und Sort-Bands sichtbar
pruefbar, ohne daraus Runtime-Daten, finale Koordinaten, Assets oder
App-Integration abzuleiten.

Der Plan ist ein Review-Werkzeug fuer Diskussion, QA und Folgebriefing. Er ist
nicht die technische Spielkarte.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`

Diese Quellen legen fest: Das sichtbare Art-Bild bleibt Review-Kontext. Die
technische Karte braucht Layer, Masks, Zonen und Mess-/Vector-QA vor Runtime-
oder Gameplay-Nutzung.

## 3. Erzeugte Dokumentationsvisuals

Preview-Ordner:

```text
docs/world_design/previews/m16_df_uferwald_measurement_svg_documentation_plan/
```

Dateien:

| Datei | Rolle | Status |
| --- | --- | --- |
| `uferwald_measurement_svg_documentation_plan.svg` | Fuehrendes Vektor-Dokumentationsvisual fuer Layer/Masks/Zonen. | `documentation_only`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `uferwald_measurement_svg_documentation_plan.png` | Raster-Review-Version des SVG-Plans. | `documentation_only`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `README.md` | Preview-Ordner-Hinweis und Statusschutz. | Dokumentation |

## 4. Was das Visual zeigt

Das Visual zeigt grob und absichtlich nicht-final:

- `base_rock_shape`
- `water_river_mask`
- `tree_obstacle_layer`
- `rock_cliff_obstacle_layer`
- `walkable_path_layer`
- `buildable_zone_layer`
- `no_walk_mask`
- `no_build_mask`
- `depth_sort_bands`
- `landmark_anchor_layer`

Die Formen sind Review- und Messplan-Platzhalter. Sie sind keine finalen
Polygone, keine Koordinatenquelle und keine Runtime-Mapdaten.

## 5. Visual-Konventionen

| Ebene | Darstellung im Plan | Aussage |
| --- | --- | --- |
| `base_rock_shape` | warme Landmasse mit gestrichelter Kontur | technische Aussenform spaeter manuell messen |
| `water_river_mask` | blaue Wasserflaeche und Flussarm | Wasser als eigene Maske planen |
| `tree_obstacle_layer` | gruene Hain-/Waldzone | harte und weiche Vegetationsblocker spaeter trennen |
| `rock_cliff_obstacle_layer` | graue Fels-/Klippenzonen | Felsen nicht aus Schatten raten |
| `walkable_path_layer` | heller Planungskorridor | kein Runtime-Pathfinding |
| `buildable_zone_layer` | organische gruene Eignungsraeume | keine festen Slots, keine Kategorieplaetze |
| `no_walk_mask` | rote Kontur/Hatch-Hinweise | Sperren fuer Bewegung getrennt pruefen |
| `no_build_mask` | violette/orange Schutzflaechen | Sperren fuer Bauen getrennt pruefen |
| `depth_sort_bands` | drei horizontale Transparenzbaender | grobe Review-Sortierung, kein Renderer |
| `landmark_anchor_layer` | nummerierte Ankerpunkte | benannte Referenzen, keine finalen Koordinaten |

## 6. Mess- und Runtime-Grenze

M16-DF behauptet keine finalen Koordinaten. Das SVG darf nicht als Runtime-
Geometrie exportiert oder automatisch in JSON/YAML, Flutter, Collision,
Walkability oder Placement-Daten uebersetzt werden.

Erlaubt durch M16-DF:

- visuelle QA der technischen Ebenen,
- Diskussion der Reihenfolge und Konflikte,
- Vorbereitung eines spaeteren Measurement-Review-Slices.

Nicht erlaubt durch M16-DF:

- Runtime-Mapdaten,
- finale Polygon- oder Anchor-Koordinaten,
- Figma-Writes,
- JSON/YAML-Runtime-Manifest,
- Assets oder Dateien unter `assets/`,
- Engine-ready Candidates,
- App-/Flutter-Integration.

## 7. Visual-QA

M16-DF-Visual-QA:

- SVG und PNG enthalten sichtbare Statushinweise:
  `documentation_only`, `not_runtime_data`, `not_asset`, `not_engine_ready`.
- Legende ist vorhanden.
- Labels bleiben im Rahmen.
- Keine abgeschnittenen Texte.
- Keine starken Label-Ueberlappungen.
- No-Walk und No-Build sind getrennt dargestellt.
- Build-Zonen sind organisch und nicht als feste Slots gezeichnet.
- Pfade sind als Planungskorridore markiert, nicht als Runtime-Pathfinding.
- Sort-Bands sind grobe Review-Baender, keine Renderer-Implementation.

## 8. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| SVG-Dokumentationsplan erzeugt | JA |
| PNG-Review-Version erzeugt | JA |
| Technische Layer/Masks/Zonen visuell pruefbar | JA |
| Finale Koordinaten erzeugt | NEIN |
| Runtime-Mapdaten erzeugt | NEIN |
| Assets oder Dateien unter `assets/` erzeugt | NEIN |
| Figma-Write ausgefuehrt | NEIN |
| JSON/YAML-Runtime-Daten erzeugt | NEIN |

## 9. Folgepfad

Empfohlener naechster Slice:

```text
M16-DG Uferwald Technical Measurement Review
```

M16-DG sollte den SVG-/PNG-Plan fachlich reviewen und entscheiden, welche
Layer zuerst in eine echte Messplanung gehen duerfen. Erst danach ist ein
weiterer Gate-Slice fuer JSON/YAML-Planung oder manuelle Polygonarbeit sinnvoll.

## 10. Stop-Regeln

M16-DF gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Assets,
- keine Dateien unter `assets/`,
- keine finalen Koordinaten,
- keine Figma-Writes,
- keine JSON/YAML-Runtime-Daten,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.
