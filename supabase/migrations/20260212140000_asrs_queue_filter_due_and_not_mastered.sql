-- A-SRS Queue: Nur fällige, nicht gemasterte Karten
-- Filter: is_mastered = false AND next_due_at <= now()
-- S5 mit next_due_at in der Zukunft darf NIEMALS in die Queue

CREATE OR REPLACE FUNCTION public.fn_a_srs_queue(
  p_category_id uuid,
  p_take integer DEFAULT 50,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(out_word_id uuid, out_srs_stage integer, out_updated_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 50), 1);
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  return query
  with
  active as (
    select uws.word_id, uws.stage, uws.updated_at,
           (case uws.stage when 1 then 6 when 2 then 5 when 3 then 4 when 4 then 3 when 5 then 2 else 0 end)::float as w
    from public.user_word_srs uws
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage between 1 and 5
      and coalesce(uws.is_mastered, false) = false
      and uws.next_due_at <= now()
  )
  select a.word_id, a.stage::int, a.updated_at
  from active a
  order by random() * a.w desc, a.updated_at asc, a.word_id
  limit v_take;
end;
$function$;
