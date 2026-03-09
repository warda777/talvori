-- A-SRS Bootstrap: Wenn fn_a_srs_queue leer ist, S0-Wörter zurückgeben
-- Problem: Nach Reset/Enroll kann fn_a_srs_intake 0 fördern (z.B. S0_target erreicht),
-- dann liefert fn_a_srs_queue nichts → "Keine Wörter verfügbar"
-- Lösung: Fallback auf S0-Wörter (stage=0, ever_enrolled=false) wenn Queue leer

CREATE OR REPLACE FUNCTION public.fn_user_learn_queue_adaptive_impl(
  p_category_id uuid,
  p_take integer DEFAULT 30,
  p_user uuid DEFAULT NULL::uuid
)
RETURNS TABLE(
  out_word_id uuid,
  out_category_id uuid,
  out_srs_stage integer,
  out_next_due_at timestamp with time zone,
  out_is_requeue boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_take int := greatest(coalesce(p_take, 30), 1);
  v_cnt int;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  perform public.fn_a_srs_intake(p_category_id, v_user);

  -- 1) Normale Queue (S1-S5) in temp table
  create temp table if not exists _asrs_queue_tmp (
    out_word_id uuid,
    out_category_id uuid,
    out_srs_stage int,
    out_next_due_at timestamptz,
    out_is_requeue bool
  ) on commit drop;
  delete from _asrs_queue_tmp;

  insert into _asrs_queue_tmp (out_word_id, out_category_id, out_srs_stage, out_next_due_at, out_is_requeue)
  select
    q.out_word_id,
    p_category_id,
    q.out_srs_stage,
    q.out_updated_at,
    false
  from public.fn_a_srs_queue(p_category_id, v_take, v_user) q;

  get diagnostics v_cnt = row_count;

  -- 2) Wenn leer: S0-Bootstrap
  if v_cnt = 0 then
    insert into _asrs_queue_tmp (out_word_id, out_category_id, out_srs_stage, out_next_due_at, out_is_requeue)
    select
      uws.word_id,
      uws.category_id,
      0,
      coalesce(uws.next_due_at, now()),
      false
    from public.user_word_srs uws
    where uws.user_id = v_user
      and uws.category_id = p_category_id
      and uws.mode = 'adaptive'::public.srs_mode
      and uws.stage = 0
      and coalesce(uws.ever_enrolled, false) = false
      and coalesce(uws.is_mastered, false) = false
    order by coalesce(uws.added_to_category_at, uws.created_at) asc, uws.word_id asc
    limit v_take;
  end if;

  return query select * from _asrs_queue_tmp;
end;
$function$;
