# 46 Local Bootstrap Provider Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen Bootstrap-Provider zusammen.

Der Provider ist ein isolierter Riverpod-Baustein fuer die lokale Offline-first-Schicht. Er stellt `LocalAppBootstrapResult` bereit, ohne bestehende UI, Supabase, `main.dart`, `word_providers.dart` oder App-Flows zu beruehren.

## Aufgabe Des Lokalen Bootstrap-Providers

Datei:

- `lib/core/local_database/providers/local_bootstrap_provider.dart`

Der Provider uebernimmt:

- `LocalAppBootstrap.bootstrap(...)` aufrufen
- `LocalAppBootstrapResult` asynchron bereitstellen
- `LocalLearningSessionFacade` indirekt ueber das Result verfuegbar machen
- geoeffnete SQLite-Datenbank bei Dispose schliessen

Der Provider macht nicht:

- keine UI-Anbindung
- keine Navigation
- keine Supabase-Nutzung
- keine bestehende Provider-Ersetzung
- keine Session automatisch starten
- keinen Progress automatisch initialisieren
- keine alte `local_word_database.dart` verwenden

## Ueberschreibbarer databasesPath

Der Provider nutzt einen separaten Pfad-Provider:

- `localBootstrapDatabasesPathProvider`

Dieser Provider wirft standardmaessig einen Fehler, wenn er nicht ueberschrieben wird.

Grund:

- Der lokale Bootstrap-Provider soll im Test keinen echten App-Datenbankpfad verwenden.
- Der echte App-Pfad soll spaeter bewusst und kontrolliert angeschlossen werden.
- Tests koennen temporaere Datenbankpfade ueber Provider-Overrides setzen.

Teststrategie:

- `ProviderContainer` ueberschreibt `localBootstrapDatabasesPathProvider` mit einem temporaeren Pfad.
- `localBootstrapProvider` verwendet dann diesen Pfad.
- Kein echter App-Pfad wird aufgerufen.

## Warum seedDefaults Aktuell false Ist

`localBootstrapProvider` ruft `LocalAppBootstrap.bootstrap(...)` aktuell mit:

- `seedDefaults: false`

Begruendung:

- sicherer Standard
- keine unerwarteten Demo-Daten in einer echten lokalen Datenbank
- keine unkontrollierte Seed-Ausfuehrung bei spaeterem App-Start
- klare Trennung zwischen Bootstrap und Datenbefuellung

Seed-Daten koennen weiterhin in separaten Tests oder spaeter in einem expliziten Debug-/Dev-Pfad verwendet werden.

[PRÜFEN] Vor echter App-Anbindung muss entschieden werden, ob es einen separaten Debug-Provider oder eine klare Dev-Flag-Strategie fuer Seed geben soll.

## database.close() Bei Dispose

Der Provider registriert nach erfolgreichem Bootstrap:

- `ref.onDispose(...)`

Dabei wird die geoeffnete Datenbank geschlossen:

- `result.database.close()`

Der Test `local_bootstrap_provider_closes_database_on_dispose` sichert ab:

- Datenbank ist vor Dispose nutzbar.
- Datenbank ist vor Dispose offen.
- Nach `ProviderContainer.dispose()` ist die Datenbank geschlossen.
- Ein weiterer Zugriff auf die geschlossene Datenbank-Instanz schlaegt fehl.

Damit ist der Provider aktuell der Besitzer des geoeffneten Bootstrap-Results und verantwortlich fuer den Datenbank-Lifecycle.

## Schutz Gegen word_progress.db

Der lokale Provider verwendet indirekt:

- `LocalAppDatabasePath.databaseName`
- `talvori_local_v1.db`

Abgesichert wird:

- `result.databasePath` endet auf `talvori_local_v1.db`
- `result.databasePath` enthaelt nicht `word_progress.db`
- im temporaeren Datenbankpfad entsteht keine Datei `word_progress.db`

Die alte `LocalWordDatabase` wird nicht benoetigt und nicht initialisiert.

## Tests

Datei:

- `test/core/local_database/local_bootstrap_provider_test.dart`

Tests:

- `local_bootstrap_provider_creates_bootstrap_result`
- `local_bootstrap_provider_closes_database_on_dispose`
- `local_bootstrap_provider_does_not_touch_old_word_progress_database`

### local_bootstrap_provider_creates_bootstrap_result

Sichert ab:

- Provider erzeugt ein `LocalAppBootstrapResult`.
- `databasePath` endet auf `talvori_local_v1.db`.
- `repositoryFactory` ist vorhanden.
- `learningSessionFacade` ist vorhanden.
- Bei `seedDefaults = false` werden keine Seed-Kategorien angelegt.
- Supabase-Initialisierung ist nicht noetig.

### local_bootstrap_provider_closes_database_on_dispose

Sichert ab:

- Datenbank ist nach Provider-Erzeugung nutzbar.
- Datenbank ist vor Dispose offen.
- `ProviderContainer.dispose()` schliesst die Datenbank.
- Zugriff nach Dispose schlaegt fehl.

### local_bootstrap_provider_does_not_touch_old_word_progress_database

Sichert ab:

- Provider verwendet die neue lokale Datenbank `talvori_local_v1.db`.
- Provider-Pfad enthaelt nicht `word_progress.db`.
- Im temporaeren Testpfad entsteht keine alte `word_progress.db`.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Provider-Anbindung in bestehende App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine echte App-Datenmigration
- keine Nutzung alter lokaler Daten
- keine Nutzung von `word_progress.db`
- keine automatische Session-Erzeugung
- keine automatische Progress-Initialisierung
- keine Seed-Ausfuehrung im Provider

Der Provider ist ein lokaler Bereitstellungsbaustein, aber noch keine App-Integration.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Lokalen Gesamtblock weiter stabil halten:
   - `flutter test test/core/srs/`
   - `flutter test test/core/local_database/`
   - `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`

2. Einen abgeleiteten Facade-Provider planen:
   - liest `localBootstrapProvider`
   - stellt nur `LocalLearningSessionFacade` bereit
   - bleibt isoliert und UI-neutral

3. Einen neuen lokalen Lerncontroller planen:
   - nutzt `LocalLearningSessionFacade`
   - kennt keine Supabase-Repositorys
   - ersetzt den alten `LearnModeController` noch nicht

4. Spaeter Lifecycle-Fragen klaeren:
   - bleibt `ref.onDispose(...)` ausreichend?
   - braucht `LocalAppBootstrapResult` eine eigene `close()`-Methode?
   - wer besitzt die lokale DB im echten App-Start?

5. Seed-Strategie fuer echte App-Nutzung separat entscheiden.

## Warum Weiterhin Keine Bestehende App-Anbindung

Noch keine bestehende App-Anbindung sollte erfolgen.

Gruende:

- Der Provider ist technisch stabil, aber noch nicht in den echten App-Lifecycle eingeordnet.
- `main.dart` initialisiert weiterhin Supabase und App-Startlogik.
- `word_providers.dart` ist ein zentraler bestehender Provider-Knoten.
- `learn_mode_controller.dart` enthaelt alte SRS-, Queue-, Timer- und Supabase-Logik.
- Eine direkte Umstellung koennte alte und neue Datenquellen vermischen.
- Seed- und Launch-Datenstrategie sind noch nicht final.

Empfehlung:

- Erst einen isolierten Facade-Provider und danach einen neuen lokalen Lerncontroller planen.
- Bestehende App-Dateien erst anfassen, wenn die lokale Controller-Schicht getestet ist.
