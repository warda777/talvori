# 📋 Programmliste – Übersicht aller Dateien

> **Letzte Aktualisierung:** 12.02.2025  
> **Total Dart Files:** 222

## 📊 Projekt-Statistiken

- **Words Feature:** ~47 Dateien
- **Home Feature:** ~56 Dateien
- **Core:** 9 Dateien

---

## lib/core/

| Datei | Zweck |
|-------|-------|
| `events/events.dart` | Event-System |
| `events/reset_event.dart` | ResetEvent |
| `services/browser_return_service.dart` | Browser-Return |
| `services/services.dart` | Services-Export |
| `theme/app_theme.dart` | AppTheme |
| `ui/effects/fireworks_overlay.dart` | Fireworks-Overlay |
| `ui/effects/fireworks_service.dart` | Fireworks-Service |
| `ui/widgets/progress_bar.dart` | ProgressBar |
| `ui/widgets/round_icon.dart` | RoundIcon |

---

## lib/features/words/

### application/

| Datei | Zweck |
|-------|-------|
| `learn_mode_controller.dart` | Learn-Flow, Queue, A-SRS/Hybrid/T-SRS, Single-Session |
| `category_detail_controller.dart` | Kategorie-Detail, seedForStart, reset |
| `word_list_controller.dart` | Wortliste, Filter |
| `category_controller.dart` | Kategorie-State |
| `category_detail_state.dart` | CategoryDetailState |
| `srs_mode_controller.dart` | SRS-Modus (time/adaptive/hybrid) |
| `srs_config.dart` | SRS-Konfiguration |
| `srs_logic.dart` | SRS-Logik |
| `a_srs_refill_engine.dart` | A-SRS Refill |
| `a_srs_bands.dart` | A-SRS Stage-Bands |
| `s0_lock_provider.dart` | S0 Lock |
| `level_selection_controller.dart` | Mode-Wechsel (AUTO/SINGLE, Stage-Picker) |
| `level_selection_provider.dart` | levelSelectionProvider, singleStageProvider |
| `card_glow_settings_provider.dart` | Card Glow (SharedPreferences) |
| `primary_language_provider.dart` | Primary Language (EN/DE) |
| `word_providers.dart` | Word-Provider |
| `word_hub_tile_overrides_provider.dart` | Hub-Tile-Farben |
| `word_hub_glow_provider.dart` | Hub-Glow |
| `radial_palette_controller.dart` | Radiale Farbpalette |
| `palette_controller.dart` | Palette |
| `mix/mix_navigation_controller.dart` | Mix-Navigation |
| `mix/mix_selection_controller.dart` | Mix-Selection |
| `mix/mix_search_providers.dart` | Mix-Search |
| `sort/vocab_sort_controller.dart` | Vocab-Sort |
| `timer_helpers.dart` | Timer-Helfer |

### data/

| Datei | Zweck |
|-------|-------|
| `supabase_word_repository.dart` | Haupt-Repository: RPCs, fetchLearnQueue, submitReview |
| `category_repository.dart` | Kategorien |
| `word_hub_taxonomy.dart` | Hub-Taxonomie |
| `words_store.dart` | Words-Store |
| `local_word_database.dart` | Lokale DB |
| `appearance_prefs_repository.dart` | Appearance-Prefs |

### domain/

| Datei | Zweck |
|-------|-------|
| `word.dart` | Word, WordUserView |
| `srs_kind.dart` | SRSKind |

### ui/screens/

| Datei | Zweck |
|-------|-------|
| `learn_mode_screen.dart` | Learn-Mode |
| `category_detail_screen.dart` | Kategorie-Detail |
| `word_hub_screen.dart` | Word Hub |
| `word_list_screen.dart` | Wortliste |
| `mix_builder_screen.dart` | Mix-Builder |
| `vocab_sort_screen.dart` | Vocab-Sort |
| `quick_sets_detail_screen.dart` | Quick Sets |
| `my_words_screen.dart` | My Words |

### ui/widgets/

| Datei | Zweck |
|-------|-------|
| `stage_switch_row.dart` | S0–S5 Switch-Reihe |
| `vertical_stage_switch.dart` | Einzelner Switch |
| `single_mode_switch_row.dart` | Single-Mode (SRC, SR1, SR2) |
| `srs_mode_toggle_with_hint.dart` | SRS-Modus (T/A/H) + Hint |
| `levels_card.dart` | LevelsCard |
| `swipeable_word_card.dart` | SwipeableCard |
| `stage_words_dialog.dart` | Stage-Wörter-Popup |
| `card_glow_painter.dart` | Card Glow |
| `plasma_link_painter.dart` | Plasma Link |
| `switch_pulse_painter.dart` | Switch Pulse |
| `category_card.dart` | Kategorie-Kachel |
| `frozen_stage_switch_overlay.dart` | Hybrid-Frozen-Overlay |
| `radial_palette_sheet.dart` | Radiale Palette |
| … weitere Widgets | |

---

## lib/features/home/

- Application: `home_controller`, `profile_controller`, `settings_controller`, `vocab_controller`
- Data: `share_ingest_service`
- UI: Screens, Widgets (BottomNav, Theme, etc.)

---

## lib/features/decks/, push/, rewards/

| Feature | Dateien |
|---------|---------|
| decks | `deck.dart` |
| push | `daily_picks_store.dart` |
| rewards | `rewards_center_screen.dart` |

---

## Verweise

- **Datenbank:** `DATABASE_USAGE.md`, `DATA_DICTIONARY.md`
- **Supabase:** `SUPABASE_ARCHITECTURE.md`
- **Struktur:** `PROJECT_STRUCTURE.md`
- **SRS-Modi:** `docs/SRS_MODI_FUER_NUTZER.md`, `docs/SRS_SYSTEMS.md`
