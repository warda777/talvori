# Template: Review Slice

Status: `Arbeitsvertrag / keine Aenderungsfreigabe`

## Einsatz

Nutze dieses Template fuer Reviews, Commitfaehigkeitspruefungen,
Scope-Pruefungen, Diff-Reviews, Risiko-Audits und uncommitted-state Reviews.

## Kurzprompt muss nennen

- Slice-ID oder Review-Ziel,
- erwartete Dateien/Bereiche,
- ob Korrekturen erlaubt sind oder nicht,
- spezifische Risiken,
- Commit-Status.

## Grundregel

Keine Dateien aendern, ausser der Kurzprompt erlaubt ausdruecklich eine
Korrektur. Review ist Analyse, nicht Umsetzung.

## Geerbte Regeln

- Pflichtlektuere und Slice-Typ-Regeln aus 336.
- M16-T-ID- und Dashboard-Regeln aus 328.
- Source-of-Truth- und External-Write-Grenzen aus 362.
- Kein Commit ohne separate ausdrueckliche Freigabe.

## Pruefpunkte

- `git status --short`,
- erwartete vs. unerwartete Dateien,
- `git diff` oder gezielter Datei-Diff, wenn noetig,
- Scope gegen Stop-Regeln,
- Risiken, Blocker und fehlende Checks,
- ob externe Writes, Assets, Code, Persistenz, Route, Navigation,
  BuildState, Supabase, SRS oder `word_progress` beruehrt wurden,
- ob 328/336 konsistent sind, wenn Docs betroffen sind.

## Standardchecks

```bash
git status --short
git diff --check
git status --short -- lib assets test integration_test ios android macos web windows linux
```

Wenn der Review strikt read-only ist, darf `git diff --check` trotzdem laufen,
weil es keine Dateien aendert.

## Abschlussbericht

Berichte:

```text
Commitfaehigkeit: JA/NEIN

Begruendung:
- ...

Gefundene Risiken:
- ...

Vor Commit zwingend zu korrigieren:
- ...

Keine Aenderungen durchgefuehrt: JA/NEIN
Kein Commit durchgefuehrt: JA/NEIN
```

