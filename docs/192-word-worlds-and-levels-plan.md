# Wortwelten und Level - Bestandsaufnahme und Zielmodell

Stand: 2026-05-23

Dieses Dokument ist eine reine Analyse. Es wurden keine Wörter importiert,
verschoben oder gelöscht und keine SRS-Felder verändert.

## Ziel der Klärung

Talvori soll fachlich klar zwischen thematischen Wortwelten und
Sprachniveaus unterscheiden:

- Wortwelt = Thema, zum Beispiel `Travel`, `Food & Cooking`,
  `Work & Careers`, `Health & Fitness`
- Niveau = Level, zum Beispiel `A1`, `A2`, `B1`, `B2`, `C1`, `C2`

Ein Wort kann beides haben:

- Wortwelt: `Travel`
- Niveau: `A2`

`Top 500 Words` ist keine normale Wortwelt. Es ist eine Sammelliste und
soll nicht neben echten Themen wie `Travel` oder `Food & Cooking` stehen.

## Ist-Zustand lokal

### Lokale Tabellen

Die lokale SQLite-Struktur liegt in
`lib/core/local_database/local_database_schema.dart`.

Relevante Tabellen:

- `categories`
  - `id`
  - `name`
  - `description`
  - `sort_order`
  - `is_archived`
  - `created_at`
  - `updated_at`

- `words`
  - `id`
  - `category_id`
  - `term`
  - `translation`
  - `translation_status`
  - `source_language`
  - `target_language`
  - `translation_error`
  - `example_sentence`
  - `notes`
  - `sort_order`
  - `is_archived`
  - `created_at`
  - `updated_at`

- `word_progress`
  - SRS- und Lernfortschritt pro `word_id`, `category_id` und `mode_id`
  - enthält unter anderem `stage`, `pass_count`, `wrong_count`,
    `next_due_at`, `is_mastered`

- `word_sources`
  - Import-/Share-Quellen pro Wort

Aktuell hängt ein lokales Wort über `words.category_id` an genau einer
Kategorie. Es gibt lokal noch kein eigenes `level`-Feld, keine `tags` und
keine Many-to-many-Tabelle für mehrere Wortwelten pro Wort.

### Lokale Modelle

`LocalWord` in `lib/core/local_database/models/local_word.dart` bildet die
lokale `words`-Tabelle ab. Relevante Felder sind `categoryId`, `term`,
`translation`, Übersetzungsstatus, Sprachen, Beispiel, Notizen und
Archivstatus.

`LocalCategory` in `lib/core/local_database/models/local_category.dart`
bildet `categories` ab.

Es gibt lokal keine Felder wie:

- `level`
- `tags`
- `is_seed`
- `is_custom`
- `source` als Wortmetadatum

Quelle und Herkunft werden teilweise indirekt modelliert:

- `LocalLearningSource` trennt Spielquellen wie `Alle Wörter`,
  `Meine Wörter`, `Favoriten`, `Mein Mix`.
- `word_sources` speichert Share-/Browser-Quellen.
- `shared_text_import_service.dart` importiert geteilte Wörter in
  `Meine Wörter`.

### Lokale Seed-Daten

Die Seed-Datei `lib/core/local_database/seed/local_seed_data.dart` enthält
aktuell:

- `Basics`
  - `seed-category-basics`
  - 25 Basiswörter
  - fachlich eher Starter-Paket als saubere Wortwelt

- `Travel`
  - `seed-category-travel`
  - 3 Wörter
  - echte thematische Wortwelt

- `Exam Practice`
  - `seed-category-exam-practice`
  - 3 Wörter
  - eher Zweck-/Lernpaket als Wortwelt

`assets/local_import/default_words_v1.json` enthält nur eine kleine
`Basics`-Kategorie mit zwei Wörtern.

Eine lokale `.dart_tool`-Datenbank im Entwicklerstand enthielt zum Zeitpunkt
der Prüfung nur `Basics` mit 17 Wörtern. Das ist als lokaler Dev-/Teststand
zu behandeln, nicht als produktive Quelle.

## Ist-Zustand Remote/Supabase

