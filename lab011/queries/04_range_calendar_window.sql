-- Задача 4. Сумма за 3 календарных дня (RANGE с интервалом) против «3 строк» (ROWS) — на товаре с пропусками.
SET search_path TO lab011;

-- «Робот-пылесос» продавался НЕ каждый день (нет 03-03 и 03-05). Две рамки над одним
-- рядом дают РАЗНЫЙ результат именно из-за пропусков:
--   сумма_за_3_строки = ROWS BETWEEN 2 PRECEDING AND CURRENT ROW — ровно 3 ФИЗИЧЕСКИЕ
--     строки (2 предыдущие + текущая), сколько бы дней между ними ни прошло.
--   сумма_за_3_дня    = RANGE BETWEEN INTERVAL '2 days' PRECEDING AND CURRENT ROW —
--     все строки, чья дата попадает в окно [дата − 2 дня; дата] по ЗНАЧЕНИЮ. Пропущенные
--     дни просто отсутствуют, поэтому такая рамка может включать меньше строк.
-- RANGE со смещением требует РОВНО ОДИН столбец в ORDER BY подходящего типа (здесь —
-- дата, а смещение — интервал того же «датного» типа).
SELECT
    s.sale_date                                     AS дата,
    s.revenue                                       AS выручка,
    sum(s.revenue) OVER (ORDER BY s.sale_date
                         ROWS BETWEEN 2 PRECEDING
                                  AND CURRENT ROW)   AS сумма_за_3_строки,
    sum(s.revenue) OVER (ORDER BY s.sale_date
                         RANGE BETWEEN INTERVAL '2 days' PRECEDING
                                   AND CURRENT ROW)  AS сумма_за_3_дня
FROM sales AS s
WHERE s.product_id = 4
ORDER BY s.sale_date;
