# 90 Local Debug Import Controller Provider Plan

Stand: 2026-05-14

## 1. Zweck Des Providers

Der Provider soll den `LocalDebugImportController` fuer den isolierten lokalen Debug-Kontext bereitstellen.

Ziele:

- `LocalDebugImportController` erzeugen
- `LocalDebugImportControllerState` lesbar machen
- `importDefaultWords(...)` spaeter aus dem `LocalLearningTestScreen` ausloesen
- Debug-Import-Status in der UI anzeigen koennen
- keinen Import beim Provider-Lesen ausfuehren

Der Provider ist kein Produktfeature. Er soll nur den bestehenden Debug-Testscreen mit der bereits isolierten Importkette verbinden.

## 2. Benoetigte Abhaengigkeiten

Fuer den vollstaendigen Default-Pfad werden benoetigt:

- `LocalControlledAssetImportService`
- `LocalJsonAssetImportService`
- `LocalJsonImportService`
- lokale `CategoryRepository`
- lokale `WordRepository`
- bestehender `LocalRepositoryFactory`
- `AssetBundle` oder `rootBundle`

Spaeter optional:

- `LocalImportSettingsRepository`

Nicht benoetigt:

- Supabase
- `WordUserView`
- `LearnModeController`
- `learn_mode_screen.dart`
- `local_word_database.dart`
- Navigation
- UI-Widgets im Provider selbst

## 3. Datenbank-/Repository-Quelle

### localBootstrapProvider / LocalRepositoryFactory Nutzen

Vorteile:

- nutzt den bestehenden lokalen DB-Lifecycle
- vermeidet eine zweite Datenbankoeffnung
- nutzt vorhandene Repository-Instanzen aus `LocalRepositoryFactory`
- passt zur vorhandenen lokalen Provider-Struktur
- `ref.onDispose` des Bootstrap-Providers bleibt zentrale Stelle fuer DB-Schliessung

Nachteile:

- Provider wird asynchron, weil `localBootstrapProvider` ein `FutureProvider` ist
- Tests brauchen Provider-Overrides oder kontrollierte Testpfade

Risiko: niedrig, wenn der Provider beim Lesen nur konstruiert und keinen Import startet.

### Neue DB Oeffnen

Vorteile:

- Provider waere unabhaengig vom Bootstrap-Provider

Nachteile:

- zweiter DB-Lifecycle
- Gefahr von konkurrierenden Verbindungen
- schwerere Tests
- groesseres Risiko fuer App-Start-Nebenwirkungen

Risiko: hoch. Fuer Version 1 nicht empfohlen.

### Direkte Repository-Erzeugung

Vorteile:

- technisch simpel, wenn bereits eine `Database` vorhanden ist

Nachteile:

- dupliziert Teile von `LocalRepositoryFactory`
- kann Lifecycle-Grenzen verwischen
- erhoeht Wartungskosten

Risiko: mittel. Nur sinnvoll, wenn `LocalRepositoryFactory` die benoetigten Repositories nicht bereitstellen wuerde. Aktuell stellt sie `categoryRepository` und `wordRepository` bereit.

## 4. Empfehlung Fuer Version 1

Empfohlen:

- auf `localBootstrapProvider` aufbauen
- `LocalRepositoryFactory` aus `LocalAppBootstrapResult` nutzen
- daraus `LocalJsonImportService` erstellen
- daraus `LocalJsonAssetImportService` erstellen
- daraus `LocalControlledAssetImportService` erstellen
- daraus `LocalDebugImportController` erstellen

Empfohlene Provider-Form:

- zuerst ein isolierter Provider fuer den Controller oder Controller-Notifier
- kein Import im Build/Provider-Read
- asynchrone Bootstrap-Abhaengigkeit sauber beruecksichtigen

Fuer den kleinsten ersten Schritt kann die Provider-Schicht zunaechst nur den initialen State exponieren und beweisen, dass Lesen keinen Import ausloest.

## 5. Was Nicht Passieren Darf

Nicht erlaubt:

- kein Import beim Provider-Lesen
- kein Import beim App-Start
- kein Import beim Bootstrap
- kein Supabase
- kein Progress durch Import
- keine Sessions durch Import
- keine Review-History durch Import
- keine bestehende UI veraendern
- keine Produktnavigation
- kein Zugriff auf `local_word_database.dart`
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Der Provider darf Import nur durch einen expliziten Methodenaufruf ermoeglichen.

## 6. Sinnvolle Tests

Sinnvolle Tests:

- `debug_import_controller_provider_exposes_initial_state`
- `debug_import_controller_provider_does_not_import_on_read`
- `debug_import_controller_provider_imports_when_notifier_called`
- `debug_import_controller_provider_does_not_create_progress_or_sessions`

### debug_import_controller_provider_exposes_initial_state

Soll absichern:

- Provider kann gelesen werden
- initialer State ist:
  - `isLoading == false`
  - `errorMessage == null`
  - `wasSuccessful == false`
  - `lastImportedAt == null`
  - `lastAction == none`
- keine Supabase-Initialisierung ist noetig

### debug_import_controller_provider_does_not_import_on_read

Soll absichern:

- reines Lesen des Providers erzeugt keine Kategorien
- reines Lesen erzeugt keine Woerter
- `word_progress` bleibt leer
- `learning_sessions` bleibt leer
- `review_history` bleibt leer

### debug_import_controller_provider_imports_when_notifier_called

Soll spaeter absichern:

- expliziter Aufruf `importDefaultWords(now: fixedNow)` importiert das registrierte Asset
- Kategorie `basics` entsteht
- Woerter `basics_hello` und `basics_water` entstehen
- State zeigt Erfolg

### debug_import_controller_provider_does_not_create_progress_or_sessions

Soll absichern:

- Import ueber Providerpfad erzeugt nur Kategorien/Woerter
- kein Progress
- keine Sessions
- keine Review-History

## 7. Spaetere Testscreen-Anbindung

Der `LocalLearningTestScreen` hat bereits `onImportDefaultWords` als Callback-Injection.

Moegliche spaetere Anbindung:

- Callback bleibt fuer Widget-Tests erhalten
- wenn Callback gesetzt ist, nutzt der Button weiter den Testpfad
- wenn kein Callback gesetzt ist, liest der Screen spaeter den Debug-Import-Controller-Provider
- Button ruft dann explizit `importDefaultWords(now: now)` auf
- Debug-State wird im Screen angezeigt:
  - laedt
  - erfolgreich
  - Fehler
  - letzter Importzeitpunkt

Wichtig:

- weiterhin nur im Debug-Testscreen
- kein Import beim Screen-Build
- keine automatische Session nach Import
- `Starten/Fortsetzen` bleibt separate Aktion

## 8. Risiken

Risiken:

- Provider loest Import beim Lesen aus
- DB-Lifecycle wird durch neue Datenbankoeffnung doppelt
- Import rueckt zu nah an App-Start oder Bootstrap
- Debug-Daten landen unkontrolliert in echter DB
- Debug-State wird als Produkt-UI missverstanden
- Provider wird versehentlich in produktive UI eingebunden

Gegenmassnahmen:

- bestehendes `localBootstrapProvider`-Ergebnis nutzen
- keine neue DB im Provider oeffnen
- Provider-Lesen nur initialisiert Controller/State
- Import nur durch expliziten Methodenaufruf
- Tests fuer "does not import on read"
- Testscreen-Anbindung separat und isoliert halten

## 9. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Eine isolierte Provider-Datei planen/erstellen:
   - `lib/core/local_database/providers/local_debug_import_controller_provider.dart`
2. Zunaechst nur den initialen State testbar machen:
   - `debug_import_controller_provider_exposes_initial_state`
3. Provider so bauen, dass Lesen keinen Import ausloest.
4. Test mit kontrollierter lokaler Testdatenbank oder Provider-Overrides schreiben.

Noch nicht im ersten TDD-Schritt:

- keine Testscreen-Anbindung
- kein UI-State fuer Erfolg/Fehler
- keine Settings-Marker-Integration
- keine neue Navigation
- kein App-Start-Import
