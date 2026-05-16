# 120 Local LearnMode Existing UI Rebuild Plan

Stand: 2026-05-16

## 1. Ziel

`LocalLearnModeScreen` soll optisch wie die bestehende Talvori-`LearnModeScreen`-UI wirken, aber weiterhin die lokale Offline-first-Kette verwenden.

Erhalten bzw. nachgebaut werden sollen:

- Wheel-/Header-Gefuehl
- Kategorieanzeige
- Stufen-/Level-Switches
- Kartenbereich
- Fortschrittsanzeige
- Bottom Controls / Action Buttons
- Hintergrund, Abstaende und Farbwelt

Nicht uebernommen werden:

- alte Supabase-Datenquelle
- alter `LearnModeController`
- alter `LearnModeState`
- alte Queue-/Timer-/Hybrid-/FinalRound-Logik

Die lokale Logik bleibt:

- `localLearningViewModelProvider`
- `LocalLearningViewModelState`
- `LocalLearnModeUiAdapter`
- `LocalLearnModeUiState`
- `LearnModeCardPresenter`
- `LearnModeCardView`
- `LocalLearningController`

## 2. Visuelle Bereiche Aus LearnModeScreen

### Header / Wheel / Kategorieanzeige

Der bestehende Screen arbeitet mit einer oberen Kapselstruktur:

- Back-Button
- Kategorie-Wheel
- Vocabs-Tile
- Add-/Settings-Buttons
- feste Hoehen und Abstaende aus `WordsLayout`

Fuer den lokalen Screen ist relevant:

- oben ein klarer Talvori-Header statt Standard-`AppBar`
- Anzeige der aktuellen lokalen Kategorie, z. B. `basics`
- optional statisches Wheel-Gefuehl
- spaeter echte lokale Kategorien-Auswahl

Im ersten Schritt sollte der Header nicht navigations- oder datengetrieben sein. Er darf lokal/statisch sein und nur den aktuellen lokalen Kontext anzeigen.

### Stage- / Level-Switches

Die bestehende UI nutzt:

- `LevelsCard`
- `LevelSelectorButtons`
- `StageSwitchRow`
- vertikale Stage-Switches
- Stage-Farben fuer New/Stage
- Moduslabels wie `AUTO`, `A1-A5`, `SINGLE`

Fuer den lokalen Screen ist relevant:

- visuelle Stufenreihe S0 bis S5
- aktuelle Stage der Karte hervorheben
- optional Fortschritt pro Stage spaeter
- keine alte T-/A-/Hybrid-Umschaltung im ersten lokalen UI-Schritt

Die bestehende Stage-Optik sollte zuerst nachgebaut werden, nicht direkt wiederverwendet werden.

### Kartenbereich

Der Kartenbereich ist bereits lokal vorbereitet:

- `LocalLearnModeUiState`
- `LearnModeCardPresenter`
- `LearnModeCardView`

Er soll weiter in Richtung Produkt-Lernkarte wachsen:

- zentrale Karte
- klare Vorder-/Rueckseiten-Hierarchie
- Meta-Zeile fuer Stage und Fortschritt
- Beispiel und Notizen ruhiger darunter
- keine Swipe-Logik im ersten Rebuild-Schritt

### Fortschrittsanzeige

Der lokale Kern liefert bereits:

- `progressLabel`
- `answeredCount`
- `totalItems`
- `remainingCount` indirekt im ViewModel-State

Fuer die UI reicht zunaechst:

- sichtbares `progressLabel`
- spaeter optional Mini-Progress-Bar
- keine alte Queue-Index-Logik

### Bottom Controls / Buttons

Aktuell lokal vorhanden:

- `Starten/Fortsetzen`
- `Richtig`
- `Falsch`
- `Session abschliessen`

Optisch sollen diese Buttons spaeter naeher an die bestehende LearnMode-Interaktion ruecken.

Wichtig:

- Aktionen bleiben lokale Callback-/Controller-Aufrufe
- kein Swipe-Zwang
- keine alte `onSwipeRight`-/`onSwipeLeft`-Kopplung

### Hintergrund / Abstaende / Farben

Wiederverwendbar als Referenz:

