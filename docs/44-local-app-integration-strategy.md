# 44 Local App Integration Strategy

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine vorsichtige lokale App-Integrationsstrategie fuer die bereits vorbereitete Offline-first-Schicht.

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine Provider-Umstellung
- keine App-Flow-Aenderung

## Ausgangslage

Der lokale Block ist technisch vorhanden:

- `LocalAppBootstrap`
- `LocalAppBootstrapResult`
- `LocalDatabaseFactory`
- `LocalRepositoryFactory`
- `LocalLearningSessionFacade`
- Seed-Daten
- lokale SRS-/SQLite-/Repository-/Read-State-/Facade-Tests

Die bestehende App verwendet aber weiterhin:

- Supabase-Initialisierung in `main.dart`
- `SupabaseWordRepository`
- alten `LearnModeController`
- alte SRS-/Queue-/UI-nahe Logik in `lib/features/words/`

Deshalb darf die lokale Schicht nicht direkt in bestehende Flows eingesteckt werden.

## 1. Wo LocalAppBootstrap Spaeter Erzeugt Werden Koennte

Langfristig gibt es drei plausible Orte.

### Variante A: In main.dart / InitGate

Beschreibung:

- `main.dart` oder `_InitGate` erzeugt den lokalen Bootstrap beim App-Start.

Vorteile:

- frueh verfuegbar
- zentraler App-Lifecycle
- Datenbank kann einmalig geoeffnet werden

Risiken:

- `main.dart` initialisiert aktuell Supabase, `.env`, Debug-Login, SharedPreferences und App-Start.
- Eine zusaetzliche lokale Initialisierung erhoeht die Startkomplexitaet.
- Fehler im lokalen Bootstrap koennten den kompletten App-Start blockieren.

Bewertung:

- fuer spaeter sinnvoll, aber nicht als naechster Schritt.

### Variante B: Eigener UI-neutraler LocalAppServicesProvider

Beschreibung:

- Ein neuer lokaler Provider/Service-Baustein erzeugt und haelt `LocalAppBootstrapResult`.
- `main.dart` bleibt zunaechst unveraendert.
- ViewModels koennen spaeter gezielt diesen lokalen Einstiegspunkt lesen.

Vorteile:

- kleinerer Eingriff
- besser testbar
- Supabase bleibt parallel unangetastet
- App-Start bleibt stabil
- lokale Integration kann neben bestehender App vorbereitet werden

Risiken:

- Datenbank-Lifecycle muss trotzdem sauber geklaert werden.
- Provider darf nicht versehentlich alte Flows ersetzen.

Bewertung:

- beste Richtung fuer den ersten echten Integrationsschritt.

### Variante C: Direkt In LearnModeController

Beschreibung:

- `LearnModeController` erzeugt oder liest den lokalen Bootstrap direkt.

Vorteile:

- nah am Lernflow

Risiken:

- `learn_mode_controller.dart` ist sehr gross und enthaelt alte SRS-, Queue-, Timer-, Supabase- und UI-State-Logik.
- Direkte Integration wuerde neue und alte Engines vermischen.
- Fehler waeren schwer zu isolieren.

Bewertung:

- nicht empfohlen.

## Empfehlung

`LocalAppBootstrap` sollte spaeter nicht direkt in `LearnModeController` und nicht sofort in `main.dart` eingebaut werden.

Empfohlen wird zuerst ein neuer UI-neutraler lokaler App-Services-Baustein, der `LocalAppBootstrapResult` kapselt und spaeter von einem neuen lokalen Lerncontroller gelesen werden kann.

## 2. Besitz Von LocalAppBootstrapResult

`LocalAppBootstrapResult` sollte genau einen klaren Besitzer haben.

Empfohlen:

- ein spaeterer `LocalAppServices`- oder `LocalAppBootstrapProvider` besitzt das Result.

Dieser Besitzer haelt:

- `databasePath`
- `database`
- `repositoryFactory`
- `learningSessionFacade`

Er sollte zunaechst nicht:

- bestehende Supabase-Provider ersetzen
- `supabaseWordRepositoryProvider` ueberschreiben
- direkt UI-State verwalten
- lokale Sessions automatisch starten

## 3. Verantwortung Fuer database.close()

Die Datenbank wird durch `LocalAppBootstrap` geoeffnet, aber aktuell nicht automatisch geschlossen.

Fuer eine App-Integration muss klar gelten:

- Der Besitzer von `LocalAppBootstrapResult` ist fuer `database.close()` verantwortlich.
- Wenn Riverpod verwendet wird, sollte `ref.onDispose(...)` den Close ausloesen.
- Solange der Bootstrap nur lokal getestet wird, schliessen Tests die Datenbank selbst.

[PRÜFEN] Vor echter App-Anbindung muss entschieden werden, ob ein eigener `close()`-Helper am Result ergaenzt wird oder ob der Provider direkt `database.close()` aufruft.

## 4. Bereitstellung Der LocalLearningSessionFacade Fuer ViewModels

Die Facade sollte spaeter nicht global lose erzeugt werden.

Empfohlene Richtung:

1. `LocalAppBootstrapResult` wird durch einen lokalen Provider/Besitzer erzeugt.
2. Ein separater Provider stellt daraus `LocalLearningSessionFacade` bereit.
3. Ein neuer lokaler Lerncontroller liest nur die Facade.
4. Bestehende UI wird erst spaeter kontrolliert auf diesen neuen Controller gemappt.

Wichtig:

- Die Facade bleibt UI-neutral.
- ViewModels erhalten keine direkte `Database`.
- ViewModels erhalten keine direkten Repositorys, solange sie nur Lernsessions steuern muessen.
- Der lokale Controller spricht mit `LocalLearningSessionFacade`, nicht mit SQLite.

## 5. Warum main.dart Noch Nicht Sofort Geaendert Werden Sollte

`main.dart` ist aktuell ein kritischer Startpunkt:

- setzt globale Fehlerbehandlung
- startet `ProviderScope`
- initialisiert `.env`
- initialisiert Supabase
- fuehrt Debug-Auto-Login aus
- testet Supabase-Datenbankverbindung
- setzt SharedPreferences-Testdaten
- zeigt Lade- und Fehlerzustand

Eine direkte Aenderung an `main.dart` waere riskant, weil:

- App-Start und lokale DB-Oeffnung miteinander gekoppelt wuerden
- Supabase weiterhin parallel aktiv ist
- Fehler im lokalen Bootstrap die gesamte App blockieren koennten
- noch nicht entschieden ist, wann Seed laufen darf
- `database.close()` im App-Lifecycle noch nicht final geplant ist

Empfehlung:

- `main.dart` erst anfassen, wenn ein isolierter lokaler Provider/Service mit Tests existiert und klar ist, wie der Lifecycle geschlossen wird.

## 6. Supabase Bleibt Zunaechst Parallel Unangetastet

Supabase soll in der naechsten Phase nicht entfernt und nicht ersetzt werden.

Das bedeutet:

- `Supabase.initialize(...)` bleibt unveraendert.
- `supabaseWordRepositoryProvider` bleibt unveraendert.
- bestehende WordHub-, Home-, Kategorie- und Lernflows bleiben unveraendert.
- lokale SQLite-Schicht wird nur daneben vorbereitet.
- kein bestehender Controller wird automatisch auf lokale Daten umgestellt.

Vorteil:

- Die App bleibt lauffaehig.
- Der lokale Block kann schrittweise validiert werden.
- Rueckfallrisiko ist klein, weil alte Flows nicht beruehrt werden.

## 7. Erste Risikoarme Vorbereitungsdatei

Die erste risikoarme Vorbereitung sollte nicht in bestehender UI oder alten Controllern passieren.

Empfohlen:

- eine neue Datei im lokalen Bereich, z. B. unter `lib/core/local_database/` oder `lib/core/local_database/services/`

Moeglicher naechster Baustein:

- `LocalAppServices`
- oder `LocalAppBootstrapProvider` als isolierter Riverpod-Provider

Wenn Riverpod verwendet wird, sollte die erste Umsetzung weiterhin keinen bestehenden Provider ersetzen.

Vorsicht:

- `word_providers.dart` ist ein zentraler bestehender Provider-Knoten mit Supabase-Provider und Learn-Mode-Selektoren.
- Eine direkte Aenderung dort ist riskanter als ein neuer isolierter lokaler Provider.

## 8. Besonders Riskante Dateien

Besonders vorsichtig behandeln:

- `lib/main.dart`
  - App-Start, Supabase, `.env`, Auth, Ladezustand

- `lib/features/words/application/learn_mode_controller.dart`
  - sehr gross
  - alte SRS-Logik
  - Supabase-Repository
  - Timer, Queue, Stage, Hybrid und UI-nahe State-Logik

- `lib/features/words/application/word_providers.dart`
  - stellt bestehende Supabase-Repositorys und Learn-Mode-Selektoren bereit
  - zentrale Abhaengigkeit fuer viele UI-Teile

