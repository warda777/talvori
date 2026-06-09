# 359 - Successful Game Pattern Translation for Talvori Construction Play

Status: verbindliches Dokumentations-/Gameplay-Translation-Gate fuer M16-BP.

Scope: Spielmuster-Uebersetzung, Bauplatz-Regeln, Folge-Code-Gate.

Nicht-Scope: Code, Assets, Tests, App-Integration, Route, Persistenz,
BuildState, Economy, Reward-Implementierung, BuildChoice-Implementierung,
Produktivmechanik-Freigabe.

## 1. Zweck

Talvori darf nicht nur technisch korrekte Previews bauen. Eine Preview kann
Carousel, Insel, Slot, Kamera, BuildChoice und Fundament enthalten und sich
trotzdem noch wie Greybox, UI-Flow oder Button-Quiz anfuehlen.

Ab M16-BP gilt fuer jeden Spielmoment:

```text
sichtbares Problem
-> spielbare Handlung
-> sichtbare Veraenderung
-> Belohnung als neue Moeglichkeit
-> naechster Hook
```

Text darf helfen, aber er darf nicht der erste Traeger der Aufgabe sein. Der
Spieler muss vor der Erklaerung sehen koennen:

- Was ist hier los?
- Welches Objekt oder welcher Ort braucht meine Handlung?
- Was veraendert sich durch mich?
- Was wird danach moeglich?

## 2. Fehleranalyse M16-BO

M16-BO war ein nuetzlicher Polish der M16-BM-Preview, aber noch nicht der
endgueltige Spielmoment.

Was M16-BO verbessert hat:

- Labels und Containment wurden ruhiger.
- Hooks und Feedback wurden konkreter.
- Safe Actions wurden weniger dominant.
- Der naechste Hook "Aussenwaende spaeter" wurde sichtbar.

Was fachlich noch nicht reicht:

- Die Spielhandlung wurde noch nicht stark genug veraendert.
- Bauteile wirkten weiter zu sehr wie Buttons oder Auswahlchips.
- Der Bauplatz hatte noch zu wenig sichtbares Problem vor dem Text.
- Die Belohnung war noch zu stark Text und zu wenig Weltveraenderung.
- Der Spieler sah noch nicht klar genug: Ich loese ein Bauplatzproblem.

Entscheidung:

M16-BO nicht als finalen Spielmoment committen. Der Stand kann als technische
Zwischenstufe oder Ausgangspunkt dienen, aber der naechste Code-Slice muss den
Foundation-Moment objektbasiert und weltveraendernd aufbauen.

## 3. Benchmark-Musterfamilien

Talvori kopiert keine Spiele. Talvori uebersetzt Musterlogik in eigene,
druckfreie Welt-/Bau-/Lernhandlungen.

### A. Puzzle-Feld / Chaos loesen

Beispiele: Block Blast, Bus Out, Candy Crush Solitaire.

Warum es funktioniert:

- Spieler sieht ein Problem sofort.
- Es gibt eine kleine, klare Huerde.
- Die Handlung ist direkt.
- Feedback kommt sofort aus dem Feld.

Talvori-Uebertragung:

- Der Bauplatz zeigt vor Text ein Problem: unklarer Boden, Riss, Geroll,
  Nebel, instabile Markierung.
- Drei Bauteile liegen sichtbar am Ort.
- Der Spieler setzt oder waehlt ein Objekt, nicht einen Textbutton.
- Die Flaeche veraendert sich direkt: Boden wird klarer, Teil rastet ein,
  neuer Umriss erscheint.

Talvori verwirft:

- Score,
- Zeitdruck,
- Combo-Druck,
- abstrakte Puzzleflaeche ohne Weltbezug.

### B. Ordnung / Tactile Satisfaction

Beispiele: Perfect Tidy, Container- und Sortierspiele.

Warum es funktioniert:

- Aufraeumen und Einrasten fuehlt sich greifbar an.
- Kleine Ordnung erzeugt sofortige Befriedigung.
- Das Feedback ist visuell und koerperlich lesbar.

Talvori-Uebertragung:

- aufraeumen,
- einsortieren,
- Bauteile einrasten lassen,
- Container oeffnen,
- Dinge passend platzieren.

