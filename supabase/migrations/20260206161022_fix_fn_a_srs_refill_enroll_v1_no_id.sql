-- Fix: fn_a_srs_refill_enroll(p_user, p_category) referenziert fälschlich eine "id"-Spalte
-- in user_word_srs. Die Tabelle hat KEINE id (PK ist user_id, word_id, category_id, mode).
-- Außerdem gilt für mode=adaptive die Constraint adaptive_due_not_null -> next_due_at muss NOT NULL sein.

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
begin
  select count(*) into s1_count
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'
    and stage = 1;

  select count(*) into s0_total
  from public.user_word_srs
  where user_id = p_user
    and category_id = p_category
    and mode = 'adaptive'
    and stage = 0;

  capacity := greatest(0, 20 - s1_count);
  if capacity = 0 or s0_total = 0 then
    return 0;
  end if;

  enroll_limit := case
    when s0_total > 40 then 20
    else ceil(s0_total * 0.25)
  end;

  n := least(capacity, enroll_limit, s0_total);

  with pick as (
    select word_id
    from public.user_word_srs
    where user_id = p_user
      and category_id = p_category
      and mode = 'adaptive'
      and stage = 0
    order by created_at asc, word_id asc
    limit n
  )
  update public.user_word_srs uws
  set stage = 1,
      streak = 0,
      next_due_at = now(), -- adaptive_due_not_null
      updated_at = now()
  where uws.user_id = p_user
    and uws.category_id = p_category
    and uws.mode = 'adaptive'
    and uws.word_id in (select word_id from pick);

  return n;
end;
$function$
;


