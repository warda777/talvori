# Talvori - Flutter App Project Structure

## 📁 Project Overview

- **Total Dart Files**: 65+
- **Architecture**: Feature-based with Clean Architecture principles
- **State Management**: Riverpod (NotifierProvider)
- **Backend**: Supabase
- **UI Framework**: Flutter Material Design
- **Theme System**: Centralized with ThemeExtension

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

#### 🏠 Home Feature (`lib/features/home/`)

```
lib/features/home/
└── ui/
    ├── home_screen.dart      # Main home screen entry point
    ├── screens/              # Home-related screens
    │   ├── category_screen.dart
    │   ├── course_screen.dart
    │   ├── home_screen.dart
    │   ├── profile_screen.dart
    │   └── vocab_screen.dart
    └── widgets/              # Home-specific widgets
        ├── bottom_nav.dart
        ├── counter_badge.dart
        ├── glow_sweep_ring.dart
        ├── progress_pill.dart
        ├── tap_flash.dart
        └── top_bar.dart
```

#### 📚 Words Feature (`lib/features/words/`) - Main Learning Module

```
lib/features/words/
├── application/              # Business logic & state management
│   ├── application.dart     # Barrel file for application layer
│   ├── category_detail_controller.dart  # Category detail state management
│   ├── category_detail_state.dart       # Category detail state model
│   ├── learn_mode_controller.dart  # Main learning controller (NotifierProvider)
│   ├── srs_config.dart      # Spaced Repetition System config
│   ├── srs_logic.dart       # SRS algorithm implementation
│   ├── timer_helpers.dart   # Timer utility functions
│   └── word_providers.dart  # Riverpod providers for words
├── data/                     # Data layer
│   ├── last_shared_word_provider.dart
│   ├── mock_word_repository.dart
│   ├── supabase_word_repository.dart  # Supabase integration
│   ├── word_hub_taxonomy.dart
│   └── words_store.dart
├── domain/                   # Domain models
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
    │   ├── my_words_screen.dart
    │   ├── vocab_sort_screen.dart
    │   ├── word_hub_screen.dart
    │   └── word_list_screen.dart
    └── widgets/             # UI widgets
        ├── widgets.dart     # Barrel file for widgets
        ├── bottom_controls.dart      # Play/Pause/Reset controls
        ├── cancel_timer_button.dart
        ├── card_area.dart           # Card display area
        ├── category_header_capsule.dart  # Category header component
        ├── category_wheel.dart      # Category selector
        ├── glow_circle_button.dart  # Glowing circular button
        ├── glow_rect_tile.dart      # Glowing rectangular tile
        ├── header_bar.dart          # Top navigation bar
        ├── learning_status_panel.dart  # Progress & stats panel
        ├── levels_card.dart         # SRS levels display card
        ├── level_badge.dart         # CEFR level display (A1-C2)
        ├── menu_sheet.dart          # Context menu
        ├── play_pause_button.dart
        ├── progress_ring.dart       # Circular progress indicator
        ├── reset_button.dart        # Hold-to-reset button
        ├── stage_switch_row.dart    # SRS stage indicators
        ├── stats_helpers.dart       # Statistics helper functions
        ├── timer_bar.dart           # Progress timer
        ├── vertical_stage_switch.dart  # Individual stage switch
        └── widgets.dart
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
- **`app_theme.dart`**: Main theme configuration with ThemeExtension registration
- **Dynamic color adaptation**: LevelBadge automatically adjusts text color for contrast
- **Consistent spacing**: Standardized gaps and padding throughout the app
- **Single source of truth**: All layout values managed centrally

### 🧩 Component Architecture

- **Modular widgets**: Each UI component is self-contained
- **Barrel files**: Clean imports with `widgets.dart`, `cards.dart`, etc.
- **Reusable components**: ProgressBar, RoundIcon, etc. in core

### 📱 Learn Mode UI Structure

```
LearnModeScreen
├── HeaderBar (Back button + CategoryWheel)
├── CardArea (SwipeableWordCard + TimerBar)
├── StageSwitchRow (S0-S5 indicators)
└── BottomControls (Play/Pause/Reset/Menu)
```

## 🔧 Key Technical Features

### 🧠 Spaced Repetition System (SRS)

- **Adaptive algorithm**: Adjusts based on user performance
- **Stage progression**: S0 (new) → S1-S5 (mastered)
- **Smart queue management**: Balances new cards with reviews
- **Gate logic**: Prevents overwhelming users with too many new cards

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

## 📊 State Management

### 🏪 Riverpod Providers

- **`learnModeControllerProvider`**: Main learning state (NotifierProvider.autoDispose)
- **`categoryDetailControllerProvider`**: Category detail state management
- **Granular selectors**: `currentWordProvider`, `stagesProvider`, `isPlayingProvider`, etc.
- **Auto-dispose**: Automatic cleanup when not needed
- **Modern Riverpod**: Using NotifierProvider instead of StateNotifierProvider

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

### 🎨 Theme System Overhaul

- **ThemeExtension Integration**: `WordsColors` for scalable color management
- **Centralized Layout**: `WordsLayout` class for consistent spacing and dimensions
- **Barrel Files**: Clean imports with `theme.dart` barrel file
- **Fallback Support**: Robust theme handling with graceful degradation

### 🏗️ Architecture Improvements

- **Controller Refactoring**: `CategoryDetailController` for better state management
- **Component Extraction**: Modular UI components for better maintainability
- **Modern Riverpod**: Migration to `NotifierProvider` for better performance
- **Clean Imports**: Barrel files for simplified dependency management

### 🐛 Bug Fixes

- **Compilation Errors**: Fixed const expression errors in layout constants
- **Wheel Transitions**: Smooth category wheel transitions with proper background opacity
- **State Synchronization**: Improved client-server state synchronization

---

_Last updated: December 2024_
_Total files: 65+ Dart files_
_Architecture: Feature-based Clean Architecture with Modern Riverpod_
_Theme System: Centralized with ThemeExtension and Layout Constants_
