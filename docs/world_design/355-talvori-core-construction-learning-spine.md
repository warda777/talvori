# M16-BI: Talvori Core Construction Learning Spine

Stand: 2026-06-09

Status: `Dokumentations-/Strategie-Slice / keine Implementierung`

## 1. Zweck

M16-BI legt den zentralen Produkt-Ruecken fuer Talvori Welt verbindlich fest.
Die bisherigen Uferhain-, Slot-, Kategorie-, Interaction- und BuildChoice-
Gates bereiten die Flaeche vor; dieses Dokument definiert, was darauf
eigentlich gespielt wird.

Verbindliche Produktlesart:

```text
Talvori ist ein Aufbau-Spiel.
Lernen ist der Motor.
Sichtbares Ziel ist Welt-, Grundstuecks-, Gebaeude-, Raum-,
Container- und Detailausbau.
```

Talvori ist damit kein Insel-Menue mit einzelnen Lernraetseln. Nutzer sollen
spielen, bauen, entdecken, loesen und ihre Welt ausbauen. Lernen passiert als
Wirkung dieser Spielhandlungen und bleibt fachlich der Hauptnutzen, aber nicht
das sichtbare Pflichtgefuehl.

M16-BI ist ein Strategie-Gate. Es gibt keinen Code, keine App-Integration,
keine Route, keine Persistenz, keine Assets, keine Economy, keinen BuildState
und keine produktive Mechanik frei.

Nachtrag M16-BJ:

`356-first-local-construction-learning-vertical-slice-gate.md` konkretisiert
den ersten lokalen Anwendungspunkt dieses Spines: Uferhain -> Startslot ->
Kategorie Zuhause -> BuildChoice Haus -> Grundstueckszoom ->
Fundament-Candidate -> Bauteile-sortieren-Lernhandlung -> lokales
Fundament-Feedback. M16-BJ bleibt ein Prompt-Gate und gibt weiterhin keinen
BuildState, keine Persistenz, keine Assets und keine App-Integration frei.

## 2. Non-Goals und Stop-Regeln

M16-BI erzeugt nicht:

- keine Implementierung,
- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine neue Seite,
- keine Tests,
- keine Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein Build-Wheel-Code,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Economy-Implementierung,
- keine Muenzen-Implementierung,
- keine BuildChoice-Implementierung,
- keine Produktivmechanik-Freigabe.

Alle Bau-, Ausbau-, Raum-, Container- und Objektbeispiele in diesem Dokument
sind fachliche Spine-Planung. Sie sind keine Runtime-Daten, keine Assets,
keine persistenten Entscheidungen und keine produktiven States.

## 3. Gelesene Grundlagen

| Dokument | Beitrag fuer M16-BI |
| --- | --- |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste, Dashboard und neue Spine-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Prompt-Regeln fuer kuenftige Slices. |
| `345-play-first-learning-experience-doctrine.md` | Talvori muss Spiel sein, dessen Spielhandlungen Lernnutzen erzeugen. |
| `350-interaction-pattern-decision-matrix.md` | UI-Muster werden nach Aktion, Risiko, Informationsmenge und Weltkontext gewaehlt. |
| `351-starter-island-infrastructure-strategy-gate.md` | Trennt Base Terrain, Free Slots, Templates, Varianten, Unlocks und BuildChoice. |
| `353-starter-island-identity-biome-and-category-scope-gate.md` | Definiert Uferhain, Starter-Kategorien, Terrain-Varianten und BuildChoice-Hierarchie. |
| `354-uferhain-preview-readiness-review.md` | Bestaetigt die aktuelle Uferhain-Preview als Greybox-Basis fuer naechste Slices. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, keine automatische Platzierung. |
| `331-minimal-word-outcome-detail-gate.md` | Outcomes, Queue-Ausgaenge, ContextCard, ContainerItem und BuildState-Grenzen. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | World Loop, Plot Family, BuildChoice und Undo bleiben Candidates/Previews. |
| `339-theme-island-resizing-and-remaining-world-rules-gate.md` | Capability ist Erlaubnis, keine Pflichtbelegung oder Build-Ausloesung. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Landmarken-vor-Kleinteilen, Container/Depth und Mobile-Dichte. |

## 4. Core Construction Learning Spine

