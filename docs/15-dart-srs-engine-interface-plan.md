# 15 Dart SRS Engine Interface Plan

Stand: 2026-05-13

## Ziel

Dieses Dokument plant ein minimales reines Dart-Interface für die lokale SRS-Engine Version 1. Es beschreibt Architektur, Datenformen und Methoden, aber enthält keinen Dart-Code.

Die Engine kapselt nur Lernlogik. Sie kennt keine UI, keine SQLite-Datenbank, keine Supabase-APIs, keine Flutter-Widgets und keine Persistenz.

## Strikte Grenzen

Die Engine darf nicht enthalten:

- SQLite-Abhängigkeit
- Supabase-Abhängigkeit
- Flutter-Widget-Code
- Navigation
- Repository-Logik
- Persistenzlogik
- Riverpod-/Provider-Abhängigkeit
- UI-Texte oder visuelle Zustände

Die Engine darf enthalten:

- Stage-Wechsel
- `pass_count`-Entscheidungen
- Rückfallregeln
- `next_due_at`-Berechnung
- Requeue-Entscheidungen
- Session-Queue-Aufbau
- Entscheidung, ob neue S0-Karten eingeführt werden dürfen

## Benötigte Enums

### SrsStage

Repräsentiert S0-S5.

- `s0`
- `s1`
- `s2`
- `s3`
- `s4`
- `s5`

Zweck:

- vermeidet magische Zahlen in Engine-Regeln
- macht Aufstieg/Rückfall testbar

### LearningMode

Repräsentiert die drei Lernmodi.

- `time`
- `adaptive`
- `hybrid`

Nutzerlabels bleiben außerhalb der Engine:

- `time` -> Nach Zeitplan
- `adaptive` -> Intensiv lernen
- `hybrid` -> Ausgewogen lernen

Entscheidung für Version 1:

- `LearningMode` wird als Dart-Enum bzw. Dart-Konstante geführt.
- Es wird keine eigene SQLite-Tabelle `learning_modes` geplant.
- In SQLite wird nur der stabile Mode-Wert im Fortschritt gespeichert.

### TrainingArea

Repräsentiert den Trainingsbereich.

- `all`
- `reviewOnly`
- `focused`

Bedeutung:

- `all`: neue Karten plus Wiederholungen
- `reviewOnly`: keine neuen S0-Karten
- `focused`: Gezielt üben, Version 1 ohne normale SRS-Progression

### ReviewAnswer

Repräsentiert die Antwortbewertung.

- `correct`
- `wrong`

Version 1 bleibt absichtlich binär. Keine Zwischenstufen wie "fast richtig".

### QueueItemStatus

Repräsentiert den Status eines Session-Items.

- `queued`
- `shown`
- `answered`
- `retryPending`
- `done`
- `difficult`

Hinweis: Die Engine darf Statusvorschläge zurückgeben; das Repository speichert sie.

### RequeueReason

Repräsentiert, warum eine Karte erneut eingeplant wird.

- `wrongAnswer`
- `repeatedWrongAnswer`
- `markedDifficult`

### NewCardPolicy

Optionaler interner Entscheidungsstatus.

- `allowed`
- `blockedByTrainingArea`
- `blockedByErrorRate`
- `blockedBySessionLimit`
- `blockedByDueReviews`

## Reine Datenmodelle

Alle Modelle sind reine Datencontainer. Sie enthalten keine Datenbankzugriffe.

### WordProgress

Minimaler Fortschrittszustand einer Karte pro Wort, Kategorie und Modus.

Felder:

- `wordId`
- `categoryId`
- `mode`
- `stage`
- `passCount`
- `wrongCount`
- `nextDueAt`
- `lastReviewedAt`
- `sameSessionWrongCount`

Optional später:

- `totalCorrect`
- `totalWrong`
- `lapses`
- `isMasteredDisplayOnly`

Regel:

- `isMasteredDisplayOnly` darf keine Engine-Entscheidung steuern.

### ReviewInput

Input für eine einzelne Antwort.

Felder:

- `progress`
- `answer`
- `mode`
- `trainingArea`
- `reviewedAt`
- `sessionContext`

Wenn `trainingArea = focused`, darf die Engine in Version 1 keinen normalen SRS-Fortschritt verändern.

### ReviewResult

Output einer Review-Entscheidung.

Felder:

- `updatedProgress`
- `stageChanged`
- `oldStage`
- `newStage`
- `oldPassCount`
- `newPassCount`
- `nextDueAt`
- `requeueDecision`
- `reviewHistoryEvent`
- `warnings`

Das Repository speichert `updatedProgress`, Session-Änderungen und `reviewHistoryEvent`.

### SessionConfig

Konfiguration für Queue-Aufbau.

Felder:

- `mode`
- `trainingArea`
- `sessionSize`
- `maxNewCards`
- `now`

Version-1-Defaults:

- `sessionSize = 20`
- T-SRS `maxNewCards = 5`
- Hybrid `maxNewCards = 8`
- A-SRS: bis zu 20 S0-Karten, wenn keine aktiven Wiederholungen vorhanden sind
- A-SRS: 2:1-Mischregel, wenn aktive Wiederholungen vorhanden sind

