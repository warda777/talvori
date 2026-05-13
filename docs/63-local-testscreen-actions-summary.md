# 63 Local Testscreen Actions Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den erweiterten Stand des isolierten `LocalLearningTestScreen` mit funktionalen Aktionen zusammen.

Der Screen bleibt eine lokale Debug-/QA-Oberflaeche fuer die Offline-first-Lernkette. Er ist weiterhin nicht in Navigation, App-Start oder bestehende Lern-Flows eingebunden.

## 1. Funktionale Aktionen

Der Testscreen kann aktuell diese Aktionen ausloesen:

- **Starten/Fortsetzen**
- **Richtig**
- **Falsch**
- **Session abschließen**

Die Aktionen sind rein delegierend. Der Screen enthaelt keine eigene SRS-Fachlogik, keine Requeue-Regeln, keine Completion-Regeln und keine direkte Persistenzlogik.

### Starten/Fortsetzen

Der Button **Starten/Fortsetzen** ruft:

- `startOrResume(...)`

Parameter:

- `categoryId` aus dem Screen-Konstruktor
- `LearningMode.adaptive`
- `TrainingArea.all`
- `now` aus `nowProvider` oder `DateTime.now()`

### Richtig

Der Button **Richtig** ruft:

- `submitCorrect(now: now)`

Der Button ist nur aktiv, wenn:

- `contract.canShowSubmitActions == true`

### Falsch

Der Button **Falsch** ruft:

- `submitWrong(now: now)`

Der Button ist nur aktiv, wenn:

- `contract.canShowSubmitActions == true`

### Session Abschliessen

Der Button **Session abschließen** ruft:

- `completeIfFinished(now: now)`

Der Button ist nur sichtbar/aktiv, wenn:

- `contract.isCompleted == false`
- `viewModelState.canCompleteSession == true`

## 2. Umsetzung Der Aktionen

Datei:

- `lib/features/local_learning_debug/ui/local_learning_test_screen.dart`

Die Aktionen sind ueber zwei Pfade umgesetzt.

### Callback-Injection Fuer Widget-Tests

Der Screen bietet optionale Callbacks:

- `onStartOrResume`
- `onSubmitCorrect`
- `onSubmitWrong`
- `onCompleteIfFinished`

Diese Callbacks ermoeglichen Widget-Tests ohne:

- echte Datenbank
- echte Facade
- Repositorys
- Seed-Daten
- Supabase
- Navigation

Die Tests pruefen dadurch nur, ob der Screen beim Button-Tap die richtigen Parameter weitergibt.

### Default-Pfad Ueber LocalLearningController

Wenn kein Callback gesetzt ist, delegiert der Screen an:

- `localLearningControllerProvider.notifier`

Default-Aufrufe:

- `startOrResume(...)`
- `submitCorrect(...)`
- `submitWrong(...)`
- `completeIfFinished(...)`

Damit kann der Screen spaeter in einer bewusst geplanten Debug-Umgebung die lokale Controller-Kette nutzen, ohne selbst Datenbank- oder SRS-Logik zu kennen.

### nowProvider

Der Screen akzeptiert optional:

- `DateTime Function()? nowProvider`

Wenn gesetzt, nutzt der Screen diese Zeit fuer Aktionen. Wenn nicht gesetzt, nutzt er:

- `DateTime.now()`

Das macht Widget-Tests deterministisch und verhindert fragile Zeitvergleiche.

## 3. Weiterhin Dargestellte Zustaende

Der Screen stellt weiterhin diese Zustaende dar:

- Initial
- Active Card
- Loading
- Error
- Completed

### Initial

Zeigt:

- **Noch keine Session**
- **Intensiv lernen**
- **Alles lernen**
- **Starten/Fortsetzen**

### Active Card

Zeigt:

- `term`
- `translation`
- `exampleSentence`, falls vorhanden
- `notes`, falls vorhanden
- Stage-Label, z. B. **Neu**
- Fortschritt als `answeredCount / totalItems`
- **Richtig**
- **Falsch**

### Loading

Zeigt:

- **Lädt...**

### Error

Zeigt:

- **Etwas ist schiefgelaufen**
- technischen `errorMessage`-Wert als Debug-Hinweis, falls vorhanden

### Completed

Zeigt:

- **Session abgeschlossen**
- **Weitere Session starten**

`Weitere Session starten` ist im aktuellen Stand noch nicht funktional verdrahtet.

## 4. Tests

Datei:

- `test/features/local_learning_debug/local_learning_test_screen_test.dart`

Vorhandene Tests:

- `local_learning_test_screen_renders_initial_state`
- `local_learning_test_screen_start_button_calls_start_or_resume`
- `local_learning_test_screen_shows_active_card`
- `local_learning_test_screen_correct_button_calls_submit_correct`
- `local_learning_test_screen_wrong_button_calls_submit_wrong`
- `local_learning_test_screen_buttons_follow_contract_flags`
- `local_learning_test_screen_handles_completed_state`
- `local_learning_test_screen_complete_button_calls_complete_if_finished`
- `local_learning_test_screen_handles_loading_state`
- `local_learning_test_screen_handles_error_state`

