-- Fix: fn_a_srs_intake referenzierte p_take, hat aber nur (p_category_id, p_user)
-- Remote-Fehler: "column p_take does not exist" in greatest(coalesce(p_take, 10), 1)
-- fn_a_srs_intake braucht kein p_take – Intake-Batch wird intern berechnet

CREATE OR REPLACE FUNCTION public.fn_a_srs_intake(
  p_category_id uuid,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_n int;
  v_s0_count int;
  v_s0_target int;
  v_intake_batch int;
  v_to_enroll int;
  v_enrolled int := 0;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  select count(*) into v_n from public.word_categories where category_id = p_category_id;
  if v_n = 0 then return 0; end if;

  select count(*) into v_s0_count
  from public.user_word_srs uws
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.stage = 0
    and coalesce(uws.ever_enrolled, false) = false
    and coalesce(uws.is_mastered, false) = false;

  v_s0_target := greatest(1, least(25, round(0.10 * v_n)::int));
  v_intake_batch := greatest(1, least(5, round(0.20 * v_s0_target)::int));

  if v_s0_count >= v_s0_target then return 0; end if;

  v_to_enroll := least(v_intake_batch, v_s0_target - v_s0_count);

  with pick as (
    select uws.word_id
    from public.user_word_srs uws
    join public.word_categories wc on wc.word_id = uws.word_id and wc.category_id = uws.category_id
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage = 0
      and coalesce(uws.ever_enrolled, false) = false
      and coalesce(uws.is_mastered, false) = false
    order by coalesce(wc.created_at, '1970-01-01'::timestamptz) asc, uws.word_id asc
    limit v_to_enroll
  )
  update public.user_word_srs uws
  set stage = 1,
      pass_count = 0,
      ever_enrolled = true,
      is_mastered = false,
      streak = 0,
      next_due_at = now(),
      updated_at = now()
  where uws.user_id = v_user
    and uws.category_id = p_category_id
    and uws.mode = 'adaptive'::public.srs_mode
    and uws.word_id in (select word_id from pick);

  get diagnostics v_enrolled = row_count;
  return v_enrolled;
end;
$function$;
