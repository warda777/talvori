-- A-SRS: Finale Phase starten (alle Wörter in S5 → Final Round)
-- Wird vom Flutter-Client aufgerufen, wenn User auf "Final Round" klickt.
CREATE OR REPLACE FUNCTION public.fn_a_srs_start_final_pass(
  p_category_id uuid,
  p_user uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
begin
  -- TODO: final_pass_active setzen (z.B. in a_refill_state oder eigener Tabelle)
  -- Für jetzt: No-Op, Client setzt final_pass_active lokal
  null;
end;
$$;
