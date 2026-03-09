-- Fix: fn_user_learn_queue_adaptive_impl sollte nur Wörter zurückgeben, die bereits in user_word_srs sind
-- Das Problem: Die Queue-Funktion gibt Wörter zurück basierend auf word_progress.stage,
-- aber fn_user_review_mode_text sucht in user_word_srs. Wenn ein Wort nicht in user_word_srs ist,
-- dann wirft fn_user_review_mode_text einen Fehler.

CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive_impl(p_category_id uuid, p_take integer DEFAULT 30, p_user uuid DEFAULT NULL::uuid)
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

  -- FIX: Nur Wörter zurückgeben, die bereits in user_word_srs sind
  s as (
    select
      uws.word_id,
      uws.category_id,
      uws.stage::int as stage,
      uws.next_due_at,
      uws.last_reviewed_at
    from public.user_word_srs uws
    join p on uws.user_id = p.user_id
          and uws.category_id = p.cat_id
          and uws.mode::text = v_mode_txt
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
      coalesce(uws.stage, 0)::int as stg,
      uws.next_due_at,
      r.show_after as pos
    from rq r
    left join public.user_word_srs uws
      on uws.user_id     = (select user_id from p)
     and uws.word_id     = r.word_id
     and uws.category_id = (select cat_id from p)
     and uws.mode::text  = v_mode_txt
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
$function$
;

