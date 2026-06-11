# M16-CR: Uferwald Anchor Zone Layer Overlay Plan

Status: `visual_documentation / overlay_plan`
Candidate status remains: `layer_postprocess_candidate`
Commit status: no commit in this slice

## 1. Zweck

M16-CR uebersetzt den M16-CP/M16-CQ-Uferwald-`island_base`-Candidate in einen
visuellen Anchor-/Zone-/Layer-Overlay-Plan.

Der Slice erzeugt nur Dokumentationsvisuals ueber dem bestehenden M16-CP-1x-
Bild. Er erzeugt keine neuen Spielbilder, keine neuen Assets, keine echten
Layer, keine Engine-ready-Dateien und keinen Code.

## 2. Gepruefte Grundlage

Pflichtgrundlage:

- `336-documentation-map-and-slice-reading-rules.md`
- `379-uferwald-layer-candidate-intake-and-qa.md`
- `380-uferwald-layer-candidate-review-and-postprocess-decision.md`
- M16-CP-1x-Bild:
  `previews/m16_cp_uferwald_layer_candidate_intake_and_qa/talvori_island_base_uferwald_structure_postprocess_candidate_v1_1x.png`

M16-CQ entscheidet, dass Uferwald als Arbeitsname und fuehrende
Struktur-/Postprocess-Referenz weitergefuehrt wird. M16-CR macht diese
Entscheidung visuell pruefbar, ohne daraus ein Asset oder Pixelziel zu machen.

## 3. Erzeugte Dokumentationsvisuals

Preview-Ordner:

```text
docs/world_design/previews/m16_cr_uferwald_anchor_zone_layer_overlay_plan/
```

Dateien:

| Datei | Rolle | Status |
| --- | --- | --- |
| `talvori_uferwald_anchor_zone_layer_overlay_plan_1x.png` | PNG-Overlay-Board ueber dem M16-CP-1x-Bild | Dokumentationsvisual, kein Asset |
| `talvori_uferwald_anchor_zone_layer_overlay_plan.svg` | SVG-Version mit eingebettetem 1x-Bild und Vektor-Overlays | Dokumentationsvisual, kein Asset |
| `talvori_uferwald_free_build_capacity_overlay_1x.png` | PNG-Free-Build-Capacity-Overlay ueber dem M16-CP-1x-Bild | Dokumentationsvisual, kein Asset |
| `talvori_uferwald_free_build_capacity_overlay.svg` | SVG-Free-Build-Capacity-Overlay mit eingebettetem 1x-Bild und Vektor-Overlays | Dokumentationsvisual, kein Asset |

Das PNG und SVG zeigen:

- gemessene Uferwald-Anchors,
- Buildable / Soft Placement / Reserve,
- No-Build / No-Overlap / Water-only / Terrain-sensitive,
- grobe Sort-Bands,
- spaetere Layer-Reihenfolge.

Das M16-CR2-FIX-Free-Build-Overlay zeigt zusaetzlich:

- 13 organisch geeignete Review-Zonen als Auswahlraum,
- sechs frei verfuegbare Start-Baukapazitaeten,
- Attachment-/Erweiterungshalos,
- Kategorie-Freiheit statt fester Kategorieplaetze.

## 4. Overlay-Regel

Das vorhandene 1x-Bild ist nur Dokumentationshintergrund. Die farbigen
Overlays sind Planungsgeometrie fuer Review, Briefing und Folgeentscheidungen.

Sie sind nicht:

- Runtime-Placement,
- finale Anchor-Koordinaten,
- echte transparente Layer,
- separate Layer-Dateien,
- Asset-Dateien,
- Engine-ready Candidates,
- App-Screens.

## 5. Anchor-Overlay

| Label | Anchor | normalized_x | normalized_y | Visual role |
| --- | --- | ---: | ---: | --- |
| A1 | `main_build_area_anchor` | 0.41 | 0.54 | Haupt-Baureserve in der zentralen Wiese |
| A2 | `hub_center_anchor` | 0.49 | 0.51 | Welt-/Hub-Bezugspunkt fuer Dokumentation |
| A3 | `house_primary_anchor` | 0.38 | 0.56 | erste Hausidee als neutrale Referenz, kein Hausplatz |
| A4 | `river_entry_anchor` | 0.31 | 0.19 | Wasserfall / oberer Wasserarm |
| A5 | `river_exit_anchor` | 0.58 | 0.73 | Flussmuendung / suedlicher Wasserabgang |
| A6 | `grove_anchor` | 0.67 | 0.31 | dichter Hain / No-Build-Identitaet |
| A7 | `reserve_zone_anchor_north` | 0.50 | 0.25 | noerdliche Langzeitreserve |
| A8 | `reserve_zone_anchor_south` | 0.67 | 0.66 | suedliche / oestliche Langzeitreserve |

