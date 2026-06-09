# M16-BJ: First Local Construction-Learning Vertical Slice Gate

Stand: 2026-06-09

Status: `Dokumentations-/Prompt-Gate-Slice / keine Implementierung`

## 1. Zweck

M16-BJ konkretisiert den ersten lokalen Construction-Learning-Vertical-Slice,
bevor Code entsteht. Das Ziel ist ein praeziser Bau-/Lern-Ablauf, der spaeter
als kleiner lokaler Preview-Code-Slice umgesetzt werden kann.

Dieses Gate verhindert, dass Talvori wieder in isolierte Wort-, Bank- oder
Quizmomente zerfaellt. Der erste Beweis muss zeigen:

```text
Der Spieler baut.
Die Lernhandlung treibt diesen Bau an.
Das sichtbare Gefuehl ist Spiel, nicht Pflichtlernen.
```

M16-BJ gibt keine Implementierung, keine App-Integration, keine Route, keine
Persistenz, keine Assets, keine Tests, keine BuildChoice-Implementierung, keine
BuildState-Freigabe und keine Economy frei.

Nachtrag M16-BL:

M16-BJ definiert fachlich den ersten Foundation-Slice. M16-BL praezisiert die
Umsetzungsrichtung: Der erste Code-Beweis darf nicht als UI-Flow-Karte mit
vielen Textflaechen entstehen, sondern muss als Game-like Showcase-/Kamera-/
Bauplatz-Preview gedacht werden. Die M16-BK-Preview war technisch moeglich,
aber zu UI-lastig; der empfohlene naechste Code-Slice ist deshalb M16-BM
Game-like Island Showcase to Foundation Camera Preview.

## 2. Non-Goals und Stop-Regeln

Dieser Slice erzeugt nicht:

- keine Flutter-/Dart-Codeaenderung,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine neue Seite,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets oder Asset-Dateien unter `assets/`,
- kein Build-Wheel-Code,
- keine BuildChoice-Implementierung,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Economy,
- keine Muenzen,
- keine Produktivmechanik-Freigabe.

Alle Begriffe wie Haus, Fundament, Bauphase, Candidate, Feedback und
Grundstueckszoom sind fachliche Preview-Grenzen. Sie sind keine Runtime-States
und keine persistenten Weltentscheidungen.

## 3. Gelesene Grundlagen

