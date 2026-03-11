-- Perfekte Adaptive Queue: Phase 1 (S1-S4) vs Phase 2 (Final Round, nur S5)
-- Phase 1: Solange S1-S4 > 0, nur diese laden. Keine S5-Wiederholung.
-- Phase 2: Erst wenn S1=S2=S3=S4=0 und S5>0 → nur S5 für Final Round.

create or replace function public.fn_fetch_adaptive_queue(
  p_user uuid,
  p_category uuid,
  p_limit int default 80
)
returns table(
  word_id uuid,
  stage int,
  pass_count int,
  is_mastered boolean
)
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_lower_exists boolean;
begin

  -- Prüfen ob noch Karten in S1-S4 existieren
  select exists(
    select 1
    from public.user_word_srs
    where user_id = p_user
      and category_id = p_category
      and mode = 'adaptive'
      and stage between 1 and 4
      and coalesce(is_mastered,false) = false
  )
  into v_lower_exists;

  ------------------------------------------------
  -- PHASE 1
  ------------------------------------------------
  if v_lower_exists then

    return query
    select
      uws.word_id,
      uws.stage,
      uws.pass_count,
      coalesce(uws.is_mastered, false)
    from public.user_word_srs uws
    where uws.user_id = p_user
      and uws.category_id = p_category
      and uws.mode = 'adaptive'
      and uws.stage between 1 and 4
      and coalesce(uws.is_mastered,false) = false
    order by uws.stage asc, uws.updated_at asc
    limit p_limit;

  ------------------------------------------------
  -- PHASE 2 (Final Round)
  ------------------------------------------------
  else

    return query
    select
      uws.word_id,
      uws.stage,
      uws.pass_count,
      coalesce(uws.is_mastered, false)
    from public.user_word_srs uws
    where uws.user_id = p_user
      and uws.category_id = p_category
      and uws.mode = 'adaptive'
      and uws.stage = 5
      and coalesce(uws.is_mastered,false) = false
    order by uws.updated_at asc
    limit p_limit;

  end if;

end;
$$;
