# 111 Local LearnMode UI Adapter Summary

Stand: 2026-05-15

## 1. Aufgabe

`LocalLearnModeUiAdapter` ist ein UI-neutraler Adapter fuer eine spaetere lokale LearnMode-UI-Anbindung.

Er uebersetzt `LocalLearningViewModelState` in einen kleinen, UI-nahen `LocalLearnModeUiState`.

Der Adapter ist eine vorbereitende Bruecke zwischen der lokalen Offline-first-Lernkette und einer spaeteren Nutzung einer LearnMode-nahen Oberflaeche.

Er macht nicht:

- keine UI bauen
- keine Provider lesen
- keine Session starten
- keinen Import starten
- keine Antwort abschicken
- keine Completion ausloesen
- kein Supabase kennen
- kein `WordUserView` erzeugen

## 2. Eingabe

Der Adapter nutzt als einzige Eingabe:

- `LocalLearningViewModelState`

Dieser State kommt aus der lokalen Lernkette und enthaelt bereits UI-nahe lokale Daten wie:

- aktuelle Wortdaten
- aktuelle Stage
- Fortschrittszaehler
- Loading-/Error-Zustand
- Submit-/Completion-Flags

## 3. Ausgabe

Der Adapter erzeugt:

- `LocalLearnModeUiState`

Dieser State ist bewusst klein und flach. Er ist fuer spaetere lokale LearnMode-nahe UI-Schritte gedacht, aber noch nicht an `LearnModeScreen` angebunden.

## 4. Aktuell Gemappte Felder

Aktuell enthaelt `LocalLearnModeUiState`:

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

Mapping-Regeln:

- `isLoading` wird uebernommen.
- `errorMessage` wird uebernommen.
- `hasCard == true`, wenn `currentWordId != null` und `term != null`.
- `term`, `translation`, `exampleSentence` und `notes` werden uebernommen.
- `currentStage` wird uebernommen.
- `progressLabel` wird aus `answeredCount` und `totalItems` gebildet, z. B. `1 / 3`.
- `canSubmitAnswer` wird uebernommen.
- `isCompleted` wird lokal abgeleitet, wenn eine Session existiert, keine aktuelle Karte vorhanden ist, Items vorhanden sind und `remainingCount == 0`.

## 5. Getestete Zustaende

Die Tests liegen in:

- `test/core/local_database/local_learn_mode_ui_adapter_test.dart`

Aktuell existieren:

- `local_learnmode_ui_adapter_maps_active_card`
  - prueft aktive Karte
  - prueft Wortdaten
  - prueft Stage
  - prueft Fortschrittslabel
  - prueft `canSubmitAnswer`
  - prueft `isCompleted == false`

- `local_learnmode_ui_adapter_maps_loading_and_error`
  - prueft Loading-Zustand
  - prueft Error-Zustand
  - prueft, dass keine eigenen Fehlertexte erzeugt werden
  - prueft, dass ohne Karte kein Submit erlaubt ist

- `local_learnmode_ui_adapter_maps_completed_state`
  - prueft abgeschlossenen lokalen Session-Zustand
  - prueft `hasCard == false`
  - prueft `canSubmitAnswer == false`
  - prueft `isCompleted == true`
  - prueft sinnvolles Fortschrittslabel, z. B. `3 / 3`
  - prueft, dass Wortfelder leer bleiben

## 6. Warum Kein WordUserView Erzeugt Wird

Der Adapter erzeugt bewusst kein `WordUserView`.

Gruende:

- `WordUserView` gehoert zur alten Supabase-nahen Lernkette.
- Die lokale Offline-first-Kette nutzt eigene lokale Modelle.
- Ein kuenstliches `WordUserView` wuerde lokale und alte Fortschrittssemantik vermischen.
- Alte Stage-/PassCount-/Queue-Felder duerfen nicht implizit aus lokalen V1-Daten rekonstruiert werden.
- Die Grenze zwischen alter Produktlogik und lokaler Lernkette bleibt dadurch klar.

Der Adapter bleibt deshalb bei einem eigenen lokalen UI-State.

## 7. Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- kein `LearnModeScreen`-Umbau
- kein `LearnModeController`-Umbau
- kein Supabase
- keine Aktion
- keine Provider-Anbindung
- kein Import
- keine Session-Erzeugung
- keine Navigation
- keine Aenderung bestehender App-Flows

Der Adapter ist nur ein lokaler Mapping-Baustein.

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 216 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

Hinweis:

- Flutter meldete weiterhin Paket-Updates als Hinweis: `76 packages have newer versions incompatible with dependency constraints`
- Es gab keine Testfehler und keine Analyzer-Probleme

## 9. Naechste Schritte

Sinnvoll:

- `LocalLearnModeUiAdapter` als abgeschlossen markieren
- danach eine lokale LearnMode-Screen-Variante oder einen Wrapper separat planen
- bestehenden `LearnModeScreen` weiterhin nicht direkt umbauen
- bestehenden `LearnModeController` weiterhin nicht direkt umbauen
- spaetere UI-Anbindung nur mit eigener Planung und Regressionstests

Nicht empfohlen:

- kein `WordUserView`-Fake
- keine direkte Supabase-Entfernung
- kein automatischer lokaler Sessionstart beim Screen-Build
- keine Vermischung lokaler V1-Regeln mit alter LearnMode-Logik
