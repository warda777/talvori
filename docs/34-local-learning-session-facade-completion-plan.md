# 34 Local Learning Session Facade Completion Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant das Completion-Verhalten fuer die `LocalLearningSessionFacade`.

Ziel ist eine kleine, UI-neutrale Facade-Erweiterung, die eine lokale Session nur dann abschliesst, wenn keine offenen Items mehr vorhanden sind. Die Completion darf keine neue Session erzeugen, keine Queue neu bauen und keine Progress-Initialisierung ausloesen.

Completion bedeutet in Version 1:

- Eine Session wird auf `completed` gesetzt, wenn keine offenen Items mehr vorhanden sind.
- `completed_at` wird gesetzt.
- Die Session ist danach nicht mehr die aktive Session fuer ihren Kontext.
- Danach darf spaeter wieder eine neue aktive Session fuer dieselbe Kombination aus `categoryId + mode + trainingArea` entstehen.
- Es gibt weiterhin keinen `abandoned`-Status.

Offene Item-Status bleiben:

- `queued`
- `shown`
- `retryPending`

Nicht offene Item-Status bleiben:

- `answered`
- `done`
- `difficult`

## Methodische Optionen

### Option A: completeIfFinished(...)

Signatur-Idee:

- `completeIfFinished({required String sessionId, required DateTime now})`

Rueckgabe-Optionen:

- `LocalSessionReadState`
- `bool`
- eigener `LocalSessionCompletionResult`

Vorteile:

- Name ist kurz und entspricht bereits der bestehenden Methode im `LocalSrsSessionService`.
- Die Fassade bleibt ein duennes Koordinationsobjekt.
- Completion kann bewusst nach dem letzten Submit oder beim Session-Screen-Aufruf ausgefuehrt werden.

Risiken:

- Bei Rueckgabe nur als `bool` muesste ein ViewModel danach separat einen Read-State laden.
- Ohne klaren Result-Typ ist nicht sofort sichtbar, ob die Session bereits abgeschlossen war oder gerade abgeschlossen wurde.

### Option B: completeIfFinishedAndReadState(...)

Signatur-Idee:

- `completeIfFinishedAndReadState({required String sessionId, required DateTime now})`

Rueckgabe:

- `LocalSessionReadState`

Vorteile:

- Der Name beschreibt den Ablauf sehr explizit.
- Das ViewModel bekommt direkt einen aktualisierten Read-State.
- Es passt zum Muster `submitAnswerAndReadNext(...)`.

Risiken:

- Der Methodenname ist lang.
- Der Name koppelt Completion sprachlich stark an Read-State-Aufbau, obwohl das fachliche Ziel Completion ist.

### Option C: eigener CompletionResult-Typ

Signatur-Idee:

- `completeIfFinished({required String sessionId, required DateTime now})`
- Rueckgabe: `LocalSessionCompletionResult`

Moegliche Felder:

- `sessionId`
- `wasCompleted`
- `wasAlreadyCompleted`
- `status`
- `completedAt`
- `readState`

Vorteile:

- Sehr ausdrucksstark.
- Spaeter gut erweiterbar fuer UI-Meldungen, Analytics oder Debugging.
- Unterscheidet klar zwischen "wurde gerade abgeschlossen" und "war nicht fertig".

Risiken:

- Fuer Version 1 vermutlich mehr Struktur als noetig.
- Ein neuer Typ erhoeht die Oberflaeche der lokalen Schicht.
- Die bisherige Facade arbeitet bewusst mit `LocalSessionReadState` als UI-neutralem Hauptzustand.

## Rueckgabevarianten Fuer Version 1

### LocalSessionReadState Zurueckgeben

Vorteile:

- Passt zum bestehenden Facade-Muster.
- ViewModels koennen denselben State weiterverwenden.
- `canSubmitAnswer` und `canCompleteSession` bilden den Zustand weiterhin UI-neutral ab.
- Bei abgeschlossener Session kann `status == completed`, `currentWordId == null`, `canSubmitAnswer == false` und `canCompleteSession == true` sichtbar werden.

Nachteile:

- Der State sagt nicht explizit, ob die Completion gerade neu passiert ist.
- Wenn spaeter Toasts, Abschlussanimationen oder Statistik-Screens unterschieden werden sollen, reicht der State allein eventuell nicht.

### bool Zurueckgeben

Vorteile:

- Minimal.
- Einfach zu testen.

Nachteile:

- Zu wenig Information fuer den naechsten ViewModel-Schritt.
- Danach muesste separat ein Read-State geladen werden.
- Bricht das bisherige Facade-Muster, bei dem Methoden einen nutzbaren lokalen State zurueckgeben.

### LocalSessionCompletionResult Zurueckgeben

Vorteile:

- Fachlich am eindeutigsten.
- Spaeter gut fuer App-Anbindung und Abschlussdarstellung.

Nachteile:

- Fuer den kleinsten naechsten Schritt nicht zwingend notwendig.
- Fuehrt einen weiteren lokalen State-Typ ein, bevor die UI-Anbindung ueberhaupt begonnen hat.

## Empfehlung Fuer Version 1

Empfehlung:

- Die Fassade bekommt zunaechst eine Methode `completeIfFinished(...)`.
- Die Methode gibt `LocalSessionReadState` zurueck.
- Intern delegiert sie nur an `LocalSrsSessionService.completeSessionIfFinished(...)`.
- Danach ruft sie `LocalSessionReadService.buildReadState(...)` auf.

Begruendung:

- Diese Variante ist der kleinste stabile naechste Schritt.
- Sie passt zum bestehenden Muster von `startOrResumeLearning(...)` und `submitAnswerAndReadNext(...)`.
- Sie vermeidet einen zusaetzlichen Result-Typ, solange noch keine UI-Anbindung existiert.
- Sie liefert trotzdem direkt den aktualisierten lokalen Zustand fuer ein spaeteres ViewModel.

Ein eigener `LocalSessionCompletionResult` kann spaeter ergaenzt werden, wenn die UI zwischen "gerade abgeschlossen", "noch offen" und "bereits abgeschlossen" unterscheiden muss.

## Geplanter Ablauf

`LocalLearningSessionFacade.completeIfFinished(...)` soll:

1. `LocalSrsSessionService.completeSessionIfFinished(...)` mit `sessionId` und `now` aufrufen.
2. Den aktualisierten `LocalSrsSessionState` erhalten.
3. `LocalSessionReadService.buildReadState(...)` aufrufen.
4. Einen aktualisierten `LocalSessionReadState` zurueckgeben.

Die Fassade enthaelt dabei keine eigene Completion-Logik. Sie prueft nicht selbst Item-Status und setzt keine Session direkt auf `completed`.

## Was Completion Nicht Tun Darf

Completion darf nicht:

- eine neue Session erzeugen
- eine Queue neu bauen
- Progress initialisieren
- Stage, `pass_count`, `wrong_count` oder `next_due_at` veraendern
- Review-History schreiben
- Requeue-Items erzeugen
- UI-Navigation ausloesen
- UI-Texte oder Widgets kennen
- Supabase verwenden
- bestehende App-Flows aendern

## Erste Tests

Die ersten Tests sollten in `test/core/local_database/local_learning_session_facade_test.dart` liegen, weil das Verhalten als Facade-Koordination abgesichert werden soll.

### complete_if_finished_keeps_active_when_open_items_exist

Ausgang:

- Eine aktive Session hat mindestens ein offenes Item.

Aktion:

- `LocalLearningSessionFacade.completeIfFinished(...)` wird aufgerufen.

Erwartung:

- Session bleibt `active`.
- `completed_at` bleibt leer.
- Rueckgabe ist ein `LocalSessionReadState`.
- Es entsteht keine neue Session.

### complete_if_finished_marks_completed_when_no_open_items_exist

Ausgang:

- Eine aktive Session hat keine offenen Items mehr.

Aktion:

- `LocalLearningSessionFacade.completeIfFinished(...)` wird aufgerufen.

Erwartung:

- Session wird `completed`.
- `completed_at` wird gesetzt.
- Rueckgabe ist ein `LocalSessionReadState` mit `status == completed`.
- `currentWordId == null`.
- `canSubmitAnswer == false`.

### completed_session_allows_new_active_session_for_same_context

Ausgang:

- Eine Session fuer `categoryId + mode + trainingArea` wurde abgeschlossen.

Aktion:

- Danach wird `startOrResumeLearning(...)` fuer denselben Kontext aufgerufen.

Erwartung:

- Eine neue aktive Session darf entstehen.
- Der SQLite-Unique-Schutz fuer aktive Sessions blockiert nicht mehr.
- Die alte Session bleibt `completed`.

### complete_if_finished_does_not_create_new_session

Ausgang:

- Eine aktive oder gerade abschliessbare Session existiert.

Aktion:

- `completeIfFinished(...)` wird aufgerufen.

Erwartung:

- Die Anzahl der Sessions steigt nicht.
- Es wird keine Queue gebaut.
- Es werden keine neuen `session_items` erzeugt.

## Kleinster Erster TDD-Schritt

Der kleinste sinnvolle TDD-Schritt ist:

1. In `LocalLearningSessionFacade` nur `completeIfFinished(...)` ergaenzen.
2. Nur den Test `complete_if_finished_keeps_active_when_open_items_exist` schreiben.
3. Pruefen, dass die Fassade lediglich delegiert und einen `LocalSessionReadState` zurueckgibt.

Danach folgen:

1. `complete_if_finished_marks_completed_when_no_open_items_exist`
2. `completed_session_allows_new_active_session_for_same_context`
3. `complete_if_finished_does_not_create_new_session`

## Weiterhin Geltende Grenzen

Auch nach Completion-Planung gelten weiter:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Entfernung
- keine echten App-Daten
- keine Produktionsdatenbank-Oeffnung
- keine App-Flow-Aenderung
- kein `LearnModeController`-Umbau
- kein `WordUserView`-Adapter

## Offene Punkte

Fuer Version 1 bleibt bewusst offen:

- Ob spaeter ein eigener `LocalSessionCompletionResult` eingefuehrt wird.
- Ob Completion automatisch nach jedem `submitAnswerAndReadNext(...)` versucht werden soll.
- Ob ein spaeteres ViewModel Abschlusszustand, Statistik und naechste Session separat darstellen soll.

Diese Punkte blockieren den naechsten TDD-Schritt nicht, solange `completeIfFinished(...)` bewusst manuell und UI-neutral bleibt.
