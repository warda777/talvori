# 22 App Integration Impact Analysis

Stand: 2026-05-13

## Zweck

Dieses Dokument analysiert die bestehende Talvori-App fuer eine spaetere Anbindung der lokalen SRS-/SQLite-Schicht.

Es ist nur Analyse und Planung:

- kein Code
- keine UI-Aenderung
- keine Provider-/ViewModel-Aenderung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung

Grundlage sind:

- `docs/17-dart-srs-engine-implementation-summary.md`
- `docs/21-local-srs-session-service-summary.md`
- aktuelle App-Struktur unter `lib/`

## Kurzfazit

Die neue lokale SRS-/SQLite-Schicht ist technisch isoliert vorhanden, aber die bestehende App nutzt weiterhin ueberwiegend die alte Supabase- und alte SRS-Struktur unter `lib/features/words/`.

Die spaetere Anbindung sollte nicht direkt in der UI beginnen. Der sicherste Weg ist:

1. lokale Datenbank-Oeffnung und Seed-/Importpfad klaeren
2. lokale Word-/Category-Read-Repositories ergaenzen
3. eine Adapter-Schicht zwischen bestehendem `LearnModeController`/UI und `LocalSrsSessionService` planen
4. erst danach einzelne App-Flows kontrolliert umstellen

Die groessten Risikodateien sind:

- `lib/features/words/application/learn_mode_controller.dart`
- `lib/features/words/data/supabase_word_repository.dart`
- `lib/features/words/ui/screens/learn_mode_screen.dart`
- `lib/features/words/ui/screens/category_detail_screen.dart`
- `lib/features/words/ui/widgets/stage_switch_row.dart`
- `lib/features/words/ui/widgets/levels_card.dart`
- `lib/features/words/application/srs_mode_controller.dart`
- `lib/features/words/application/srs_logic.dart`

## 1. Dateien Mit Supabase-Nutzung

### Direkte Supabase-Initialisierung

- `lib/main.dart`
  - importiert `supabase_flutter`
  - initialisiert Supabase
  - fuehrt Debug-Auto-Login aus
  - testet Datenbankverbindung
  - muss spaeter sehr vorsichtig behandelt werden, weil App-Start und Auth betroffen sind

### Supabase-Datenzugriff Fuer Woerter, Kategorien Und SRS

- `lib/features/words/data/supabase_word_repository.dart`
  - zentrale Supabase-Datenquelle fuer Woerter, Kategorien, Progress, Queues, Reviews, RPCs, Edge Functions und SRS-nahe Operationen
  - sehr gross und stark gekoppelt
  - enthaelt alte SRS-Contracts, `submitReview`, Queue-Fetches, `user_word_srs`, `is_mastered`, `pass_count`, `next_due_at`, Stage-Counts und weitere RPCs
  - spaeter wahrscheinlich nicht in einem Schritt ersetzen

- `lib/features/words/application/learn_mode_controller.dart`
  - importiert Supabase und `SupabaseWordRepository`
  - sehr grosser Controller
  - enthaelt Lernqueue, Review-Speicherung, Hybrid-/A-SRS-Pfade, Timer-/Stage-Logik und App-State
  - muss fuer lokale SRS-Anbindung wahrscheinlich ueber einen Adapter entkoppelt werden

- `lib/features/words/application/category_detail_controller.dart`
  - importiert Supabase und `SupabaseWordRepository`
  - laedt/veraendert Kategorie-Details und Progress
  - relevant fuer Startpunkt einer Lernsession

- `lib/features/words/application/word_list_controller.dart`
  - importiert Supabase und `SupabaseWordRepository`
  - nutzt Supabase-Ping und Word-Repository
  - relevant fuer Wortlisten und lokale Wortversorgung

- `lib/features/words/application/word_providers.dart`
  - stellt `supabaseWordRepositoryProvider`
  - erzeugt WordHub-/Repository-Controller
  - wahrscheinlich zentraler Provider-Umschaltpunkt fuer spaetere lokale Datenquelle

