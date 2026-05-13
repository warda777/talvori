# 67 Local JSON Import Validation Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst die erweiterte Importvalidierung des `LocalJsonImportService` zusammen.

Der Service bleibt ein lokaler, UI-neutraler Importbaustein fuer Kategorien und Woerter in der neuen Offline-first-Datenbank `talvori_local_v1.db`. Die Validierung schuetzt den Import vor ungueltigen Pflichtdaten und vor doppelten IDs innerhalb einer einzelnen Importdatei.

## 1. Umgesetzte Validierungen

Aktuell sind folgende Validierungen umgesetzt:

- fehlende oder leere Kategorie-ID wird abgelehnt
- fehlender oder leerer Wortbegriff wird abgelehnt
- doppelte Kategorie-IDs innerhalb derselben Importdatei werden abgelehnt
- doppelte Wort-IDs innerhalb derselben Importdatei werden abgelehnt

Die Validierung fuer Pflichtfelder liegt in:

- `lib/core/local_database/import/local_json_import_models.dart`

Die Validierung eindeutiger IDs innerhalb einer Importdatei liegt in:

- `lib/core/local_database/services/local_json_import_service.dart`

Bei ungueltigen Importdaten wird eine `FormatException` geworfen.

## 2. Atomizitaet

Der Import bleibt bei Validierungsfehlern atomar.

Das bedeutet:

- bei Fehlern entsteht kein Teilimport
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

Wichtig ist dabei die Reihenfolge:

1. JSON wird geparst.
2. Kategorien und Woerter werden in Importmodelle umgewandelt.
3. doppelte IDs innerhalb der Importdatei werden geprueft.
4. erst danach werden Repositories aufgerufen.

Dadurch werden fehlerhafte Importdateien abgewiesen, bevor Kategorien oder Woerter gespeichert werden.

## 3. Tests

Datei:

- `test/core/local_database/local_json_import_service_test.dart`

Vorhandene Tests fuer die Importvalidierung:

- `local_import_rejects_missing_category_id`
- `local_import_rejects_missing_word_term`
- `local_import_rejects_duplicate_category_ids_in_import_file`
- `local_import_rejects_duplicate_word_ids_in_import_file`

### local_import_rejects_missing_category_id

Sichert ab:

- eine Kategorie mit leerer ID wird abgelehnt
- der Import wirft eine `FormatException`
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

### local_import_rejects_missing_word_term

Sichert ab:

- ein Wort mit leerem `term` wird abgelehnt
- der Import wirft eine `FormatException`
- es bleibt kein vorheriger Kategorie-Teilimport bestehen
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

### local_import_rejects_duplicate_category_ids_in_import_file

Sichert ab:

- doppelte Kategorie-IDs innerhalb derselben Importdatei werden abgelehnt
- der Import wirft eine `FormatException`
- kein Teilimport wird gespeichert
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

### local_import_rejects_duplicate_word_ids_in_import_file

Sichert ab:

- doppelte Wort-IDs innerhalb derselben Importdatei werden abgelehnt
- der Import wirft eine `FormatException`
- kein Teilimport wird gespeichert
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

## 4. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- keine Supabase-Nutzung
- keine Flutter-Assets
- kein `rootBundle`
- kein echter Dateizugriff
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf die alte `word_progress.db`
- kein Progress-Import
- keine Session-Erzeugung durch Import
- keine Review-History durch Import
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Der Importservice bleibt damit klar auf Inhaltsdaten begrenzt.

## 5. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Importvalidierung: 113 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 162 Tests bestanden
- Analyzer: `No issues found!`

## 6. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- Importvalidierung als abgeschlossen betrachten
- Asset-Import separat planen
- echte Importdatei oder Test-Fixture separat planen
- JSON-Struktur fuer kuratierte lokale Inhaltsdaten festlegen
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keine bestehende UI umbauen
- weiterhin keinen Supabase-Import direkt in die App einbauen

Empfehlung:

Der erweiterte Importvalidierungsblock ist stabil genug, um als abgeschlossener lokaler Teilbaustein behandelt zu werden. Der naechste Schritt sollte wieder nur Planung sein: entweder Asset-Import, eine echte Import-Fixture oder die spaetere Einbindung in einen bewusst isolierten Importpfad.
