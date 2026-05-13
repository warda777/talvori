# 45 Local Bootstrap Provider Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant einen isolierten lokalen Bootstrap-/Services-Provider.

Der Provider soll die lokale Offline-first-Schicht spaeter fuer App-nahe Controller bereitstellen, ohne bestehende UI, Supabase-Provider, `main.dart`, `word_providers.dart` oder App-Flows zu veraendern.

Ziele:

- `LocalAppBootstrap` einmalig erzeugen
- `LocalAppBootstrapResult` halten
- `LocalLearningSessionFacade` bereitstellen
- `database.close()` bei Dispose sicherstellen
- Supabase-Provider nicht beruehren
- alte `local_word_database.dart` nicht verwenden

## 1. Aufgabe Des Providers

Der Provider soll ein lokaler Composition-Baustein sein.

Er soll:

- den App-Datenbankpfad erhalten oder spaeter ueber `getDatabasesPath()` beziehen
- `LocalAppBootstrap.bootstrap(...)` aufrufen
- das erzeugte `LocalAppBootstrapResult` halten
- aus dem Result die `LocalLearningSessionFacade` verfuegbar machen
- beim Dispose die geoeffnete SQLite-Datenbank schliessen

Er soll nicht:

- eine Session automatisch starten
- Progress automatisch initialisieren
- alte Provider ersetzen
- Supabase initialisieren oder lesen
- UI-State verwalten
- Navigation ausloesen
- `LearnModeController` kennen
- `WordUserView` kennen

## 2. Ablageort

### Variante A: lib/core/local_database/providers/

Beschreibung:

- neuer Ordner fuer lokale Riverpod-Provider im lokalen Datenbankbereich

Vorteile:

- klar isoliert von `features/words`
- keine Vermischung mit bestehenden `word_providers.dart`
- nah an `LocalAppBootstrap`
- testbar als lokaler Block

Nachteile:

- `core/local_database` bekommt Riverpod-Abhaengigkeit, falls bisher vermieden

Bewertung:

- beste Variante, wenn der Provider wirklich lokal und isoliert bleibt.

### Variante B: lib/core/local_database/

Beschreibung:

- Provider-Datei direkt neben Bootstrap und Factories

Vorteile:

- kurze Pfade
- sichtbar beim Bootstrap-Code

Nachteile:

- vermischt Kernbausteine und Provider-Komposition
- kann bei wachsender Struktur unuebersichtlich werden

Bewertung:

- moeglich, aber weniger sauber als eigener `providers/`-Ordner.

### Variante C: Separater App-Composition-Bereich

Moegliche Pfade:

- `lib/core/app_composition/`
- `lib/app/bootstrap/`

Vorteile:

- trennt lokale Datenbanklogik von App-Komposition
- spaeter geeignet fuer mehrere globale Services

Nachteile:

- neuer Architektur-Bereich
- fuer den naechsten kleinen Schritt eventuell zu gross
- koennte wie eine App-Anbindung wirken, obwohl noch keine echte Integration gewollt ist

Bewertung:

- spaeter interessant, aber fuer den ersten isolierten Schritt nicht noetig.

## Empfehlung Fuer Version 1

Empfohlen:

- `lib/core/local_database/providers/`

Begruendung:

- lokal genug fuer den aktuellen Block
- getrennt von bestehenden Feature-Providern
- kein Eingriff in `word_providers.dart`
- spaeter leicht zu verschieben, falls ein App-Composition-Bereich entsteht

## 3. Geeignete Riverpod-Variante

### FutureProvider

Beschreibung:

- Provider erzeugt asynchron ein `LocalAppBootstrapResult`.
- `ref.onDispose(...)` schliesst die Datenbank.

Vorteile:

- passt zu async Bootstrap
- Riverpod verwaltet Loading/Error-State
- einfache Tests mit ProviderContainer
- keine UI-Annahme

Nachteile:

- Aufrufer muessen mit `AsyncValue` umgehen
- darf nicht zu frueh in bestehende UI-Flows verdrahtet werden

Bewertung:

- beste Variante fuer Version 1.

### Provider Mit Async Initialisierung

Beschreibung:

- synchroner Provider stellt eine Service-Klasse bereit, die intern async initialisiert.

Vorteile:

- weniger `AsyncValue` an den Lesestellen

Nachteile:

- Lifecycle und Fehlerzustand werden undeutlicher
- Tests werden komplexer
- Gefahr, halb initialisierte Services bereitzustellen

Bewertung:

- nicht empfohlen fuer den ersten Schritt.

### Eigene Service-Klasse Ohne Provider

Beschreibung:

- nur eine Klasse kapselt Bootstrap und Close.

Vorteile:

- komplett Riverpod-neutral
- gut als reiner Unit-Baustein

Nachteile:

