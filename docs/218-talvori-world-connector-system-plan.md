# Talvori Welt Phase 2C/2D: Connector-System-Plan

Stand: 2026-06-03

Dieses Dokument plant eine einfache lokale Connector-Logik fuer die Talvori-Welt. Es beschreibt, wie Inseln spaeter organisch ueber modulare Verbindungsstuecke verbunden werden koennen, ohne ein einzelnes Brueckenbild zu strecken.

Es ist ein reines Planungsdokument. Es wurden keine Dart-/Flutter-Dateien, keine Assets, keine Supabase-Daten, keine SQLite-/Vokabeldaten, keine SRS-Daten, kein `word_progress`, keine Reward Bridge, keine Persistenz, keine Secrets und keine Release-Artefakte geaendert.

## 1. Ziel der Connector-Logik

Inseln sollen in der Talvori-Welt spaeter nicht nur frei im Space schweben. Sie sollen modular, organisch und visuell nachvollziehbar verbunden werden koennen.

Ziele:

- Inseln modular verbinden,
- unterschiedliche Distanzen abbilden,
- unterschiedliche Richtungen und Andockpunkte unterstuetzen,
- Verbindungen natuerlich und leicht unregelmaessig wirken lassen,
- keine sichtbare Bildstreckung erzeugen,
- Connectoren zunaechst lokal/mock halten.

Wichtig:

Ein einzelnes Brueckenbild wird nicht skaliert, um jede Distanz zu fuellen. Stattdessen kombiniert die App mehrere Connector-Assets.

## 2. Connector-Typen

Vorhandene Connector-Typen:

| Typ | Rolle |
| --- | --- |
| `short` | kurze Verbindung zwischen nahen Inseln |
| `medium` | mittlere Verbindung als Standardsegment |
| `long` | laengeres Segment fuer groessere Distanzen |
| `corner_left` | organischer Richtungswechsel nach links |
| `corner_right` | organischer Richtungswechsel nach rechts |
| `end_cap` | sauberer Abschluss an Inselrand oder offenem Ende |
| `small_platform` | kleiner Zwischenknoten, Dockingpunkt oder Pause im Weg |

Optionale spaetere Typen:

- `broken`,
- `mist_path`,
- `energy_bridge`,
- `floating_fragments`.

Diese spaeteren Typen koennen Verbindungslinien abwechslungsreicher machen, sind aber nicht Teil des ersten lokalen Slices.

## 3. Grundlogik

Wenn zwei Inseln verbunden werden sollen, berechnet die App:

1. Startpunkt an Insel A,
2. Zielpunkt an Insel B,
3. Abstand zwischen den Punkten,
4. grobe Richtung,
5. benoetigte Connector-Kombination.

Die Berechnung arbeitet auf Weltkoordinaten, nicht auf Bildschirmkoordinaten. Dadurch bleibt die Logik unabhaengig von Zoom, Pan, Portrait und Landscape.

Grundidee:

- Inselobjekte definieren moegliche Dockingpunkte.
- Die Connector-Logik waehlt eine Segmentfolge.
- Der Renderer platziert die Segmente mit `worldPosition`, `rotation`, `scale` und `zIndex`.
- Die Welt bleibt rendererunabhaengig gedacht, damit Flutter, Flame oder spaetere Renderer die gleiche Logik nutzen koennen.

## 4. Regellogik Nach Distanz

### Kurze Distanz

Empfohlene Kombination:

- `end_cap + short + end_cap`

Einsatz:

- zwei nahe Inseln,
- kurzer visueller Uebergang,
- keine Zwischenplattform notwendig.

### Mittlere Distanz

Empfohlene Kombination:

- `end_cap + medium + end_cap`

Optional:

- kleine Felsfragmente,
- leichter Versatz,
- ein `short` als Ergaenzung, wenn die Distanz knapp nicht passt.

### Lange Distanz

Empfohlene Kombinationen:

- `end_cap + medium + small_platform + medium + end_cap`,
- `long + small_platform + medium`.

Wichtig:

- Die App streckt kein einzelnes Bild.
- Laengere Distanzen entstehen durch Segmentkombinationen.
- `small_platform` kann als natuerlicher Ruhepunkt und Dockingknoten dienen.

### Sehr Lange Distanz

Sehr lange Distanzen verwenden mehrere Segmente:

- mehrere `medium`- oder `long`-Segmente,
- kleine Zwischenplattformen,
- optional spaeter `broken`, `mist_path` oder `floating_fragments`.

Regel:

Je laenger die Verbindung, desto eher braucht sie Zwischenknoten. Eine sehr lange gerade Bruecke wirkt technisch und weniger organisch.

### Richtungswechsel

Wenn eine Verbindung nicht gerade laufen soll:

- `corner_left` oder `corner_right` verwenden,
- `small_platform` als natuerlichen Knoten einsetzen,
- Verbindung in zwei oder mehr Teilstrecken zerlegen.

Beispiele:

- `end_cap + short + corner_left + small_platform + medium + end_cap`,
- `end_cap + medium + small_platform + corner_right + short + end_cap`.

## 5. Organischer Look

Connectoren sollen nicht wie ein technisches Raster wirken.

Look-Regeln:

- keine perfekte technische Linie,
- keine Rasteroptik,
- keine harten 90-Grad-Ketten ohne organische Unterbrechung,
- leichte Versatzwerte erlauben,
- kleine Rotationsunterschiede erlauben,
- unterschiedliche Segmentlaengen kombinieren,
- kleine Zwischenplattformen fuer lange Wege nutzen,
- Inseln duerfen nicht ueberlappen.

