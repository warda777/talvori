# Phase 2G-M1: Island Greybox Scale And Plot Metrics

Stand: 2026-06-05

Dieses Dokument startet Phase 2G-M1 als reinen Greybox-/Scale-/
Plot-Messblock fuer das Talvori-Waldlichtung-Masterlayout.

Fuehrende Dokumente:

- `docs/world_design/246-island-master-layout-and-modular-plot-system.md`
- `docs/world_design/245-build-alignment-and-anchor-system.md`
- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck

Dieses Dokument bereitet konkrete Mass-/Greybox-Regeln fuer die private
Talvori-Insel vor.

Es definiert:

- erste relative Plotgroessen,
- Mindestkapazitaet fuer eine sinnvolle Starter-Insel,
- langfristige Plot-Kapazitaet fuer die erste Ausbauinsel,
- Plot-Kompatibilitaet,
- Socket-Typen und Anschlussregeln,
- Rolle der aktuellen Waldlichtung als `StarterCorePlot`,
- naechste Messwerte fuer Greybox/Preview.

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

## 2. Research-Gate: Modular Level Metrics

Kurzer fokussierter Professional-Game-Development-Check:

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung |
| --- | --- | --- |
| Unity Grid beschreibt Cell Size, Cell Gap und isometrische Cell Layouts als Ausrichtungssystem fuer GameObjects: `https://docs.unity.cn/Manual/class-Grid.html` | Modulare Welten brauchen ein internes Koordinaten-/Zellensystem, auch wenn die finale Optik organisch ist. | Talvori nutzt relative Plot-Einheiten statt freier Pixelplatzierung. |
| Unity Tilemap beschreibt `Tile Anchor` und Tilemap-Orientierung: `https://docs.unity.cn/Manual/class-Tilemap.html` | Jede Plot-Flaeche braucht lokale Anchor-Positionen und eindeutige Ausrichtung. | Jeder Plot bekommt `plot_center`, Side-Sockets und lokale Build-/Path-/Deko-Anker. |
| Unity Snaps/ProBuilder beschreibt modulare Prototype-Assets, die auf Grid/Snapping ausgelegt sind und spaeter durch detaillierte Art ersetzt werden koennen: `https://unity.com/blog/games/customizing-snaps-prototype-assets-with-probuilder-2` | Professionelle Teams pruefen erst Blockout/Metriken, bevor finale Assets entstehen. | Phase 2G-M1 bleibt Greybox-/Metric-Planung, nicht Asset-Produktion. |
| Unreal Static Mesh Sockets zeigen benannte Attachment Points fuer genaue Anschluesse: `https://dev.epicgames.com/documentation/en-us/unreal-engine/using-sockets-with-static-meshes-in-unreal-engine` | Anschluesse brauchen Namen, Richtung und Kompatibilitaet. | Talvori definiert Socket-Typen wie `path_socket`, `residential_socket` und `expansion_socket`. |
| Talvori `245` zeigt, dass Anchor- und Footprint-Pruefung fuer Bauzustaende Pflicht ist. | Plot-Metriken muessen vor Bauassets kommen, sonst entstehen erneut unpassende Einzelbilder. | `frame_started` bleibt gestoppt, bis `starter_home_plot` und seine Metriken definiert sind. |

Risiken:

- Zu starre Plot-Metriken koennen die Waldlichtung wie ein Brettspielraster
  wirken lassen.
- Zu weiche Metriken fuehren erneut zu Asset-Passung nach Augenmass.
- Zu kleine Plots erzwingen spaeter unplausible Haus-/Weg-/Gartenmasstaebe.

Talvori-Entscheidung:

- Intern wird mit relativen Plot-Einheiten und kompatiblen Sockets geplant.
- Die sichtbaren Plotraender duerfen organisch ueberzeichnet werden.
- Funktionale Anchors, Footprints und Socket-Linien bleiben trotzdem stabil.

Erlaubt dadurch:

- Masterlayout-Greybox,
- Plot-Metrik-Block,
- spaetere Layout-Preview ohne finale Assets.

Blockiert bleibt:

- neue Assets,
- `frame_started`,
- Code,
- App-Integration,
- Tests,
- Persistenz/Supabase/SRS/Reward/Ressourcen.

## 3. Relatives Plot-Masssystem

Phase 2G-M1 verwendet vorlaeufig eine relative Einheit:

```text
P = Standard-Plot-Einheit
```

`P` ist noch kein finaler Pixelwert. Es beschreibt nur Verhaeltnisse.

Vorlaeufige Regel:

- `medium_plot = 1.0 P`
- `small_plot = 0.5 P`
- `micro_plot = 0.25 P`
- `large_plot = 2.0 P`
- `hub_plot = 3.0 bis 4.0 P`
- `edge_plot = 0.5 bis 1.5 P`, je nach Rand-/Connector-Funktion

