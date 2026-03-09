-- A‑SRS Fixes
-- 1) Queue soll Stage 0 (neue Karten) liefern, ohne Stage sofort auf 1 zu setzen.
--    -> Dadurch steht NICHT sofort "20" in A1/S1, sondern bleibt in S0 bis zum 1. richtigen Swipe.
-- 2) Review RPC muss next_due_at korrekt setzen + zurückgeben (sonst CONTRACT FAIL im Flutter).
-- 3) Enrollment muss für adaptive next_due_at != NULL erfüllen (Constraint adaptive_due_not_null).

-- -----------------------------
-- Enrollment: seed für Kategorie/Mode
-- -----------------------------
CREATE OR REPLACE FUNCTION public.fn_enroll_user_category_mode(
  p_category_id uuid,
  p_mode text,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
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
  --    IMPORTANT: for adaptive, next_due_at must NOT be NULL (constraint adaptive_due_not_null)
  insert into public.user_word_srs (
    user_id, word_id, category_id, mode,
    stage, ef, streak, lapses, next_due_at, last_reviewed_at
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
    case when v_mode = 'adaptive'::public.srs_mode then v_due else null end,
    null
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$;

-- Optional: single-word enroll (auch für adaptive next_due_at setzen)
CREATE OR REPLACE FUNCTION public.fn_enroll_word_mode(
  p_word uuid,
  p_category uuid,
  p_mode text,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_mode public.srs_mode := p_mode::public.srs_mode;
  v_due timestamptz := now();
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  insert into public.user_words(user_id, word_id, picked, favorite, created_at)
  values (v_user, p_word, false, false, now())
  on conflict (user_id, word_id) do nothing;

  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, streak, lapses, ef,
    next_due_at, last_reviewed_at
  )
  values (
    v_user, p_word, p_category, v_mode,
    0, 0, 0, 1.00,
    case when v_mode = 'adaptive'::public.srs_mode then v_due else null end,
    null
  )
  on conflict (user_id, word_id, category_id, mode) do nothing;
end;
$function$;

-- -----------------------------
-- Review: Stage 0 ist reviewbar (A‑SRS), next_due_at wird gesetzt + returned
-- Rules:
--  - S0: 1× korrekt -> S1
--  - S1..S3: 2× korrekt in Folge -> next stage
--  - S4..S5: 3× korrekt in Folge -> next stage (S5 bleibt bei S5, streak capped)
-- -----------------------------
CREATE OR REPLACE FUNCTION public.fn_user_review_mode_text(
  p_user uuid,
  p_category uuid,
  p_word uuid,
  p_mode text,
  p_result boolean
)
RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
declare
  v_mode public.srs_mode := p_mode::public.srs_mode;

  v_stage   int;
  v_streak  int;
  v_ef      numeric;
  v_lapses  int;

  v_new_stage  int;
  v_new_streak int;
  v_required   int;

  v_base_days int;
  v_interval_days int;
  v_new_due timestamptz;
begin
  select stage, streak, ef, lapses
    into v_stage, v_streak, v_ef, v_lapses
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = v_mode
  for update;

  if not found then
    raise exception 'A-SRS: word not enrolled - use enroll first'
      using errcode = 'P0001';
  end if;

  v_required := case
    when v_stage = 0 then 1
    when v_stage between 1 and 3 then 2
    else 3
  end;

  if p_result is true then
    v_new_streak := v_streak + 1;

    if v_new_streak >= v_required then
      if v_stage < 5 then
        v_new_stage := v_stage + 1;
        v_new_streak := 0; -- nach Promotion reset
      else
        -- Stage 5 bleibt Stage 5 (completed wird über streak/learned abgeleitet)
        v_new_stage := 5;
        v_new_streak := least(v_new_streak, v_required);
      end if;
    else
      v_new_stage := v_stage; -- bleibt in Stage, nur streak steigt
    end if;
  else
    -- falsch: bounce 1 stage zurück, streak reset, lapses++
    v_new_stage := greatest(v_stage - 1, 0);
    v_new_streak := 0;
    v_lapses := v_lapses + 1;

    if v_mode in ('adaptive','hybrid') then
      v_ef := greatest(0.60, v_ef - 0.18);
    end if;
  end if;

  -- Due-Plan
  v_base_days := case v_new_stage
    when 0 then 0
    when 1 then 1
    when 2 then 2
    when 3 then 6
    when 4 then 19
    when 5 then 60
    else 0
  end;

  if v_new_stage = 0 then
    v_new_due := now();
  else
    if v_mode in ('adaptive','hybrid') then
      v_interval_days := greatest(1, round(v_base_days * v_ef)::int);
    else
      v_interval_days := v_base_days;
    end if;
    v_new_due := now() + make_interval(days => v_interval_days);
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      streak = v_new_streak,
      ef = v_ef,
      lapses = v_lapses,
      last_reviewed_at = now(),
      next_due_at = v_new_due,
      updated_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = v_mode;

  srs_stage := v_new_stage;
  next_due_at := v_new_due;
  return next;
end;
$function$;

-- -----------------------------
-- Queue: adaptive Queue aus user_word_srs (inkl. Stage 0), nicht aus word_progress
-- -----------------------------
CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive_impl(
  p_category_id uuid,
  p_take integer DEFAULT 30,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(out_word_id uuid, out_category_id uuid, out_srs_stage integer, out_next_due_at timestamp with time zone, out_is_requeue boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 30), 1);
  v_mode_txt text := 'adaptive';
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  return query
  with
  p as (
    select v_user as user_id, p_category_id as cat_id, v_take as take_n
  ),

  rf as (
    select coalesce(
      (
        select crs.refill_counter
        from public.category_refill_state crs
        join p on crs.user_id = p.user_id
              and crs.category_id = p.cat_id
              and crs.mode::text = v_mode_txt
        limit 1
      ),
      0
    )::int as refill_counter
  ),

  rq as (
    select r.word_id, r.show_after
    from public.user_requeue r
    join p on r.user_id = p.user_id
          and r.category_id = p.cat_id
          and r.mode::text = v_mode_txt
    order by r.created_at desc
    limit 10
  ),

  -- Source: user_word_srs ist Source of Truth für adaptive
  s as (
    select
      uws.word_id,
      uws.category_id,
      uws.stage::int as stage,
      uws.next_due_at as next_due_at,
      uws.last_reviewed_at as last_reviewed_at
    from public.user_word_srs uws
    join p on uws.user_id = p.user_id and uws.category_id = p.cat_id
    where uws.mode::text = v_mode_txt
  ),

  s_nr as (
    select s.*
    from s
    where not exists (select 1 from rq where rq.word_id = s.word_id)
  ),

  eligible as (
    select
      snr.word_id,
      snr.category_id,
      snr.stage,
      snr.next_due_at,
      snr.last_reviewed_at,
      coalesce(wpds.last_queued_counter, -1)::int as last_queued_counter,
      (select rf.refill_counter from rf)::int as refill_counter,
      (coalesce(wpds.last_queued_counter, -1) < (select rf.refill_counter from rf)) as is_eligible
    from s_nr snr
    left join public.word_progress_deck_state wpds
      on wpds.user_id     = (select user_id from p)
     and wpds.category_id = snr.category_id
     and wpds.word_id     = snr.word_id
     and wpds.mode::text  = v_mode_txt
  ),

  s_ok as (
    select * from eligible where is_eligible = true
  ),

  -- Stage buckets (inkl. S0)
  s0 as (
    select e.word_id, e.category_id, 0 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 0
  ),
  s1 as (
    select e.word_id, e.category_id, 1 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 1
  ),
  s2 as (
    select e.word_id, e.category_id, 2 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 2
  ),
  s3 as (
    select e.word_id, e.category_id, 3 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 3
  ),
  s4 as (
    select e.word_id, e.category_id, 4 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 4
  ),
  s5 as (
    select e.word_id, e.category_id, 5 as stg, e.next_due_at,
           row_number() over (order by coalesce(e.last_reviewed_at,'epoch'::timestamptz) asc, e.word_id) as rn
    from s_ok e where e.stage = 5
  ),

  -- Priorität: due Stages > neue Karten (S0 zuletzt auffüllen)
  base as (
    select s2.word_id, s2.category_id, s2.stg, s2.next_due_at, 60 as prio, s2.rn from s2
    union all select s3.word_id, s3.category_id, s3.stg, s3.next_due_at, 59 as prio, s3.rn from s3
    union all select s1.word_id, s1.category_id, s1.stg, s1.next_due_at, 58 as prio, s1.rn from s1
    union all select s4.word_id, s4.category_id, s4.stg, s4.next_due_at, 57 as prio, s4.rn from s4
    union all select s5.word_id, s5.category_id, s5.stg, s5.next_due_at, 56 as prio, s5.rn from s5 where s5.rn <= 2
    union all select s0.word_id, s0.category_id, s0.stg, s0.next_due_at, 10 as prio, s0.rn from s0
  ),

  base_pos as (
    select b.*,
           row_number() over (order by b.prio desc, b.rn asc, b.word_id) as base_i
    from base b
  ),

  base_final as (
    select
      bp.word_id, bp.category_id, bp.stg, bp.next_due_at,
      (bp.base_i + (select count(*) from rq where rq.show_after <= bp.base_i)) as pos
    from base_pos bp
  ),

  rq_final as (
    select
      r.word_id,
      (select cat_id from p) as category_id,
      coalesce(uws.stage, 0)::int as stg,
      uws.next_due_at as next_due_at,
      r.show_after as pos
    from rq r
    left join public.user_word_srs uws
      on uws.user_id = (select user_id from p)
     and uws.word_id = r.word_id
     and uws.category_id = (select cat_id from p)
     and uws.mode::text = v_mode_txt
  ),

  merged as (
    select rqf.word_id, rqf.category_id, rqf.stg, rqf.next_due_at, rqf.pos, true as is_requeue
    from rq_final rqf
    union all
    select bf.word_id, bf.category_id, bf.stg, bf.next_due_at, bf.pos, false as is_requeue
    from base_final bf
  ),

  final_take as materialized (
    select m.word_id, m.category_id, m.pos
    from merged m
    order by m.pos asc, m.word_id
    limit (select take_n from p)
  ),

  mark_queued as (
    insert into public.word_progress_deck_state
      (user_id, category_id, word_id, mode, last_queued_counter, updated_at)
    select
      (select user_id from p),
      ft.category_id,
      ft.word_id,
      v_mode_txt,
      (select refill_counter from rf),
      now()
    from final_take ft
    on conflict (user_id, category_id, word_id, mode)
    do update set
      last_queued_counter = excluded.last_queued_counter,
      updated_at = excluded.updated_at
    returning 1
  ),

  force_exec as (
    select count(*)::int as wrote_rows from mark_queued
  )

  select
    ft.word_id as out_word_id,
    ft.category_id as out_category_id,
    m.stg as out_srs_stage,
    m.next_due_at as out_next_due_at,
    m.is_requeue as out_is_requeue
  from final_take ft
  join merged m
    on m.word_id = ft.word_id
   and m.category_id = ft.category_id
   and m.pos = ft.pos
  cross join force_exec
  order by ft.pos asc, ft.word_id;
end;
$function$;


