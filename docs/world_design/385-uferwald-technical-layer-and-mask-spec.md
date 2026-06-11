# M16-DB: Uferwald Technical Layer and Mask Spec

Stand: 2026-06-11

Status: `Docs-/Technical-Spec-Gate / keine Code-, Bild- oder Asset-Freigabe`

Template: `docs/world_design/prompt_templates/docs_only_slice.md`

## 1. Zweck

M16-DB konkretisiert die technische Layer-/Masken-Architektur aus M16-DA fuer
Uferwald. Der Slice definiert, welche technischen Ebenen spaeter vorhanden sein
muessen, bevor Uferwald als spielbare Karte fuer Build/Map, Visit/Wander,
Object Focus oder Overview belastbar werden kann.

M16-DB erzeugt keine Runtime-Daten. Es erzeugt keine Bilder, keine Assets,
keine Flutter-/Dart-Dateien, keine App-Integration, keine Route, keine
Persistenz und keinen BuildState.

Leitregel:

> Das sichtbare Uferwald-Art-Bild ist nicht die technische Spielkarte.

## 2. Eingangsquellen

Fuehrende Quellen:

- `docs/world_design/336-documentation-map-and-slice-reading-rules.md`
- `docs/world_design/370-asset-family-and-export-spec.md`
- `docs/world_design/379-uferwald-layer-candidate-intake-and-qa.md`
- `docs/world_design/381-uferwald-anchor-zone-layer-overlay-plan.md`
- `docs/world_design/383-talvori-camera-modes-and-visit-wander-rule.md`
- `docs/world_design/384-uferwald-playable-map-layer-and-mask-architecture.md`

M16-DA ist die harte Architekturregel. M16-DB ist die konkrete Spezifikation
der technischen Ebenen, die daraus folgen.

## 3. Non-Goals

M16-DB gibt nicht frei:

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
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine automatische Ableitung aus Pixelbildern,
- keinen Commit.

## 4. Technische Grundregel

Uferwald braucht zwei getrennte Ebenen von Wahrheit:

1. Technische Wahrheit: Layer, Masks, Zonen, Anchors, Sort-Bands und spaeter
   konkrete Mapdaten.
2. Sichtbare Wahrheit: Art-Rendering, Review-Bild, Overlay oder spaeter
   Layer-Art.

Die technische Wahrheit muss fuehrend sein. Sichtbare Art darf technische
Entscheidungen illustrieren, aber nicht ersetzen.

Damit gilt:

- Visit/Wander darf Walkability, Pfade oder Hindernisse nicht aus Pixeln
  erraten.
- Build/Map darf Bauzonen, Plot-Footprints oder No-Build-Zonen nicht aus
  Pixeln erraten.
- Object Focus darf Pivot, Occlusion, Sortierung oder Objektnaehe nicht aus
  Pixeln erraten.
- Overview darf ein gerendertes Bild zeigen, aber keine Gameplay-Daten daraus
  ableiten.

## 5. Gemeinsame Datenkonventionen

Diese Spezifikation bleibt formatneutral, definiert aber die gemeinsame
Konvention fuer spaetere Daten:

| Feld | Regel |
| --- | --- |
| `map_id` | `uferwald_starter_island` fuer diese technische Spec. |
| `canvas_family` | Muss spaeter eindeutig sein und mit Uferwald-Layerfamilien stabil bleiben. |
| `coordinate_space` | Bevorzugt `normalized_0_1` fuer Docs, Review und fruehe Manifest-Dateien. |
| `canvas_origin` | `top_left_normalized_0_0` fuer Dokumentationskoordinaten. |
| `world_origin` | `hub_center_anchor`, solange kein spaeteres Runtime-Gate einen anderen Ursprung begruendet. |
| `layer_pivot` | `world_origin_unless_family_override`. |
| `source_status` | Aktuelle Uferwald-Bilder bleiben `layer_postprocess_candidate` oder Review-Referenz, nicht technische Quelle. |

Spaetere technische Daten duerfen als Markdown-Spec, JSON/YAML-Manifest,
SVG/Figma-Vector-Plan oder Raster-Maskenplanung entstehen. Diese Formate sind
Planungsoptionen, keine Freigabe fuer App-Integration oder `assets/`.

