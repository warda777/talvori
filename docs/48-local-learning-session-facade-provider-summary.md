# 48 Local Learning Session Facade Provider Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den `localLearningSessionFacadeProvider` zusammen.

Der Provider ist ein isolierter, abgeleiteter Riverpod-Baustein. Er stellt die bereits durch `localBootstrapProvider` erzeugte `LocalLearningSessionFacade` bereit, ohne selbst eine Datenbank zu oeffnen oder Lernlogik auszufuehren.

## Aufgabe Von localLearningSessionFacadeProvider

Datei:

- `lib/core/local_database/providers/local_bootstrap_provider.dart`

Der Provider uebernimmt:

- `localBootstrapProvider` lesen
- auf dessen `LocalAppBootstrapResult` warten
- `result.learningSessionFacade` zurueckgeben

Der Provider macht nicht:

- keine Datenbank oeffnen
- keinen Bootstrap direkt ausfuehren
- keine Seed-Daten ausfuehren
- keine Session starten
- keinen Progress initialisieren
- keine Review-History schreiben
- keine UI anbinden
- kein Supabase kennen
- keine bestehende Provider-Struktur ersetzen

## Nutzung Von localBootstrapProvider

`localLearningSessionFacadeProvider` liest:

- `localBootstrapProvider.future`

Danach gibt er nur weiter:

- `result.learningSessionFacade`

Damit bleibt die Besitzregel klar:

- `localBootstrapProvider` besitzt das `LocalAppBootstrapResult`.
- `localBootstrapProvider` besitzt die geoeffnete Datenbank.
- `localBootstrapProvider` schliesst die Datenbank bei Dispose.
- `localLearningSessionFacadeProvider` ist nur ein bequemer Zugriff auf die Facade.

## Warum Keine Eigene Datenbank Geoeffnet Wird

Der Facade-Provider importiert und verwendet nicht:

- `LocalAppBootstrap`
- `LocalDatabaseFactory`
- `LocalRepositoryFactory`
- direkte SQLite-APIs

Er oeffnet deshalb keine zweite Datenbank und erzeugt keine eigene Repository-/Service-Kette.

Die lokale Datenbank wird weiterhin ausschliesslich ueber `localBootstrapProvider` aufgebaut.

## Warum Keine Seed-Daten, Sessions Oder Progress Entstehen

Der Provider gibt nur die vorhandene Facade zurueck.

Er ruft nicht auf:

- `LocalAppBootstrap.bootstrap(...)`
- `LocalSeedDataService.seedDefaults(...)`
- `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)`
- `LocalLearningSessionFacade.startOrResumeLearning(...)`
- `LocalLearningSessionFacade.submitAnswerAndReadNext(...)`
- `LocalLearningSessionFacade.completeIfFinished(...)`

Dadurch entstehen beim Lesen des Providers:

- keine Seed-Kategorien
- keine Seed-Woerter
- kein `word_progress`
- keine `learning_sessions`
- keine `review_history`

## Absicherung Der Gleichen Facade-Instanz

Der Test `local_learning_session_facade_provider_uses_existing_bootstrap_result` prueft:

- zuerst wird `localBootstrapProvider` gelesen
- daraus wird `result.learningSessionFacade` genommen
- danach wird `localLearningSessionFacadeProvider` gelesen
- beide Referenzen zeigen auf dieselbe Instanz

Damit ist abgesichert:

- Der Facade-Provider erzeugt keine neue Facade-Kette.
- Der Facade-Provider oeffnet keine zweite lokale Datenbank.
- Der Facade-Provider nutzt das bestehende Bootstrap-Result.

## Tests

Datei:

- `test/core/local_database/local_bootstrap_provider_test.dart`

Relevante Tests:

- `local_learning_session_facade_provider_exposes_facade`
- `local_learning_session_facade_provider_uses_existing_bootstrap_result`

Weiterhin relevante Bootstrap-Provider-Tests:

- `local_bootstrap_provider_creates_bootstrap_result`
- `local_bootstrap_provider_closes_database_on_dispose`
- `local_bootstrap_provider_does_not_touch_old_word_progress_database`

### local_learning_session_facade_provider_exposes_facade

Sichert ab:

- ProviderContainer nutzt einen temporaeren Datenbankpfad.
- Facade-Provider gibt eine `LocalLearningSessionFacade` zurueck.
- keine Seed-Kategorien werden angelegt.
- keine `learning_sessions` werden angelegt.
- keine `review_history` wird geschrieben.
- keine alte `word_progress.db` entsteht.
- Supabase-Initialisierung ist nicht noetig.

### local_learning_session_facade_provider_uses_existing_bootstrap_result

Sichert ab:

- Facade aus `localBootstrapProvider` und Facade aus `localLearningSessionFacadeProvider` sind dieselbe Instanz.
- Es entsteht nur die neue lokale Datenbankdatei `talvori_local_v1.db`.
- Es entsteht keine alte `word_progress.db`.
- keine Seed-Kategorien werden angelegt.
- keine `learning_sessions` werden angelegt.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an bestehenden App-Flows
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine echte App-Datenmigration
- keine Nutzung alter lokaler Daten
- keine Nutzung von `word_progress.db`
- keine automatische Session-Erzeugung
- keine automatische Progress-Initialisierung
- keine Seed-Ausfuehrung ueber den Facade-Provider

Der Provider ist ein lokaler Komfortzugriff, aber noch keine App-Integration.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Lokalen Gesamtblock regelmaessig pruefen:
   - `flutter test test/core/srs/`
   - `flutter test test/core/local_database/`
   - `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`

2. Einen neuen lokalen Lerncontroller planen:
   - liest `localLearningSessionFacadeProvider`
   - kennt keine Supabase-Repositorys
   - ersetzt `LearnModeController` nicht
   - startet Sessions nur durch explizite Methoden

3. Einen UI-neutralen State fuer diesen Controller planen:
   - angelehnt an `LocalSessionReadState`
   - keine Widgets
   - keine Navigation
   - keine UI-Texte als harte Kopplung

4. Vor jeder bestehenden App-Anbindung erneut Risikoanalyse und Tests ausfuehren.

## Warum Weiterhin Keine Bestehende App-Anbindung

Noch keine bestehende App-Anbindung sollte erfolgen.

Gruende:

- Der Facade-Provider ist stabil, aber nur ein lokaler Bereitstellungsbaustein.
- Bestehende App-Flows verwenden weiterhin Supabase und alte SRS-Logik.
- `main.dart` ist weiterhin fuer App-Start und Supabase-Initialisierung verantwortlich.
- `word_providers.dart` ist ein zentraler bestehender Provider-Knoten.
- `learn_mode_controller.dart` ist gross und stark mit alter Queue-, Timer-, UI- und Supabase-Logik gekoppelt.
- Eine direkte Anbindung koennte alte und neue Datenquellen vermischen.

Empfehlung:

- Als naechstes einen neuen isolierten lokalen Lerncontroller planen.
- Bestehende App-Dateien erst anfassen, wenn dieser lokale Controller getestet ist.
