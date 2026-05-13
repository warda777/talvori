# 28 Local Session Read Service Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `LocalSessionReadService` zusammen.

Der Service ist ein UI-neutraler Lesebaustein fuer lokale SRS-Sessions. Er reichert einen vorhandenen `LocalSrsSessionState` mit Wort- und Stage-Daten an, ohne Sessions zu starten, Fortschritt zu initialisieren oder Daten zu veraendern.

## Aufgabe Des Service

`LocalSessionReadService` uebernimmt nur Lesen und Anreichern.

Input:

- `LocalSrsSessionState`

Output:

- `LocalSessionReadState`

Der Service:

- liest `currentWordId` aus dem Session-State
- laedt aktuelle Wortdaten aus `WordRepository`
- laedt aktuelle Stage aus `WordProgressRepository`
- berechnet `canSubmitAnswer`
- gibt einen app-nahen, aber UI-neutralen Read-State zurueck

Er erzeugt keine neue Session, schreibt keine Review-History, veraendert keine Session-Items und initialisiert keinen Progress.

## Uebernommene Daten Aus LocalSrsSessionState

`LocalSessionReadState` uebernimmt diese Daten direkt aus `LocalSrsSessionState`:

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
- `currentWordId`
- `canCompleteSession`

Zusaetzlich wird daraus abgeleitet:

- `canSubmitAnswer`

Version-1-Regel:

- `canSubmitAnswer == true`, wenn:
  - `status == active`
  - `currentWordId != null`
  - `remainingCount > 0`

Wenn keine aktuelle Karte existiert, ist `canSubmitAnswer == false`.

## Zusaetzlich Geladene Daten

Wenn `currentWordId != null` ist, laedt der Service:

Aus `WordRepository.loadWordById(...)`:

- `currentTerm`
- `currentTranslation`
- `currentExampleSentence`
- `currentNotes`

Aus `WordProgressRepository.loadProgress(...)`:

- `currentStage`

Die Stage wird bewusst aus `word_progress` geladen, weil Fortschritt pro `word_id + category_id + mode` getrennt ist.

Wenn `currentWordId == null`, bleiben diese Felder `null`:

- `currentTerm`
- `currentTranslation`
- `currentExampleSentence`
- `currentNotes`
- `currentStage`

## Warum Getrennt Von LocalSrsSessionService

`LocalSrsSessionService` koordiniert Session-Aktionen:

- Session starten oder fortsetzen
- Queue bauen lassen
- Antworten verarbeiten
- Review-Ergebnisse speichern
- Session abschliessen

`LocalSessionReadService` hat eine andere Aufgabe:

- vorhandenen Session-State lesen
- Wortdaten fuer die aktuelle Karte laden
- Stage fuer die aktuelle Karte laden
- nichts veraendern

Die Trennung bleibt wichtig, weil:

- Mutationslogik und Leselogik nicht vermischt werden
- `LocalSrsSessionService` nicht weiter anwaechst
- Tests kleiner und klarer bleiben
- ein spaeteres ViewModel klare Bausteine bekommt
- das Risiko fuer bestehende App-Flows niedrig bleibt

## Tests

Datei:

- `test/core/local_database/local_session_read_service_test.dart`

Vorhandene Tests:

- `read_state_contains_current_word_data`
  - prueft, dass `term`, `translation`, `exampleSentence` und `notes` aus dem aktuellen Wort geladen werden
  - prueft Basisdaten aus `LocalSrsSessionState`
  - prueft `canSubmitAnswer == true` fuer aktive Session mit aktueller Karte

- `read_state_contains_current_stage`
  - prueft, dass `currentStage` aus `word_progress` geladen wird

- `read_state_returns_null_word_fields_when_session_has_no_current_item`
  - prueft, dass Wortfelder und Stage `null` bleiben, wenn `currentWordId == null`
  - prueft `canSubmitAnswer == false`
  - prueft, dass `canCompleteSession` erhalten bleibt

- `read_state_does_not_modify_progress_or_session`
  - prueft, dass `word_progress` unveraendert bleibt
  - prueft, dass `learning_sessions` unveraendert bleibt
  - prueft, dass `session_items` unveraendert bleibt
  - prueft, dass keine `review_history` geschrieben wird

Die Tests nutzen eine In-Memory-SQLite-Datenbank und bleiben vollstaendig lokal.

## Weiterhin Geltende Grenzen

Nicht umgesetzt:

- keine UI-Anbindung
- keine ViewModel-Anbindung
- keine Provider-Integration
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- kein `WordUserView`-Adapter
- keine echten App-Daten
- keine Produktionsdatenbank-Oeffnung
- keine UI-Texte oder Moduslabels

Der Service ist ein reiner lokaler Read-Baustein.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Einen Integrationstest planen, der `LocalSrsSessionService.startOrResumeSession(...)` und `LocalSessionReadService.buildReadState(...)` gemeinsam nutzt.
2. Pruefen, welche Daten ein spaeteres ViewModel zusaetzlich braucht, ohne den Read-State vorschnell aufzublaehen.
3. Eine lokale App-Adapter-Schicht planen, die `startOrResumeSession`, `submitAnswer` und `buildReadState` koordiniert.
4. Weiterhin keine bestehende UI umbauen, bis lokale Datenquelle, Session-Start und Read-State stabil zusammen getestet sind.
5. Vor einer App-Anbindung die lokalen SRS-, SQLite-, Repository-, Session- und Read-Service-Tests gemeinsam ausfuehren.

Empfehlung:

Der naechste kleine technische Schritt ist ein integrationsnaher Test, der zeigt, dass nach einem lokalen Session-Start direkt ein `LocalSessionReadState` mit Wortdaten und Stage erzeugt werden kann.