Fuer den Bauplatz:

- Fundamentteil passt in Grundflaeche.
- Fenster und Dach liegen bereit, wirken aber sichtbar spaeter.
- Falsches Teil wackelt ruhig oder bleibt neben dem Umriss.
- Richtiges Teil rastet ein und macht den Ort stabiler.

Talvori verwirft:

- Perfektionsstress,
- harte Fehlerbestrafung,
- endloses Aufraeumen ohne Lern- oder Weltfortschritt.

### C. Aufbau / Besitz / sichtbarer Fortschritt

Beispiele: Township, Clash of Clans, Fallout Shelter, Minecraft, Whiteout
Survival.

Warum es funktioniert:

- Der eigene Ort veraendert sich.
- Spieler fuehlen Ownership.
- Naechste Optionen werden sichtbar.
- Fortschritt ist im Raum ablesbar, nicht nur in Zahlen.

Talvori-Uebertragung:

- Ort veraendert sich sichtbar.
- Neue Bauoption erscheint.
- Neue Zone oder naechster Bauabschnitt wird angedeutet.
- Spieler fuehlt: Das ist mein Bauplatz, meine Insel, mein Fortschritt.

Talvori verwirft:

- Timer,
- Ressourcendruck,
- Pay-to-Win,
- Angriffsdruck,
- Weltverlust,
- Bauzwang.

### D. Sammeln / Oeffnen / neue Moeglichkeit

Beispiele: Pokemon TCG Pocket, Slay the Spire, Balatro, Vampire Survivors.

Warum es funktioniert:

- Neue Dinge veraendern Moeglichkeiten.
- Spieler sammeln nicht nur Besitz, sondern Optionen.
- Kleine Entdeckungen fuehren zur naechsten Entscheidung.

Talvori-Uebertragung:

- Blueprint-Fragment,
- neuer Bauabschnitt,
- neues Fundstueck,
- Archiv-Eintrag,
- neue Faehigkeit als Preview.

Fuer Foundation:

- Nach richtigem Fundament erscheint kein XP, sondern ein Aussenwand-Schatten.
- "Aussenwaende spaeter" ist die Belohnung als neue Moeglichkeit.
- Ein kleines Fundstueck oder Blueprint-Fragment kann spaeter ein Gate sein,
  aber nicht in diesem Dokument implementiert werden.

Talvori verwirft:

- Gacha,
- Lootbox,
- Seltenheitsdruck,
- FOMO,
- Build-/Reward-Persistenz ohne Gate.

### E. Welt-/Perspektivraetsel

Beispiele: Monument Valley.

Warum es funktioniert:

- Raum, Kamera und Wege sind Teil des Raetsels.
- Umgebung traegt Hinweise.
- Das Aha-Gefuehl entsteht durch Perspektivwechsel.

Talvori-Uebertragung:

- Wege oeffnen,
- Bruecke sichtbar machen,
- Kamera/Fokus als Spielgefuehl,
- Umgebung traegt Hinweis.

Fuer Foundation:

- Kamera geht nicht zu einer Formularseite, sondern naeher an denselben Ort.
- Die Insel bleibt angedeutet.
- Der Bauplatz zeigt Hinweise im Boden und in der Umgebung.

Talvori verwirft:

- sterile Detailansicht,
- UI-Seitenwechsel als Hauptgefuehl,
- Erklaertext statt Raumhinweis.

### F. Sprache / Bedeutung durch Kontext

Beispiele: Chants of Sennaar, Disco Elysium.

Warum es funktioniert:

- Bedeutung entsteht aus Ort, Figur, Handlung und Konsequenz.
- Sprache wird entdeckt, nicht abgefragt.
- Erinnerung entsteht durch Situation.

Talvori-Uebertragung:

- Bedeutung aus Ort und Handlung.
- Woerter werden ueber Weltkontext verstanden.
- Archiv ist Wiederfinden, nicht Lernfenster.

Fuer Foundation:

- `Fundament`, `Fenster`, `Dach` werden als Bauteile am Bauplatz verstanden.
- Der Spieler lernt Reihenfolge und Funktion durch Handlung.
- Tali/Vori darf knapp hinweisen, aber der Ort erklaert zuerst.

