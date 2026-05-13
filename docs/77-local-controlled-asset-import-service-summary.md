# 77 Local Controlled Asset Import Service Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand des `LocalControlledAssetImportService` zusammen.

Der Service ist ein lokaler, UI-neutraler Ausloesebaustein fuer den registrierten JSON-Asset-Import. Er fuehrt keinen Import automatisch aus und ist nicht an App-Start, UI, Provider-Automatik, Debug-Route oder Supabase angebunden.

## 1. Aufgabe Des LocalControlledAssetImportService

Datei:

- `lib/core/local_database/services/local_controlled_asset_import_service.dart`

Der Service uebernimmt genau eine Aufgabe:

- einen expliziten registrierten Asset-Import ausloesen

Dafuer nutzt er:

- `LocalJsonAssetImportService`

Der Service macht nicht:

- keine eigene JSON-Ladelogik
- keine eigene JSON-Validierung
- keine eigene Importlogik
- keine eigene Repository-Logik
- keine Datenbank selbst oeffnen
- kein Supabase kennen
- keinen Progress erzeugen
- keine Session starten
- keine Review-History schreiben

Damit bleibt er eine bewusst kleine Delegationsschicht.

## 2. importRegisteredAsset(...)

Methode:

- `importRegisteredAsset({required String assetKey, required DateTime now})`

Verhalten:

1. nimmt einen expliziten `assetKey` entgegen
2. nimmt einen expliziten Zeitpunkt `now` entgegen
3. ruft `LocalJsonAssetImportService.importFromAsset(assetKey: assetKey, now: now)` auf
4. gibt dessen `Future<void>` zurueck

Die Methode enthaelt keine eigene Fachlogik:

- keine Asset-Key-Sonderlogik
- keine Importvalidierung
- keine Idempotenzpruefung
- keine Progress-Initialisierung
- keine Session-Erzeugung
- keine Review-History-Erzeugung

Die eigentliche Arbeit bleibt in der bestehenden Kette:

`LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService` -> `CategoryRepository`/`WordRepository`.

## 3. Warum Nur Explizit Ausgeloest

Der Import wird bewusst nur explizit ausgeloest, weil lokale Inhaltsdaten nicht unkontrolliert in eine echte lokale Datenbank geschrieben werden sollen.

Nicht erlaubt:

- automatischer App-Start-Import
- automatische Ausfuehrung durch `LocalAppBootstrap`
- automatische Ausfuehrung durch `localBootstrapProvider`
- automatische Ausfuehrung beim Lesen eines Providers
- Debug-Route oder Navigation in diesem Schritt
- UI-Button in diesem Schritt

Diese Trennung verhindert:

- unerwartete Datenbefuellung
- Vermischung von Bootstrap und Import
- versehentliche Demo-Daten in echten lokalen Datenbanken
- schwer nachvollziehbare App-Start-Nebenwirkungen

Der Import bleibt ein bewusster Datenbefuellungsschritt.

## 4. Schutz Gegen Bootstrap-/Provider-Automatik

Abgesichert ist:

- `LocalAppBootstrap.bootstrap(seedDefaults: false, ...)` importiert das registrierte Asset nicht.
- Ohne expliziten Aufruf von `LocalControlledAssetImportService.importRegisteredAsset(...)` bleiben Inhalts- und Lerntabellen leer.

Getestet wird aktuell der Bootstrap-Pfad:

- Bootstrap oeffnet eine lokale Testdatenbank.
- `seedDefaults` ist `false`.
- `importRegisteredAsset(...)` wird nicht aufgerufen.
- Danach bleiben leer:
  - `categories`
  - `words`
  - `word_progress`
  - `learning_sessions`
  - `review_history`

Damit ist bewiesen:

- Bootstrap allein importiert das registrierte Asset nicht.
- Import passiert nur durch expliziten Controlled-Import-Aufruf.
- Die vorhandene Bootstrap-Schicht bleibt datenbefuellungsfrei, solange sie nicht bewusst anders erweitert wird.

Der lokale Bootstrap-Provider bleibt ebenfalls ohne Import-Automatik, weil er weiterhin nur `LocalAppBootstrap.bootstrap(..., seedDefaults: false, ...)` aufruft und keinen Controlled-Import-Service verwendet.

## 5. Tests

Datei:

- `test/core/local_database/local_controlled_asset_import_service_test.dart`

Tests:

- `controlled_import_loads_registered_asset_and_imports_words`
- `controlled_import_is_idempotent`
- `controlled_import_does_not_run_on_bootstrap_without_explicit_call`

### controlled_import_loads_registered_asset_and_imports_words

Sichert ab:

- `LocalControlledAssetImportService.importRegisteredAsset(...)` kann das registrierte Asset importieren.
- Asset-Key `assets/local_import/default_words_v1.json` wird verwendet.
- Kategorie `basics` wird erstellt.
- Woerter `basics_hello` und `basics_water` werden erstellt.
- `term` und `translation` stimmen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- keine alte `word_progress.db` entsteht.

### controlled_import_is_idempotent

Sichert ab:

- derselbe kontrollierte Asset-Import kann mehrfach laufen.
- Kategorieanzahl bleibt gleich.
- Wortanzahl bleibt gleich.
- stabile Kategorie-IDs bleiben gleich.
- stabile Wort-IDs bleiben gleich.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- keine alte `word_progress.db` entsteht.

### controlled_import_does_not_run_on_bootstrap_without_explicit_call

Sichert ab:

- `LocalAppBootstrap` loest keinen registrierten Asset-Import aus.
- `seedDefaults: false` bleibt datenbefuellungsfrei.
- ohne expliziten Controlled-Import-Aufruf bleiben leer:
  - `categories`
  - `words`
  - `word_progress`
  - `learning_sessions`
  - `review_history`
- keine alte `word_progress.db` entsteht.

## 6. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- kein App-Start-Import
- keine Navigation
- keine Debug-Route
- keine Provider-Automatik
- keine Bootstrap-Automatik
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

Der Service ist ein lokaler Baustein, aber noch kein App-Feature.

## 7. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/AssetImport/ControlledImport/RegisteredAsset/Fixture: 129 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 178 Tests bestanden
- Analyzer: `No issues found!`

Hinweise:

- keine Testfehler
- bekannte Flutter-Hinweise zu neueren Package-Versionen
- gelegentliches Warten auf den Flutter-Startup-Lock bei parallelen Flutter-Kommandos

## 8. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- Controlled Import als abgeschlossen markieren
- optional einen Debug-Import-Button separat planen
- optional einen Debug-only Import-Controller separat planen
- optional einen Settings-Marker fuer spaetere Importdiagnose planen
- weiterhin keinen automatischen App-Start-Import einfuehren
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keine bestehende UI umbauen
- weiterhin Supabase und alte lokale DBs unangetastet lassen

Empfehlung:

Der `LocalControlledAssetImportService` ist als expliziter, isolierter Importausloeser abgeschlossen. Ein naechster Schritt sollte nur separat geplant werden, z. B. als Debug-only Importausloesung. Bestehende App-Flows sollten weiterhin nicht angebunden werden.