Die Remote-Struktur ist in `remote_public_dump.sql` dokumentiert.

### Remote `words`

`public.words` enthält:

- `id`
- `text`
- `translation`
- `from_lang`
- `to_lang`
- `domain`
- `pos`
- `level`
- `tags`
- `srs_stage`
- `created_at`
- `due_at`
- `translated_by`
- `translated_at`
- `qa_score`
- `qa_note`

Wichtige Indizes und Constraints:

- Primary Key: `id`
- Unique: `(text, from_lang, to_lang)`
- Unique Index: `(text, translation, from_lang, to_lang)`
- Index auf `level`
- GIN-Index auf `tags`

Remote existiert also bereits ein `level`-Feld und ein flexibles
`tags`-Array.

### Remote `categories`

`public.categories` enthält:

- `id`
- `name`
- `slug`
- `type`
- `created_at`
- `order_index`
- `group_slug`
- `group_name`

`type` ist eingeschränkt auf:

- `topic`
- `pos`
- `level`
- `origin`
- `custom`

Damit kann Supabase fachlich bereits zwischen Themen, Wortarten, Leveln,
Herkunft und Custom-Gruppen unterscheiden.

### Remote `word_categories`

`public.word_categories` ist eine Many-to-many-Verknüpfung:

- `word_id`
- `category_id`
- `created_at`

Primary Key:

- `(word_id, category_id)`

Damit kann ein Remote-Wort bereits mehreren Kategorien zugeordnet werden.
Ein Wort kann also zum Beispiel in `Travel` und gleichzeitig in einer
Level-Kategorie oder in einem anderen Gruppentyp stehen.

### Remote Nutzer-/SRS-Tabellen

Remote gibt es unter anderem:

- `user_words`
- `word_progress`
- `user_word_srs`

Diese Tabellen enthalten SRS- und Nutzerfortschritt mit Feldern wie
`srs_stage`, `stage`, `pass_count`, `is_mastered`, `next_due_at`.

Wichtig: Diese Daten dürfen durch eine Wortwelt-/Level-Bereinigung nicht
direkt verändert werden.

## Ist-Zustand in der UI

### Wort-Hub

`lib/features/words/data/word_hub_taxonomy.dart` trennt bereits grob:

- thematische Bereiche, zum Beispiel `Life & Daily Flow`,
  `People & Mind`, `Society & Systems`
- `Language Tools` mit `Top 500 Words`, `Phrases & Idioms`,
  `Irregular Verbs`, `Grammar & Syntax`
- `Levels & Progress` mit `A1` bis `C2`

Das ist fachlich näher am Zielmodell.

### Wortspiele-Auswahl

`lib/features/home/ui/widgets/game_word_source_picker.dart` mischt aktuell
unter `Beruf & Sprache`:

- `Work & Careers`
- `Top 500 Words`
- `A1`
- `A2`
- `B1`
- `B2`
- `C1`
- `C2`

Dadurch werden `Top 500 Words` und `A1` bis `C2` in den Wortspielen wie
normale Wortwelten behandelt. Das ist der zentrale fachliche Bruch.

Wenn keine lokale Kategorie existiert, erzeugt die Auswahl synthetische IDs
wie `word-world-top_500` oder `word-world-a1`. Diese führen in lokalen
Spielen oft zu Empty States, sind aber semantisch trotzdem als Wortwelt
sichtbar.

## Kategorien-Bestandsaufnahme

### Echte Wortwelten, die bleiben sollten

Diese Kategorien sind thematische Wortwelten:

- Health & Fitness
- Home & Living
- Food & Cooking
- Style & Fashion
- Money & Shopping
- Productivity
- Personality
- Feelings
- Relationships
- Thoughts
- Law & Politics
- Environment
- School & Studies
- Science
- Space
- Nature
- Animals
- Tech & Innovation
- Media & News
- Sports
- Travel
- Gaming
- Transport
- Music & Entertainment
- Art & Literature
- Work & Careers

### Keine Wortwelten: Level

Diese Einträge sollten als Niveau-Tags beziehungsweise Level behandelt
werden, nicht als Wortwelten:

- A1
- A2
- B1
- B2
- C1
- C2

Empfohlenes Datenfeld:

- Remote: vorhandenes `words.level`
- Lokal: neues optionales Feld `level` oder separate Level-Metadaten

### Keine Wortwelt: Top 500 Words

`Top 500 Words` ist zu groß und zu unscharf als Wortwelt. Es sollte aus der
normalen Wortwelt-Auswahl entfernt werden.

Sinnvolle spätere Aufteilung:

- Starter-Wörter
- Grundverben
- Alltagswörter
- Häufige Nomen
- Häufige Adjektive
- Funktionswörter und Bindewörter
- Fragewörter und Präpositionen

Diese Pakete wären Lernpakete oder kuratierte Sets, nicht Themen-Wortwelten.

### Weitere Sondergruppen

Diese Hub-Einträge sind ebenfalls keine klassischen Wortwelten:

- Phrases & Idioms
- Irregular Verbs
- Grammar & Syntax
- Basics
- Exam Practice

Empfehlung:

- `Basics` als Starter-Paket behandeln.
- `Exam Practice` als Lernpaket oder Zwecksammlung behandeln.
- `Phrases & Idioms`, `Irregular Verbs`, `Grammar & Syntax` als
  Sprachwerkzeuge oder Pakete behandeln, nicht als Themen-Wortwelten.

## Zielstruktur

### Minimal sinnvolle Struktur

Für Talvori reicht zunächst:

- `words`
  - kanonisches Wort
  - `term`/`text`
  - `translation`
  - `source_language`
  - `target_language`
  - optional `level`
  - optional `pos`
  - optional `tags`

- `word_worlds` oder weiter `categories`
  - nur thematische Wortwelten mit Typ `topic`
  - zum Beispiel `Travel`, `Food & Cooking`

- `word_world_memberships` oder lokal analog zu Remote `word_categories`
  - `word_id`
  - `category_id`
  - ermöglicht mehrere Wortwelten pro Wort

- `word_packages` oder `sets`
  - für `Starter-Wörter`, `Grundverben`, `Top 500`-Teilpakete,
    `Exam Practice`

### Brauchen wir `category_id + level`?

Ja, kurzfristig ist `category_id + level` sinnvoll:

- `category_id` beziehungsweise Membership beschreibt die Wortwelt.
- `level` beschreibt das Niveau.

Beispiel:

- `travel` gehört zur Wortwelt `Travel`
- `travel` hat Level `A1` oder `A2`

Damit kann die UI später filtern:

- alle `Travel`-Wörter
- alle `A2`-Wörter
- alle `Travel`-Wörter auf `A2`

### Brauchen wir Many-to-many?

Ja, fachlich ist Many-to-many sinnvoll.

Beispiele:

- `doctor` kann zu `Health & Fitness` und `Work & Careers` passen.
- `ticket` kann zu `Travel` und `Transport` passen.
- `music` kann zu `Music & Entertainment` und `Art & Literature` passen.

Remote existiert diese Struktur bereits mit `word_categories`. Lokal fehlt
sie noch.

### Wie verhindert man doppelte Wörter?

Empfehlung:

1. Kanonische Wort-ID pro normalisiertem Wort und Sprachpaar.
2. Normalisierung:
   - trim
   - lowercase
   - Whitespace vereinheitlichen
   - einfache Apostroph-/Bindestrichvarianten vereinheitlichen
3. Unique Key lokal:
   - `normalized_term`
   - `source_language`
   - `target_language`
4. Kategorien werden nicht durch Duplikate modelliert, sondern durch
   Memberships.

Wichtig: Remote gibt es bereits `words_text_lang_uniq` auf
`(text, from_lang, to_lang)`. Lokal gibt es eine vergleichbare globale
Eindeutigkeit noch nicht.

## Empfohlene Importstrategie

Keine direkte Löschung und kein direktes Verschieben im ersten Schritt.

Empfohlene Reihenfolge:

1. Neue Zielstruktur vorbereiten
   - lokal optional `level` ergänzen
   - lokal Membership-Tabelle ergänzen
   - Paket-/Set-Konzept dokumentieren oder vorbereiten

