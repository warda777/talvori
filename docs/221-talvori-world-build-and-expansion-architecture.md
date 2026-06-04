# Talvori Welt: Build- und Expansion-Architektur

Stand: 2026-06-04

Dieses Dokument leitet aus den bisherigen Talvori-Welt-Planungen und der
Architektur-Recherche ein konkretes Zielmodell fuer Inseln, Bauzonen,
Gebaeude, Fundamente, Wege, Deko, Connectoren und Erweiterungen ab.

Es ist ein reines Architektur-Dokument. Es wurden keine Dart-/Flutter-Dateien,
keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten,
kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und
keine Release-Artefakte geaendert.

Grundlage:

- `docs/217-talvori-world-start-island-claiming-plan.md`
- `docs/218-talvori-world-connector-system-plan.md`
- `docs/219-talvori-world-docking-points-plan.md`
- `docs/220-talvori-world-professional-game-architecture-research.md`

## 1. Grundentscheidung

Talvori Welt besteht aus zwei Ebenen:

1. sichtbare Assets,
2. semantische Unsichtbar-Ebene.

Das sichtbare PNG ist nur die Darstellung. Die eigentliche Welt besteht aus
strukturierten Daten.

Grundregeln:

- Keine freie Platzierung direkt auf Bilder.
- Gebaeude brauchen BuildZones.
- Fundamente brauchen vorbereitete Bauplaetze.
- Wege brauchen PathNodes und PathAnchors.
- Baeume und Deko brauchen DecorationZones.
- Connectoren brauchen DockingPoints.
- Wasser, Felsen, Klippen, bestehende Gebaeude und Landmarken koennen Flaechen
  blockieren.

Talvori soll gefuehrte Freiheit bieten: Nutzer treffen Entscheidungen, aber das
System schuetzt Ordnung, Lesbarkeit und visuelle Qualitaet.

## 2. IslandObject / WorldIsland

Eine sichtbare Insel oder Region wird langfristig als `IslandObject` bzw.
`WorldIsland` modelliert.

Zielmodell:

