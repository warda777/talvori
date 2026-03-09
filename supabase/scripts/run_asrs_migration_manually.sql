-- A-SRS Minimal-Spec v1 – Manuell ausführen
-- Im Supabase Dashboard: SQL Editor → New Query → Einfügen und Run
--
-- Voraussetzung: user_word_srs, word_categories existieren bereits

-- 1. Schema
ALTER TABLE public.user_word_srs
  ADD COLUMN IF NOT EXISTS pass_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ever_enrolled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_mastered boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS added_to_category_at timestamp with time zone;

UPDATE public.user_word_srs uws
SET
  ever_enrolled = (uws.stage >= 1),
  is_mastered = false,
  added_to_category_at = COALESCE(
    (SELECT wc.created_at FROM public.word_categories wc
     WHERE wc.word_id = uws.word_id AND wc.category_id = uws.category_id
     LIMIT 1),
    uws.created_at
  ),
  pass_count = CASE WHEN uws.stage >= 1 THEN uws.streak ELSE 0 END
WHERE uws.mode = 'adaptive'::public.srs_mode
  AND added_to_category_at IS NULL;
