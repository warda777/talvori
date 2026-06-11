# Template: Docs-only Slice

Status: `Arbeitsvertrag / keine Implementierungsfreigabe`

## Einsatz

Nutze dieses Template fuer reine Dokumentations-, Gate-, Planungs-,
Boundary-, Research- oder Projektmanagement-Slices.

## Kurzprompt muss nennen

- Slice-ID,
- Ziel,
- erwartete neue/geaenderte Markdown-Dateien,
- besondere Grenzen,
- ob 328/336 aktualisiert werden sollen,
- Commit-Status.

## Geerbte Regeln

- Pflichtlektuere aus `docs/world_design/336-documentation-map-and-slice-reading-rules.md`.
- M16-T-ID-Abgleich aus `docs/world_design/328-talvori-learning-game-readiness-todo-checklist.md`.
- Source-of-Truth- und External-Write-Regeln aus AGENTS.md und 362.
- Kein Commit ohne separate ausdrueckliche Freigabe.

## Standard-Stop-Regeln

- keine Flutter-/Dart-Dateien,
- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- keine Dateien unter `assets/`,
- keine Bilder, PNG, SVG oder Preview-Ordner, ausser der Kurzprompt erlaubt
  Visuals ausdruecklich,
- keine Tests,
- keine externen Writes.

## Arbeitsablauf

1. `git status --short` pruefen.
2. Pflichtdocs aus 336 und Kurzprompt lesen.
3. Erwartete Dateien und Stop-Regeln gegen den aktuellen Status pruefen.
4. Markdown-Dateien erstellen oder aktualisieren.
5. 328 aktualisieren, wenn M16-T-IDs betroffen sind.
6. 336 aktualisieren, wenn neue Docs, Templates oder Slice-Regeln entstehen.
7. Abschlusschecks ausfuehren.

## Standardchecks

```bash
git status --short
git diff --check
git status --short -- lib assets test integration_test ios android macos web windows linux
```

## Abschlussbericht

Berichte:

- genutztes Template,
- vorheriger und aktueller git status,
- geaenderte/erstellte Dateien,
- neue/geaenderte M16-T-IDs,
- neuer Fortschritt, wenn 328 geaendert wurde,
- ob 336 aktualisiert wurde,
- geerbte Stop-Regeln,
- Check-Ergebnisse,
- Risiken/offene Punkte,
- empfohlener naechster Slice,
- kein Commit durchgefuehrt: JA/NEIN.

