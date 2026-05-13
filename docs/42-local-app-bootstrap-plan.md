# 42 Local App Bootstrap Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen UI-neutralen `LocalAppBootstrap`.

Der Bootstrap soll die bereits stabilen lokalen Bausteine koordinieren, ohne die bestehende App anzubinden:

- App-Datenbankpfad bilden
- lokale SQLite-Datenbank oeffnen
- `LocalRepositoryFactory` bauen
- `LocalLearningSessionFacade` bereitstellen
- optional kleine Seed-Daten ausfuehren
- weiterhin keine UI, Provider, Navigation, Supabase oder bestehende App-Flows anfassen

Der Bootstrap ist ein lokaler Integrationsbaustein. Er ist noch keine App-Start-Anbindung.

## Zu Koordinierende Komponenten

### LocalAppDatabasePath

Aufgabe:

- baut aus einem uebergebenen Basisdatenbankpfad den Pfad zur neuen lokalen Datenbank
- verwendet `talvori_local_v1.db`
- verwendet nicht `word_progress.db`

### LocalDatabaseFactory

Aufgabe:

- oeffnet eine SQLite-Datenbank an einem gegebenen Pfad
- verwendet `LocalDatabaseSchema.version`
- erstellt V1-Schema bei Neuanlage
- aktiviert Foreign Keys

### LocalRepositoryFactory

Aufgabe:

- nimmt eine bereits geoeffnete `Database`
- erzeugt lokale Repositorys und Services
- stellt `LocalLearningSessionFacade` bereit

### LocalSeedDataService

Aufgabe:

- legt optional kleine lokale Standard-Kategorien und Standard-Woerter an
- nutzt `CategoryRepository` und `WordRepository`
- schreibt keinen Progress, keine Sessions und keine Review-History

### LocalLearningSessionFacade

Aufgabe:

- UI-neutraler Einstiegspunkt fuer spaetere lokale Lernsession-Flows
- startet/fortsetzt Sessions
- verarbeitet Antworten
- schliesst Sessions bei Completion ab

## Sinnvolle Methode

Vorschlag:

```dart
bootstrap({
  required String databasesPath,
  required bool seedDefaults,
  required DateTime now,
})
```

Geplanter Ablauf:

1. `LocalAppDatabasePath.buildPath(databasesPath)` aufrufen.
2. `LocalDatabaseFactory.openAtPath(path)` aufrufen.
3. `LocalRepositoryFactory(database: db)` erzeugen.
4. Wenn `seedDefaults == true`:
   - `LocalSeedDataService(...)` erzeugen
   - `seedDefaults(now: now)` ausfuehren
5. Ergebnisobjekt zurueckgeben.

Wichtig:

- `databasesPath` wird uebergeben.
- Bootstrap ruft im ersten lokalen Schritt nicht selbst `getDatabasesPath()` auf.
- Dadurch bleibt der Baustein testbar und UI-neutral.

## Rueckgabevarianten

### Variante A: LocalLearningSessionFacade Direkt

Beschreibung:

- `bootstrap(...)` gibt nur `LocalLearningSessionFacade` zurueck.

Vorteile:

- minimal
- spaeter leicht fuer ViewModel nutzbar

Nachteile:

- Datenbankinstanz ist nicht erreichbar
- Lifecycle/Close-Verantwortung ist unklar
- Tests koennen schwerer pruefen, welcher Pfad geoeffnet wurde
- spaeter fehlen Repositorys fuer Diagnose, Seed und lokale Datenpflege

Bewertung:

- zu schmal fuer Version 1

### Variante B: Kleines Dependency-Bundle

Beschreibung:

- Bootstrap gibt ein Bundle mit Datenbank, Pfad, RepositoryFactory und Facade zurueck.

Moegliche Felder:

- `databasePath`
- `database`
- `repositoryFactory`
- `learningSessionFacade`

Optional spaeter:

- `seedWasRun`
- `close()`

Vorteile:

- Lifecycle bleibt sichtbar
- Tests koennen Datenbank und Tabellen pruefen
- lokale Services bleiben erreichbar
- keine UI-/Provider-Abhaengigkeit
- passt zur bisherigen lokalen Teststrategie

Nachteile:

- etwas mehr Struktur als direkte Facade-Rueckgabe
- Close-Verantwortung muss klar dokumentiert werden

Bewertung:

- beste Variante fuer Version 1

### Variante C: LocalAppBootstrapResult Mit Nur Statusdaten

Beschreibung:

- Bootstrap gibt ein Result-Objekt mit Status, aber ohne echte Dependencies zurueck.

Vorteile:

- gut fuer Diagnose

Nachteile:

- nicht ausreichend, um lokale Session-Facade weiterzuverwenden
- wuerde spaeter weitere Getter oder Provider erzwingen

Bewertung:

- nicht passend als erster Bootstrap-Baustein

## Empfehlung Fuer Version 1

Empfohlen wird ein kleines Dependency-Bundle, z. B.:

- `LocalAppBootstrapResult`

Es sollte mindestens enthalten:

- `databasePath`
- `database`
- `repositoryFactory`
- `learningSessionFacade`

Die Verantwortung fuer `database.close()` muss klar bleiben:

- Bootstrap oeffnet die Datenbank.
- Aufrufer/Test schliesst die Datenbank.
- Spaeter kann optional eine `close()`-Methode am Result ergaenzt werden.

Warum diese Variante:

- testbar
- UI-neutral
- transparent fuer Lifecycle
- flexibel fuer spaetere App-Integration
- keine Vermischung mit Provider oder App-Start