## 6. Pflicht-Layer und Masks

### 6.1 `base_rock_shape`

Zweck:

- Fuehrende Insel-Silhouette und harte Landmasse.
- Beschreibt Klippenkoerper, Randform, grobe Hoehenkoerper und Uferkante.
- Gibt dem Rendering die tragende Form, aber noch keine begehbaren Flaechen.

Spaetere Datenform moeglich:

- Polygon oder Multi-Polygon,
- SVG/Figma-Path,
- JSON/YAML-Polygonliste,
- Raster-Mask fuer harte Landmasse.

Nutzer:

- Build/Map fuer Kartenbounds und Edge-Masking,
- Visit/Wander fuer Aussenbegrenzung,
- Object Focus fuer Umgebungskontext,
- Overview fuer komplette Insel-Silhouette.

Darf nicht daraus abgeleitet werden:

- Walkability,
- Buildability,
- feste Slots,
- Kategorieplaetze,
- Pfadverlauf,
- No-Build-Zonen ausserhalb harter Aussenform.

### 6.2 `grass_terrain_mask`

Zweck:

- Beschreibt Wiesen-, Boden- und weiche Terrainflaechen.
- Trennt gruene/natuerliche Flaechen von Wasser, Felsen, Hain und harten
  Hindernissen.
- Liefert spaeter Art- und Gameplay-Kontext fuer organische Bau- und
  Bewegungsraeume.

Spaetere Datenform moeglich:

- Polygon/Multi-Polygon,
- Raster-Mask,
- SVG/Figma-Flaeche,
- JSON/YAML mit Terrain-Typen und Varianten.

Nutzer:

- Build/Map fuer Eignungspruefung zusammen mit `buildable_zone_layer`,
- Visit/Wander fuer Lesbarkeit von begehbaren Flaechen zusammen mit
  `walkable_path_layer`,
- Object Focus fuer natuerlichen Objektkontext,
- Overview fuer Terrainverteilung.

Darf nicht daraus abgeleitet werden:

- automatisch begehbare Flaeche,
- automatisch baubare Flaeche,
- feste Grundstuecke,
- Kategoriebindung,
- Kollisionsfreiheit.

### 6.3 `water_river_mask`

Zweck:

- Beschreibt Meer, Flussarm, Uferarm, Wasserfall-/Eintrittsbereich,
  Muendung und Uferuebergaenge.
- Dient als harte Referenz fuer Wasser-only- und No-Walk-/No-Build-Logik.

Spaetere Datenform moeglich:

- Wasser-Polygon,
- Fluss-Polyline plus Breite,
- Raster-Mask,
- SVG/Figma-Wasserflaechen,
- JSON/YAML mit `river_entry_anchor` und `river_exit_anchor`.

Nutzer:

- Visit/Wander fuer Wasserbarrieren und moegliche Bruecken-Gates,
- Build/Map fuer No-Build- und Uferabstandsregeln,
- Object Focus fuer Ufernaehe und atmosphaerische Kontexte,
- Overview fuer Inselidentitaet.

Darf nicht daraus abgeleitet werden:

- begehbare Bruecken oder Furten ohne eigenes Gate,
- Gebaeudestandorte am Wasser,
- Kategorieplaetze,
- dekorative Wasserwege als echte Navigation.

### 6.4 `walkable_path_layer`

Zweck:

- Definiert echte begehbare Wege, Wegbreiten, Pfadknoten und erlaubte
  Besucherbewegung.
- Ist die fuehrende Quelle fuer Visit/Wander-Navigation.

Spaetere Datenform moeglich:

- Polyline-Netz mit Breiten,
- Path-Corridor-Polygone,
- Graph aus Nodes und Edges,
- JSON/YAML mit Waypoints, Segmenten und Kosten,
- SVG/Figma-Path als Planungsquelle.

Nutzer:

- Visit/Wander als primaerer Nutzer,
- Object Focus fuer Annaeherung an Objekte,
- Overview fuer optionale Weglesbarkeit,
- Build/Map nur indirekt fuer Konfliktpruefung mit Bauzonen.

Darf nicht daraus abgeleitet werden:

- Buildability,
- Grundstuecke,
- Kategorieplaetze,
- Terrain-Typ,
- automatisch gueltige Besucheranimation ohne No-Walk-/Obstacle-Pruefung.

