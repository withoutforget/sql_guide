-- Задача 11. Ранг клиента по тратам: и по всему магазину, и внутри своего города.
SET search_path TO lab010;

-- Два окна в одном SELECT с РАЗНЫМ определением:
--   rank() OVER (ORDER BY ...)                    — место среди ВСЕХ клиентов;
--   rank() OVER (PARTITION BY city ORDER BY ...)  — место ВНУТРИ своего города.
-- Одна и та же строка одновременно получает глобальный и локальный ранг — это удобно
-- сравнивать («в Москве только 2-я, хотя по стране 3-я»). Разделы независимы: в
-- Москве три клиента (ранги 1..3), в Казани два (1..2), в городах-одиночках — всегда 1.
WITH spend AS (
    SELECT cu.name, cu.city,
           sum(p.price * o.qty) AS total_spent
    FROM orders    AS o
    JOIN products  AS p  ON p.id  = o.product_id
    JOIN customers AS cu ON cu.id = o.customer_id
    GROUP BY cu.name, cu.city
)
SELECT
    name                                                          AS клиент,
    city                                                          AS город,
    total_spent                                                   AS потрачено,
    rank() OVER (ORDER BY total_spent DESC)                       AS ранг_по_магазину,
    rank() OVER (PARTITION BY city ORDER BY total_spent DESC)     AS ранг_в_городе
FROM spend
ORDER BY city, ранг_в_городе;
