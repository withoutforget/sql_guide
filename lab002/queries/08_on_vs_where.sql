-- Задача 8. Все клиенты и их ИЮНЬСКИЕ заказы; клиентов показать всех (условие — в ON!).
SET search_path TO lab002;

-- Ключевой момент: ограничение «только июнь» стоит в ON, а НЕ в WHERE.
-- В ON оно лишь решает, какой заказ считать парой; клиенты без июньских заказов
-- (в т.ч. Жанна вообще без заказов, и те, у кого заказы только в июле) остаются
-- в выборке с NULL. Перенеси это условие в WHERE — и LEFT JOIN выродится в INNER.
SELECT
    c.name        AS customer,
    o.id          AS order_id,
    o.ordered_at
FROM customers AS c
LEFT JOIN orders AS o
       ON o.customer_id = c.id
      AND o.ordered_at >= DATE '2024-06-01'
      AND o.ordered_at <  DATE '2024-07-01'
ORDER BY c.name, o.ordered_at;
