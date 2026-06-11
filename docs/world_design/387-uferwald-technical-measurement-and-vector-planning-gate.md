# M16-DD: Uferwald Technical Measurement and Vector Planning Gate

Stand: 2026-06-11

Status: `Docs-/Measurement-/Vector-Planning-Gate / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DD legt fest, wie die in M16-DC geplanten Uferwald-Layer, Masks und Zonen
spaeter sauber gemessen oder vektorbasiert geplant werden duerfen.

Der Slice ist bewusst ein Gate vor echter Geometrie:

- keine finalen Koordinaten,
- keine echten Polygon-Dateien,
- keine SVG/PNG-Erzeugung,
- keine Runtime-Mapdaten,
- keine App-Integration,
- keine Assets.

Leitregel:

> Erst technische Mess-/Vector-Planung, dann technische Manifest-Daten, dann
> sichtbares Rendering oder lokale Preview-Logik.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`
- `docs/world_design/385-uferwald-technical-layer-and-mask-spec.md`
- `docs/world_design/386-uferwald-technical-layer-manifest.md`

M16-DD darf die Uferwald-Bilder und Overlays nur als Review-Kontext nutzen.
Sie bleiben nicht die technische Quelle.

## 3. Non-Goals

M16-DD gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Bilder,
- keine PNG/SVG,
- keine Preview-Ordner,
- keine echten Polygon-/Vector-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine externen Writes,
- keinen Commit.

## 4. Mess- und Vector-Grundregel

Alle Uferwald-Messungen muessen manuell, nachvollziehbar und mit expliziter
Layer-Zuordnung entstehen. Ein spaeteres Tool darf Pixelbilder als sichtbaren
Hintergrund anzeigen, aber technische Daten nicht automatisch daraus ableiten.

Erlaubt fuer spaetere Folge-Slices:

- manuelle Polygonplanung,
- Figma als Vektor-/Overlay-Arbeitsflaeche,
- SVG als vektorbasierter Planungs-Export,
- JSON/YAML als maschinennahe Planungsstruktur,
- Markdown-Tabellen fuer Review und QA.

Nicht erlaubt durch M16-DD:

- automatische Segmentierung aus dem Uferwald-Pixelbild,
- Pfad-, Build- oder Collision-Ableitung aus RGB-Pixeln,
- direkte Runtime-Nutzung von Review-Overlays,
- echte App-/Flutter-Integration,
- Assets oder Dateien unter `assets/`.

## 5. Reihenfolge der Mess-/Vector-Planung

Die erste technische Planung muss in dieser Reihenfolge passieren:

1. `base_rock_shape`
2. `water_river_mask`
3. `tree_obstacle_layer`
4. `rock_cliff_obstacle_layer`
5. `walkable_path_layer`
6. `landmark_anchor_layer`
7. `buildable_zone_layer`
8. `plot_footprint_layer`
9. `no_walk_mask`
10. `no_build_mask`
11. `depth_sort_bands`

Begruendung:

- Erst muessen harte Insel-, Wasser- und Hindernisgrenzen stehen.
- Danach koennen Wege und Landmarken sinnvoll geplant werden.
- Erst danach duerfen Build-Zonen und Footprints mit Abstand, Nachbarschaft
  und No-Overlap geprueft werden.
- Composite-Masks wie `no_walk_mask` und `no_build_mask` duerfen erst aus
  technischen Source-Layern kombiniert werden.
- Sort-Bands brauchen am Ende die wichtigsten Landschafts-, Weg- und
  Objektkontexte.

## 6. Ableitungsregeln

