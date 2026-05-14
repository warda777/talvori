# 81 Local Import Settings Repository Summary

Stand: 2026-05-14

## 1. Aufgabe

`LocalImportSettingsRepository` speichert und laedt lokale Importdiagnose-Marker fuer den kontrollierten Asset-Import. Es nutzt ausschliesslich die bestehende `settings`-Tabelle der lokalen SQLite-Datenbank.

Der Marker beschreibt nur den Diagnosezustand des Imports. Er importiert keine Daten selbst und ist nicht an UI, Supabase, Bootstrap oder App-Flows angebunden.

## 2. Verwendete Settings-Keys

Das Repository verwendet feste Keys fuer `default_words_v1`:

- `default_words_v1_imported_at`
- `default_words_v1_asset_key`
- `default_words_v1_import_version`
- `default_words_v1_last_attempt_at`
- `default_words_v1_last_error`

Zeitwerte werden als ISO-8601-Strings gespeichert. `value_type` ist fuer Zeitwerte `datetime` und fuer Textwerte `string`.

## 3. Gespeicherte Daten

Der geladene Marker enthaelt:

- `importedAt`
  - Zeitpunkt des letzten erfolgreichen Imports.

- `assetKey`
  - Verwendeter Asset-Key, z. B. `assets/local_import/default_words_v1.json`.

- `importVersion`
  - Stabile Importversion, aktuell `default_words_v1`.

- `lastAttemptAt`
  - Zeitpunkt des letzten expliziten Importversuchs.
  - Kann auch ohne Erfolgsmarker existieren.

- `lastError`
  - Letzter technischer Importfehler fuer Debug/QA.
  - Wird ueber einen eigenen Settings-Key gespeichert und durch Loeschen dieses Keys entfernt.

## 4. Umgesetzte Methoden

- `saveSuccessMarker(...)`
  - Speichert `importedAt`, `assetKey` und `importVersion`.

- `saveLastAttempt(...)`
  - Speichert den letzten expliziten Importversuch als `lastAttemptAt`.

- `saveLastError(...)`
  - Speichert den letzten technischen Fehler als String.

- `clearLastError()`
  - Loescht nur den Fehler-Key.
  - Erfolgsmarker und `lastAttemptAt` bleiben erhalten.

- `loadMarker()`
  - Laedt alle vorhandenen Markerwerte.
  - Gibt `null` zurueck, wenn noch kein Marker-Key existiert.

## 5. Nur Diagnose, Keine Idempotenz

Der Marker ersetzt keine Import-Idempotenz. Auch wenn ein Erfolgsmarker existiert, darf ein bewusst ausgeloester Import weiterhin laufen.

Die Duplikatfreiheit bleibt Aufgabe der Importkette:

- `LocalJsonImportService`
- `LocalJsonAssetImportService`
- `LocalControlledAssetImportService`

Der Marker ist nur fuer Diagnose und Debug/QA gedacht. Er darf nicht als harte Import-Sperre interpretiert werden.

## 6. Tests

Die Tests liegen in `test/core/local_database/local_import_settings_repository_test.dart`.

Abgesichert sind:

- `import_settings_repository_saves_and_loads_marker`
  - Speichert und laedt `importedAt`, `assetKey` und `importVersion`.
  - Prueft, dass keine Kategorien, Woerter, Progress-Eintraege, Sessions oder Review-History entstehen.

- `import_settings_repository_saves_last_attempt`
  - Speichert und laedt `lastAttemptAt` ohne Erfolgsmarker.
  - Prueft, dass die uebrigen Markerfelder `null` bleiben.
  - Prueft, dass keine Lerndaten veraendert werden.

- `import_settings_repository_saves_and_clears_last_error`
  - Speichert `lastError`.
  - Prueft, dass Erfolgsmarker und `lastAttemptAt` erhalten bleiben.
  - Loescht danach nur den Fehler-Key.
  - Prueft erneut, dass Erfolgsmarker und `lastAttemptAt` erhalten bleiben.
  - Prueft, dass keine Lerndaten veraendert werden.

## 7. Grenzen

Weiterhin gilt:

- Keine UI-Anbindung.
- Kein Supabase.
- Kein Import selbst.
- Kein Progress.
- Keine Sessions.
- Keine Review-History.
- Keine Integration in `LocalDebugImportController`.
- Keine Bootstrap-/Provider-/App-Start-Automatik.
- Keine bestehende App-Flow-Aenderung.

## 8. Gruene Stabilitaetschecks

Der lokale Stabilitaetscheck nach dem Repository-Ausbau war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden.

- `flutter test test/core/local_database/`
  - 136 Tests bestanden.

- `flutter test test/features/local_learning_debug/`
  - 10 Tests bestanden.

- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Insgesamt waren damit 185 lokale Tests gruen.

## 9. Naechste Schritte

Sinnvolle naechste Optionen:

- `LocalImportSettingsRepository` als abgeschlossen markieren.
- Integration in `LocalDebugImportController` separat planen.
- Erst danach gezielt testen, dass der Debug-Controller Erfolgs- und Fehlermarker schreibt.
- Weiterhin keine bestehende UI-/App-Flow-Anbindung vornehmen.
