# Master-Schema-Gap-Analyse

Stand: 2026-05-30

Diese Analyse prüft die bestehenden Dateien unter `docs/word-review/` und die relevanten Tools unter `tool/` gegen das neue Master-Review-Schema aus `vocabulary_review_template.csv`.

Es wurden keine Supabase-Daten, keine SQLite-/App-Vokabeldaten, keine Imports, keine SRS-Daten und kein `word_progress` verändert.

## 1. Master-Schema

Zielspalten:

```text
word_key, base_language, base_term, normalized_base_term, meaning_id,
meaning_note, part_of_speech, level, category, word_world, de_translation,
es_translation, fr_translation, example_base, example_de, translation_note,
duplicate_group, conflict_type, review_status, reviewer, last_reviewed_at,
release_ready
```

## 2. Geprüfte CSV-Dateien

### `vocabulary_review_template.csv`

Zweck: Leere Master-Vorlage.

Aktuelle Spalten:

```text
word_key, base_language, base_term, normalized_base_term, meaning_id,
meaning_note, part_of_speech, level, category, word_world, de_translation,
es_translation, fr_translation, example_base, example_de, translation_note,
duplicate_group, conflict_type, review_status, reviewer, last_reviewed_at,
release_ready
```

Bewertung:

- Passt vollständig zum Master-Schema.
- Enthält bewusst keine Vokabeldaten.
- Ist Vorlage, aber keine Datenquelle.

### `supabase_words_review.csv`

Zweck: Read-only Rohreview des Supabase-Wortbestands.

Aktuelle Spalten:

```text
word_id, term/text, translation, from_lang, to_lang,
current_category_names, current_category_types, current_level, current_tags,
domain, pos, source/origin, qa_score, qa_note, decision,
proposed_word_worlds, proposed_level, proposed_package, notes
```

Mapping auf Master-Schema:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `word_id` | `word_key` | direkt nutzbar |
| `from_lang` | `base_language` | normalisieren, z. B. `EN` -> `en` |
| `term/text` | `base_term` | direkt nutzbar |
| `term/text` | `normalized_base_term` | muss normalisiert berechnet werden |
| `pos` | `part_of_speech` | direkt nutzbar, aber fachlich prüfen |
| `current_level` / `proposed_level` | `level` | `proposed_level` kann Vorrang bekommen, wenn geprüft |
| `current_category_names` | `category` | Rohkategorie, ggf. mehrere Werte |
| `proposed_word_worlds` / `current_category_names` | `word_world` | Mapping nötig |
| `translation` | `de_translation` | nur wenn `to_lang = de` |
| `qa_note` / `notes` | `translation_note` | zusammenführen oder trennen |
| `decision` | `review_status` | nur teilweise passend, Mapping nötig |

Fehlende Master-Spalten:

- `meaning_id`
- `meaning_note`
- `es_translation`
- `fr_translation`
- `example_base`
- `example_de`
- `duplicate_group`
- `conflict_type`
- `reviewer`
- `last_reviewed_at`
- `release_ready`

Bewertung:

- Beste Ausgangsbasis für den Master-Review.
- Enthält die breiteste Abdeckung des Wortbestands.
- Noch kein echtes Master-Schema, weil Bedeutung, Review-Status, Mehrsprachigkeit und Release-Freigabe fehlen.

### `duplicate_candidates_review.csv`

Zweck: Kandidatenliste für Dubletten.

Aktuelle Spalten:

```text
duplicate_group_key, duplicate_type, word_id, term, translation, from_lang,
to_lang, current_category_names, current_level, current_tags,
proposed_action, keep_word_id, notes
```

Mapping auf Master-Schema:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `word_id` | `word_key` | direkt nutzbar |
| `from_lang` | `base_language` | normalisieren |
| `term` | `base_term` | direkt nutzbar |
| `term` | `normalized_base_term` | berechnen |
| `translation` | `de_translation` | nur bei `to_lang = de` |
| `current_level` | `level` | Rohwert |
| `current_category_names` | `category` / `word_world` | Mapping nötig |
| `duplicate_group_key` | `duplicate_group` | direkt nutzbar |
| `duplicate_type` | `conflict_type` | direkt nutzbar |
| `proposed_action` | `review_status` oder Zusatzentscheidung | nicht 1:1 |
| `notes` | `translation_note` | nur teilweise passend |

