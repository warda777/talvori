# 73 Local JSON Real Asset File Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand der echten lokalen JSON-Asset-Datei fuer spaetere Offline-first-Importdaten zusammen.

Die Datei existiert bereits lokal, ist aber noch nicht als Flutter-Asset registriert und noch nicht in App-Flows eingebunden.

## 1. Aufgabe Der Echten Asset-Datei

Die echte Asset-Datei stellt lokale Inhaltsdaten fuer den spaeteren App-Asset-Import bereit:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- `sort_order`
- `is_archived`

Sie ist als spaetere App-Bundle-Datenquelle gedacht, aber aktuell bewusst nur per normalem Dateizugriff getestet.

Die Datei erzeugt selbst keinen Lernzustand:

- kein `word_progress`
- keine `learning_sessions`
- keine `session_items`
- keine `review_history`

Progress und Sessions entstehen weiterhin erst durch die bestehenden lokalen Services.

## 2. Speicherort

Die echte lokale Asset-Datei liegt unter:

- `assets/local_import/default_words_v1.json`

Der Pfad ist bewusst von der Test-Fixture getrennt:

- echte Asset-Datei: `assets/local_import/default_words_v1.json`
- Test-Fixture: `test/fixtures/local_import/default_words_v1.json`

Der Pfad ist noch nicht in `pubspec.yaml` eingetragen.

## 3. Struktur

Die Datei hat eine Top-Level-Liste von Kategorien.

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

Aktuell enthaelt die Datei eine Kategorie:

- `basics`

Kategorie:

- `id`: `basics`
- `name`: `Basics`
- `description`: `Essential starter words for local offline-first import.`
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

Der Umfang ist bewusst klein. Die Datei prueft zuerst den echten Asset-Dateipfad, die JSON-Struktur, den Import und die lokale Lernkette. Eine Erweiterung auf mehr Kategorien oder eine volle Sessiongroesse bleibt ein separater Schritt.

## 5. Unterschied Zur Test-Fixture

Die Test-Fixture unter `test/fixtures/local_import/default_words_v1.json` bleibt ein reines Testartefakt.

Die echte Asset-Datei unter `assets/local_import/default_words_v1.json` ist fuer spaetere App-Bundle-Daten vorgesehen.

Wichtige Unterschiede:

- Die Fixture ist ausschliesslich Testdatenquelle.
- Die echte Asset-Datei ist eine moegliche spaetere App-Datenquelle.
- Die Fixture braucht keinen `pubspec.yaml`-Eintrag.
- Die echte Asset-Datei braucht spaeter einen `pubspec.yaml`-Eintrag, bevor sie ueber Flutter-Assets geladen werden kann.
- Die aktuellen Tests lesen beide Dateien bewusst per `File(...).readAsString()`.
- Es wird aktuell kein `rootBundle` genutzt.

Damit bleiben Testdaten und spaetere App-Daten klar getrennt.

## 6. Tests

Datei:

- `test/core/local_database/local_json_import_service_test.dart`

Tests fuer die echte Asset-Datei:

- `real_asset_file_has_valid_json_structure`
- `real_asset_file_can_be_imported_with_local_json_import_service`
- `real_asset_file_import_is_idempotent`
- `real_asset_file_words_can_start_session`

### real_asset_file_has_valid_json_structure

Sichert ab:

- Datei existiert am erwarteten Pfad.
- Datei kann per normalem `File(...).readAsString()` geladen werden.
- JSON ist parsebar.
- Top-Level-Struktur ist eine Liste.
- mindestens eine Kategorie existiert.
- Kategorie-Pflichtfelder sind vorhanden.
- `words` ist eine nicht leere Liste.
- Wort-Pflichtfelder sind vorhanden.

### real_asset_file_can_be_imported_with_local_json_import_service

Sichert ab:

- echte Asset-Datei kann ueber `LocalJsonImportService` importiert werden.
- Kategorie `basics` wird erstellt.
- Woerter `basics_hello` und `basics_water` werden erstellt.
- `term`, `translation`, `example_sentence`, `notes`, `sort_order` und `is_archived` werden uebernommen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- alte `word_progress.db` entsteht nicht.

