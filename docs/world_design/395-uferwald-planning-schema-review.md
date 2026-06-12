# M16-DL: Uferwald Planning Schema Review

Stand: 2026-06-12

Status: `Docs-/Review-Slice / keine JSON/YAML-Datei / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/review_slice.md`

## 1. Zweck

M16-DL reviewt das M16-DK Uferwald Technical Planning Schema Gate. Ziel ist
die fachliche Entscheidung, ob das Markdown-Schema aus `394` ausreichend ist,
um danach ein sehr enges JSON/YAML-Planning-Format-Gate vorzubereiten.

M16-DL erzeugt keine JSON/YAML-Datei, keine Runtime-Daten, keine finalen
Koordinaten, keine Polygone, keine Bilder, keine SVG/PNG-Dateien, keine
Assets, keine App-Integration und keinen Code.

## 2. Review-Basis

Gelesene Pflichtdokumente:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
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

Fuehrende Regel aus der Kette:

> Sichtbares Art-Bild ist nicht die technische Spielkarte.

M16-DK muss deshalb ein Feldschema bleiben. Es darf maschinennahe
Planungsarbeit vorbereiten, aber noch keine technische Karte, keine Runtime-
Geometrie und keine produktiven Daten erzeugen.

## 3. Gesamturteil

M16-DK ist fuer den naechsten engen Planungsschritt ausreichend.

Das Schema trennt Layer-IDs, Rollen, Statuswerte, QA-Felder, offene
Messfragen, Pixelableitungsverbote, manuelle/vectorbasierte Messpflichten,
Runtime-Review-Pflichten und Blockerstatus klar genug. Es erzeugt keine
echten Werte, keine Koordinaten, keine Polygone und keine JSON/YAML-Datei.

Ein M16-DK-FIX ist nicht noetig.

Ein M16-DM JSON/YAML Planning Format Gate darf vorbereitet werden, aber nur
als sehr enges Format-Gate. M16-DM darf nicht automatisch Runtime-Daten,
finale Koordinaten, Polygonpunkte, Pfadknoten, Asset-Dateien, App-Integration
oder Code oeffnen.

## 4. Review nach Prueffeldern

| Thema | Status | Bewertung |
| --- | --- | --- |
| Layer-IDs | ausreichend | M16-DK fuehrt alle Pflicht-Layer aus M16-DA bis M16-DH: `base_rock_shape`, `grass_terrain_mask`, `water_river_mask`, `walkable_path_layer`, `tree_obstacle_layer`, `rock_cliff_obstacle_layer`, `buildable_zone_layer`, `plot_footprint_layer`, `no_walk_mask`, `no_build_mask`, `depth_sort_bands` und `landmark_anchor_layer`. |
| Layer-Rollen | ausreichend | Die Rollen bleiben getrennt und greifen die technischen Rollen aus 385/386 auf. Kein Layer wird als fertige Runtime-Quelle beschrieben. |
| Gemeinsame Pflichtfelder | ausreichend | `schema_id`, `slice_id`, `map_id`, `schema_status`, `coordinate_space`, `canvas_origin`, `world_origin_reference`, `source_docs`, `blocked_scope` und `next_review_gate` geben genug Struktur fuer ein Folgeformat, ohne Werte zu behaupten. |
| Geometry-Placeholder | ausreichend | M16-DK benennt Geometrie-Feldgruppen nur als Platzhalter und blockiert `geometry_values`, `coordinate_values` und `polygon_points` ausdruecklich. |
| Rollen-/Status-Enums | ausreichend | Walkability, Buildability, Obstacles, Occlusion, Anchors, Sort-Bands, Path Corridor und Water/Buffer sind getrennt genug, um M16-DM zu strukturieren. |
| QA-Felder | ausreichend | QA-Felder pruefen Statusschutz, Pixelableitungsverbot, manuelle Messpflicht, Runtime-Review-Pflicht, No-Walk/No-Build-Trennung, Blockerstatus und offene Messfragen. |
| Offene Messfragen | ausreichend | Das Schema fordert offene Messfragen pro Layer und verhindert, dass unbekannte Pfad-, Wasser-, Blocker-, Build-, Anchor- oder Sort-Fragen als geloest erscheinen. |
| Pixelableitungsverbote | ausreichend | M16-DK verbietet Ableitung aus Pixeln fuer Walkability, Buildability, Wassergrenzen, Blocker, No-Walk/No-Build, Anchors, Sort-Bands, Path-Centerlines, Footprints und Kapazitaeten. |
| Manuelle/vectorbasierte Messpflicht | ausreichend | Das Schema zwingt spaetere Messung als manuelle oder vectorbasierte Arbeit und bleibt dadurch kompatibel mit 387/388. |
| Runtime-Review-Pflicht | ausreichend | M16-DK verlangt separates Review vor Runtime-Naehe. Kein Schemafeld ist eine Runtime-Freigabe. |
| Blockerstatus | ausreichend | Blockierte Nutzungen sind explizit: JSON/YAML-Datei, Runtime-Daten, finale Koordinaten, Polygone, Assets, Visuals, Code, App-Integration. |

## 5. Spezielle Risiko-Pruefung

