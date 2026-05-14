# 85 Local Debug Router Integration Plan

Stand: 2026-05-14

## 1. Ziel der Debug-Router-Integration

Die Debug-Router-Integration soll den bestehenden `LocalLearningTestScreen` spaeter manuell erreichbar machen, ohne die produktive App-Navigation oder bestehende Lernflows zu veraendern.

Ziele:

- `LocalLearningTestScreen` in einer App-Umgebung oeffnen koennen.
- Lokale Offline-first-Kette visuell pruefen.
- Debug-/Dev-Zugang statt Produktfeature.
- Keine bestehende Lernoberflaeche ersetzen.
- Keine Aenderung an `learn_mode_screen.dart`.
- Keine Aenderung am bestehenden `LearnModeController`.
- Keine Supabase- oder alte Word-Datenquelle einbinden.

Die Route bleibt ein Werkzeug fuer Entwicklung und QA. Sie ist keine finale UI-Integration.

## 2. Moegliche Integrationsvarianten

### Variante A: Gar nicht einhaengen, Builder behalten

Beschreibung:

- Der bestehende Builder bleibt isoliert:
  - `localLearningDebugRoutePath`
  - `buildLocalLearningDebugScreen(...)`
- Keine App-Route wird registriert.
- Keine Navigation wird geaendert.

Vorteile:

- Kein Risiko fuer bestehende App-Flows.
- Kein Risiko fuer produktive Sichtbarkeit.
- Bestehende Tests bleiben isoliert.
- Kein Kontakt mit `main.dart`.

Nachteile:

- Screen ist weiterhin nicht manuell in der laufenden App erreichbar.

Bewertung:

- Sicherster aktueller Zustand.

### Variante B: Separate Debug-Router-Datei

Beschreibung:

- Eine separate Debug-Router-Datei wuerde Debug-Routen definieren.
- Diese Datei wuerde noch nicht automatisch in `main.dart` eingebunden.
- Spaeter koennte eine Debug-Composition sie gezielt verwenden.

Vorteile:

- Debug-Routing bleibt von Produkt-Routing getrennt.
- Route kann isoliert getestet werden.
- Kein Menueeintrag in normaler UI.
- Geringeres Risiko als direkte `main.dart`-Aenderung.

Nachteile:

- Solange sie nicht in eine Debug-Composition eingebunden ist, bleibt sie nicht manuell erreichbar.
- Es braucht spaeter einen klaren Debug-Gate.

Bewertung:

- Beste technische Naechstvariante, wenn mehr als der Builder noetig wird.

### Variante C: Dev-Menue spaeter

Beschreibung:

- Ein internes Dev-Menue koennte Debug-Werkzeuge anzeigen und zur lokalen Lernroute navigieren.

Vorteile:

- Bewusster Zugang fuer QA/Entwicklung.
- Skalierbar fuer mehrere Debug-Werkzeuge.

Nachteile:

- Beruehrt UI.
- Braucht klare Sichtbarkeitsregeln.
- Hoeheres Risiko, versehentlich produktiv sichtbar zu werden.

Bewertung:

- Erst spaeter sinnvoll, nicht als naechster Schritt.

### Variante D: Direkte main.dart-Route

Beschreibung:

- `main.dart` wuerde um eine Route oder Routing-Konfiguration erweitert.

Vorteile:

- Schnell manuell erreichbar.

Nachteile:

- Beruehrt App-Composition.
- `main.dart` enthaelt aktuell InitGate, Supabase-Initialisierung und App-Startlogik.
- Hoeheres Risiko fuer bestehende Flows.
- Debug-Zugang koennte versehentlich produktiv sichtbar werden.

Bewertung:

- Aktuell vermeiden.

### Variante E: Vorhandene Navigation erweitern

Beschreibung:

- Ein bestehender Screen oder ein bestehendes Menue wuerde einen Link zur Debug-Route erhalten.

Vorteile:

- Einfach fuer manuelle Tests erreichbar.

Nachteile:

- Veraendert bestehende UI.
- Veraendert Produktnavigation.
- Vermischt Debug- und Produktflaechen.
- Risiko fuer normale Nutzer.

Bewertung:

- Nicht geeignet fuer den naechsten Schritt.

## 3. Klare Empfehlung

Empfehlung:

1. Den bestehenden Builder als abgeschlossen betrachten.
2. Als naechsten technischen Schritt hoechstens eine separate Debug-Router-Datei planen/implementieren.
3. Diese Debug-Router-Datei noch nicht in `main.dart` oder Produktnavigation einhaengen.
4. Keine direkte `main.dart`-Route als naechsten Schritt.

Die sicherste Variante fuer den naechsten TDD-Schritt ist also:

- separate Debug-Router-/Route-Definition isoliert testen,
- ohne App-Composition,
- ohne Produktnavigation,
- ohne automatische Datenbefuellung.

## 4. Schutz vor produktiver Sichtbarkeit

Eine spaetere echte Debug-Router-Anbindung braucht mindestens eine Schutzschicht.

Moegliche Schutzmechanismen:

- `kDebugMode`
  - Route nur in Debug-Builds registrieren.
  - Vorteil: einfacher Flutter-Standard.
  - Grenze: QA/Profile-Builds brauchen ggf. andere Regeln.

- Explizites Debug-Flag
  - Zum Beispiel eine zentrale Debug-Konfiguration.
  - Vorteil: bewusst steuerbar.
  - Grenze: muss sauber verwaltet werden.

