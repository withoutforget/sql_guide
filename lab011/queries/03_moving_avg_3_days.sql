-- Задача 3. Скользящее среднее выручки за 3 дня по каждому товару (ROWS).
SET search_path TO lab011;

-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW — рамка максимум из трёх физических строк:
-- две предыдущие и текущая. В начале ряда рамка короче (1-2 строки), поэтому первые
-- значения — среднее по тому, что уже накоплено. Скользящее среднее сглаживает
-- дневные колебания и показывает тренд.
SELECT
    p.name                                                    AS товар,
    s.sale_date                                               AS дата,
    s.revenue                                                 AS выручка,
    round(avg(s.revenue) OVER (PARTITION BY s.product_id
                               ORDER BY s.sale_date
                               ROWS BETWEEN 2 PRECEDING
                                        AND CURRENT ROW), 1)   AS скользящее_среднее_3д
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY p.name, s.sale_date;
