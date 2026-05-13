# 49 Local Learning Controller Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen neuen isolierten lokalen Lerncontroller.

Der Controller soll die lokale `LocalLearningSessionFacade` fuer spaetere App-nahe Nutzung kapseln, ohne den bestehenden `LearnModeController` umzubauen oder bestehende UI-, Supabase- oder App-Flows zu veraendern.

Ziele:

- `LocalLearningSessionFacade` nutzen
- lokale Session starten oder fortsetzen
- Antworten einreichen
- Completion pruefen
- UI-neutralen Controller-State liefern
- bestehenden `LearnModeController` nicht ersetzen
- bestehende Provider nicht ersetzen

## 1. Zweck Des Neuen Lokalen Controllers

Der neue Controller soll eine schmale lokale Schicht zwischen Provider/Facade und spaeterer UI-Anbindung sein.

Er soll:

- `localLearningSessionFacadeProvider` lesen
- `startOrResumeLearning(...)` der Facade aufrufen
- `submitAnswerAndReadNext(...)` der Facade aufrufen
- `completeIfFinished(...)` der Facade aufrufen
- den aktuellen `LocalSessionReadState` in einem Controller-State halten
- Loading- und Error-Zustand verwalten
- letzte Aktion nachvollziehbar machen

Er soll nicht:

- alte SRS-Logik aus `learn_mode_controller.dart` kopieren
- Supabase lesen
- eine Datenbank direkt oeffnen
- Repositorys direkt verwenden
- UI-Texte oder Widgets kennen
- Navigation ausloesen
- bestehende App-Flows ersetzen

## 2. Erlaubte Und Nicht Erlaubte Abhaengigkeiten

### Erlaubt

Erlaubte Abhaengigkeiten:

- `localLearningSessionFacadeProvider`
- `LocalLearningSessionFacade`
- `LocalSessionReadState`
- `LearningMode`
- `TrainingArea`
- `ReviewAnswer`

Optional:

- Riverpod `Notifier` oder `AsyncNotifier`, falls als Provider umgesetzt
- `DateTime`, als expliziter Parameter in Methoden

### Nicht Erlaubt

Nicht erlaubte Abhaengigkeiten:

- Supabase
- `SupabaseWordRepository`
- `supabaseWordRepositoryProvider`
- `learn_mode_controller.dart`
- `LearnModeController`
- `LearnModeState`
- `WordUserView`
- `BuildContext`
- Navigation
- UI-Widgets
- alte `local_word_database.dart`
- `LocalDatabaseFactory`
- direkte SQLite-Abfragen
- alte SRS-Dateien wie `srs_logic.dart` oder `srs_config.dart`

## 3. Sinnvolle Controller-Methoden

### startOrResume(...)

Zweck:

- lokale Session fuer `categoryId + mode + trainingArea` starten oder fortsetzen
- Fortschritt ueber Facade vorbereiten lassen
- aktuellen `LocalSessionReadState` speichern

Moegliche Parameter:

- `categoryId`
- `LearningMode mode`
- `TrainingArea trainingArea`
- `DateTime now`
- optional `sessionSize`

Rueckgabe:

- kein direktes UI-Objekt
- State wird intern aktualisiert

### submitCorrect(...)

Zweck:

- `ReviewAnswer.correct` an die Facade weitergeben
- aktualisierten `LocalSessionReadState` speichern

Parameter:

- `DateTime now`

Voraussetzung:

- aktueller State enthaelt eine aktive `sessionId`
- `canSubmitAnswer == true`

### submitWrong(...)

Zweck:

- `ReviewAnswer.wrong` an die Facade weitergeben
- Requeue-Logik bleibt in Facade/Service/Engine
- aktualisierten `LocalSessionReadState` speichern

Parameter:

- `DateTime now`

### submitAnswer(...)

Alternative:

- Eine generische Methode mit `ReviewAnswer answer`

Bewertung:

- fachlich flexibler
- Tests koennen correct/wrong/focused getrennt pruefen

Empfehlung:

- intern eine generische Methode `submitAnswer(...)`
- optional Komfortmethoden `submitCorrect(...)` und `submitWrong(...)`

### completeIfFinished(...)

Zweck:

- Completion ueber Facade pruefen
- falls keine offenen Items vorhanden sind, Session abschliessen lassen
- aktualisierten `LocalSessionReadState` speichern

Wichtig:

- erzeugt keine neue Session
- startet keine neue Queue

### resetLocalState(...)

Zweck:

- nur den Controller-State zuruecksetzen
- keine Datenbankdaten loeschen
- keine Session abbrechen

Bewertung:

- fuer Tests und spaetere Navigation eventuell nuetzlich
- sollte nicht als fachlicher Session-Abbruch missverstanden werden

[PRÜFEN] Ob `resetLocalState(...)` fuer Version 1 wirklich gebraucht wird.

## 4. Sinnvoller Controller-State

Ein moeglicher State:

- `isLoading`
- `errorMessage`
- `readState`
- `sessionId`
- `canSubmitAnswer`
- `canCompleteSession`
- `lastAction`

### isLoading

Zeigt an:

- Start/Resume laeuft
- Antwort wird eingereicht
- Completion wird geprueft

### errorMessage

UI-neutraler Fehlertext oder technischer Fehlerhinweis.

Wichtig:

- keine finalen UI-Texte
- keine lokalisierte UX-Kopie
- spaeter koennte stattdessen ein Fehlercode sinnvoller sein

[PRÜFEN] Ob `errorMessage` als String ausreicht oder ein Fehler-Typ sinnvoller ist.

### readState

Enthaelt den aktuellen `LocalSessionReadState`.

Dieser bleibt die wichtigste Datenquelle:

- aktuelle Karte
- Wortdaten
- Stage
- Session-Fortschritt
- Submit-/Completion-Faehigkeit

### sessionId

Kann aus `readState.sessionId` abgeleitet werden.

Bewertung:

- als Convenience im State moeglich
- sollte nicht doppelt in Konflikt geraten

Empfehlung:

- wenn gespeichert, immer aus `readState` ableiten

### canSubmitAnswer

Kann aus `readState.canSubmitAnswer` uebernommen werden.

### canCompleteSession

Kann aus `readState.canCompleteSession` uebernommen werden.

### lastAction

Sinnvolle Werte:

- `none`
- `startOrResume`
- `submitCorrect`
- `submitWrong`
- `completeIfFinished`
- `resetLocalState`

Zweck:

- Tests koennen nachvollziehen, welche Aktion zuletzt erfolgreich war.
- Spaetere UI kann optional reagieren, ohne Fachlogik zu erraten.

## 5. Uebernahme Von LocalSessionReadState

Der Controller-State sollte `LocalSessionReadState` moeglichst direkt uebernehmen.

Regeln:

- keine UI-Texte hart einbauen
- keine Labels wie `T-SRS`, `A-SRS`, `Hybrid` erzwingen
- keine Anzeige-Namen fuer Modi im Controller berechnen
- keine Navigation ableiten
- keine Widget-spezifischen Felder aufnehmen

Empfohlen:

- `readState` als Originalobjekt halten
- zentrale Convenience-Getter nur fuer haeufige Flags:
  - `sessionId`
  - `canSubmitAnswer`
  - `canCompleteSession`

Damit bleibt die spaetere UI frei, Begriffe und Layout separat zu bestimmen.

## 6. Erste Tests

Zuerst sinnvolle Tests:

- `local_learning_controller_start_loads_read_state`
- `local_learning_controller_submit_correct_updates_state`
- `local_learning_controller_submit_wrong_updates_state_with_requeue`
- `local_learning_controller_complete_when_finished_updates_state`
- `local_learning_controller_does_not_import_supabase`

### local_learning_controller_start_loads_read_state

Soll pruefen:

- Controller liest `localLearningSessionFacadeProvider`.
- `startOrResume(...)` startet oder setzt lokale Session fort.
- State enthaelt `readState`.
- `readState.currentWordId` ist gesetzt.
- `canSubmitAnswer` ist korrekt.
- keine Supabase-Initialisierung ist noetig.

