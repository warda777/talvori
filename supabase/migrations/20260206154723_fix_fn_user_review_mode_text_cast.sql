-- Fix: fn_user_review_mode_text muss mode mit p_mode::srs_mode vergleichen
-- Der Fehler "operator does not exist: srs_mode = text" tritt auf, weil
-- mode (srs_mode enum) direkt mit p_mode (text) verglichen wird

CREATE OR REPLACE FUNCTION public.fn_user_review_mode_text(p_user uuid, p_category uuid, p_word uuid, p_mode text, p_result boolean)
 RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_stage   int;
  v_streak  int;
  v_ef      numeric;
  v_lapses  int;

  v_new_stage  int;
  v_new_streak int;
begin
  -- 1) HARD CONTRACT: niemals implicit enrollen (S0 darf nicht reviewed werden)
  select stage, streak, ef, lapses
    into v_stage, v_streak, v_ef, v_lapses
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = (p_mode::public.srs_mode)  -- FIX: Cast text to srs_mode enum
  for update;

  if not found then
    raise exception 'A-SRS: word not enrolled (S0) - use refill/enroll first'
      using errcode = 'P0001';
  end if;

  -- 2) Promotion-Regel: erst nach 2× korrekt in Folge promoten
  if p_result is true then
    v_new_streak := v_streak + 1;

    if v_new_streak >= 2 then
      v_new_stage := least(v_stage + 1, 5);
      v_new_streak := 0; -- nach Promotion streak reset
    else
      v_new_stage := v_stage; -- bleibt in Stage, nur streak steigt
    end if;

  else
    -- falsch: einfacher Bounce nach unten (konservativ), streak reset, lapses++
    v_new_stage := greatest(v_stage - 1, 1); -- niemals auf 0 (S0 ist "nicht enrolled")
    v_new_streak := 0;
    v_lapses := v_lapses + 1;
  end if;

  update public.user_word_srs
  set stage = v_new_stage,
      streak = v_new_streak,
      lapses = v_lapses,
      last_reviewed_at = now(),
      updated_at = now()
  where user_id = p_user
    and category_id = p_category
    and word_id = p_word
    and mode = (p_mode::public.srs_mode);  -- FIX: Cast text to srs_mode enum

  -- aktuell gibst du eh null zurück, daher lassen wir next_due_at = null
  srs_stage := v_new_stage;
  next_due_at := null;
  return next;
end;
$function$
;

