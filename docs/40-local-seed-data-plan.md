# 40 Local Seed Data Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant kleine lokale Seed-Daten fuer Version 1 der neuen Offline-first-Schicht.

Seed-Daten sollen:

- kleine Demo-/Testdaten bereitstellen
- ohne Supabase funktionieren
- ohne DeepL funktionieren
- keine echte Migration benoetigen
- lokal in `talvori_local_v1.db` nutzbar sein
- lokale Offline-first-Tests ermoeglichen
- Progress-Initialisierung und Session-Start absichern

Seed-Daten sind nicht als finale Inhaltsstrategie gedacht. Sie sind ein risikoarmer Zwischenschritt, um die lokale Kette mit echten Tabellen und Repositorys weiter zu pruefen.

## Geeignete Kategorien

Fuer Version 1 reichen wenige, klare Kategorien.

Empfohlen:

1. `Basics`
   - einfache Alltagswoerter
   - geeignet fuer Smoke-Tests und erste Sessions

2. `Travel`
   - praxisnahe Woerter fuer Reise-/Orientierungssituationen
   - gut verstaendlich und spaeter demo-tauglich

3. `Exam Practice`
   - pruefungsnahe Woerter oder kurze Formulierungen
   - passt zum A-SRS-/Intensiv-lernen-Szenario

Warum diese Kategorien:

- normale Nutzer verstehen sie sofort
- keine SRS-Fachbegriffe
- breit genug fuer Demo
- klein genug fuer kontrollierte Tests

## Genutzte Wortfelder

Seed-Woerter sollen nur V1-Felder verwenden:

- `term`
- `translation`
- `example_sentence`
- `notes`
- `sort_order`
- `is_archived`

Pflichtfelder aus dem Repository:

- `categoryId`
- `term`
- `translation`
- `now`

Empfehlung:

- `example_sentence` fuer die meisten Seed-Woerter setzen
- `notes` nur kurz und optional verwenden
- `sort_order` stabil pro Kategorie setzen
- `is_archived = false` fuer aktive Seed-Woerter

Keine zusaetzlichen Felder in Version 1:

- kein Audio
- keine Wortart
- keine Artikel
- keine DeepL-Metadaten
- keine Supabase-IDs
- keine SRS-Progress-Werte im Seed selbst

Progress entsteht spaeter durch `LocalProgressInitializationService`.

## Anzahl Der Woerter

Empfehlung:

- klein halten
- 10 bis 20 Woerter pro Kategorie

Konkreter V1-Vorschlag:

- `Basics`: 20 Woerter
- `Travel`: 12 bis 15 Woerter
- `Exam Practice`: 20 Woerter

Begruendung:

- 20 Woerter reichen fuer eine Standard-Sessiongroesse von 20.
- A-SRS kann damit eine komplette neue Session aus S0 bilden.
- Travel bleibt bewusst kleiner, um kurze Kategorie-Szenarien zu testen.
- Mehr Daten wuerden den ersten Seed-Schritt unnoetig vergroessern.

## Einfuegevarianten

### Variante A: Ueber CategoryRepository Und WordRepository

Beschreibung:

- Seed-Service nutzt `CategoryRepository.upsertCategory(...)`
- Seed-Service nutzt `WordRepository.upsertWord(...)`
- stabile IDs verhindern Duplikate

Vorteile:

- nutzt getestete Repository-Pfade
- bleibt nah an spaeterer App-Nutzung
- respektiert Mapping und Defaults der Repositorys
- reduziert SQL-Duplizierung
- gut testbar mit In-Memory- oder temporaerer SQLite-Datenbank

Nachteile:

- etwas mehr Dart-Struktur als direktes SQL
- Seed-Daten brauchen ein kleines Datenmodell oder konstante Liste

Bewertung:

- beste und risikoaermste Variante fuer Version 1

### Variante B: Direktes SQL

Beschreibung:

- Seed-Daten werden direkt per `db.insert(...)` oder SQL eingefuegt

Vorteile:

- schnell
- wenig Abstraktion

Nachteile:

- umgeht Repository-Regeln
- dupliziert Spaltenwissen
- hoeheres Risiko bei Schema-Aenderungen
- schlechter als Test fuer spaetere lokale App-Kette

Bewertung:

- fuer Version 1 nicht empfohlen

### Variante C: JSON/Asset Spaeter

Beschreibung:

- Seed-Daten liegen spaeter als JSON oder Asset vor
- ein Loader liest und validiert sie

Vorteile:

- Inhalte koennen leichter gepflegt werden
- spaeter besser fuer echte Bundled-Daten
- klare Trennung von Daten und Logik

Nachteile:

- braucht Asset-Registrierung
- fuehrt App-Bundle-/Load-Fragen ein
- fuer ersten lokalen TDD-Schritt mehr Komplexitaet als noetig

Bewertung:

- spaeter sinnvoll
- jetzt nur planen, nicht implementieren

## Empfehlung Fuer Version 1

Empfohlen wird:

1. Kleine Seed-Daten als konstante lokale Dart-Struktur im lokalen Datenbankbereich planen.
2. Ein kleiner `LocalSeedDataService` oder aehnlicher UI-neutraler Baustein nutzt `CategoryRepository` und `WordRepository`.
3. Kategorien und Woerter bekommen stabile IDs.
4. Seed wird idempotent ueber `upsertCategory(...)` und `upsertWord(...)`.
5. Seed erzeugt nur Kategorien und Woerter, keinen Fortschritt.
6. Progress wird danach separat durch `LocalProgressInitializationService` erzeugt.
7. Session-Start wird separat ueber `LocalLearningSessionFacade` getestet.

Risikoaermste Quelle:

- kleine, handgepflegte lokale Seed-Daten direkt im V1-Format

Nicht erste Quelle:

- Supabase-Export
- DeepL-/Wortimport
- alte `word_progress.db`
- UI-basierte manuelle Eingabe

## Idempotenz

Seed-Daten muessen mehrfach ausfuehrbar sein, ohne Duplikate zu erzeugen.

Empfohlene Regeln:

- Jede Seed-Kategorie hat eine stabile ID.
- Jedes Seed-Wort hat eine stabile ID.
- `CategoryRepository.upsertCategory(...)` wird mit ID aufgerufen.
- `WordRepository.upsertWord(...)` wird mit ID aufgerufen.
- Beim zweiten Lauf werden bestehende Zeilen aktualisiert statt dupliziert.
- `sort_order` bleibt stabil.
- Archivierte Testdaten werden nicht automatisch erzeugt, ausser ein Test braucht sie explizit.

Wichtig:

- Keine Eindeutigkeit ueber `term` oder `translation` erzwingen.
- Duplikate gleicher Begriffe sind fachlich erlaubt, solange IDs stabil sind.
- Der Seed-Service darf nicht direkt `word_progress` schreiben.

## Spaeter Sinnvolle Tests

### seed_data_can_create_categories_and_words

Ziel:

- Seed erzeugt erwartete Kategorien.
- Seed erzeugt erwartete Woerter.
- Kategorien und Woerter sind ueber Repositorys ladbar.

Erwartung:

- mindestens eine Kategorie existiert
- aktive Woerter existieren
- `sort_order` stimmt
- `is_archived` ist fuer Standard-Seed-Woerter `false`

### seed_data_is_idempotent

Ziel:

- Seed kann zweimal laufen.
- Es entstehen keine doppelten Kategorien oder Woerter.

Erwartung:

- Kategorieanzahl bleibt gleich
- Wortanzahl bleibt gleich
- stabile IDs bleiben erhalten

### seeded_words_can_initialize_progress_and_start_session

Ziel:

- Aus Seed-Woertern kann Progress initialisiert werden.
- Danach kann eine lokale Session gestartet werden.

Erwartung:

- `LocalProgressInitializationService` erzeugt S0-Progress.
- `LocalLearningSessionFacade.startOrResumeLearning(...)` gibt einen `LocalSessionReadState` zurueck.
- `currentWordId` ist gesetzt.
- `currentStage` ist `S0`.

## Was Bewusst Nicht Passieren Darf

Weiterhin nicht tun:

- keine UI-Anbindung
- keine Provider-Umstellung
- kein `LearnModeController`-Umbau
- keine Supabase-Entfernung
- kein DeepL-Import
- keine Migration alter lokaler Daten
- keine Migration von Supabase-Daten
- keine Aenderung an `word_progress.db`
- keine Nutzung alter `LocalWordDatabase`
- kein Schreiben von SRS-Fortschritt im Seed
- keine Review-History im Seed
- keine Session-Erzeugung im Seed

Seed-Daten sollen nur Kategorie- und Wortbasis bereitstellen.

## Kleinster Naechster TDD-Schritt

Der kleinste sinnvolle naechste TDD-Schritt ist:

1. Einen kleinen lokalen Seed-Baustein planen/implementieren, z. B. `LocalSeedDataService`.
2. Nur den Test `seed_data_can_create_categories_and_words` schreiben.
3. In diesem Test:
   - temporaere oder In-Memory-SQLite-Datenbank oeffnen
   - `LocalRepositoryFactory` verwenden
   - Seed ausfuehren
   - Kategorien und Woerter ueber Repositorys laden
4. Noch nicht testen:
   - Progress
   - Session-Start
   - UI
   - echte App-Datenbank

Danach:

1. `seed_data_is_idempotent`
2. `seeded_words_can_initialize_progress_and_start_session`

## Empfehlung

Fuer Version 1 sollte Seed klein, lokal und langweilig bleiben.

Empfohlen:

- 3 Kategorien
- 10 bis 20 Woerter pro Kategorie
- stabile IDs
- Einfuegen ueber `CategoryRepository` und `WordRepository`
- keine Progress- oder Session-Daten im Seed

So kann die lokale Offline-first-Kette weiter wachsen, ohne Supabase, alte lokale Datenbank oder UI-Flows zu beruehren.
