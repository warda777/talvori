-- Manual safe-subset language-code normalization for public.words.
--
-- Purpose:
--   Normalize only EN/DE candidates that have no conflicting en/de row with
--   the same text.
--
-- Safety notes:
--   - Run manually in the Supabase SQL Editor only.
--   - Do not run this from Flutter or a local tool.
--   - This updates only public.words.from_lang and public.words.to_lang.
--   - This does not change text, translation, categories, word_progress,
--     user_word_srs, user_words, pass_count, stage, is_mastered, or next_due_at.
--   - The original 25-candidate update is blocked by words_text_lang_uniq.
--   - This script derives the safe subset dynamically from the 25 reviewed ids
--     and skips any candidate where an en/de row with the same text exists.
--   - The prior SQL analysis showed 16 non-conflicting rows.

-- Before: inspect the safe subset that would be normalized.
WITH candidates(id) AS (
  VALUES
    ('0003d2c4-9558-42b6-bf79-aa099e3f4701'::uuid),
    ('42cba640-454e-447b-b0e0-e5a44f8968c7'::uuid),
    ('3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'::uuid),
    ('b4b7f57d-f73a-492a-a693-63110229f7d7'::uuid),
    ('577f310a-1c4b-4e42-a925-187ba159394a'::uuid),
    ('0febef01-f685-4c8b-8826-af7753746fa3'::uuid),
    ('8915c19f-b3b8-44f6-a63c-6adea030086a'::uuid),
    ('0a29d3d0-ad57-4c78-94b7-ad6d603915c0'::uuid),
    ('297c7517-c6ea-4340-9601-6405ee65d654'::uuid),
    ('37a99d9c-9192-44ce-83b9-08eee8bca169'::uuid),
    ('715a3af7-0244-4fff-a382-6ae153c66b0c'::uuid),
    ('8b48b271-2a4e-472e-a0d1-99c142cdc1ab'::uuid),
    ('1aff8ead-820c-447c-9dc9-fe5981d91412'::uuid),
    ('0c165b4c-2afb-4861-ac60-75bf59a8611b'::uuid),
    ('ac426143-a234-4394-b48a-0928e6489b6c'::uuid),
    ('31b9fd7e-fbbf-44fa-af67-40c66144f843'::uuid),
    ('32464b29-fec5-4fd3-ba25-a873e3b0f8eb'::uuid),
    ('9dea269e-4638-47bc-b4c9-3ca0c7e21733'::uuid),
    ('87e752ea-e944-469a-ad9e-9037a79ee7d5'::uuid),
    ('66d4eaa9-66d7-47fb-a8e6-58e14823e1a2'::uuid),
    ('61ca2b4e-332c-4a20-82a8-76e962482f15'::uuid),
    ('fd72add0-6144-4b98-bc52-4a737434c4ac'::uuid),
    ('094a3407-d275-4ea9-ad89-198218618dcf'::uuid),
    ('2a7e4ef2-4585-4b25-9c63-d81bc694cce5'::uuid),
    ('6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'::uuid)
),
safe_candidates AS (
  SELECT w.id, w.text, w.translation, w.from_lang, w.to_lang
  FROM public.words w
  JOIN candidates c ON c.id = w.id
  WHERE w.from_lang = 'EN'
    AND w.to_lang = 'DE'
    AND NOT EXISTS (
      SELECT 1
      FROM public.words conflict
      WHERE conflict.text = w.text
        AND conflict.from_lang = 'en'
        AND conflict.to_lang = 'de'
        AND conflict.id <> w.id
    )
)
SELECT id, text, translation, from_lang, to_lang
FROM safe_candidates
ORDER BY text;

