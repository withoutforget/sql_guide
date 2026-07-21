-- Задача 7. Самый дорогой заказ каждого клиента (CROSS JOIN LATERAL + ORDER BY + LIMIT 1).
SET search_path TO lab006;

-- Вот то, ради чего нужен LATERAL: «для каждой строки слева выполнить правый
-- запрос». Для каждого клиента c правый подзапрос ищет ЕГО заказы
-- (o.customer_id = c.id — корреляция), считает выручку строки (price * quantity),
-- сортирует по ней и берёт LIMIT 1 — самый дорогой. Обычный коррелированный
-- скалярный подзапрос из lab004 так не смог бы: он возвращает ОДНО значение, а нам
-- нужно сразу несколько колонок (товар, дата, сумма) той же самой строки-рекордсмена.
-- ВАЖНО: это CROSS JOIN LATERAL — если справа пусто (у клиента нет заказов),
-- строка слева ОТБРАСЫВАЕТСЯ. Поэтому Жанны (заказов нет) в ответе не будет.
-- Сравните с задачей 8, где тот же запрос на LEFT JOIN LATERAL сохраняет Жанну.
SELECT c.name        AS customer,
       top.product,
       top.ordered_at,
       top.revenue
FROM customers AS c
CROSS JOIN LATERAL (
    SELECT pr.name        AS product,
           o.ordered_at,
           pr.price * o.quantity AS revenue
    FROM orders   AS o
    JOIN products AS pr ON pr.id = o.product_id
    WHERE o.customer_id = c.id          -- корреляция: заказы именно этого клиента
    ORDER BY revenue DESC
    LIMIT 1
) AS top
ORDER BY top.revenue DESC, c.id;
