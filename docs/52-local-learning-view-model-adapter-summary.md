# 52 Local Learning View Model Adapter Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `LocalLearningViewModelAdapter` zusammen.

Der Adapter ist eine UI-nahe, aber widget-unabhaengige Mapping-Schicht fuer die lokale Offline-first-Lernkette. Er uebersetzt den State des `LocalLearningController` in einen flachen `LocalLearningViewModelState`, der spaeter von einer UI- oder ViewModel-Schicht gelesen werden kann.

Er ist noch keine UI-Anbindung und ersetzt keinen bestehenden App-Flow.

## Aufgabe Des Adapters

Dateien:

- `lib/core/local_database/adapters/local_learning_view_model_adapter.dart`
- `lib/core/local_database/adapters/local_learning_view_model_state.dart`

Der Adapter uebernimmt:

- `LocalLearningControllerState` lesen
- vorhandenen `LocalSessionReadState` auswerten
- UI-nahe Felder in einen flachen ViewModel-State kopieren
- Loading-, Error- und Last-Action-Zustand weiterreichen
- fehlenden `readState` sicher als nicht aktive Session darstellen

Der Adapter macht nicht:

- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine Datenbank lesen
- keine Repositorys verwenden
- kein Supabase kennen
- kein `WordUserView` kennen
- keine UI-Texte erzeugen
- keine Navigation ausloesen
- keine SRS-Regeln berechnen

## Eingabe

Die einzige Eingabe ist:

- `LocalLearningControllerState`

Dieser State enthaelt:

- `isLoading`
- `errorMessage`
- `readState`
- `lastAction`

Wenn `readState` vorhanden ist, liest der Adapter daraus die lokalen Session-, Wort- und Fortschrittsdaten.

Wenn `readState` fehlt, erzeugt der Adapter keinen kuenstlichen Session-Zustand.

## Ausgabe

Die Ausgabe ist:

- `LocalLearningViewModelState`

Dieser State ist flach und UI-nah, bleibt aber widget-unabhaengig.

Er enthaelt:

- Loading- und Error-Zustand
- Session-Metadaten
- aktuelle Wortdaten
- aktuelle Stage
- Progress-Counter
- Submit-/Completion-Flags
- letzte Controller-Aktion

## Gemappte Felder

Direkt aus `LocalLearningControllerState`:

- `isLoading`
- `errorMessage`
- `lastAction`

Aus `LocalSessionReadState`, falls vorhanden:

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

Zusatzfeld:

- `hasSession`
  - `true`, wenn `readState != null`
  - `false`, wenn kein lokaler Read-State vorhanden ist

Bei fehlendem `readState`:

- sessionbezogene Felder bleiben `null`
- Counter werden `0`
- `canSubmitAnswer` wird `false`
- `canCompleteSession` wird `false`

## Tests

Datei:

- `test/core/local_database/local_learning_view_model_adapter_test.dart`

Vorhandene Tests:

- `local_learning_view_model_adapter_maps_read_state_to_view_model_state`
- `local_learning_view_model_adapter_handles_missing_read_state`
- `local_learning_view_model_adapter_exposes_loading_and_error`
- `local_learning_view_model_adapter_exposes_progress_counters_and_flags`
- `local_learning_view_model_adapter_does_not_require_supabase_or_word_user_view`

### maps_read_state_to_view_model_state

Sichert ab:

- vorhandener `LocalSessionReadState` wird vollstaendig uebernommen
- Wortdaten werden gemappt
- Stage wird gemappt
- Session-Zaehler werden gemappt
- Submit-/Completion-Flags werden uebernommen
- `lastAction` wird uebernommen

### handles_missing_read_state

Sichert ab:

- fehlender `readState` ergibt `hasSession == false`
- sessionbezogene Felder bleiben `null`
- Wortfelder bleiben `null`
- `currentStage` bleibt `null`
- Submit und Completion sind nicht erlaubt
- Loading, Error und LastAction werden trotzdem uebernommen

### exposes_loading_and_error

Sichert ab:

- `isLoading` wird unveraendert uebernommen
- `errorMessage` wird unveraendert uebernommen
- der Adapter erzeugt keine eigenen Fehlertexte

### exposes_progress_counters_and_flags

Sichert ab:

- `currentPosition` wird nicht neu berechnet
- `totalItems` wird nicht neu berechnet
- `answeredCount` wird nicht neu berechnet
- `remainingCount` wird nicht neu berechnet
- `canSubmitAnswer` wird nicht neu berechnet
- `canCompleteSession` wird nicht neu berechnet

### does_not_require_supabase_or_word_user_view

Sichert ab:

- Adapter-Test laeuft ohne Supabase-Initialisierung
- es werden nur lokale Controller-/Read-State-Modelle verwendet
- keine `WordUserView`-Instanz ist noetig
- ein gueltiger ViewModel-State entsteht aus lokalen Modellen

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Provider-Ersetzung in bestehenden App-Flows
- keine Supabase-Entfernung
- keine Supabase-Migration
- keine Navigation
- kein lokaler Testscreen
- keine Modusbutton-UI-Aenderung
- keine Mapping-Schicht zu `WordUserView`

Der Adapter ist bewusst nur ein lokaler Mapping-Baustein.

## Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 96 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`
  - `No issues found!`

Damit waren zuletzt 135 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller und Adapter gruen.

## Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- `learn_mode_screen.dart` ist stark an alte Controller-, Stage-, Swipe- und Animationslogik gekoppelt.
- `learn_mode_controller.dart` enthaelt weiterhin alte Supabase-, Queue-, Timer- und SRS-Logik.
- Der neue Adapter ersetzt noch keine Navigation und keine Screen-Logik.
- Die lokale Schicht nutzt lokale Modelle, waehrend die bestehende UI noch `WordUserView` erwartet.
- Eine zu fruehe Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der Adapter ist ein sicherer Vorbereitungsschritt, aber noch kein produktiver UI-Umschaltpunkt.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Adapter-Block dokumentiert als abgeschlossen betrachten.
2. Vollstaendigen lokalen Stabilitaetscheck vor jeder weiteren Integration erneut ausfuehren.
3. Einen optionalen Provider fuer `LocalLearningViewModelState` planen, der den Controller-State liest und den Adapter nutzt.
4. Danach entscheiden, ob ein isolierter lokaler Testscreen geplant wird.
5. Vor jeder bestehenden UI-Anbindung separat planen:
   - Datenmodell-Mapping
   - Modus-/Trainingsbereichsnamen
   - Navigation
   - Rueckbaupfad
   - Tests
6. Bestehenden `learn_mode_screen.dart` und `LearnModeController` erst anfassen, wenn der lokale UI-nahe State stabil und getestet ist.
