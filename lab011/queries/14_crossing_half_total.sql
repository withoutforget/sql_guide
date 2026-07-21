-- Задача 14. 🔥 День, когда накопленная выручка товара впервые превзошла половину его итога.
SET search_path TO lab011;

-- Для каждого товара считаем два окна: нарастающий итог по дням (ROWS — честный
-- построчный) и ПОЛНЫЙ итог товара (окно без ORDER BY = вся партиция). Оставляем дни,
-- где нарастающий итог достиг половины полного, и берём САМЫЙ РАННИЙ такой день
-- (row_number = 1). Это день, на котором набрана половина месячной выручки товара —
-- своего рода «центр тяжести» продаж во времени.
WITH acc AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        sum(s.revenue) OVER (PARTITION BY s.product_id
                             ORDER BY s.sale_date
                             ROWS BETWEEN UNBOUNDED PRECEDING
                                      AND CURRENT ROW)  AS нарастающий,
        sum(s.revenue) OVER (PARTITION BY s.product_id) AS итог_товара
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
),
crossed AS (
    SELECT товар, sale_date, нарастающий, итог_товара,
           row_number() OVER (PARTITION BY товар ORDER BY sale_date) AS rn
    FROM acc
    WHERE нарастающий >= итог_товара / 2.0
)
SELECT
    товар,
    sale_date   AS день_половины,
    нарастающий AS накоплено,
    итог_товара
FROM crossed
WHERE rn = 1
ORDER BY товар;