- `lib/features/words/application/category_stats_provider.dart`
  - nutzt `supabaseWordRepositoryProvider`
  - liefert Kategorie-Statistiken/Progress
  - spaeter Kandidat fuer lokale Stage-/Progress-Counts

- `lib/features/words/application/quick_sets_providers.dart`
  - nutzt `supabaseWordRepositoryProvider`
  - relevant fuer Quick Sets

- `lib/features/words/application/s0_lock_provider.dart`
  - nutzt Supabase RPCs fuer S0-Lock
  - muss spaeter fachlich neu bewertet werden, weil V1 neue Karten ueber `NewCardPolicyService` und QueueBuilder steuert

- `lib/features/words/application/sort/vocab_sort_controller.dart`
  - nutzt `SupabaseWordRepository`
  - Sortier-/WordHub-nahe Funktion

### Supabase-Nutzung In UI Oder Widgets

- `lib/features/home/ui/screens/home_screen.dart`
  - importiert `supabase_word_repository.dart`
  - [PRÜFEN] genaue Nutzung vor Umbau pruefen

- `lib/features/home/ui/widgets/home_word_wheel.dart`
  - erzeugt oder nutzt `SupabaseWordRepository`
  - [PRÜFEN] kann fuer Home-Vorschau statt Lernsession relevant sein

- `lib/features/words/ui/screens/category_detail_screen.dart`
  - importiert Supabase-Repository und SRS-Mode
  - zeigt Kategorie-Progress und Startoptionen
  - wichtiger spaeterer UI-Integrationspunkt

- `lib/features/words/ui/screens/learn_mode_screen.dart`
  - importiert `WordUserView` aus Supabase-Repository
  - UI ist stark an alte Word-/Stage-Modelle gekoppelt

- `lib/features/words/ui/screens/word_hub_screen.dart`
  - importiert Supabase-Repository
  - nutzt `supabaseId` aus Taxonomie
  - [PRÜFEN] fuer lokale Kategorieversorgung relevant

- `lib/features/words/ui/cards/word_card.dart`
  - importiert Supabase-Repository
  - [PRÜFEN] vermutlich wegen `WordUserView`

- `lib/features/words/ui/widgets/category_card.dart`
  - nutzt `supabaseWordRepositoryProvider`
  - zeigt Stage-/Kategorie-Progress

- `lib/features/words/ui/widgets/learn_mode_stage_words_dialog.dart`
  - importiert Supabase-Repository
  - zeigt Stage-Woerter/Dialogdaten

- `lib/features/words/ui/widgets/stage_words_dialog.dart`
  - importiert Supabase-Repository
  - zeigt Stage-Woerter/Dialogdaten

- `lib/features/words/ui/widgets/sort/word_decision_wheel.dart`
  - importiert Supabase-Repository
  - [PRÜFEN] Sortier-/Word-Entscheidung, nicht zwingend Lernsession

- `lib/features/words/ui/widgets/word_wheel_core.dart`
  - erzeugt `SupabaseWordRepository`
  - [PRÜFEN] Home-/WordHub-Anzeige

### Supabase Oder Supabase-ID In Daten/Kommentaren

- `lib/features/words/data/word_hub_taxonomy.dart`
  - enthaelt `supabaseId`
  - wichtig fuer aktuelle Kategoriezuordnung
  - lokale ID-Strategie muss spaeter mappingfaehig sein

- `lib/features/words/application/category_detail_state.dart`
  - importiert Supabase-Repository
  - [PRÜFEN] wahrscheinlich State-Typen fuer `WordUserView`/Progress

- `lib/features/home/data/share_ingest_service.dart`
  - nutzt Supabase Function fuer Wortimport
  - nicht direkt SRS-Session, aber wichtig fuer Offline-first/Importstrategie