| Ziel-Ebene | Darf spaeter abgeleitet werden aus | Nicht erlaubt |
| --- | --- | --- |
| `base_rock_shape` | manueller Vector-Plan auf Basis von Art-/Overlay-Review | automatische Pixelkontur |
| `water_river_mask` | manueller Wasser-Vector-Plan, River-Entry/Exit-Anker | Blauwerte aus Pixeln |
| `tree_obstacle_layer` | manuell markierte Hain-/Waldzonen und spaetere Bauminstanzen | Gruenwerte oder Deko-Baeume als Collision |
| `rock_cliff_obstacle_layer` | manuell markierte Klippen/Felsblocker | Schatten/Kanten aus Pixeln |
| `walkable_path_layer` | manuell geplante Pfadkorridore und Path-Nodes | optisch heller Pfad im Bild |
| `landmark_anchor_layer` | manuell benannte Review-/Map-Punkte | gemessene Bitmap-Anker als final |
| `buildable_zone_layer` | technische Terrain-/Obstacle-/No-Build-Analyse plus Review-Zonen | gruene Wiese automatisch buildable |
| `plot_footprint_layer` | Build-Zonen plus Objektgroessen-/Adjacency-Regeln | sichtbare Lichtungen als fertige Plots |
| `no_walk_mask` | Union aus `water_river_mask`, `tree_obstacle_layer`, `rock_cliff_obstacle_layer`, Aussenkante und spaeteren harten Sperren | Bildpixel oder dekorative Schatten |
| `no_build_mask` | Union aus Wasser, Hindernissen, Wegen, Hub-/Anchor-Schutz und Randabstaenden | No-Walk automatisch 1:1 uebernehmen |
| `depth_sort_bands` | manuelle Y-/Region-Baender plus Landschafts-/Objektkontext | automatische Sortierung aus Bildtiefe |

Die Ableitungen bleiben in M16-DD theoretisch. Echte Ableitungsdateien brauchen
einen Folge-Slice.

## 7. Layer-spezifische Messregeln

### 7.1 `base_rock_shape`

Messziel:

- technische Insel-Aussenform,
- harte Landmasse,
- Rand-/Klippenkoerper,
- Edge-Mask-Reserve fuer fullscreen/cover Kamera.

Planungsmethode:

- manuelles Polygon oder Multi-Polygon,
- sichtbares Uferwald-Bild nur als Hintergrund,
- Review mit 381-Overlay, aber keine automatische Konturerkennung.

QA vor Runtime-Manifest:

- Aussenwasser und Inselrand sind klar getrennt.
- Kein Pfad, keine Build-Zone und kein Hindernis wird aus der Silhouette
  abgeleitet.
- Bounds koennen spaeter Kamera-Edge-Masking informieren, bleiben aber noch
  keine Runtime-Bounds.

### 7.2 `water_river_mask`

Messziel:

- Hauptwasser,
- Flussarm,
- Uferarm,
- Eintritt/Austritt,
- harte Wasser-Sperrflaechen.

Planungsmethode:

- manuelle Wasserpolygone,
- optional River-Polyline mit Breitenangaben,
- `river_entry_anchor` und `river_exit_anchor` nur als geplante Referenzen.

QA vor Runtime-Manifest:

- Wasser ist nicht begehbar, solange kein Bruecken-/Furt-Gate existiert.
- Wasser ist nicht bebaubar.
- Uferabstaende fuer `no_walk_mask` und `no_build_mask` sind als offene
  Messpunkte markiert.

### 7.3 `walkable_path_layer`

Messziel:

- echte begehbare Pfadkorridore,
- Stationen,
- Path-Nodes,
- Mindestbreiten fuer Marker/Figur und Kamera-Follow.

Planungsmethode:

- manuelle Polyline mit Breite,
- Path-Corridor-Polygone,
- spaeter optional JSON/YAML-Graph.

QA vor Runtime-Manifest:

- Jeder Pfad liegt ausserhalb harter Wasser-, Baum- und Felsblocker.
- Stationspunkte liegen auf dem Pfadnetz.
- M16-CY-FIX-3-Pfade werden nicht uebernommen, wenn sie nur optisch geraten
  waren.

### 7.4 `tree_obstacle_layer`

Messziel:

- harte Hain-/Waldblocker,
- weiche Waldkanten,
- moegliche Occlusion-Kanten.

Planungsmethode:

- manuelle Hindernis-Polygone,
- spaeter optional Bauminstanzen mit Radius,
- klare Trennung zwischen Dekor, Sichtkante und echter Blockerzone.

QA vor Runtime-Manifest:

- Hain bleibt Uferwald-Identitaet, aber wird nicht pauschal zur Collision.
- Harte Blocker und weiche atmosphaerische Baumgruppen sind getrennt.
- No-Build und No-Walk verwenden nur gepruefte technische Blocker.

