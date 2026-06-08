# M16-AN: Isolated Bank Meaning Puzzle Preview Gate

Stand: 2026-06-08

Status: `Implementierungs-/Preview-Plan-Slice / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AN bereitet den ersten lokalen Preview-/Implementierungs-Prompt fuer die
Bank-Spielminute vor. Der Slice legt fest, wie ein spaeterer isolierter
`Bank Meaning Puzzle + Context Door`-Preview aussehen duerfte, welche Dateien
dafuer spaeter ueberhaupt erlaubt waeren und welche Stop-Regeln weiter gelten.

M16-AN erstellt keinen App-Screen und keine produktive Mechanik.

Non-Goals:

- keine produktive App-Integration,
- keine Route,
- keine Navigation,
- keine produktive Seite,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Assets und keine Asset-Dateien unter `assets/`,
- keine produktive Quest Engine,
- keine Social-/Competition-/Timer-/Economy-Mechanik,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine Commit-Ausfuehrung.

## 2. Gelesene interne Grundlagen

| Dokument | Bedeutung fuer M16-AN |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes M16-T-Dashboard; `M16T-PLAY-008` bleibt teilweise, technische Architektur bleibt blockiert. |
| `docs/world_design/336-documentation-map-and-slice-reading-rules.md` | Prompt-/Output-Regeln, Visual-QA, Scope-Check und Regel: Docs geben keinen Code frei. |
| `docs/world_design/345-play-first-learning-experience-doctrine.md` | Play-First-Regel: Talvori ist kein Vokabeltrainer mit Spieldeko. |
| `docs/world_design/346-non-learning-game-patterns-for-play-first-talvori.md` | Sichere Muster: Mini-Puzzle, Choice Fork, Calm Retry, Curiosity Hook; gefaehrliche Muster bleiben blockiert. |
| `docs/world_design/347-first-playable-mvp-loop-slice-gate.md` | M16-AM waehlt `Bank` als erste Meaning-Puzzle-Loop-Variante. |
| `docs/world_design/330-minimal-playable-learning-loop-contract.md` | Learning-to-World Contract: Lernen erzeugt Moeglichkeit, keine Platzierung. |
| `docs/world_design/331-minimal-word-outcome-detail-gate.md` | `Bank` ist wegen Sitzbank/Geldinstitut/Flussufer ein `NeedsUserChoice`-/`ContextCard`-Fall. |
| `docs/world_design/332-reward-budget-and-review-queue-control-gate.md` | Keine Pflichtentscheidung, keine Review-Masse, `Later` bleibt erlaubt. |
| `docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md` | Context/Sense vor Word Type, Confidence, Theme/Plot und Reward. |
| `docs/world_design/334-companion-and-sensitive-return-safety-gate.md` | Tali/Vori darf erklaeren, aber nicht entscheiden, draengen oder Fortschritt ausloesen. |
| `docs/world_design/335-learning-states-and-srs-boundary-gate.md` | Preview-Interaktion darf keine SRS-/`word_progress`-Mutation erzeugen. |
| `docs/world_design/337-mobile-density-accessibility-and-depth-planning-gate.md` | Mobile-Lesbarkeit, kurze Overlays, erreichbare Exits und keine UI-Ueberladung. |

## 3. Preview-Ziel

Die spaetere Preview soll einen einzigen kleinen Spielmoment pruefbar machen:

```text
Am Fluss macht Tali kurz Pause.
```

M16-AS-Ergaenzung:

Die Preview soll diesen Moment als Flussufer-/Insel-/Plot-Szene zeigen, nicht
als separates Lernfenster. Bedeutungen werden als Orte, Wege, Schilder oder
Objekte in der Szene angeboten; Safe Exits, Companion-Hinweis und Codex-Erklaerung
bleiben HUD/Sprechblase/Overlay.

Das Wort `Bank` erscheint nicht als Vokabelabfrage, sondern als kleine
Situation. Die Nutzerentscheidung ist eine Meaning Puzzle / Context Door:

- `Sitzbank`,
- `Geldinstitut`,
- `Flussufer`.

Der sichere Ausgang:

- passende Bedeutung wird als ContextCard, Codex Discovery oder kleiner
  World Hint erklaert,
- falsche Auswahl fuehrt zu Calm Retry ohne Strafe,
- `Later`, `Codex`, `Backlog` und `Change` bleiben sichtbar oder fachlich
  simuliert,
- kein Build,
- kein Placement,
- kein SRS-/`word_progress`-Write,
- kein Asset,
- kein BuildState,
- kein `frame_started`.

## 4. Play-First-Check fuer die Bank-Preview

| Frage | M16-AN-Antwort |
| --- | --- |
| Was ist der Spielmoment? | Eine kleine Context Door: Aus einer Fluss-Situation muss die passende Bedeutung von `Bank` erkannt werden. |
| Was macht neugierig? | Das Wort ist absichtlich mehrdeutig; Nutzer will wissen, welche Tuer zur Szene passt. |
| Was ist die kleine Challenge? | Nicht das Wort uebersetzen, sondern die Bedeutung aus Situation und Ort ableiten. |
| Was fuehlt sich belohnend an? | Die Szene klaert sich; Tali/Vori macht kurz Pause am richtigen Ort; eine ContextCard oder Codex Discovery wird sichtbar. |
| Was lernt der Nutzer nebenbei? | `Bank` kann Sitzbank, Geldinstitut oder Flussufer bedeuten; Kontext entscheidet. |
| Warum ist es keine klassische Uebung? | Keine Multiple-Choice-Vokabelabfrage als Hauptgefuehl, sondern eine kleine Spielentscheidung in einer Szene. |
| Welche Druckmuster sind ausgeschlossen? | Timer, Streak, XP-Grind, Pflichtreview, FOMO, Verlust, Strafe, sensitive Retention, Social-Druck. |
| Wo sind Safe Exits? | `Later`, `Codex`, `Backlog`, `Change` und Ende ohne Pflicht bleiben sichtbar oder fachlich simuliert. |

Pflichtregel fuer den spaeteren Code-Prompt:

Jeder Code-Slice fuer diese Preview muss diesen Play-First-Check wiederholen
und zeigen, wie der konkrete UI-Zustand den Spielmoment traegt.
`M16T-PLAY-008` bleibt bis zur Anwendung in einem echten Implementierungs-Slice
teilweise erledigt.

## 5. Isolierungsstrategie

Die spaetere Bank-Preview darf nur lokal und isoliert entstehen.

Erlaubte Richtung, nur nach separater Freigabe:

- eine isolierte Preview-Datei,
- optional ein lokaler Debug-/Sandbox-Entry,
- lokale `setState`-Zustaende,
- statische Beispieltexte,
- Standard-Flutter-Widgets oder vorhandene sichere Basiselemente,
- kein Datenzugriff.

Blockiert:

- Einbindung in echte Navigation,
- Home-Screen-Umbau,
- produktiver Lernmodus,
- Datenmodell,
- lokale DB,
- Supabase,
- Provider,
- Routing,
- Persistenz,
- Import-/SRS-/`word_progress`-Kopplung,
- Reward Bridge,
- Build-Wheel,
- App-Startpunkt-Umbau,
- Assets unter `assets/`.

## 6. Erlaubte spaetere Code-Optionen

M16-AN implementiert keine dieser Optionen. Die Optionen sind nur
Folge-Prompt-Material.

| Option | Beschreibung | Vorteile | Risiken | Spaeter erlaubte Dateien | Blockierte Dateien | Checks |
| --- | --- | --- | --- | --- | --- | --- |
| Option A | Isolierte lokale Flutter-Preview-Datei. | Interaktiv pruefbar, klein, nah am ersten Spielmoment. | Koennte versehentlich als produktiver Screen gelesen werden. | `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart`; optional nach eigener Freigabe `bank_meaning_puzzle_preview_main.dart`. | App-Routen, Home, produktive Navigation, Datenlayer, Assets, Tests ohne Test-Gate. | `dart format`, `flutter analyze` oder `dart analyze` fuer geaenderte Dateien, `git diff --check`, Scope-Check. |
| Option B | Storyboard-/Diagramm-only fortsetzen. | Maximal sicher, keine Code-Gefahr. | Keine echte Interaktion, Spielgefuehl schwer pruefbar. | Nur `docs/world_design/...` und Preview-Diagramme. | Alle `lib/`, `assets/`, `test/`, `integration_test/`. | Visual-QA, SVG-Parse, `git diff --check`. |
| Option C | Isolierter Widget-Test/Golden-aehnlicher Preview spaeter. | Kann Layout spaeter pruefen. | Tests sind aktuell explizit blockiert und brauchen eigenes Test-Gate. | Erst nach Test-Gate unter klar erlaubtem Testpfad. | Tests in M16-AN oder ohne Freigabe. | Test-Gate, A11y-/Device-Plan, Scope-Check. |

## 7. Empfohlene naechste Implementierungsvariante

M16-AN empfiehlt fuer einen spaeteren, separat freizugebenden Code-Slice:

```text
Option A: isolierte lokale Preview-Datei
```

Begruendung:

- Bank braucht echte Auswahlinteraktion, sonst bleibt das Play-First-Gefuehl
  theoretisch.
- Eine isolierte Datei kann den Spielmoment zeigen, ohne App-Integration,
  Route, Persistenz, Assets oder SRS zu beruehren.
- Drei Bedeutungen reichen fuer eine kleine, mobile-lesbare Challenge.
- Die Preview kann Guardrails sichtbar machen: `Later`, `Codex`, `Backlog`,
  `Change`, Calm Retry, kein Build.

Nicht empfohlen als naechster Schritt:

- produktiver Screen,
- Route,
- Home-Zentrale-Umbau,
- Review-Queue-Implementierung,
- Datenmodell,
- Persistenz,
- Asset-Erstellung,
- Build-Wheel,
- Social-/Timer-/Economy-Mechanik.

## 8. Preview-Verhalten

| Zustand | Erlaubtes Verhalten | Blockiert |
| --- | --- | --- |
| Startzustand | Kurze Szene: Tali macht am Fluss Pause; `Bank` wird als Kontextproblem gezeigt. | Vokabeltest-Intro, Pflichtlernen, Textwand. |
| Auswahlzustand | Drei klare Optionen: Sitzbank, Geldinstitut, Flussufer. | Mehr als drei Optionen, Timer, Punktedruck. |
| Richtige Auswahl | ContextCard oder Codex Discovery erklaert, warum Kontext entscheidet; kleiner World Hint als Preview. | Build, Placement, SRS-Write, XP-Grind. |
| Falsche Auswahl | Calm Retry: kurz erklaeren, dass Kontext noch einmal angesehen werden kann. | Strafe, Beschaemung, Weltstrafe, Verlust. |
| Later | Entscheidung wird ohne Nachteil geparkt. | Warnung, Druck, Streak-Schuld. |
| Codex | Bedeutung wird neutral im Codex/ContextCard-Raum erklaert. | Persistenz oder produktiver Codex-Write ohne Gate. |
| Backlog | Preview simuliert Parken fuer spaeter. | Versteckte Queue- oder DB-Aenderung. |
| Change | Nutzer kann Bedeutung wechseln und erneut pruefen. | Irreversible Entscheidung. |
| Ende | Runde endet ohne Pflicht und ohne automatische Folgeentscheidung. | Review-Zwang, Social-Druck, Timer, BuildState. |

## 9. UI-/UX-Grenzen

M16-AN gibt keine UI-Implementierung frei, definiert aber spaetere
Preview-Grenzen:

- mobile-lesbar,
- maximal drei Bedeutungsoptionen,
- keine Textwand,
- Tali/Vori optional und kurz,
- `Later` sichtbar,
- Feedback kurz und ruhig,
- Calm Retry statt Fehlerstrafe,
- keine Animation, wenn sie ablenkt,
- keine Soundpflicht,
- keine Assetpflicht,
- keine Motionpflicht,
- keine Dauer-Overlays,
- Close/Later/Backlog/Change bleiben erreichbar.

## 10. Akzeptanzkriterien fuer einen spaeteren Code-Slice

Ein spaeterer Implementierungs-Prompt darf nur freigegeben werden, wenn er
mindestens diese Kriterien enthaelt:

- Preview zeigt die Bank-Fluss-Situation.
- Drei Bedeutungen sind sichtbar: Sitzbank, Geldinstitut, Flussufer.
- Auswahl funktioniert lokal.
- Richtige Auswahl zeigt ContextCard, Codex Discovery oder kleinen World Hint.
- Falsche Auswahl fuehrt zu Calm Retry ohne Strafe.
- `Later`, `Codex`, `Backlog` und `Change` sind sichtbar oder fachlich
  simuliert.
- Kein SRS-/`word_progress`-Write.
- Keine Persistenz.
- Keine Route.
- Keine App-Integration.
- Keine produktive Navigation.
- Keine Assets unter `assets/`.
- Keine automatische Wortplatzierung.
- Kein BuildState.
- Kein `frame_started`.
- Kein Launch-Target ohne ausdrueckliche separate Freigabe.
- `dart format` fuer geaenderte Dart-Dateien.
- `flutter analyze` oder `dart analyze` nur fuer geaenderte Dart-Dateien,
  falls Code im Folge-Slice entsteht.
- Tests nur nach expliziter Testfreigabe.
- `git diff --check`.
- `git status --short`.
- Nicht committen.

## 11. Draft: Later Implementation Prompt

Der folgende Prompt ist nur ein Draft. Er ist durch M16-AN nicht freigegeben
und darf erst nach separater Nutzerfreigabe ausgefuehrt werden.

```text
Wir arbeiten im Repository talvori.