### 6.5 `tree_obstacle_layer`

Zweck:

- Definiert Hain, dichte Baumgruppen, Waldkanten und Vegetationshindernisse.
- Schuetzt Uferwald-Identitaet und verhindert, dass der Hain versehentlich
  begehbar oder bebaubar wird.

Spaetere Datenform moeglich:

- Hindernis-Polygone,
- Baum-Instanzpunkte mit Radius,
- Raster-Mask,
- SVG/Figma-Obstacle-Flaechen,
- JSON/YAML mit Dichte- und No-Build-Flags.

Nutzer:

- Visit/Wander fuer No-Walk-Pruefung,
- Build/Map fuer No-Build-/Terrain-sensitive-Pruefung,
- Object Focus fuer Occlusion und Umgebungskontext,
- Overview fuer Hain-Lesbarkeit.

Darf nicht daraus abgeleitet werden:

- dekorative einzelne Baeume als echte Pfadknoten,
- bebaubare Waldlichtungen ohne eigene Zone,
- automatische Sortierung aller Figuren ohne `depth_sort_bands`.

### 6.6 `rock_cliff_obstacle_layer`

Zweck:

- Definiert Felsen, Klippen, harte Hoehenkanten und Blocker.
- Trennt dekorative Hoehenlogik von echten Bewegungs- und Bauhindernissen.

Spaetere Datenform moeglich:

- Hindernis-Polygone,
- Cliff-Polyline plus No-Walk-Puffer,
- Raster-Mask,
- SVG/Figma-Flaechen,
- JSON/YAML mit Hoehen-/Klippenklassen.

Nutzer:

- Visit/Wander fuer Movement-Grenzen,
- Build/Map fuer No-Build und Abstandsregeln,
- Object Focus fuer Depth/Occlusion,
- Overview fuer Hoehenstruktur.

Darf nicht daraus abgeleitet werden:

- begehbare Stufen,
- Bauplaetze auf Terrassen,
- Figuren-Sortierung ohne separate Sort-Bands,
- Wegverbindungen durch Klippen.

### 6.7 `buildable_zone_layer`

Zweck:

- Definiert organische Eignungsraeume fuer freie Bauentscheidungen.
- Ermoeglicht freie Baukapazitaet ohne feste Slots und ohne Kategoriebindung.
- Trennt Ortsfreiheit von Kapazitaetszaehlern.

Spaetere Datenform moeglich:

- Eignungs-Polygone,
- Soft-Zone-Polygone mit Score,
- JSON/YAML mit `zone_id`, Groesse, Nachbarschaft und Constraints,
- SVG/Figma-Zonenplan.

Nutzer:

- Build/Map als primaerer Nutzer,
- Object Focus fuer spaeteren Objektkontext,
- Overview fuer Kapazitaets-/Reserveueberblick,
- Visit/Wander nur indirekt fuer Konfliktpruefung mit Wegen.

Darf nicht daraus abgeleitet werden:

- feste Grundstuecke,
- feste 12 Slots,
- Kategorieplaetze,
- automatische Gebaeudeplatzierung,
- Produktions-Persistenz.

### 6.8 `plot_footprint_layer`

Zweck:

- Definiert spaetere Objekt- und Gebaeude-Footprint-Klassen.
- Klaert, welche Flaechen kleine, mittlere, grosse und Attachment-Objekte
  benoetigen.
- Schuetzt Adjacency-Regeln wie Garage/Garten/Terrasse neben Haus.

Spaetere Datenform moeglich:

- Footprint-Templates als Polygone,
- Bounding-Box-/Radius-Klassen,
- JSON/YAML mit `footprint_class`, `min_area`, `attachment_edges`,
- SVG/Figma-Footprint-Beispiele.

Nutzer:

- Build/Map fuer Groessen- und No-Overlap-Pruefung,
- Object Focus fuer Objekt-Pivot und Umfeld,
- Overview fuer grobe Lesbarkeit,
- Visit/Wander fuer spaetere Path-/Object-Konflikte.

Darf nicht daraus abgeleitet werden:

- konkrete gebaute Objekte,
- feste Kategoriezuordnung,
- finaler Hausplatz,
- automatische Bauphase,
- Runtime-State.