- `WordsColors.surfaceBg`
- `WordsColors.cardBg`
- `WordsLayout.topCapsuleH`
- `WordsLayout.topPadding`
- `WordsLayout.gapBelowTop`
- `WordsLayout.gapAboveBottom`
- `WordsLayout.pageBottomPadding`
- `WordsLayout.levelsCardH`
- `WordsLayout.switchGap`

Der lokale Screen sollte diese Konstanten als Orientierung nutzen, aber keine alte Screen-Struktur blind kopieren.

## 3. Direkt Wiederverwendbare Bestehende Widgets

### `CategoryHeaderCapsule`

Bewertung: teilweise wiederverwendbar, aber nicht als erster Schritt.

Vorteile:

- kapselartiger Header entspricht bestehendem Design
- nutzt `WordsLayout`
- liest selbst keine Riverpod-Provider
- bekommt Daten und Callbacks per Props

Risiken:

- erwartet Kategorie-Wheel, Vocabs, Add, Settings und mehrere Actions
- kann fuer lokalen Lernmodus zu gross oder zu produktnah wirken
- Back/Vocabs/Add/Settings haetten im lokalen Debug-Screen noch keine saubere lokale Bedeutung

Empfehlung:

- visuell als Vorlage nutzen
- spaeter eventuell in abgespeckter Form verwenden
- fuer V1 eher `LocalLearnModeHeader` bauen

### `LevelSelectorButtons`

Bewertung: nicht direkt wiederverwendbar.

Vorteile:

- gute Button-Optik fuer Modusauswahl
- bestehende Labels und Glow-Verhalten

Problem:

- liest `srsModeControllerProvider`
- nutzt alte `SrsSystem`-Semantik
- Animationen und Moduswechsel sind an alte Lernlogik gekoppelt

Empfehlung:

- nicht direkt verwenden
- Form, Groessen und visuelle Sprache nachbauen

### `StageSwitchRow`

Bewertung: nicht direkt wiederverwendbar.

Vorteile:

- zentrale Stage-Optik
- Counts, Farben, Labels und Groessen sind teilweise parametrisierbar

Probleme:

- importiert und liest alte Application-Provider
- nutzt `LearnModeState`
- enthaelt Hybrid-Timer-Logik
- enthaelt Stage-Drop-/Pulse-/Blink-Verhalten
- kann alte Semantik in den lokalen Screen ziehen

Empfehlung:

- nicht direkt im lokalen Screen verwenden
- einen neutralen `LocalStageSwitchPanel` planen

### `LevelsCard`

Bewertung: nicht direkt wiederverwendbar.

Vorteile:

- entspricht dem bestehenden Layout der Stage-/Level-Fläche
- kombiniert Mode Buttons, Stage Switches und Startbereich

Probleme:

- ist ein `ConsumerStatefulWidget`
- liest `srsModeControllerProvider`
- liest `s0LockedProvider`
- verwendet `StageWordsDialog`
- kennt alte SRS-/Popup-/Lock-Semantik

Empfehlung:

- nicht uebernehmen
- als Layoutreferenz fuer `LocalStageSwitchPanel` und lokale Bottom-Actions nutzen

### Theme- / Layout-Konstanten

Bewertung: direkt wiederverwendbar.

Sinnvoll:

- `WordsColors`
- `WordsLayout`

Beide sind visuell und nicht an alte Lernlogik gekoppelt.

## 4. Nicht Direkt Wiederverwendbare Widgets

Nicht direkt wiederverwendbar sind Widgets, die alte Provider, Controller oder alte SRS-Zustaende lesen:

- `LearnModeScreen`
- `LevelsCard`
- `StageSwitchRow`
- `LevelSelectorButtons`
- alte `CardArea`-/Bottom-Control-Strukturen, falls sie `currentWordProvider`, `LearnModeController` oder `WordUserView` erwarten

Grund:

- sie ziehen alte Supabase-nahe Datenmodelle mit
- sie erwarten `LearnModeState`
- sie koppeln Optik mit alter Queue-/Timer-/Hybrid-/FinalRound-Logik
- sie koennen automatische oder implizite alte Aktionen ausloesen

## 5. Noetige Lokale Neutrale Ersatz-Widgets

### `LocalLearnModeHeader`

