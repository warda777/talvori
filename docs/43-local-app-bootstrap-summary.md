# 43 Local App Bootstrap Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand des `LocalAppBootstrap`-Blocks zusammen.

Der Bootstrap ist ein UI-neutraler lokaler Integrationsbaustein. Er bereitet die lokale Offline-first-Schicht vor, ohne die bestehende App, Provider, UI, Navigation oder Supabase anzubinden.

## LocalAppBootstrap

`LocalAppBootstrap` uebernimmt die Koordination der lokalen Startbausteine:

- App-Datenbankpfad bilden
- lokale SQLite-Datenbank oeffnen
- `LocalRepositoryFactory` erzeugen
- `LocalLearningSessionFacade` bereitstellen
- optional kleine lokale Seed-Daten einfuegen

Umgesetzt ist:

- `bootstrap({required String databasesPath, required bool seedDefaults, required DateTime now})`

Der Bootstrap macht nicht:

- kein `getDatabasesPath()` direkt aufrufen
- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- kein Supabase
- keine alte `local_word_database.dart`
- keine App-Flow-Aenderung
- kein `main.dart`-Umbau

## LocalAppBootstrapResult

`LocalAppBootstrapResult` ist das Rueckgabe-Bundle des Bootstrap-Vorgangs.

Es enthaelt:

- `databasePath`
- `database`
- `repositoryFactory`
- `learningSessionFacade`

Damit bleibt der Datenbank-Lifecycle sichtbar:

- `LocalAppBootstrap` oeffnet die Datenbank.
- Der Aufrufer oder Test ist fuer `database.close()` verantwortlich.
- Die lokale Facade ist direkt verfuegbar, ohne UI oder Provider einzubeziehen.

## Ablauf Von bootstrap(...)

`bootstrap(...)` arbeitet in dieser Reihenfolge:

1. `LocalAppDatabasePath.buildPath(databasesPath)` bildet den Pfad zur neuen lokalen Datenbank.
2. `LocalDatabaseFactory.openAtPath(databasePath)` oeffnet die SQLite-Datenbank.
3. `LocalRepositoryFactory(database: database)` erzeugt lokale Repositorys und Services.
4. Bei `seedDefaults == true` fuehrt `LocalSeedDataService.seedDefaults(now: now)` Seed-Daten ein.
5. `LocalAppBootstrapResult` wird mit Pfad, Datenbank, RepositoryFactory und Facade zurueckgegeben.

## seedDefaults = false

Wenn `seedDefaults = false` gesetzt ist:

- die Datenbank wird geoeffnet
- das V1-Schema wird erstellt
- `LocalRepositoryFactory` wird erzeugt
- `LocalLearningSessionFacade` wird bereitgestellt
- keine Seed-Kategorien werden angelegt
- keine Seed-Woerter werden angelegt

Die Tabellen bleiben inhaltlich leer, sind aber vorhanden und nutzbar.

## seedDefaults = true

Wenn `seedDefaults = true` gesetzt ist:

- `LocalSeedDataService` wird verwendet
- Seed-Kategorien werden ueber `CategoryRepository` angelegt
- Seed-Woerter werden ueber `WordRepository` angelegt

Aktuelle Seed-Kategorien:

- `Basics`
- `Travel`
- `Exam Practice`

Wichtig:

- Seed schreibt keinen `word_progress`
- Seed schreibt keine `learning_sessions`
- Seed schreibt keine `review_history`
- Seed startet keine Session
- Seed erzeugt keine Lernhistorie

Progress entsteht weiterhin erst durch `LocalProgressInitializationService`.
Sessions entstehen weiterhin erst durch `LocalLearningSessionFacade.startOrResumeLearning(...)`.

## Abgrenzung Zur Alten word_progress.db

Der Bootstrap verwendet die neue lokale Datenbank:

- `talvori_local_v1.db`

Abgesichert wird:

- `LocalAppDatabasePath.databaseName` ist `talvori_local_v1.db`
- `LocalAppBootstrap` nutzt `LocalAppDatabasePath.buildPath(...)`
- der Bootstrap-Pfad enthaelt nicht `word_progress.db`
- im temporaeren Datenbankpfad wird keine `word_progress.db` erzeugt
- die alte `LocalWordDatabase` wird nicht initialisiert

Die alte lokale Datenbank bleibt bewusst getrennt und wird in diesem Block nicht beruehrt.

