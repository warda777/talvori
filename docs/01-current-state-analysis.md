# 01 Current State Analysis

Stand: 2026-05-13

## Kurzfazit

Talvori ist eine bestehende Flutter/Dart-App mit einer grundsätzlich erkennbaren Feature-Struktur und Riverpod-basierter MVVM-Nähe. Die Hauptfunktionalität für Wörter, Kategorien, Lernmodus, SRS und UI liegt in `lib/features/words`. Die Architektur ist nicht chaotisch, aber an mehreren Stellen zu stark verdichtet: besonders `learn_mode_controller.dart` und `supabase_word_repository.dart` bündeln sehr viele Verantwortlichkeiten.

Für einen schnellen Launch ist der wichtigste Punkt nicht ein kompletter Neubau, sondern eine kontrollierte Entflechtung:

- UI bleibt möglichst erhalten.
- Datenzugriff wird hinter Repository-/Store-Grenzen stabilisiert.
- SRS-Regeln werden zuerst theoretisch finalisiert.
- Supabase wird erst entfernt, wenn alle Abhängigkeiten inventarisiert und lokal ersetzt sind.

## Projektstruktur

Wichtige oberste Bereiche:

- `lib/main.dart`: App-Start, Supabase-Initialisierung, Debug-Login, ProviderScope.
- `lib/core`: Theme, gemeinsame Services, Events und UI-Bausteine.
- `lib/features/home`: Start-/Profil-/Settings-/Kategorieeinstieg.
- `lib/features/words`: Vokabelkern, Kategorien, Lernmodus, SRS, Repositories, lokale DB-Ansätze und UI.
- `lib/features/onboarding`: Onboarding, aktuell mit technischen SRS-Bezeichnungen.
- `lib/features/rewards`: Rewards UI.
- `lib/features/push`: Daily Picks Store.
- `supabase`: Edge Functions, Migrationen und Diagnose-Skripte.
- `sql`: Datenbank-/Dictionary-SQL.
- `docs`: existierende Diagramme/Screenshots und diese Analyse.
- `test`: sehr wenig Testabdeckung, aktuell nur `widget_test.dart`.

## MVVM-Bewertung

Die App folgt grob einer MVVM-/Feature-Struktur:

- `domain`: einfache Fachmodelle wie `Word` und `Deck`.
- `data`: Repositories, Stores, Datenbankzugriff.
- `application`: Controller, Provider, SRS-/Queue-Logik.
- `ui`: Screens, Widgets, visuelle Bausteine.

Die Trennung ist aber nicht konsequent genug:

- UI importiert teilweise direkt `supabase_word_repository.dart`.
- Controller enthalten sehr viel SRS-, Session-, Queue-, UI-Sync- und Debug-Logik gleichzeitig.
- `supabase_word_repository.dart` enthält Typdefinitionen, RPC-Zugriff, Mapping, Kategorieoperationen, Reviewlogik, Single-Session-Funktionen und Hilfs-APIs.
- SRS-Regeln sind auf Dart, Supabase-RPCs und UI-Kommentare verteilt.
- Es gibt parallel `LearningEngine` und `SrsSystem`; das wirkt wie historisch gewachsene doppelte Modusmodellierung.

Bewertung: Die Architektur ist als Grundlage brauchbar, braucht aber vor der Offline-Umstellung klare Schnittstellen und kleinere Verantwortungsbereiche.

## Wichtige Dateien

### App-Start

- `lib/main.dart`
  - lädt `.env`
  - initialisiert Supabase
  - macht Debug-Auto-Login
  - prüft Supabase-Verbindung

### Datenzugriff

- `lib/features/words/data/supabase_word_repository.dart`
  - zentrale Supabase-Schicht
  - RPC-Aufrufe für Queue, Reviews, Kategorieprogress, Single-Session
  - direkte Tabellenabfragen auf `words`, `categories`, `user_words`, `user_word_srs`, Views
  - sehr groß und fachlich überladen

- `lib/features/words/data/local_word_database.dart`
  - vorhandener `sqflite`-Ansatz
  - aktuell primär `word_progress`, `word_progress_deck_state`, `category_refill_state`
  - noch kein vollständiger Ersatz für Wörter, Kategorien, Sessions, Reviews und Settings

### SRS / Lernlogik

- `lib/features/words/application/learn_mode_controller.dart`
  - extrem großer zentraler Controller
  - enthält Session-/Queue-/Review-/Progress-/Stage-/Hybrid-/A-SRS-Verhalten
  - größter Kandidat für spätere Aufteilung

