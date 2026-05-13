# 56 Local Learning Screen Contract Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `LocalLearningScreenContract` zusammen.

Der Contract ist ein UI-neutraler Presenter fuer eine spaetere lokale Lernoberflaeche. Er leitet aus `LocalLearningViewModelState` einfache Screen-Zustaende ab, ohne Widgets, Navigation, Texte oder Aktionen zu kennen.

Er ist noch kein Screen und noch keine App-Flow-Anbindung.

## Aufgabe Des Screen-Contracts

Datei:

- `lib/core/local_database/adapters/local_learning_screen_contract.dart`

Der Contract uebernimmt:

- `LocalLearningViewModelState` lesen
- einfache boolesche Screen-Zustaende ableiten
- Initial-, Loading-, Error-, Active-Card- und Completed-Zustaende unterscheidbar machen
- Submit-Aktionssichtbarkeit aus bestehendem State ableiten

Der Contract macht nicht:

- keine UI-Texte erzeugen
- keine Buttontexte erzeugen
- keine Modusnamen erzeugen
- keine Trainingsbereichsnamen erzeugen
- keine Widgets kennen
- keine Navigation ausloesen
- keine Datenbank lesen
- keine Supabase-Abhaengigkeit haben
- kein `WordUserView` kennen
- keine Controller-Aktionen ausfuehren

## Eingabe

Die einzige Eingabe ist:

- `LocalLearningViewModelState`

Dieser State kommt spaeter typischerweise aus:

- `localLearningViewModelProvider`

Relevante Eingabefelder:

- `isLoading`
- `errorMessage`
- `hasSession`
- `status`
- `currentWordId`
- `canSubmitAnswer`

Der Contract veraendert diese Daten nicht und speichert nichts.

## Abgeleitete Zustaende

Der Contract leitet diese Felder ab:

- `isInitial`
- `isLoading`
- `hasError`
- `hasActiveCard`
- `isCompleted`
- `canShowSubmitActions`

### isInitial

`isInitial` ist true, wenn:

- `hasSession == false`
- `isLoading == false`
- `errorMessage == null`

Bedeutung:

- Es gibt noch keine lokale Session im ViewModel-State.
- Es laeuft keine Aktion.
- Es liegt kein Fehler vor.

### isLoading

`isLoading` wird unveraendert aus `LocalLearningViewModelState` uebernommen.

Bedeutung:

- Der lokale Controller fuehrt gerade eine Aktion aus oder bereitet einen Zustand vor.

### hasError

`hasError` ist true, wenn:

- `errorMessage != null`

Wichtig:

- Der Fehlertext wird nicht uebersetzt.
- Der Fehlertext wird nicht in UI-Kopie umgewandelt.
- Der Contract erkennt nur, dass ein Fehler vorhanden ist.

### hasActiveCard

`hasActiveCard` ist true, wenn:

- `hasSession == true`
- `currentWordId != null`
- `status == active`

Bedeutung:

- Eine laufende lokale Session hat eine aktuelle Karte, die spaeter dargestellt werden koennte.

### isCompleted

`isCompleted` ist true, wenn:

- `status == completed`

Bedeutung:

- Die lokale Session ist abgeschlossen.

### canShowSubmitActions

`canShowSubmitActions` ist true, wenn:

- `canSubmitAnswer == true`
- `hasActiveCard == true`

Bedeutung:

- Richtig/Falsch-Aktionen duerften spaeter sichtbar oder aktiv sein.

Wichtig:

- Der Contract submittert keine Antwort.
- Der Contract entscheidet keine SRS-Regel.
- Der Contract prueft nur die Sichtbarkeit auf Basis des ViewModel-State.

## Tests

Datei:

- `test/core/local_database/local_learning_screen_contract_test.dart`

Vorhandene Tests:

- `screen_contract_handles_empty_state`
- `screen_contract_handles_active_card`
- `screen_contract_handles_completed_state`
- `screen_contract_handles_loading_state`
- `screen_contract_handles_error_state`

