# Talvori Waldlichtung: Island Master Layout And Modular Plot System

Stand: 2026-06-05

Dieses Dokument stoppt Phase 2G `frame_started` vorerst vollstaendig und
startet stattdessen einen reinen Planungsblock fuer das
Talvori-Waldlichtung-Masterlayout.

Fuehrende Dokumente:

- `docs/world_design/235-world-production-roadmap-and-checklists.md`
- `docs/world_design/239-world-scale-and-dimension-rules.md`
- `docs/world_design/240-private-island-state-system.md`
- `docs/world_design/245-build-alignment-and-anchor-system.md`
- `assets/images/world/buildable_islands/forest_clearing/template.md`

## 1. Zweck

Talvori braucht vor weiteren Bauassets ein Insel-Masterlayout.

Dieses Dokument klaert:

- wie die Waldlichtung als private Insel grundsaetzlich gedacht wird,
- welche modularen Grundstuecks-/Plot-Flaechen sie tragen muss,
- wie Plots miteinander verbunden werden,
- welche Anchors und Sockets jedes Plot braucht,
- wie Wege, Gebaeude, Deko, Natur, Zaun, Expansion und spaetere Kategorien
  zusammenpassen,
- warum `frame_started` erst wieder aufgegriffen werden darf, wenn sein Plot,
  seine Anchors und sein Footprint im Gesamtsystem definiert sind.

Nicht-Ziel:

- kein Flutter-/Dart-Code,
- keine App-Integration,
- keine Tests,
- keine Asset-Erzeugung,
- keine PNG-Aenderung,
- keine Bauzustands-Fortsetzung,
- keine Freigabe von `frame_started`,
- kein Commit.

## 2. Research-Gate: Modular Kits, Grid, Snap, Pivot, Anchor, Socket

Kurzer fokussierter Professional-Game-Development-Check:

| Quelle / Orientierung | Ableitung fuer Talvori | Entscheidung |
| --- | --- | --- |
| Unity Grid dokumentiert Zellgroessen, Zellabstaende und isometrische Layouts als Ausrichtungshilfe fuer GameObjects: `https://docs.unity.cn/Manual/class-Grid.html` | Professionelle Layouts brauchen ein lokales Raster oder ein vergleichbares Bezugssystem, damit Teile nicht nach Augenmass platziert werden. | Talvori definiert ein Plot-Raster/Plot-System, auch wenn die finale Optik organisch bleibt. |
| Unity Tilemap dokumentiert `Tile Anchor` als definierte Anchor-Position innerhalb einer Zelle: `https://docs.unity.cn/Manual/class-Tilemap.html` | Jedes Plot braucht lokale Anchor-Positionen fuer Platzierung, Wege und Anschluesse. | Talvori-Plots bekommen `plot_center`, Sockets, BuildAnchors, PathAnchors und DecorationAnchors. |
| Unity Snaps/ProBuilder beschreibt modulare Prototype-Assets, die auf Grid/Snapping ausgelegt sind und spaeter durch High-Detail-Art ersetzt werden koennen: `https://unity.com/blog/games/customizing-snaps-prototype-assets-with-probuilder-2` | Erst Blockout/Kit-Regeln, dann hochwertige Assets. So werden spaetere Teile austauschbar. | Waldlichtung braucht ein Masterlayout/Plot-Kit, bevor weitere finale Bauzustands-Assets entstehen. |
| Unreal Sockets werden als benannte Attachment Points fuer Objekte/Meshes genutzt: `https://dev.epicgames.com/documentation/en-us/unreal-engine/using-sockets-with-static-meshes-in-unreal-engine` | Anschluesse muessen benannt und pruefbar sein, statt nur visuell passend zu wirken. | Talvori nutzt `ConnectionSockets`, `ExpansionSockets` und Build-/Path-/Deko-Anker. |
| `docs/world_design/245-build-alignment-and-anchor-system.md` zeigt, dass reine Zentrumsausrichtung fuer `frame_started` nicht reicht. | Einzelne Bauzustands-Assets sind zu spaet im Prozess, wenn Plot und Footprint nicht vorher geklaert sind. | Phase 2G wird gestoppt; zuerst wird das Insel-Masterlayout definiert. |

Risiko:

- Ein zu starres Raster kann die natuerliche Waldlichtung kuenstlich wirken
  lassen.
- Ein zu freies organisches Layout macht spaetere Assets inkompatibel.

Talvori-Entscheidung:

- Intern wird modular, anchor- und socketbasiert geplant.
- Visuell darf die Insel organisch bleiben.
- Plots muessen regelbasiert anschliessen, auch wenn ihre Gras-/Felsraender
  natuerlich variieren.

Erlaubt dadurch:

- Planung von Plot-Typen, Sockets, Anchors und Footprints.
- Spaetere Greybox-/Blockout-Skizzen fuer Inselgroesse und Plot-Anordnung.

Blockiert bleibt:

- `frame_started`-Freigabe,
- neue Bauassets,
- App-Code,
- Expansion-, PlacedItem-, Interior-, Reward-, Ressourcen- oder
  Persistenzsysteme.

## 3. Grundsatzentscheidung

Die Waldlichtung wird nicht weiter als einzelnes frei bebautes Bild betrachtet.

Sie wird geplant als:

- `IslandMasterLayout`
- mehrere modulare `PlotTiles` / Grundstuecksflaechen
- `ConnectionSockets`
- `BuildAnchors`
- `PathAnchors`
- `DecorationAnchors`
- `ZoneAnchors`
- `ExpansionSockets`
- definierte `FootprintPolygons`

Regel:

> Kein neues Bauasset ohne Plot-Typ, Anchor, Footprint und Anschlusslogik.

Die einzelnen Grundstuecke sollen spaeter regelbasiert kombinierbar sein. Sie
brauchen an allen relevanten Seiten Anschluss-/Socket-Punkte, damit Wege,
Zaunsegmente, Erweiterungen, Nachbarplots und Kategoriegebaeude sauber
andocken koennen.

## 4. Waldlichtung Neu Bewertet

Die aktuelle Waldlichtung ist als erster lokaler Proof-of-Concept wertvoll:

- `base.png` zeigt einen glaubwuerdigen Island-View-Core.
- `foundation_started` und `foundation_complete` beweisen einfaches Layering.
- Die zentrale `main_build_area` funktioniert als erster Bauplatz.

Aber:

- Die aktuelle Waldlichtung ist fuer eine vollstaendige Architekturlandschaft
  zu klein, wenn sie Haus, Garten, Wege, Nachbarschaft, Markt, Natur,
  Erweiterungen, Kategorien und spaetere soziale Inselzonen gleichzeitig tragen
  soll.
- Die aktuelle Insel kann als Starter-Kern bleiben, aber nicht als komplette
  langfristige Privatinsel verstanden werden.
- Der `frame_started`-Fehler zeigt, dass Einzelzustands-Assets ohne
  Gesamt-Layout zu frueh entstehen.

Entscheidung:

- Die aktuelle Waldlichtung gilt ab jetzt als `StarterCorePlot`.
- Eine groessere private Insel wird als erweiterbare Struktur aus mehreren
  Plots geplant.
- `StarterCorePlot` kann spaeter Teil des `IslandMasterLayout` sein, aber ist
  nicht die ganze Insel.

## 5. Zielbild: Hauptzonen Einer Vollstaendigen Inselstruktur

Talvori plant zuerst Zonen und Plot-Typen, nicht einzelne fertige Gebaeude.

Sinnvolle Hauptzonen:

- Wohnbereich
- Hausgrundstueck / Garten
- Wege und Verbindungen
- Nachbarschaft / weitere Grundstuecke
- Dorf-/Marktbereich
- Versorgung
- Freizeit/Natur
- Arbeit/Gewerbe
- Landwirtschaft
- Wasser/Hafen optional
- Deko-/Lebendigkeitsobjekte
- Erweiterungs- und Randzonen

Nicht jede Zone wird sofort gebaut. Die Zonen dienen als Zukunftssicherheit
fuer Plot-Groessen, Anschluesse und Kategorievarianten.

## 6. Plot-/Grundstueckssystem

### `starter_home_plot`

- Zweck: erstes Haus/Huette, erster Baufortschritt, Startidentitaet.
- Relative Groesse: medium, groesser als aktueller reiner Fundamentbereich.
- Anschluesse: mindestens `north_socket`, `east_socket`, `south_socket`,
  `west_socket`.
