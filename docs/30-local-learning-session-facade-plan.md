# 30 Local Learning Session Facade Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine UI-neutrale `LocalLearningSessionFacade`.

Die Fassade soll die bereits vorhandenen lokalen Services in einer kleinen app-nahen Koordinationsschicht zusammenfassen. Sie soll spaeter ViewModels entlasten, ohne selbst UI, Navigation, Provider, Supabase oder bestehende App-Flows zu kennen.

Die Planung beschreibt keine Implementierung und keinen Dart-Code.

## Warum Eine Fassade Sinnvoll Ist

Aktuell funktioniert die lokale Kette bereits technisch:

1. Progress fuer Kategorie und Modus vorbereiten.
2. Session starten oder fortsetzen.
3. Read-State mit Wortdaten und Stage bauen.

Ohne Fassade muesste ein spaeteres ViewModel diese Reihenfolge selbst kennen und korrekt ausfuehren. Das wuerde das ViewModel frueh mit lokaler Datenlogik belasten.

Eine `LocalLearningSessionFacade` kann diese Reihenfolge kapseln:

- Progress vorbereiten
- lokale Session starten oder fortsetzen
- `LocalSessionReadState` zurueckgeben
- spaeter Antworten einreichen
- danach direkt den naechsten `LocalSessionReadState` zurueckgeben

Sie bleibt trotzdem UI-neutral.

## Grundgrenzen

Die Fassade darf:

- lokale Services koordinieren
- fertige lokale States zurueckgeben
- keine eigene SRS-Fachlogik enthalten
- keine SQLite-Queries selbst schreiben, solange die Services/Repositories das leisten

Die Fassade darf nicht:

- Widgets kennen
- Navigation ausloesen
- UI-Texte oder Labels erzeugen
- Provider kennen
- Supabase kennen
- bestehende App-Flows veraendern
- echte App-Daten importieren
- `LearnModeController` ersetzen

## Koordinierte Services

Die Fassade koordiniert:

- `LocalProgressInitializationService`
- `LocalSrsSessionService`
- `LocalSessionReadService`

### LocalProgressInitializationService

Aufgabe:

- aktive Wort-IDs einer Kategorie laden
- fehlenden `S0`-Progress fuer `categoryId + mode` vorbereiten

Wichtig:

- keine Queue
- keine Stage-Wechsel
- keine Reviews
- keine UI

### LocalSrsSessionService

Aufgabe:

- Session starten oder fortsetzen
- Queue ueber reine SRS-Engine bauen
- Antworten verarbeiten
- Session abschliessen, wenn fertig

Wichtig:

- liefert `LocalSrsSessionState`
- kennt keine Wortanzeigedaten

### LocalSessionReadService

Aufgabe:

- `LocalSrsSessionState` mit Wortdaten und aktueller Stage anreichern
- `LocalSessionReadState` erzeugen

Wichtig:

- liest nur
- veraendert keine Sessions, Progress-Daten oder Review-History

## Sinnvolle Methoden

### startOrResumeLearning(...)

Zweck:

- kompletter lokaler Start-/Resume-Ablauf fuer eine Kategorie, einen Modus und einen Trainingsbereich

Input spaeter:

- `categoryId`
- `LearningMode mode`
- `TrainingArea trainingArea`
- `DateTime now`
- optional `sessionSize`

Output:

- `LocalSessionReadState`

Ablauf:

1. `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)`
2. `LocalSrsSessionService.startOrResumeSession(...)`
3. `LocalSessionReadService.buildReadState(...)`
4. `LocalSessionReadState` zurueckgeben

Wichtig:

- Wenn bereits eine aktive Session existiert, darf keine neue Session erzeugt werden.
- Progress-Initialisierung darf keine doppelten Progress-Eintraege erzeugen.
- Der Read-State-Aufbau darf keine Daten veraendern.

### submitAnswerAndReadNext(...)

Zweck:

