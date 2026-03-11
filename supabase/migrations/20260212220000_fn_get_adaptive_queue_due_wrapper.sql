-- Wrapper fn_get_adaptive_queue_due für Flutter fetchAdaptiveQueue
-- Nutzt fn_user_learn_queue_adaptive (→ fn_a_srs_queue mit is_mastered=false Filter)
-- Param-Namen: p_user, p_category_id, p_take (wie vom Client erwartet)

DROP FUNCTION IF EXISTS public.fn_get_adaptive_queue_due(uuid, uuid, integer);

CREATE OR REPLACE FUNCTION public.fn_get_adaptive_queue_due(
  p_user uuid,
  p_category_id uuid,
  p_take integer DEFAULT 80
)
RETURNS TABLE(word_id uuid, category_id uuid, srs_stage integer, next_due_at timestamp with time zone, is_requeue boolean)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  select *
  from public.fn_user_learn_queue_adaptive(p_category_id, coalesce(nullif(p_take, 0), 80), p_user);
$function$;