## Tests

Datei:

- `test/core/local_database/local_app_bootstrap_test.dart`

Tests:

- `bootstrap_opens_database_and_builds_facade`
- `bootstrap_can_seed_defaults_when_requested`
- `bootstrap_does_not_touch_old_word_progress_database`

### bootstrap_opens_database_and_builds_facade

Sichert ab:

- Bootstrap bildet den neuen lokalen Datenbankpfad.
- Die Datenbank wird geoeffnet.
- V1-Tabellen existieren.
- `LocalRepositoryFactory` wird bereitgestellt.
- `LocalLearningSessionFacade` wird bereitgestellt.
- Bei `seedDefaults = false` werden keine Kategorien und Woerter angelegt.

### bootstrap_can_seed_defaults_when_requested

Sichert ab:

- Bei `seedDefaults = true` werden `Basics`, `Travel` und `Exam Practice` angelegt.
- Seed-Woerter werden angelegt.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.
- Die Facade bleibt verfuegbar.

### bootstrap_does_not_touch_old_word_progress_database

Sichert ab:

- Der Bootstrap-Pfad endet auf `talvori_local_v1.db`.
- Der Bootstrap-Pfad enthaelt nicht `word_progress.db`.
- Im temporaeren Basisdatenbankpfad entsteht keine alte `word_progress.db`.

## Vollstaendige Lokale Kette

Folgende lokale Kette funktioniert jetzt:

1. App-Datenbankpfad bauen
2. lokale SQLite-Datenbank oeffnen
3. V1-Schema erstellen
4. Foreign Keys aktivieren
5. `LocalRepositoryFactory` erzeugen
6. lokale Repositorys und Services bereitstellen
7. optional Seed-Daten einfuegen
8. Progress fuer lokale Woerter initialisieren
9. lokale Session starten oder fortsetzen
10. `LocalSessionReadState` mit Wortdaten und Stage erzeugen
11. Antworten verarbeiten
12. Completion pruefen

Kurz:

- Bootstrap -> RepositoryFactory -> optional Seed -> Progress -> Session -> ReadState -> Answer -> Completion

Die Kette bleibt vollstaendig lokal und UI-neutral.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- kein `main.dart`-Umbau
- kein `LearnModeController`-Umbau
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine echte App-Datenmigration
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Daten
- keine Nutzung der alten `word_progress.db`
- keine echten Launch-Inhalte
- kein DeepL-/Wortimport
- kein `WordUserView`-Adapter

Der Bootstrap ist bereit als lokaler Baustein, aber noch nicht als App-Start-Integration.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Lokalen Gesamtblock weiterhin regelmaessig pruefen:
   - `flutter test test/core/srs/`
   - `flutter test test/core/local_database/`
   - `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`

2. UI-neutrale App-Anbindungsplanung erstellen:
   - Wo wird Bootstrap spaeter erzeugt?
   - Wer besitzt `database.close()`?
   - Wie wird die Facade spaeter ViewModels bereitgestellt?

3. Seed-Daten erweitern oder Importstrategie finalisieren:
   - kleine Demo-Seeds beibehalten
   - spaeter JSON/Asset pruefen
   - Supabase-Export separat planen

4. Bestehende App-Controller und ViewModels erst danach vorsichtig vorbereiten.

5. Vor jeder echten App-Anbindung erneut Risikoanalyse und Stabilitaetscheck ausfuehren.

## Warum Weiterhin Keine UI-/Provider-/Supabase-Anbindung

Noch keine UI-, Provider- oder Supabase-Anbindung sollte erfolgen.

Gruende:

- Die lokale Schicht ist stabil, aber noch nicht in den bestehenden App-Lifecycle eingeordnet.
- Der Datenbank-Lifecycle muss vor der App-Anbindung klar entschieden werden.
- Supabase ist weiterhin aktiv und darf nicht unkontrolliert ersetzt werden.
- Bestehende ViewModels und Controller koennen sonst unbeabsichtigt alte und neue Datenquellen mischen.
- Die Seed-Daten sind noch klein und nicht als Launch-Datensatz gedacht.
- Eine zu fruehe UI-Anbindung wuerde das Risiko fuer App-Flows erhoehen.

Der naechste Schritt sollte deshalb weiterhin geplant, klein und UI-neutral bleiben.
