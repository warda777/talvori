# 87 Local Debug Router Dev Gate Plan

Stand: 2026-05-14

## 1. Ziel

Die echte Debug-Router-Anbindung soll den `LocalLearningTestScreen` spaeter manuell erreichbar machen.

Ziele:

- Zugriff nur in Debug/Dev.
- Keine produktive Navigation.
- Keine bestehende Lernoberflaeche ersetzen.
- Keine Aenderung am bestehenden Supabase-Lernflow.
- Keine automatische lokale Datenbefuellung.
- Keine Kopplung von Route und Import.

Die Route bleibt ein internes Werkzeug fuer Entwicklung und QA. Sie ist keine Produktintegration.

## 2. Moegliche Gate-Strategien

### kDebugMode

Beschreibung:

- Debug-Route wird nur registriert, wenn `kDebugMode == true`.

Vorteile:

- Einfach.
- Flutter-Standard.
- Gut testbar, wenn die Gate-Logik in einer kleinen Funktion gekapselt wird.

Nachteile:

- Profile-/QA-Builds sind nicht automatisch abgedeckt.
- Direktes Verwenden in `main.dart` waere trotzdem riskant, wenn zu frueh integriert.

Bewertung:

- Gute Grundlage fuer Version 1, aber nicht direkt in `main.dart` starten.

### Eigenes Debug-Flag

Beschreibung:

- Eine eigene Debug-Konfiguration entscheidet, ob lokale Debug-Routen sichtbar sind.

Vorteile:

- Bewusster steuerbar als reines `kDebugMode`.
- Kann spaeter fuer QA/Profile-Builds erweitert werden.

Nachteile:

- Mehr Konfiguration.
- Risiko falscher Defaults.
- Braucht klare Tests fuer true/false.

Bewertung:

- Sinnvoll, wenn Debug-Zugaenge ueber reine Debug-Builds hinaus gebraucht werden.

### Separate Debug-Router-Composition

Beschreibung:

- Debug-Routen werden in einer separaten Composition gesammelt.
- Die Produkt-App muss sie nicht kennen, solange keine bewusste Einbindung erfolgt.

Vorteile:

- Saubere Trennung von Produkt- und Debug-Routing.
- Gut isoliert testbar.
- Kein normaler Menueeintrag noetig.
- Bessere Vorbereitung fuer mehrere Debug-Werkzeuge.

Nachteile:

- Noch nicht automatisch manuell erreichbar.
- Spaeter braucht es einen bewussten Hook in die App-Composition.

Bewertung:

- Sicherste technische Richtung fuer den naechsten Schritt.

### Versteckte Dev-Route

Beschreibung:

- Eine Route existiert, wird aber nicht in Menues angezeigt.
- Zugriff waere nur ueber direkten Pfad oder Dev-Werkzeug moeglich.

Vorteile:

- Keine normale Produktnavigation.
- Manuell testbar, sobald eingebunden.

Nachteile:

- Kann trotzdem produktiv erreichbar sein, wenn falsch gegated.
- Erfordert sehr klare Build-/Gate-Regeln.

Bewertung:

- Spaeter moeglich, aber nicht ohne vorherige Gate-Tests.

### Direkte main.dart-Route

Beschreibung:

- `main.dart` registriert die Debug-Route direkt.

Vorteile:

- Schnell erreichbar.

Nachteile:

- `main.dart` enthaelt App-Start, InitGate, Supabase-Initialisierung und HomeScreen-Composition.
- Hoeheres Risiko fuer bestehende App-Flows.
- Debug-Route kann versehentlich produktiv sichtbar werden.

Bewertung:

- Aktuell nicht empfohlen.

## 3. Empfehlung

Empfohlen fuer den naechsten Schritt:

1. Eine kleine, isolierte Dev-Gate-Logik planen/implementieren.
2. Sie nicht in `main.dart` einbauen.
3. Eine separate Debug-Router-Composition oder Debug-Route-Liste verwenden.
4. Tests fuer Debug an/aus schreiben.

Die sicherste Variante ist:

- separate Debug-Router-Composition
- gesteuert durch ein kleines Debug-Gate
- standardmaessig nicht produktiv sichtbar
- weiterhin keine App-Router- oder `main.dart`-Aenderung im ersten Schritt

## 4. Spaetere Einbindung

Eine spaetere Einbindung sollte ohne normale Navigation erfolgen.

Erlaubte Richtung:

- Debug-Router-Composition nutzt `localLearningDebugRouteDefinition`.
- Bei aktivem Debug-Gate wird die Debug-Route in einer Debug-Routenliste bereitgestellt.
- Kein normaler Menueintrag.
- Kein Link aus bestehendem Lernflow.
- Kein Zugriff ueber `LearnModeController`.
- Keine Aenderung an `learn_mode_screen.dart`.
- Keine Supabase-Abhaengigkeit.

