# 20 Local SRS Session Service Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den naechsten Integrationsschritt zwischen der lokalen SQLite-Schicht und der reinen Dart-SRS-Engine.

Es beschreibt keinen Dart-Code und keine UI-Anbindung. Ziel ist ein kleiner `LocalSrsSessionService`, der als Koordinator zwischen Repository-Schicht und `SrsEngine` arbeitet.

Der Service soll:

- aktive Sessions starten oder fortsetzen
- SQLite-Daten in Engine-Inputs uebersetzen
- Engine-Ergebnisse an die Persistenzschicht weitergeben
- keine eigene SRS-Fachlogik enthalten
- keine UI-, Supabase- oder App-Flow-Abhaengigkeit einfuehren

## Grundgrenzen

`LocalSrsSessionService` darf:

- Repositories und lokale Services koordinieren
- `QueueBuildInput` aus lokalen Daten vorbereiten
- `ReviewInput` aus Session-Zustand und Fortschritt vorbereiten
- `SrsEngine.buildSessionQueue(...)` aufrufen
- `SrsEngine.reviewCard(...)` aufrufen
- `QueueBuildResult` ueber `LearningSessionRepository` speichern lassen
- `ReviewResult` ueber `SrsReviewPersistenceService` atomar speichern lassen
- einen UI-neutralen Session-Zustand zurueckgeben

`LocalSrsSessionService` darf nicht:

- Stage-Aufstieg, Rueckfall, Intervalle oder Requeue selbst entscheiden
- Queue-Mischregeln duplizieren
- direkt UI-Zustand, Navigation oder Widgets kennen
- Supabase verwenden
- App-Flows umstellen
- Datenbank-Schema veraendern
- Import, Backup oder Export echter Daten loesen

Die Regel bleibt: Die Engine entscheidet Lernlogik, die SQLite-Schicht speichert, der Session-Service verbindet beide Seiten.

## Rolle Im Zielbild

Der Service sitzt zwischen ViewModel/App-Schicht und lokaler Daten-/Engine-Schicht.

Geplanter Datenfluss:

1. App/ViewModel fordert eine Session fuer Kategorie, Modus und Trainingsbereich an.
2. `LocalSrsSessionService` sucht eine aktive lokale Session.
3. Falls eine aktive Session existiert, wird sie geladen und fortgesetzt.
4. Falls keine aktive Session existiert, laedt der Service Fortschritt, neue Karten und Recent Answers.
5. Der Service baut daraus `QueueBuildInput`.
6. `SrsEngine.buildSessionQueue(...)` erzeugt `QueueBuildResult`.
7. `LearningSessionRepository` speichert Session und Items.
8. App/ViewModel erhaelt einen UI-neutralen Session-State.

Beim Beantworten:

1. App/ViewModel uebergibt Antwort fuer das aktuelle Session-Item.
2. Der Service laedt den aktuellen Fortschritt und Session-Kontext.
3. Der Service baut `ReviewInput`.
4. `SrsEngine.reviewCard(...)` erzeugt `ReviewResult`.
5. `SrsReviewPersistenceService` speichert Progress, History, Session-Item, Requeue und Position atomar.
6. Der Service gibt den naechsten UI-neutralen Session-State zurueck.

## Geplante Methoden

### startOrResumeSession(...)

Zweck:

- Eine aktive Session fuer `categoryId + mode + trainingArea` fortsetzen.
- Nur wenn keine aktive Session existiert, eine neue Session erzeugen.

Geplante Eingaben:

- `categoryId`
- `LearningMode mode`
- `TrainingArea trainingArea`
- `DateTime now`
- optional `sessionSize`, sonst Version-1-Standard `20`

Geplanter Ablauf:

1. `LearningSessionRepository.findActiveSession(...)` aufrufen.
2. Wenn vorhanden:
   - `session_items` laden
   - aktuellen Fortschritt/aktuelles Item bestimmen
   - UI-neutralen Session-State zurueckgeben
