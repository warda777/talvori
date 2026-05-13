# 66 Local JSON Import Service Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand des `LocalJsonImportService` zusammen.

Der Service ist ein lokaler, UI-neutraler Importbaustein fuer die neue Offline-first-Datenbank `talvori_local_v1.db`. Er importiert Kategorien und Woerter aus einem JSON-String, ohne Supabase, Assets, alte lokale Datenbanken, UI oder bestehende App-Flows zu beruehren.

## 1. Aufgabe Des LocalJsonImportService

Datei:

- `lib/core/local_database/services/local_json_import_service.dart`

Der Service uebernimmt:

- JSON-String parsen
- Kategorien validieren
- Woerter validieren
- Kategorien ueber `CategoryRepository.upsertCategory(...)` speichern
- Woerter ueber `WordRepository.upsertWord(...)` speichern

Er macht nicht:

- keine Assets laden
- kein `rootBundle` verwenden
- keine Dateien direkt lesen
- kein Supabase kennen
- keine alte `local_word_database.dart` kennen
- keine alte `word_progress.db` oeffnen
- keine SRS-Engine aufrufen
- keine Sessions starten
- keine Progress-Daten erzeugen
- keine Review-History schreiben

## 2. Erlaubte Importdaten

Importiert werden duerfen Kategorien mit:

- `id`
- `name`
- `description` optional
- `sort_order`
- `is_archived`
- `words`

Importiert werden duerfen Woerter mit:

- `id`
- `term`
- `translation`
- `example_sentence` optional
- `notes` optional
- `sort_order`
- `is_archived`

Die Importmodelle liegen in:

- `lib/core/local_database/import/local_json_import_models.dart`

Aktuelle Validierung:

- Pflicht-Strings muessen vorhanden und nicht leer sein.
- `sort_order` muss ein Integer sein.
- `is_archived` muss, wenn vorhanden, ein Boolean sein.
- `words` muss eine Liste sein.
- jedes Wort muss ein Objekt sein.

## 3. Ausdruecklich Nicht Importierte Daten

Der Importservice importiert nicht:

- alten SRS-Fortschritt
- `is_mastered`
- alte `pass_count`-Werte
- alte `next_due_at`-Werte
- alte Streak-/EF-/Lapses-Daten
- alte Refill-/Mirror-Daten
- alte Sessions
- alte Session-Items
- alte Review-History
- Supabase-IDs als verpflichtende lokale Hauptstrategie

Begruendung:

- V1 startet lokalen Fortschritt bewusst neu.
- Alte SRS-Daten sind nicht verlaesslich V1-kompatibel.
- Inhaltsimport und Lernzustand bleiben klar getrennt.

## 4. Idempotenz

Idempotenz wird ueber stabile IDs und Repository-`upsert`s abgesichert.

Der Service nutzt:

- `CategoryRepository.upsertCategory(...)`
- `WordRepository.upsertWord(...)`

Dadurch gilt:

- gleicher Kategorie-Import erzeugt keine doppelte Kategorie
- gleicher Wort-Import erzeugt kein doppeltes Wort
- vorhandene IDs werden aktualisiert statt dupliziert

Der Test `local_import_is_idempotent` prueft:

- Kategorieanzahl bleibt nach zweitem Import gleich
- Wortanzahl bleibt nach zweitem Import gleich
- Kategorie-IDs bleiben stabil
- Wort-IDs bleiben stabil
- keine doppelten Kategorien entstehen
- keine doppelten Woerter entstehen

## 5. Kein Progress, Keine Sessions, Keine Review-History

Der Importservice erzeugt bewusst nur Inhaltsdaten.

Er schreibt nicht in:

- `word_progress`
- `learning_sessions`
- `session_items`
- `review_history`

Warum:

- Progress entsteht fachlich erst durch `LocalProgressInitializationService`.
- Sessions entstehen erst durch `LocalLearningSessionFacade.startOrResumeLearning(...)`.
- Review-History entsteht nur durch echte Antwortverarbeitung.
- Import darf keine Lernhistorie vortaeuschen.
- Import bleibt dadurch wiederholbar und sicher.

