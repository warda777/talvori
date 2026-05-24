-- ACHTUNG / BLOCKED:
-- Dieses Skript darf aktuell NICHT ausgefuehrt werden, weil es bei
-- mindestens einem Kandidaten zu einem Unique-Constraint-Konflikt kommt:
-- words_text_lang_uniq, Beispiel (text, from_lang, to_lang) = (dash, en, de).
--
-- Vorher `2026-05-24_analyze_language_code_conflicts.sql` ausfuehren und
-- die Konflikte manuell pruefen. Kandidaten mit Konflikt duerfen nicht
-- pauschal normalisiert werden.
--
-- Stattdessen fuer die nicht-konfliktierenden Kandidaten nur
-- `2026-05-24_normalize_language_codes_safe_subset.sql` verwenden.

-- Manual language-code normalization for public.words.
--
-- Purpose:
--   Normalize exactly 25 word rows from EN/DE to en/de.
--
-- Safety notes:
--   - Run manually in the Supabase SQL Editor only.
--   - Do not run this from Flutter or a local tool.
--   - This updates only public.words.from_lang and public.words.to_lang.
--   - This does not change text, translation, categories, word_progress,
--     user_word_srs, user_words, pass_count, stage, is_mastered, or next_due_at.
--   - The UPDATE is guarded by the exact ids and current EN/DE values so changed
--     rows are not overwritten silently.

-- Before: inspect the current values.
SELECT id, text, translation, from_lang, to_lang
FROM public.words
WHERE id IN (
  '0003d2c4-9558-42b6-bf79-aa099e3f4701',
  '42cba640-454e-447b-b0e0-e5a44f8968c7',
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  'b4b7f57d-f73a-492a-a693-63110229f7d7',
  '577f310a-1c4b-4e42-a925-187ba159394a',
  '0febef01-f685-4c8b-8826-af7753746fa3',
  '8915c19f-b3b8-44f6-a63c-6adea030086a',
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  '297c7517-c6ea-4340-9601-6405ee65d654',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '715a3af7-0244-4fff-a382-6ae153c66b0c',
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ac426143-a234-4394-b48a-0928e6489b6c',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  '9dea269e-4638-47bc-b4c9-3ca0c7e21733',
  '87e752ea-e944-469a-ad9e-9037a79ee7d5',
  '66d4eaa9-66d7-47fb-a8e6-58e14823e1a2',
  '61ca2b4e-332c-4a20-82a8-76e962482f15',
  'fd72add0-6144-4b98-bc52-4a737434c4ac',
  '094a3407-d275-4ea9-ad89-198218618dcf',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
)
ORDER BY text;

UPDATE public.words
SET from_lang = 'en',
    to_lang = 'de'
WHERE id IN (
  '0003d2c4-9558-42b6-bf79-aa099e3f4701',
  '42cba640-454e-447b-b0e0-e5a44f8968c7',
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  'b4b7f57d-f73a-492a-a693-63110229f7d7',
  '577f310a-1c4b-4e42-a925-187ba159394a',
  '0febef01-f685-4c8b-8826-af7753746fa3',
  '8915c19f-b3b8-44f6-a63c-6adea030086a',
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  '297c7517-c6ea-4340-9601-6405ee65d654',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '715a3af7-0244-4fff-a382-6ae153c66b0c',
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ac426143-a234-4394-b48a-0928e6489b6c',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  '9dea269e-4638-47bc-b4c9-3ca0c7e21733',
  '87e752ea-e944-469a-ad9e-9037a79ee7d5',
  '66d4eaa9-66d7-47fb-a8e6-58e14823e1a2',
  '61ca2b4e-332c-4a20-82a8-76e962482f15',
  'fd72add0-6144-4b98-bc52-4a737434c4ac',
  '094a3407-d275-4ea9-ad89-198218618dcf',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
)
AND from_lang = 'EN'
AND to_lang = 'DE';

-- After: inspect the normalized values.
SELECT id, text, translation, from_lang, to_lang
FROM public.words
WHERE id IN (
  '0003d2c4-9558-42b6-bf79-aa099e3f4701',
  '42cba640-454e-447b-b0e0-e5a44f8968c7',
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  'b4b7f57d-f73a-492a-a693-63110229f7d7',
  '577f310a-1c4b-4e42-a925-187ba159394a',
  '0febef01-f685-4c8b-8826-af7753746fa3',
  '8915c19f-b3b8-44f6-a63c-6adea030086a',
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  '297c7517-c6ea-4340-9601-6405ee65d654',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '715a3af7-0244-4fff-a382-6ae153c66b0c',
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ac426143-a234-4394-b48a-0928e6489b6c',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  '9dea269e-4638-47bc-b4c9-3ca0c7e21733',
  '87e752ea-e944-469a-ad9e-9037a79ee7d5',
  '66d4eaa9-66d7-47fb-a8e6-58e14823e1a2',
  '61ca2b4e-332c-4a20-82a8-76e962482f15',
  'fd72add0-6144-4b98-bc52-4a737434c4ac',
  '094a3407-d275-4ea9-ad89-198218618dcf',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
)
ORDER BY text;

-- Control: should return 0 rows after successful normalization.
SELECT id, text, translation, from_lang, to_lang
FROM public.words
WHERE id IN (
  '0003d2c4-9558-42b6-bf79-aa099e3f4701',
  '42cba640-454e-447b-b0e0-e5a44f8968c7',
  '3d018bfe-bd5d-4ba2-a448-6a92f54eb7bb',
  'b4b7f57d-f73a-492a-a693-63110229f7d7',
  '577f310a-1c4b-4e42-a925-187ba159394a',
  '0febef01-f685-4c8b-8826-af7753746fa3',
  '8915c19f-b3b8-44f6-a63c-6adea030086a',
  '0a29d3d0-ad57-4c78-94b7-ad6d603915c0',
  '297c7517-c6ea-4340-9601-6405ee65d654',
  '37a99d9c-9192-44ce-83b9-08eee8bca169',
  '715a3af7-0244-4fff-a382-6ae153c66b0c',
  '8b48b271-2a4e-472e-a0d1-99c142cdc1ab',
  '1aff8ead-820c-447c-9dc9-fe5981d91412',
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  'ac426143-a234-4394-b48a-0928e6489b6c',
  '31b9fd7e-fbbf-44fa-af67-40c66144f843',
  '32464b29-fec5-4fd3-ba25-a873e3b0f8eb',
  '9dea269e-4638-47bc-b4c9-3ca0c7e21733',
  '87e752ea-e944-469a-ad9e-9037a79ee7d5',
  '66d4eaa9-66d7-47fb-a8e6-58e14823e1a2',
  '61ca2b4e-332c-4a20-82a8-76e962482f15',
  'fd72add0-6144-4b98-bc52-4a737434c4ac',
  '094a3407-d275-4ea9-ad89-198218618dcf',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
)
AND (
  from_lang <> 'en'
  OR to_lang <> 'de'
);
