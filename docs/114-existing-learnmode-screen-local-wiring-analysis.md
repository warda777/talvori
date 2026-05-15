# 114 Existing LearnMode Screen Local Wiring Analysis

Stand: 2026-05-15

## 1. Aktuell Gelesene Provider Und Controller

`LearnModeScreen` liest direkt oder indirekt mehrere alte Provider aus der bestehenden Supabase-nahen Lernkette.

Direkt im Screen:

- `learnModeControllerProvider`
- `levelSelectionProvider`
- `allowedStagesProvider`
- `srsModeControllerProvider`
- `s0LockedProvider(widget.categoryId)`
- `singleStageProvider`
- `singleSessionCountsProvider`
- `currentWordProvider`

Der Screen haelt ausserdem direkt:

- `late final LearnModeController _controller`

und ruft auf:

- `_controller.init(...)`
- `_controller.setInLearnScreen(...)`
- `_controller.loadWordsForQuickSets(...)`
- `_controller.onSwipeRight()`
- `_controller.onSwipeLeft()`

Indirekt ueber Child-Widgets:

- `HeaderBar` liest `isLoadingProvider`, `categoriesProvider`, `learnModeControllerProvider`
- `CardArea` liest `currentWordProvider`, `isPausedProvider`, `learnModeControllerProvider`, `primaryLanguageProvider`
- `BottomControls` liest `isPlayingProvider`, `learnModeControllerProvider`
- `StageSwitchRow` liest an mehreren Stellen `learnModeControllerProvider`

`learn_mode_state.dart` existiert aktuell nicht als separate Datei. `LearnModeState` ist in `learn_mode_controller.dart` definiert.

Die lokale Kette bietet separat:

- `localLearningControllerProvider`
- `localLearningViewModelProvider`
- `LocalLearningController`
- `LocalLearningViewModelState`
- `LocalLearnModeUiAdapter`
- `LocalLearnModeUiState`

Diese lokale Kette wird vom bestehenden `LearnModeScreen` aktuell nicht gelesen.

## 2. Wirklich Benutzte LearnModeState-Felder Fuer Die Anzeige

Der Screen und seine eingebetteten Widgets nutzen aus `LearnModeState` fuer Anzeige und Interaktion vor allem:

- `loading`
- `categories`
- `selectedCategoryIndex`
- `stages`
- `deckStages`
- `totalWordsInCategory`
- `activeStage`
- `masteredCount`
- `wordQueue`
- `shuffledWordIds`
- `index`
- `showTranslation`
- `running`
- `timerActive`
- `timerPaused`
- `remainingMillis`
- `timeLimit`
- `hybridStageRemainingSec`
- `hybridStageFrozen`
- `hybridSessionStarted`
- `inLearnScreen`
- `cardsSwipedInSession`
- `isSubmitting`
- `emptyQueueHint`
- `showFinalStartButton`
- `finalPassActive`
- `categoryMastered`
- `categoryMasteredRestartReady`

Fuer die reine Kartenanzeige werden besonders gebraucht:

- aktuelles Wort ueber `currentWordProvider`
- `current.text`
- `current.translation`
- `current.level`
- `current.srsStage`
- `current.streak`
- `current.passCount`
- `showTranslation`
- `timerPaused`
- `timerActive`
- `running`
- `isSubmitting`
- `showFinalStartButton`
- `categoryMastered`

Fuer die Stage-/Switch-Anzeige werden besonders gebraucht:

- `stages`
- `deckStages`
- `masteredCount`
- `activeStage`
- `finalPassActive`
- `categoryMastered`
- `categoryMasteredRestartReady`
- `singleSessionCountsProvider`
- `singleStageProvider`
- `allowedStagesProvider`
- `s0LockedProvider`

Die lokale V1-Kette deckt davon heute nur einen kleineren LearnMode-nahen Kern ab:

- Loading/Error
- aktuelle Karte
- Begriff/Uebersetzung/Beispiel/Notizen
- lokale Stage
- Fortschritt
- Submit-Erlaubnis
- Completed-State

Nicht lokal abgebildet sind aktuell:

- alte Kategorie-Wheel-Logik
- alte A-SRS/T-SRS/Hybrid-Switch-Semantik
- Timer-Spiel
- Final Round
- Fireworks/Restart
- alte `passCount`-/`streak`-Semantik
- Supabase-basierte Stage-Counts

## 3. Aktuelle Aktionen Des Screens

