# 79 Local Debug Import Controller Summary

Stand: 2026-05-14

## Zweck

Dieses Dokument fasst den aktuellen Stand des `LocalDebugImportController` zusammen.

Der Controller ist ein isolierter Debug-only Baustein fuer den kontrollierten lokalen Asset-Import. Er ist nicht an UI, Navigation, Provider, App-Start oder Supabase angebunden.

## 1. Aufgabe Des LocalDebugImportController

Datei:

- `lib/core/local_database/controllers/local_debug_import_controller.dart`

Der Controller uebernimmt:

- kontrollierten Asset-Import explizit ausloesen
- Debug-/QA-State halten
- erfolgreichen Importzeitpunkt speichern
- Importfehler als Debug-Fehlerzustand abbilden
- Debug-State zuruecksetzen

Der Controller macht nicht:

- keine Datenbank selbst oeffnen
- keine eigene JSON-Ladelogik
- keine eigene Importlogik
- keine Provider bereitstellen
- keine UI kennen
- keine Navigation kennen
- kein Supabase kennen
- keinen Progress erzeugen
- keine Session starten
- keine Review-History schreiben

## 2. Abhaengigkeit

Der Controller nutzt genau eine fachliche Abhaengigkeit:

- `LocalControlledAssetImportService`

Die Importkette bleibt:

`LocalDebugImportController` -> `LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService` -> lokale Repositorys.

Der Controller kennt nur den registrierten Default-Asset-Key:

- `assets/local_import/default_words_v1.json`

Er kennt keine Supabase-Repositorys, keine alte lokale DB und keine UI-Modelle.

## 3. Methoden

### importDefaultWords(...)

Methode:

- `importDefaultWords({required DateTime now})`

Verhalten:

1. setzt vor dem Import:
   - `isLoading = true`
   - `errorMessage = null`
   - `wasSuccessful = false`
2. ruft `LocalControlledAssetImportService.importRegisteredAsset(...)` auf mit:
   - `assetKey`: `assets/local_import/default_words_v1.json`
   - `now`: uebergebener Zeitpunkt
3. setzt bei Erfolg:
   - `isLoading = false`
   - `errorMessage = null`
   - `wasSuccessful = true`
   - `lastImportedAt = now`
   - `lastAction = importDefaultWords`
4. setzt bei Fehler:
   - `isLoading = false`
   - `errorMessage = error.toString()`
   - `wasSuccessful = false`
   - `lastImportedAt` bleibt unveraendert
   - `lastAction = importDefaultWordsFailed`

Die Methode startet keine Session und erzeugt keinen Progress.

### resetDebugState(...)

Methode:

- `resetDebugState()`

Verhalten:

- setzt `isLoading = false`
- setzt `errorMessage = null`
- setzt `wasSuccessful = false`
- setzt `lastImportedAt = null`
- setzt `lastAction = resetDebugState`

Die Methode veraendert keine importierten Kategorien oder Woerter. Sie schreibt auch keinen Progress, keine Sessions und keine Review-History.

## 4. State

State-Klasse:

- `LocalDebugImportControllerState`

Felder:

- `isLoading`
- `errorMessage`
- `wasSuccessful`
- `lastImportedAt`
- `lastAction`

### isLoading

Zeigt, ob gerade ein Debug-Import laeuft.

### errorMessage

Enthaelt einen technischen Fehlerhinweis fuer Debug/QA. Es werden keine Produkttexte oder UI-Texte erzeugt.

### wasSuccessful

Zeigt, ob der letzte Import erfolgreich abgeschlossen wurde.

### lastImportedAt

Speichert den Zeitpunkt des letzten erfolgreichen Imports.

### lastAction

Enum:

- `none`
- `importDefaultWords`
- `importDefaultWordsFailed`
- `resetDebugState`

Damit bleibt der Controller-State einfach testbar und UI-neutral.

## 5. Tests

Datei:

- `test/core/local_database/local_debug_import_controller_test.dart`

Tests:

- `debug_import_controller_imports_default_words_when_called`
- `debug_import_controller_does_not_import_on_initialization`
- `debug_import_controller_sets_error_state_on_failure`
- `debug_import_controller_reset_debug_state_does_not_modify_data`

### Expliziter Import

`debug_import_controller_imports_default_words_when_called` sichert ab:

- vor Methodenaufruf sind lokale Tabellen leer
- `importDefaultWords(...)` importiert erst bei explizitem Aufruf
- Kategorie `basics` existiert danach
- Woerter `basics_hello` und `basics_water` existieren danach
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- State zeigt erfolgreichen Import

### Kein Import Bei Initialisierung

`debug_import_controller_does_not_import_on_initialization` sichert ab:

- Controller-Erzeugung importiert nichts
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- initialer State ist sauber:
  - `isLoading == false`
  - `wasSuccessful == false`
  - `errorMessage == null`
  - `lastImportedAt == null`
  - `lastAction == none`

### Erfolgs-State

Der Erfolgs-State wird im expliziten Importtest abgesichert:

- `wasSuccessful == true`
- `isLoading == false`
- `errorMessage == null`
- `lastImportedAt == fixedNow`
- `lastAction == importDefaultWords`

### Fehler-State

`debug_import_controller_sets_error_state_on_failure` sichert ab:

- ein fehlschlagender Import wird abgefangen
- `isLoading == false`
- `wasSuccessful == false`
- `errorMessage` ist gesetzt
- `lastImportedAt == null`
- `lastAction == importDefaultWordsFailed`
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

### Reset Ohne Datenaenderung

`debug_import_controller_reset_debug_state_does_not_modify_data` sichert ab:

- nach erfolgreichem Import sind Kategorie und Woerter vorhanden
- `resetDebugState()` setzt nur den Debug-State zurueck
- Kategorie `basics` bleibt vorhanden
- Woerter `basics_hello` und `basics_water` bleiben vorhanden
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- `lastAction == resetDebugState`

## 6. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- keine Debug-Route
- kein Provider
- kein App-Start-Import
- keine Navigation
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

Der Controller bleibt ein lokaler Debug-Baustein, noch kein App-Feature.

## 7. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis des letzten vollstaendigen lokalen Checks:

- SRS: 39 Tests bestanden
- Local Database inkl. Import/AssetImport/ControlledImport/DebugImportController/RegisteredAsset/Fixture: 133 Tests bestanden
- Local Learning Debug/Testscreen: 10 Tests bestanden
- Gesamt: 182 Tests bestanden
- Analyzer: `No issues found!`

Hinweise:

- keine Testfehler
- bekannte Flutter-Hinweise zu neueren Package-Versionen
- gelegentliches Warten auf den Flutter-Startup-Lock bei parallelen Flutter-Kommandos

## 8. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte sind:

- Debug-Import-Controller als abgeschlossen markieren
- optional Debug-Import-Provider separat planen
- optional Debug-Import-Button separat planen
- optional Settings-Marker fuer Importdiagnose separat planen
- weiterhin keinen automatischen App-Start-Import einfuehren
- weiterhin keine App-Flow-Anbindung vornehmen
- weiterhin keine bestehende UI umbauen
- weiterhin Supabase und alte lokale DBs unangetastet lassen

Empfehlung:

Der `LocalDebugImportController` ist als isolierter Debug-only Controller abgeschlossen. Ein moeglicher Provider oder Button sollte separat geplant und weiterhin nicht an bestehende App-Flows angebunden werden.
