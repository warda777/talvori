# Talvori - Flutter App Project Structure

## 📁 Project Overview

- **Total Dart Files**: 140
- **Architecture**: Feature-based with Clean Architecture principles
- **State Management**: Riverpod (NotifierProvider)
- **Backend**: Supabase
- **UI Framework**: Flutter Material Design
- **Theme System**: Centralized with ThemeExtension
- **Platforms**: iOS, Android

## 🏗️ Core Architecture

### 📂 `lib/core/` - Shared Infrastructure

```
lib/core/
├── events/                    # Global event system
│   ├── events.dart           # Barrel file for events
│   └── reset_event.dart      # Reset event for app-wide resets
├── services/                  # Core services
│   ├── services.dart         # Barrel file for services
│   └── browser_return_service.dart  # Browser navigation service
├── theme/                     # App theming
│   └── app_theme.dart        # Main app theme configuration with ThemeExtension
└── ui/widgets/               # Reusable UI components
    ├── progress_bar.dart     # Generic progress bar widget
    └── round_icon.dart       # Round icon button widget
```

## 🎯 Feature Modules

### 📂 `lib/features/` - Feature-based Organization

#### 🏠 Home Feature (`lib/features/home/`) - Refactored Architecture

```
lib/features/home/
├── application/              # Business logic & state management
│   ├── application.dart     # Barrel file for application layer
│   ├── home_controller.dart # Home screen controller (NotifierProvider)
│   └── home_state.dart      # Home screen state model
├── data/                     # Data layer
│   ├── data.dart            # Barrel file for data layer
│   └── share_ingest_service.dart  # Share data ingestion service
├── providers.dart            # Riverpod provider definitions
└── ui/
    ├── screens/              # Home-related screens
    │   ├── course_screen.dart
    │   ├── home_screen.dart  # Fully refactored & presentational
    │   ├── profile_screen.dart
    │   └── vocab_screen.dart
    ├── strings/              # Localization & UI strings
    │   ├── strings.dart      # Barrel file for strings
    │   └── home_strings.dart # Centralized UI strings
    ├── theme/                # Theme & styling
    │   ├── theme.dart        # Barrel file for theme
    │   └── home_theme.dart   # Colors, spacing & dimensions
    └── widgets/              # Home-specific widgets
        ├── widgets.dart      # Barrel file for widgets
        ├── bottom_nav.dart
        ├── category_popup.dart    # Category selection popup
        ├── counter_badge.dart
        ├── glow_sweep_ring.dart
        ├── practice_picker.dart   # Practice mode picker
        ├── progress_pill.dart
        ├── tap_flash.dart
        └── top_bar.dart
```

#### 📚 Words Feature (`lib/features/words/`) - Main Learning Module (102 files)

