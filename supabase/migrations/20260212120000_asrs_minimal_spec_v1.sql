-- A-SRS Minimal-Spec v1: Kompletter Umbau
-- Quelle: Finale A-SRS Minimal-Spec v1
--
-- Änderungen:
-- - pass_count, ever_enrolled, is_mastered, added_to_category_at in user_word_srs
-- - Enroll nur aus S0, deterministisch (added_to_category_at ASC, word_id ASC)
-- - Intake-Regel: S0_target, S0_low, intake_batch
-- - Antwort-Regel: pass_count, required_pass (S1-S3: 1, S4-S5: 2)
-- - Kein Downshift, bei falsch: pass_count=0, Stage bleibt
-- - Mastered: S5 + 2× richtig
-- - Queue: gewichtete Stage-Auswahl (S1=6, S2=5, S3=4, S4=3, S5=2)
-- - Retry: Client-seitig (retry_delay 0/1/3)

-- -----------------------------
-- 1. Schema: Neue Spalten in user_word_srs
-- -----------------------------
ALTER TABLE public.user_word_srs
  ADD COLUMN IF NOT EXISTS pass_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ever_enrolled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_mastered boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS added_to_category_at timestamp with time zone;

-- Migration bestehender Daten (adaptive)
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

-- -----------------------------
-- 2. Enroll/Seed: fn_enroll_user_category_mode erweitern
-- -----------------------------
CREATE OR REPLACE FUNCTION public.fn_enroll_user_category_mode(
  p_category_id uuid,
  p_mode text,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
  v_inserted int := 0;
  v_due timestamptz := now();
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- 1) Ensure user_words exists for ALL words in category
  insert into public.user_words (user_id, word_id, picked, favorite, created_at)
  select v_user, wc.word_id, false, false, now()
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id) do nothing;

  -- 2) Ensure user_word_srs exists for this mode/category
  --    A-SRS: stage=0, ever_enrolled=false, is_mastered=false, added_to_category_at=wc.created_at
  insert into public.user_word_srs (
    user_id, word_id, category_id, mode,
    stage, ef, streak, lapses, pass_count, ever_enrolled, is_mastered, added_to_category_at,
    next_due_at, last_reviewed_at
  )
  select
    v_user,
    wc.word_id,
    wc.category_id,
    v_mode,
    0,
    1.00,
    0,
    0,
    0,
    false,
    false,
    wc.created_at,
    case when v_mode = 'adaptive'::public.srs_mode then v_due else null end,
    null
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id, category_id, mode) do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$;

