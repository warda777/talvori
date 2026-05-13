# 24 Local Category Word Progress Summary

Stand: 2026-05-13

## Zweck

Dieses Dokument fasst den lokalen Kategorie-/Wort-/Progress-Basisblock zusammen.

Der Block erweitert die isolierte lokale SQLite-Schicht unter `lib/core/local_database/`, ohne UI, Supabase, bestehende App-Flows oder echte App-Daten anzubinden.

## Lokale Repository-Bausteine

Aktuell existieren fuer diesen Basisblock:

- `CategoryRepository`
- `WordRepository`
- `WordProgressRepository`
- `LocalCategory`
- `LocalWord`

Die Repositories arbeiten direkt gegen die vorhandene lokale SQLite-Struktur:

- `categories`
- `words`
- `word_progress`

Damit gibt es jetzt eine minimale lokale Basis, um Kategorien und Woerter zu speichern, Wort-IDs zu laden und fuer diese Woerter SRS-Fortschritt pro Lernmodus zu initialisieren.

## CategoryRepository

`CategoryRepository` verwaltet lokale Kategorie-Basisdaten.

Aufgaben:

- Kategorie neu anlegen
- Kategorie mit gleicher ID aktualisieren
- Kategorie nach ID laden
- Kategorien sortiert laden
- archivierte Kategorien standardmaessig ausblenden
- archivierte Kategorien optional mitladen
- Kategorie archivieren oder wieder aktivieren
- `updated_at` beim Archivieren aktualisieren

Sortierung:

- `sort_order ASC`
- danach `name ASC`

Nicht Aufgabe von `CategoryRepository`:

- UI-State
- Supabase-Zugriff
- WordHub-Taxonomie-Mapping
- SRS-Fortschritt
- Session-Erstellung
- Import echter App-Daten

## WordRepository

`WordRepository` verwaltet lokale Wort-Basisdaten.

Aufgaben:

- Wort neu anlegen
- Wort mit gleicher ID aktualisieren
- `category_id` setzen
- Wort nach ID laden
- Woerter fuer eine Kategorie laden
- archivierte Woerter standardmaessig ausblenden
- archivierte Woerter optional mitladen
- Wort archivieren oder wieder aktivieren
- `updated_at` beim Archivieren aktualisieren
- Wort-IDs fuer eine Kategorie laden

Sortierung:

- `sort_order ASC`
- danach `term ASC`

Nicht Aufgabe von `WordRepository`:

- SRS-Fortschritt erzeugen
- Reviews speichern
- Sessions erstellen
- Supabase importieren
- DeepL-Import
- UI-Adapter fuer bestehende App-Views

## Zusammenspiel Mit WordProgressRepository

`WordRepository` erzeugt keinen Lernfortschritt selbst.

Der geplante Ablauf fuer Progress-Initialisierung ist:

1. Lokale Kategorien existieren in `categories`.
2. Lokale Woerter existieren in `words`.
3. `WordRepository.loadWordIdsForCategory(...)` liefert aktive Wort-IDs einer Kategorie.
4. Eine spaetere Service- oder Adapter-Schicht ruft fuer jede Wort-ID `WordProgressRepository.ensureProgressForWord(...)` auf.
5. `WordProgressRepository` erzeugt fehlenden Fortschritt als `S0`.
6. Der Fortschritt wird getrennt pro `word_id`, `category_id` und `mode_id` gespeichert.

Wichtig:

- Archivierte Woerter werden standardmaessig nicht fuer die Progress-Initialisierung geliefert.
- Fortschritt wird pro Lernmodus getrennt angelegt.
- Erneutes Initialisieren erzeugt wegen der bestehenden Repository-Logik und SQLite-Unique-Regel keine doppelten Progress-Eintraege.

## Tests

### CategoryRepository

Datei:

- `test/core/local_database/category_repository_test.dart`

Abgesichert wird:

- `upsert_category_creates_category`
  - legt eine Kategorie an
  - prueft Kernfelder

- `upsert_category_updates_existing_category`
  - aktualisiert eine bestehende Kategorie
  - erzeugt keinen zweiten Datensatz bei gleicher ID

