-- Задача 3. Заказы москвичей на сумму дороже 5000 ₽ за строку (JOIN + WHERE).
SET search_path TO lab002;

SELECT
    c.name                AS customer,
    p.name                AS product,
    o.quantity,
    p.price * o.quantity  AS сумма
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
JOIN products  AS p  ON p.id = o.product_id
WHERE c.city = 'Москва'
  AND p.price * o.quantity > 5000
ORDER BY сумма DESC;
