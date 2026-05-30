# Manual Review First Batch Report

Stand: 2026-05-30

Dieser Report validiert eine lokale manuelle Review-Arbeitsdatei. Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, keine SRS-Daten und kein `word_progress`.

## Zusammenfassung

- Gesamtzeilen: 103
- Leere Entscheidungen: 41
- Gefüllte Entscheidungen: 62
- Validierungsprobleme: 0

## Zeilen pro Review-Block

| Wert | Anzahl |
|---|---:|
| exakte_dubletten | 32 |
| case_varianten | 30 |
| fehlende_level_kategorien | 25 |
| bedeutungsvarianten | 16 |

## Erlaubte `review_decision` Werte

`<leer>`, `keep`, `merge_later`, `split_meaning`, `canonical_case`, `set_level`, `set_word_world`, `reject`, `needs_context`, `add_note`

## Validierungsprobleme

_Keine Validierungsprobleme gefunden._

## Workflow-Hinweis

Die Vorlage `manual_review_first_batch.csv` sollte nicht direkt als persönliche Arbeitsdatei genutzt werden. Für echte manuelle Bearbeitung eine lokale Kopie wie `manual_review_first_batch_working.csv` anlegen, validieren und erst abgestimmte Ergebnisse später als separates Overlay versionieren.
