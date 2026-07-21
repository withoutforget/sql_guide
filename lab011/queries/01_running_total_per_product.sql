-- Задача 1. Нарастающий итог выручки по каждому товару (running total).
SET search_path TO lab011;

-- ORDER BY внутри OVER превращает агрегат в НАРАСТАЮЩИЙ итог: рамка по умолчанию
-- (когда есть ORDER BY) — «от начала раздела до текущей строки». PARTITION BY товар
-- перезапускает накопление в начале каждого товара. Здесь sale_date ВНУТРИ товара
-- уникальна, поэтому рамка по умолчанию (RANGE) корректна — ровесников нет.
-- В задаче 2 увидим, где именно она даёт неверный результат.
SELECT
    p.name                                        AS товар,
    s.sale_date                                   AS дата,
    s.revenue                                     AS выручка,
    sum(s.revenue) OVER (PARTITION BY s.product_id
                         ORDER BY s.sale_date)     AS нарастающий_итог
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY p.name, s.sale_date;
