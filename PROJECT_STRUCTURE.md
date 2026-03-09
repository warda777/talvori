# Talvori - Flutter App Project Structure

> Aktualisiert am 12.02.2025

## 📁 Projektübersicht

- **Total Dart Files**: 222
- **Architektur**: Feature-basiert (Riverpod)
- **Backend**: Supabase & Edge Functions
- **Neue Features**: 
  - Stage Words Dialog mit modus-spezifischen Erklärungen
  - Modusabhängige Stage-Bezeichnungen im Popup (T0-T5, A0-A5, H0-H5 statt S0-S5)
  - Button-Bezeichnungen: "AUTO" (statt S0-S5), "SINGLE" (statt Single)
  - Visuelle Feedback-Systeme (Card Glow, Plasma Link, Switch Pulse)
  - Card Glow Settings (persistente Slider-Einstellungen)
  - Primary Language Einstellung (universell für alle Kategorien)
  - SVG-Icon Integration für Slider-Steuerung
  - Plasma Link Bündelung auf 10% reduziert
  - Wandering Wave Effekt im Plasma Link
  - Plasma Link und Switch Pulse auch im SINGLE-Modus aktiv

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
│       │   ├── card_glow_settings_provider.dart
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
│       │   ├── primary_language_provider.dart
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
│           │   ├── category_settings_dialog.dart
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

- `assets/` – Icons (inkl. SVG: low_sun-line.svg, bright_sun-line.svg, impulse.svg), Bilder, Sounds
- `sql/` – Data Dictionary & SQL-Skripte
- `docs/` – Generierte Dokumentation (ERD, PDF)
- `test/` – Widget Tests & Regression Checks

## 🔧 Provider & State Management

### Card Glow Settings Provider
- **Datei**: `lib/features/words/application/card_glow_settings_provider.dart`
- **Typ**: NotifierProvider
- **Speicherung**: SharedPreferences
- **Zweck**: Persistente Einstellungen für Glow-Intensität und Pulsierungsgeschwindigkeit

### Primary Language Provider
- **Datei**: `lib/features/words/application/primary_language_provider.dart`
- **Typ**: NotifierProvider
- **Speicherung**: SharedPreferences
- **Zweck**: Universelle Spracheinstellung (Englisch/Deutsch) für alle Kategorien

## 🎨 UI Komponenten

### SwipeableWordCard
- **Datei**: `lib/features/words/ui/cards/swipeable_word_card.dart`
- **Features**:
  - Animierter Glow-Effekt (BoxShadow-basiert)
  - Zwei horizontale Slider für Glow-Intensität und Pulsierungsgeschwindigkeit
  - SVG-Icons mit präziser Positionierung (Transform.translate)
  - Slider nur auf Vorderseite sichtbar
  - Persistente Einstellungen über CardGlowSettingsProvider

### Category Settings Dialog
- **Datei**: `lib/features/words/ui/widgets/category_settings_dialog.dart`
- **Zweck**: Einstellung der Primary Language
- **Integration**: Über Settings-Button in CategoryDetailScreen
