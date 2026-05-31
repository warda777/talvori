# MVP Content First Review Batch Report

Stand: 2026-05-31

Dieser Report validiert eine lokale MVP-Content-Review-Arbeitsdatei. Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, keine SRS-Daten, kein `word_progress` und keine Produktivvokabeln.

## Zusammenfassung

- Gesamtzeilen: 150
- Leere Entscheidungen: 50
- Gefüllte Entscheidungen: 100
- Validierungsprobleme: 0

## Entscheidungen je Typ

| Wert | Anzahl |
|---|---:|
| approved_for_mvp | 67 |
| fix_translation_later | 23 |
| reject_for_mvp | 6 |
| move_out_of_mvp | 2 |
| needs_context | 2 |

## Zeilen je Wortwelt

| Wert | Anzahl |
|---|---:|
| Travel | 50 |
| Food & Cooking | 46 |
| Home & Living | 43 |
| Food & Cooking; Home & Living | 7 |
| Home & Living; Music & Entertainment | 2 |
| Environment; Food & Cooking | 1 |
| Home & Living; Work & Careers | 1 |

## Risikotypen

| Wert | Anzahl |
|---|---:|
| standard_review | 85 |
| structure_issue | 55 |
| same_base_and_translation | 10 |

## Erlaubte `review_decision` Werte

`<leer>`, `approved_for_mvp`, `fix_translation_later`, `needs_context`, `reject_for_mvp`, `move_out_of_mvp`, `add_note`

## Validierungsprobleme

_Keine Validierungsprobleme gefunden._

## Workflow-Hinweis

Die Vorlage `mvp_content_first_review_batch.csv` bleibt die kleine Review-Arbeitsliste. Für manuelle Bearbeitung wird eine lokale, ignorierte Kopie wie `mvp_content_first_review_batch_working.csv` genutzt. Erst nach vollständigem Review aller 150 Zeilen soll ein separates Overlay erzeugt werden.
