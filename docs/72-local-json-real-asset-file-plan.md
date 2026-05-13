# 72 Local JSON Real Asset File Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant eine echte lokale JSON-Asset-Datei fuer den spaeteren App-Asset-Import.

Es ist nur Planung:

- kein Code
- keine Asset-Datei
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`
- keine Aenderung an `pubspec.yaml`

## 1. Zweck Der Echten Asset-Datei

Die echte Asset-Datei soll spaeter lokale Startdaten fuer die Offline-first-Schicht bereitstellen.

Ziel:

- Kategorien und Woerter im App-Bundle bereitstellen
- Offline-Import ohne Supabase ermoeglichen
- Inhalte in `talvori_local_v1.db` importieren koennen
- keine alte lokale DB verwenden
- keinen alten SRS-Fortschritt importieren
- keine Sessions importieren
- keine Review-History importieren

Die Datei soll nur Inhaltsdaten enthalten:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- `sort_order`
- `is_archived`

## 2. Empfohlener Pfad

Moegliche Pfade:

- `assets/local_import/default_words_v1.json`
- `assets/local_seed/default_words_v1.json`

### Variante A: `assets/local_import/default_words_v1.json`

Vorteile:

- passt direkt zum `LocalJsonImportService`
- beschreibt die Datei als importierbare Inhaltsdatei
- vermeidet Verwechslung mit `LocalSeedDataService`
- macht klar, dass der Import bewusst ausgeloest werden muss
- kann spaeter mehrere Importdateien aufnehmen

Nachteile:

- etwas technischer Name
- braucht spaeter klare Doku, dass die Datei nicht automatisch importiert wird

### Variante B: `assets/local_seed/default_words_v1.json`

Vorteile:

- klingt nach Startdaten
- fuer Produkt-/Demo-Daten leicht verstaendlich

Nachteile:

- kann mit hart codierten Seed-Daten verwechselt werden
- "Seed" klingt nach automatischer Initialisierung
- erhoeht Risiko, dass Daten unkontrolliert beim App-Start importiert werden

Empfehlung:

- `assets/local_import/default_words_v1.json`

Begruendung:

Der Begriff `local_import` beschreibt die Rolle der Datei genauer. Es geht nicht um automatische Seed-Ausfuehrung, sondern um eine importierbare JSON-Quelle, die spaeter bewusst geladen und an `LocalJsonImportService` delegiert wird.

## 3. Unterschied Zur Test-Fixture

Aktuelle Test-Fixture:

- `test/fixtures/local_import/default_words_v1.json`

Geplante echte Asset-Datei:

- `assets/local_import/default_words_v1.json`

Unterschiede:

- `test/fixtures/...` bleibt reine Testdatenquelle.
- `assets/...` waere spaeter App-Bundle-Datenquelle.
- Test-Fixtures werden per `File(...).readAsString()` geladen.
- echte Assets werden ueber `AssetBundle` geladen.
- eine Test-Fixture ist nicht automatisch Produkt- oder App-Content.
- eine echte Asset-Datei braucht spaeter einen `pubspec.yaml`-Eintrag.

Warum nicht automatisch dieselbe Datei genutzt werden sollte:

- Test-Fixtures duerfen klein, kuenstlich und testorientiert bleiben.
- App-Assets sollten bewusster kuratiert sein.
- App-Assets koennen spaeter Produkt-/Demo-Wirkung haben.
- Änderungen an App-Assets haben anderen Review-Bedarf als Testdaten.
- Eine klare Trennung verhindert, dass Testdaten versehentlich als Produktdaten ausgeliefert werden.

## 4. Inhalt Der Ersten Echten Asset-Datei

Die erste echte Asset-Datei soll dieselbe Struktur wie `LocalJsonImportService` erwarten.

Top-Level:

- Liste von Kategorien

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

Sinnvolle erste Kategorien:

- `basics`
- optional spaeter `travel`
- optional spaeter `exam_practice`

Inhaltlich soll die Datei zuerst einfache, neutrale Demo-/Startdaten enthalten. Sie soll noch keine finalen Launch-Inhalte vortaeuschen.

## 5. Umfang

Moegliche Varianten:

### Variante A: Zunaechst Identisch Zur Fixture

Umfang:

- `basics`
- 2 Woerter:
  - `basics_hello`
  - `basics_water`

Vorteile:

- kleinster Schritt
- einfach reviewbar
- geringe Fehlerwahrscheinlichkeit
- kann direkt gegen bestehende Fixture-Erwartungen gespiegelt werden

Nachteile:

- zu klein fuer echte lokale Nutzung
- keine volle Sessiongroesse
- wenig Mehrwert gegenueber Fixture

### Variante B: Basics Direkt Auf 20 Woerter Erweitern

Umfang:

- `basics`
- 20 aktive Woerter

Vorteile:

- reicht fuer eine volle Sessiongroesse
- realistischer fuer Offline-first-Smoke-Tests
- macht spaeteren Debug-Import nuetzlicher

Nachteile:

- hoeherer Reviewaufwand
- mehr Inhaltsqualitaet noetig
- groesserer erster Schritt

### Variante C: 3 Kategorien Mit Je 5 Bis 10 Woertern

Umfang:

- `basics`
- `travel`
- `exam_practice`
- je 5 bis 10 Woerter

Vorteile:

- deckt mehrere Kategorien ab
- realistischere Struktur
- gut fuer Kategorieauswahl spaeter

Nachteile:

- groesster erster Inhaltsaufwand
- mehr Risiko fuer Tippfehler und inkonsistente IDs

Empfehlung:

- fuer den kleinsten naechsten TDD-Schritt: zunaechst identisch zur Fixture oder sehr nah daran
- danach separat planen, ob `basics` auf 20 Woerter erweitert wird

Begruendung:

Der naechste Schritt soll beweisen, dass eine echte Asset-Datei lokal existiert, valide JSON-Struktur hat und spaeter importierbar ist. Umfang und Inhaltsqualitaet koennen danach kontrolliert erweitert werden.

## 6. ID-Strategie

IDs sollen stabil, sprechend und lokal sein.

Empfohlen:

- Kategorie-ID: `basics`
- Wort-IDs:
  - `basics_hello`
  - `basics_water`
  - `basics_goodbye`
  - `basics_book`
  - `basics_friend`

Nicht verwenden:

- keine Supabase-IDs
- keine alten IDs aus `word_progress.db`
- keine IDs aus `local_word_database.dart`
- keine zufaelligen UUIDs
- keine automatisch generierten IDs

Warum sprechende IDs:

- einfacher Review
- stabile Idempotenz
- klare Fehlersuche
- keine versteckte Migration aus alter Infrastruktur

## 7. Qualitaetsregeln Fuer Inhalte

Die echte Asset-Datei soll folgende Regeln einhalten:

- keine leeren Begriffe
- keine leeren Uebersetzungen
- eindeutige Kategorie-IDs
- eindeutige Wort-IDs innerhalb der Datei
- verstaendliche Beispielsaetze
- kurze Notizen
- `sort_order` konsistent und aufsteigend pro Kategorie
- `is_archived` explizit setzen
- keine finalen Launch-Inhalte vortaeuschen, wenn es nur Demo-Daten sind
- keine Supabase-Felder
- keine alten SRS-Felder
- kein `is_mastered`
- kein `pass_count`
- kein `next_due_at`

Empfehlung fuer Demo-Daten:

- neutrale Alltagsbegriffe
- einfache Beispielsaetze
- kurze Notizen wie "Common greeting." oder "Useful everyday noun."
- keine marken-, nutzer- oder personenbezogenen Inhalte

## 8. Spaetere Tests

Sinnvolle Tests fuer spaetere Schritte:

- `real_asset_file_has_valid_json_structure`
- `real_asset_file_can_be_imported_with_local_json_import_service`
- `real_asset_file_import_is_idempotent`
- `real_asset_file_does_not_create_progress`
- `real_asset_file_words_can_start_session`

### real_asset_file_has_valid_json_structure

Sichert ab:

- Datei liegt am erwarteten Pfad.
- JSON ist parsebar.
- Top-Level ist eine Liste.
- mindestens eine Kategorie existiert.
- Kategorien enthalten Pflichtfelder.
- Woerter enthalten Pflichtfelder.

Dieser Test kann zunaechst per normalem `File` laufen, solange noch kein `pubspec.yaml`-Eintrag existiert.

### real_asset_file_can_be_imported_with_local_json_import_service

Sichert ab:

- Datei kann ueber `LocalJsonImportService` in eine In-Memory-DB importiert werden.
- Kategorien werden erstellt.
- Woerter werden erstellt.

### real_asset_file_import_is_idempotent

Sichert ab:

- gleicher Dateiimport kann mehrfach laufen.
- keine doppelten Kategorien entstehen.
- keine doppelten Woerter entstehen.
- stabile IDs bleiben gleich.

### real_asset_file_does_not_create_progress

Sichert ab:

- Import erzeugt keinen `word_progress`.
- Import erzeugt keine `learning_sessions`.
- Import erzeugt keine `review_history`.

### real_asset_file_words_can_start_session

Sichert ab:

- importierte Woerter koennen Progress initialisieren.
- danach kann eine lokale Session gestartet werden.
- `LocalSessionReadState` ist nutzbar.

## 9. Was Weiterhin Nicht Passieren Darf

Weiterhin ausgeschlossen:

- keine `pubspec.yaml`-Aenderung in diesem Schritt
- kein `rootBundle`-Test in diesem Schritt
- keine App-Anbindung
- kein automatischer Import beim App-Start
- kein Supabase
- keine alte DB
- kein Zugriff auf `local_word_database.dart`
- kein Zugriff auf alte `word_progress.db`
- kein Progress-Import
- keine Session durch Import
- keine Review-History durch Import
- keine UI-Anbindung
- keine Navigation
- keine Provider-Umstellung
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`

## 10. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. echte Asset-Datei anlegen:
   - `assets/local_import/default_words_v1.json`
2. Inhalt zunaechst klein halten:
   - `basics`
   - 2 Woerter wie in der Fixture
3. noch keine `pubspec.yaml`-Aenderung
4. noch kein `rootBundle`
5. einen Test schreiben:
   - `real_asset_file_has_valid_json_structure`
6. Der Test liest die Datei per normalem `File`, solange sie noch nicht als Flutter-Asset registriert ist.
7. Der Test prueft nur:
   - Datei existiert
   - JSON ist gueltig
   - Top-Level ist Liste
   - Kategorie- und Wortpflichtfelder sind vorhanden

Erst danach sollten folgen:

- Import der echten Asset-Datei in In-Memory-SQLite pruefen
- Idempotenz pruefen
- kein Progress durch Import pruefen
- optional `pubspec.yaml`-Eintrag separat planen
- spaeter `AssetBundle`/`rootBundle`-Pfad separat testen

Diese Reihenfolge haelt die echte Asset-Datei lokal, isoliert und ohne App-Flow-Risiko.
