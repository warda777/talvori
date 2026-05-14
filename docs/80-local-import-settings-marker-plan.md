# 80 Local Import Settings Marker Plan

Stand: 2026-05-14

## 1. Zweck des Settings-Markers

Der Settings-Marker soll eine reine Diagnoseinformation fuer den kontrollierten lokalen Asset-Import bereitstellen. Er merkt nicht die importierten Daten selbst, sondern nur, ob und wann der explizite Import fuer `default_words_v1` versucht oder erfolgreich ausgefuehrt wurde.

Der Marker soll helfen, Debug- und QA-Fragen zu beantworten:

- Wurde der kontrollierte Import bereits bewusst ausgeloest?
- Wann wurde der Import zuletzt versucht?
- Wann war der letzte erfolgreiche Import?
- Welcher Asset-Key wurde verwendet?
- Welche Importversion wurde verwendet?
- Gab es zuletzt einen Importfehler?

Der Marker bleibt bewusst getrennt von der eigentlichen Importlogik. Die Idempotenz bleibt Aufgabe von `LocalJsonImportService`, `LocalJsonAssetImportService` und `LocalControlledAssetImportService`.

## 2. Zu speichernde Daten

Fuer Version 1 reichen wenige stabile Key-Value-Eintraege:

- `default_words_v1_imported_at`
  - Zeitpunkt des letzten erfolgreichen Imports.
  - Wert als ISO-8601-String.
  - Wird nur nach erfolgreichem explizitem Import gesetzt.

- `default_words_v1_asset_key`
  - Verwendeter Asset-Key.
  - Erwarteter Wert: `assets/local_import/default_words_v1.json`.
  - Wird nur nach erfolgreichem explizitem Import gesetzt.

- `default_words_v1_import_version`
  - Stabile Importversion.
  - Empfehlung fuer Version 1: `default_words_v1`.
  - Nicht aus der Datei raten, sondern bewusst im Import-/Debug-Kontext setzen.

- `default_words_v1_last_attempt_at`
  - Zeitpunkt des letzten expliziten Importversuchs.
  - Wird vor dem Importversuch gesetzt.
  - Hilft zu erkennen, ob ein Fehler vor oder waehrend des Imports auftrat.

- `default_words_v1_last_error`
  - Optionaler technischer Fehlerhinweis fuer Debug/QA.
  - Da `settings.value` nicht nullable ist, sollte "kein Fehler" am besten durch Loeschen dieses Keys dargestellt werden.
  - Alternativ waere ein leerer String moeglich, ist aber weniger eindeutig.

Alle Zeitwerte sollten einheitlich als ISO-8601 gespeichert werden. Der vorhandene `now`-Parameter aus dem Debug-Import-Controller bleibt dafuer ausreichend testbar.

## 3. Speicherort

Der Marker sollte in der bestehenden `settings`-Tabelle gespeichert werden:

- `key TEXT PRIMARY KEY`
- `value TEXT NOT NULL`
- `value_type TEXT NOT NULL`
- `updated_at TEXT NOT NULL`

Damit ist keine neue Tabelle noetig. Es ist auch kein Schema-Upgrade erforderlich, solange die bestehenden Key-Value-Felder ausreichen.

Empfohlene `value_type`-Werte fuer Version 1:

- `datetime` fuer `imported_at` und `last_attempt_at`
- `string` fuer `asset_key`, `import_version` und `last_error`

## 4. Sinnvolle Repository-Schicht

Es gibt zwei naheliegende Varianten.

### SettingsRepository

Ein generisches `SettingsRepository` wuerde einfache Key-Value-Operationen anbieten, zum Beispiel Upsert, Lesen und Loeschen eines Settings-Keys.

Vorteile:

- Passt direkt zur generischen `settings`-Tabelle.
- Kann spaeter auch fuer andere lokale Einstellungen genutzt werden.
- Wenig Domain-Wissen in der Repository-Schicht.

