# 61 Local Testscreen Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den isolierten `LocalLearningTestScreen` zusammen.

Der Screen ist eine kleine lokale Debug-/QA-Oberflaeche fuer die neue Offline-first-Lernkette. Er dient dazu, lokale ViewModel- und ScreenContract-Zustaende sichtbar zu pruefen, ohne bestehende App-Flows, Supabase, alte Word-UI oder Navigation zu beruehren.

Er ist noch keine produktive Lernoberflaeche.

## 1. Aufgabe Des LocalLearningTestScreen

Der `LocalLearningTestScreen` uebernimmt aktuell:

- lokalen Initialzustand anzeigen
- aktive Karte aus lokalem ViewModel-State anzeigen
- Fortschritt anzeigen
- nutzerfreundliches Stage-Label anzeigen
- Submit-Button-Zustand anhand des Screen-Contracts anzeigen
- Completed-Zustand anzeigen
- Loading-Zustand anzeigen
- Error-Zustand anzeigen

Der Screen startet keine Session automatisch. Er fuehrt keine Datenbankabfrage aus und enthaelt keine eigene SRS-Fachlogik.

## 2. Ablageort

Datei:

- `lib/features/local_learning_debug/ui/local_learning_test_screen.dart`

Der Screen liegt bewusst in einem isolierten Debug-Feature-Bereich:

- nicht in `lib/features/words/ui/screens/`
- nicht neben `learn_mode_screen.dart`
- nicht in bestehender Navigation
- nicht in bestehenden App-Flows

Damit bleibt die lokale Testoberflaeche klar von der alten Word-/Supabase-Lernoberflaeche getrennt.

## 3. Keine Navigation Oder App-Flow-Anbindung

Der Screen ist nicht in die App-Navigation eingebunden.

Das ist Absicht:

- bestehende Nutzerfluesse bleiben unveraendert
- `main.dart` bleibt unveraendert
- `word_providers.dart` bleibt unveraendert
- `learn_mode_controller.dart` bleibt unveraendert
- `learn_mode_screen.dart` bleibt unveraendert
- Supabase bleibt unangetastet
- der Screen kann ueber Widget-Tests isoliert geprueft werden

Eine spaetere Debug-Route oder ein internes Debug-Menue kann den Screen bewusst mit einer `categoryId` oeffnen. Das ist noch nicht umgesetzt.

## 4. Gelesene Provider

Der Screen liest:

- `localLearningViewModelProvider`
- `localLearningScreenContractProvider`

Der Screen bekommt:

- `categoryId` als Konstruktor-Parameter

Aktuell nutzt der Screen `categoryId` noch nicht fuer eine Aktion, weil der erste Screen-Block keine Session automatisch startet.

Der Screen liest nicht:

- Supabase-Provider
- alte Word-Provider
- `localBootstrapProvider`
- `localLearningSessionFacadeProvider`
- Repositories
- SQLite-Datenbank
- alte `local_word_database.dart`

## 5. Darstellbare Zustaende

### Initial

Wenn `contract.isInitial == true`, zeigt der Screen:

- **Noch keine Session**
- **Intensiv lernen**
- **Alles lernen**
- **Starten/Fortsetzen**

`Richtig` und `Falsch` werden im Initialzustand nicht angezeigt.

### Active Card

Wenn `contract.hasActiveCard == true`, zeigt der Screen:

- `term`
- `translation`
- `exampleSentence`, falls vorhanden
- `notes`, falls vorhanden
- `currentStage` als Nutzerlabel
- Fortschritt als `answeredCount / totalItems`
- **Richtig**
- **Falsch**

Aktuell wird `SrsStage.s0` als **Neu** angezeigt. Die weiteren Stage-Labels sind ebenfalls im Screen gemappt:

- S0: **Neu**
- S1: **Begonnen**
- S2: **Im Aufbau**
- S3: **Gefestigt**
- S4: **Sicher**
- S5: **Langzeit**

### Button-Flags

Die Buttons **Richtig** und **Falsch** folgen `contract.canShowSubmitActions`.

Wenn `canShowSubmitActions == true`:

- **Richtig** ist enabled
- **Falsch** ist enabled

Wenn `canShowSubmitActions == false`:

- **Richtig** ist disabled
- **Falsch** ist disabled

Der aktuelle Testscreen loest dabei noch keine echte Antwortaktion aus.

### Completed

Wenn `contract.isCompleted == true`, zeigt der Screen:

- **Session abgeschlossen**
- **Weitere Session starten**

Es wird keine aktive Karte angezeigt. **Richtig** und **Falsch** werden nicht angezeigt.

### Loading

Wenn `contract.isLoading == true`, zeigt der Screen:

- **Lädt...**

Es wird keine Session automatisch gestartet.

### Error

Wenn `contract.hasError == true`, zeigt der Screen:

- **Etwas ist schiefgelaufen**
- den technischen `errorMessage`-Wert als Debug-Hinweis, falls vorhanden

Der Fehlertext wird nicht uebersetzt und nicht in finale Produktkopie umgewandelt.

## 6. Verwendete Texte Aus Der Labelstrategie

