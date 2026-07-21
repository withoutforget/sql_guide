-- Задача 13. 🔥 Самый большой скачок выручки день-к-дню по каждому товару.
SET search_path TO lab011;

-- Собираем два приёма. Сначала LAG даёт вчерашнюю выручку → дельта = сегодня − вчера.
-- Затем внутри товара ранжируем строки по дельте (по убыванию) и оставляем топ-1: это
-- день максимального прироста. NULLS LAST отправляет первый день (у него дельты нет)
-- в конец, чтобы он не попал в ответ. Фильтровать по окну напрямую нельзя — заворачиваем
-- расчёт в CTE (приём из lab010: окно в подзапросе, WHERE — снаружи).
WITH deltas AS (
    SELECT
        p.name AS товар, s.sale_date, s.revenue,
        s.revenue - lag(s.revenue) OVER (PARTITION BY s.product_id
                                         ORDER BY s.sale_date) AS дельта
    FROM sales AS s
    JOIN products AS p ON p.id = s.product_id
),
ranked AS (
    SELECT товар, sale_date, revenue, дельта,
           row_number() OVER (PARTITION BY товар
                              ORDER BY дельта DESC NULLS LAST, sale_date) AS rn
    FROM deltas
)
SELECT
    товар,
    sale_date AS день_скачка,
    revenue   AS выручка_в_день,
    дельта    AS прирост
FROM ranked
WHERE rn = 1
ORDER BY прирост DESC;
