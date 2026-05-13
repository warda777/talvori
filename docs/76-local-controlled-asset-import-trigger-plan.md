# 76 Local Controlled Asset Import Trigger Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine kontrollierte Importausloesung fuer den registrierten lokalen JSON-Asset-Import.

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

## 1. Zweck Der Kontrollierten Importausloesung

Die kontrollierte Importausloesung soll das registrierte Asset bewusst importieren:

- Asset-Key: `assets/local_import/default_words_v1.json`
- Ladeweg: `LocalJsonAssetImportService`
- Importziel: lokale SQLite-Datenbank `talvori_local_v1.db`
- Importinhalt: Kategorien und Woerter

Wichtig:

- kein automatischer App-Start-Import
- keine UI-/App-Flow-Anbindung
- kein Supabase
- keine alte lokale DB
- kein Progress-Import

Die Ausloesung soll nur einen bereits bestehenden, getesteten Importpfad verwenden:

`AssetBundle` -> `LocalJsonAssetImportService` -> `LocalJsonImportService` -> `CategoryRepository`/`WordRepository`.

## 2. Moegliche Ausloeseorte

### Variante A: Eigener Lokaler Importservice

Beispiel:

- `LocalControlledAssetImportService`
- oder `LocalRegisteredAssetImportService`

Aufgabe:

- `LocalJsonAssetImportService.importFromAsset(...)` mit festem oder uebergebenem Asset-Key aufrufen
- keine UI kennen
- keine Datenbank selbst oeffnen
- keine Bootstrap-Logik duplizieren
- keine Progress-/Session-Logik enthalten

Vorteile:

- kleinster isolierter Baustein
- gut testbar
- keine App-Flow-Beruehrung
- kein Bootstrap-Automatismus
- klare Verantwortung: expliziter Importaufruf

Nachteile:

- braucht spaeter einen separaten Ausloeser, z. B. Debug-Route oder Dev-Menue
- noch keine echte App-Nutzung ohne weiteren bewussten Schritt

Bewertung:

- Risiko: niedrig
- Testbarkeit: hoch
- Rueckbaubarkeit: hoch
- Empfehlung: ja

### Variante B: Debug-only Controller

Beispiel:

- lokaler Debug-Controller mit Methode `importDefaultWords(...)`

Aufgabe:

- kontrollierten Importservice aufrufen
- Status fuer Debug-Anzeige halten

Vorteile:

- spaeter gut mit Debug-Screen kombinierbar
- kann Lade-/Fehlerzustand fuer interne Tests bereitstellen

Nachteile:

- Controller fuehrt schon naeher an UI-/Debug-Flows heran
- etwas groesserer erster Schritt
- Gefahr, dass Debug-Zustand und Importlogik vermischt werden

Bewertung:

- Risiko: mittel
- Testbarkeit: gut
- Rueckbaubarkeit: gut
- Empfehlung: spaeter, nicht als erster Schritt

### Variante C: Debug-Route Spaeter

Beispiel:

- interne Debug-Route mit Button "Lokale Woerter importieren"

Vorteile:

- manuelle Ausloesung gut sichtbar
- kein automatischer Import
- nuetzlich fuer manuelle QA

Nachteile:

- Navigation/App-Routing muesste angefasst werden
- UI- und App-Flow-Risiko steigt
- nicht der kleinste isolierte Schritt

Bewertung:

- Risiko: mittel bis hoch
- Testbarkeit: mittel
- Rueckbaubarkeit: mittel
- Empfehlung: erst nach isoliertem Service und Controller planen

### Variante D: Bootstrap Mit seed/import Flag

Beispiel:

- `bootstrap({ ..., importDefaultAsset: true })`

Vorteile:

- technisch bequem
- nutzt bereits geoeffnete DB und RepositoryFactory

Nachteile:

- Import rueckt gefaehrlich nah an App-Start/Lifecycle
- Flag koennte spaeter versehentlich aktiviert bleiben
- vermischt Bootstrap mit Datenbefuellung
- aehnliches Risiko wie unkontrolliertes Seed-Verhalten

Bewertung:

- Risiko: mittel bis hoch
- Testbarkeit: gut, aber mit Lifecycle-Risiko
- Rueckbaubarkeit: mittel
- Empfehlung: nicht fuer Version 1

### Variante E: App-Start Automatisch

Beispiel:

- beim App-Start immer registriertes Asset importieren

Vorteile:

- Nutzer haette direkt Inhalte

Nachteile:

- hoechstes Risiko
- Import laeuft unkontrolliert bei jedem Start
- App-Start wird langsamer und fehleranfaelliger
- Datenbefuellung wird schwer nachvollziehbar
- Risiko fuer echte lokale Daten
- widerspricht der bisherigen isolierten Strategie

Bewertung:

- Risiko: hoch
- Testbarkeit: schwierig
- Rueckbaubarkeit: schlecht
- Empfehlung: ausdrücklich nicht

## 3. Klare Empfehlung

Empfohlen wird Variante A:

- eigener lokaler kontrollierter Importservice

Der erste Service sollte:

- UI-neutral sein
- Supabase nicht kennen
- keine Datenbank selbst oeffnen
- einen bereits gebauten `LocalJsonAssetImportService` verwenden
- einen expliziten Methodenaufruf fuer den registrierten Asset-Key anbieten
- keine automatische Ausfuehrung im Bootstrap oder Provider starten

Moegliche spaetere Form:

```dart
importDefaultWords({required DateTime now})
```

oder generischer:

```dart
importRegisteredAsset({
  required String assetKey,
  required DateTime now,
})
```

Fuer Version 1 ist ein generischer, aber expliziter Asset-Key sinnvoller. Dadurch bleibt der Service klein und testbar, ohne Produktentscheidung ueber "Default Words" in den Namen einzubauen.

