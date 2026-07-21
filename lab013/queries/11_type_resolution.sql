-- Задача 11. Разрешение типов (type resolution): CASE и UNION приводят ветки к общему типу.
SET search_path TO lab013;

-- Когда выражение объединяет значения разных типов (ветки CASE, столбцы UNION,
-- аргументы COALESCE/GREATEST), PostgreSQL выбирает ОДИН общий тип и приводит к
-- нему всё. Числовые типы сходятся к более «широкому»: integer + numeric → numeric.
-- Если общий тип найти нельзя (например, число и настоящий text) — будет ошибка
-- (разбор — в теории 05). Здесь показываем корректные случаи.

-- (а) CASE: одна ветка numeric (price), другая integer (0) → результат numeric.
SELECT
    id,
    name,
    CASE WHEN in_stock THEN price ELSE 0 END               AS shown_price,
    pg_typeof(CASE WHEN in_stock THEN price ELSE 0 END)    AS result_type   -- numeric
FROM products
ORDER BY id;

-- (б) UNION: три разных числовых типа сводятся к общему numeric.
SELECT metric, value, pg_typeof(value) AS value_type
FROM (
    SELECT 'цена, ₽'::text AS metric, price        AS value FROM products WHERE id = 1  -- numeric
    UNION ALL
    SELECT 'остаток, шт',            units                  FROM products WHERE id = 1  -- integer
    UNION ALL
    SELECT 'вес, кг',                weight_kg::numeric     FROM products WHERE id = 1  -- double→numeric
) t
ORDER BY metric;
