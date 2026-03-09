-- Align A‑SRS to "Talvori A‑SRS – S0 Contract"
-- Source: file://Finale%20A-SRS%20Regeln%20Contract%2023_01_26.pdf
--
-- Key rules implemented here:
-- - S0 is NOT a review state (no answer events for stage=0)
-- - New cards enter S1 ONLY via refill/enroll cycle (S0 -> S1)
-- - Stage 1 is capped by a band: S1_min=10, S1_max=20 (refill only when below min; never exceed max)
-- - Deterministic enroll selection uses word_categories.created_at (acts as added_to_category_at fallback)

-- -----------------------------
-- Refill / Enroll (adaptive v1): S0 -> S1 with banding
-- -----------------------------
CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(p_user uuid, p_category uuid)
RETURNS integer
LANGUAGE plpgsql
AS $function$
declare
  s1_count int;
  s0_total int;
  capacity int;
  enroll_limit int;
  n int;
begin
  -- Count S1 (active new cards pool)
  select count(*) into s1_count
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 1;

  -- Count S0 (not yet enrolled)
  select count(*) into s0_total
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 0;

  -- Banding per contract
  -- - Refill only if below min
  -- - Do not exceed max
  if s1_count >= 10 then
    return 0;
  end if;

  capacity := greatest(0, 20 - s1_count);
  if capacity = 0 or s0_total = 0 then
    return 0;
  end if;

  -- Enroll-limiter per contract
  enroll_limit := case
    when s0_total > 40 then 20
    else ceil(s0_total * 0.25)
  end;

  n := least(capacity, enroll_limit, s0_total);

  -- Deterministic pick: category insertion time, then word_id
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

-- -----------------------------
-- Review (adaptive): disallow stage 0, streak thresholds per contract
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
  v_threshold  int;
  v_due timestamptz := now();
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
    raise exception 'A-SRS: word not enrolled - use refill/enroll first'
      using errcode = 'P0001';
  end if;

  -- HARD RULE: stage 0 is not part of review queue, thus no answer events
  if v_stage = 0 then
    raise exception 'A-SRS: stage 0 is not reviewable'
      using errcode = 'P0001';
  end if;

  -- Thresholds per contract (stage 1..5)
  v_threshold := case v_stage
    when 1 then 2
    when 2 then 2
    when 3 then 2
    when 4 then 3
    when 5 then 3
    else 2
  end;

  if p_result is true then
    v_new_streak := v_streak + 1;
    if v_new_streak >= v_threshold then
      if v_stage < 5 then
        v_new_stage := v_stage + 1;
        v_new_streak := 0;
      else
        -- Stage 5 stays stage 5 (mastered handling is elsewhere; app uses streak>=3 as "learned")
        v_new_stage := 5;
        v_new_streak := 0;
      end if;
    else
      v_new_stage := v_stage;
    end if;
  else
    -- wrong: reset streak; S1 stays S1; S2..S5 bounce -1
    v_new_streak := 0;
    if v_stage = 1 then
      v_new_stage := 1;
    else
      v_new_stage := greatest(v_stage - 1, 1);
    end if;
    v_lapses := v_lapses + 1;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      streak = v_new_streak,
      lapses = v_lapses,
      last_reviewed_at = now(),
      next_due_at = v_due,
      updated_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = v_mode;

  srs_stage := v_new_stage;
  next_due_at := v_due;
  return next;
end;
$function$;

-- -----------------------------
-- Adaptive queue: use user_word_srs and EXCLUDE stage 0
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
      and uws.stage between 1 and 5 -- ✅ EXCLUDE S0
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
  base as (
    select s2.word_id, s2.category_id, s2.stg, s2.next_due_at, 60 as prio, s2.rn from s2
    union all select s3.word_id, s3.category_id, s3.stg, s3.next_due_at, 59 as prio, s3.rn from s3
    union all select s1.word_id, s1.category_id, s1.stg, s1.next_due_at, 58 as prio, s1.rn from s1
    union all select s4.word_id, s4.category_id, s4.stg, s4.next_due_at, 57 as prio, s4.rn from s4
    union all select s5.word_id, s5.category_id, s5.stg, s5.next_due_at, 56 as prio, s5.rn from s5 where s5.rn <= 2
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
      coalesce(uws.stage, 1)::int as stg,
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


