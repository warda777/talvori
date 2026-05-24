-- Manual cleanup for URL-contaminated word imports.
--
-- Purpose:
--   Clean exactly three safe Browser/Share contamination cases in public.words.
--
-- Safety notes:
--   - Run manually in the Supabase SQL Editor only.
--   - Do not run this from Flutter or a local tool.
--   - This updates only public.words.text and public.words.translation.
--   - This does not change language codes, categories, user words, word_progress,
--     user_word_srs, pass_count, stage, is_mastered, or next_due_at.
--   - Each UPDATE is guarded by the exact id and URL-fragment checks so changed
--     rows are not overwritten silently.

-- Before: inspect the current values.
SELECT id, text, translation
FROM public.words
WHERE id IN (
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
);

UPDATE public.words
SET text = 'move',
    translation = 'umziehen'
WHERE id = '0c165b4c-2afb-4861-ac60-75bf59a8611b'
  AND text LIKE '%https://www.bbc.com/%'
  AND translation LIKE '%https://www.bbc.com/%';

UPDATE public.words
SET text = 'superstar',
    translation = 'Superstar'
WHERE id = '2a7e4ef2-4585-4b25-9c63-d81bc694cce5'
  AND text LIKE '%https://www.bbc.com/%'
  AND translation LIKE '%https://www.bbc.com/%';

UPDATE public.words
SET text = 'throughout',
    translation = 'durchgehend'
WHERE id = '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
  AND text LIKE '%https://www.bbc.com/%'
  AND translation LIKE '%https://www.bbc.com/%';

-- After: inspect the cleaned values.
SELECT id, text, translation
FROM public.words
WHERE id IN (
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
);

-- Control: should return 0 rows after successful cleanup.
SELECT id, text, translation
FROM public.words
WHERE id IN (
  '0c165b4c-2afb-4861-ac60-75bf59a8611b',
  '2a7e4ef2-4585-4b25-9c63-d81bc694cce5',
  '6a6e9ac6-ddc4-4ee0-a6a6-51d8ad8edf3f'
)
AND (
  text LIKE '%http%'
  OR translation LIKE '%http%'
);