Fehlende Master-Spalten:

- `meaning_id`
- `meaning_note`
- `part_of_speech`
- `es_translation`
- `fr_translation`
- `example_base`
- `example_de`
- `reviewer`
- `last_reviewed_at`
- `release_ready`

Bewertung:

- Hilfs-/Kandidatenliste.
- Nicht als Master-Quelle geeignet.
- Sollte später in Master-Zeilen zurückgemappt werden, um `duplicate_group` und `conflict_type` zu füllen.

### `language_code_normalization_review.csv`

Zweck: Kandidaten zur Normalisierung von Sprachcodes.

Aktuelle Spalten:

```text
word_id, term, translation, from_lang, to_lang, proposed_from_lang,
proposed_to_lang, decision, notes
```

Mapping:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `word_id` | `word_key` | direkt nutzbar |
| `proposed_from_lang` oder `from_lang` | `base_language` | nach Entscheidung |
| `term` | `base_term` | direkt nutzbar |
| `translation` | `de_translation` | bei `to_lang`/`proposed_to_lang = de` |
| `decision` | `review_status` oder Normalisierungsentscheidung | nicht 1:1 |
| `notes` | `translation_note` | nur teilweise passend |

Fehlende Master-Spalten:

- fast alle Bedeutungs-, Level-, Kategorie-, Mehrsprachigkeits- und Release-Spalten

Bewertung:

- Reine Hilfsliste für Sprachcode-Konflikte.
- Sollte nicht direkt Master werden.
- Kann Master-Zeilen um Normalisierungsentscheidungen ergänzen.

### `language_code_conflicts_review.csv`

Zweck: Konfliktliste bei Sprachcode-Normalisierung.

Aktuelle Spalten:

```text
candidate_id, candidate_text, candidate_translation, target_from_lang,
target_to_lang, conflicting_id, conflicting_text, conflicting_translation,
conflict_type, proposed_action, keep_word_id, notes
```

Mapping:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `candidate_id` / `conflicting_id` | `word_key` | je nach Rolle separate Master-Zeile |
| `target_from_lang` | `base_language` | normalisiert |
| `candidate_text` / `conflicting_text` | `base_term` | rollenabhängig |
| `candidate_translation` / `conflicting_translation` | `de_translation` | rollenabhängig |
| `conflict_type` | `conflict_type` | direkt nutzbar |
| `keep_word_id` | Zusatzentscheidung | keine Master-Spalte, aber wichtig |
| `notes` | `translation_note` | teilweise |

Fehlende Master-Spalten:

- Bedeutung, Level, Kategorie, Wortwelt, Beispiele, Mehrsprachigkeit, Reviewer, Zeitstempel, Release-Freigabe

Bewertung:

- Hilfsdatei.
- Gut für `conflict_type`, nicht als Master-Quelle.

### `language_code_conflicts_remaining_review.csv`

Zweck: Verbleibende Konflikte nach vorheriger Normalisierung.

Aktuelle Spalten:

```text
candidate_id, candidate_text, candidate_translation, conflicting_id,
conflicting_text, conflicting_translation, conflict_type, proposed_action,
keep_word_id, notes
```

Bewertung:

- Hilfsdatei für noch offene Konflikte.
- Gehört als Konflikt-Overlay zum Master, nicht als Master-Quelle.

### `language_code_conflict_context.csv`

Zweck: Kontextdatei für Sprachcode-Konflikte mit Kategorie-, Nutzungs- und Metadaten.

Aktuelle Spalten:

```text
conflict_group, role, word_id, text, translation, from_lang, to_lang, level,
tags, domain, pos, category_names, category_types, group_names,
user_words_count, word_progress_count, user_word_srs_count, created_at,
translated_by, translated_at, qa_score, qa_note, suggested_decision, notes
```

