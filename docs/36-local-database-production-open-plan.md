# 36 Local Database Production Open Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant die Produktionsdatenbank-Oeffnung fuer die lokale SQLite-Schicht.

Ziel ist, die bereits getestete lokale SRS-/SQLite-/Repository-/Read-State-/Facade-Schicht mit einer echten lokalen App-Datenbank oeffnen zu koennen, ohne sie bereits an UI, Provider, bestehende App-Flows oder Supabase-Ersatzlogik anzubinden.

Die Produktionsdatenbank-Oeffnung soll:

- eine lokale SQLite-Datenbank in der echten App-Umgebung oeffnen
- das Schema erstellen oder spaeter migrieren
- Foreign Keys aktivieren
- `LocalDatabaseSchema` als zentrale Schemaquelle verwenden
- Repositorys und lokale Services aus einer geoeffneten Datenbank bauen koennen
- weiterhin vollstaendig UI-neutral bleiben
- Supabase noch nicht entfernen

Nicht Ziel dieses Schritts:

- keine echte App-Anbindung
- keine Provider-Umstellung
- keine UI-Aenderung
- kein `LearnModeController`-Umbau
- keine Migration bestehender Supabase-Daten
- kein Import echter Wortdaten

## Sinnvolle Komponenten

### LocalDatabaseFactory

Empfohlene Aufgabe:

- oeffnet die echte lokale SQLite-Datenbank
- kennt Datenbankname, Version und Pfad
- ruft `openDatabase(...)` auf
- setzt `onConfigure`, `onCreate` und `onUpgrade`
- aktiviert Foreign Keys
- verwendet `LocalDatabaseSchema.createV1(...)`

Vorteil:

- klare technische Verantwortung fuer das Oeffnen der Datenbank
- gut isoliert testbar
- keine Repository- oder Service-Erzeugung vermischt mit Datenbank-Lifecycle

### LocalRepositoryFactory

Empfohlene Aufgabe:

- nimmt eine bereits geoeffnete `Database`
- erzeugt daraus Repositorys und lokale Services
- baut als obersten lokalen Einstiegspunkt eine `LocalLearningSessionFacade`

Vorteil:

- trennt Datenbank-Lifecycle von Dependency-Aufbau
- spaeter leichter in Provider oder Dependency Injection einzubinden
- kann in Tests mit In-Memory-Datenbank verwendet werden

### LocalDatabaseBootstrap

Moegliche spaetere Aufgabe:

- koordiniert `LocalDatabaseFactory` und `LocalRepositoryFactory`
- liefert ein kleines Bundle lokaler Abhaengigkeiten
- koennte spaeter App-Start, Diagnose oder Seed-Daten vorbereiten

Bewertung:

- Fuer den ersten TDD-Schritt noch nicht noetig.
- Kann spaeter sinnvoll werden, wenn Produktionsdatenbank, Settings, Seed-Daten und Debug-Diagnose zusammenkommen.

### LocalDatabaseProvider

Moegliche spaetere Aufgabe:

- stellt Datenbank oder Facade app-weit bereit

Bewertung:

- Noch nicht fuer diesen Schritt verwenden.
- Ein Provider waere bereits naeher an App-Anbindung und sollte erst nach Produktionsdatenbank-Tests geplant werden.

## Empfehlung Fuer Version 1

Empfohlen wird eine zweistufige Struktur:

1. `LocalDatabaseFactory`
   - oeffnet und konfiguriert die lokale SQLite-Datenbank

2. `LocalRepositoryFactory`
   - baut Repositorys und lokale Services aus einer geoeffneten Datenbank

Noch nicht empfohlen:

- kein `LocalDatabaseProvider`
- kein App-Start-Bootstrap
- keine direkte Integration in bestehende ViewModels

Diese Trennung haelt den naechsten Schritt klein und testbar.

## Datenbankoeffnung

### Datenbankname

Vorschlag:

- `talvori_local_v1.db`

Begruendung:

- klar als neue lokale Offline-first-Datenbank erkennbar
- vermeidet direkte Kollision mit moeglichen alten Datenbanknamen
- Version ist im Namen sichtbar, ohne Schema-Versionierung zu ersetzen

[PRUEFEN]

- Ob die bestehende `lib/features/words/data/local_word_database.dart` einen Datenbanknamen nutzt, der mit dem neuen Namen kollidieren koennte.
- Ob alte lokale Daten bewusst getrennt bleiben sollen.

### Pfad

Vorschlag:

- `getDatabasesPath()`
- danach `join(databasePath, 'talvori_local_v1.db')`

Begruendung:

- entspricht `sqflite`-Standard fuer mobile Plattformen
- funktioniert auf iOS und Android
- macOS/Desktop-Testpfade koennen im Test ueber `sqflite_common_ffi` separat behandelt werden

Wichtig:

