-- A‑SRS: S1-Enrollment-Sperre komplett entfernen.
-- Vorher: Bei 20/30 Karten in A1 wurde S0→S1-Enrollment blockiert.
-- Nachher: Keine Obergrenze für A1 – beliebig viele Karten können enrolled werden.

-- 1) fn_a_srs_s0_correct: Guard entfernen
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
begin
  -- Ensure row exists (falls Seed nicht gelaufen ist)
  insert into public.user_word_srs(user_id, word_id, category_id, mode, stage, ef, streak, lapses, next_due_at, last_reviewed_at)
  values (p_user, p_word, p_category, 'adaptive'::public.srs_mode, 0, 1.00, 0, 0, now(), null)
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  -- Guard: Nur echte S0-Karten dürfen hier "enrolled" werden
  if (select stage from public.user_word_srs
      where user_id = p_user and word_id = p_word and category_id = p_category and mode = 'adaptive'::public.srs_mode) <> 0 then
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

-- 2) fn_a_srs_refill_enroll: s1_max-Cap entfernen (capacity nur durch enroll_limit begrenzt)
CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(p_user uuid, p_category uuid)
RETURNS integer
LANGUAGE plpgsql
AS $function$
declare
  s1_count int;
  s0_total int;
  enroll_limit int;
  n int;
  s1_min constant int := 10;
begin
  select count(*) into s1_count
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 1;

  select count(*) into s0_total
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 0;

  if s1_count > s1_min then
    return 0;
  end if;

  if s0_total = 0 then
    return 0;
  end if;

  enroll_limit := case
    when s0_total > 40 then 30
    else ceil(s0_total * 0.25)
  end;

  n := least(enroll_limit, s0_total);

  with pick as (
    select uws.word_id
    from public.user_word_srs uws
    join public.word_categories wc
      on wc.category_id = uws.category_id
     and wc.word_id = uws.word_id
    where uws.user_id = p_user
      and uws.category_id = p_category
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage = 0
    order by wc.created_at asc, uws.word_id asc
    limit n
  )
  update public.user_word_srs uws
  set stage = 1,
      streak = 0,
      next_due_at = now(),
      updated_at = now()
  where uws.user_id = p_user
    and uws.category_id = p_category
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.word_id in (select word_id from pick);

  return n;
end;
$function$;