Der Screen nutzt einfache Texte aus der Labelstrategie:

- **Intensiv lernen**
- **Alles lernen**
- **Starten/Fortsetzen**
- **Richtig**
- **Falsch**
- **Session abgeschlossen**
- **Weitere Session starten**
- **Lädt...**

Zusaetzlich nutzt er fuer den Debug-/Error-Zustand:

- **Etwas ist schiefgelaufen**

Die Texte bleiben bewusst einfach. Sie sind fuer den isolierten Testscreen geeignet, aber noch keine finale Produktkopie.

## 7. Tests

Datei:

- `test/features/local_learning_debug/local_learning_test_screen_test.dart`

Vorhandene Tests:

- `local_learning_test_screen_renders_initial_state`
- `local_learning_test_screen_shows_active_card`
- `local_learning_test_screen_buttons_follow_contract_flags`
- `local_learning_test_screen_handles_completed_state`
- `local_learning_test_screen_handles_loading_state`
- `local_learning_test_screen_handles_error_state`

### local_learning_test_screen_renders_initial_state

Sichert ab:

- Initialzustand wird angezeigt
- **Intensiv lernen** wird angezeigt
- **Alles lernen** wird angezeigt
- **Starten/Fortsetzen** wird angezeigt
- keine aktuelle Karte wird angezeigt
- **Richtig** und **Falsch** werden nicht angezeigt

### local_learning_test_screen_shows_active_card

Sichert ab:

- aktive Karte wird angezeigt
- `term`, `translation`, `exampleSentence` und `notes` werden angezeigt
- Stage S0 wird als **Neu** angezeigt
- Fortschritt wird angezeigt
- **Richtig** und **Falsch** werden angezeigt

### local_learning_test_screen_buttons_follow_contract_flags

Sichert ab:

- **Richtig** und **Falsch** sind disabled, wenn `canShowSubmitActions == false`
- **Richtig** und **Falsch** sind enabled, wenn `canShowSubmitActions == true`
- keine echte Button-Aktion wird getestet oder ausgeloest

### local_learning_test_screen_handles_completed_state

Sichert ab:

- Completed-Zustand zeigt **Session abgeschlossen**
- **Weitere Session starten** wird angezeigt
- keine aktive Karte wird angezeigt
- **Richtig** und **Falsch** werden nicht angezeigt

### local_learning_test_screen_handles_loading_state

Sichert ab:

- Loading-Zustand zeigt **Lädt...**
- keine Submit-Buttons werden angezeigt
- kein Initialzustand wird angezeigt

### local_learning_test_screen_handles_error_state

Sichert ab:

- Error-Zustand zeigt **Etwas ist schiefgelaufen**
- technischer Debug-Hinweis aus `errorMessage` wird angezeigt
- keine Submit-Buttons werden angezeigt
- kein Initialzustand wird angezeigt

## 8. Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine Navigation
- keine App-Flow-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Supabase-Entfernung
- keine Supabase-Initialisierung
- keine `WordUserView`-Nutzung
- keine Nutzung der alten `local_word_database.dart`
- keine direkte SQLite-Abfrage
- kein automatischer Session-Start
- keine echte Antwortaktion ueber Buttons
- keine Completion-Aktion ueber Button
- keine finale Produkt-UI

Der Screen ist weiterhin ein isolierter Testscreen.

## 9. Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 105 Tests bestanden
- `flutter test test/features/local_learning_debug/`
  - 6 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Damit waren zuletzt 150 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller, Adapter, ViewModelProvider, ScreenContract und Testscreen gruen.

## 10. Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- Der Screen ist noch ein Debug-/QA-Screen.
- Buttons sind noch nicht funktional mit Controller-Aktionen verdrahtet.
- Der Screen startet keine echte Session.
- Die `categoryId` wird zwar als Konstruktor-Parameter uebergeben, aber eine sichere Debug-Route oder Kategorieauswahl ist noch nicht geplant und getestet.
- Bestehender `learn_mode_screen.dart` und `LearnModeController` enthalten weiterhin alte UI-, Supabase- und Lernlogik.
- Supabase und lokale SQLite-Schicht laufen weiterhin parallel.
- Eine zu fruehe Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der sichere Weg bleibt: Testscreen isoliert halten, jede weitere Aktion klein testen und erst danach eine separate Debug-Erreichbarkeit planen.

## 11. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Testscreen-Block als abgeschlossen dokumentiert betrachten.
2. Vor weiteren Schritten erneut lokalen Stabilitaetscheck ausfuehren.
3. Als naechsten TDD-Schritt eine einzelne Aktion verdrahten:
   - zuerst `Starten/Fortsetzen`
   - weiterhin mit Provider-Overrides oder klar isolierter Testumgebung
4. Danach getrennt planen:
   - `Richtig`
   - `Falsch`
   - `Session abschliessen`
5. Erst danach eine sichere Debug-Erreichbarkeit planen:
   - keine produktive Navigation
   - keine automatische Sichtbarkeit
   - `categoryId` wird bewusst uebergeben
6. Bestehende Word-UI und alte Controller weiterhin unangetastet lassen.