### 5.1 Echte Geometrie

Bewertung: unproblematisch.

M16-DK bereitet keine echte Geometrie vor. Es nennt Feldgruppen und
Datenform-Kandidaten, erzeugt aber keine Koordinaten, keine Punktlisten, keine
Polygone, keine Pfadknoten und keine Runtime-Centerlines.

Wichtig fuer M16-DM: Auch ein JSON/YAML-Planning-Format darf zunaechst nur
Formatfelder und Platzhalterstatus definieren. Sobald echte Werte entstehen,
braucht es ein eigenes Mess-/Vector-/Runtime-Review-Gate.

### 5.2 JSON/YAML zu frueh

Bewertung: kontrolliert.

M16-DK spricht JSON/YAML nur als moegliches Folgeformat an. Es erzeugt keine
Datei und keine maschinenlesbaren Daten. Das reicht fuer ein M16-DM Format-
Gate, aber nicht fuer eine Datenfreigabe.

M16-DM muss deshalb ausdruecklich entscheiden:

- ob weiter Markdown-only geplant wird,
- ob eine Beispielstruktur nur im Dokument gezeigt wird,
- oder ob eine echte Planungsdatei erlaubt wird.

Ohne ausdrueckliche Folgefreigabe bleiben echte JSON/YAML-Dateien blockiert.

### 5.3 No-Walk und No-Build

Bewertung: ausreichend getrennt.

M16-DK behandelt No-Walk und No-Build als getrennte Rollen und prueft beide
separat. Das ist wichtig, weil ein Weg fuer Bewegung noetig sein kann, aber
trotzdem Build-Schutz ausloest; umgekehrt kann eine Flaeche nicht bebaubar
sein, ohne zwingend fuer Figuren unpassierbar zu sein.

### 5.4 Rollen-Trennung

Bewertung: ausreichend.

Walkability, Buildability, Obstacles, Occlusion, Anchors, Sort-Bands, Path
Corridor und Water/Buffer sind getrennt genug, um Fehler aus M16-CY-FIX-3 zu
vermeiden. Kein sichtbarer Pfad, Baum, Fels, Wasserbereich oder Huegel wird
automatisch zur technischen Wahrheit.

### 5.5 Runtime, Asset, Figma, Code und App-Grenzen

Bewertung: sauber blockiert.

M16-DK gibt keine Runtime-Mapdaten, keine Assets, keine Figma-Writes, keine
App-Integration, keine Flutter-/Dart-Dateien, keine Persistenz, keinen
BuildState und keinen Code frei. Diese Grenzen muessen in M16-DM erneut
stehen.

## 6. Offene Punkte fuer M16-DM

M16-DM sollte nicht M16-DK korrigieren, sondern das naechste Format-Gate sehr
eng zuschneiden. Pflichtgrenzen fuer M16-DM:

- M16-DM ist zuerst ein JSON/YAML Planning Format Gate, kein Runtime-Manifest.
- Keine finalen Koordinaten.
- Keine Polygonpunkte.
- Keine Path-Centerlines.
- Keine echten Waypoint-Koordinaten.
- Keine Build-Zonen-Polygone.
- Keine No-Walk-/No-Build-Union als Werteliste.
- Keine Daten unter `assets/`.
- Keine App-/Flutter-Integration.
- Keine Persistenz.
- Keine Figma-Writes.
- Keine Ableitung aus Pixelbildern.
- Jede Beispielstruktur muss als `planning_schema_only`, `not_runtime_data`
  und `no_geometry_values` markiert werden.

Wenn M16-DM eine echte Datei erzeugen soll, muss der Prompt den Pfad, Status,
Felder und Verbote explizit oeffnen. Ohne diese ausdrueckliche Oeffnung bleibt
M16-DM ein reines Markdown-Format-Gate.

## 7. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Ist M16-DK ausreichend? | JA |
| Ist M16-DK-FIX noetig? | NEIN |
| Darf danach ein M16-DM JSON/YAML Planning Format Gate vorbereitet werden? | JA |
| Darf M16-DM automatisch Runtime-Daten erzeugen? | NEIN |
| Darf M16-DM automatisch finale Koordinaten oder Polygone erzeugen? | NEIN |
| Darf M16-DM automatisch App-/Asset-/Code-Arbeit starten? | NEIN |

## 8. Nicht-Freigaben

M16-DL gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine JSON/YAML-Datei,
- keine finalen Koordinaten,
- keine Polygone,
- keine Path-Centerlines,
- keine Bilder,
- keine SVG/PNG-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Figma-Writes,
- keine externen Writes,
- keinen Commit.

## 9. Empfohlener naechster Slice

Empfohlen:

```text
M16-DM Uferwald JSON/YAML Planning Format Gate
```

M16-DM sollte nur klaeren, wie eine spaetere Planungsstruktur aussehen darf.
Der Slice darf echte JSON/YAML-Dateien oder Beispiel-Skeletons nur erzeugen,
wenn der M16-DM-Prompt dies ausdruecklich erlaubt und zugleich den Status
`planning_only`, `not_runtime_data`, `no_final_coordinates` und
`no_geometry_values` verbindlich macht.