- Keine hart codierten absoluten Pfade.
- Keine Windows-spezifischen Annahmen.
- Fuer Tests weiterhin In-Memory oder temporaere Testdatenbanken verwenden.

### Version

Version:

- `LocalDatabaseSchema.version`
- aktuell `1`

Regel:

- Die Datenbank-Factory soll nicht selbst eine abweichende Version definieren.
- `LocalDatabaseSchema` bleibt die zentrale Quelle fuer die Schema-Version.

### onConfigure

Aufgabe:

- Foreign Keys aktivieren.

Geplante Aktion:

- `PRAGMA foreign_keys = ON`

Warum:

- `sqflite` aktiviert Foreign Keys nicht verlaesslich implizit fuer jede Verbindung.
- Die Tests pruefen bereits Foreign-Key-Verhalten in In-Memory-Datenbanken.
- Produktionsdatenbank muss dieselbe Integritaet erzwingen.

### onCreate

Aufgabe:

- Schema fuer Version 1 erstellen.

Geplante Aktion:

- `LocalDatabaseSchema.createV1(db)`

Wichtig:

- Keine doppelte SQL-Definition in der Factory.
- Kein separates Produktionsschema.
- Tests und Produktionsoeffnung verwenden dieselbe Schemaquelle.

### onUpgrade

Fuer Version 1:

- noch keine echte Migration noetig
- aber `onUpgrade` sollte als bewusster Einstiegspunkt geplant werden

Version-1-Verhalten:

- Wenn `oldVersion < 1`, create V1 ist bereits `onCreate`.
- Fuer spaetere Versionen sollen Migrationen sequenziell laufen.

[PRUEFEN]

- Ob fuer Version 1 ein expliziter Fehler bei unerwarteten Versionen sinnvoll ist.
- Wie Downgrades behandelt werden sollen. Fuer V1 sollte kein automatisches Loeschen oder Neuaufbauen stattfinden.

### onOpen

Aufgabe:

- optional erneut Foreign Keys aktivieren oder pruefen

Empfehlung:

- Foreign Keys mindestens in `onConfigure` aktivieren.
- Optional im Test pruefen, dass `PRAGMA foreign_keys` nach dem Oeffnen aktiv ist.

## Aus Der Geoeffneten DB Zu Bauende Bausteine

Aus einer geoeffneten `Database` sollen spaeter gebaut werden:

Repositorys:

- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `ReviewHistoryRepository`
- `LearningSessionRepository`

Services:

- `LocalProgressInitializationService`
- `SrsReviewPersistenceService`
- `LocalSrsSessionService`
- `LocalSessionReadService`
- `LocalLearningSessionFacade`

Abhaengigkeitskette:

1. `Database`
2. Repositorys
3. lokale Persistence-/Session-/Read-Services
4. `LocalLearningSessionFacade`

Die reine SRS-Engine bleibt weiterhin unabhaengig:

- keine SQLite-Abhaengigkeit
- keine Supabase-Abhaengigkeit
- keine UI-Abhaengigkeit
- keine Persistenzlogik

## Was Noch Nicht Passieren Darf

Dieser Schritt darf nicht:

- UI anbinden
- Provider umstellen
- `LearnModeController` veraendern
- bestehende App-Flows aendern
- Supabase entfernen
- Supabase-Repositories ersetzen
- echte Daten importieren
- alte lokale Daten migrieren
- Supabase-Fortschritt migrieren
- automatische Seed-Daten in die Produktionsdatenbank schreiben
- App-Navigation veraendern
- `WordUserView`-Adapter einfuehren

Die Produktionsdatenbank-Oeffnung soll zuerst isoliert testbar sein.

## Erste Tests

Die ersten Tests sollten weiterhin unter `test/core/local_database/` liegen.

### production_database_opens_and_creates_schema

Ziel:

- Eine echte sqflite-Datenbank wird ueber die neue Factory geoeffnet.
- Alle V1-Tabellen existieren.
- `LocalDatabaseSchema.version` wird verwendet.

Erwartung:

- Tabellen existieren:
  - `categories`
  - `words`
  - `word_progress`
  - `review_history`
  - `learning_sessions`
  - `session_items`
  - `settings`

### production_database_enables_foreign_keys

Ziel:

- Die Produktions-Open-Logik aktiviert Foreign Keys.

Erwartung:

- `PRAGMA foreign_keys` liefert aktiv.
- Ein verwaister Datensatz, z. B. ein `words.category_id` ohne Kategorie, wird abgelehnt.

### repository_factory_creates_local_facade_dependencies

Ziel:

- Aus einer geoeffneten Datenbank kann die lokale Dependency-Kette gebaut werden.

Erwartung:

- Repositorys werden erstellt.
- `LocalLearningSessionFacade` wird erstellt.
- Es wird keine UI-, Provider- oder Supabase-Abhaengigkeit benoetigt.

### production_database_can_be_opened_twice_without_losing_schema

