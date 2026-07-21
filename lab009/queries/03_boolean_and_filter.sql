-- Задача 3. По категориям: есть ли 5-звёздочный товар, все ли ходовые, сколько «пятёрок».
SET search_path TO lab009;

-- Булевы агрегаты сворачивают группу в один флаг «да/нет»:
--   bool_or(усл)  — истинно, если условие верно ХОТЯ БЫ для одной строки (∃);
--   bool_and(усл) — истинно, если условие верно ДЛЯ ВСЕХ строк группы (∀).
-- FILTER (напоминание из lab001) считает агрегат только по нужным строкам.
SELECT
    category                                         AS категория,
    bool_or(rating = 5)                              AS есть_пятизвёздочный,   -- ∃
    bool_and(units_sold > 50)                        AS все_ходовые_gt50,      -- ∀
    count(*)                                         AS товаров,
    count(*) FILTER (WHERE rating = 5)               AS пятёрок,
    string_agg(name, ', ') FILTER (WHERE rating = 5) AS какие_пятизвёздочные
FROM products
GROUP BY category
ORDER BY category;
