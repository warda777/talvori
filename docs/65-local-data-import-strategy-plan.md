# 65 Local Data Import Strategy Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant die lokale Datenimportstrategie fuer die neue Offline-first-Datenbank:

- `talvori_local_v1.db`

Es ist nur Planung:

- kein Code
- keine UI-Aenderung
- keine Supabase-Aenderung
- keine App-Flow-Aenderung
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`

## 1. Ziel Der Importstrategie

Ziel ist, echte oder zumindest launch-nahe lokale Inhaltsdaten in `talvori_local_v1.db` zu bringen:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- Sortierung
- Archivstatus

Der Import soll:

- nur Inhaltsdaten importieren
- keinen alten SRS-Fortschritt migrieren
- Supabase nicht direkt entfernen
- bestehende UI-Flows nicht veraendern
- alte lokale `word_progress.db` nicht beruehren
- lokale SRS-Engine nicht blockieren

Die neue lokale Engine kann bereits mit Seed-Daten, Progress-Initialisierung und Sessions arbeiten. Die Importstrategie betrifft deshalb nicht die Funktionsfaehigkeit der Engine selbst, sondern die Datenbasis fuer realistischere lokale Nutzung.

## 2. Erlaubte Und Nicht Erlaubte Daten

### Erlaubt

Importiert werden duerfen:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen
- `sort_order`
- `is_archived`

Diese Felder passen zur V1-Wortstruktur:

- `id`
- `category_id`
- `term`
- `translation`
- `example_sentence`
- `notes`
- `sort_order`
- `is_archived`
- `created_at`
- `updated_at`

### Nicht Importieren

Nicht importiert werden:

- alter SRS-Fortschritt
- `is_mastered`
- alte `pass_count`-Werte
- alte `next_due_at`-Werte
- alte Streak-/EF-/Lapses-Daten
- alte Refill-Daten
- alte A-SRS-Mirror-Daten
- alte Sessions
- alte Session-Items
- alte Review-History

Begruendung:

- Die alte Engine war fachlich nicht verlaesslich genug.
- Die neue V1-Regelbasis hat andere Stage-, Requeue-, Due-Date- und Session-Regeln.
- Fortschritt soll lokal neu und nachvollziehbar durch `LocalProgressInitializationService`, `LocalLearningSessionFacade` und echte Antworten entstehen.

## 3. Vergleich Moeglicher Importquellen

### A. Bestehende Kleine Seed-Daten

Quelle:

- `lib/core/local_database/seed/local_seed_data.dart`
- `LocalSeedDataService`

Aktuell enthalten:

- `Basics`
- `Travel`
- `Exam Practice`
- je 3 Woerter

Bewertung:

- Risiko: sehr niedrig
- Aufwand: sehr niedrig
- Datenqualitaet: niedrig bis mittel, da Demo-Daten
- Offline-Tauglichkeit: sehr hoch
- Testbarkeit: sehr hoch
- Naehe zum Launch: niedrig bis mittel

Vorteile:

- existiert bereits
- nutzt `CategoryRepository` und `WordRepository`
- idempotent durch stabile IDs
- erzeugt keinen Progress, keine Sessions und keine Review-History
- vollstaendig lokal

Nachteile:

- zu wenig echte Inhalte
- eher Demo-/Smoke-Test-Daten
- nicht ausreichend fuer produktiven Launch

Fazit:

- Beste Quelle fuer technische Smoke-Tests.
- Nicht ausreichend als finale Importstrategie.

### B. `word_hub_taxonomy.dart` Als Kategoriequelle

Quelle:

- `lib/features/words/data/word_hub_taxonomy.dart`

Inhalt:

- `HubSection`
- `HubSubcat`
- `hubSections`
- thematische Struktur
- `key`
- `label`
- optional `supabaseId`

Bewertung:

- Risiko: mittel
- Aufwand: niedrig bis mittel
- Datenqualitaet: gut fuer Kategorie-Struktur, keine Wortdaten
- Offline-Tauglichkeit: hoch
- Testbarkeit: hoch
- Naehe zum Launch: mittel fuer Kategorien, niedrig fuer Woerter

Vorteile:

- lokale Datei
- liefert eine bereits gedachte Kategorie-/Tab-Struktur
- geeignet, um lokale Kategorien mit stabilen IDs aus `key` abzuleiten
- kann WordHub-Struktur spaeter lokal spiegeln

Nachteile:

- liefert keine Vokabeln
- `supabaseId` darf nicht unkontrolliert in lokale Haupt-ID-Strategie uebernommen werden
- steht aktuell noch in einem Supabase-nahen App-Kontext

Fazit:

- Sinnvoll als spaetere Kategorie-Strukturquelle.
- Nicht geeignet als alleinige Importquelle fuer Woerter.
- Fuer V1 nur kontrolliert und ohne Supabase-ID-Abhaengigkeit verwenden.

### C. Spaeterer Supabase-Export Fuer Kategorien Und Woerter

Quelle:

- Supabase-Daten, theoretisch exportiert aus bestehenden Tabellen/Views
- aktuell nahe an `supabase_word_repository.dart`

Bewertung:

- Risiko: hoch
- Aufwand: hoch
- Datenqualitaet: potenziell hoch
- Offline-Tauglichkeit: nach Export hoch
- Testbarkeit: mittel bis hoch, wenn Exportdatei statisch ist
- Naehe zum Launch: hoch, aber nicht als naechster Schritt

Vorteile:

- echte vorhandene Inhalte
- moeglicherweise launchrelevant
- kann Kategorien und Woerter aus aktueller App-Welt retten

Nachteile:

- Supabase-Struktur ist gross und stark mit alter SRS-Logik gekoppelt
- `supabase_word_repository.dart` enthaelt `WordUserView`, alte SRS-Felder, RPCs, `is_mastered`, `pass_count`, `next_due_at` und weitere Altlogik
- ID-Mapping muss bewusst geplant werden
- SRS-Fortschritt darf nicht mitgenommen werden
- direkte App-Anbindung waere riskant

Fazit:

- Spaeter sinnvoll fuer echte Daten.
- Nicht der naechste Code-Schritt.
- Erst als statischer, gepruefter Export planen, nicht als direkte Supabase-Live-Abhaengigkeit.

### D. Manuelle Lokale Eingabe

Quelle:

- spaetere UI oder internes Tool fuer lokale Kategorien/Woerter

Bewertung:

- Risiko: mittel
- Aufwand: mittel bis hoch
- Datenqualitaet: variabel
- Offline-Tauglichkeit: hoch
- Testbarkeit: mittel
- Naehe zum Launch: mittel, aber UI-Aufwand

Vorteile:

- vollstaendig offline moeglich
- keine Supabase-Migration noetig
- Nutzer koennen spaeter eigene Daten erzeugen

Nachteile:

- braucht UI und App-Flows
- derzeit ausdruecklich nicht Ziel
- Validierung und Fehlerfaelle muessen bedacht werden

Fazit:

- Spaeter wichtig.
- Nicht fuer den naechsten isolierten Import-TDD-Schritt.

### E. JSON-/Asset-Import

Quelle:

- lokale JSON-Dateien oder Flutter-Assets mit Kategorien und Woertern

Bewertung:

- Risiko: niedrig bis mittel
- Aufwand: mittel
- Datenqualitaet: gut, wenn kuratiert
- Offline-Tauglichkeit: sehr hoch
- Testbarkeit: sehr hoch
- Naehe zum Launch: hoch als risikoarme V1-Bridge

Vorteile:

- klare Trennung von Code und Daten
- ohne Supabase nutzbar
- gut versionierbar
- gut validierbar
- gut testbar
- kann echte Startdaten liefern
- kann spaeter aus Supabase-Export erzeugt werden

Nachteile:

- Importformat muss definiert werden
- Validierung noetig
- Asset-Registrierung spaeter noetig, wenn in Flutter-App gebundelt
- Datenpflege ausserhalb von Dart-Konstanten braucht Disziplin

Fazit:

- Beste strategische Richtung fuer V1-Import.
- Sollte als naechster isolierter TDD-Pfad geplant werden.

### F. DeepL-/Wortimport Spaeter

Quelle:

- spaetere externe Wort-/Uebersetzungsquelle

Bewertung:

- Risiko: hoch
- Aufwand: hoch
- Datenqualitaet: potenziell hoch, aber pruefbeduerftig
- Offline-Tauglichkeit: niedrig bis mittel, wenn Online-Service noetig ist
- Testbarkeit: mittel
- Naehe zum Launch: niedrig fuer Offline-first-V1

Vorteile:

- koennte spaeter gute Wortdaten erzeugen
- passt zu langfristiger Wortimportstrategie

Nachteile:

- externe Abhaengigkeit
- Kosten/API/Fehlerfaelle
- nicht Offline-first als Basis
- zu gross fuer aktuellen lokalen Meilenstein

Fazit:

- Spaeteres Thema.
- Nicht fuer V1-Importstrategie blockierend.

### G. Alte `local_word_database.dart`

Quelle:

- `lib/features/words/data/local_word_database.dart`
- alte Datenbank `word_progress.db`

Bewertung:

- Risiko: sehr hoch
- Aufwand: hoch
- Datenqualitaet: fuer Inhaltsdaten unklar, fuer SRS-Fortschritt nicht geeignet
- Offline-Tauglichkeit: technisch lokal, fachlich inkompatibel
- Testbarkeit: niedrig bis mittel
- Naehe zum Launch: niedrig

Vorteile:

- existiert lokal
- kann spaeter analysiert werden, falls dort relevante lokale Daten liegen

Nachteile:

- anderes Schema
- alte A-SRS-/Refill-/Mirror-Logik
- `is_mastered`, `ever_enrolled`, `streak_in_stage`, `device_seq`, Refill-State
- Datenbankname `word_progress.db` darf nicht mit `talvori_local_v1.db` vermischt werden
- Fortschritt ist fachlich nicht kompatibel mit V1

Fazit:

- Fuer neue Engine nicht verwenden.
- Spaeter nur analysieren oder gezielt ignorieren.
- Nicht migrieren, vor allem keinen Fortschritt.

## 4. Empfehlung Fuer Version 1

Klare Empfehlung:

1. Kurzfristig:
   - bestehende kleine Seed-Daten als technische Smoke-Test-Daten behalten
   - keine echte App-Anbindung daran koppeln

2. Naechster strategischer Importpfad:
   - JSON-/Asset-Import fuer lokale Kategorien und Woerter planen und testgetrieben vorbereiten

3. Spaeter:
   - `word_hub_taxonomy.dart` kontrolliert als Kategorie-Strukturquelle nutzen
   - Supabase-Export als statische Exportdatei fuer echte Kategorien/Woerter pruefen

4. Ausdruecklich nicht verwenden:
   - alte `local_word_database.dart` als Quelle fuer neue Engine
   - alten SRS-Fortschritt
   - direkte Supabase-Live-Abfrage als Import im lokalen Engine-Pfad

Was die lokale Engine nicht blockiert:

- echte Datenquelle ist noch nicht final
- alter Fortschritt wird nicht migriert
- Supabase bleibt parallel aktiv
- die lokale Engine kann mit Seed- oder JSON-Daten weiter funktionieren

## 5. Strategie Fuer JSON-/Asset-Import

Ein JSON-/Asset-Import ist fuer V1 sinnvoller als immer groessere Dart-Konstanten.

### Dateistruktur

Moegliche Struktur:

- `assets/local_seed/v1/categories.json`
- oder `assets/local_import/v1/default_words.json`

Alternativ fuer Tests:

- Test-Fixtures unter `test/fixtures/local_import/`

Empfohlenes JSON-Format:

- Liste von Kategorien
- jede Kategorie enthaelt:
  - `id`
  - `name`
  - `description`
  - `sort_order`
  - `is_archived`
  - `words`
- jedes Wort enthaelt:
  - `id`
  - `term`
  - `translation`
  - `example_sentence`
  - `notes`
  - `sort_order`
  - `is_archived`

### Validierung

Validiert werden sollte:

- Kategorie-ID vorhanden und nicht leer
- Kategorie-Name vorhanden und nicht leer
- Wort-ID vorhanden und nicht leer
- `category_id` ergibt sich aus der Kategorie
- `term` vorhanden und nicht leer
- `translation` vorhanden und nicht leer
- `sort_order` Integer
- `is_archived` Boolean oder Default `false`
- keine doppelten IDs innerhalb der Datei

### Stabile IDs

Stabile IDs sind Pflicht fuer Idempotenz.

Empfehlung:

- Kategorie-IDs aus stabilen Slugs ableiten, z. B. `local-category-basics`
- Wort-IDs aus Kategorie-Slug plus Wort-Slug ableiten, z. B. `local-basics-hello`
- keine zufaelligen UUIDs in Importdateien

### Idempotenz

Mehrfachimport soll keine Duplikate erzeugen.

Umsetzungsidee:

- Import nutzt `CategoryRepository.upsertCategory(...)`
- Import nutzt `WordRepository.upsertWord(...)`
- bestehende IDs werden aktualisiert statt neu eingefuegt
- archivierte Eintraege koennen ueber `is_archived` gesetzt werden

### Kein Progress Beim Import

Import darf nicht erzeugen:

- `word_progress`
- `learning_sessions`
- `session_items`
- `review_history`

Progress entsteht danach separat ueber:

- `LocalProgressInitializationService.initializeProgressForCategoryAndMode(...)`

## 6. Strategie Fuer Supabase-Export Spaeter

Supabase-Export sollte nur theoretisch und spaeter geplant werden.

### Moegliche Exportdaten

Exportiert werden koennten:

- Kategorien
- Woerter
- Uebersetzungen
- Beispielsaetze, falls vorhanden
- Notizen, falls vorhanden
- Sortierung, falls vorhanden
- Archivstatus oder Aktivstatus, falls vorhanden

Nicht exportieren:

- `user_word_srs`
- `is_mastered`
- `pass_count`
- `next_due_at`
- alte Stage-Counts
- alte Queues
- alte Sessions
- alte Review-History

### ID-Mapping

Moegliche Strategie:

- lokale Haupt-IDs bleiben lokale stabile IDs
- Supabase-ID optional als `legacy_supabase_id` spaeter ergaenzen, falls Migration wichtig wird
- fuer V1 nicht blockierend

Wichtig:

- Supabase-ID darf nicht automatisch lokale Haupt-ID-Strategie ersetzen.
- Falls Export statisch ist, sollte eine Mapping-Tabelle oder Export-Metadaten geplant werden.

### Warum Fortschritt Nicht Uebernehmen

Kein SRS-Fortschritt wird uebernommen, weil:

- alte Regeln fachlich nicht V1-konform sind
- `is_mastered` in V1 keine Engine-Entscheidung steuert
- alte `pass_count`- und `next_due_at`-Werte andere Bedeutung haben koennen
- Requeue-/Refill-/Mirror-Daten nicht kompatibel sind
- neue lokale Engine bewusst sauber neu startet

### Risiken

- unvollstaendige Daten
- abweichende Feldnamen
- alte Views wie `WordUserView` mischen Inhalts- und Fortschrittsdaten
- direkte Supabase-Abhaengigkeit koennte Offline-first-Ziel verwischen
- Datenschutz/Auth/Exportrechte muessen spaeter beachtet werden

### Warum Nicht Der Naechste Code-Schritt

Supabase-Export ist nicht der naechste Code-Schritt, weil:

- JSON-Importformat zuerst stabil sein sollte
- Importtests ohne Supabase einfacher und sicherer sind
- bestehende Supabase-Dateien nicht veraendert werden sollen
- lokale Engine keinen Supabase-Export braucht, um stabil zu bleiben

## 7. Strategie Fuer `word_hub_taxonomy.dart`

`word_hub_taxonomy.dart` liefert aktuell:

- Bereiche (`HubSection`)
- Unterkategorien (`HubSubcat`)
- Keys
- Labels
- optionale `supabaseId`

Es liefert nicht:

- Woerter
- Uebersetzungen
- Beispielsaetze
- Notizen

### Nutzung Als Kategorie-Struktur

Moeglich waere spaeter:

- lokale Kategorien aus `HubSubcat.key` und `HubSubcat.label` erzeugen
- `HubSection` als Gruppierung oder Beschreibung verwenden
- `sort_order` aus Listenposition ableiten

### Problem `supabaseId`

`supabaseId` ist problematisch, wenn es:

- als lokale Haupt-ID genutzt wird
- direkte Supabase-Abhaengigkeit in den lokalen Import bringt
- lokale Datenquelle und Supabase-Welt vermischt

Empfehlung:

- `supabaseId` fuer V1 ignorieren
- falls noetig spaeter als Legacy-Mapping verwenden
- lokale IDs aus `key` ableiten

### Nicht Unkontrolliert Vermischen

Die Taxonomie liegt im alten Word-Feature-Kontext. Deshalb darf sie nicht unkontrolliert:

- Supabase-IDs erzwingen
- alte WordHub-Provider aktivieren
- bestehende UI-Flows beeinflussen
- lokale Importlogik direkt an bestehende WordHub-Screens koppeln

## 8. Strategie Fuer Alte `local_word_database.dart`

Die alte Datei:

- nutzt `word_progress.db`
- enthaelt alte Tabellen:
  - `word_progress`
  - `word_progress_deck_state`
  - `category_refill_state`
- enthaelt alte A-SRS-/Refill-nahe Funktionen
- nutzt Felder wie `is_mastered`, `ever_enrolled`, `streak_in_stage`, `device_seq`

### Warum Nicht Fuer Neue Engine Verwenden

Sie sollte nicht fuer die neue Engine verwendet werden, weil:

- Schema nicht kompatibel ist
- Fortschrittsmodell nicht V1-konform ist
- Datenbankname absichtlich von `talvori_local_v1.db` getrennt wurde
- alte Logik moeglicherweise noch von bestehenden App-Flows genutzt wird
- Aenderungen daran bestehende App-Funktionen brechen koennten

### Konflikte Mit `talvori_local_v1.db`

Konflikte:

- gleicher Tabellenname `word_progress`, aber anderes Schema
- alte Stage-Integer statt V1-Enum-Strings
- alter Fortschritt mit `is_mastered`
- alte Refill-/Deck-State-Tabellen
- andere Primaerschluessel

### Spaetere Optionen

Spaeter moeglich:

- nur lesend analysieren
- ignorieren, bis alte Flows entfernt sind
- gezielt loeschen erst nach vollstaendiger Ablösung
- niemals direkt in neue V1-Progress-Daten migrieren

Empfehlung:

- fuer V1 ignorieren und nicht anfassen

## 9. Spaetere Tests

Sinnvolle Tests fuer einen spaeteren lokalen Importservice:

- `local_import_creates_categories_and_words`
- `local_import_is_idempotent`
- `local_import_does_not_create_progress`
- `imported_words_can_initialize_progress_and_start_session`
- `import_does_not_touch_old_word_progress_database`
- `import_does_not_require_supabase`
- `local_import_rejects_missing_category_id`
- `local_import_rejects_missing_word_term`
- `local_import_rejects_duplicate_ids_in_import_file`
- `local_import_can_archive_imported_words`

Wichtige Testregeln:

- In-Memory-SQLite oder temporaere Testdatenbank nutzen
- keine echte App-Datenbank
- kein Supabase
- keine alte `word_progress.db`
- keine UI
- keine Navigation

## 10. Was Weiterhin Nicht Passieren Darf

Weiterhin nicht erlaubt:

- keine UI-Anbindung
- keine Navigation
- keine Supabase-Entfernung
- kein direkter Supabase-Live-Import
- kein alter Fortschrittsimport
- keine alten Sessions
- keine alte Review-History
- keine Aenderung bestehender App-Flows
- keine Aenderung an `main.dart`
- keine Aenderung an `word_providers.dart`
- keine Aenderung an `learn_mode_controller.dart`
- keine Aenderung an `learn_mode_screen.dart`
- keine Aenderung an `local_word_database.dart`
- keine automatische Seed-/Import-Ausfuehrung beim App-Start

## 11. Kleinster Naechster TDD-Schritt

Empfohlener kleinster naechster TDD-Schritt:

1. Einen lokalen, UI-neutralen Importservice planen oder implementieren:
   - z. B. `LocalJsonImportService`
2. Zuerst keine Assets einbinden.
3. Stattdessen eine kleine Test-Fixture als In-Memory-Datenstruktur oder JSON-String im Test verwenden.
4. Test zuerst:
   - `local_import_creates_categories_and_words`
5. Importservice soll nur:
   - validierte Kategorien und Woerter entgegennehmen
   - `CategoryRepository.upsertCategory(...)` verwenden
   - `WordRepository.upsertWord(...)` verwenden
6. Importservice soll nicht:
   - Progress erzeugen
   - Sessions erzeugen
   - Review-History schreiben
   - Supabase lesen
   - alte lokale DB beruehren
   - UI kennen

Danach als zweite kleine Tests:

- `local_import_is_idempotent`
- `local_import_does_not_create_progress`
- `imported_words_can_initialize_progress_and_start_session`

Diese Reihenfolge bleibt lokal, isoliert und testbar, ohne den abgeschlossenen Offline-first-Lernblock zu gefaehrden.