### local_learning_controller_submit_correct_updates_state

Soll pruefen:

- nach Start kann `submitCorrect(...)` aufgerufen werden.
- State wird aktualisiert.
- `answeredCount` steigt.
- `currentPosition` steigt.
- kein Requeue wird durch den Controller selbst erzeugt.

### local_learning_controller_submit_wrong_updates_state_with_requeue

Soll pruefen:

- nach Start kann `submitWrong(...)` aufgerufen werden.
- State wird aktualisiert.
- Requeue entsteht in der lokalen Facade-/Service-Schicht.
- Controller enthaelt keine eigene Requeue-Logik.

### local_learning_controller_complete_when_finished_updates_state

Soll pruefen:

- Controller ruft `completeIfFinished(...)` der Facade auf.
- State zeigt completed-Zustand, wenn keine offenen Items mehr vorhanden sind.
- Controller erzeugt keine neue Session.

### local_learning_controller_does_not_import_supabase

Soll pruefen:

- Controller-Datei importiert keine Supabase-Pakete.
- Test laeuft ohne Supabase-Initialisierung.
- Controller benoetigt weder `SupabaseWordRepository` noch `WordUserView`.

## 7. Warum Neuer Controller Sicherer Ist

Ein neuer Controller ist sicherer als ein direkter Umbau von `learn_mode_controller.dart`.

Gruende:

- `learn_mode_controller.dart` ist sehr gross und stark gekoppelt.
- Er enthaelt alte SRS-, Queue-, Timer-, Hybrid-, Supabase- und UI-nahe Logik.
- Ein direkter Umbau wuerde alte und neue Engine vermischen.
- Fehler waeren schwer zu isolieren.
- Bestehende App-Flows koennten brechen.
- Tests fuer einen kleinen neuen Controller sind deutlich klarer.

Der neue lokale Controller kann:

- klein starten
- nur die lokale Facade nutzen
- ohne UI getestet werden
- spaeter als Adaptergrundlage dienen
- bei Problemen wieder isoliert werden

## 8. Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine bestehende Provider-Ersetzung
- keine Supabase-Entfernung
- keine Supabase-Anbindung
- kein Lernscreen-Umbau
- kein Modusbutton-Umbau
- kein `main.dart`-Umbau
- kein `word_providers.dart`-Umbau
- kein `learn_mode_controller.dart`-Umbau
- kein `WordUserView`-Adapter
- keine Navigation
- keine echten App-Datenmigrationen

Der neue Controller soll nur lokal und testbar vorbereitet werden.

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte sein:

1. Neue Plan-/Testbasis fuer einen lokalen Controller schaffen.
2. Eine neue isolierte Datei planen/erstellen, z. B.:
   - `lib/core/local_database/controllers/local_learning_controller.dart`
   - oder `lib/core/local_database/providers/local_learning_controller_provider.dart`
3. Nur einen minimalen State definieren:
   - `isLoading`
   - `errorMessage`
   - `readState`
   - `lastAction`
4. Nur einen Test schreiben:
   - `local_learning_controller_start_loads_read_state`
5. Test nutzt:
   - temporaeren lokalen Datenbankpfad
   - Seed oder lokale Testdaten
   - `localLearningSessionFacadeProvider`
6. Test prueft:
   - State beginnt leer
   - `startOrResume(...)` laedt `LocalSessionReadState`
   - `canSubmitAnswer` ist korrekt
   - keine Supabase-Initialisierung noetig

Nicht Teil des ersten TDD-Schritts:

- keine Antwortverarbeitung
- keine Completion
- keine UI-Anbindung
- keine alten Controller-Aenderungen
- keine Provider-Ersetzung in bestehender App

## Empfehlung

Der naechste technische Schritt sollte ein neuer isolierter lokaler Lerncontroller sein.

Er sollte gegen `localLearningSessionFacadeProvider` arbeiten und den alten `LearnModeController` nicht beruehren. So bleibt die lokale Offline-first-Schicht testbar, waehrend die bestehende App weiterhin unveraendert laeuft.
