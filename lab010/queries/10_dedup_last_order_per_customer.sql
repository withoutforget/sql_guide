-- Задача 10. Дедупликация: оставить по ОДНОМУ (последнему) заказу на клиента.
SET search_path TO lab010;

-- Дедупликация через ROW_NUMBER — важнейший практический паттерн. PARTITION BY по
-- КЛЮЧУ, который схлопываем (клиент); ORDER BY внутри окна задаёт, КАКУЮ из строк
-- ключа оставить — здесь самую свежую (ordered_at DESC), а ", o.id DESC" — доводчик
-- на случай двух заказов в один день. Снаружи rn = 1 оставляет ровно одну строку на
-- клиента. Тем же приёмом убирают дубли по любому ключу (последняя цена, последняя
-- версия записи и т.п.).
WITH ranked AS (
    SELECT o.id,
           cu.name  AS customer,
           p.name   AS product,
           o.ordered_at,
           p.price * o.qty AS amount,
           row_number() OVER (PARTITION BY o.customer_id
                              ORDER BY o.ordered_at DESC, o.id DESC) AS rn
    FROM orders    AS o
    JOIN products  AS p  ON p.id  = o.product_id
    JOIN customers AS cu ON cu.id = o.customer_id
)
SELECT customer   AS клиент,
       ordered_at AS дата_заказа,
       product    AS товар,
       amount     AS сумма
FROM ranked
WHERE rn = 1
ORDER BY клиент;