- Sockets: alle vier Hauptseiten; diagonal optional.
- Bauanker: `building_anchor`, `front_yard_anchor`, `back_yard_anchor`.
- Dekoanker: kleine Randanker fuer Steine, Blumen, Gras, Baumstumpf.
- Weganker: `path_entry_anchor`, `path_exit_anchor`.
- Gebaeude erlaubt: ja, `building_small`.
- Innenraum spaeter moeglich: ja.
- Kategorie: neutral, muss spaeter Varianten tragen koennen.

### `garden_plot`

- Zweck: Hof, Garten, kleine Natur-/Lernobjekte, spaeter Kategorie-Deko.
- Relative Groesse: small bis medium.
- Anschluesse: mindestens zwei path-kompatible Seiten.
- Sockets: `north_socket`, `south_socket` oder passend zum Nachbarplot.
- Bauanker: keine grossen Gebaeude; optional kleiner Schuppen spaeter.
- Dekoanker: mehrere `decoration_anchor_*`, `tree_anchor_*`.
- Weganker: ein Hauptweganker plus kleine Nebenanker.
- Gebaeude erlaubt: nur micro/small optional spaeter.
- Innenraum spaeter moeglich: nein.
- Kategorie: neutral, spaeter thematisch dekorierbar.

### `path_connector_plot`

- Zweck: verbindet Plots, fuehrt Nutzer visuell durch die Insel.
- Relative Groesse: narrow/small.
- Anschluesse: mindestens zwei kompatible `path_socket`.
- Sockets: je nach Variante gerade, Kurve, T-Stueck, Kreuzung.
- Bauanker: nein.
- Dekoanker: nur Randdeko.
- Weganker: `path_entry_anchor`, `path_exit_anchor`, optional
  `path_mid_anchor`.
- Gebaeude erlaubt: nein.
- Innenraum spaeter moeglich: nein.
- Kategorie: neutral.

### `neighbor_home_plot`

- Zweck: spaetere Freunde/Nachbarschaft/Showcase.
- Relative Groesse: medium.
- Anschluesse: Wege, Rand/Connector, optional Social-Socket.
- Sockets: alle Hauptseiten, mindestens zwei offen.
- Bauanker: `building_anchor`, Hofanker.
- Dekoanker: personalisierbare Randanker.
- Weganker: Eingang zum Nachbarschaftspfad.
- Gebaeude erlaubt: ja.
- Innenraum spaeter moeglich: ja, aber erst nach Social-Konzept.
- Kategorie: neutral/personalisierbar.

### `market_square_plot`

- Zweck: Dorf-/Marktbereich, spaeter Shop/Markt/Bibliothek/Quest-Knoten.
- Relative Groesse: large.
- Anschluesse: mehrere Wege, spaeter Dorf-/Community-Anschluss.
- Sockets: alle Hauptseiten plus optionale diagonale Marktplatzanschluesse.
- Bauanker: mehrere kleine/medium Anchors, aber nicht alle sofort aktiv.
- Dekoanker: Brunnen, Bank, Schild, Lichtpunkt spaeter.
- Weganker: Kreuzung/Platzmitte.
- Gebaeude erlaubt: ja, aber erst spaeter.
- Innenraum spaeter moeglich: ja fuer einzelne Gebaeude.
- Kategorie: muss stark category-neutral bleiben.

### `shop_plot`

- Zweck: einzelnes kleines Geschaeft, Marktstand, Kategoriegebaeude.
- Relative Groesse: medium.
- Anschluesse: Vorderseite an Weg/Marktplatz, Rueckseite optional.
- Sockets: mindestens front/back plus seitliche Erweiterung.
- Bauanker: `building_anchor`.
- Dekoanker: Schild/kleine Waren nur spaeter.
- Weganker: `path_entry_anchor` vor Eingang.
- Gebaeude erlaubt: ja.
- Innenraum spaeter moeglich: optional.
- Kategorie: ja, muss Varianten tragen koennen.

### `nature_plot`