2. Bestehende lokale Zuordnungen spiegeln
   - bestehendes `words.category_id` bleibt zunächst unverändert
   - zusätzlich Membership aus bestehender Kategorie erzeugen
   - SRS bleibt unangetastet

3. UI fachlich entkoppeln
   - Wortspiel-Picker zeigt nur echte Wortwelten unter Wortwelten
   - A1-C2 wandern in eine eigene Level-Auswahl
   - Top 500 verschwindet aus Wortwelten und wird später als Paket angeboten

4. Importlogik anpassen
   - neues Wort zuerst über normalisierten Key suchen
   - falls vorhanden: keine Dublette erzeugen
   - nur Membership, Quelle oder Nutzerzuordnung ergänzen

5. Daten bereinigen
   - erst nach Backup und Testmigration
   - A1-C2-Kategorien in Level-Metadaten überführen
   - Top-500-Kategorie entfernen oder in Pakete aufteilen

## Risiken

- Lokaler SRS-Fortschritt ist an `category_id` gebunden. Wird eine Kategorie
  gelöscht oder eine Wort-ID neu erzeugt, kann Fortschritt verwaisen.
- Remote SRS-Tabellen sind ebenfalls an `category_id`, `word_id` und `mode`
  gekoppelt.
- Der lokale Picker erzeugt synthetische Kategorie-IDs für nicht vorhandene
  Wortwelten. Das ist robust für Empty States, aber fachlich irreführend bei
  Leveln und Top 500.
- Aktuelle lokale Struktur erlaubt dasselbe Wort in mehreren Kategorien nur
  als Dublette. Das erschwert Fortschritt, Favoriten, Quellen und
  Übersetzungsstatus.
- `Basics` ist aktuell teilweise als Health-&-Fitness-Fallback verdrahtet.
  Das sollte vor einer Migration geprüft werden, weil `Basics` fachlich kein
  Health-&-Fitness-Set ist.

## Nächster Umsetzungsschritt

Empfohlen als nächster kleiner, sicherer Schritt:

1. Noch keine Datenmigration.
2. `Top 500 Words` und `A1` bis `C2` aus der Wortwelt-Auswahl der Wortspiele
   herauslösen.
3. Eine separate UI-Konzeption für Level-Filter vorbereiten.
4. Eine lokale Schema-v4-Migration entwerfen, aber noch nicht produktiv
   ausführen:
   - optional `words.level`
   - neue Membership-Tabelle analog `word_categories`
   - keine Änderung an `word_progress`
5. Danach erst Import-/Seed-Daten in das neue Modell überführen.

## Entscheidungsvorschlag

- Echte Themen bleiben Wortwelten.
- A1-C2 werden Level, nicht Wortwelten.
- Top 500 Words wird aus der normalen Wortwelt-Liste entfernt.
- Top 500 wird später in kleinere Lernpakete zerlegt.
- Lokale Datenstruktur sollte sich schrittweise an Remote annähern:
  - `level` am Wort
  - Many-to-many für Wortwelten
  - separate Pakete für kuratierte Sets
- SRS-Fortschritt bleibt währenddessen unverändert und wird nicht migriert,
  bis die neue Struktur stabil ist.

## Umsetzungsschritt 1: Picker-Bereinigung

Stand: 2026-05-24

Der zentrale Wortwelt-Picker der Wortspiele wurde fachlich bereinigt:

- `Top 500 Words` wurde aus der Wortwelt-Auswahl entfernt.
- `A1`, `A2`, `B1`, `B2`, `C1` und `C2` wurden aus der Wortwelt-Auswahl
  entfernt.
- Die Wortwelt-Auswahl zeigt jetzt nur thematische Wortwelten.
- Die Gruppe `Beruf & Sprache` wurde im Picker zu `Beruf`, weil dort nur noch
  `Work & Careers` steht.
- Eine separate Level-Auswahl fuer A1-C2 wird spaeter umgesetzt.
- Es wurde keine Datenmigration durchgefuehrt.
- Es wurden keine Woerter geloescht, importiert oder verschoben.
- SRS-Fortschritt bleibt unveraendert.