### screen_contract_handles_empty_state

Sichert ab:

- fehlende Session wird als Initialzustand erkannt
- kein Loading-Zustand
- kein Error-Zustand
- keine aktive Karte
- nicht completed
- keine Submit-Aktionen sichtbar

### screen_contract_handles_active_card

Sichert ab:

- aktive Session mit `status == active` und `currentWordId != null` wird als aktive Karte erkannt
- Initial ist false
- Loading ist false
- Error ist false
- Completed ist false
- Submit-Aktionen sind sichtbar, wenn `canSubmitAnswer == true`

### screen_contract_handles_completed_state

Sichert ab:

- `status == completed` wird als Completed-Zustand erkannt
- keine aktive Karte wird angenommen
- keine Submit-Aktionen werden sichtbar
- Initial bleibt false

### screen_contract_handles_loading_state

Sichert ab:

- Loading wird unveraendert uebernommen
- Loading ist kein Initialzustand
- ohne Fehler bleibt `hasError == false`
- ohne aktuelle Karte bleibt `hasActiveCard == false`
- keine Submit-Aktionen werden sichtbar

### screen_contract_handles_error_state

Sichert ab:

- vorhandene `errorMessage` fuehrt zu `hasError == true`
- Fehlerzustand ist kein Initialzustand
- Loading wird unveraendert uebernommen
- ohne aktuelle Karte bleibt `hasActiveCard == false`
- keine Submit-Aktionen werden sichtbar

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- kein lokaler Screen
- keine Widgets
- keine Navigation
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Provider-Ersetzung in bestehenden App-Flows
- keine Supabase-Entfernung
- keine Supabase-Migration
- keine Modusbutton-UI-Aenderung
- keine Completion-Meldungen
- keine finalen UI-Texte
- keine Mapping-Schicht zu `WordUserView`

Der Contract ist bewusst nur eine lokale, UI-neutrale Ableitungsschicht.

## Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 103 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`
  - `No issues found!`

Damit waren zuletzt 142 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider, Controller, Adapter, ViewModelProvider und ScreenContract gruen.

## Warum Weiterhin Keine Bestehende UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende UI- oder App-Flows sollte weiterhin nicht erfolgen.

Gruende:

- Der Contract liefert nur boolesche Screen-Zustaende, aber noch keine echte Screen-Architektur.
- `learn_mode_screen.dart` ist weiterhin an alte Swipe-, Stage-, Animation- und `WordUserView`-Strukturen gekoppelt.
- `learn_mode_controller.dart` enthaelt weiterhin alte Supabase-, Queue-, Timer- und SRS-Logik.
- Supabase und lokale SQLite-Schicht laufen noch parallel.
- Es gibt noch keine finale Strategie fuer Modusnamen, Trainingsbereichsnamen, Buttontexte und Completion-Meldungen in der UI.
- Eine zu fruehe UI-Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der Contract ist ein sicherer Vorbereitungsschritt, aber noch kein produktiver Umschaltpunkt.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. ScreenContract-Block dokumentiert als abgeschlossen betrachten.
2. Vollstaendigen lokalen Stabilitaetscheck vor jeder weiteren Integration erneut ausfuehren.
3. Entscheiden, ob als naechstes ein isolierter lokaler Testscreen geplant werden soll.
4. Falls ja, zuerst eine Testscreen-Planungsdatei erstellen:
   - keine bestehende Navigation
   - keine bestehende UI ersetzen
   - keine Supabase-Datenquelle
   - nur lokale Provider-Kette
5. Alternativ einen kleinen Provider fuer `LocalLearningScreenContract` planen, der `localLearningViewModelProvider` liest und den Contract bereitstellt.
6. Bestehenden `learn_mode_screen.dart` und `LearnModeController` erst anfassen, wenn die lokale UI-nahe Kette bewusst und separat integriert werden soll.