- Zweck: Wald, Teich, Felsen, Ruhezone, spaeter Naturobjekte.
- Relative Groesse: small bis large.
- Anschluesse: flexible Rand-/Wegeanschluesse.
- Sockets: mindestens ein bis zwei Pfadanschluesse.
- Bauanker: nein oder nur micro.
- Dekoanker: viele `tree_anchor_*`, Stein-/Blumenanker.
- Weganker: optionaler Naturpfad.
- Gebaeude erlaubt: nein.
- Innenraum spaeter moeglich: nein.
- Kategorie: neutral, kann spaeter Lernobjekte aufnehmen.

### `farm_plot`

- Zweck: Landwirtschaft, Ernte-/Wachstumsfantasie, spaeter Ressourcen-Metapher.
- Relative Groesse: medium bis large.
- Anschluesse: Weg plus optional Wasser-/Versorgungsanschluss.
- Sockets: alle Hauptseiten moeglich.
- Bauanker: kleiner Schuppen optional spaeter.
- Dekoanker: Beete, Baeume, Zaun.
- Weganker: Zugang und Feldrand.
- Gebaeude erlaubt: small optional.
- Innenraum spaeter moeglich: nur bei Gebaeude.
- Kategorie: neutral, spaeter fuer Essen/Natur nutzbar.

### `workshop_plot`

- Zweck: Werkstatt, Technik, Handwerk, spaeter Kategoriearbeit.
- Relative Groesse: medium.
- Anschluesse: Weg, optional Markt/Nachbarschaft.
- Sockets: front/back/side.
- Bauanker: `building_anchor`.
- Dekoanker: spaeter Werkbank/Kisten nur als PlacedItems, nicht im Baseplot.
- Weganker: Eingang.
- Gebaeude erlaubt: ja.
- Innenraum spaeter moeglich: ja.
- Kategorie: muss Varianten fuer Technik/Business/Alltag tragen koennen.

### `water_edge_plot`

- Zweck: Wasser/Hafen optional, Randuebergang, spaeter Reisen/Connector.
- Relative Groesse: medium bis large.
- Anschluesse: Landseite plus Wasser-/Dockingseite.
- Sockets: landseitig path-kompatibel, wasserseitig `docking_socket`.
- Bauanker: kein Haus; optional Steg spaeter.
- Dekoanker: Schilf, Steine, Uferpflanzen.
- Weganker: Uferpfad.
- Gebaeude erlaubt: spaeter nur spezielle Varianten.
- Innenraum spaeter moeglich: nein.
- Kategorie: neutral, spaeter Reisen/Kultur moeglich.

### `decoration_micro_plot`

- Zweck: kleine Lebendigkeitsobjekte, Lueckenfueller, Fokusmomente.
- Relative Groesse: micro.
- Anschluesse: sitzt an Plot-Rand oder Wegkante.
- Sockets: optional, meist Elternplot-gebunden.
- Bauanker: nein.
- Dekoanker: ein Objekt oder kleine Gruppe.
- Weganker: nein.
- Gebaeude erlaubt: nein.
- Innenraum spaeter moeglich: nein.
- Kategorie: neutral oder leicht thematisch, aber nie architekturtragend.

## 7. Anchor-/Socket-System Fuer Grundstuecke

Jeder Plot braucht mindestens:

- `plot_center`
- `north_socket`
- `east_socket`
- `south_socket`
- `west_socket`
- optional `diagonal_socket_ne`
- optional `diagonal_socket_se`
- optional `diagonal_socket_sw`
- optional `diagonal_socket_nw`
- `path_entry_anchor`
- `path_exit_anchor`
- `building_anchor`
- `front_yard_anchor`
- `back_yard_anchor`
- `decoration_anchor_*`
- `tree_anchor_*`
- `fence_anchor_*`
- `expansion_socket_*`
- `building_footprint_polygon`
- `path_footprint_polygon`
- `decoration_safe_area`

Regeln:

- Gebaeude duerfen nur auf `building_anchor` oder innerhalb eines definierten
  `building_footprint_polygon` stehen.
- Wege duerfen nur ueber kompatible `path_socket` verbunden werden.
- Zaunsegmente duerfen nur auf `fence_anchor_*` oder Fence-Kanten sitzen.
- Baeume duerfen nicht in `path_footprint_polygon` oder
  `building_footprint_polygon` ragen.