Der Core Construction Learning Spine ist die fuehrende End-to-End-Reihenfolge
fuer kuenftige MVP-, Gameplay-, BuildChoice-, World-, UI- und
Implementierungs-Slices.

```text
Insel waehlen
-> freien Slot waehlen
-> Hauptkategorie waehlen
-> konkrete BuildChoice waehlen
-> in Grundstueck hineinzoomen
-> Bauphase starten
-> spielerische Lernaufgabe loesen
-> lokaler Bau-/Ausbau-Candidate erscheint
-> naechster Bauabschnitt
-> Gebaeude betreten
-> Raum auswaehlen
-> Moebel/Objekt waehlen
-> Container/Fach/Schublade oeffnen
-> Dinge befuellen
-> neue Mission / neues Wort / neuer Kontext
```

Spine-Regeln:

- Jede Stufe muss als Spielhandlung lesbar sein.
- Lernen unterstuetzt eine Bau-, Ausbau-, Entdeckungs-, Raum- oder
  Containerhandlung.
- Nutzer sehen Fortschritt als Weltveraenderungsmoeglichkeit, nicht als
  Lernpunktestand.
- Jede echte Mutation bleibt blockiert, bis BuildState, Persistenz, Undo,
  Assets, Tests und App-Integration eigene Gates haben.
- Bis dahin entstehen nur lokale Candidates, Previews, Bubbles, ContextCards,
  Archiv-Hinweise oder spaetere Gate-Aufgaben.

## 5. Beispiel: Zuhause / Haus

Konkreter Spine fuer ein spaeteres Zuhause-Beispiel:

```text
Uferhain waehlen
-> freien Slot waehlen
-> Kategorie Zuhause
-> BuildChoice Haus
-> Grundstueck zoomt auf
-> Fundament
-> Aussenwaende
-> Innenwaende
-> Fenster
-> Tueren
-> Dach
-> Haus betreten
-> Kueche / Wohnzimmer / Schlafzimmer
-> Moebel waehlen
-> Schrank / Fach / Schublade oeffnen
-> Teller / Besteck / Schluessel einsortieren
```

Wie Lernen dabei wirkt:

| Bau-/Ausbau-Stufe | Spielhandlung | Lernnutzen | Blockiert |
| --- | --- | --- | --- |
| Slot waehlen | Ort auf dem Uferhain antippen. | Terrain und Kategorie als Bedeutungskontext verstehen. | Placement, Persistenz. |
| BuildChoice Haus | Hausidee visuell vergleichen. | `Haus` als WorldCandidate mit Sense/User Choice einordnen. | Showcase-Code ohne Gate, BuildState. |
| Fundament | richtige Teile/Begriffe in der Szene zuordnen. | Grundbegriffe, Lage, Kontext. | `foundation_started` als State. |
| Waende / Fenster / Tueren | Objekt- oder Kontextaktion loesen. | Wortfelder Haus, Raum, Oeffnung, Richtung. | Asset-/Bauzustand. |
| Raum betreten | Raum als neuer Fokusbereich. | Kueche/Wohnzimmer/Schlafzimmer-Kontext. | Interior-Persistenz. |
| Moebel waehlen | kleine visuelle Auswahl. | Objektkategorien und Funktionen. | Moebel-Asset/Build. |
| Container oeffnen | Schublade/Fach/Kiste als Fokusraum. | TinyObjects wie Schluessel, Teller, Besteck auffindbar machen. | Inventar-Dump, TinyObject-Wolke. |

Alles bleibt bis spaeterer Gates lokal, Preview oder Candidate. Kein
BuildState, keine Persistenz, keine Assets, keine Economy und keine
Produktivfreigabe.

## 6. BuildChoice-Hierarchie

Die Hauptkategorie ist nur die grobe Richtung. Konkrete Dinge wie Garage,
Vorhof, Terrasse, Pool, Teich oder Outdoor-Sauna gehoeren nicht in das erste
Kategorie-Wheel. Sie sind spaetere BuildChoice-/Showcase-Optionen unter einer
Hauptkategorie.

