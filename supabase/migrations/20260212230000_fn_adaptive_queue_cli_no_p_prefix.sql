-- Workaround für "column p_take does not exist": Umgeht fn_user_learn_queue_adaptive komplett
-- Ruft fn_user_learn_queue_adaptive_impl direkt mit Parametern OHNE p_-Präfix auf

DROP FUNCTION IF EXISTS public.fn_adaptive_queue_cli(uuid, uuid, integer);

CREATE OR REPLACE FUNCTION public.fn_adaptive_queue_cli(
  category_id uuid,
  user_id uuid,
  take_limit integer DEFAULT 80
)
RETURNS TABLE(word_id uuid, category_id uuid, srs_stage integer, next_due_at timestamp with time zone, is_requeue boolean)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
  select
    out_word_id as word_id,
    out_category_id as category_id,
    out_srs_stage as srs_stage,
    out_next_due_at as next_due_at,
    out_is_requeue as is_requeue
  from public.fn_user_learn_queue_adaptive_impl(
    category_id,
    greatest(coalesce(nullif(take_limit, 0), 80), 1),
    user_id
  );
$function$;

GRANT EXECUTE ON FUNCTION public.fn_adaptive_queue_cli(uuid, uuid, integer) TO anon;
GRANT EXECUTE ON FUNCTION public.fn_adaptive_queue_cli(uuid, uuid, integer) TO authenticated;
