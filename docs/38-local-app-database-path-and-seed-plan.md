# 38 Local App Database Path And Seed Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den naechsten lokalen, UI-neutralen Schritt fuer Talvori:

- echten App-Datenbankpfad fuer die neue lokale SQLite-Schicht festlegen
- neue Offline-first-Datenbank klar von der alten lokalen `local_word_database.dart` abgrenzen
- Seed-/Importstrategie fuer erste lokale Kategorien und Woerter planen
- weiterhin keine UI, Provider, Supabase-Dateien oder App-Flows aendern

Der lokale SRS-/SQLite-/Repository-/Read-State-/Facade-/Factory-Block ist technisch stabil. Der naechste Schritt muss klaeren, wo die echte lokale Datenbank spaeter liegt und wie erste lokale Wortdaten risikoarm hineinkommen.

## 1. App-Datenbankpfad

### Datenbankname

Empfehlung fuer die neue lokale Offline-first-Datenbank:

- `talvori_local_v1.db`

Begruendung:

- eindeutig neuer Talvori-Datenbankname
- unterscheidet sich von der alten lokalen Datenbank `word_progress.db`
- macht die Version-1-Zielrichtung sichtbar
- vermeidet Vermischung mit alten A-SRS-Mirror-/Refill-Daten

### Pfadbildung

Die spaetere Pfadbildung sollte ueber `sqflite` erfolgen:

- `getDatabasesPath()`
- danach Join mit `talvori_local_v1.db`

Regeln:

- keine harten absoluten Pfade
- keine macOS-spezifischen Pfade im Produktionscode
- keine Windows-spezifischen Annahmen
- keine Pfade aus Tests fuer die echte App verwenden
- Tests weiter mit temporaeren Datenbanken oder FFI-Testpfaden ausfuehren

Die vorhandene `LocalDatabaseFactory` oeffnet bereits ueber:

- `openAtPath(String path)`

Der naechste kleine Baustein sollte deshalb nur den App-Pfad ermitteln und an `LocalDatabaseFactory.openAtPath(...)` uebergeben. Die Factory selbst muss dafuer nicht mit UI, Provider oder App-Start gekoppelt werden.

### Abgrenzung Zur Alten local_word_database.dart

Die neue Datenbank darf nicht denselben Namen verwenden wie die alte:

- alt: `word_progress.db`
- neu empfohlen: `talvori_local_v1.db`

Warum:

- Die alte Datenbank enthaelt andere Tabellen, andere Progress-Regeln und alte A-SRS-nahe Logik.
- Die neue Datenbank folgt dem V1-Schema unter `lib/core/local_database/local_database_schema.dart`.
- Ein gemeinsamer Name koennte bestehende lokale Daten beschaedigen oder alte Tabellen mit neuen Repositories vermischen.

## 2. Konfliktanalyse Mit Alter local_word_database.dart

Datei:

- `lib/features/words/data/local_word_database.dart`

### Datenbankname

Die alte Datei verwendet:

- `word_progress.db`

### Tabellen

Die alte Datei erstellt unter anderem:

- `word_progress`
- `word_progress_deck_state`
- `category_refill_state`

Die alte `word_progress`-Tabelle ist nicht kompatibel mit der neuen `word_progress`-Tabelle.

Alte Tabelle:

- `user_id`
- `category_id`
- `word_id`
- `mode`
- `stage` als Integer
- `ever_enrolled`
- `is_mastered`
- `streak_in_stage`
- `added_to_category_at`
- `device_id`
- `device_seq`

Neue Tabelle:

- `id`
- `word_id`
- `category_id`
- `mode_id`
- `stage` als stabiler Enum-String `s0` bis `s5`
- `pass_count`
- `wrong_count`
- `next_due_at`
- `last_reviewed_at`

### Zweck Der Alten Datenbank

Die alte Datenbank dient offenbar einer alten lokalen A-SRS-/Refill-/Mirror-Logik:

- Refill-Counter
- Stage-Counts
- Enrollment aus S0
- Cascade-Transaktionen
- `is_mastered`
- device-sequenzierte Progress-Events

Sie haengt an alter Logik wie:

- `a_srs_refill_engine.dart`
- `a_srs_bands.dart`
- alter Stage-/Mastered-Bedeutung

### Empfehlung: Jetzt Getrennt Halten

Fuer Version 1 soll die alte Datenbank:

- nicht migriert werden
- nicht geloescht werden
- nicht umbenannt werden
- nicht fuer neue lokale SRS-Engine verwendet werden
- nicht mit `talvori_local_v1.db` vermischt werden

