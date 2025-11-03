# 📋 Programmliste - Aktualisierte Übersicht

> **Letzte Aktualisierung:** Januar 2025  
> **Version:** 1.1  
> **Status:** ✅ Aktualisiert

## 📊 Projekt-Statistiken

- **Total Dart Files**: 140
- **Words Feature**: 102 Dateien
- **Home Feature**: 25 Dateien
- **Core**: 5 Dateien

## 📁 Hauptstruktur

### Core Layer

- **Events**: StageTransitionEvent, ResetEvent
- **Services**: BrowserReturnService
- **Theme**: AppTheme mit ThemeExtension
- **UI Widgets**: ProgressBar, RoundIcon

### Features

#### 🏠 Home (25 Dateien)

- **Application**: HomeController, HomeState
- **Data**: ShareIngestService
- **Screens**: Home, Course, Profile, Vocab, Category
- **Widgets**: BottomNav, CategoryPopup, PracticePicker, TopBar

#### 📚 Words (102 Dateien)

- **Application**:
  - Controllers: LearnMode, Category, WordList, CategoryDetail
  - Mix Feature: Navigation, Search, Selection Controllers
  - Sort Feature: VocabSortController
  - Providers: S0Lock, LearningEngine, LevelSelection, SRSMode
  - SRS: Config, Logic
- **Data**:
  - SupabaseWordRepository (Komplette RPC-Integration)
  - CategoryRepository
  - WordHubTaxonomy (8 Sections: Life, People, Society, Nature, Action, Culture, Language, Levels)
- **Domain**: Word, SRSKind
- **Services**: SFXService
- **UI**:
  - Screens: LearnMode, CategoryDetail, WordHub, WordList, MixBuilder, QuickSets, MyWords, VocabSort
  - Cards: SwipeableWordCard, WordCard
  - Widgets: 45+ Widgets (Controls, Indicators, Badges, etc.)

#### 🃏 Decks (1 Datei)

- Deck Domain Model

#### 🔔 Push (1 Datei)

- DailyPicksStore

#### 🏆 Rewards (1 Datei)

- RewardsCenterScreen

## 🎯 Haupt-Features

### Spaced Repetition System (SRS)

- **Stufen**: S0 (Neu) → S1-S5 (Gelernt)
- **Modi**: S0-S5, S1-S5, Single Stage
- **Engines**: T-SRS, A-SRS, Hybrid
- **S0 Lock**: Optional Sperre für neue Karten

### Mix Feature

- Custom Word Collections
- Multi-Category Support
- Search Integration
- Donut Toggle Interface

### Quick Sets

- My Words
- Favorites
- Known Words (S1+)
- My Mix

### Word Hub

- 8 Hauptbereiche
- 40+ Kategorien
- Taxonomie-basierte Navigation

## 🔗 Edge Functions

### ingest_word

- DeepL Integration
- QA-System (Back-Translation)
- Case-insensitive Lookup
- German Noun Capitalization

### translate-missing

- Batch Processing
- Rate Limit Handling
- QA-Option
- Dry-Run Support

## 📊 Supabase Integration

### RPC Functions

- `fn_user_stage_counts`
- `fn_user_workload_today`
- `fn_user_learn_queue_mode`
- `fn_user_review`
- `fn_user_category_progress`
- `fn_single_session_seed`
- `fn_single_session_counts`
- `fn_single_session_move`
- `fn_single_session_reset`
- `fn_single_session_next`

### Views

- `words_view`: Base word queries
- `v_words_with_categories`: Category joins
- `v_words_user`: User flags & metadata

### Tables

- `words`: Haupt-Wörter-Tabelle
- `categories`: Kategorien-Management
- `user_words`: User-Wort-Verknüpfung

## 🎨 Theme System

- **ThemeExtension**: WordsColors, AppTheme
- **Layout**: WordsLayout (zentrale Konstanten)
- **Home Theme**: Feature-spezifische Themes
- **Dynamic Colors**: Kontrast-Anpassung

## 📝 Vollständige Code-Dokumentation

Die vollständige Code-Dokumentation mit allen Dateien ist in `Programmliste.md` enthalten (15,088 Zeilen).

---

_Für strukturelle Details siehe: PROJECT_STRUCTURE.md_
_Für Supabase-Architektur siehe: SUPABASE_ARCHITECTURE.md_
