# 23 Local Category Word Repository Plan

Stand: 2026-05-13

## Zweck

Dieses Dokument plant den naechsten kleinen lokalen Datenbank-Schritt fuer Kategorien und Woerter.

Es beschreibt keine Implementierung und keinen Dart-Code. Die bestehende App, UI, Supabase-Anbindung und App-Flows bleiben unveraendert.

Der Schritt soll die vorhandene lokale SQLite-Schicht unter `lib/core/local_database/` so erweitern, dass `LocalSrsSessionService` spaeter nicht nur mit vorbereiteten `word_progress`-Eintraegen getestet werden kann, sondern auch eine lokale Kategorie-/Wortbasis bekommt.

## Ausgangslage

Das lokale Schema enthaelt bereits:

- `categories`
- `words`
- `word_progress`
- `review_history`
- `learning_sessions`
- `session_items`
- `settings`

Die Tabellen `categories` und `words` sind bereits im Schema vorhanden.

`WordProgressRepository` kann Fortschritt fuer Woerter initialisieren und laden, setzt aber voraus, dass die zugehoerigen `categories`- und `words`-Datensaetze bereits existieren.

Der naechste kleine Schritt ist daher:

- `CategoryRepository`
- `WordRepository`
- isolierte Repository-Tests mit In-Memory-SQLite

## CategoryRepository

### Aufgaben

`CategoryRepository` soll Version 1 nur lokale Kategorie-Basisdaten speichern und laden.

Aufgaben:

- Kategorien lokal speichern
- Kategorien laden
- Kategorie nach ID laden
- Kategorien sortiert laden
- Kategorien archivieren

Nicht Aufgabe von `CategoryRepository`:

- UI-State verwalten
- Supabase lesen oder schreiben
- WordHub-Taxonomie mappen
- Lernfortschritt berechnen
- Session-Queues bauen
- echte App-Daten importieren

### Datenmodell

Die lokale Kategorie entspricht der Tabelle `categories`.

Version-1-Felder:

- `id`
- `name`
- `description`
- `sort_order`
- `is_archived`
- `created_at`
- `updated_at`

Optional spaeter laut Plan:

- `source_language`
- `target_language`
- `icon_name`
- `color_value`
- `legacy_supabase_id`

Diese optionalen Felder werden in diesem Schritt nicht umgesetzt.

### Minimale Methoden Fuer Version 1

Vorgeschlagene minimale Methoden:

- `upsertCategory(...)`
  - speichert eine Kategorie neu oder aktualisiert sie
  - nutzt lokale UUID, wenn keine ID uebergeben wird

- `loadCategoryById(id)`
  - laedt eine Kategorie nach ID
  - gibt `null` zurueck, wenn sie nicht existiert

- `loadCategories({includeArchived = false})`
  - laedt Kategorien sortiert
  - Standard: archivierte Kategorien ausblenden
  - Sortierung: `sort_order ASC`, danach `name ASC`

- `archiveCategory({required id, required archived, required updatedAt})`
  - setzt `is_archived`
  - aktualisiert `updated_at`

Vorerst nicht noetig:

- Kategorie loeschen
- Batch-Import
- Reorder-API
- Sprach-/Icon-/Farb-Metadaten
- Supabase-ID-Mapping

## WordRepository

### Aufgaben

`WordRepository` soll Version 1 nur lokale Wort-Basisdaten speichern und laden.

Aufgaben:

- Woerter lokal speichern
- Woerter pro Kategorie laden
- Wort nach ID laden
- Woerter archivieren
- Woerter fuer `word_progress` vorbereiten

Nicht Aufgabe von `WordRepository`:

- SRS-Fortschritt schreiben
- Reviews speichern
- Sessions erstellen
- Supabase importieren
- DeepL-Import ausfuehren
- UI-Adapter fuer `WordUserView` liefern

### Datenmodell

Die lokalen Woerter entsprechen der Tabelle `words`.

Version-1-Felder:

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

Nicht in Version 1:

- Audio
- Artikel
- Wortart
- DeepL-Metadaten
- Synonyme
- Tags
- `legacy_supabase_id`

### Minimale Methoden Fuer Version 1

Vorgeschlagene minimale Methoden:

- `upsertWord(...)`
  - speichert ein Wort neu oder aktualisiert es
  - setzt `category_id`
  - nutzt lokale UUID, wenn keine ID uebergeben wird

- `loadWordById(id)`
  - laedt ein Wort nach ID
  - gibt `null` zurueck, wenn es nicht existiert

- `loadWordsForCategory({required categoryId, includeArchived = false})`
  - laedt Woerter einer Kategorie
  - Standard: archivierte Woerter ausblenden
  - Sortierung: `sort_order ASC`, danach `term ASC`

- `archiveWord({required id, required archived, required updatedAt})`
  - setzt `is_archived`
  - aktualisiert `updated_at`

- `loadWordIdsForCategory({required categoryId, includeArchived = false})`
  - liefert nur IDs
  - sinnvoll, um danach `WordProgressRepository.ensureProgressForWord(...)` pro Modus aufzurufen

### Vorbereitung Fuer word_progress

`WordRepository` soll `word_progress` nicht selbst erzeugen.

Stattdessen:

1. `WordRepository.loadWordIdsForCategory(...)` laedt lokale Wort-IDs.
2. Eine spaetere Service-/Adapter-Schicht ruft fuer jede ID `WordProgressRepository.ensureProgressForWord(...)` auf.
3. Dadurch bleibt die Trennung klar:
   - `WordRepository` verwaltet Wortbasisdaten
   - `WordProgressRepository` verwaltet SRS-Fortschritt

Optional spaeter:

- `ensureProgressForCategoryAndMode(...)` als eigener lokaler Service, nicht direkt im `WordRepository`.

## Erste Tests

### CategoryRepository-Tests

Datei spaeter:

- `test/core/local_database/category_repository_test.dart`

Erste Tests:

- `upsert_category_creates_category`
  - legt Kategorie an
  - prueft Pflichtfelder

- `upsert_category_updates_existing_category`
  - aktualisiert Name/Beschreibung/Sortierung
  - erzeugt keinen zweiten Datensatz

- `load_category_by_id_returns_matching_category`
  - laedt nur die gewuenschte Kategorie

- `load_categories_returns_non_archived_sorted_by_sort_order_then_name`
  - blendet archivierte Kategorien standardmaessig aus
  - sortiert stabil

- `load_categories_can_include_archived`
  - laedt archivierte Kategorien, wenn explizit gewuenscht

- `archive_category_sets_is_archived_and_updated_at`
  - setzt Archivstatus
  - aktualisiert `updated_at`

### WordRepository-Tests

Datei spaeter:

- `test/core/local_database/word_repository_test.dart`

Erste Tests:

- `upsert_word_creates_word`
  - legt Wort in bestehender Kategorie an
  - prueft Pflichtfelder

- `upsert_word_updates_existing_word`
  - aktualisiert Term/Uebersetzung/Notizen/Sortierung
  - erzeugt keinen zweiten Datensatz

- `load_word_by_id_returns_matching_word`
  - laedt nur das gewuenschte Wort

- `load_words_for_category_returns_only_that_category_sorted`
  - ignoriert Woerter anderer Kategorien
  - sortiert nach `sort_order`, danach `term`

- `load_words_for_category_excludes_archived_by_default`
  - archivierte Woerter werden standardmaessig ausgeblendet

- `load_words_for_category_can_include_archived`
  - archivierte Woerter koennen explizit mitgeladen werden

- `archive_word_sets_is_archived_and_updated_at`
  - setzt Archivstatus
  - aktualisiert `updated_at`

- `load_word_ids_for_category_returns_ids_for_progress_initialization`
  - liefert nur IDs aktiver Woerter einer Kategorie

### Integrationsnaher Repository-Test

Optional als zweiter Schritt, nicht sofort:

- `word_ids_can_be_used_to_initialize_progress_for_all_modes`

Erwartung:

- Kategorie und Woerter werden lokal gespeichert
- `loadWordIdsForCategory(...)` liefert IDs
- `WordProgressRepository.ensureProgressForWord(...)` erzeugt S0-Fortschritt pro Modus

Dieser Test betrifft bereits die Zusammenarbeit zweier Repositories und sollte erst nach den Einzeltests geschrieben werden.

## Lokale Test- Und Seed-Daten

### Minimale Test-Kategorien

