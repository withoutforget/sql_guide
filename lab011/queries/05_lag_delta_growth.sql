-- Задача 5. Сравнение с предыдущим днём: дельта и рост в % (LAG).
SET search_path TO lab011;

-- lag(revenue) OVER (PARTITION BY товар ORDER BY дата) — выручка ПРЕДЫДУЩЕЙ строки
-- ряда товара. LAG работает по всей упорядоченной партиции (рамка на него не влияет).
-- В первый день предыдущей строки нет → LAG возвращает NULL: дельта и рост % тоже
-- становятся NULL (сравнивать не с чем). Считаем «вчера» один раз в CTE, чтобы не
-- повторять оконный вызов в трёх местах.
WITH d AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        lag(s.revenue) OVER (PARTITION BY s.product_id
                             ORDER BY s.sale_date) AS вчера
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
)
SELECT
    товар,
    sale_date                            AS дата,
    revenue                              AS выручка,
    вчера,
    revenue - вчера                      AS дельта,
    round(100.0 * (revenue - вчера) / вчера, 1) AS рост_проц
FROM d
ORDER BY товар, дата;