Begruendung:

- Die alte Engine war fachlich nicht verlaesslich genug.
- Supabase-Fortschritt wird fuer Version 1 bewusst nicht migriert.
- Die neue lokale Engine startet mit neuem Fortschritt.
- Eine Migration wuerde mehr Risiko erzeugen als Nutzen.
- Die App nutzt die alte Datei moeglicherweise noch in bestehenden Flows; unkontrollierte Aenderungen koennten App-Verhalten brechen.

Spaeter moegliche Optionen:

- alte Datenbank ignorieren und nach Supabase-/Alt-Flow-Ablösung nicht mehr verwenden
- alte Datenbank nur lesend analysieren
- gezielte Migration einzelner Wortlisten, aber nicht alter SRS-Fortschritte
- alte Datei nach vollstaendiger App-Umstellung entfernen

## 3. Seed-/Importstrategie Fuer Erste Lokale Kategorien Und Woerter

### Option A: Kleine Lokale Seed-Daten Fuer Tests Oder Demo

Beschreibung:

- kleine, kuratierte lokale Beispielkategorien und Woerter
- direkt passend zum neuen V1-Schema
- wenige Eintraege, z. B. 1 bis 3 Kategorien mit je 10 bis 20 Woertern

Vorteile:

- geringstes Risiko
- schnell testbar
- keine Supabase-Abhaengigkeit
- keine DeepL-Abhaengigkeit
- keine UI-Anbindung noetig
- ermoeglicht lokalen End-to-End-Nachweis:
  - Kategorie
  - Woerter
  - Progress initialisieren
  - Session starten
  - ReadState bauen

Nachteile:

- noch keine echten Nutzerinhalte
- nur Demo-/Smoke-Test-Wert

Bewertung:

- beste erste Datenquelle fuer Version 1

### Option B: word_hub_taxonomy.dart Als Quelle

Datei:

- `lib/features/words/data/word_hub_taxonomy.dart`

Inhalt:

- `HubSection`
- `HubSubcat`
- `hubSections`
- Kategorie-/Tab-Struktur mit Labels
- optionale `supabaseId`

Vorteile:

- existiert bereits lokal
- bietet thematische Kategorien
- kann lokale Kategorien strukturieren
- hilfreich fuer Kategorie-Seed, nicht zwingend fuer Wort-Seed

Nachteile:

- enthaelt offenbar Kategorien, aber keine eigentlichen Vokabel-Woerter
- `supabaseId` verweist auf aktuelle Supabase-Welt
- direkte Nutzung koennte alte WordHub-/Supabase-Annahmen einschleppen

Bewertung:

- gut als spaetere Quelle fuer lokale Kategorie-Struktur
- nicht ausreichend als alleinige Wortquelle
- fuer ersten TDD-Schritt nur vorsichtig nutzen oder zunaechst vermeiden

### Option C: Spaeterer Supabase-Export

Beschreibung:

- bestehende Supabase-Woerter exportieren
- in lokales V1-Schema importieren

Vorteile:

- echte App-Daten
- potenziell launchrelevant
- kann vorhandene Kategorien/Woerter retten

Nachteile:

- Supabase-Struktur und alte lokale IDs muessen gemappt werden
- Importqualitaet muss geprueft werden
- SRS-Fortschritt soll nicht migriert werden
- Risiko fuer Dateninkonsistenzen
- blockiert nicht die lokale Engine

Bewertung:

- wichtig, aber nicht erster Schritt
- als Launch-/Post-Launch-Thema separat planen

### Option D: Manuelle Eingabe

Beschreibung:

- Nutzer oder Admin legt lokal Woerter an
- bestehende `CategoryRepository` und `WordRepository` koennen Daten speichern

Vorteile:

- fachlich sauber
- keine Migration noetig
- passt zu Offline-first

Nachteile:

- UI-Anbindung fehlt
- Eingabe-Flow waere App-Flow-/UI-Arbeit
- nicht geeignet als naechster lokaler Schritt

Bewertung:

- spaeter sinnvoll
- jetzt nicht anfangen

### Option E: DeepL/Wortimport Spaeter

Beschreibung:

- Wortimport oder Uebersetzung ueber DeepL oder aehnliche Dienste

Vorteile:

- koennte spaeter echte Wortdaten erzeugen
- hilfreich fuer Wachstum

Nachteile:

- nicht offline-first
- externe API-Abhaengigkeit
- Fehlerbehandlung, Kosten und Datenschutz
- fuer lokale Engine nicht notwendig

