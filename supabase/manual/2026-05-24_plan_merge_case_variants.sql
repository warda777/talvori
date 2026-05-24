/*
  NICHT AUSFUEHREN - NUR PLAN

  Zweck:
  Entwurf fuer einen spaeteren, manuell geprueften Merge/Archivierungsschritt
  fuer drei Gross-/Kleinschreibungsvarianten:

  - dash
  - report
  - satellite

  Dieser SQL-Entwurf ist absichtlich blockiert und darf nicht als Migration
  ausgefuehrt werden. Er skizziert nur Pruefungen und moegliche Schritte.

  Sicherheit:
  - Keine DELETEs.
  - Keine SRS-Aenderungen.
  - Keine user_words-/word_progress-/user_word_srs-Aenderungen.
  - Keine Kategorie-Aenderungen ohne finale manuelle Entscheidung.
  - Keine produktive Archivierung ohne bestaetigtes Archivierungsfeld.
*/

-- ============================================================================
-- 1. IDs und vorlaeufige Keep-/Archive-Empfehlung
-- ============================================================================

-- dash:
--   keep_id:    e09286d3-351c-4f04-a14a-b7d851c25713  -- en/de, C2
--   archive_id: 0a29d3d0-ad57-4c78-94b7-ad6d603915c0  -- EN/DE, Bindestrich, Productivity
--
-- report:
--   keep_id:    70fbac34-dad7-4af5-986a-19942af4baf5  -- en/de, A2, POS aktuell verb
--   archive_id: 31b9fd7e-fbbf-44fa-af67-40c66144f843  -- EN/DE, Bericht, Productivity
--
-- satellite:
--   keep_id:    e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422  -- en/de, B2, Space
--   archive_id: 32464b29-fec5-4fd3-ba25-a873e3b0f8eb  -- EN/DE, Satellit

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
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  'e09286d3-351c-4f04-a14a-b7d851c25713',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '70fbac34-dad7-4af5-986a-19942af4baf5',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
)
ORDER BY text, from_lang, to_lang;

-- ============================================================================
-- 3. Pruefung User-/SRS-/Progress-Bezuege
-- ============================================================================

SELECT word_id, COUNT(*) AS user_words_count
FROM public.user_words
WHERE word_id IN (
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  'e09286d3-351c-4f04-a14a-b7d851c25713',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '70fbac34-dad7-4af5-986a-19942af4baf5',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS word_progress_count
FROM public.word_progress
WHERE word_id IN (
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  'e09286d3-351c-4f04-a14a-b7d851c25713',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '70fbac34-dad7-4af5-986a-19942af4baf5',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
)
GROUP BY word_id
ORDER BY word_id;

SELECT word_id, COUNT(*) AS user_word_srs_count
FROM public.user_word_srs
WHERE word_id IN (
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  'e09286d3-351c-4f04-a14a-b7d851c25713',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '70fbac34-dad7-4af5-986a-19942af4baf5',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
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
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  'e09286d3-351c-4f04-a14a-b7d851c25713',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '70fbac34-dad7-4af5-986a-19942af4baf5',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
)
ORDER BY wc.word_id, c.type, c.name;

-- ============================================================================
-- 5. Moegliche Grossschreibungs-Updates - AUSKOMMENTIERT
-- ============================================================================

/*
  Diese UPDATEs sind bewusst auskommentiert und nur ein Entwurf.
  Vor Ausfuehrung muessen Keep-ID, POS und Kategorie-Uebertragung final
  bestaetigt werden.

  UPDATE public.words
  SET translation = 'Bindestrich'
  WHERE id = 'e09286d3-351c-4f04-a14a-b7d851c25713'
    AND text = 'dash'
    AND from_lang = 'en'
    AND to_lang = 'de'
    AND translation = 'bindestrich';

  -- Achtung: report hat POS = verb. Vorher fachlich pruefen.
  UPDATE public.words
  SET translation = 'Bericht'
  WHERE id = '70fbac34-dad7-4af5-986a-19942af4baf5'
    AND text = 'report'
    AND from_lang = 'en'
    AND to_lang = 'de'
    AND translation = 'bericht';

  UPDATE public.words
  SET translation = 'Satellit'
  WHERE id = 'e0d7acc3-7b01-48b4-a6e8-2f0cb06ad422'
    AND text = 'satellite'
    AND from_lang = 'en'
    AND to_lang = 'de'
    AND translation = 'satellit';
*/

-- ============================================================================
-- 6. Moegliche Kategorie-Uebertragung - AUSKOMMENTIERT
-- ============================================================================

/*
  Fehlende category memberships vom archive-Kandidaten auf keep-ID kopieren.
  Diese INSERTs sind bewusst auskommentiert und nur ein Entwurf.

  dash: Productivity von archive_id auf keep_id kopieren

  INSERT INTO public.word_categories (word_id, category_id)
  SELECT
    'e09286d3-351c-4f04-a14a-b7d851c25713'::uuid,
    wc.category_id
  FROM public.word_categories wc
  WHERE wc.word_id = '0a29d3d0-ad57-4c78-94b7-ad6d603915c0'
  ON CONFLICT DO NOTHING;

  report: Productivity von archive_id auf keep_id kopieren

  INSERT INTO public.word_categories (word_id, category_id)
  SELECT
    '70fbac34-dad7-4af5-986a-19942af4baf5'::uuid,
    wc.category_id
  FROM public.word_categories wc
  WHERE wc.word_id = '31b9fd7e-fbbf-44fa-af67-40c66144f843'
  ON CONFLICT DO NOTHING;

  satellite: aktuell keine category membership vom candidate bekannt.
  Falls spaeter eine Kategorie am archive-Kandidaten haengt, separat pruefen.
*/

-- ============================================================================
-- 7. Moegliche Archivierung - NICHT VORHANDEN / NICHT AUSFUEHREN
-- ============================================================================

/*
  In der dokumentierten Remote-Struktur von public.words ist kein
  is_archived-Feld bestaetigt. Deshalb wird hier KEIN Archivierungs-UPDATE
  vorgeschlagen.

  Wenn spaeter ein Archivierungsfeld oder eine Archivierungstabelle bestaetigt
  wird, muss ein separates, sicheres SQL-Skript erstellt werden.

  KEINE DELETEs verwenden.
*/

