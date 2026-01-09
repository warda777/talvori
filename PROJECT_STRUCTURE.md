# Talvori - Flutter App Project Structure

> Aktualisiert am 27.01.2025

## 📁 Projektübersicht

- **Total Dart Files**: 212
- **Architektur**: Feature-basiert (Riverpod)
- **Backend**: Supabase & Edge Functions
- **Neue Features**: 
  - Stage Words Dialog mit modus-spezifischen Erklärungen
  - Visuelle Feedback-Systeme (Card Glow, Plasma Link, Switch Pulse)

## 📂 Verzeichnisstruktur (`lib/`)

```
├── core/
│   ├── events/
│   │   ├── events.dart
│   │   └── reset_event.dart
│   ├── services/
│   │   ├── browser_return_service.dart
│   │   └── services.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── ui/
│       ├── effects/
│       │   ├── fireworks_overlay.dart
│       │   └── fireworks_service.dart
│       └── widgets/
│           ├── progress_bar.dart
│           └── round_icon.dart
├── features/
│   ├── common/
│   │   └── widgets/
│   │       ├── fireball_bounce_animation.dart
│   │       └── sparkle_particle_effect.dart
│   ├── decks/
│   │   └── domain/
│   │       └── deck.dart
│   ├── home/
│   │   ├── application/
│   │   │   ├── application.dart
│   │   │   ├── home_controller.dart
│   │   │   ├── home_state.dart
│   │   │   ├── profile_controller.dart
│   │   │   ├── settings_controller.dart
│   │   │   ├── v_icon_controller.dart
│   │   │   └── vocab_controller.dart
│   │   ├── data/
│   │   │   ├── data.dart
│   │   │   └── share_ingest_service.dart
│   │   ├── ui/
│   │   │   ├── screens/
│   │   │   ├── strings/
│   │   │   ├── theme/
│   │   │   ├── widgets/
│   │   │   └── home_screen.dart
│   │   └── providers.dart
│   ├── push/
│   │   └── data/
│   │       └── daily_picks_store.dart
│   ├── rewards/
│   │   └── ui/
│   │       └── screens/
│   └── words/
│       ├── application/
│       │   ├── mix/
│       │   ├── sort/
│       │   ├── application.dart
│       │   ├── category_controller.dart
│       │   ├── category_controller.g.dart
│       │   ├── category_detail_controller.dart
│       │   ├── category_detail_state.dart
│       │   ├── category_id_cache.dart
│       │   ├── category_stats_provider.dart
│       │   ├── category_illustrations.dart
│       │   ├── learn_mode_controller.dart
│       │   ├── learn_navigation_origin.dart
│       │   ├── learning_engine_provider.dart
│       │   ├── level_selection_controller.dart
│       │   ├── level_selection_provider.dart
│       │   ├── quick_sets_providers.dart
│       │   ├── s0_lock_provider.dart
│       │   ├── srs_config.dart
│       │   ├── srs_logic.dart
│       │   ├── srs_mode_controller.dart
│       │   ├── timer_helpers.dart
│       │   ├── word_list_controller.dart
│       │   ├── word_list_controller.g.dart
│       │   └── word_providers.dart
│       ├── data/
│       │   ├── category_repository.dart
│       │   ├── last_shared_word_provider.dart
│       │   ├── mock_word_repository.dart
│       │   ├── supabase_word_repository.dart
│       │   ├── word_hub_taxonomy.dart
│       │   └── words_store.dart
│       ├── domain/
│       │   ├── srs_kind.dart
│       │   └── word.dart
│       ├── services/
│       │   ├── services.dart
│       │   └── sfx_service.dart
│       └── ui/
│           ├── cards/
│           ├── screens/
│           ├── theme/
│           ├── widgets/
│           │   ├── stage_words_dialog.dart
│           │   ├── card_glow_painter.dart
│           │   ├── plasma_link_painter.dart
│           │   ├── switch_pulse_painter.dart
│           │   └── ...
│           └── ui_constants.dart
├── ui/
│   └── common/
│       ├── mini_badge.dart
│       └── mini_badge_examples.dart
└── main.dart
```

## 📂 Supabase Functions (`supabase/functions/`)

```
├── ingest_word/
│   └── index.ts
└── translate-missing/
    └── index.ts
```

## 📁 Sonstige wichtige Verzeichnisse

- `assets/` – Icons, Bilder, Sounds
- `sql/` – Data Dictionary & SQL-Skripte
- `docs/` – Generierte Dokumentation (ERD, PDF)
- `test/` – Widget Tests & Regression Checks
