# 03 Offline-First SQLite Plan

Stand: 2026-05-13

## Zielbild

Talvori soll für den Launch vollständig lokal funktionieren. SQLite wird die primäre Datenquelle. Netzwerk, Supabase und Cloud-Sync dürfen für den Kern nicht erforderlich sein.

Offline-first bedeutet:

- App startet ohne Internet.
- Wörter und Kategorien sind lokal verfügbar.
- Lernfortschritt wird lokal persistiert.
- Sessions werden lokal fortgesetzt.
- Reviews und Fehler können nicht durch Neustart verloren gehen.
- Supabase ist nicht Source of Truth.

## Vorhandener Ansatz

`lib/features/words/data/local_word_database.dart` nutzt bereits `sqflite` und enthält:

- `word_progress`
- `word_progress_deck_state`
- `category_refill_state`

Das ist ein nützlicher Start, aber noch kein vollständiges Offline-Modell. Es fehlen vor allem:

- lokale Wörter
- lokale Kategorien
- Kategorie-Wort-Zuordnung
- Review-Eventlog
- aktive Sessions
- Session-Items/Queue
- lokale Settings
- Favoriten/My-Words
- Import-/Seed-Konzept

## Version-1-Mindestmodell

Für die erste lokale Engine werden mindestens diese Tabellen geplant:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

Der Fortschritt wird pro Wort, Kategorie und Modus getrennt gespeichert.

`word_progress` benötigt mindestens:

- `word_id`
- `category_id`
- `mode_id`
- `stage`
- `pass_count`
- `wrong_count`
- `next_due_at`
- `last_reviewed_at`

Weitere Tabellen und Felder können ergänzt werden, dürfen aber die Version-1-Engine nicht unnötig blockieren.

## Vorgeschlagene Tabellen

### app_profile

Lokaler Nutzer-/Gerätekontext.

- `profile_id`
- `device_id`
- `created_at`
- `updated_at`

Hinweis: Für Launch reicht ein lokales Standardprofil.

### words

Lokaler Wortbestand.

- `id`
- `text`
- `translation`
- `from_lang`
- `to_lang`
- `domain`
- `pos`
- `level`
- `tags_json`
- `created_at`
- `updated_at`
- `source`

### categories

Lokale Kategorien.

- `id`
- `name`
- `slug`
- `type`
- `group_slug`
- `group_name`
- `order_index`
- `created_at`
- `updated_at`

### word_categories

Zuordnung Wort zu Kategorie.

- `word_id`
- `category_id`
- `created_at`
- Primärschlüssel: `word_id + category_id`

### user_words

Nutzerbezogene Wortmarkierungen unabhängig vom SRS-Modus.

- `profile_id`
- `word_id`
- `picked`
- `favorite`
- `in_my_words`
- `source`
- `created_at`
- `updated_at`
- Primärschlüssel: `profile_id + word_id`

### learning_modes

Stabile interne Modusdefinition.

- `id`: z. B. `time`, `adaptive`, `hybrid`
- `user_label`
- `description`
- `is_enabled`

Diese Tabelle kann alternativ als Dart-Konstante beginnen. Wichtig ist aber, dass `mode_id` stabil bleibt.

### word_progress

Zentrale Fortschrittstabelle pro Kategorie, Wort und Modus.

Primärschlüssel:

- `profile_id`
- `category_id`
- `word_id`
- `mode_id`

Felder:

- `stage` 0-5
- `pass_count`
- `correct_in_stage`
- `wrong_in_stage`
- `total_correct`
- `total_wrong`
- `lapses`
- `last_reviewed_at`
- `next_due_at`
- `last_result`
- `ever_introduced`
- `introduced_at`
- `s5_reached_at`
- `reactivated_at`
- `is_mastered` optional, siehe `04-srs-engine-theory.md`
- `updated_at`

### review_history

Unveränderliches Ereignisprotokoll.

- `id`
- `profile_id`
- `category_id`
- `word_id`
- `mode_id`
- `training_area_id`
- `session_id`
- `reviewed_at`
- `answer_result`
- `old_stage`
- `new_stage`
- `old_pass_count`
- `new_pass_count`
- `old_next_due_at`
- `new_next_due_at`
- `response_ms`
- `created_at`