Nachteile:

- Import-spezifische Keys koennen sich in Controller oder Service verteilen.
- Mehr Risiko fuer Tippfehler bei Key-Namen.
- Der erste Anwendungsfall ist aktuell nur Importdiagnose, nicht allgemeine App-Settings.

### LocalImportSettingsRepository

Ein `LocalImportSettingsRepository` wuerde die Importdiagnose gezielt kapseln und intern die bestehende `settings`-Tabelle verwenden.

Vorteile:

- Sehr enger Scope fuer Version 1.
- Import-Keys bleiben an einer Stelle.
- Debug-Controller muss keine Roh-Settings-Keys kennen.
- Besser passend zur aktuellen isolierten Arbeitsweise.

Nachteile:

- Weniger allgemein wiederverwendbar.
- Falls spaeter viele Settings hinzukommen, kann eine generische Grundlage sinnvoll werden.

### Empfehlung fuer Version 1

Fuer Version 1 ist `LocalImportSettingsRepository` die risikoaermere Variante. Der Marker ist ein Importdiagnose-Baustein, kein allgemeines Settings-System. Das Repository kann die vorhandene `settings`-Tabelle direkt nutzen und nur die noetigen Import-Marker-Operationen anbieten.

Falls spaeter weitere Settings-Anwendungsfaelle entstehen, kann darunter oder daneben ein generisches `SettingsRepository` eingefuehrt werden.

## 5. Wann der Marker gesetzt werden darf

Der Marker darf nur im Zusammenhang mit einem expliziten kontrollierten Importaufruf geschrieben werden.

Erlaubt:

- Vor einem expliziten Import: `default_words_v1_last_attempt_at` setzen.
- Nach erfolgreichem explizitem Import: `imported_at`, `asset_key` und `import_version` setzen.
- Nach fehlgeschlagenem explizitem Import: `last_error` setzen.
- Nach erfolgreichem Import: einen alten `last_error`-Key entfernen.

Nicht erlaubt:

- Beim Bootstrap.
- Beim Lesen von `localBootstrapProvider`.
- Beim App-Start.
- Beim Erzeugen des Debug-Import-Controllers.
- Beim Lesen eines Providers.
- Durch UI-Rendering.

## 6. Was der Marker nicht tun darf

Der Marker ist nur Diagnose, kein Steuermechanismus fuer die Importlogik.

Er darf nicht:

- Idempotenz ersetzen.
- Einen bewussten erneuten Import verhindern.
- Als harte Import-Sperre verwendet werden.
- Progress erzeugen.
- Sessions erzeugen.
- Review-History schreiben.
- Supabase verwenden.
- Die alte `word_progress.db` beruehren.
- Bestehende App-Flows veraendern.

Auch wenn `default_words_v1_imported_at` gesetzt ist, muss ein bewusst ausgeloester Re-Import weiterhin moeglich bleiben. Die Duplikatfreiheit bleibt durch Upserts und stabile IDs abgesichert.

## 7. Zusammenspiel mit LocalDebugImportController

Der bestehende `LocalDebugImportController` koennte spaeter optional um eine Import-Marker-Abhaengigkeit erweitert werden.

Moeglicher Ablauf:

1. `importDefaultWords(now: fixedNow)` wird explizit aufgerufen.
2. Controller setzt seinen bestehenden Loading-State.
3. Controller schreibt ueber `LocalImportSettingsRepository`:
   - `default_words_v1_last_attempt_at = fixedNow`
4. Controller ruft weiterhin `LocalControlledAssetImportService.importRegisteredAsset(...)` auf.
5. Bei Erfolg schreibt der Controller:
   - `default_words_v1_imported_at = fixedNow`
   - `default_words_v1_asset_key = assets/local_import/default_words_v1.json`
   - `default_words_v1_import_version = default_words_v1`
   - alter `default_words_v1_last_error` wird geloescht.
