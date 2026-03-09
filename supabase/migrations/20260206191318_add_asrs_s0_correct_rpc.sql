-- A‑SRS: S0 ist kein Review-State, aber "New"-Karten dürfen angezeigt werden.
-- Bei KORREKT soll eine Karte aus S0 in S1 (A1) "enrolled" werden – pro Karte, nicht als Batch.
--
-- WICHTIG:
-- - Das ist KEIN Review. Es wird bewusst NICHT fn_user_review_mode_text genutzt.
-- - S1 ist band-limitiert (max 20). Wenn voll, wird Enrollment geblockt.

CREATE OR REPLACE FUNCTION public.fn_a_srs_s0_correct(
  p_user uuid,
  p_category uuid,
  p_word uuid
)
RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_s1_count int;
begin
  -- Guard: S1 Band-Max (20)
  select count(*)::int
    into v_s1_count
  from public.user_word_srs uws
  where uws.user_id = p_user
    and uws.category_id = p_category
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.stage = 1;

  if coalesce(v_s1_count, 0) >= 20 then
    raise exception 'A-SRS: S1 (A1) is full (max=20) - S0 enrollment is locked'
      using errcode = 'P0001';
  end if;

  -- Ensure row exists (falls Seed nicht gelaufen ist)
  insert into public.user_word_srs(user_id, word_id, category_id, mode, stage, ef, streak, lapses, next_due_at, last_reviewed_at)
  values (p_user, p_word, p_category, 'adaptive'::public.srs_mode, 0, 1.00, 0, 0, now(), null)
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  -- Guard: Nur echte S0-Karten dürfen hier "enrolled" werden
  if (select stage from public.user_word_srs
      where user_id = p_user and word_id = p_word and category_id = p_category and mode = 'adaptive'::public.srs_mode) <> 0 then
    -- Nichts ändern, aber stabil antworten
    srs_stage := (select stage from public.user_word_srs
                  where user_id = p_user and word_id = p_word and category_id = p_category and mode = 'adaptive'::public.srs_mode);
    next_due_at := (select next_due_at from public.user_word_srs
                    where user_id = p_user and word_id = p_word and category_id = p_category and mode = 'adaptive'::public.srs_mode);
    return next;
  end if;

  update public.user_word_srs
  set stage = 1,
      streak = 0,
      lapses = 0,
      next_due_at = now(),
      last_reviewed_at = null,
      updated_at = now()
  where user_id = p_user
    and word_id = p_word
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 0;

  srs_stage := 1;
  next_due_at := now();
  return next;
end;
$function$;


