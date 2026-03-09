# Datenbankzugriffe der App

> Aktualisiert am 12.02.2025

## Direkt genutzte Tabellen (`.from()`)

### Views (Read-Only)
- **`v_words_user`** - View mit Wörtern und User-spezifischen Daten (srs_stage_user, next_due_at_user, etc.)
- **`v_words_user_srs`** - View mit Wörtern + SRS-Daten pro Modus (time/adaptive/hybrid); verwendet `word_id`, `srs_stage_user`, `next_due_at`
- **`words_view`** - View für Wörter (erweiterte Ansicht)

### Tabellen (Read/Write)
- **`words`** - Basis-Tabelle für Wörter
- **`categories`** - Kategorien
- **`user_words`** - User-spezifische Wort-Daten (favorites, picked, srs_stage, etc.)
- **`user_word_srs`** - Modus-spezifischer SRS-Zustand (stage, streak, next_due_at) pro User/Wort/Kategorie/Modus
- **`word_categories`** - Verknüpfungstabelle zwischen Wörtern und Kategorien
- **`single_session_items`** - Single-Session Items (für Single-Mode)
- **`a_refill_state`** - A-SRS Refill-Zähler (user_id, category_id, mode, refill_counter)
- **`a_deck_state`** - A-SRS Deck-Zustand (last_queued_counter)
- **`word_progress_deck_state`** - A-SRS Deck-State pro Wort (last_queued_counter)

## RPC-Funktionen (`.rpc()`)

### Progress & Counts
- **`fn_user_stage_counts`** - Stage-Zähler für eine Kategorie
- **`fn_user_category_progress`** - Progress mit Mode-Unterstützung (time/adaptive/hybrid)
- **`fn_category_word_count`** - Gesamtanzahl Wörter in einer Kategorie
- **`fn_user_workload_today`** - Heutige Workload

### Learn Queue
- **`fn_user_learn_queue`** - Lern-Queue für eine Kategorie (Legacy)
- **`fetch_learn_queue_for_mode`** - Lern-Queue für T-SRS und Hybrid (mit stage-Parameter)
- **`fn_user_learn_queue_adaptive_impl`** - Adaptiver Lern-Queue für A-SRS (S1–S5)

### Review
- **`fn_user_review_mode`** - Review für A-SRS (adaptive Mode)
- **`fn_user_review_time_mode`** - Review für T-SRS (time Mode)
- **`fn_user_review_hybrid_mode`** - Review für Hybrid Mode

### A-SRS
- **`fn_a_srs_refill_enroll`** - Neue Karten in S1 einbuchen (Refill)
- **`fn_a_srs_next_refill_counter`** - Refill-Counter erhöhen für nächste Deck-Runde
- **`fn_a_srs_s0_correct`** - S0→S1 bei korrektem Swipe
- **`fn_requeue_s0_fail`** - S0 bei falschem Swipe zurück in Queue

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



