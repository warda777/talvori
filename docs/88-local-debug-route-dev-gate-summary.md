# 88 Local Debug Route Dev Gate Summary

Stand: 2026-05-14

## 1. Aufgabe

`getLocalLearningDebugRoutes(...)` ist die erste isolierte Dev-Gate-/Debug-Router-Composition fuer den lokalen `LocalLearningTestScreen`.

Die Funktion entscheidet anhand eines expliziten `enabled`-Parameters, ob die LocalLearning-Debug-Route in einer Debug-Routenliste enthalten ist.

Sie macht nicht:

- keine App-Anbindung
- keine Navigation
- keinen Import
- keine Datenbankoeffnung
- kein Supabase
- keine Produktnavigation

## 2. enabled: true

Wenn `enabled == true`, gibt `getLocalLearningDebugRoutes(...)` eine Liste mit genau einer Route zurueck:

- `localLearningDebugRouteDefinition`

Diese Definition enthaelt:

- `path: /debug/local-learning`
- `name: debugLocalLearning`
- `defaultCategoryId: basics`
- `builder: buildLocalLearningDebugScreen`

Der Builder selbst baut nur:

- `LocalLearningTestScreen(categoryId: categoryId)`

Er startet keine Datenbefuellung und fuehrt keine App-Navigation aus.

## 3. enabled: false

Wenn `enabled == false`, gibt `getLocalLearningDebugRoutes(...)` eine leere Liste zurueck.

Damit kann spaeter eine Debug-/Dev-Composition entscheiden, ob lokale Debug-Routen verfuegbar sind. Im deaktivierten Zustand wird keine Route bereitgestellt.

## 4. Noch Kein kDebugMode

`kDebugMode` wird in diesem ersten Schritt bewusst noch nicht direkt verwendet.

Gruende:

- Die Gate-Logik bleibt vollstaendig deterministisch testbar.
- Tests koennen beide Zustaende (`enabled: true` und `enabled: false`) direkt pruefen.
- Es gibt noch keine App-Composition und keine `main.dart`-Anbindung.
- Ein spaeteres `kDebugMode`- oder Dev-Flag kann diese Funktion kontrolliert aufrufen.

Damit bleibt dieser Schritt isoliert und ohne Build-Mode-Abhaengigkeit.

## 5. Keine App-Navigation Oder main.dart-Anbindung

Die Dev-Gate-Funktion ist weiterhin nicht eingebunden in:

- `main.dart`
- `MaterialApp`
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

Eine echte Debug-Router-Anbindung muss separat geplant und getestet werden.

## 6. Tests

Datei:

- `test/features/local_learning_debug/local_learning_debug_routes_test.dart`

Vorhandene Tests fuer diesen Bereich:

- `debug_route_can_build_local_learning_test_screen_with_category_id`
- `debug_router_builds_local_learning_screen`
- `debug_gate_exposes_route_only_when_enabled`

### debug_route_can_build_local_learning_test_screen_with_category_id

Sichert ab:

- der direkte Builder baut den `LocalLearningTestScreen`
- `categoryId` wird uebergeben
- Initialzustand rendert mit Provider-Overrides
- kein Supabase, keine Datenbank und keine Navigation noetig

### debug_router_builds_local_learning_screen

Sichert ab:

- die Route-Definition enthaelt `path`, `name` und `defaultCategoryId`
- der Definition-Builder baut den `LocalLearningTestScreen`
- `categoryId == basics`
- Initialzustand rendert mit Provider-Overrides

### debug_gate_exposes_route_only_when_enabled

Sichert ab:

- `enabled: true` liefert genau `localLearningDebugRouteDefinition`
- `path == /debug/local-learning`
- `name == debugLocalLearning`
- `enabled: false` liefert eine leere Liste

Der Gate-Test baut keine Widgets, startet keinen Import und oeffnet keine Datenbank.

## 7. Weiterhin Geltende Grenzen

Weiterhin gilt:

- Keine App-Anbindung.
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

## 8. Gruene Stabilitaetschecks

Der lokale Stabilitaetscheck nach dem Dev-Gate-Block war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden.

- `flutter test test/core/local_database/`
  - 136 Tests bestanden.

- `flutter test test/features/local_learning_debug/`
  - 13 Tests bestanden.

- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Insgesamt waren damit 188 lokale Tests gruen.

## 9. Naechste Schritte

Sinnvolle naechste Optionen:

- Dev-Gate-Block als abgeschlossen markieren.
- Eine echte Debug-Router-Anbindung separat planen.
- Spaeter entscheiden, ob `kDebugMode`, ein eigenes Debug-Flag oder eine separate Debug-Composition die Funktion aufruft.
- Weiterhin keine produktive Navigation einbauen.
- Weiterhin keine bestehende App-Flow-Anbindung vornehmen.
