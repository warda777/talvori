# M16-DI: Uferwald Measurement Visual Precision Pass

Stand: 2026-06-11

Status: `visual_documentation / measurement_precision_review_visual`

Template: `docs/world_design/prompt_templates/visual_documentation_slice.md`

## 1. Zweck

M16-DI macht die Praezisionsregeln aus M16-DH sichtbar pruefbar. Das Ziel ist
ein SVG/PNG-Dokumentationsvisual plus getrennte Detail-Review-PNGs, damit
Pfadbreiten, Wasser-/Uferpuffer, Baum-/Hainrollen, Fels-/Klippenrollen,
No-Walk-/No-Build-Unionen, Pfad-gegen-Blocker-QA, Sort-/Occlusion-Kanten und
Anchor-Rollen nicht in einem ueberladenen Bild verschwinden.

M16-DI erzeugt keine technische Spielkarte. Das Visual ist ein
`documentation_only`- und `planning_visual`-Artefakt, nicht Runtime-Daten, kein
Asset und nicht engine-ready.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
- `docs/world_design/390-uferwald-technical-measurement-review.md`
- `docs/world_design/391-uferwald-measurement-precision-pass.md`

Diese Quellen legen fest: Sichtbare Uferwald-Art bleibt Kontext. Spielbare
Kartenlogik darf nicht aus Pixeln geraten werden. Erst technische Layer,
Masks, Zonen, Puffer, Sort-Regeln und Anchor-Rollen, danach visuelle
Umsetzung, danach erst Runtime-/Flutter-Entscheidungen.

## 3. Erzeugte Dokumentationsvisuals

Preview-Ordner:

```text
docs/world_design/previews/m16_di_uferwald_measurement_visual_precision_pass/
```

Dateien:

| Datei | Rolle | Status |
| --- | --- | --- |
| `uferwald_measurement_visual_precision_pass.svg` | SVG-Uebersicht ueber die vier getrennten Review-Ansichten. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `uferwald_measurement_visual_precision_pass.png` | Raster-Review-Version der SVG-Uebersicht. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `uferwald_measurement_visual_precision_contact_sheet.png` | Contact Sheet mit allen vier Pruefansichten. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `01_walkable_and_water_review.png` | Detailansicht fuer Laufkorridore, Wasser, Uferpuffer, Engpass und Konfliktmarker. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `02_build_and_no_build_review.png` | Detailansicht fuer organische Build-Zonen, No-Build, Wegschutz und Hub-/Anchor-Schutz. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `03_obstacles_and_occlusion_review.png` | Detailansicht fuer dekorative Elemente, harte Blocker und Occlusion-Kanten. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `04_anchors_and_sort_bands_review.png` | Detailansicht fuer Anchor-Rollen und Sort-Bands. | `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`, `not_engine_ready` |
| `README.md` | Preview-Ordner-Hinweis und Statusschutz. | Dokumentation |

## 4. M16-DI-FIX-Lesbarkeitsregel

Die erste M16-DI-Gesamtansicht war fachlich vollstaendig, aber fuer Review zu
ueberladen. M16-DI-FIX setzt deshalb eine feste Lesbarkeitsregel:

- Das Haupt-SVG/PNG ist nur eine Uebersicht ueber die vier Pruefansichten.
- Die eigentliche fachliche Pruefung erfolgt ueber vier getrennte Detail-PNGs.
- Jede Detailansicht zeigt nur wenige Farben und nur die Layer, die fuer diese
  konkrete Frage relevant sind.
- Legenden bleiben kurz.
- Kartenlabels sind groesser und gezielter gesetzt.
- Contact Sheet zeigt alle vier Ansichten fuer schnelle Review-Orientierung.

## 5. Was der Visual Precision Pass zeigt

Die Detail-Visuals zeigen sichtbar:

- `planning_path_corridor` als breite Korridore, nicht als duenne Linie,
- normale Pfadbreite mit mindestens `3.0 x visitor_marker_diameter`,
- Engpass-Marker fuer Bereiche unter `3.0 x`, aber nicht unter `2.0 x`,
- Wassergrenze mit `water_no_walk_buffer`,
- `water_no_build_buffer` als eigene Bausperren-Pruefung,
- `decorative_tree`, `soft_forest_edge`, `hard_tree_blocker`,
  `tree_occlusion_edge`,
- `decorative_rock`, `hard_rock_blocker`, `cliff_edge`,
  `height_occlusion_edge`,
- `no_walk_mask` als Review-Union,
- `no_build_mask` als getrennte Review-Union,
- Pfad-gegen-Blocker-QA mit Clearance-, Engpass- und Konfliktmarkern,
- `background_north`, `midground_center`, `foreground_south`,
- Anchor-Rollen: `landmark`, `path_node`, `build_reference`,
  `object_focus_reference`.