Diese Werte sind Greybox-Werte. Der naechste Messblock muss entscheiden, wie
`P` im Island-View-Canvas, in Bildschirmgroesse und in lesbarer mobiler Ansicht
abgebildet wird.

## 4. Plotgroessen

### `micro_plot`

- Zweck: kleines Objekt, Deko, Mini-Fokus, einzelner Baum/Stein/Blume.
- Relative Groesse: ca. `0.25 P`.
- Typische Nutzung: Deko-Luecke, Lichtpunkt, kleiner Lerngegenstand.
- Gebaeude moeglich: nein.
- Wege moeglich: nein, nur Randkontakt.
- Deko moeglich: ja.
- Mehrere Anchors noetig: selten; meist 1 bis 2.
- Innenraeume spaeter moeglich: nein.

### `small_plot`

- Zweck: Garten, Hofteil, kleiner Naturbereich, Pfadkurve, kleiner Anschluss.
- Relative Groesse: ca. `0.5 P`.
- Typische Nutzung: `garden_plot`, kleiner `nature_plot`, Path-Segment.
- Gebaeude moeglich: nur micro/small optional spaeter, kein Hauptgebaeude.
- Wege moeglich: ja.
- Deko moeglich: ja.
- Mehrere Anchors noetig: ja, mindestens Path/Deko.
- Innenraeume spaeter moeglich: nein.

### `medium_plot`

- Zweck: Standard-Grundstueck fuer ein kleines Gebaeude plus Randluft.
- Relative Groesse: `1.0 P`.
- Typische Nutzung: `starter_home_plot`, `shop_plot`, `workshop_plot`,
  `neighbor_home_plot`.
- Gebaeude moeglich: ja, `building_small`.
- Wege moeglich: ja, mindestens ein Eingang.
- Deko moeglich: ja, aber nicht im Gebaeude-Footprint.
- Mehrere Anchors noetig: ja, Build/Path/FrontYard/BackYard/Deko.
- Innenraeume spaeter moeglich: ja, wenn ein Gebaeude entsteht.

### `large_plot`

- Zweck: groesserer Funktionsbereich oder kombiniertes Grundstueck.
- Relative Groesse: ca. `2.0 P`.
- Typische Nutzung: Farm, groesserer Naturbereich, kleiner Marktrand,
  spaetere Kategoriezone.
- Gebaeude moeglich: ja, aber nicht zwingend.
- Wege moeglich: ja, mehrere.
- Deko moeglich: ja.
- Mehrere Anchors noetig: ja, mehrere Build-/Deko-/Path-Anker.
- Innenraeume spaeter moeglich: nur fuer enthaltene Gebaeude.

### `hub_plot`

- Zweck: zentraler Knoten fuer Wege, Markt, Dorfplatz, soziale Sichtbarkeit.
- Relative Groesse: ca. `3.0 bis 4.0 P`.
- Typische Nutzung: `market_square_plot`, zentrale Kreuzung,
  spaeter Bibliothek/Markt/Quest-Knoten.
- Gebaeude moeglich: ja, aber erst mit klarer Unterteilung.
- Wege moeglich: ja, mehrere Richtungen.
- Deko moeglich: ja, aber nicht so, dass Wege blockiert werden.
- Mehrere Anchors noetig: ja, viele.
- Innenraeume spaeter moeglich: ja fuer einzelne Gebaeude, nicht fuer den Hub
  selbst.

### `edge_plot`

- Zweck: Rand, Docking, Expansion, Wasser-/Fels-/Brueckenuebergang.
- Relative Groesse: ca. `0.5 bis 1.5 P`.
- Typische Nutzung: `water_edge_plot`, `expansion_socket`, Docking-Kante.
- Gebaeude moeglich: nur Sonderfaelle spaeter.
- Wege moeglich: ja, besonders Uebergang/Connector.
- Deko moeglich: ja, randgebunden.
- Mehrere Anchors noetig: ja, Socket/Expansion/Deko.
- Innenraeume spaeter moeglich: nein.

## 5. Mindestkapazitaet Der Privaten Insel

Eine sinnvolle private Starter-Insel darf nicht nur ein Haus tragen.

Mindestkapazitaet fuer die erste sinnvolle Starter-Insel:

- `1 x starter_home_plot` (`medium_plot`)
- `1 x garden_plot` (`small_plot` oder `medium_plot`)
- `2 x path_connector_plot` (`small_plot`)
- `1 x nature_plot` (`small_plot` bis `medium_plot`)
- `1 x function_plot` fuer Versorgung/Shop/Werkstatt spaeter (`medium_plot`)
- `1 x expansion_edge_plot` (`edge_plot`)
- `1 x decoration_micro_cluster` (mehrere `micro_plot`)

