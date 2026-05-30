# Vokabel-Review-Workflow für den englisch-deutschen Basiscontent

## 1. Ziel

Dieser Workflow beschreibt, wie der englisch-deutsche Basiswortschatz von Talvori vor dem Release Wort für Wort geprüft wird, ohne produktive Daten automatisch zu verändern.

Der Review soll sicherstellen:

- Übersetzungen sind korrekt, natürlich und eindeutig genug.
- Bedeutungsvarianten sind sauber getrennt oder dokumentiert.
- Dubletten, Schreibfehler, URL-Reste und Importartefakte werden gefunden.
- Wortwelten, Kategorien, Level und Paketzuordnungen sind fachlich sinnvoll.
- Nur geprüfter Content mit Status `approved` darf später in Release-Pakete.
- Spanische und französische Übersetzungen können parallel vorbereitet werden, ohne ungeprüft produktiv sichtbar zu werden.

Der Review ist ein Content-Qualitätsschritt. Er verändert keine Nutzerstände, keine SRS-Daten und keine lokalen oder Supabase-Produktivdaten.

## 2. Ausgangsdaten und bestehende Vorarbeit

Bereits vorhanden:

- `tool/export_supabase_words_review.dart`
  - liest Supabase über REST read-only
  - exportiert `docs/word-review/supabase_words_review.csv`
  - erzeugt `docs/word-review/supabase_words_summary.md`
- `tool/extract_word_review_cleanup_candidates.dart`
  - liest die bestehende Review-CSV
  - erzeugt Kandidatenlisten für Sprachcodes, Dubletten, fehlende Kategorien und Paket-/Level-Fragen
- `tool/export_language_code_conflicts_remaining.dart`
- `tool/export_language_conflict_context.dart`
- `tool/extract_url_contaminated_words.dart`
- `tool/clean_url_contaminated_words.dart`
  - vorsichtig verwenden: Cleanup-Tools dürfen nur nach manueller Freigabe und mit Dry-Run/Review-Dateien genutzt werden
- `docs/word-review/supabase_words_summary.md`
- `docs/word-review/cleanup_candidates_summary.md`
- `docs/word-review/duplicate_candidates_review.csv`
- `docs/word-review/uncategorized_words_review.csv`
- `docs/word-review/language_code_normalization_review.csv`
- `docs/word-review/package_and_level_candidates_review.csv`

Aktueller Befund aus der vorhandenen Summary:

- 13.629 Wörter im Supabase-Review-Export
- 13.620 Zeilen `en->de`
- 9 Zeilen `EN->DE`
- 16 Wörter ohne Kategorie
- 24 mögliche Dubletten nach `term/from_lang/to_lang`
- 16 mögliche Dubletten nach `term/translation/from_lang/to_lang`
- A1-C2-Level und Paketkandidaten sind in den bestehenden Daten teilweise als Kategorien modelliert und müssen fachlich getrennt bewertet werden

## 3. Daten, die geprüft werden

Für jedes Wort beziehungsweise jede Bedeutung wird geprüft:

- englischer Basisbegriff
- deutsche Übersetzung
- Sprachcodes
- Wortart
- Bedeutungsnotiz
- Beispiel im Englischen
- Beispiel auf Deutsch
- Wortwelt/Kategorie
- Lernlevel
- Paketzuordnung, z. B. Top-Wörter oder Basiswortschatz
- Dubletten- und Konfliktstatus
- Release-Status

Content-Daten bleiben strikt getrennt von User-Daten:

- Content-Daten: Wörter, Übersetzungen, Bedeutungen, Wortwelten, Level, Pakete, Beispielsätze
- User-Daten: `word_progress`, `review_history`, bekannte Wörter, Noch-lernen-Markierungen, Favoriten, Streaks, Einstellungen, Chatverläufe

Der Review darf niemals User-Daten überschreiben.

## 4. Review-Status

Erlaubte Statuswerte:

- `raw`
  - unverarbeiteter Import- oder Exportstand
  - nicht releasefähig
