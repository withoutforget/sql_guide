-- Задача 2. Полная строка заказа: клиент, товар, категория, количество и сумма (JOIN 4 таблиц).
SET search_path TO lab002;

SELECT
    o.id                  AS order_id,
    c.name                AS customer,
    p.name                AS product,
    cat.name              AS category,
    o.quantity,
    p.price * o.quantity  AS сумма
FROM orders     AS o
JOIN customers  AS c    ON c.id   = o.customer_id
JOIN products   AS p    ON p.id   = o.product_id
JOIN categories AS cat  ON cat.id = p.category_id
ORDER BY o.id;
