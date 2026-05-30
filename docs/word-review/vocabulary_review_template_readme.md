# Vocabulary Review Template

Diese Vorlage ist die leere Master-Struktur für den späteren manuellen Vokabel-Review. Sie enthält keine produktiven Vokabeldaten, keine Beispielwörter und keine automatisch erzeugten Übersetzungen.

## Zweck

Die CSV `vocabulary_review_template.csv` dient als Ausgangspunkt, um englische Basiswörter Wort für Wort zu prüfen und perspektivisch weitere Übersetzungsspalten vorzubereiten.

Geprüft werden sollen unter anderem:

- Bedeutung und Übersetzung
- Bedeutungsvarianten
- Wortart
- Level
- Kategorie und Wortwelt
- Dubletten und Konflikte
- Release-Freigabe

## Statuswerte

Erlaubte Werte für `review_status`:

- `raw`
- `needs_review`
- `ai_suggested`
- `human_reviewed`
- `approved`
- `rejected`

Nur Einträge mit `review_status = approved` und `release_ready = true` gelten später als releasefähig.

## Mehrsprachigkeit

Die Spalten `es_translation` und `fr_translation` sind vorbereitet, damit Spanisch und Französisch später parallel geprüft werden können. Leere oder ungeprüfte Werte dürfen nicht produktiv freigegeben werden.

KI-Vorschläge dürfen nur mit `review_status = ai_suggested` geführt werden. Sie müssen menschlich geprüft werden, bevor sie `approved` werden können.

## Datensicherheit

Diese Vorlage verändert keine App-Daten. Sie betrifft keine Supabase-Daten, keine SQLite-Daten, keine User-Daten, kein SRS und kein `word_progress`.