-- Optional sanity count: expected 16 rows based on the prior analysis.
WITH candidates(id) AS (
  VALUES
    ('0003d2c4-9558-42b6-bf79-aa099e3f4701'::uuid),
    ('42cba640-454e-447b-b0e0-e5a44f8968c7'::uuid),
    ('3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'::uuid),
    ('b4b7f57d-f73a-492a-a693-63110229f7d7'::uuid),
    ('577f310a-1c4b-4e42-a925-187ba159394a'::uuid),
    ('0febef01-f685-4c8b-8826-af7753746fa3'::uuid),
    ('8915c19f-b3b8-44f6-a63c-6adea030086a'::uuid),
    ('0a29d3d0-ad57-4c78-94b7-ad6d603915c0'::uuid),
    ('297c7517-c6ea-4340-9601-6405ee65d654'::uuid),
    ('37a99d9c-9192-44ce-83b9-08eee8bca169'::uuid),
    ('715a3af7-0244-4fff-a382-6ae153c66b0c'::uuid),
    ('8b48b271-2a4e-472e-a0d1-99c142cdc1ab'::uuid),
    ('1aff8ead-820c-447c-9dc9-fe5981d91412'::uuid),
    ('0c165b4c-2afb-4861-ac60-75bf59a8611b'::uuid),
    ('ac426143-a234-4394-b48a-0928e6489b6c'::uuid),
    ('31b9fd7e-fbbf-44fa-af67-40c66144f843'::uuid),
    ('32464b29-fec5-4fd3-ba25-a873e3b0f8eb'::uuid),
    ('9dea269e-4638-47bc-b4c9-3ca0c7e21733'::uuid),
    ('87e752ea-e944-469a-ad9e-9037a79ee7d5'::uuid),
    ('66d4eaa9-66d7-47fb-a8e6-58e14823e1a2'::uuid),
    ('61ca2b4e-332c-4a20-82a8-76e962482f15'::uuid),
    ('fd72add0-6144-4b98-bc52-4a737434c4ac'::uuid),
    ('094a3407-d275-4ea9-ad89-198218618dcf'::uuid),
    ('2a7e4ef2-4585-4b25-9c63-d81bc694cce5'::uuid),
    ('6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'::uuid)
)
SELECT count(*) AS safe_subset_count
FROM public.words w
JOIN candidates c ON c.id = w.id
WHERE w.from_lang = 'EN'
  AND w.to_lang = 'DE'
  AND NOT EXISTS (
    SELECT 1
    FROM public.words conflict
    WHERE conflict.text = w.text
      AND conflict.from_lang = 'en'
      AND conflict.to_lang = 'de'
      AND conflict.id <> w.id
  );

UPDATE public.words w
SET from_lang = 'en',
    to_lang = 'de'
FROM (
  WITH candidates(id) AS (
    VALUES
      ('0003d2c4-9558-42b6-bf79-aa099e3f4701'::uuid),
      ('42cba640-454e-447b-b0e0-e5a44f8968c7'::uuid),
      ('3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'::uuid),
      ('b4b7f57d-f73a-492a-a693-63110229f7d7'::uuid),
      ('577f310a-1c4b-4e42-a925-187ba159394a'::uuid),
      ('0febef01-f685-4c8b-8826-af7753746fa3'::uuid),
      ('8915c19f-b3b8-44f6-a63c-6adea030086a'::uuid),
      ('0a29d3d0-ad57-4c78-94b7-ad6d603915c0'::uuid),
      ('297c7517-c6ea-4340-9601-6405ee65d654'::uuid),
      ('37a99d9c-9192-44ce-83b9-08eee8bca169'::uuid),
      ('715a3af7-0244-4fff-a382-6ae153c66b0c'::uuid),
      ('8b48b271-2a4e-472e-a0d1-99c142cdc1ab'::uuid),
      ('1aff8ead-820c-447c-9dc9-fe5981d91412'::uuid),
      ('0c165b4c-2afb-4861-ac60-75bf59a8611b'::uuid),
      ('ac426143-a234-4394-b48a-0928e6489b6c'::uuid),
      ('31b9fd7e-fbbf-44fa-af67-40c66144f843'::uuid),
      ('32464b29-fec5-4fd3-ba25-a873e3b0f8eb'::uuid),
      ('9dea269e-4638-47bc-b4c9-3ca0c7e21733'::uuid),
      ('87e752ea-e944-469a-ad9e-9037a79ee7d5'::uuid),
      ('66d4eaa9-66d7-47fb-a8e6-58e14823e1a2'::uuid),
      ('61ca2b4e-332c-4a20-82a8-76e962482f15'::uuid),
      ('fd72add0-6144-4b98-bc52-4a737434c4ac'::uuid),
      ('094a3407-d275-4ea9-ad89-198218618dcf'::uuid),
      ('2a7e4ef2-4585-4b25-9c63-d81bc694cce5'::uuid),
      ('6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'::uuid)
  )
  SELECT candidate.id
  FROM public.words candidate
  JOIN candidates c ON c.id = candidate.id
  WHERE candidate.from_lang = 'EN'
    AND candidate.to_lang = 'DE'
    AND NOT EXISTS (
      SELECT 1
      FROM public.words conflict
      WHERE conflict.text = candidate.text
        AND conflict.from_lang = 'en'
        AND conflict.to_lang = 'de'
        AND conflict.id <> candidate.id
    )
) safe_candidates
WHERE w.id = safe_candidates.id
  AND w.from_lang = 'EN'
  AND w.to_lang = 'DE';

