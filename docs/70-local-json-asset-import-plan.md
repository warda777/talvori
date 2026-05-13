# 70 Local JSON Asset Import Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den Asset-Import fuer lokale JSON-Importdaten.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`
- keine Aenderung an `pubspec.yaml`

## 1. Ziel Des Asset-Imports

Ziel ist, spaeter eine lokale JSON-Datei als App-Asset bereitzustellen und daraus Kategorien und Woerter offline in `talvori_local_v1.db` importieren zu koennen.

Der Asset-Import soll:

- eine lokale JSON-Datei im App-Bundle lesen
- Kategorien und Woerter offline importieren
- `LocalJsonImportService` fuer die eigentliche Validierung und Speicherung nutzen
- keine Supabase-Abhaengigkeit haben
- keine alte lokale DB verwenden
- keine alte `word_progress.db` beruehren
- keinen Progress importieren
- keine Session starten
- keine Review-History schreiben

Der Import bleibt damit ein Inhaltsimport, kein Lernzustandsimport.

## 2. Fixture Versus Asset

Aktueller Test-Fixture-Pfad:

- `test/fixtures/local_import/default_words_v1.json`

Geplanter Asset-Pfad:

- unter `assets/...`

Unterschied:

- `test/fixtures/...` ist nur fuer Tests gedacht.
- `assets/...` wuerde spaeter im App-Bundle landen.
- Fixtures werden per normalem `File(...).readAsString()` im Test gelesen.
- Assets werden in Flutter ueber einen `AssetBundle` geladen.
- Eine Fixture ist nicht automatisch Produktdaten.
- Eine Fixture soll nicht versehentlich beim App-Start importiert werden.

Warum die Fixture nicht automatisch Produktdaten ist:

- Sie ist klein und testorientiert.
- Sie liegt ausserhalb des App-Asset-Systems.
- Sie ist nicht in `pubspec.yaml` registriert.
- Sie enthaelt aktuell nur `basics` mit zwei Woertern.
- Sie dient dazu, Importmechanik zu pruefen, nicht finalen Content auszuliefern.

## 3. Empfohlener Asset-Pfad

Moegliche Pfade:

- `assets/local_import/default_words_v1.json`
- `assets/local_seed/default_words_v1.json`

### Variante A: `assets/local_import/default_words_v1.json`

Vorteile:

- benennt den Zweck direkt als Import
- passt zu `LocalJsonImportService`
- unterscheidet sich klar von Seed-Dart-Konstanten
- kann spaeter mehrere Importdateien enthalten

Nachteile:

- klingt etwas technischer
- muss klar dokumentiert werden, damit der Import nicht automatisch beim Start laeuft

### Variante B: `assets/local_seed/default_words_v1.json`

Vorteile:

- macht deutlich, dass die Daten initiale lokale Inhalte sein koennen
- nah an bestehendem Seed-Begriff

Nachteile:

- kann mit `LocalSeedDataService` verwechselt werden
- "Seed" klingt eher nach automatischem Startverhalten
- Risiko, dass Demo-/Seed-Daten und Produktimport vermischt werden

Empfehlung:

- `assets/local_import/default_words_v1.json`

Begruendung:

Der Pfad beschreibt die Funktion genauer: Es handelt sich um eine importierbare JSON-Datei, nicht um hart codierte Seed-Daten. Das reduziert das Risiko, den Asset-Import mit dem bestehenden `LocalSeedDataService` zu vermischen.

## 4. `pubspec.yaml`-Aenderung

Spaeter waere eine Asset-Registrierung in `pubspec.yaml` noetig.

Moegliche Zeile:

```yaml
flutter:
  assets:
    - assets/local_import/default_words_v1.json
```

Oder, wenn mehrere lokale Importdateien geplant sind:

```yaml
flutter:
  assets:
    - assets/local_import/
```

Empfehlung fuer Version 1:

- zuerst nur die einzelne Datei registrieren
- keine breite Verzeichnisregistrierung, solange der Asset-Bestand klein ist