## Umsetzungsschritt 2: Supabase-Review-Export

Stand: 2026-05-24

Es wurde ein read-only Review-Export der vorhandenen Supabase-Woerter
erstellt:

- Review-Dateien liegen unter `docs/word-review/`.
- `docs/word-review/supabase_words_review.csv` enthaelt eine manuell
  reviewbare Wortliste mit leeren Entscheidungsfeldern.
- `docs/word-review/supabase_words_summary.md` enthaelt Zaehlungen,
  Kategorie-/Level-Hinweise und Dubletten-Kandidaten.
- Der Export liest nur `words`, `categories` und `word_categories`.
- Es wurden keine produktiven Daten veraendert.
- Es wurden keine Woerter geloescht, importiert oder verschoben.
- Es wurde keine Supabase-Migration ausgefuehrt.
- SRS-Fortschritt bleibt unveraendert.

Naechster Schritt ist die manuelle Pruefung und Zuordnung in der Review-CSV,
bevor eine spaetere Migration geplant wird.

## Umsetzungsschritt 3: Cleanup-Kandidaten

Stand: 2026-05-24

Aus dem Supabase-Review-Export wurden separate Review-Dateien fuer kleine
Problemgruppen erzeugt:

- Sprachcode-Normalisierung (`EN`/`DE` zu `en`/`de`)
- Dubletten-Kandidaten
- Woerter ohne Kategorie
- Top-500- und A1-C2-Kandidaten

Die Dateien liegen unter `docs/word-review/` und dienen nur als Grundlage fuer
manuelle Entscheidungen. Es wurden keine Supabase-Daten veraendert, keine
Woerter geloescht, keine Kategorien geaendert und keine SRS-Felder beruehrt.

## Umsetzungsschritt 4: Sprachcode-Normalisierung vorbereitet

Stand: 2026-05-24

Fuer die 25 Kandidaten mit Sprachpaar `EN` -> `DE` wurde ein sicheres
Dry-Run/Apply-Skript vorbereitet:

- Standardmodus ist Dry-Run; ohne `--apply` werden keine Daten geschrieben.
- Das Skript liest `docs/word-review/language_code_normalization_review.csv`.
- Es betrifft nur die 25 expliziten Kandidaten fuer `EN`/`DE` zu `en`/`de`.
- Im Schreibmodus duerfen nur `words.from_lang` und `words.to_lang`
  aktualisiert werden.
- Es werden keine Woerter geloescht, keine Kategorien geaendert und keine
  SRS-Daten beruehrt.
- Das Skript wurde nicht produktiv mit `--apply` ausgefuehrt.

## Umsetzungsschritt 5: URL-Bereinigung per SQL vorbereitet

Stand: 2026-05-24

Fuer drei eindeutig URL-verunreinigte Woerter wurde ein manuelles SQL-Skript
vorbereitet:

- Apply per Tool wurde durch Supabase RLS/Permissions blockiert.
- Das SQL-Skript liegt unter
  `supabase/manual/2026-05-24_clean_url_contaminated_words.sql`.
- Es darf manuell im Supabase SQL Editor ausgefuehrt werden.
- Es betrifft nur drei explizite `words.id` Werte.
- Es aktualisiert nur `words.text` und `words.translation`.
- Es aendert keine Sprachcodes, Kategorien, Woerterlisten oder SRS-Daten.
- Jede `UPDATE`-Anweisung prueft zusaetzlich auf den erwarteten URL-Rest,
  damit geaenderte Daten nicht still ueberschrieben werden.

## Umsetzungsschritt 6: Sprachcode-Normalisierung per SQL vorbereitet

Stand: 2026-05-24

Fuer die 25 Kandidaten mit Sprachpaar `EN` -> `DE` wurde ein manuelles
SQL-Skript vorbereitet:

- Tool-Apply wurde nicht verifiziert; die Remote-Werte blieben unveraendert.
- Das SQL-Skript liegt unter
  `supabase/manual/2026-05-24_normalize_language_codes.sql`.
