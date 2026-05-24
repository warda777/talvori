# Cleanup Candidates Summary

Stand: 2026-05-24T14:50:03.287411

Dieser Schritt erzeugt nur Review-Dateien. Es wurden keine
Supabase-Daten, Woerter, Kategorien oder SRS-Fortschritte
veraendert.

## Dateien

- `language_code_normalization_review.csv`
- `duplicate_candidates_review.csv`
- `uncategorized_words_review.csv`
- `package_and_level_candidates_review.csv`

## Kandidaten

- EN->DE-/Sprachcode-Normalisierungskandidaten: 25
- Dubletten-Gruppen: 40
- Dubletten-Zeilen in Review-Datei: 80
- Eindeutige Dubletten-Woerter: 48
- Woerter ohne Kategorie: 16
- Top-500-Kandidaten: 500
- A1-C2-Level-Kandidaten: 13604
- Paket-/Level-Review-Zeilen gesamt: 13604

## Empfohlene Pruefreihenfolge

1. Sprachcodes normalisieren
2. Exakte Dubletten pruefen
3. Woerter ohne Kategorie pruefen
4. Top 500 als Paket markieren
5. A1-C2 als Levelstruktur vorbereiten

## Hinweis

Die Dateien enthalten bewusst keine automatischen Loesch- oder
Migrationsentscheidungen. Spalten wie `decision`,
`proposed_action`, `keep_word_id` und `notes` sind fuer die
manuelle Pruefung vorgesehen.
