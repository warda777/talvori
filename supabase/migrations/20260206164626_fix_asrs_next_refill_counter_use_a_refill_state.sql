-- A‑SRS: refill_counter muss in a_refill_state erhöht werden (Queue nutzt a_refill_state)
--
-- Symptom (aus Logs):
-- - Erstes Deck lädt (weil last_queued_counter=-1 und refill_counter=0 => -1 < 0 true)
-- - Danach setzt mark_queued last_queued_counter=0
-- - Nächstes Deck: refill_counter bleibt 0 (weil fn_a_srs_next_refill_counter bisher category_refill_state updated),
--   somit 0 < 0 ist false => Queue liefert 0 Rows => "Keine Wörter verfügbar".
--
-- Fix:
-- - Wenn p_mode='adaptive' => a_refill_state (text keys) inkrementieren und zurückgeben.
-- - Für andere Modes bleibt das alte Verhalten (category_refill_state) erhalten.

CREATE OR REPLACE FUNCTION public.fn_a_srs_next_refill_counter(
  p_user uuid,
  p_category uuid,
  p_mode text
)
RETURNS integer
LANGUAGE plpgsql
AS $function$
declare
  v_new integer;
begin
  if p_mode = 'adaptive' then
    insert into public.a_refill_state(user_id, category_id, mode, refill_counter)
    values (p_user::text, p_category::text, p_mode, 1)
    on conflict (user_id, category_id, mode)
    do update set refill_counter = public.a_refill_state.refill_counter + 1
    returning refill_counter into v_new;

    return v_new;
  end if;

  insert into public.category_refill_state(user_id, category_id, mode, refill_counter)
  values (p_user, p_category, p_mode, 1)
  on conflict (user_id, category_id, mode)
  do update set refill_counter = public.category_refill_state.refill_counter + 1,
               updated_at = now()
  returning refill_counter into v_new;

  return v_new;
end;
$function$;