Empfehlung:

```text
Starter-Insel Minimum: 7 bis 8 funktionale Plot-Slots
```

Langfristige erste Ausbauinsel:

- 1 Starter-Hausgrundstueck
- 1 bis 2 Garten-/Hofplots
- 3 bis 4 Path-/Connector-Plots
- 1 bis 2 Nachbar-/Erweiterungsplots
- 1 Natur-/Freizeitplot
- 1 kleiner Funktions-/Versorgungsplot
- 1 Markt-/Hub-Vorbereitung
- 2 bis 3 Edge-/Expansion-Plots
- mehrere Micro-Deko-Slots

Empfehlung:

```text
Erste Ausbauinsel: 12 bis 16 funktionale Plot-Slots
```

Zonen, die nicht sofort sichtbar sein muessen, aber im Layout vorbereitet
werden sollen:

- Nachbarschaft,
- Markt/Hub,
- Wasser/Hafen,
- Farm/Natur-Erweiterung,
- weitere Kategoriegebaeude,
- Social-/Showcase-Kante,
- Connector zu spaeteren Inselmodulen.

## 6. Bewertung Der Aktuellen Waldlichtung Als `StarterCorePlot`

Rolle:

- erster sichtbarer Kern der privaten Insel,
- erster Bauplatz fuer `empty -> foundation_started -> foundation_complete`,
- emotionaler Startpunkt,
- nicht die vollstaendige private Insel.

Erlaubt auf der aktuellen Waldlichtung:

- ein erstes Startgebaeude-Footprint,
- kleines Fundament/BuildAreaState,
- sehr begrenzter Hof-/Vorplatz,
- dezente Deko/Natur am Rand,
- ein bis zwei vorbereitete Anschlussrichtungen.

Nicht mehr darauf planen:

- komplette Nachbarschaft,
- Markt/Hub,
- mehrere Gebaeude,
- Farm,
- Wasser/Hafen,
- grosses Wegnetz,
- PlacedItem-System,
- vollstaendige Privatinsel-Landschaft.

Entscheidung:

- Die aktuelle Waldlichtung stellt nur das erste Hausgrundstueck dar.
- Sie wird spaeter in eine groessere Inselstruktur eingebettet.
- Anschluesse koennen ueber offene Randstellen als `expansion_socket_*` oder
  `path_socket` vorbereitet werden.
- Der spaetere `starter_home_plot` muss definieren, welcher Teil dieser
  Waldlichtung wirklich BuildFootprint, Hof, Weg und Randzone ist.

## 7. Plot-Socket-Regeln

Jeder Plot hat mindestens:

- `north_socket`
- `east_socket`
- `south_socket`
- `west_socket`

Optional:

- `diagonal_socket_ne`
- `diagonal_socket_se`
- `diagonal_socket_sw`
- `diagonal_socket_nw`

### Socket-Typen

- `path_socket`: Weganschluss.
- `terrain_socket`: normale Land-/Gras-/Felskante.
- `water_socket`: Wasser-/Uferanschluss.
- `market_socket`: Platz-/Markt-/Hub-Anschluss.
- `residential_socket`: Wohn-/Hausgrundstueck-Anschluss.
- `nature_socket`: Wald-/Naturanschluss.
- `expansion_socket`: spaeterer Erweiterungsanschluss.

### Kompatibilitaet

| Socket | Kompatibel Mit | Regel |
| --- | --- | --- |
| `path_socket` | `path_socket`, `residential_socket`, `market_socket`, `nature_socket`, `expansion_socket` | Wege duerfen verbinden, wenn Wegbreite und Richtung passen. |
| `terrain_socket` | `terrain_socket`, `nature_socket`, `residential_socket`, `expansion_socket` | Organische Landkanten duerfen anschliessen, wenn Hoehe/Plateau passt. |
| `water_socket` | `water_socket`, `expansion_socket`, spezieller `dock_socket` spaeter | Kein direkter Wohn-/Marktanschluss ohne Ufer-/Dock-Plot. |
| `market_socket` | `market_socket`, `path_socket`, `shop_socket` spaeter | Markt braucht Wege oder kompatible Markt-/Shop-Kante. |
| `residential_socket` | `path_socket`, `terrain_socket`, `residential_socket`, `garden_socket` spaeter | Wohnplots brauchen Zugang und Randluft. |
| `nature_socket` | `nature_socket`, `terrain_socket`, `path_socket` | Natur darf Wege beruehren, aber Hauptwege nicht blockieren. |
| `expansion_socket` | `path_socket`, `terrain_socket`, `residential_socket`, `nature_socket`, `water_socket` | Expansion braucht klaren Zieltyp beim Freischalten. |

