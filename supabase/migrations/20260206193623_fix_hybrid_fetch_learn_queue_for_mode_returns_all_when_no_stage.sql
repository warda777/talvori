-- Fix: Hybrid-Learn-Mode darf nicht leer werden.
-- Aktuell filtert fetch_learn_queue_for_mode bei p_mode='hybrid' immer auf ns.next_stage
-- (fn_hybrid_next_stage). Wenn next_stage NULL ist oder eine Stage ohne Karten wählt, kommen 0 Rows
-- -> App zeigt "Keine Wörter verfügbar".
--
-- Erwartung im Learn-Mode (s0toS5): wenn p_stage NULL ist, sollen wie bei 'time' alle Stages 0..5
-- geliefert werden. Stage-selektives Verhalten (single) bleibt über p_stage erhalten.

CREATE OR REPLACE FUNCTION public.fetch_learn_queue_for_mode(
  p_category_id uuid,
  p_mode text,
  p_stage integer DEFAULT NULL::integer,
  p_limit integer DEFAULT 200
)
RETURNS TABLE(word_id uuid, srs_stage integer)
LANGUAGE sql
STABLE
AS $function$
select
  wc.word_id,
  coalesce(uws.stage, 0) as srs_stage
from public.word_categories wc
left join public.user_word_srs uws
  on uws.user_id = auth.uid()
 and uws.word_id = wc.word_id
 and uws.category_id = wc.category_id
 and uws.mode = p_mode::public.srs_mode
where wc.category_id = p_category_id
  and (
    case
      -- Stage-Specific (single): strikt filtern
      when p_stage is not null then coalesce(uws.stage, 0) = p_stage
      -- s0toS5 (kein p_stage): IMMER alle Stages (auch Hybrid)
      else coalesce(uws.stage, 0) between 0 and 5
    end
  )
order by
  -- Reviews (S1–S5) zuerst, New (S0) zuletzt
  case when coalesce(uws.stage, 0) = 0 then 1 else 0 end asc,
  uws.last_reviewed_at nulls first,
  wc.word_id
limit p_limit;
$function$;


