# Erster manueller Review-Batch: Zusammenfassung

Stand: 2026-05-30

Diese Datei fasst das abgeschlossene Overlay
`manual_review_first_batch_overlay.csv` zusammen. Das Overlay ist eine
Entscheidungsvorbereitung. Es ist kein Merge, keine Vokabelkorrektur, kein
Import und keine Freigabe.

## Ziel des ersten Batches

Der erste manuelle Batch sollte kleine, fachlich riskante Konfliktgruppen aus
dem englisch-deutschen Basisbestand vor der großen Wort-für-Wort-Prüfung
vorsortieren:

- exakte Dubletten
- Groß-/Kleinschreibungsvarianten
- Bedeutungsvarianten
- fehlende Level, Kategorien oder Wortwelten

Dabei wurden nur `review_decision` und `review_note` vorbereitet. Es wurden
keine Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine Imports, keine
SRS-Daten und kein `word_progress` verändert.

## Ergebnis

- geprüfte Overlay-Zeilen: 103
- Review-Blöcke: 4
- Validierungsprobleme: 0
- `approved`: 0
- `release_ready=true`: 0

## Entscheidungen nach `review_decision`

| Entscheidung | Anzahl | Bedeutung |
|---|---:|---|
| `merge_later` | 30 | fachlich wahrscheinlich gleiche Einträge, aber erst später mit Live-Prüfung zusammenführen |
| `canonical_case` | 20 | kanonische Groß-/Kleinschreibung vorbereiten |
| `split_meaning` | 18 | echte Bedeutungsvarianten getrennt halten |
| `set_word_world` | 16 | spätere Wortwelt-/Themenzuordnung prüfen |
| `needs_context` | 11 | ohne Kontext keine sichere Entscheidung |
| `set_level` | 8 | später Level prüfen oder aus Dublettenpartner übernehmen |

## Entscheidungen nach Review-Block

| Review-Block | Anzahl | Ergebnis |
|---|---:|---|
| `exakte_dubletten` | 32 | überwiegend `merge_later`, einzelne Bedeutungs-/Kontextfälle |
| `case_varianten` | 30 | überwiegend `canonical_case`, einige echte Bedeutungsunterschiede |
| `bedeutungsvarianten` | 16 | überwiegend `split_meaning`, wenige Normalisierungsfälle |
| `fehlende_level_kategorien` | 25 | `set_level`, `set_word_world` oder `needs_context` |

## Wichtigste fachliche Ergebnisse

- Reine Import-/Normalisierungsvarianten wie `ADJECTIVE`, `ADVERB`, `VERB`
  sollen später normalisiert werden, ohne Metadaten zu verlieren.
- Wochentage wie `Friday`, `Monday`, `Saturday`, `Thursday`, `Tuesday`
  brauchen kanonische Großschreibung. Top-500-Memberships dürfen dabei nicht
  verloren gehen.
- `may/May`, `it/IT`, `pin/PIN`, `move`, `incident` und `throughout` sind
  keine einfachen Dubletten. Sie brauchen Bedeutungsmodellierung oder klare
  Bedeutungsnotizen.
- `report` bleibt riskant, weil `Bericht` als Nomen und ein vorhandener
  `verb`-Eintrag fachlich kollidieren.
- Fehlende Strukturfelder wurden nur als spätere Vorschläge markiert. Es wurde
  kein Level und keine Wortwelt produktiv gesetzt.

## Offene Risiken

- Vor jedem späteren Merge müssen Live-Referenzen auf User-/SRS-/Progress-Daten
  erneut geprüft werden.
- Die Daten brauchen langfristig ein sauberes Bedeutungsmodell, damit echte
  Bedeutungen nicht in einem Übersetzungsstring vermischt werden.
- A1-C2 und `Top 500 Words` sind weiterhin ein großer Strukturblock, weil sie
  aktuell teilweise wie Kategorien/Wortwelten erscheinen.
- Das Overlay enthält noch keine finalen Content-Änderungen. Es beschreibt nur,
  was später geprüft oder umgesetzt werden sollte.

## Was nicht geändert wurde

- keine produktiven Vokabeldaten
- keine Supabase-Daten
- keine SQLite-Daten
- keine SRS- oder `word_progress`-Daten
- keine Spanisch-/Französisch-Inhalte
- keine `approved`-Freigaben
- kein `release_ready=true`

## Nächste Schritte

1. A1-C2 als Level und `Top 500 Words` als Content-Paket sauber von
   Wortwelten trennen.
2. Eine kleine repräsentative Struktur-Arbeitsliste prüfen, bevor die großen
   6.096 Strukturissues angefasst werden.
3. Danach Mapping-Regeln für `level`, `word_world` und `content_package`
   bestätigen.
4. Erst nach diesen Regeln größere Struktur-Overlays erzeugen.
