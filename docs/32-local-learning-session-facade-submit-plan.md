# 32 Local Learning Session Facade Submit Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant `submitAnswerAndReadNext(...)` fuer die UI-neutrale `LocalLearningSessionFacade`.

Die Methode soll den Antwortpfad so kapseln, dass spaetere ViewModels nicht selbst `LocalSrsSessionService.submitAnswer(...)` und `LocalSessionReadService.buildReadState(...)` in der richtigen Reihenfolge koordinieren muessen.

Die Planung beschreibt keine Implementierung und keinen Dart-Code.

## Ziel Von submitAnswerAndReadNext(...)

`submitAnswerAndReadNext(...)` soll:

1. eine Antwort an `LocalSrsSessionService.submitAnswer(...)` weitergeben
2. den aktualisierten `LocalSrsSessionState` erhalten
3. danach `LocalSessionReadService.buildReadState(...)` aufrufen
4. einen aktualisierten `LocalSessionReadState` zurueckgeben

Damit wird aus einer Antwort direkt ein neuer lesbarer Zustand fuer eine spaetere ViewModel-Schicht.

## Sinnvolle Parameter

Fuer Version 1 reichen:

- `String sessionId`
- `ReviewAnswer answer`
- `DateTime now`

Rueckgabe:

- `LocalSessionReadState`

Bewusst nicht als Parameter:

- `wordId`
- `categoryId`
- `mode`
- `trainingArea`
- `sessionItemId`

Begruendung:

- `LocalSrsSessionService.submitAnswer(...)` kennt bereits die aktive Session und bestimmt das aktuelle Session-Item.
- Dadurch muss die Fassade keine Session-Item-Auswahl selbst duplizieren.
- Die Fassade bleibt Koordinatorin.

## Geplanter Ablauf

`submitAnswerAndReadNext(...)` soll genau diese Reihenfolge haben:

1. Antwort einreichen:
   - `LocalSrsSessionService.submitAnswer(sessionId, answer, now)`

2. Aktualisierten Session-State erhalten:
   - Rueckgabe ist `LocalSrsSessionState`

3. Read-State bauen:
   - `LocalSessionReadService.buildReadState(updatedSessionState)`

4. Ergebnis zurueckgeben:
   - `LocalSessionReadState`

## Was Die Methode Nicht Tun Darf

Die Fassade darf in `submitAnswerAndReadNext(...)` nicht:

- eigene Stage-Logik enthalten
- eigene Requeue-Logik enthalten
- eigene Due-Date-Logik enthalten
- eigene Queue-Logik enthalten
- direkte SQLite-Abfragen machen
- `word_progress` selbst aktualisieren
- `review_history` selbst schreiben
- `session_items` selbst veraendern
- UI-Logik enthalten
- UI-Texte oder Labels erzeugen
- Navigation ausloesen
- Provider kennen
- Supabase verwenden
- bestehende App-Flows veraendern

Die Lernlogik bleibt in der reinen SRS-Engine.

Die Persistenz bleibt in:

- `LocalSrsSessionService`
- `SrsReviewPersistenceService`
- Repositories

Der Read-State-Aufbau bleibt in:

- `LocalSessionReadService`

## Zu Testende Faelle

### Richtige Antwort

Fall:

- Session ist aktiv
- aktuelle Karte wird korrekt beantwortet

Erwartung:

- `LocalSrsSessionService.submitAnswer(...)` verarbeitet die Antwort
- Progress, Review-History, Session-Item und Position werden durch bestehende Services aktualisiert
- Fassade gibt aktualisierten `LocalSessionReadState` zurueck
- Read-State zeigt naechste Karte oder Completion-Zustand

### Falsche Antwort Mit Requeue

Fall:

- Session ist aktiv
- aktuelle Karte wird falsch beantwortet

Erwartung:

- Stage/Rueckfall wird durch Engine und Session-Service behandelt
- Requeue-Item wird durch bestehende Persistenz erzeugt, falls Engine dies entscheidet
- Fassade gibt aktualisierten `LocalSessionReadState` zurueck
- Read-State zeigt weiterhin einen nutzbaren Zustand

### Focused-Antwort

Fall:

- Session laeuft im Trainingsbereich `TrainingArea.focused`
- Antwort wird gegeben

Erwartung:

- normaler SRS-Progress bleibt unveraendert
- Review-History darf geschrieben werden
- Session-Item und Position duerfen aktualisiert werden
- Fassade gibt aktualisierten `LocalSessionReadState` zurueck

### Naechste Karte Oder Completion-Zustand

Fall:

- Antwort war letzte offene Karte

Erwartung:

- Read-State darf `currentWordId == null` haben
- Wortfelder bleiben `null`
- `canSubmitAnswer == false`
- `canCompleteSession` kann `true` sein

Wichtig:

- Completion selbst sollte nicht automatisch in `submitAnswerAndReadNext(...)` passieren, solange `completeIfFinished(...)` separat geplant ist.

## Erste Tests

Zuerst umsetzen:

- `submit_answer_and_read_next_correct_returns_updated_read_state`

Warum zuerst:

- kleinster stabiler Pfad
- keine Requeue-Komplexitaet
- nutzt bereits getestete `LocalSrsSessionService.submitAnswer(...)`-Logik
- beweist die neue Fassadenreihenfolge: submit -> read

Danach:

- `submit_answer_and_read_next_wrong_returns_updated_read_state_with_requeue`
  - prueft falsche Antwort und Requeue-Item

- `submit_answer_and_read_next_focused_does_not_change_progress`
  - prueft focused-Verhalten ueber die Fassade

Spaeter ergaenzbar:

- `submit_answer_and_read_next_returns_completion_read_state_after_last_item`
  - prueft `currentWordId == null`
  - prueft `canSubmitAnswer == false`
  - prueft `canCompleteSession == true`

## Testaufbau Fuer Den Ersten TDD-Schritt

Minimaler Test fuer `submit_answer_and_read_next_correct_returns_updated_read_state`:

1. In-Memory-SQLite oeffnen.
2. Kategorie und mehrere Woerter anlegen.
3. `LocalLearningSessionFacade.startOrResumeLearning(...)` aufrufen.
4. `sessionId` aus dem Read-State verwenden.
5. `submitAnswerAndReadNext(sessionId, ReviewAnswer.correct, now + 1 Minute)` aufrufen.
6. Pruefen:
   - Rueckgabe ist `LocalSessionReadState`
   - `sessionId` bleibt gleich
   - `answeredCount` ist erhoeht
   - `currentPosition` ist erhoeht
   - `currentWordId` zeigt naechste Karte oder ist `null`, falls Session fertig
   - `review_history` hat einen Eintrag
   - erstes `session_item` ist beantwortet
   - keine zweite Session wurde erzeugt

## Grenzen

Weiterhin nicht Teil dieses Schritts:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- keine echten App-Daten
- keine Produktionsdatenbank-Oeffnung
- kein `LearnModeController`-Umbau
- kein `WordUserView`-Adapter
- kein `completeIfFinished(...)`

## Risiken

Moegliche Risiken:

- Die Fassade koennte versehentlich Session-Service-Logik duplizieren.
- Die Fassade koennte direkte DB-Zugriffe bekommen und dadurch schwerer testbar werden.
- Completion-Verhalten koennte vorschnell in Submit vermischt werden.
- Focused-Verhalten koennte doppelt geregelt werden, obwohl es bereits im bestehenden lokalen Stack abgesichert ist.

Gegenmassnahmen:

- Fassade nur delegieren lassen.
- Keine neuen Regeln in die Fassade schreiben.
- Pro Schritt nur einen Fall testen.
- Completion separat planen.

## Empfohlener Kleinster TDD-Schritt

Der kleinste erste TDD-Schritt ist:

1. `submitAnswerAndReadNext(...)` in `LocalLearningSessionFacade` ergaenzen.
2. Nur den Test `submit_answer_and_read_next_correct_returns_updated_read_state` schreiben.
3. Keine Requeue-Tests in diesem Schritt.
4. Keine Focused-Tests in diesem Schritt.
5. Keine Completion-Methode in diesem Schritt.

Dieser Schritt ist klein, weil er nur den sicheren korrekten Antwortpfad ueber bereits getestete Services verbindet.