```
lib/features/words/
├── application/              # Business logic & state management
│   ├── application.dart     # Barrel file for application layer
│   ├── category_controller.dart        # Category state management
│   ├── category_controller.g.dart      # Generated code
│   ├── category_detail_controller.dart  # Category detail state management
│   ├── category_detail_state.dart       # Category detail state model
│   ├── category_id_cache.dart          # Category ID caching
│   ├── category_stats_provider.dart     # Category statistics
│   ├── learn_mode_controller.dart       # Main learning controller (NotifierProvider)
│   ├── learn_navigation_origin.dart     # Navigation origin tracking
│   ├── learning_engine_provider.dart    # Learning engine toggle state
│   ├── level_selection_controller.dart  # Level selection logic
│   ├── level_selection_provider.dart    # Level selection state (S0-S5, S1-S5, Single)
│   ├── mix/                            # Mix feature controllers
│   │   ├── mix_groups.dart             # Mix group definitions
│   │   ├── mix_navigation_controller.dart
│   │   ├── mix_navigation_origin.dart
│   │   ├── mix_search_providers.dart
│   │   └── mix_selection_controller.dart
│   ├── quick_sets_providers.dart        # Quick sets feature
│   ├── s0_lock_provider.dart           # S0 lock state (prevents new cards)
│   ├── sort/                           # Sort feature controllers
│   │   ├── add_button_lock_provider.dart
│   │   ├── category_stroke_colors.dart
│   │   └── vocab_sort_controller.dart
│   ├── srs_config.dart      # Spaced Repetition System config
│   ├── srs_logic.dart       # SRS algorithm implementation
│   ├── srs_mode_controller.dart        # SRS mode (T-SRS, A-SRS, Hybrid)
│   ├── timer_helpers.dart   # Timer utility functions
│   ├── word_list_controller.dart       # Word list state management
│   ├── word_list_controller.g.dart     # Generated code
│   └── word_providers.dart  # Riverpod providers for words
├── data/                     # Data layer
│   ├── category_repository.dart        # Category data access
│   ├── last_shared_word_provider.dart  # Shared word tracking
│   ├── mock_word_repository.dart       # Mock data for testing
│   ├── supabase_word_repository.dart  # Supabase integration (RPC calls)
│   ├── word_hub_taxonomy.dart         # Hub taxonomy definitions
│   └── words_store.dart                # Local word storage
├── domain/                   # Domain models
│   ├── srs_kind.dart        # SRS kind enum (tSrs, aSrs, neutral)
│   └── word.dart            # Word entity
├── services/                 # Feature-specific services
│   ├── services.dart        # Barrel file for services
│   └── sfx_service.dart     # Sound effects & haptic feedback
└── ui/                      # User interface
    ├── theme/               # Centralized theme system
    │   ├── theme.dart       # Barrel file for theme
    │   ├── words_colors.dart # ThemeExtension for colors
    │   └── words_layout.dart # Centralized layout constants
    ├── cards/               # Card components
    │   ├── cards.dart       # Barrel file for cards
    │   ├── counter_badge.dart
    │   ├── glow_sweep_ring.dart
    │   ├── swipeable_word_card.dart  # Main learning card
    │   ├── tap_flash.dart
    │   └── word_card.dart
    ├── screens/             # Screen components
    │   ├── category_detail_screen.dart  # Refactored with controller
    │   ├── learn_mode_screen.dart    # Main learning interface
    │   ├── mix_builder_screen.dart   # Mix builder interface
    │   ├── my_words_screen.dart
    │   ├── quick_sets_detail_screen.dart  # Quick sets detail
    │   ├── vocab_sort_screen.dart
    │   ├── word_hub_screen.dart      # Word hub with taxonomy
    │   └── word_list_screen.dart
    ├── widgets/             # UI widgets (45+ widgets)
    │   ├── widgets.dart     # Barrel file for widgets
    │   ├── bottom_controls.dart      # Play/Pause/Reset controls
    │   ├── burger_section_card.dart  # Section card for hub
    │   ├── cancel_timer_button.dart
    │   ├── card_area.dart           # Card display area
    │   ├── category_card.dart       # Category display card
    │   ├── category_header_capsule.dart  # Category header component
    │   ├── category_wheel.dart      # Category selector
    │   ├── category_wheel_example.dart
    │   ├── empty_state.dart         # Empty state widget
    │   ├── glow_circle_button.dart  # Glowing circular button
    │   ├── glow_rect_tile.dart      # Glowing rectangular tile
    │   ├── grid_section.dart        # Grid layout section
    │   ├── header_bar.dart          # Top navigation bar
    │   ├── learning_status_panel.dart  # Progress & stats panel
    │   ├── level_badge.dart         # CEFR level display (A1-C2)
    │   ├── level_selector_buttons.dart  # Level selection buttons (S0-S5, S1-S5, Single)
    │   ├── levels_card.dart         # SRS levels display card (with S0 lock support)
    │   ├── list_end_footer.dart     # List footer with loading
    │   ├── menu_sheet.dart          # Context menu
    │   ├── mini_badge.dart          # Mini badge component
    │   ├── mix_donut_toggle.dart    # Mix donut toggle
    │   ├── mix_pick_or_search_bar.dart   # Mix pick/search bar
    │   ├── mix_search_result_tile.dart   # Mix search results
    │   ├── mix_top_bar.dart         # Mix top bar
    │   ├── mode_toggle.dart         # Learning engine toggle (E-SRS/L-SRS)
    │   ├── play_pause_button.dart
    │   ├── progress_ring.dart       # Circular progress indicator
    │   ├── reset_button.dart        # Hold-to-reset button
    │   ├── section_header.dart      # Section header
    │   ├── shimmer_box.dart         # Shimmer loading box
    │   ├── shimmer_list.dart        # Shimmer loading list
    │   ├── single_mode_switch_row.dart  # Single mode switch row (S{n}, SR1, SR2)
    │   ├── single_stage_picker.dart     # Single stage picker widget
    │   ├── sort/                    # Sort-specific widgets
    │   │   └── word_decision_wheel.dart
    │   ├── stage_switch_row.dart    # SRS stage indicators (with S0 lock support)
    │   ├── stats_helpers.dart       # Statistics helper functions
    │   ├── srs_mode_toggle.dart    # SRS mode toggle (T-SRS/A-SRS/Hybrid)
    │   ├── srs_mode_toggle_with_hint.dart  # SRS mode toggle with hint
    │   ├── srs_visuals.dart        # SRS visual helpers
    │   ├── timer_bar.dart           # Progress timer
    │   ├── vertical_stage_switch.dart  # Individual stage switch (with lock overlay)
    │   ├── vocab_sort_left_panel.dart  # Vocab sort left panel
    │   ├── word_list_item.dart     # Word list item
    │   ├── word_list_toolbar.dart  # Word list toolbar
    │   └── widgets.dart
    └── ui_constants.dart           # UI constants
```