## 4. Was Die Importausloesung Tun Darf

Die kontrollierte Importausloesung darf:

- `LocalJsonAssetImportService` aufrufen
- den Asset-Key `assets/local_import/default_words_v1.json` verwenden
- JSON aus dem registrierten Asset laden
- den geladenen JSON-String an `LocalJsonImportService` delegieren
- Kategorien importieren
- Woerter importieren
- idempotent bleiben
- klare Fehler aus dem Importpfad weiterreichen

Sie darf bestehende lokale Garantien nutzen:

- stabile IDs
- Repository-`upsert`s
- Importvalidierung im `LocalJsonImportService`
- keine Progress-Erzeugung im Importservice

## 5. Was Die Importausloesung Nicht Tun Darf

Die kontrollierte Importausloesung darf nicht:

- Progress erzeugen
- Sessions starten
- Review-History schreiben
- automatisch bei jedem App-Start laufen
- im `LocalAppBootstrap` automatisch ausgefuehrt werden
- im `localBootstrapProvider` automatisch ausgefuehrt werden
- bestehende App-Flows aendern
- UI kennen
- Navigation kennen
- Supabase verwenden
- alte `word_progress.db` verwenden
- `local_word_database.dart` beruehren
- `LearnModeController` beruehren
- `learn_mode_screen.dart` beruehren

Der Import bleibt ein bewusster Datenbefuellungsschritt, nicht Teil des Lernstarts.

## 6. Schutz Gegen Unkontrollierte Mehrfachausfuehrung

Mehrfachausfuehrung wird auf mehreren Ebenen begrenzt.

### Idempotenz

Der Import ist bereits idempotent:

- stabile Kategorie-IDs
- stabile Wort-IDs
- Repository-`upsert`s
- Tests fuer wiederholte Imports

Dadurch erzeugt ein zweiter Import keine doppelten Kategorien oder Woerter.

### Expliziter Aufruf

Der Import soll nur durch einen expliziten Methodenaufruf laufen.

Nicht erlaubt:

- automatische Ausfuehrung im Bootstrap
- automatische Ausfuehrung im Bootstrap-Provider
- automatische Ausfuehrung beim App-Start
- automatische Ausfuehrung beim Lesen eines Providers

### Optionaler Settings-Marker Spaeter

Spaeter kann ein Settings-Marker sinnvoll sein, z. B.:

- `default_words_v1_imported_at`
- `default_words_v1_import_hash`
- `default_words_v1_import_version`

Dieser Marker waere nur ein zusaetzlicher Schutz und eine Diagnosehilfe.

Wichtig:

Ein Settings-Marker ersetzt nicht die Idempotenz. Der Import muss auch ohne Marker sicher mehrfach laufen koennen.

### Keine Automatik Im Bootstrap-Provider

Der bestehende `localBootstrapProvider` bleibt bei:

- `seedDefaults: false`
- kein Import
- keine automatische Datenbefuellung

Das verhindert, dass blosses Lesen des Providers Daten in die lokale DB schreibt.

## 7. Sinnvolle Spaetere Tests

### controlled_import_loads_registered_asset_and_imports_words

Sichert ab:

- kontrollierter Importservice ruft `LocalJsonAssetImportService.importFromAsset(...)` auf
- registrierter Asset-Key wird verwendet
- Kategorie `basics` wird erstellt
- Woerter `basics_hello` und `basics_water` werden erstellt
- kein Supabase ist noetig

### controlled_import_is_idempotent

Sichert ab:

- kontrollierter Import kann mehrfach aufgerufen werden
- Kategorieanzahl bleibt gleich
- Wortanzahl bleibt gleich
- keine doppelten Kategorien entstehen
- keine doppelten Woerter entstehen

### controlled_import_does_not_create_progress

Sichert ab:

- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer
- Import bleibt auf Kategorien und Woerter beschraenkt

### controlled_import_does_not_run_on_bootstrap_without_explicit_call

Sichert ab:

- `LocalAppBootstrap.bootstrap(seedDefaults: false, ...)` importiert das Asset nicht
- `localBootstrapProvider` importiert das Asset nicht
- Kategorien bleiben leer, solange kein expliziter Importaufruf erfolgt
- Lesen des Bootstrap-Providers loest keine Datenbefuellung aus

## 8. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Einen kleinen lokalen Service planen/erstellen, z. B.:
   - `LocalControlledAssetImportService`
2. Der Service bekommt im Konstruktor:
   - `LocalJsonAssetImportService`
3. Der Service stellt genau eine Methode bereit:
   - `importRegisteredAsset({required String assetKey, required DateTime now})`
4. Die Methode delegiert nur:
   - `localJsonAssetImportService.importFromAsset(assetKey: assetKey, now: now)`
5. Erster Test:
   - `controlled_import_loads_registered_asset_and_imports_words`
6. Der Test nutzt:
   - registrierten Asset-Key
   - In-Memory-SQLite-Testdatenbank
   - `rootBundle` oder testbares `AssetBundle`
   - `LocalJsonImportService`
7. Der Test prueft:
   - `basics` existiert
   - `basics_hello` existiert
   - `basics_water` existiert
   - `word_progress` bleibt leer
   - `learning_sessions` bleibt leer
   - `review_history` bleibt leer

Noch nicht Teil des naechsten Schritts:

- keine UI
- keine Debug-Route
- keine Provider-Automatik
- kein Bootstrap-Flag
- kein App-Start-Import
- kein Progress
- keine Session
- keine Review-History

Empfehlung:

Der naechste Schritt sollte den kontrollierten Import als reine, explizite Delegation absichern. Erst danach sollte geplant werden, ob und wie ein Debug-only Controller oder eine Debug-Route diesen Service spaeter manuell ausloesen darf.