Die Versatzwerte sollen deterministisch sein, z. B. ueber die Connector-ID als Seed. Dadurch bleibt die Verbindung stabil, wirkt aber trotzdem weniger maschinell.

Beispiel:

- `connector.id` erzeugt einen kleinen stabilen Offset,
- jedes Segment bekommt eine geringe Rotationsvariation,
- Scale bleibt in einem engen Bereich, damit Assets nicht verzerrt wirken.

## 6. Datenmodell Lokal/Mock

### WorldConnector

```dart
class WorldConnector {
  final String id;
  final String fromIslandId;
  final String toIslandId;
  final List<WorldConnectorSegment> segments;
  final bool isUnlocked;
  final String visualState;
}
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Connector-ID |
| `fromIslandId` | Startinsel |
| `toIslandId` | Zielinsel |
| `segments` | konkrete Segmentfolge |
| `isUnlocked` | ob Verbindung nutzbar ist |
| `visualState` | z. B. `normal`, `preview`, `locked`, `disabled` |

### WorldConnectorSegment

```dart
class WorldConnectorSegment {
  final String id;
  final String connectorType;
  final String assetPath;
  final Offset worldPosition;
  final double rotation;
  final double scale;
  final int zIndex;
}
```

Felder:

| Feld | Bedeutung |
| --- | --- |
| `id` | stabile Segment-ID |
| `connectorType` | `short`, `medium`, `long`, `corner_left`, `corner_right`, `end_cap`, `small_platform` |
| `assetPath` | Asset-Pfad des Moduls |
| `worldPosition` | Position im World Canvas |
| `rotation` | Ausrichtung in Radiant oder Grad, je nach Renderer-Konvention |
| `scale` | dezente Groessenanpassung, keine Distanzstreckung |
| `zIndex` | Zeichenreihenfolge im World Canvas |

## 7. Dockingpunkte

Community-Regionen koennen feste Dockingpunkte haben.

Private Inseln bekommen spaeter Snap-/Docking-Zonen:

- Nord,
- Ost,
- Sued,
- West,
- optionale Diagonalpunkte,
- spaeter spezielle Bruecken-/Hafenpunkte.

Nicht jede Insel muss verbunden sein.

Moegliche Verbindungszustaende:

- `locked`: Verbindung ist sichtbar vorbereitet, aber noch gesperrt,
- `preview`: Verbindung wird als Vorschau gezeigt,
- `disabled`: Verbindung existiert in den Daten, wird aber nicht gerendert,
- `normal`: Verbindung ist sichtbar und nutzbar.

Private Inseln:

- koennen spaeter ueber Snap-Zonen verbunden werden,
- sollen nicht frei chaotisch verbunden werden,
- duerfen beim Platzieren keine anderen Inseln ueberlappen.

Community-Regionen:

- koennen feste, kuratierte Verbindungen besitzen,
- duerfen nicht frei durch Nutzer verschoben werden,
- koennen als stabile Weltknoten dienen.

## 8. Phase 2C/2D Scope

Fuer Phase 2C/2D bleibt die Connector-Logik klein und lokal.

Erlaubt:

- lokale Mock-Verbindungen,
- feste Beispiel-Connectoren zwischen einigen Inseln,
- rendererunabhaengige Datenmodelle vorbereiten,
- Segmente aus vorhandenen Connector-Assets zusammensetzen,
- einfache Distanzklassen und Segmentfolgen.

Nicht Teil dieses Dokuments:

- keine Persistenz,
- keine Supabase Writes,
- keine Reward Bridge,
- keine Ressourcenlogik,
- keine automatische Pfadsuche,
- keine Longpress-Verschiebung,
- keine echte Social-/Freundeslogik,
- keine Cloud-Welt.

Longpress-Verschiebung eigener Inseln bleibt in `docs/217-talvori-world-start-island-claiming-plan.md` als spaetere Funktion vorgesehen, wird hier aber nicht implementiert.

## 9. Akzeptanzkriterien

Das Connector-System gilt fuer einen spaeteren lokalen Slice als passend vorbereitet, wenn:

- Connectoren modular kombiniert wirken,
- keine sichtbare Bildstreckung genutzt wird,
- kurze, mittlere, lange und sehr lange Distanzen abbildbar sind,
- Richtungswechsel ueber Corner-Module moeglich sind,
- `small_platform` als natuerlicher Zwischenknoten nutzbar ist,
- Verbindungen organisch statt technisch wirken,
- Inseln nicht ueberlappt werden,
- nicht jede Insel zwangsweise verbunden sein muss,
- Community-Regionen feste Dockingpunkte haben koennen,
- private Inseln spaeter Snap-/Docking-Zonen bekommen koennen,
- das System lokal/mock starten kann,
- der Renderer austauschbar bleibt.

## 10. Offene Entscheidungen

Vor einer spaeteren Implementierung muessen noch entschieden werden:

- ob Connectoren automatisch aus Distanzklassen generiert oder initial manuell kuratiert werden,
- wie Dockingpunkte in den Insel-Mockdaten gespeichert werden,
- welche Segmentgroessen im aktuellen World Canvas gut wirken,
- ob locked/preview Connectoren sichtbar sein sollen,
- ob Connectoren vor oder hinter Inselassets gerendert werden,
- wie stark organische Versatzwerte sein duerfen, ohne Taps oder Lesbarkeit zu stoeren.

Empfehlung fuer den ersten Implementierungsblock:

Mit wenigen kuratierten Mock-Verbindungen starten. Erst wenn die visuelle Wirkung stimmt, eine einfache automatische Segmentauswahl hinzufuegen.
