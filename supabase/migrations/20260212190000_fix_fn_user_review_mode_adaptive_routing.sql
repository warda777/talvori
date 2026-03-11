-- Fix: fn_user_review_mode MUSS für mode=adaptive fn_a_srs_review aufrufen (pass_count-Logik)
-- Wenn fn_user_review_mode_text verwendet wird, bleibt pass_count=0 und Wörter werden nie mastered.
-- Diese Migration stellt sicher, dass adaptive korrekt zu fn_a_srs_review routed wird.

DROP FUNCTION IF EXISTS public.fn_user_review_mode(uuid, public.srs_mode, boolean, uuid, uuid);

CREATE OR REPLACE FUNCTION public.fn_user_review_mode(
  p_category uuid,
  p_mode public.srs_mode,
  p_result boolean,
  p_user uuid,
  p_word uuid
)
RETURNS TABLE(srs_stage integer, next_due_at timestamp with time zone)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
begin
  if p_mode = 'adaptive'::public.srs_mode then
    return query
    select r.srs_stage, now() as next_due_at
    from public.fn_a_srs_review(p_user, p_category, p_word, p_result) r;
  else
    return query
    select * from public.fn_user_review_mode_text(p_user, p_category, p_word, p_mode::text, p_result);
  end if;
end;
$function$;
