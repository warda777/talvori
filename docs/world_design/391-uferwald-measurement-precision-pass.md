# M16-DH: Uferwald Measurement Precision Pass

Stand: 2026-06-11

Status: `Docs-/Precision-Gate / keine Runtime-Daten`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DH praezisiert die in M16-DG gefundenen Luecken des Uferwald-Messplans.
Das Ziel ist ein fachlicher Precision Pass, der den naechsten visuellen
Praezisionsplan ermoeglicht, ohne neue Bilder, SVGs, PNGs, JSON/YAML,
Runtime-Daten, Assets oder Code zu erzeugen.

M16-DH ist ein Vertrag fuer spaetere Mess- und Vector-Arbeit. Es ist keine
technische Karte und keine Implementierungsfreigabe.

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

Fuehrende Regel:

> Sichtbares Art-Bild und Review-Overlays sind nicht die technische
> Spielkarte.

## 3. Precision-Grundregel

M16-DH definiert relative Mess- und QA-Regeln. Diese Regeln duerfen im
naechsten Visual-Precision-Pass sichtbar gemacht werden, bleiben aber noch
keine finalen Koordinaten, keine Polygon-Dateien und keine Runtime-Daten.

Jede spaetere Messung muss drei Ebenen trennen:

1. Review-Geometrie: visuelle Pruefung fuer Andreas und Folgebriefing.
2. Planungsgeometrie: noch nicht runtime-faehige manuelle Layer-/Maskenidee.
3. Runtime-Geometrie: erst nach eigenem JSON/YAML-/Runtime-Gate erlaubt.

M16-DH oeffnet nur Ebene 1 und vorbereitet Ebene 2 textlich.

## 4. Pfadbreiten

### 4.1 Mindestbreite fuer Figur/Marker

Fuehrende Einheit:

```text
visitor_marker_diameter = spaeterer sichtbarer Marker-/Figur-Durchmesser im
Visit/Wander-Modus
```

Planungsregel:

- `walkable_path_layer` muss als Korridor gedacht werden, nicht als duenne
  Linie.
- Ein normaler Pfadkorridor braucht mindestens `3.0 x visitor_marker_diameter`
  als Review-Breite.
- Ein kurzer Engpass darf nicht unter `2.0 x visitor_marker_diameter` fallen.
- Ein Engpass unter `2.0 x visitor_marker_diameter` ist `not_walkable_until_gate`.
- Der Marker darf im Review-Korridor nicht optisch Wasser, harte Baumblocker,
  harte Felsblocker oder Aussenkante beruehren.

Diese Werte sind relative Review-Verhaeltnisse, keine Pixelmasse.

### 4.2 Planungskorridor vs Runtime-Pfad

| Begriff | Bedeutung | Status |
| --- | --- | --- |
| `planning_path_corridor` | Breite Review-Flaeche, in der ein spaeterer Pfad liegen koennte. | Erlaubt fuer naechsten Visual-Pass |
| `runtime_path_centerline` | spaeterer technischer Bewegungsgraph oder Centerline. | Blockiert |
| `runtime_path_width` | spaeterer technischer Kollisions-/Bewegungspuffer. | Blockiert |

M16-DH erlaubt nur den `planning_path_corridor`. Jede Centerline, jeder Node,
jede Wegkante und jedes Pathfinding bleibt blockiert.

### 4.3 Station-Abstand

Stationspunkte duerfen spaeter nur gesetzt werden, wenn:

- sie innerhalb eines `planning_path_corridor` liegen,
- sie mindestens `1.5 x visitor_marker_diameter` Abstand zu harter
  No-Walk-Geometrie halten,
- sie nicht direkt auf einer Ufer-, Hain- oder Klippenkante sitzen,
- sie auf Mid-Zoom eindeutig antippbar/lesbar waeren,
- ihr Label oder Stationsname nicht mit benachbarten Stationen kollidiert.

Stationspunkte sind noch keine Runtime-Path-Nodes.

### 4.4 Kamera-Follow-Abstand

Fuer Visit/Wander-Review gilt:

- Ein spaeterer Marker braucht um sich herum einen `follow_safe_area`.
- `follow_safe_area` muss mindestens Marker plus naechste Korridorbreite
  sichtbar halten.
- Kamera-Follow darf nicht erzwingen, dass der Blick an Wasser-, Hain- oder
  Klippenkanten leer laeuft.
- Stationen an Kartenraendern brauchen zusaetzlichen Edge-/Framing-Review.

Diese Regel ist Kamera-QA, keine Pan-Bounds-Implementierung.

## 5. Wassergrenzen

### 5.1 Harte Wassergrenze