### Start

Der Start passiert aktuell automatisch in `initState`:

- nach dem ersten Frame ruft der Screen `_controller.init(categoryId: widget.categoryId, title: widget.title, ...)` auf.

Das ist fuer lokale Offline-first-Anbindung wichtig: Ein lokaler Modus darf nicht unkontrolliert beim Build oder beim normalen alten Flow starten. Lokales `startOrResume` sollte nur in einem klaren lokalen Pfad passieren.

### Swipe / Answer

`CardArea` ruft bei Swipe:

- `onSwipeCommit(true)`
- `onSwipeCommit(false)`
- danach `c.setShowTranslation(false)`

Im Screen fuehrt `_handleSwipeCommit(correct)` dann aus:

- Queue-/Index-Schutz ueber `shuffledWordIds` und `index`
- `isSubmitting`-Gate
- Swipe-Throttling
- SRS-Modus-Auswertung
- `_controller.onSwipeRight()` oder `_controller.onSwipeLeft()`
- Pulse-/PlasmaLink-Updates

### Correct / Wrong

Korrekt/Falsch sind im alten Flow identisch mit Swipe rechts/links:

- `_controller.onSwipeRight()`
- `_controller.onSwipeLeft()`

In der lokalen Kette waeren die Entsprechungen:

- `LocalLearningController.submitCorrect(now: ...)`
- `LocalLearningController.submitWrong(now: ...)`

Diese API passt fachlich, aber nicht strukturell in den alten Screen, weil der alte Screen vorher `WordUserView`, `shuffledWordIds`, `index`, `passCount` und alte Stage-Switch-Effekte erwartet.

### Completion

Alte Completion ist stark A-SRS-/Final-Round-gebunden:

- `showFinalStartButton`
- `startFinalPass()`
- `categoryMastered`
- `categoryMasteredRestartReady`
- `resetAdaptiveCategory()`
- Feuerwerk ueber `FireworksService`

Lokale Completion laeuft anders:

- `LocalLearningController.completeIfFinished(now: ...)`
- `LocalLearnModeUiState.isCompleted`

Diese beiden Completion-Begriffe duerfen nicht gleichgesetzt werden.

### Navigation Zurueck

Back-Navigation laeuft ueber:

- `_handleBackNavigation(context)`
- `LearnNavigationOrigin`
- `QuickSetsDetailScreen`
- `CategoryDetailScreen`
- `Navigator.pop(didReset)`

Diese Navigation ist stark an alte Kategorie-/QuickSets-Flows gekoppelt und sollte im lokalen ersten Schritt nicht umgebaut werden.

## 4. Verwendung Von WordUserView

`WordUserView` wird an mehreren kritischen Stellen verwendet:

- `LearnModeState.wordQueue`
- `currentWordProvider`
- `CardArea`
- `LearnModeScreen` Listener auf `currentWordProvider`
- `_handleSwipeWillStart`
- `_targetStageForIdleCard`
- Controller-Queue-/Deck-/Stage-Berechnungen
- `fetchWordUserViewsByIds(...)`
- Stage-/Dialog-/Wheel-Widgets im alten Bereich

`WordUserView` kommt aus:

- `features/words/data/supabase_word_repository.dart`

Damit ist es kein neutraler UI-Typ, sondern Teil der alten Supabase-nahen Datenkette.

Fuer die lokale Kette sollte kein kuenstliches `WordUserView` erzeugt werden, weil sonst lokale V1-Semantik in alte Felder wie `streak`, `passCount`, `srsStage`, alte Queue-IDs und Supabase-nahe Annahmen gepresst wuerde.

## 5. Rein Visuelle Und Wiederverwendbare Teile

Wiederverwendbar sind vor allem visuelle Bausteine, wenn sie von alten Providern entkoppelt oder mit neutralen Props versorgt werden:

- Grundlayout aus Header, Kartenbereich, Stage-/Progress-Bereich und Bottom Controls
- `SwipeableWordCard` als visuelle Karte
- Teile der Karten-Optik, Glow, Settings-Button und Swipe-Animation
- Button-Stile aus `BottomControls`
- Stage-/Progress-Visuals, sofern sie mit lokalen Counts/Labels gespeist werden
- Plasma-/Pulse-Effekte spaeter optional, wenn lokale Stage-Ziele sauber definiert sind

Nicht sofort wiederverwendbar ohne Entkopplung:

- `CardArea` als Ganzes, weil es `currentWordProvider` und `learnModeControllerProvider` liest
- `BottomControls` als Ganzes, weil es Timer/Reset/FinalRound aus dem alten Controller liest
- `HeaderBar` als Ganzes, weil es alte Kategorien und altes Wheel liest
- `StageSwitchRow` als Ganzes, weil es alte Stage-/Queue-Logik kennt

Der visuelle Kern ist also wiederverwendbar, aber die heutigen Container-Widgets sind nicht controller-neutral.

## 6. Supabase-/Alte-SRS-Kopplung

Stark gekoppelt an Supabase oder alte SRS-Logik sind:

- `LearnModeController`
- `LearnModeState.wordQueue`
- `currentWordProvider`
- `SupabaseWordRepository`
- `WordUserView`
- `categoryProgressProvider`
- `learnedInStage5Provider`
- `SrsSystem.time/adaptive/hybrid` im alten Controller
- Timer-/Hybrid-Budget-Logik
- Final-Round-Logik
- Reset-Logik ueber Supabase/RPC
- Stage-Counts aus alter Progressquelle

Diese Kopplung sitzt nicht nur im Controller, sondern auch in UI-Helfern und Child-Widgets.

Darum ist eine lokale Anbindung durch blosses Austauschen eines Providers nicht realistisch.

## 7. Lokaler Modus Ohne Gesamten LearnModeController-Umbau

Ja, ein lokaler Modus ist moeglich, ohne den gesamten `LearnModeController` umzubauen, aber nicht als einfacher Provider-Swap.

Der sichere Weg ist:

1. Den alten Controller unangetastet lassen.
2. Die echte visuelle LearnMode-UI schrittweise in controller-neutrale Bausteine schneiden.
3. Diese Bausteine einmal vom alten Screen mit `LearnModeState` versorgen.
4. Dieselben Bausteine spaeter von einem lokalen Wrapper mit `LocalLearnModeUiState` versorgen.

Ein direkter lokaler Branch innerhalb von `LearnModeScreen` waere moeglich, haette aber viele kleine Risiken:

- `initState` startet aktuell immer den alten Controller.
- `CardArea`, `HeaderBar`, `BottomControls` lesen alte Provider selbst.
- Swipe-Commit prueft alte Queue-Felder.
- Completion/FinalRound/Timer sind alte Semantik.
- Navigation zurueck ist alte Category-/QuickSets-Logik.

Ohne vorherige Entkopplung muesste ein lokaler Branch an vielen Stellen Bedingungen einbauen. Das waere schnell, aber fragil.

## 8. Strategien

### A) LearnModeScreen Direkt Um Lokalen Branch Erweitern

Beschreibung:

- `LearnModeScreen` bekaeme z. B. einen `localMode`-Parameter.
- In `initState`, `build`, `CardArea`, `BottomControls` und Swipe-Handling wuerden lokale Branches eingebaut.

Vorteile:

- der sichtbare Entry bleibt formal derselbe Screen
- kurzfristig koennte die bestehende Struktur teilweise genutzt werden

Nachteile:

- hohes Risiko, alten Flow zu beruehren
- viele Child-Widgets lesen alte Provider direkt
- viele Bedingungen in einer ohnehin grossen Datei
- alte und lokale Completion-/Stage-/Timer-Semantik wuerden nebeneinander liegen
- schwer testbar

Bewertung:

- nicht als erster Implementierungsschritt empfohlen

### B) Neuer LocalLearnModeController Mit Gleicher/Aehnlicher API

Beschreibung:

- ein lokaler Controller wuerde Methoden und Felder bereitstellen, die dem alten `LearnModeController` aehneln.

Vorteile:

- koennte die UI-Integration erleichtern
- lokale Aktionen haetten eine vertraute Form

Nachteile:

- wenn die API zu aehnlich wird, entsteht Druck, `WordUserView`, `passCount`, `shuffledWordIds` und alte Stage-Logik nachzubauen
- Gefahr eines zweiten alten Controllers mit anderer Datenquelle
- echte UI-Wiederverwendung bleibt blockiert, solange Widgets alte Provider direkt lesen

Bewertung:

- als spaetere Facade denkbar, aber nicht als erster Schritt

### C) LearnModeScreen In Wiederverwendbare UI-Komponenten Aufteilen

Beschreibung:

- zuerst werden kleine, visuelle Teile controller-neutral gemacht.
- Beispiel: ein Kartenbereich, der nur Props bekommt:
  - `frontText`
  - `backText`
  - `stageLabel`
  - `progressLabel`
  - `canSubmitAnswer`
  - `onCorrect`
  - `onWrong`
  - `onFlip`
- Der alte `LearnModeScreen` kann diese Komponente weiterhin mit alten Daten fuettern.
- Ein lokaler Wrapper kann dieselbe Komponente mit `LocalLearnModeUiState` fuettern.

Vorteile:

- echte bestehende UI wird schrittweise wiederverwendet
- alter Controller bleibt unangetastet
- lokale Kette bleibt sauber
- kleine Tests pro Baustein moeglich
- rueckbaubar

Nachteile:

- braucht einen bewusst geplanten UI-Schnitt
- nicht alles ist sofort wiederverwendbar
- kurzfristig existieren alter Screen und lokaler Wrapper parallel

Bewertung:

- sicherste Strategie, um die echte UI langfristig lokal zu nutzen

### D) Alten Controller Ersetzen

Beschreibung:

- `LearnModeController` wuerde intern auf lokale Offline-first-Services umgestellt.

Vorteile:

- bestehender Screen koennte formal bleiben

Nachteile:

- sehr hohes Regressionsrisiko
- Supabase-Flows wuerden indirekt betroffen
- alte App-Flows, WordHub, CategoryDetail, QuickSets, Timer, Hybrid und FinalRound haengen daran
- schwerer Rueckbau

Bewertung:

- aktuell nicht empfohlen

## 9. Empfehlung

Der schnellste sichere Weg, damit die echte vorhandene UI verwendet wird, ist Strategie C:

1. Keine direkte Aenderung am alten `LearnModeController`.
2. Keine direkte Umstellung von `LearnModeScreen` auf lokale Provider.
3. Zuerst einen kleinen, controller-neutralen visuellen Baustein aus der bestehenden LearnMode-UI identifizieren.
4. Diesen Baustein mit Props statt Provider-Zugriff testbar machen.
5. Alten Screen weiter mit alter Datenquelle betreiben.
6. Lokalen Screen oder Wrapper mit `LocalLearnModeUiState` denselben Baustein nutzen lassen.

Der erste sinnvolle UI-Schnitt ist der Kartenbereich, nicht Header/StageSwitch/BottomControls.

Warum:

- Die Karte ist der wichtigste sichtbare Teil der echten Lern-UI.
- `LocalLearnModeUiState` liefert bereits die noetigen Kerndaten.
- `SwipeableWordCard` ist visuell wertvoll und kann wahrscheinlich mit lokalen Texten wiederverwendet werden.
- Header, Wheel, StageSwitch, Timer und FinalRound sind deutlich staerker an alte App-Flows gekoppelt.

Damit kann die echte UI schrittweise lokal genutzt werden, ohne sofort den gesamten Screen oder Controller umzubauen.

## 10. Kleinster Konkreter Naechster Implementierungsschritt

Der kleinste naechste TDD-Schritt sollte nicht `LearnModeScreen` als Ganzes umbauen.

Empfohlen:

- Einen kleinen controller-neutralen Presenter oder Props-Typ fuer die LearnMode-Karte planen und testen.

Moeglicher Name:

- `LocalLearnModeCardPresenter`
- oder `LearnModeCardUiState`

Erster Test:

- `learnmode_card_presenter_maps_local_active_card`

Erwartung:

- Eingabe: `LocalLearnModeUiState` mit aktiver Karte
- Ausgabe:
  - `frontText`
  - `backText`
  - `stageLabel`
  - `progressLabel`
  - `canSwipe`
  - optional `exampleSentence`
  - optional `notes`

Danach waere der naechste UI-Schritt:

- einen kleinen wiederverwendbaren Karten-View extrahieren oder neu als neutralen Wrapper um `SwipeableWordCard` bauen
- zuerst im lokalen Debug-Bereich testen
- danach erst pruefen, ob `LearnModeScreen` diesen Baustein ebenfalls nutzen kann

Nicht als naechster Schritt empfohlen:

- `LearnModeScreen` direkt um einen lokalen Branch erweitern
- `LearnModeController` ersetzen
- `WordUserView` aus lokalen Daten nachbauen
- alte Supabase-Provider durch lokale Provider ersetzen
- automatischen lokalen Sessionstart beim Screen-Build einfuehren