### real_asset_file_import_is_idempotent

Sichert ab:

- dieselbe echte Asset-Datei kann mehrfach importiert werden.
- Kategorieanzahl bleibt gleich.
- Wortanzahl bleibt gleich.
- stabile Kategorie-IDs bleiben gleich.
- stabile Wort-IDs bleiben gleich.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- alte `word_progress.db` entsteht nicht.

### real_asset_file_words_can_start_session

Sichert ab:

- Import selbst erzeugt keinen Progress.
- Import selbst erzeugt keine Session.
- Import selbst schreibt keine Review-History.
- importierte Woerter koennen danach ueber `LocalProgressInitializationService` Progress erhalten.
- danach kann ueber `LocalLearningSessionFacade.startOrResumeLearning(...)` eine lokale Session gestartet werden.
- Rueckgabe ist ein nutzbarer `LocalSessionReadState`.
- `sessionId` ist gesetzt.
- `currentWordId` ist gesetzt.
- `currentTerm` ist gesetzt.
- `currentTranslation` ist gesetzt.
- `currentStage == SrsStage.s0`.
- `canSubmitAnswer == true`.
- `learning_sessions` enthaelt eine aktive Session.
- `session_items` enthaelt Items.
- alte `word_progress.db` entsteht nicht.

## 7. Asset-Datei Zu Import Zu Progress Zu Session

Die getestete lokale Kette lautet:

1. `assets/local_import/default_words_v1.json` wird per normalem Dateizugriff geladen.
2. `LocalJsonImportService.importFromJsonString(...)` importiert Kategorie und Woerter.
3. Direkt nach Import bleiben leer:
   - `word_progress`
   - `learning_sessions`
   - `review_history`
4. `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)` initialisiert S0-Progress fuer:
   - `categoryId`: `basics`
   - `mode`: `LearningMode.adaptive`
5. `LocalLearningSessionFacade.startOrResumeLearning(...)` startet eine lokale Session fuer:
   - `categoryId`: `basics`
   - `mode`: `LearningMode.adaptive`
   - `trainingArea`: `TrainingArea.all`
6. Der Rueckgabewert ist ein nutzbarer `LocalSessionReadState`.

Damit ist abgesichert:

- Die echte Asset-Datei liefert importierbare lokale Inhaltsdaten.
- Import bleibt auf Kategorien und Woerter begrenzt.
- Progress entsteht erst im separaten Progress-Schritt.
- Sessions entstehen erst ueber die Facade.
- Supabase und alte lokale DBs werden nicht benoetigt.

## 8. Weiterhin Geltende Grenzen

Weiterhin gilt:

- noch keine `pubspec.yaml`-Aenderung
- noch kein `rootBundle`
- noch keine `AssetBundle`-Ladung der echten Datei
- noch keine App-Anbindung
- kein automatischer Import beim App-Start
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

Die echte Asset-Datei bleibt damit lokal, isoliert und ohne App-Flow-Risiko.

## 9. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/AssetFile/AssetImport/Fixture: 124 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 173 Tests bestanden
- Analyzer: `No issues found!`

## 10. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- echte Asset-Datei als abgeschlossen markieren
- `pubspec.yaml`-Asset-Eintrag separat planen
- `rootBundle`-/`AssetBundle`-Test separat planen
- spaeter entscheiden, ob `basics` auf mehr Woerter erweitert wird
- spaeter entscheiden, ob weitere Kategorien wie `travel` oder `exam_practice` in die echte Asset-Datei gehoeren
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keinen automatischen Import beim App-Start einfuehren
- weiterhin Supabase und alte lokale DBs unangetastet lassen

Empfehlung:

Die echte lokale JSON-Asset-Datei ist als isolierter Datei-, Import- und Lernkettenbaustein abgeschlossen. Der naechste Schritt sollte nicht die bestehende UI sein, sondern separat geplant werden: `pubspec.yaml`-Registrierung, `AssetBundle`/`rootBundle`-Test oder bewusste Erweiterung der Inhaltsdaten.
