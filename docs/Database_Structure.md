# Talvori – Database Structure

\includepdf[pages=1,scale=0.85,landscape=true,pagecommand={}]{erd.pdf}

\clearpage
# Talvori – Data Dictionary (public)

# Talvori – Data Dictionary (public)

Generiert: 2025-11-14 15:21

## public.captures

> RLS: user_id = auth.uid().

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | bigint | NO | YES | nextval('captures_id_seq'::regclass) |  |
| 2 | user_id | uuid | NO |  |  |  |
| 3 | text | text | NO |  |  |  |
| 4 | source_url | text | YES |  |  |  |
| 5 | source_title | text | YES |  |  |  |
| 6 | user_agent | text | YES |  |  |  |
| 7 | created_at | timestamp with time zone | YES |  | now() |  |

#### Foreign Keys
- **captures_user_id_fkey**: (user_id) -> public.profiles (id) · on update NO ACTION · on delete CASCADE


## public.categories

> Vokabel-Gruppierungen (CEFR, Topics, Domains); steuernde Reihenfolge.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES | gen_random_uuid() |  |
| 2 | name | text | NO |  |  |  |
| 3 | slug | text | NO |  |  |  |
| 4 | type | text | NO |  |  | z. B. 'cefr', 'topic', 'domain'. |
| 5 | created_at | timestamp with time zone | NO |  | now() |  |
| 6 | order_index | integer | YES |  |  |  |
| 7 | group_slug | text | YES |  |  |  |
| 8 | group_name | text | YES |  |  |  |


## public.entries

> RLS: user_id = auth.uid().

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES | gen_random_uuid() |  |
| 2 | user_id | uuid | NO |  |  |  |
| 3 | term | text | NO |  |  |  |
| 4 | lang | text | YES |  | 'de'::text |  |
| 5 | context | text | YES |  |  |  |
| 6 | created_at | timestamp with time zone | YES |  | now() |  |
| 7 | updated_at | timestamp with time zone | YES |  | now() |  |
| 8 | fts | tsvector | YES |  | to_tsvector('simple'::regconfig, ((COALESCE(term, ''::text) \|\| ' '::text) \|\| COALESCE(context, ''::text))) | Volltextindex für Suche. |
| 9 | translation_de | text | YES |  |  |  |
| 10 | synonyms_en | text[] | YES |  | '{}'::text[] |  |
| 11 | source_url | text | YES |  |  |  |
| 12 | source_title | text | YES |  |  |  |
| 13 | user_agent | text | YES |  |  |  |


## public.ingest_errors

> Fehlerprotokoll beim Import/Parsing.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | bigint | NO | YES | nextval('ingest_errors_id_seq'::regclass) |  |
| 2 | created_at | timestamp with time zone | YES |  | now() |  |
| 3 | target | text | YES |  |  |  |
| 4 | user_id | uuid | YES |  |  |  |
| 5 | payload | jsonb | YES |  |  |  |
| 6 | message | text | YES |  |  |  |


## public.lesson_words

> Reihenfolge von Wörtern innerhalb einer Lesson.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | lesson_id | uuid | NO | YES |  |  |
| 2 | word_id | uuid | NO | YES |  |  |
| 3 | order_index | integer | NO |  | 0 |  |

#### Foreign Keys
- **lesson_words_lesson_id_fkey**: (lesson_id) -> public.lessons (id) · on update NO ACTION · on delete CASCADE
- **lesson_words_word_id_fkey**: (word_id) -> public.words (id) · on update NO ACTION · on delete CASCADE


## public.lessons

> Kuratiertes Set (Titel, Kategorie, Reihenfolge).

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES | gen_random_uuid() |  |
| 2 | title | text | NO |  |  |  |
| 3 | category_id | uuid | YES |  |  |  |
| 4 | order_index | integer | NO |  | 0 |  |
| 5 | created_at | timestamp with time zone | NO |  | now() |  |

#### Foreign Keys
- **lessons_category_fkey**: (category_id) -> public.categories (id) · on update NO ACTION · on delete SET NULL
- **lessons_category_id_fkey**: (category_id) -> public.categories (id) · on update NO ACTION · on delete SET NULL


## public.profiles

> App-Profil je User (z. B. capture_key).

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES |  |  |
| 2 | created_at | timestamp with time zone | YES |  | now() |  |
| 3 | capture_key | text | YES |  |  |  |

#### Foreign Keys
- **profiles_id_fkey**: (id) -> auth.users (id) · on update NO ACTION · on delete CASCADE


## public.single_session_items

