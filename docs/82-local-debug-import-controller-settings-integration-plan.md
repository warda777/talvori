# 82 Local Debug Import Controller Settings Integration Plan

Stand: 2026-05-14

## 1. Zweck der Integration

Die Integration soll den bestehenden `LocalDebugImportController` um eine reine Diagnosemarkierung erweitern.

Der kontrollierte Import bleibt weiterhin explizit. Neu waere nur, dass der Controller zusaetzlich Marker in der bestehenden `settings`-Tabelle schreibt:

- `lastAttemptAt` vor dem Import speichern.
- Erfolgsmarker nach erfolgreichem Import speichern.
- Alten Fehler nach erfolgreichem Import loeschen.
- Fehler nach fehlgeschlagenem Import speichern.

Damit kann Debug/QA spaeter nachvollziehen:

- ob ein Import bewusst versucht wurde,
- wann der letzte Versuch war,
- wann der letzte erfolgreiche Import war,
- welcher Asset-Key verwendet wurde,
- welche Importversion verwendet wurde,
- welcher Fehler zuletzt auftrat.

Die Integration darf keine neue Importlogik einfuehren. Die eigentliche Importkette bleibt:

`LocalDebugImportController` -> `LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService`.

## 2. Erlaubte zusaetzliche Abhaengigkeit

Erlaubt ist:

- `LocalImportSettingsRepository`

Nicht erlaubt bleiben:

- UI
- Widgets
- Navigation
- Supabase
- `LearnModeController`
- `WordUserView`
- alte `local_word_database.dart`
- direkter Zugriff auf alte `word_progress.db`

### Optional oder zwingend?

Empfehlung: Das Repository sollte im Controller-Konstruktor optional sein.

Begruendung:

- Der bestehende Controller-Pfad bleibt rueckwaertskompatibel.
- Die bisherigen Tests und isolierten Einsatzszenarien koennen ohne Settings-Repository weiter funktionieren.
- Die Marker-Funktion ist Diagnose, nicht fachlich notwendig fuer den Import.
- Der naechste TDD-Schritt kann klein bleiben: erst absichern, dass "ohne Repository" weiterhin funktioniert, oder direkt den Erfolgsmarker mit Repository testen.

Moegliche spaetere Konstruktorform:

- required: `LocalControlledAssetImportService`
- optional: `LocalImportSettingsRepository?`

Der Controller darf das Repository nicht selbst erzeugen. Besitz und Datenbank-Lifecycle bleiben ausserhalb des Controllers.

## 3. Ablauf bei importDefaultWords(...)

### Vor dem Import

Wenn ein `LocalImportSettingsRepository` vorhanden ist:

1. `saveLastAttempt(attemptedAt: now)` aufrufen.
2. Danach den bestehenden Loading-State setzen oder den State wie bisher direkt vor dem Import setzen.

Empfehlung fuer Version 1:

- State zuerst auf Loading setzen.
- Dann `saveLastAttempt(now)` schreiben.
- Dann kontrollierten Import ausfuehren.

Wenn das Schreiben von `lastAttemptAt` fehlschlaegt, sollte der Import in Version 1 nicht stillschweigend trotzdem laufen. Der Fehler gehoert dann in den bestehenden Fehlerpfad, weil die Diagnoseintegration Teil des expliziten Debug-Imports ist. Das haelt Tests einfach und vermeidet halbklare Debug-Zustaende.

### Bei Erfolg

Nach erfolgreichem `LocalControlledAssetImportService.importRegisteredAsset(...)`:

1. `saveSuccessMarker(...)` aufrufen mit:
   - `importedAt: now`
   - `assetKey: LocalDebugImportController.defaultWordsAssetKey`
   - `importVersion: default_words_v1`
2. `clearLastError()` aufrufen.
3. Controller-State wie bisher auf Erfolg setzen:
   - `isLoading = false`
   - `errorMessage = null`
   - `wasSuccessful = true`
   - `lastImportedAt = now`
   - `lastAction = importDefaultWords`

Der alte Fehler wird nur bei Erfolg geloescht. So bleibt ein fehlgeschlagener letzter Versuch sichtbar, bis ein erfolgreicher Import ihn ersetzt.

### Bei Fehler

Wenn der kontrollierte Import oder ein Marker-Schreibvorgang fehlschlaegt:

1. Fehler abfangen.
2. Wenn ein `LocalImportSettingsRepository` vorhanden ist, `saveLastError(errorMessage: error.toString())` versuchen.
3. Erfolgsmarker nicht ueberschreiben.
4. `importedAt` im Repository bleibt unveraendert.
5. `lastImportedAt` im Controller-State bleibt unveraendert.
6. Controller-State wie bisher auf Fehler setzen:
   - `isLoading = false`
   - `errorMessage = error.toString()`
   - `wasSuccessful = false`
   - `lastAction = importDefaultWordsFailed`

