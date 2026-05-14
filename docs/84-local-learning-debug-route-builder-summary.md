# 84 Local Learning Debug Route Builder Summary

Stand: 2026-05-14

## 1. Aufgabe

Der isolierte LocalLearning Debug-Route-Builder stellt einen kleinen, nicht eingebundenen Einstiegspunkt fuer den `LocalLearningTestScreen` bereit.

Er dient dazu, den Screen spaeter kontrolliert ueber eine Debug-Route bauen zu koennen, ohne jetzt App-Navigation, Produkt-Router oder bestehende Lernflows zu veraendern.

Der Builder macht nicht:

- keine Route in die App einhaengen
- keinen Navigator verwenden
- keinen Import starten
- keine Datenbank oeffnen
- keine Supabase-Abhaengigkeit einfuehren
- keine Produktnavigation erzeugen

## 2. Route-Konstante

Datei:

- `lib/features/local_learning_debug/routing/local_learning_debug_routes.dart`

Die Route-Konstante lautet:

- `localLearningDebugRoutePath = '/debug/local-learning'`

Sie beschreibt nur den geplanten Debug-Pfad. Der Pfad ist noch nicht in `main.dart`, einen App-Router oder eine Produktnavigation eingebunden.

## 3. buildLocalLearningDebugScreen(...)

Die Builder-Funktion:

- `buildLocalLearningDebugScreen({required String categoryId})`

arbeitet bewusst minimal:

1. Sie nimmt eine `categoryId` entgegen.
2. Sie gibt `LocalLearningTestScreen(categoryId: categoryId)` zurueck.
3. Sie fuehrt keine weitere Logik aus.

Der Builder laedt keine Kategorien, prueft keine Datenbank und startet keinen Import. Die `categoryId` bleibt ein expliziter Konstruktorwert fuer den Testscreen.

## 4. Keine Navigation/App-Router-Anbindung

Der Builder ist noch nicht in Navigation oder App-Router eingebunden.

Das ist Absicht:

- `main.dart` bleibt unveraendert.
- Bestehende App-Flows bleiben unveraendert.
- Produktnavigation bleibt unveraendert.
- Der bestehende Supabase-Lernflow bleibt unangetastet.
- `learn_mode_screen.dart` wird nicht ersetzt.
- `LearnModeController` wird nicht veraendert.

Der aktuelle Stand ist nur eine vorbereitete Debug-Build-Funktion. Eine echte Debug-Router-Anbindung muss separat geplant und getestet werden.

## 5. Tests

Datei:

- `test/features/local_learning_debug/local_learning_debug_routes_test.dart`

Vorhandener Test:

- `debug_route_can_build_local_learning_test_screen_with_category_id`

Der Test sichert ab:

- `localLearningDebugRoutePath == '/debug/local-learning'`
- `buildLocalLearningDebugScreen(categoryId: 'basics')` baut einen `LocalLearningTestScreen`
- die `categoryId` wird an den Screen uebergeben
- der Initialzustand wird mit Provider-Overrides gerendert
- **Noch keine Session** ist sichtbar
- **Intensiv lernen** ist sichtbar
- **Alles lernen** ist sichtbar
- **Starten/Fortsetzen** ist sichtbar
- **Richtig** und **Falsch** sind im Initialzustand nicht sichtbar

Der Test braucht:

- keine Supabase-Initialisierung
- keine `WordUserView`
- keine echte Datenbank
- keinen Import
- keine Navigation

## 6. Weiterhin Geltende Grenzen

Weiterhin gilt:

- Keine `main.dart`-Aenderung.
- Keine Navigation.
- Keine App-Flow-Anbindung.
- Kein Supabase.
- Kein automatischer Import.
- Keine automatische Datenbefuellung.
- Keine Datenbankoeffnung.
- Keine Aenderung an `word_providers.dart`.
- Keine Aenderung an `learn_mode_controller.dart`.
- Keine Aenderung an `learn_mode_screen.dart`.
- Keine Nutzung von `local_word_database.dart`.

## 7. Gruene Stabilitaetschecks

Der lokale Stabilitaetscheck nach dem Debug-Route-Builder war gruen:

- `flutter test test/core/srs/`
  - 39 Tests bestanden.

- `flutter test test/core/local_database/`
  - 136 Tests bestanden.

- `flutter test test/features/local_learning_debug/`
  - 11 Tests bestanden.

- `flutter analyze lib/core/srs lib/core/local_database lib/features/local_learning_debug test/core/srs test/core/local_database test/features/local_learning_debug`
  - `No issues found!`

Insgesamt waren damit 186 lokale Tests gruen.

## 8. Naechste Schritte

Sinnvolle naechste Optionen:

- Debug-Route-Builder als abgeschlossen markieren.
- Eine echte Debug-Router-Anbindung separat planen.
- Vor einer echten Anbindung ein klares Debug-/Dev-Gate planen.
- Weiterhin keine produktive Navigation einbauen.
- Weiterhin keine bestehende UI- oder App-Flow-Anbindung vornehmen.