- `needs_review`
  - muss manuell geprüft werden
  - nicht releasefähig
- `ai_suggested`
  - KI hat einen Vorschlag geliefert
  - darf nicht automatisch produktiv sichtbar werden
- `human_reviewed`
  - menschlich geprüft, aber noch nicht final freigegeben
  - nur eingeschränkt releasefähig, wenn zusätzlich Freigabe fehlt
- `approved`
  - fachlich und sprachlich geprüft
  - releasefähig
- `rejected`
  - nicht verwenden
  - darf nicht in Release-Pakete

Nur `approved` darf später in geprüfte Content-Pakete übernommen werden.

## 5. Review-Tabellenformat

Empfohlenes Master-Schema als CSV, Sheet oder JSONL:

| Spalte | Bedeutung |
|---|---|
| `word_key` | stabile fachliche Wort-ID oder Import-ID |
| `base_language` | Sprache des Basisbegriffs, z. B. `en` |
| `base_term` | englischer Basisbegriff |
| `normalized_base_term` | normalisierte Form für Dublettenprüfung |
| `meaning_id` | stabile Bedeutungs-ID, z. B. `move:relocate` |
| `meaning_note` | kurze Erklärung der gemeinten Bedeutung |
| `part_of_speech` | Wortart, z. B. `noun`, `verb`, `adjective` |
| `level` | Lernlevel, z. B. `A1`, `A2`, `B1` |
| `category` | technische Kategorie oder bisherige Kategorie |
| `word_world` | sichtbare Wortwelt, z. B. `Travel`, `Health & Fitness` |
| `de_translation` | geprüfte oder zu prüfende deutsche Übersetzung |
| `es_translation` | spanische Übersetzung, leer oder `needs_review`, bis geprüft |
| `fr_translation` | französische Übersetzung, leer oder `needs_review`, bis geprüft |
| `example_base` | Beispielsatz in der Basissprache |
| `example_de` | deutscher Beispielsatz |
| `translation_note` | Hinweise zu Register, Kontext, falschen 1:1-Übersetzungen |
| `duplicate_group` | Gruppe für Dubletten oder Bedeutungsvarianten |
| `conflict_type` | z. B. `exact_duplicate`, `case_variant`, `meaning_variant` |
| `review_status` | `raw`, `needs_review`, `ai_suggested`, `human_reviewed`, `approved`, `rejected` |
| `reviewer` | Kürzel oder Name der prüfenden Person |
| `last_reviewed_at` | ISO-Datum der letzten Prüfung |
| `release_ready` | `true` nur bei freigegebenem Content |

Optionale spätere Spalten:

- `ja_translation`
- `zh_translation`
- `hi_translation`
- `ru_translation`
- `register`
- `region`
- `frequency_rank`
- `content_package_id`
- `content_package_version`

## 6. Bedeutungsvarianten

Ein englisches Wort kann mehrere Bedeutungen haben. Diese dürfen nicht als simple Dubletten zusammengeführt werden.

Beispiele:

- `move` = bewegen
- `move` = umziehen
- `right` = richtig
- `right` = Recht
- `light` = Licht
- `light` = leicht

Regeln:

- Jede eigenständige Bedeutung erhält eine eigene `meaning_id`.
- `meaning_note` muss die gemeinte Bedeutung klar erklären.
- Unterschiedliche Bedeutungen dürfen dieselbe `base_term` haben.
- Mehrdeutige Wörter ohne `meaning_note` bleiben `needs_review`.
- Wenn zwei Zeilen exakt dieselbe Bedeutung abbilden, wird eine als Dublette markiert.
- Wenn zwei Zeilen unterschiedliche Bedeutungen abbilden, werden sie als `meaning_variant` markiert und nicht gelöscht.

## 7. Dublettenbehandlung

Dubletten werden markiert, nicht automatisch gelöscht.

Typische Gruppen:

- `exact_duplicate`
  - gleicher Basisbegriff, gleiche Übersetzung, gleiche Sprachcodes, gleiche Bedeutung
- `case_variant`
  - Unterschiede nur durch Groß-/Kleinschreibung, z. B. `Friday`/`friday`
- `same_base_different_translation`
  - gleicher Basisbegriff, unterschiedliche Übersetzung
  - kann echte Bedeutungsvariante oder Konflikt sein
- `translation_variant`
  - unterschiedliche, aber mögliche Übersetzungen für dieselbe Bedeutung
- `technical_term_conflict`
  - z. B. `IT` als Branche vs. `it` als Pronomen

Review-Entscheidungen:

- `keep`
- `merge_later`
- `split_meaning`
- `rename`
- `reject`
- `needs_context`

Automatische Zusammenführung ist nicht erlaubt.

## 8. Problematische Wörter

Wörter bleiben `needs_review` oder werden `rejected`, wenn sie:

- falsche oder unnatürliche Übersetzungen haben
- ohne Kontext missverständlich sind
- Importreste, URLs oder Sonderzeichen enthalten
- extrem lang oder kein sinnvolles Lernwort sind
- beleidigend, sensibel oder alterskritisch sind
- eigentlich eine Phrase, Grammatikregel oder Paketbezeichnung sind
- eine Kategorie oder ein Level statt eines Wortes abbilden
- keine klare Wortwelt oder kein klares Level haben

Problematische Wörter sollen nicht still korrigiert werden. Sie bekommen `conflict_type`, `translation_note` und einen Review-Status.

## 9. Kategorien, Wortwelten, Level und Pakete

Zu prüfen:

- Ist die Wortwelt fachlich passend?
- Ist das Level realistisch?
- Sind A1-C2 echte Level und nicht normale Wortwelten?
- Ist `Top 500 Words` ein Paket und keine reguläre Wortwelt?
- Gehört ein Wort in mehrere Wortwelten?
- Muss eine Kategorie in Paket, Level, Thema oder Spezialliste getrennt werden?

Empfohlene Zieltrennung:

- Wortwelten: thematische Nutzeransichten
- Level: Schwierigkeitsgrad
- Pakete: kuratierte Content-Sammlungen, z. B. Top 500
- Speziallisten: Grammatik, unregelmäßige Verben, Redewendungen

Ein Wort kann mehreren fachlichen Sichten angehören, aber die Begriffe dürfen im Datenmodell nicht vermischt werden.

## 10. Mehrsprachige Vorbereitung

Der Review wird so geführt, dass Spanisch und Französisch später nicht als komplett getrennte Projekte neu begonnen werden müssen.

Beim Prüfen eines englischen Basiswortes werden im selben Schema geführt:

- `de_translation`
- `es_translation`
- `fr_translation`

Regeln:

- Deutsch wird für den ersten Release priorisiert geprüft.
- Spanisch und Französisch können leer bleiben oder den Status `needs_review` tragen.
- KI-Vorschläge für Spanisch/Französisch dürfen nur als `ai_suggested` markiert werden.
- Keine KI-Übersetzung wird ungeprüft in produktive Daten übernommen.
- Release-Pakete enthalten je Sprachpaar nur `approved` Übersetzungen.
- Weitere Sprachen können später durch neue Spalten oder ein normalisiertes Translation-Table-Format ergänzt werden.

Langfristig kann das Master-Schema in ein normalisiertes Modell übergehen:

- `terms`
- `meanings`
- `translations`
- `examples`
- `content_packages`
- `content_package_items`
- `review_events`

Für den manuellen MVP-Review ist eine Sheet-/CSV-Struktur pragmatischer.

## 11. KI-Nutzung

KI darf helfen, aber nicht entscheiden.

Erlaubt:

- Vorschläge für Übersetzungen
- Hinweise auf Mehrdeutigkeit
- Beispielsätze als Entwurf
- Dubletten- und Konfliktvorschläge
- Kategorie- oder Level-Vorschläge

Nicht erlaubt:

- automatische Freigabe
- automatische Korrektur produktiver Vokabeldaten
- ungeprüfte Spanisch-/Französisch-Erstellung
- automatische Löschung oder Zusammenführung
- Überschreiben menschlich geprüfter Inhalte

Jede KI-generierte Zeile erhält `review_status = ai_suggested`, bis sie manuell geprüft wurde.

## 12. Sichere automatische Prüfregeln

Automatische Regeln dürfen nur markieren.

Empfohlene Prüfregeln:

- leere Übersetzung
- gleicher Text in `base_term` und Übersetzung
- exakte Dublette
- Groß-/Kleinschreibung-Dublette
- gleiche `base_term` mit unterschiedlicher Übersetzung
- fehlendes Level
- fehlende Wortwelt/Kategorie
- unerwarteter Sprachcode, z. B. `EN` statt `en`
- URL- oder HTML-Verdacht
- sehr langer Begriff
- ungewöhnliche Sonderzeichen
- Begriff wirkt wie Kategorie, Level oder Paketname
- mehrere Bedeutungen ohne `meaning_note`
- Übersetzung enthält Slash-Listen ohne Erklärung
- Wortart fehlt oder passt nicht zur Übersetzung

Beispiel-`conflict_type`-Werte:

- `empty_translation`
- `same_base_and_translation`
- `exact_duplicate`
- `case_variant`
- `same_base_different_translation`
- `missing_level`
- `missing_word_world`
- `unexpected_language_code`
- `url_or_html_suspect`
- `too_long`
- `needs_meaning_note`
- `category_or_package_term`

## 13. Empfohlene Prüfreihenfolge

1. Sprachcodes normalisieren und alle `EN->DE`-Kandidaten prüfen.
2. URL-/HTML-/Importartefakte prüfen.
3. Exakte Dubletten und Case-Varianten prüfen.
4. Gleiche Basisbegriffe mit unterschiedlichen Übersetzungen nach Bedeutung trennen.
5. Wörter ohne Kategorie prüfen.
6. A1-C2 als Levelstruktur von Wortwelten trennen.
7. Top 500 und andere Pakete als Pakete markieren.
8. Wort-für-Wort-Review des englisch-deutschen Basisbestands.
9. Bedeutungsnotizen und Beispielsätze ergänzen.
10. Spanisch-/Französisch-Spalten vorbereiten und nur geprüfte Einträge freigeben.
11. Release-Paket pro Sprachpaar nur aus `approved` Content erzeugen.

## 14. Tool-Strategie

Der sichere Master-Seed-Export ist als lokales read-only Tool vorbereitet:

- `tool/export_vocabulary_review_seed.dart`
  - liest standardmäßig `docs/word-review/supabase_words_review.csv`
  - schreibt bei explizitem Aufruf `docs/word-review/vocabulary_review_seed.csv`
  - verbindet sich nicht mit Supabase
  - öffnet keine SQLite-Datenbank
  - führt keinen Import aus
  - erzeugt keine KI-Vorschläge
  - lässt Spanisch und Französisch leer
  - setzt jede Zeile auf `review_status = needs_review`
  - setzt jede Zeile auf `release_ready = false`

Beispiel:

```bash
dart tool/export_vocabulary_review_seed.dart \
  --input docs/word-review/supabase_words_review.csv \
  --output docs/word-review/vocabulary_review_seed.csv \
  --force
```

Bestehende Output-Dateien werden nur mit `--force` überschrieben.

Der generierte Seed kann anschließend lokal analysiert werden:

- `tool/analyze_vocabulary_review_seed.dart`
  - liest standardmäßig `docs/word-review/vocabulary_review_seed.csv`
  - schreibt `docs/word-review/vocabulary_review_seed_quality_report.md`
  - schreibt kleine, gezielte Kandidatenlisten für Problemfälle
  - verbindet sich nicht mit Supabase
  - öffnet keine SQLite-Datenbank
  - führt keinen Import aus
  - korrigiert keine Vokabeldaten
  - erzeugt keine KI-Vorschläge

