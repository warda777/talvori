# 54 Local Learning View Model Provider Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `localLearningViewModelProvider` zusammen.

Der Provider ist ein isolierter, abgeleiteter Riverpod-Provider fuer die lokale Offline-first-Lernkette. Er stellt einen `LocalLearningViewModelState` bereit, ohne selbst Aktionen auszufuehren oder bestehende App-Flows zu beruehren.

Er ist noch keine UI-Anbindung und ersetzt keinen bestehenden Provider der App.

## Aufgabe Des Providers

Datei:

- `lib/core/local_database/providers/local_learning_view_model_provider.dart`

Der Provider uebernimmt:

- `localLearningControllerProvider` lesen
- den aktuellen `LocalLearningControllerState` beobachten
- `LocalLearningViewModelAdapter.map(...)` aufrufen
- `LocalLearningViewModelState` bereitstellen

Der Provider macht nicht:

- keine Session starten
- keine Antwort submitten
- keine Completion ausloesen
- keine Datenbank oeffnen
- keine Repositorys lesen
- keine lokale Facade direkt lesen
- kein Supabase kennen
- kein `WordUserView` kennen
- keine UI-Widgets kennen
- keine Navigation ausloesen

## Datenquelle

Die einzige Datenquelle ist:

- `localLearningControllerProvider`

Der Provider liest daraus:

- `LocalLearningControllerState`

Der State enthaelt:

- `isLoading`
- `errorMessage`
- `readState`
- `lastAction`

Wichtig:

- Der Provider liest nicht den Controller-Notifier.
- Der Provider ruft keine Controller-Methoden auf.
- Der Provider liest nicht `localLearningSessionFacadeProvider`.

## Nutzung Des Adapters

Der Provider nutzt:

- `LocalLearningViewModelAdapter`

Die Abfolge ist:

1. `ref.watch(localLearningControllerProvider)`
2. `LocalLearningViewModelAdapter().map(controllerState)`
3. Rueckgabe als `LocalLearningViewModelState`

Damit bleibt die Verantwortung sauber getrennt:

- `LocalLearningController` verwaltet Aktionen und Controller-State.
- `LocalLearningViewModelAdapter` mappt Controller-State in ViewModel-State.
- `localLearningViewModelProvider` stellt den gemappten State fuer spaetere Leser bereit.

## Ausgabe

Die Ausgabe ist:

- `LocalLearningViewModelState`

Dieser State enthaelt:

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

Der Provider erzeugt keine eigenen UI-Texte und keine eigenen fachlichen Defaults.

## Tests

Datei:

- `test/core/local_database/local_learning_view_model_provider_test.dart`

Vorhandene Tests:

- `local_learning_view_model_provider_maps_controller_state`
- `local_learning_view_model_provider_does_not_start_session_or_submit`

### local_learning_view_model_provider_maps_controller_state

Sichert ab:

- Provider kann mit `ProviderContainer` gelesen werden.
- `localLearningControllerProvider` kann kontrolliert ueberschrieben werden.
- Rueckgabe ist ein gemappter `LocalLearningViewModelState`.
- `isLoading` wird uebernommen.
- `errorMessage` wird uebernommen.
- `lastAction` wird uebernommen.
- Session-, Wort-, Stage- und Counter-Felder werden aus dem Controller-State gemappt.
- keine Datenbank ist erforderlich.
- keine Supabase-Initialisierung ist erforderlich.
- keine `WordUserView`-Instanz ist erforderlich.

### local_learning_view_model_provider_does_not_start_session_or_submit

Sichert ab:

- Reines Lesen des Providers erzeugt keine Session.
- Bei fehlendem `readState` bleibt `hasSession == false`.
- `sessionId` und `currentWordId` bleiben `null`.
- `canSubmitAnswer` bleibt `false`.
- `canCompleteSession` bleibt `false`.
- `lastAction` wird nicht veraendert.
- Es wird keine Controller-Aktion ausgeloest.

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
- keine automatische Session-Erzeugung durch Lesen des Providers

Der Provider ist bewusst nur ein lokaler Lesebaustein.

## Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 98 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`
  - `No issues found!`

Damit waren zuletzt 137 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller, Adapter und ViewModelProvider gruen.

## Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- `localLearningViewModelProvider` stellt Daten bereit, ist aber noch kein Screen-Vertrag.
- `learn_mode_screen.dart` ist weiterhin an alte Swipe-, Stage-, Animation- und `WordUserView`-Strukturen gekoppelt.
- `learn_mode_controller.dart` enthaelt weiterhin alte Supabase-, Queue-, Timer- und SRS-Logik.
- Supabase und lokale SQLite-Schicht laufen noch parallel.
- Eine zu fruehe UI-Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der Provider ist ein sicherer Vorbereitungsschritt, aber noch kein produktiver Umschaltpunkt.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. ViewModelProvider-Block dokumentiert als abgeschlossen betrachten.
2. Vollstaendigen lokalen Stabilitaetscheck vor jeder weiteren Integration erneut ausfuehren.
3. Einen isolierten lokalen Testscreen planen, falls eine visuelle Smoke-Test-Flaeche gewuenscht ist.
4. Alternativ zuerst einen Screen-Vertrag planen:
   - welche Felder der lokale Screen wirklich braucht
   - welche Aktionen sichtbar sein sollen
   - welche Empty-/Loading-/Error-Zustaende angezeigt werden
5. Vor jeder bestehenden UI-Anbindung separat planen:
   - Datenmodell-Mapping
   - Modus-/Trainingsbereichsnamen
   - Navigation
   - Rueckbaupfad
   - Tests
6. Bestehenden `learn_mode_screen.dart` und `LearnModeController` erst anfassen, wenn die lokale UI-nahe Provider-Kette bewusst angebunden werden soll.