Mapping:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `word_id` | `word_key` | direkt nutzbar |
| `from_lang` | `base_language` | normalisieren |
| `text` | `base_term` | direkt nutzbar |
| `translation` | `de_translation` | bei `to_lang = de` |
| `level` | `level` | direkt nutzbar |
| `pos` | `part_of_speech` | direkt nutzbar |
| `category_names` | `category` / `word_world` | Mapping nötig |
| `conflict_group` | `duplicate_group` | direkt nutzbar |
| `suggested_decision` | `review_status` oder Entscheidungshinweis | nicht 1:1 |
| `qa_note` / `notes` | `translation_note` | teilweise |

Fehlende Master-Spalten:

- `meaning_id`
- `meaning_note`
- `es_translation`
- `fr_translation`
- `example_base`
- `example_de`
- `reviewer`
- `last_reviewed_at`
- `release_ready`

Bewertung:

- Wertvolle Kontextdatei für Konfliktfälle.
- Nicht als globale Master-Basis geeignet, weil sie nur Konfliktgruppen abdeckt.

### `uncategorized_words_review.csv`

Zweck: Wörter ohne Kategorie.

Aktuelle Spalten:

```text
word_id, term, translation, from_lang, to_lang, current_level, current_tags,
proposed_word_worlds, proposed_level, decision, notes
```

Bewertung:

- Hilfsdatei für fehlende Wortwelt/Kategorie.
- Kann `word_world`, `category`, `level`, `translation_note` und eventuell `review_status` für betroffene Master-Zeilen ergänzen.
- Nicht als Master-Quelle geeignet.

### `package_and_level_candidates_review.csv`

Zweck: Kandidaten für Paket- und Levelstruktur.

Aktuelle Spalten:

```text
word_id, term, translation, from_lang, to_lang, current_category_names,
current_level, proposed_package, proposed_level, notes
```

Bewertung:

- Hilfsdatei für Level- und Paketklärung.
- Deckt laut Summary sehr viele Zeilen ab, ist aber keine vollständige semantische Review-Datei.
- Sollte später `level` und Paket-Metadaten ergänzen; `proposed_package` ist keine Master-Spalte und gehört eher in spätere Content-Paket-Tabellen.

### `url_contaminated_words_review.csv`

Zweck: Kandidaten für URL-/HTML-/Importartefakte.

Aktuelle Spalten:

```text
word_id, term, translation, from_lang, to_lang, current_category_names,
current_level, issue_type, proposed_term, proposed_translation, decision,
notes
```

Mapping:

| Bestehende Spalte | Master-Spalte | Hinweis |
|---|---|---|
| `word_id` | `word_key` | direkt nutzbar |
| `issue_type` | `conflict_type` | direkt nutzbar |
| `proposed_term` | Zusatzentscheidung | darf nicht automatisch übernehmen |
| `proposed_translation` | Zusatzentscheidung | darf nicht automatisch übernehmen |
| `decision` | Review-/Cleanup-Entscheidung | nicht 1:1 |
| `notes` | `translation_note` | teilweise |

Bewertung:

- Hilfsdatei für Problemfälle.
- Nicht als Master-Quelle geeignet.
- Wichtiges Overlay für `conflict_type = url_or_html_suspect` oder ähnlich.

### `local_import_conflicts.csv`

Zweck: Konflikte zwischen Remote-Wort und lokalem Importstand.

Aktuelle Spalten:

```text
remote_word_id, remote_text, remote_translation, local_word_id, local_term,
local_translation, issue_type, notes
```

Bewertung:

- Import-/Abgleichskonflikt, nicht Master-Review.
- Kann Hinweise für spätere Konfliktprüfung liefern.
- Sollte nicht direkt in Release-Content übernommen werden.

## 3. Geprüfte Markdown-Dateien

### Summaries und Reports

- `supabase_words_summary.md`
  - beschreibt read-only Exportstand, Volumen, Sprachpaare, Kategorien, Dubletten.
  - gute Orientierung, keine Master-Datenquelle.
- `cleanup_candidates_summary.md`
  - fasst Kandidatenlisten zusammen.
  - gute Prüfreihenfolge, keine Master-Datenquelle.
