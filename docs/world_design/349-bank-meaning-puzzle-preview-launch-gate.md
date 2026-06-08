# M16-AP: Bank Meaning Puzzle Preview Launch Gate

Stand: 2026-06-08

Status: `Dokumentations-/Gate-Slice / keine Implementierung`

## 1. Zweck und Non-Goals

M16-AP prueft, ob und wie die isolierte Bank Meaning Puzzle Preview lokal
sichtbar gestartet werden duerfte. Ziel ist ein sicherer naechster
Implementierungsrahmen fuer einen optionalen lokalen Preview-Startpunkt, ohne
produktive App-Integration.

M16-AP erstellt keinen Code und keine Launch-Datei.

Non-Goals:

- keine produktive App-Integration,
- keine Route,
- keine Navigation,
- keine Home-/main-/Router-Aenderung,
- keine Persistenz,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets und keine Asset-Dateien unter `assets/`,
- kein BuildState,
- kein `frame_started`,
- keine Bauzustaende,
- keine Tests oder Widget-Tests,
- keine Screenshots als Repo-Artefakte,
- keine produktive Mechanik-Freigabe,
- keine Commit-Ausfuehrung.

## 2. Gelesene interne Grundlagen

| Dokument / Datei | Bedeutung fuer M16-AP |
| --- | --- |
| `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md` | Fuehrendes Dashboard und betroffene M16-T-IDs. |
| `docs/world_design/336-documentation-map-and-slice-reading-rules.md` | Prompt-, Output-, Scope- und Visual-QA-Regeln. |
| `docs/world_design/348-isolated-bank-meaning-puzzle-preview-gate.md` | Direkter Gate-Vorgaenger fuer Bank Preview und Folge-Prompt. |
| `docs/world_design/347-first-playable-mvp-loop-slice-gate.md` | Erster MVP-Loop: Bank als Meaning Puzzle + Context Door. |
| `docs/world_design/345-play-first-learning-experience-doctrine.md` | Play-First Rule und Implementierungs-Pflichtcheck. |
| `docs/world_design/346-non-learning-game-patterns-for-play-first-talvori.md` | Sichere Mini-Puzzle-/Context-Door-Muster und blockierte Druckmuster. |
| `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart` | M16-AO-Widget: isoliert, lokal, ohne Route, Datenzugriff oder Assets. |

## 3. Aktueller Stand nach M16-AO

M16-AO hat nur diese Datei erstellt:

`lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart`

Aktueller Befund:

- Die Preview ist ein isoliertes Widget.
- Die Preview ist noch nicht ueber App, Route oder Navigation startbar.
- Es existiert kein Launch-Target fuer `flutter run -t`.
- Das Widget importiert nur `package:flutter/material.dart`.
- Das Widget nutzt lokale `StatefulWidget`-/`setState`-Zustaende.
- Es gibt keine Provider-, Router-, Supabase-, DB-, SRS- oder
  `word_progress`-Imports.
- `dart analyze` fuer die Datei war sauber.
- Projektweites `flutter analyze` hat bestehende Fremdbefunde ausserhalb des
  Slice gezeigt, unter anderem `ios_pods_check/...` und einen fehlenden
  `browser_return_service.dart`-Import.

Play-First-Befund:

- Szene sichtbar: `Am Fluss macht Tali kurz Pause.`
- Wort sichtbar: `Bank`.
- Drei Bedeutungen sichtbar: `Sitzbank`, `Geldinstitut`, `Flussufer`.
- Auswahl ist lokal moeglich.
- Richtiges Feedback ist ContextCard/Codex-Discovery-artig.
- Falsches Feedback ist Calm Retry ohne Strafe.
- Safe Exits `Later`, `Codex`, `Backlog`, `Change` sind sichtbar.
- Guardrails `kein Timer`, `kein Streak`, `kein XP`, `kein Review-Zwang`,
  `kein Build`, `kein Placement`, `kein SRS-Write` sind sichtbar.

## 4. Launch-Optionen

