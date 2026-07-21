-- Задача 6. Товары, которые никто ни разу не заказывал (анти-соединение).
SET search_path TO lab002;

SELECT
    p.id,
    p.name,
    p.price
FROM products AS p
LEFT JOIN orders AS o  ON o.product_id = p.id
WHERE o.id IS NULL
ORDER BY p.id;