Der Test `local_import_does_not_create_progress` sichert diese Grenze explizit ab.

## 6. Import Zu Progress Zu Session

Der integrationsnahe Test `imported_words_can_initialize_progress_and_start_session` weist die lokale Kette nach:

1. JSON importiert eine Kategorie und mindestens drei Woerter.
2. Direkt nach Import bleiben leer:
   - `word_progress`
   - `learning_sessions`
   - `review_history`
3. `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)` erzeugt Progress fuer die importierten Woerter.
4. `LocalLearningSessionFacade.startOrResumeLearning(...)` startet eine lokale Session.
5. Der Rueckgabewert ist ein nutzbarer `LocalSessionReadState`.

Abgesichert wird:

- `sessionId` ist gesetzt
- `currentWordId` ist gesetzt
- `currentTerm` ist gesetzt
- `currentTranslation` ist gesetzt
- `currentStage == SrsStage.s0`
- `canSubmitAnswer == true`
- `learning_sessions` enthaelt eine aktive Session
- `session_items` enthaelt Items

Damit ist gezeigt:

- Import erzeugt Inhalte.
- Progress entsteht erst im separaten Progress-Schritt.
- Sessions entstehen erst im separaten Session-Schritt.

## 7. Tests

Datei:

- `test/core/local_database/local_json_import_service_test.dart`

Vorhandene Tests:

- `local_import_creates_categories_and_words`
- `local_import_is_idempotent`
- `local_import_does_not_create_progress`
- `imported_words_can_initialize_progress_and_start_session`

### local_import_creates_categories_and_words

Sichert ab:

- Kategorie wird erstellt.
- Woerter werden erstellt.
- `term` und `translation` stimmen.
- `sort_order` stimmt.
- `is_archived` stimmt.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### local_import_is_idempotent

Sichert ab:

- gleicher Import kann mehrfach laufen.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- stabile IDs bleiben gleich.
- keine Lernzustandsdaten entstehen.

### local_import_does_not_create_progress

Sichert ab:

- Import erzeugt Kategorien und Woerter.
- Import erzeugt keinen `word_progress`.
- Import erzeugt keine `learning_sessions`.
- Import erzeugt keine `review_history`.

### imported_words_can_initialize_progress_and_start_session

Sichert ab:

- Importierte Woerter koennen spaeter Progress erhalten.
- Importierte Woerter koennen danach eine lokale Session starten.
- Die lokale Offline-first-Kette funktioniert mit importierten Inhaltsdaten.

## 8. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- keine Navigation
- keine Supabase-Nutzung
- keine Supabase-Entfernung
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`
- keine Assets
- kein `rootBundle`
- kein echter Dateizugriff
- keine alte `word_progress.db`
- kein Import alter Fortschritte
- kein automatischer App-Start-Import

Der Service ist ein lokaler Importbaustein, noch keine App-Integration.

## 9. Aktuelle Stabilitaetschecks

Der zuletzt ausgefuehrte lokale Stabilitaetscheck war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden
- `flutter test test/core/local_database/`
  - 109 Tests bestanden
- `flutter test test/features/local_learning_debug/`
  - 10 Tests bestanden
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Gesamt:

- 158 lokale Tests bestanden
- gezielter Analyzer meldete keine Probleme

## 10. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Importservice als lokalen Meilenstein dokumentiert betrachten.
2. Falls weitergearbeitet wird, zuerst Importvalidierung ausbauen:
   - fehlende Kategorie-ID ablehnen
   - fehlender Wortbegriff ablehnen
   - doppelte IDs innerhalb einer Importdatei ablehnen
3. Danach optional Asset-Import separat planen:
   - keine automatische App-Anbindung
   - keine Supabase-Abhaengigkeit
   - keine alte lokale Datenbank
4. Spaeter eine echte Importdatei oder Test-Fixture planen.
5. Vor jeder weiteren Integration erneut den lokalen Stabilitaetscheck ausfuehren.
6. Bestehende UI, Supabase und alte App-Flows weiterhin unangetastet lassen.