| Option | Beschreibung | Vorteile | Risiken | Erlaubte Dateien | Blockierte Dateien | Checks | App-Integration simuliert? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Option A | Isoliertes lokales Preview-Launch-Target als separate `*_main.dart` Datei. | Lokal mit `flutter run -t` pruefbar; folgt bestehenden Preview-Mustern; keine Route noetig. | Koennte faelschlich als App-Integration gelesen werden, wenn Stop-Regeln fehlen. | `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview_main.dart` | `lib/main.dart`, Router, Home, Provider, Datenlayer, `assets/`, `test/`, `integration_test/` | `dart format`, `dart analyze` fuer neue Datei, `git diff --check`, Scope-Check | Nein, wenn nur lokaler `runApp(MaterialApp(home: ...))` Einstieg. |
| Option B | Keine Launch-Datei; Widget bleibt nur im Code vorhanden. | Maximal sicher; keine neue Dart-Datei. | Preview bleibt praktisch schwer sichtbar; Playtest der ersten Spielminute bleibt blockiert. | keine neue Datei | alle neuen Dateien | `git status`, ggf. Code-Review der bestehenden Datei | Nein. |
| Option C | Temporaerer Dev-/Debug-Hook in vorhandener App. | Kann echte App-Umgebung zeigen. | Hohe Scope-Gefahr: Route, Navigation, Home, Provider oder Debug-Code koennen produktiv werden. | keine in M16-AP erlaubte Datei | App, Home, Router, Navigation, Provider, Datenlayer | eigenes App-Integration-/Route-Gate noetig | Ja, deshalb fuer jetzt blockiert. |

## 5. Empfohlene sichere Launch-Variante

M16-AP empfiehlt fuer einen spaeteren, separat freizugebenden Code-Slice:

```text
Option A: isoliertes lokales Preview-Launch-Target
```

Begruendung:

- Im Projekt existieren bereits lokale Preview-Launch-Muster mit separaten
  `*_main.dart`-Dateien.
- `flutter run -t` kann die Preview sichtbar machen, ohne produktive App,
  Route oder Navigation zu beruehren.
- Ein isolierter Startpunkt kann nur Flutter-Bindings initialisieren und
  `BankMeaningPuzzlePreview` in einer kleinen `MaterialApp` starten.
- Der Spielmoment bleibt pruefbar: Szene, drei Bedeutungen, lokale Auswahl,
  ruhiges Feedback und Safe Exits.

Pflichtgrenze:

Der lokale Launch darf nicht als App-Integration gelesen werden. Er ist nur ein
manueller Sandbox-Einstieg fuer die Preview.

## 6. Erlaubte spaetere Code-Dateien

Bereits vorhanden:

- `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview.dart`

Spaeter optional erlaubt, nur nach separater Freigabe:

- `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview_main.dart`

Der spaetere Launch-Target darf hoechstens:

- Flutter-Bindings initialisieren,
- `BankMeaningPuzzlePreview` starten,
- eine lokale `MaterialApp` oder `Directionality` setzen, falls noetig,
- den lokalen Startbefehl dokumentieren.

Blockiert:

- `lib/main.dart`,
- App router,
- Home screen,
- Navigation,
- Provider,
- Datenlayer,
- Supabase,
- `assets/`,
- `test/`,
- `integration_test/`,
- produktive App-Struktur,
- produktive Route,
- produktive Screen-Registrierung.

## 7. Akzeptanzkriterien fuer einen spaeteren Launch-Code-Slice

Ein spaeterer M16-AQ- oder vergleichbarer Code-Slice duerfte nur freigegeben
werden, wenn er mindestens diese Kriterien einhaelt:

- Startet nur lokal als Preview.
- Erstellt ausschliesslich
  `lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview_main.dart`.
- Importiert nur Flutter/Material und `bank_meaning_puzzle_preview.dart`.
- Verwendet keine produktive App-Struktur.
- Kein Import in produktive App.
- Keine Route.
- Keine Navigation.
- Keine Home-/main-/Router-Aenderung.
- Keine Persistenz.
- Keine Supabase/local DB Writes.
- Kein SRS-/`word_progress`.
- Kein BuildState.
- Kein `frame_started`.
- Keine Assets.
- Keine Tests.
- `dart format` fuer die neue Datei.
- `dart analyze` fuer die neue Datei.
- `git diff --check`.
- `git status --short`.
- Scope-Check gegen `lib/`, `assets/`, `test/`, `integration_test/`.
- Nicht committen.

