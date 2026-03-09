# 🗄️ Supabase Architecture Documentation

> **Letzte Aktualisierung:** 12.02.2025  
> **Version:** 1.6  
> **Status:** ✅ Aktive Entwicklung

## 📋 Übersicht

Diese Dokumentation beschreibt alle Supabase-Tabellen, Views, RPC Functions und deren Verwendung in der Talvori-App.

---

## 🗂️ Tabellen (Tables)

### 1. `words` - Hauptwörter-Tabelle

**Zweck:** Speichert alle Wörter mit Übersetzungen und Metadaten

**Felder:**

- `id` (String) - Eindeutige UUID
- `text` (String) - Wort-Text
- `translation` (String) - Übersetzung
- `from_lang` (String) - Quellsprache
- `to_lang` (String) - Zielsprache
- `deck_id` (String?) - Optional: Deck-Zuordnung
- `favorite` (Boolean) - Favorit-Status
- `created_at` (DateTime) - Erstellungsdatum
- `due_at` (DateTime?) - Fälligkeitsdatum
- `srs_stage` (Integer) - SRS-Stufe

**Verwendung in der App:**

- `fetchRecentWords()` - Neueste Wörter laden
- `testIngestWord()` - Test-Funktion
- Word-Erstellung in Edge Functions

**Aktionen:** SELECT, INSERT, UPDATE

---

### 2. `categories` - Kategorien-Tabelle

**Zweck:** Organisiert Wörter in thematische Kategorien

**Felder:**

- `id` (String) - Eindeutige UUID
- `name` (String) - Kategorie-Name
- `slug` (String) - URL-freundlicher Name
- `group_slug` (String?) - Gruppenzuordnung
- `group_name` (String?) - Gruppenname
- `order_index` (Integer?) - Sortierreihenfolge
- `type` (String) - Kategorie-Typ

**Verwendung in der App:**

- `_ensureCategorySlug()` - UUID zu Slug konvertieren
- `findCategoryIdByName()` - Kategorie-ID per Name finden
- `fetchAllCategories()` - Alle Kategorien laden
- Auth-Check in `main.dart`

**Aktionen:** SELECT

---

### 3. `user_words` - User-Wörter Verknüpfung

**Zweck:** Verknüpft Benutzer mit Wörtern (Meine Wörter, Favoriten)

**Felder:**

- `user_id` (String) - Benutzer-UUID
- `word_id` (String) - Wort-UUID
- `picked` (Boolean) - In "Meine Wörter" markiert
- `created_at` (DateTime) - Erstellungsdatum

**Verwendung in der App:**

- `addToMyWords()` - Wort zu "Meine Wörter" hinzufügen
- `removeFromMyWords()` - Wort aus "Meine Wörter" entfernen
- `getPickedWordIds()` - Gemerkte Wort-IDs abfragen
- `fetchMyWords()` - Meine Wörter laden
- `countMyWords()` - Anzahl gemerkter Wörter

**Aktionen:** SELECT, INSERT, DELETE, UPSERT

---

### 4. `user_word_srs` - Modus-spezifischer SRS-Zustand

**Zweck:** Speichert SRS-Progress pro User/Wort/Kategorie/Modus (time, adaptive, hybrid)

**Felder:**

- `user_id`, `word_id`, `category_id`, `mode` (PK)
- `stage` (Integer) - SRS-Stufe 0–5
- `ef`, `streak`, `lapses` - SM-2-ähnliche Metriken
- `next_due_at`, `last_reviewed_at` - Zeitstempel

**Verwendung in der App:**

- `fetchLearnQueueForMode()` - Queue via `v_words_user_srs` abfragen
- `submitReview()` - Review via `fn_user_review_time_mode`, `fn_user_review_hybrid_mode`, `fn_user_review_mode`
- `fn_user_category_progress` - Stage-Zähler für UI

**Aktionen:** SELECT, INSERT, UPDATE