- Es darf manuell im Supabase SQL Editor ausgefuehrt werden.
- Es betrifft nur 25 explizite `words.id` Werte.
- Es aktualisiert nur `words.from_lang` und `words.to_lang`.
- Es aendert keine Worttexte, Kategorien, Woerterlisten oder SRS-Daten.
- Das SQL wurde noch nicht ausgefuehrt.

## Sprachcode-Normalisierung blockiert durch Dubletten

Stand: 2026-05-24

Der manuelle SQL-Update-Versuch fuer `EN`/`DE` -> `en`/`de` wurde von
Supabase abgebrochen:

- Fehler: Unique Constraint `words_text_lang_uniq`.
- Beispiel: `(text, from_lang, to_lang) = (dash, en, de)` existiert bereits.
- Dadurch duerfen die 25 Kandidaten nicht pauschal normalisiert werden.
- Das Update-Skript
  `supabase/manual/2026-05-24_normalize_language_codes.sql` wurde als
  blockiert markiert.
- Eine reine SELECT-Konfliktanalyse wurde vorbereitet:
  `supabase/manual/2026-05-24_analyze_language_code_conflicts.sql`.
- Eine Review-Datei fuer manuelle Entscheidungen wurde vorbereitet:
  `docs/word-review/language_code_conflicts_review.csv`.
- Keine Daten wurden normalisiert.
- SRS-Fortschritt, Kategorien und Worttexte bleiben unveraendert.

Naechster Schritt: Konflikte pruefen und je Kandidat entscheiden, ob Woerter
zusammengefuehrt, geloescht, separat behalten oder sicher normalisiert werden
sollen.

## Umsetzungsschritt 7: Sprachcode-Konflikte aufgeteilt

Stand: 2026-05-24

Die SQL-Konfliktanalyse fuer `EN`/`DE` -> `en`/`de` wurde ausgewertet:

- 16 Kandidaten sind nicht-konfliktierend und koennen separat normalisiert
  werden.
- 9 Kandidaten haben Konflikte mit einem bestehenden `en`/`de` Unique Key.
- Das urspruengliche 25er-SQL bleibt blockiert und darf nicht ausgefuehrt
  werden.
- Ein Safe-Subset-SQL wurde vorbereitet:
  `supabase/manual/2026-05-24_normalize_language_codes_safe_subset.sql`.
- Das Safe-Subset-SQL leitet die nicht-konfliktierenden Kandidaten dynamisch
  aus der 25er-Kandidatenliste ab und ueberspringt Kandidaten mit gleichem
  `text` in `en`/`de`.
- Eine Review-Datei fuer die verbleibenden Konfliktfaelle wurde vorbereitet:
  `docs/word-review/language_code_conflicts_remaining_review.csv`.
- Die Konfliktfaelle werden separat geprueft.
- In diesem Schritt wurden keine Supabase-Daten geaendert.

## Umsetzungsschritt 8: Merge-Plan fuer exakte Sprachcode-Dubletten

Stand: 2026-05-24

Die drei risikoaermsten exakten Sprachcode-Dubletten wurden als
Merge-/Archivierungskandidaten vorbereitet:

- `behind`
- `entire`
- `interview`

Fuer diese Gruppen gilt:

- gleicher englischer Begriff
- gleiche deutsche Uebersetzung
- Konflikt durch `EN`/`DE` vs. bereits vorhandenes `en`/`de`
- unterschiedliche Kategorie-/Level-Kontexte

Es wurde kein Merge ausgefuehrt und keine Supabase-Daten wurden geaendert.

Vorbereitet wurden:

- Review-Plan:
  `docs/word-review/exact_duplicate_merge_plan.md`
- blockierter SQL-Entwurf:
  `supabase/manual/2026-05-24_plan_merge_exact_language_duplicates.sql`

Der SQL-Entwurf ist als `NICHT AUSFUEHREN - NUR PLAN` markiert. Vor einem
produktiven Merge muessen `word_categories`, `user_words`, `word_progress`
und `user_word_srs` live erneut geprueft werden. SRS-/User-Daten duerfen
nicht geloescht oder stillschweigend umgehaengt werden.