Die Build-Zonen bleiben organische Eignungsraeume. Das Visual zeigt keine
festen Slots, keine festen Kategorieplaetze und keine Runtime-Placement-Daten.

## 6. Praezisionsregeln im Visual

### 6.1 Walkable/Water-Review

`01_walkable_and_water_review.png` beantwortet die Frage:

```text
Wo darf man laufen und wo nicht?
```

Sichtbar sind:

- breite `planning_path_corridor`,
- Wasserflaeche,
- harte Wassergrenze,
- `water_no_walk_buffer`,
- Engpass-/Konfliktmarker,
- Laufkorridor als Review-Band, nicht als Runtime-Centerline.

### 6.2 Build/No-Build-Review

`02_build_and_no_build_review.png` beantwortet die Frage:

```text
Wo koennte spaeter gebaut werden und wo nicht?
```

Sichtbar sind:

- organische Build-Zonen,
- `no_build_mask`,
- Wegschutz,
- Wasser-/Rand-/Hub-/Anchor-Schutz,
- keine festen Slots,
- keine festen Kategorieplaetze.

### 6.3 Obstacles/Occlusion-Review

`03_obstacles_and_occlusion_review.png` beantwortet die Frage:

```text
Was ist Deko, was blockiert, was verdeckt nur?
```

Sichtbar sind:

- `decorative_tree` vs `hard_tree_blocker`,
- `decorative_rock` vs `hard_rock_blocker`,
- `tree_occlusion_edge`,
- `height_occlusion_edge`,
- klare Trennung zwischen Occlusion und Collision.

### 6.4 Anchors/Sort-Bands-Review

`04_anchors_and_sort_bands_review.png` beantwortet die Frage:

```text
Welche Punkte sind Orientierung, Pfad-, Build- oder Objektbezug?
```

Sichtbar sind:

- `landmark`,
- `path_node`,
- `build_reference`,
- `object_focus_reference`,
- `background_north`,
- `midground_center`,
- `foreground_south`.

Anchor-Marker bleiben Rollenmarker. Sie sind keine finalen Koordinaten, keine
Runtime-Anker und keine gespeicherten Interaktionspunkte.

### 6.5 Pfadbreiten

Der Pfad wird als Planungskorridor dargestellt. Der breite Standardkorridor ist
visuell auf `3.0 x visitor_marker_diameter` ausgelegt. Der markierte Engpass
zeigt eine Review-Zone zwischen `2.0 x` und `3.0 x`, die spaeter nicht
automatisch in Runtime-Pfade uebernommen werden darf.

Wichtig: Das Visual erzeugt keine Runtime-Path-Centerline. Es zeigt nur
Korridore, Breitenklassen und QA-Bedarf.

### 6.6 Wasser und Uferpuffer

Das Visual trennt:

- harte Wasserflaeche,
- Wassergrenze,
- `water_no_walk_buffer`,
- `water_no_build_buffer`.

Damit bleibt sichtbar, dass Begehbarkeit und Bebaubarkeit verschiedene
Sperrlogiken haben. Bruecken, Furten oder Querungen bleiben weiterhin bis zu
einem eigenen Gate blockiert.

### 6.7 Baum-, Hain-, Fels- und Klippenrollen

Das Visual trennt dekorative Elemente, weiche Kanten, harte Blocker und
Occlusion-Kanten:

- dekorative Baeume sind nicht automatisch Blocker,
- `soft_forest_edge` ist Uebergangsraum,
- `hard_tree_blocker` sperrt Bewegung und Bauen,
- `tree_occlusion_edge` betrifft Vorder-/Hintergrund, nicht automatisch
  Collision,
- dekorative Felsen sind nicht automatisch Sperren,
- `hard_rock_blocker` und `cliff_edge` erzeugen harte Pruefzonen,
- `height_occlusion_edge` betrifft Sort-/Occlusion-Review.

### 6.8 No-Walk und No-Build

`no_walk_mask` und `no_build_mask` sind getrennt visualisiert. Das schuetzt vor
der falschen Annahme, dass dieselbe Maske fuer Bewegung und Bauen reicht.

`no_walk_mask` prueft harte Bewegungsgrenzen. `no_build_mask` prueft
Bausperren, Puffer, Hub-/Anchor-Schutz, Wegschutz und spaetere
Attachment-Reserven.

### 6.9 Sort-/Occlusion-Regeln

Das Visual zeigt drei Review-Bands:

- `background_north`
- `midground_center`
- `foreground_south`