Ziel:

- Mehrfaches Oeffnen derselben lokalen Datenbank bleibt stabil.

Erwartung:

- Schema bleibt vorhanden.
- Bestehende Testdaten bleiben erhalten.
- `onCreate` laeuft nicht erneut destruktiv.
- Foreign Keys bleiben aktiv.

## Bewusst Noch Nicht Zu Schreibende Tests

Noch nicht schreiben:

- UI-/Widget-Tests
- Provider-Tests
- App-Start-Integrationstests
- Supabase-Entfernungstests
- echte Migrationstests von Supabase
- Seed-/Importtests fuer echte Wortdaten
- Backup-/Exporttests
- Tests fuer alte `local_word_database.dart`-Migration

Diese Themen kommen erst nach stabiler Produktionsdatenbank-Oeffnung.

## Risiken

### Konflikt Mit Alter local_word_database.dart

Es existiert bereits:

- `lib/features/words/data/local_word_database.dart`

Risiko:

- alte lokale Wortdatenbank und neue Offline-first-Datenbank koennten parallel existieren
- aehnliche Namen koennten Verwechslungen erzeugen
- spaetere App-Anbindung koennte versehentlich alte und neue Datenquellen mischen

Gegenmassnahme:

- neuen Datenbanknamen klar abgrenzen
- neue Produktionsdatenbank unter `lib/core/local_database/` halten
- alte Datei vorerst nicht aendern
- spaeter eigene Impact-Analyse fuer diese alte Datenbank erstellen

### Pfad- Und Plattform-Unterschiede

Risiko:

- iOS, Android, macOS-Tests und FFI-Tests nutzen unterschiedliche Pfadlogik
- Tests duerfen keine echten App-Datenbanken verschmutzen

Gegenmassnahme:

- Factory fuer Produktionspfad klein halten
- Tests mit temporaeren Pfaden oder FFI-Datenbankpfaden schreiben
- keine absoluten Pfade hardcoden

### Migrationen Und Schema-Versionierung

Risiko:

- Version 1 ist einfach, aber spaetere Versionen brauchen saubere Migrationen
- fehlerhafte Migrationen koennen lokale Lernfortschritte beschaedigen

Gegenmassnahme:

- `LocalDatabaseSchema.version` als zentrale Quelle verwenden
- Migrationen spaeter schrittweise und getestet ergaenzen
- keine destruktive Downgrade- oder Reset-Strategie in V1 einbauen

### Zu Fruehe App-Anbindung

Risiko:

- UI oder Provider koennten auf eine Produktionsdatenbank zugreifen, bevor Seed-Daten, Import, Settings und Fehlerbehandlung geklaert sind

Gegenmassnahme:

- keine Provider-Anbindung in diesem Schritt
- keine App-Flow-Aenderung
- erst isolierte Produktionsdatenbank-Tests

### Supabase Bleibt Parallel Aktiv

Risiko:

- spaeter koennten lokale und Supabase-Daten auseinanderlaufen

Gegenmassnahme:

- Supabase vorerst nicht entfernen
- keine Mischlogik einfuehren
- spaetere Umschaltstrategie separat planen

### Leere Produktionsdatenbank

Risiko:

- Eine korrekt geoeffnete lokale Datenbank enthaelt noch keine echten Woerter oder Kategorien.

Gegenmassnahme:

- Produktionsdatenbank-Oeffnung nicht mit Datenimport vermischen
- Seed-/Importstrategie separat planen
- Tests nur Schema, Foreign Keys und Dependency-Aufbau pruefen

## Kleinster Erster TDD-Schritt

Der kleinste sinnvolle erste TDD-Schritt ist:

1. Eine `LocalDatabaseFactory` planen/implementieren, die eine Datenbank ueber einen uebergebenen Pfad oder Namen oeffnen kann.
2. Nur den Test `production_database_opens_and_creates_schema` schreiben.
3. In diesem Test mit einem temporaeren Testpfad arbeiten, nicht mit echten App-Daten.
4. Pruefen, dass alle V1-Tabellen nach dem Oeffnen existieren.

Danach folgen:

1. `production_database_enables_foreign_keys`
2. `production_database_can_be_opened_twice_without_losing_schema`
3. `repository_factory_creates_local_facade_dependencies`

## Empfehlung

Die Produktionsdatenbank-Oeffnung ist der richtige naechste Schritt, aber sie sollte weiterhin komplett isoliert bleiben.

Empfohlene Reihenfolge:

1. `LocalDatabaseFactory` mit Tests.
2. Foreign-Key-Test fuer Produktions-Open-Logik.
3. Reopen-Test gegen Schema-Verlust.
4. `LocalRepositoryFactory` mit Facade-Dependency-Test.
5. Danach erst Seed-/Importstrategie planen.
6. Erst danach eine app-nahe, aber weiterhin vorsichtige Anbindungsplanung.