#### 🃏 Decks Feature (`lib/features/decks/`)

```
lib/features/decks/
└── domain/
    └── deck.dart            # Deck entity model
```

#### 🔔 Push Feature (`lib/features/push/`)

```
lib/features/push/
└── data/
    └── daily_picks_store.dart  # Daily push notifications
```

#### 🏆 Rewards Feature (`lib/features/rewards/`)

```
lib/features/rewards/
└── ui/screens/
    └── rewards_center_screen.dart
```

## 🎨 UI Architecture Highlights

### 🎯 Centralized Theme System

- **`WordsColors` ThemeExtension**: Scalable color management with fallback support
- **`WordsLayout`**: Centralized layout constants for consistent spacing and dimensions
- **`HomeTheme`**: Feature-specific theme constants for colors, spacing, and dimensions
- **`app_theme.dart`**: Main theme configuration with ThemeExtension registration
- **Dynamic color adaptation**: LevelBadge automatically adjusts text color for contrast
- **Consistent spacing**: Standardized gaps and padding throughout the app
- **Single source of truth**: All layout values managed centrally
- **Localization ready**: `HomeStrings` for centralized UI text management

### 🧩 Component Architecture

- **Modular widgets**: Each UI component is self-contained
- **Barrel files**: Clean imports with `widgets.dart`, `cards.dart`, etc.
- **Reusable components**: ProgressBar, RoundIcon, etc. in core

### 📱 Learn Mode UI Structure

```
LearnModeScreen
├── HeaderBar (Back button + CategoryWheel)
├── CardArea (SwipeableWordCard + TimerBar)
├── StageSwitchRow (S0-S5 indicators with S0 lock support)
└── BottomControls (Play/Pause/Reset/Menu)
```

### 🔒 S0 Lock Feature

The S0 (New) stage can be locked to prevent new cards from being added to the learning queue. The lock state is synchronized across Category Screen and Learn Mode Screen:

- **Provider**: `s0LockedProvider` (StateProvider<bool>) in `application/s0_lock_provider.dart`
- **UI Component**: `VerticalStageSwitch` shows lock overlay when `isLocked = true`
- **Visual Feedback**: Locked switch is dimmed (45% opacity) with white lock icon overlay
- **Blink Effect**: S0 briefly glows when unlocked via `StageSwitchRowController.blinkS0Once()`
- **Business Logic**: When locked, new cards should be excluded from learning queue

## 🔧 Key Technical Features

### 🧠 Spaced Repetition System (SRS)