```text
WorldIsland
  id
  ownerId optional
  islandType
  islandRole
  biome
  displayName
  assetPath
  worldPosition
  scale
  boundingBox
  assetBounds
  logicalBounds
  hitTestShape
  renderLayer
  zIndexPolicy
  buildZones[]
  dockingPoints[]
  pathNodes[]
  decorationZones[]
  blockedAreas[]
  itemSlots[]
  ownershipState
  visualState
  progressionState
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Insel-ID |
| `ownerId` | optionaler Besitzer, nur bei privaten oder fremden Nutzerinseln |
| `islandType` | `showcase`, `starter`, `own`, `community`, `friend`, `foreign` |
| `islandRole` | `main`, `expansion`, `theme`, `event`, `community`, `showcase` |
| `biome` | Wald, Feld, Fels, Schnee, Kristall, Tropen usw. |
| `displayName` | sichtbarer Name |
| `assetPath` | visuelles Insel-/Region-Asset |
| `worldPosition` | Position im World Canvas oder spaeter in WorldRegion |
| `scale` | Darstellungs- und Platzierungsfaktor |
| `boundingBox` | logische Begrenzung fuer Hit-Test, Kamera und Naehe |
| `assetBounds` | sichtbare Asset-Grenze inklusive transparenter PNG-Raender |
| `logicalBounds` | fachliche Inselgrenze fuer Platzierung, Naehe und Kollision |
| `hitTestShape` | einfache oder polygonale Interaktionsflaeche |
| `renderLayer` | grober Render-Layer, z. B. background, island, connector, label |
| `zIndexPolicy` | Sortierregel, z. B. fest, Y-Sortierung oder Layer-Prioritaet |
| `buildZones` | erlaubte Bau- und Ausbauzonen |
| `dockingPoints` | Connector- und Snap-Anker |
| `pathNodes` | Punkte fuer Wege und Bewegungslogik |
| `decorationZones` | kontrollierte Deko-/Naturflaechen |
| `blockedAreas` | gesperrte Flaechen |
| `itemSlots` | konkrete Slots fuer platzierte Items |
| `ownershipState` | frei, ausgewaehlt, eigen, Freund, fremd, Community |
| `visualState` | sichtbar, locked, preview, fog, repair, highlight |
| `progressionState` | Ausbau-, Lern- oder Freischaltzustand |

Wichtig:

- Lokale Positionsdaten innerhalb einer Insel bleiben relativ zum Insel-Asset
  oder zur logischen Insel-BoundingBox.
- Weltposition und lokale Inselposition werden getrennt.
- Dadurch koennen Renderer, Zoom, Pan, Portrait und Landscape gewechselt werden,
  ohne die fachlichen Daten neu zu erfinden.
- Sichtbare PNG-Grenzen und logische Inselgrenzen duerfen unterschiedlich sein.
- Hit-Testing darf nicht dauerhaft vom transparenten Bildrechteck abhaengen.

## 2a. Bounds, Hit-Testing Und Z-Order

Talvori braucht getrennte Grenzen fuer Darstellung, Interaktion und Logik.

Unterscheidung:

| Begriff | Rolle |
| --- | --- |
| `assetBounds` | tatsaechliche Bildflaeche, oft groesser wegen Transparenz |
| `visualBounds` | sichtbarer Teil des Assets |
| `logicalBounds` | fachliche Flaeche fuer Platzierung und Naehe |
| `hitTestShape` | tappbare Flaeche, meist kleiner als Bildrechteck |
| `placementBounds` | Flaeche fuer Bau-, Deko- und Connector-Regeln |

Regeln:

- Transparente PNG-Raender duerfen keine falschen Taps oder Kollisionen
  erzeugen.
- Hit-Testing sollte auf `hitTestShape` oder logisch vereinfachten Shapes
  basieren.
- BuildZones und DockingPoints liegen innerhalb der `logicalBounds`, nicht
  zwingend innerhalb der Bildrechteck-Kante.
- Kollision und Ueberlappung verwenden `placementBounds` und `blockedAreas`.

Z-Order:

- Connectoren liegen unter Insel-/Gebaeude-Assets, aber ueber Hintergrund.
- Labels und UI-Hotspots liegen ueber Inseln.
- Wege koennen unter Gebaeuden, aber ueber Terrain liegen.
- Figuren/NPCs brauchen spaeter Y-basierte oder Layer-basierte Sortierung.
- Community-Regionen, Starter-Inseln und eigene Inseln duerfen nicht nur nach
  Widget-Reihenfolge sortiert werden.

Diese Regeln muessen im Weltmodell oder in einer Renderer-Adapter-Schicht
abbildbar sein, damit Flutter nicht die fachliche Wahrheit der Tiefensortierung
bleibt.

## 3. BuildZones

`BuildZone` beschreibt, wo auf einer Insel etwas entstehen darf.

Geplante Typen:

| Typ | Rolle |
| --- | --- |
| `main_build_area` | zentraler Platz fuer erstes oder wichtigstes Gebaeude |
| `secondary_build_area` | weitere Gebaeudeplaetze |
| `nature_area` | Baeume, Garten, Wasser, Pflanzen, natuerliche Elemente |
| `decoration_area` | Laternen, Kristalle, Zaune, Baenke, kleine Deko |
| `path_area` | Wege, Pfade, Stufen, Brueckenansatz |
| `water_area` | Wasser, Quelle, Teich, Lagune, nicht frei bebaubar |
| `blocked_area` | Fels, Klippe, Landmarke oder sonstige Sperrflaeche |
| `future_expansion_area` | vorbereitete Flaeche fuer spaetere Ausbaulogik |

Zielmodell:

```text
BuildZone
  id
  islandId
  localPosition
  size
  shape
  allowedItemTypes[]
  locked
  priority
  visualHint optional
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Zone-ID |
| `islandId` | zugehoerige Insel |
| `localPosition` | relative Position zur Insel |
| `size` | Radius, Breite/Hoehe oder Polygon-Extent |
| `shape` | `circle`, `rect`, `polygon` |
| `allowedItemTypes` | z. B. Haus, Markt, Bibliothek, Baum, Weg |
| `locked/unlocked` | ob die Zone aktuell nutzbar ist |
| `priority` | Auswahl- und Renderprioritaet |
| `visualHint` | optionale spaetere Debug-/Bauplatzanzeige |

