-- Задача 4. По КАЖДОМУ клиенту (включая ничего не купивших): число заказов и сумма трат.
SET search_path TO lab002;

-- LEFT JOIN сохраняет всех клиентов; COUNT(o.id) не считает NULL → у клиента без
-- заказов честный 0; COALESCE превращает NULL-сумму в 0.
SELECT
    c.name,
    c.city,
    COUNT(o.id)                            AS orders_count,
    COALESCE(SUM(p.price * o.quantity), 0) AS total_spent
FROM customers AS c
LEFT JOIN orders   AS o  ON o.customer_id = c.id
LEFT JOIN products AS p  ON p.id = o.product_id
GROUP BY c.id, c.name, c.city
ORDER BY total_spent DESC, c.name;
