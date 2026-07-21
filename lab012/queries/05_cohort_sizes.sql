-- Задача 5. Размеры когорт: сколько клиентов в каждой когорте.
SET search_path TO lab012;

-- На основе когорты клиента (первый период) считаем размер каждой когорты — это
-- «знаменатель» retention: доля вернувшихся = вернулись / размер когорты.
WITH first_purchase AS (
    SELECT customer_id, min(period) AS cohort_period
    FROM orders
    GROUP BY customer_id
)
SELECT
    pr.label         AS когорта_месяц,
    fp.cohort_period AS когорта_период,
    count(*)         AS клиентов
FROM first_purchase AS fp
JOIN periods AS pr ON pr.period = fp.cohort_period
GROUP BY fp.cohort_period, pr.label
ORDER BY fp.cohort_period;
