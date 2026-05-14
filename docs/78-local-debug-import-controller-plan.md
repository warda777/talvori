# 78 Local Debug Import Controller Plan

Stand: 2026-05-14

## Zweck

Dieses Dokument plant einen Debug-only Import-Controller fuer den kontrollierten lokalen Asset-Import.

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

## 1. Zweck Des Debug-only Import-Controllers

Der Debug-only Import-Controller soll den kontrollierten Asset-Import bewusst ausloesen koennen.

Ziele:

- registriertes Asset explizit importieren
- Debug-/QA-Status halten
- Fehlerzustand sichtbar machen koennen
- erfolgreichen Importzeitpunkt merken
- keinen automatischen App-Start-Import einfuehren
- keine produktive UI-Anbindung schaffen

Der Controller soll auf dem bestehenden lokalen Importpfad aufbauen:

`LocalDebugImportController` -> `LocalControlledAssetImportService` -> `LocalJsonAssetImportService` -> `LocalJsonImportService`.

Wichtig:

Der Controller ist nur ein geplanter Debug-/QA-Baustein. Er ersetzt keine bestehende App-Logik und wird nicht automatisch in App-Flows eingebunden.

## 2. Erlaubte Abhaengigkeiten

Erlaubt:

- `LocalControlledAssetImportService`
- Asset-Key `assets/local_import/default_words_v1.json`
- `DateTime now`

Optional spaeter erlaubt:

- ein kleiner Clock-/Now-Provider fuer Tests
- ein Debug-State-Modell
- ein Debug-Controller-Provider, sofern isoliert und nicht in bestehende App-Flows eingebunden

Nicht erlaubt:

- Supabase
- UI-Widgets
- Navigation
- `LearnModeController`
- `WordUserView`
- alte `local_word_database.dart`
- alte `word_progress.db`
- `BuildContext`
- bestehende `word_providers.dart`
- bestehender `learn_mode_screen.dart`

Der Controller soll keine Datenbank direkt oeffnen. Er soll nur den bereits bereitgestellten kontrollierten Importservice verwenden.

## 3. Sinnvolle Methoden

### importDefaultWords(...)

Moegliche Signatur:

```dart
Future<void> importDefaultWords({required DateTime now})
```

Verhalten:

1. `isLoading` auf `true` setzen
2. `errorMessage` zuruecksetzen
3. `LocalControlledAssetImportService.importRegisteredAsset(...)` aufrufen mit:
   - `assetKey`: `assets/local_import/default_words_v1.json`
   - `now`: uebergebener Zeitpunkt
4. bei Erfolg:
   - `wasSuccessful` auf `true`
   - `lastImportedAt` auf `now`
   - `lastAction` auf `importDefaultWords`
5. bei Fehler:
   - `errorMessage` setzen
   - `wasSuccessful` auf `false`
   - `lastAction` sinnvoll setzen, z. B. `importDefaultWordsFailed`
6. `isLoading` wieder auf `false` setzen

Wichtig:

Die Methode darf keine Progress-Initialisierung und keinen Session-Start ausloesen.

### resetDebugState(...)

Moegliche Signatur:

```dart
void resetDebugState()
```

Verhalten:

- Debug-Status zuruecksetzen
- keine Importaktion ausloesen
- keine Datenbank veraendern

Sinnvolle Ruecksetzung:

- `isLoading: false`
- `errorMessage: null`
- `wasSuccessful: false`
- `lastAction: resetDebugState`

`lastImportedAt` sollte je nach Debug-Anforderung entweder erhalten bleiben oder bewusst auf `null` gesetzt werden. Fuer Version 1 ist `null` nach Reset einfacher und testbarer.

## 4. Sinnvoller State

Ein kleiner State reicht.

Moegliche Felder:

- `isLoading`
- `errorMessage`
- `wasSuccessful`
- `lastImportedAt`
- `lastAction`

### isLoading

Zeigt an, dass gerade ein Debug-Import laeuft.

Regeln:

- initial `false`
- waehrend `importDefaultWords(...)` `true`
- danach wieder `false`

### errorMessage

Enthaelt einen technischen Fehlerhinweis fuer Debug/QA.

Regeln:

- initial `null`
- vor neuem Import zuruecksetzen
- bei Fehler setzen
- keine lokalisierten Produkttexte erzwingen

### wasSuccessful

Zeigt, ob der letzte Import erfolgreich abgeschlossen wurde.

Regeln:

- initial `false`
- bei Erfolg `true`
- bei Fehler `false`

### lastImportedAt

Speichert den Zeitpunkt des letzten erfolgreichen Imports.

Regeln:

- initial `null`
- bei erfolgreichem Import `now`
- bei Fehler nicht aktualisieren

### lastAction

Dokumentiert die letzte Controller-Aktion.

Moegliche Werte:

- `none`
- `importDefaultWords`
- `importDefaultWordsFailed`
- `resetDebugState`

Enums waeren sauberer als freie Strings, wenn der Controller implementiert wird.

## 5. Was Nicht Passieren Darf

Der Debug-only Import-Controller darf nicht:

- beim Provider-Lesen importieren
- beim Erzeugen des Controllers importieren
- beim App-Start importieren
- Progress erzeugen
- Sessions starten
- Review-History schreiben
- bestehende UI veraendern
- bestehende App-Flows veraendern
- Navigation ausloesen
- Supabase nutzen
- alte `local_word_database.dart` nutzen
- alte `word_progress.db` nutzen
- `LearnModeController` erweitern oder ersetzen
- `learn_mode_screen.dart` anbinden

Import darf nur passieren, wenn `importDefaultWords(...)` explizit aufgerufen wird.

## 6. Sinnvolle Spaetere Tests

### debug_import_controller_imports_default_words_when_called

Sichert ab:

- initial passiert kein Import
- expliziter Aufruf von `importDefaultWords(...)` ruft `LocalControlledAssetImportService` auf
- Kategorie `basics` wird erstellt
- Woerter `basics_hello` und `basics_water` werden erstellt

### debug_import_controller_does_not_import_on_initialization

Sichert ab:

- Controller-Erzeugung importiert nichts
- Provider-Lesen, falls es spaeter einen Provider gibt, importiert nichts
- `categories` bleibt leer
- `words` bleibt leer

### debug_import_controller_sets_success_state

Sichert ab:

- nach erfolgreichem Import:
  - `isLoading == false`
  - `errorMessage == null`
  - `wasSuccessful == true`
  - `lastImportedAt == now`
  - `lastAction == importDefaultWords`

### debug_import_controller_sets_error_state_on_failure

Sichert ab:

- Fehler aus dem Importpfad werden gefangen
- `isLoading == false`
- `errorMessage` ist gesetzt
- `wasSuccessful == false`
- `lastImportedAt` bleibt unveraendert
- kein Teilzustand sieht wie ein erfolgreicher Import aus

### debug_import_controller_does_not_create_progress_or_sessions

Sichert ab:

- nach Import bleiben leer:
  - `word_progress`
  - `learning_sessions`
  - `review_history`
- Import bleibt ein Inhaltsdatenimport
- Progress entsteht weiterhin erst durch `LocalProgressInitializationService`
- Sessions entstehen weiterhin erst durch `LocalLearningSessionFacade`

## 7. Risiken

### Import Wird Versehentlich Automatisch Ausgeloest

Risiko:

- Controller oder Provider importiert beim Initialisieren.
- Debug-Daten landen unkontrolliert in einer lokalen DB.

Gegenmassnahme:

- Tests fuer "does not import on initialization".
- Controller-Methoden strikt aktionsbasiert halten.
- Kein Import in Konstruktor, `build`, Provider-Initialisierung oder Bootstrap.

### Debug-Controller Wird Zu Frueh In UI Eingebunden

Risiko:

- Debug-Import wird in bestehende App-Flows sichtbar.
- Nutzer oder normale App-Starts koennen Demo-Daten importieren.

Gegenmassnahme:

- Controller zunaechst ohne UI-Anbindung implementieren.
- Debug-Button oder Debug-Route separat planen.
- Bestehende UI-Dateien nicht anfassen.

### Demo-Daten Landen Unkontrolliert In Echter DB

Risiko:

- registriertes Asset wird in eine produktive lokale DB importiert, ohne klare Entscheidung.

Gegenmassnahme:

- expliziter Aufruf notwendig.
- spaeter optional Settings-Marker oder Debug-Guard planen.
- keine App-Start-Automatik.
- keine Bootstrap-Automatik.

### Fehlerzustand Wird Mit Produkterlebnis Vermischt

Risiko:

- technische Debug-Fehlertexte gelangen in echte UI.

Gegenmassnahme:

- Controller-State bleibt Debug-only.
- keine UI-Texte finalisieren.
- keine bestehende UI-Anbindung.

## 8. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Einen isolierten Controller erstellen, z. B.:
   - `lib/core/local_database/controllers/local_debug_import_controller.dart`
2. Einen kleinen State erstellen, z. B.:
   - `LocalDebugImportControllerState`
3. Minimaler State:
   - `isLoading`
   - `errorMessage`
   - `wasSuccessful`
   - `lastImportedAt`
   - `lastAction`
4. Controller bekommt:
   - `LocalControlledAssetImportService`
5. Erste Methode:
   - `importDefaultWords({required DateTime now})`
6. Erster Test:
   - `debug_import_controller_imports_default_words_when_called`
7. Test prueft:
   - kein Import vor Methodenaufruf
   - Import nach explizitem Methodenaufruf
   - Kategorie `basics` existiert
   - Woerter `basics_hello` und `basics_water` existieren
   - `word_progress`, `learning_sessions`, `review_history` bleiben leer
   - Erfolg-State wird gesetzt

Noch nicht Teil des naechsten Schritts:

- kein Provider
- kein Debug-Button
- keine Debug-Route
- keine UI-Anbindung
- keine App-Flow-Anbindung
- kein Settings-Marker
- keine Progress-Initialisierung
- kein Session-Start

Empfehlung:

Der erste TDD-Schritt sollte nur den Controller als isolierte, explizite Aktionsschicht beweisen. Eine spaetere Debug-UI oder ein Settings-Marker sollte getrennt geplant werden.
