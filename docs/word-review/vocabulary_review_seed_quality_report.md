# Vocabulary Review Seed Quality Report

Stand: 2026-05-30

Dieser Report analysiert den lokal generierten Master-Review-Seed. Er verändert keine Supabase-Daten, keine SQLite-Daten, keine Imports, keine SRS-Daten und kein `word_progress`.

## 1. Grundzahlen

- Zeilen: 13629
- Eindeutige `word_key`: 13629
- Eindeutige `base_term`: 13620
- Sprachpaare: 1 (aus `base_language` und vorhandener `de_translation` abgeleitet)
- Level: 7
- Kategorien: 352
- Wortwelten: 108

### Sprachpaare
| Wert | Anzahl |
|---|---:|
| en->de | 13629 |


### Level
| Wert | Anzahl |
|---|---:|
| B2 | 3015 |
| B1 | 2680 |
| A2 | 2347 |
| C1 | 2173 |
| A1 | 1963 |
| C2 | 1426 |
| (leer) | 25 |


## 2. Sicherheitsprüfung

- Alle `review_status = needs_review`: ja
- Alle `release_ready = false`: ja
- `es_translation` überall leer: ja
- `fr_translation` überall leer: ja
- Zeilen mit `approved`: 0
- Zeilen mit `release_ready = true`: 0

## 3. Sprachcodeprüfung

### `base_language`
| Wert | Anzahl |
|---|---:|
| en | 13629 |


- Unerwartete Sprachcodes: 0
- Nicht-lowercase Sprachcodes: 0

## 4. Übersetzungsprüfung

- Leere deutsche Übersetzungen: 0
- Gleicher Wert in `base_term` und `de_translation`: 992
- Sehr lange Übersetzungen: 8
- Slash/Semikolon/Mehrfachvarianten-Verdacht: 249
- URL-/HTML-Verdacht: 0

## 5. Dublettenprüfung

- Exakte Dubletten nach `base_term + de_translation + base_language`: 32
- Case-Varianten: 30
- Gleiche Basisbegriffe mit unterschiedlichen Übersetzungen: 16

## 6. Strukturprüfung

- Fehlendes Level: 25
- Ungewöhnliche Level: 0
- Fehlende Kategorie: 16
- Fehlende Wortwelt: 16
- A1-C2 als Kategorie/Wortwelt-Verdacht: 5539
- Top-500 als Kategorie/Wortwelt-Verdacht: 500

### Kategorien mit sehr wenigen Wörtern
| Wert | Anzahl |
|---|---:|
| A1; A2; B2; Top 500 Words | 2 |
| A1; A2; Food & Cooking; Top 500 Words | 2 |
| A1; Art & Literature | 2 |
| A1; B1; Media & News | 2 |
| A1; B1; Money & Shopping; Top 500 Words | 2 |
| A1; B2; Food & Cooking | 2 |
| A1; Food & Cooking; Home & Living; Top 500 Words | 2 |
| A1; Gaming; Top 500 Words | 2 |
| A1; Law & Politics | 2 |
| A1; School & Studies; Work & Careers | 2 |
| A1; Sports; Top 500 Words | 2 |
| A1; Transport | 2 |
| A1; Travel | 2 |
| A2; B1; Health & Fitness | 2 |
| A2; B1; Music & Entertainment | 2 |
| A2; B1; Top 500 Words | 2 |
| A2; B2; Media & News | 2 |
| A2; B2; Music & Entertainment | 2 |
| A2; B2; Top 500 Words | 2 |
| A2; Environment; Top 500 Words | 2 |
| A2; Food & Cooking; Home & Living | 2 |
| A2; Gaming | 2 |
| A2; Grammar & Syntax | 2 |
| A2; Money & Shopping; Work & Careers | 2 |
| A2; Nature | 2 |
| A2; Tech & Innovation | 2 |
| Animals; B1; B2 | 2 |
| Animals; Gaming | 2 |
| Art & Literature; B1; B2 | 2 |
| B1; B2; Money & Shopping | 2 |
| ... | 140 weitere Werte |


### Kategorien mit sehr vielen Wörtern
| Wert | Anzahl |
|---|---:|
| B2 | 1044 |
| C1 | 914 |
| C2 | 849 |
| Phrases & Idioms | 599 |
| B1 | 510 |


## 7. Priorisierte Review-Listen

Empfohlene Reihenfolge:

1. Sprachcode-/Formatprobleme
2. URL-/HTML-/Importartefakte
3. Exakte Dubletten
4. Case-Varianten
5. Gleiche Basisbegriffe mit unterschiedlichen Übersetzungen
6. Fehlende Kategorien/Level
7. Bedeutungsvarianten mit fehlender `meaning_note`
8. Normale Wort-für-Wort-Prüfung

## 8. Kandidatenlisten

- `seed_empty_translation_candidates.csv`: 0 Kandidaten, maximal 200 exportiert
- `seed_duplicate_candidates.csv`: 32 Kandidaten, maximal 200 exportiert
- `seed_meaning_variant_candidates.csv`: 16 Kandidaten, maximal 200 exportiert
- `seed_structure_issue_candidates.csv`: 6096 Kandidaten, maximal 200 exportiert

## 9. Wichtigste nächste Schritte

- Kandidatenlisten manuell prüfen; nichts automatisch korrigieren.
- Exakte Dubletten und Bedeutungsvarianten getrennt behandeln.
- `meaning_id` und `meaning_note` erst nach fachlicher Prüfung setzen.
- Spanisch/Französisch weiterhin leer lassen, bis sie geprüft sind.
- Erst nach menschlicher Freigabe `approved` und `release_ready = true` setzen.