| Hauptkategorie | Spaetere BuildChoice-/Showcase-Kandidaten | Spine-Lesart |
| --- | --- | --- |
| Zuhause | Haus, Zimmer, Garage, Vorhof, Terrasse | persoenlicher Ausbau, Raum- und Alltagskontext. |
| Garten | Gartenbereich, Teich, Pool, Outdoor-Sauna, Blumenbereich | Natur, Wasser, Aussenraum und ruhige Objektwahl. |
| Ufer/Wasser | Steg, Uferplatz, Wasserweg, kleiner Bootsort | Wasser-, Bewegungs- und Mehrdeutigkeitskontext. |
| Werkstatt | Werkbank, Garage-Werkstatt, Bootswerkstatt | Machen, Reparieren, Tool-/ActionChallenge. |
| Markt | Marktstand, Laden, Hafenmarkt-Idee | Essen, Kaufen, Handeln ohne Economy-Code. |
| Lager | Kiste, Tasche, Schuppen, Vorratsplatz | Container-Depth und Findability fuer kleine Dinge. |
| Wissen | Lernort, Aussichtspunkt, Bibliothek-Idee | Bedeutung, Denkaufgabe, ContextCard. |
| Archiv | Wortarchiv, Erinnerungsort, Bedeutungssammlung | Wiederfinden, Sense, Beispiele. |
| Spaeter | Ablage, Rueckzugsort, unsichere Woerter | ruhiger Fallback und sichere Ausgaenge. |

Regel:

```text
Kategorie = Richtung.
BuildChoice = konkrete Bauidee.
Bauabschnitt = spielbare Aufgabe.
Container/Depth = kleine Dinge und Detailwissen.
BuildState = blockiert.
```

## 7. Learning-as-Play-Regel

Jede Lernaufgabe muss als Spielhandlung erscheinen. Erlaubte Formen:

- suchen,
- bauen,
- reparieren,
- kombinieren,
- sortieren,
- entdecken,
- Weg waehlen,
- Objekt einsetzen,
- Kontext verstehen,
- Container oeffnen,
- Mission abschliessen.

Nicht erlaubt als Hauptgefuehl:

- Vokabeltest als Hauptbild,
- isolierte Quizkarte,
- Lernfenster ueber der Welt,
- Multiple Choice ohne Weltauftrag,
- XP-/Timer-/Streak-Druck,
- Review-Zwang,
- Textwand,
- Punktejagd ohne Bau-/Weltwirkung.

Pflichtfrage fuer jeden spaeteren Lernmoment:

```text
Welche Bau-, Ausbau-, Welt-, Raum- oder Containeraktion wird durch diese
Lernhandlung verstaendlicher, moeglich oder sichtbarer?
```

Wenn diese Frage nicht beantwortet werden kann, ist der Slice kein
Talvori-Spine-Slice und darf keine Lernspiel-Implementierung freigeben.

## 8. Beispiel: Bank richtig einordnen

Der M16-BH-Versuch war als Uferplatz-Greybox nuetzlich, aber produktstrategisch
unvollstaendig, wenn `Bank` als isolierter Lernmoment dominiert.

Problematische Lesart:

```text
Ufer-Slot antippen
-> Bank-Frage erscheint
-> Nutzer waehlt Bedeutung
-> Lernmoment endet
```

Das prueft Kontext, aber noch nicht den fuehrenden Produkt-Ruecken. Es kann
wie ein einzelnes Lernraetsel auf einer Insel wirken.

Korrekte Spine-Einordnung:

- `Bank` ist ein Kontextmoment am Uferplatz.
- Oder `Bank` ist ein Objekt/Ort im Garten-, Ufer- oder Terrassen-Ausbau.
- Oder `Bank` ist ein Archiv-/Bedeutungsmoment nach einer Spielhandlung.
- Die Entscheidung hilft beim Ort, beim Bau-/Ausbau-Verstaendnis oder beim
  Kontext des aktuellen Weltmoments.

Beispielhafte Spielhandlung:

```text
Spieler baut oder prueft eine Uferterrasse.
Tali zeigt auf den Fluss: "Was meint Bank hier?"
Optionen: Sitzbank, Geldinstitut, Ufer.
Richtig: Ufer.
Feedback: Der Ort klaert die Bedeutung; der Uferplatz-Candidate wird
fachlich verstaendlicher.
```

Weiteres Beispiel:

```text
Spieler waehlt Garten + Ufer.
Eine spaetere BuildChoice koennte "Sitzbank am Ufer" oder "Uferweg" zeigen.
Dann klaert `Bank`, ob ein Sitzobjekt oder das Flussufer gemeint ist.
```

