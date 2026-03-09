-- Hybrid review must NOT go through A‑SRS review rules (which forbid Stage 0 and require pre-enroll).
-- We reuse the existing TIME review logic (`fn_user_review`) to compute stage + next_due_at,
-- but persist the result into `user_word_srs` with mode='hybrid' so that:
-- - `fn_user_category_progress(p_category, 'hybrid')` updates correctly
-- - the app can read stage/due from `v_words_user_srs` for hybrid

CREATE OR REPLACE FUNCTION public.fn_user_review_hybrid_mode(
  p_word uuid,
  p_category uuid,
  p_result boolean,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_old_stage int := 0;
  v_stage int;
  v_due timestamptz;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  -- Consume hybrid daily budget based on current hybrid stage (if any)
  select uws.stage
    into v_old_stage
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.word_id = p_word
    and uws.category_id = p_category
    and uws.mode = 'hybrid'::public.srs_mode;

  if not found then
    v_old_stage := 0;
  end if;

  perform public.fn_hybrid_consume_budget(
    p_category,
    v_user,
    v_old_stage,
    18,  -- early budget
    12   -- late budget
  );

  -- Reuse TIME review logic to compute new stage + due
  select (r->>'srs_stage')::int, (r->>'next_due_at')::timestamptz
    into v_stage, v_due
  from (
    select to_jsonb(x) as r
    from public.fn_user_review(p_word, p_result) x
    limit 1
  ) t;

  -- Persist to user_word_srs as mode='hybrid'
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, streak, lapses, ef,
    next_due_at, last_reviewed_at, updated_at
  )
  values (
    v_user, p_word, p_category, 'hybrid'::public.srs_mode,
    v_stage, 0, 0, 1.00,
    v_due, now(), now()
  )
  on conflict (user_id, word_id, category_id, mode)
  do update set
    stage = excluded.stage,
    next_due_at = excluded.next_due_at,
    last_reviewed_at = now(),
    updated_at = now();

  return query select v_stage, v_due;
end;
$function$
;

