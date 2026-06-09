# M16-BL: Game-like Island Selection and Construction Camera Flow Gate

Stand: 2026-06-09

Status: `Dokumentations-/UX-Pattern-Gate-Slice / keine Implementierung`

## 1. Zweck

M16-BL korrigiert die Umsetzungsrichtung fuer den ersten
Construction-Learning-Vertical-Slice. Talvori-Slices duerfen nicht als
UI-Flow-Karten starten, wenn das Produktversprechen eigentlich Spielwelt,
Kamera, Bauplatz und sichtbaren Aufbau meint.

Der naechste Produktbeweis muss wie ein Spiel wirken:

```text
Insel-Showcase
-> Welt betreten
-> Grundstueck zoomen
-> bauen
-> Lernen als Bauhandlung
```

M16-BL gibt keinen Code, keine App-Integration, keine Route, keine Navigation,
keine Persistenz, keine Assets, keine Tests, keine BuildChoice-
Implementierung, keinen BuildState und keine Produktivmechanik frei.

Nachtrag M16-BN:

`358-fun-adventure-curiosity-reward-gameplay-spine-gate.md` ergaenzt diesen
Kamera-/Showcase-Flow um den Fun-/Hook-Layer. Ein Slice kann visuell wie
Showcase, Weltansicht und Bauplatz aufgebaut sein und trotzdem noch zu schwach
sein, wenn Neugier-Hook, kleine Huerde, Weltreaktion, Belohnung als neue
Moeglichkeit und naechster freiwilliger Hook fehlen.

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
- keine Produktivmechanik-Freigabe,
- kein Commit.

## 3. Gelesene Grundlagen