Beispiel:

```bash
dart tool/analyze_vocabulary_review_seed.dart \
  --input docs/word-review/vocabulary_review_seed.csv \
  --report docs/word-review/vocabulary_review_seed_quality_report.md
```

Die große Datei `docs/word-review/vocabulary_review_seed.csv` bleibt in
`.gitignore` ignoriert. Commit-fähig sind nur der Qualitätsreport und kleine
Kandidatenlisten, sofern sie gezielt Problemfälle dokumentieren.

Für den ersten manuellen Batch gibt es zusätzlich einen lokalen Validator:

- `tool/validate_manual_review_batch.dart`
  - liest standardmäßig `docs/word-review/manual_review_first_batch.csv`
  - schreibt `docs/word-review/manual_review_first_batch_report.md`
  - prüft Header, Pflichtfelder, erlaubte `review_decision`-Werte und nötige Notizen
  - setzt keine Entscheidungen automatisch
  - vergibt kein `approved` und kein `release_ready`

Persönliche Arbeitskopien sollen nicht direkt versioniert werden. Dafür ist
`docs/word-review/*_working.csv` in `.gitignore` ignoriert. Abgestimmte
Review-Ergebnisse sollen später als separates Overlay entstehen.

Für diesen Overlay-Schritt gibt es ein separates read-only Tool:

- `tool/export_manual_review_overlay.dart`
  - liest standardmäßig `docs/word-review/manual_review_first_batch_working.csv`
  - schreibt standardmäßig `docs/word-review/manual_review_first_batch_overlay.csv`
  - exportiert nur Zeilen mit gefüllter `review_decision`
  - überspringt leere Entscheidungen
  - blockiert unbekannte Entscheidungen
  - verlangt bei `needs_context`, `reject` und `split_meaning` eine `review_note`
  - verlangt `--force`, wenn die Output-Datei bereits existiert
  - erzeugt kein `approved` und kein `release_ready`

Beispiel:

```bash
cp docs/word-review/manual_review_first_batch.csv \
  docs/word-review/manual_review_first_batch_working.csv

dart tool/validate_manual_review_batch.dart \
  --input docs/word-review/manual_review_first_batch_working.csv \
  --report docs/word-review/manual_review_first_batch_report.md

dart tool/export_manual_review_overlay.dart \
  --input docs/word-review/manual_review_first_batch_working.csv \
  --output docs/word-review/manual_review_first_batch_overlay.csv \
  --reviewer Andreas \
  --reviewed-at 2026-05-30
```

Das Overlay-Format ist bewusst klein:

- `word_key`
- `review_block`
- `base_term`
- `de_translation`
- `conflict_type`
- `review_decision`
- `review_note`
- `reviewer`
- `reviewed_at`

Ein Overlay ist kein Produktivimport. Es enthält nur menschliche
Review-Entscheidungen und verändert keine App-, Supabase-, SQLite-, SRS- oder
`word_progress`-Daten. Spätere Prozesse müssen Overlays erneut prüfen, bevor
daraus echte Content-Änderungen oder Release-Pakete entstehen.

Der erste manuelle Batch ist abgeschlossen und dokumentiert:

- `docs/word-review/manual_review_first_batch_summary.md`
- `docs/word-review/manual_review_first_batch_overlay.csv`
- `docs/word-review/manual_review_first_batch_report.md`

Der nächste Struktur-Fokus ist die Trennung von A1-C2-Leveln, `Top 500 Words`
als Paket und echten thematischen Wortwelten. Dafür gibt es eine eigene
Planung und eine kleine read-only Arbeitsliste:

- `docs/word-review/level_and_package_structure_review_plan.md`
- `docs/word-review/level_package_structure_first_batch.csv`
- `tool/export_level_package_structure_batch.dart`
- `tool/validate_level_package_structure_batch.dart`
- `tool/export_level_package_structure_overlay.dart`