- Separate Debug-Composition
  - Eine eigene App-Composition oder ein eigener Router fuer Debug-Werkzeuge.
  - Vorteil: Produkt-App bleibt sauber.
  - Grenze: mehr Struktur erforderlich.

- Kein Menueeintrag in normaler UI
  - Auch wenn die Route existiert, darf sie nicht in Produktnavigation angezeigt werden.

Empfehlung fuer Version 1:

- Noch keine echte Anbindung.
- Fuer eine spaetere Anbindung: `kDebugMode` plus getrennte Debug-Router-Datei bevorzugen.
- Kein normaler UI-Menueeintrag.

## 5. categoryId-Uebergabe

Fuer den ersten Debug-Fall sollte die Kategorie explizit bleiben.

Empfehlung:

- Zunaechst `categoryId: 'basics'`.
- Spaeter optional Route-Parameter oder Query-Parameter.
- Keine Kategorieabfrage im Screen.
- Kein automatischer Import.
- Kein automatischer Seed.

Begruendung:

- `LocalLearningTestScreen` ist bereits auf Konstruktor-`categoryId` ausgelegt.
- Der Screen bleibt UI-nah, aber datenquellenfrei.
- Wenn `basics` nicht existiert, ist das ein Vorbereitungsproblem, kein Screen-Problem.

## 6. Voraussetzungen vor Nutzung

Vor einer sinnvollen manuellen Nutzung muessen lokale Daten bewusst vorhanden sein.

Moegliche Wege:

- Kontrollierter Asset-Import wurde vorher explizit ausgeloest.
- Alternativ existieren Test-/Debug-Daten durch einen bewussten lokalen Setup-Schritt.
- Ohne Daten zeigt der Screen initiale oder Fehlerzustaende.

Nicht erlaubt:

- Kein automatischer Import beim Route-Aufruf.
- Keine automatische Datenbankbefuellung.
- Kein Import im Builder.
- Kein Import im Screen.
- Kein Import beim App-Start.

Die Route darf nur sichtbar machen, ob die lokale Umgebung vorbereitet ist.

## 7. Was nicht passieren darf

Die Integration darf nicht:

- automatischen Import beim Oeffnen der Route starten.
- Supabase verwenden.
- bestehenden Lernflow veraendern.
- `learn_mode_screen.dart` veraendern.
- `LearnModeController` veraendern.
- `word_providers.dart` veraendern.
- `local_word_database.dart` verwenden.
- produktive Navigation erweitern.
- normale Nutzer zur Debug-Route fuehren.
- Import und Route fachlich koppeln.

Die lokale Debug-Route bleibt ein isolierter Zugang zu einem isolierten Testscreen.

## 8. Sinnvolle Tests

Spaetere Tests:

- `debug_router_registers_route_only_in_debug_mode`
  - Prueft, dass Debug-Routen nur bei aktivem Debug-Gate verfuegbar sind.

- `debug_router_builds_local_learning_screen`
  - Prueft, dass die Route den `LocalLearningTestScreen` mit `categoryId: basics` baut.

- `debug_router_does_not_import_automatically`
  - Prueft, dass Route-Building keinen Importservice aufruft und keine Daten erzeugt.

- `debug_router_does_not_touch_supabase`
  - Prueft, dass lokale Provider-Overrides ausreichen und keine Supabase-Initialisierung noetig ist.

- `production_routes_do_not_include_debug_local_learning`
  - Prueft, dass produktive Routen die Debug-Route nicht enthalten.

Optional:

- `debug_router_can_accept_category_id_parameter`
  - Erst sinnvoll, wenn Parameter statt fixer `basics`-ID geplant wird.

## 9. Risiken

Risiken:

- Debug-Route wird versehentlich produktiv sichtbar.
- `categoryId: basics` zeigt auf nicht importierte Daten.
- Import und Route werden zu frueh gekoppelt.
- `main.dart` wird zu frueh riskant geaendert.
- Bestehender Supabase-Lernflow und lokale Offline-first-Kette werden vermischt.
- Debug-Route wird mit fertiger Produktintegration verwechselt.

Gegenmassnahmen:

- Separate Debug-Router-Datei statt direkter `main.dart`-Aenderung.
- Route nicht in Produktnavigation anzeigen.
- Debug-Gate vor echter Anbindung definieren.
- Kategorie explizit uebergeben.
- Keine automatische Datenbefuellung.

## 10. Kleinster naechster TDD-Schritt

Der kleinste sichere naechste TDD-Schritt:

1. Eine isolierte Debug-Router-Definitionsdatei planen oder erstellen, die noch nicht in die App eingebunden ist.
2. Einen Test schreiben:
   - `debug_router_builds_local_learning_screen`
3. Die Route in diesem Test direkt aus der Debug-Router-Definition bauen.
4. Provider-Overrides fuer Initialzustand nutzen.
5. Pruefen:
   - `LocalLearningTestScreen` wird gebaut.
   - `categoryId == basics`.
   - kein Import laeuft.
   - keine Datenbank wird geoeffnet.
   - kein Supabase wird gebraucht.
   - keine Produktnavigation wird geaendert.

Nicht als naechster Schritt empfohlen:

- `main.dart` aendern.
- bestehende Navigation erweitern.
- Dev-Menue bauen.
- Import automatisch mit Route koppeln.