- `lib/features/words/data/supabase_word_repository.dart`
  - grosse Supabase-Datenquelle
  - alte SRS-Persistenz und RPCs

- `lib/features/words/application/srs_mode_controller.dart`
  - alte Moduslogik mit Longpress/Hybrid

- `lib/features/words/ui/screens/learn_mode_screen.dart`
  - alte Lern-UI, `WordUserView`, Stage-Anzeige, Moduslogik

- `lib/features/words/ui/screens/category_detail_screen.dart`
  - Startpunkt fuer Kategorie-/Lernsession-Flows

- `lib/features/words/ui/widgets/srs_mode_toggle.dart`
  - alte technische Labels und Longpress-Hybrid

- `lib/features/words/ui/widgets/stage_switch_row.dart`
  - komplexe Stage-/Trainingsbereich-Interaktion

Diese Dateien sollten erst angefasst werden, wenn ein neuer lokaler Controller und Adapterplan steht.

## 9. Neuer Lokaler Controller Statt Direkter LearnModeController-Umbau

Ein neuer lokaler Controller ist besser als ein direkter Umbau von `learn_mode_controller.dart`.

Empfohlene Richtung:

- neuer `LocalLearningController` oder `LocalLearningSessionController`
- nutzt `LocalLearningSessionFacade`
- gibt UI-neutralen oder UI-nahen State aus
- kennt keine Supabase-Repositorys
- kennt keine alte SRS-Engine
- ersetzt den alten Controller noch nicht automatisch

Warum:

- alte und neue Logik bleiben getrennt
- Tests koennen klein bleiben
- Rueckbau ist einfach
- bestehende UI-Flows bleiben stabil
- spaetere UI-Anbindung kann schrittweise erfolgen

Nicht empfohlen:

- `learn_mode_controller.dart` direkt auf lokale SQLite-Schicht umbauen
- alte State-Felder sofort entfernen
- `WordUserView` sofort durch `LocalSessionReadState` ersetzen

## 10. Tests Vor Jeder Echten App-Anbindung

Vor jeder echten App-Anbindung muessen mindestens laufen:

- `flutter test test/core/srs/`
- `flutter test test/core/local_database/`
- `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`

Wenn ein neuer lokaler Provider oder Controller entsteht, zusaetzlich:

- gezielte Tests fuer diesen neuen Provider/Controller
- Start ohne Seed
- Start mit Seed
- Lifecycle/Dispose schliesst Datenbank
- keine Nutzung von `word_progress.db`
- keine zweite aktive Session fuer denselben Kontext
- keine Supabase-Abhaengigkeit im lokalen Controller

Vor Aenderungen an bestehenden App-Dateien zusaetzlich:

- bestehende relevante Widget-/Controller-Tests, falls vorhanden
- `flutter analyze` fuer die beruehrten Dateien
- manueller Smoke-Test der betroffenen App-Route

## 11. Empfohlener Kleinster Naechster Schritt

Der kleinste sinnvolle naechste Schritt ist weiterhin UI-neutral:

1. Einen neuen lokalen Bootstrap-Provider/Service planen.
2. Klaeren, ob dieser in `core/local_database` bleibt oder in einen kleinen App-Composition-Bereich wandert.
3. Einen Test planen, der prueft:
   - Bootstrap wird einmalig erzeugt
   - `LocalAppBootstrapResult` ist verfuegbar
   - `LocalLearningSessionFacade` ist verfuegbar
   - `database.close()` wird bei Dispose aufgerufen
   - Supabase-Provider bleiben unangetastet

Erst danach sollte Code fuer diesen isolierten lokalen Provider geschrieben werden.

Noch kein Schritt sollte:

- `main.dart` veraendern
- `learn_mode_controller.dart` umbauen
- `word_providers.dart` ersetzen
- Supabase entfernen
- UI-Buttons oder Lernscreen-Flows anbinden

## Empfehlung

Die lokale Schicht ist bereit fuer eine vorsichtige Integrationsplanung, aber noch nicht fuer eine direkte App-Flow-Umstellung.

Empfohlen wird:

1. Neuer isolierter lokaler Bootstrap-/Services-Provider.
2. Danach neuer lokaler Lerncontroller gegen `LocalLearningSessionFacade`.
3. Danach erst Adapterplanung fuer bestehende UI.

Diese Reihenfolge haelt Supabase und die alte Lernlogik lauffaehig, waehrend die neue Offline-first-Schicht kontrolliert in die App hineinwachsen kann.
