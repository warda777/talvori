# 103 Local Categories Provider Summary

Stand: 2026-05-15

## 1. Aufgabe

`localCategoriesProvider` stellt lokale Kategorien aus der neuen Offline-first-Datenbank `talvori_local_v1.db` bereit.

Der Provider ist ein UI-neutraler Baustein fuer eine spaetere kontrollierte Sichtbarkeit lokaler Kategorien im WordHub-Umfeld.

Er ersetzt keinen bestehenden Supabase-Flow und bindet noch keine UI an.

## 2. Nutzung Von localBootstrapProvider

`localCategoriesProvider` nutzt `localBootstrapProvider`, um den bestehenden lokalen Bootstrap zu verwenden.

Der Ablauf:

1. `localBootstrapProvider.future` liefert das lokale Bootstrap-Ergebnis.
2. Dieses Ergebnis enthaelt die bereits aufgebaute lokale Datenbank und `LocalRepositoryFactory`.
3. Der Provider nutzt diese bestehende Kette weiter.

Damit bleibt der Datenbank-Lifecycle zentral beim lokalen Bootstrap.

## 3. Nutzung Von CategoryRepository

Der Provider liest Kategorien ueber:

- `bootstrapResult.repositoryFactory.categoryRepository.loadCategories()`

Dadurch werden aktive lokale Kategorien geladen.

Die Rueckgabe ist:

- `FutureProvider<List<LocalCategory>>`

Aktuell werden keine zusaetzlichen WordHub-spezifischen ViewModels erzeugt. Der Provider liefert zuerst bewusst die lokalen Repository-Modelle.

## 4. Keine Eigene Datenbankoeffnung

`localCategoriesProvider` oeffnet keine eigene Datenbank.

Er nutzt:

- keine direkte `sqflite`-Initialisierung
- keinen eigenen Datenbankpfad
- keine alte `local_word_database.dart`
- keinen UI-seitigen Datenbankzugriff

Das reduziert das Risiko fuer doppelte DB-Lifecycles und haelt den lokalen Block konsistent mit der bestehenden Bootstrap-/Repository-Kette.

## 5. Kein Import Beim Lesen

Beim Lesen des Providers passiert kein Import.

Der Provider:

- laedt nur vorhandene Kategorien
- startet keinen Asset-Import
- startet keinen JSON-Import
- erzeugt keine lokalen Demo-Daten
- startet keine Session

Wenn keine Kategorien vorhanden sind, gibt der Provider eine leere Liste zurueck.

## 6. Tests

Die Tests liegen in:

- `test/core/local_database/local_categories_provider_test.dart`

Aktuell existieren:

- `local_categories_provider_loads_imported_categories`
  - legt `basics` bewusst ueber `CategoryRepository` an
  - liest danach `localCategoriesProvider`
  - prueft, dass `basics` enthalten ist
  - prueft Name und `isArchived == false`
  - prueft, dass kein Progress, keine Session und keine Review-History entstehen
  - prueft, dass keine alte `word_progress.db` entsteht

- `local_categories_provider_does_not_import_on_read`
  - liest `localCategoriesProvider` ohne vorherigen Import und ohne Kategorieanlage
  - prueft, dass das Ergebnis leer ist
  - prueft, dass `categories`, `words`, `word_progress`, `learning_sessions` und `review_history` leer bleiben
  - prueft, dass keine alte `word_progress.db` entsteht

## 7. Grenzen

Weiterhin gilt:

- keine UI-Anbindung
- kein WordHub-Umbau
- kein Supabase
- kein Import
- kein Progress
- keine Sessions
- keine Review-History
- keine alte lokale DB
- keine automatische Datenbefuellung

Der Provider ist nur ein Lesezugriff auf bereits vorhandene lokale Kategorien.

## 8. Aktuelle Stabilitaetschecks

Zuletzt gruen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter test test/features/local_learning_debug/`
- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`

Ergebnis:

- 204 lokale Tests bestanden
- gezielter Analyzer: `No issues found`

## 9. Naechste Schritte

Sinnvoll:

- `localCategoriesProvider` als abgeschlossen markieren
- danach einen kleinen lokalen WordHub-Debug-Entry planen
- bestehenden Supabase-WordHub weiterhin unangetastet lassen
- zunaechst nur lokale Kategorien sichtbar machen, wenn sie bereits vorhanden sind
- keinen automatischen Import an den WordHub koppeln

Nicht empfohlen:

- keine direkte Umstellung des bestehenden WordHub auf lokale Kategorien
- keine Entfernung des Supabase-Flows nebenbei
- kein automatischer Import beim Oeffnen des WordHub
- keine direkte Anbindung an `LearnModeScreen`