-- After: inspect the full 25-candidate set.
WITH candidates(id) AS (
  VALUES
    ('0003d2c4-9558-42b6-bf79-aa099e3f4701'::uuid),
    ('42cba640-454e-447b-b0e0-e5a44f8968c7'::uuid),
    ('3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'::uuid),
    ('b4b7f57d-f73a-492a-a693-63110229f7d7'::uuid),
    ('577f310a-1c4b-4e42-a925-187ba159394a'::uuid),
    ('0febef01-f685-4c8b-8826-af7753746fa3'::uuid),
    ('8915c19f-b3b8-44f6-a63c-6adea030086a'::uuid),
    ('0a29d3d0-ad57-4c78-94b7-ad6d603915c0'::uuid),
    ('297c7517-c6ea-4340-9601-6405ee65d654'::uuid),
    ('37a99d9c-9192-44ce-83b9-08eee8bca169'::uuid),
    ('715a3af7-0244-4fff-a382-6ae153c66b0c'::uuid),
    ('8b48b271-2a4e-472e-a0d1-99c142cdc1ab'::uuid),
    ('1aff8ead-820c-447c-9dc9-fe5981d91412'::uuid),
    ('0c165b4c-2afb-4861-ac60-75bf59a8611b'::uuid),
    ('ac426143-a234-4394-b48a-0928e6489b6c'::uuid),
    ('31b9fd7e-fbbf-44fa-af67-40c66144f843'::uuid),
    ('32464b29-fec5-4fd3-ba25-a873e3b0f8eb'::uuid),
    ('9dea269e-4638-47bc-b4c9-3ca0c7e21733'::uuid),
    ('87e752ea-e944-469a-ad9e-9037a79ee7d5'::uuid),
    ('66d4eaa9-66d7-47fb-a8e6-58e14823e1a2'::uuid),
    ('61ca2b4e-332c-4a20-82a8-76e962482f15'::uuid),
    ('fd72add0-6144-4b98-bc52-4a737434c4ac'::uuid),
    ('094a3407-d275-4ea9-ad89-198218618dcf'::uuid),
    ('2a7e4ef2-4585-4b25-9c63-d81bc694cce5'::uuid),
    ('6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'::uuid)
)
SELECT w.id, w.text, w.translation, w.from_lang, w.to_lang
FROM public.words w
JOIN candidates c ON c.id = w.id
ORDER BY w.text;

-- Control: should return 0 rows for the safe subset after successful update.
WITH candidates(id) AS (
  VALUES
    ('0003d2c4-9558-42b6-bf79-aa099e3f4701'::uuid),
    ('42cba640-454e-447b-b0e0-e5a44f8968c7'::uuid),
    ('3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb'::uuid),
    ('b4b7f57d-f73a-492a-a693-63110229f7d7'::uuid),
    ('577f310a-1c4b-4e42-a925-187ba159394a'::uuid),
    ('0febef01-f685-4c8b-8826-af7753746fa3'::uuid),
    ('8915c19f-b3b8-44f6-a63c-6adea030086a'::uuid),
    ('0a29d3d0-ad57-4c78-94b7-ad6d603915c0'::uuid),
    ('297c7517-c6ea-4340-9601-6405ee65d654'::uuid),
    ('37a99d9c-9192-44ce-83b9-08eee8bca169'::uuid),
    ('715a3af7-0244-4fff-a382-6ae153c66b0c'::uuid),
    ('8b48b271-2a4e-472e-a0d1-99c142cdc1ab'::uuid),
    ('1aff8ead-820c-447c-9dc9-fe5981d91412'::uuid),
    ('0c165b4c-2afb-4861-ac60-75bf59a8611b'::uuid),
    ('ac426143-a234-4394-b48a-0928e6489b6c'::uuid),
    ('31b9fd7e-fbbf-44fa-af67-40c66144f843'::uuid),
    ('32464b29-fec5-4fd3-ba25-a873e3b0f8eb'::uuid),
    ('9dea269e-4638-47bc-b4c9-3ca0c7e21733'::uuid),
    ('87e752ea-e944-469a-ad9e-9037a79ee7d5'::uuid),
    ('66d4eaa9-66d7-47fb-a8e6-58e14823e1a2'::uuid),
    ('61ca2b4e-332c-4a20-82a8-76e962482f15'::uuid),
    ('fd72add0-6144-4b98-bc52-4a737434c4ac'::uuid),
    ('094a3407-d275-4ea9-ad89-198218618dcf'::uuid),
    ('2a7e4ef2-4585-4b25-9c63-d81bc694cce5'::uuid),
    ('6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'::uuid)
)
SELECT w.id, w.text, w.translation, w.from_lang, w.to_lang
FROM public.words w
JOIN candidates c ON c.id = w.id
WHERE w.from_lang = 'EN'
  AND w.to_lang = 'DE'
  AND NOT EXISTS (
    SELECT 1
    FROM public.words conflict
    WHERE conflict.text = w.text
      AND conflict.from_lang = 'en'
      AND conflict.to_lang = 'de'
      AND conflict.id <> w.id
  )
ORDER BY w.text;