- `lib/features/words/application/srs_mode_controller.dart`
  - Moduszustand `time`, `adaptive`, `hybrid`
  - enthält Tap/Longpress-Logik für Hybrid

- `lib/features/words/application/srs_config.dart`
  - aktuelle Konfigurationswerte, Tageslimit, Stage-Titel, Intervall-Labels

- `lib/features/words/application/srs_logic.dart`
  - Due-Prüfung, Smart-Card-Order, Popup-Texte
  - enthält technische UI-Begriffe

- `lib/features/words/application/a_srs_bands.dart`
  - Band-/Stage-Verteilung für A-SRS

- `lib/features/words/application/a_srs_refill_engine.dart`
  - lokaler A-SRS-Refill-Ansatz über `LocalWordDatabase`

### UI Lernmodi und Trainingsbereiche

- `lib/features/words/ui/widgets/srs_mode_toggle.dart`
  - Switch zwischen T-SRS/A-SRS
  - Longpress für Hybrid

- `lib/features/words/ui/widgets/srs_mode_toggle_with_hint.dart`
  - zeigt aktuell `Long-press for Hybrid`

- `lib/features/words/ui/widgets/mode_toggle.dart`
  - zusätzlicher alter/alternativer T-SRS/A-SRS Switch über `LearningEngine`

- `lib/features/words/ui/widgets/level_selector_buttons.dart`
  - Trainingsbereiche `AUTO`, `T1-T5/A1-A5/H1-H5`, `SINGLE`

- `lib/features/words/ui/widgets/stage_switch_row.dart`
  - visuelle Stufenanzeige S0-S5 bzw. T/A/H-Prefixe

- `lib/features/words/ui/screens/learn_mode_screen.dart`
  - Lernscreen und Reviewbewegungen

- `lib/features/words/ui/screens/category_detail_screen.dart`
  - Kategorie-Detail, Auswahl von Modus/Trainingsbereich/Start

- `lib/features/onboarding/ui/screens/onboarding_flow_screen.dart`
  - technische Bezeichnungen `T-SRS`, `A-SRS`, `Hybrid`

## Zu große Dateien

Gemessene auffällige Dateigrößen:

- `lib/features/words/application/learn_mode_controller.dart`: ca. 4091 Zeilen
- `lib/features/words/data/supabase_word_repository.dart`: ca. 2593 Zeilen
- `lib/features/words/ui/screens/word_hub_screen.dart`: ca. 1260 Zeilen
- `lib/features/words/ui/widgets/rotary_color_ring.dart`: ca. 1149 Zeilen
- `lib/features/words/ui/widgets/custom_color_picker_dialog.dart`: ca. 1129 Zeilen
- `lib/features/words/application/radial_palette_controller.dart`: ca. 1063 Zeilen
- `lib/features/words/ui/screens/learn_mode_screen.dart`: ca. 1043 Zeilen
- `lib/features/words/ui/widgets/radial_palette_tools.dart`: ca. 971 Zeilen
- `lib/features/words/ui/cards/word_card.dart`: ca. 750 Zeilen

## Mögliche spätere Aufteilung

Keine Codeänderung in diesem Schritt. Sinnvolle spätere Schnitte:

- `learn_mode_controller.dart`
  - `SessionController`
  - `ReviewActionHandler`
  - `QueueCoordinator`
  - `StageProgressUpdater`
  - `ModePolicyAdapter`
  - `LearnModeStateMapper`

- `supabase_word_repository.dart`
  - `WordRepository`
  - `CategoryRepository`
  - `ReviewRepository`
  - `SessionRepository`
  - `ProgressRepository`
  - `IngestRepository`
  - Mapping-Typen in eigene Dateien

- SRS-Fachlogik
  - reine Engine ohne Flutter/Riverpod/UI
  - Queue-Builder
  - Mode-Policies
  - Review-Transition-Regeln
  - Test-Fixtures

- UI
  - Modusauswahl als einfache drei Buttons
  - Trainingsbereichsnamen zentralisieren
  - technische Stage-/Mode-Labels aus Nutzeroberfläche entfernen

## Launch-Risiken aus dem Ist-Zustand

- SRS-Regeln liegen verteilt in Supabase-RPCs, Dart-Controller und UI-Kommentaren.
- Sessions sind aktuell nicht als robuste lokale, manipulationsresistente Einheit modelliert.
- Supabase ist im App-Start und in vielen Feature-Dateien direkt verankert.
- Es gibt kaum automatisierte Tests für SRS, Queue, Sessions und Offline-Verhalten.
- Die UI verwendet technische Begriffe, die normale Nutzer nicht verstehen müssen.
- Große Dateien erschweren gezielte, risikoarme Änderungen.

