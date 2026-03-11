-- A-SRS: Guard für bereits gemasterte Wörter in fn_a_srs_review
-- Problem: Gemasterte Wörter (is_mastered=true) landeten im Final-Round-Deck und wurden
-- beim Review ent-mastered (pass_count=1, is_mastered=false) → Mastered-Zahlen sanken.
-- Lösung: Wenn is_mastered=true, keine Änderung vornehmen, aktuellen Status zurückgeben.

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
  v_pass_count int;
  v_ever bool;
  v_mastered bool;
  v_new_stage int;
  v_new_pass_count int;
  v_new_is_mastered bool;
begin
  select uws.stage, uws.pass_count, uws.ever_enrolled, uws.is_mastered
    into v_stage, v_pass_count, v_ever, v_mastered
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

  -- Guard: Bereits gemasterte Wörter nicht erneut reviewen (verhindert Ent-Mastering)
  if coalesce(v_mastered, false) then
    srs_stage := v_stage;
    pass_count := coalesce(v_pass_count, 0);
    is_mastered := true;
    return next;
    return;
  end if;

  if p_result then
    if v_stage = 1 then
      v_new_pass_count := coalesce(v_pass_count, 0) + 1;
      if v_new_pass_count >= 2 then
        v_new_stage := 2;
        v_new_pass_count := 0;
      else
        v_new_stage := 1;
      end if;
      v_new_is_mastered := false;

    elsif v_stage = 2 then
      v_new_pass_count := coalesce(v_pass_count, 0) + 1;
      if v_new_pass_count >= 2 then
        v_new_stage := 3;
        v_new_pass_count := 0;
      else
        v_new_stage := 2;
      end if;
      v_new_is_mastered := false;

    elsif v_stage = 3 then
      v_new_pass_count := coalesce(v_pass_count, 0) + 1;
      if v_new_pass_count >= 2 then
        v_new_stage := 4;
        v_new_pass_count := 0;
      else
        v_new_stage := 3;
      end if;
      v_new_is_mastered := false;

    elsif v_stage = 4 then
      v_new_pass_count := coalesce(v_pass_count, 0) + 1;
      if v_new_pass_count >= 3 then
        v_new_stage := 5;
        v_new_pass_count := 0;
      else
        v_new_stage := 4;
      end if;
      v_new_is_mastered := false;

    elsif v_stage = 5 then
      v_new_pass_count := coalesce(v_pass_count, 0) + 1;
      v_new_stage := 5;
      if v_new_pass_count >= 3 then
        v_new_is_mastered := true;
        v_new_pass_count := 0;
      else
        v_new_is_mastered := false;
      end if;

    else
      v_new_stage := 1;
      v_new_pass_count := 0;
      v_new_is_mastered := false;
    end if;

  else
    v_new_is_mastered := false;
    v_new_pass_count := 0;
    if v_stage <= 1 then
      v_new_stage := 1;
    else
      v_new_stage := v_stage - 1;
    end if;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      pass_count = v_new_pass_count,
      is_mastered = v_new_is_mastered,
      updated_at = now(),
      last_reviewed_at = now(),
      next_due_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = 'adaptive'::public.srs_mode;

  srs_stage := v_new_stage;
  pass_count := v_new_pass_count;
  is_mastered := v_new_is_mastered;
  return next;
end;
$function$;