Alle Koordinaten bleiben `measured_on_candidate_bitmap_not_final_runtime_anchor`.

## 6. Zonen-Overlay

| Zone | Visualisiert als | Entscheidung |
| --- | --- | --- |
| `buildable_footprint` | gruene zentrale Wiesenreserve | fuer spaetere neutrale Slots pruefbar, aber noch kein Slot-Layer |
| `soft_placement_zone` | gelber gestrichelter Bereich um Hub/Meadow | geeigneter Bereich fuer spaetere Build-Station-Planung |
| `reserve_zone` | blaue gestrichelte Nord-/Suedbereiche | Langzeitreserve fuer 16-20 Slots bleibt sichtbar |
| `no_build_zone` | roter Hain-/Klippenbereich | dichter Hain und harte Kanten bleiben geschuetzt |
| `no_overlap_zone` | violette gestrichelte Schutzringe | Hub, Fluss und spaetere Station duerfen nicht kollidieren |
| `water_only_zone` | blaue Wasserpfade / Flussmuendung | Wasserlogik muss spaeter in `water_paths` passen |
| `terrain_sensitive_zone` | orange Klippen-/Randbereiche | Felsen, Hoehen und Uebergaenge brauchen spaetere QA |

## 7. Sort-Bands

| Sort-Band | Approximate range | Overlay meaning |
| --- | --- | --- |
| `background_north` | `y <= 0.34` | Wasserfall, Hainplateau, Nordreserve und ferne Kanten |
| `midground_center` | `0.34 < y <= 0.63` | Hub, zentrale Bau-/Soft-Placement-Zone, Hauptreserve |
| `foreground_south` | `y > 0.63` | Flussmuendung, Strand/Kueste, suedliche Reserve |

Die Sort-Bands sind nur grobe visuelle Pruefung. Sie ersetzen keine
Engine-/Renderer-Sortierlogik.

## 8. Layer-Reihenfolge

M16-CR visualisiert die spaetere Arbeitsreihenfolge:

1. `island_base`
2. `water_paths`
3. `terrain_layers`
4. `slot_markers`
5. `build_stations`
6. `building_phases`
7. `workers_companions`
8. `ui_hud_bubbles`

Diese Reihenfolge ist ein Planungsmodell. M16-CR erzeugt keine dieser
Familien als echte separate Layer.

## 8.1 M16-CR2-FIX Free-Build Capacity Rule

M16-CR2-FIX ergaenzt den Overlay-Plan um eine freie
Baukapazitaetsregel:

- Uferwald bekommt keine fest geplanten 12 Grundstuecke.
- Das Overlay markiert einen Auswahlraum von ca. 12-14 geeigneten organischen
  Review-Zonen, sofern sie visuell plausibel sind.
- Die aktualisierte Fassung markiert 13 Review-Zonen.
- Startregel fuer spaetere Produkt-/Flow-Pruefung: 6 frei verfuegbare
  Baukapazitaeten.
- Nutzer duerfen diese 6 Kapazitaeten frei auf geeigneten Zonen der ganzen
  Insel einsetzen.
- Nach jeder Bebauung sinkt nur die verfuegbare Baukapazitaet, nicht die
  Ortsfreiheit.
- Zonen bleiben Review-/Planungsraeume, keine Slots, keine Runtime-Placement-
  Daten und keine Kategorieplaetze.
- Die langfristige 16-20-Reserve bleibt Potenzial und wird in diesem Overlay
  nicht vollstaendig auskartiert.

Die 13 Review-Zonen sind keine finale Slotanzahl. Sie beweisen nur, dass die
Insel mehr Ortsoptionen anbietet als die ersten 6 Bauentscheidungen benoetigen.

## 8.2 Plot-Flexibility und Kategorie-Freiheit

Kategorieentscheidungen bleiben frei:

- Haus, Garten, Garage, Markt, Werkstatt, Lager, Archiv und spaetere Ideen
  duerfen nicht fest an Orte gebunden werden.
- Terrain darf Variante, Stimmung, Groesse oder Anschlusslogik beeinflussen.
- Terrain blockiert Kategorien nicht hart, solange eine spaetere Regel nicht
  aus gutem Grund ein eigenes Gate oeffnet.
- Geeignete Zonen sind Ortspotenzial, keine Kategorie-Vorschlaege.

