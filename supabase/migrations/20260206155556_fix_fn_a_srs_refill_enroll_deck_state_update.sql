-- Fix: fn_a_srs_refill_enroll muss word_progress_deck_state korrekt aktualisieren
-- Das Problem: Die Refill-Funktion verwendet "on conflict do nothing", was bedeutet,
-- dass bestehende Einträge nicht aktualisiert werden. Die Queue-Funktion benötigt
-- jedoch aktualisierte last_queued_counter Werte.

CREATE OR REPLACE FUNCTION public.fn_a_srs_refill_enroll(p_user uuid, p_category uuid, p_mode text, p_refill_counter integer)
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
      null, -- next_due_at = null (A-SRS hat kein Time-Due)
      now(), -- last_reviewed_at = now()
      now(), -- created_at = now()
      now()  -- updated_at = now()
    from upd_wp u
    on conflict (user_id, word_id, category_id, mode)
    do update set
      stage = 1,
      streak = 0,
      updated_at = now()
    returning word_id
  )
  -- FIX: Stelle sicher, dass deck-state rows existieren UND last_queued_counter auf 0 gesetzt wird
  -- (nicht -1, damit die Queue-Funktion sie findet)
  insert into public.word_progress_deck_state(user_id, category_id, word_id, mode, last_queued_counter, updated_at)
  select p_user, p_category, u.word_id, p_mode, 0, now()
  from upd_uws u
  on conflict (user_id, category_id, word_id, mode) 
  do update set
    last_queued_counter = 0,  -- WICHTIG: Setze auf 0, damit die Queue-Funktion sie findet
    updated_at = now();

  return v_enroll;
end;
$function$
;

