-- Задача 5. Клиенты, не сделавшие ни одного заказа (анти-соединение).
SET search_path TO lab002;

-- LEFT JOIN оставляет всех клиентов; у кого нет заказов — o.id = NULL;
-- WHERE o.id IS NULL оставляет ровно этих «сирот».
SELECT
    c.id,
    c.name,
    c.city
FROM customers AS c
LEFT JOIN orders AS o  ON o.customer_id = c.id
WHERE o.id IS NULL
ORDER BY c.id;
