# Talvori Welt Phase 2D: Docking-Points-Plan

Stand: 2026-06-03

Dieses Dokument plant die Dockingpunkt-Logik fuer spaetere modulare
Connectoren in der Talvori-Welt. Es ist ein reines Planungsdokument.

Es wurden keine Dart-/Flutter-Dateien, keine Assets, keine Supabase-Daten,
keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward
Bridge, keine Persistenz, keine Secrets und keine Release-Artefakte geaendert.

## 1. Problem

Der erste lokale Mock-Connector-Layer wurde wieder entfernt, weil die
Connectoren optisch frei im Space hingen. Sie starteten und endeten nicht
erkennbar an Inselraendern, Plattformen oder Andockzonen.

Das Problem war nicht primaer das Connector-Asset selbst. Das Problem war die
fehlende Dockingpunkt-Logik:

- Connectoren duerfen nicht frei im Space platziert werden.
- Connectoren muessen sichtbar an Inselraendern, Plattformen oder Andockzonen
  anschliessen.
- Ohne Dockingpunkte wirken Verbindungen zufaellig, technisch und falsch.
- Eine Verbindung braucht eine glaubwuerdige Start- und Zielstelle, bevor sie
  gerendert wird.

## 2. Ziel

Jede Insel und jede groessere Region bekommt spaeter definierte Dockingpunkte.
Connectoren verbinden nur Dockingpunkt zu Dockingpunkt.

Dadurch soll gelten:

- Verbindungen wirken organisch und glaubwuerdig.
- Start und Ende eines Connectors sitzen sichtbar an einer passenden Kante.
- Connectoren koennen in Laenge, Richtung und Segmentfolge lokal/mock geplant
  werden.
- Die Dockingpunkt-Daten bleiben rendererunabhaengig und koennen spaeter von
  Flutter, Flame oder einem anderen Renderer genutzt werden.

## 3. Dockingpunkt-Typen

Geplante Typen:

| Typ | Rolle |
| --- | --- |
| `north` | oberer Inselrand oder noerdliche Anschlusskante |
| `south` | unterer Inselrand oder suedliche Anschlusskante |
| `east` | rechter Inselrand oder oestliche Anschlusskante |
| `west` | linker Inselrand oder westliche Anschlusskante |
| `northeast` | diagonaler Anschluss oben rechts |
| `northwest` | diagonaler Anschluss oben links |
| `southeast` | diagonaler Anschluss unten rechts |
| `southwest` | diagonaler Anschluss unten links |
| `bridge_anchor` | sichtbarer Bruecken-/Felsanker am Rand |
| `platform_anchor` | Anschluss an eine Plattform oder Zwischeninsel |
| `hidden_snap_zone` | unsichtbare spaetere Snap-Zone fuer Platzierung |

Nicht jeder Inseltyp braucht jeden Dockingpunkt. Community-Regionen koennen
groessere, kuratierte Dockingbereiche haben. Private Inseln koennen mehrere
moegliche Snap-Zonen besitzen, die je nach Position und Ausbauzustand aktiviert
werden.

## 4. Datenmodell Lokal/Mock

Geplantes lokales Modell:

```dart
class WorldDockingPoint {
  final String id;
  final String islandId;
  final Offset localPosition;
  final WorldDockingDirection direction;
  final WorldDockingPointType type;
  final bool isOccupied;
  final List<WorldConnectorType> supportedConnectorTypes;
  final WorldDockingVisualHint visualHint;
  final int priority;
}
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Dockingpunkt-ID |
| `islandId` | Insel oder Region, zu der der Punkt gehoert |
| `localPosition` | Position relativ zum Insel-Asset oder Insel-Bounding-Rect |
| `direction` | grobe Ausrichtung, z. B. `north`, `east`, `southwest` |
| `type` | fachlicher Typ, z. B. `bridge_anchor` oder `hidden_snap_zone` |
| `isOccupied` | ob dort bereits ein Connector oder eine Verbindung liegt |
| `supportedConnectorTypes` | erlaubte Segmenttypen oder Connector-Gruppen |
| `visualHint` | spaetere Marker-/Debug-/Bearbeitungsdarstellung |
| `priority` | Auswahlprioritaet bei mehreren passenden Punkten |

Wichtig:

- `localPosition` bleibt relativ zur Insel, nicht zum aktuellen Bildschirm.
- Der Renderer rechnet daraus spaeter eine Weltposition.
- Dadurch funktionieren Zoom, Pan, Portrait und Landscape ohne eigene
  Dockingpunkt-Varianten.

## 5. Inseltypen

### Showcase-Insel

Die Showcase-/Beispielinsel ist nicht claimbar und nicht frei verschiebbar.

Planung:

- wenige feste Dockingpunkte,
- nur spaetere Beispiel- oder Showcase-Verbindungen,
- keine automatische private Besitzlogik,
- keine freien Nutzer-Snap-Zonen.

Die Showcase-Insel kann als kuratierter Weltpunkt dienen, aber sie ist nicht
der Standardanker fuer private Inseln.

### Starter-Insel

Starter-Inseln sind private Startoptionen. Nach Auswahl wird eine Starter-Insel
zur ersten eigenen Insel.

Planung:

- mehrere moegliche Dockingpunkte,
- Dockingpunkte koennen je nach Inseltyp unterschiedlich liegen,
- spaeter abhaengig von gewaehlt, verschoben, ausgebaut oder verbunden,
- private Inseln koennen langfristig per Snap/Longpress neu positioniert
  werden,
- nur eigene/private Inseln duerfen spaeter beweglich sein.

Phase 2D plant nur lokale/mock Dockingpunkte. Longpress, Snap-Regeln und
Persistenz werden hier noch nicht gebaut.

### Community-Region

Community-Regionen sind grosse, nicht private Weltknoten.

Planung:

- feste grosse Dockingbereiche,
- nicht frei verschiebbar,
- wichtig fuer Hauptverbindungen,
- geeignet fuer kuratierte Verbindungen zwischen Weltbereichen,
- kein Claiming und keine Besitzmarkierung.

Community-Dockingpunkte duerfen groesser und eindeutiger sein als private
Inselpunkte, weil sie spaeter Hauptachsen und zentrale Verbindungen tragen.

## 6. Connector-Regel

Eine Verbindung von Insel A nach Insel B ist nur gueltig, wenn beide Seiten
passende Dockingpunkte haben.

Grundregel:

1. Waehle Dockingpunkt A an Insel A.
2. Waehle Dockingpunkt B an Insel B.
3. Pruefe Richtung und Abstand zwischen beiden Weltpositionen.
4. Bestimme daraus die Connector-Kombination.
5. Rendere Connector-Segmente nur entlang dieser gueltigen Verbindung.

Regeln:

- Keine Verbindung ohne Dockingpunkt.
- Keine Verbindung, die direkt aus der Inselmitte startet.
- Keine Verbindung, die optisch frei im Space endet.
- Entfernung bestimmt `short`, `medium`, `long` oder
  Plattform-Kombinationen.
- Richtung bestimmt Rotation und ggf. `corner_left` oder `corner_right`.
- `end_cap` kann spaeter an sichtbaren Inselrändern oder Ankerpunkten helfen.
- `small_platform` kann fuer laengere oder geknickte Verbindungen als
  Zwischenpunkt dienen.

Die Connector-Logik aus `docs/218-talvori-world-connector-system-plan.md`
bleibt gueltig, wird aber um die harte Voraussetzung erweitert:
Connectoren duerfen erst gerendert werden, wenn Start- und Ziel-Dockingpunkte
feststehen.

## 7. Sichtbarkeit

Dockingpunkte sind normalerweise unsichtbar.

Spaetere Sichtbarkeit:

- Im normalen Weltmodus keine Marker.
- Im Bearbeitungsmodus dezente Marker fuer eigene/private Inseln.
- Im Debug-/Mock-Modus optional kleine Punktmarker zur visuellen Pruefung.
- Bei Longpress/Snap spaeter moegliche Hervorhebung gueltiger Zonen.

Visualisierung darf die Welt nicht technisch oder editorartig wirken lassen.
Dockingpunkte sind ein Strukturmodell, nicht dauerhaft sichtbare UI.

## 8. Phase-2D Scope

Phase 2D bleibt klein und lokal/mock.

Erlaubt:

- wenige manuell definierte Beispiel-Dockingpunkte,
- lokale Mock-Daten,
- optional Debug-/Mock-Visualisierung,
- manuell kuratierte Testverbindungen nur, wenn sie an Dockingpunkten starten
  und enden.

Nicht Teil von Phase 2D:

- keine Persistenz,
- keine Supabase Writes,
- keine SQLite-/SRS-/`word_progress`-Aenderungen,
- keine Reward Bridge,
- keine Ressourcenlogik,
- keine automatische Pfadsuche,
- keine vollstaendige Connector-Generierung,
- keine Longpress-Verschiebung,
- keine Snap-Platzierung,
- keine Social-Backend-Logik.

## 9. Akzeptanzkriterien

Eine spaetere Dockingpunkt-Umsetzung gilt als richtig, wenn:

- Connectoren nicht mehr frei im Space haengen.
- Jede Verbindung an einer sinnvollen Andockstelle startet und endet.
- Dockingpunkte rendererunabhaengig geplant sind.
- Private Inseln und Community-Regionen unterschiedlich behandelt werden.
- Showcase-Inseln nicht claimbar und nicht frei verschiebbar bleiben.
- Community-Regionen feste, kuratierte Andockbereiche besitzen.
- Private Inseln spaeter fuer Longpress/Snap und mehrere eigene Inseln
  erweiterbar bleiben.
- Das System mehrere Connector-Typen unterstuetzen kann, ohne einzelne Bilder
  stark zu strecken.
- Phase 2D lokal/mock bleibt und keine Backend-, SRS-, Reward- oder
  Persistenz-Seiteneffekte erzeugt.