- `lib/features/home/application/home_controller.dart`
  - erzeugt `SupabaseWordRepository`
  - [PRÜFEN] Home-Datenquelle

- `lib/features/home/application/profile_controller.dart`
  - Supabase nur als Kommentar/TODO erkannt
  - [PRÜFEN] wahrscheinlich nicht blockierend

- `lib/features/home/application/settings_controller.dart`
  - Supabase nur als Kommentar/TODO erkannt
  - [PRÜFEN] wahrscheinlich nicht blockierend

- `lib/features/home/application/vocab_controller.dart`
  - Supabase nur als Kommentar/TODO erkannt
  - [PRÜFEN] wahrscheinlich nicht blockierend

- `lib/features/words/data/appearance_prefs_repository.dart`
  - Supabase nur als Kommentar/TODO erkannt
  - [PRÜFEN] nicht direkt relevant fuer lokale SRS-Session

- `lib/features/words/application/mix/mix_groups.dart`
  - Supabase nur als Kommentar/TODO erkannt
  - [PRÜFEN] nicht direkt SRS-kritisch

## 2. Dateien Mit Alter SRS-Logik

### Zentrale Alte SRS-Logik

- `lib/features/words/application/learn_mode_controller.dart`
  - aktuell groesste alte SRS-Schaltzentrale
  - enthaelt Queue-Aufbau, Review-Handling, Stage-Counts, Timer, Hybrid-State, A-SRS-Final-Pass, S0-Handling, Supabase-Persistenz und UI-nahe Animationstrigger
  - ca. 4091 Zeilen
  - spaeter nur in sehr kleinen Schritten anfassen

- `lib/features/words/data/supabase_word_repository.dart`
  - alte SRS-Persistenz und RPC-Schicht
  - enthaelt `submitReview`, `fetchLearnQueueAdaptive`, `fetchLearnQueueForMode`, `fetchWordsForStage`, `enrollFromS0ToS1`, `countLearnedInStage5` und weitere SRS-nahe Methoden
  - ca. 2593 Zeilen
  - sollte spaeter nicht direkt entfernt, sondern schrittweise umgangen werden

- `lib/features/words/application/srs_logic.dart`
  - enthaelt alte Due-Logik, Smart-Queue-Reihenfolge und UI-Texte fuer SRS-Popups
  - importiert `SupabaseWordRepository`
  - widerspricht teilweise der V1-Regelbasis, z. B. alte T-SRS-Intervalle und technische Labels

- `lib/features/words/application/srs_config.dart`
  - enthaelt alte SRS-Konfiguration, Burst-/Ratio-/Stage-Gewichte und UI-Config
  - alte T-SRS-Labels wie 2/6/19/45-90 Tage
  - sollte spaeter gegen neue V1-Regeln abgeglichen werden

- `lib/features/words/application/srs_mode_controller.dart`
  - definiert altes `SrsSystem { time, adaptive, hybrid }`
  - speichert Modus in SharedPreferences
  - enthaelt `tap()`, `toggleTimeAdaptive()` und `longPress()` fuer Hybrid
  - direkter Konflikt mit geplanter UI-Regel: kein Longpress fuer Hybrid, kein Switch zwischen A-SRS/T-SRS

- `lib/features/words/domain/srs_kind.dart`
  - `SrsKind { tSrs, aSrs }`
  - UI-/Visual-Hilfstyp, spaeter wahrscheinlich ersetzbar oder begrenzbar

- `lib/features/words/application/level_selection_provider.dart`
  - definiert `LevelSelectionMode { s0toS5, s1toS5, single }`
  - enthaelt `noSaveProgressProvider`
  - betrifft spaetere Trainingsbereiche `Alle Wörter lernen`, `Wiederholen ohne neue Wörter`, `Gezielt üben`

- `lib/features/words/application/a_srs_bands.dart`
  - alte A-SRS-Band-/Stage-Verteilungslogik
  - [PRÜFEN] wahrscheinlich durch neue QueueBuilder-Regeln obsolet