Talvori verwirft:

- Vokabeltest als Hauptbild,
- isolierte Quizkarte,
- lange Lexikon-Erklaerung vor Handlung.

### G. Action / Mission / klare Rollen

Beispiele: Brawl Stars, Wuthering Waves, Eternium, XCOM.

Warum es funktioniert:

- Ziel ist klar.
- Rolle und Handlung sind sofort lesbar.
- Feedback kommt unmittelbar.
- Eine Mission hat Anfang, Reaktion und naechsten Impuls.

Talvori-Uebertragung:

- kurze Mission,
- klares Ziel,
- eine Handlung,
- unmittelbare Reaktion,
- kein MVP-PvP.

Fuer Foundation:

- Mission: Stabilisiere den ersten Bauplatz.
- Handlung: Setze das passende Bauteil in den Umriss.
- Reaktion: Boden haelt.
- Hook: Aussenwaende spaeter.

Talvori verwirft:

- PvP,
- Rangdruck,
- Reflexstress,
- Kampf als MVP-Hauptmotiv.

### H. Showcase / Auswahl / Identitaet

Beispiele: Need for Speed, Disney Speedstorm, Pokemon TCG Pocket.

Warum es funktioniert:

- Ein grosses zentrales Objekt erzeugt Identitaet.
- Wenige klare Aktionen reichen.
- Auswahl wirkt nach Ownership statt Formular.
- Starke Silhouetten helfen mehr als lange Texte.

Talvori-Uebertragung:

- Inseln gross im Zentrum.
- Bauideen visuell auswaehlbar.
- Starke Silhouetten.
- Wenige klare Aktionen.

Talvori verwirft:

- Listen-/Formularauswahl,
- Textkarten als Hauptgefuehl,
- zu viele gleich grosse Optionen,
- Showcase als produktive Route ohne Gate.

## 4. Talvori-Designregeln

Harte Regeln aus den Musterfamilien:

- Erst sichtbares Problem, dann Text.
- Erst Objekt oder Ort, dann Erklaerung.
- Jede Lernhandlung muss eine sichtbare Weltveraenderung ausloesen.
- Jede Belohnung ist eine neue Moeglichkeit.
- Jede Aufgabe braucht einen naechsten Hook.
- Bauteile muessen wie Spielobjekte wirken, nicht wie Buttons.
- Bubbles sind kurz.
- HUD ist minimal.
- Kein Formulargefuehl.
- Kein Quizscreen.
- Kein permanentes Footer-HUD.

Zusatzregel:

Wenn ein Bau-/Lernmoment nur durch seinen Text verstaendlich ist, ist er noch
nicht spielbar genug.

## 5. Object-Based Buildsite Puzzle

Der neue Zielansatz fuer die Foundation-Preview ist ein objektbasiertes
Bauplatz-Puzzle.

### Bauplatz-Zustand

Der Bauplatz zeigt vor Text ein Problem:

- unklarer Boden,
- Nebel, Riss, Geroll oder unscharfer Umriss,
- drei sichtbare Bauteile liegen am Bauplatz.

Der Spieler soll ohne langen Text erkennen:

```text
Dieser Ort ist noch nicht stabil.
Hier muss etwas passen.
```

### Handlung

Erlaubte erste Umsetzung:

- Spieler tippt oder zieht ein Fundamentteil in die Grundflaeche.
- Fenster und Dach wirken sichtbar als spaetere Teile.
- Richtige Wahl rastet ein.
- Falsche Wahl wackelt ruhig oder gibt kurzen Hinweis.

Keine Pflicht fuer die erste Preview:

- echte Drag-Physik,
- Persistenz,
- Asset,
- Reward-System,
- BuildState.

### Feedback

Nach richtiger Handlung:

- Boden wird klarer,
- Fundament leuchtet,
- Aussenwand-Schatten erscheint,
- kleine Bubble: "Der Boden haelt. Aussenwaende spaeter."

Nach falscher Handlung:

- Teil wackelt ruhig oder bleibt draussen,
- keine rote Fehlerfarbe,
- keine Strafe,
- kurzer Hinweis: "Noch nicht. Erst braucht der Ort festen Grund."

### Lernnutzen