---

### 5. `a_refill_state` / `a_deck_state` - A-SRS State

**Zweck:** A-SRS Refill-Zähler und Deck-State (Text-Keys für user_id, category_id)

**Verwendung:** `fn_a_srs_refill_enroll`, `fn_user_learn_queue_adaptive_impl`, `fn_a_srs_next_refill_counter`

---

## 👁️ Views (Sichten)

### 4. `words_view` - Wörter-View

**Zweck:** Optimierte Sicht für komplexe Wörter-Abfragen

**Verwendung in der App:**

- `fetchByFilter()` - Gefilterte Wörter-Suche mit Pagination
- Unterstützt Filter nach: Kategorie, Level, POS, Domain, Query

**Aktionen:** SELECT (mit komplexen Filtern)

---

### 5. `v_words_with_categories` - Wörter mit Kategorien

**Zweck:** Join-View für Wörter mit Kategorie-Informationen

**Verwendung in der App:**

- Edge Function `translate-missing`
- Komplexe Abfragen mit Kategorie-Daten

**Aktionen:** SELECT

---

### 6. `v_words_user` - Wörter mit User-Flags

**Zweck:** Optimierte Sicht für Wörter mit allen User-bezogenen Informationen

**Spalten:**

- Basis-Wort-Daten: `id`, `text`, `translation`, `level`, `pos`
- User-Flags: `in_my_words`, `favorite_user`, `picked_user`, `srs_stage_user`
- Meta-Daten: `next_due_at_user`, `user_added_at`, `category_slug`, `group_slug`

**Verwendung in der App:**

- `fetchWordUserViewsByFilter()` - Gefilterte Wörter mit User-Flags
- Quick Sets Filter: My Words, Favorites, Known Words, My Mix
- Mix Feature: Multi-category word collections
- Word List Screen: Alle Listen mit User-Status

**Aktionen:** SELECT (mit komplexen Filtern und User-Flags)

---

### 7. `v_words_user_srs` - Wörter mit SRS-Daten pro Modus

**Zweck:** View mit Word-Details + SRS-Daten für time/adaptive/hybrid; `word_id`, `srs_stage_user`, `next_due_at`

**Verwendung:** `fetchLearnQueueForMode`, `fetchLearnQueueAdaptive`, `fetchWordUserViewsByIds()` – zentrale Quelle für alle SRS-Modi

---

## ⚙️ RPC Functions (Stored Procedures)

### Lern-System Functions

#### `fn_user_stage_counts`

**Zweck:** Anzahl der Wörter pro SRS-Stufe pro Kategorie
**Parameter:** `cat` (String) - Kategorie-ID
**Rückgabe:** `stage` (Integer), `cnt` (Integer)
**Verwendung:** `fetchStageCounts()` - Stufen-Balken in UI

#### `fn_user_workload_today`

**Zweck:** Tägliche Arbeitslast (fällige + neue Wörter)
**Parameter:** `cat` (String) - Kategorie-ID
**Rückgabe:** `newTotal` (Integer), `dueToday` (Integer)
**Verwendung:** `fetchWorkloadToday()` - Tägliche Ziele

#### `fn_user_learn_queue`

**Zweck:** Alle Lern-Wörter einer Kategorie
**Parameter:** `cat` (String), `take` (Integer)
**Rückgabe:** Liste von `WordUserView`
**Verwendung:** `fetchLearnQueueAll()` - Komplette Lern-Queue

#### `fetch_learn_queue_for_mode`

**Zweck:** Lern-Queue für T-SRS und Hybrid (mit stage-Parameter)
**Parameter:** `p_category_id`, `p_mode`, `p_stage`, `p_limit`

#### `fn_user_learn_queue_adaptive_impl`

**Zweck:** A-SRS Lern-Queue (S1–S5, ohne S0); nutzt `a_refill_state`, `a_deck_state`

