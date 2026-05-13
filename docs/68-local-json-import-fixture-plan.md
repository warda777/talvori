# 68 Local JSON Import Fixture Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine echte lokale JSON-Import-Fixture fuer den `LocalJsonImportService`.

Es ist nur Planung:

- kein Code
- keine JSON-Datei
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`

## 1. Zweck Der Import-Fixture

Die Fixture soll realistischere lokale Testdaten fuer die neue Offline-first-Datenbank liefern.

Ziele:

- groessere und realistischere Testdaten als Inline-JSON in Unit-Tests
- lokale Kategorien und Woerter fuer Importtests
- stabile Testbasis fuer Import, Idempotenz und Session-Start
- keine Supabase-Abhaengigkeit
- kein Asset-Import
- keine App-Anbindung
- keine alte lokale Datenbank

Die Fixture soll weiterhin nur Inhaltsdaten enthalten:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- `sort_order`
- `is_archived`

Sie soll keinen Lernfortschritt enthalten.

## 2. Speicherort

Empfohlener Pfad:

- `test/fixtures/local_import/default_words_v1.json`

Begruendung:

- klar als Test-Fixture erkennbar
- nicht im App-Asset-System
- kein `rootBundle`
- keine automatische App-Nutzung
- gut in Tests per normalem Dateizugriff lesbar
- getrennt von Produktionscode und Seed-Dart-Konstanten

Alternative Pfade:

- `test/fixtures/local_database/default_words_v1.json`
- `test/fixtures/local_json_import/default_words_v1.json`

Empfehlung:

`test/fixtures/local_import/default_words_v1.json` ist kurz, eindeutig und nah am geplanten Importzweck.

## 3. JSON-Struktur

Die Datei soll eine Top-Level-Kategorienliste enthalten.

Schema:

```json
[
  {
    "id": "basics",
    "name": "Basics",
    "description": "Essential starter words.",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "basics_hello",
        "term": "hello",
        "translation": "hallo",
        "example_sentence": "Hello, how are you?",
        "notes": "Common greeting.",
        "sort_order": 1,
        "is_archived": false
      }
    ]
  }
]
```

Kategorie-Felder:

- `id`
- `name`
- `description`
- `sort_order`
- `is_archived`
- `words`

Wort-Felder:

- `id`
- `term`
- `translation`
- `example_sentence`
- `notes`
- `sort_order`
- `is_archived`

Alle IDs sollen stabil und sprechend sein. Optionale Felder duerfen in der Fixture trotzdem bewusst gesetzt werden, damit die Importstrecke fuer Beispielsatz und Notizen mitgeprueft wird.

## 4. Sinnvolle Beispielkategorien

Empfohlene Kategorien fuer die erste Fixture:

- `basics`
- `travel`
- `exam_practice`

### basics

Zweck:

- einfache Alltagswoerter
- gute erste Kategorie fuer Session- und Smoke-Tests
- geeignet, um eine komplette Session mit neuen S0-Karten zu starten

Beispiele:

- hello
- goodbye
- water
- food
- book
- today
- tomorrow
- friend
- help
- please

### travel

Zweck:

- konkrete Alltagsszenarien
- gut fuer Beispielsatz- und Notizfelder

Beispiele:

- ticket
- station
- airport
- hotel
- luggage
- map
- train
- bus
- reservation
- passport

### exam_practice

Zweck:

- pruefungsnahe Begriffe
- spaeter geeignet fuer gezieltes Ueben

Beispiele:

- question
- answer
- essay
- grammar
- vocabulary
- listening
- speaking
- reading
- writing
- correction

## 5. Wortanzahl

Fuer die erste Fixture gibt es zwei sinnvolle Varianten.

### Variante A: 5 Bis 10 Woerter Pro Kategorie

Vorteile:

- klein und gut lesbar
- schnell zu reviewen
- ausreichend fuer Import- und Idempotenztests
- ausreichend fuer einfache Session-Starts

Nachteile:

- testet Sessiongroesse 20 nicht voll aus
- weniger realistisch fuer groessere lokale Nutzung

### Variante B: 20 Woerter Fuer Basics, 5 Bis 10 Fuer Weitere Kategorien

Vorteile:

- `basics` kann eine volle Sessiongroesse von 20 bedienen
- besserer Smoke-Test fuer Queue und Sessiongrenze
- weiterhin ueberschaubar

Nachteile:

- groessere Fixture
- mehr Reviewaufwand fuer Inhalte

Empfehlung fuer Version 1:

- `basics`: 20 aktive Woerter
- `travel`: 8 bis 10 aktive Woerter
- `exam_practice`: 8 bis 10 aktive Woerter

Damit bleibt die Fixture klein genug fuer Tests, aber gross genug, um eine volle lokale Session mit `basics` realistisch zu pruefen.

## 6. ID-Strategie

IDs sollen stabil, sprechend und lokal sein.

Empfohlen:

- Kategorie-IDs:
  - `basics`
  - `travel`
  - `exam_practice`
- Wort-IDs:
  - `basics_hello`
  - `basics_water`
  - `travel_ticket`
  - `exam_practice_question`

Nicht verwenden:

- keine UUIDs, solange sprechende IDs reichen
- keine Supabase-IDs
- keine alten IDs aus `word_progress.db`
- keine IDs aus `local_word_database.dart`
- keine automatisch generierten IDs beim Import

Vorteile sprechender IDs:

- leicht reviewbar
- stabil fuer Idempotenztests
- gut fuer Fehlersuche
- keine versteckte Abhaengigkeit zu alter oder entfernter Infrastruktur

## 7. Spaetere Tests

Sinnvolle Tests fuer den naechsten Schritt:

- `local_import_fixture_can_be_loaded_from_test_file`
- `local_import_fixture_creates_categories_and_words`
- `local_import_fixture_is_idempotent`
- `local_import_fixture_does_not_create_progress`
- `local_import_fixture_words_can_start_session`

### local_import_fixture_can_be_loaded_from_test_file

Sichert ab:

- Fixture-Datei liegt am erwarteten Testpfad.
- Test kann sie per normalem Dateizugriff laden.
- Datei enthaelt gueltiges JSON.
- Es wird kein `rootBundle` verwendet.
- Es wird kein Flutter-Asset-System verwendet.

### local_import_fixture_creates_categories_and_words

Sichert ab:

- Fixture erzeugt die erwarteten Kategorien.
- Woerter werden importiert.
- wichtige Felder wie `term`, `translation`, `example_sentence`, `notes`, `sort_order` und `is_archived` kommen an.

### local_import_fixture_is_idempotent

Sichert ab:

- dieselbe Fixture kann mehrfach importiert werden.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- stabile IDs bleiben gleich.

### local_import_fixture_does_not_create_progress

Sichert ab:

- Fixture-Import erzeugt nur Inhaltsdaten.
- `word_progress` bleibt leer.
- `learning_sessions` bleibt leer.
- `review_history` bleibt leer.

### local_import_fixture_words_can_start_session

Sichert ab:

- importierte Fixture-Woerter koennen Progress initialisieren.
- danach kann eine lokale Session gestartet werden.
- Rueckgabe ist ein nutzbarer `LocalSessionReadState`.
- `currentStage` ist S0.

## 8. Was Weiterhin Nicht Passieren Darf

Weiterhin ausgeschlossen:

- kein `rootBundle`
- kein Flutter-Asset
- kein App-Start-Import
- kein Supabase
- keine alte lokale DB
- kein Zugriff auf `word_progress.db`
- kein Zugriff auf `local_word_database.dart`
- kein Progress-Import
- keine Session-Erzeugung durch Import
- keine Review-History durch Import
- keine UI-Anbindung
- keine Navigation
- keine Provider-Umstellung
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

Die Fixture bleibt zuerst ein reines Testartefakt.

## 9. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Fixture-Datei `test/fixtures/local_import/default_words_v1.json` anlegen.
2. Einen einzigen Test schreiben:
   - `local_import_fixture_can_be_loaded_from_test_file`
3. Der Test prueft nur:
   - Datei kann per normalem `File(...).readAsString()` gelesen werden.
   - Inhalt ist gueltiges JSON.
   - Top-Level-Struktur ist eine Liste.
   - mindestens eine Kategorie ist enthalten.
   - kein `rootBundle` und kein Asset-System werden verwendet.

Erst danach sollten Importtests mit echter Datenbank folgen:

- Fixture importiert Kategorien und Woerter.
- Fixture bleibt idempotent.
- Fixture erzeugt keinen Progress.
- Fixture-Woerter koennen Progress initialisieren und eine Session starten.

Diese Reihenfolge haelt den Schritt klein, lokal, rueckbaubar und ohne App-Anbindung.
