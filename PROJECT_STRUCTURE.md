# Talvori - Flutter Vokabel-App Projektstruktur

## 📁 Root-Verzeichnis

```
talvori/
├── 📄 pubspec.yaml                    # Flutter-Projekt-Konfiguration, Dependencies
├── 📄 pubspec.lock                    # Locked Dependencies (automatisch generiert)
├── 📄 analysis_options.yaml           # Dart Linter-Konfiguration
├── 📄 README.md                       # Projekt-Dokumentation
├── 📄 .env                            # Umgebungsvariablen (Supabase Keys, etc.)
├── 📄 .env.example                    # Beispiel für .env Datei
└── 📄 .gitignore                      # Git-Ignore Regeln
```

## 📁 lib/ - Hauptquellcode

```
lib/
├── 📄 main.dart                       # App-Einstiegspunkt, Supabase-Initialisierung
│
├── 📁 core/                           # Kern-Funktionalitäten
│   ├── 📁 events/                     # Event-System
│   │   ├── 📄 events.dart             # Barrel-File für Events
│   │   └── 📄 reset_event.dart        # Globaler Reset-Event für alle Screens
│   │
│   ├── 📁 services/                   # Services und Utilities
│   │   ├── 📄 services.dart           # Barrel-File für Services
│   │   └── 📄 browser_return_service.dart # Browser-Return Handling
│   │
│   ├── 📁 ui/                         # Core UI-Komponenten
│   │   └── 📁 widgets/
│   │       ├── 📄 round_icon.dart     # Wiederverwendbare runde Icon-Buttons
│   │       └── 📄 progress_bar.dart   # Generische Progress-Bar (0..1)
│   │
│   └── 📁 theme/                      # App-Design System
│       └── 📄 app_theme.dart          # Material Design Theme-Konfiguration
│
├── 📁 features/                       # Feature-basierte Architektur
│   │
│   ├── 📁 home/                       # Home-Screen Feature
│   │   └── 📁 ui/
│   │       ├── 📁 screens/
│   │       │   └── 📄 home_screen.dart # Hauptbildschirm der App
│   │       └── 📁 widgets/
│   │
│   ├── 📁 words/                      # Wörter-Feature (Hauptfunktionalität)
│   │   ├── 📁 application/            # Business Logic (Riverpod)
│   │   │   ├── 📄 application.dart    # Barrel-File für Application Layer
│   │   │   ├── 📄 learn_mode_controller.dart # Learn Mode State Management
│   │   │   └── 📄 word_providers.dart # Riverpod Provider für Wörter
│   │   │
│   │   ├── 📁 data/                   # Datenzugriff
│   │   │   ├── 📄 supabase_word_repository.dart # Supabase API Calls
│   │   │   ├── 📄 last_shared_word_provider.dart # SharedPreferences für letztes Wort
│   │   │   └── 📄 word_hub_taxonomy.dart # Kategorie-Taxonomie
│   │   │
│   │   └── 📁 ui/                     # User Interface
│   │       ├── 📁 screens/            # Vollbildschirm-Screens
│   │       │   ├── 📄 word_hub_screen.dart # Kategorie-Übersicht
│   │       │   ├── 📄 category_detail_screen.dart # Kategorie-Details mit Progress
│   │       │   ├── 📄 word_list_screen.dart # Wort-Liste einer Kategorie
│   │       │   ├── 📄 learn_mode_screen.dart # Hauptlern-Screen mit Karten
│   │       │   ├── 📄 category_detail_screen.dart # Kategorie-Details
│   │       │   └── 📄 learn_mode_screen.dart # Lern-Modus mit SRS-Algorithmus
│   │       │
│   │       ├── 📁 cards/              # Karten-spezifische UI-Komponenten
│   │       │   ├── 📄 cards.dart      # Barrel-File für alle Cards
│   │       │   ├── 📄 word_card.dart  # Wiederverwendbare Wort-Karte
│   │       │   ├── 📄 swipeable_word_card.dart # Swipeable Word-Card mit Gestures
│   │       │   ├── 📄 counter_badge.dart # Counter-Badge für Word-Count
│   │       │   ├── 📄 tap_flash.dart  # Tap-Flash Animation-Effekt
│   │       │   └── 📄 glow_sweep_ring.dart # Glow-Sweep Ring Animation
│   │       │
│   │       ├── 📁 widgets/            # Wiederverwendbare UI-Komponenten
│   │       │   ├── 📄 widgets.dart    # Barrel-File für alle Widgets
│   │       │   ├── 📄 reset_button.dart # Hold-to-Confirm Reset-Button
│   │       │   ├── 📄 vertical_stage_switch.dart # SRS Stage Anzeige (S0-S5)
│   │       │   ├── 📄 play_pause_button.dart # Play/Pause Toggle für Timer
│   │       │   ├── 📄 cancel_timer_button.dart # Timer-Cancel Button
│   │       │   ├── 📄 timer_bar.dart  # Timer-Progress-Bar (Feature-Wrapper)
│   │       │   ├── 📄 category_wheel.dart # Kategorie-Auswahl mit Scroll-Animation
│   │       │   └── 📄 level_badge.dart # CEFR Level Badge (A1-C2)
│   │       │
│   │       └── 📄 consts.dart         # UI-Konstanten (Farben, Größen)
│   │
│   ├── 📁 decks/                      # Decks-Feature (für zukünftige Erweiterungen)
│   │   └── 📁 domain/
│   │       └── 📄 deck.dart           # Deck-Datenmodell
│   │
│   ├── 📁 push/                       # Push-Notifications
│   │   └── 📄 push_service.dart       # Push-Notification Service
│   │
│   └── 📁 rewards/                    # Belohnungssystem
│       └── 📄 rewards_service.dart    # Rewards/Badges Service
│
└── 📁 test/                           # Unit & Widget Tests
    └── 📄 widget_test.dart            # Flutter Widget Tests
```

