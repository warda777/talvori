# 📋 Programmliste - Aktualisierte Übersicht

> **Letzte Aktualisierung:** 29. Januar 2025  
> **Version:** 1.6  
> **Status:** ✅ Aktualisiert

## 📊 Projekt-Statistiken

- **Total Dart Files**: 212
- **Words Feature**: 138 Dateien
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

#### 📚 Words (138 Dateien)

- **Application**:
  - Controllers: LearnMode, Category, WordList, CategoryDetail
  - Mix Feature: Navigation, Search, Selection Controllers
  - Sort Feature: VocabSortController
  - Providers: S0Lock, LearningEngine, LevelSelection, SRSMode, CardGlowSettings, PrimaryLanguage
  - SRS: Config, Logic, SrsPopupText (Dialog-Helper)
- **Data**:
  - SupabaseWordRepository (Komplette RPC-Integration, fetchWordsByStage)
  - CategoryRepository
  - WordHubTaxonomy (8 Sections: Life, People, Society, Nature, Action, Culture, Language, Levels)
- **Domain**: Word, SRSKind
- **Services**: SFXService
- **UI**:
  - Screens: LearnMode, CategoryDetail, WordHub, WordList, MixBuilder, QuickSets, MyWords, VocabSort
  - Cards: SwipeableWordCard (mit animiertem Glow-Effekt, Slider-Steuerung), WordCard
  - Widgets: 63+ Widgets (StageWordsDialog, CategorySettingsDialog, Controls, Indicators, Badges, PlasmaLinkPainter, CardGlowPainter, SwitchPulsePainter, etc.)

#### 🃏 Decks (1 Datei)

- Deck Domain Model

#### 🔔 Push (1 Datei)

- DailyPicksStore

#### 🏆 Rewards (1 Datei)

- RewardsCenterScreen

## 🎯 Haupt-Features

### Spaced Repetition System (SRS)

- **Stufen**: Modusabhängige Bezeichnungen
  - T-SRS: T0 (Neu) → T1-T5 (Gelernt)
  - A-SRS: A0 (Neu) → A1-A5 (Gelernt)
  - Hybrid: H0 (Neu) → H1-H5 (Gelernt)
- **Modi**: AUTO (T0-T5/A0-A5/H0-H5), T1-T5/A1-A5/H1-H5, SINGLE Stage
- **Engines**: T-SRS, A-SRS, Hybrid
- **S0 Lock**: Optional Sperre für neue Karten (T0/A0/H0)
- **Stage Words Dialog**: 
  - Popup mit allen Wörtern eines Stages
  - Modus-spezifische Erklärungen (T-SRS, A-SRS, Hybrid)
  - Dynamische Stage-Bezeichnungen je nach aktivem Modus (T0-T5, A0-A5, H0-H5)
  - T-SRS Erklärung (2-6-19 System)
  - Aufstieg/Abstieg-Regeln mit modusabhängigen Bezeichnungen
  - Farben & Feedback-Legende
  - Nummerierung (z.B. "1/35") bei jedem Wort
  - Automatisch erscheinender Scrollbar

### Visuelle Feedback-Systeme

- **Card Glow Animation**: 
  - Pulsierender, nebeliger Glow-Effekt um die Karte
  - Mehrschichtige Animation mit Plasma-Link-Farben
  - Dynamische Pulsierung (größer/kleiner werdend)
  - Animierte Partikel-Effekte an Ecken und Kanten
  - **Slider-Steuerung**:
    - Glow-Intensitäts-Slider (horizontal): Von komplett aus bis sehr stark
    - Pulsierungsgeschwindigkeit-Slider (horizontal): Von statisch bis sehr schnell
    - SVG-Icons: `low_sun-line.svg` / `bright_sun-line.svg` (Glow), `Icons.remove` / `impulse.svg` (Pulsierung)
    - Präzise Icon-Positionierung mit `Transform.translate` für symmetrischen Abstand
    - Persistente Einstellungen via `CardGlowSettingsProvider` (SharedPreferences)
    - Slider nur auf der Vorderseite der Karte sichtbar
  
- **Plasma Link Animation**:
  - Verbindet Karte mit Ziel-Stage-Switch während Drag-Geste
  - Mehrere animierte Fäden zwischen Karten-Unterkante (10% Breite) und Switch-Oberkante
  - Bündelung in der Mitte für organischen Look
  - Dynamische Kurven mit tangentialen Übergängen, größerer Bogen nach oben
  - Wandering Wave: Radien bewegen sich entlang der Länge des Links
  - Erscheint erst nach Karten-Animation (500ms Delay)
  - Verschwindet beim Drag, erscheint wieder wenn Karte zurückkommt
  - Halbierte Animationsgeschwindigkeit für ruhigere Bewegung
  - Funktioniert auch im SINGLE-Modus (zeigt auf SRC-Switch)
  
- **Switch Pulse Animation**:
  - Corona-Effekt um Ziel-Stage-Switch bei erfolgreichem Swipe
  - Expandierender, pulsierender Glow (2 Sekunden Dauer)
  - Mehrschichtige Animation für Tiefe
  - Funktioniert auch im SINGLE-Modus (zeigt Bounce auf SRC, R1 oder R2)

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
- `fn_user_review_mode`: Review mit SRS-Modus-Unterstützung (time/adaptive/hybrid)
- `fn_user_category_progress`
- `fn_single_session_seed`
- `fn_single_session_counts`
- `fn_single_session_move`
- `fn_single_session_reset`
- `fn_single_session_next`

### Repository Functions

- `fetchWordsByStage()`: Lädt alle Wörter für einen bestimmten Stage einer Kategorie (inkl. Stage 0 mit korrekter Logik)
- `submitReview()`: Erweitert um SRS-Modus-Parameter (time/adaptive/hybrid)

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

## ⚙️ Benutzereinstellungen

### Card Glow Settings
- **Provider**: `CardGlowSettingsProvider` (NotifierProvider)
- **Speicherung**: SharedPreferences (persistent)
- **Einstellungen**:
  - `intensity`: Glow-Intensität (0.0 - 1.0)
  - `pulseSpeed`: Pulsierungsgeschwindigkeit (0.0 - 1.0)
- **Verwendung**: Universell für alle Karten, bleibt erhalten bis geändert

### Primary Language
- **Provider**: `PrimaryLanguageProvider` (NotifierProvider)
- **Speicherung**: SharedPreferences (persistent)
- **Einstellungen**: Englisch oder Deutsch
- **Verwendung**: 
  - Universell für alle Kategorien
  - Bestimmt Vorder- und Rückseite der Karten
  - Nach Swipe wird Karte immer in Primary Language angezeigt
- **UI**: `CategorySettingsDialog` (über Settings-Button in CategoryDetailScreen)

## 📝 Vollständige Code-Dokumentation

Die vollständige Code-Dokumentation mit allen Dateien ist in `Programmliste.md` enthalten (15,088 Zeilen).

---

_Für strukturelle Details siehe: PROJECT_STRUCTURE.md_
_Für Supabase-Architektur siehe: SUPABASE_ARCHITECTURE.md_