| Dokument | Beitrag fuer M16-BJ |
| --- | --- |
| `355-talvori-core-construction-learning-spine.md` | Fuehrender Bau-/Lern-Spine und Verbot isolierter Lernmomente ohne Welt-/Bauzweck. |
| `353-starter-island-identity-biome-and-category-scope-gate.md` | Uferhain-Identitaet, Kategorie-Scope, sichtbare Nutzerbegriffe und BuildChoice-Hierarchie. |
| `351-starter-island-infrastructure-strategy-gate.md` | Fixe Infrastruktur, freie Slots, Template-/Variantenlogik und BuildState-Grenzen. |
| `354-uferhain-preview-readiness-review.md` | Uferhain-Preview ist als Greybox-Basis bereit, braucht aber den Spine als naechsten Produktbeweis. |
| `350-interaction-pattern-decision-matrix.md` | UI-Muster nach Aktion, Risiko, Informationsmenge und Spielkontext waehlen. |
| `345-play-first-learning-experience-doctrine.md` | Play-First und Island-First bleiben Pflichtfilter. |
| `330-minimal-playable-learning-loop-contract.md` | Lernen erzeugt Moeglichkeit, nicht automatische Platzierung oder Persistenz. |
| `331-minimal-word-outcome-detail-gate.md` | Word Outcome, ContextCard, Candidate und BuildState-Grenzen. |
| `338-world-loop-plot-family-and-buildchoice-gate.md` | PlotFamily, BuildChoice und Confirm/Later/Change bleiben Candidates/Previews. |
| `337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Dichte, Landmarken-vor-Kleinteilen und Exit-Erreichbarkeit. |

## 4. Gewaehlter Vertical Slice

Der erste lokale Vertical Slice lautet verbindlich:

```text
Uferhain
-> Startslot nahe zentraler Lichtung oder Hub
-> Kategorie Zuhause
-> BuildChoice Haus
-> Grundstueckszoom
-> Fundament-Candidate
-> eine spielerische Lernhandlung
-> lokales Fundament-Feedback
-> kein BuildState
-> keine Persistenz
```

Warum dieser Slice zuerst kommt:

- Er beweist den Construction-Learning-Spine besser als ein isolierter
  Bank-/Wortmoment.
- Er hat ein klares Bauziel: Das erste Fundament fuer ein Haus.
- Er ist fuer Nutzer sofort verstaendlich.
- Er passt zur Uferhain-Starterinsel und zur Kategorie `Zuhause`.
- Er bleibt klein genug fuer eine lokale Preview ohne Assets, Datenmodell oder
  App-Integration.
- Er verhindert, dass Lernen als Quizfenster neben der Welt steht.

## 5. Spine-Stufen konkret

| Stufe | Was sieht der Spieler? | Was tut der Spieler? | Lernhandlung | Sichtbarer Fortschritt | Blockiert |
| --- | --- | --- | --- | --- | --- |
| Insel sichtbar | Uferhain mit freien Startslots und ruhigen Erweiterungsslots. | Er orientiert sich und waehlt einen freien Startslot. | keine Pflichtlernhandlung. | Ein moeglicher Bauort wird fokussiert. | Route, Persistenz, Terrain-Editor. |
| Freier Startslot | Ein freier Platz nahe zentraler Lichtung/Hub. | Er tippt den Slot. | Kontext: Dieser Platz kann gestaltet werden. | Slot-HUD oder kompakter Picker erscheint. | BuildState, Placement, Save. |
| Kategorie Zuhause | Kurze Hauptkategorie-Auswahl. | Er waehlt `Zuhause`. | Kategorie als Bedeutungsrahmen fuer Haus-/Alltagswortfeld. | Zuhause-Candidate-Richtung ist lokal gewaehlt. | harte Terrain-Blockade, einmalige Kategoriebelegung. |
| BuildChoice Haus | Eine kleine Haus-Idee, noch kein Gebaeude. | Er waehlt oder bestaetigt `Haus`. | Objektverstaendnis: Haus als konkrete Bauidee. | Haus-Candidate wird vorbereitet. | Showcase-Seite, Asset, BuildChoice-Code als Produktfeature. |
| Grundstueckszoom | Lokale Preview-Ebene mit fokussiertem Bauplatz. | Er schaut vom Inselboard auf den Slot hinein. | Raum-/Baukontext wird enger. | Der Bauplatz wird als Grundstueck lesbar. | Route, neue App-Seite, Persistenzwechsel. |
| Fundament-Candidate | Ghost/Skizze/Markierung fuer das Fundament. | Er startet den ersten Bauabschnitt. | Reihenfolge im Hausbau wird vorbereitet. | Fundament erscheint als Candidate. | `foundation_started`, BuildState, gespeicherter Bauzustand. |
| Lernhandlung | Drei Bauideen am Grundstueck: Fundament, Fenster, Dach. | Er entscheidet, was zuerst zum Bauplatz gehoert. | Bauteile sortieren: Was gehoert zuerst zum Hausbau? | Richtige Wahl staerkt das Fundament-Candidate. | Quizscreen, Score, Timer, XP, Review-Zwang. |
| Lokales Feedback | Kurze Bubble/Schild am Grundstueck. | Er liest oder tippt weiter. | Bedeutung durch Handlung: Erst braucht das Haus festen Grund. | Bauplatz wirkt klarer vorbereitet. | Reward, Persistenz, SRS-/`word_progress`-Write. |
| Abbruch / Zurueck / Spaeter | Sichere Exit-Aktionen bleiben erreichbar. | Er kann zur Insel zurueck, spaeter machen oder aendern. | keine Pflicht. | Kein Verlust, weil nichts gespeichert wurde. | Druck, Streak, Pflichtabschluss. |

## 6. Grundstueckszoom-Boundary

Der Grundstueckszoom ist fuer den ersten Code-Slice keine Route und keine neue
App-Seite. Er ist eine lokale Preview-Ebene innerhalb einer isolierten Preview.

Regeln:

- Aus Inselansicht wird lokal eine Grundstuecksansicht.
- Der gewaehlt Slot bleibt Ursprung der Szene.
- Es gibt keine Navigation, keinen Router-Eintrag und keinen neuen App-Screen.
- Es gibt keinen Persistenzwechsel und keine Datenmodell-Aenderung.
- Zurueck zur Insel bleibt immer moeglich.
- Der Zoom darf spaeter anders geloest werden, aber die MVP-Preview bleibt
  lokal, reversibel und ohne gespeicherten Fortschritt.

## 7. BuildChoice Haus Boundary

BuildChoice ist eine konkrete Bauidee, kein gebautes Objekt.

Fuer M16-BJ gilt:

- Hauptkategorie: `Zuhause`.
- BuildChoice: `Haus`.
- Unterideen wie Garage, Terrasse, Zimmer, Vorhof, Gartenhaus oder Innenraum
  bleiben spaeteren BuildChoice-/Showcase-Gates vorbehalten.
- `Haus` erzeugt nur einen lokalen Haus-Candidate.
- Es gibt kein gebautes Haus, kein Asset, keinen BuildState und keine
  Persistenz.

Spielerische Lesart:

- Die Auswahl soll wie ein kleiner Bauentschluss wirken.
- Im ersten Code-Slice darf `Haus` minimal als lokaler Button, Choice oder
  kleine Preview angedeutet werden.
- Eine grosse BuildChoice-/Showcase-Seite ist in M16-BJ nicht freigegeben.

## 8. Bauphase: Fundament-Candidate

Das Fundament ist der erste Bauabschnitt.

Regeln:

- Fundament ist nur Candidate/Preview.
- Es gibt kein `foundation_started`.
- Es gibt keinen gespeicherten Bauzustand.
- Die Darstellung darf als Fundament-Ghost, Skizze, Markierung oder ruhige
  Flaeche am Grundstueck erscheinen.
- Der Bauplatz wirkt vorbereitet, nicht fertig gebaut.
- Tali/Vori darf kurz helfen, aber nicht belehren.
- Keine Textwand.

## 9. Erste spielerische Lernhandlung

Die erste Lernhandlung lautet:

```text
Bauteile sortieren: Was gehoert zuerst zum Hausbau?
```

Beispielablauf:

- Tali zeigt am Grundstueck drei kleine Bauideen:
  - Fundament
  - Fenster
  - Dach
- Der Spieler waehlt, was zuerst zum Bauplatz gehoert.
- Richtige Antwort: `Fundament`.
- Positives Feedback:
  - "Genau. Erst braucht das Haus einen festen Grund."
- Ruhiger Hinweis bei falscher Wahl:
  - "Schau nochmal: Was braucht ein Haus zuerst?"

Pflichtgrenzen:

- Die Aufgabe passiert auf dem Grundstueck.
- Sie wirkt wie Bauhandlung, nicht wie Vokabeltest.
- Kein Quizscreen.
- Keine rote Fehlerlogik.
- Kein Score.
- Kein Timer.
- Kein XP.
- Kein Review-Zwang.
- Kein SRS-/`word_progress`-Write.

## 10. Lernnutzen

Die Lernhandlung unterstuetzt:

- Reihenfolge,
- Objektverstaendnis,
- Haus-/Bau-Wortfeld,
- Kontext,
- Bedeutung durch Handlung.

Der sichtbare Spieler-Satz soll sein:

```text
Ich baue mein erstes Fundament.
```

Der fachliche Nutzen ist Lernen. Das erlebte Spielgefuehl ist Bauen,
Entscheiden und ein erster sichtbarer Weltfortschritt.

## 11. Lokales Feedback

Nach richtiger Handlung:

- Fundament-Candidate wird sichtbar staerker,
- kurze positive Weltreaktion,
- optional kurze Tali/Vori-Bubble,
- keine Persistenz,
- kein BuildState,
- kein Reward,
- kein Asset.

Nach falscher Handlung:

- ruhiger Hinweis,
- keine rote Fehlerfarbe,
- keine Strafe,
- kein Verlust,
- kein Pflichtretry,
- der Spieler kann neu waehlen, zurueck oder spaeter.

## 12. Safe Exits

Sichere Aktionen:

- Zurueck,
- Spaeter,
- Aendern,
- Archiv.

Regeln:

- Der Spieler darf jederzeit abbrechen.
- Kein Pflichtgefuehl.
- Kein Verlusthinweis, weil nichts gespeichert wird.
- Keine Streak-, Timer-, XP- oder Review-Druckmechanik.

## 13. UI-/Interaction-Pattern nach 350

| Spine-Stufe | Gewaehltes Muster | Begruendung |
| --- | --- | --- |
| Insel / Slot | Direkte Weltaktion | Ein freier Slot wird in der Welt angetippt. |
| Kategorie Zuhause | Kleines In-place-Wheel oder kompaktes Bottom-HUD | Kurze Hauptkategorie, wenige Worte, kein Vergleich vieler Objekte. |
| BuildChoice Haus | Kleine lokale Preview, spaeter Showcase | Haus ist konkrete Bauidee; grosse Showcase-Seite bleibt spaeteres Gate. |
| Grundstueckszoom | Lokale Preview-Ebene | Fokus auf Bauplatz ohne Route/App-Seite. |
| Fundament-Aufgabe | Welt-/Objektaktion | Lernen passiert als Bauentscheidung am Grundstueck. |
| Feedback | Kleine Bubble, Schild oder HUD | Rueckmeldung erklaert die Bauhandlung ohne Lernfenster. |

Bewusst verworfen:

- grosse neue Seite,
- isoliertes Lernfenster,
- Quizscreen,
- Drag als Hauptflow,
- Build-Wheel-Code,
- Showcase-Seite in diesem Gate,
- Persistenz,
- produktiver BuildState.

## 14. Bank bewusst parken

Der Bank-Moment wird nicht als naechster isolierter Code-Slice weitergefuehrt.

Grund:

`Bank` kann als einzelner Meaning-Puzzle-Moment zwar funktionieren, beweist aber
den Core Construction Learning Spine nicht ausreichend. Talvori darf nicht zu
einem Inselboard mit einzelnen Lernraetseln werden.

Korrekte spaetere Einordnung:

- Bank als Ufer-Kontextmoment,
- Bank als Terrassen-/Uferplatz-Ausbau,
- Bank als Garten-/Sitzbank-Kontext,
- Bank als Archiv-/Bedeutungsmoment nach einer Weltaktion.

Beispiel:

Der Spieler baut spaeter einen Uferplatz oder eine Terrasse. Tali fragt, was
`Bank` in dieser Szene bedeutet. Die Entscheidung hilft beim Ort-, Bau- oder
Kontextverstaendnis.

Bis dahin gilt:

- kein isolierter Bank-Slice als naechster Code-Schritt,
- kein Bank-Quiz als Hauptbild,
- kein Meaning Puzzle ohne Bau-/Weltauftrag.

## 15. Empfohlener Folge-Code-Slice

Urspruenglicher Folge-Code-Slice:

```text
M16-BK First Local Foundation Construction Preview
```

Korrektur nach M16-BL:

M16-BK bleibt als technischer Zwischenbeweis lesbar, wird aber nicht als
naechste Produkt-Richtung weitergefuehrt. Der neue empfohlene Folge-Code-Slice
ist:

```text
M16-BM Game-like Island Showcase to Foundation Camera Preview
```

Ziel fuer M16-BM:

- Insel-Showcase mit Uferhain im Zentrum,
- Insel betreten,
- Slot im Weltbild antippen,
- Kamera/Zoom ins Grundstueck,
- Haus/Fundament als visuelle Bauidee,
- Bauteil-Auswahl direkt am Bauplatz,
- Fundament wird sichtbar staerker,
- minimale HUD/Bubbles,
- kein BuildState,
- keine Persistenz,
- keine Assets,
- keine Route.

Urspruengliche erlaubte Datei-Strategie fuer M16-BK, inzwischen durch M16-BL
abgeloest:

| Option | Dateien | Bewertung |
| --- | --- | --- |
| Option A | `lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview.dart` | Naheliegend, aber riskanter: Die bestehende Board-Preview kann wieder mit Spielmoment-, BuildChoice- und Lernlogik ueberladen werden. |
| Option B | `lib/features/world/local_world/ui/widgets/local_foundation_construction_spine_preview.dart` plus optional `lib/features/world/local_world/ui/widgets/local_foundation_construction_spine_preview_main.dart` | Empfohlen: isoliert, klar startbar, prueft den Spine ohne die Uferhain-Board-Preview weiter aufzublaehen. |

Historische Empfehlung aus M16-BJ:

Option B. Diese Empfehlung war fuer den ersten technischen Foundation-Beweis
brauchbar, aber nach M16-BL nicht mehr die fuehrende Produkt-Richtung. Fuer
den naechsten Code-Slice gilt stattdessen die M16-BM-Dateiempfehlung aus
`357-game-like-island-selection-and-construction-camera-flow-gate.md`.

## 16. Historische M16-BK-Akzeptanzkriterien

Diese Kriterien bleiben als Lernpunkt erhalten. Fuer den naechsten Code-Slice
gelten jedoch die strengeren M16-BM-Akzeptanzkriterien aus `357`.

M16-BK waere erst gruen, wenn:

- Nutzer erkennt: "Ich baue ein Haus/Fundament."
- Lernen wirkt als Bauhandlung.
- Kein Lernfenster dominiert.
- Kein isolierter Wort-/Quizmoment entsteht.
- Kein BuildState entsteht.
- Keine Persistenz entsteht.
- Keine Assets unter `assets/` entstehen.
- Keine Route, Navigation oder App-Integration entsteht.
- Tap outside, Zurueck oder Spaeter bleibt moeglich.
- Keine RenderFlex-/RenderBox-Probleme auftreten.
- UI bleibt auf kleiner Mobile-Ansicht lesbar.
- `dart format`, `dart analyze`, `git diff --check`, `git status --short` und
  Scope-Check werden berichtet.

## 17. M16-T-ID-Entscheidung

| ID | Entscheidung | Begruendung |
| --- | --- | --- |
| `M16T-SPINE-006` | `[x]` | First Local Construction-Learning Vertical Slice Gate ist mit konkretem Uferhain -> Zuhause -> Haus -> Fundament-Flow dokumentiert. |
| `M16T-SPINE-007` | `[x]` | Grundstueckszoom Preview Boundary ist als lokale Ebene ohne Route, Navigation, Persistenz oder App-Seite festgelegt. |
| `M16T-SPINE-008` | `[x]` | Foundation Candidate Construction Step ist als erster Bauabschnitt ohne `foundation_started`, BuildState oder Persistenz definiert. |
| `M16T-SPINE-009` | `[x]` | Learning Action as Build Action ist mit Bauteile-sortieren am Grundstueck operationalisiert. |
| `M16T-SPINE-010` | `[x]` | M16-BK Implementation Prompt Readiness ist mit Folge-Slice, Dateiempfehlung und Akzeptanzkriterien vorbereitet. |

## 18. Stop-Regel fuer kuenftige Prompts

Jeder kuenftige Slice zum ersten Construction-Learning-Vertical-Slice muss
beantworten:

- Welche Spine-Stufe wird umgesetzt?
- Ist es Insel, Slot, Kategorie, BuildChoice, Grundstueckszoom, Bauphase,
  Lernhandlung oder Feedback?
- Welche sichtbare Bauhandlung entsteht?
- Welche Lernhandlung treibt oder erklaert diesen Bau?
- Warum ist es kein Lernfenster?
- Warum ist es kein isolierter Bank-/Wort-/Quizmoment?
- Welche Stop-Regeln verhindern BuildState, Persistenz, Assets,
  App-Integration und Route?

Ohne diese Antworten darf kein Code-Slice fuer M16-BK oder verwandte
Foundation-/BuildChoice-/Construction-Learning-Slices starten.