Bewertung:

- klar spaeter
- nicht Version-1-Blocker

## 4. Empfehlung Fuer Version 1

Empfehlung:

1. Neue App-Datenbank `talvori_local_v1.db` getrennt von `word_progress.db` halten.
2. Zuerst einen UI-neutralen App-Datenbankpfad-Baustein planen/implementieren.
3. Danach kleine lokale Seed-Daten fuer Kategorien und Woerter als rein lokalen Test-/Demo-Seed planen.
4. `word_hub_taxonomy.dart` zunaechst nur als moegliche Kategoriequelle betrachten, nicht als Wortimport.
5. Supabase-Export, DeepL/Wortimport und echte Migration spaeter separat planen.

Risikoaermste erste Datenquelle:

- kleine lokale Seed-Daten, direkt im neuen V1-Format

Was die lokale Engine nicht blockiert:

- fehlender Supabase-Export
- fehlende DeepL-Anbindung
- fehlende Migration alter `word_progress.db`
- fehlende UI fuer manuelle Eingabe

Die lokale Engine braucht fuer den naechsten Schritt nur:

- Kategorien
- Woerter
- Progress-Initialisierung ueber bestehende Services
- Session-Start ueber `LocalLearningSessionFacade`

## 5. Was Noch Nicht Passieren Darf

Weiterhin nicht tun:

- keine UI-Anbindung
- keine Provider-Umstellung
- kein `LearnModeController`-Umbau
- keine Supabase-Entfernung
- keine Supabase-Repository-Ersetzung
- keine automatische Migration alter Daten
- keine Migration von Supabase-Fortschritt
- keine Vermischung mit `word_progress.db`
- kein Schreiben in alte `local_word_database.dart`
- kein App-Start-Bootstrap mit echter Nutzung
- keine DeepL-/Import-API-Anbindung
- keine echten App-Daten veraendern

## 6. Spaeter Sinnvolle Tests

### app_database_path_uses_expected_name

Ziel:

- Der App-Datenbankpfad verwendet den erwarteten Namen `talvori_local_v1.db`.
- Pfad wird ueber `getDatabasesPath()` plus Join gebildet.
- Kein harter absoluter Pfad.

### old_local_word_database_is_not_modified

Ziel:

- Neuer Pfad-/Seed-Baustein greift nicht auf `word_progress.db` zu.
- Alte `LocalWordDatabase` wird nicht initialisiert.
- Neue lokale Tests bleiben auf `talvori_local_v1.db`.

### seed_data_can_create_categories_and_words

Ziel:

- Kleine lokale Seed-Daten koennen Kategorien und Woerter ueber `CategoryRepository` und `WordRepository` erzeugen.
- Archivierte/duplizierte Faelle bleiben kontrolliert.
- Seed ist idempotent oder bewusst definiert.

### seeded_words_can_initialize_progress_and_start_session

Ziel:

- Aus Seed-Woertern kann Progress initialisiert werden.
- Danach kann `LocalLearningSessionFacade.startOrResumeLearning(...)` eine Session starten.
- `LocalSessionReadState` enthaelt Wortdaten und `S0`.

## 7. Kleinster Naechster TDD-Schritt

Der kleinste sinnvolle naechste TDD-Schritt ist:

1. Einen UI-neutralen Pfad-Baustein planen/implementieren, z. B. `LocalAppDatabasePath`.
2. Nur testen:
   - `app_database_path_uses_expected_name`
3. Der Baustein soll nur den Pfad fuer `talvori_local_v1.db` bilden.
4. Er soll keine Datenbank oeffnen.
5. Er soll keine Repositorys erzeugen.
6. Er soll keine UI, Provider oder Supabase kennen.

Danach:

1. Testen, dass die neue Pfadlogik nicht `word_progress.db` verwendet.
2. Kleine lokale Seed-Daten planen.
3. Seed-Daten erst danach in einem separaten TDD-Schritt implementieren.

## Empfehlung

Der naechste Schritt sollte nicht App-Anbindung sein.

Empfohlene Reihenfolge:

1. App-Datenbankpfad-Baustein fuer `talvori_local_v1.db`
2. Test gegen versehentliche alte DB-Nutzung
3. kleine lokale Seed-Daten planen
4. Seed-Daten lokal testen
5. danach erst UI-neutralen App-Bootstrap planen

So bleibt die neue lokale Engine stabil, getrennt von alten Datenquellen und bereit fuer eine spaetere kontrollierte App-Anbindung.
