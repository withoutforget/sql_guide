-- Задача 6. Что будет завтра: выручка следующего дня и тренд (LEAD).
SET search_path TO lab011;

-- lead(revenue) OVER (...) — выручка СЛЕДУЮЩЕЙ строки ряда товара (зеркало LAG).
-- В последний день следующей строки нет → NULL. Сравнив сегодня с завтра, подпишем
-- направление. LEAD, как и LAG, смотрит на всю партицию и игнорирует рамку.
WITH d AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        lead(s.revenue) OVER (PARTITION BY s.product_id
                              ORDER BY s.sale_date) AS завтра
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
)
SELECT
    товар,
    sale_date  AS дата,
    revenue    AS выручка,
    завтра,
    CASE WHEN завтра IS NULL   THEN 'последний день'
         WHEN завтра > revenue THEN 'завтра рост'
         WHEN завтра < revenue THEN 'завтра спад'
         ELSE 'без изменений' END AS прогноз
FROM d
ORDER BY товар, дата;