- beantwortet noch nicht, wie App-nahe Controller die Facade spaeter erhalten
- Lifecycle muss separat geregelt werden

Bewertung:

- moeglich als Hilfsklasse, aber nicht ausreichend als App-naher Provider-Plan.

## Empfehlung

Fuer Version 1 sollte ein isolierter `FutureProvider<LocalAppBootstrapResult>` geplant werden.

Zusaetzlich kann ein abgeleiteter Provider geplant werden:

- `localLearningSessionFacadeProvider`

Dieser wuerde nur aus dem Bootstrap-Result die `LocalLearningSessionFacade` lesen.

Wichtig:

- Beide Provider bleiben neu und lokal.
- Sie ersetzen keinen bestehenden Supabase-Provider.
- Sie werden noch nicht in UI oder bestehenden App-Flows verwendet.

## 4. Erlaubte Und Nicht Erlaubte Abhaengigkeiten

### Erlaubt

Erlaubte Abhaengigkeiten:

- `LocalAppBootstrap`
- `LocalAppBootstrapResult`
- `LocalAppDatabasePath`
- `LocalDatabaseFactory`
- `LocalRepositoryFactory`
- `LocalLearningSessionFacade`
- spaeter `getDatabasesPath()`
- `DateTime` fuer Seed-Zeitpunkt
- Riverpod, falls als Provider umgesetzt

### Nicht Erlaubt

Nicht erlaubte Abhaengigkeiten:

- Supabase
- `SupabaseWordRepository`
- `supabaseWordRepositoryProvider`
- UI-Widgets
- Navigation
- `BuildContext`
- `LearnModeController`
- `WordUserView`
- alte `local_word_database.dart`
- `word_progress.db`
- bestehende Word-/Learn-Feature-Provider

## 5. database.close()

Die lokale SQLite-Datenbank muss geschlossen werden, wenn der Provider disposed wird.

### Variante A: ref.onDispose(...)

Beschreibung:

- Der Provider registriert nach erfolgreichem Bootstrap:
  - `ref.onDispose(() => result.database.close())`

Vorteile:

- klare Riverpod-Lifecycle-Verantwortung
- kein API-Umbau an `LocalAppBootstrapResult`
- gut testbar mit `ProviderContainer.dispose()`

Nachteile:

- nur passend, wenn der Besitzer wirklich ein Riverpod-Provider ist

Bewertung:

- empfohlen fuer Version 1.

### Variante B: close()-Methode Am Result

Beschreibung:

- `LocalAppBootstrapResult` bekommt spaeter eine `close()`-Methode.

Vorteile:

- kapselt Close-Verhalten
- auch ausserhalb von Riverpod nutzbar

Nachteile:

- aendert bestehendes Result-API
- fuer den ersten Provider-Test nicht zwingend noetig

Bewertung:

- spaeter moeglich, aber nicht erster Schritt.

## Empfehlung Fuer Version 1

Fuer den ersten Provider-Schritt:

- `ref.onDispose(...)` verwenden
- `LocalAppBootstrapResult` unveraendert lassen
- Close-Verhalten mit ProviderContainer-Test absichern

[PRÜFEN] Falls spaeter mehrere Besitzer oder manuelle Bootstrap-Nutzung entstehen, kann eine `close()`-Methode am Result ergaenzt werden.

## 6. Seed-Verhalten

Seed darf nicht unkontrolliert bei jedem App-Start laufen.

### seedDefaults = false Als Sicherer Standard

Vorteile:

- keine unerwarteten Daten
- keine App-Start-Nebenwirkungen
- sicher fuer echte lokale Datenbank
- vermeidet Launch-Daten-Verwirrung

Bewertung:

- empfohlener Standard.

### seedDefaults = true Nur Fuer Debug/Test

Vorteile:

- lokale Demo-Daten schnell verfuegbar
- gut fuer Tests und Entwicklungsmodus

Risiken:

- bei echtem App-Start koennen Demo-Daten unerwartet erscheinen
- wiederholtes Seeden ist zwar idempotent, aber trotzdem fachlich nicht immer gewollt

Bewertung:

- nur explizit fuer Tests, Debug oder spaetere Dev-Flag-Nutzung.

## Empfehlung

Der Provider sollte fuer Version 1 standardmaessig mit `seedDefaults = false` starten.

Seed kann in Tests oder spaeter in einem klar benannten Debug-Provider aktiviert werden.

[PRÜFEN] Vor echter App-Anbindung muss entschieden werden, ob und wann Seed in Debug-Builds automatisch laufen darf.

## 7. Erste Tests

Zuerst sinnvolle Tests:

- `local_bootstrap_provider_creates_bootstrap_result`
- `local_bootstrap_provider_exposes_learning_session_facade`
- `local_bootstrap_provider_closes_database_on_dispose`
- `local_bootstrap_provider_does_not_use_supabase`
- `local_bootstrap_provider_does_not_touch_old_word_progress_database`

