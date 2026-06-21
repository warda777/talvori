# 441 Talvori Firenze Road Infrastructure Kit Architecture 1L

Status: `planning_only` / `architecture_gate` / `documentation_only`
Runtime integration: NO
Production assets: NO
Firenze layout changes: NO
Commit: NO

Superseded for production direction 2026-06-21:

`442-talvori-unity-modular-district-platform-decision.md` und
`443-p02-vertical-slice-and-online-foundation-roadmap.md` fuehren die neue
Produktionsrichtung. Dieses Dokument bleibt als Road-/Graph-/Visual-Skin-Proof
und Analyse gueltig, aber Blender-first Road-Kit-Produktion ist nicht mehr der
primaere Produktionsweg. Fuer P02 startet Produktion mit einem coherent
environment kit und Unity-Prefab-/Road-/District-Assembly; Blender/Codex bauen
kontrollierte Luecken, Anpassungen oder QA-Proofs, nicht die finale Stadt-Art
aus Primitiven.

## 1. Ziel

Dieser Slice entscheidet, wie Firenze-Strassen visuell als Talvori Neo-
Renaissance Road Infrastructure Kit aufgebaut werden sollen, bevor weitere
Meshy-/Blender-Assets entstehen.

Der erste Meshy Text-to-3D-Test fuer `firenze_cobble_road_tile_set_v1` wurde
als falsche Form interpretiert: massiver Steinblock statt flacher modularer
Road-Kit. 1L stoppt deshalb weitere freie Road-Generierung und definiert eine
kontrollierte Architektur fuer Strassen, Kurven, Junctions, Brueckenansatz und
Kanten.

Dieser Slice erzeugt keine Runtime-Geometrie, keine Produktivassets und keine
Firenze-Layoutaenderung.

## 2. Gelesene Grundlagen

- `docs/world_design/439-talvori-firenze-visual-era-and-environment-style-direction-gate.md`
- `docs/world_design/440-talvori-firenze-neo-renaissance-visual-direction-board.md`
- `docs/world_design/426-firenze-master-technical-layout-readiness-check.md`
- `docs/world_design/431-firenze-area-specification-metrics-and-reachability-review-v1.md`
- `_incoming_character_assets/talvori_firenze_environment_v1/road_curb_candidates/firenze_cobble_road_tile_set_v1_reference/README.md`

Firenze-Topologie, die dieser Slice schuetzt:

- Master-SVG bleibt technische Planungsquelle.
- Canvas bleibt `1672 x 941`.
- River, Bridges, Main Roads, Side Roads, Parcels und Navigation bleiben
  bestehende Layerfamilien.
- 181 Navigation Nodes und 221 Navigation Edges bleiben unveraendert.
- B01-B08 Bridge-Ketten bleiben die einzigen Arno-Querungsfamilien.
- P01-P14 Access-/Entry-Logik bleibt unveraendert.
- `city_spawn_start` bleibt unveraendert.

## 3. Profi-Muster und Ableitung

