-- Задача 10. По каждому городу: сколько клиентов и сколько заказов (обойти fan-out через DISTINCT).
SET search_path TO lab002;

-- Ловушка: после LEFT JOIN строка клиента размножилась на число его заказов.
-- Поэтому число клиентов считаем COUNT(DISTINCT c.id) — иначе клиент с 3
-- заказами посчитался бы трижды. Число заказов — COUNT(o.id) (NULL не считает,
-- так что города без заказов дадут 0).
SELECT
    c.city,
    COUNT(DISTINCT c.id) AS customers,
    COUNT(o.id)          AS orders
FROM customers AS c
LEFT JOIN orders AS o  ON o.customer_id = c.id
GROUP BY c.city
ORDER BY orders DESC, c.city;
