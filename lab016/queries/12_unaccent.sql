-- Задача 12. Поиск без учёта диакритики: unaccent снимает акценты, и «cafe» находит «Nescafé», «Café Zoë».
SET search_path TO lab016;

-- unaccent(текст) заменяет буквы с диакритикой на базовые латинские (é→e, ö→o,
-- ï→i, š→s, ñ→n и т.п.) по словарю расширения. Нормализовав обе стороны сравнения
-- через unaccent, ищем по «плоскому» написанию: пользователь набрал без акцентов —
-- всё равно находим. Показываем нормализацию и два поиска.
SELECT
    id,
    name,
    unaccent(name) AS normalized
FROM foreign_names
ORDER BY id;

-- «cafe» → Nescafé, Café Zoë ; «skoda» → Škoda Octavia. LIKE применяем к уже
-- обесцвеченной (unaccent+lower) строке, поэтому диакритика и регистр не мешают.
SELECT id, name
FROM foreign_names
WHERE unaccent(lower(name)) LIKE '%cafe%'
   OR unaccent(lower(name)) LIKE '%skoda%'
ORDER BY id;
