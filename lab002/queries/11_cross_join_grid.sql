-- Задача 11. Матрица «категория × месяц»: число заказов в каждой клетке, включая нули (CROSS + LEFT).
SET search_path TO lab002;

-- CROSS JOIN строит полный каркас (каждая категория × каждый месяц) — без «дыр».
-- Месяц задаём ДИАПАЗОНОМ дат [lo, hi) — тем же приёмом, что в задаче 8 (без
-- функций форматирования дат). Затем LEFT JOIN подтягивает заказы, попавшие в
-- этот диапазон (условие про даты — в ON, чтобы пустые клетки сохранились), а
-- COUNT(o.id) даёт 0 там, где продаж не было. Метка месяца — начало диапазона.
SELECT
    cat.name      AS category,
    m.lo          AS month,
    COUNT(o.id)   AS orders_count
FROM categories AS cat
CROSS JOIN (VALUES
        (DATE '2024-06-01', DATE '2024-07-01'),
        (DATE '2024-07-01', DATE '2024-08-01')
    ) AS m(lo, hi)
LEFT JOIN products AS p  ON p.category_id = cat.id
LEFT JOIN orders   AS o  ON o.product_id = p.id
                        AND o.ordered_at >= m.lo
                        AND o.ordered_at <  m.hi
GROUP BY cat.id, cat.name, m.lo
ORDER BY cat.name, m.lo;