6. Bei Fehler schreibt der Controller:
   - `default_words_v1_last_error = <technischer Fehlerhinweis>`
   - `default_words_v1_imported_at` bleibt unveraendert.
7. Der Controller-State bleibt weiterhin UI-neutral und Debug-only.

Der Marker sollte lesbar gemacht werden, aber nicht automatisch Aktionen ausloesen. Eine spaetere Debug-Ansicht koennte den Marker anzeigen, ohne dadurch Import, Progress oder Sessions zu starten.

## 8. Sinnvolle Tests

Spaetere Tests sollten weiterhin lokal, isoliert und ohne UI/Supabase laufen.

Sinnvolle erste Repository-Tests:

- `import_settings_repository_saves_and_loads_marker`
  - Speichert Importzeitpunkt, Asset-Key und Importversion.
  - Laedt dieselben Werte wieder aus der `settings`-Tabelle.

- `import_settings_repository_saves_last_attempt`
  - Speichert den letzten Versuch separat vom erfolgreichen Import.

- `import_settings_repository_saves_and_clears_last_error`
  - Speichert einen Fehlerhinweis.
  - Entfernt ihn nach einem erfolgreichen Import wieder.

Sinnvolle Controller-Tests:

- `debug_import_controller_writes_success_marker`
  - Expliziter Import schreibt Erfolgsmarker.
  - Kategorien/Woerter werden importiert.
  - Progress, Sessions und Review-History bleiben leer.

- `debug_import_controller_writes_error_marker`
  - Fehler beim kontrollierten Import schreibt `last_error`.
  - Erfolgsmarker bleibt unveraendert.

- `marker_does_not_replace_idempotency`
  - Trotz gesetztem Marker kann ein expliziter Re-Import ausgefuehrt werden.
  - Keine Duplikate entstehen.

- `bootstrap_does_not_write_import_marker`
  - `LocalAppBootstrap` mit `seedDefaults: false` schreibt keine Importmarker.

- `provider_read_does_not_write_import_marker`
  - Reines Provider-Lesen schreibt keine Importmarker.

## 9. Risiken

Der Marker ist klein, kann aber falsch verstanden werden.

Risiken:

- Der Marker wird als harte Import-Sperre interpretiert.
- Ein gesetzter Marker verhindert spaeter bewusst gewollte Re-Imports.
- Der Marker wird versehentlich beim App-Start oder Bootstrap geschrieben.
- Fehlerdetails werden spaeter direkt als Produkt-UI angezeigt.
- Importversionen werden uneinheitlich benannt.
- `last_error` bleibt nach erfolgreichem Import stehen und verwirrt Debug/QA.
- Ein generisches Settings-System wird zu frueh gross gezogen.

Gegenmassnahmen:

- Dokumentieren, dass der Marker Diagnose ist.
- Import bleibt explizit.
- Idempotenz bleibt in der Importlogik.
- Fehlerhinweise nur fuer Debug/QA verwenden.
- Importversion als stabile Konstante behandeln.
- Erfolg loescht alten Fehlerhinweis.

## 10. Kleinster naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte weiterhin lokal und isoliert bleiben:

1. `LocalImportSettingsRepository` planen/implementieren.
2. Nur die bestehende `settings`-Tabelle verwenden.
3. Noch nicht in `LocalDebugImportController` integrieren.
4. Einen ersten Test schreiben:
   - `import_settings_repository_saves_and_loads_marker`
5. In-Memory-SQLite verwenden.
6. Pruefen:
   - Markerwerte werden gespeichert.
   - Markerwerte koennen wieder geladen werden.
   - keine Kategorien/Woerter veraendert werden.
   - kein Progress entsteht.
   - keine Sessions entstehen.
   - keine Review-History entsteht.
   - kein Supabase noetig ist.

Erst danach sollte der Debug-Import-Controller den Marker optional schreiben. Bootstrap, Provider, App-Start und bestehende UI-Flows bleiben weiterhin unangetastet.
