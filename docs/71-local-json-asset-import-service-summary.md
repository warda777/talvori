# 71 Local JSON Asset Import Service Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand des `LocalJsonAssetImportService` zusammen.

Der Service ist ein kleiner lokaler Lade- und Delegationsbaustein fuer spaetere JSON-Assets. Er ist noch nicht an echte App-Assets, `pubspec.yaml`, UI, Provider oder App-Flows angebunden.

## 1. Aufgabe Des LocalJsonAssetImportService

Datei:

- `lib/core/local_database/services/local_json_asset_import_service.dart`

Der Service uebernimmt:

- JSON-String aus einem injizierten `AssetBundle` laden
- den geladenen JSON-String zurueckgeben
- optional den geladenen JSON-String an `LocalJsonImportService.importFromJsonString(...)` delegieren

Der Service enthaelt keine eigene Importlogik:

- keine eigene JSON-Validierung
- keine eigene Repository-Logik
- keine eigene Idempotenzlogik
- keine eigene Progress-Logik
- keine Session-Logik
- keine Review-History-Logik

## 2. AssetBundle-Injection

`LocalJsonAssetImportService` erhaelt ein `AssetBundle` im Konstruktor.

Dadurch gilt:

- Tests koennen ein Fake- oder Memory-Bundle verwenden.
- Der Service muss nicht direkt `rootBundle` verwenden.
- Es ist keine echte Asset-Datei fuer die aktuellen Tests noetig.
- `pubspec.yaml` muss fuer die aktuellen Tests nicht geaendert werden.
- Der Ladeweg bleibt testbar und UI-neutral.

Diese Trennung ist wichtig, weil App-Assets spaeter ueber Flutter registriert werden, die aktuelle lokale Testschicht aber weiterhin isoliert bleiben soll.

## 3. loadJsonFromAsset(...)

Methode:

- `loadJsonFromAsset(String assetKey)`

Verhalten:

1. nimmt einen Asset-Key entgegen
2. ruft intern `assetBundle.loadString(assetKey)` auf
3. gibt den geladenen JSON-String zurueck

Die Methode:

- oeffnet keine Datenbank
- ruft keinen Importservice auf
- liest keine Datei per `File`
- nutzt kein Supabase
- erzeugt keinen Progress
- startet keine Session
- schreibt keine Review-History

## 4. importFromAsset(...)

Methode:

- `importFromAsset({required String assetKey, required DateTime now})`

Verhalten:

1. laedt JSON ueber `loadJsonFromAsset(assetKey)`
2. delegiert an `LocalJsonImportService.importFromJsonString(json: ..., now: now)`

Der Service darf dafuer optional einen `LocalJsonImportService` im Konstruktor erhalten.

Wichtig:

- Die eigentliche Validierung bleibt im `LocalJsonImportService`.
- Kategorien werden weiterhin dort ueber `CategoryRepository` gespeichert.
- Woerter werden weiterhin dort ueber `WordRepository` gespeichert.
- Idempotenz bleibt ueber stabile IDs und Repository-`upsert`s abgesichert.
- Der Asset-Service dupliziert keine Importregeln.

Wenn `importFromAsset(...)` ohne `LocalJsonImportService` aufgerufen wird, wirft der Service einen `StateError`. Dadurch bleibt der reine Ladefall weiterhin ohne Datenbank nutzbar.

## 5. Tests

Datei:

- `test/core/local_database/local_json_asset_import_service_test.dart`

Vorhandene Tests:

- `local_asset_import_loads_json_from_bundle`
- `local_asset_import_delegates_to_json_import_service`
- `local_asset_import_is_idempotent`

### local_asset_import_loads_json_from_bundle

Sichert ab:

- JSON wird aus einem Memory-`AssetBundle` geladen.
- der richtige Asset-Key wird verwendet.
- der geladene JSON-String wird zurueckgegeben.
- keine Datenbank wird geoeffnet.
- keine echte Asset-Datei ist noetig.
- keine `pubspec.yaml`-Aenderung ist noetig.

### local_asset_import_delegates_to_json_import_service

Sichert ab:

- `importFromAsset(...)` laedt JSON aus dem Bundle.
- der geladene JSON-String wird an `LocalJsonImportService` delegiert.
- Kategorien werden erstellt.
- Woerter werden erstellt.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### local_asset_import_is_idempotent

Sichert ab:

- derselbe Asset-Import kann mehrfach laufen.
- Kategorieanzahl bleibt gleich.
- Wortanzahl bleibt gleich.
- stabile Kategorie-IDs bleiben gleich.
- stabile Wort-IDs bleiben gleich.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

## 6. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine echte Asset-Datei
- keine `pubspec.yaml`-Aenderung
- keine UI-Anbindung
- keine Navigation
- kein Supabase
- keine alte DB
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf alte `word_progress.db`
- kein Progress durch Import
- keine Sessions durch Import
- keine Review-History durch Import
- kein automatischer App-Start-Import
- keine Provider-Umstellung
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Der Service bleibt damit lokal, isoliert und testbar.

## 7. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/AssetImport/Fixture: 120 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 169 Tests bestanden
- Analyzer: `No issues found!`

## 8. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- Asset-Import-Service als abgeschlossen betrachten
- echte Asset-Datei separat planen
- `pubspec.yaml`-Asset-Eintrag separat planen
- spaeter eine echte Asset-Datei getrennt von der Test-Fixture anlegen
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keinen automatischen App-Start-Import einfuehren
- weiterhin Supabase unangetastet lassen

Empfehlung:

Der `LocalJsonAssetImportService` ist als isolierter Lade- und Delegationsbaustein stabil genug. Die naechsten Schritte sollten nur separat und bewusst geplant werden: echte Asset-Datei, `pubspec.yaml`-Eintrag und erst danach eine kontrollierte lokale Importausloesung.
