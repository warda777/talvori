# Template: Implementation Slice

Status: `Arbeitsvertrag / nur mit ausdruecklicher Implementierungsfreigabe`

## Einsatz

Nutze dieses Template fuer isolierte Code-Slices. Es darf nur verwendet
werden, wenn der Kurzprompt ausdruecklich Code- oder Implementierungsarbeit
freigibt.

## Kurzprompt muss nennen

- Slice-ID,
- Implementierungsziel,
- exakte erlaubte Dateien,
- ausdruecklich nicht erlaubte Dateien/Bereiche,
- relevante 336-Slice-Typen,
- erwartete Tests/Checks,
- besondere Stop-Regeln,
- Commit-Status.

## Harte Voraussetzungen

- Kein Code ohne ausdrueckliche Implementierungsfreigabe.
- Erwartete Dateien muessen exakt genannt sein.
- Relevante Docs aus 336 muessen gelesen werden.
- Wenn SRS, `word_progress`, SQLite, Supabase, Persistenz, Route, Navigation,
  BuildState, App-Integration, Assets oder externe Writes betroffen sein
  koennten, braucht es ein eigenes Gate oder ausdrueckliche Freigabe.
- Bei Konflikt gilt die strengere Stop-Regel.

## Standard-Stop-Regeln

Ohne eigenes Gate und Freigabe:

- keine App-Integration,
- keine Route,
- keine Navigation,
- keine Persistenz,
- kein BuildState,
- keine Supabase/local DB Writes,
- keine SRS-/`word_progress`-Aenderung,
- keine automatische Wortplatzierung,
- keine Assets,
- keine externen Writes,
- kein Commit.

## Arbeitsablauf

1. `git status --short` pruefen.
2. 336-Slice-Typ und relevante Fachdocs lesen.
3. Erwartete Dateien gegen aktuellen Status und Stop-Regeln pruefen.
4. Minimal scoped implementieren.
5. Format-/Analyze-/Test-/Run-Checks nur gemaess Kurzprompt und Projektbedarf
   ausfuehren.
6. Scope-Check ausfuehren.
7. Abschlussbericht mit Checks und Risiken liefern.

## Standardchecks

Mindestens:

```bash
git status --short
git diff --check
git status --short -- lib assets test integration_test ios android macos web windows linux
```

Weitere Checks wie `dart format`, `dart analyze`, `flutter test` oder
`flutter run` nur, wenn sie zum Slice passen und keine Stop-Regel verletzen.

## Abschlussbericht

Berichte:

- genutztes Template,
- vorheriger git status,
- geaenderte/erstellte Dateien,
- relevante M16-T-IDs,
- was implementiert wurde,
- warum keine verbotene Integration/Persistenz/Asset-/External-Write-Aktion
  entstanden ist,
- Format-/Analyze-/Test-/Run-Ergebnis,
- `git diff --check`,
- `git status --short`,
- Scope-Check,
- Risiken/offene Punkte,
- kein Commit durchgefuehrt: JA/NEIN.

