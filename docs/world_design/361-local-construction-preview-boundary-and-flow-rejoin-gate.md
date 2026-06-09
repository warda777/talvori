# M16-BS: Local Construction Preview Boundary and Flow Rejoin Gate

Stand: 2026-06-09

Status: `Dokumentations-/Review-/Boundary-Gate-Slice / keine Implementierung`

## 1. Zweck

M16-BS ist das Boundary- und Flow-Rejoin-Gate nach M16-BQ.

M16-BQ hat den isolierten object-based Worker-Bauplatzmoment bewiesen:
Fundament entsteht nicht mehr als Button-Quiz, sondern durch sichtbares
Bauplatzproblem, indirekten Worker-Auftrag, lokale Arbeit und stufenweise
Weltveraenderung.

M16-BS klaert, wie dieser Moment wieder in den eigentlichen Talvori-Spine
zurueckgefuehrt wird:

```text
Uferhain / Insel
-> Slot
-> Kategorie / BuildChoice
-> Kamera/Fokus ins Grundstueck
-> object-based Worker-Bauplatzmoment
-> lokaler Baufortschritt
-> naechster Hook
```

Dieses Gate gibt keinen Code, keine App-Integration, keine Route, keine
Navigation, keine Persistenz, keine Assets, keine Tests, keinen BuildState und
keine Produktivmechanik frei.

## 2. Ausgangslage

M16-BQ ist committed und liegt als lokale isolierte Preview vor:

- `lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview.dart`
- `lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview_main.dart`

Die Preview zeigt:

- object-based Foundation Buildsite Puzzle,
- instabilen Bauplatz vor Text,
- Spaten, Fenster, Dach bzw. Fundamentsteine als Objektangebote,
- indirekt gesteuerten Worker,
- lokale Worker-Job-Phasen,
- Debug-Work-Path standardmaessig aus,
- stufenweise Boden- und Fundamentveraenderung,
- Aussenwand-Hook als neue Moeglichkeit,
- keine Route, keine App-Integration, keine Persistenz, keine Assets und
  keinen BuildState.

Die Preview bleibt trotzdem isoliert. Sie ist kein Produktmodul, keine
produktive Bauphase und keine freigegebene App-Komponente.

## 3. Warum Kein Weiterer BQ-Polish Jetzt

BQ ist als Proof gut genug, weil es die wichtigsten Regeln aus 358, 359 und
360 lokal zeigt:

- sichtbares Problem vor Text,
- Objekt/Ort vor Erklaerung,
- Worker-Auftrag statt reine UI-Auswahl,
- Arbeit in mehreren Stufen,
- Weltveraenderung statt Button-Bestaetigung,
- Belohnung als naechste Moeglichkeit.

Weiterer BQ-Polish kann endlos werden. Der naechste Produktbeweis ist nicht
"noch bessere Fundament-Szene", sondern:

```text
Kann dieser Bauplatzmoment in den Talvori-Spielablauf zurueckkehren?
```

Der Spielmoment muss jetzt in den Spine zurueck: Insel, Slot, Kategorie,
BuildChoice, Kamera/Fokus und Bauplatz muessen als ein lokaler sicherer Flow
zusammen lesbar werden.

## 4. Warum Nicht Direkt Aussenwaende Jetzt

Der Hook `Aussenwaende spaeter` ist stark, aber ein direkter
Aussenwaende-Code-Slice waere wieder ein isolierter Bauplatzmoment.

Vor dem naechsten Bauabschnitt muss geklaert sein:

- Wie kommt der Spieler vom Uferhain in den Bauplatz?
- Welcher Slot und welche BuildChoice tragen den Bauplatz?
- Wie bleibt Kamera/Fokus lokal und nicht Route?
- Wie bleibt Baufortschritt Preview/Candidate und nicht BuildState?
- Wie werden Bauabschnitte spaeter an Slot, BuildChoice und Weltkontext
  angebunden?

Ohne diese Boundary wuerde ein Aussenwaende-Slice den Hook zwar einloesen, aber
den Spine nicht beweisen.

## 5. Fuehrender Rejoin-Flow

Verbindlicher Rejoin-Flow fuer den naechsten lokalen Code-Proof:

```text
Uferhain sichtbar
-> Startslot waehlen
-> Kategorie Zuhause
-> BuildChoice Haus
-> Kamera/Fokus ins Grundstueck
-> object-based Foundation Worker Moment
-> Fundament lokal stabilisiert
-> Hook Aussenwaende spaeter
-> zurueck zur Insel / weiter vorbereiten / spaeter
```

Spielgefuehl:

- Der Spieler betritt keinen Formularscreen.
- Der Spieler sieht zuerst Welt, Slot, Bauplatz und sichtbares Problem.
- UI erklaert nur knapp per Bubble, HUD oder kleinem Toolbelt.
- Der Worker fuehrt Bauarbeit sichtbar aus.
- Aussenwaende sind ein Hook, keine produktive Freigabe.

## 6. Boundary-Regeln