Zusätzlich sind `tree_occlusion_edge` und `height_occlusion_edge` sichtbar.
Das bleibt Review-Logik fuer spaetere Sortierung, keine Renderer-
Implementation.

### 6.10 Anchor-Rollen

Anchor-Marker sind Rollenmarker, keine finalen Koordinaten:

- `landmark`,
- `path_node`,
- `build_reference`,
- `object_focus_reference`.

Mehrfachrollen bleiben erlaubt, muessen aber spaeter explizit dokumentiert
werden. Kein Anchor aus M16-DI ist ein Runtime-Anchor, ein gespeicherter State,
ein Slot oder ein App-Interaktionspunkt.

## 7. Visual-QA

M16-DI-Visual-QA:

- Statushinweise sind sichtbar:
  `documentation_only`, `planning_visual`, `not_runtime_data`, `not_asset`,
  `not_engine_ready`.
- Legenden sind pro Detailbild vorhanden und kurz.
- Contact Sheet ist vorhanden und lesbar.
- Labels bleiben im Rahmen.
- Keine abgeschnittenen Texte.
- Keine starken Label-Ueberlappungen.
- No-Walk und No-Build sind getrennt dargestellt.
- Pfadkorridore sind breit gezeichnet und nicht als Runtime-Centerline
  markiert.
- Pfadkorridore schneiden keine harten Wasser-/Baum-/Felsblocker, ausser als
  bewusster QA-Konfliktmarker.
- Build-Zonen sind organisch und nicht als feste Slots gezeichnet.
- Sort-/Occlusion-Regeln sind sichtbar, aber nicht als Renderer-
  Implementation markiert.

## 8. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| M16-DH-Regeln sichtbar pruefbar gemacht | JA |
| Ueberladene Gesamtansicht in vier Pruefansichten getrennt | JA |
| SVG-Uebersicht erzeugt | JA |
| PNG-Uebersicht erzeugt | JA |
| Vier Detail-PNGs erzeugt | JA |
| Contact Sheet erzeugt | JA |
| Finale Koordinaten erzeugt | NEIN |
| Runtime-Path-Centerline erzeugt | NEIN |
| JSON/YAML-Daten erzeugt | NEIN |
| Assets oder Dateien unter `assets/` erzeugt | NEIN |
| App-/Flutter-Integration freigegeben | NEIN |

## 9. Was weiterhin blockiert bleibt

Weiterhin blockiert:

- finale Koordinaten,
- echte Polygon-Dateien,
- JSON/YAML-Manifest oder Schema-Datei,
- Runtime-Mapdaten,
- Pathfinding,
- Collision-/Walkability-Daten,
- Buildability-/Placement-Runtime-Daten,
- Flutter-/Dart-Code,
- App-Integration,
- Persistenz,
- BuildState,
- Assets oder Dateien unter `assets/`,
- Engine-ready Candidates,
- approved Assets.

## 10. Risiken

Wichtigste Risiken:

- Das SVG wird als Runtime-Geometrie missverstanden.
- Pfadkorridore werden als echte Movement-Paths gelesen.
- Anchor-Rollen werden als finale Koordinaten gelesen.
- No-Walk und No-Build werden wieder zusammengeworfen.
- Occlusion-Kanten werden faelschlich als Collision verstanden.
- Organische Build-Zonen werden als feste Slots interpretiert.
- Das Contact Sheet wird als Runtime-Plan statt als Review-Uebersicht gelesen.

Diese Risiken werden durch sichtbare Status-Badges, getrennte Detailansichten,
kurze Legenden, Contact Sheet, README, 336 und diese Gate-Dokumentation
begrenzt.

## 11. Folgepfad

Empfohlener naechster Slice:

```text
M16-DJ Uferwald Visual Precision Review
```

M16-DJ sollte den M16-DI-SVG-/PNG-Plan fachlich reviewen und entscheiden:

- ob Pfadbreiten und Engpaesse ausreichend sichtbar sind,
- ob No-Walk und No-Build sauber getrennt sind,
- ob Wasser-/Baum-/Felsblocker plausibel bleiben,
- ob Sort-/Occlusion-Kanten fuer einen naechsten Schema-Gate reichen,
- welche Visual-Regeln vor JSON/YAML weiter praezisiert werden muessen.

Erst nach einem Review darf ein weiterer Gate-Slice pruefen, ob eine
maschinennaehere Planungsstruktur oder ein Schema vorbereitet werden darf.

## 12. Stop-Regeln

M16-DI gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine JSON/YAML-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine finalen Koordinaten,
- keine Runtime-Path-Centerline,
- keine Figma-Writes,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.