Wichtig:

`pubspec.yaml` wird in diesem Schritt noch nicht geaendert.

## 5. Asset-Ladeweg

Moegliche Ladewege:

- `rootBundle.loadString(...)`
- `AssetBundle`-Injection fuer Tests
- direkter `File`-Zugriff

### `rootBundle.loadString(...)`

Vorteile:

- einfacher Standardweg in Flutter
- gut fuer Produktionspfad im App-Bundle

Nachteile:

- schwerer isoliert zu testen
- koppelt Service direkt an globales Flutter-Bundle
- kann Tests unnoetig eng an Flutter-Asset-Konfiguration binden

### `AssetBundle`-Injection

Vorteile:

- gut testbar
- kein globaler `rootBundle` im Service noetig
- Tests koennen ein Fake- oder Memory-Bundle verwenden
- klare Trennung zwischen Laden und Importieren

Nachteile:

- minimal mehr Konstruktor-/Service-Aufwand
- braucht einen kleinen separaten Lade-Service

### Direkter `File`-Zugriff

Vorteile:

- einfach fuer Test-Fixtures
- bereits fuer `test/fixtures/...` passend

Nachteile:

- nicht passend fuer App-Assets
- funktioniert nicht verlaesslich im Flutter-App-Bundle
- wuerde Asset- und Dateisystempfade vermischen

Empfehlung:

- Fuer App-Assets keinen direkten `File`-Zugriff verwenden.
- Einen Service mit `AssetBundle`-Injection planen.
- `rootBundle` nur an der Composition-Grenze als Default verwenden, nicht tief in der Importlogik.

## 6. Neuer Service Oder Erweiterung?

Moegliche Varianten:

- separater `LocalJsonAssetImportService`
- `LocalJsonImportService` um Asset-Laden erweitern

### Separater `LocalJsonAssetImportService`

Aufgabe:

- JSON-String aus Asset laden
- an `LocalJsonImportService.importFromJsonString(...)` weitergeben

Vorteile:

- klare Trennung der Zustaendigkeiten
- `LocalJsonImportService` bleibt reiner String-Import
- Asset-Tests bleiben isoliert
- geringeres Risiko fuer bestehende Importtests
- spaeter leichter austauschbar gegen Datei-, Netzwerk- oder Exportimport

Nachteile:

- ein kleiner zusaetzlicher Service

### `LocalJsonImportService` erweitern

Aufgabe:

- zusaetzliche Methode wie `importFromAsset(...)`

Vorteile:

- weniger Dateien
- einfache API an einer Stelle

Nachteile:

- vermischt Parsing/Speichern mit Asset-Laden
- zieht Flutter-Asset-Konzepte in den aktuellen lokalen Importservice
- erschwert reine Dart-/SQLite-Tests
- erhoeht Risiko fuer bestehenden stabilen Importblock

Empfehlung:

- `LocalJsonAssetImportService` als separater Service.

Begruendung:

Der bestehende `LocalJsonImportService` ist stabil und bewusst UI-/Asset-neutral. Ein separater Asset-Service kann nur laden und delegieren. Das ist die risikoaermste Variante.

## 7. Was Der Asset-Import Tun Darf

Der Asset-Import darf:

- einen JSON-String aus einem registrierten Asset laden
- den Asset-Pfad als Parameter oder Konstante verwenden
- `LocalJsonImportService.importFromJsonString(...)` aufrufen
- Kategorien importieren
- Woerter importieren
- bestehende Validierung und Idempotenz des JSON-Importservices nutzen

Der Asset-Import ist damit nur ein Lade- und Delegationsbaustein.

## 8. Was Der Asset-Import Nicht Tun Darf

Der Asset-Import darf nicht:

- Progress erzeugen
- Sessions starten
- Review-History schreiben
- Supabase nutzen
- alte `word_progress.db` nutzen
- `local_word_database.dart` verwenden
- automatisch beim App-Start laufen
- bestehende Provider ersetzen
- bestehende App-Flows veraendern
- UI oder Navigation kennen
- `LearnModeController` kennen
- `WordUserView` kennen