Rejoin bedeutet:

- lokale Preview verbindet bisher getrennte Proofs,
- Uferhain/Slot/BuildChoice/Kamera und BQ-Bauplatz werden in einem sicheren
  Ablauf testbar,
- Spielgefuehl und Uebergang werden geprueft.

Rejoin bedeutet nicht:

- App-Integration,
- Route,
- Navigation,
- produktiver Screen,
- persistent gespeicherter BuildState,
- Datenmodell,
- Provider,
- Shared Service,
- Supabase/local DB Write,
- SRS-/`word_progress`-Mutation,
- Asset-Einfuehrung,
- BuildChoice-Produktimplementierung.

Der naechste Code-Slice darf also nur eine lokale Preview sein.

## 7. BQ Als Muster, Nicht Produktmodul

M16-BQ ist ein lokaler Proof fuer object-based Worker-Bauplatzhandlungen.

Er darf dienen als:

- visuelle Referenz,
- Muster fuer Worker-Auftrag,
- Muster fuer stufenweise Bauplatzveraenderung,
- Muster fuer kurze Bubbles und minimale Safe Actions,
- Muster fuer `Aussenwaende spaeter` als neue Moeglichkeit.

Er darf nicht automatisch werden zu:

- produktivem Widget im App-Flow,
- shared Bauplatz-Service,
- Datenmodell,
- Provider,
- Route,
- BuildState-Quelle,
- Persistenzschicht,
- globaler BuildChoice-Implementierung.

Falls spaeter Code aus BQ wiederverwendet wird, muss der Folge-Slice explizit
antworten:

- Wird BQ kopiert, importiert, referenziert oder nur als Muster gelesen?
- Welche Datei darf geaendert werden?
- Warum entsteht daraus keine App-Integration?
- Warum entsteht daraus kein BuildState und keine Persistenz?

## 8. Empfohlener Folge-Code-Slice

Empfohlener Folge-Code-Slice:

> M16-BT Local Uferhain-to-Buildsite Rejoin Preview

Ziel:

Eine isolierte lokale Preview, die den Flow zeigt:

- Uferhain-Ausschnitt,
- Startslot,
- Zuhause / Haus als BuildChoice,
- Kamera/Fokus ins Grundstueck,
- object-based Worker-Bauplatzmoment nach BQ-Muster,
- lokales Fundament-Feedback,
- `Aussenwaende spaeter` als Hook.

Grenzen:

- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Assets,
- keine Tests,
- keine BuildChoice-Produktimplementierung.

## 9. M16-BT Datei-Optionen

### Option A: Neue Isolierte Rejoin-Preview

Empfohlene Dateien:

- `lib/features/world/local_world/ui/widgets/local_uferhain_buildsite_rejoin_preview.dart`
- `lib/features/world/local_world/ui/widgets/local_uferhain_buildsite_rejoin_preview_main.dart`

Vorteile:

- M16-BQ bleibt als klarer Bauplatz-Proof erhalten.
- Rejoin-Flow kann separat getestet werden.
- Kein bestehender Proof wird ueberladen.
- Datei- und Import-Grenzen bleiben sauber.
- Spaeterer Review kann BQ und Rejoin getrennt bewerten.

Risiken:

- Etwas mehr lokale Preview-Dateien.
- Gefahr von Duplikation, wenn zu viel BQ-Code kopiert wird.

Boundary:

Option A darf BQ als Muster lesen oder begrenzt kopieren, aber keine shared
Produktabstraktion einfuehren.

### Option B: Bestehende M16-BQ-Datei Erweitern

Moegliche Datei:

- `lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview.dart`

Vorteile:

- weniger Dateien,
- der bestehende Bauplatz kann direkt erweitert werden.

Risiken:

- BQ verliert seine klare Rolle als isolierter Bauplatz-Proof.
- Insel-/Slot-/BuildChoice-Flow kann den Bauplatz-Proof ueberladen.
- Review wird schwieriger: Ist das Problem im Rejoin oder im Bauplatz?
- Hoeheres Risiko, spaeter aus Versehen ein Produktmodul daraus zu lesen.

Entscheidung:

```text
Option A ist empfohlen.
```

M16-BT soll eine neue isolierte Rejoin-Preview sein. BQ bleibt Muster und
Referenz, nicht automatisch wiederverwendetes Produktwidget.

## 10. Akzeptanzkriterien Fuer M16-BT

M16-BT ist nur gruen, wenn:

- Spielraum dominiert.
- Uferhain, Slot, BuildChoice und Bauplatz sind als ein lokaler Flow lesbar.
- Slot / BuildChoice / Kamera-Fokus fuehren organisch zum Bauplatz.
- Grundstueckszoom wirkt wie Kamera/Fokus, nicht wie neue App-Seite.
- Der Bauplatzmoment bleibt object-first.
- Der Worker arbeitet sichtbar.
- Das Fundament stabilisiert sich lokal.
- `Aussenwaende spaeter` erscheint als neuer Hook.
- Keine Quizkarte entsteht.
- Keine Phasenleiste entsteht.
- Keine Formularoptik entsteht.
- Keine produktive Navigation entsteht.
- Kein BuildState entsteht.
- Keine Persistenz entsteht.
- Kein Asset entsteht.
- Kein App-Flow entsteht.