- `load_category_by_id_returns_matching_category`
  - laedt genau die passende Kategorie
  - gibt `null` fuer fehlende Kategorie zurueck

- `load_categories_returns_non_archived_sorted_by_sort_order_then_name`
  - blendet archivierte Kategorien standardmaessig aus
  - sortiert stabil nach `sort_order`, dann `name`

- `load_categories_can_include_archived`
  - laedt archivierte Kategorien bei expliziter Option mit

- `archive_category_sets_is_archived_and_updated_at`
  - setzt Archivstatus
  - aktualisiert `updated_at`

### WordRepository

Datei:

- `test/core/local_database/word_repository_test.dart`

Abgesichert wird:

- `upsert_word_creates_word`
  - legt ein Wort an
  - prueft Kernfelder inklusive `category_id`

- `upsert_word_updates_existing_word`
  - aktualisiert ein bestehendes Wort
  - erzeugt keinen zweiten Datensatz bei gleicher ID

- `load_word_by_id_returns_matching_word`
  - laedt genau das passende Wort
  - gibt `null` fuer fehlendes Wort zurueck

- `load_words_for_category_returns_only_that_category_sorted`
  - laedt nur Woerter der angegebenen Kategorie
  - sortiert nach `sort_order`, dann `term`

- `load_words_for_category_excludes_archived_by_default`
  - blendet archivierte Woerter standardmaessig aus

- `load_words_for_category_can_include_archived`
  - laedt archivierte Woerter bei expliziter Option mit

- `archive_word_sets_is_archived_and_updated_at`
  - setzt Archivstatus
  - aktualisiert `updated_at`

- `load_word_ids_for_category_returns_ids_for_progress_initialization`
  - liefert Wort-IDs einer Kategorie in stabiler Sortierung
  - blendet archivierte Woerter standardmaessig aus

### Word Progress Initialization Integration

Datei:

- `test/core/local_database/word_progress_initialization_integration_test.dart`

Abgesichert wird:

- `word_ids_can_be_used_to_initialize_progress_for_all_modes`
  - lokale Kategorie wird erzeugt
  - lokale Woerter werden erzeugt
  - aktive Wort-IDs werden ueber `WordRepository` geladen
  - fuer jede Wort-ID wird Fortschritt fuer `time`, `adaptive` und `hybrid` initialisiert
  - jeder Fortschritt startet in `S0`
  - Fortschritt ist pro Modus getrennt
  - erneuter Aufruf erzeugt keine doppelten Progress-Eintraege
  - archivierte Woerter werden standardmaessig nicht initialisiert

## Weiterhin Geltende Grenzen

Dieser Block bleibt bewusst lokal und isoliert.

Nicht umgesetzt:

- keine UI-Anbindung
- keine Supabase-Entfernung
- kein echter Import bestehender App-Daten
- keine App-Flow-Aenderung
- keine automatische Progress-Initialisierung beim Oeffnen einer echten Kategorie
- kein WordHub-Taxonomie-Mapping
- kein DeepL- oder Wortimport
- kein Backup oder Export

Die bestehende App nutzt diese lokalen Repositories noch nicht.

## Sinnvolle Naechste Schritte

Sinnvolle naechste kleine Schritte:

1. Einen kleinen lokalen Service planen, der fuer eine Kategorie und einen Modus Progress fuer alle aktiven Woerter vorbereitet.
2. Diesen Service isoliert testen, ohne UI oder App-Flow anzubinden.
3. Eine lokale Seed-/Import-Strategie fuer erste Kategorien und Woerter planen.
4. Pruefen, ob bestehende App-Daten, `word_hub_taxonomy.dart` oder Supabase-Exporte spaeter als Datenquelle dienen sollen.
5. Eine App-Anbindungsstrategie vorbereiten, bei der bestehende ViewModels erst nach stabiler lokaler Datenbasis umgestellt werden.

Empfehlung:

Der naechste kleinste technische Schritt ist ein isolierter `LocalProgressInitializationService`, der `WordRepository.loadWordIdsForCategory(...)` und `WordProgressRepository.ensureProgressForWord(...)` koordiniert. Dieser Service sollte weiterhin keine UI-, Supabase- oder App-Flow-Abhaengigkeit bekommen.
