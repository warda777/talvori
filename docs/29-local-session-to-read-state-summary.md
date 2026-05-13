# 29 Local Session To Read State Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen Session-to-ReadState-Integrationsnachweis zusammen.

Der Nachweis bleibt vollstaendig innerhalb der isolierten lokalen SQLite-/Repository-/SRS-/Read-State-Schicht. Es gibt weiterhin keine UI-Anbindung, keine Supabase-Entfernung und keine Aenderung bestehender App-Flows.

## Was Der Integrationstest Nachweist

Der Test `started_session_can_build_read_state_with_word_data_and_stage` zeigt:

- lokale Kategorie kann erzeugt werden
- mehrere lokale aktive Woerter koennen mit `term`, `translation`, `example_sentence` und `notes` erzeugt werden
- `LocalProgressInitializationService` erzeugt `S0`-Progress fuer `LearningMode.adaptive`
- `LocalSrsSessionService.startOrResumeSession(...)` startet eine aktive lokale Session
- der zurueckgegebene `LocalSrsSessionState` kann direkt an `LocalSessionReadService.buildReadState(...)` uebergeben werden
- daraus entsteht ein `LocalSessionReadState` mit:
  - passender `sessionId`
  - gesetzter `currentWordId`
  - gesetztem `currentTerm`
  - gesetzter `currentTranslation`
  - gesetztem `currentExampleSentence`
  - gesetzten `currentNotes`
  - `currentStage == S0`
  - `canSubmitAnswer == true`
- der Read-Service erzeugt keine zweite Session
- der Read-Service veraendert keine `word_progress`-, `learning_sessions`-, `session_items`- oder `review_history`-Daten

Damit ist lokal bewiesen: Nach einem Session-Start kann sofort ein app-naher, aber UI-neutraler Read-State mit Wortdaten und Stage erzeugt werden.

## Funktionierende Lokale Kette

Aktuell funktioniert diese Kette:

1. `CategoryRepository`
   - legt lokale Kategorie an.

2. `WordRepository`
   - legt lokale Woerter an.
   - stellt Wortdaten fuer spaetere Anzeige bereit.

3. `LocalProgressInitializationService`
   - laedt aktive Wort-IDs.
   - initialisiert fehlenden Fortschritt als `S0` fuer den gewuenschten Lernmodus.

4. `WordProgressRepository`
   - speichert Progress pro `word_id + category_id + mode_id`.

5. `LocalSrsSessionService.startOrResumeSession(...)`
   - laedt neue `S0`-Progress-Daten.
   - baut ueber die reine `SrsEngine` eine Session-Queue.
   - speichert eine aktive lokale Session.
   - gibt `LocalSrsSessionState` zurueck.

6. `LocalSessionReadService.buildReadState(...)`
   - liest `currentWordId` aus `LocalSrsSessionState`.
   - laedt Wortdaten ueber `WordRepository.loadWordById(...)`.
   - laedt Stage ueber `WordProgressRepository.loadProgress(...)`.
   - gibt `LocalSessionReadState` zurueck.

Damit ist die lokale Kette jetzt nicht nur speicher- und sessionfaehig, sondern auch lesefaehig fuer eine spaetere ViewModel-Schicht.

## Beteiligte Komponenten

Am Nachweis beteiligt sind:

- `LocalDatabaseSchema`
- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`
- `LocalProgressInitializationService`
- `LocalSrsSessionService`
- `LocalSessionReadService`
- `SrsReviewPersistenceService`
- reine Dart-`SrsEngine`
- `LocalSrsSessionState`
- `LocalSessionReadState`
- `LearningMode`
- `TrainingArea`
- `SrsStage`

Der Test nutzt eine In-Memory-SQLite-Datenbank und echte lokale Repository-/Service-Instanzen.

## Bedeutung Fuer Spaetere App-/ViewModel-Anbindung

Eine spaetere UI braucht nicht nur eine aktive Session, sondern auch konkrete Daten fuer die aktuelle Karte.

Dieser Schritt zeigt, dass ein spaeteres ViewModel einen klaren Ablauf nutzen kann:

1. Session starten oder fortsetzen.
2. `LocalSrsSessionState` erhalten.
3. `LocalSessionReadService` aufrufen.
4. `LocalSessionReadState` mit Wortdaten und Stage erhalten.

Das ist wichtig, weil:

- ViewModels spaeter nicht direkt in SQLite-Tabellen greifen muessen
- UI und lokale Persistenz getrennt bleiben
- Session-Mutation und Read-Anreicherung getrennt bleiben
- bestehende App-Flows noch nicht beruehrt werden muessen
- die lokale Schicht vor UI-Umbau testbar bleibt

Der Nachweis reduziert das Risiko, dass eine spaetere App-Anbindung zwar Sessions startet, aber keine vollstaendigen Anzeigedaten fuer die aktuelle Karte liefern kann.

## Weiterhin Geltende Grenzen

Nicht umgesetzt:

- keine UI-Anbindung
- keine ViewModel-Anbindung
- keine Provider-Integration
- keine Navigation
- keine Supabase-Entfernung
- kein Supabase-Datenimport
- keine App-Flow-Aenderung
- kein `WordUserView`-Adapter
- keine echten App-Daten
- keine Produktionsdatenbank-Oeffnung
- keine UI-Texte oder Moduslabels
- keine echten Lernmodus-Buttons
- keine Umstellung bestehender Controller

Die bestehende App nutzt diese lokale Kette noch nicht.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Einen UI-neutralen lokalen App-Adapter planen, der diese drei Schritte koordiniert:
   - Progress vorbereiten
   - Session starten oder fortsetzen
   - Read-State bauen

2. Entscheiden, ob dieser Adapter separat bleibt oder spaeter als ViewModel-nahe Fassade genutzt wird.

3. Einen Test fuer den kompletten lokalen Startablauf planen:
   - `initializeProgressForCategoryAndMode(...)`
   - `startOrResumeSession(...)`
   - `buildReadState(...)`

4. Lokale Datenquelle fuer echte Kategorien und Woerter planen:
   - Seed-Daten
   - `word_hub_taxonomy.dart`
   - spaeterer Import
   - Supabase-Export als spaeteres Thema

5. Erst danach eine vorsichtige ViewModel-/Provider-Anbindung planen.

Empfehlung:

Der naechste kleinste Planungsschritt ist ein `LocalLearningSessionFacade`-Plan: eine UI-neutrale Koordinationsschicht, die Progress-Initialisierung, Session-Start und Read-State-Aufbau zusammenfasst, ohne UI, Supabase oder bestehende App-Flows zu veraendern.
