# 📁 Projektstruktur (Talvori)

Letzte Aktualisierung: 2025-10-30

## Layering

- `lib/features/words/ui/...` UI Widgets/Screens
- `lib/features/words/application/...` Controller, Provider, Business-Logik
- `lib/features/words/data/...` Datenzugriff (Supabase Repository)
- `lib/features/words/domain/...` Modelle/Entities
- `lib/core/...` Core-Services, Theme, Utilities

## Wichtige Module

### UI

- `ui/screens/category_detail_screen.dart` – Kategorie-Detail, LevelsCard, Mode-Auswahl
- `ui/screens/learn_mode_screen.dart` – Learn-Modus; rendert `StageSwitchRow` oder `SingleModeSwitchRow`
- `ui/widgets/levels_card.dart` – Enthält `StageSwitchRow`, Puls/Glow-Controller, Single-Highlight
- `ui/widgets/stage_switch_row.dart` – S0–S5 Switch-Reihe, Blinken/Pulsieren, Auswahl im Single-Mode
- `ui/widgets/vertical_stage_switch.dart` – Einzelner Switch (Design, Glow nur außen)
- `ui/widgets/level_selector_buttons.dart` – Buttons: S0–S5, S1–S5, Single
- `ui/widgets/single_mode_switch_row.dart` – UI-Reihe für Single-Session (SRC, SR1, SR2)
- `ui/widgets/single_stage_picker.dart` – BottomSheet für S1–S5 Auswahl

### Application

- `application/learn_mode_controller.dart` – Learn-Flow, Antworten-Logik, Queue-Management, Single-Session Hooks
- `application/level_selection_provider.dart` – Riverpod-State: `levelSelectionProvider`, `singleStageProvider`, `selectingSingleProvider`, `allowedStagesProvider`, `singleSessionCountsProvider`
- `application/level_selection_controller.dart` – Zentrale Handler für Mode-Wechsel und Stage-Picker

### Data

- `data/supabase_word_repository.dart` – Supabase-Zugriff
  - `fetchLearnQueueForMode(categoryId, mode, singleStage)` – RPC `fn_user_learn_queue_mode`
  - Single-Session:
    - `singleSeed(catId, stage)` → `fn_single_session_seed`
    - `singleCounts(catId, stage)` → `fn_single_session_counts`
    - `singleMove(catId, stage, wordId, correct)` → `fn_single_session_move (p_correct)`
    - `singleReset(catId, stage)` → `fn_single_session_reset`
    - `singleNextWordId(catId, stage)` → `fn_single_session_next` (Map/List tolerant, Debug-Log)
    - `fetchWordById(wordId)` → `v_words_user`

### Domain

- `domain/word.dart` – Word/WordUserView, null-sichere `fromJson`

## Design-Guidelines

- Glow nur am äußeren Switch-Container (Gold/Rot), nicht an der inneren Kapsel
- Innere Kapsel immer dunkelgrau; ausgewählte Stufe (Single) mit hellblauem Rand/Glow (`#6FD3FF`)
- Sichtbarkeits-Maske nur im Learn-Mode anwenden (nicht in Kategorie-Screen)

## Letzte Änderungen

- Single-Mode UI vereinheitlicht, `SingleModeSwitchRow` nutzt identische Farben wie S0–S5
- `singleNextWordId` auf RPC `fn_single_session_next` umgestellt, robustere Antwortverarbeitung
- `singleMove` Parameter zu `p_correct` (Boolean) geändert
- Kategorie-Screen: `selectedStageHighlight` und Puls/Glow-Feedback integriert