#### `fn_user_review_mode`

**Zweck:** Review für A-SRS (adaptive Mode)
**Parameter:** `p_word`, `p_result`, `p_mode` (adaptive)
**Rückgabe:** `srs_stage`, `next_due_at`

#### `fn_user_review_time_mode`

**Zweck:** Review für T-SRS (time Mode); persistiert in `user_word_srs` mode='time'

#### `fn_user_review_hybrid_mode`

**Zweck:** Review für Hybrid Mode; persistiert in `user_word_srs` mode='hybrid'

#### `fn_a_srs_refill_enroll`, `fn_a_srs_s0_correct`, `fn_requeue_s0_fail`

**Zweck:** A-SRS Refill, S0→S1 bei korrektem Swipe, S0 bei falschem Swipe zurück in Queue

#### `fn_user_review` (veraltet)

**Hinweis:** Ersetzt durch `fn_user_review_mode`, `fn_user_review_time_mode`, `fn_user_review_hybrid_mode`.

#### `fn_user_category_progress`

**Zweck:** Fortschritt einer Kategorie
**Parameter:** `cat` (String) - Kategorie-ID
**Rückgabe:** Stufen-Array, Gesamtanzahl, fällige Wörter
**Verwendung:** `fetchCategoryProgress()` - Fortschritts-Anzeige

### Single-Session (Single Mode)

#### `fn_single_session_seed`

**Zweck:** Startzustand für Single-Session vorbereiten (füllt SRC-Bucket)
**Parameter:** `p_category_id` (String), `p_stage` (Integer), `p_limit` (Integer)
**Verwendung:** `singleSeed(catId, stage)`

#### `fn_single_session_counts`

**Zweck:** Zähler für Session-Buckets ermitteln
**Parameter:** `p_category_id` (String), `p_stage` (Integer)
**Rückgabe:** `src`, `sr1`, `sr2` (Integer)
**Verwendung:** `singleCounts(catId, stage)`

#### `fn_single_session_move`

**Zweck:** Aktuelle Karte in SR1/SR2 verschieben
**Parameter:** `p_category_id` (String), `p_stage` (Integer), `p_word_id` (String), `p_correct` (Boolean)
**Verwendung:** `singleMove(catId, stage, wordId, correct)`

#### `fn_single_session_reset`

**Zweck:** Session zurücksetzen (alle Karten zurück nach SRC)
**Parameter:** `p_category_id` (String), `p_stage` (Integer)
**Verwendung:** `singleReset(catId, stage)`

#### `fn_single_session_next`

**Zweck:** Nächste Karte aus SRC (Single-Session) liefern
**Parameter:** `p_category_id` (String), `p_stage` (Integer)
**Rückgabe:** `{ word_id, bucket }` (als Map oder List mit erster Zeile)
**Verwendung:** `singleNextWordId(catId, stage)`

### Kategorie-Management Functions

#### `fn_reset_user_category`

**Zweck:** Kategorie für Benutzer zurücksetzen
**Parameter:** `p_category_id` (String) - Kategorie-ID
**Verwendung:** `resetCategory()` - Kategorie-Reset

#### `fn_seed_user_category`

**Zweck:** Kategorie für Start vorbereiten
**Parameter:** `p_category_id` (String) - Kategorie-ID
**Verwendung:** `seedForStart()` - Lern-Session starten

#### `fn_category_word_count`

**Zweck:** Wort-Anzahl pro Kategorie
**Parameter:** `p_category_id` (String) - Kategorie-ID
**Rückgabe:** Anzahl Wörter
**Verwendung:** `getCategoryWordCount()` - Kategorie-Statistiken

### Stage-Wörter Abfrage

#### `fetchWordsByStage`

