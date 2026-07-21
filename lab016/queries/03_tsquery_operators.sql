-- Задача 3. Сложный запрос операторами tsquery (& | !) и «человеческий» синтаксис websearch_to_tsquery.
SET search_path TO lab016;

-- to_tsquery принимает ОПЕРАТОРЫ: & (И), | (ИЛИ), ! (НЕ). websearch_to_tsquery
-- разбирает «человеческую» строку (пробел = И, слово OR = ИЛИ, минус = НЕ, кавычки = фраза).
-- Сначала посмотрим, во что превращаются оба запроса:
SELECT
    to_tsquery('russian', 'ноутбук & игровой & !офисный')       AS to_tsquery_q,
    websearch_to_tsquery('russian', 'смартфон камера -планшет')  AS websearch_q;

-- Теперь применим их. Ищем игровой ноутбук (обе леммы обязательны) по названию+описанию:
SELECT id, name
FROM products
WHERE search_tsv @@ to_tsquery('russian', 'ноутбук & игровой')
ORDER BY id;

-- И «человеческий» запрос: товары про смартфон с камерой, но не планшеты.
SELECT id, name
FROM products
WHERE search_tsv @@ websearch_to_tsquery('russian', 'смартфон камера -планшет')
ORDER BY id;