- Antwort speichern und direkt den naechsten Read-State liefern

Input spaeter:

- `sessionId`
- `ReviewAnswer answer`
- `DateTime now`

Output:

- `LocalSessionReadState`

Ablauf:

1. `LocalSrsSessionService.submitAnswer(...)`
2. `LocalSessionReadService.buildReadState(...)`
3. `LocalSessionReadState` zurueckgeben

Wichtig:

- Die Fassade entscheidet nicht selbst ueber Stage-Wechsel oder Requeue.
- Das bleibt Aufgabe von `SrsEngine`, `LocalSrsSessionService` und `SrsReviewPersistenceService`.
- Focused-Verhalten bleibt in den bestehenden Services geregelt.

### completeIfFinished(...)

Zweck:

- Session abschliessen, wenn keine offenen Items mehr vorhanden sind
- danach einen Read-State fuer den aktuellen lokalen Zustand zurueckgeben

Moeglicher Input spaeter:

- `sessionId`
- `DateTime now`

Moeglicher Output:

- `LocalSessionReadState`

Offene Entscheidung fuer spaeter:

- [ENTSCHEIDUNG NOTWENDIG] Soll `completeIfFinished(...)` einen `LocalSessionReadState` zurueckgeben oder nur einen einfachen Completion-Status?

Vorschlag:

- Fuer ViewModel-nahe Nutzung ist `LocalSessionReadState` bequem.
- Fuer strikte Trennung kann ein kleiner Completion-Result-Typ besser sein.
- Diese Entscheidung ist nicht blockierend fuer den ersten Start-/Resume-Fassadentest.

## StartOrResumeLearning Im Detail

`startOrResumeLearning(...)` sollte Version 1 genau diese Reihenfolge haben:

1. Progress vorbereiten:
   - `initializeProgressForCategoryAndMode(categoryId, mode, now)`

2. Session starten oder fortsetzen:
   - `startOrResumeSession(categoryId, mode, trainingArea, now, sessionSize)`

3. Read-State bauen:
   - `buildReadState(sessionState)`

4. Read-State zurueckgeben:
   - `LocalSessionReadState`

Warum diese Reihenfolge:

- Ohne Progress-Vorbereitung findet `startOrResumeSession(...)` keine neuen `S0`-Progress-Daten.
- Ohne Session-Start gibt es kein `currentWordId`.
- Ohne Read-State fehlen Wortdaten und Stage fuer spaetere ViewModels.

## SubmitAnswerAndReadNext Im Detail

`submitAnswerAndReadNext(...)` sollte spaeter genau diese Reihenfolge haben:

1. Antwort einreichen:
   - `LocalSrsSessionService.submitAnswer(sessionId, answer, now)`

2. Aktualisierten Session-State erhalten:
   - `LocalSrsSessionState`

3. Naechsten Read-State bauen:
   - `LocalSessionReadService.buildReadState(updatedSessionState)`

4. Read-State zurueckgeben:
   - `LocalSessionReadState`

Wichtig:

- Die Fassade speichert nichts selbst.
- Die Fassade erstellt keine Requeue-Regeln.
- Die Fassade berechnet keine Due-Dates.
- Die Fassade schreibt keine Review-History.

## Erste Tests

Zuerst schreiben:

- `start_or_resume_learning_initializes_progress_starts_session_and_returns_read_state`
  - lokale Kategorie und Woerter existieren
  - Fassade wird aufgerufen
  - Progress wird fuer aktive Woerter erzeugt
  - Session wird gestartet
  - Read-State enthaelt Wortdaten und Stage

- `start_or_resume_learning_reuses_existing_session`
  - erster Aufruf startet Session
  - zweiter Aufruf fuer denselben Kontext erzeugt keine zweite aktive Session
  - Read-State zeigt dieselbe Session

- `start_or_resume_learning_does_not_create_duplicate_progress`
  - mehrfacher Aufruf erzeugt keine doppelten `word_progress`-Eintraege

