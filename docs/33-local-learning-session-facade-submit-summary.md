# 33 Local Learning Session Facade Submit Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den erweiterten Stand der `LocalLearningSessionFacade` zusammen.

Die Fassade ist weiterhin ein UI-neutraler lokaler Koordinationsbaustein. Sie verbindet lokale Progress-Initialisierung, Session-Start/-Resume, Antwortverarbeitung und Read-State-Aufbau, ohne eigene SRS-Fachlogik, UI, Supabase, Provider, Navigation oder bestehende App-Flows zu kennen.

## Aktuelle Aufgaben Der Fassade

`LocalLearningSessionFacade` uebernimmt jetzt zwei lokale Koordinationsaufgaben:

1. Lernsession starten oder fortsetzen.
2. Antwort einreichen und direkt den aktualisierten Read-State liefern.

Sie entlastet damit spaeter ein ViewModel von der Reihenfolge:

- Progress vorbereiten
- Session starten oder fortsetzen
- Read-State bauen
- Antwort weitergeben
- aktualisierten Read-State bauen

Die Fassade speichert selbst nichts und entscheidet keine Lernregeln.

## Aktuell Umgesetzte Methoden

Umgesetzt sind:

- `startOrResumeLearning(...)`
- `submitAnswerAndReadNext(...)`

Nicht umgesetzt:

- `completeIfFinished(...)`
- gesonderter Completion-Result-Typ
- UI-/Provider-Anbindung

## startOrResumeLearning(...)

`startOrResumeLearning(...)` koordiniert den lokalen Session-Start.

Ablauf:

1. `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)`
   - bereitet fehlenden `S0`-Progress fuer aktive Woerter vor

2. `LocalSrsSessionService.startOrResumeSession(...)`
   - startet eine neue aktive Session oder setzt eine bestehende aktive Session fort

3. `LocalSessionReadService.buildReadState(...)`
   - laedt Wortdaten und Stage fuer die aktuelle Karte

4. Rueckgabe:
   - `LocalSessionReadState`

Abgesichert ist:

- Progress wird fuer aktive Woerter vorbereitet
- es entsteht eine aktive Session
- eine bestehende aktive Session wird wiederverwendet
- es entstehen keine doppelten Progress-Eintraege
- der Read-State enthaelt Wortdaten, Stage und Submit-Status

## submitAnswerAndReadNext(...)

`submitAnswerAndReadNext(...)` koordiniert den lokalen Antwortpfad.

Ablauf:

1. `LocalSrsSessionService.submitAnswer(...)`
   - reicht die Antwort an die bestehende lokale Session-Schicht weiter
   - diese baut `ReviewInput`
   - ruft die reine SRS-Engine auf
   - speichert das Ergebnis atomar ueber `SrsReviewPersistenceService`
   - gibt einen aktualisierten `LocalSrsSessionState` zurueck

2. `LocalSessionReadService.buildReadState(...)`
   - laedt Wortdaten und Stage fuer den aktualisierten Session-State

3. Rueckgabe:
   - `LocalSessionReadState`

Wichtig:

- Die Fassade enthaelt keine eigene Stage-Logik.
- Die Fassade enthaelt keine eigene Requeue-Logik.
- Die Fassade enthaelt keine eigene Focused-Logik.
- Die Fassade macht keine direkten SQLite-Abfragen.
- Die Fassade kennt keine UI und kein Supabase.

## Getestete Antwortfaelle

### Correct

Test:

- `submit_answer_and_read_next_correct_returns_updated_read_state`

Abgesichert wird:

- Rueckgabe bleibt ein aktualisierter `LocalSessionReadState`
- `sessionId` bleibt gleich
- `answeredCount` steigt
- `currentPosition` steigt
- `review_history` enthaelt ein `correct`-Event
- urspruengliches `session_item` ist `answered`
- kein Requeue-Item wird erzeugt
- keine zweite aktive Session entsteht

### Wrong + Requeue

Test:

- `submit_answer_and_read_next_wrong_returns_updated_read_state_with_requeue`

Abgesichert wird:

- Rueckgabe bleibt ein aktualisierter `LocalSessionReadState`
- `sessionId` bleibt gleich
- `answeredCount` steigt
- `currentPosition` steigt
- `review_history` enthaelt ein `wrong`-Event
- urspruengliches `session_item` ist `answered`
- ein Requeue-Item mit `retryPending` wird erzeugt
- keine zweite aktive Session entsteht

### Focused Ohne Progression

Test:

- `submit_answer_and_read_next_focused_does_not_change_progress`

Abgesichert wird:

- `TrainingArea.focused` veraendert keinen normalen SRS-Progress
- `stage` bleibt unveraendert
- `pass_count` bleibt unveraendert
- `next_due_at` bleibt unveraendert
- `review_history` enthaelt ein Event mit `training_area_id = focused`
- urspruengliches `session_item` ist `answered`
- kein Requeue-Item wird erzeugt
- `currentPosition` steigt
- Rueckgabe bleibt ein `LocalSessionReadState`
- keine zweite aktive Session entsteht

## Vollstaendige Testliste Der Fassade

Datei:

- `test/core/local_database/local_learning_session_facade_test.dart`

Tests:

- `start_or_resume_learning_initializes_progress_starts_session_and_returns_read_state`
- `start_or_resume_learning_reuses_existing_session`
- `start_or_resume_learning_does_not_create_duplicate_progress`
- `submit_answer_and_read_next_correct_returns_updated_read_state`
- `submit_answer_and_read_next_wrong_returns_updated_read_state_with_requeue`
- `submit_answer_and_read_next_focused_does_not_change_progress`

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
- kein `completeIfFinished(...)`
- keine automatische Completion nach Submit

Die bestehende App nutzt diese Fassade noch nicht.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Completion-Verhalten planen:
   - Soll eine Fassade-Methode `completeIfFinished(...)` einen `LocalSessionReadState` oder einen eigenen Result-Typ zurueckgeben?

2. Completion-Read-State testen:
   - letzte Karte beantworten
   - `currentWordId == null`
   - `canSubmitAnswer == false`
   - `canCompleteSession == true`

3. Danach erst `completeIfFinished(...)` minimal per TDD implementieren.

4. Lokale Datenbereitstellung fuer echte Kategorien und Woerter planen.

5. Vor jeder App-Anbindung alle lokalen SRS-/SQLite-/Repository-/Facade-Tests gemeinsam ausfuehren.

## Warum Noch Keine UI-Anbindung

Trotz stabilerer lokaler Fassade sollte noch keine UI-Anbindung erfolgen.

Gruende:

- Completion-Verhalten ist noch nicht final ueber die Fassade gekapselt.
- Produktionsdatenbank-Oeffnung ist noch nicht geplant.
- echte lokale Wortdaten/Seed-/Importstrategie sind noch offen.
- bestehende App-Controller sind gross und riskant.
- Supabase ist noch aktiv und darf nicht unkontrolliert ersetzt werden.
- UI-Modusnamen und Trainingsbereiche sind fachlich geplant, aber noch nicht angebunden.

Empfehlung:

Der naechste kleine Schritt sollte ein Completion-Plan fuer die Fassade sein, nicht UI-Integration.