`water_river_mask` braucht spaeter eine harte Wassergrenze:

- Meer, Flussarm, Uferarm und Wasserfall-/Eintrittsbereich werden als
  eigene Wasserflaechen geplant.
- Die Grenze ist eine manuelle Review-/Vector-Kante, nicht aus Blauwerten
  abgeleitet.
- Wasser ist fuer Visit/Wander `no_walk`.
- Wasser ist fuer Build/Map `no_build`.
- Wasser ist kein dekorativer Weg.

### 5.2 Uferpuffer

Zwischen Wasser und Pfad/Build-Zonen braucht Uferwald zwei Pufferarten:

| Puffer | Zweck | Regel |
| --- | --- | --- |
| `water_no_walk_buffer` | verhindert Markerberuehrung mit Wasser | Pflicht fuer Wander-Review |
| `water_no_build_buffer` | verhindert Gebaeude/Fundamente direkt im Wasser | Pflicht fuer Build-Review |

No-Walk- und No-Build-Puffer duerfen unterschiedlich breit sein. No-Build kann
groesser sein als No-Walk, wenn Uferlesbarkeit oder Erweiterungen Schutz
brauchen.

### 5.3 River Entry/Exit

`river_entry_anchor` und `river_exit_anchor` bleiben Landmarken und
Messreferenzen:

- `river_entry_anchor`: oberer Wasser-/Wasserfall-/Eintrittsbereich.
- `river_exit_anchor`: Flussmuendung oder unterer Wasserabgang.

Sie duerfen in M16-DH keine finalen Koordinaten erhalten. Spaeter muessen sie
beide mit `water_river_mask` und `landmark_anchor_layer` konsistent sein.

### 5.4 Bruecken und Furten

Bruecken, Furten, Stege oder wasserquerende Bewegung bleiben blockiert bis zu
einem eigenen Gate.

Bis dahin gilt:

- Kein Pfad darf Wasser schneiden.
- Kein Wegpunkt darf auf Wasser liegen.
- Kein Build-Footprint darf Wasser oder Wasserpuffer schneiden.

## 6. Baum- und Hainlayer

Der `tree_obstacle_layer` muss vier Rollen trennen:

| Rolle | Bedeutung | Darf Bewegung blockieren? | Darf Bauen blockieren? |
| --- | --- | --- | --- |
| `decorative_tree` | einzelne Deko- oder Stimmungsbaeume | Nein, nicht automatisch | Nein, nicht automatisch |
| `soft_forest_edge` | weiche Waldkante, optische Grenze | Nur nach Review | Nur nach Review |
| `hard_tree_blocker` | dichter Hain / echte Sperrflaeche | Ja | Ja |
| `tree_occlusion_edge` | Kante, vor/hinter der Figuren verschwinden koennen | Nein als Collision | Nur indirekt |

Regeln:

- Der Hain bleibt Uferwald-Identitaet, aber nicht jeder Baum ist Collision.
- Harte Baumblocker duerfen nicht aus Gruenwerten im Bild entstehen.
- Eine Waldlichtung ist nicht automatisch Build-Zone.
- Occlusion-Kanten muessen getrennt von No-Walk dokumentiert werden.

## 7. Fels- und Klippenlayer

Der `rock_cliff_obstacle_layer` muss vier Rollen trennen:

| Rolle | Bedeutung | Regel |
| --- | --- | --- |
| `decorative_rock` | kleiner Atmosphaerenfels | kein automatischer Blocker |
| `hard_rock_blocker` | Felskoerper, der Bewegung/Bauen sperrt | in No-Walk und/oder No-Build pruefen |
| `cliff_edge` | harte Hoehenkante | No-Walk-Puffer Pflicht |
| `height_occlusion_edge` | Sicht-/Sortierkante durch Hoehe | Sort-/Occlusion-Regel, nicht Collision |

No-Walk-/No-Build-Puffer:

- `cliff_no_walk_buffer` schuetzt Bewegung vor harten Hoehenkanten.
- `cliff_no_build_buffer` schuetzt Footprints vor Klippen und Randabbruechen.
- Dekorative Felsen duerfen nur dann Sperren werden, wenn sie als
  `hard_rock_blocker` markiert sind.

## 8. No-Walk-Union

`no_walk_mask` ist die harte Bewegungs-Sperre fuer Visit/Wander. Sie darf
nicht aus Pixeln oder einem Gesamtbild abgeleitet werden.

Vorlaeufige Review-Formel:

```text
no_walk_mask =
  water_river_mask
  + water_no_walk_buffer
  + hard_tree_blocker
  + hard_rock_blocker
  + cliff_no_walk_buffer
  + base_rock_shape_outer_edge
  + forbidden_path_segments
```

