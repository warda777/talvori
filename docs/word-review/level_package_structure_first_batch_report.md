# Level-/Paket-/Wortwelt-Struktur-Batch Report

Stand: 2026-05-30

Dieser Report validiert eine lokale Struktur-Review-Arbeitsdatei. Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, keine SRS-Daten, kein `word_progress` und keine produktiven Vokabeldaten.

## Zusammenfassung

- Gesamtzeilen: 57
- Leere Entscheidungen: 0
- Gefüllte Entscheidungen: 57
- Validierungsprobleme: 0

## Zeilen pro Strukturfall

| Wert | Anzahl |
|---|---:|
| level_only | 25 |
| level_topic | 15 |
| level_top_500 | 13 |
| level_top_500_topic | 2 |
| multi_topic | 2 |

## Entscheidungen nach `review_decision`

| Wert | Anzahl |
|---|---:|
| map_level | 25 |
| map_word_world | 17 |
| map_package | 15 |

## Erlaubte `review_decision` Werte

`<leer>`, `map_level`, `map_package`, `map_word_world`, `needs_context`, `keep`, `reject`

## Validierungsprobleme

_Keine Validierungsprobleme gefunden._

## Workflow-Hinweis

Die Entscheidungen sind Review-Overlay-Vorbereitung. Sie setzen keine Level, Pakete oder Wortwelten produktiv. Größere Struktur-Batches sollten erst nach Auswertung dieses repräsentativen Batches folgen.
