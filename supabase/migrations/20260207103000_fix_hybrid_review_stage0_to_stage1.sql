-- Hybrid: Fix review RPC so that stage transitions are computed per-category (user_word_srs),
-- NOT via public.user_words (fn_user_review). Otherwise words can jump (e.g. S0 -> S5)
-- because user_words.srs_stage may already be high from other modes/categories.
--
-- Goal (immediate user-visible fix):
-- - In Hybrid, a correct swipe in Stage 0 moves to Stage 1 (H1), not instantly to Stage 5.
-- - Stages are advanced conservatively: correct => +1 (max 5), wrong => -1 (min 1, except stage 0 stays 0).
-- - next_due_at is computed via fn_hybrid_lock_interval(stage) (0h for stage 0-2, then 6h/18h/72h for 3-5).

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
  v_new_stage int := 0;
  v_due timestamptz;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  -- Ensure row exists for this category/mode/word
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, ef, streak, lapses,
    next_due_at, last_reviewed_at, updated_at
  )
  values (
    v_user, p_word, p_category, 'hybrid'::public.srs_mode,
    0, 1.00, 0, 0,
    now(), null, now()
  )
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  select uws.stage
    into v_old_stage
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.word_id = p_word
    and uws.category_id = p_category
    and uws.mode = 'hybrid'::public.srs_mode
  for update;

  if not found then
    v_old_stage := 0;
  end if;

  -- Consume hybrid daily budget based on the *current* stage
  perform public.fn_hybrid_consume_budget(
    p_category,
    v_user,
    v_old_stage,
    18,  -- early budget
    12   -- late budget
  );

  if p_result then
    if v_old_stage <= 0 then
      v_new_stage := 1; -- ✅ S0 -> H1
    else
      v_new_stage := least(5, v_old_stage + 1);
    end if;
  else
    if v_old_stage <= 0 then
      v_new_stage := 0; -- stays new
    else
      v_new_stage := case when v_old_stage = 1 then 1 else greatest(1, v_old_stage - 1) end;
    end if;
  end if;

  v_due := now() + public.fn_hybrid_lock_interval(v_new_stage);

  update public.user_word_srs
  set stage = v_new_stage,
      next_due_at = v_due,
      last_reviewed_at = now(),
      updated_at = now()
  where user_id = v_user
    and word_id = p_word
    and category_id = p_category
    and mode = 'hybrid'::public.srs_mode;

  return query select v_new_stage, v_due;
end;
$function$;


