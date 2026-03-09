-- Prüfen: Hat die Datenbank überhaupt Wörter in Kategorien?
-- Im Supabase SQL Editor ausführen.

-- 1) Kategorien mit Wort-Anzahl
SELECT c.id, c.name, c.slug, COUNT(wc.word_id) AS word_count
FROM categories c
LEFT JOIN word_categories wc ON wc.category_id = c.id
GROUP BY c.id, c.name, c.slug
ORDER BY word_count DESC
LIMIT 20;

-- 2) Wenn word_count = 0 überall: word_categories ist leer
--    → Wörter müssen erst in Kategorien eingepflegt werden