Aufgabe:

- lokaler Header im LearnMode-Stil
- zeigt Kategorie/Modus-Kontext
- optional statisches Wheel-Gefuehl
- keine Kategorieabfrage
- keine Navigation ausser optionalem Back-Callback von aussen

Eingabe:

- `categoryId`
- optional `categoryLabel`
- optional `modeLabel`, z. B. `Adaptive`

### `LocalStageSwitchPanel`

Aufgabe:

- lokale S0-S5-Anzeige im Stil der Stage-Switches
- zeigt aktuelle Stage
- spaeter lokale Counts
- keine Hybrid-Timer
- keine StageWordsDialoge
- keine alten Provider

Eingabe:

- `currentStage`
- optional `stageCounts`
- optional `selectedStage`

### `LocalProgressStageView`

Aufgabe:

- kleine Fortschritts-/Stage-Zusammenfassung
- kann `progressLabel` und Stage anzeigen
- kann im Header, in der Stage-Zone oder in der Card-Meta-Zeile eingesetzt werden

Eingabe:

- `progressLabel`
- `stageLabel`
- optional `isCompleted`

### `LocalLearnModeCardView`

Aktuell entspricht diese Rolle:

- `LearnModeCardView`

Naechste Entwicklung:

- weiter optisch an Karte aus Produkt-UI angleichen
- weiterhin nur `LearnModeCardPresenterState`
- keine Provider

### `LocalLearnModeBottomActions`

Aufgabe:

- lokale Start-/Correct-/Wrong-/Complete-Aktionen visuell vereinheitlichen
- erhaelt nur Callbacks
- keine Controller direkt lesen, falls moeglich

Eingabe:

- `canStartOrResume`
- `canSubmitAnswer`
- `isCompleted`
- `onStartOrResume`
- `onCorrect`
- `onWrong`
- `onCompleteIfFinished`

## 6. Lokale Datenquelle Je UI-Element

### Screen-Grundlayout

Quelle:

- `LocalLearningViewModelState`
- `LocalLearnModeUiState`

Nutzen:

- Loading
- Error
- Empty
- Active Card
- Completed

### Header

Quelle:

- `categoryId` aus `LocalLearnModeScreen`
- spaeter lokale Kategorie-Metadaten, wenn ein Provider dafuer existiert

V1:

- statische Anzeige aus `categoryId`

### Stage-/Level-Panel

Quelle:

- `LocalLearnModeUiState.currentStage`
- spaeter lokale StageCounts aus Repository/ViewModel-Erweiterung

V1:

- aktuelle Stage markieren
- alle S0-S5 statisch anzeigen

### Karte

Quelle:

- `LocalLearnModeUiState`
- `LearnModeCardPresenterState`

Nutzen:

- `frontText`
- `backText`
- `exampleSentence`
- `notes`
- `stageLabel`
- `progressLabel`
- `canSubmitAnswer`

### Bottom Actions

Quelle:

- `LocalLearnModeUiState`
- lokale Callbacks aus `LocalLearnModeScreen`

Nutzen:

- Starten/Fortsetzen
- Richtig/Falsch
- Session abschliessen

## 7. Zunaechst Nur Optische Funktionen

Diese Funktionen duerfen im ersten UI-Rebuild nur optisch sein:

- Wheel
  - zuerst statische Kategorieanzeige oder statisches Wheel-Gefuehl
  - keine echte Kategorieauswahl
  - kein Import
  - keine Session beim Wechsel

- Stufen-Switches
  - zuerst reine Anzeige S0-S5
  - aktuelle Stage hervorheben
  - keine Stage-Auswahl
  - keine Stage-Drop-Interaktion
  - keine Timer-/Hybrid-Anzeige

- Progress
  - zuerst nur `progressLabel`
  - keine alte Queue-Laenge
  - keine FinalRound-Anzeige

- Buttons
  - bestehende lokale Aktionen behalten
  - kein Swipe
  - keine automatische Completion

- Animationen
  - erst spaeter
  - keine Plasma-/Pulse-/Fireworks-Logik im ersten Rebuild

## 8. Empfohlene Reihenfolge