Insbesondere darf er nicht bei jedem App-Start unkontrolliert importieren. Ein Importaufruf muss spaeter bewusst und testbar ausgeloest werden.

## 9. Spaetere Tests

Sinnvolle Tests fuer einen spaeteren TDD-Schritt:

- `local_asset_import_loads_json_from_bundle`
- `local_asset_import_delegates_to_json_import_service`
- `local_asset_import_creates_categories_and_words`
- `local_asset_import_does_not_create_progress`
- `local_asset_import_is_idempotent`

### local_asset_import_loads_json_from_bundle

Sichert ab:

- Asset-Service kann JSON ueber ein injiziertes `AssetBundle` laden.
- kein direkter `File`-Zugriff wird genutzt.
- kein Supabase ist noetig.
- keine Datenbank muss fuer diesen ersten Test geoeffnet werden.

### local_asset_import_delegates_to_json_import_service

Sichert ab:

- Asset-Service ruft den bestehenden JSON-Importservice auf.
- Asset-Service implementiert keine eigene Importlogik.
- Validierung bleibt beim `LocalJsonImportService`.

### local_asset_import_creates_categories_and_words

Sichert ab:

- geladener Asset-JSON-String erzeugt ueber den Importservice Kategorien und Woerter.
- Felder werden korrekt uebernommen.

### local_asset_import_does_not_create_progress

Sichert ab:

- Asset-Import erzeugt keine `word_progress`.
- Asset-Import erzeugt keine `learning_sessions`.
- Asset-Import erzeugt keine `review_history`.

### local_asset_import_is_idempotent

Sichert ab:

- derselbe Asset-Import kann mehrfach laufen.
- stabile IDs verhindern Duplikate.
- Counts bleiben gleich.

## 10. Risiken

Wichtige Risiken:

- Asset wird versehentlich bei jedem App-Start importiert.
- Seed-/Demo-Daten landen unkontrolliert in echter DB.
- Asset-Pfad ist falsch in `pubspec.yaml` registriert.
- Tests werden schwer, wenn direkt `rootBundle` verwendet wird.
- Produktdaten und Testdaten werden vermischt.
- bestehender stabiler `LocalJsonImportService` wird durch Asset-Logik unnoetig gekoppelt.
- Import wird zu frueh an Provider, Bootstrap oder UI angebunden.
- Asset-Datei wird mit Supabase-IDs oder alten lokalen IDs vermischt.

Risikoreduzierung:

- separater `LocalJsonAssetImportService`
- `AssetBundle`-Injection
- kein automatischer App-Start-Import
- kein `pubspec.yaml`-Umbau im ersten TDD-Schritt
- keine bestehende App-Anbindung
- Asset-Datei separat von Test-Fixture behandeln

## 11. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Noch keine echte Asset-Datei anlegen.
2. Noch keine `pubspec.yaml`-Aenderung vornehmen.
3. Einen kleinen `LocalJsonAssetImportService` planen/implementieren, der ein injiziertes `AssetBundle` nutzt.
4. Einen ersten Test schreiben:
   - `local_asset_import_loads_json_from_bundle`
5. Der Test nutzt ein Fake- oder Memory-`AssetBundle` mit JSON-String.
6. Der Test prueft nur:
   - der JSON-String wird aus dem Bundle gelesen
   - der richtige Asset-Key wird verwendet
   - kein `File`-Zugriff noetig ist
   - kein Supabase noetig ist
   - keine echte App-Anbindung passiert

Danach kann ein zweiter Schritt pruefen, dass der Asset-Service an `LocalJsonImportService` delegiert und Kategorien/Woerter in eine In-Memory-DB importiert.

Diese Reihenfolge haelt den Asset-Import lokal, isoliert, testbar und ohne Risiko fuer bestehende App-Flows.