### local_bootstrap_provider_creates_bootstrap_result

Soll pruefen:

- Provider erzeugt ein `LocalAppBootstrapResult`.
- Result enthaelt `databasePath`.
- Result enthaelt eine geoeffnete `database`.
- Result enthaelt `repositoryFactory`.

### local_bootstrap_provider_exposes_learning_session_facade

Soll pruefen:

- `LocalLearningSessionFacade` ist ueber das Bootstrap-Result verfuegbar.
- Optionaler abgeleiteter Facade-Provider kann die Facade aus dem Result lesen.

### local_bootstrap_provider_closes_database_on_dispose

Soll pruefen:

- ProviderContainer erzeugt Result.
- Nach `container.dispose()` ist die Datenbank geschlossen.
- Weitere Datenbankzugriffe schlagen kontrolliert fehl oder zeigen, dass Close ausgefuehrt wurde.

### local_bootstrap_provider_does_not_use_supabase

Soll pruefen:

- Provider importiert keine Supabase-Klassen.
- Provider benoetigt keine Supabase-Initialisierung.
- Test kann ohne Supabase laufen.

Hinweis:

- Dieser Test ist eventuell eher ein Analyzer-/Import-Vertrauenspunkt als ein klassischer Runtime-Test.

### local_bootstrap_provider_does_not_touch_old_word_progress_database

Soll pruefen:

- Provider nutzt `talvori_local_v1.db`.
- Im Testpfad entsteht keine `word_progress.db`.
- alte `LocalWordDatabase` wird nicht benoetigt.

## 8. Risiken

### Provider Zu Frueh In Bestehende App-Flows Eingebunden

Risiko:

- alte und neue Datenquellen werden vermischt
- UI zeigt Supabase-Daten, waehrend lokale Session lokale Daten nutzt

Gegenmassnahme:

- Provider zunaechst nur in Tests verwenden
- keine bestehende Feature-Datei anfassen

### Seed Laeuft Ungewollt

Risiko:

- Demo-Daten erscheinen in echter lokaler DB
- spaetere echte Daten werden mit Seed-Daten vermischt

Gegenmassnahme:

- `seedDefaults = false` als Standard
- Seed nur explizit aktivieren
- Seed-Verhalten testen

### Datenbank Bleibt Offen

Risiko:

- Ressourcenleck
- Tests beeinflussen sich gegenseitig
- App-Lifecycle unklar

Gegenmassnahme:

- `ref.onDispose(...)` mit Test absichern
- eindeutige Besitzregel fuer `LocalAppBootstrapResult`

### Supabase Und Lokale Datenquelle Werden Vermischt

Risiko:

- doppelte Wahrheit fuer Kategorien, Woerter und Progress
- schwer nachvollziehbare Bugs

Gegenmassnahme:

- keine Supabase-Imports im lokalen Provider
- kein Umbau von `word_providers.dart`
- spaeter klare Adapterstrategie

### Alter LocalWordDatabase-Pfad Wird Beruehrt

Risiko:

- neue Engine vermischt sich mit alter A-SRS-Mirror-Datenbank
- Migration wird unklar

Gegenmassnahme:

- `talvori_local_v1.db` weiter pruefen
- Test gegen `word_progress.db` beibehalten

## 9. Kleinster Naechster TDD-Schritt

Der kleinste naechste TDD-Schritt sollte sein:

1. Neue Testdatei fuer den lokalen Bootstrap-Provider planen/erstellen.
2. Nur einen Test schreiben:
   - `local_bootstrap_provider_creates_bootstrap_result`
3. Provider isoliert unter `lib/core/local_database/providers/` erstellen.
4. Test verwendet temporaeren Datenbankpfad.
5. Provider bootstrapped mit `seedDefaults = false`.
6. Test prueft nur:
   - `LocalAppBootstrapResult` existiert
   - `databasePath` endet auf `talvori_local_v1.db`
   - `repositoryFactory` existiert
   - `learningSessionFacade` existiert
7. Keine UI, kein Supabase, kein `main.dart`, kein `word_providers.dart`.

Danach separat:

- Facade-Provider-Test
- Dispose-/Close-Test
- Alter-DB-Sicherheitstest
- optional Debug-Seed-Test

## Empfehlung

Fuer Version 1 sollte ein isolierter Riverpod-`FutureProvider` im lokalen Datenbankbereich geplant werden.

Der Provider bleibt ein technischer Bereitstellungsbaustein. Er ist noch keine App-Anbindung.

Erst wenn dieser Provider getestet ist, sollte ein neuer lokaler Lerncontroller gegen `LocalLearningSessionFacade` geplant werden.
