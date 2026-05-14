# 86 Local Debug Route Definition Summary

Stand: 2026-05-14

## 1. Aufgabe

Die isolierte LocalLearning Debug-Route-Definition beschreibt eine interne Debug-Route fuer den `LocalLearningTestScreen`, ohne sie in die App einzubinden.

Sie ist ein kleiner lokaler Routing-Baustein fuer Entwicklung und QA. Sie macht den Testscreen noch nicht in der laufenden App erreichbar und ersetzt keine bestehende Lernoberflaeche.

Die Definition macht nicht:

- keine App-Einbindung
- keine Navigation
- keinen Import
- keine Datenbankoeffnung
- keine Supabase-Nutzung
- keine Produktnavigation

## 2. Konstanten

Datei:

- `lib/features/local_learning_debug/routing/local_learning_debug_routes.dart`

Vorhandene Konstanten:

- `localLearningDebugRoutePath`
  - Wert: `/debug/local-learning`

- `localLearningDebugRouteName`
  - Wert: `debugLocalLearning`

- `localLearningDebugDefaultCategoryId`
  - Wert: `basics`

Zusaetzlich existiert:

- `localLearningDebugRouteDefinition`
  - enthaelt `path`, `name`, `defaultCategoryId` und `builder`

## 3. Screen-Building

Die Route-Definition nutzt einen Builder:

- `buildLocalLearningDebugScreen({required String categoryId})`

Dieser Builder gibt zurueck:

- `LocalLearningTestScreen(categoryId: categoryId)`

Die vordefinierte Route-Definition verwendet als Default:

- `categoryId: basics`

Der Builder fuehrt keine weitere Logik aus. Er startet keinen Import, oeffnet keine Datenbank, fragt keine Kategorien ab und kennt kein Supabase.

## 4. Keine App-Navigation Oder main.dart-Anbindung

Die Debug-Route-Definition ist weiterhin nicht eingebunden in:

- `main.dart`
- App-Router
- Produktnavigation
- bestehende Lernflows
- bestehende Menues

Das ist Absicht:

- `main.dart` bleibt unveraendert.
- Bestehende App-Flows bleiben unveraendert.
- Der bestehende Supabase-Lernflow bleibt unangetastet.
- `learn_mode_screen.dart` wird nicht ersetzt.
- `LearnModeController` wird nicht veraendert.

Eine echte Debug-Router-Anbindung muss separat geplant und mit Debug-/Dev-Gate abgesichert werden.

## 5. Tests

Datei:

- `test/features/local_learning_debug/local_learning_debug_routes_test.dart`

Vorhandene Tests:

- `debug_route_can_build_local_learning_test_screen_with_category_id`
- `debug_router_builds_local_learning_screen`

### debug_route_can_build_local_learning_test_screen_with_category_id

Sichert ab:

- `localLearningDebugRoutePath == '/debug/local-learning'`
- `buildLocalLearningDebugScreen(categoryId: 'basics')` baut den Testscreen
- `categoryId` wird an den Screen uebergeben
- Initialzustand rendert mit Provider-Overrides
- **Noch keine Session** ist sichtbar
- **Intensiv lernen** ist sichtbar
- **Alles lernen** ist sichtbar
- **Starten/Fortsetzen** ist sichtbar

### debug_router_builds_local_learning_screen

Sichert ab:

- `localLearningDebugRouteDefinition.path == '/debug/local-learning'`
- `localLearningDebugRouteDefinition.name == 'debugLocalLearning'`
- `localLearningDebugRouteDefinition.defaultCategoryId == 'basics'`
- der Definition-Builder baut einen `LocalLearningTestScreen`
- `categoryId == basics`
- Initialzustand rendert mit Provider-Overrides
- **Richtig** und **Falsch** sind im Initialzustand nicht sichtbar

Die Tests benoetigen:

- keine Supabase-Initialisierung
- keine `WordUserView`
- keinen Import
- keine echte Datenbank
- keine App-Navigation

## 6. Weiterhin Geltende Grenzen

Weiterhin gilt:

- Keine App-Einbindung.
- Keine Navigation.
- Kein Import.
- Keine Datenbankoeffnung.
- Kein Supabase.
- Keine Produktnavigation.
- Keine Aenderung an `main.dart`.
- Keine Aenderung an `word_providers.dart`.
- Keine Aenderung an `learn_mode_controller.dart`.
- Keine Aenderung an `learn_mode_screen.dart`.
- Keine Nutzung von `local_word_database.dart`.

## 7. Gruene Stabilitaetschecks

Der lokale Stabilitaetscheck nach der Debug-Route-Definition war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden.

- `flutter test test/core/local_database/`
  - 136 Tests bestanden.

- `flutter test test/features/local_learning_debug/`
  - 12 Tests bestanden.

- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Insgesamt waren damit 187 lokale Tests gruen.

## 8. Naechste Schritte

Sinnvolle naechste Optionen:

- Debug-Route-Definition als abgeschlossen markieren.
- Eine echte Debug-Router-Anbindung separat planen.
- Vor einer echten Einbindung ein klares Debug-/Dev-Gate planen.
- Weiterhin keine produktive Navigation einbauen.
- Weiterhin keine bestehende App-Flow-Anbindung vornehmen.
