# 37 Local Database Production Open Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den aktuellen Stand der lokalen Produktionsdatenbank-Oeffnung und der `LocalRepositoryFactory` zusammen.

Der lokale Block kann jetzt produktionsnah geoeffnet und verdrahtet werden, bleibt aber weiterhin vollstaendig isoliert von UI, Provider, Supabase und bestehenden App-Flows.

## LocalDatabaseFactory

`LocalDatabaseFactory` uebernimmt den Datenbank-Lifecycle fuer eine lokale SQLite-Datenbank.

Umgesetzt ist:

- `openAtPath(String path)`

Die Factory:

- bekommt einen Pfad uebergeben
- oeffnet dort eine SQLite-Datenbank
- verwendet `LocalDatabaseSchema.version`
- aktiviert Foreign Keys in `onConfigure`
- ruft bei Neuanlage `LocalDatabaseSchema.createV1(db)` in `onCreate` auf
- erzeugt keine Repositorys
- kennt keine UI
- kennt kein Supabase
- kennt keine Provider
- veraendert keine App-Flows

Wichtig:

- Die Factory verwendet noch keinen echten App-Pfad.
- Tests nutzen temporaere Testdatenbanken.
- Die Produktions-App ist noch nicht angebunden.

## LocalRepositoryFactory

`LocalRepositoryFactory` uebernimmt den lokalen Dependency-Aufbau aus einer bereits geoeffneten `Database`.

Sie oeffnet keine Datenbank selbst.

Aus einer geoeffneten `Database` erzeugt sie:

- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`
- `LocalProgressInitializationService`
- `SrsReviewPersistenceService`
- `LocalSrsSessionService`
- `LocalSessionReadService`
- `LocalLearningSessionFacade`

Damit ist der lokale Dependency-Pfad klar getrennt:

1. `LocalDatabaseFactory` oeffnet die Datenbank.
2. `LocalRepositoryFactory` verdrahtet Repositorys und Services.
3. `LocalLearningSessionFacade` ist der UI-neutrale lokale Einstiegspunkt.

## Tests

### LocalDatabaseFactory Tests

Datei:

- `test/core/local_database/local_database_factory_test.dart`

Tests:

- `production_database_opens_and_creates_schema`
- `production_database_enables_foreign_keys`
- `production_database_can_be_opened_twice_without_losing_schema`

Abgesichert wird:

- Eine lokale SQLite-Datenbank kann ueber einen Pfad geoeffnet werden.
- Das V1-Schema wird erstellt.
- Alle V1-Tabellen existieren:
  - `categories`
  - `words`
  - `word_progress`
  - `review_history`
  - `learning_sessions`
  - `session_items`
  - `settings`
- Foreign Keys sind aktiv.
- Verwaiste Datensaetze werden abgelehnt.
- Dieselbe Datenbank kann erneut geoeffnet werden.
- Schema und Daten bleiben beim erneuten Oeffnen erhalten.
- `onCreate` baut nicht destruktiv neu auf.

### LocalRepositoryFactory Test

Datei:

- `test/core/local_database/local_repository_factory_test.dart`

Test:

- `repository_factory_creates_local_facade_dependencies`

Abgesichert wird:

- Aus einer bereits geoeffneten Datenbank kann die lokale Repository-/Service-Kette erzeugt werden.
- Kategorie und Woerter koennen ueber die erzeugten Repositorys angelegt werden.
- `LocalLearningSessionFacade.startOrResumeLearning(...)` kann mit diesen Dependencies eine lokale Session starten.
- Die Rueckgabe ist ein `LocalSessionReadState`.
- `currentWordId` ist gesetzt.
- `currentTerm` ist gesetzt.
- `currentStage` ist `S0`.
- Eine aktive Session wird erzeugt.
- Es werden keine UI-, Supabase- oder App-Flow-Abhaengigkeiten benoetigt.

## Produktionsnahe Lokale Kette

Folgende lokale Kette kann jetzt produktionsnah geoeffnet und genutzt werden:

1. Temporaerer oder spaeter echter SQLite-Pfad
2. `LocalDatabaseFactory.openAtPath(...)`
3. V1-Schema aus `LocalDatabaseSchema`
4. aktive Foreign Keys
5. `LocalRepositoryFactory`
6. lokale Repositorys
7. lokale Services
8. `LocalLearningSessionFacade`
9. `LocalSessionReadState`

Damit ist ein erster produktionsnaher Pfad vorhanden, ohne die bestehende App umzubauen.

## Weiterhin Geltende Grenzen

Weiterhin nicht umgesetzt:

- keine UI-Anbindung
- keine Provider-Anbindung
- keine Navigation
- keine Supabase-Anbindung
- keine Supabase-Entfernung
- keine App-Flow-Aenderung
- keine echten App-Daten
- kein echter App-Datenbankpfad im App-Start
- keine Seed-Daten
- kein Wortimport
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Daten
- kein `LearnModeController`-Umbau
- kein `WordUserView`-Adapter
- kein `LocalDatabaseProvider`
- kein App-Bootstrap

Die neue lokale Produktionsoeffnung ist vorbereitet, aber noch nicht in der App verwendet.

## Sinnvolle Naechste Schritte

Sinnvolle naechste Schritte:

1. Gesamten lokalen Testblock erneut ausfuehren:
   - `flutter test test/core/srs/`
   - `flutter test test/core/local_database/`
   - `flutter analyze lib/core/srs lib/core/local_database test/core/srs test/core/local_database`

2. Echten App-Datenbankpfad planen:
   - Datenbankname
   - `getDatabasesPath()`
   - Pfadbildung
   - keine App-Anbindung

3. Seed-/Importstrategie fuer lokale Kategorien und Woerter planen.

4. Bestehende alte `local_word_database.dart` separat analysieren:
   - Konfliktrisiko
   - Datenbankname
   - spaetere Ablösung oder Isolation

5. Danach einen UI-neutralen App-Bootstrap-Plan erstellen.

## Warum Weiterhin Noch Keine UI-Anbindung

Noch keine UI-Anbindung sollte erfolgen.

Gruende:

- Die Produktionsdatenbank kann technisch geoeffnet werden, aber echte lokale Daten fehlen noch.
- Seed-/Importstrategie ist noch nicht entschieden.
- Supabase laeuft weiterhin parallel und darf nicht unkontrolliert ersetzt werden.
- Bestehende ViewModels und Controller sind noch nicht auf lokale Services vorbereitet.
- Eine zu fruehe Provider-Umstellung koennte bestehende App-Flows brechen.
- Die alte `local_word_database.dart` muss vor einer App-Anbindung bewusst eingeordnet werden.
- Der lokale Block sollte erst noch einmal vollstaendig als Gesamtblock geprueft werden.

Empfehlung:

Der naechste Schritt sollte weiterhin lokal und UI-neutral bleiben: Stabilitaetscheck, Datenpfadplanung und Seed-/Importplanung vor jeder App-Anbindung.
