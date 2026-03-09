-- Fix: Für mode=adaptive gilt die Constraint "adaptive_due_not_null":
-- next_due_at darf NICHT NULL sein.
-- Aktuell setzen Enroll/Refill-Funktionen next_due_at teilweise auf NULL und brechen dadurch ab,
-- wodurch A‑SRS keine Wörter in die Queue bekommt.

-- 1) Fix Enroll für komplette Kategorie
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
  -- IMPORTANT: adaptive -> next_due_at MUST be NOT NULL (adaptive_due_not_null)
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
    case
      when v_mode = 'adaptive'::public.srs_mode then now()
      else null
    end,
    null
  from public.word_categories wc
  where wc.category_id = p_category_id
  on conflict (user_id, word_id, category_id, mode)
  do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$
;

-- 2) Fix Enroll für einzelnes Wort
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
begin
  if v_user is null then
    raise exception 'No user in context (auth.uid() is NULL). Pass p_user when testing.';
  end if;

  -- 1) Ensure user_words exists (optional but recommended for your view-join)
  insert into public.user_words(user_id, word_id, picked, favorite, created_at)
  values (v_user, p_word, false, false, now())
  on conflict (user_id, word_id) do nothing;

  -- 2) Ensure user_word_srs exists for this mode/category
  insert into public.user_word_srs(
    user_id, word_id, category_id, mode,
    stage, streak, lapses, ef,
    next_due_at, last_reviewed_at
  )
  values (
    v_user, p_word, p_category, v_mode,
    0, 0, 0, 1.00,
    case
      when v_mode = 'adaptive'::public.srs_mode then now()
      else null
    end,
    now()
  )
  on conflict (user_id, word_id, category_id, mode) do nothing;
end;
$function$
;

-- 3) Fix: unsere 4-Parameter Refill-Funktion muss für adaptive ebenfalls next_due_at != NULL setzen
CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(
  p_user uuid,
  p_category uuid,
  p_mode text,
  p_refill_counter integer
)
RETURNS integer
LANGUAGE plpgsql
AS $function$
declare
  v_s1_count integer;
  v_need integer;
  v_enroll integer;
begin
  -- S1 count (mode-aware) - zähle in user_word_srs, nicht word_progress
  select count(*)
    into v_s1_count
  from public.user_word_srs uws
  where uws.user_id = p_user
    and uws.category_id = p_category
    and uws.mode::text = p_mode
    and uws.stage = 1;

  -- target band: S1_min=12, S1_max=20; enroll only if below min; enroll_limit_max=8
  v_need := greatest(0, 12 - v_s1_count);
  v_enroll := least(8, v_need);

  if v_enroll <= 0 then
    return 0;
  end if;

  -- deterministisch aus S0 nehmen (aus word_progress, da dort alle Wörter sind)
  with pick as (
    select wp.word_id
    from public.word_progress wp
    where wp.user_id = p_user
      and wp.category_id = p_category
      and wp.mode::text = p_mode
      and wp.is_mastered = false
      and wp.stage = 0
      -- Nur Wörter nehmen, die noch nicht in user_word_srs sind
      and not exists (
        select 1
        from public.user_word_srs uws
        where uws.user_id = p_user
          and uws.word_id = wp.word_id
          and uws.category_id = p_category
          and uws.mode::text = p_mode
      )
    order by wp.added_to_category_at asc, wp.word_id asc
    limit v_enroll
  ),
  -- Aktualisiere word_progress
  upd_wp as (
    update public.word_progress wp
      set stage = 1,
          ever_enrolled = true
    where wp.user_id = p_user
      and wp.category_id = p_category
      and wp.mode::text = p_mode
      and wp.word_id in (select word_id from pick)
    returning wp.word_id
  ),
  -- Erstelle Einträge in user_word_srs (wichtig für fn_user_review_mode_text!)
  upd_uws as (
    insert into public.user_word_srs(
      user_id, word_id, category_id, mode,
      stage, streak, lapses, ef,
      next_due_at, last_reviewed_at, created_at, updated_at
    )
    select
      p_user,
      u.word_id,
      p_category,
      p_mode::public.srs_mode,
      1,  -- Start in Stage 1
      0,  -- streak = 0
      0,  -- lapses = 0
      1.0, -- ef = 1.0
      now(), -- adaptive_due_not_null requires NOT NULL
      now(),
      now(),
      now()
    from upd_wp u
    on conflict (user_id, word_id, category_id, mode)
    do update set
      stage = 1,
      streak = 0,
      next_due_at = excluded.next_due_at,
      updated_at = now()
    returning word_id
  )
  insert into public.word_progress_deck_state(user_id, category_id, word_id, mode, last_queued_counter, updated_at)
  select p_user, p_category, u.word_id, p_mode, 0, now()
  from upd_uws u
  on conflict (user_id, category_id, word_id, mode)
  do update set
    last_queued_counter = 0,
    updated_at = now();

  insert into public.category_refill_state(user_id, category_id, mode, refill_counter, updated_at)
  values (p_user, p_category, p_mode, p_refill_counter, now())
  on conflict (user_id, category_id, mode)
  do update set
    refill_counter = p_refill_counter,
    updated_at = now();

  return v_enroll;
end;
$function$
;


