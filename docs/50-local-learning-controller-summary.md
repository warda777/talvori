# 50 Local Learning Controller Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den neuen isolierten `LocalLearningController` zusammen.

Der Controller ist ein UI-neutraler Riverpod-Baustein fuer die lokale Offline-first-Lernkette. Er kapselt den Zugriff auf die `LocalLearningSessionFacade`, haelt einen kleinen Controller-State und stellt Methoden bereit, die spaeter von einem ViewModel oder einer UI-Schicht genutzt werden koennen.

Er ersetzt den bestehenden `LearnModeController` nicht und ist noch nicht in bestehende App-Flows eingebunden.

## Aufgabe Des LocalLearningController

Datei:

- `lib/core/local_database/controllers/local_learning_controller.dart`

Der Controller uebernimmt:

- lokale Session starten oder fortsetzen
- richtige Antwort einreichen
- falsche Antwort einreichen
- Completion pruefen
- aktuellen `LocalSessionReadState` halten
- Loading-Zustand halten
- Fehlerzustand halten
- letzte erfolgreiche Aktion dokumentieren

Der Controller enthaelt keine eigene SRS-Fachlogik. Stage-Wechsel, Requeue, Due-Date-Berechnung, Session-Persistenz und Completion bleiben in Facade, Services, Repositories und Engine.

## Abhaengigkeiten

Der Controller nutzt:

- `localLearningSessionFacadeProvider`
- `LocalSessionReadState`
- `LearningMode`
- `TrainingArea`
- `ReviewAnswer`
- Riverpod `NotifierProvider`

Der Controller nutzt nicht:

- Supabase
- `SupabaseWordRepository`
- bestehender `LearnModeController`
- `WordUserView`
- UI-Widgets
- `BuildContext`
- Navigation
- alte `local_word_database.dart`
- direkte SQLite-Abfragen
- direkte Repository-Zugriffe

## Umgesetzte Methoden

### startOrResume(...)

`startOrResume(...)` liest die lokale Facade ueber `localLearningSessionFacadeProvider`, ruft `startOrResumeLearning(...)` auf und speichert den zurueckgegebenen `LocalSessionReadState` im Controller-State.

Die Methode:

- setzt waehrend der Aktion `isLoading`
- loescht vorherige Fehler
- startet oder setzt eine lokale Session fort
- setzt `lastAction` auf `startOrResume`
- speichert Fehler in `errorMessage`

### submitCorrect(...)

`submitCorrect(...)` verwendet die aktuelle `sessionId` aus `readState` und ruft `submitAnswerAndReadNext(...)` mit `ReviewAnswer.correct` auf.

Die Methode:

- prueft, ob eine lokale Session vorhanden ist
- delegiert die Antwort an die Facade
- speichert den aktualisierten `LocalSessionReadState`
- setzt `lastAction` auf `submitCorrect`
- erzeugt selbst keine Requeue- oder Stage-Logik

### submitWrong(...)

`submitWrong(...)` verwendet die aktuelle `sessionId` aus `readState` und ruft `submitAnswerAndReadNext(...)` mit `ReviewAnswer.wrong` auf.

Die Methode:

- prueft, ob eine lokale Session vorhanden ist
- delegiert die falsche Antwort an die Facade
- laesst Requeue vollstaendig in Engine/Service/Persistenzschicht
- speichert den aktualisierten `LocalSessionReadState`
- setzt `lastAction` auf `submitWrong`

### completeIfFinished(...)

`completeIfFinished(...)` verwendet die aktuelle `sessionId` aus `readState` und ruft `completeIfFinished(...)` der Facade auf.

Die Methode:

- prueft, ob eine lokale Session vorhanden ist
- delegiert Completion an die Facade
- speichert den aktualisierten `LocalSessionReadState`
- setzt `lastAction` auf `completeIfFinished`
- erzeugt keine neue Session
- baut keine neue Queue

## Controller-State

Der State besteht aus:

- `isLoading`
- `errorMessage`
- `readState`
- `lastAction`

`readState` ist die zentrale Datenquelle fuer:

- `sessionId`
- aktuelle Karte
- Wortdaten
- Stage
- Session-Fortschritt
- `canSubmitAnswer`
- `canCompleteSession`

`lastAction` nutzt aktuell diese Werte:

