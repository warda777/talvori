# 31 Local Learning Session Facade Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst die erste minimale `LocalLearningSessionFacade` zusammen.

Die Fassade ist ein UI-neutraler lokaler Koordinationsbaustein. Sie verbindet Progress-Initialisierung, Session-Start/-Resume und Read-State-Aufbau, ohne UI, Supabase, Provider, Navigation oder bestehende App-Flows zu kennen.

## Aufgabe Der Fassade

`LocalLearningSessionFacade` uebernimmt den lokalen Start-/Resume-Ablauf fuer eine Lernsession.

Sie sorgt dafuer, dass ein spaeteres ViewModel nicht selbst diese Reihenfolge kennen muss:

1. Progress fuer aktive Woerter vorbereiten.
2. Lokale Session starten oder fortsetzen.
3. Wortdaten und Stage fuer die aktuelle Karte lesen.
4. `LocalSessionReadState` zurueckgeben.

Die Fassade enthaelt keine eigene SRS-Fachlogik.

## Koordinierte Services

Die Fassade koordiniert genau diese Services:

- `LocalProgressInitializationService`
- `LocalSrsSessionService`
- `LocalSessionReadService`

### LocalProgressInitializationService

Wird verwendet, um fuer aktive Woerter einer Kategorie fehlenden `S0`-Progress im gewuenschten Modus vorzubereiten.

### LocalSrsSessionService

Wird verwendet, um eine lokale Session zu starten oder eine bestehende aktive Session fortzusetzen.

### LocalSessionReadService

Wird verwendet, um den zurueckgegebenen `LocalSrsSessionState` mit Wortdaten und aktueller Stage anzureichern.

## Umgesetzte Methode

Umgesetzt wurde nur:

- `startOrResumeLearning(...)`

Parameter:

- `categoryId`
- `LearningMode mode`
- `TrainingArea trainingArea`
- `DateTime now`
- optional `sessionSize`

Rueckgabe:

- `LocalSessionReadState`

Noch nicht umgesetzt:

- `submitAnswerAndReadNext(...)`
- `completeIfFinished(...)`

## Ablauf Von startOrResumeLearning(...)

`startOrResumeLearning(...)` fuehrt genau diese Schritte aus:

1. Progress vorbereiten:
   - `initializeProgressForCategoryAndMode(categoryId, mode, now)`

2. Session starten oder fortsetzen:
   - `startOrResumeSession(categoryId, mode, trainingArea, now, sessionSize)`

3. Read-State bauen:
   - `buildReadState(sessionState)`

4. Ergebnis zurueckgeben:
   - `LocalSessionReadState`

Wichtig:

- Bei erneutem Aufruf fuer denselben Kontext entsteht keine zweite aktive Session.
- Erneute Progress-Initialisierung erzeugt keine doppelten `word_progress`-Eintraege.
- Die Fassade schreibt selbst keine Review-History.
- Die Fassade berechnet keine Stage-Wechsel, Due Dates, Queue-Regeln oder Requeue-Regeln.

## Tests

Datei:

- `test/core/local_database/local_learning_session_facade_test.dart`

Vorhandene Tests:

- `start_or_resume_learning_initializes_progress_starts_session_and_returns_read_state`
  - prueft, dass Progress fuer aktive Woerter erzeugt wird
  - prueft, dass eine aktive Session entsteht
  - prueft, dass Session-Items entstehen
  - prueft, dass ein `LocalSessionReadState` mit `currentWordId`, Wortdaten, `S0`-Stage und `canSubmitAnswer == true` zurueckkommt

- `start_or_resume_learning_reuses_existing_session`
  - prueft, dass ein zweiter Aufruf fuer denselben Kontext keine zweite aktive Session erzeugt
  - prueft, dass derselbe Session-/Read-Kontext zurueckkommt

- `start_or_resume_learning_does_not_create_duplicate_progress`
  - prueft, dass wiederholter Aufruf keine doppelten `word_progress`-Eintraege erzeugt
  - prueft eindeutige Kombinationen aus `word_id + category_id + mode_id`

Die Tests nutzen eine In-Memory-SQLite-Datenbank und bleiben vollstaendig lokal.

## Weiterhin Geltende Grenzen

Nicht umgesetzt:

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
- keine UI-Texte oder Moduslabels
- keine echten Lernmodus-Buttons
- kein `submitAnswerAndReadNext(...)`
- kein `completeIfFinished(...)`

Die bestehende App nutzt diese Fassade noch nicht.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Abschlussdokumentation fuer die gesamte lokale SRS-/SQLite-Kette aktualisieren.
2. Einen Plan fuer `submitAnswerAndReadNext(...)` erstellen, bevor Code geschrieben wird.
3. Erst danach `submitAnswerAndReadNext(...)` minimal per TDD implementieren.
4. Klaeren, ob `completeIfFinished(...)` spaeter einen `LocalSessionReadState` oder einen eigenen Completion-Result-Typ zurueckgeben soll.
5. Lokale Datenbereitstellung fuer echte Kategorien und Woerter planen.
6. Erst nach stabiler lokaler Fassade eine ViewModel-/Provider-Anbindung planen.

Empfehlung:

Der naechste technische Schritt sollte nicht sofort UI-Anbindung sein. Sinnvoller ist zuerst ein kleiner Plan fuer `submitAnswerAndReadNext(...)`, damit auch der Antwortpfad ueber die Fassade sauber, testbar und UI-neutral bleibt.
