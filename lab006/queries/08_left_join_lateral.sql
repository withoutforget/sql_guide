-- Задача 8. То же, но сохранить клиентов без заказов (LEFT JOIN LATERAL ... ON true).
SET search_path TO lab006;

-- Тот же запрос, что в задаче 7, но CROSS JOIN LATERAL заменён на LEFT JOIN LATERAL
-- ... ON true. Разница ровно как между INNER и LEFT JOIN из lab002, только справа
-- стоит коррелированный подзапрос:
--   * CROSS JOIN LATERAL  — если справа 0 строк, левая строка выпадает (задача 7);
--   * LEFT JOIN LATERAL   — левая строка СОХРАНЯЕТСЯ, а правые колонки = NULL.
-- Условие соединения тут не нужно (вся связь уже внутри подзапроса через
-- o.customer_id = c.id), поэтому пишут ON true — «соединять всегда». В результате
-- появляется Жанна: заказов у неё нет, значит product/ordered_at/revenue = NULL.
-- COALESCE подставляет читаемую заглушку. Это и есть «видимая разница» двух форм.
SELECT c.name                       AS customer,
       COALESCE(top.product, '— нет заказов') AS product,
       top.ordered_at,
       top.revenue
FROM customers AS c
LEFT JOIN LATERAL (
    SELECT pr.name        AS product,
           o.ordered_at,
           pr.price * o.quantity AS revenue
    FROM orders   AS o
    JOIN products AS pr ON pr.id = o.product_id
    WHERE o.customer_id = c.id
    ORDER BY revenue DESC
    LIMIT 1
) AS top ON true
ORDER BY top.revenue DESC NULLS LAST, c.id;
