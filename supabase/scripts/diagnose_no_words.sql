-- Diagnose: "Keine Wörter" auf der Karte
-- Im Supabase SQL Editor ausführen. Ersetze YOUR_USER_ID und YOUR_CATEGORY_ID durch echte Werte.
-- User-ID: Supabase Auth → Users → deine User-UUID
-- Kategorie-ID: z.B. aus dem Screenshot (catId=f8e14f1e-...) oder aus categories Tabelle

-- 1️⃣ Wörter in Kategorien (word_categories)
SELECT '1. word_categories: Wörter pro Kategorie (Top 10)' AS check_name;
SELECT category_id, COUNT(*) AS word_count
FROM public.word_categories
GROUP BY category_id
ORDER BY word_count DESC
LIMIT 10;

-- 2️⃣ Für eine konkrete Kategorie: Ersetze 'YOUR_CATEGORY_ID' durch UUID (z.B. f8e14f1e-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
-- SELECT '2. Wörter in Kategorie X' AS check_name;
-- SELECT COUNT(*) AS cnt FROM public.word_categories WHERE category_id = 'YOUR_CATEGORY_ID'::uuid;

-- 3️⃣ user_word_srs für adaptive (alle User)
SELECT '3. user_word_srs (adaptive): Einträge pro Kategorie' AS check_name;
SELECT category_id, COUNT(*) AS cnt
FROM public.user_word_srs
WHERE mode = 'adaptive'
GROUP BY category_id
ORDER BY cnt DESC
LIMIT 10;

-- 4️⃣ fn_category_word_count für erste Kategorie
SELECT '4. fn_category_word_count für erste Kategorie' AS check_name;
SELECT fn_category_word_count(category_id) AS word_count, category_id
FROM (SELECT category_id FROM public.word_categories LIMIT 1) sub;

-- 5️⃣ fn_user_learn_queue_adaptive Test (User + Kategorie ersetzen!)
-- SELECT '5. fn_user_learn_queue_adaptive' AS check_name;
-- SELECT * FROM fn_user_learn_queue_adaptive(
--   'YOUR_CATEGORY_ID'::uuid,
--   80,
--   'YOUR_USER_ID'::uuid
-- );

-- 6️⃣ A-SRS Bootstrap-Check: S0-Rows in user_word_srs für Kategorie (Ersetze YOUR_CATEGORY_ID, YOUR_USER_ID)
-- SELECT '6. user_word_srs S0-Rows (Bootstrap-Quelle)' AS check_name;
-- SELECT COUNT(*) AS s0_count
-- FROM public.user_word_srs uws
-- WHERE uws.user_id = 'YOUR_USER_ID'::uuid
--   AND uws.category_id = 'YOUR_CATEGORY_ID'::uuid
--   AND uws.mode = 'adaptive'
--   AND uws.stage = 0
--   AND COALESCE(uws.ever_enrolled, false) = false
--   AND COALESCE(uws.is_mastered, false) = false;
