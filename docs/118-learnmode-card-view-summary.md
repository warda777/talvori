# 118 LearnMode Card View Summary

Stand: 2026-05-15

## 1. Aufgabe

`LearnModeCardView` ist ein controller-neutraler Karten-View im lokalen Debug-Bereich.

Er zeigt einen bereits vorbereiteten Karten-State an und ist der erste visuelle Baustein auf dem Weg zur spaeteren Wiederverwendung der echten LearnMode-Karten-UI.

Der View selbst kennt keine Controller, keine Provider und keine Datenquelle.

## 2. Eingabe

Der View nutzt als Eingabe:

- `LearnModeCardPresenterState`

Dieser State wird aktuell durch `LearnModeCardPresenter` erzeugt.

## 3. Darstellung Bei Aktiver Karte

Wenn `hasCard == true`, stellt `LearnModeCardView` aktuell diese Daten dar:

- `frontText`
- `backText`
- `exampleSentence`, falls vorhanden
- `notes`, falls vorhanden
- `stageLabel`, falls vorhanden
- `progressLabel`

Der View zeigt die Felder bewusst schlicht und testbar. Es gibt noch keine Buttons, keine Swipe-Logik und keine Animationen.

## 4. Verhalten Bei hasCard == false

Wenn `hasCard == false`, rendert `LearnModeCardView`:

- `SizedBox.shrink()`

Damit zeigt der View keine aktive Karte und erfindet keine Fallback-Texte.

Der Empty-/No-Session-Zustand bleibt Aufgabe des uebergeordneten Screens, aktuell `LocalLearnModeScreen`.

## 5. Nutzung Im LocalLearnModeScreen

`LocalLearnModeScreen` nutzt den View jetzt fuer aktive Karten ueber diese Kette:

1. `localLearningViewModelProvider`
2. `LocalLearnModeUiAdapter`
3. `LocalLearnModeUiState`
4. `LearnModeCardPresenter`
5. `LearnModeCardView`

Loading, Error, Empty und Completed bleiben weiterhin im `LocalLearnModeScreen`.

Der aktive Kartenbereich wird nicht mehr direkt im Screen aus allen einzelnen UI-State-Feldern gerendert, sondern ueber Presenter und View.

## 6. Tests

Die Tests fuer den View liegen in:

- `test/features/local_learning_debug/learnmode_card_view_test.dart`

Aktuell existieren:

- `learnmode_card_view_shows_active_card`
  - prueft `frontText`
  - prueft `backText`
  - prueft `exampleSentence`
  - prueft `notes`
  - prueft `stageLabel`
  - prueft `progressLabel`

- `learnmode_card_view_hides_card_when_no_card`
  - prueft, dass bei `hasCard == false` keine aktive Karte angezeigt wird
  - prueft, dass keine Fallback-Texte entstehen
  - prueft, dass `progressLabel` im No-Card-Fall nicht angezeigt wird

Die Integration im lokalen Screen wird abgesichert durch:

- `test/features/local_learning_debug/local_learn_mode_screen_test.dart`

Dort existieren weiterhin:

- `local_learnmode_screen_shows_active_card`
- `local_learnmode_screen_handles_loading_error_empty`
- `local_learnmode_screen_handles_completed_state`

## 7. Grenzen

Weiterhin gilt:

- kein Supabase
- kein `WordUserView`
- keine Provider im View
- kein `LearnModeScreen`-Umbau
- kein `LearnModeController`-Umbau
- keine Aktionen
- keine Buttons
- kein Swipe
- keine Animationen
- keine Session-Erzeugung
- kein Import
- keine Navigation
- keine Aenderung bestehender App-Flows

Der View ist weiterhin isoliert im lokalen Debug-Bereich.

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 224 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 9. Naechste Schritte

Sinnvoll:

- `LearnModeCardView` als abgeschlossen markieren
- danach `Correct`-/`Wrong`-Callbacks im View separat planen
- spaeter optische Annaeherung an die bestehende Karten-UI planen
- spaeter pruefen, ob ein neutraler Karten-View in den gemeinsamen Words-UI-Bereich wandern soll

Nicht empfohlen:

- keine direkte Aenderung am bestehenden `LearnModeScreen`
- kein `WordUserView`-Fake
- keine Controller-Zugriffe im View
- keine Supabase-Entfernung nebenbei
- keine Vermischung mit alter Queue-/PassCount-Logik