## 📁 supabase/ - Backend-Funktionen

```
supabase/
└── 📁 functions/                      # Supabase Edge Functions
    ├── 📁 ingest_word/                # Wort-Import Funktion
    │   └── 📄 index.ts                # TypeScript Funktion für Wort-Import
    └── 📁 translate-missing/          # Übersetzungs-Funktion
        └── 📄 index.ts                # DeepL Übersetzungs-Service
```

## 📁 assets/ - Statische Ressourcen

```
assets/
├── 📁 icons/                          # SVG-Icons
│   ├── 📄 cellphone_arrow_down_icon.svg
│   ├── 📄 chrome_r.svg
│   ├── 📄 circle-play.svg
│   ├── 📄 crown.svg
│   ├── 📄 go_icon.svg
│   ├── 📄 google-chrome_ring.svg
│   ├── 📄 line_chrome.svg
│   ├── 📄 logos_safari.svg
│   └── 📄 v.svg
│
├── 📁 images/                         # Bilder
│   ├── 📄 placeholder_1.png
│   ├── 📄 placeholder_2.jpg
│   └── 📄 placeholder.jpg
│
└── 📁 sounds/                         # Audio-Dateien
    └── 📄 README.md                   # Sound-Dateien Dokumentation
```

## 📁 android/ - Android-spezifische Dateien

```
android/
├── 📄 build.gradle.kts                # Android Build-Konfiguration
├── 📄 gradle.properties               # Gradle Properties
├── 📄 settings.gradle.kts             # Gradle Settings
├── 📄 local.properties                # Lokale Android-Konfiguration
├── 📄 gradlew                         # Gradle Wrapper (Unix)
├── 📄 gradlew.bat                     # Gradle Wrapper (Windows)
└── 📁 app/
    ├── 📄 build.gradle.kts            # App-spezifische Build-Konfiguration
    └── 📁 src/
        ├── 📁 main/
        │   ├── 📄 AndroidManifest.xml # Android Manifest
        │   └── 📁 kotlin/
        │       └── 📄 MainActivity.kt # Android Main Activity
        ├── 📁 debug/                  # Debug-Konfiguration
        └── 📁 profile/                # Profile-Konfiguration
```

## 📁 ios/ - iOS-spezifische Dateien

```
ios/
├── 📄 Podfile                         # CocoaPods Dependencies
├── 📄 Podfile.lock                    # Locked CocoaPods Dependencies
├── 📁 Flutter/                        # Flutter iOS-Konfiguration
│   ├── 📄 AppFrameworkInfo.plist      # iOS Framework Info
│   ├── 📄 Debug.xcconfig              # Debug-Konfiguration
│   ├── 📄 Release.xcconfig            # Release-Konfiguration
│   └── 📄 Generated.xcconfig          # Generierte Konfiguration
└── 📁 Runner/                         # iOS App-Target
    ├── 📄 AppDelegate.swift           # iOS App Delegate
    ├── 📄 Info.plist                  # iOS App Info
    ├── 📄 Runner-Bridging-Header.h    # Objective-C Bridge
    └── 📁 Assets.xcassets/            # iOS App Icons & Assets
```

## 📁 web/ - Web-spezifische Dateien

```
web/
├── 📄 index.html                      # Web App HTML
├── 📄 manifest.json                   # Web App Manifest
├── 📄 favicon.png                     # Web App Favicon
└── 📁 icons/                          # Web App Icons
    ├── 📄 Icon-192.png
    ├── 📄 Icon-512.png
    ├── 📄 Icon-maskable-192.png
    └── 📄 Icon-maskable-512.png
```

## 📁 build/ - Build-Ausgaben (automatisch generiert)

```
build/
├── 📁 ios/                            # iOS Build-Ausgaben
├── 📁 reports/                        # Build-Reports
└── 📁 native_assets/                  # Native Assets
```

---

## 🏗️ Architektur-Übersicht

### **Feature-basierte Architektur:**

- **`features/`** - Jedes Feature hat eigene Ordner für UI, Data, Application
- **`core/`** - Geteilte Funktionalitäten (Events, Services, Theme)
- **Barrel-Files** - Kurze Import-Pfade (`events.dart`, `services.dart`, `widgets.dart`)

### **State Management:**

- **Riverpod** - Für State Management (`learn_mode_controller.dart`)
- **NotifierProvider** - Moderne Riverpod-Provider
- **SharedPreferences** - Lokale Datenspeicherung

### **Backend:**

- **Supabase** - Backend-as-a-Service
- **Edge Functions** - TypeScript-Funktionen für Backend-Logik
- **PostgreSQL** - Datenbank für Wörter und Kategorien

### **UI-Komponenten:**

- **Modulare Widgets** - Alle UI-Komponenten als separate Dateien
- **Wiederverwendbarkeit** - Widgets können in verschiedenen Screens verwendet werden
- **Konsistentes Design** - Einheitliches Theme-System

---

## 📊 Datei-Statistiken

- **Gesamt:** ~50+ Dart-Dateien
- **UI-Widgets:** 7 ausgelagerte Widget-Komponenten
- **Screens:** 5 Haupt-Screens
- **Services:** 3 Backend-Services
- **Features:** 4 Haupt-Features (words, home, decks, push, rewards)

---

_Generiert am: $(date)_
_Projekt: Talvori - Flutter Vokabel-App_
