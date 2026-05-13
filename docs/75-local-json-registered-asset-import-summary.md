# 75 Local JSON Registered Asset Import Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand des registrierten lokalen JSON-Asset-Imports zusammen.

Der Block ist weiterhin lokal und isoliert:

- kein automatischer App-Start-Import
- keine UI-Anbindung
- kein Supabase
- keine bestehende App-Flow-Aenderung

## 1. Aufgabe Des Registrierten Asset-Imports

Der registrierte Asset-Import stellt sicher, dass die echte lokale JSON-Datei ueber Flutter als Asset verfuegbar ist und lokal getestet geladen werden kann.

Die Kette ist jetzt abgesichert:

1. Flutter registriert die echte JSON-Datei ueber `pubspec.yaml`.
2. `rootBundle.loadString(...)` kann die Datei laden.
3. Der geladene JSON-String kann an `LocalJsonImportService.importFromJsonString(...)` uebergeben werden.
4. Kategorien und Woerter werden in eine lokale In-Memory-SQLite-Datenbank importiert.
5. Import erzeugt weiterhin keinen Progress, keine Sessions und keine Review-History.

Wichtig:

Der registrierte Asset-Import bedeutet nur, dass die Datei ladbar und importierbar ist. Er loest keinen Import automatisch aus.

## 2. Registrierte Datei In pubspec.yaml

Registrierte Datei:

- `assets/local_import/default_words_v1.json`

Aktueller relevanter `pubspec.yaml`-Ausschnitt:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/icons/
    - assets/images/
    - assets/sounds/
    - assets/local_import/default_words_v1.json