- `lib/features/words/application/a_srs_refill_engine.dart`
  - nutzt altes `LocalWordDatabase`
  - lokale, aber alte A-SRS-spezifische Refill-Engine
  - [PRÜFEN] nicht mit neuer `lib/core/local_database/`-Schicht vermischen

- `lib/features/words/data/local_word_database.dart`
  - alte lokale DB fuer A-SRS-Mirror/Refill
  - nutzt andere Tabellen und andere Regeln, z. B. `is_mastered`, `streak_in_stage`, `ever_enrolled`, `category_refill_state`
  - darf nicht unkontrolliert mit neuer SQLite-Schicht zusammengefuehrt werden

### UI-Nahe Alte SRS-Logik

- `lib/features/words/ui/screens/learn_mode_screen.dart`
  - enthaelt alte lokale Bounce-/Stage-Vorschau-Logik
  - liest `srsModeControllerProvider`
  - mappt Modi auf `SrsKind`
  - zeigt T/A/H-Prefixe und Stage-Switches
  - ca. 1043 Zeilen, riskant

- `lib/features/words/ui/screens/category_detail_screen.dart`
  - liest SRS-Modus und Kategorie-Progress
  - setzt Hybrid bei Screen-Start teilweise zurueck
  - zeigt Start-/Progressdaten
  - wichtig fuer spaeteres `startOrResumeSession(...)`

- `lib/features/words/ui/widgets/levels_card.dart`
  - nutzt `srsModeControllerProvider`, `srs_logic.dart`, `srs_config.dart`
  - zeigt Stage-/Trainingsbereichslogik
  - reagiert auf S0-Lock und Stage-Taps

- `lib/features/words/ui/widgets/stage_switch_row.dart`
  - Stage-Switches, Drag/Drop, Single-Auswahl, Hybrid-Frozen-Timer
  - enthaelt LongPressDraggable und Tap-Handling
  - UI-Risiko hoch, weil Interaktion komplex ist

- `lib/features/words/ui/widgets/srs_mode_toggle.dart`
  - zeigt `T-SRS`, `A-SRS`, `Hybrid`
  - aktiviert Hybrid per Longpress
  - direkter UI-Konflikt mit geplanter V1-UX

- `lib/features/words/ui/widgets/srs_mode_toggle_with_hint.dart`
  - zeigt Hinweise `Long-press for Hybrid` und `Tap Hybrid to exit`
  - muss spaeter ersetzt werden

- `lib/features/words/ui/widgets/level_selector_buttons.dart`
  - zeigt `AUTO`, `T1-T5/A1-A5/H1-H5`, `SINGLE`
  - betrifft Umbenennung der Trainingsbereiche

- `lib/features/words/ui/widgets/category_detail_hint_bubble.dart`
  - zeigt `T-SRS`, `A-SRS`, `Hybrid` und Stage-Prefixe
  - spaeter UI-Textanpassung noetig

- `lib/features/words/ui/widgets/learn_mode_stage_words_dialog.dart`
  - zeigt Stage-/PassCount-Dialoge
  - [PRÜFEN] Inhalte muessen mit neuer Engine-Regelbasis abgeglichen werden

- `lib/features/words/ui/widgets/stage_words_dialog.dart`
  - zeigt Stage-Woerter und SRS-Erklaerungen
  - [PRÜFEN] UI-Texte an V1-Namen anpassen

## 3. ViewModels, Provider Und Services Fuer Spaetere Umstellung

### Wahrscheinlich Zentrale Umstellung

- `learn_mode_controller.dart`
  - spaeter Hauptkandidat fuer Anbindung an `LocalSrsSessionService`
  - sollte nicht direkt mit SQLite sprechen
  - sollte entweder einen Adapter oder einen neuen lokalen Controller verwenden

