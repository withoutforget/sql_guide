-- Задача 4. Когорта каждого клиента = период его ПЕРВОЙ покупки.
SET search_path TO lab012;

-- Когорта — группа клиентов, объединённых моментом первого события. Здесь берём
-- «месяц первой покупки»: для клиента это min(period) по его заказам. Считаем в
-- CTE агрегатом с GROUP BY, затем присоединяем имя/город и ярлык месяца когорты.
WITH first_purchase AS (
    SELECT customer_id, min(period) AS cohort_period
    FROM orders
    GROUP BY customer_id
)
SELECT
    c.id             AS клиент_id,
    c.name           AS клиент,
    c.city           AS город,
    fp.cohort_period AS когорта_период,
    pr.label         AS когорта_месяц
FROM first_purchase AS fp
JOIN customers AS c  ON c.id = fp.customer_id
JOIN periods   AS pr ON pr.period = fp.cohort_period
ORDER BY fp.cohort_period, c.id;