Regeln:

- Eine BuildZone ist nicht automatisch sichtbar.
- Im normalen Weltmodus kann sie unsichtbar bleiben.
- Im Bau-/Auswahlmodus darf sie dezent hervorgehoben werden.
- Platzierung erfolgt nur, wenn Item-Typ, Zone, Zustand und Blockierung passen.

## 3a. Platzierungsvalidierung

Vor jeder Platzierung braucht Talvori eine Validierung. Diese Validierung ist
Teil der Weltlogik, nicht des Renderers.

Eine Platzierung ist nur gueltig, wenn:

- die Zielzone existiert,
- die Zielzone unlocked ist,
- der Item-Typ in `allowedItemTypes` erlaubt ist,
- das Item in Groesse und Shape zur Zone passt,
- keine `blockedAreas` beruehrt werden,
- keine bestehenden Items ungueltig ueberlappt werden,
- Pfade, Wasser, Klippen und Dockingbereiche nicht blockiert werden,
- die Insel dem Nutzer gehoert oder explizit bearbeitbar ist,
- noetige Voraussetzungen aus `progressionState` erfuellt sind.

Moegliches Ergebnis einer Validierung:

```text
PlacementValidationResult
  isValid
  reason
  correctedLocalPosition optional
  targetZoneId optional
  blockingObjectIds[]
```

Wichtig:

- Snap oder leichte Positionskorrektur ist erlaubt, wenn die Zone das vorsieht.
- Ungueltige Platzierung darf nicht gerendert oder persistiert werden.
- Debug-/Editor-Modus soll spaeter zeigen koennen, warum eine Platzierung
  ungueltig ist.

## 4. Bau- und Ausbauphasen

Gebaeude und Bauplaetze wachsen in Stufen. Die Stufen schuetzen die visuelle
Lesbarkeit und geben Lernfortschritt eine klare Weltwirkung.

Moegliche Phasen:

1. leerer Bauplatz,
2. gerodet/geebnet,
3. Fundament,
4. Rohbau,
5. kleines Gebaeude,
6. ausgebautes Gebaeude,
7. lebendiges Gebaeude,
8. Meister-Version.

Konzeptionelle Lernbindung:

| Lernereignis | Weltwirkung |
| --- | --- |
| Wort erkannt | Fundament |
| Wort aktiv erinnert | Waende / Struktur |
| Satz verstanden | Fenster / Schild / Weg |
| Phrase gemeistert | stabile Struktur / Spezialteile |
| Dialog geschafft | Bewohner / Leben |
| Aussprache geschafft | Licht / Energie |

Wichtig:

- Dies ist nur Planung.
- Keine Reward Bridge wird in diesem Dokument gebaut.
- Bestehende SRS- oder `word_progress`-Semantik bleibt unangetastet.
- Spaeter entscheidet eine separate Reward Bridge deterministisch, welche
  Lernereignisse welche Weltressourcen oder Ausbauimpulse erzeugen.

## 5. PlacedWorldItem

Ein platziertes Weltobjekt ist eine konkrete Instanz innerhalb einer Zone oder
an einem Slot.

Zielmodell:

```text
PlacedWorldItem
  id
  islandId
  zoneId
  itemType
  category
  localPosition
  level
  variant
  visualState
  learningBinding optional
  resourceCost optional
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Item-ID |
| `islandId` | Insel, auf der das Item liegt |
| `zoneId` | BuildZone, DecorationZone oder ItemSlot |
| `itemType` | Haus, Markt, Bibliothek, Baum, Laterne, Weg usw. |
| `category` | `building`, `nature`, `path`, `bridge`, `decoration`, `npc`, `effect` |
| `localPosition` | relative Position zur Insel oder Zone |
| `level` | Ausbaulevel |
| `variant` | visuelle Variante, z. B. Dach/Farbe/Material |
| `visualState` | normal, locked, preview, building, repaired, glowing |
| `learningBinding` | optionale spaetere Verbindung zu Lernlogik |
| `resourceCost` | optionale spaetere Kostenstruktur |

Regeln:

- Ein Item wird nicht direkt anhand von Pixeln platziert.
- Ein Item muss zu Zone, Kategorie und Inselzustand passen.
- `localPosition` ist fachlich, nicht bildschirmbezogen.

## 6. PathNodes Und Wege

Wege verbinden logische Punkte. Sie sind nicht nur gemalte Linien.

Geplante Begriffe:

| Begriff | Rolle |
| --- | --- |
| `PathNode` | logischer Punkt auf einer Insel |
| `PathAnchor` | Anschluss an Gebaeude, Zone, Dockingpunkt oder Platz |
| `PathSegment` | Verbindung zwischen zwei Nodes |
| `startZone` | Ausgangszone |
| `endZone` | Zielzone |
| `visualVariant` | Pfadstil, z. B. Stein, Erde, Holz, magisch |

Wege verbinden:

- Gebaeude,
- BuildZones,
- Dockingpunkte,
- Bruecken,
- Community-Plaetze,
- spaetere Bewohner- oder NPC-Bewegungspunkte.

Regeln:

- Wege duerfen nicht durch `blockedAreas` fuehren.
- Wege duerfen an `path_area` oder vorbereiteten `PathNodes` entstehen.
- Wege koennen spaeter automatisch wachsen, aber nur entlang gueltiger Nodes.

## 7. DockingPoints Und Connectoren

Die Regeln aus `docs/218` und `docs/219` bleiben massgeblich.

Grundsatz:

> Connectoren verbinden nur DockingPoint zu DockingPoint.

Regeln:

- Keine frei schwebenden Connectoren.
- Keine Verbindung ohne Start- und Ziel-Dockingpunkt.
- Keine Verbindung direkt aus Inselmitten.
- Entfernung bestimmt Segmentkombination.
- Richtung bestimmt Rotation, Kurven und ggf. `corner_left` /
  `corner_right`.
- `small_platform` kann als Zwischenknoten fuer laengere oder geknickte
  Verbindungen dienen.
- Connectoren werden erst sichtbar, wenn Start- und Zielpunkte definiert sind.

Zielmodell:

```text
DockingPoint
  id
  islandId
  localPosition
  direction
  type
  isOccupied
  supportedConnectorTypes[]
  visualHint
  priority
```

Connector-Modell:

```text
WorldConnector
  id
  fromIslandId
  fromDockingPointId
  toIslandId
  toDockingPointId
  segments[]
  isUnlocked
  visualState
```

Segment-Modell:

```text
WorldConnectorSegment
  id
  connectorType
  assetPath
  worldPosition
  rotation
  scale
  zIndex
