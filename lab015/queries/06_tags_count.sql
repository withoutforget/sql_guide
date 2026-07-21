-- Задача 6. Развернуть теги через запятую и посчитать товары по каждому тегу.
SET search_path TO lab015;

-- Колонка tags хранит список через запятую ('скидка,новинка,хит'). Чтобы
-- считать по тегам, строку-список надо «нормализовать» в строки: string_to_table
-- (SRF) разворачивает её, LATERAL прикрепляет к каждому товару (см. lab006),
-- дальше — обычный GROUP BY.
SELECT
    tag,
    count(*) AS products_cnt
FROM products AS p,
     LATERAL string_to_table(p.tags, ',') AS tag
GROUP BY tag
ORDER BY products_cnt DESC, tag;