- `none`
- `startOrResume`
- `submitCorrect`
- `submitWrong`
- `completeIfFinished`

Der State enthaelt bewusst keine UI-Texte, keine Navigation und keine Kopie alter LearnMode-State-Strukturen.

## Tests

Datei:

- `test/core/local_database/local_learning_controller_test.dart`

Vorhandene Tests:

- `local_learning_controller_start_loads_read_state`
- `local_learning_controller_submit_correct_updates_state`
- `local_learning_controller_submit_wrong_updates_state_with_requeue`
- `local_learning_controller_complete_when_finished_updates_state`

### local_learning_controller_start_loads_read_state

Sichert ab:

- initialer State hat kein `readState`
- `startOrResume(...)` erzeugt einen nutzbaren lokalen Read-State
- aktuelle Karte, Begriff und Stage werden geladen
- `canSubmitAnswer` ist true
- `lastAction` wird korrekt gesetzt
- kein Fehler bleibt im State

### local_learning_controller_submit_correct_updates_state

Sichert ab:

- richtige Antwort erhoeht `answeredCount`
- `currentPosition` wird fortgeschrieben
- `lastAction` wird auf `submitCorrect` gesetzt
- kein Requeue-Item entsteht
- keine Supabase-Initialisierung ist noetig

### local_learning_controller_submit_wrong_updates_state_with_requeue

Sichert ab:

- falsche Antwort erhoeht `answeredCount`
- `currentPosition` wird fortgeschrieben
- `lastAction` wird auf `submitWrong` gesetzt
- ein `retryPending`-Requeue-Item entsteht durch die lokale Facade-/Service-Schicht
- der Controller enthaelt keine eigene Requeue-Logik

### local_learning_controller_complete_when_finished_updates_state

Sichert ab:

- Completion kann ueber den Controller ausgeloest werden
- Session wird bei erledigten Items als `completed` gelesen
- `currentWordId` wird null
- `canSubmitAnswer` wird false
- `lastAction` wird auf `completeIfFinished` gesetzt
- `completeIfFinished(...)` erzeugt keine neue Session

## Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 91 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`
  - `No issues found!`

Damit waren zuletzt 130 lokale Tests fuer SRS, SQLite, Repository, Read-State, Facade, Factory, Seed, Bootstrap, Provider und Controller gruen.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Provider-Ersetzung in bestehenden App-Flows
- keine Supabase-Entfernung
- keine Supabase-Migration
- keine echte App-Datenmigration
- kein Umbau des bestehenden Lernscreens
- kein Modusbutton-Umbau
- keine Navigation
- keine Nutzung alter `word_progress.db`

Der Controller ist fertig als lokaler, isolierter Baustein. Er ist noch keine produktive App-Integration.

## Warum Weiterhin Keine UI-/App-Flow-Anbindung

Eine direkte Anbindung an bestehende Screens oder alte Controller waere weiterhin zu riskant.

Gruende:

- Der bestehende `LearnModeController` ist mit alter Queue-, Timer-, UI- und Supabase-Logik gekoppelt.
- Supabase und lokale SQLite-Schicht laufen noch parallel, aber sind nicht fachlich zusammengefuehrt.
- Es gibt noch keine finale Strategie, welcher Screen zuerst lokal angebunden wird.
- Lokale Seed-/Testdaten ersetzen noch keine echten App-Daten.
- Eine zu fruehe Anbindung koennte alte und neue Fortschrittslogik vermischen.

Der sichere Weg bleibt: lokale Schicht weiter isoliert halten, dann eine kleine, kontrollierte App-nahe Integration planen.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Lokalen Controller-Block dokumentiert als abgeschlossen betrachten.
2. Vollstaendigen lokalen Stabilitaetscheck vor jeder weiteren Integration erneut ausfuehren.
3. Einen UI-neutralen Adapter fuer spaetere ViewModel-/Screen-Anbindung planen.
4. Entscheiden, welcher bestehende Lernscreen oder welche neue lokale Testoberflaeche zuerst angebunden werden soll.
5. Vor echter UI-Anbindung eine Migrations-/Parallelbetrieb-Strategie fuer Supabase und lokale Datenquelle festlegen.
6. Bestehende App-Dateien erst anfassen, wenn der konkrete Integrationsschnitt dokumentiert und testbar ist.
