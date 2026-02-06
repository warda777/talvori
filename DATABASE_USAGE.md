# Datenbankzugriffe der App

## Direkt genutzte Tabellen (`.from()`)

### Views (Read-Only)
- **`v_words_user`** - View mit Wörtern und User-spezifischen Daten (srs_stage_user, next_due_at_user, etc.)
- **`words_view`** - View für Wörter (vermutlich erweiterte Ansicht)

### Tabellen (Read/Write)
- **`words`** - Basis-Tabelle für Wörter
- **`categories`** - Kategorien
- **`user_words`** - User-spezifische Wort-Daten (favorites, picked, user_added_at, etc.)
- **`word_categories`** - Verknüpfungstabelle zwischen Wörtern und Kategorien
- **`single_session_items`** - Single-Session Items (für Single-Mode)

## RPC-Funktionen (`.rpc()`)

### Progress & Counts
- **`fn_user_stage_counts`** - Stage-Zähler für eine Kategorie
- **`fn_user_category_progress_mode`** - Progress mit Mode-Unterstützung (time/adaptive/hybrid)
- **`fn_category_word_count`** - Gesamtanzahl Wörter in einer Kategorie
- **`fn_user_workload_today`** - Heutige Workload

### Learn Queue
- **`fn_user_learn_queue`** - Lern-Queue für eine Kategorie
- **`fetch_learn_queue_for_mode`** - Lern-Queue mit Mode-Unterstützung

### Review
- **`fn_user_review_mode`** - Review für adaptive/hybrid Mode
- **`fn_user_review_time_mode`** - Review für time Mode

### Single Session (Single-Mode)
- **`fn_single_session_seed`** - Single-Session initialisieren
- **`fn_single_session_counts`** - Single-Session Counts abrufen
- **`fn_single_session_move`** - Wort in Single-Session verschieben
- **`fn_single_session_reset`** - Single-Session zurücksetzen
- **`fn_single_session_next`** - Nächstes Wort in Single-Session

### Category Management
- **`fn_seed_user_category`** - User-Kategorie initialisieren/seeden
- **`fn_reset_category_progress`** - Kategorie-Progress zurücksetzen

### S0 Lock
- **`fn_get_s0_locked`** - Stage 0 Lock-Status abrufen
- **`fn_set_s0_locked`** - Stage 0 Lock-Status setzen

## Verwendungsorte

### Haupt-Repository
- `lib/features/words/data/supabase_word_repository.dart` - Hauptzugriffspunkt für alle DB-Operationen

### Controller
- `lib/features/words/application/learn_mode_controller.dart` - Learn-Mode Logik
- `lib/features/words/application/category_detail_controller.dart` - Category Detail Logik
- `lib/features/words/application/s0_lock_provider.dart` - S0 Lock Management

### Weitere Stellen
- `lib/main.dart` - Initialisierung/Health-Check
- `lib/features/words/application/word_list_controller.dart` - Word List Logik