- `srs_mode_controller.dart`
  - spaeter Modusauswahl ohne Longpress und ohne A/T-Switch neu planen
  - Mapping von altem `SrsSystem` zu neuem `LearningMode` noetig

- `level_selection_provider.dart`
  - spaeter Mapping von `LevelSelectionMode` zu neuem `TrainingArea`
  - `single` entspricht voraussichtlich `TrainingArea.focused`
  - `s1toS5` entspricht voraussichtlich `TrainingArea.reviewOnly`
  - `s0toS5` entspricht voraussichtlich `TrainingArea.all`

- `word_providers.dart`
  - spaeter Provider-Schicht fuer lokale Repositories/Services
  - aktuell erzeugt `SupabaseWordRepository`

- `category_stats_provider.dart`
  - spaeter lokale Progress-/Stage-Counts statt Supabase-Progress

- `category_detail_controller.dart`
  - spaeter Startpunkt fuer `startOrResumeSession(...)`

- `quick_sets_providers.dart`
  - [PRÜFEN] Quick Sets brauchen spaeter lokale Word-/Category-Quelle

- `word_list_controller.dart`
  - [PRÜFEN] lokale Wortlistenversorgung statt Supabase

- `s0_lock_provider.dart`
  - [PRÜFEN] S0-Lock eventuell entfernen oder in neue New-Card-Policy integrieren

### Bereits Neue Lokale Schicht

- `lib/core/srs/`
  - reine Engine, keine UI-/SQLite-Abhaengigkeit
  - sollte unveraendert bleiben, solange App-Anbindung geplant wird

- `lib/core/local_database/`
  - lokale Schema-/Repository-/Session-Service-Schicht
  - sollte nur ueber eigene Tests erweitert werden

## 4. UI-Stellen Fuer Lernmodi

Aktuelle sichtbare oder UI-nahe Stellen:

- `lib/features/onboarding/ui/screens/onboarding_flow_screen.dart`
  - zeigt `T-SRS`, `A-SRS`, `Hybrid`

- `lib/features/words/ui/widgets/srs_mode_toggle.dart`
  - zeigt `T-SRS`, `A-SRS`, `Hybrid`
  - nutzt Switch und Longpress

- `lib/features/words/ui/widgets/srs_mode_toggle_with_hint.dart`
  - zeigt Longpress-Hinweis fuer Hybrid

- `lib/features/words/ui/screens/category_detail_screen.dart`
  - bindet `SrsModeToggleWithHint` ein
  - liest `srsModeControllerProvider`

- `lib/features/words/ui/screens/quick_sets_detail_screen.dart`
  - bindet `SrsModeToggleWithHint` ein

- `lib/features/words/ui/screens/learn_mode_screen.dart`
  - zeigt Modus-Prefixe T/A/H in Stage-Switches

- `lib/features/words/ui/widgets/levels_card.dart`
  - zeigt Stage-Visuals pro Modus

- `lib/features/words/ui/widgets/category_detail_hint_bubble.dart`
  - textet den aktiven Modus

- `lib/features/words/ui/widgets/srs_visuals.dart`
  - visuelle Zuordnung fuer SRS-Kind

- `lib/features/words/ui/widgets/mode_toggle.dart`
  - alter `LearningEngineToggle` mit `T-SRS`/`A-SRS`
  - [PRÜFEN] ob noch aktiv genutzt wird oder Legacy ist

## 5. T-SRS, A-SRS, Hybrid, Longpress Und Switch-Logik

### T-SRS/A-SRS/Hybrid Begriffe

Hauptstellen:

- `onboarding_flow_screen.dart`
- `srs_mode_toggle.dart`
- `srs_mode_toggle_with_hint.dart`
- `category_detail_hint_bubble.dart`
- `srs_logic.dart`
- `levels_card.dart`
- `stage_switch_row.dart`
- `learn_mode_screen.dart`
- `supabase_word_repository.dart`

Geplante Richtung:

- UI-Begriffe spaeter ersetzen durch nutzerverstaendliche Namen:
  - `Nach Zeitplan`
  - `Intensiv lernen` oder `Freies Lernen`
  - `Ausgewogen lernen`

### Longpress Fuer Hybrid

Aktuelle SRS-relevante Stellen:

- `srs_mode_controller.dart`
  - `longPress()` setzt Hybrid

- `srs_mode_toggle.dart`
  - `onLongPress` ruft `ctrl.longPress()`

- `srs_mode_toggle_with_hint.dart`
  - zeigt `Long-press for Hybrid`

Weitere Longpress-Treffer in Home/Palette/Farbtools sind wahrscheinlich nicht SRS-relevant:

- `home/ui/widgets/top_bar.dart`
- `home/ui/widgets/category_popup.dart`
- `home/ui/widgets/fireball_gesture_wrapper.dart`
- `words/ui/widgets/color_wheel.dart`
- `words/ui/widgets/stage_switch_row.dart`
- `words/ui/widgets/single_mode_switch_row.dart`

[PRÜFEN] Diese Longpresses duerfen nicht pauschal entfernt werden. Nur die Hybrid-Aktivierung per Longpress ist fachlich betroffen.

### Switch Zwischen T-SRS Und A-SRS

Aktuelle relevante Stellen:

- `srs_mode_toggle.dart`
  - visueller Switch zwischen `T-SRS` und `A-SRS`

- `srs_mode_controller.dart`
  - `tap()` und `toggleTimeAdaptive()`

- `mode_toggle.dart`
  - alter `LearningEngineToggle` mit Switch
  - [PRÜFEN] ob noch in UI verwendet

Geplante Richtung:

- spaeter drei einfache Buttons statt Switch/Longpress
- keine technischen Labels in der UI
- alter Controller eventuell intern weiter nutzbar, aber UI-API sollte neu gedacht werden

## 6. Trainingsbereiche S0-S5, S1-S5 Und Single

Aktuelle Stellen:

- `level_selection_provider.dart`
  - `LevelSelectionMode.s0toS5`
  - `LevelSelectionMode.s1toS5`
  - `LevelSelectionMode.single`
  - `allowedStagesProvider`

- `level_selector_buttons.dart`
  - Labels `AUTO`, `T1-T5/A1-A5/H1-H5`, `SINGLE`

- `srs_logic.dart`
  - `SrsPopupRange.s0toS5`, `s1toS5`, `single`
  - technische Beschreibungen wie `AUTO`, `SINGLE`, `T1-T5`

- `levels_card.dart`
  - nutzt Stage-/Range-Auswahl

- `learn_mode_screen.dart`
  - Single-Mode-Switches `SRC`, `R1`, `R2`
  - Stage-Switches S0-S5

- `single_mode_switch_row.dart`
  - Single-Session-Buckets und technische Labels

- `stage_switch_row.dart`
  - Stage-Switches S0-S5 und Auswahl

Geplante fachliche Zuordnung:

- `s0toS5` -> `TrainingArea.all` -> UI: `Alle Wörter lernen` [PRÜFEN Name]
- `s1toS5` -> `TrainingArea.reviewOnly` -> UI: `Wiederholen` oder `Ohne neue Wörter` [PRÜFEN Name]
- `single` -> `TrainingArea.focused` -> UI: `Gezielt üben`

Wichtig:

- `focused` veraendert keinen normalen SRS-Fortschritt.
- Die bestehende `noSaveProgressProvider`-Semantik muss sehr genau mit der neuen Focused-Regel abgeglichen werden. [PRÜFEN]

## 7. Dateien, Die Wahrscheinlich Unveraendert Bleiben Koennen

Wahrscheinlich unveraendert oder nur indirekt betroffen:

- `lib/core/theme/app_theme.dart`
- `lib/core/ui/effects/*`
- `lib/core/ui/widgets/progress_bar.dart`
- `lib/core/ui/widgets/round_icon.dart`
- `lib/features/common/widgets/*`
- `lib/features/decks/domain/deck.dart`
- `lib/features/rewards/ui/screens/rewards_center_screen.dart`
- `lib/features/push/data/daily_picks_store.dart` [PRÜFEN falls Wortdaten genutzt werden]
- `lib/features/home/ui/theme/*`
- viele rein visuelle Home-Widgets ohne Supabase- oder SRS-Treffer
- WordHub-/Palette-/Color-Tools ohne Lernsession-Bezug [PRÜFEN pro Datei]
- neue Schicht `lib/core/srs/`
- neue Schicht `lib/core/local_database/`

Nicht automatisch unveraendert:

- Widgets, die zwar visuell wirken, aber `srsModeControllerProvider`, Stage-Counts, `WordUserView` oder Supabase-Repository importieren.

## 8. Riskante Dateien

### Sehr Hoch

- `learn_mode_controller.dart`
  - extrem lang, zentrale App-Logik, viele Zustandsuebergaenge
  - Gefahr: kleine Aenderungen koennen Queue, UI, Animationen und Persistenz gleichzeitig brechen

- `supabase_word_repository.dart`
  - sehr lang, viele RPCs und Datenmodelle
  - Gefahr: Entfernen oder Teilumbau bricht mehrere Features gleichzeitig

- `learn_mode_screen.dart`
  - UI, Animation, Stage-Switches und alte SRS-Vorschau eng gekoppelt

- `category_detail_screen.dart`
  - Startpunkt fuer Lernmodi, Progress und SRS-Modus

### Hoch

- `stage_switch_row.dart`
  - komplexe Stage-Interaktion, Drag/Drop, Single-Modus, Hybrid-Frozen-Logik

- `levels_card.dart`
  - Trainingsbereiche, Stage-Counts, Startlogik, S0-Lock

- `srs_mode_controller.dart`
  - Modus-State, Persistenz in SharedPreferences, Longpress-Hybrid

- `level_selection_provider.dart`
  - Trainingsbereichs-State, `noSaveProgressProvider`, Single-Stage

- `category_stats_provider.dart`
  - Progress-Quelle fuer Kategorie-UI

- `word_providers.dart`
  - zentrale Provider fuer Repository-Zugriff

### Mittel

- `srs_logic.dart`
  - alte Queue-/Due-/Popup-Logik; wahrscheinlich ersetzbar, aber viele UI-Texte koennen dranhaengen

- `srs_config.dart`
  - alte Zahlen und UI-Erklaerungen, fachlich nicht mehr V1-konform

- `a_srs_refill_engine.dart`
  - lokale Legacy-A-SRS-Engine; nicht mit neuer Engine vermischen

- `local_word_database.dart`
  - lokale Legacy-Datenbank; Namens- und Schema-Konfliktrisiko mit neuer SQLite-Schicht

## 9. Empfohlene Reihenfolge Fuer Spaetere App-Anbindung

1. Keine UI-Aenderung zuerst
   - Zuerst lokale App-Datenbank-Oeffnung und Provider fuer `Database`/Repositories planen.

2. Lokale Word-/Category-Versorgung bauen
   - `CategoryRepository` und `WordRepository` fuer neue SQLite-Schicht ergaenzen.
   - Seed-/Importstrategie klaeren.
   - Ohne lokale Woerter kann `LocalSrsSessionService` nicht appnah genutzt werden.

3. Adapter-Modell definieren
   - Bestehende UI erwartet aktuell `WordUserView`, Stage-Counts und alte Controller-State-Felder.
   - Entweder Adapter von lokalem State zu bestehendem UI-Modell oder neuer lokaler Learn-State planen. [PRÜFEN]

4. Read-only Integration vorbereiten
   - Kategorie-Progress lokal anzeigen, ohne Reviews zu schreiben.
   - Noch keine Supabase-Entfernung.