### local_learning_test_screen_renders_initial_state

Sichert ab:

- Initialzustand wird angezeigt
- keine Karte wird angezeigt
- **Starten/Fortsetzen** ist sichtbar
- **Richtig** und **Falsch** sind nicht sichtbar

### local_learning_test_screen_start_button_calls_start_or_resume

Sichert ab:

- Button-Tap ruft `onStartOrResume` genau einmal
- `categoryId` kommt aus dem Konstruktor
- `mode == LearningMode.adaptive`
- `trainingArea == TrainingArea.all`
- `now` kommt aus `nowProvider`

### local_learning_test_screen_shows_active_card

Sichert ab:

- aktive Karte wird angezeigt
- Wortdaten werden angezeigt
- Stage S0 wird als **Neu** angezeigt
- Fortschritt wird angezeigt
- **Richtig** und **Falsch** werden angezeigt

### local_learning_test_screen_correct_button_calls_submit_correct

Sichert ab:

- Button-Tap auf **Richtig** ruft `onSubmitCorrect` genau einmal
- `now` kommt aus `nowProvider`
- keine echte Datenbank ist noetig

### local_learning_test_screen_wrong_button_calls_submit_wrong

Sichert ab:

- Button-Tap auf **Falsch** ruft `onSubmitWrong` genau einmal
- `now` kommt aus `nowProvider`
- keine echte Datenbank ist noetig

### local_learning_test_screen_buttons_follow_contract_flags

Sichert ab:

- **Richtig** und **Falsch** sind disabled, wenn `canShowSubmitActions == false`
- **Richtig** und **Falsch** sind enabled, wenn `canShowSubmitActions == true`

### local_learning_test_screen_handles_completed_state

Sichert ab:

- Completed-Zustand zeigt **Session abgeschlossen**
- **Weitere Session starten** wird angezeigt
- keine aktive Karte wird angezeigt
- **Richtig** und **Falsch** werden nicht angezeigt

### local_learning_test_screen_complete_button_calls_complete_if_finished

Sichert ab:

- Button-Tap auf **Session abschließen** ruft `onCompleteIfFinished` genau einmal
- `now` kommt aus `nowProvider`
- Button ist in einem abschliessbaren, aber noch nicht completed Zustand verfuegbar

### local_learning_test_screen_handles_loading_state

Sichert ab:

- Loading-Zustand zeigt **Lädt...**
- keine Submit-Buttons werden angezeigt

### local_learning_test_screen_handles_error_state

Sichert ab:

- Error-Zustand zeigt **Etwas ist schiefgelaufen**
- technischer Debug-Hinweis wird angezeigt, falls vorhanden
- keine Submit-Buttons werden angezeigt

## 5. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine Navigation
- keine App-Flow-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Supabase-Nutzung
- keine Supabase-Entfernung
- kein `WordUserView`
- keine alte `local_word_database.dart`
- keine direkte Repository-Nutzung im Screen
- keine direkte SQLite-Nutzung im Screen
- keine echte Datenbank im Widget-Test
- keine Seed-Daten im Screen
- keine automatische Session beim Rendern

Der Screen ist weiterhin ein isolierter Testscreen.

## 6. Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 105 Tests bestanden
- `flutter test test/features/local_learning_debug/`
  - 10 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Damit waren zuletzt 154 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller, Adapter, ViewModelProvider, ScreenContract und Testscreen gruen.

## 7. Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- Der Screen ist weiterhin ein Debug-/QA-Screen.
- Er ist nicht gestalterisch oder navigationsseitig als Produktoberflaeche fertig.
- Eine sichere Debug-Route oder ein Debug-Menue ist noch nicht geplant und getestet.
- Die `categoryId` muss weiterhin bewusst von aussen uebergeben werden.
- Bestehender `learn_mode_screen.dart` und `LearnModeController` enthalten weiterhin alte UI-, Supabase- und Lernlogik.
- Supabase und lokale SQLite-Schicht laufen weiterhin parallel.
- Eine zu fruehe Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der lokale Aktionsblock ist stabil, aber noch kein produktiver Umschaltpunkt.

## 8. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Testscreen bewusst nicht einhaengen.
2. Testscreen-Aktionsblock als lokalen Meilenstein markieren.
3. Optional eine Debug-Route separat planen:
   - keine produktive Navigation
   - `categoryId` wird bewusst uebergeben
   - keine automatische Seed-Ausfuehrung
4. Alternativ den lokalen Block als abgeschlossen markieren und erst spaeter wieder fuer App-Anbindung aufgreifen.
5. Vor jeder echten Anbindung erneut vollstaendigen lokalen Stabilitaetscheck ausfuehren.
6. Bestehende Word-UI und alte Controller weiterhin unangetastet lassen.

