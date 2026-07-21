-- Задача 2. Нарастающая выручка магазина построчно: ловушка рамки по умолчанию (RANGE) против ROWS.
SET search_path TO lab011;

-- По ВСЕМУ магазину (без PARTITION BY) сортировка «ORDER BY sale_date» имеет ДУБЛИ:
-- в каждой дате несколько продаж — это РОВЕСНИКИ (peers).
--   итог_range  = sum(...) OVER (ORDER BY sale_date) — рамка ПО УМОЛЧАНИЮ, то есть
--     RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. В режиме RANGE «CURRENT ROW»
--     захватывает ВСЕ строки с тем же ключом сортировки, поэтому всем строкам одной
--     даты приписывается ОДИН итог — на КОНЕЦ дня. Это НЕ построчный итог (ловушка!).
--   итог_rows   = sum(...) OVER (ORDER BY sale_date, id ROWS ...) — ROWS считает
--     ФИЗИЧЕСКИМИ строками; доводчик id делает порядок строгим → честный итог,
--     растущий с КАЖДОЙ строкой. Сравните два столбца внутри одной даты.
SELECT
    s.sale_date                                   AS дата,
    p.name                                        AS товар,
    s.revenue                                     AS выручка,
    sum(s.revenue) OVER (ORDER BY s.sale_date)    AS итог_range_ловушка,
    sum(s.revenue) OVER (ORDER BY s.sale_date, s.id
                         ROWS BETWEEN UNBOUNDED PRECEDING
                                  AND CURRENT ROW) AS итог_rows_построчно
FROM sales AS s
JOIN products AS p ON p.id = s.product_id
ORDER BY s.sale_date, s.id;
