# Phase 2G-M2: Island Plot Metrics And Greybox Layout

Stand: 2026-06-05

Dieses Dokument startet Phase 2G-M2 als reinen Planungsblock fuer konkrete
Plot-Metriken und ein erstes Greybox-Masterlayout der privaten Talvori-Insel.

Fuehrende Dokumente:

- `docs/world_design/247-island-greybox-scale-and-plot-metrics.md`
- `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `docs/world_design/245-build-alignment-and-anchor-system.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck

Dieses Dokument uebersetzt die bisher relative Einheit `P` aus Phase 2G-M1 in
konkrete vorlaeufige Greybox-Metriken.

Es definiert:

- vorlaeufiges Standard-Plotmass,
- Plotgroessen in relativen und logischen Greybox-Einheiten,
- StarterCorePlot-Mass,
- Wegbreite,
- Socket-Abstand,
- Mindestabstaende,
- Sicherheitszonen,
- erste Masterlayout-Greybox mit Plot-Koordinaten,
- Starter- und Expansion-Plots,
- Regeln fuer spaetere Erweiterungs-Andockpunkte.

Nicht-Ziel:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Asset-Erzeugung,
- keine PNG-Aenderung,
- kein neues Inselbild,
- kein `frame_started`,
- keine Bauzustands-Fortsetzung,
- kein Commit.

## 2. Research-Gate: Reicht Die Grundlage?

Entscheidung:

Fuer Phase 2G-M2 reicht die Research-Grundlage aus `246` und `247` aus. Es ist
keine neue grosse Recherche noetig.

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung |
| --- | --- | --- |
| `246` dokumentiert Grid, Tile Anchor, Snaps/ProBuilder und Sockets als professionelle Orientierung fuer modulare Layouts. | Modulare Level werden intern mit Grid/Snap/Socket/Anchor geplant, auch wenn die finale Optik organisch ist. | M2 nutzt logische `gu`-Einheiten und Plot-Koordinaten. |
| `247` definiert relative Plotgroessen, Mindestkapazitaet und Socket-Typen. | M2 muss nicht erneut die Theorie klaeren, sondern konkrete Greybox-Metriken setzen. | `P` wird als logische isometrische Standard-Plotflaeche konkretisiert. |
| `245` zeigt, dass Bauassets ohne Footprint-/Anchor-Pruefung scheitern. | Gebaeude und Bauzustaende brauchen Plot-Footprints vor Asset-Produktion. | `frame_started` bleibt blockiert, bis `starter_home_plot` konkret definiert ist. |

Risiko:

- Greybox-Werte koennen spaeter angepasst werden, sobald echte Device-Preview
  und Lesbarkeit geprueft werden.
- Zu fruehe Pixelwerte wuerden wieder Asset-Produktion vortaeuschen.

Talvori-Entscheidung:

- M2 setzt konkrete logische Greybox-Werte.
- M2 setzt keine finalen Asset-Pixelwerte.
- M2 erlaubt danach nur weitere Greybox-/Layout-Preview-Planung, keine Assets.

Erlaubt dadurch:

- Layout-Preview planen,
- Plot-Metriken diskutieren,
- Starter-/Expansion-Grenzen pruefen.

Blockiert bleibt:

- `frame_started`,
- neue Insel-/Plot-/Gebaeudeassets,
- Code,
- App-Integration,
- Tests,
- Persistenz/Supabase/SRS/Reward/Ressourcen.

## 3. Vorlaeufige Greybox-Einheit `P`

Definition:

```text
1P = ein Standard-medium-Plot in logischen Greybox-Einheiten.
```

`P` ist keine Asset-Pixelgroesse.

M2 verwendet:

```text
1P = 100gu Breite x 72gu Tiefe
```

`gu` bedeutet `greybox unit`. Diese Einheit dient nur fuer Planung,
Koordinaten und Verhaeltnisse.

Form:

- Ein Plot wird intern als isometrisch gedachte logische Zelle geplant.
- In Tabellen wird er als rechteckige Bounding-Box in `gu` beschrieben.
- In spaeteren Previews kann diese Bounding-Box als isometrische Raute oder
  organisch abgerundete Insel-Flaeche visualisiert werden.

Regeln:

- `medium_plot = 1P = 100gu x 72gu`.
- `starter_home_plot` braucht mehr als ein reiner Bau-Footprint.
- Ein `medium_plot` muss ein kleines Haus, einen kleinen Hof und mindestens
  einen Weganschluss tragen koennen.
- Die aktuelle Waldlichtung soll logisch als `starter_home_plot` mit
  `1.5P` geplant werden, nicht nur als `1P`.

## 4. Konkrete Vorlaeufige Plot-Metriken

Alle Werte sind Greybox-Werte, keine finalen Asset-Pixel.

| Metrik | Vorlaeufiger Wert | Bedeutung |
| --- | ---: | --- |
| `standardPlotWidth` | `100gu` | Breite eines `medium_plot`. |
| `standardPlotDepth` | `72gu` | Tiefe eines `medium_plot`. |
| `microPlotSize` | `35gu x 26gu` | Kleine Deko-/Fokusflaeche. |
| `smallPlotWidth` | `70gu` | Kleine Plotbreite. |
| `smallPlotDepth` | `50gu` | Kleine Plottiefe. |
| `largePlotWidth` | `145gu` | Groesserer Funktionsplot. |
| `largePlotDepth` | `104gu` | Groessere Funktionsplottiefe. |
| `hubPlotWidth` | `200gu` | Hub-/Market-Greyboxbreite. |
| `hubPlotDepth` | `144gu` | Hub-/Market-Greyboxtiefe. |
| `edgePlotWidth` | `70-120gu` | Rand-/Docking-/Expansion-Plot. |
| `edgePlotDepth` | `36-72gu` | Randtiefe je nach Funktion. |
| `pathWidth` | `16gu` | Standardweg in Greybox. |
| `socketWidth` | `18gu` | Breite eines kompatiblen Anschlussfensters. |
| `socketTolerance` | `+/- 4gu` | Erlaubter Planungsversatz fuer Socket-Mitte. |
| `minBuildingToPlotEdgeDistance` | `14gu` | Mindestluft zwischen Gebaeude und Plotkante. |
| `minBuildingToPathDistance` | `10gu` | Mindestluft zwischen Gebaeude und Weg. |
| `decorationSafetyZone` | `8gu` | Abstand fuer Deko zu Weg, Footprint und Socket. |
| `fenceOffset` | `6gu` | Abstand von Zaun zur funktionalen Plotgrenze. |
| `treeToBuildingDistance` | `18gu` | Mindestabstand Baumkrone/Stamm zu Gebaeude. |
| `buildingFootprintRatio` | `0.38` | Maximal ca. 38% eines `medium_plot` fuer Gebaeude. |
| `yardRatio` | `0.25` | Ca. 25% fuer Hof/Vorplatz/Garten. |
| `pathConnectorRatio` | `0.12` | Ca. 12% fuer Hauptweganschluss. |

Interpretation:

- Ein Gebaeude darf den Plot nicht dominieren.
- Wege und Hof muessen lesbar bleiben.
- Deko ist zusaetzlich, nicht Ersatz fuer Randluft.
- Socket-Flaechen bleiben frei von Gebaeude-/Deko-Footprints.

## 5. Plotgroessen In `P` Und `gu`