**Zweck:** Lädt alle Wörter für einen bestimmten Stage einer Kategorie
**Parameter:** 
- `categoryId` (String) - Kategorie-ID (UUID oder Slug)
- `stage` (Integer) - Stage (0-5)
**Rückgabe:** Liste von `WordUserView`
**Verwendung:** `StageWordsDialog` - Popup mit allen Wörtern eines Stages

**Logik:**
- **Stage 0:** Alle Wörter ohne `user_words` Eintrag ODER mit `srs_stage = 0` in `user_words`
- **Stage 1-5:** Alle Wörter mit entsprechendem `srs_stage` in `user_words`
- Unterstützt Chunking für große Listen (>1000 Wörter)

---

## 🔧 Edge Functions

### `ingest_word`

**Zweck:** Neues Wort über externe API erstellen
**Parameter:** `text`, `fromLang`, `toLang`
**Verwendung:** Wort-Erstellung mit Übersetzung

### `translate-missing`

**Zweck:** Fehlende Übersetzungen ergänzen
**Parameter:** `category` (optional)
**Verwendung:** Batch-Übersetzung fehlender Wörter

---

## 🔄 Datenfluss-Architektur

```mermaid
graph TD
    A[UI Layer] --> B[Application Layer]
    B --> C[Data Layer]
    C --> D[Supabase]

    D --> E[Tables: words, categories, user_words]
    D --> F[Views: words_view, v_words_with_categories]
    D --> G[RPC Functions: fn_user_*]
    D --> H[Edge Functions: ingest_word, translate-missing]

    E --> I[CRUD Operations]
    F --> J[Complex Queries]
    G --> K[Business Logic]
    H --> L[External APIs]
```

---

## 📊 Verwendungsstatistik

| Komponente                  | Häufigkeit | Kritikalität |
| --------------------------- | ---------- | ------------ |
| `fn_user_learn_queue_mode`  | Hoch       | Kritisch     |
| `fn_user_review`            | Hoch       | Kritisch     |
| `fn_user_category_progress` | Hoch       | Kritisch     |
| `words`                     | Hoch       | Kritisch     |
| `v_words_user`              | Hoch       | Kritisch     |
| `v_words_user_srs`          | Hoch       | Kritisch     |
| `user_word_srs`             | Hoch       | Kritisch     |
| `user_words`                | Mittel     | Wichtig      |
| `categories`                | Mittel     | Wichtig      |
| `words_view`                | Mittel     | Wichtig      |

## 🎯 Filter-System

### WordListFilter Types

Die App unterstützt verschiedene Filter-Kategorien über `WordListFilter`:

**Filter-Kategorien:**

- **Category**: Filtern nach Kategorie (UUID oder Slug)
- **Level**: CEFR-Level (A1, A2, B1, B2, C1, C2)
- **POS**: Part of Speech (noun, verb, adjective, etc.)
- **Domain**: Nach Gruppen-Domain (group_slug)
- **About**: Quick Sets Filter
  - `my-words`: In My Words markierte Wörter
  - `favorites`: User's Favorites
  - `known-words`: Wörter ab S1-Stufe
  - `my-mix`: Custom word collections
- **Query**: Textsuche (ilike auf text/translation)

**Verwendung:**

- `fetchWordUserViewsByFilter()` in SupabaseWordRepository
- Word List Screen mit Pagination
- Sort-Modi: Neueste, Alphabetisch

---

## 🚀 Geplante Erweiterungen

- [ ] **Performance-Optimierung:** Indizes für häufige Abfragen
- [ ] **Caching:** Redis für wiederkehrende Daten
- [ ] **Analytics:** Lern-Statistiken erweitern
- [ ] **Offline-Support:** Lokale Synchronisation

---

## 📝 Changelog

### Version 1.6 (12. Februar 2025)

