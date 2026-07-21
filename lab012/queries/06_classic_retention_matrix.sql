-- Задача 6. Матрица classic retention: доля клиентов когорты, активных ИМЕННО в возрасте k.
SET search_path TO lab012;

-- Возраст k = период_активности − период_когорты.

-- Шаги: (1) когорта клиента = min(period); (2) активные пары (клиент, период) —
-- DISTINCT по заказам; (3) возраст = period − cohort_period; (4) для когорты и
-- возраста k доля = активных_в_возрасте_k / размер_когорты.
-- ТРЕУГОЛЬНАЯ матрица: возраст k наблюдаем, только если cohort_period + k ≤ 6
-- (позже данных ещё нет). Недоступные ячейки = NULL (не 0!): 0 значило бы «никто
-- не вернулся», а NULL — «данных за этот возраст ещё не существует».
WITH first_purchase AS (
    SELECT customer_id, min(period) AS cohort_period
    FROM orders GROUP BY customer_id
),
active AS (                        -- в каких периодах клиент был активен
    SELECT DISTINCT customer_id, period FROM orders
),
aged AS (                          -- возраст каждой активности относительно когорты
    SELECT fp.cohort_period, a.customer_id, a.period - fp.cohort_period AS age
    FROM active AS a
    JOIN first_purchase AS fp ON fp.customer_id = a.customer_id
),
sizes AS (
    SELECT cohort_period, count(*) AS cohort_size
    FROM first_purchase GROUP BY cohort_period
)
SELECT
    pr.label       AS когорта,
    s.cohort_size  AS размер,
    round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 0) / s.cohort_size) AS возр_0,
    CASE WHEN s.cohort_period + 1 <= 6 THEN round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 1) / s.cohort_size) END AS возр_1,
    CASE WHEN s.cohort_period + 2 <= 6 THEN round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 2) / s.cohort_size) END AS возр_2,
    CASE WHEN s.cohort_period + 3 <= 6 THEN round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 3) / s.cohort_size) END AS возр_3,
    CASE WHEN s.cohort_period + 4 <= 6 THEN round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 4) / s.cohort_size) END AS возр_4,
    CASE WHEN s.cohort_period + 5 <= 6 THEN round(100.0 * count(ag.customer_id) FILTER (WHERE ag.age = 5) / s.cohort_size) END AS возр_5
FROM sizes AS s
JOIN periods AS pr ON pr.period = s.cohort_period
JOIN aged   AS ag ON ag.cohort_period = s.cohort_period
GROUP BY pr.label, s.cohort_period, s.cohort_size
ORDER BY s.cohort_period;