1. Screen-Grundlayout wie `LearnModeScreen` vorbereiten
   - `AppBar` im lokalen Screen perspektivisch durch Talvori-naeheres Layout ersetzen
   - Hintergrund aus `WordsColors.surfaceBg`
   - Seitenabstaende und vertikale Struktur an `WordsLayout` orientieren
   - bestehende State-Branches beibehalten

2. Header/Wheel statisch nachbauen
   - neues `LocalLearnModeHeader`
   - zeigt Kategorie und lokalen Lernkontext
   - keine Kategorieauswahl
   - keine alte Navigation

3. Stage-Switches lokal-neutral nachbauen
   - neues `LocalStageSwitchPanel`
   - zeigt S0-S5
   - hebt aktuelle Stage hervor
   - keine Provider
   - keine Hybrid-/Timer-Logik

4. CardView weiter angleichen
   - bestehende `LearnModeCardView` ausbauen
   - Typografie, Groessen, Abstaende und Meta-Zeile weiter naehern
   - API unveraendert lassen

5. Bottom Controls angleichen
   - neues `LocalLearnModeBottomActions` oder lokale Extraktion aus Screen
   - Buttons optisch an Produkt-Buttons annaehern
   - Callbacks unveraendert

6. Animationen spaeter planen
   - erst nach stabiler statischer Struktur
   - nur mit neutralen lokalen State-Feldern
   - keine alte Queue-/Provider-Logik

## 9. Was Nicht Passieren Darf

Weiterhin verboten:

- kein `WordUserView`
- kein `LearnModeController`
- kein `currentWordProvider`
- kein `SupabaseWordRepository`
- kein Supabase
- keine alte Queue-Logik
- keine alte Timer-Logik
- keine alte Hybrid-Logik
- keine alte FinalRound-Logik
- keine automatische Session beim Build
- kein automatischer Import
- keine Produktnavigation
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `word_providers.dart`

## 10. Sinnvolle Spaetere Tests

Moegliche Tests:

- `local_learnmode_screen_uses_existing_layout_structure`
  - prueft Header, Stage-Zone, Card-Zone und Actions als sichtbare Struktur

- `local_header_shows_category_and_mode`
  - prueft lokale Kategorieanzeige
  - prueft statischen lokalen Modus

- `local_stage_panel_shows_s0_to_s5`
  - prueft S0-S5
  - prueft aktuelle Stage-Markierung

- `local_card_still_shows_active_word`
  - prueft Begriff, Uebersetzung, Beispiel, Notizen
  - prueft Stage und Fortschritt

- `local_buttons_still_call_correct_wrong`
  - prueft lokale `Richtig`-/`Falsch`-Callbacks

- `local_learnmode_screen_does_not_start_session_on_build`
  - prueft, dass Build weiterhin keine Session startet

- `local_learnmode_screen_does_not_require_supabase_or_worduserview`
  - schuetzt die lokale Isolation

Keine Pixel-/Layout-Mass-Tests im ersten Schritt. Die Tests sollten sichtbare Struktur und Callback-Verhalten stabil pruefen.

## 11. Erster Konkreter UI-Schritt

Empfehlung:

Als erster konkreter TDD-Schritt sollte ein neutrales `LocalLearnModeHeader` geplant und gebaut werden.

Warum dieser Schritt:

- er bringt den lokalen Screen sofort naeher an die bestehende LearnMode-Optik
- er ist kleiner als Stage-Switches
- er braucht keine lokale StageCounts-Erweiterung
- er muss keine alte Provider-Logik lesen
- er veraendert die lokale Lernlogik nicht

Minimaler Umfang:

- neuer isolierter Header im `local_learning_debug`-Bereich
- Eingaben:
  - `categoryId`
  - optional `title`
  - optional `modeLabel`
- Anzeige:
  - Talvori-nahe obere Flaeche
  - Kategorie-/Titeltext
  - lokaler Modus-Hinweis
- Keine Actions im ersten Schritt oder nur externe optionale Callbacks
- Kein Wheel mit echter Auswahl
- Kein Supabase
- Kein Provider

Danach kann `LocalLearnModeScreen` diesen Header nutzen, waehrend Loading/Error/Empty/Active/Completed und alle lokalen Aktionen unveraendert bleiben.
