# M16-P: Word Semantics Decision Preview Implementation Prompt Draft

Stand: 2026-06-07

Status: `Prompt-Draft gestartet / keine Implementierung`

## 1. Ziel

M16-P dokumentiert einen spaeteren Implementierungs-Prompt fuer einen
minimalen, isolierten `WordSemanticsDecisionPreview`-Code-Slice. Der Prompt
wird in diesem Block nur vorbereitet. Er wird nicht ausgefuehrt.

Aus M16-P folgen keine Flutter-/Dart-Dateien, keine neue Dart-Datei, keine
App-Integration, keine Route, keine neue Seite, keine Tests, keine
Screenshots, keine Runtime-Konfiguration, keine Persistenz, keine Supabase
Writes, keine lokalen DB-Writes, keine SRS-/`word_progress`-Aenderung, keine
Reward Bridge, keine automatische Wortplatzierung, keine Build-Wheel-
Implementierung, keine Assets, keine Asset-Dateien unter `assets/`, kein
Build-State, kein `frame_started` und keine Bauzustaende.

## 2. Gepruefte Grundlage

| Dokument | Bedeutung fuer M16-P |
| --- | --- |
| `docs/world_design/324-word-semantics-preview-implementation-gate.md` | Fuehrendes Gate: spaeterer Code-Slice theoretisch moeglich, aber nicht freigegeben. |
| `docs/world_design/323-word-semantics-decision-preview-scope.md` | Definiert Preview-Pipeline, Beispielwoerter und sichere Ausgaenge. |
| `docs/world_design/322-next-safe-preview-slice-decision-gate.md` | Empfiehlt `WordSemanticsDecisionPreview` als sichersten naechsten Kandidaten. |
| `docs/world_design/321-global-world-semantics-consistency-audit.md` | Pflichtfilter: Context/Sense, Word-Type, Safety, Representation Decision, User Choice. |
| `docs/world_design/270-word-to-island-routing-matrix.md` | Routing macht Vorschlaege und platziert nichts automatisch. |
| `docs/world_design/272-plot-capability-derivation.md` | Plot-Capabilities sind Erlaubnisse, keine Pflichtbelegung. |
| `docs/world_design/274-sensitive-content-representation-rules.md` | Sensitive/abstract Begriffe brauchen neutrale Fallbacks und Policy Gates. |
| `docs/world_design/276-mobile-clutter-rules-small-objects.md` | Kleine Objekte gehoeren in Container/Depth/Codex/Backlog, nicht automatisch in IslandView. |
| `docs/world_design/284-word-to-island-ux-flow.md` | User Choice, Sense und sichere Fallbacks stehen vor sichtbarer Platzierung. |

## 3. Spaeter erlaubter Implementierungs-Scope

Nur nach separater ausdruecklicher Nutzerfreigabe duerfte ein spaeterer
Implementierungsblock hoechstens Folgendes erstellen:

| Spaetere Datei | Status in M16-P | Zweck |
| --- | --- | --- |
| `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart` | nur geplant, nicht erstellen | Isolierte lokale Preview fuer Beispielwort-Entscheidungen. |
| `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview_main.dart` | optionaler spaeterer Launch-Target, nicht erstellen | Nur falls separat freigegeben, fuer manuelles lokales `flutter run -t`. |

Der spaetere Code-Slice duerfte hoechstens enthalten:

- lokale, isolierte Preview,
- Beispielwortkarten fuer:
  - `Haus`,
  - `Garage`,
  - `Baum`,
  - `schwimmen`,
  - `Angst`,
  - `lernen`,
  - `Messer`,
  - `Polizei`,
- lokale Auswahl eines Beispielwortes per `setState`,
- Anzeige pro Beispielwort:
  - Context/Sense,
  - Word Type,
  - Safety/Sensitive,
  - Candidate ThemeIsland(s),
  - Candidate Plot/Depth,
  - Representation Decision,
  - Preview Only / Later Gate,
- klare Guardrails:
  - Keine Speicherung,
  - Keine Platzierung,
  - Kein Bauzustand,
  - Keine automatische Wortplatzierung.

## 4. Ausdruecklich blockierter spaeterer Scope

Auch der spaetere Implementierungs-Prompt muss blockieren:

- keine echte Routing-Implementierung,
- keine finale Datenstruktur,
- keine App-Integration,
- keine Route,
- keine produktive Navigation,
- keine Persistenz,
- keine Supabase Writes,
- keine lokalen DB-Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine Reward Bridge,
- keine automatische Wortplatzierung,
- keine Build-Wheel-Implementierung,
- keine Assets,
- keine Asset-Dateien unter `assets/`,
- kein Build-State,
- kein `frame_started`,
- keine Bauzustaende.

## 5. Spaeterer Check-Ablauf

Der spaetere Implementierungs-Prompt muss verlangen:

1. vorher `git status --short`,
2. relevante Dateien lesen,
3. betroffene Dateien vor jeder Aenderung nennen,
4. nur den freigegebenen isolierten Preview-Scope umsetzen,
5. `dart format` fuer geaenderte Dart-Dateien,
6. `dart analyze` fuer geaenderte Dart-Dateien,
7. `git diff --check`,
8. `git status --short`,
9. nicht committen.

## 6. Draft: Later Implementation Prompt

Der folgende Prompt ist ein Entwurf. Er ist in M16-P nicht freigegeben und darf
jetzt nicht ausgefuehrt werden.