Beispielhafte lokale Kategorien:

- `category-basics`
  - `name`: `Basics`
  - `description`: `Grundwortschatz`
  - `sort_order`: `0`
  - `is_archived`: `0`

- `category-travel`
  - `name`: `Travel`
  - `description`: `Reisen`
  - `sort_order`: `1`
  - `is_archived`: `0`

- `category-archived`
  - `name`: `Archived`
  - `description`: `Archiviert`
  - `sort_order`: `99`
  - `is_archived`: `1`

### Minimale Test-Woerter

Beispielhafte lokale Woerter fuer `category-basics`:

- `word-hello`
  - `term`: `hello`
  - `translation`: `hallo`
  - `example_sentence`: `Hello, how are you?`
  - `notes`: `Begruessung`
  - `sort_order`: `0`
  - `is_archived`: `0`

- `word-thanks`
  - `term`: `thanks`
  - `translation`: `danke`
  - `example_sentence`: `Thanks for your help.`
  - `notes`: `Hoeflichkeit`
  - `sort_order`: `1`
  - `is_archived`: `0`

- `word-old`
  - `term`: `old`
  - `translation`: `alt`
  - `example_sentence`: `This is old.`
  - `notes`: `archivierter Testfall`
  - `sort_order`: `99`
  - `is_archived`: `1`

Beispielhafte lokale Woerter fuer `category-travel`:

- `word-ticket`
  - `term`: `ticket`
  - `translation`: `Fahrkarte`
  - `sort_order`: `0`
  - `is_archived`: `0`

Diese Testdaten sollen klein bleiben und nur Repository-Verhalten absichern.

## App-Fragen Die Offen Bleiben

- Woher echte Woerter beim Launch kommen. [PRÜFEN]
- Ob `word_hub_taxonomy.dart` spaeter auf lokale Kategorien gemappt werden muss. [PRÜFEN]
- Ob bestehende Supabase-Woerter exportiert werden. [PRÜFEN]
- Ob manuelle lokale Eingabe fuer eine erste Offline-Version reicht. [PRÜFEN]
- Ob `legacy_supabase_id` spaeter fuer Kategorien oder Woerter ergaenzt werden soll. [PRÜFEN]
- Ob vorhandene lokale Legacy-DB `features/words/data/local_word_database.dart` ignoriert, migriert oder separat gehalten wird. [PRÜFEN]
- Wie Duplikate in der UI dargestellt werden, da `words` bewusst keinen Unique-Index auf `category_id, term, translation` hat. [PRÜFEN]
- Wie lokale Seed-Daten versioniert werden sollen. [PRÜFEN]

## Bewusst Noch Nicht Umgesetzt

Nicht Teil dieses Schritts:

- UI-Anbindung
- Supabase-Entfernung
- DeepL/Wortimport
- echte Migration
- `WordUserView`-Adapter
- Import echter App-Daten
- Backup/Export
- lokale Datenbank-Oeffnung im App-Start
- Kategorie-/Wort-Bearbeitung in der UI
- Progress-Initialisierung fuer alle Kategorien beim App-Start
- Loeschlogik fuer Kategorien oder Woerter

## Empfohlener Naechster TDD-Schritt

Als naechster kleiner Umsetzungsschritt bietet sich `CategoryRepository` an.

Reihenfolge:

1. `CategoryRepository`-Modell und Repository isoliert erstellen.
2. `category_repository_test.dart` mit In-Memory-SQLite schreiben.
3. Nur Kategorie-Tests laufen lassen.
4. Danach `WordRepository` analog umsetzen.
5. Erst danach pruefen, wie Wort-IDs in `WordProgressRepository.ensureProgressForWord(...)` eingespeist werden.

Warum diese Reihenfolge:

- `words.category_id` haengt per Foreign Key von `categories.id` ab.
- Kategorie-Tests sind klein und risikoarm.
- Word-Tests koennen danach auf einem stabilen Kategorie-Repository aufbauen.

## Fertig Fuer Umsetzung?

Der Plan ist bereit fuer den naechsten minimalen TDD-Schritt:

- `CategoryRepository`
- `test/core/local_database/category_repository_test.dart`

Noch nicht bereit ist:

- echte App-Anbindung
- Import echter Woerter
- Supabase-Ablösung