> Einmal-Session-Queue (Bucket, Stage) ohne Persistenz in SRS.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | user_id | uuid | NO | YES | auth.uid() |  |
| 2 | category_id | uuid | NO | YES |  |  |
| 3 | stage | integer | NO | YES |  |  |
| 4 | word_id | uuid | NO | YES |  |  |
| 5 | bucket | text | NO |  |  |  |
| 6 | created_at | timestamp with time zone | NO |  | now() |  |


## public.staging_words

> Import-Zwischentabelle (CSV/Batch), wird in words überführt.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | text | text | NO |  |  |  |
| 2 | translation | text | NO |  |  |  |
| 3 | from_lang | text | NO |  | 'en'::text |  |
| 4 | to_lang | text | NO |  | 'de'::text |  |
| 5 | level | text | YES |  |  |  |
| 6 | pos | text | YES |  |  |  |
| 7 | category_slug | text | NO |  |  |  |
| 8 | subdomain | text | YES |  |  |  |


## public.user_daily_picks

> Tägliche Push-Auswahl je User (Scheduling & Versandzeit).

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES | gen_random_uuid() |  |
| 2 | user_id | uuid | NO |  |  |  |
| 3 | word_id | uuid | NO |  |  |  |
| 4 | scheduled_for | date | YES |  |  | Geplanter Tag für Push/Reminder. |
| 5 | sent_at | timestamp with time zone | YES |  |  |  |
| 6 | created_at | timestamp with time zone | NO |  | now() |  |

#### Foreign Keys
- **user_daily_picks_user_id_fkey**: (user_id) -> auth.users (id) · on update NO ACTION · on delete CASCADE
- **user_daily_picks_word_id_fkey**: (word_id) -> public.words (id) · on update NO ACTION · on delete CASCADE


## public.user_words

> RLS: user_id = auth.uid().

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | user_id | uuid | NO | YES |  |  |
| 2 | word_id | uuid | NO | YES |  |  |
| 3 | picked | boolean | NO |  | true |  |
| 4 | favorite | boolean | NO |  | false |  |
| 5 | created_at | timestamp with time zone | NO |  | now() |  |
| 6 | srs_stage | smallint | NO |  | 0 | Aktuelle SRS-Stufe (z. B. 0–5). |
| 7 | next_due_at | timestamp with time zone | YES |  |  | Nächster Wiederholzeitpunkt (Scheduler). |
| 8 | last_reviewed_at | timestamp with time zone | YES |  |  | Zeitpunkt der letzten Wiederholung. |
| 9 | last_result | boolean | YES |  |  |  |
| 10 | source | text | YES |  | 'app'::text |  |

#### Foreign Keys
- **user_words_user_id_fkey**: (user_id) -> auth.users (id) · on update NO ACTION · on delete CASCADE
- **user_words_word_id_fkey**: (word_id) -> public.words (id) · on update NO ACTION · on delete CASCADE


## public.word_categories

> N:M-Link: words <-> categories.

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | word_id | uuid | NO | YES |  | FK -> words.id |
| 2 | category_id | uuid | NO | YES |  | FK -> categories.id |
| 3 | created_at | timestamp with time zone | NO |  | now() |  |

#### Foreign Keys
- **word_categories_category_fkey**: (category_id) -> public.categories (id) · on update NO ACTION · on delete CASCADE
- **word_categories_category_id_fkey**: (category_id) -> public.categories (id) · on update NO ACTION · on delete CASCADE
- **word_categories_word_id_fkey**: (word_id) -> public.words (id) · on update NO ACTION · on delete CASCADE


## public.words

> Master-Lexikon: jedes Wort einmal, Sprache/Pos/Level, Metadaten (QA, Tags).

| # | Column | Type | Null | PK | Default | Description |
|---|--------|------|------|----|---------|-------------|
| 1 | id | uuid | NO | YES | gen_random_uuid() |  |
| 2 | text | text | NO |  |  | Grundform/Token (engl.). |
| 3 | translation | text | NO |  |  | Standard-Übersetzung (z. B. de). |
| 4 | from_lang | text | NO |  |  |  |
| 5 | to_lang | text | NO |  |  |  |
| 6 | domain | text | YES |  |  |  |
| 7 | pos | text | YES |  |  | Part of Speech (noun, verb, adj, …). |
| 8 | level | text | YES |  |  | CEFR-Level (A1–C2) oder custom. |
| 9 | tags | text[] | YES |  | '{}'::text[] |  |
| 11 | srs_stage | integer | YES |  | 0 |  |
| 12 | created_at | timestamp with time zone | YES |  | now() |  |
| 13 | due_at | timestamp with time zone | YES |  |  |  |
| 14 | translated_by | text | YES |  |  |  |
| 15 | translated_at | timestamp with time zone | YES |  |  |  |
| 16 | qa_score | numeric | YES |  |  |  |
| 17 | qa_note | text | YES |  |  |  |


