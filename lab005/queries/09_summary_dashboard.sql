-- Задача 9. Сводка по магазину одной строкой (несколько независимых CTE в одну строку).
SET search_path TO lab005;

-- CTE не обязаны быть связаны. Считаем четыре независимых показателя, каждый —
-- своим понятным "кубиком", и собираем их в одну строку-сводку. FROM revenue,
-- lines, buyers, top_cat перечисляет CTE через запятую: для таблиц 1x1 это
-- CROSS JOIN (lab002), который просто ставит их значения рядом. Итог: общая
-- выручка 137320 ₽, 22 строки заказов, 8 активных клиентов, топ-категория —
-- Электроника.
WITH
    revenue AS (
        SELECT SUM(p.price * o.quantity) AS grand_total
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
    ),
    lines AS (
        SELECT COUNT(*) AS order_lines
        FROM orders
    ),
    buyers AS (
        SELECT COUNT(DISTINCT customer_id) AS active_customers
        FROM orders
    ),
    top_cat AS (
        SELECT cat.name AS top_category
        FROM orders     AS o
        JOIN products   AS p   ON p.id = o.product_id
        JOIN categories AS cat ON cat.id = p.category_id
        GROUP BY cat.name
        ORDER BY SUM(p.price * o.quantity) DESC
        LIMIT 1
    )
SELECT revenue.grand_total,
       lines.order_lines,
       buyers.active_customers,
       top_cat.top_category
FROM revenue, lines, buyers, top_cat;