Verbotene Kombinationen:

- `water_socket` direkt an `residential_socket` ohne `water_edge_plot`.
- `market_socket` direkt an `nature_socket` ohne `path_connector_plot` oder
  Uebergang.
- `path_socket` an inkompatible Hoehen-/Klippenkante.
- `building_anchor` direkt auf Plotgrenze oder Socket-Linie.
- Dekoanker auf Socket-Mitte.

Weg-Regeln:

- Wege muessen ueber kompatible `path_socket` ueber Plotgrenzen laufen.
- Wegbreite muss ueber die Grenze konsistent bleiben.
- Wegmitte muss auf beiden Plots denselben Anschluss treffen.
- Organische Wegraender duerfen variieren, aber die funktionale
  Socket-Linie bleibt stabil.

## 8. Erste Grobe Masterlayout-Struktur

Text-Greybox, nicht final:

```text
[nature_edge] ---- [garden_plot] ---- [expansion_edge]
      |                  |                   |
[path_connector] -- [starter_home] -- [path_connector]
      |                  |                   |
[neighbor_future] -- [hub/market_seed] -- [function_plot]
                         |
                  [expansion_edge]
```

Interpretation:

- `starter_home` ist das aktuelle `StarterCorePlot`.
- `garden_plot` gibt Hof/Natur-Luft.
- `path_connector` links/rechts verhindert isolierte Einzelplots.
- `hub/market_seed` ist nur Vorbereitung, nicht sofort sichtbar.
- `neighbor_future` und `function_plot` koennen spaeter freigeschaltet werden.
- `expansion_edge` haelt Rand-/Connector-Wachstum offen.

Noch nicht final:

- genaue Form,
- Pixelwerte,
- Inselbild,
- Assetpfade,
- Runtime-Daten.

## 9. Naechste Konkrete Messwerte

Der naechste Block muss konkret definieren:

- `standardPlotMeasure` fuer `P`,
- `starterCorePlotMeasure`,
- `socketSpacing`,
- `pathWidth`,
- `minBuildingToPlotEdgeDistance`,
- `minBuildingToPathDistance`,
- `decorationSafetyZone`,
- `maxBuildingHeightInIslandView`,
- `minReadableObjectSizeMobile`,
- `islandSizeToPlotCountRatio`,
- `starterIslandMinPlotCount`,
- `firstExpansionIslandTargetPlotCount`,
- `plotHeightLayer` / Hoehenversatz fuer Plateau- oder Uferplots,
- Debug-Greybox-Preview-Regeln.

Keine finalen Pixelwerte werden in diesem Dokument erzwungen. Pixelwerte
werden erst gesetzt, wenn eine Greybox/Preview-Methode dafuer definiert ist.

## 10. Auswirkungen Auf Phase 2G

`frame_started` bleibt gestoppt.

Es darf erst wieder aufgegriffen werden, wenn:

- `starter_home_plot` im Masterlayout definiert ist,
- die Plotgroesse feststeht,
- das `building_footprint_polygon` feststeht,
- Socket- und Weganschluesse des Plots bekannt sind,
- klar ist, wie Haus, Hof, Weg, Deko und Expansion nebeneinander Platz haben,
- Anchor-/Footprint-Regeln aus `245` angewendet werden koennen.

## 11. Stop-Regeln

Stoppen, wenn:

- ein neues Inselasset ohne Masterlayout erzeugt werden soll,
- ein neues Plot-Asset ohne Plotgroesse erzeugt werden soll,
- ein Gebaeudeasset ohne Gebaeude-Footprint erzeugt werden soll,
- ein Wegasset ohne Socket-Kompatibilitaet erzeugt werden soll,
- ein Dekoasset ohne Deko-Sicherheitszone erzeugt werden soll,
- eine Insel als vollstaendige Privatinsel behandelt wird, obwohl sie nur
  `StarterCorePlot` ist,
- `frame_started` weitergebaut werden soll, bevor `starter_home_plot` im
  Masterlayout definiert ist,
- Code geschrieben wird,
- PNGs veraendert oder neue Assets erzeugt werden.

## 12. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- Plotgroessen relativ definiert sind,
- Mindestkapazitaet der privaten Insel klar ist,
- die aktuelle Waldlichtung eindeutig als `StarterCorePlot` bewertet ist,
- Socket-Typen und Kompatibilitaeten beschrieben sind,
- eine erste Greybox-Struktur existiert,
- konkrete naechste Messwerte definiert sind,
- `frame_started` weiterhin blockiert bleibt.

## 13. Naechster Erlaubter Schritt

Erlaubt ist als naechstes:

- konkrete Plot-Metriken festlegen,
- oder eine Greybox-Skizze / Layout-Preview planen.

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