### SessionContext

Sessionbezogener Zustand für Review-Entscheidungen.

Felder:

- `sessionId`
- `currentPosition`
- `recentAnswers`
- `sameSessionWrongCountsByWordId`
- `remainingQueueSize`

Zweck:

- Fehlerquote 3 aus 10 prüfen
- Mehrfach-Requeue bestimmen
- technische Sessiongrenze einhalten

### QueueBuildInput

Input zum Erzeugen einer Session-Queue.

Felder:

- `mode`
- `trainingArea`
- `now`
- `sessionConfig`
- `dueReviewProgresses`
- `newProgresses`
- `notDueProgresses`
- `recentAnswers`

Regel:

- Das Repository liefert fertige Listen.
- Die Engine fragt keine Datenbank ab.

### QueueBuildResult

Output des Queue-Aufbaus.

Felder:

- `items`
- `newCardsIncluded`
- `reviewsIncluded`
- `newCardPolicy`
- `warnings`

Das Repository speichert daraus `learning_sessions` und `session_items`.

### SessionItem

Reines Queue-Item.

Felder:

- `wordId`
- `categoryId`
- `mode`
- `stageAtEnqueue`
- `position`
- `status`
- `dueAtEnqueue`
- `retryAfterPosition`
- `requeueReason`

### RequeueDecision

Output der Requeue-Logik.

Felder:

- `shouldRequeue`
- `targetOffset`
- `targetPosition`
- `status`
- `reason`
- `sameSessionWrongCount`

Version-1-Regeln:

- erster Fehler derselben Karte in derselben Session: nach ca. 10 anderen Karten
- zweiter Fehler derselben Karte in derselben Session: nach ca. 5 anderen Karten
- dritter Fehler derselben Karte in derselben Session: schwierig markieren und ans Ende der aktuellen Session-Queue

### ReviewHistoryEvent

Reines Ereignismodell, das das Repository speichern kann.

Felder:

- `wordId`
- `categoryId`
- `mode`
- `trainingArea`
- `answer`
- `reviewedAt`
- `oldStage`
- `newStage`
- `oldPassCount`
- `newPassCount`
- `oldNextDueAt`
- `newNextDueAt`
- `requeueReason`

## Engine-Klassen und Services

### SrsEngine

Fassade für die Engine.

Aufgaben:

- zentrale Methode für Review-Entscheidung
- zentrale Methode für Queue-Aufbau
- delegiert intern an spezialisierte Services

Sinnvolle Methoden:

- `reviewCard(...)`
- `buildSessionQueue(...)`
- `shouldIntroduceNewCards(...)`

### StageTransitionService

Kapselt Aufstieg und Rückfall.

Aufgaben:

- `pass_count`-Schwellen anwenden
- Aufstieg S0-S5 bestimmen
- Rückfall bei Fehler bestimmen
- T-SRS-Tagesaufstieg begrenzen
- Gezielt üben ohne SRS-Fortschritt behandeln

Sinnvolle Methoden:

- `applyStageTransition(...)`
- `requiredCorrectAnswersForStage(...)`
- `fallbackStageForWrongAnswer(...)`
- `canAdvanceToday(...)`

### DueDateCalculator

Kapselt `next_due_at`.

Aufgaben:

- T-SRS-Intervalle berechnen
- Hybrid-Intervalle berechnen
- A-SRS ohne harte Zeitblockade behandeln
- S5 wiederholbar halten

Sinnvolle Methoden:

- `calculateNextDueAt(...)`
- `isDue(...)`
- `intervalForStageAndMode(...)`

### QueueBuilder

Kapselt Session-Queue-Aufbau.

Aufgaben:

- endliche Queue mit Standardgröße 20 bauen
- T-SRS maximal 5 neue S0-Karten
- Hybrid maximal 8 neue S0-Karten
- A-SRS bis zu 20 S0-Karten, wenn keine aktiven Wiederholungen vorhanden sind
- A-SRS mit 2:1-Mischregel, wenn aktive Wiederholungen vorhanden sind: zwei aktive Wiederholungskarten, dann eine neue S0-Karte
- freie Plätze mit neuen S0-Karten auffüllen, wenn nicht genug Wiederholungskarten vorhanden sind
- Fehlerquote-Regel anwenden

Sinnvolle Methoden:

- `buildSessionQueue(...)`
- `selectDueReviews(...)`
- `selectNewCards(...)`
- `mixReviewsAndNewCards(...)`

### RequeueService

Kapselt Requeue nach Fehlern.

Aufgaben:

- erster Fehler nach ca. 10 Karten
- zweiter Fehler nach ca. 5 Karten
- dritter Fehler als schwierig ans Queue-Ende
- keine dauerhaft verschwundenen Karten

Sinnvolle Methoden:

- `applyRequeue(...)`
- `sameSessionWrongCountFor(...)`
- `targetPositionForWrongAnswer(...)`

### NewCardPolicyService

Kapselt die Frage, ob neue S0-Karten eingeführt werden dürfen.

Aufgaben:

- TrainingArea beachten
- Fehlerquote 3 aus 10 beachten
- Moduslimit beachten
- A-SRS nicht hart blockieren, sondern nur Auto-Nachschub stoppen

Sinnvolle Methoden:

- `shouldIntroduceNewCards(...)`
- `maxNewCardsForMode(...)`
- `isBlockedByRecentErrors(...)`

## Methoden der Engine

### reviewCard

Zweck:

- verarbeitet eine Antwort auf eine Karte
- liefert neue Progress-Entscheidung und Requeue-Entscheidung

Input:

- `ReviewInput`

Output:

- `ReviewResult`

Speichert nicht selbst.

### buildSessionQueue

Zweck:

- baut eine endliche Session-Queue aus bereits geladenen Fortschritten

Input:

- `QueueBuildInput`

Output:

- `QueueBuildResult`

Speichert nicht selbst.

### calculateNextDueAt

Zweck:

- berechnet das nächste Fälligkeitsdatum nach Modus und Stufe

Input:

- Modus
- Stage
- aktueller Zeitpunkt
- Antwort

Output:

- `DateTime` oder kein harter Termin für A-SRS-Entscheidungen

### applyStageTransition

Zweck:

- entscheidet Aufstieg, Gleichbleiben oder Rückfall

Input:

- `WordProgress`
- `ReviewAnswer`
- `LearningMode`
- `TrainingArea`
- Zeitpunkt

Output:

- neuer Stage-/Pass-Count-Zustand

### applyRequeue

Zweck:

- entscheidet, ob und wo eine falsch beantwortete Karte erneut erscheint

Input:

- `SessionContext`
- `WordProgress`
- Antwort

Output:

- `RequeueDecision`

### shouldIntroduceNewCards

Zweck:

- entscheidet, ob die Engine neue S0-Karten in diese Session aufnehmen darf

Input:

- `LearningMode`
- `TrainingArea`
- `SessionContext`
- vorhandene Review-Anzahl
- vorhandene S0-Anzahl
- Fehlerhistorie

Output:

- `NewCardPolicy`
- maximale neue Karten

## Input-Grenzen

Die Engine bekommt vom Repository:

- fertige `WordProgress`-Listen
- fällige Wiederholungen
- neue S0-Karten
- nicht fällige Karten, falls für A-SRS/Hybrid nötig
- aktuelle Session-Konfiguration
- aktuelle Session-Position
- Fehlerhistorie der Session
- aktuelle Zeit als Input

Die Engine macht nicht:

- keine Datenbankabfrage
- kein Laden von Kategorien
- kein Laden von Wörtern
- kein Speichern von Progress
- kein Speichern von Sessions

## Output-Grenzen

Die Engine gibt zurück:

- aktualisierte Progress-Daten
- Queue-Items
- Requeue-Entscheidungen
- Due-Date-Entscheidungen
- Review-History-Event-Daten
- Warnungen/Policy-Gründe

Das Repository entscheidet danach über:

- Speichern in `word_progress`
- Speichern in `review_history`
- Speichern in `learning_sessions`
- Speichern in `session_items`
- Transaktionen

## Priorisierte Tests Für Das Erste Engine-Interface

Die ersten 10 Tests sollten reine Engine-Tests sein, ohne SQLite und ohne Flutter.

1. S0 richtig steigt nach S1 auf.
   - Erwartung: Stage S1, `pass_count = 0`.

2. S1 einmal richtig bleibt S1.
   - Erwartung: `pass_count = 1`.

3. S1 zweimal richtig steigt nach S2 auf.
   - Erwartung: Stage S2, `pass_count = 0`.

4. S5 falsch fällt auf S3.
   - Erwartung: Stage S3, `pass_count = 0`, Requeue.

5. T-SRS S1 am selben Tag festigt ohne Aufstieg.
   - Erwartung: bleibt S1, kein S2 am selben Tag.

6. T-SRS berechnet feste Intervalle.
   - Erwartung: S1 1 Tag, S2 3 Tage, S3 7 Tage, S4 14 Tage, S5 30 Tage.

7. A-SRS darf bei erfüllten `pass_count`-Schwellen am selben Tag bis S5 aufsteigen.
   - Erwartung: keine Zeitblockade.

8. A-SRS Queue mit 200 S0 und keinen aktiven Wiederholungen enthält maximal 20 S0-Karten.
   - Erwartung: endliche Queue, kein Auto-Endlos-Refill.

9. Fehlerquote 3 aus 10 stoppt neuen S0-Auto-Nachschub.
   - Erwartung: T-SRS/Hybrid blockieren neue S0; A-SRS stoppt nur Auto-Nachschub.

10. Mehrfach-Requeue derselben Karte in derselben Session.
   - Erwartung: erster Fehler ca. 10 Karten, zweiter Fehler ca. 5 Karten, dritter Fehler schwierig ans Session-Ende.

## Offene Punkte

Für das erste Dart-SRS-Engine-Interface sind aktuell keine fachlichen Blocker offen.

Spätere Erweiterungen können nach den ersten Tests entschieden werden, z. B. feinere Mischgewichte, UI-wählbare Sessiongrößen oder zusätzliche Statistiken.