| Muster | Quelle / Orientierung | Talvori-Ableitung |
| --- | --- | --- |
| Tilemaps / Tile-Sets | [Unity Tilemap Manual](https://docs.unity3d.com/Manual/tilemaps/tilemaps-landing.html) | Gut fuer wiederholbare Kachel- und Anschlusslogik, aber Firenze darf nicht in ein starres sichtbares Raster kippen. |
| Rule Tiles / Autotiles | [Unity 2D Tilemap Extras Rule Tile](https://docs.unity3d.com/Packages/com.unity.2d.tilemap.extras@latest/manual/RuleTile.html) | Anschlussregeln sind wertvoll fuer Road-Edges und Junction-Varianten, aber nicht als alleinige Stadtloesung. |
| Terrain Sets / Wang Tiles | [Tiled Terrain Sets](https://doc.mapeditor.org/en/stable/manual/terrain/) | Gut fuer Materialuebergaenge und edge/corner/transition-Sets; fuer Talvori als Denkmodell fuer Road-Profile und Variation Decals. |
| Spline-/Path-basierte Strassen | [Unity Splines](https://docs.unity3d.com/Packages/com.unity.splines@latest/manual/index.html) | Organische Road-Skins koennen spaeter entlang vorhandener Graph-/Road-Polylines erzeugt werden, ohne Navigation zu ersetzen. |
| Gameplay vs Visual Skin | lokale 426/431/439/440 Regeln | Der Navigation Graph bleibt Gameplay-Schicht; Road-Art ist Visual Skin und darf keine neuen Wege erfinden. |

## 4. Entscheidung

Verworfene Optionen:

| Option | Entscheidung | Grund |
| --- | --- | --- |
| Tile-only | NO | Zu rasterig fuer Firenze; wuerde organische Master-SVG-Roads und Route-Camera-Gefuehl abschwaechen. |
| Meshy-only | NO | Der erste Test zeigte Block-/Diorama-Fehlinterpretation; Meshy ist nicht verlaesslich fuer Road-Netz-Topologie. |
| freie gemalte Road-Bilder | NO | Wuerde Layout, Graph und Visual Skin vermischen und neue Wege erfinden koennen. |

Gewaehlte Architektur:

```text
Hybrid: protected gameplay graph + Blender-first flat road geometry +
profile-based visual road skin + small Meshy material/prop candidates.
```

Hinweis ab `442`/`443`: Diese Architektur beschreibt den damaligen Proof- und
Analyseweg. Fuer P02-Produktion fuehrt nun coherent environment kit first;
Blender-first Road Geometry bleibt als kontrolliertes Luecken-, Anpassungs-
oder QA-Werkzeug erhalten, nicht als primaerer Stadtproduktionsplan.

Kern:

- Der bestehende Firenze Graph steuert Navigation, Reachability und Bridge-
  Regeln.
- Eine spaetere Visual-Skin-Schicht darf entlang bestehender Road-/Bridge-
  Pfade flache Road-Strips, Curbs und Junction-Caps anzeigen.
- Blender/Codex kontrollieren Form, Flachheit, Kurven, Junction-Caps,
  Massstab und Renderbarkeit.
- Meshy darf Materialreferenzen, Props und kleine Curb-/Step-Kandidaten
  liefern, aber keine kompletten Road-Netze und keine Topologie.

## 5. Road-System-Schichten

```text
Protected Gameplay Graph
-> Road Profile Assignment
-> Blender-first Flat Geometry / Junction Caps
-> Material + Decal Skin
-> 2D/2.5D Render Candidates
-> Runtime Preview Gate (spaeter, nicht in 1L)
```

Trennung:

- Gameplay Graph: echte Nodes, Edges, P## Access/Entry, Bridge-Ketten.
- Road Profile Assignment: welche Road-Familie bekommt welches visuelle
  Profil.
- Visual Skin Layer: Pflaster, Kanten, Curbs, Plazas, Decals.
- Collision/Object Layer: bleibt gesperrt; keine Collision-Masks in 1L.

## 6. FirenzeRoadProfile v1

Alle Breiten sind visuelle Planungsziele fuer Route-Camera- und Close-View-
Lesbarkeit. Sie sind keine finalen Weltkoordinaten, keine Collision-Breiten und
keine Runtime-Masks.

| Profil | Visuelle Breite | Material | Kante / Curb | Explorer-Footpoint-Regel | Kamera-Modus | Meshy / Blender / 2D-Rolle |
| --- | --- | --- | --- | --- | --- | --- |
| `primary_road` | Route Camera ca. 26-36 px, Close ca. 34-46 px | warme grosse Kalkstein-/Sandstein-Pflaster | beidseitig niedriger Stein-Curb oder weiche Kante | Footpoint laeuft auf Graph-Centerline oder spaeterer Lane; Curb ist visuell, nicht Laufziel | Route Camera, Street Close | Blender erzeugt flache Spline-/Strip-Geometrie; Meshy nur Materialreferenz; 2D Render als Skin-Kandidat |
| `secondary_road` | Route Camera ca. 20-28 px, Close ca. 28-36 px | kleinere, aber lesbare Pflastermischung | einseitig oder fragmentiert, nicht technisch | Footpoint bleibt auf echter Edge, nicht am Rand | Route Camera | Blender kontrolliert Kurven und Caps; Meshy darf Cobble-/Edge-Material liefern |
| `alley_or_plot_path` | Route Camera ca. 14-22 px, Close ca. 22-30 px | heller Stein, verdichtete Erde, vereinzelte Pflaster | meist kein hoher Curb, nur Bodenwechsel | Footpoint endet weiter an P##_entry nach P##_access, nie an P##_anchor | Plot Close, Route Camera | Blender/2D Decals; Meshy hoechstens kleine Step-/Edge-Props |
| `bridge_deck` | Route Camera ca. 26-34 px, Close ca. 32-44 px | stabiler Steinbelag, Brueckenplatten | seitliche Deckkante/Rail nur visuell, nicht blockierend | Footpoint folgt vollstaendiger B##_N -> B##_M -> B##_S-Kette | Route Camera, Street Close | Blender-first wegen Bridge-Ketten und River-Sortierung; Meshy darf Stein-/Rail-Material liefern |
| `plaza_or_junction` | variabel, Junction-Patch ca. 44-80 px sichtbar | groessere Steinplatten, radial/irregular Patch | Kanten muessen an Profile anschliessen | Footpoint nutzt Graph-Knoten/Edge-Verlauf; Junction-Cap visualisiert, ersetzt aber keinen Node | Route Camera, Street Close | Blender Junction-Cap-Set; Meshy keine kompletten Plazas, nur Material/Prop-Kandidaten |

## 7. Minimaler Road-Kit-Baukasten

Pflichtstuecke fuer einen ersten Road-Kit-Proof:

| Stueck | Zweck | Formkontrolle | Hinweise |
| --- | --- | --- | --- |
| `straight` | kurze gerade Segmente | Blender-first | Laenge skalierbar, Material wiederholbar, keine sichtbare Rasterkante. |
| `gentle_curve` | organische leichte Kurven | Blender-first Spline/Bezier | Wichtig fuer Firenze, weil Roads nicht streng orthogonal sind. |
| `strong_curve` | enge Kurven an Blocks/Plots | Blender-first | Muss Footpoint lesbar halten, kein Charakter-Clipping. |
| `s_curve` | organische Road-Korrektur | Blender-first | Nur als Skin-Form, nicht als neue Navigation. |
| `t_junction` | 3-Wege-Knoten | Blender Junction Cap | Knoten bleibt Graph-Knoten; Cap verbindet Profile sauber. |
| `y_junction` | schräge 3-Wege-Knoten | Blender Junction Cap | Wichtig fuer organische Firenze-Topologie. |
| `cross_junction` | 4-Wege-Knoten | Blender Junction Cap | Nicht zu gross, nicht als Plaza missverstehen. |
| `plaza_patch` | breitere Platz-/Knotenflaeche | Blender + 2D Decals | Nur fuer freigegebene Plaza-/Junction-Kontexte. |
| `bridge_approach` | Road-zu-Bridge-Uebergang | Blender-first | Muss Bridge-Deck und River-Layer respektieren. |
| `curb_edge` | Road-Rand und Profiltrennung | Blender/Meshy candidate | Sehr niedrig, keine Wand. |
| `variation_decals` | Steinrisse, warme Flecken, kleine Reparaturen | 2D decals | Nicht zur neuen Geometrie machen. |

Nicht im Minimal-Kit:

- komplette Stadtstrassen,
- komplette Road-Netze,
- fertige collision shape,
- produktive Tilemap,
- neue Routingdaten,
- ganze District-Art.

## 8. Meshy-Rolle

Meshy darf liefern:

- Materialreferenzen fuer Kalkstein-/Sandsteinpflaster,
- einzelne low-profile Curb-/Step-Kandidaten,
- kleine Props am Strassenrand,
- Word Lantern / Market Props / Planter aus 440,
- Varianten fuer Oberflaechenfarbe und Handpaint-Style,
- GLB/Preview-Quellen fuer Blender-QA.

Meshy darf nicht liefern:

- komplette Road-Netze,
- neue Firenze-Strassenform,
- neue Junction-Topologie,
- massive Stone Blocks,
- Tunnel, Bruecken, Gebaeude oder Dioramen als Road-Kit,
- Collider-/Collision-/Walkability-Logik,
- fertige Runtime-Assets.

Wenn Meshy wieder massive Blocks erzeugt:

```text
Meshy Road-Shape-Generation stoppen.
Blender-first Road Geometry bauen.
Meshy nur noch fuer Material-/Prop-Referenz verwenden.
```

## 9. Blender-/Codex-Rolle

Blender/Codex kontrolliert spaeter, in einem eigenen Asset-/Proof-Slice:

- flache Strassen-Geometrie,
- Profile-Breiten,
- Kurven,
- S-Kurven,
- Junction-Caps,
- Bridge-Approach-Caps,
- Massstab gegen Explorer-Footpoint,
- Top-ish / Route-Camera Render,
- Lowpoly- oder 2D-Render-Kandidaten,
- klare Dateistruktur und QA-Bericht.

Codex darf dabei keine neue Firenze-Route erfinden. Eine spaetere Generierung
muss vorhandene Road-/Navigation-Quellen lesen oder manuell definierte
Testsegmente als `not_runtime` markieren.

## 10. Road/Graph-Schutzregeln

1. Navigation bleibt auf bestehenden Nodes/Edges.
2. Visual Road Skin darf nie als neue begehbare Route gelten.
3. `P##_entry_i` und `P##_access_i` bleiben Laufziel-/Access-Vertrag.
4. `P##_anchor` bleibt visuelle/Kamera-Referenz, nie Laufziel.
5. Arno-Querung bleibt nur ueber B##_N -> B##_M -> B##_S.
6. Road-Profile duerfen zugewiesen, aber nicht als Runtime-Collision gelesen
   werden.
7. Decals und Curbs duerfen Wege nicht optisch blockieren.
8. Player-facing Road-Art darf keine Node-/Edge-/GIS-/Debug-Labels zeigen.

## 11. Empfohlene Pipeline

### Phase A: Road Geometry Lab

- Ein rein lokaler Blender-Proof mit 3-5 flachen Stuecken.
- Keine Firenze-Integration.
- Explorer-Footpoint-Placeholder fuer Massstab.
- Top-ish und Route-Camera Render.

### Phase B: Profile Material Test

- Meshy/AI nur fuer Material- und Surface-Varianten.
- Material auf Blender-first Road-Stuecke legen.
- Road/Curb gemeinsam pruefen.

### Phase C: Junction Cap Test

- T/Y/Cross-Junction Caps in Blender bauen.
- Sichtbar gegen unterschiedliche RoadProfile anschliessen.
- Keine Runtime-Graph-Erzeugung.

### Phase D: Firenze Graph Skin Preview

- Erst nach A-C.
- Vorhandene Firenze-Road-/Graph-Daten als geschuetzte Quelle.
- Visual Skin ueber echte Edges legen, aber Navigation nicht veraendern.

## 12. QA-Kriterien

PASS fuer Road-Kit-Proofs:

- flach, niedrig, keine massiven Blocks,
- Road-Profile sichtbar unterscheidbar,
- Explorer-Footpoint bleibt lesbar,
- Strasse wirkt warm Neo-Renaissance,
- Pflaster ist gross genug fuer Route Camera,
- Curbs sind niedrig und nicht wie Mauern,
- Junctions schliessen Profile sauber an,
- keine technische Kartenoptik,
- keine neuen Wege oder Arno-Querungen,
- keine `assets/`- oder Runtime-Integration.

WARN:

- Material gut, aber Form zu hoch,
- Pflaster gut, aber zu kleinteilig,
- Road modular, aber zu rasterig,
- Meshy-Output brauchbar nur als Materialreferenz.

FAIL:

- massiver Block,
- Tunnel/Bridge/Gebaeude statt Road Kit,
- Asphalt/moderne Strasse,
- GIS-/Debug-Look,
- neue Road-Netz-Topologie,
- keine Explorer-Scale-Lesbarkeit.

## 13. Entscheidung

Road Infrastructure Architecture 1L: PASS als Planungsentscheidung.

Ausgewaehlter Weg:

```text
Hybrid: protected Firenze gameplay graph + Blender-first flat road kit +
profile-based visual skin + Meshy only for materials/props/small candidates.
```

Meshy bleibt nuetzlich, aber nicht fuer komplette Road-Netze oder
Road-Geometrie-Topologie.

## 14. Naechste konkrete Aufgabe

Empfohlener naechster Slice:

```text
Talvori Firenze Blender Road Geometry Lab 1M
```

Scope:

- lokal unter `_incoming_character_assets/talvori_firenze_environment_v1/`,
- 3-5 flache Blender-first Road-Stuecke bauen,
- `straight`, `gentle_curve`, `t_junction`, `curb_edge`, optional
  `bridge_approach`,
- Explorer-Footpoint-Placeholder,
- Top-ish und Route-Camera Renders,
- kein `assets/`-Import,
- keine Runtime-Integration,
- keine Firenze-Layoutaenderung,
- keine Meshy-Road-Shape-Abhaengigkeit.