- **Adaptive algorithm**: Adjusts based on user performance
- **Stage progression**: S0 (new) → S1-S5 (mastered)
- **Smart queue management**: Balances new cards with reviews
- **Gate logic**: Prevents overwhelming users with too many new cards
- **S0 Lock**: Option to lock S0 stage to prevent new cards
- **Multiple modes**: S0-S5, S1-S5, Single stage mode
- **Three engines**: T-SRS (Traditional), A-SRS (Adaptive), Hybrid

### 🎯 Mix Feature

- **Custom word collections**: Build personalized word mixes
- **Search integration**: Add words via search
- **Multi-category support**: Combine words from different categories
- **Donut toggle**: Visual selection interface

### ⚡ Quick Sets

- **Quick access**: Fast navigation to predefined word sets
- **My Words**: Words marked by user
- **Favorites**: User's favorite words
- **Known Words**: Words in S1+ stages
- **My Mix**: Custom word collections

### ⏱️ Timer System

- **Visual progress bar**: Shows remaining time
- **Pause/Resume functionality**: User can control learning pace
- **Auto-reset**: Timer resets after each card

### 🎵 Audio & Haptic Feedback

- **SFX Service**: Sound effects for correct/incorrect answers
- **Haptic feedback**: Tactile responses for better UX
- **Fallback system**: Haptic when audio fails

### 🎨 Visual Feedback

- **Swipe animations**: Smooth card transitions
- **Stage indicators**: Visual progress tracking
- **Level badges**: CEFR level display with proper contrast
- **Glow effects**: Visual emphasis for important elements
- **Lock overlay**: White lock icon on locked S0 switch

## 📊 State Management

### 🏪 Riverpod Providers

- **`learnModeControllerProvider`**: Main learning state (NotifierProvider.autoDispose)
- **`categoryDetailControllerProvider`**: Category detail state management
- **`homeControllerProvider`**: Home screen state management (NotifierProvider)
- **`s0LockedProvider`**: S0 lock state (StateProvider<bool>)
- **`levelSelectionProvider`**: Level selection mode (S0-S5, S1-S5, Single)
- **`srsModeControllerProvider`**: SRS mode (T-SRS, A-SRS, Hybrid)
- **Granular selectors**: `currentWordProvider`, `stagesProvider`, `isPlayingProvider`, etc.
- **Auto-dispose**: Automatic cleanup when not needed
- **Modern Riverpod**: Using NotifierProvider instead of StateNotifierProvider
- **Provider separation**: Provider definitions in separate `providers.dart` files

### 🔄 State Flow

1. **User interaction** → Controller method
2. **Business logic** → State update
3. **UI rebuild** → Provider notification
4. **Visual feedback** → User sees changes

## 🗄️ Data Layer

### 🗃️ Supabase Integration

- **Real-time sync**: Live updates across devices
- **RPC functions**: Server-side logic for SRS
- **User progress**: Persistent learning data

### 💾 Local Storage

- **SharedPreferences**: Offline progress tracking
- **Stage persistence**: Local SRS stage data
- **Session management**: Current learning session

## 🚀 Performance Optimizations

### ⚡ Efficient Rebuilds

- **Selective providers**: Only rebuild necessary widgets
- **Memoization**: Expensive calculations cached
- **Lazy loading**: Components loaded on demand

### 🎯 Memory Management

- **Auto-dispose providers**: Automatic cleanup
- **Timer management**: Proper cancellation
- **Image optimization**: Efficient asset loading

## 📱 Platform Support

- **iOS**: Native iOS design patterns
- **Android**: Material Design compliance
- **Responsive**: Adapts to different screen sizes

## 🔧 Development Tools

- **Hot reload**: Fast development iteration
- **Debug logging**: Comprehensive debugging info
- **Error handling**: Graceful failure recovery
- **Type safety**: Full Dart type checking

## 🆕 Recent Updates

### 🎯 Mix & Quick Sets Features (January 2025)

- **Mix Builder Screen**: Create custom word collections
- **Mix Navigation**: Dedicated navigation for mix feature
- **Mix Search**: Search and add words to mixes
- **Mix Donut Toggle**: Visual selection interface
- **Quick Sets**: Fast access to predefined word sets
- **Quick Sets Detail**: Detailed view for quick sets