Wenn auch `saveLastError(...)` fehlschlaegt, sollte der Controller weiterhin den urspruenglichen Fehler im State anzeigen. Der Marker-Fehler darf den eigentlichen Importfehler nicht verschlucken.

## 4. Was nicht passieren darf

Die Integration darf nicht:

- Idempotenz ersetzen.
- Einen bewussten Re-Import blockieren.
- Import bei Controller-Erzeugung ausfuehren.
- Import beim Provider-Lesen ausfuehren.
- Import beim Bootstrap ausfuehren.
- Import beim App-Start ausfuehren.
- Progress erzeugen.
- Sessions erzeugen.
- Review-History schreiben.
- Supabase verwenden.
- Eine UI oder Navigation einfuehren.
- Bestehende App-Flows veraendern.

Der Marker bleibt Diagnose. Die Duplikatfreiheit bleibt weiterhin Aufgabe der Importservices und stabilen IDs.

## 5. Sinnvolle Tests

Die Tests sollten weiter in `test/core/local_database/local_debug_import_controller_test.dart` oder in einem klar getrennten Controller-Settings-Test liegen.

Sinnvolle naechste Tests:

- `debug_import_controller_writes_success_marker`
  - Erzeugt Controller mit `LocalImportSettingsRepository`.
  - Fuehrt `importDefaultWords(now: fixedNow)` explizit aus.
  - Prueft:
    - `lastAttemptAt == fixedNow`
    - `importedAt == fixedNow`
    - `assetKey == assets/local_import/default_words_v1.json`
    - `importVersion == default_words_v1`
    - `lastError == null`
    - Kategorien/Woerter wurden importiert.
    - `word_progress`, `learning_sessions`, `review_history` bleiben leer.

- `debug_import_controller_writes_error_marker`
  - Nutzt fehlschlagenden `LocalControlledAssetImportService`.
  - Prueft:
    - `lastAttemptAt == fixedNow`
    - `lastError` ist gesetzt.
    - `importedAt` bleibt unveraendert oder null.
    - Controller-State bleibt im Fehlerzustand.
    - Kein Progress, keine Sessions, keine Review-History.

- `marker_does_not_replace_idempotency`
  - Fuehrt erfolgreichen Import zweimal explizit aus.
  - Prueft:
    - Marker wird aktualisiert.
    - Kategorien/Woerter werden nicht dupliziert.
    - Re-Import wird nicht durch Marker blockiert.

- `debug_import_controller_without_settings_repository_still_works`
  - Erzeugt Controller ohne `LocalImportSettingsRepository`.
  - Fuehrt bisherigen Importpfad aus.
  - Prueft, dass der bestehende Controller-State und Import weiter funktionieren.

Optional spaeter:

- `debug_import_controller_success_clears_previous_error_marker`
  - Setzt erst Fehler.
  - Fuehrt danach erfolgreichen Import aus.
  - Prueft, dass `lastError == null`.

## 6. Empfehlung

### Repository optional halten

`LocalImportSettingsRepository` sollte fuer diese Integrationsstufe optional im `LocalDebugImportController` sein.

Das ist die risikoaermste Variante, weil:

- bestehender Debug-Controller weiter ohne Marker nutzbar bleibt,
- keine Provider- oder Bootstrap-Aenderung noetig ist,
- Tests klein bleiben,
- die Diagnosefunktion nicht zur Pflicht fuer Importlogik wird.

### Kleinster naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Einen neuen Test schreiben:
   - `debug_import_controller_writes_success_marker`
2. In-Memory-SQLite verwenden.
3. `LocalImportSettingsRepository` im Test erzeugen.
4. Controller mit optionalem Repository erzeugen.
5. `importDefaultWords(now: fixedNow)` explizit aufrufen.
6. Marker laden und pruefen:
   - `lastAttemptAt == fixedNow`
   - `importedAt == fixedNow`
   - `assetKey == LocalDebugImportController.defaultWordsAssetKey`
   - `importVersion == default_words_v1`
   - `lastError == null`
7. Weiterhin pruefen:
   - `word_progress` bleibt leer.
   - `learning_sessions` bleibt leer.
   - `review_history` bleibt leer.
   - kein Supabase noetig ist.

Erst danach sollten Fehler-Marker, Idempotenz und der explizite Test fuer "ohne Repository weiterhin funktionsfaehig" folgen.
