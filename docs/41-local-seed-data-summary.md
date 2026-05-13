# 41 Local Seed Data Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen Seed-Daten-Block zusammen.

Der Seed-Block stellt kleine lokale Demo-/Testdaten bereit, ohne Supabase, DeepL, alte lokale Datenbank, UI oder bestehende App-Flows zu beruehren.

## LocalSeedDataService

`LocalSeedDataService` uebernimmt eine enge Aufgabe:

- lokale Standard-Kategorien und Standard-Woerter ueber bestehende Repositorys anlegen

Umgesetzt ist:

- `seedDefaults({required DateTime now})`

Der Service verwendet:

- `CategoryRepository.upsertCategory(...)`
- `WordRepository.upsertWord(...)`

Der Service macht nicht:

- keine direkte SQL-Schreiblogik fuer Seed
- kein `word_progress`
- keine `learning_sessions`
- keine `review_history`
- keine SRS-Engine-Aufrufe
- keine UI
- kein Supabase
- keine alte `local_word_database.dart`

## Aktuelle Seed-Kategorien Und Woerter

Aktuell existieren drei Seed-Kategorien.

### Basics

ID:

- `seed-category-basics`

Woerter:

- `hello` -> `hallo`
- `thank you` -> `danke`
- `water` -> `Wasser`

### Travel

ID:

- `seed-category-travel`

Woerter:

- `ticket` -> `Fahrkarte`
- `station` -> `Bahnhof`
- `hotel` -> `Hotel`

### Exam Practice

ID:

- `seed-category-exam-practice`

Woerter:

- `explain` -> `erklaeren`
- `compare` -> `vergleichen`
- `result` -> `Ergebnis`

Alle Seed-Woerter haben:

- stabile IDs
- `term`
- `translation`
- `example_sentence`
- `notes`
- `sort_order`
- `is_archived = false` ueber Repository-Default

## Idempotenz

Idempotenz wird durch stabile IDs und Repository-`upsert` gesichert.

Regeln:

- Jede Kategorie hat eine feste ID.
- Jedes Wort hat eine feste ID.
- Kategorien werden ueber `upsertCategory(...)` angelegt oder aktualisiert.
- Woerter werden ueber `upsertWord(...)` angelegt oder aktualisiert.
- Ein zweiter Seed-Lauf erzeugt keine doppelten Kategorien.
- Ein zweiter Seed-Lauf erzeugt keine doppelten Woerter.

Der Test `seed_data_is_idempotent` prueft, dass Kategorieanzahl, Wortanzahl und stabile IDs nach einem zweiten Lauf gleich bleiben.

## Warum Seed Keine Progress-/Session-/History-Daten Schreibt

Seed-Daten sollen nur die Inhaltsbasis erzeugen:

- Kategorien
- Woerter

Sie schreiben bewusst nicht:

- `word_progress`
- `learning_sessions`
- `session_items`
- `review_history`

Begruendung:

- SRS-Fortschritt soll fachlich durch `LocalProgressInitializationService` entstehen.
- Sessions sollen nur durch `LocalLearningSessionFacade.startOrResumeLearning(...)` entstehen.
- Review-History soll nur durch echte Antwortverarbeitung entstehen.
- Seed darf keine Lernhistorie vortaeuschen.
- Seed bleibt dadurch sicher wiederholbar und klar von Lernlogik getrennt.

## Tests

Datei:

- `test/core/local_database/local_seed_data_service_test.dart`

Tests:

- `seed_data_can_create_categories_and_words`
- `seed_data_is_idempotent`
- `seeded_words_can_initialize_progress_and_start_session`

### seed_data_can_create_categories_and_words

Sichert ab:

- Seed erzeugt `Basics`, `Travel` und `Exam Practice`.
- Jede Kategorie hat aktive Woerter.
- Woerter haben `term` und `translation`.
- Woerter sind nicht archiviert.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### seed_data_is_idempotent

Sichert ab:

- Seed kann zweimal laufen.
- Kategorieanzahl bleibt gleich.
- Wortanzahl bleibt gleich.
- stabile Kategorie-IDs bleiben gleich.
- stabile Wort-IDs bleiben gleich.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- `word_progress`, `learning_sessions` und `review_history` bleiben leer.

### seeded_words_can_initialize_progress_and_start_session

Sichert ab:

- Seed selbst erzeugt vor der Progress-Initialisierung keinen `word_progress`.
- `LocalProgressInitializationService` kann fuer `Basics` und `LearningMode.adaptive` Progress erzeugen.
- `LocalLearningSessionFacade.startOrResumeLearning(...)` kann danach eine lokale Session starten.
- `LocalSessionReadState` enthaelt:
  - `sessionId`
  - `currentWordId`
  - `currentTerm`
  - `currentTranslation`
  - `currentStage = S0`
  - `canSubmitAnswer = true`
- `learning_sessions` enthaelt eine aktive Session.
- `session_items` enthaelt Items.

## Funktionierende Lokale Kette

Folgende lokale Kette funktioniert jetzt:

1. Seed-Daten einfuegen
2. Kategorien und Woerter ueber Repositorys laden
3. Progress fuer Seed-Woerter initialisieren
4. lokale Session starten
5. `LocalSessionReadState` mit Wortdaten und Stage erhalten

Kurz:

- Seed -> Progress initialisieren -> Session starten -> ReadState

Diese Kette bleibt vollstaendig lokal und UI-neutral.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- keine echte App-Datenbankbefuellung
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Daten
- keine Aenderung an `word_progress.db`
- kein DeepL-/Wortimport
- kein JSON-/Asset-Seed
- keine echten Launch-Inhalte

Die Seed-Daten sind klein und dienen lokalem Test-/Demo-Zweck.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Lokalen Gesamtblock erneut pruefen:
   - `flutter test test/core/srs/`
   - `flutter test test/core/local_database/`
   - gezielter Analyzer fuer lokalen Block

2. Seed-Daten spaeter auf 10 bis 20 Woerter pro Kategorie erweitern.

3. Einen UI-neutralen App-Bootstrap planen:
   - App-Datenbankpfad bilden
   - Datenbank oeffnen
   - RepositoryFactory bauen
   - optional Seed ausfuehren
   - weiterhin keine UI-Anbindung

4. Danach entscheiden, ob Seed-Daten langfristig Dart-Konstanten bleiben oder spaeter in JSON/Assets wandern.

5. Supabase-Export und DeepL-/Importstrategie separat planen.