### 🔒 S0 Lock Feature (January 2025)

- **New Provider**: `s0LockedProvider` for managing S0 lock state
- **UI Enhancement**: Lock overlay on `VerticalStageSwitch` when S0 is locked
- **Visual Feedback**: Dimmed switch (45% opacity) with white lock icon
- **Blink Effect**: S0 briefly glows when unlocked
- **Synchronization**: Lock state shared between Category Screen and Learn Mode Screen
- **Integration**: `StageSwitchRow` and `LevelsCard` support S0 lock functionality

### 🎨 UI Loading & Performance Improvements

- **Stale-While-Revalidate**: Implemented instant render pattern for better perceived performance
- **Loading Condition Fixes**: Fixed unnecessary spinners when data is already available
- **Riverpod Integration**: Replaced local `_CategoryCard` with Riverpod `CategoryCard` in WordHubScreen
- **SWR-Correct Loading**: Category cards now show existing data during revalidation instead of shimmer
- **ListEndFooter Enhancement**: Added `showDone` parameter for intelligent footer display
- **Debug Visibility**: Added debug prints for loading state monitoring
- **Instant Render**: Controllers immediately show cached data, only show spinners when truly empty

### 🏠 Home Feature Refactoring

- **Controller Architecture**: `HomeController` with `NotifierProvider` for state management
- **Service Extraction**: `ShareIngestService` for handling incoming share data
- **Widget Extraction**: `PracticePicker` and `CategoryPopup` as reusable components
- **Provider Separation**: Provider definitions moved to dedicated `providers.dart` files
- **Lifecycle Management**: `WidgetsBindingObserver` for proper app lifecycle handling
- **Presentational Screen**: `HomeScreen` is now fully presentational (no business logic)
- **Theme Centralization**: `HomeTheme` for colors, spacing, and dimensions
- **String Centralization**: `HomeStrings` for UI text and localization preparation
- **Barrel Files**: Clean imports with `application.dart`, `data.dart`, `widgets.dart`, `theme.dart`, and `strings.dart`

### 🎨 Theme System Overhaul

- **ThemeExtension Integration**: `WordsColors` for scalable color management
- **Centralized Layout**: `WordsLayout` class for consistent spacing and dimensions
- **Barrel Files**: Clean imports with `theme.dart` barrel file
- **Fallback Support**: Robust theme handling with graceful degradation

### 🏗️ Architecture Improvements

- **Controller Refactoring**: `CategoryDetailController` and `HomeController` for better state management
- **Component Extraction**: Modular UI components for better maintainability
- **Modern Riverpod**: Migration to `NotifierProvider` for better performance
- **Clean Imports**: Barrel files for simplified dependency management
- **Error Handling**: Improved error handling with silent catch blocks

### 🎯 UI/UX Enhancements

- **Gold Glow Effects**: Updated all main buttons (Categories, Practice, Play) to use gold glow effects
- **Consistent Button Styling**: All buttons now use the same TapFlash system with gold accents
- **Visual Feedback**: Enhanced user feedback with consistent golden glow animations
- **Button Color Unification**: Categories button and Play button now share the same gold color scheme

### 🐛 Bug Fixes

- **Compilation Errors**: Fixed const expression errors in layout constants
- **Wheel Transitions**: Smooth category wheel transitions with proper background opacity
- **State Synchronization**: Improved client-server state synchronization
- **Import Cleanup**: Removed unused imports after widget extraction
- **Loading State Issues**: Fixed unnecessary loading spinners when data is already available

---

_Last updated: January 2025_
_Total files: 140 Dart files_
_Architecture: Feature-based Clean Architecture with Modern Riverpod_
_Theme System: Centralized with ThemeExtension, Layout Constants, and Feature-specific Themes_
_Features: Words (102 files), Home (25 files), Mix, Quick Sets, Vocab Sort_
_Home Feature: Fully refactored with Presentational UI, Centralized Theme & Strings_
_S0 Lock Feature: Lock/unlock S0 stage to prevent new cards in learning queue_
_Mix Feature: Custom word collections with search and multi-category support_
