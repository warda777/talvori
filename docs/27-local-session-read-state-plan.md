# 27 Local Session Read State Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den naechsten kleinen app-nahen, aber UI-neutralen Schritt fuer die lokale SRS-/SQLite-Schicht.

Ziel ist ein `LocalSessionReadState`, der spaeter einem ViewModel helfen kann, eine laufende lokale Session anzuzeigen. Der State darf aber keine Flutter-Widgets, Navigation, UI-Texte, Styling-Entscheidungen oder Supabase-Abhaengigkeiten kennen.

Der Schritt bleibt Planung:

- kein Dart-Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung

## Ausgangslage

`LocalSrsSessionService.startOrResumeSession(...)` liefert aktuell einen UI-neutralen `LocalSrsSessionState`.

Dieser enthaelt:

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

Damit ist bekannt, welche Karte aktuell dran ist. Fuer eine spaetere App-Anbindung reichen diese Daten aber noch nicht, weil das ViewModel auch Wortdaten braucht:

- Begriff
- Uebersetzung
- Beispielsatz
- Notizen
- aktuelle Stage, falls vorhanden

## Zweck Eines UI-Neutralen LocalSessionReadState

Ein `LocalSessionReadState` soll den aktuellen lokalen Session-Zustand fuer eine spaetere ViewModel-Schicht lesbar machen.

Er soll:

- eine bestehende Session beschreiben
- aktuelle Wortdaten mitliefern
- vorhandene Session-Zaehler erhalten
- Submit-/Completion-Moeglichkeiten ausdruecken
- keine UI-Texte oder Labels festlegen
- keine Navigation kennen
- keine Widgets kennen
- keine Supabase-Daten laden
- keine App-Flows ausloesen

Der State ist damit ein App-naher Transportzustand, aber kein UI-Modell im engeren Sinn.

## Laden Der Wortdaten Aus currentWordId

Der vorhandene `LocalSrsSessionState` enthaelt `currentWordId`.

Geplanter Ablauf:

1. Eine laufende oder gerade gestartete Session liefert `LocalSrsSessionState`.
2. Wenn `currentWordId != null` ist, laedt ein Read-Service das Wort ueber `WordRepository.loadWordById(currentWordId)`.
3. Aus `LocalWord` werden UI-neutrale Wortfelder uebernommen:
   - `term`
   - `translation`
   - `exampleSentence`
   - `notes`
4. Falls aktuelle Stage benoetigt wird, laedt der Read-Service zusaetzlich `WordProgressRepository.loadProgress(...)` fuer:
   - `wordId`
   - `categoryId`
   - `mode`
5. Wenn kein aktuelles Item existiert, bleiben Wortfelder `null`.

Wichtig:

- `WordRepository.loadWordById(...)` ist der richtige Einstieg fuer Wortbasisdaten.
- `WordProgressRepository.loadProgress(...)` ist nur fuer Progress-/Stage-Daten zustaendig.
- Der Read-Service darf keine neue Session erzeugen.
- Der Read-Service darf keine Progress-Daten initialisieren.
- Der Read-Service darf keine Queue veraendern.

## Vorgeschlagene Felder

Ein app-naher, aber UI-neutraler `LocalSessionReadState` sollte mindestens enthalten:

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
- `currentTerm`
- `currentTranslation`
- `currentExampleSentence`
- `currentNotes`
- `currentStage`
- `canSubmitAnswer`
- `canCompleteSession`

Optional spaeter:

- `currentDueAt`
- `currentIsNewCard`
- `currentItemStatus`
- `currentRetryAfterPosition`
- `currentSameSessionWrongCount`
- `categoryName`
- `progressPercent`

Diese optionalen Felder sollten erst ergaenzt werden, wenn ein konkretes ViewModel sie braucht.

## canSubmitAnswer

`canSubmitAnswer` sollte aus dem State ableitbar sein.