Grenze:

`Bank` darf kein automatisch gebautes Objekt, kein Placement, kein SRS-Write,
kein Reward und kein BuildState werden. Der Bank-Moment bleibt Weltauftrag,
ContextCard, Archiv-Hinweis oder Candidate-Hilfe bis eigene Gates mehr
erlauben.

## 9. UI-Muster pro Spine-Stufe

| Spine-Stufe | Primaeres UI-/Spielmuster | Sekundaer | Bewusst nicht |
| --- | --- | --- | --- |
| Insel waehlen | Map / Showcase | Carousel fuer Insel-Familien | einfache Liste als Hauptgefuehl |
| Slot waehlen | direkte Weltaktion auf der Insel | kleines Bottom-HUD | neue Seite fuer einfachen Tap |
| Hauptkategorie waehlen | kompaktes In-place-Wheel oder Bottom-HUD | kleine Kategoriegruppe | grosses Fenster, harte Terrain-Filter |
| BuildChoice waehlen | Showcase-Seite oder Grundstuecks-Preview | Carousel/Card-Auswahl | erstes Wheel mit Detailbauten ueberladen |
| Bauphase | Grundstuecksansicht | Companion-Bubble / HUD | BuildState ohne Gate |
| Lernspiel | Weltaktion oder Objektaktion | Bubble, Schild, ContextCard-HUD | Lernfenster oder Quizscreen als Hauptflaeche |
| Innenausbau | Raumansicht / Showcase / Werkbank | kleine Objektwahl | Mobelliste als Formular |
| Container | Container-/Inventar-/Detailansicht | Fokusraum mit 3-5 Objekten | Inventar-Dump, TinyObject-Wolke |
| Archiv | Sammlung/Detailseite oder Archiv-Ort | ContextCard | Pop-up fuer lange Inhalte |
| Spaeter / Ablage | ruhiger Fallback | Later/Change/Archiv | Schuld, Verlust, Druck |

Interaction-Regel:

Die UI-Art folgt der Spine-Stufe. Kleine direkte Weltaktionen bleiben klein.
Grosse visuelle Entscheidungen bekommen spaeter Showcase-/Werkbank-/Raum-
Muster. Kein UI-Muster darf den Weltauftrag in ein Lernformular verwandeln.

## 10. MVP Vertical Slice

Erste sinnvolle kleine vertikale MVP-Preview:

```text
Uferhain
-> Startslot
-> Kategorie Zuhause
-> BuildChoice Haus
-> Grundstueckszoom
-> Fundament-Candidate
-> eine spielerische Lernaufgabe
-> lokales Fundament-Feedback
-> keine Persistenz
```

Warum diese Variante zuerst:

- Sie beweist den fuehrenden Construction-Spine besser als ein isolierter
  Bank-Moment.
- Sie verbindet Insel, Slot, Kategorie, BuildChoice, Bauabschnitt und Lernen
  in einem kleinen End-to-End-Pfad.
- `Haus` ist ein starker Aufbau-Anker, aber bleibt Candidate und braucht
  keine Assets, wenn es als Greybox/Fundament-Preview geplant wird.
- Der Slice kann zeigen, ob Lernen wirklich Bau-/Weltfortschritt erklaert,
  statt nur eine Weltdeko um eine Lernfrage zu legen.

Alternative spaeter:

```text
Uferhain
-> Uferplatz
-> kleine Uferterrasse / Steg-Idee
-> Bank-Kontextmoment
-> lokale Bedeutungsklaerung
-> kein BuildState
```

Die Alternative ist geeignet, wenn der naechste Slice bewusst Ufer- und
Mehrdeutigkeitskontext pruefen soll. Sie ist aber nicht der beste erste
Core-Spine-Beweis, weil sie zu leicht wieder als einzelner Lernmoment gelesen
wird.

Empfehlung:

```text
Zuerst: Zuhause -> Haus -> Fundament-Candidate -> spielerische Lernaufgabe.
Danach: Bank am Ufer als Kontextmoment innerhalb eines Ufer-/Terrassen- oder
Uferplatz-Ausbaus.
```

## 11. Was ab jetzt verboten ist

