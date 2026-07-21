-- Задача 14. 🔥 Самый дорогой (по цене за штуку) товар, который заказывал каждый клиент.
SET search_path TO lab002;

-- Изюм: найти максимум БЕЗ подзапросов и оконных функций — только джойнами.
-- Приём «нет ничего большего»: к каждой заказанной позиции (o1/p1) пытаемся
-- LEFT JOIN'ом подобрать заказ ТОГО ЖЕ клиента с БОЛЕЕ дорогим товаром (p2.price
-- > p1.price). Если такого нет (o2.id IS NULL) — значит p1 и есть самый дорогой
-- товар этого клиента. Обратите внимание на скобки: справа соединяются две
-- таблицы (orders o2 + products p2), и уже к их паре применяется LEFT JOIN.
SELECT DISTINCT
    c.name    AS customer,
    p1.name   AS product,
    p1.price
FROM orders     AS o1
JOIN customers  AS c   ON c.id  = o1.customer_id
JOIN products   AS p1  ON p1.id = o1.product_id
LEFT JOIN (orders AS o2 JOIN products AS p2 ON p2.id = o2.product_id)
       ON o2.customer_id = o1.customer_id
      AND p2.price > p1.price
WHERE o2.id IS NULL
ORDER BY p1.price DESC, c.name;
