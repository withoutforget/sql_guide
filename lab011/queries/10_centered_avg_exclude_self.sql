-- Задача 10. Сглаживание по соседним дням без учёта самого дня (EXCLUDE CURRENT ROW) и детект выброса.
SET search_path TO lab011;

-- Рамка ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING — «вчера, сегодня, завтра» (центрированное
-- окно). EXCLUDE CURRENT ROW выкидывает из рамки саму текущую строку, поэтому среднее
-- считается ТОЛЬКО по соседям — это «ожидание» для дня по его окружению. Большое
-- отклонение факта от ожидания = выброс (день выбился из локального тренда). На краях
-- ряда сосед один. Смотрим на «Смартфон Nova».
WITH d AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        avg(s.revenue) OVER (PARTITION BY s.product_id
                             ORDER BY s.sale_date
                             ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
                             EXCLUDE CURRENT ROW) AS соседи
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
)
SELECT
    товар,
    sale_date              AS дата,
    revenue                AS выручка,
    round(соседи, 1)       AS среднее_соседей,
    round(revenue - соседи, 1) AS отклонение,
    CASE WHEN abs(revenue - соседи) >= 4000 THEN '⚠ выброс' ELSE '' END AS метка
FROM d
WHERE товар = 'Смартфон Nova'
ORDER BY дата;