```

Damit ist genau die echte lokale JSON-Asset-Datei registriert.

## 3. Warum Nur Die Einzelne Datei

Es wurde bewusst nur die einzelne Datei registriert:

- `assets/local_import/default_words_v1.json`

Nicht registriert wurde:

- `assets/local_import/`

Gruende:

- kleinster moeglicher Scope
- keine versehentlichen weiteren Asset-Dateien
- klarer Testumfang
- weniger Risiko, Test-/Demo-/Produktdaten zu vermischen
- bessere Kontrolle ueber spaetere Inhaltsdateien
- passend zum aktuellen Stand mit genau einer echten lokalen Importdatei

Das gesamte Verzeichnis sollte erst registriert werden, wenn mehrere echte Importdateien bewusst kuratiert, getestet und fuer das App-Bundle freigegeben sind.

## 4. RootBundle-Laden

Das Laden ueber `rootBundle` wird im Test abgesichert:

- `asset_is_registered_and_loadable_with_root_bundle`

Der Test:

1. ruft `rootBundle.loadString('assets/local_import/default_words_v1.json')` auf
2. prueft, dass der Inhalt nicht leer ist
3. parst den Inhalt als JSON
4. prueft, dass die Top-Level-Struktur eine Liste ist
5. prueft, dass die Liste nicht leer ist
6. prueft, dass die erste Kategorie `id`, `name` und `words` enthaelt

Damit ist bewiesen:

- der Asset-Key ist korrekt registriert
- Flutter kann die Datei ueber `rootBundle` laden
- die geladene Datei hat die erwartete JSON-Grundstruktur

## 5. RootBundle-JSON Zu LocalJsonImportService

Der Import des ueber `rootBundle` geladenen JSON-Strings wird im Test abgesichert:

- `loaded_asset_can_be_imported_with_local_json_import_service`

Der Test:

1. laedt `assets/local_import/default_words_v1.json` ueber `rootBundle.loadString(...)`
2. oeffnet eine In-Memory-SQLite-Testdatenbank
3. erzeugt `CategoryRepository` und `WordRepository`
4. erzeugt `LocalJsonImportService`
5. importiert den geladenen JSON-String
6. prueft, dass `basics` erstellt wurde
7. prueft, dass `basics_hello` und `basics_water` erstellt wurden
8. prueft `term` und `translation`
9. prueft, dass leer bleiben:
   - `word_progress`
   - `learning_sessions`
   - `review_history`
10. prueft, dass keine alte `word_progress.db` entsteht

Damit ist die lokale Kette abgesichert:

`pubspec.yaml`-Asset-Eintrag -> `rootBundle` -> JSON-String -> `LocalJsonImportService` -> Kategorien/Woerter.

## 6. Tests

Datei:

- `test/core/local_database/local_json_import_service_test.dart`

Registrierter-Asset-bezogene Tests:

- `asset_is_registered_and_loadable_with_root_bundle`
- `loaded_asset_can_be_imported_with_local_json_import_service`

Weitere echte-Asset-Datei-Tests:

- `real_asset_file_has_valid_json_structure`
- `real_asset_file_can_be_imported_with_local_json_import_service`
- `real_asset_file_import_is_idempotent`
- `real_asset_file_words_can_start_session`

### asset_is_registered_and_loadable_with_root_bundle

Sichert ab:

- Asset ist ueber `pubspec.yaml` registriert.
- `rootBundle` kann die Datei laden.
- Inhalt ist nicht leer.
- JSON ist parsebar.
- Top-Level ist eine nicht leere Liste.
- erste Kategorie enthaelt `id`, `name` und `words`.

### loaded_asset_can_be_imported_with_local_json_import_service

Sichert ab:

- ueber `rootBundle` geladener JSON-String kann importiert werden.
- Kategorie `basics` wird erstellt.
- Woerter `basics_hello` und `basics_water` werden erstellt.
- `term` und `translation` stimmen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- keine alte `word_progress.db` entsteht.

### real_asset_file_has_valid_json_structure

Sichert weiterhin ab:

- die echte Datei existiert am erwarteten Pfad.
- normaler Dateizugriff kann die Datei lesen.
- Kategorie- und Wortpflichtfelder sind vorhanden.

### real_asset_file_can_be_imported_with_local_json_import_service

Sichert weiterhin ab:

- die echte Datei kann per normalem `File` geladen und importiert werden.
- alle aktuellen Felder der Kategorie und Woerter werden uebernommen.
- Import erzeugt keinen Progress, keine Sessions und keine Review-History.

### real_asset_file_import_is_idempotent

Sichert weiterhin ab:

- dieselbe echte Datei kann mehrfach importiert werden.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- stabile IDs bleiben gleich.

### real_asset_file_words_can_start_session

Sichert weiterhin ab:

- importierte Woerter koennen danach Progress initialisieren.
- danach kann eine lokale Session gestartet werden.
- Import selbst bleibt ohne Progress, Session und Review-History.

## 7. Weiterhin Geltende Grenzen

Weiterhin gilt:

- kein automatischer App-Start-Import
- keine UI-Anbindung
- keine Navigation
- keine Provider-Umstellung
- kein Supabase
- keine Supabase-Entfernung
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf alte `word_progress.db`
- kein Progress durch Import
- keine Sessions durch Import
- keine Review-History durch Import
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Der Asset-Eintrag und die Tests machen die Datei nur ladbar und importierbar. Sie verbinden sie nicht mit dem App-Start oder einer UI.

## 8. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/AssetImport/RegisteredAsset/Fixture: 126 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 175 Tests bestanden
- Analyzer: `No issues found!`

Hinweise:

- keine Testfehler
- bekannte Flutter-Hinweise zu neueren Package-Versionen
- gelegentliches Warten auf den Flutter-Startup-Lock bei parallelen Flutter-Kommandos

## 9. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- registrierten Asset-Import als abgeschlossen markieren
- kontrollierte Importausloesung separat planen
- entscheiden, ob der Import spaeter manuell, debug-only oder ueber einen expliziten lokalen Service angestossen wird
- weiterhin keinen automatischen App-Start-Import einfuehren
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keine bestehende UI umbauen
- weiterhin Supabase und alte lokale DBs unangetastet lassen

Empfehlung:

Der registrierte lokale JSON-Asset-Import ist als isolierter Block abgeschlossen. Der naechste Schritt sollte nicht die bestehende App-Integration sein, sondern eine separate Planung fuer eine kontrollierte, bewusst ausgeloeste Importausfuehrung.