- `language_code_conflicts_remaining_summary.md`
  - Zusammenfassung verbleibender Sprachcode-Konflikte.
  - Hilfsdokument.
- `language_code_conflict_context_summary.md`
  - Zusammenfassung des Kontext-Exports.
  - Hilfsdokument.
- `url_contamination_summary.md`
  - Zusammenfassung URL-/Importartefakte.
  - Hilfsdokument.
- `local_import_report.md`
  - Importreport; nicht direkt Master.

### Entscheidungs- und Planungsdokumente

- `language_code_conflict_decisions.md`
  - fachliche Entscheidungsvorbereitung für Sprachcode-Konflikte.
  - kann `conflict_type`, `duplicate_group`, `translation_note` und spätere Review-Entscheidungen speisen.
- `exact_duplicate_merge_plan.md`
  - Entscheidungsvorbereitung für exakte Dubletten.
  - wichtiges Overlay für Dublettenfälle.
- `case_variant_merge_plan.md`
  - Entscheidungsvorbereitung für Groß-/Kleinschreibungsvarianten.
  - wichtiges Overlay für Case-Konflikte.
- `meaning_variant_model_plan.md`
  - beschreibt relevante Bedeutungsvarianten wie `move`.
  - sehr wichtig für `meaning_id` und `meaning_note`.
- `vocabulary_review_template_readme.md`
  - erklärt die Master-Vorlage.
  - keine Datenquelle.

## 4. Geprüfte Tools

### `tool/export_supabase_words_review.dart`

Zweck:

- liest Supabase read-only
- exportiert `supabase_words_review.csv`
- erzeugt `supabase_words_summary.md`

Eignung:

- Wichtigster Ausgangspunkt für den Rohbestand.
- Muss später angepasst werden, wenn direkt ein Master-Review-Seed erzeugt werden soll.

Nötige Anpassungen:

- Spaltenmapping auf Master-Schema
- `normalized_base_term` berechnen
- `base_language` normalisieren
- `de_translation` aus `translation` ableiten
- leere `es_translation`/`fr_translation` ausgeben
- initial `review_status = raw` oder `needs_review`
- `release_ready = false`
- optional `conflict_type` aus eingebauten Prüfregeln setzen

### `tool/export_vocabulary_review_seed.dart`

Zweck:

- liest `docs/word-review/supabase_words_review.csv`
- erzeugt daraus bei explizitem Aufruf `docs/word-review/vocabulary_review_seed.csv`
- verwendet das neue Master-Schema
- setzt alle Zeilen sicher auf `review_status = needs_review`
- setzt alle Zeilen sicher auf `release_ready = false`

Eignung:

- Aktueller read-only Master-Seed-Exporter.
- Nutzt nur lokale CSV-Dateien.
- Öffnet keine Supabase-Verbindung.
- Öffnet keine SQLite-Verbindung.
- Führt keinen Import aus.
- Erzeugt keine KI-Übersetzungen und keine ES-/FR-Produktivdaten.

Sicherheitsverhalten:

- Bestehende Output-Dateien werden nur mit `--force` überschrieben.
- Fehlende Pflichtspalten brechen mit verständlicher Fehlermeldung ab.
- Spanisch und Französisch bleiben initial leer.
- Der Output ist weiterhin Review-Material und nicht releasefähig.

### `tool/extract_word_review_cleanup_candidates.dart`

Zweck:

- liest `supabase_words_review.csv`
- erzeugt Hilfslisten für Sprachcodes, Dubletten, fehlende Kategorien und Paket-/Level-Fragen

Eignung:

- Weiterhin sinnvoll als Overlay-Generator.
- Nicht als Master-Exporter.

Nötige Anpassungen:

- Später zusätzlich eine Master-kompatible Konfliktdatei oder JSONL-Overlay erzeugen.
- `duplicate_group` und `conflict_type` konsistent mit Master-Schema benennen.

### `tool/export_language_code_conflicts_remaining.dart`

Zweck:

- liest Sprachcode-Normalisierungskandidaten
- exportiert verbleibende Konflikte

Eignung:

- Hilfswerkzeug für Sprachcode-Konflikte.
- Sollte später Master-Overlays erzeugen oder `conflict_type`-Updates vorbereiten.

### `tool/export_language_conflict_context.dart`

Zweck:

- erzeugt Kontext für Konfliktgruppen inklusive Nutzungs-/Progress-Zähler.

Eignung:

- Wichtig für Risikoanalyse vor Merge/Archivierung.
- Nicht als Master-Quelle, da nur Konflikte.

### `tool/extract_url_contaminated_words.dart`

Zweck:

- findet URL-/HTML-/Importartefakte.

Eignung:

- Hilfswerkzeug für `conflict_type`.
- Sollte später Master-Overlay für `url_or_html_suspect` erzeugen.

### `tool/clean_url_contaminated_words.dart`

Zweck:

- Cleanup-Hilfe für URL-kontaminierte Wörter.

Eignung und Risiko:

- Nicht Teil des Master-Review-Exports.
- Darf nur nach manueller Entscheidung und mit Sicherheitsguards/Dry-Run verwendet werden.
- Für den aktuellen Master-Schema-Schritt nicht ausführen.

### `tool/normalize_supabase_language_codes.dart`

Zweck:

- Normalisierung von Sprachcodes anhand einer Review-CSV.

Eignung und Risiko:

- Potenziell schreibendes Cleanup-Tool.
- Nicht für Master-Schema-Erzeugung verwenden.
- Erst nach Review-Freigabe und Release-Sicherheitsprüfung.

### `tool/import_supabase_words_to_local.dart`

Zweck:

- Import von Supabase-Wörtern in lokale Daten.

Eignung und Risiko:

- Nicht für Master-Review verwenden.
- Für diese Analyse ausdrücklich nicht ausführen.

## 5. Beste Ausgangsbasis

Empfehlung: `docs/word-review/supabase_words_review.csv` als Rohbasis für den Master-Review verwenden.

Warum:

- breiteste Abdeckung des bestehenden Supabase-Wortbestands
- enthält IDs, Begriffe, Übersetzungen, Sprachcodes, Kategorien, Level, POS, QA-Hinweise und Vorschlagsfelder
- ist read-only erzeugt worden
- vorhandene Kandidatenlisten referenzieren diese Datei oder deren IDs

Nicht ausreichend als alleinige Master-Datei:

- keine Bedeutungs-IDs
- keine Mehrsprachigkeitsspalten
- kein klares `review_status`
- keine `release_ready`-Freigabe
- keine Reviewer-/Zeitstempel-Felder
- Dubletten/URL/Konflikte liegen in separaten Hilfsdateien

## 6. Empfohlenes Mapping für einen späteren Master-Seed

| Master-Spalte | Quelle / Initialwert |
|---|---|
| `word_key` | `supabase_words_review.word_id` |
| `base_language` | normalisiertes `from_lang` |
| `base_term` | `term/text` |
| `normalized_base_term` | normalisierte Form von `term/text` |
| `meaning_id` | leer, später aus Bedeutungsreview |
| `meaning_note` | leer, später aus Bedeutungsreview |
| `part_of_speech` | `pos` |
| `level` | `proposed_level`, sonst `current_level` |
| `category` | `current_category_names` |
| `word_world` | `proposed_word_worlds`, sonst gemappte `current_category_names` |
| `de_translation` | `translation`, wenn `to_lang` normalisiert `de` ist |
| `es_translation` | leer |
| `fr_translation` | leer |
| `example_base` | leer |
| `example_de` | leer |
| `translation_note` | `qa_note` + `notes` |
| `duplicate_group` | aus `duplicate_candidates_review` oder Konfliktdateien |
| `conflict_type` | aus Kandidatenlisten oder Prüfregeln |
| `review_status` | `needs_review` als sichere Voreinstellung |
| `reviewer` | leer |
| `last_reviewed_at` | leer |
| `release_ready` | `false` |

## 7. Fehlende Informationen im Gesamtbestand

Kritische Lücken:

- stabile `meaning_id`
- fachliche `meaning_note`
- Beispiele in Englisch und Deutsch
- geprüfte Spanisch-/Französisch-Übersetzungen
- einheitliche `review_status`-Semantik
- `release_ready`
- `reviewer` und `last_reviewed_at`
- eindeutige Trennung von Wortwelt, Level und Paket
- konsolidiertes Konfliktmodell für Dubletten, Case-Varianten und Bedeutungsvarianten

Mittlere Lücken:

- saubere POS-Normalisierung
- `translation_note` aus mehreren Quellen
- `category` vs. `word_world` bei Mehrfachkategorien
- initiale Markierung für URL-/HTML-Verdacht

## 8. Risiken und Unklarheiten

- `decision` und `proposed_action` sind nicht dasselbe wie `review_status`.
- A1-C2 und Top 500 tauchen als Kategorien auf, gehören fachlich aber eher zu Level/Paket.
- Gleicher englischer Begriff kann echte Bedeutungsvariante statt Dublette sein.
- Deutsche Übersetzungen mit Slash oder Semikolon können mehrere Bedeutungen vermischen.
- `translation` kann nur dann sicher `de_translation` werden, wenn das Sprachpaar normalisiert `en-de` ist.
- Einige Tools sind reine Exporte, andere können später Änderungen vorbereiten oder ausführen. Schreibende Tools dürfen nicht Teil des Master-Seed-Schritts sein.
- User-/SRS-/Progress-Zähler aus Kontextdateien sind Momentaufnahmen und müssen vor produktiven Merge-Entscheidungen erneut live geprüft werden.

## 9. Empfohlene Tool-Anpassungen

Priorität 1:

- `export_vocabulary_review_seed.dart`
  - ist als separater read-only Master-Seed-Exporter vorhanden
  - keine Supabase-Writes
  - keine SQLite-Writes
  - `review_status = needs_review`
  - `release_ready = false`
  - nächster Schritt: Output nach manueller Erzeugung als Arbeitskopie prüfen, nicht produktiv importieren

Priorität 2:

- `extract_word_review_cleanup_candidates.dart`
  - Master-kompatible Overlays erzeugen:
    - `word_key`
    - `duplicate_group`
    - `conflict_type`
    - `translation_note`

Priorität 3:

- `extract_url_contaminated_words.dart`
  - optional Master-kompatibles Overlay für `url_or_html_suspect`

Priorität 4:

- `export_language_code_conflicts_remaining.dart`
- `export_language_conflict_context.dart`
  - Konflikt- und Bedeutungsvarianten in Master-Felder übersetzen

Nicht für den Master-Seed verwenden:

- `clean_url_contaminated_words.dart`
- `normalize_supabase_language_codes.dart`
- `import_supabase_words_to_local.dart`

Diese Tools können später nach manueller Freigabe relevant werden, sind aber nicht Teil der sicheren Master-Review-Vorbereitung.

## 10. Empfehlung für das weitere Vorgehen

1. `supabase_words_review.csv` als Rohbasis behalten.
2. `tool/export_vocabulary_review_seed.dart` nutzen, um bei Bedarf eine Master-Seed-Arbeitskopie zu erzeugen.
3. Die neue Datei nicht automatisch produktiv nutzen.
4. Hilfsdateien als Overlays einlesen:
   - Dubletten
   - Sprachcode-Konflikte
   - URL-Kandidaten
   - fehlende Kategorien
   - Paket-/Level-Fragen
5. Bedeutungsvarianten manuell modellieren, bevor `meaning_id` final gesetzt wird.
6. Spanisch und Französisch initial leer lassen.
7. Erst nach menschlichem Review `review_status = approved` und `release_ready = true` setzen.

## 11. Ergebnis

- Keine bestehende CSV außer `vocabulary_review_template.csv` passt vollständig zum Master-Schema.
- `supabase_words_review.csv` ist die beste Ausgangsbasis.
- Alle anderen CSV-Dateien sind Hilfs-/Kandidatenlisten oder Konflikt-Overlays.
- Die Markdown-Dateien enthalten wertvolle Entscheidungslogik, sind aber keine strukturierten Master-Datenquellen.
- Der Master-Seed-Exporter ist read-only vorbereitet und verändert keine Produktivdaten.