Der Lernnutzen bleibt:

- Reihenfolge verstehen,
- Bauteil-Funktion verstehen,
- Haus-/Bauwortfeld,
- Kontext durch Handlung.

Das sichtbare Gefuehl ist:

```text
Ich stabilisiere den Bauplatz.
```

Nicht:

```text
Ich beantworte eine Frage.
```

## 6. Folge-Code-Slice: M16-BQ

Empfohlener naechster Code-Slice:

> M16-BQ Object-Based Foundation Buildsite Puzzle Preview

Ziel:

Die bestehende M16-BM/BO-Idee wird nicht als Button-Flow fortgefuehrt, sondern
als objektbasiertes Bauplatz-Puzzle neu umgesetzt.

Empfehlung:

Neue isolierte Preview-Datei bevorzugen.

Empfohlene erlaubte Dateien:

- `lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview.dart`
- `lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview_main.dart`

Warum neu isolieren:

- M16-BM/BO prueft Showcase, Inselwechsel, Slots und BuildChoice-Breite.
- M16-BQ soll enger und mutiger das Bauplatzproblem testen.
- Eine neue isolierte Datei verhindert, dass der bestehende Multi-Island-Flow
  weiter ueberladen wird.
- Erfolgreiche BQ-Lektionen koennen spaeter in BM oder eine produktive Preview
  zurueckuebertragen werden.

Alternative nur falls explizit gewuenscht:

- `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview.dart`
- `lib/features/world/local_world/ui/widgets/local_island_showcase_foundation_camera_preview_main.dart`

Diese Alternative ist weniger sauber, weil sie Multi-Island-Showcase und
Buildsite-Puzzle in einem Proof vermischt.

## 7. Akzeptanzkriterien fuer M16-BQ

M16-BQ ist nur gruen, wenn:

- Bauplatzproblem vor Text verstaendlich ist.
- Bauteile wie Objekte wirken.
- Fundament wird in Umriss eingesetzt oder deutlich als Objekt ausgewaehlt.
- Richtige Wahl veraendert den Ort sichtbar.
- Aussenwand-Hook erscheint.
- Keine Quizkarte sichtbar ist.
- Keine Phasenleiste sichtbar ist.
- Kein grosses Panel dominiert.
- Kein permanenter Footer dominiert.
- Keine Persistenz entsteht.
- Kein BuildState entsteht.
- Keine Assets entstehen.
- Keine App-Integration entsteht.

Visual-QA:

- keine abgeschnittenen Labels,
- keine Ellipsis fuer zentrale Begriffe,
- keine ueberlappenden Bauteile oder HUDs,
- Bauplatz bleibt Hauptflaeche.

## 8. Prompt-Regel fuer 336

Kuenftige Gameplay-, Build-, Learning-, UI- und Implementierungs-Slices muessen
359 lesen, wenn Spielhandlung, Bauaufgabe, Puzzle, Mission oder Belohnung
betroffen sind.

Jeder solche Prompt muss beantworten:

- Was sieht der Spieler vor dem Text?
- Was ist das sichtbare Problem?
- Welches Objekt wird manipuliert?
- Was veraendert sich sichtbar?
- Welche neue Moeglichkeit entsteht?
- Warum ist es kein Button-Quiz?

## 9. M16T-FUN IDs

Dieses Gate dokumentiert folgende erledigte Regel-IDs:

- M16T-FUN-007 Successful Game Pattern Translation
- M16T-FUN-008 Object-first before text
- M16T-FUN-009 Buildsite puzzle must change the world
- M16T-FUN-010 Reward as next visible possibility
- M16T-FUN-011 M16-BQ implementation readiness

## 10. Stop-Regeln

- keine Flutter-/Dart-Dateien
- keine App-Integration
- keine Route
- keine Navigation
- keine Persistenz
- keine Supabase/local DB Writes
- keine SRS-/word_progress-Aenderung
- keine automatische Wortplatzierung
- keine Assets
- kein BuildState
- kein frame_started
- keine Tests
- keine Screenshots als Repo-Artefakte
- keine Economy
- keine Muenzen
- keine Reward-Implementierung
- keine BuildChoice-Implementierung
- keine Produktivmechanik-Freigabe
- nicht committen
