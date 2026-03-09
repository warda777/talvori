-- A-SRS Diagnose: Prüft ob pass_count gespeichert wird und ob Scheduler korrekt ist
-- Ausführen: psql -f asrs_diagnose.sql oder im Supabase SQL Editor

-- 1️⃣ pass_count in user_word_srs
SELECT '1. pass_count Spalte' AS check_name;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'user_word_srs'
  AND column_name IN ('pass_count', 'stage', 'ever_enrolled', 'is_mastered', 'updated_at');

-- 2️⃣ Stage-Verteilung in user_word_srs (adaptive)
SELECT '2. Stage-Verteilung (user_word_srs, mode=adaptive)' AS check_name;
SELECT stage, COUNT(*) AS cnt
FROM public.user_word_srs
WHERE mode = 'adaptive'
GROUP BY stage
ORDER BY stage;

-- 3️⃣ pass_count-Werte pro Stage (S1-S5)
SELECT '3. pass_count pro Stage (S1-S5)' AS check_name;
SELECT stage, pass_count, COUNT(*) AS cnt
FROM public.user_word_srs
WHERE mode = 'adaptive' AND stage BETWEEN 1 AND 5
GROUP BY stage, pass_count
ORDER BY stage, pass_count;

-- 4️⃣ Welche fn_user_review_mode für adaptive?
SELECT '4. fn_user_review_mode Definition (adaptive)' AS check_name;
SELECT pg_get_functiondef(oid)::text LIKE '%fn_a_srs_review%' AS uses_fn_a_srs_review
FROM pg_proc
WHERE proname = 'fn_user_review_mode';

-- 5️⃣ Welche fn_user_learn_queue_adaptive_impl?
SELECT '5. fn_user_learn_queue_adaptive_impl nutzt fn_a_srs_queue?' AS check_name;
SELECT pg_get_functiondef(oid)::text LIKE '%fn_a_srs_queue%' AS uses_fn_a_srs_queue
FROM pg_proc
WHERE proname = 'fn_user_learn_queue_adaptive_impl';

-- 6️⃣ Beispiel: S1-Karten mit pass_count
SELECT '6. Beispiel S1-Karten (stage, pass_count, updated_at)' AS check_name;
SELECT word_id, stage, pass_count, updated_at
FROM public.user_word_srs
WHERE mode = 'adaptive' AND stage = 1
ORDER BY updated_at DESC
LIMIT 10;