Die Struktur-Batch-Datei ist nur eine Review-Arbeitsliste. Sie setzt keine
Level, keine Wortwelten und keine Pakete produktiv.

Der erste repräsentative Struktur-Batch wurde in einer lokalen Working-Copy
bearbeitet und validiert:

- 57 Strukturzeilen
- 57 gefüllte Entscheidungen
- 0 Validierungsprobleme
- Overlay: `docs/word-review/level_package_structure_first_batch_overlay.csv`
- Report: `docs/word-review/level_package_structure_first_batch_report.md`

Die Entscheidungen bleiben Overlay-/Review-Daten. Sie ändern keine App-Daten,
keine Supabase-Daten, keine SQLite-Daten, keine SRS-Daten und kein
`word_progress`. Größere Struktur-Batches sollen erst nach fachlicher Prüfung
dieses repräsentativen Batches folgen.

Grund:

- Es existiert bereits ein read-only Supabase-Review-Export.
- Es existieren bereits Cleanup- und Konflikt-Extraktoren.
- Der neue Seed-Exporter arbeitet nur auf lokalen CSV-Dateien.
- Produktive Vokabeldaten werden dadurch nicht berührt.

Weitere Tools sollten weiterhin:

- standardmäßig read-only sein
- keine Supabase-Writes enthalten
- keine SQLite-Writes enthalten
- keine Imports ausführen
- kleine Fixture-Tests haben
- Review-CSV oder JSONL erzeugen
- problematische Einträge nur markieren
- `--input` und `--output` unterstützen
- niemals ohne Review-Datei produktive Daten ändern

Mögliche spätere Ausgabe:

- `docs/word-review/vocabulary_review_seed.jsonl`

## 15. Release-Freigabe

Ein Wort oder eine Bedeutung ist releasefähig, wenn:

- `review_status = approved`
- `release_ready = true`
- Sprachcodes normalisiert sind
- Bedeutung eindeutig ist
- Übersetzung fachlich korrekt und natürlich ist
- Wortwelt und Level geprüft sind
- Dubletten-/Konfliktstatus geklärt ist
- keine ungeprüften KI-Vorschläge enthalten sind

Nicht releasefähig:

- `raw`
- `needs_review`
- `ai_suggested`
- `rejected`
- ungeklärte Dubletten
- ungeklärte Bedeutungsvarianten
- ungeklärte URL-/Importartefakte

## 16. Nächste konkrete Schritte

1. Bestehende Review-Dateien in `docs/word-review/` auf Aktualität prüfen.
2. Master-Review-Schema als Sheet oder CSV-Vorlage anlegen.
3. Sprachcode-Normalisierungskandidaten manuell entscheiden.
4. URL-/HTML-Kandidaten manuell prüfen.
5. Dubletten-Kandidaten nach `exact_duplicate`, `case_variant` und `meaning_variant` sortieren.
6. Bedeutungsschlüssel für häufige Mehrdeutigkeiten definieren.
7. A1-C2 und Top 500 fachlich von Wortwelten trennen.
8. Struktur-Overlay zu Level/Paket/Wortwelt fachlich prüfen.
9. Weitere Struktur-Batches gezielt erzeugen, besonders für `top_500_only` und `top_500_topic`.
10. Wort-für-Wort-Review des englisch-deutschen Basisbestands starten.
11. Spanisch-/Französisch-Spalten zunächst vorbereiten, aber nur manuell geprüfte Werte auf `approved` setzen.
12. Erst danach Content-Paket-Import/Export für Release-Pakete bauen.

## 17. Nicht-Ziele dieses Schritts

- keine Supabase-Datenänderung
- kein Supabase-Write
- kein Import
- keine SQLite-Datenänderung
- keine SRS-/`word_progress`-Änderung
- keine automatische Vokabelkorrektur
- keine ungeprüften KI-Übersetzungen
- keine produktiven Spanisch-/Französisch-Daten
- keine neue Content-Paket-Synchronisation