## 8. Play-First-Check fuer lokalen Launch

Ein lokaler Launch darf das Spielgefuehl der Preview nicht veraendern.

| Prueffrage | M16-AP-Befund |
| --- | --- |
| Szene sichtbar? | Ja, M16-AO zeigt `Am Fluss macht Tali kurz Pause.` |
| Drei Bedeutungen sichtbar? | Ja: `Sitzbank`, `Geldinstitut`, `Flussufer`. |
| Auswahl lokal moeglich? | Ja, lokal per `setState`. |
| Feedback ruhig? | Ja, richtige Auswahl klaert Bedeutung; falsche Auswahl ist Calm Retry. |
| Safe Defaults sichtbar? | Ja: `Later`, `Codex`, `Backlog`, `Change`. |
| Score-/Streak-/Timer-/XP-Logik? | Nein, im Widget explizit als Guardrail blockiert. |
| Klassischer Vokabeltest als Hauptgefuehl? | Nein, die Struktur ist Context Door / Meaning Puzzle. |

M16T-PLAY-008 kann damit als erledigt markiert werden: Der Play-First-Check
ist nicht nur dokumentiert, sondern in M16-AO praktisch im
Implementierungsprozess angewendet und in M16-AP gegen den Launch-Rahmen
ueberprueft.

## 9. M16-T-ID-Entscheidung

| ID | Entscheidung in M16-AP | Grund |
| --- | --- | --- |
| `M16T-PLAY-008` | `[x]` | Play-First-Check wurde in M16-AO angewendet und in M16-AP fuer den lokalen Launch als Pflichtfilter nachgewiesen. |
| `M16T-ARCH-001` | bleibt `[!]` | Architecture/Boundary-Gate bleibt fuer produktive Kopplung blockiert. |
| `M16T-ARCH-002` | bleibt `[!]` | App-Integration bleibt blockiert. |
| `M16T-ARCH-003` | bleibt `[!]` | Route-Gate bleibt blockiert. |
| `M16T-ARCH-004` | bleibt `[!]` | Test-/Performance-/Accessibility-Gate bleibt blockiert. |
| `M16T-GIT-003` | bleibt `[!]` | Commit bleibt bis separater Freigabe blockiert. |
| `M16T-DOC-003` | bleibt `[~]` | Visual-QA wird angewendet, aber globale Visual-QA-Disziplin bleibt fortlaufend. |

Dashboard-Folge:

- Gesamtanzahl bleibt `127`.
- `M16T-PLAY-008` wechselt von `[~]` zu `[x]`.
- Gewichteter Fortschritt steigt von `85.4 %` auf `85.8 %`.

## 10. Dokumentationsvisualisierungen

M16-AP erzeugt Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_ap_bank_preview_launch_gate/`

Visuals:

- `launch_option_matrix.png` und `.svg`,
- `isolated_launch_boundary.png` und `.svg`,
- `allowed_vs_blocked_launch_files.png` und `.svg`,
- `launch_acceptance_gate.png` und `.svg`,
- `play_first_launch_check.png` und `.svg`,
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

## 11. Stop-Regeln

M16-AP gibt nicht frei:

- App-Integration,
- Route,
- produktive Navigation,
- Home-/main-/Router-Aenderung,
- Flutter-/Dart-Codeaenderung in diesem Slice,
- Persistenz,
- Supabase/local DB Writes,
- SRS-/`word_progress`-Aenderung,
- automatische Wortplatzierung,
- Build-Wheel-Code,
- Assets oder Asset-Dateien unter `assets/`,
- BuildState,
- `frame_started`,
- Bauzustaende,
- Screenshots als Repo-Artefakte,
- Tests oder Widget-Tests,
- Produktivmechanik-Freigabe,
- Commit-Ausfuehrung.