-- -----------------------------
-- 3. Intake: fn_a_srs_intake - S0 → S1 Enroll nach Intake-Regel
-- -----------------------------
-- S0_target = clamp(round(0.10 * N), 1, 25)
-- S0_low = clamp(round(0.50 * S0_target), 1, 12)
-- intake_batch = clamp(round(0.20 * S0_target), 1, 5)
CREATE OR REPLACE FUNCTION public.fn_a_srs_intake(
  p_category_id uuid,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_n int;           -- Gesamtzahl Wörter in Kategorie
  v_s0_count int;
  v_s0_target int;
  v_s0_low int;
  v_intake_batch int;
  v_to_enroll int;
  v_enrolled int := 0;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  select count(*) into v_n from public.word_categories where category_id = p_category_id;
  if v_n = 0 then return 0; end if;

  select count(*) into v_s0_count
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.stage = 0
    and uws.ever_enrolled = false
    and uws.is_mastered = false;

  v_s0_target := greatest(1, least(25, round(0.10 * v_n)::int));
  v_s0_low := greatest(1, least(12, round(0.50 * v_s0_target)::int));
  v_intake_batch := greatest(1, least(5, round(0.20 * v_s0_target)::int));

  if v_s0_count >= v_s0_target then return 0; end if;

  v_to_enroll := least(v_intake_batch, v_s0_target - v_s0_count);

  with pick as (
    select uws.word_id
    from public.user_word_srs uws
    join public.word_categories wc on wc.word_id = uws.word_id and wc.category_id = uws.category_id
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage = 0
      and uws.ever_enrolled = false
      and uws.is_mastered = false
    order by wc.created_at asc, uws.word_id asc
    limit v_to_enroll
  )
  update public.user_word_srs uws
  set stage = 1,
      pass_count = 0,
      ever_enrolled = true,
      is_mastered = false,
      streak = 0,
      next_due_at = now(),
      updated_at = now()
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.word_id in (select word_id from pick);

  get diagnostics v_enrolled = row_count;
  return v_enrolled;
end;
$function$;

-- -----------------------------
-- 4. Review: fn_a_srs_review - Antwort-Regel
-- -----------------------------
-- Richtig: pass_count += 1; wenn pass_count >= required: stage++, pass_count=0
--   S5 + 2 richtig → is_mastered = true
-- Falsch: pass_count = 0, stage bleibt
CREATE OR REPLACE FUNCTION public.fn_a_srs_review(
  p_user uuid,
  p_category uuid,
  p_word uuid,
  p_result boolean
)
RETURNS TABLE(srs_stage integer, pass_count integer, is_mastered boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_stage int;
  v_pass int;
  v_ever bool;
  v_mastered bool;
  v_required int;
  v_new_stage int;
  v_new_pass int;
  v_new_mastered bool;
begin
  select uws.stage, uws.pass_count, uws.ever_enrolled, uws.is_mastered
    into v_stage, v_pass, v_ever, v_mastered
  from public.user_word_srs uws
  where uws.user_id = p_user
    and uws.category_id = p_category
    and uws.word_id = p_word
    and uws.mode = 'adaptive'::public.srs_mode
  for update;

  if not found then
    raise exception 'A-SRS: word not enrolled - use enroll first' using errcode = 'P0001';
  end if;

  if v_stage = 0 then
    raise exception 'A-SRS: S0 is not reviewable - enroll first' using errcode = 'P0001';
  end if;

  v_required := case
    when v_stage in (1, 2, 3) then 1
    when v_stage in (4, 5) then 2
    else 1
  end;

  if p_result then
    v_new_pass := v_pass + 1;
    if v_new_pass >= v_required then
      if v_stage = 5 then
        v_new_stage := 5;
        v_new_pass := 0;
        v_new_mastered := true;
      else
        v_new_stage := v_stage + 1;
        v_new_pass := 0;
        v_new_mastered := false;
      end if;
    else
      v_new_stage := v_stage;
      v_new_mastered := false;
    end if;
  else
    v_new_stage := v_stage;
    v_new_pass := 0;
    v_new_mastered := false;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      pass_count = v_new_pass,
      is_mastered = v_new_mastered,
      updated_at = now(),
      next_due_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = 'adaptive'::public.srs_mode;

  srs_stage := v_new_stage;
  pass_count := v_new_pass;
  is_mastered := v_new_mastered;
  return next;
end;
$function$;

-- fn_user_review_mode: Für adaptive → fn_a_srs_review, sonst fn_user_review_mode_text
-- Signatur wie bestehend: (p_category, p_mode, p_result, p_user, p_word)
DROP FUNCTION IF EXISTS public.fn_user_review_mode(uuid, public.srs_mode, boolean, uuid, uuid);
CREATE OR REPLACE FUNCTION public.fn_user_review_mode(
  p_category uuid,
  p_mode public.srs_mode,
  p_result boolean,
  p_user uuid,
  p_word uuid
)
RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
begin
  if p_mode = 'adaptive'::public.srs_mode then
    return query
    select r.srs_stage, now() as next_due_at
    from public.fn_a_srs_review(p_user, p_category, p_word, p_result) r;
  else
    return query
    select * from public.fn_user_review_mode_text(p_user, p_category, p_word, p_mode::text, p_result);
  end if;
end;
$function$;

-- -----------------------------
-- 5. Queue: fn_a_srs_queue - Gewichtete Stage-Auswahl
-- -----------------------------
-- Gewichte: S1=6, S2=5, S3=4, S4=3, S5=2
-- Pro Stage: ältestes updated_at
-- Liefert (word_id, stage) - Client baut Queue mit Retry-Logik
CREATE OR REPLACE FUNCTION public.fn_a_srs_queue(
  p_category_id uuid,
  p_take integer DEFAULT 50,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(out_word_id uuid, out_srs_stage integer, out_updated_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 50), 1);
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  return query
  with
  active as (
    select uws.word_id, uws.stage, uws.updated_at,
           (case uws.stage when 1 then 6 when 2 then 5 when 3 then 4 when 4 then 3 when 5 then 2 else 0 end)::float as w
    from public.user_word_srs uws
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage between 1 and 5
      and uws.is_mastered = false
  )
  select a.word_id, a.stage::int, a.updated_at
  from active a
  order by random() * a.w desc, a.updated_at asc, a.word_id
  limit v_take;
end;
$function$;

-- -----------------------------
-- 6. Counts: fn_user_category_progress für adaptive
-- -----------------------------
-- Für mode=adaptive: S0 = stage=0 AND ever_enrolled=false AND is_mastered=false
-- S1..S5 = stage=n AND is_mastered=false
CREATE OR REPLACE FUNCTION public.fn_user_category_progress(p_category uuid, p_mode public.srs_mode, p_user uuid DEFAULT NULL::uuid)
RETURNS TABLE(total integer, stages integer[], due_today integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
begin
  if p_mode = 'adaptive'::public.srs_mode then
    return query
    with base as (
      select
        wc.word_id,
        coalesce(uws.stage, 0) as stage,
        coalesce(uws.ever_enrolled, false) as ever_enrolled,
        coalesce(uws.is_mastered, false) as is_mastered
      from public.word_categories wc
      left join public.user_word_srs uws
        on uws.user_id = v_user
       and uws.category_id = wc.category_id
       and uws.word_id = wc.word_id
       and uws.mode = 'adaptive'::public.srs_mode
      where wc.category_id = p_category
    ),
    agg as (
      select
        count(*)::int as total,
        array[
          count(*) filter (where stage = 0 and ever_enrolled = false and is_mastered = false),
          count(*) filter (where stage = 1 and is_mastered = false),
          count(*) filter (where stage = 2 and is_mastered = false),
          count(*) filter (where stage = 3 and is_mastered = false),
          count(*) filter (where stage = 4 and is_mastered = false),
          count(*) filter (where stage = 5 and is_mastered = false)
        ]::int[] as stages,
        0::int as due_today
      from base
    )
    select agg.total, agg.stages, agg.due_today from agg;
  else
    return query
    with base as (
      select
        wc.word_id,
        coalesce(uws.stage, 0) as stage,
        uws.next_due_at
      from public.word_categories wc
      left join public.user_word_srs uws
        on uws.user_id = v_user
       and uws.category_id = wc.category_id
       and uws.word_id = wc.word_id
       and uws.mode = p_mode
      where wc.category_id = p_category
    ),
    agg as (
      select
        count(*)::int as total,
        array[
          count(*) filter (where stage = 0),
          count(*) filter (where stage = 1),
          count(*) filter (where stage = 2),
          count(*) filter (where stage = 3),
          count(*) filter (where stage = 4),
          count(*) filter (where stage = 5)
        ]::int[] as stages,
        count(*) filter (
          where stage > 0 and next_due_at is not null and next_due_at <= now()
        )::int as due_today
      from base
    )
    select agg.total, agg.stages, agg.due_today from agg;
  end if;
end;
$function$;

-- -----------------------------
-- 7. fn_user_learn_queue_adaptive_impl → nutzt fn_a_srs_queue + fn_a_srs_intake
-- -----------------------------
-- Vor dem Queue-Abruf: Intake ausführen (S0→S1)
-- Dann: fn_a_srs_queue für gewichtete Auswahl
-- Rückgabe-Format kompatibel mit bestehendem Contract (word_id, category_id, srs_stage, next_due_at, is_requeue)
CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive_impl(
  p_category_id uuid,
  p_take integer DEFAULT 30,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(
  out_word_id uuid,
  out_category_id uuid,
  out_srs_stage integer,
  out_next_due_at timestamp with time zone,
  out_is_requeue boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 30), 1);
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  perform public.fn_a_srs_intake(p_category_id, v_user);

  return query
  select
    q.out_word_id,
    p_category_id as out_category_id,
    q.out_srs_stage,
    q.out_updated_at as out_next_due_at,
    false as out_is_requeue
  from public.fn_a_srs_queue(p_category_id, v_take, v_user) q;
end;
$function$;