```

Phase 2D darf einzelne lokale Mock-Verbindungen zeigen. Eine vollstaendige
Pfadsuche oder automatische Verbindungsgenerierung gehoert nicht in Phase 2D.

## 8. Insel-Erweiterung / Nutzer-Archipel

Die erste gewaehlte Insel wird die Hauptinsel des Nutzers.

Spaeter kann der Nutzer weitere private Inseln freischalten. Diese Inseln
bilden gemeinsam ein Nutzer-Archipel.

Moegliche Rollen:

- Hauptinsel,
- Erweiterungsinsel,
- Themeninsel,
- Eventinsel,
- Deko-/Naturinsel.

Besitzer-Markierung:

- Fahne,
- Avatar,
- Besitzer-Siegel,
- Companion-Symbol,
- dezenter Besitzring,
- optional spaeter Nutzername.

Regeln:

- Besitzer-Markierung ist sichtbar, aber nicht dominant.
- Community-Regionen sind nicht claimbar.
- Showcase-Inseln sind nicht claimbar.
- Fremde Inseln sind nicht frei verschiebbar.
- Longpress/Drag ist spaeter nur fuer eigene Inseln erlaubt.
- Longpress/Drag braucht Snap-/Docking-Regeln.
- Ungueltige Positionen werden verhindert: Ueberlappung, zu geringe Distanz,
  blockierte Community-Zonen, unguelige Dockingpunkte.

## 9. Automatische Erweiterung

Automatische Erweiterung ist nur regelbasiert erlaubt.

Nicht gewuenscht:

- zufaellig-chaotisches Wachstum,
- freie Pixelplatzierung,
- unkontrollierte Objektueberlappung,
- Connectoren ohne Dockingpunkte,
- Deko ohne passende Zonen.

Regeln:

- Neue Inseln entstehen aus Templates.
- Neue Bauzonen entstehen aus Templates.
- Neue Connectoren entstehen aus Dockingpunkten.
- Neue Deko entsteht aus DecorationZones.
- Neue Wege entstehen entlang PathNodes.
- Neue Gebaeude entstehen in BuildZones.
- BlockedAreas bleiben geschuetzt.

Dadurch kann Talvori spaeter automatisch wachsen, ohne die Premium-Weltwirkung
zu verlieren.

## 10. Templates

Templates definieren, wie Inseln, Zonen, Connectoren und Deko entstehen duerfen.

Geplante Template-Typen:

- `StarterIslandTemplate`,
- `CommunityRegionTemplate`,
- `ExpansionIslandTemplate`,
- `BuildZoneTemplate`,
- `DockingPointTemplate`,
- `ConnectorTemplate`,
- `DecorationTemplate`.

Templates enthalten:

- Asset-Pfade,
- erlaubte Zonen,
- Platzierungsregeln,
- Ausbaustufen,
- Varianten,
- moegliche spaetere Lernbindungen.
- Template-Version,
- Daten-Schema-Version,
- Migrationshinweise fuer alte Inselinstanzen.

Beispiel:

```text
StarterIslandTemplate
  id
  biome
  assetPath
  defaultBuildZones[]
  defaultDockingPoints[]
  defaultPathNodes[]
  defaultDecorationZones[]
  defaultBlockedAreas[]
  allowedStarterBuildings[]
```

Templates sind keine fertigen Nutzerstaende. Sie sind Bauplaene fuer lokale
oder spaeter persistierte Inselinstanzen.

### Versionierung Und Migration

Templates muessen versioniert werden, bevor echte Persistenz oder Cloud-Welten
entstehen.

Empfohlene Felder:

```text
TemplateMetadata
  templateId
  templateVersion
  schemaVersion
  createdAt optional
  deprecatedAt optional
  migrationTarget optional