### 6.9 `no_walk_mask`

Zweck:

- Definiert harte Sperrflaechen fuer Besucherbewegung.
- Kombiniert Wasser, Hain, Klippen und harte Aussenrander zu einer
  Movement-Grenze, ohne Build-Regeln zu ersetzen.

Spaetere Datenform moeglich:

- Union-Polygon,
- Raster-Mask,
- JSON/YAML aus referenzierten Source-Layern,
- SVG/Figma-Maskenplan.

Nutzer:

- Visit/Wander als primaerer Nutzer,
- Object Focus fuer Marker- und Kamera-Sicherheit,
- Build/Map nur zur Konfliktwarnung,
- Overview fuer Review.

Darf nicht daraus abgeleitet werden:

- No-Build automatisch in jeder Situation,
- Buildable Zones,
- Objekt-Footprints,
- Wegnetz ohne `walkable_path_layer`.

### 6.10 `no_build_mask`

Zweck:

- Definiert harte Sperrflaechen fuer Bauen.
- Schuetzt Wasser, Hain, Klippen, Kanten, Wege, Hub und spaetere Safe Areas.

Spaetere Datenform moeglich:

- Union-Polygon,
- Raster-Mask,
- JSON/YAML mit Source-Layer-Referenzen und Gruenden,
- SVG/Figma-Maskenplan.

Nutzer:

- Build/Map als primaerer Nutzer,
- Object Focus fuer Bauplatzkontext,
- Overview fuer Baupotenzial,
- Visit/Wander nur indirekt fuer Weg-/Baukonflikte.

Darf nicht daraus abgeleitet werden:

- No-Walk automatisch in jeder Situation,
- feste Slots,
- Kategorieplaetze,
- Objekt-Footprints,
- Kapazitaetszaehler.

### 6.11 `depth_sort_bands`

Zweck:

- Definiert Vordergrund, Mittelgrund, Hintergrund, Sortierbaender und
  Occlusion-Regeln.
- Verhindert, dass Figuren, Build Stations, Gebaeude oder Bubbles spaeter nur
  nach Augenmass ueber/unter der Welt liegen.

Spaetere Datenform moeglich:

- Sort-Band-Polygone,
- Y-Band-Regeln,
- JSON/YAML mit `band_id`, `sort_base`, `occlusion_policy`,
- SVG/Figma-Bandplan.

Nutzer:

- Visit/Wander fuer Figuren und Marker,
- Build/Map fuer Build Stations und Bauphasen,
- Object Focus fuer Objektueberdeckung,
- Overview fuer grobe Tiefenlesbarkeit.

Darf nicht daraus abgeleitet werden:

- Walkability,
- Buildability,
- Kollisionslogik,
- echte Hoehenphysik,
- App-Renderer-Implementierung.

### 6.12 `landmark_anchor_layer`

Zweck:

- Definiert benannte Landmarken und Bezugspunkte fuer Uferwald.
- Verbindet technische Karte, Kamera-Modi, Copy, Review und spaetere
  Objektauswahl.

Pflicht-Anker fuer die erste Fassung:

- `hub_center_anchor`
- `main_build_area_anchor`
- `house_primary_anchor`
- `river_entry_anchor`
- `river_exit_anchor`
- `grove_anchor`
- `reserve_zone_anchor_north`
- `reserve_zone_anchor_south`
- spaeter optional: `startplatz_anchor`, `aussichtspunkt_anchor`,
  `waterfall_anchor`, `path_loop_anchor`

Spaetere Datenform moeglich:

- JSON/YAML-Ankerliste,
- Normalized coordinate pairs,
- SVG/Figma-Anchor-Layer,
- Markdown-Manifest fuer Review.

Nutzer:

- Build/Map fuer Fokus und Baukontext,
- Visit/Wander fuer Stationen und Wegpunkte,
- Object Focus fuer Kamera- und Objektbezug,
- Overview fuer Orientierung.

Darf nicht daraus abgeleitet werden:

- Runtime-Slots,
- finale Pfade,
- Kategorieplaetze,
- Objektbesitz,
- Persistenz oder Cloud-Daten.

## 7. Modus-Matrix