Bitte setze einen minimalen, isolierten lokalen Preview-Code-Slice um:
Bank Meaning Puzzle Preview.

Fuehrende Docs:
- docs/world_design/348-isolated-bank-meaning-puzzle-preview-gate.md
- docs/world_design/347-first-playable-mvp-loop-slice-gate.md
- docs/world_design/345-play-first-learning-experience-doctrine.md
- docs/world_design/331-minimal-word-outcome-detail-gate.md
- docs/world_design/333-minimal-semantic-profile-and-routing-priority-gate.md
- docs/world_design/337-mobile-density-accessibility-and-depth-planning-gate.md

Vor dem Start:
- git status --short ausgeben.
- Bestehende lokale Preview-Muster lesen.
- Betroffene Datei vor der Aenderung nennen.

Erstelle ausschliesslich:
- lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart

Kein Launch-Target.
Keine App-Integration.
Keine Route.
Keine Navigation.
Keine Persistenz.
Keine Supabase/local DB Writes.
Keine SRS-/word_progress-Aenderung.
Keine automatische Wortplatzierung.
Keine Assets.
Kein BuildState.
Kein frame_started.
Keine Tests.

Preview-Inhalt:
- Szene: "Am Fluss macht Tali kurz Pause."
- Wort: Bank.
- Bedeutungen: Sitzbank, Geldinstitut, Flussufer.
- Lokale Auswahl per setState.
- Richtige Auswahl: ContextCard/Codex Discovery/kleiner World Hint.
- Falsche Auswahl: Calm Retry ohne Strafe.
- Later, Codex, Backlog, Change sichtbar oder fachlich simuliert.
- Sichtbare Guardrails: keine Speicherung, keine Platzierung, kein BuildState,
  keine automatische Wortplatzierung.