Danach:

- `submit_answer_and_read_next_returns_updated_read_state`
  - bestehende Session
  - Antwort wird eingereicht
  - Progress/History/Session werden ueber bestehende Services aktualisiert
  - Read-State zeigt naechste Karte oder Completion-Zustand

- `facade_does_not_touch_ui_supabase_or_app_flows`
  - eher Architektur-/Import-Test oder Review-Regel
  - prueft, dass Fassade nur lokale Services kennt

- `complete_if_finished_marks_completed_or_keeps_active`
  - spaeter, wenn Rueckgabeform fuer `completeIfFinished(...)` entschieden ist

## Testdaten

Die ersten Tests sollten wieder In-Memory-SQLite nutzen.

Minimale Testdaten:

- eine Kategorie
- mehrere aktive Woerter mit:
  - `term`
  - `translation`
  - `exampleSentence`
  - `notes`
- `LearningMode.adaptive`
- `TrainingArea.all`
- `now`

Zu pruefen:

- `learning_sessions` enthaelt genau eine aktive Session
- `word_progress` enthaelt Progress fuer aktive Woerter
- `session_items` enthalten Queue-Items
- `LocalSessionReadState.currentWordId != null`
- `currentTerm != null`
- `currentTranslation != null`
- `currentStage == S0`
- `canSubmitAnswer == true`

## Grenzen

Weiterhin nicht Teil der Fassade:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Entfernung
- keine Supabase-Anbindung
- keine echten App-Daten
- kein `LearnModeController`-Umbau
- kein `WordUserView`-Adapter
- keine UI-Texte oder Moduslabels
- keine echten Lernmodus-Buttons
- keine Produktionsdatenbank-Oeffnung
- keine Migration bestehender Supabase-Daten

Die Fassade bleibt ein lokaler, UI-neutraler Koordinationsbaustein.

## Bewertung Vor App-Anbindung

### Vorteile

- ViewModels muessen weniger lokale Service-Reihenfolge kennen.
- Start-/Resume-Ablauf wird einmal zentral getestet.
- Progress-Initialisierung wird nicht in UI-nahe Controller verschoben.
- Session-Start und Read-State-Aufbau bleiben konsistent.
- Spaetere App-Anbindung kann gegen eine kleinere API arbeiten.
- Bestehende App-Flows bleiben bis dahin unangetastet.

### Risiken

- Die Fassade darf nicht zu viel Fachlogik aufnehmen.
- Sie darf keine zweite SRS-Engine werden.
- Sie darf keine direkten SQLite-Queries duplizieren.
- Sie darf nicht schleichend UI-Texte oder ViewModel-Details enthalten.
- Sie darf nicht automatisch echte Daten importieren.

### Risikoreduktion

Regeln fuer die spaetere Implementierung:

- Fassade nur koordinieren lassen.
- Keine neue Stage-, Queue- oder Requeue-Logik in der Fassade.
- Keine UI-Imports.
- Keine Supabase-Imports.
- Alle Fachentscheidungen bleiben in SRS-Engine oder bestehenden lokalen Services.
- Tests zuerst schreiben.

## Empfehlung

Die Fassade ist vor einer App-Anbindung sinnvoll.

Sie sollte aber klein starten:

1. Nur `startOrResumeLearning(...)` implementieren.
2. Nur einen Integrationstest fuer Start/Resume und Read-State schreiben.
3. Danach `submitAnswerAndReadNext(...)` in einem separaten Schritt planen und testen.
4. `completeIfFinished(...)` erst anfassen, wenn die Rueckgabeform entschieden ist.

Der naechste kleinste technische Schritt waere:

- `LocalLearningSessionFacade` mit nur `startOrResumeLearning(...)`
- Test: `start_or_resume_learning_initializes_progress_starts_session_and_returns_read_state`

Alles andere bleibt bewusst spaeter.
