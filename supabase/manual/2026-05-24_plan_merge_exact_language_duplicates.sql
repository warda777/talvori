/*
  NICHT AUSFUEHREN - NUR PLAN

  Zweck:
  Entwurf fuer einen spaeteren, manuell geprueften Merge/Archivierungsschritt
  fuer drei exakte Sprachcode-Dubletten:

  - behind
  - entire
  - interview

  Dieser SQL-Entwurf ist absichtlich blockiert und darf nicht als Migration
  ausgefuehrt werden. Er skizziert nur Pruefungen und moegliche Schritte.

  Sicherheit:
  - Keine DELETEs.
  - Keine SRS-Aenderungen.
  - Keine user_words-/word_progress-/user_word_srs-Aenderungen.
  - Keine produktive Archivierung ohne bestaetigtes Archivierungsfeld.
  - Vor jeder produktiven Variante alle SELECTs live pruefen.
*/

-- ============================================================================
-- 1. IDs und vorlaeufige Keep-/Archive-Empfehlung
-- ============================================================================

-- behind:
--   keep_id:    857507cd-ca70-4a7d-bc5f-66dc09e7f648  -- en/de, A1
--   archive_id: 3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb  -- EN/DE, Productivity
--
-- entire:
--   keep_id:    2a5d060a-cddf-4a67-8ce7-a21367c00fe1  -- en/de, B2
--   archive_id: 37a99d9c-9192-44ce-83b9-08eee8bca169  -- EN/DE, Productivity
--
-- interview:
--   keep_id:    b07abd1a-d672-4f35-a12c-86c0ff47062d  -- en/de, A1, Media & News
--   archive_id: 1aff8ead-820c-447c-9dc9-fe5981d91412  -- EN/DE, Productivity

-- ============================================================================
-- 2. Vorher-SELECT fuer alle 6 IDs
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
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  '857507cd-ca70-4a7d-bc5f-66dc09e7f648',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '2a5d060a-cddf-4a67-8ce7-a21367c00fe1',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  'b07abd1a-d672-4f35-a12c-86c0ff47062d'
)
ORDER BY text, from_lang, to_lang;

-- ============================================================================
-- 3. Pruefung User-/SRS-/Progress-Bezuege
-- ============================================================================

SELECT word_id, COUNT(*) AS user_words_count
FROM public.user_words
WHERE word_id IN (
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  '857507cd-ca70-4a7d-bc5f-66dc09e7f648',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '2a5d060a-cddf-4a67-8ce7-a21367c00fe1',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  'b07abd1a-d672-4f35-a12c-86c0ff47062d'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS word_progress_count
FROM public.word_progress
WHERE word_id IN (
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  '857507cd-ca70-4a7d-bc5f-66dc09e7f648',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '2a5d060a-cddf-4a67-8ce7-a21367c00fe1',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  'b07abd1a-d672-4f35-a12c-86c0ff47062d'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS user_word_srs_count
FROM public.user_word_srs
WHERE word_id IN (
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  '857507cd-ca70-4a7d-bc5f-66dc09e7f648',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '2a5d060a-cddf-4a67-8ce7-a21367c00fe1',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  'b07abd1a-d672-4f35-a12c-86c0ff47062d'
)
GROUP BY word_id
ORDER BY word_id;

-- ============================================================================
-- 4. Pruefung word_categories
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
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  '857507cd-ca70-4a7d-bc5f-66dc09e7f648',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '2a5d060a-cddf-4a67-8ce7-a21367c00fe1',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  'b07abd1a-d672-4f35-a12c-86c0ff47062d'
)
ORDER BY wc.word_id, c.type, c.name;

-- ============================================================================
-- 5. Moegliche Kategorie-Uebertragung - AUSKOMMENTIERT
-- ============================================================================

/*
  Wenn die Live-Pruefungen bestaetigen, dass die keep-ID beibehalten wird,
  koennen fehlende Kategorie-Memberships vom archive-Kandidaten auf die
  keep-ID kopiert werden.

  Diese INSERTs sind bewusst auskommentiert und nur ein Entwurf.

  behind: Productivity von archive_id auf keep_id kopieren

  INSERT INTO public.word_categories (word_id, category_id)
  SELECT
    '857507cd-ca70-4a7d-bc5f-66dc09e7f648'::uuid,
    wc.category_id
  FROM public.word_categories wc
  WHERE wc.word_id = '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'
  ON CONFLICT DO NOTHING;

  entire: Productivity von archive_id auf keep_id kopieren

  INSERT INTO public.word_categories (word_id, category_id)
  SELECT
    '2a5d060a-cddf-4a67-8ce7-a21367c00fe1'::uuid,
    wc.category_id
  FROM public.word_categories wc
  WHERE wc.word_id = '37a99d9c-9192-44ce-83b9-08eee8bca169'
  ON CONFLICT DO NOTHING;

  interview: Productivity von archive_id auf keep_id kopieren

  INSERT INTO public.word_categories (word_id, category_id)
  SELECT
    'b07abd1a-d672-4f35-a12c-86c0ff47062d'::uuid,
    wc.category_id
  FROM public.word_categories wc
  WHERE wc.word_id = '1aff8ead-820c-447c-9dc9-fe5981d91412'
  ON CONFLICT DO NOTHING;
*/

-- ============================================================================
-- 6. Moegliche Archivierung - NICHT VORHANDEN / NICHT AUSFUEHREN
-- ============================================================================

/*
  In der dokumentierten Remote-Struktur von public.words ist kein
  is_archived-Feld bestaetigt. Deshalb wird hier KEIN UPDATE vorgeschlagen.

  Wenn spaeter ein Archivierungsfeld oder eine Archivierungstabelle bestaetigt
  wird, muss ein separates, sicheres SQL-Skript erstellt werden.

  KEINE DELETEs verwenden.
*/