Nach der Aenderung:
- dart format fuer die neue Datei.
- flutter analyze oder dart analyze fuer die neue Datei, soweit projektseitig
  sinnvoll.
- git diff --check.
- git status --short.

Nicht committen.
```

## 12. M16-T-ID-Entscheidung

| ID | Entscheidung in M16-AN | Grund |
| --- | --- | --- |
| `M16T-PLAY-008` | bleibt `[~]` | Der Play-First-Check ist fuer die Bank-Preview operationalisiert, aber noch nicht in einem echten Implementierungs-Slice angewendet. |
| `M16T-CORE-003` | bleibt `[~]` | UI-Events werden als Stop-Regel benannt; produktive UI-Event-Grenzen brauchen spaetere Anwendung. |
| `M16T-L2W-003` | bleibt `[~]` | `Bank` zeigt Weltreife als Context/Sense-Entscheidung, aber kein produktives Gate ist umgesetzt. |
| `M16T-ARCH-001` | bleibt `[!]` | Architektur-/Boundary-Gate bleibt vor produktiver Kopplung blockiert. |
| `M16T-ARCH-002` | bleibt `[!]` | App-Integration bleibt blockiert. |
| `M16T-ARCH-003` | bleibt `[!]` | Route-Gate bleibt blockiert. |
| `M16T-ARCH-004` | bleibt `[!]` | Test-/Performance-/Accessibility-Gate bleibt blockiert. |
| `M16T-DOC-003` | bleibt `[~]` | Visual-QA-Regel wird angewendet, aber nicht global abgeschlossen. |
| `M16T-GIT-003` | bleibt `[!]` | Commit bleibt bis separater Freigabe blockiert. |

Dashboard-Folge:

- Gesamtanzahl bleibt `127`.
- Gewichteter Fortschritt bleibt `85.4 %`.
- M16-AN aendert den Sprint-/Aktueller-Stand-Kontext, aber keine
  M16-T-Statuswerte.

## 13. Dokumentationsvisualisierungen

M16-AN erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_an_bank_meaning_puzzle_preview/`