Kuenftige Slices duerfen keine isolierten Lernmomente mehr bauen, ohne die
Spine-Fragen zu beantworten:

- Welche Bau-/Ausbau-/Weltaktion wird unterstuetzt?
- Welche Spine-Stufe ist betroffen?
- Was sieht der Spieler als Fortschritt?
- Welche Lernhandlung erzeugt oder erklaert diesen Fortschritt?
- Warum fuehlt es sich wie Spiel an?
- Warum ist es kein Lernfenster?
- Welche Safe Exits bleiben sichtbar?
- Welche Stop-Regeln verhindern BuildState, Placement, Persistenz, Assets,
  SRS-/`word_progress`-Writes und App-Integration?

Verbotene Slice-Muster:

- `Wort X` als isolierte Quiz-Bubble ohne Weltauftrag.
- Meaning Puzzle ohne Bau-, Raum-, Container- oder Weltbezug.
- Kategorie-Wheel als Ziel statt als Vorbereitung fuer Spielhandlung.
- BuildChoice-Unterideen im ersten Wheel statt Showcase-/BuildChoice-Gate.
- Lernfenster ueber einer Insel als Hauptspielraum.
- Reward, XP, Timer oder Streak als Ersatz fuer sichtbaren Weltfortschritt.
- Bank, Haus, Garage, Garten oder aehnliche Woerter als automatische
  Platzierung.

## 12. M16-T-ID-Entscheidung

| ID | Status | Entscheidung |
| --- | --- | --- |
| `M16T-SPINE-001` | `[x]` | Core Construction Learning Spine ist als fuehrender End-to-End-Loop definiert. |
| `M16T-SPINE-002` | `[x]` | BuildChoice-Hierarchie von Hauptkategorie zu Objekt, Raum und Container ist dokumentiert. |
| `M16T-SPINE-003` | `[x]` | Jede Lernaufgabe muss eine Bau-/Ausbau-/Welt-/Raum-/Containeraktion unterstuetzen. |
| `M16T-SPINE-004` | `[x]` | Erste Vertical-Slice-Empfehlung ist Zuhause -> Haus -> Fundament-Candidate -> spielerische Lernaufgabe. |
| `M16T-SPINE-005` | `[x]` | Isolierte Lernmomente ohne Welt-/Bauzweck sind fuer kuenftige Slices blockiert. |

## 13. Prompt-Regel fuer kuenftige Slices

Kuenftige World-, UI-, BuildChoice-, Gameplay-, Quest-, Challenge-,
Learning-Loop- und Implementierungs-Slices muessen M16-BI lesen, wenn sie
Weltfortschritt, Spielmoment, Lernhandlung, BuildChoice, Innenausbau,
Container/Depth oder Uferhain betreffen.

Jeder solche Prompt muss beantworten:

- Welche Spine-Stufe wird beruehrt?
- Welche Bau-/Ausbau-/Weltaktion wird unterstuetzt?
- Welcher sichtbare Fortschritt entsteht?
- Welche Lernhandlung erzeugt oder erklaert diesen Fortschritt?
- Welche BuildChoice-, Raum- oder Container-Ebene ist betroffen?
- Warum ist es kein isoliertes Lernfenster?
- Welche Interaction-Pattern-Entscheidung aus `350` passt?
- Ist es MVP, nach MVP oder blockiert?
- Welche Stop-Regeln verhindern BuildState, Persistenz, Assets,
  SRS-/`word_progress`-Writes und App-Integration?

## 14. Entscheidung

M16-BI entscheidet:

```text
Talvori fuehrt ueber einen Construction Learning Spine.
Spieler bauen und erkunden ihre Welt.
Lernen treibt Bau-, Ausbau-, Raum-, Container- und Kontextfortschritt.
Isolierte Lernmomente sind ab jetzt kein ausreichender Slice-Zweck mehr.
```

Damit bleibt Uferhain die erste Weltgrundlage, aber der naechste Fortschritt
soll nicht noch ein einzelnes Raetsel sein. Der naechste sinnvolle kleine
Vertical Slice soll den Bau-Spine beweisen: Slot -> Kategorie -> BuildChoice
-> Bauabschnitt -> spielerische Lernhandlung -> lokaler Candidate, ohne
BuildState, Persistenz, Assets oder App-Integration.
