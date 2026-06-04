# Talvori Welt: Professional Game Architecture Research

Stand: 2026-06-03

Dieses Dokument fasst Architekturprinzipien professioneller 2D-, 2.5D-,
isometrischer und City-Builder-Welten zusammen und leitet daraus Anforderungen
fuer Talvori Welt ab.

Es ist ein reines Recherche- und Ableitungsdokument. Es wurden keine
Dart-/Flutter-Dateien, keine Assets, keine Supabase-Daten, keine
SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward
Bridge, keine Persistenz, keine Secrets und keine Release-Artefakte geaendert.

Orientierende Quellen:

- Tiled Map Editor: Layer und Custom Properties
  - https://doc.mapeditor.org/en/stable/manual/layers/
  - https://doc.mapeditor.org/en/stable/manual/custom-properties/
- Unity Tilemap/Grid: Grid-, Tilemap- und Isometric-Z-as-Y-Strukturen
  - https://docs.unity.cn/Manual/class-Grid.html
  - https://docs.unity.cn/6000.0/Documentation/Manual/tilemaps/work-with-tilemaps/isometric-tilemaps/isometric-tilemap-grid-cells.html
- Unity Tilemap Praxis: Layer, Sorting, Collider und isometrische 2D-Umgebungen
  - https://unity.com/blog/engine-platform/isometric-2d-environments-with-tilemap
- Godot TileMap: TileMap-Layer, Collision, Occlusion und Navigation Shapes
  - https://docs.godotengine.org/en/latest/tutorials/2d/using_tilemaps.html

## 1. Ausgangspunkt

Talvori nutzt aktuell hochwertige 2.5D-Assets fuer Inseln, Starter-Inseln,
Community-Regionen und Space-Hintergrund. Diese Bilder erzeugen einen starken
ersten visuellen Eindruck.

Bilder allein reichen aber nicht fuer eine erweiterbare Welt.

Die bisherigen Versuche mit Connectoren haben das klar gezeigt:

- Connectoren koennen visuell schoen sein, wirken aber falsch, wenn sie frei im
  Space starten oder enden.
- Inseln koennen hochwertig aussehen, aber die App weiss ohne Zusatzdaten nicht,
  wo Bauplaetze, Wege, Dockingpunkte oder blockierte Bereiche liegen.
- Gebaeude, Fundamente, Wege, Baeume, Deko, Dockingpunkte und Connectoren
  brauchen semantische Punkte, Zonen und Regeln.

Talvori braucht deshalb eine professionelle Weltarchitektur: sichtbare Assets
plus unsichtbare Struktur.

## 2. Was Professionelle Spiele Grundsaetzlich Machen

Professionelle Aufbau-, City-Builder-, Strategie-, 2D- und 2.5D-Spiele trennen
sichtbare Grafik und logische Weltstruktur.

Typische Muster:

- Die sichtbare Grafik ist ein Renderer-Ergebnis.
- Die Weltlogik lebt in Daten: Raster, Tiles, Slots, Nodes, Objektlayer,
  Kollisionen, Zonen, Navigation und Metadaten.
- Gebaeude, Wege, Deko und Bruecken werden nicht beliebig auf ein Bild gesetzt.
- Level- und World-Editoren arbeiten mit Objekten, Koordinaten, Layern,
  Kollisionsflaechen, Navigation, Custom Properties und Zustandsdaten.

Tiled organisiert Karten in Layern und erlaubt Custom Properties fuer Maps,
Layer, Objects und Tiles. Unitys Tilemap/Grid-System trennt Grid, Tilemaps,
Sorting/Rendering und optionale Collider. Godot erlaubt TileMaps mit
funktionalen Zusatzformen wie Collision, Occlusion und Navigation.

Der gemeinsame Kern:

> Ein Spielbild ist nicht die Welt. Es ist nur die Darstellung einer Welt, die
> intern strukturierte Daten besitzt.

## 3. Relevante Architekturprinzipien

### Tile/Grid-Logik

Viele Welten nutzen ein Raster oder ein tile-artiges Koordinatensystem, auch
wenn das Raster im finalen Spiel nicht sichtbar ist.

