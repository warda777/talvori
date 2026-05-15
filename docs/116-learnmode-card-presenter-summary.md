# 116 LearnMode Card Presenter Summary

Stand: 2026-05-15

## 1. Aufgabe

`LearnModeCardPresenter` ist ein controller-neutraler Presenter fuer den Kartenbereich einer spaeter wiederverwendbaren LearnMode-UI.

Er uebersetzt lokale LearnMode-nahe Daten in einen kleinen, rein darstellungsnahen Karten-State.

Der Presenter ist bewusst:

- kein Widget
- kein Provider
- kein Controller
- keine Aktionsebene
- keine Supabase-Bruecke

Er ist der erste kleine Baustein, um die echte LearnMode-Karten-UI spaeter kontrolliert wiederverwenden zu koennen.

## 2. Eingabe

Der Presenter nutzt als Eingabe:

- `LocalLearnModeUiState`

Diese Eingabe kommt aus der lokalen Offline-first-Kette und wird aktuell durch `LocalLearnModeUiAdapter` erzeugt.

Der Presenter liest keine Provider und kennt keine Datenquelle direkt.

## 3. Ausgabe

Der Presenter erzeugt:

- `LearnModeCardPresenterState`

Dieser State ist klein und flach. Er beschreibt nur, was eine spaetere Karten-UI anzeigen oder aktivieren koennte.

## 4. Gemappte Felder

Aktuell mappt `LearnModeCardPresenter`:

- `hasCard`
- `frontText`
- `backText`
- `exampleSentence`
- `notes`
- `stageLabel`
- `progressLabel`
- `canSubmitAnswer`
- `isCompleted`

Mapping-Regeln:

- `hasCard` wird aus `LocalLearnModeUiState.hasCard` uebernommen.
- `frontText` kommt aus `term`.
- `backText` kommt aus `translation`.
- `exampleSentence` wird uebernommen.
- `notes` wird uebernommen.
- `stageLabel` kommt aus `currentStage?.name`, z. B. `s0`.
- `progressLabel` wird uebernommen.
- `canSubmitAnswer` wird uebernommen.
- `isCompleted` wird uebernommen.

Der Presenter erzeugt keine Fallback-Texte.

## 5. Getestete Zustaende

Die Tests liegen in:

- `test/core/local_database/learnmode_card_presenter_test.dart`

Aktuell existieren:

- `learnmode_card_presenter_maps_local_active_card`
  - prueft aktive Karte
  - prueft `frontText`
  - prueft `backText`
  - prueft `exampleSentence`
  - prueft `notes`
  - prueft `stageLabel`
  - prueft `progressLabel`
  - prueft `canSubmitAnswer`
  - prueft `isCompleted == false`

- `learnmode_card_presenter_handles_empty_state`
  - prueft Empty-/No-Card-State
  - prueft, dass keine Karte erzeugt wird
  - prueft, dass keine Fallback-Texte entstehen
  - prueft `canSubmitAnswer == false`

- `learnmode_card_presenter_handles_completed_state`
  - prueft Completed-State
  - prueft `progressLabel`, z. B. `3 / 3`
  - prueft, dass keine aktive Karte entsteht
  - prueft, dass keine Fallback-Texte entstehen

## 6. Keine Alte Abhaengigkeit

Der Presenter verwendet bewusst kein `WordUserView`.

Gruende:

- `WordUserView` gehoert zur alten Supabase-nahen Lernkette.
- Lokale V1-Daten sollen nicht in alte Stage-/PassCount-/Queue-Semantik gepresst werden.
- Der Presenter soll spaeter auch unabhaengig von der alten Produktlogik testbar bleiben.

Der Presenter verwendet ausserdem:

- kein Supabase
- keine Provider
- keinen `LearnModeController`
- keinen `LocalLearningController`
- keine Datenbank

Er ist nur ein reiner Mapper.

## 7. Grenzen

Weiterhin gilt:

- keine UI
- kein `LearnModeScreen`-Umbau
- kein `LearnModeController`-Umbau
- keine Aktion
- keine Provider-Anbindung
- kein Start einer Session
- kein Import
- keine Navigation
- keine Aenderung bestehender App-Flows

Der Presenter bereitet nur einen spaeteren controller-neutralen Karten-View vor.

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 222 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 9. Naechste Schritte

Sinnvoll:

- `LearnModeCardPresenter` als abgeschlossen markieren
- danach einen controller-neutralen Karten-View planen
- spaeter pruefen, wie dieser Karten-View visuelle Teile der bestehenden LearnMode-UI wiederverwenden kann
- bestehende `LearnModeScreen`-UI weiterhin nicht direkt umbauen
- bestehenden `LearnModeController` weiterhin nicht direkt umbauen

Nicht empfohlen:

- kein `WordUserView`-Fake
- kein direkter lokaler Branch im bestehenden `LearnModeScreen`
- keine Supabase-Entfernung nebenbei
- keine Vermischung lokaler V1-Daten mit alter Queue-/PassCount-Logik
