-- A‑SRS: Refill-Trigger am Minimum
-- Problem: Wir haben Refill blockiert bei s1_count >= S1_min.
-- Dadurch wird bei s1_count == S1_min (z.B. 10) NICHT nachgeladen, obwohl der Contract sagt,
-- dass ab Erreichen des Minimums nachgeladen werden soll, um wieder Richtung Max zu füllen.

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
  s1_min constant int := 10;
  s1_max constant int := 20;
begin
  select count(*) into s1_count
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 1;

  select count(*) into s0_total
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'::public.srs_mode
    and stage = 0;

  -- ✅ Refill soll erlaubt sein, sobald S1 das Minimum erreicht (== s1_min).
  --    Blockiere nur, wenn wir ÜBER dem Minimum sind.
  if s1_count > s1_min then
    return 0;
  end if;

  capacity := greatest(0, s1_max - s1_count);
  if capacity = 0 or s0_total = 0 then
    return 0;
  end if;

  enroll_limit := case
    when s0_total > 40 then 20
    else ceil(s0_total * 0.25)
  end;

  n := least(capacity, enroll_limit, s0_total);

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


