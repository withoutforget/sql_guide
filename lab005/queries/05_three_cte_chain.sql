-- Задача 5. Выручка по городам и доля города в общей выручке (цепочка из трёх CTE).
SET search_path TO lab005;

-- Разворачиваем аналитику в три последовательных шага, каждый опирается на
-- предыдущий:
--   ШАГ 1 (order_line)     — выручка каждой строки заказа (price * quantity) + её клиент;
--   ШАГ 2 (customer_total) — сумма по клиенту (свёртка шага 1) + его город;
--   ШАГ 3 (city_total)     — сумма по городу (свёртка шага 2).
-- Финал берёт city_total и считает долю города в общей выручке (city_total нужен
-- дважды: как строки и в SELECT SUM(...) для знаменателя). Лидер — Москва: 80850 ₽
-- (58.9% всей выручки), где сидят сразу три клиента.
WITH
    order_line AS (
        SELECT o.customer_id,
               p.price * o.quantity AS line_total
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
    ),
    customer_total AS (
        SELECT ol.customer_id,
               c.city,
               SUM(ol.line_total) AS total
        FROM order_line AS ol
        JOIN customers  AS c ON c.id = ol.customer_id
        GROUP BY ol.customer_id, c.city
    ),
    city_total AS (
        SELECT city,
               SUM(total) AS city_revenue
        FROM customer_total
        GROUP BY city
    )
SELECT city,
       city_revenue,
       ROUND(city_revenue * 100.0 / (SELECT SUM(city_revenue) FROM city_total), 1) AS pct_of_total
FROM city_total
ORDER BY city_revenue DESC;