Vorschlag fuer Version 1:

- `true`, wenn:
  - `status == active`
  - `currentWordId != null`
  - `remainingCount > 0`

- `false`, wenn:
  - keine aktuelle Karte vorhanden ist
  - Session abgeschlossen ist
  - `remainingCount == 0`

Der Read-State entscheidet nicht, ob eine Antwort richtig oder falsch ist. Er zeigt nur, ob ein Submit grundsaetzlich moeglich ist.

## currentStage

`currentStage` sollte aus `word_progress` geladen werden, nicht aus dem Wortdatensatz.

Grund:

- Stage ist Fortschritt, nicht Wortbasisdaten.
- Fortschritt ist pro `categoryId + wordId + mode` getrennt.
- Dasselbe Wort kann in `time`, `adaptive` und `hybrid` unterschiedliche Stages haben.

Wenn `currentWordId == null` oder kein Progress gefunden wird, sollte `currentStage == null` sein.

## Service-Variante

Es gibt zwei moegliche Varianten:

1. Separater `LocalSessionReadService`
2. Erweiterung von `LocalSrsSessionService`

## Variante 1: Separater LocalSessionReadService

Aufgaben:

- vorhandenen `LocalSrsSessionState` in `LocalSessionReadState` anreichern
- Wortdaten ueber `WordRepository.loadWordById(...)` laden
- Stage ueber `WordProgressRepository.loadProgress(...)` laden
- keine Session starten
- keine Session fortsetzen
- keine Antwort speichern
- keine Progress-Daten veraendern

Moegliche Methode:

- `buildReadState(LocalSrsSessionState sessionState)`

Optional spaeter:

- `loadReadStateForActiveSession({categoryId, mode, trainingArea})`
  - nur lesen, keine Session erzeugen

Bewertung:

- Trennung der Zustaendigkeiten: sehr gut
- Testbarkeit: sehr gut
- ViewModel-Anbindung: gut, weil ViewModel einen klaren Read-Baustein bekommt
- Risiko fuer bestehende App: niedrig
- Risiko fuer `LocalSrsSessionService`: niedrig, weil keine neue Verantwortung dort landet

## Variante 2: LocalSrsSessionService Erweitern

Moegliche Erweiterung:

- `startOrResumeSession(...)` koennte direkt `LocalSessionReadState` zurueckgeben
- oder eine neue Methode `startOrResumeSessionReadState(...)` koennte Session und Wortdaten gemeinsam liefern

Bewertung:

- Trennung der Zustaendigkeiten: mittel
- Testbarkeit: noch moeglich, aber Service wird breiter
- ViewModel-Anbindung: kurzfristig bequem
- Risiko fuer bestehende App: hoeher, weil Session-Start, Review-Handling und Read-Anreicherung in einem Service wachsen
- Risiko fuer lokale Schicht: zunehmende Kopplung zwischen Mutationslogik und Leselogik

## Empfehlung

Empfohlen wird ein separater `LocalSessionReadService`.

Begruendung:

- `LocalSrsSessionService` koordiniert bereits Start, Resume, Submit und Complete.
- Read-Anreicherung ist eine andere Verantwortung als Session-Mutation.
- Ein eigener Service ist leichter isoliert zu testen.
- Spaetere ViewModels koennen klar zwischen Aktionen und Lesen unterscheiden.
- Das Risiko fuer bestehende App-Flows bleibt kleiner.

Empfohlene Struktur spaeter:

- `lib/core/local_database/models/local_session_read_state.dart`
- `lib/core/local_database/services/local_session_read_service.dart`
- `test/core/local_database/local_session_read_service_test.dart`

## Geplanter LocalSessionReadService

Der Service sollte spaeter verwenden:

- `WordRepository`
- `WordProgressRepository`

Input:

- `LocalSrsSessionState`

Output:

- `LocalSessionReadState`

Der Service sollte nicht verwenden:

- Supabase
- Flutter Widgets
- Navigator
- ViewModels
- Provider
- `SrsEngine`
- `SrsReviewPersistenceService`
- `LearningSessionRepository`, solange ein fertiger `LocalSrsSessionState` uebergeben wird

## Geplanter Ablauf

1. ViewModel oder spaeterer Adapter ruft `LocalSrsSessionService.startOrResumeSession(...)` auf.
2. Ergebnis ist `LocalSrsSessionState`.
3. Adapter ruft `LocalSessionReadService.buildReadState(sessionState)` auf.
4. Read-Service laedt aktuelle Wortdaten ueber `WordRepository`.
5. Read-Service laedt aktuelle Stage ueber `WordProgressRepository`.
6. Ergebnis ist ein UI-neutraler `LocalSessionReadState`.
7. ViewModel kann daraus eigene UI-Zustaende ableiten.

## Erste Tests

Spaeter zuerst schreiben:

- `read_state_contains_current_word_data`
  - vorhandener Session-State mit `currentWordId`
  - passendes Wort existiert
  - Read-State enthaelt `currentTerm`, `currentTranslation`, `currentExampleSentence`, `currentNotes`

- `read_state_contains_current_stage`
  - Progress fuer `currentWordId + categoryId + mode` existiert
  - Read-State enthaelt passende `currentStage`

- `read_state_returns_null_word_fields_when_session_has_no_current_item`
  - `currentWordId == null`
  - Wortfelder bleiben `null`
  - `canSubmitAnswer == false`

- `read_state_does_not_create_new_session`
  - Anzahl `learning_sessions` bleibt unveraendert
  - Service liest nur

- `read_state_does_not_modify_progress_or_session`
  - `word_progress` bleibt unveraendert
  - `learning_sessions` bleibt unveraendert
  - `session_items` bleibt unveraendert

- `read_state_can_submit_answer_when_active_current_word_exists`
  - aktive Session, aktuelle Karte vorhanden
  - `canSubmitAnswer == true`

- `read_state_cannot_submit_answer_when_no_current_word_exists`
  - keine aktuelle Karte
  - `canSubmitAnswer == false`

## Bewusst Noch Nicht Umgesetzt

Nicht Teil dieses Schritts:

- UI-Anbindung
- `LearnModeController`-Umbau
- Supabase-Entfernung
- `WordUserView`-Adapter
- echte Navigation
- Provider-Integration
- neue Buttons fuer Lernmodi
- Umbenennung der UI-Modi
- echte App-Datenmigration
- Produktionsdatenbank-Oeffnung

## Risiken

Wichtige Risiken fuer spaeter:

- Wenn Read-State und Session-Mutation vermischt werden, wird `LocalSrsSessionService` schnell zu gross.
- Wenn `currentStage` aus dem falschen Modus geladen wird, zeigt die App falschen Fortschritt.
- Wenn `currentWordId == null` nicht sauber behandelt wird, entstehen UI-Fehler am Session-Ende.
- Wenn der Read-Service versehentlich Sessions erzeugt oder Progress initialisiert, wird reines Lesen manipulierbar.
- Wenn spaeter UI-Texte in den Read-State rutschen, wird die lokale Schicht zu stark an die UI gekoppelt.

## Naechster Kleinster Sinnvoller Schritt

Der naechste technische Schritt waere:

1. `LocalSessionReadState` als reines Datenmodell anlegen.
2. `LocalSessionReadService` mit `buildReadState(...)` implementieren.
3. Nur die ersten vier Tests schreiben:
   - `read_state_contains_current_word_data`
   - `read_state_contains_current_stage`
   - `read_state_returns_null_word_fields_when_session_has_no_current_item`
   - `read_state_does_not_modify_progress_or_session`

Dieser Schritt waere klein, testbar und weiterhin komplett ohne UI-, Supabase- oder App-Flow-Aenderung.
