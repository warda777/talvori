# M16-DJ: Uferwald Visual Precision Review

Stand: 2026-06-12

Status: `review_slice`, `documentation_only`, `no_new_visuals`,
`not_runtime_data`, `not_asset`, `not_engine_ready`

## 1. Zweck

M16-DJ prueft den abgeschlossenen M16-DI Uferwald Measurement Visual
Precision Pass fachlich. Ziel ist nicht, weitere Visuals zu erzeugen, sondern
zu entscheiden, ob die vier getrennten Pruefansichten ausreichen, um danach
einen Schema-/Planungs-Gate-Slice vorzubereiten.

M16-DJ erzeugt keine neuen Bilder, keine SVG/PNG-Dateien, keine JSON/YAML-
Dateien, keine Runtime-Mapdaten, keine Assets, keine App-Integration und
keinen Code.

## 2. Review-Basis

Gelesene Pflichtgrundlagen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/392-uferwald-measurement-visual-precision-pass.md`
- `docs/world_design/391-uferwald-measurement-precision-pass.md`
- `docs/world_design/390-uferwald-technical-measurement-review.md`
- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/previews/m16_di_uferwald_measurement_visual_precision_pass/README.md`

Gepruefte M16-DI-Visuals:

- `01_walkable_and_water_review.png`
- `02_build_and_no_build_review.png`
- `03_obstacles_and_occlusion_review.png`
- `04_anchors_and_sort_bands_review.png`
- `uferwald_measurement_visual_precision_contact_sheet.png`
- `uferwald_measurement_visual_precision_pass.svg`
- `uferwald_measurement_visual_precision_pass.png`

## 3. Gesamturteil

Die M16-DI-FIX-Trennung in vier Detailansichten ist fachlich gelungen. Die
Visuals sind deutlich besser pruefbar als ein ueberladenes Gesamtbild, weil
jedes Bild eine eigene Frage beantwortet:

- Wo darf spaeter gelaufen werden und wo blockieren Wasser oder Puffer?
- Wo koennte spaeter gebaut werden, ohne feste Slots zu markieren?
- Welche Elemente sind Dekoration, Blocker oder nur Occlusion?
- Welche Punkte sind Rollenanker und wie sind grobe Sort-Bands gedacht?

Damit ist M16-DI ausreichend fuer den naechsten Schema-/Planungs-Gate-Slice.
M16-DI ist nicht ausreichend fuer Runtime-Daten, finale Koordinaten, echte
Polygone, JSON/YAML-Dateien, Flutter-Code, Assets oder Engine-ready-
Entscheidungen.

## 4. Bewertung je Pruefansicht

| Pruefansicht | Status | Ausreichend fuer Schema-/Planungs-Gate | Noch unklar / nicht freigegeben |
| --- | --- | --- | --- |
| Walkable / Water | ausreichend | Ja. Der breite `planning_path_corridor`, Wasserflaechen, harte Wassergrenze, `water_no_walk_buffer`, Engpass- und Konfliktmarker sind getrennt lesbar. Die Ansicht impliziert keine Runtime-Centerline, sondern einen Review-Korridor. | Exakte Pfadpolygone, Runtime-Path-Centerline, Knotenfolge, Pathfinding-Kosten und final gemessene Breiten bleiben offen. |
| Build / No-Build | ausreichend | Ja. Organische Build-Zonen sind als Eignungsraeume erkennbar, nicht als feste Slots. `no_build_mask`, Wegschutz, Wasser-/Rand-/Hub-/Anchor-Schutz sind sichtbar getrennt. | Exakte Build-Polygone, Footprint-Groessen je Gebaeudefamilie, Guard-Radien und echte Kapazitaetsberechnung bleiben offen. |
| Obstacles / Occlusion | ausreichend mit kleiner Folgepraezisierung | Ja. Dekorative Baeume/Felsen, harte Baum-/Felsblocker und Occlusion-Kanten sind unterscheidbar. Der Hinweis `Occlusion != Collision` verhindert die wichtigste Fehlinterpretation. | Weiche Waldkanten und genaue Blocker-Ausdehnung muessen im naechsten Schema als Rollen/Felder weiter getrennt werden; keine Pixelableitung. |
| Anchors / Sort-Bands | ausreichend | Ja. Anchor-Rollen fuer `landmark`, `path_node`, `build_reference` und `object_focus_reference` sind verstaendlich. `background_north`, `midground_center` und `foreground_south` sind als Sort-Bands erkennbar. | Keine finalen Koordinaten, keine Runtime-Anker, keine Renderer-Implementation und keine finale Sortierformel. |

## 5. Contact Sheet, Overview und README

Das Contact Sheet ist als schneller Review-Einstieg geeignet. Es zeigt die
vier Detailansichten nebeneinander, haelt die Statuslabels sichtbar und macht
klar, dass die Detail-PNGs das eigentliche Pruefmaterial sind.

Das SVG/PNG-Hauptvisual ist als Uebersicht sinnvoll, aber nicht die fuehrende
Pruefquelle. Es reduziert die Komplexitaet auf vier Kartenbereiche und
verweist korrekt auf die Detailansichten.

