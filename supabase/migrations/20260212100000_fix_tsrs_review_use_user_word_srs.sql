-- T-SRS: Fix review RPC so that stage transitions are computed from user_word_srs (mode='time'),
-- NOT from user_words (fn_user_review). Otherwise words can jump S0 -> S5 when user_words.srs_stage
-- is already high from other modes/categories.
--
-- Goal: In T-SRS, a correct swipe in Stage 0 moves to Stage 1 (T1), not to Stage 5.
-- TIME intervals: T1=2d, T2=6d, T3=19d, T4=45d, T5=90d.

CREATE OR REPLACE FUNCTION public.fn_user_review_time_mode(
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
  v_new_stage int := 0;
  v_due timestamptz;
  v_days int;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  -- Ensure row exists for this category/mode/word (S0)
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, ef, streak, lapses,
    next_due_at, last_reviewed_at, updated_at
  )
  values (
    v_user, p_word, p_category, 'time'::public.srs_mode,
    0, 1.00, 0, 0,
    now(), null, now()
  )
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  -- Read current stage from user_word_srs (mode='time'), NOT user_words
  select uws.stage
    into v_old_stage
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.word_id = p_word
    and uws.category_id = p_category
    and uws.mode = 'time'::public.srs_mode
  for update;

  if not found then
    v_old_stage := 0;
  end if;

  if p_result then
    -- CORRECT: S0->S1, S1->S2, ..., S4->S5
    if v_old_stage <= 0 then
      v_new_stage := 1;
    else
      v_new_stage := least(5, v_old_stage + 1);
    end if;
    v_days := case v_new_stage
      when 1 then 2
      when 2 then 6
      when 3 then 19
      when 4 then 45
      when 5 then 90
      else 2
    end;
    v_due := now() + make_interval(days => v_days);
  else
    -- WRONG: stay or go down
    if v_old_stage <= 0 then
      v_new_stage := 0;
      v_due := now();
    else
      v_new_stage := case when v_old_stage = 1 then 1 else greatest(1, v_old_stage - 1) end;
      v_due := now(); -- immediate retry
    end if;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      next_due_at = v_due,
      last_reviewed_at = now(),
      updated_at = now()
  where user_id = v_user
    and word_id = p_word
    and category_id = p_category
    and mode = 'time'::public.srs_mode;

  return query select v_new_stage, v_due;
end;
$function$;
