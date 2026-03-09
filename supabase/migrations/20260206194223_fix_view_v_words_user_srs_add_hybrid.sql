-- Fix: v_words_user_srs enthält bisher nur SRS-Modi 'adaptive' und 'time'.
-- Der Flutter-Code filtert für Hybrid aber mit `srs_mode = 'hybrid'` (siehe supabase_word_repository.dart),
-- wodurch im Hybrid-Modus IMMER 0 Wörter zurückkommen -> "Keine Wörter verfügbar".
--
-- Lösung: Hybrid als dritten UNION-Branch ergänzen (analog zu 'time'), mit Join auf user_word_srs(mode='hybrid').

CREATE OR REPLACE VIEW "public"."v_words_user_srs" AS
WITH base AS (
  SELECT
    w.id AS word_id,
    w.text,
    w.translation,
    w.from_lang,
    w.to_lang,
    w.domain,
    w.pos,
    w.level,
    w.tags,
    w.created_at AS word_created_at,
    wc.category_id
  FROM public.words w
  JOIN public.word_categories wc
    ON wc.word_id = w.id
),
u AS (
  SELECT
    uw.word_id,
    uw.user_id,
    uw.picked,
    uw.favorite,
    uw.created_at AS user_added_at
  FROM public.user_words uw
  WHERE uw.user_id = auth.uid()
)

-- A-SRS (adaptive)
SELECT
  b.word_id,
  b.text,
  b.translation,
  b.from_lang,
  b.to_lang,
  b.domain,
  b.pos,
  b.level,
  b.tags,
  b.word_created_at,
  b.category_id,
  u.user_id,
  (u.user_id IS NOT NULL) AS in_my_words,
  COALESCE(u.picked, false) AS picked_user,
  COALESCE(u.favorite, false) AS favorite_user,
  u.user_added_at,
  'adaptive'::text AS srs_mode,
  COALESCE(uws.stage, 0) AS srs_stage_user,
  uws.next_due_at AS next_due_at_user,
  uws.last_reviewed_at AS last_reviewed_at_user,
  uws.ef,
  uws.streak,
  uws.lapses
FROM base b
LEFT JOIN u
  ON u.word_id = b.word_id
LEFT JOIN public.user_word_srs uws
  ON uws.word_id = b.word_id
 AND uws.category_id = b.category_id
 AND uws.user_id = auth.uid()
 AND uws.mode = 'adaptive'::public.srs_mode

UNION ALL

-- T-SRS (time)
SELECT
  b.word_id,
  b.text,
  b.translation,
  b.from_lang,
  b.to_lang,
  b.domain,
  b.pos,
  b.level,
  b.tags,
  b.word_created_at,
  b.category_id,
  u.user_id,
  (u.user_id IS NOT NULL) AS in_my_words,
  COALESCE(u.picked, false) AS picked_user,
  COALESCE(u.favorite, false) AS favorite_user,
  u.user_added_at,
  'time'::text AS srs_mode,
  COALESCE(uws.stage, 0) AS srs_stage_user,
  uws.next_due_at AS next_due_at_user,
  uws.last_reviewed_at AS last_reviewed_at_user,
  uws.ef,
  uws.streak,
  uws.lapses
FROM base b
LEFT JOIN u
  ON u.word_id = b.word_id
LEFT JOIN public.user_word_srs uws
  ON uws.word_id = b.word_id
 AND uws.category_id = b.category_id
 AND uws.user_id = auth.uid()
 AND uws.mode = 'time'::public.srs_mode

UNION ALL

-- Hybrid
SELECT
  b.word_id,
  b.text,
  b.translation,
  b.from_lang,
  b.to_lang,
  b.domain,
  b.pos,
  b.level,
  b.tags,
  b.word_created_at,
  b.category_id,
  u.user_id,
  (u.user_id IS NOT NULL) AS in_my_words,
  COALESCE(u.picked, false) AS picked_user,
  COALESCE(u.favorite, false) AS favorite_user,
  u.user_added_at,
  'hybrid'::text AS srs_mode,
  COALESCE(uws.stage, 0) AS srs_stage_user,
  uws.next_due_at AS next_due_at_user,
  uws.last_reviewed_at AS last_reviewed_at_user,
  uws.ef,
  uws.streak,
  uws.lapses
FROM base b
LEFT JOIN u
  ON u.word_id = b.word_id
LEFT JOIN public.user_word_srs uws
  ON uws.word_id = b.word_id
 AND uws.category_id = b.category_id
 AND uws.user_id = auth.uid()
 AND uws.mode = 'hybrid'::public.srs_mode
;


