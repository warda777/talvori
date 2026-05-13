# 19 SQLite Schema Test Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant die SQLite-Schema-Tests fuer Version 1 der lokalen Talvori-Datenbasis. Es beschreibt keine Implementierung und keinen Dart-Code.

Die Tests sollen sicherstellen, dass das lokale Schema die reine Dart-SRS-Engine dauerhaft und manipulationssicher mit Daten versorgen kann, ohne UI, Supabase oder App-Flows zu beruehren.

## Zu Erstellende Tabellen

Version 1 benoetigt diese Tabellen:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

## Pflichtfelder Pro Tabelle

### categories

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `name` TEXT NOT NULL
- `sort_order` INTEGER NOT NULL DEFAULT 0
- `is_archived` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optionale Felder:

- `description` TEXT NULL
- `source_language` spaeter optional
- `target_language` spaeter optional
- `icon_name` spaeter optional
- `color_value` spaeter optional
- `legacy_supabase_id` spaeter optional

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- `name` erlaubt kein NULL.
- Defaults fuer `sort_order` und `is_archived` greifen.

### words

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `category_id` TEXT NOT NULL
- `term` TEXT NOT NULL
- `translation` TEXT NOT NULL
- `sort_order` INTEGER NOT NULL DEFAULT 0
- `is_archived` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optionale Felder:

- `example_sentence` TEXT NULL
- `notes` TEXT NULL
- `legacy_supabase_id` spaeter optional

Nicht enthalten in Version 1:

- Audio
- Artikel
- Wortart
- DeepL-Metadaten
- weitere Zusatzfelder

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- `category_id`, `term` und `translation` erlauben kein NULL.
- Defaults fuer `sort_order` und `is_archived` greifen.
- Duplikate fuer `category_id, term, translation` sind erlaubt.

### word_progress

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `stage` TEXT NOT NULL
- `pass_count` INTEGER NOT NULL DEFAULT 0
- `wrong_count` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optionale Felder:

- `next_due_at` TEXT NULL
- `last_reviewed_at` TEXT NULL

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- `word_id`, `category_id`, `mode_id` und `stage` erlauben kein NULL.
- Defaults fuer `pass_count` und `wrong_count` greifen.
- Fortschritt ist pro `word_id, category_id, mode_id` eindeutig.

### review_history

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `training_area_id` TEXT NOT NULL
- `answer` TEXT NOT NULL
- `reviewed_at` TEXT NOT NULL
- `old_stage` TEXT NOT NULL
- `new_stage` TEXT NOT NULL
- `old_pass_count` INTEGER NOT NULL
- `new_pass_count` INTEGER NOT NULL
- `created_at` TEXT NOT NULL

Optionale Felder:

- `session_id` TEXT NULL
- `old_next_due_at` TEXT NULL
- `new_next_due_at` TEXT NULL
- `requeue_reason` TEXT NULL

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- Review-Ereignisse koennen mit und ohne `session_id` gespeichert werden.
- `focused`/Gezielt-ueben-Antworten koennen gespeichert werden, ohne dass das Schema Progress-Aenderungen erzwingt.

### learning_sessions

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `training_area_id` TEXT NOT NULL
- `status` TEXT NOT NULL
- `session_size` INTEGER NOT NULL
- `current_position` INTEGER NOT NULL DEFAULT 0
- `started_at` TEXT NOT NULL
- `last_activity_at` TEXT NOT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optionale Felder:

- `completed_at` TEXT NULL

Zulaessige Status fuer Version 1:

- `active`
- `completed`

Nicht verwenden:

- `abandoned`

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- `current_position` Default ist 0.
- `completed_at` darf NULL sein.
- Maximal eine aktive Session pro `category_id, mode_id, training_area_id` ist erlaubt.
- Eine abgeschlossene Session darf neben einer aktiven Session fuer denselben Kontext existieren.

### session_items

Pflichtfelder:

- `id` TEXT PRIMARY KEY
- `session_id` TEXT NOT NULL
- `word_id` TEXT NOT NULL
- `category_id` TEXT NOT NULL
- `mode_id` TEXT NOT NULL
- `stage_at_enqueue` TEXT NOT NULL
- `position` INTEGER NOT NULL
- `status` TEXT NOT NULL
- `is_new_card` INTEGER NOT NULL DEFAULT 0
- `same_session_wrong_count` INTEGER NOT NULL DEFAULT 0
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Optionale Felder:

- `due_at_enqueue` TEXT NULL
- `retry_after_position` INTEGER NULL
- `requeue_reason` TEXT NULL
- `shown_at` TEXT NULL
- `answered_at` TEXT NULL

Schema-Tests:

- Tabelle existiert.
- Pflichtfelder existieren.
- `id` ist Primary Key.
- `position` erlaubt kein NULL.
- `status` erlaubt kein NULL.
- Defaults fuer `is_new_card` und `same_session_wrong_count` greifen.
- Pro `session_id, position` ist nur ein Item erlaubt.
- Requeue kann als neues `session_item` mit neuer Position gespeichert werden.
- Das urspruengliche Item kann `answered` bleiben.

### settings

Pflichtfelder:

- `key` TEXT PRIMARY KEY
- `value` TEXT NOT NULL
- `value_type` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Schema-Tests:

- Tabelle existiert.
- `key` ist Primary Key.
- `value`, `value_type` und `updated_at` erlauben kein NULL.
- Derselbe `key` kann nicht doppelt eingefuegt werden.

## Zu Testende Indizes

### categories

Keine zusaetzlichen Pflichtindizes fuer Version 1.

### words

Pflichtindex:

- Index auf `category_id`

