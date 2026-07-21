-- Задача 13. Один запрос «игры» — три подхода: LIKE (буквально), FTS (по леммам), триграммы (по сходству).
SET search_path TO lab016;

-- Показываем, ЧТО находит каждый метод на запросе «игры»:
--   LIKE '%игры%'  — только буквальную подстроку «игры»; словоформы «игр», «игре»
--                    он НЕ видит → находит один товар;
--   FTS            — по лемме «игр», поэтому ловит и «игры», и «игр» во всех формах;
--   триграммы (<%) — по символьному сходству слова со словами текста (тоже находит
--                    формы и вдобавок пережил бы опечатку).
-- Видно: LIKE отстаёт, FTS и триграммы находят все товары про игры.
SELECT
    p.id,
    p.name,
    (p.description ILIKE '%игры%')                                                       AS by_like,
    (to_tsvector('russian', p.description) @@ plainto_tsquery('russian', 'игры'))         AS by_fts,
    ('игры' <% p.description)                                                             AS by_trgm
FROM products p
WHERE p.description ILIKE '%игры%'
   OR to_tsvector('russian', p.description) @@ plainto_tsquery('russian', 'игры')
   OR 'игры' <% p.description
ORDER BY p.id;