```text
Wir arbeiten im Repository `talvori`.

Ich gebe den minimalen isolierten `WordSemanticsDecisionPreview`-Code-Slice
jetzt ausdruecklich frei.

Nutze als fuehrende Dokumente:
- `docs/world_design/325-word-semantics-preview-implementation-prompt-draft.md`
- `docs/world_design/324-word-semantics-preview-implementation-gate.md`
- `docs/world_design/323-word-semantics-decision-preview-scope.md`
- `docs/world_design/321-global-world-semantics-consistency-audit.md`
- `docs/world_design/270-word-to-island-routing-matrix.md`
- `docs/world_design/272-plot-capability-derivation.md`
- `docs/world_design/274-sensitive-content-representation-rules.md`
- `docs/world_design/276-mobile-clutter-rules-small-objects.md`
- `docs/world_design/284-word-to-island-ux-flow.md`

Wichtig:
- Vor dem Start `git status --short` ausgeben.
- Bestehende Struktur lesen, bevor Dateien geaendert werden.
- Betroffene Dateien vor jeder Aenderung konkret nennen und kurz begruenden.
- Keine unklaren Dateien aendern.
- Nur den minimalen lokalen Preview-Scope umsetzen.
- Noch nicht committen.

Erlaubter Minimal-Scope:
- Erstelle hoechstens:
  `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview.dart`
- Optionaler Launch-Target nur falls in diesem Prompt ausdruecklich erlaubt:
  `lib/features/world/local_world/ui/widgets/word_semantics_decision_preview_main.dart`
- Lokale, isolierte Preview.
- Beispielwortkarten:
  - Haus
  - Garage
  - Baum
  - schwimmen
  - Angst
  - lernen
  - Messer
  - Polizei
- Lokale Auswahl eines Beispielwortes per `setState`.
- Anzeige pro Beispielwort:
  - Context/Sense
  - Word Type
  - Safety/Sensitive
  - Candidate ThemeIsland(s)
  - Candidate Plot/Depth
  - Representation Decision
  - Preview Only / Later Gate
- Sichtbare Guardrails:
  - Keine Speicherung
  - Keine Platzierung
  - Kein Bauzustand
  - Keine automatische Wortplatzierung

Explizit blockiert:
- keine echte Routing-Implementierung
- keine finale Datenstruktur
- keine App-Integration
- keine Route
- keine produktive Navigation
- keine Persistenz
- keine Supabase Writes
- keine lokalen DB-Writes
- keine SRS-/`word_progress`-Aenderung
- keine Reward Bridge
- keine automatische Wortplatzierung
- keine Build-Wheel-Implementierung
- keine Assets
- keine Asset-Dateien unter `assets/`
- kein Build-State
- kein `frame_started`
- keine Bauzustaende
- keine Tests, ausser sie werden in diesem Prompt zusaetzlich ausdruecklich
  freigegeben
- keine Screenshots

Nach der Aenderung:
- `dart format` fuer alle geaenderten Dart-Dateien ausfuehren.
- `dart analyze` fuer alle geaenderten Dart-Dateien ausfuehren.
- `git diff --check` ausfuehren.
- `git status --short` ausfuehren.

Abschlussausgabe:
1. Vorheriger `git status --short`
2. Welche Dateien gelesen wurden
3. Welche Dateien geaendert/erstellt wurden
4. Warum genau diese Datei(en) noetig waren
5. Kurze Beschreibung der Preview
6. Scope-Nachweis:
   - keine App-Integration
   - keine Route
   - keine produktive Navigation
   - keine Persistenz
   - keine Runtime-Konfiguration
   - keine Assets
   - keine Tests
   - keine Screenshots
   - keine automatische Wortplatzierung
   - kein Build-State
   - kein `frame_started`
7. Ergebnis von `dart format`
8. Ergebnis von `dart analyze`
9. Ergebnis von `git diff --check`
10. Ergebnis von `git status --short`

Nicht committen.
```

## 7. Dokumentationsvisualisierungen

M16-P ergaenzt echte PNG-Dokumentationsvisualisierungen unter:

`docs/world_design/previews/m16_p_word_semantics_preview_prompt_draft/`

Erzeugte Visuals:

- `01_prompt_scope_boundary.png`
- `02_later_prompt_execution_flow.png`
- `03_preview_widget_content_map.png`
- `04_stop_rules_for_later_prompt.png`
- optional `00_contact_sheet.png`

Diese PNGs sind Dokumentationspreviews. Sie sind keine Screenshots, keine
App-Screens, keine finalen UI-PNGs, keine Spielassets und keine Dateien unter
`assets/`.

Visual-Quality-Regel:

Alle M16-P-Visuals muessen Text-Containment, Innenabstand, Kartenabstand,
ueberlappungsfreie Karten, Labels, Pfeile, Titel, Footer und Legenden,
lesbares Contact Sheet sowie nicht abgeschnittene Inhalte pruefen.

## 8. Stop-Regeln

Aus M16-P folgt ausdruecklich:

- Keine Implementierung.
- Keine Flutter-/Dart-Dateien.
- Keine neue Dart-Datei.
- Keine App-Integration.
- Keine Route.
- Keine neue Seite.
- Keine Tests und keine Widget-Tests.
- Keine Screenshots.
- Keine Runtime-Konfiguration.
- Keine Persistenz.
- Keine Supabase Writes.
- Keine lokalen DB-Writes.
- Keine SRS-/`word_progress`-Aenderung.
- Keine Reward Bridge.
- Keine automatische Wortplatzierung.
- Keine Build-Wheel-Implementierung.
- Keine Assets.
- Keine Asset-Dateien unter `assets/`.
- Kein Build-State.
- Kein `frame_started`.
- Keine Bauzustaende.