## 11. Regeln Aus 357 Anwenden

M16-BT muss die Game-like Camera Flow Rule aus 357 anwenden:

- Insel/Slot/Grundstueck wirken als Welt- und Kamera-Flow.
- Der Spieler soll fuehlen: Ich gehe naeher an diesen Ort heran.
- Grundstueckszoom ist keine Route und kein neuer App-Screen.
- Umgebung bleibt angedeutet.
- UI bleibt HUD/Bubble/kurze Aktion, nicht Hauptspielraum.
- BuildChoice wirkt visuell, nicht wie kleines Textformular.

Bewusst verworfen:

- Listen-/Formularflow,
- Flow-Chart,
- grosse Entscheidungskarten,
- produktive Route,
- permanente Erklaerleiste.

## 12. Regeln Aus 358 Anwenden

M16-BT muss den Fun-/Adventure-/Curiosity-Layer aus 358 beantworten:

| Element | M16-BT Lesart |
| --- | --- |
| Player Hook | Auf dem Uferhain wartet ein erster Ort, an dem ein Zuhause entstehen kann. |
| Kleine Huerde | Der Bauplatz ist noch unklar und muss stabilisiert werden. |
| Spielerische Handlung | Spieler waehlt Slot, Hausidee und beauftragt den Worker mit dem richtigen Werkzeug/Material. |
| Sichtbarer Fortschritt | Boden wird ruhiger, Fundament entsteht lokal. |
| Belohnung als neue Moeglichkeit | `Aussenwaende spaeter` wird sichtbar. |
| Naechster Hook | Der Spieler will sehen, wie aus dem Fundament spaeter ein Haus wird. |

Blockiert bleiben:

- Timer,
- XP,
- Muenzen,
- Streak,
- Pay-to-Win,
- FOMO,
- Pflichtreview,
- Reward-System,
- Persistenz-Reward.

## 13. Regeln Aus 359 Anwenden

M16-BT muss die object-first Bauplatzregeln aus 359 anwenden:

- Erst sichtbares Problem, dann Text.
- Erst Objekt oder Ort, dann Erklaerung.
- Bauteile wirken wie Spielobjekte, nicht wie Buttons.
- Der Bauplatz veraendert sich sichtbar.
- Falsche Teile geben ruhigen Hinweis, keine Strafe.
- Belohnung ist eine neue Moeglichkeit im Raum.
- Kein Button-Quiz.
- Keine Quizkarte.
- Kein permanentes Footer-HUD.

Die Insel- und Slot-Stufen duerfen BQ nicht wieder in eine UI-Karte
zurueckverwandeln.

## 14. Regeln Aus 360 Anwenden

M16-BT muss die Character-assisted World Action Rule aus 360 anwenden:

- MVP-Default bleibt indirekte Steuerung.
- Spieler gibt Auftrag: Ziel, Werkzeug, Material, Reihenfolge oder Objekt.
- Worker fuehrt sichtbar aus: laufen, graben, tragen, legen, ausrichten.
- Weltveraenderung passiert durch die sichtbare Handlung.
- Keine direkte Avatarsteuerung.
- Kein Joystick.
- Kein Pathfinding.
- Keine Kollision.
- Kein Movement-System.

Der Worker ist kein Deko-Icon. Er muss den Bauplatzmoment lebendiger und
klarer machen.

## 15. Betroffene M16-T-IDs

M16-BS erledigt:

- `M16T-FUN-017` Local construction preview flow rejoin boundary
- `M16T-FUN-018` BQ as object-based buildsite pattern
- `M16T-FUN-019` M16-BT rejoin preview readiness

Diese IDs geben keinen Code frei. Sie definieren nur die Boundary fuer den
naechsten lokalen Code-Proof.

## 16. Prompt-Regel Fuer Rejoin-Slices

Kuenftige Rejoin-, Construction-, Buildsite- oder Preview-Slices muessen
`361-local-construction-preview-boundary-and-flow-rejoin-gate.md` lesen.

Jeder entsprechende Prompt muss beantworten:

- Welcher isolierte Proof wird verbunden?
- Was bleibt Preview und was bleibt blockiert?
- Welche Datei darf geaendert werden?
- Wird BQ als Muster, Kopie, Import oder Referenz genutzt?
- Warum entsteht keine App-Integration?
- Warum entsteht keine Route und keine Navigation?
- Warum entsteht kein BuildState und keine Persistenz?
- Welche Regeln aus 357, 358, 359 und 360 werden konkret angewendet?

Wenn diese Fragen nicht beantwortet sind, bleibt der Slice ein Review- oder
Gate-Slice und darf keinen Code freigeben.

## 17. Stop-Regeln

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
