-- Задача 7. Classic против rolling retention на примере когорты 1.
SET search_path TO lab012;

-- Classic retention возраста k — доля когорты, активная ИМЕННО в возрасте k.
-- Rolling (range) retention возраста k — доля, активная в возрасте k ИЛИ ПОЗЖЕ
-- (то есть максимальный возраст активности клиента ≥ k). Из-за «дырок» (Борис
-- вернулся в возрасте 2, пропустив 1; Дарья — в возрасте 3) rolling ≥ classic:
-- rolling «прощает» пропуск, если клиент ещё вернётся. generate_series строит
-- ось возрастов 0..5, коррелированные подзапросы считают обе доли.
WITH first_purchase AS (
    SELECT customer_id, min(period) AS cohort_period
    FROM orders GROUP BY customer_id
),
aged AS (                          -- возрасты активности клиентов когорты 1
    SELECT o.customer_id, o.period - fp.cohort_period AS age
    FROM (SELECT DISTINCT customer_id, period FROM orders) AS o
    JOIN first_purchase AS fp ON fp.customer_id = o.customer_id
    WHERE fp.cohort_period = 1
),
per_customer AS (                  -- максимальный возраст активности клиента
    SELECT customer_id, max(age) AS max_age
    FROM aged GROUP BY customer_id
),
ages AS (SELECT generate_series(0, 5) AS age),
sz   AS (SELECT count(*) AS n FROM per_customer)
SELECT
    a.age                                                             AS возраст,
    (SELECT n FROM sz)                                                AS размер_когорты,
    round(100.0 * (SELECT count(*) FROM aged         ag WHERE ag.age = a.age)
                / (SELECT n FROM sz))                                 AS classic_pct,
    round(100.0 * (SELECT count(*) FROM per_customer pc WHERE pc.max_age >= a.age)
                / (SELECT n FROM sz))                                 AS rolling_pct
FROM ages AS a
ORDER BY a.age;