- Deko darf Hauptwege, Eingangsanker und BuildFootprints nicht blockieren.
- Grundstuecke muessen sauber an andere Grundstuecke anschliessen.
- Kein Asset darf frei geraten oder nur nach Augenmass platziert werden.
- Vor Asset-Erzeugung muss klar sein, auf welchem Plot und welchem Anchor das
  Asset sitzt.

## 8. Groessen-/Skalierungsentscheidung Fuer Den Naechsten Block

Vor weiteren Assets muss konkret geplant werden:

- Wie viele Plots soll eine Starter-Insel mindestens tragen?
- Welche Plot-Groesse ist Standard?
- Wie viele Plot-Groessen gibt es?
- Welche maximale Gebaeudegroesse passt in Island View?
- Wie gross muss `starter_home_plot` sein, damit Haus, Hof und Weg plausibel
  bleiben?
- Welche Sockets muessen einander geometrisch treffen?
- Wie werden spaetere Insel-Erweiterungen angeschlossen?
- Wann wird die aktuelle Waldlichtung als Core erweitert statt ersetzt?

Noch nicht festlegen:

- keine finalen Pixelwerte fuer alle Plottypen,
- keine finalen Inselabmessungen,
- keine neuen Assetpfade,
- keine Runtime-Datenstruktur.

Naechster Mess-/Planungsblock muss definieren:

- Plot-Raster oder Plot-Koordinatensystem,
- Standard-Plotgroesse in relativen Einheiten,
- StarterCorePlot-Groesse,
- minimale private Inselkapazitaet,
- Socket-Kompatibilitaetsregeln,
- Debug-Greybox fuer Plot-Anordnung.

## 9. Auswirkungen Auf `frame_started`

Phase 2G `frame_started` bleibt vollstaendig gestoppt.

`frame_started` darf erst wieder aufgegriffen werden, wenn klar ist:

- auf welchem Plot es sitzt,
- ob dieser Plot `starter_home_plot` oder ein anderer Plot-Typ ist,
- welche Anchorpunkte es nutzt,
- welche Footprint-Grenzen gelten,
- wie Hof, Weg, Zaun, Garten und spaetere Expansion daneben Platz behalten,
- wie der Rohbau in die gesamte Inselstruktur passt.

Der aktuelle `frame_started.png`-Kandidat wurde nicht freigegeben und soll
nicht committed werden.

## 10. Stop-Regeln

Stoppen, wenn:

- ein neues Bauasset ohne Plot-Typ erzeugt werden soll,
- ein neues Bauasset ohne Anchor erzeugt werden soll,
- ein neues Bauasset ohne Footprint erzeugt werden soll,
- ein neues Bauasset ohne Anschluss-/Socket-Konzept erzeugt werden soll,
  obwohl es mit Wegen oder Grundstuecken verbunden wird,
- die Inselgroesse fuer die geplante Landschaft nicht reicht,
- Einzelassets nur nach Augenmass erzeugt werden,
- `frame_started` weitergebaut werden soll, bevor das Masterlayout geklaert
  ist,
- Kategorien hart codiert werden,
- Code geschrieben wird,
- PNGs veraendert oder neue Assets erzeugt werden.

## 11. Akzeptanzkriterien

Dieses Dokument ist gut, wenn:

- die Waldlichtung als `StarterCorePlot` statt als komplette Insel bewertet
  ist,
- ein modulares Plot-System beschrieben ist,
- erste Plot-Typen mit Zweck, Groesse, Anschluessen und Ankern definiert sind,
- Anchor-/Socket-Regeln fuer Grundstuecke klar sind,
- klar ist, warum `frame_started` gestoppt bleibt,
- der naechste Schritt ein Masterlayout-/Greybox-Block ist, nicht Asset oder
  Code,
- groessere Systeme weiterhin blockiert bleiben.

## 12. Naechster Erlaubter Schritt

Erlaubt ist als naechstes:

- ein Greybox-/Masterlayout-Block fuer Plot-Anordnung,
- oder ein Mess-/Scale-Block fuer Standard-Plotgroessen und
  Socket-Kompatibilitaet.

Nicht erlaubt:

- `frame_started` weiterbauen,
- neues Bauasset erzeugen,
- App-Code,
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