### 7.5 `rock_cliff_obstacle_layer`

Messziel:

- harte Fels- und Klippenkanten,
- nicht begehbare Hoehenuebergaenge,
- blockierende Felskoerper.

Planungsmethode:

- manuelle Obstacle-Polygone,
- Klippen-Polylines mit spaeterem Puffer,
- getrennte Kennzeichnung fuer Dekor-Felsen und harte Blocker.

QA vor Runtime-Manifest:

- Keine impliziten Treppen oder Hoehenwege.
- Kein Build-Footprint darf harte Klippen schneiden.
- Sort-Band-Bedarf wird markiert, aber nicht aus Schatten abgeleitet.

### 7.6 `buildable_zone_layer`

Messziel:

- organische Eignungsraeume fuer freie Baukapazitaet,
- mehr geeignete Orte als Startkapazitaeten,
- keine festen Slots,
- keine Kategorieplaetze.

Planungsmethode:

- manuelle Soft-Zone-Polygone,
- Score oder Eignungsnotiz spaeter moeglich,
- Review gegen 381-Free-Build-Capacity-Regel.

QA vor Runtime-Manifest:

- Geeignete Zone ist nicht automatisch Plot.
- Terrain darf Varianten nahelegen, aber keine Kategorie hart binden.
- 6 Start-Baukapazitaeten bleiben Kapazitaet, nicht sechs Orte.

### 7.7 `plot_footprint_layer`

Messziel:

- Footprint-Klassen fuer kleine, mittlere und grosse Objekte,
- Attachment- und Nachbarschaftsbedarf,
- No-Overlap-Abstaende.

Planungsmethode:

- Footprint-Templates als planbare Formen,
- Groessenklassen in JSON/YAML spaeter moeglich,
- kein Platzieren echter Gebaeude.

QA vor Runtime-Manifest:

- Haus, Garage, Garten, Markt, Werkstatt, Lager und Archiv bleiben frei
  waehlbare Kategorien.
- Footprints pruefen nur Groesse und Nachbarschaft, nicht Besitz oder State.
- Keine Bauphase und kein BuildState entsteht.

### 7.8 `no_walk_mask`

Messziel:

- harte Sperrflaechen fuer Visit/Wander.

Planungsmethode:

- spaeter als Union aus technischen Source-Layern,
- Wasser, harte Baumblocker, harte Felsblocker und Aussenrand duerfen
  einfliessen,
- manuelle QA gegen Pfadnetz.

QA vor Runtime-Manifest:

- Nicht identisch mit `no_build_mask` setzen.
- Keine automatische Pixelmaske.
- Jeder Visit/Wander-Pfad muss gegen diese Maske geprueft werden.

### 7.9 `no_build_mask`

Messziel:

- harte Sperrflaechen fuer Build/Map und Object-Footprints.

Planungsmethode:

- spaeter als Union aus Wasser, harten Hindernissen, Wegen, Hub-/Anchor-
  Schutzraeumen und Randabstaenden,
- Buildable-Zonen werden gegen diese Maske geprueft.

QA vor Runtime-Manifest:

- Nicht identisch mit `no_walk_mask` setzen.
- Wege koennen begehbar sein, aber fuer Bauen gesperrt bleiben.
- No-Build bedeutet nicht automatisch No-Walk.

### 7.10 `depth_sort_bands`

Messziel:

- Vordergrund,
- Mittelgrund,
- Hintergrund,
- Occlusion-Kanten,
- spaetere Sortierregeln fuer Figuren, Build Stations, Bauphasen und Bubbles.

Planungsmethode:

- manuelle Y-/Region-Baender,
- Review gegen 381-Bands `background_north`, `midground_center`,
  `foreground_south`,
- spaeter JSON/YAML-Sort-Band-Liste moeglich.

QA vor Runtime-Manifest:

- Sort-Bands sind keine Collision.
- Sort-Bands sind keine Hoehenphysik.
- Figuren und Objekte muessen pruefbar einem Band zugeordnet werden koennen.

### 7.11 `landmark_anchor_layer`

Messziel:

- benannte Landmarken,
- Path-/Station-Kontext,
- Object-Focus-Bezuege,
- Kamera- und Review-Bezugspunkte.

Planungsmethode:

- manuelle Anchor-Planung,
- keine finalen Koordinaten in M16-DD,
- spaeter normalisierte Koordinaten nur nach Mess-/Review-Gate.

QA vor Runtime-Manifest:

- Anchor-IDs sind stabil benannt.
- Jeder Anchor hat Zweck, Modusbezug und Risiko.
- Bitmap-gemessene Doku-Anker aus 379/381 werden nicht automatisch final.

## 8. Tool-Regeln fuer spaetere Folgearbeit

| Tool / Format | Erlaubte Rolle spaeter | Grenze |
| --- | --- | --- |
| Figma | Manuelle Vector-/Overlay-Planung, Review-Kommentare, Layer-Gruppen | Keine App-/Asset-Freigabe und kein Figma-Write ohne eigenen Auftrag |
| SVG | Vektorplan fuer technische Review-Geometrie | M16-DD erzeugt noch keine SVG-Datei |
| JSON/YAML | Maschinennahe Manifeststruktur fuer Folge-Specs | Noch keine Runtime-Daten |
| Markdown | Review, QA, Tabellen, offene Messfragen | Nicht als Runtime-Manifest lesen |
| Manuelle Polygonplanung | Fuehrender Weg fuer technische Layer | Kein automatisches Pixeltracing |

## 9. QA vor technischem Runtime-Manifest

Bevor aus Mess-/Vector-Planung ein technisches Runtime-Manifest entstehen
darf, muessen alle folgenden Fragen mit JA beantwortet sein:

- Sind `base_rock_shape`, Wasser, Hain, Felsen und harte Aussenkanten separat
  geplant?
- Sind `walkable_path_layer` und `no_walk_mask` getrennt und gegenseitig
  geprueft?
- Sind `buildable_zone_layer`, `plot_footprint_layer` und `no_build_mask`
  getrennt?
- Sind No-Walk und No-Build bewusst verschieden, wo sie verschieden sein
  muessen?
- Sind Build-Zonen organisch und frei, ohne feste 12 Slots oder
  Kategorieplaetze?
- Sind `depth_sort_bands` fuer Figuren, Objekte und Object Focus ausreichend
  geplant?
- Sind Landmark-Anchors benannt, aber nicht unreviewed als Runtime-Koordinaten
  uebernommen?
- Ist jede Ableitung aus technischen Source-Layern dokumentiert?
- Ist keine technische Ebene automatisch aus Pixeln erzeugt?
- Ist klar, dass M16-CY-FIX-3 nur UX-/Risiko-Proof bleibt?

Wenn eine Frage NEIN ist, bleibt der Folge-Slice nicht commitfaehig fuer
Runtime-Mapdaten.

## 10. M16-CY-FIX-3 als Risiko-Proof

M16-CY-FIX-3 zeigt, warum M16-DD noetig ist:

- Die Wander-Preview wirkte spielerischer und intuitiver.
- Stationsnamen, Marker und Tap-Bewegung machten den Ort lebendiger.
- Trotzdem blieb der Wegverlauf am fertigen Bild entlang geraten.
- Ohne Mess-/Vector-Plan fehlen echte Pfadbreiten, No-Walk/No-Build,
  Hindernisse, Sort-Bands und pruefbare Build-Zonen.

Schoener Look reicht nicht, wenn technische Mess- und Vector-Planung fehlt.

## 11. Folgepfad

Empfohlener naechster Slice:

```text
M16-DE Uferwald Measurement Source and Vector Workspace Plan
```

Dieser Folge-Slice sollte klaeren, ob die Mess-/Vector-Planung weiterhin nur
Markdown bleibt oder ob ein explizit freigegebenes Visual-/Vector-Planungsformat
wie SVG oder Figma vorbereitet wird. Auch M16-DE darf nur mit ausdruecklicher
Freigabe Bilder, SVGs, Figma-Writes oder Geometriedateien erzeugen.

## 12. Stop-Regeln

M16-DD gibt nicht frei:

- keinen Code,
- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- keinen BuildState,
- keine Runtime-Mapdaten,
- keine Tests,
- keine Bilder,
- keine PNG/SVG,
- keine Preview-Ordner,
- keine echten Polygon-/Vector-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine externen Writes,
- keinen Commit.
