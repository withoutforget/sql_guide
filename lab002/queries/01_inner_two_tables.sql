-- Задача 1. Расшифровать заказы: id заказа, имя клиента и дата (INNER JOIN двух таблиц).
SET search_path TO lab002;

SELECT
    o.id         AS order_id,
    c.name       AS customer,
    o.ordered_at
FROM orders    AS o
JOIN customers AS c  ON c.id = o.customer_id
ORDER BY o.id;