5. Isolierten lokalen Lernpfad hinter internem Schalter testen
   - Eine Kategorie, ein Modus, ein Trainingsbereich.
   - `startOrResumeSession(...)`
   - `submitAnswer(...)`
   - `completeSessionIfFinished(...)`

6. App-Neustart-Szenario testen
   - Aktive Session starten.
   - App beenden.
   - Dieselbe Session fortsetzen.
   - Keine neue Queue erzeugen.

7. UI-Bezeichnungen separat vereinfachen
   - Technische Begriffe entfernen.
   - Longpress-Hybrid entfernen.
   - Drei Modus-Buttons einfuehren.
   - Trainingsbereiche umbenennen.

8. Alte SRS-Logik isolieren
   - `learn_mode_controller.dart` schrittweise von alter Supabase-Review-Logik trennen.
   - Keine grosse Komplettmigration.

9. Supabase erst spaeter entfernen
   - Erst wenn lokale Woerter, Kategorien, Progress, Sessions und UI-Flows stabil sind.

## 10. Tests Vor Jeder App-Anbindung

Vor jedem Schritt an bestehender App-Anbindung:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`

Vor jedem Schritt, der bestehende `features/words`-Controller oder Provider beruehrt:

- bestehende lokale SRS-/SQLite-Tests
- neue Tests fuer den betroffenen Adapter/Provider
- `flutter analyze` [PRÜFEN aktuell vorhandene Analyze-Baseline]

Vor jeder UI-Anbindung:

- lokale SRS-/SQLite-Tests
- Widget-/Controller-Tests fuer den konkreten Screen oder Controller [PRÜFEN vorhandene Teststruktur]
- manuelle App-Pruefung:
  - Kategorie oeffnen
  - Session starten
  - richtige Antwort
  - falsche Antwort mit Requeue
  - Focused/Gezielt-ueben ohne Progress-Aenderung
  - App-Neustart waehrend aktiver Session
  - Session abschliessen

Vor Supabase-Entfernung:

- `rg "supabase|Supabase|supabase_flutter|SupabaseWordRepository|supabaseWordRepositoryProvider" lib pubspec.yaml`
- lokale Offline-Startpruefung
- alle SRS- und lokale Datenbanktests
- App-Flow-Test fuer Home, Kategorie, Lernen, WordHub und Wortliste

## Offene Pruefpunkte

- [PRÜFEN] Ob `mode_toggle.dart` und `learning_engine_provider.dart` noch aktiv in der UI verwendet werden oder Legacy sind.
- [PRÜFEN] Wie bestehende `WordUserView`-Abhaengigkeiten am besten durch lokale Modelle oder Adapter ersetzt werden.
- [PRÜFEN] Ob `local_word_database.dart` noch produktiv genutzt wird und wie es von der neuen `core/local_database`-Schicht abgegrenzt wird.
- [PRÜFEN] Wie lokale Kategorien/Woerter initial in SQLite gelangen.
- [PRÜFEN] Ob `supabaseId` in `word_hub_taxonomy.dart` fuer lokale Kategoriezuordnung temporaer gemappt werden muss.
- [PRÜFEN] Wie `noSaveProgressProvider` mit `TrainingArea.focused` zusammengefuehrt oder ersetzt wird.
- [PRÜFEN] Welche bestehenden Tests ausserhalb `test/core/` vorhanden sind oder erst erstellt werden muessen.
- [PRÜFEN] Welche UI-Texte zuerst ersetzt werden sollen, ohne Lernlogik gleichzeitig umzubauen.

## Empfehlung

Der naechste sinnvolle Schritt ist noch keine App-Anbindung, sondern eine konkrete Planung fuer:

- lokale Datenbank-Oeffnung im App-Kontext
- lokale `CategoryRepository`/`WordRepository`
- Adapter zwischen bestehender UI-Erwartung und `LocalSrsSessionState`

Erst danach sollte ein sehr kleiner, isolierter App-Integrationsschritt umgesetzt werden.