| Ebene | Build/Map | Visit/Wander | Object Focus | Overview |
| --- | --- | --- | --- | --- |
| `base_rock_shape` | Bounds, Edge-Mask | Aussenkante | Kontext | Silhouette |
| `grass_terrain_mask` | Eignungsbasis | Bodenlesbarkeit | Umgebung | Terrainueberblick |
| `water_river_mask` | No-Build/Ufer | Barriere | Uferkontext | Identitaet |
| `walkable_path_layer` | Konfliktcheck | fuehrend | Annaeherung | optional sichtbar |
| `tree_obstacle_layer` | No-Build | No-Walk | Occlusion | Hain |
| `rock_cliff_obstacle_layer` | No-Build | No-Walk | Occlusion | Hoehen |
| `buildable_zone_layer` | fuehrend | indirekt | Objektkontext | Potenzial |
| `plot_footprint_layer` | fuehrend | Konfliktcheck | Pivot/Umfeld | Groessenlesbarkeit |
| `no_walk_mask` | Warnung | fuehrend | Marker-Sicherheit | Review |
| `no_build_mask` | fuehrend | indirekt | Baukontext | Review |
| `depth_sort_bands` | Station/Bauphase | Figur/Marker | Objektueberdeckung | Tiefe |
| `landmark_anchor_layer` | Fokus | Stationen | Fokus | Orientierung |

## 8. Produktionsreihenfolge

Die Reihenfolge fuer Uferwald ist verbindlich:

1. Technische Layer/Masks/Zonen definieren.
2. Daraus visuelle Layer/Art, Overlays oder Render-Briefs ableiten.
3. Danach erst lokale Preview mit echter Pfad-/Buildlogik pruefen.
4. Danach erst ein eigenes Asset-/Engine-/Integration-Gate oeffnen.

Konkreter naechster technischer Pfad:

```text
M16-DC Uferwald Technical Layer Manifest
```

M16-DC sollte noch ohne App-Integration arbeiten und die M16-DB-Spec in ein
konkretes, pruefbares Manifest uebersetzen, zum Beispiel als Markdown- oder
JSON/YAML-Plan mit Layer-IDs, Zone-IDs, Anchor-IDs und offenen Messpunkten.

## 9. M16-CY-FIX-3 als verworfener Risiko-Proof

M16-CY-FIX-3 hat gezeigt, warum diese Spec noetig ist:

- Die Preview wirkte spielerischer, weil Stationen direkt antippbar waren.
- Der Besucher-Marker bewegte sich sichtbar.
- Der Pfad musste aber weiterhin aus dem sichtbaren Uferwald-Bild interpretiert
  werden.
- Dadurch blieb nicht pruefbar, ob der Pfad technisch begehbar, kollisionsfrei
  oder layerfaehig ist.

M16-CY-FIX-3 bleibt deshalb ein UX-Learnings-Proof, aber kein produktionsfaehiger
Navigation-, Collision-, Build- oder Layer-Proof.

## 10. Commitfaehigkeit kuenftiger Slices

Ein kuenftiger Uferwald-/World-/Map-/Build-/Visit-Slice ist nicht
commitfaehig, wenn er spielbare Logik behauptet und eine der folgenden Fragen
mit NEIN beantworten muss:

- Ist fuer Bewegung `walkable_path_layer` plus `no_walk_mask` definiert?
- Ist fuer Bauen `buildable_zone_layer`, `plot_footprint_layer` plus
  `no_build_mask` definiert?
- Sind Wasser, Hain, Felsen/Klippen und harte Rander als eigene Layers/Masks
  dokumentiert?
- Sind `depth_sort_bands` fuer Vorder-/Mittel-/Hintergrund und Occlusion
  vorhanden?
- Sind Landmark-Anchors benannt und vom Pixelbild getrennt?
- Ist klar, welches Dokument technische Wahrheit und welches Bild nur Review
  oder Atmosphaere ist?
- Wird keine Gameplay-Logik aus dem fertigen Uferwald-Bild geraten?

Wenn eine Frage offen ist, bleibt der Slice Docs-/Review-/Preview-only.

## 11. Stop-Regeln

M16-DB gibt nicht frei:

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
- keine Assets,
- keine Dateien unter `assets/`,
- keine Engine-ready Candidates,
- keine approved Assets,
- keine externen Writes,
- keinen Commit.
