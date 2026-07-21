-- Задача 11. Средняя, макс. и мин. суммарная трата в расчёте на клиента (подзапрос в FROM).
SET search_path TO lab004;

-- Это агрегат ОТ агрегата (среднее от сумм), а вкладывать агрегаты нельзя
-- (AVG(SUM(...)) — ошибка). Решение: подзапрос в FROM (производная таблица).
--   * внутренний запрос сворачивает заказы в "сумму на клиента" (по строке на
--     клиента) — это производная таблица per_customer;
--   * внешний запрос агрегирует уже её колонку total.
-- Алиас производной таблице (per_customer) даём всегда — это требование стандарта.
-- Захар без заказов в GROUP BY не попадает, поэтому среднее считается по 7
-- клиентам с заказами. В lab005 это же удобно переписать через CTE (WITH).
SELECT
    ROUND(AVG(total), 2) AS avg_total,
    MAX(total)           AS max_total,
    MIN(total)           AS min_total
FROM (
    SELECT o.customer_id, SUM(p.price * o.quantity) AS total
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY o.customer_id
) AS per_customer;