Bewusst nicht vorhanden:

- kein Unique-Index auf `category_id, term, translation`

### word_progress

Pflichtindizes:

- Index auf `category_id, mode_id, next_due_at`
- Index auf `word_id`
- Index auf `stage`

### review_history

Pflichtindizes:

- Index auf `word_id`
- Index auf `category_id, mode_id, reviewed_at`
- Index auf `session_id`

### learning_sessions

Pflichtindizes:

- Index auf `category_id, mode_id, training_area_id, status`
- Index auf `last_activity_at`

### session_items

Pflichtindizes:

- Index auf `session_id, position`
- Index auf `session_id, status`
- Index auf `session_id, word_id`

### settings

Kein zusaetzlicher Index notwendig, weil `key` Primary Key ist.

## Zu Testende Unique-Regeln

### word_progress

Regel:

- UNIQUE `word_id, category_id, mode_id`

Tests:

- derselbe Fortschrittseintrag kann nicht doppelt angelegt werden
- dasselbe Wort darf in anderem Modus eigenen Fortschritt haben
- dasselbe Wort darf in anderer Kategorie eigenen Fortschritt haben, falls Datenmodell das zulaesst

### learning_sessions

Regel:

- maximal eine aktive Session pro `category_id, mode_id, training_area_id`

Empfohlene technische Umsetzung:

- partieller Unique-Index auf `category_id, mode_id, training_area_id` WHERE `status = active`

Tests:

- zweite aktive Session im selben Kontext wird abgelehnt
- aktive Session in anderem Modus ist erlaubt
- aktive Session in anderem Trainingsbereich ist erlaubt
- abgeschlossene Session im selben Kontext ist erlaubt

### session_items

Regel:

- UNIQUE `session_id, position`

Tests:

- zwei Items mit gleicher Position in derselben Session werden abgelehnt
- gleiche Position in anderer Session ist erlaubt
- Requeue-Item mit neuer Position ist erlaubt

### settings

Regel:

- `key` PRIMARY KEY

Tests:

- derselbe Key kann nicht doppelt eingefuegt werden
- ein anderer Key ist erlaubt

## Geplante Fremdschluesselbeziehungen

### words

- `words.category_id` -> `categories.id`

### word_progress

- `word_progress.word_id` -> `words.id`
- `word_progress.category_id` -> `categories.id`

### review_history

- `review_history.word_id` -> `words.id`
- `review_history.category_id` -> `categories.id`
- `review_history.session_id` -> `learning_sessions.id` NULL erlaubt

### learning_sessions

- `learning_sessions.category_id` -> `categories.id`

### session_items

- `session_items.session_id` -> `learning_sessions.id`
- `session_items.word_id` -> `words.id`
- `session_items.category_id` -> `categories.id`

Hinweis:

- `mode_id` und `training_area_id` werden in Version 1 als stabile String-Werte gespeichert.
- Es sind keine eigenen Tabellen fuer Modes oder TrainingAreas geplant.

## Erste Schema-Tests

Die ersten Tests sollten klein und in dieser Reihenfolge geschrieben werden:

1. `creates_all_v1_tables`
   - prueft, dass alle sieben Tabellen existieren.

2. `creates_required_columns_for_core_tables`
   - prueft Pflichtfelder fuer `categories`, `words`, `word_progress`.

3. `creates_required_columns_for_session_tables`
   - prueft Pflichtfelder fuer `learning_sessions`, `session_items`.

4. `creates_required_columns_for_history_and_settings`
   - prueft Pflichtfelder fuer `review_history` und `settings`.

5. `word_progress_is_unique_per_word_category_and_mode`
   - prueft die wichtigste Progress-Trennung.

6. `learning_sessions_allows_only_one_active_session_per_context`
   - prueft den Manipulationsschutz gegen doppelte aktive Sessions.

7. `session_items_position_is_unique_per_session`
   - prueft stabile Queue-Reihenfolge.

8. `settings_key_is_primary_key`
   - prueft Key-Value-Eindeutigkeit.

9. `words_allow_duplicate_terms_in_same_category`
   - prueft bewusst erlaubte Duplikate.

10. `foreign_keys_reject_orphan_rows`
   - prueft zentrale Fremdschluessel fuer Kategorie, Wort, Session.

## Bewusst Noch Nicht Schreiben

Noch nicht Teil der reinen Schema-Tests:

- Repository-Methoden
- Mapping von SQLite-Zeilen zu SRS-Engine-Modellen
- `SrsEngine`-Integration
- Review-Transaktionen
- Session-Fortsetzung nach App-Neustart
- Supabase-Migration
- Supabase-Entfernung
- UI-Anbindung
- ViewModel-Anbindung
- Import echter App-Daten
- Backup oder Export lokaler Daten
- Performance-Tests mit sehr grossen Datenmengen

Diese Tests folgen spaeter auf Repository- oder Integrationsebene.

## Ergebnis

`docs/18-sqlite-repository-plan.md` ist jetzt fuer Version 1 entscheidungsfrei: Es sind keine offenen `[ENTSCHEIDUNG NOTWENDIG]`-Marker mehr vorhanden.

Als erstes umgesetzt werden sollten:

1. `creates_all_v1_tables`
2. `word_progress_is_unique_per_word_category_and_mode`
3. `learning_sessions_allows_only_one_active_session_per_context`
4. `session_items_position_is_unique_per_session`
5. `foreign_keys_reject_orphan_rows`

Diese Tests sichern die lokale Datenbasis dort ab, wo spaeter Datenverlust, doppelte Sessions oder kaputte Queue-Fortsetzung am teuersten waeren.