## Was Noch Nicht Passieren Darf

Weiterhin nicht tun:

- keine UI-Anbindung
- keine Provider-Umstellung
- kein `main.dart`-Umbau
- kein `LearnModeController`-Umbau
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine echte Migration
- keine Migration alter `word_progress.db`
- keine automatische Nutzung im App-Start
- keine Navigation
- keine echten App-Daten veraendern
- keine DeepL-/Wortimport-Anbindung

Der Bootstrap darf nur lokale Bausteine koordinieren.

## Spaeter Sinnvolle Tests

### bootstrap_opens_database_and_builds_facade

Ziel:

- Bootstrap bildet Pfad.
- Bootstrap oeffnet Datenbank.
- Bootstrap baut `LocalRepositoryFactory`.
- Bootstrap stellt `LocalLearningSessionFacade` bereit.

Erwartung:

- Datenbank ist nutzbar.
- V1-Tabellen existieren.
- Facade ist vorhanden.
- Keine UI- oder Supabase-Abhaengigkeit.

### bootstrap_can_seed_defaults_when_requested

Ziel:

- Wenn `seedDefaults == true`, werden Seed-Kategorien und Seed-Woerter angelegt.

Erwartung:

- `Basics`, `Travel`, `Exam Practice` existieren.
- Woerter existieren.
- Seed erzeugt keinen Progress, keine Sessions und keine Review-History.

### bootstrap_without_seed_does_not_create_categories

Ziel:

- Wenn `seedDefaults == false`, bleibt die Datenbank leer von Seed-Kategorien.

Erwartung:

- keine Kategorien
- keine Woerter
- Schema existiert trotzdem

### bootstrap_uses_talvori_local_v1_database_name

Ziel:

- Bootstrap nutzt `LocalAppDatabasePath.databaseName`.

Erwartung:

- Pfad endet auf `talvori_local_v1.db`.

### bootstrap_does_not_touch_old_word_progress_database

Ziel:

- Bootstrap verwendet nicht `word_progress.db`.
- Alte `LocalWordDatabase` wird nicht initialisiert.

Erwartung:

- Bootstrap-Pfad enthaelt nicht `word_progress.db`.
- keine Nutzung von `lib/features/words/data/local_word_database.dart`

## Risiken

### Zu Fruehe App-Anbindung

Risiko:

- Bootstrap koennte versehentlich direkt in `main.dart`, Provider oder ViewModels eingebaut werden.

Gegenmassnahme:

- Bootstrap zuerst nur unter `lib/core/local_database/` implementieren.
- Nur lokale Tests.
- Keine App-Dateien aendern.

### Seed Bei Jedem Start Unkontrolliert Ausfuehren

Risiko:

- Seed koennte bei jedem App-Start laufen und Nutzerinhalte ueberschreiben.

Gegenmassnahme:

- `seedDefaults` als expliziter Boolean.
- Seed idempotent halten.
- Spaeter Settings/Marker fuer Produktionsverhalten planen.
- Nicht automatisch in App-Start integrieren.

### Vermischung Mit Alter local_word_database.dart

Risiko:

- Neue lokale DB und alte `word_progress.db` koennten verwechselt werden.

Gegenmassnahme:

- Nur `talvori_local_v1.db` verwenden.
- Keine alte Datei importieren.
- Test fuer Nicht-Nutzung von `word_progress.db`.

### Supabase Parallel Aktiv

Risiko:

- Supabase bleibt in der App aktiv und koennte spaeter mit lokalen Datenquellen konkurrieren.

Gegenmassnahme:

- Bootstrap nicht an bestehende Supabase-Provider anschliessen.
- Supabase-Entfernung separat planen.

### Datenbank-Lifecycle Und Close-Verantwortung

Risiko:

- geoeffnete Datenbank bleibt in Tests oder spaeterer App unkontrolliert offen.

Gegenmassnahme:

- `LocalAppBootstrapResult` enthaelt die Datenbank sichtbar.
- Tests schliessen Datenbank explizit.
- Spaeter optional `close()` am Result oder Bootstrap-Lifecycle planen.

## Kleinster Naechster TDD-Schritt

Der kleinste sinnvolle naechste TDD-Schritt ist:

1. `LocalAppBootstrapResult` und `LocalAppBootstrap` anlegen.
2. Nur Methode `bootstrap(...)` mit `seedDefaults = false` testen.
3. Nur Test schreiben:
   - `bootstrap_opens_database_and_builds_facade`
4. Test nutzt temporaeren Datenbankpfad.
5. Test prueft:
   - Datenbankpfad endet auf `talvori_local_v1.db`
   - Datenbank ist offen und Schema existiert
   - `LocalRepositoryFactory` existiert
   - `LocalLearningSessionFacade` existiert
   - keine Seed-Kategorien werden erwartet

Danach:

1. `bootstrap_can_seed_defaults_when_requested`
2. `bootstrap_without_seed_does_not_create_categories`
3. `bootstrap_uses_talvori_local_v1_database_name`
4. `bootstrap_does_not_touch_old_word_progress_database`

## Empfehlung

`LocalAppBootstrap` ist der richtige naechste lokale Schritt, aber weiterhin kein App-Start-Umbau.

Empfohlen:

- klein halten
- UI-neutral
- testbar ueber uebergebenen `databasesPath`
- mit explizitem `seedDefaults`-Parameter
- Rueckgabe als Dependency-Bundle
- keine Provider, keine UI, kein Supabase
