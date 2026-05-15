# 110 Local To LearnMode UI Adapter Plan

Stand: 2026-05-15

## 1. Ziel

Ziel ist ein Adapter zwischen der lokalen Offline-first-Lernkette und einer spaeteren Weiterverwendung der bestehenden `LearnModeScreen`-UI.

Der Adapter soll:

- lokale Daten aus `LocalLearningViewModelState` in UI-nahe Felder uebersetzen
- eine klare lokale UI-State-Struktur vorbereiten
- die bestehende visuelle Lernoberflaeche spaeter weiterverwendbar machen
- keine neue Produkt-UI erzwingen
- den alten `LearnModeController` noch nicht umbauen
- `learn_mode_screen.dart` noch nicht anfassen

Der erste Schritt bleibt bewusst UI-neutral.

## 2. Lokale Quelle

Die lokale Quelle ist:

- `LocalLearningViewModelState`
- `localLearningViewModelProvider`
- spaeter fuer Aktionen: `LocalLearningController`

`LocalLearningViewModelState` enthaelt bereits die wichtigsten lokalen Lernfelder:

- `isLoading`
- `errorMessage`
- `hasSession`
- `sessionId`
- `categoryId`
- `mode`
- `trainingArea`
- `status`
- `currentWordId`
- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`
- `canSubmitAnswer`
- `canCompleteSession`
- `lastAction`

`localLearningViewModelProvider` liest nur `localLearningControllerProvider` und mappt dessen State ueber `LocalLearningViewModelAdapter`. Reines Lesen startet keine Session und fuehrt keine Aktion aus.

## 3. Bedarf Der Bestehenden LearnModeScreen-UI

Der bestehende `LearnModeScreen` ist aktuell umfangreich und UI-nah an den alten Lernflow gekoppelt.

Vermutlich benoetigte UI-Daten fuer eine lokale Variante:

- aktuelles Wort / Begriff
- Uebersetzung
- Beispielsatz
- Notizen
- aktuelle Stage
- Fortschritt
- ob eine Antwort abgegeben werden darf
- Completed-State
- Loading-State
- Error-State
- Richtig/Falsch-Aktionen
- Starten/Fortsetzen
- optional Completion-Aktion

Aktuelle lokale Entsprechungen:

- Begriff -> `term`
- Uebersetzung -> `translation`
- Beispielsatz -> `exampleSentence`
- Notizen -> `notes`
- Stage -> `currentStage`
- Fortschritt -> `answeredCount`, `totalItems`, `remainingCount`, `currentPosition`
- Submit erlaubt -> `canSubmitAnswer`
- Completion erlaubt -> `canCompleteSession`
- Loading -> `isLoading`
- Error -> `errorMessage`
- Session vorhanden -> `hasSession`

Ein erster Adapter sollte daraus noch keine Animationen, Timer oder alte Stage-Switch-Logik rekonstruieren.

## 4. Problematische Alte Struktur

### WordUserView

`LearnModeScreen` und die alte Lernkette arbeiten stark mit `WordUserView`.

Problem:

- lokale Daten kommen nicht als `WordUserView`
- `WordUserView` enthaelt alte Supabase- und Progress-Semantik
- kuenstliches Nachbauen koennte alte und neue Logik vermischen

### LearnModeState

`LearnModeState` enthaelt sehr viele alte UI- und Fachfelder:

- `wordQueue`
- `shuffledWordIds`
- `index`
- `stages`
- `deckStages`
- `activeStage`
- Timer-Felder
- Hybrid-Budget-Felder
- Final-Pass-Felder
- alte Submission-Flags

Viele davon sind nicht 1:1 Teil der lokalen V1-Kette.

### Alte Queue

Die alte Queue sitzt im `LearnModeController` und arbeitet mit `WordUserView`, Shuffle-IDs, Index und alten Refill-Regeln.

Die lokale Queue liegt dagegen in:

- `learning_sessions`
- `session_items`
- `LocalLearningSessionFacade`
- `LocalSessionReadState`

### SupabaseWordRepository

Der alte Controller nutzt `SupabaseWordRepository` und damit Supabase-nahe Datenmodelle.

Dieser Pfad soll nicht nebenbei entfernt oder ersetzt werden.

### Alte Stage-/PassCount-Logik

Die bestehende UI und Controller-Logik verwenden alte Stage-, PassCount-, A-SRS/T-SRS/Hybrid- und Timer-Semantik.

Die lokale V1-Kette verwendet dagegen:

- `SrsStage`
- `LearningMode`
- `TrainingArea`
- lokale Progress-Regeln
- lokale Session-Items

Diese Semantiken duerfen nicht unkontrolliert zusammengefuehrt werden.

## 5. Adapter-Strategien

### A) LocalLearningViewModelState Direkt In LearnModeScreen Verwenden

Beschreibung:

- `LearnModeScreen` wuerde direkt `localLearningViewModelProvider` lesen.

Vorteile:

- wenig neue Zwischenschicht
- schnelle direkte Datenanbindung

Nachteile:

- `learn_mode_screen.dart` ist gross und stark an alte Provider gekoppelt
- direkte Nutzung wuerde schnell UI- und Datenlogik vermischen
- schwer testbar, solange alter Screen unveraendert bleibt

Bewertung:

- nicht als naechster Schritt geeignet

### B) LocalLearningViewModelState In Neue Lokale UI-State-Struktur Mappen

Beschreibung:

- eigener UI-neutraler Adapter
- Eingabe: `LocalLearningViewModelState`
- Ausgabe: z. B. `LocalLearnModeUiState`

Vorteile:

- keine UI-Dateien noetig
- sehr gut testbar
- klare Grenze zwischen lokaler Lernkette und spaeterer UI
- kein `WordUserView`-Fake
- rueckbaubar

Nachteile:

- eine zusaetzliche kleine Struktur
- spaetere LearnModeScreen-Anbindung bleibt separat zu planen

Bewertung:

- sicherste Strategie fuer den naechsten Schritt

### C) WordUserView Kuenstlich Aus Lokalen Daten Nachbauen

Beschreibung:

- lokale Daten wuerden in ein altes `WordUserView`-aehnliches Modell gepresst.

Vorteile:

- bestehende UI koennte kurzfristig mehr Felder wiederverwenden

Nachteile:

- hohe Semantik-Gefahr
- Supabase-nahe Struktur wuerde in lokale Kette hineinragen
- alte Progress- und Stage-Felder koennten falsch interpretiert werden

Bewertung:

- nicht empfohlen

### D) LearnModeController Direkt Umbauen

Beschreibung:

- alter Controller wuerde direkt auf lokale Kette umgestellt.

Vorteile:

- bestehender Screen koennte formal erhalten bleiben

Nachteile:

- hohes Regressionsrisiko
- alte Supabase-, Queue-, Timer- und Stage-Logik stark verwoben
- schwerer Rueckbau
- viele bestehende App-Flows betroffen

Bewertung:

- nicht als naechster Schritt geeignet

## 6. Empfehlung

Empfohlen ist Strategie B:

- `LocalLearningViewModelState` in eine neue lokale UI-State-Struktur mappen
- noch keine Aenderung an `LearnModeScreen`
- noch keine Aenderung an `LearnModeController`
- keine Nutzung von `WordUserView`
- keine Supabase-Entfernung

Diese Strategie schafft eine schmale, testbare Bruecke zwischen lokaler Lernkette und spaeterer UI-Anbindung.

## 7. Erster LocalLearnModeUiState

Ein erster `LocalLearnModeUiState` sollte klein bleiben.

Sinnvolle Felder:

- `isLoading`
- `errorMessage`
- `hasCard`
- `term`
- `translation`
- `exampleSentence`
- `notes`
- `currentStage`
- `progressLabel`
- `canSubmitAnswer`
- `isCompleted`

Moegliche Ableitungen:

- `hasCard == currentWordId != null && term != null`
- `progressLabel == "$answeredCount / $totalItems"`
- `isCompleted == hasSession && remainingCount == 0`

Wichtig:

- keine alten Stage-Counts erzeugen
- keine alte Queue rekonstruieren
- kein `WordUserView` erzeugen
- keine UI-Texte ueberfrachten
- keine Aktionen ausfuehren

## 8. Spaetere Aktionen

Fuer eine spaetere lokale LearnMode-UI waeren diese Aktionen noetig:

- `startOrResume`
- `submitCorrect`
- `submitWrong`
- `completeIfFinished`

Quelle dafuer waere:

- `LocalLearningController`
- oder eine schmale lokale Action-Fassade fuer den Screen

Der UI-State-Adapter selbst darf diese Aktionen nicht ausfuehren.

## 9. Was Nicht Passieren Darf

Nicht erlaubt:

- kein Umbau von `LearnModeController`
- kein Umbau von `LearnModeScreen`
- kein Entfernen von Supabase
- kein `WordUserView`-Fake ohne klare Grenze
- keine automatische Session beim Screen-Build
- kein Import beim Screen-Build
- keine Aenderung an bestehenden App-Flows
- keine Produktnavigation
- keine Vermischung lokaler und alter Progress-Semantik

Der Adapter ist nur ein vorbereitender Mapping-Baustein.

## 10. Sinnvolle Tests

Sinnvolle spaetere Tests:

- `local_learnmode_ui_adapter_maps_active_card`
  - prueft Begriff, Uebersetzung, Beispiel, Notizen, Stage und Submit-Flag

- `local_learnmode_ui_adapter_maps_completed_state`
  - prueft Completed-Ableitung aus lokalen Countern/Flags

- `local_learnmode_ui_adapter_maps_loading_and_error`
  - prueft Loading und Fehlertext

- `local_learnmode_ui_adapter_does_not_require_supabase_or_worduserview`
  - prueft, dass nur lokale Modelle noetig sind

Weitere spaetere Tests:

- `local_learnmode_ui_adapter_maps_empty_state`
- `local_learnmode_ui_adapter_maps_progress_label`
- `local_learnmode_ui_adapter_does_not_start_session`

## 11. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Neue UI-neutrale Adapter-Datei anlegen, z. B.:
   - `lib/core/local_database/adapters/local_learn_mode_ui_adapter.dart`
2. Neue State-Datei oder gleiche Datei mit State-Klasse:
   - `LocalLearnModeUiState`
3. Ersten Test schreiben:
   - `local_learnmode_ui_adapter_maps_active_card`
4. Eingabe:
   - ein `LocalLearningViewModelState` mit aktivem Wort
5. Erwartung:
   - `hasCard == true`
   - `term`, `translation`, `exampleSentence`, `notes` werden uebernommen
   - `currentStage` wird uebernommen
   - `progressLabel` wird korrekt abgeleitet
   - `canSubmitAnswer` wird uebernommen

Noch nicht:

- keine Provider-Anbindung
- keine UI-Anbindung
- kein `LearnModeScreen`-Umbau
- kein `LearnModeController`-Umbau
- keine Supabase-Aenderung