Nicht automatisch enthalten:

- `no_build_mask`,
- alle dekorativen Baeume,
- alle dekorativen Felsen,
- weiche Waldkanten,
- Sort-Bands,
- Build-Zonen.

`forbidden_path_segments` sind geplante Korridore, die durch QA fallen, weil
sie Wasser, harte Baumblocker, harte Felsblocker oder zu enge Kanten schneiden.

## 9. No-Build-Union

`no_build_mask` ist die harte Bausperre fuer Build/Map und Object-Focus-
Footprints. Sie darf nicht 1:1 aus `no_walk_mask` entstehen.

Vorlaeufige Review-Formel:

```text
no_build_mask =
  water_river_mask
  + water_no_build_buffer
  + hard_tree_blocker
  + hard_rock_blocker
  + cliff_no_build_buffer
  + walkable_path_layer_as_build_protection
  + hub_anchor_protection
  + landmark_anchor_protection
  + base_rock_shape_edge_margin
  + attachment_expansion_protection
```

Wichtig:

- Wege koennen begehbar sein, aber fuer Bauen gesperrt bleiben.
- Hain kann fuer Bauen haerter gesperrt sein als fuer reine Sicht.
- Erweiterungsschutz schuetzt spaetere Garage, Garten, Terrasse, Vorhof oder
  Attachments davor, schon im ersten Footprint blockiert zu werden.
- No-Build ist kein Kapazitaetszaehler und keine Slotliste.

## 10. Pfad-gegen-Blocker-QA

Jeder spaetere `planning_path_corridor` muss diese QA bestehen:

| Pruefung | Muss bestehen |
| --- | --- |
| Wasser-Schnitt | Pfad darf `water_river_mask` und `water_no_walk_buffer` nicht schneiden. |
| Baumblocker-Schnitt | Pfad darf `hard_tree_blocker` nicht schneiden. |
| Felsblocker-Schnitt | Pfad darf `hard_rock_blocker` und `cliff_no_walk_buffer` nicht schneiden. |
| Aussenkante | Pfad muss innerhalb `base_rock_shape` plus sicherem Innenabstand liegen. |
| No-Walk | Pfad darf harte `no_walk_mask` nicht schneiden. |
| No-Build | Pfad darf No-Build nur beruehren, wenn der Schnitt bewusst als `walkable_path_layer_as_build_protection` dokumentiert ist. |
| Station | Jede Station liegt im Pfadkorridor und ausserhalb harter Blocker. |

Wenn eine Pruefung NEIN ist, wird das Segment als `blocked_path_candidate`
markiert und darf nicht in Runtime- oder JSON/YAML-Planung wandern.

## 11. Sort- und Occlusion-Regeln

### 11.1 Sort-Bands

Die drei bisherigen Review-Bands bleiben als Startmodell:

- `background_north`
- `midground_center`
- `foreground_south`

Fuer den naechsten Visual-Pass muessen sie um Uebergangs- und
Occlusion-Regeln ergaenzt werden. Sie bleiben keine Renderer-Implementation.

### 11.2 Sort-Anker

Jede spaetere Figur, Station, Build Station oder Bauphase braucht einen
`sort_anchor`:

- Der `sort_anchor` ist der Fuss-/Bodenbezug, nicht die Bildmitte.
- Sortierung folgt spaeter dem `sort_anchor`, nicht der oberen Objektkante.
- Sort-Anker bleiben in M16-DH Rollenregeln, keine Koordinaten.

### 11.3 Figur-vor/hinter-Objekt-Regeln

Review-Regel:

- Figur vor Objekt, wenn ihr `sort_anchor` im Vordergrundbereich des Objekts
  liegt.
- Figur hinter Objekt, wenn ihr `sort_anchor` hinter einer dokumentierten
  `occlusion_edge` liegt.
- Objekt-Focus darf keine Figur oder Bubble verdecken, wenn die
  `occlusion_edge` nicht geklaert ist.

### 11.4 Hain-/Fels-Occlusion

Hain und Felsen brauchen eigene Occlusion-Kanten:

- `tree_occlusion_edge` fuer dichte Baumfronten.
- `height_occlusion_edge` fuer Fels-/Klippenhoehen.

Diese Kanten sind keine Collision und keine No-Walk-Masken. Sie dienen nur der
spaeteren Vorder-/Hintergrund- und Object-Focus-Pruefung.

## 12. Anchor-Rollen

Jeder Anchor bekommt genau dokumentierte Rollen. Mehrfachrollen sind erlaubt,
muessen aber explizit sein.

