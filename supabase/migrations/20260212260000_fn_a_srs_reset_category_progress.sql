-- A-SRS: Kategorie-Progress zurücksetzen (alle Wörter → S0)
-- Wird von Restart-Button und performReset (adaptive) genutzt
create or replace function public.fn_a_srs_reset_category_progress(
  p_category_id uuid,
  p_user uuid default auth.uid()
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := coalesce(p_user, auth.uid());
  v_count integer := 0;
begin
  if v_user is null then
    raise exception 'No user in context';
  end if;

  update public.user_word_srs
  set
    stage = 0,
    pass_count = 0,
    is_mastered = false,
    ever_enrolled = false,
    streak = 0,
    lapses = 0,
    next_due_at = now(),
    last_reviewed_at = null,
    updated_at = now()
  where user_id = v_user
    and category_id = p_category_id
    and mode = 'adaptive'::public.srs_mode;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;