| Dokument | Beitrag fuer M16-BL |
| --- | --- |
| `355-talvori-core-construction-learning-spine.md` | Fuehrender Construction-Learning-Spine: Lernen treibt Bau und Weltfortschritt. |
| `356-first-local-construction-learning-vertical-slice-gate.md` | Fachlicher erster Foundation-Slice mit Uferhain -> Zuhause -> Haus -> Fundament. |
| `350-interaction-pattern-decision-matrix.md` | Showcase, Board, Bottom-HUD, Weltaktion und Werkbank-Muster bewusst waehlen. |
| `353-starter-island-identity-biome-and-category-scope-gate.md` | Uferhain als erste Inselidentitaet und BuildChoice-Hierarchie. |
| `351-starter-island-infrastructure-strategy-gate.md` | Feste Inselinfrastruktur, freie Slots, Templates, Varianten und BuildState-Grenzen. |
| `328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrende M16-T-Liste und neue SPINE-IDs. |
| `336-documentation-map-and-slice-reading-rules.md` | Pflichtlektuere- und Prompt-Regeln. |
| `345-play-first-learning-experience-doctrine.md` | Play-First und Island-First als harte Filter. |

## 4. Fehleranalyse M16-BK

Der lokale M16-BK Foundation-Preview-Ansatz hat den Spine technisch abbildbar
gemacht, aber noch nicht das richtige Spielgefuehl getroffen.

Probleme:

- zu UI-lastig,
- zu viele Textflaechen,
- zu viele Phasen, Buttons und erklaerende Panels,
- zu wenig Kamera-/Welt-/Spielfeldgefuehl,
- Fundament und Bauplatz waren vorhanden, aber die Welt trug die Handlung
  nicht stark genug,
- die Lernhandlung drohte weiter wie Fragekarte mit Textbuttons zu wirken.

Bewertung:

M16-BK war ein nuetzlicher technischer Beweis, aber kein ausreichender
Produktbeweis. Der Spine wurde als Ablauf sichtbar, aber nicht spielerisch
genug. Deshalb wird die M16-BK-Preview nicht als naechste Richtung committet
oder weitergefuehrt.

Korrektur:

Der naechste Code-Slice muss nicht den UI-Flow verfeinern, sondern den
Game-Flow neu testen: Showcase, Insel betreten, Kamera/Fokus, Bauplatz,
visuelle BuildChoice, Bauteile direkt am Grundstueck.

## 5. Benchmark-/Research-Check nach 350

M16-BL nutzt den M16-AX-Research-Check als Pattern-Pruefung. Es werden keine
Mechaniken kopiert und keine Produktfeatures freigegeben.

| Muster | Beobachtetes Prinzip | Talvori uebernimmt | Talvori verwirft |
| --- | --- | --- | --- |
| Auto-/Charakterauswahl | Ein grosses zentrales Objekt, seitliches Swipen und wenige klare Aktionen erzeugen Ownership. | Insel-Showcase mit Uferhain gross im Zentrum und Future-Islands spaeter im Carousel. | Listenansicht, Textkarten, Auswahlformular als erstes Gefuehl. |
| Insel-/Weltkarten | Eine grosse Weltflaeche gibt Orientierung; HUD bleibt klein. | Spielraum dominiert, Slots liegen sichtbar in der Welt, Erweiterungen bleiben ruhig. | Debuglabels, permanente Regeltexte, ueberladene Bottom-Panels. |
| Aufbau-/Base-Spiele | Flaeche antippen, dort bauen, Fortschritt direkt am Ort sehen. | Grundstueck direkt im Weltbild antippen, Kamera geht naeher heran, Bauplatz traegt Aufgabe. | Timer, Ressourcenknappheit, Pay-to-Win, Bauzwang. |
| RPG-/Crafting-Spiele | Werkbank/Bauplatz ist eine Spielstation, nicht nur Menue. | Bauplatz als Station fuer Bauteile sortieren und visuelle BuildChoice. | Crafting-Inventar, Materialgrind, Rezeptsystem im MVP. |
| Mobile-Games | Minimales HUD laesst den Spielraum fuehren. | Ein Hauptziel, kurze Bubbles, Safe Actions kompakt. | Phasenleisten, grosse Tutorialfenster, Footer, technische Guardrail-Chips. |

Entscheidung:

- Gewaehlt: Showcase/Carousel fuer Inselwahl, Weltansicht fuer Insel, lokale
  Kamera/Fokusbewegung fuer Grundstueck, visuelle BuildChoice/Bauplatz-Preview
  fuer Haus/Fundament, kleine Bubble/HUD fuer Feedback.
- Bewusst verworfen: UI-Flow-Karten, grosse Textpanels, Fragekarte mit drei
  Textbuttons als Hauptbild, Debug-HUD, Drag als Hauptflow, produktive Route,
  Persistenz oder BuildState.
- Vorbildlogik: Moderne Spiele lassen zuerst das Objekt oder die Welt
  dominieren; UI erklaert nur so viel, wie fuer die naechste Handlung noetig
  ist.

## 6. Fuehrender Game-Flow

Verbindlicher Game-Flow fuer den naechsten Produktbeweis:

```text
Insel-Showcase
-> Insel auswaehlen
-> Insel betreten
-> Grundstueck/Slot im Weltbild antippen
-> Kamera zoomt lokal ins Grundstueck
-> BuildChoice visuell waehlen
-> Bauabschnitt im Grundstueck
-> Lernhandlung als Bauaktion
-> lokales Baufeedback
-> zurueck zur Insel / weiterbauen / spaeter
```

Regeln:

- Der Spielraum dominiert jede Stufe.
- UI bleibt HUD, Bubble, kleine Aktion oder Showcase-Hilfe.
- Jede sichtbare Aufgabe passiert an Insel, Grundstueck, Bauplatz oder Objekt.
- Lernen darf nicht als separates Lernfenster ueber die Welt gelegt werden.

## 7. Insel-Auswahl

Die Insel-Auswahl ist kein Listen- oder Formularscreen.

Regeln:

- Insel steht gross im Zentrum.
- Links/rechts wischen oder ein Carousel wechselt Inseln.
- Wenige Ressourcen-/Info-Pills duerfen sichtbar sein, aber nicht dominieren.
- Keine lange Liste.
- Keine Textwand.
- Uferhain ist die erste Insel.
- Future Island Families koennen spaeter im Carousel erscheinen.
- Auswahl fuehlt sich wie Auto-, Charakter- oder Map-Auswahl an.

MVP-Preview:

- Uferhain als grosse, stilisierte Insel-Greybox.
- Ein klarer Call-to-Action: Insel waehlen / betreten.
- Future Islands nur als ruhige Platzhalter, wenn ueberhaupt.

## 8. Insel betreten

Nach der Auswahl sieht der Spieler die eigene Insel.

Regeln:

- Spielraum dominiert.
- HUD minimal.
- Slots/Grundstuecke sind in der Welt sichtbar.
- Erweiterungen sind ruhig sichtbar, aber nicht kauf- oder timerartig.
- Kein Debug-Text.
- Kein Formular.
- Keine permanente technische Erklaerleiste.

Der Spieler soll sofort verstehen:

```text
Ich bin auf meiner Insel.
Hier gibt es Orte, die ich gestalten kann.
```

## 9. Grundstueck auswaehlen

Das Grundstueck wird direkt im Weltbild angetippt.

Regeln:

- Kein grosses Menue nach dem ersten Tap.
- Ein kleines lokales Signal zeigt Fokus: Glow, Ring, Schild, kurze Bubble.
- Danach bewegt sich die Kamera oder der Fokus lokal ins Grundstueck.
- Der Spieler soll fuehlen: Ich gehe naeher an diesen Ort heran.
- Tap-out oder Zurueck bleibt moeglich.

Nicht erlaubt:

- Grundstueck als Listenzeile,
- grosse Entscheidungskarte als Hauptbild,
- Debug-Panel mit Slot-Regeln,
- sofortiges Placement oder BuildState.

## 10. Grundstueckszoom / Kamera

Der Grundstueckszoom ist keine Route und keine neue App-Seite im
Produktgefuehl. Er ist eine Kamera-/Fokusbewegung.

Regeln:

- Die Umgebung bleibt angedeutet.
- Das Grundstueck bleibt Teil der Insel.
- Ein Grundstueck allein auf leerem Hintergrund ist zu steril.
- Zurueck zur Insel ist immer moeglich.
- Kein Persistenzwechsel.
- Kein Router.
- Keine App-Integration.

MVP-Preview:

- Lokale Animation oder sofortiger Fokuswechsel ist erlaubt.
- Wichtig ist das Gefuehl von Kamera/Fokus, nicht der technische Effekt.
- Der Bauplatz muss im Raum liegen, nicht in einer Karte.

## 11. BuildChoice

BuildChoice wie Haus, Garage, Terrasse, Teich oder Outdoor-Sauna braucht
visuelle Vorschau.

Regeln:

- Kein kleines Wheel fuer BuildChoice.
- Geeignet sind Showcase, Card-Carousel, Bauplatz-Vorschau oder
  werkbank-aehnliche Station.
- Fuer das erste MVP wird nur `Haus` als simple lokale Wahl gezeigt.
- Spaeter koennen Haus, Garage, Terrasse, Pool, Teich, Outdoor-Sauna und
  aehnliche Unterideen als visuelle Unterauswahl erscheinen.
- BuildChoice erzeugt nur einen Candidate, kein gebautes Objekt.

Fuer M16-BM:

- `Haus` darf als einfache Ghost-/Blueprint-Idee direkt am Bauplatz erscheinen.
- Keine Showcase-Seite als produktive App-Route.
- Keine Assets.
- Keine Persistenz.

## 12. Bauphase

Die Bauphase passiert im Grundstueck.

Regeln:

- Fundament wird auf dem Grundstueck sichtbar.
- Waende, Fenster, Tueren und Dach bleiben spaetere Bauabschnitte.
- Spieler tippt, ordnet oder zieht Bauteile direkt am Bauplatz.
- Keine Phasenleiste als Hauptgefuehl.
- Kein grosses Tutorialfenster.
- Kleine Tali/Vori-Bubble ist erlaubt.
- Fundament bleibt Candidate, kein BuildState.

Der Bauplatz soll sagen:

```text
Hier passiert der naechste Schritt.
```

Nicht:

```text
Lies diese Aufgabe und druecke den richtigen Textbutton.
```

## 13. Lernhandlung als Bauaktion

Die Lernhandlung muss physisch oder visuell als Bauhandlung erscheinen.

Beispiel:

- Bauteile liegen am Bauplatz.
- Spieler waehlt oder ordnet das Fundament an die Grundflaeche.
- Fenster und Dach sind sichtbar als spaetere Teile, aber nicht zuerst passend.
- Die richtige Wahl staerkt die Fundament-Skizze.

Nicht erlaubt:

- Fragekarte mit drei Textbuttons als Hauptflaeche,
- Quizscreen,
- Lernfenster ueber der Welt,
- Score, Timer, XP, Review-Zwang,
- rote Fehlerlogik.

Text darf helfen, aber das Spielfeld traegt die Aufgabe.

## 14. HUD-Regeln

HUD ist Unterstuetzung, nicht Hauptspielraum.

Regeln:

- minimal,
- nur ein Hauptziel auf einmal,
- kurze Bubbles statt lange Panels,
- Safe Actions versteckt, kompakt oder als kleine Toolbelt-Aktionen,
- keine permanenten Debug-Hinweise,
- keine Guardrail-Chips im normalen Spielbild,
- kein Footer, der Spielraum blockiert,
- keine dauerhafte Phasenleiste,
- keine Textwand.

Erlaubt:

- kurze Tali/Vori-Bubble,
- kleiner Zielhinweis,
- Zurueck / Spaeter / Aendern / Archiv kompakt,
- Toast/Bubble fuer lokales Feedback.

## 15. M16-BM als neuer Folge-Code-Slice

Naechster Code-Slice:

```text
M16-BM Game-like Island Showcase to Foundation Camera Preview
```

Ziel:

- Insel-Showcase mit Uferhain im Zentrum,
- Button oder Swipe-Placeholder `Insel waehlen`,
- Insel betreten,
- Slot im Weltbild antippen,
- Kamera/Zoom ins Grundstueck,
- Haus/Fundament als visuelle Bauidee,
- Bauteil-Auswahl direkt am Bauplatz,
- Fundament wird sichtbar staerker,
- minimale HUD/Bubbles,
- keine Persistenz,
- keine Assets,
- keine Route.

M16-BM ersetzt die Fortsetzung des zu UI-lastigen M16-BK-Ansatzes.

## 16. Empfohlene Dateien fuer M16-BM

Empfohlen:

- `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview.dart`
- optional `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview_main.dart`

Nicht empfohlen:

- alte M16-BK-Dateien weiterfuehren,
- `starter_island_plot_board_preview.dart` weiter ueberladen,
- produktive App-Dateien, Router, Home, Provider oder Datenlayer beruehren.

Begruendung:

Eine neue isolierte Preview testet den neuen Game-Flow sauberer als eine
Reparatur des UI-lastigen Foundation-Preview-Ansatzes.

## 17. Akzeptanzkriterien fuer M16-BM

M16-BM ist nur gruen, wenn:

- Insel-Auswahl wie Showcase/Spielauswahl wirkt,
- Spielraum dominiert,
- Grundstueckszoom wie Kamera/Fokus wirkt, nicht wie Formularseite,
- BuildChoice `Haus` visuell wirkt, nicht wie Textbutton,
- Fundament-Aufgabe am Bauplatz stattfindet,
- keine grosse Quizkarte entsteht,
- keine dauerhafte Phasenleiste entsteht,
- Texte minimal bleiben,
- Safe Exits vorhanden, aber nicht dominant sind,
- keine Guardrail-Chips das Spielbild dominieren,
- kein BuildState entsteht,
- keine Persistenz entsteht,
- keine Assets entstehen,
- keine App-Integration entsteht.

## 18. M16-T-ID-Entscheidung

| ID | Entscheidung | Begruendung |
| --- | --- | --- |
| `M16T-SPINE-011` | `[x]` | Game-like island selection and camera flow ist als neuer fuehrender UX-Flow dokumentiert. |
| `M16T-SPINE-012` | `[x]` | Showcase pattern for island/buildchoice selection ist fuer Inselwahl und visuelle BuildChoice festgelegt. |
| `M16T-SPINE-013` | `[x]` | Construction task must happen on build site ist als harte Bauplatz-Regel definiert. |
| `M16T-SPINE-014` | `[x]` | Minimal HUD for construction-learning flow ist mit Bubble-/HUD-/Safe-Exit-Grenzen dokumentiert. |
| `M16T-SPINE-015` | `[x]` | M16-BM prompt readiness ist mit Folge-Slice, Dateiempfehlung und Akzeptanzkriterien vorbereitet. |

## 19. Stop-Regel fuer kuenftige Prompts

Kuenftige Implementierungs-Slices fuer Inselauswahl, Grundstueckszoom,
BuildChoice oder Bauphase muessen beantworten:

- Ist dies Showcase, Weltansicht, Kamera-Zoom, Bauplatz oder HUD?
- Warum dominiert der Spielraum?
- Wie wird Text reduziert?
- Welche erfolgreichen Spielmuster wurden uebertragen?
- Warum ist es nicht Formular, Flow-Chart oder Lernfenster?
- Welche Stop-Regeln verhindern BuildState, Persistenz, Assets, Route,
  App-Integration und produktive BuildChoice-Implementierung?

Ohne diese Antworten darf M16-BM oder ein verwandter Code-Slice nicht starten.