- ✅ `user_word_srs`: Modus-spezifischer SRS-Zustand (time/adaptive/hybrid)
- ✅ `v_words_user_srs`: View mit 3 UNION-Branches für alle SRS-Modi
- ✅ `fn_user_review_hybrid_mode`, `fn_user_review_time_mode`: Review-RPCs pro Modus
- ✅ A-SRS: `fn_a_srs_refill_enroll`, `fn_a_srs_s0_correct`, `fn_requeue_s0_fail`, `fn_a_srs_next_refill_counter`
- ✅ `a_refill_state`, `a_deck_state`: A-SRS State-Tabellen

### Version 1.5 (27. Januar 2025)

- ✅ Stage Words Dialog erweitert: Modus-spezifische Erklärungen (T-SRS, A-SRS, Hybrid)
- ✅ `SrsPopupText`: Neue Helper-Klasse für kontextuelle Dialog-Texte
- ✅ `SrsUiConfig`: Konfiguration für UI-Texte und T-SRS Parameter
- ✅ `submitReview()` erweitert: Unterstützt jetzt SRS-Modus (time/adaptive/hybrid)
- ✅ `fn_user_review_mode`: Neue RPC-Funktion mit modus-spezifischer Logik
- ✅ Nummerierung in Wortliste: Zeigt Position (z.B. "1/35") bei jedem Wort
- ✅ Scrollbar: Automatisch erscheinend/verschwindend beim Scrollen
- ✅ Card Glow Animation: Pulsierender nebeliger Glow-Effekt um die Karte
- ✅ Plasma Link Animation: Animierte Verbindung zwischen Karte und Stage-Switch
- ✅ Switch Pulse Animation: Corona-Effekt bei erfolgreichem Swipe
- ✅ Drag Return Callback: Link erscheint wieder wenn Karte zurückkommt

### Version 1.5 (27. Januar 2025)

- ✅ Stage Words Dialog: Popup-Fenster mit allen Wörtern eines Stages
- ✅ `fetchWordsByStage()`: Neue Repository-Funktion zum Laden von Wörtern nach Stage
- ✅ T-SRS Erklärung: Erklärung des 2-6-19 Systems im Dialog
- ✅ Tap-Handler für Switches: Öffnet Dialog mit Stage-Wörtern

### Version 1.3 (Januar 2025)

- ✅ Mix Feature: Custom word collections with search and multi-category support
- ✅ Quick Sets: Fast access to predefined word sets (My Words, Favorites, Known Words, My Mix)
- ✅ Word List Filter: Advanced filtering with category, level, POS, domain, and query filters
- ✅ Enhanced Views: v_words_user with complete user flags support

### Version 1.2 (Januar 2025)

- ✅ S0-Lock Feature: Client-seitige Sperrung der S0-Stufe (keine neuen Karten)
- ✅ Keine Backend-Änderungen erforderlich (Client-seitige UI-Funktion)

### Version 1.1

- ✅ Grundlegende Tabellen-Struktur
- ✅ SRS-Algorithmus implementiert
- ✅ Lern-Modi (S0-S5, S1-S5, Single)
- ✅ User-Wörter Management
- ✅ Kategorie-System
- ✅ Single-Mode: Keine Stage-Änderung im Single-Modus

### Version 1.0

- ✅ Grundlegende Tabellen-Struktur
- ✅ SRS-Algorithmus implementiert
- ✅ Lern-Modi (S0-S5, S1-S5, Single)
- ✅ User-Wörter Management
- ✅ Kategorie-System

---

## 🔍 Troubleshooting

### Häufige Probleme:

1. **Null-Safety:** Alle String-Felder mit `?? ''` absichern
2. **RPC-Parameter:** Korrekte Parameter-Namen verwenden
3. **Auth-Status:** User-Authentifizierung vor Datenzugriff prüfen

### Debug-Tipps:

- RPC-Calls mit `debugPrint()` loggen
- Supabase-Dashboard für Live-Daten nutzen
- Edge Function Logs in Supabase Console prüfen

---

_Diese Dokumentation wird kontinuierlich aktualisiert. Bei Änderungen bitte entsprechend anpassen._
