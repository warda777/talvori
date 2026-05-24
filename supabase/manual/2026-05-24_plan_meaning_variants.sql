/*
  NICHT AUSFUEHREN - NUR KONZEPT

  Zweck:
  Konzept- und Analyse-SQL fuer drei Bedeutungsvarianten unter den
  verbleibenden Sprachcode-Konflikten:

  - incident
  - move
  - throughout

  Diese Datei ist kein Migrationsskript. Sie enthaelt keine produktiven
  UPDATEs, keine DELETEs und keine Kategorie-/SRS-Aenderungen.

  Vor produktiven Aenderungen wird ein Datenmodell fuer Bedeutungen benoetigt.
*/

-- ============================================================================
-- 1. Betroffene IDs
-- ============================================================================

-- incident:
--   candidate_id: 8b48b271-2a4e-472e-a0d1-99c142cdc1ab  -- Vorfall, EN/DE
--   conflict_id:  f054cac4-7825-4d46-975e-ca008040a3ee  -- Störung/Vorfall, en/de
--
-- move:
--   candidate_id: 0c165b4c-2afb-4861-ac60-75bf59a8611b  -- umziehen, EN/DE
--   conflict_id:  ba6b854f-c6af-4751-b9e8-61d8374272a2  -- bewegen, en/de
--
-- throughout:
--   candidate_id: 6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f  -- durchgehend, EN/DE
--   conflict_id:  8aae50ac-dadb-49ad-8ce6-89f6c501ecac  -- in ganz, en/de

-- ============================================================================
-- 2. Read-only Kontext-SELECT fuer alle 6 IDs
-- ============================================================================

SELECT
  id,
  text,
  translation,
  from_lang,
  to_lang,
  level,
  tags,
  domain,
  pos,
  created_at,
  translated_by,
  translated_at,
  qa_score,
  qa_note
FROM public.words
WHERE id IN (
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  'f054cac4-7825-4d46-975e-ca008040a3ee',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ba6b854f-c6af-4751-b9e8-61d8374272a2',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f',
  '8aae50ac-dadb-49ad-8ce6-89f6c501ecac'
)
ORDER BY text, from_lang, to_lang;

-- ============================================================================
-- 3. Read-only Kategorie-Kontext
-- ============================================================================

SELECT
  wc.word_id,
  wc.category_id,
  c.name AS category_name,
  c.slug AS category_slug,
  c.type AS category_type,
  c.group_slug,
  c.group_name
FROM public.word_categories wc
JOIN public.categories c ON c.id = wc.category_id
WHERE wc.word_id IN (
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  'f054cac4-7825-4d46-975e-ca008040a3ee',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ba6b854f-c6af-4751-b9e8-61d8374272a2',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f',
  '8aae50ac-dadb-49ad-8ce6-89f6c501ecac'
)
ORDER BY wc.word_id, c.type, c.name;

-- ============================================================================
-- 4. Read-only User-/SRS-/Progress-Kontext
-- ============================================================================

SELECT word_id, COUNT(*) AS user_words_count
FROM public.user_words
WHERE word_id IN (
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  'f054cac4-7825-4d46-975e-ca008040a3ee',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ba6b854f-c6af-4751-b9e8-61d8374272a2',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f',
  '8aae50ac-dadb-49ad-8ce6-89f6c501ecac'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS word_progress_count
FROM public.word_progress
WHERE word_id IN (
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  'f054cac4-7825-4d46-975e-ca008040a3ee',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ba6b854f-c6af-4751-b9e8-61d8374272a2',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f',
  '8aae50ac-dadb-49ad-8ce6-89f6c501ecac'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS user_word_srs_count
FROM public.user_word_srs
WHERE word_id IN (
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  'f054cac4-7825-4d46-975e-ca008040a3ee',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ba6b854f-c6af-4751-b9e8-61d8374272a2',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f',
  '8aae50ac-dadb-49ad-8ce6-89f6c501ecac'
)
GROUP BY word_id
ORDER BY word_id;

-- ============================================================================
-- 5. Moegliche spaetere Tabellenidee - NUR KOMMENTAR
-- ============================================================================

/*
  Vor produktiven Aenderungen sollte ein echtes Mehrbedeutungsmodell
  entworfen werden. Eine moegliche Tabelle:

  CREATE TABLE public.word_meanings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    word_id uuid NOT NULL REFERENCES public.words(id) ON DELETE CASCADE,
    translation text NOT NULL,
    explanation text,
    example_sentence text,
    language text NOT NULL DEFAULT 'de',
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
  );

  Offene Frage:
  - Haengt SRS spaeter an public.words oder an public.word_meanings?
  - Werden Level/Wortwelten am Wort oder an Bedeutungen gepflegt?
  - Wie werden bestehende translations in word_meanings migriert?

  Diese CREATE TABLE Anweisung ist bewusst auskommentiert und darf nicht
  ohne eigenes Schema-/Migrationsreview ausgefuehrt werden.
*/

