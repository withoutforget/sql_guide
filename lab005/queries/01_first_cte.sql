-- Задача 1. Суммарная выручка по каждому клиенту (первый CTE, для читаемости).
SET search_path TO lab005;

-- Знакомимся с синтаксисом WITH имя AS (...) SELECT ... . В CTE customer_revenue
-- сворачиваем заказы в "клиент -> сумма трат" (выручка строки = price * quantity).
-- Это обычный агрегирующий запрос из lab001/lab002, но теперь у него есть ИМЯ, и
-- главный запрос обращается к нему как к таблице: джойнит справочник customers за
-- именем и сортирует. CTE живёт только внутри этого запроса, в схеме ничего не
-- создаётся. Ответ: Егор (34640) и Анна (30550) — крупнейшие клиенты.
WITH customer_revenue AS (
    SELECT o.customer_id,
           SUM(p.price * o.quantity) AS total
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY o.customer_id
)
SELECT c.name, cr.total
FROM customer_revenue AS cr
JOIN customers AS c ON c.id = cr.customer_id
ORDER BY cr.total DESC;