Visuals:

- `isolated_preview_boundary.png` und `.svg`,
- `bank_meaning_puzzle_state_flow.png` und `.svg`,
- `play_first_preview_check.png` und `.svg`,
- `allowed_files_vs_blocked_files.png` und `.svg`,
- `implementation_readiness_gate.png` und `.svg`,
- optional `00_contact_sheet.png` und `.svg`.

Diese Visuals sind Dokumentationsmaterial, keine App-Screens, keine
Screenshots, keine Spielassets und keine Dateien unter `assets/`.

Visual-QA:

- PNG und SVG erzeugen.
- Text bleibt vollstaendig in Karten/Rahmen/Panels.
- Keine Woerter laufen aus Rahmen.
- Ausreichender Innenabstand.
- Keine unerwuenschten Ueberlappungen.
- Contact Sheet vollstaendig lesbar.
- Keine abgeschnittenen Inhalte.
- SVG-Dateien sind XML-parsebar.

## 14. Stop-Regeln

Aus M16-AN folgt ausdruecklich:

- Keine App-Integration.
- Keine Route.
- Keine produktive Navigation.
- Keine Flutter-/Dart-Codeaenderung in diesem Slice.
- Keine Persistenz.
- Keine Supabase/local DB Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine automatische Wortplatzierung.
- Kein Build-Wheel-Code.
- Keine Assets oder Asset-Dateien unter `assets/`.
- Kein BuildState.
- Kein `frame_started`.
- Keine Bauzustaende.
- Keine Screenshots als Repo-Artefakte.
- Keine Tests oder Widget-Tests.
- Keine Social-/Competition-/Economy-/Timer-Implementierung.
- Keine Produktivmechanik-Freigabe.
- Nicht committen.