Warum wichtig:

- Debugging
- Manipulationsschutz
- spätere Statistiken
- Rekonstruktion bei Fehlern

### learning_sessions

Eine aktive Session pro Kategorie, Modus und Trainingsbereich.

- `id`
- `profile_id`
- `category_id`
- `mode_id`
- `training_area_id`
- `status`: `active`, `completed`, `abandoned_by_user`
- `created_at`
- `updated_at`
- `started_at`
- `completed_at`
- `queue_version`
- `current_index`
- `settings_json`

Unique Constraint:

- genau eine aktive Session pro `profile_id + category_id + mode_id + training_area_id`

### session_items

Persistierte Queue.

- `session_id`
- `position`
- `word_id`
- `stage_at_enqueue`
- `due_at_enqueue`
- `state`: `queued`, `shown`, `answered`, `retry_pending`, `done`
- `shown_count`
- `last_shown_at`
- `last_answered_at`
- `retry_after_position`
- `retry_reason`

Wichtig: Falsch beantwortete Karten bleiben in derselben Session sichtbar und werden per Position/Requeue erneut eingeordnet.

### daily_limits

Lokale Tageszähler pro Kategorie/Modus.

- `profile_id`
- `category_id`
- `mode_id`
- `day`
- `new_introduced`
- `reviews_done`
- `errors`
- `updated_at`

### settings

Lokale Einstellungen.

- `key`
- `value_json`
- `updated_at`

Beispiele:

- letzter Modus
- letzter Trainingsbereich
- S0-Lock
- Sound/Haptik
- UI-Präferenzen

## Benötigte Indizes

- `word_progress(profile_id, category_id, mode_id, stage)`
- `word_progress(profile_id, category_id, mode_id, next_due_at)`
- `word_progress(profile_id, category_id, mode_id, stage, next_due_at)`
- `learning_sessions(profile_id, category_id, mode_id, training_area_id, status)`
- `session_items(session_id, position)`
- `review_history(profile_id, category_id, mode_id, reviewed_at)`
- `word_categories(category_id, word_id)`
- `words(text, from_lang, to_lang)`

## Daten, die dauerhaft lokal gespeichert werden müssen

- Wörter und Übersetzungen
- Kategorien und Gruppierung
- Wort-Kategorie-Zuordnung
- Favoriten/My-Words/Picked-Status
- Fortschritt pro `category_id + word_id + mode_id`
- Review-Historie
- aktive Session und Queue
- Tageszähler für neue Karten und Reviews
- Einstellungen
- lokale Profil-/Device-ID

## Migration aus Supabase

Entscheidung für diese Planungsphase: Supabase-Datenmigration wird zurückgestellt. Sie blockiert nicht die erste lokale Engine.

Mögliche spätere Wege:

- leerer lokaler Fortschrittsstart für erste Test-/Launch-Version
- einmaliger Export aus Supabase als Seed-Datei
- App-interner Import alter Fortschrittsdaten
- manuelle Migration nur für Testgeräte

## DeepL und Wortimport

Entscheidung für diese Planungsphase: DeepL/Wortimport wird zurückgestellt. Diese Funktionen dürfen als spätere Launch- oder Post-Launch-Themen dokumentiert werden, blockieren aber nicht die erste lokale SRS-Engine.

## Architektur-Empfehlung

- SQLite-Zugriff in Data-Schicht kapseln.
- SRS-Engine darf kein `sqflite`, kein Flutter und kein Riverpod kennen.
- Die SRS-Engine entscheidet nur über Lernlogik: Stage-Wechsel, `next_due_at`, Requeue, neue Karten ja/nein und Session-Queue.
- Das Repository ist für Speicherung zuständig: Wörter, Kategorien, Fortschritt, Sessions, Review-Historie und Einstellungen.
- Repository liefert Fachobjekte an Controller.
- Controller koordiniert Session, aber berechnet Regeln nicht selbst.
- UI kennt keine Datenbanktabellen und keine technischen SRS-Begriffe.
