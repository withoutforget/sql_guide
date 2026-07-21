-- Задача 2. Средняя, макс. и мин. трата в расчёте на клиента (та же задача lab004 №11, но через CTE).
SET search_path TO lab005;

-- Это "агрегат от агрегата": среднее ОТ клиентских сумм. Напрямую AVG(SUM(...))
-- нельзя, нужен промежуточный шаг "сумма на клиента". В lab004 (задача 11) мы
-- решали это подзапросом в FROM (производной таблицей). Здесь — тот же смысл и
-- ТОТ ЖЕ результат, но промежуточный шаг ВЫНЕСЕН наверх и НАЗВАН per_customer:
-- главный запрос стал коротким ("посчитать avg/max/min по таблице per_customer").
-- Результат: avg=17165.00, max=34640.00, min=2070.00 (по 8 клиентам).
WITH per_customer AS (
    SELECT o.customer_id,
           SUM(p.price * o.quantity) AS total
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY o.customer_id
)
SELECT
    ROUND(AVG(total), 2) AS avg_total,
    MAX(total)           AS max_total,
    MIN(total)           AS min_total
FROM per_customer;
