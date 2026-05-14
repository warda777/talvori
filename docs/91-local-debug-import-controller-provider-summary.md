# 91 Local Debug Import Controller Provider Summary

Stand: 2026-05-14

## 1. Aufgabe Des Providers

Der `LocalDebugImportControllerProvider` stellt den lokalen Debug-Import-Controller fuer den isolierten Debug-Kontext bereit.

Datei:

- `lib/core/local_database/providers/local_debug_import_controller_provider.dart`

Der Provider uebernimmt:

- `LocalDebugImportControllerState` asynchron bereitstellen
- `LocalDebugImportController` intern aufbauen
- die bestehende lokale Importkette verbinden
- `importDefaultWords(...)` als explizite Notifier-Methode bereitstellen
- AssetBundle-Injection fuer Tests ermoeglichen

Der Provider macht nicht:

- keinen Import beim Lesen
- keine neue Datenbank oeffnen
- kein Supabase kennen
- keine UI kennen
- keine Navigation ausloesen
- keinen App-Start-Import ausloesen

## 2. Nutzung Von localBootstrapProvider

Der Provider nutzt:

- `localBootstrapProvider`

Im `build()` wartet der `AsyncNotifier` auf:

- `ref.watch(localBootstrapProvider.future)`

Damit verwendet der Debug-Import-Provider denselben lokalen Bootstrap-Pfad wie die restliche lokale Schicht. Der bestehende DB-Lifecycle bleibt beim Bootstrap-Provider.

Wichtig:

- Der Provider oeffnet keine eigene Datenbank.
- Der Provider fuehrt keinen Seed aus.
- Der Provider startet keinen Import beim Lesen.

## 3. Nutzung Von LocalRepositoryFactory

Aus dem `LocalAppBootstrapResult` liest der Provider:

- `repositoryFactory`

Aus dieser bestehenden `LocalRepositoryFactory` nutzt er:

- `categoryRepository`
- `wordRepository`

Damit werden Kategorien und Woerter spaeter ueber die bereits vorhandene lokale Repository-Schicht importiert. Es werden keine Repositories direkt im Provider aus einer neuen DB erzeugt.

## 4. Aufbau Der Importkette

Der Provider baut im `build()` diese Kette auf:

1. `LocalJsonImportService`
   - nutzt `categoryRepository`
   - nutzt `wordRepository`
2. `LocalJsonAssetImportService`
   - nutzt `AssetBundle`
   - nutzt `LocalJsonImportService`
3. `LocalControlledAssetImportService`
   - nutzt `LocalJsonAssetImportService`
4. `LocalDebugImportController`
   - nutzt `LocalControlledAssetImportService`

Die fachliche Kette bleibt:

`LocalDebugImportController` -> `LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService` -> lokale Repositorys.

## 5. AssetBundle-Injection

Der Provider enthaelt:

- `localDebugImportAssetBundleProvider`

Default:

- `rootBundle`

Tests koennen diesen Provider mit einem Memory-AssetBundle ueberschreiben. Dadurch laesst sich der Importpfad ohne echte Asset-Datei und ohne `rootBundle`-Abhaengigkeit pruefen.

Das verhindert fragile Tests und haelt den Provider trotzdem im App-Pfad kompatibel mit dem registrierten Asset.

## 6. Warum Beim Lesen Kein Import Passiert

Beim Lesen von `localDebugImportControllerProvider` passiert nur:

- Bootstrap-Ergebnis abwarten
- lokale Importservices konstruieren
- `LocalDebugImportController` konstruieren
- initialen Controller-State zurueckgeben

Es wird nicht aufgerufen:

- `importDefaultWords(...)`
- `importRegisteredAsset(...)`
- `importFromAsset(...)`
- `importFromJsonString(...)`

Dadurch bleiben beim reinen Lesen leer:

- `categories`
- `words`
- `word_progress`
- `learning_sessions`
- `review_history`

## 7. Expliziter Import Ueber importDefaultWords(...)

Der Provider stellt im Notifier bereit:

- `importDefaultWords({required DateTime now})`

Diese Methode:

1. setzt den Provider-State auf Loading
2. ruft `LocalDebugImportController.importDefaultWords(now: now)` auf
3. uebernimmt danach den Controller-State

Nur dieser explizite Methodenaufruf loest den Import aus.

Bei Erfolg zeigt der State:

- `isLoading == false`
- `wasSuccessful == true`
- `errorMessage == null`
- `lastImportedAt == now`
- `lastAction == importDefaultWords`

Der Import erzeugt weiterhin nur Kategorien und Woerter. Er erzeugt keinen Progress, keine Sessions und keine Review-History.

## 8. Tests

Datei:

- `test/core/local_database/local_debug_import_controller_provider_test.dart`

Tests:

- `debug_import_controller_provider_exposes_initial_state`
- `debug_import_controller_provider_imports_when_notifier_called`

### debug_import_controller_provider_exposes_initial_state

Sichert ab:

- Provider kann gelesen werden
- initialer State ist leer/neutral:
  - `isLoading == false`
  - `errorMessage == null`
  - `wasSuccessful == false`
  - `lastImportedAt == null`
  - `lastAction == none`
- reines Lesen importiert nichts
- `categories` bleibt leer
- `words` bleibt leer
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- keine alte `word_progress.db` entsteht

### debug_import_controller_provider_imports_when_notifier_called

Sichert ab:

- vor explizitem Aufruf sind `categories` und `words` leer
- `importDefaultWords(now: fixedNow)` importiert explizit
- Kategorie `basics` existiert danach
- Woerter `basics_hello` und `basics_water` existieren danach
- State zeigt Erfolg
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- keine alte `word_progress.db` entsteht
- kein Supabase ist noetig

## 9. Weiterhin Geltende Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- kein App-Start-Import
- kein Bootstrap-Import
- kein Provider-Import beim Lesen
- kein Supabase
- keine Supabase-Entfernung
- kein Zugriff auf `local_word_database.dart`
- kein Progress durch Import
- keine Sessions durch Import
- keine Review-History durch Import
- keine Navigation
- keine produktive App-Flow-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

## 10. Aktuelle Lokale Stabilitaetschecks

Zuletzt gruene lokale Stabilitaetschecks:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- SRS: 39 Tests bestanden
- Local Database: 138 Tests bestanden
- Local Learning Debug: 14 Tests bestanden
- Gesamt: 191 Tests bestanden
- Analyzer: `No issues found!`

Hinweis:

- bekannte Hinweise zu neueren Package-Versionen bleiben unveraendert

## 11. Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

- `LocalDebugImportControllerProvider` als abgeschlossen markieren
- `LocalLearningTestScreen`-Importbutton an den Provider anbinden
- Callback-Injection im Testscreen fuer Widget-Tests behalten
- Debug-State im Testscreen anzeigen:
  - Loading
  - Erfolg
  - Fehler
  - letzter Importzeitpunkt
- weiterhin keine produktive App-Flow-Anbindung
- weiterhin kein automatischer Import beim App-Start