| Plotgroesse | Relative Groesse | Greybox-Mass | Typische Nutzung |
| --- | ---: | ---: | --- |
| `micro_plot` | `0.25P` | `35 x 26gu` | Deko, Lichtpunkt, kleines Objekt. |
| `small_plot` | `0.5P` | `70 x 50gu` | Garten, Pfadsegment, kleiner Naturplot. |
| `medium_plot` | `1.0P` | `100 x 72gu` | Standard-Gebaeudeplot. |
| `starter_home_plot` | `1.5P` | `130 x 86gu` | Start-Hausgrundstueck mit Hof/Weg. |
| `large_plot` | `2.0P` | `145 x 104gu` | Farm, Naturzone, groesseres Thema. |
| `hub_plot` | `3-4P` | `200 x 144gu` | Markt-/Dorf-/Quest-Knoten. |
| `edge_plot` | `0.5-1.5P` | `70-120 x 36-72gu` | Rand, Docking, Expansion, Ufer. |

## 6. StarterCorePlot Konkretisiert

Die aktuelle Waldlichtung wird logisch als:

```text
plotType: starter_home_plot
plotRole: StarterCorePlot
logicalSize: 1.5P
greyboxSize: 130gu x 86gu
```

Sie repraesentiert:

- erstes Hausgrundstueck,
- erster BuildAreaState-Footprint,
- kleiner Hof/Vorplatz,
- Weganschluss,
- vorbereitete Expansion-/Path-Sockets.

Sie repraesentiert nicht:

- gesamte Privatinsel,
- Markt,
- Nachbarschaft,
- Farm,
- Wasser/Hafen,
- mehrere Gebaeude,
- vollstaendiges Wegnetz.

### Logische Anker Im StarterCorePlot

Alle Werte sind lokal zum `starter_home_plot` gedacht. Der Plotmittelpunkt ist
`(0, 0)` in lokalen `gu`.

| Anchor | Lokale Greybox-Position | Zweck |
| --- | ---: | --- |
| `plot_center` | `(0, 0)` | Plot-Orientierung. |
| `building_anchor` | `(0, -6)` | Zentrum des ersten Hauses/Bauzustands. |
| `building_footprint_polygon` | `(-28,-28), (28,-28), (34,14), (0,30), (-34,14)` | Maximaler Gebaeude-/Rohbau-Footprint. |
| `front_yard_anchor` | `(0, 28)` | Hof/Vorplatz vor dem Haus. |
| `back_yard_anchor` | `(0, -34)` | Rueckwaertige Randluft/Natur. |
| `path_entry_anchor` | `(0, 43)` | Hauptzugang nach Sueden/Vorne. |
| `decoration_anchor_left` | `(-48, 8)` | Linke Randdeko. |
| `decoration_anchor_right` | `(48, 6)` | Rechte Randdeko. |
| `decoration_anchor_back` | `(0, -42)` | Rueckwaertige Naturdeko. |
| `expansion_socket_west` | `(-65, 0)` | Seitlicher Anschluss. |
| `expansion_socket_east` | `(65, 0)` | Seitlicher Anschluss. |
| `path_socket_south` | `(0, 43)` | Weganschluss nach vorn. |
| `terrain_socket_north` | `(0, -43)` | Natur-/Terrainanschluss nach hinten. |

Offene Seiten:

- Sueden/Vorne: Hauptweg.
- Westen: spaeter Garten/Nachbarschaft oder Naturpfad.
- Osten: spaeter PathConnector/FunctionPlot.
- Norden: Natur/Backyard, nicht sofort Markt oder Nachbarschaft.

## 7. Erste Masterlayout-Greybox Als Koordinatenstruktur

Koordinatensystem:

- Plot-Koordinaten sind logische Rasterkoordinaten `(x, y)`.
- `starter_home` liegt bei `(0, 0)`.
- `x` waechst nach rechts/osten.
- `y` waechst nach unten/sueden/vorne.
- Ein Koordinatenschritt entspricht grob `1P` Abstand zwischen
  Plot-Zentren, nicht finalen Pixeln.

### Starter-Insel Sichtbar