Nutzen:

- stabile Platzierung,
- klare Nachbarschaften,
- einfache Blockierungsregeln,
- reproduzierbare Erweiterung,
- bessere Tests.

Talvori muss nicht zwingend ein sichtbares Tile-Raster zeigen. Aber Inseln
brauchen mindestens ein internes Koordinatensystem fuer Bauzonen, Wege,
Dockingpunkte und Objektplatzierung.

### Isometrische Koordinaten

Isometrische und 2.5D-Welten verwenden oft eine Umrechnung zwischen logischen
Weltkoordinaten und Bildschirmpositionen.

Wichtig:

- Logik arbeitet auf Welt-/Tile-/Local-Koordinaten.
- Renderer rechnet diese in Pixel/Screen um.
- Hoehe, Tiefe und Y-Sortierung werden getrennt behandelt.

Fuer Talvori heisst das:

- Inselobjekte brauchen lokale Koordinaten.
- Weltobjekte brauchen Weltkoordinaten.
- Der Flutter-Renderer darf diese Koordinaten anzeigen, aber nicht allein
  besitzen.

### Objektlayer

Professionelle Welten bestehen aus mehreren logischen Layern:

- Terrain / Inselbasis,
- Gebaeude,
- Wege,
- Deko,
- Connectoren,
- Interaktions-Hotspots,
- Kollisions-/Blocked-Areas,
- private Lern-Overlays,
- UI-Overlays.

Diese Layer koennen unterschiedlich gerendert werden, muessen aber fachlich
getrennt bleiben.

### Z-Order / Tiefensortierung

In 2.5D entscheidet die Zeichenreihenfolge, ob Objekte glaubwuerdig davor oder
dahinter liegen.

Typische Grundlagen:

- Objekte mit tieferer Y-Position liegen oft weiter vorne.
- Hoehenebenen brauchen eigene Prioritaeten.
- Bruecken, Baeume, Gebaeude und Figuren duerfen sich nicht zufaellig
  ueberdecken.

Fuer Talvori:

- jedes platzierte Weltobjekt braucht eine `zIndex`- oder Sortierlogik,
- Inselassets, Connectoren, Labels und Hotspots duerfen nicht beliebig im
  Widget-Stack liegen,
- spaetere Rendererwechsel werden leichter, wenn Z-Order im Datenmodell
  mitgedacht wird.

### Build Slots / Build Zones

Gebaeude entstehen in professionellen Aufbauwelten nicht irgendwo. Es gibt
Slots, Bauzonen oder Regeln, die erlaubte Plaetze definieren.

Talvori braucht:

- Bauzonen fuer Haus, Markt, Bibliothek und spaetere Gebaeude,
- Fundamentplaetze,
- Groessen-/Kategorie-Regeln,
- blockierte Flaechen,
- visuelle Bauplatzmarkierungen nur bei Bedarf.

### Path Nodes / Path Anchors

Wege sind nicht nur Texturen. Sie verbinden logische Punkte.

Talvori braucht:

- PathNodes fuer Wege,
- PathAnchors an Gebaeuden und Bauzonen,
- Pfadsegmente zwischen Nodes,
- Regeln, welche Nodes verbunden werden duerfen.

Dadurch koennen Wege spaeter wachsen, ohne als frei gezeichnete Linie falsch
zu wirken.

### Dockingpunkte

Connectoren zwischen Inseln brauchen definierte Start- und Zielpunkte.

Talvori braucht:

- Dockingpunkte an Inselraendern,
- grosse Dockingbereiche bei Community-Regionen,
- Snap-Zonen fuer private Inseln,
- Regeln fuer Richtung, Abstand und erlaubte Connector-Typen.

Ohne Dockingpunkte haengen Connectoren im Space. Mit Dockingpunkten werden sie
zu glaubwuerdigen Verbindungen.

### Blocked Areas

Nicht jede sichtbare Flaeche ist bebaubar.

Blockierte Bereiche:

- Wasser,
- Klippen,
- Felsen,
- bestehende Gebaeude,
- Wege,
- dekorative Landmarken,
- private oder oeffentliche Sperrzonen.

Blocked Areas verhindern chaotische Platzierung und schuetzen die visuelle
Qualitaet.

### Decoration Zones

Deko sollte kontrolliert wachsen.

Talvori braucht Zonen fuer:

- Baeume,
- Blumen,
- Laternen,
- Kristalle,
- Zaune,
- kleine Bewohner,
- Partikel oder Lernmarker.

Diese Zonen sorgen dafuer, dass Wachstum lebendig wirkt, aber nicht beliebig.

### Resource / State Layer

Eine Aufbauwelt veraendert sich durch Zustand.

Talvori braucht einen State Layer fuer:

- Besitz,
- Ausbau-Level,
- gesperrt/freigeschaltet,
- private Lernzustande,
- Fog/Repair/Reminder,
- Ressourcenstand,
- Fortschrittsbindung.

Dieser Layer darf nicht direkt an Flutter-Widgets oder Asset-Dateien gekoppelt
sein.

### Rendererunabhaengiges Weltmodell

Die Weltlogik muss rendererunabhaengig bleiben.

Flutter kann aktuell die Anzeige bauen. Spaeter koennen Flame, Tiled/JSON,
Rive, ein eigener 2.5D-Renderer oder langfristig 3D geprueft werden.

Das Datenmodell muss gleich bleiben:

- Insel,
- Bauzone,
- Dockingpunkt,
- Pfadnode,
- platziertes Objekt,
- Zustand,
- Lernbindung.

## 4. Warum PNGs Allein Nicht Reichen

PNGs zeigen nur das Ergebnis. Sie enthalten keine Spielregeln.

Ohne Zusatzdaten weiss die App nicht:

- wo gebaut werden darf,
- wo ein Fundament hinpasst,
- welche Flaechen Wasser oder Fels sind,
- wo ein Weg beginnen soll,
- wo Connectoren sauber ansetzen,
- welche Deko-Zonen frei sind,
- welche Punkte fuer Expansion geeignet sind.

Dadurch entstehen genau die bisherigen Fehler:

- frei schwebende Connectoren,
- falsche Platzierung,
- kein klarer Inselrand-Anschluss,
- zufaellige Erweiterung,
- keine vernuenftige Skalierung,
- schwer wartbare Flutter-Sonderlogik.

Spaetere automatische Erweiterung braucht Templates und Regeln. Ein schoenes
Asset ist die visuelle Basis, aber die Welt braucht darunter semantische Daten.

## 5. Ableitung Fuer Talvori

Jede Talvori-Insel braucht neben dem sichtbaren Asset eine unsichtbare
semantische Struktur.

Mindestens:

- `buildZones`,
- `dockingPoints`,
- `pathNodes`,
- `decorationZones`,
- `blockedAreas`,
- `itemSlots`,
- `ownershipState`,
- `visualState`,
- `progressionState`,
- optional `learningBinding`.

Diese Daten muessen relativ zur Insel gedacht werden, nicht relativ zum
aktuellen Bildschirm.

Beispiel:

```text
IslandTemplate
  assetPath
  localBounds
  buildZones[]
  dockingPoints[]
  pathNodes[]
  decorationZones[]
  blockedAreas[]
  defaultItems[]
```

Eine konkrete Inselinstanz kann daraus entstehen:

```text
IslandObject
  templateId
  worldPosition
  scale
  ownershipState
  placedItems[]
  progressionState
```

## 6. Konsequenz Fuer Bau- Und Erweiterungssystem

Talvori sollte folgende Regeln festhalten:

- Gebaeude entstehen nur auf `BuildZones`.
- Fundamente entstehen nur auf vorbereiteten Bauplaetzen.
- Wege verbinden `PathNodes`.
- Connectoren verbinden `DockingPoints`.
- Baeume und Deko entstehen in `DecorationZones`.
- Wasser, Felsen, Klippen, bestehende Gebaeude und Landmarken blockieren
  Flaechen.