Nicht als erster Schritt:

- Route direkt in `MaterialApp` einhaengen.
- `main.dart` umbauen.
- HomeScreen oder Produktnavigation erweitern.

## 5. categoryId

Fuer Version 1 bleibt:

- `categoryId: basics`

Regeln:

- Die Kategorie-ID kommt aus der Debug-Route-Definition.
- Der Screen fragt keine Kategorie ab.
- Der Screen startet keinen Import.
- Der Screen startet keinen Seed.
- Wenn `basics` nicht importiert ist, darf der Screen Initial- oder Fehlerzustaende zeigen.

Spaeter kann eine Parametrisierung geplant werden:

- Query-Parameter
- Route-Parameter
- internes Debug-Auswahlmenue

Das ist nicht Teil des naechsten kleinen Schritts.

## 6. Voraussetzungen Vor Nutzung

Vor sinnvoller manueller Nutzung muss eine lokale Datenbasis bewusst vorbereitet werden.

Moeglich:

- Kontrollierter Asset-Import wurde vorher explizit ausgeloest.
- Lokale Daten wurden in einer Debug-/QA-Umgebung bewusst angelegt.

Nicht erlaubt:

- Import beim Oeffnen der Route.
- Import beim App-Start.
- automatische Datenbefuellung im Router.
- automatische Datenbefuellung im Screen.

Die Debug-Route zeigt nur, ob die lokale Lernkette mit vorhandenen Daten funktioniert.

## 7. Was nicht passieren darf

Nicht erlaubt:

- kein automatischer Import beim Oeffnen.
- keine App-Start-Datenbefuellung.
- keine Supabase-Nutzung.
- keine produktive Sichtbarkeit.
- keine Aenderung des bestehenden Lernflows.
- keine Aenderung an `learn_mode_screen.dart`.
- keine Aenderung an `LearnModeController`.
- keine Aenderung an `word_providers.dart`.
- keine Nutzung von `local_word_database.dart`.
- keine Produktnavigation.

## 8. Sinnvolle Tests

Spaetere Tests:

- `debug_gate_exposes_route_only_in_debug_mode`
  - Bei aktivem Debug-Gate ist die Debug-Route in der Debug-Routenliste enthalten.

- `debug_gate_does_not_register_route_in_production_mode`
  - Bei deaktiviertem Debug-Gate ist die Debug-Route nicht enthalten.

- `debug_route_builds_local_learning_test_screen`
  - Route baut `LocalLearningTestScreen` mit `categoryId: basics`.

- `debug_route_does_not_start_import`
  - Route-Building ruft keinen Importservice auf.

- `debug_route_does_not_touch_supabase`
  - Route-Building ist mit lokalen Provider-Overrides testbar und braucht keine Supabase-Initialisierung.

Optional spaeter:

- `debug_route_has_no_product_menu_entry`
  - Erst sinnvoll, wenn ein Menue oder eine echte Navigation eingefuehrt wird.

## 9. Risiken

Risiken:

- Debug-Route wird produktiv sichtbar.
- `main.dart` wird zu frueh riskant geaendert.
- Route wird mit fertiger Produktintegration verwechselt.
- Lokale DB enthaelt noch keine `basics`-Daten.
- Import und Route werden zu frueh gekoppelt.
- Debug-Gate hat unsichere Defaults.

Gegenmassnahmen:

- Dev-Gate zuerst isoliert testen.
- Keine direkte `main.dart`-Aenderung.
- Debug-Route nicht in Produktnavigation anzeigen.
- `basics` als explizite Debug-ID behandeln.
- Keine automatische Datenbefuellung.

## 10. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt:

1. Eine kleine Dev-Gate-/Debug-Router-Composition isoliert erstellen.
2. Noch nicht in `main.dart` einbinden.
3. Test schreiben:
   - `debug_gate_exposes_route_only_in_debug_mode`
4. Testfall fuer aktiviertes Gate:
   - Route-Liste enthaelt `localLearningDebugRouteDefinition`.
5. Testfall fuer deaktiviertes Gate:
   - Route-Liste enthaelt die Debug-Route nicht.
6. Weiterhin pruefen:
   - kein Import wird gestartet.
   - keine Datenbank wird geoeffnet.
   - kein Supabase wird gebraucht.

Nicht als naechster Schritt:

- `main.dart` aendern.
- Produktnavigation erweitern.
- Dev-Menue bauen.
- Import automatisch an Route koppeln.
