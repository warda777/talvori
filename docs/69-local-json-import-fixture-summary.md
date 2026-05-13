# 69 Local JSON Import Fixture Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand der lokalen JSON-Import-Fixture fuer den `LocalJsonImportService` zusammen.

Die Fixture ist ein reines Testartefakt. Sie dient dazu, den Importpfad mit einer echten JSON-Datei zu pruefen, ohne Flutter-Assets, `rootBundle`, Supabase, alte lokale Datenbanken oder bestehende App-Flows einzubinden.

## 1. Aufgabe Der Fixture

Die Fixture stellt lokale Inhaltsdaten fuer Importtests bereit:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- `sort_order`
- `is_archived`

Sie ermoeglicht Tests, die naeher an einer echten Importdatei liegen als Inline-JSON-Strings im Testcode.

Die Fixture erzeugt selbst keinen Lernzustand:

- kein `word_progress`
- keine `learning_sessions`
- keine `session_items`
- keine `review_history`

## 2. Speicherort

Die Fixture liegt unter:

- `test/fixtures/local_import/default_words_v1.json`

Dieser Ort ist bewusst gewaehlt:

- klar als Test-Fixture erkennbar
- nicht im App-Asset-System
- kein `rootBundle`
- keine automatische App-Nutzung
- kein Produktionspfad
- kein Zugriff auf alte lokale Datenbanken

## 3. Struktur

Die JSON-Datei hat eine Top-Level-Liste von Kategorien.

Jede Kategorie enthaelt:

- `id`
- `name`
- `description`
- `sort_order`
- `is_archived`
- `words`

Jedes Wort enthaelt:

- `id`
- `term`
- `translation`
- `example_sentence`
- `notes`
- `sort_order`
- `is_archived`

Die IDs sind stabil und sprechend. Es werden keine Supabase-IDs, keine alten IDs aus `word_progress.db` und keine IDs aus `local_word_database.dart` verwendet.

## 4. Enthaltene Kategorien Und Woerter

Aktuell enthaelt die Fixture eine Kategorie:

- `basics`

Kategorie:

- `id`: `basics`
- `name`: `Basics`
- `description`: `Essential starter words for local import tests.`
- `sort_order`: `1`
- `is_archived`: `false`

Enthaltene Woerter:

- `basics_hello`
  - `term`: `hello`
  - `translation`: `hallo`
  - `example_sentence`: `Hello, how are you?`
  - `notes`: `Common greeting.`
  - `sort_order`: `1`
  - `is_archived`: `false`
- `basics_water`
  - `term`: `water`
  - `translation`: `Wasser`
  - `example_sentence`: `I would like some water.`
  - `notes`: `Useful everyday noun.`
  - `sort_order`: `2`
  - `is_archived`: `false`

Die Fixture ist bewusst klein gehalten. Sie prueft zuerst den echten Dateipfad und den Importmechanismus, noch nicht eine vollstaendige Lernsessiongroesse von 20 Karten.

## 5. Tests

Datei:

- `test/core/local_database/local_json_import_service_test.dart`

Fixture-bezogene Tests:

- `local_import_fixture_can_be_loaded_from_test_file`
- `local_import_fixture_creates_categories_and_words`
- `local_import_fixture_is_idempotent`
- `local_import_fixture_words_can_start_session`

### local_import_fixture_can_be_loaded_from_test_file

Sichert ab:

- Fixture kann per normalem `File(...).readAsString()` geladen werden.
- Es wird kein `rootBundle` verwendet.
- Es wird kein Flutter-Asset-System verwendet.
- JSON ist parsebar.
- Top-Level-Struktur ist eine Liste.
- mindestens eine Kategorie existiert.
- die erste Kategorie enthaelt `id`, `name` und `words`.
- `words` ist eine nicht leere Liste.

### local_import_fixture_creates_categories_and_words

Sichert ab:

- Fixture kann ueber `LocalJsonImportService` importiert werden.
- Kategorien werden erstellt.
- Woerter werden erstellt.
- die Kategorie `basics` existiert.
- das Wort `basics_hello` existiert.
- `term` und `translation` stimmen.
- `example_sentence` und `notes` werden uebernommen.
- `sort_order` wird uebernommen.
- `is_archived` wird uebernommen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### local_import_fixture_is_idempotent

Sichert ab:

- dieselbe Fixture kann mehrfach importiert werden.
- Kategorieanzahl bleibt gleich.
- Wortanzahl bleibt gleich.
- stabile Kategorie-IDs bleiben gleich.
- stabile Wort-IDs bleiben gleich.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### local_import_fixture_words_can_start_session

Sichert ab:

- Import selbst erzeugt keinen Progress.
- Import selbst erzeugt keine Session.
- Import selbst schreibt keine Review-History.
- importierte Woerter koennen danach ueber `LocalProgressInitializationService` Progress erhalten.
- ueber `LocalLearningSessionFacade.startOrResumeLearning(...)` kann danach eine lokale Session gestartet werden.
- `LocalSessionReadState` ist nutzbar.
- `sessionId` ist gesetzt.
- `currentWordId` ist gesetzt.
- `currentTerm` ist gesetzt.
- `currentTranslation` ist gesetzt.
- `currentStage == SrsStage.s0`
- `canSubmitAnswer == true`
- `learning_sessions` enthaelt eine aktive Session.
- `session_items` enthaelt Items.
- im Workspace entsteht keine alte `word_progress.db`.

## 6. Fixture Zu Import Zu Progress Zu Session

Die getestete lokale Kette lautet:

1. Fixture-Datei wird per normalem Dateizugriff geladen.
2. `LocalJsonImportService.importFromJsonString(...)` importiert Kategorien und Woerter.
3. Direkt nach Import bleiben leer:
   - `word_progress`
   - `learning_sessions`
   - `review_history`
4. `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)` initialisiert S0-Progress fuer `basics`.
5. `LocalLearningSessionFacade.startOrResumeLearning(...)` startet eine lokale Session fuer:
   - `categoryId`: `basics`
   - `mode`: `LearningMode.adaptive`
   - `trainingArea`: `TrainingArea.all`
6. Der Rueckgabewert ist ein nutzbarer `LocalSessionReadState`.

Damit ist abgesichert:

- Die Fixture liefert echte lokale Inhaltsdaten.
- Import bleibt auf Inhaltsdaten begrenzt.
- Progress entsteht erst im separaten Progress-Schritt.
- Sessions entstehen erst ueber die Facade.
- Die alte lokale DB wird nicht verwendet.

## 7. Weiterhin Geltende Grenzen

Weiterhin gilt:

- kein Asset-Import
- kein `rootBundle`
- keine App-Anbindung
- kein Supabase
- keine alte DB
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf alte `word_progress.db`
- kein Progress durch Import
- keine Session durch Import
- keine Review-History durch Import
- keine UI-Anbindung
- keine Navigation
- keine Provider-Umstellung
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Die Fixture bleibt aktuell rein lokal und testbezogen.

## 8. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/Fixture: 117 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 166 Tests bestanden
- Analyzer: `No issues found!`

## 9. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- Fixture-Block als abgeschlossen markieren
- Asset-Import separat planen
- echte Importdatei spaeter erweitern
- Fixture spaeter auf mehr Kategorien und Woerter ausbauen
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keine bestehende UI umbauen
- weiterhin Supabase unangetastet lassen

Empfehlung:

Der lokale JSON-Fixture-Block ist stabil genug, um als abgeschlossener Testbaustein behandelt zu werden. Eine spaetere Erweiterung auf mehr Inhalte oder Asset-Import sollte separat geplant und wieder isoliert getestet werden.