Diese Regel ist wichtig fuer individuelle Inselentwicklung: Wenn spaeter Cloud-
oder Besucheransichten entstehen, sollen Nutzerinseln nicht alle gleich
aussehen, sondern aus freien Ortsentscheidungen wachsen.

## 8.3 Footprints und Adjacency

Freie Ortswahl bedeutet nicht, dass jedes Objekt gleich viel Platz braucht:

| Objekt-/Ausbauart | Regel |
| --- | --- |
| Haus / Markt / Werkstatt | brauchen breitere klare Flaechen und gute Lesbarkeit |
| Garage / Lager | koennen kleinere oder randnaehere Flaechen nutzen |
| Garten | kann als angrenzende organische Flaeche neben einem Haus entstehen |
| Terrasse / Vorhof / kleine Erweiterung | brauchen freie Nachbarschaft und No-Overlap-Abstand |
| spaetere Attachments | duerfen Richtung und Seite nicht vorschreiben |

Adjacency-Regel:

- Garage kann am Haus angebaut werden.
- Garten kann am Haus angrenzen.
- Vorhof, Terrasse und kleinere Erweiterungen brauchen freie Nachbarschaft.
- Nutzer entscheiden die Seite und Richtung einer Erweiterung frei.
- Attachment-Halos im Overlay zeigen nur moeglichen Freiraum, nicht finale
  Bauplaetze.

## 9. Visual-QA

M16-CR-Visual-QA:

- PNG oeffnet und ist lesbar.
- SVG ist strukturiert und wurde per `xmllint --noout` validiert.
- Anchor-Labels liegen als A1-A8 direkt auf dem Bild; lange Namen stehen in der
  Legende, damit keine Label-Wolke entsteht.
- Legende, Zonen, Layer-Stack und Statushinweis sind getrennt.
- Keine abgeschnittenen Texte im Board.
- Keine sichtbaren Label-Ueberlappungen.
- Status bleibt klar: Dokumentation, nicht Asset, nicht App-Screen, nicht
  Engine-ready.
- M16-CR2-FIX-Free-Build-Overlay ist lesbar und zeigt 13 Review-Zonen ohne
  feste Grundstuecks- oder Kategorieplatz-Optik.
- Die sechs Startkapazitaeten stehen in der Legende und nicht als sechs feste
  Inselpunkte.

## 10. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| Uferwald als Overlay-Planungsreferenz nutzen | JA |
| Anchor-/Zone-Modell fuer Review ausreichend | JA |
| Layer-Reihenfolge fuer Folgebriefing ausreichend | JA |
| Pixelbild als Asset-Ziel uebernehmen | NEIN |
| Overlay als Runtime-Placement uebernehmen | NEIN |
| Neue Bildgenerierung noetig | NEIN |
| Echte Layer jetzt vorhanden | NEIN |
| Insel bietet genug flexible Bauzonen | JA |
| Markierte Review-Zonen im Free-Build-Overlay | 13 |
| 6 Start-Baukapazitaeten plausibel | JA |
| Spaetere Attachments/Erweiterungen visuell vorbereitbar | JA |
| Feste 12 Grundstuecke planen | NEIN |
| Kategorien an Orte binden | NEIN |

## 11. Naechster Slice

Empfohlener naechster Slice:

```text
M16-CS Uferwald External Layer Separation Brief
```

Begruendung:

- Das Overlay macht Anchors, Zonen und Layer-Reihenfolge erstmals visuell
  pruefbar.
- Das Free-Build-Capacity-Overlay beweist mit 13 Review-Zonen, dass Uferwald
  genuegend organische Ortsoptionen fuer 6 freie Startentscheidungen und
  spaetere Erweiterungen bietet.
- Vor externer Paintover-/Layerarbeit braucht der Brief nun genaue Vorgaben,
  welche Bereiche getrennt, vereinfacht, geschuetzt oder neu angelegt werden
  muessen und wie freie Baukapazitaet ohne feste Slots erhalten bleibt.
- Eine neue Bildvariante ist noch nicht noetig; das Problem ist jetzt nicht
  Motivsuche, sondern saubere Layer-Separation.

## 12. Nicht-Freigaben

M16-CR gibt nicht frei:

- keine Spielbildgenerierung,
- keine neuen finalen Spielbilder,
- keine Asset-Freigabe,
- keine Dateien unter `assets/`,
- keine Engine-ready-Freigabe,
- keine App-/Code-Freigabe,
- keine festen 12 Grundstuecke,
- keine festen Kategorieplaetze,
- keine Runtime-Placement-Daten,
- keine echten transparenten Layer,
- keine echten separaten Layer,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein `BuildState`,
- keine Tests,
- kein Commit.