```

Regeln:

- Eine bestehende Inselinstanz merkt sich, aus welcher Template-Version sie
  entstanden ist.
- Wenn ein Template geaendert wird, duerfen bestehende Inseln nicht
  unkontrolliert brechen.
- Migrationen duerfen BuildZones, DockingPoints oder Slots nicht einfach
  verschieben, ohne platzierte Items zu pruefen.
- Alte Templates koennen fuer bestehende Inseln gueltig bleiben, auch wenn neue
  Nutzer eine neue Template-Version erhalten.
- Migrationen brauchen Tests, bevor persistierte Nutzerinseln betroffen sind.

Phase 2E bleibt lokal/mock. Die Versionierung wird aber jetzt mitgedacht, damit
spaetere Insel- und Template-Daten nicht zum Sackgassenmodell werden.

## 11. Skalierung

Talvori darf spaeter nicht alle Inseln, Details und Nutzerwelten gleichzeitig
voll laden.

Geplante Begriffe:

| Begriff | Rolle |
| --- | --- |
| `WorldRegion` | groesserer Weltbereich |
| `WorldTile` | ladbare Kachel oder logischer Ausschnitt |
| `visibleViewport` | aktuell sichtbarer Bereich |
| `nearbyIslands` | nahe Inseln fuer Preview oder Interaktion |
| `loadedIslandIds` | aktuell geladene Detailinseln |
| `previewState` | vereinfachte Vorschau |
| `detailState` | vollstaendige Inselstruktur |

Regel:

Nur sichtbare oder relevante Inseln werden geladen.

Detaildaten werden erst geladen, wenn:

- Nutzer nah genug heranzoomt,
- Nutzer eine Insel antippt,
- `Meine Insel` fokussiert wird,
- Freunde-/Besuchskontext spaeter aktiv ist.

In der Weltuebersicht reicht Preview:

- Besitzer,
- Name,
- Hauptasset,
- Level-/Statussignal,
- wenige Hauptmarker.

Details:

- BuildZones,
- Items,
- PathNodes,
- Dockingpunkte,
- private Lern-Overlays,
- visuelle Detailzustaende.

### Kamera, Viewport Und Orientierung

Die Kamera ist eine eigene fachliche Schicht zwischen Weltmodell und Renderer.

Geplante Begriffe:

| Begriff | Rolle |
| --- | --- |
| `cameraTarget` | Insel, Zone oder Position, die fokussiert wird |
| `cameraBounds` | erlaubter Bewegungsbereich |
| `minZoom` / `maxZoom` | sinnvolle Zoom-Grenzen je Modus |
| `focusMode` | Weltuebersicht, Meine Insel, Detailansicht, Besuch |
| `orientationMode` | Portrait-Ausschnitt oder Landscape-Explore |

Regeln:

- Portrait zeigt einen fokussierten Ausschnitt, keine gequetschte Welt.
- Landscape darf als breiter Explore-Modus vorbereitet bleiben.
- `Meine Insel` fokussiert die eigene Hauptinsel oder den Nutzer-Archipel.
- Debug-/Editor-Modus darf andere Kamera-Grenzen haben als normaler Nutzerflow.
- Kamera-Logik darf Zoom/Pan-Gesten nicht durch ungewollte Rebuilds
  ueberschreiben.

### Performance Und LOD

Viele Inseln brauchen Level-of-Detail-Regeln.

LOD-Regeln:

- weit entfernt: Asset, Name, Besitz-/Statussignal,
- mittlere Naehe: Haupt-Hotspots, Docking-/Connector-Preview,
- Detail: BuildZones, PathNodes, Items, Deko, private Overlays,
- Editor/Debug: Zonen, Bounds, Dockingpunkte, BlockedAreas.

Performance-Regeln:

- Hit-Testing nur fuer sichtbare oder nahe Objekte.
- Detaildaten nur fuer `loadedIslandIds`.
- Preview-Daten duerfen kleiner sein als Detaildaten.
- Spaeter kann ein einfacher Spatial Index oder WorldTile-Index genutzt werden.
- Grosse Asset-Serien brauchen klare Lade- und Entladegrenzen.

## 12. Renderer-Unabhaengigkeit

Talvori trennt:

- Weltmodell,
- Platzierungslogik,
- Renderer,
- Lern-/Reward-Logik,
- Persistenz,
- UI-Overlays.

Aktuell rendert Flutter:

- Space-Hintergrund,
- Inselassets,
- Hotspots,
- Labels,
- Overlays,
- Zoom/Pan.

Spaeter koennen geprueft werden:

- Flame,
- Tiled/JSON,
- Rive,
- eigener 2.5D-Renderer,
- langfristig 3D/2.5D-Engine.

Wichtig:

- Weltlogik steckt nicht dauerhaft im Flutter-Widget.
- Flutter darf Daten anzeigen, aber nicht die fachliche Wahrheit sein.
- Lern-/Reward-Logik bleibt separat und testbar.
- Persistenz bleibt separat und wird nicht in diesem Dokument gebaut.

## 13. Phase-2E-Vorschlag

Naechster technischer Slice:

- keine Connectoren,
- keine Bau-Logik,
- zuerst lokale BuildZone-, PathNode- und DockingPoint-Daten fuer 3
  Starter-Inseln,
- optional Debug-Anzeige,
- keine Persistenz,
- keine Reward Bridge.

Empfohlene Starter-Inseln:

- Waldlichtung,
- Ackerfeld,
- Felseninsel.

Ziel von Phase 2E:

- beweisen, dass Inseln semantische Bauzonen besitzen,
- Debugpunkte optional anzeigen koennen,
- spaeterer Bau- und Connector-Code auf echten Zonen statt Pixeln aufsetzt,
- Renderer und Weltmodell nicht weiter vermischt werden.

Konkrete Mindestdaten fuer Phase 2E:

- pro Starter-Insel mindestens eine `main_build_area`,
- mindestens eine `secondary_build_area` oder `future_expansion_area`,
- mindestens zwei `PathNodes`,
- mindestens zwei `DockingPoints`,
- mindestens eine `blocked_area`,
- mindestens eine `decoration_area`.

Nicht in Phase 2E:

- keine sichtbaren Connectoren,
- keine automatische Platzierung,
- keine Gebaeude-Auswahl,
- keine Persistenz.

## 14. Debug-/Editor-Modus Und Tests

Talvori braucht frueh einen internen Debug-/Editor-Modus fuer semantische
Weltstruktur.

Zweck:

- BuildZones sichtbar pruefen,
- DockingPoints sichtbar pruefen,
- PathNodes und PathSegments pruefen,
- BlockedAreas sichtbar machen,
- HitTestShapes und LogicalBounds pruefen,
- Template-Version und verwendete Inselinstanz anzeigen.

Regeln:

- Debug-/Editor-Anzeige ist standardmaessig aus.
- Keine sichtbare Nutzer-UI fuer Debug-Marker im normalen Modus.
- Debug darf lokal/mock sein.
- Debug darf keine Supabase Writes oder Persistenz ausloesen.

Testbare Regeln:

- Ein Gebaeude kann nur in erlaubter BuildZone platziert werden.
- Ein Fundament darf nicht in `blocked_area` entstehen.
- Ein Pfadsegment darf nur gueltige PathNodes verbinden.
- Ein Connector darf nur DockingPoint zu DockingPoint verbinden.
- Ein Item darf ein bestehendes Item nicht ungueltig ueberlappen.
- Eine private Insel darf nur auf gueltige Snap-/Docking-Zonen verschoben
  werden.
- Template-Migrationen duerfen platzierte Items nicht verlieren.

## 15. Scope-Grenzen

Weiterhin ausgeschlossen:

- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderungen,
- keine Reward Bridge,
- keine echte Ressourcen-Persistenz,
- keine Cloud-Welt,
- kein Social-Backend,
- keine echte Oekonomie,
- keine Longpress-Verschiebung,
- keine automatische Weltgenerierung als Vollsystem,
- keine 3D-Engine.

Dieses Dokument plant Architektur. Es baut keine neue Funktion.

## 16. Akzeptanzkriterien

Dieses Architekturmodell ist gut, wenn:

- klar ist, warum Bilder allein nicht reichen,
- jede Insel logisch Bauzonen bekommen kann,
- Fundamente, Gebaeude, Natur und Wege spaeter geordnet platzierbar sind,
- Connectoren erst nach Dockingpunkten sinnvoll werden,
- mehrere eigene Inseln und Nutzer-Archipel vorbereitet sind,
- automatische Erweiterung regelbasiert gedacht ist,
- Platzierungsvalidierung vor Bau, Deko, Wegen und Connectoren vorgesehen ist,
- Asset-Bounds, LogicalBounds und Hit-Testing getrennt sind,
- Kamera, LOD und Performance fuer grosse Weltkarten mitgedacht sind,
- Template-Versionierung und Migration als spaetere Pflicht vorgesehen sind,
- Debug-/Editor-Modus und Tests fuer Zonen, Punkte und Platzierungsregeln
  vorgesehen sind,
- Renderer und Weltlogik getrennt bleiben,
- Lern-/Reward-Logik konzeptionell anschliessbar ist, aber nicht direkt in den
  Renderer wandert,
- Phase-2E als kleiner lokaler naechster Slice ableitbar ist.