| PlotId | Koordinate | Plottyp | Groesse | Status | Haupt-Sockets |
| --- | ---: | --- | --- | --- | --- |
| `starter_home` | `(0, 0)` | `starter_home_plot` | `1.5P` | sichtbar/start | `south:path`, `west:terrain/expansion`, `east:path`, `north:nature` |
| `garden_west` | `(-1, 0)` | `garden_plot` | `0.5-1P` | sichtbar/ruhig | `east:residential`, `south:path`, `west:expansion` |
| `path_south` | `(0, 1)` | `path_connector_plot` | `0.5P` | sichtbar | `north:path`, `south:path`, `east:path` |
| `nature_north` | `(0, -1)` | `nature_plot` | `0.5-1P` | sichtbar/ruhig | `south:nature`, `west:terrain`, `east:terrain` |
| `function_seed_east` | `(1, 0)` | `shop/workshop_seed_plot` | `1P` | vorbereitet/teilweise sichtbar | `west:path`, `south:path`, `east:expansion` |
| `hub_seed_south` | `(0, 2)` | `hub/market_seed` | `1-2P`, spaeter groesser | vorbereitet | `north:path`, `east:path`, `west:path`, `south:expansion` |
| `expansion_edge_se` | `(1, 1)` | `edge_plot` | `0.5-1P` | vorbereitet | `west:path`, `north:terrain`, `east:expansion`, `south:expansion` |

### Spaetere Expansion

| PlotId | Koordinate | Plottyp | Groesse | Status | Grund |
| --- | ---: | --- | --- | --- | --- |
| `neighbor_west` | `(-2, 0)` | `neighbor_home_plot` | `1P` | Expansion | Freunde/Nachbarschaft. |
| `market_square` | `(0, 3)` | `hub_plot` | `3-4P` | Expansion | Markt/Hub erst nach Starterinsel. |
| `nature_edge_nw` | `(-1, -1)` | `nature_plot` | `1P` | Expansion | Wald/Natur erweitert StarterCore. |
| `water_edge_east` | `(2, 0)` | `water_edge_plot` | `1-1.5P` | Expansion optional | Ufer/Hafen/Reisen spaeter. |
| `farm_southwest` | `(-1, 2)` | `farm_plot` | `2P` | Expansion | Landwirtschaft/Essen spaeter. |

### ASCII-Greybox

```text
              [nature_edge_nw] -- [nature_north] ---- [water_edge_east*]
                    |                  |                    |
[neighbor_west*] -- [garden_west] -- [starter_home] -- [function_seed_east]
                    |                  |                    |
              [farm_southwest*] -- [path_south] ----- [expansion_edge_se]
                                       |
                                [hub_seed_south]
                                       |
                                [market_square*]
```

`*` = spaetere Expansion, nicht Teil der sofort sichtbaren Starter-Insel.

## 8. Starter-Insel Und Erste Ausbauinsel

Sofort sichtbare Starter-Insel:

- `starter_home`
- `garden_west`
- `path_south`
- `nature_north`
- `function_seed_east`
- `hub_seed_south`
- `expansion_edge_se`
- mehrere `decoration_micro_plot` innerhalb/zwischen diesen Plots

Empfehlung:

```text
Starter-Insel sichtbar: 7 Hauptplots + Micro-Deko-Slots.
```

Erste Ausbauinsel:

- alle Starter-Plots,
- `neighbor_west`,
- `market_square`,
- `nature_edge_nw`,
- `water_edge_east` optional,
- `farm_southwest`,
- weitere Edge-/Expansion-Sockets.

Empfehlung:

```text
Erste Ausbauinsel: 12 bis 14 Hauptplots + Micro-Deko-Slots.
```

## 9. Erweiterungs-Andocken

Expansion-Regeln:

- Jede Expansion braucht einen vorhandenen `expansion_socket`.
- Expansion-Plots duerfen nicht direkt ein vorhandenes Gebaeude ueberdecken.
- Expansion muss Weg- oder Terrain-Kontinuitaet herstellen.
- `market_square` braucht mindestens einen `path_socket` vom `hub_seed_south`.
- `neighbor_west` braucht residential/path-Anschluss ueber `garden_west` oder
  einen separaten `path_connector`.
- `water_edge_east` darf nicht direkt an Wohnplots andocken, wenn kein
  `water_edge_plot` oder `dock_socket` dazwischenliegt.
- Organische Raender duerfen visuell variieren; funktionale Socket-Mitten
  bleiben kompatibel.

## 10. Naechste Messwerte

Der naechste Block soll konkretisieren:

- ob `P = 100 x 72gu` fuer Mobile-Island-View lesbar bleibt,
- wie `gu` in eine Preview-Canvas-Groesse uebersetzt wird,
- ob `starter_home_plot = 130 x 86gu` genug Hof/Weg/Randluft bietet,
- welche Socket-Mitten in einer visuellen Greybox markiert werden,
- ob `pathWidth = 16gu` bei mobiler Skalierung lesbar bleibt,
- ob `buildingFootprintRatio = 0.38` fuer Haus/Huette plausibel ist,
- wie gross die erste private Insel im Verhaeltnis zur aktuellen
  Waldlichtung werden muss,
- welche Plot-Koordinaten sofort sichtbar, vorbereitet oder verborgen sind.

## 11. Auswirkungen Auf `frame_started`

`frame_started` bleibt blockiert.

Es darf erst wieder geplant werden, wenn:

- `starter_home_plot` in einer Greybox visualisiert wurde,
- `building_footprint_polygon` in dieser Greybox bestaetigt ist,
- `path_entry_anchor` und Hofbereich nicht kollidieren,
- die Rohbau-Silhouette in `building_footprint_polygon` passt,
- `frame_started` nicht die gesamte `starter_home_plot`-Flaeche dominiert,
- ein erneuter Asset-Prompt auf diese Metriken verweist.

## 12. Stop-Regeln

Stoppen, wenn:

- ein neues Inselasset ohne Masterlayout erzeugt werden soll,
- ein neues Plot-Asset ohne Plotgroesse erzeugt werden soll,
- ein Gebaeudeasset ohne Gebaeude-Footprint erzeugt werden soll,
- ein Wegasset ohne Socket-Kompatibilitaet erzeugt werden soll,
- ein Dekoasset ohne Deko-Sicherheitszone erzeugt werden soll,
- `P` als finale Asset-Pixelgroesse behandelt wird,
- die aktuelle Waldlichtung wieder als vollstaendige Privatinsel behandelt
  wird,
- `frame_started` weitergebaut wird,
- Code geschrieben wird,
- PNGs veraendert oder neue Assets erzeugt werden.

## 13. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- `P` als logische Greybox-Einheit konkretisiert ist,
- vorlaeufige Plot-Metriken vorhanden sind,
- `starter_home_plot` / `StarterCorePlot` konkretisiert ist,
- eine Koordinaten-Greybox existiert,
- Starter- und Expansion-Plots getrennt sind,
- Socket-/Expansion-Regeln klar sind,
- naechste Messwerte definiert sind,
- Assets und Code weiterhin blockiert bleiben.

## 14. Naechster Erlaubter Schritt

Erlaubt ist als naechstes:

- eine Greybox-Skizze/Layout-Preview planen,
- oder die logischen Metriken gegen Mobile-Lesbarkeit und Inselkapazitaet
  pruefen.

Nicht erlaubt:

- neue Assets,
- neues Inselbild,
- `frame_started`,
- Bauzustands-Fortsetzung,
- Code,
- App-Integration,
- Tests,
- Persistenz,
- Supabase,
- SRS-/`word_progress`,
- Reward Bridge,
- Ressourcenlogik,
- Sound-/FX-Schicht,
- Expansion-System,
- PlacedItems,
- Interiors/ObjectDetail.
