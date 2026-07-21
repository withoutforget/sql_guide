-- Задача 8. Первый и последний день партиции: ловушка LAST_VALUE.
SET search_path TO lab011;

-- first_value/last_value берут значение из ПЕРВОЙ/ПОСЛЕДНЕЙ строки РАМКИ (а не всей
-- партиции!). С рамкой по умолчанию (... AND CURRENT ROW) последняя строка рамки —
-- это САМА текущая строка, поэтому наивный last_value возвращает выручку ТЕКУЩЕГО дня,
-- а не последнего в ряду (видно: колонка last_наивно совпадает с колонкой выручка).
-- Чтобы взять реальный последний день, рамку надо расширить до UNBOUNDED FOLLOWING.
-- first_value с рамкой по умолчанию корректен: первая строка рамки не меняется.
SELECT
    p.name                                                        AS товар,
    s.sale_date                                                   AS дата,
    s.revenue                                                     AS выручка,
    first_value(s.revenue) OVER (PARTITION BY s.product_id
                                 ORDER BY s.sale_date)             AS первый_день,
    last_value(s.revenue)  OVER (PARTITION BY s.product_id
                                 ORDER BY s.sale_date)             AS last_наивно_ловушка,
    last_value(s.revenue)  OVER (PARTITION BY s.product_id
                                 ORDER BY s.sale_date
                                 ROWS BETWEEN UNBOUNDED PRECEDING
                                          AND UNBOUNDED FOLLOWING) AS последний_день
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY p.name, s.sale_date;