- Neue Inseln und Erweiterungen entstehen aus Templates, nicht zufaellig.
- Private Inseln duerfen spaeter bewegt oder erweitert werden, aber nur ueber
  Snap-/Docking-/Validierungsregeln.
- Community-Regionen bleiben kuratiert und nicht frei verschiebbar.

Dadurch kann Talvori gefuehrte Freiheit anbieten:

- Nutzer waehlen und gestalten,
- das System schuetzt Ordnung, Lesbarkeit und Qualitaet.

## 7. Konsequenz Fuer Spaetere 3D-/Renderer-Offenheit

Die Weltlogik darf nicht im Flutter-Widget stecken.

Flutter darf aktuell:

- Assets anzeigen,
- Hotspots rendern,
- lokale Mock-Daten visualisieren,
- Zoom/Pan abbilden,
- UI-Overlays zeigen.

Flutter sollte nicht dauerhaft allein entscheiden:

- wo gebaut werden darf,
- welche Dockingpunkte existieren,
- welche Wege gueltig sind,
- welche Objekte kollidieren,
- welcher Lernzustand welche Weltveraenderung ausloest.

Renderer-Offenheit bedeutet:

- Weltmodell bleibt unabhaengig vom Renderer.
- Assets koennen ersetzt werden.
- Flutter, Flame, Tiled/JSON oder eine spaetere 2.5D-/3D-Engine koennen die
  gleichen Welt-Daten nutzen.
- Lern- und Weltlogik muessen nicht neu geschrieben werden, wenn der Renderer
  wechselt.

## 8. Risiken, Wenn Man Es Falsch Macht

Risiken ohne semantische Weltstruktur:

- chaotische Platzierung,
- unpassende Connectoren,
- frei schwebende Bruecken,
- Gebaeude auf Wasser, Felsen oder falschen Ebenen,
- keine kontrollierbare visuelle Qualitaet,
- doppelte Arbeit bei spaeterem Rendererwechsel,
- keine Skalierung auf viele Nutzerinseln,
- schwer wartbare Flutter-Sonderlogik,
- unklare Trennung zwischen Lernen, Weltlogik und Renderer,
- spaetere Persistenz wird bruechig, weil Daten nicht sauber modelliert sind.

## 9. Empfohlene Talvori-Entscheidung

Talvori Welt soll als assetbasierte 2.5D-Welt mit semantischer
Unsichtbar-Ebene geplant werden.

Das sichtbare Asset bleibt wichtig. Es erzeugt Emotion, Qualitaet und den
ersten Wow-Moment.

Aber jede Insel braucht strukturierte Daten fuer:

- Bau,
- Wege,
- Deko,
- Docking,
- Besitz,
- Zustand,
- Erweiterung,
- spaetere Lernbindung.

Kurz:

> Talvori rendert schoene Inseln, aber Talvori spielt auf strukturierten
> Inselmodellen.

Diese Entscheidung passt zu den bisherigen strategischen Regeln:

- lokale Prototypen zuerst,
- Flutter als aktueller Renderer,
- Reward Bridge spaeter,
- keine direkte Kopplung von Lernlogik in den Renderer,
- keine Supabase Writes ohne ausdrueckliche Freigabe,
- rendererunabhaengige Weltlogik.

## 10. Naechster Schritt Nach Diesem Dokument

Empfohlenes naechstes Dokument:

`docs/221-talvori-world-build-and-expansion-architecture.md`

Dieses Dokument soll das konkrete Talvori-Modell definieren:

- `IslandObject`,
- `BuildZone`,
- `DockingPoint`,
- `PathNode`,
- `PlacedWorldItem`,
- `IslandTemplate`,
- `ConnectorTemplate`,
- `ExpansionRules`.

Ziel von `docs/221`:

- keine UI-Details,
- keine neue Implementierung,
- keine Persistenz,
- sondern ein praezises Modell fuer lokale/mock Bau- und Erweiterungslogik,
  das spaeter sauber in Flutter, Flame, Tiled/JSON oder eine andere
  Rendererschicht ueberfuehrt werden kann.