Die Preview-README benennt die Dateien, den Status und die Grenzen klar:
keine Runtime-Mapdaten, keine finalen Koordinaten, keine JSON/YAML-Daten,
keine Assets, keine Dateien unter `assets/`, keine Engine-ready Candidates
und keine App- oder Code-Freigabe.

## 6. Was ausreichend ist

Ausreichend fuer den naechsten Schema-/Planungs-Gate-Slice sind:

- die Trennung von `planning_path_corridor`, Wassergrenze und Wasserpuffern,
- organische Build-Zonen ohne feste Slots oder Kategorieplaetze,
- getrennte No-Walk- und No-Build-Review-Unionen,
- sichtbare Deko-/Blocker-/Occlusion-Rollen fuer Baeume und Felsen,
- sichtbare Sort-Bands als Planungsrollen, nicht als Renderer-Code,
- Anchor-Rollen als Grundlage fuer ein spaeteres Planungs-/Schemafeldmodell,
- klare Statusmarkierung als Dokumentationsvisual.

## 7. Was noch unklar bleibt

Nicht ausreichend geklaert sind:

- exakte Polygonpunkte,
- finale Anchor-Koordinaten,
- echte Runtime-Path-Centerlines,
- konkrete Pathfinding-Graphen,
- Build-Footprint-Masse je Objektfamilie,
- genaue No-Walk-/No-Build-Union-Geometrien,
- maschinenlesbare JSON/YAML-Strukturen,
- Flutter- oder Renderer-Verhalten,
- Asset- oder Engine-ready-Export.

Diese Luecken sind fuer M16-DJ kein Fehler, solange sie im naechsten Gate als
Planungsfelder und offene Messfragen behandelt werden.

## 8. Entscheidung

| Frage | Entscheidung |
| --- | --- |
| Sind die vier getrennten Pruefansichten ausreichend verstaendlich? | JA |
| Sind sie ausreichend praezise fuer ein Schema-/Planungs-Gate? | JA |
| Ist ein M16-DI-FIX-2 vor dem naechsten Schritt noetig? | NEIN |
| Duerfen daraus JSON/YAML- oder Runtime-Daten entstehen? | NEIN |
| Duerfen daraus finale Koordinaten entstehen? | NEIN |
| Duerfen daraus Assets, Engine-ready Candidates oder App-Code entstehen? | NEIN |

M16-DI darf als fachlich ausreichend fuer einen naechsten Docs-only
Schema-/Planungs-Gate-Slice gelesen werden. Dieser Folge-Slice darf
Planungsfelder, Rollen, Statuswerte, QA-Felder und offene Messfragen
definieren. Er darf ohne separate Freigabe keine JSON/YAML-Datei, keine
Runtime-Mapdaten, keine finalen Koordinaten, keine neuen Visuals, keine Assets
und keinen Code erzeugen.

## 9. Risiken bei falscher Weiterverwendung

- Die Detailansichten koennten faelschlich als exakte Geometrie oder
  Runtime-Karte gelesen werden.
- Der Walkable-Korridor koennte als fertige Path-Centerline missverstanden
  werden.
- Build-Zonen koennten wieder zu festen Slots oder Kategorieplaetzen werden.
- Occlusion-Kanten koennten faelschlich als Collision-Masken genutzt werden.
- Sort-Bands koennten zu frueh als Renderer-Implementation festgeschrieben
  werden.
- Anchor-Rollen koennten ohne Mess-Gate als finale Koordinaten benutzt werden.

## 10. Empfohlener naechster Slice

Empfohlen ist:

`M16-DK Uferwald Technical Planning Schema Gate`

Ziel dieses Folge-Slices sollte sein, ein reines Markdown-Schema fuer die
spaetere Planungsstruktur zu definieren:

- Layer-IDs und Layer-Rollen,
- Rollen-/Status-Enums fuer Walkability, Buildability, Obstacles, Occlusion,
  Anchors und Sort-Bands,
- Pflichtfelder fuer spaetere Mess- oder Vector-Planung,
- QA-Felder und Blockerstatus,
- klare Grenze gegen Runtime-Daten und JSON/YAML-Dateierzeugung.

Nicht empfohlen ist:

- M16-DI-FIX-2,
- direkte JSON/YAML-Erzeugung,
- direkte Runtime-Mapdaten,
- Flutter-/Preview-Code,
- neue Visuals,
- Asset- oder Engine-ready-Arbeit.

## 11. Nicht-Freigaben

M16-DJ gibt nicht frei:

- Code,
- Flutter-/Dart-Dateien,
- App-Integration,
- Route oder Navigation,
- Persistenz,
- `BuildState`,
- Tests,
- Bilder, SVGs oder PNGs,
- JSON/YAML-Dateien,
- Runtime-Mapdaten,
- Dateien unter `assets/`,
- Assets,
- Engine-ready Candidates,
- Figma-/externe Writes,
- Commit.