3. Wenn nicht vorhanden:
   - faellige Fortschritte ueber `WordProgressRepository.loadDueProgresses(...)` laden
   - neue S0-Fortschritte ueber `WordProgressRepository.loadNewProgresses(...)` laden
   - Recent Answers ueber `ReviewHistoryRepository.loadRecentAnswers(...)` laden
   - `SessionConfig` und `QueueBuildInput` bauen
   - `SrsEngine.buildSessionQueue(...)` aufrufen
   - `LearningSessionRepository.createSessionFromQueueResult(...)` aufrufen
   - neue Session mit Items als UI-neutralen Session-State zurueckgeben

Wichtig:

- Es darf keine zweite aktive Session fuer denselben Kontext entstehen.
- Der partielle Unique-Index in SQLite bleibt die letzte Absicherung gegen parallele Startversuche.
- Wenn ein paralleler Startversuch an der Unique-Regel scheitert, sollte der Service die inzwischen erstellte aktive Session laden.

### getCurrentSessionState(...)

Zweck:

- Den aktuellen lokalen Zustand einer aktiven Session laden, ohne neue Queue zu bauen.

Geplante Eingaben:

- entweder `sessionId`
- oder `categoryId + mode + trainingArea`

Geplanter Rueckgabewert:

- Session-Metadaten
- geordnete Session-Items
- aktuelles Item
- Position
- Anzahl erledigter Items
- Anzahl offener Items
- ob die Session abgeschlossen werden kann

Wichtig:

- Diese Methode darf keine neue Session erzeugen.
- Sie dient auch dem App-Neustart-Szenario.

### submitAnswer(...)

Zweck:

- Eine Antwort fuer das aktuelle Session-Item an die Engine geben und das Ergebnis atomar speichern.

Geplante Eingaben:

- `sessionId`
- `sessionItemId`
- `ReviewAnswer answer`
- `DateTime now`

Geplanter Ablauf:

1. Session und Item laden.
2. Aktuellen `WordProgress` fuer `wordId + categoryId + mode` laden.
3. Recent Answers fuer Fehlerquote laden.
4. Session-spezifische Fehlerzaehler je Wort aus `session_items` ableiten.
5. Restliche Queue-Groesse bestimmen.
6. `SessionContext` bauen.
7. `ReviewInput` bauen.
8. `SrsEngine.reviewCard(...)` aufrufen.
9. `SrsReviewPersistenceService.persistReviewResult(...)` aufrufen.
10. Aktualisierten Session-State laden und zurueckgeben.

Wichtig:

- Bei `TrainingArea.focused` darf die Engine keinen normalen Fortschritt veraendern.
- Focused-Antworten duerfen trotzdem in `review_history` gespeichert werden.
- Requeue wird als neues `session_item` gespeichert.
- Das urspruengliche Item bleibt beantwortet.
- Bei Fehlern in der Persistenz darf kein halber Zustand uebrig bleiben.

### completeSessionIfFinished(...)

Zweck:

- Eine Session abschliessen, wenn keine offenen Items mehr vorhanden sind.

Geplante Eingaben:

- `sessionId`
- `DateTime now`

Geplante Regel:

- Eine Session ist fertig, wenn keine Items mit einem offenen Bearbeitungsstatus mehr vorhanden sind.
- Offene Bearbeitungsstatus fuer Version 1 sind mindestens `queued`, `shown` und `retryPending`.
- Danach ruft der Service `LearningSessionRepository.completeSession(...)` auf.

Wichtig:

- `completed` beendet die aktive Session sauber.
- Danach darf fuer denselben Kontext wieder eine neue aktive Session erzeugt werden.
- Es gibt in Version 1 keinen Status `abandoned`.

## Interne Abhaengigkeiten

Der Service verwendet intern:

- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`
- `SrsReviewPersistenceService`
- `SrsEngine`

Spaeter wahrscheinlich ergaenzend:

- `WordRepository`, um Worttexte fuer den UI-State zu laden
- `CategoryRepository`, falls Session-State Kategorie-Metadaten enthalten soll
- `SettingsRepository`, um spaeter eine Nutzerwahl fuer Sessiongroesse 10/20/40 zu laden

Fuer Version 1 kann `sessionSize = 20` zunaechst als Standard aus der Service-Konfiguration kommen. Eine echte Settings-Anbindung kann spaeter folgen.

## Daten An Die Engine

### Fuer buildSessionQueue(...)

Der Service bereitet vor:

- `SessionConfig`
  - `mode`
  - `trainingArea`
  - `now`
  - `sessionSize = 20`
- `dueReviewProgresses`
  - aus `WordProgressRepository.loadDueProgresses(...)`
- `newProgresses`
  - aus `WordProgressRepository.loadNewProgresses(...)`
- `recentAnswers`
  - aus `ReviewHistoryRepository.loadRecentAnswers(...)`

Die Engine bekommt fertige Listen. Sie fragt keine Datenbank ab.

### Fuer reviewCard(...)

Der Service bereitet vor:

- aktueller `WordProgress`
- `ReviewAnswer`
- `TrainingArea`
- `reviewedAt`
- `SessionContext`
  - `sessionId`
  - `currentPosition`
  - `recentAnswers`
  - `sameSessionWrongCountsByWordId`
  - `remainingQueueSize`

Die Engine gibt ein `ReviewResult` zurueck. Sie speichert nichts selbst.

## Daten Aus Der Engine

### Aus QueueBuildResult

Der Service uebergibt an `LearningSessionRepository`:

- Queue-Items
- Session-Kontext
- Reihenfolge
- Sessiongroesse
- Kategorie, Modus und Trainingsbereich

`newCardPolicy` muss in Version 1 nicht dauerhaft gespeichert werden.

### Aus ReviewResult

Der Service uebergibt an `SrsReviewPersistenceService`:

- `updatedProgress`
- Review-History-Daten
- beantwortetes `session_item`
- Requeue-Entscheidung, falls vorhanden
- neue Position
- Zeitstempel

Die Speicherung muss weiterhin atomar erfolgen.

## UI-Neutraler Session-State

Der Service soll spaeter Daten liefern koennen, die ein ViewModel nutzen kann, ohne dass der Service UI kennt.

Moegliche Felder:

- `sessionId`
- `categoryId`
- `mode`
- `trainingArea`
- `status`
- `sessionSize`
- `currentPosition`
- `totalItems`
- `answeredCount`
- `remainingCount`
- `currentItem`
- `currentWordId`
- `currentStage`
- `isCurrentItemNew`
- `canSubmitAnswer`
- `canCompleteSession`
- `lastReviewResult` optional

Fuer die Anzeige von Begriff, Uebersetzung und Beispielsatz braucht die App spaeter Wortdaten aus `WordRepository`. Das ist Anzeige-/App-Datenlogik und gehoert nicht in die SRS-Engine.

## App-Neustart-Szenario

Ziel:

- App schliessen oder Neustart darf keine neue Queue erzeugen.
- Fehler, Requeue, Position und beantwortete Items bleiben erhalten.

Geplanter Ablauf nach Neustart:

1. App/ViewModel ruft `startOrResumeSession(...)` fuer denselben Kontext auf.
2. Service findet aktive Session.
3. Service laedt `session_items` nach Position.
4. Service berechnet aktuelles offenes Item anhand `current_position` und Status.
5. Service gibt bestehenden Session-State zurueck.
6. Es wird kein `QueueBuildResult` neu erzeugt.

## Noetige Kleine Repository-Ergaenzungen Fuer Den Naechsten Schritt

Die vorhandene lokale Schicht ist bereits nah am Ziel. Fuer den Service koennen spaeter kleine, isolierte Hilfen sinnvoll sein:

- `WordProgressRepository.loadProgress(...)` fuer genau `wordId + categoryId + mode`
- `LearningSessionRepository.loadSessionById(...)`
- `LearningSessionRepository.loadOpenSessionItems(...)` oder ein Status-Filter
- Hilfsmethode, um `sameSessionWrongCountsByWordId` aus `session_items` zu laden
- Hilfsmethode, um das aktuelle offene Item zu bestimmen

Diese Punkte sind Implementierungsdetails fuer den naechsten TDD-Schritt und keine neuen fachlichen Entscheidungen.

## Erste Tests

### start_or_resume_session_creates_new_session_when_none_exists

Ausgang:

- Kategorie mit Woertern und Fortschritt existiert.
- Keine aktive Session fuer `categoryId + mode + trainingArea`.

Erwartung:

- Service laedt due/new Progresses.
- Service ruft `SrsEngine.buildSessionQueue(...)` indirekt auf.
- `LearningSessionRepository` speichert eine aktive Session mit Items.
- Rueckgabe enthaelt Session-State mit erstem offenen Item.

### start_or_resume_session_reuses_active_session

Ausgang:

- Aktive Session existiert bereits.

Erwartung:

- Keine neue Session wird erzeugt.
- Queue wird nicht neu gebaut.
- Bestehende Items und Position werden geladen.

### start_or_resume_session_builds_queue_from_due_and_new_progresses

Ausgang:

- Faellige Reviews, neue S0-Karten und Recent Answers liegen lokal vor.

Erwartung:

- `QueueBuildInput` enthaelt die richtigen Listen.
- Die Engine-Regeln fuer Sessiongroesse, Moduslimit und Fehlerquote werden ueber `SrsEngine` angewendet.

### submit_answer_updates_progress_history_session_and_requeue

Ausgang:

- Aktive Session mit aktuellem Item.
- Antwort ist falsch.

Erwartung:

- Progress wird aktualisiert.
- Review-History wird geschrieben.
- Urspruengliches Item wird beantwortet.
- Requeue-Item wird angelegt.
- `current_position` wird aktualisiert.

### submit_answer_without_requeue_updates_progress_history_and_position

Ausgang:

- Aktive Session mit aktuellem Item.
- Antwort ist richtig.

Erwartung:

- Progress wird aktualisiert.
- Review-History wird geschrieben.
- Session-Item wird beantwortet.
- Kein Requeue-Item wird angelegt.
- Position wird aktualisiert.

### app_restart_scenario_resumes_same_session

Ausgang:

- Aktive Session mit beantworteten und offenen Items existiert.

Erwartung:

- `startOrResumeSession(...)` gibt dieselbe Session zurueck.
- Position, beantwortete Items und Requeue-Items bleiben erhalten.
- Es entsteht keine zweite aktive Session.

### focused_answer_does_not_change_progress_but_can_write_history

Ausgang:

- Aktive Focused-Session.
- Antwort wird eingereicht.

Erwartung:

- `stage`, `passCount` und `nextDueAt` bleiben unveraendert.
- Review-History wird gespeichert.
- Session-Item und Position werden aktualisiert.

### complete_session_if_finished_marks_completed

Ausgang:

- Alle Items einer aktiven Session sind abgeschlossen.

Erwartung:

- Session wird auf `completed` gesetzt.
- Danach kann fuer denselben Kontext wieder eine neue aktive Session entstehen.

### submit_answer_is_atomic_when_persistence_fails

Ausgang:

- Persistenz schlaegt waehrend `submitAnswer(...)` fehl.

Erwartung:

- Kein halber Zustand bleibt gespeichert.
- Progress, History, Session-Item und Position bleiben konsistent.

## Bewusst Noch Nicht Umgesetzt

Nicht Teil dieses Integrationsschritts:

- UI-Anbindung
- Supabase-Entfernung
- echte App-Navigation
- Import echter Daten
- Backup/Export
- Migration alter Supabase-Fortschritte
- DeepL- oder Wortimport-Logik
- UI-Buttons fuer Modi
- Umbenennung sichtbarer UI-Texte
- globale App-State-Architektur
- Nutzerwahl fuer Sessiongroesse 10/20/40
- Sync zwischen Geraeten

## Empfohlener Naechster TDD-Schritt

Als naechster kleiner Umsetzungsschritt bietet sich ein isolierter Test fuer `LocalSrsSessionService.startOrResumeSession(...)` an.

Erster Test:

- `start_or_resume_session_creates_new_session_when_none_exists`

Warum dieser Test zuerst:

- Er prueft die zentrale Verbindung zwischen SQLite-Daten, `QueueBuildInput`, `SrsEngine.buildSessionQueue(...)` und `LearningSessionRepository`.
- Er veraendert keine UI.
- Er braucht keine Supabase-Anbindung.
- Er bleibt vollstaendig im lokalen SRS-/SQLite-Bereich.

Danach sollte direkt folgen:

- `start_or_resume_session_reuses_active_session`

Dieser zweite Test sichert das wichtigste Manipulationsschutz-Szenario ab: App-Neustart oder erneuter Start darf keine neue Session erzeugen, solange eine aktive Session existiert.