| Rolle | Bedeutung | Grenze |
| --- | --- | --- |
| `landmark` | Orientierungspunkt fuer Karte, Copy oder Review | keine Bewegung |
| `path_node` | spaeterer Weg-/Stationskandidat | erst nach Pfad-QA |
| `build_reference` | Bau-/Build-Zonen-Bezugspunkt | kein fixer Slot |
| `object_focus_reference` | spaeterer Fokuspunkt fuer Objektkamera | keine Runtime-Interaktion |

Vorlaeufige Rollen fuer bekannte Anchors:

| Anchor | Primaere Rolle | Zusaetzliche moegliche Rolle | Status |
| --- | --- | --- | --- |
| `hub_center_anchor` | `landmark` | `path_node`, `object_focus_reference` | keine finalen Koordinaten |
| `main_build_area_anchor` | `build_reference` | `landmark` | keine finalen Koordinaten |
| `house_primary_anchor` | `build_reference` | `object_focus_reference` | kein fixer Hausplatz |
| `river_entry_anchor` | `landmark` | `object_focus_reference` | keine Bruecke/Furt |
| `river_exit_anchor` | `landmark` | `path_node` nur nach Wasser-QA | keine Bruecke/Furt |
| `grove_anchor` | `landmark` | `object_focus_reference` | kein automatischer Walk-Punkt |
| `reserve_zone_anchor_north` | `build_reference` | `landmark` | keine Slot-Festlegung |
| `reserve_zone_anchor_south` | `build_reference` | `landmark` | keine Slot-Festlegung |
| `startplatz_anchor` | `path_node` | `landmark` | erst nach Pfad-QA |
| `aussichtspunkt_anchor` | `landmark` | `path_node`, `object_focus_reference` | erst nach Pfad-QA |

Keine dieser Rollen ist eine finale Koordinate, ein Runtime-Anchor, ein Slot,
ein gespeicherter State oder eine App-Interaktion.

## 13. Ausreichend fuer naechsten Visual-Precision-Pass

Nach M16-DH ausreichend:

- Relative Pfadbreiten sind definiert.
- Planungskorridor und Runtime-Pfad sind getrennt.
- Wassergrenze, Uferpuffer, River Entry/Exit und Bruecken-/Furt-Blockade sind
  fachlich geklaert.
- Baum-/Hainrollen sind getrennt.
- Fels-/Klippenrollen sind getrennt.
- No-Walk- und No-Build-Union-Regeln sind definiert und bewusst verschieden.
- Pfad-gegen-Blocker-QA ist als harte Checkliste vorhanden.
- Sort-/Occlusion-Regeln haben Rollen und Kantenbegriffe.
- Anchor-Rollen sind fuer den naechsten Review-Schritt klassifiziert.

Damit ist ein weiterer Visual-Precision-Pass sinnvoll.

## 14. Weiterhin blockiert fuer JSON/YAML und Runtime

Weiterhin blockiert:

- finale Koordinaten,
- echte Polygon-Dateien,
- JSON/YAML-Manifest oder Schema-Datei,
- Runtime-Mapdaten,
- Pathfinding,
- Kollisionsdaten,
- Flutter-/Dart-Code,
- App-Integration,
- Persistenz,
- BuildState,
- Assets oder Dateien unter `assets/`.

JSON/YAML darf erst starten, wenn ein naechster Visual-Precision-Pass die
Regeln aus M16-DH sichtbar prueft und ein Review-Slice bestaetigt, welche
Geometrie stabil genug fuer ein Schema-Gate ist.

## 15. Empfohlener naechster Slice

Empfohlen:

```text
M16-DI Uferwald Measurement Visual Precision Pass
```

M16-DI sollte als Visual Documentation Slice die M16-DH-Regeln sichtbar
ueberpruefen:

- Pfadkorridor-Breitenklassen,
- Wasser-/Uferpuffer,
- harte vs weiche Baum-/Hainrollen,
- Fels-/Klippenpuffer,
- No-Walk-/No-Build-Union-Overlays,
- Pfad-gegen-Blocker-Konflikte,
- Sort-/Occlusion-Kanten,
- Anchor-Rollen.

M16-DI darf weiterhin keine Runtime-Daten, JSON/YAML-Dateien, Assets oder Code
erzeugen, sofern ein Folgeprompt das nicht separat und enger oeffnet.

## 16. Stop-Regeln

M16-DH gibt nicht frei:

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
- keine SVG/PNG-Dateien,
- keine JSON/YAML-Dateien,
- keine Assets,
- keine Dateien unter `assets/`,
- keine finalen Koordinaten,
- keine Figma-Writes,
- keine Engine-ready Candidates,
- keine approved Assets,
- keinen Commit.
