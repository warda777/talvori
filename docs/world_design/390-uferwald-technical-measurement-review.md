# M16-DG: Uferwald Technical Measurement Review

Stand: 2026-06-11

Status: `Docs-/Review-Gate / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/review_slice.md`

## 1. Ziel

M16-DG prueft den aktuellen M16-DF-Uferwald Measurement SVG/PNG
Documentation Plan fachlich gegen die technische Layer-Architektur aus
M16-DA bis M16-DD.

Das Review entscheidet, ob Uferwald fuer die naechsten technischen
Messschritte ausreichend vorbereitet ist und welche Praezisierungen zwingend
vor maschinennaeheren Formaten wie JSON/YAML, Runtime-Mapdaten oder echter
Polygonarbeit gebraucht werden.

M16-DG ist kein Code-, Asset-, Figma-, JSON/YAML- oder Runtime-Slice.

## 2. Review-Basis

Vollstaendig gelesene Pflichtdokumente:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`
- `docs/world_design/387-uferwald-technical-measurement-and-vector-planning-gate.md`
- `docs/world_design/388-uferwald-measurement-source-and-vector-workspace-plan.md`
- `docs/world_design/389-uferwald-measurement-svg-documentation-plan.md`
- `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`
- `docs/world_design/previews/m16_df_uferwald_measurement_svg_documentation_plan/README.md`

Gepruefte Visual-Dateien:

- `docs/world_design/previews/m16_df_uferwald_measurement_svg_documentation_plan/uferwald_measurement_svg_documentation_plan.svg`
- `docs/world_design/previews/m16_df_uferwald_measurement_svg_documentation_plan/uferwald_measurement_svg_documentation_plan.png`

Fuehrende Architekturregel:

> Sichtbares Art-Bild oder Review-Overlay ist nicht die technische Spielkarte.

## 3. Kurzfazit

Der M16-DF-Plan ist als erster visueller Mess- und Diskussionsplan
ausreichend. Er zeigt die notwendigen Layer/Masks/Zonen, trennt No-Walk und
No-Build sichtbar, markiert Build-Zonen als organische Eignungsraeume und
enthaelt Landmark-Anker.

Er ist aber noch nicht ausreichend fuer M16-DH als JSON/YAML-, Runtime- oder
echter Polygon-Folgearbeit. Vor maschinennaeheren Daten braucht Uferwald einen
Measurement Precision Pass fuer Pfadbreiten, harte Wasser-/Baum-/Felsgrenzen,
No-Walk-/No-Build-Komposition, Sort-/Occlusion-Regeln und Pfad-gegen-Blocker-
QA.

## 4. Bewertung je Pruefpunkt

| Pruefpunkt | Status | Bewertung |
| --- | --- | --- |
| 1. echte Pfadbreiten | unklar | Der Plan zeigt Pfade als helle Korridore, aber keine Breitenklassen, Mindestbreiten, Figur-/Marker-Abstaende oder Path-Corridor-Messregel. Fuer Review reicht das, fuer Visit/Wander nicht. |
| 2. dekorative Baeume vs echte Blocker | unklar | `tree_obstacle_layer` ist sichtbar, aber harte Blocker, weiche Waldkante, Deko-Baum und Occlusion-Kante sind noch nicht getrennt. |
| 3. harte Wassergrenzen | unklar | `water_river_mask` ist visuell vorhanden, aber Uferlinie, River-Entry/Exit, Wasserpuffer, Bruecken-/Furt-Verbote und harte Sperrkante sind nicht praezise. |
| 4. harte Fels-/Klippenblocker | unklar | Graue Felszonen sind sichtbar, aber harte Klippenkante, dekorativer Fels, Hoehenkante und No-Walk-/No-Build-Puffer sind nicht getrennt. |
| 5. genaue No-Walk-Zonen | fehlt | No-Walk ist markiert, aber noch keine genaue Composite-Maske aus Wasser, Baumblocker, Felsblocker, Aussenkante und Pfadkonflikt-QA. |
| 6. genaue No-Build-Zonen | unklar | No-Build ist getrennt von No-Walk sichtbar, aber noch nicht als technische Union aus Wasser, Hindernissen, Wegen, Hub-/Anchor-Schutz, Randabstand und Erweiterungsregeln definiert. |
| 7. organische Build-Zonen ohne feste Slots | ausreichend | Build-Zonen wirken organisch und nicht wie feste 12 Slots oder Kategorieplaetze. Fuer Review ist das gut. Fuer technische Planung fehlen aber Flaeche, Footprint-Klassen, Kapazitaetsregeln und Attachment-Abstaende. |
| 8. Sort-Bands fuer Figur-/Objekt-Ueberlagerung | unklar | Drei Sort-Bands sind sichtbar. Es fehlen aber Sort-Anker, Occlusion-Kanten, Objekt-/Figur-Beispiele, Uebergangsregeln und Konflikte mit Hain/Felsen. |
| 9. Landmark-Anker als spaetere Messpunkte | ausreichend | A1-A8 sind sichtbar und benannt. Sie taugen als spaetere Messpunkte. Sie duerfen aber nicht als finale Koordinaten oder Runtime-Anker gelesen werden. |
| 10. Wege laufen nicht durch Blocker | widerspruechlich | Der aktuelle Korridor kann visuell Wasser-/No-Walk-/No-Build-Bereiche schneiden oder zu nah an ihnen liegen. Ohne harte Masken und Pfadbreiten ist Kollisionsfreiheit nicht pruefbar. |

## 5. Was schon ausreichend ist

Ausreichend fuer den naechsten Review-Schritt:

- Die Pflicht-Layer aus 385/386 sind im Visual fast vollstaendig sichtbar.
- `base_rock_shape`, `water_river_mask`, `tree_obstacle_layer`,
  `rock_cliff_obstacle_layer`, `walkable_path_layer`,
  `buildable_zone_layer`, `no_walk_mask`, `no_build_mask`,
  `depth_sort_bands` und `landmark_anchor_layer` sind visuell auffindbar.
- No-Walk und No-Build sind als unterschiedliche Konzepte erkennbar.
- Build-Zonen sind organisch und nicht als feste Kategorieplaetze gezeichnet.
- Landmark-Anker sind benannt und koennen spaeter als Messpunkte dienen.
- Statusschutz ist klar: `documentation_only`, `not_runtime_data`,
  `not_asset`, `not_engine_ready`.

## 6. Zwingende Luecken vor M16-DH

Vor einem maschinennaeheren Folge-Slice muessen diese Punkte praezisiert
werden:

1. Pfadbreiten als Review-Regel: Marker-/Figurbreite, Mindestkorridor,
   Stationsabstand und Kamera-Follow-Abstand.
2. Wassergrenzen: harte Wasserpolygone, Uferpuffer, River-Entry/Exit und
   Bruecken-/Furt-Blockade bis eigenes Gate.
3. Baum-Layer: harte Hainblocker, weiche Waldkanten, dekorative Baeume und
   Occlusion-Kanten getrennt markieren.
4. Fels-/Klippen-Layer: harte Klippenkanten, dekorative Felsen,
   Hoehenuebergaenge und No-Walk-/No-Build-Puffer trennen.
5. `no_walk_mask`: als bewusste Review-Union aus Wasser, harten
   Baumblockern, harten Felsblockern, Aussenkante und verbotenen
   Pfadsegmenten definieren.
6. `no_build_mask`: getrennt von No-Walk als Review-Union aus Wasser,
   Hindernissen, Wegen, Hub-/Anchor-Schutz, Randabstand und
   Erweiterungsschutz definieren.
7. Pfad-gegen-Blocker-QA: jeder Pfadkorridor muss gegen Wasser, Hain,
   Fels/Klippe und No-Build-Kontext geprueft werden.
8. Sort-Bands: Sort-Anker, Objekt-/Figur-Bezug und Occlusion-Beispiele
   benoetigen eine klarere Regel.
9. Landmark-Anker: Jeder Anchor braucht Rolle als Landmark, Path-Node,
   Build-Reference oder Object-Focus-Reference, aber noch keine finalen
   Runtime-Koordinaten.
10. Visual-QA-Polish: Der M16-DF-Plan ist lesbar, aber die untere
    Legenden-/Hinweisflaeche sollte in einem spaeteren Visual-Pass mehr
    Abstand bekommen, bevor sie als langfristiges Referenzboard dient.

## 7. Risiken ohne Praezisierung

Wenn direkt mit JSON/YAML, Runtime-Mapdaten oder Flutter-Preview-Logik
weitergemacht wird, entstehen diese Risiken:

- Visit/Wander-Pfade werden wieder aus dem Bild geraten.
- Pfade schneiden Wasser, Hain oder Felsblocker.
- No-Walk und No-Build werden versehentlich gleichgesetzt.
- Gruene Flaechen werden automatisch als baubar gelesen.
- Dekorative Baeume oder Felsen werden unklar als Collision interpretiert.
- Sortierung und Occlusion werden aus Bildtiefe geraten.
- Landmark-Anker werden als finale Koordinaten missverstanden.
- Build-Zonen kippen zur versteckten Slot- oder Kategorieplatzlogik.
- Das SVG wird zu frueh als Runtime-Geometrie gelesen.

## 8. Entscheidung

| Entscheidung | Ergebnis |
| --- | --- |
| M16-DF als erster Messplan ausreichend | JA, fuer Review und Diskussion |
| M16-DF als Grundlage fuer Runtime-Daten ausreichend | NEIN |
| M16-DF als Grundlage fuer JSON/YAML-Manifest ausreichend | NEIN |
| Build-Zonen-Prinzip ausreichend | JA, als organische Review-Zonen |
| Pfad-/Walkability-Praezision ausreichend | NEIN |
| No-Walk-/No-Build-Praezision ausreichend | NEIN |
| Landmark-Anker fuer spaetere Messung ausreichend | JA, als benannte Messpunkte |
| Direkter Sprung zu Runtime-/Flutter-Logik erlaubt | NEIN |

## 9. Empfohlener naechster Slice

Empfohlen:

```text
M16-DH Uferwald Measurement Precision Pass
```

M16-DH sollte noch kein JSON/YAML-Runtime-Manifest erzeugen. Er sollte den
M16-DF-Plan fachlich schaerfen:

- Pfadbreiten,
- harte Wasser-/Baum-/Felsgrenzen,
- No-Walk-/No-Build-Union-Regeln,
- Pfad-gegen-Blocker-QA,
- Sort-/Occlusion-Regeln,
- Anchor-Rollen.

Erst danach ist sinnvoll:

```text
M16-DI Uferwald JSON/YAML Planning Schema Gate
```

JSON/YAML darf erst kommen, wenn die Review-Geometrie fachlich stabil genug
ist, um nicht versehentlich fehlerhafte Runtime-Daten zu verfestigen.

## 10. Nicht-Freigaben

M16-DG gibt nicht frei:

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
- keine neuen Bilder,
- keine SVG/PNG-Erzeugung,
- keine Figma-Writes,
- keine JSON/YAML-Runtime-Dateien,
- keine finalen Koordinaten,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.
