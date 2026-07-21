-- Задача 9. Три самых дорогих заказа каждого клиента (top-N на группу: LEFT JOIN LATERAL + LIMIT).
SET search_path TO lab006;

-- Фирменный кейс LATERAL — «top-N строк в каждой группе». В задачах 7–8 мы брали
-- LIMIT 1 (топ-1); меняем на LIMIT 3 — и для КАЖДОГО клиента получаем до трёх его
-- самых дорогих заказов. Без LATERAL (и без оконных функций, которые будут в
-- lab010) это чисто в SQL не выразить: коррелированный подзапрос из lab004 отдаёт
-- одно значение, а нам нужно несколько ЦЕЛЫХ СТРОК на группу.
-- Как читать: для каждого клиента c правый подзапрос отбирает его заказы, считает
-- выручку, сортирует по убыванию и берёт первые 3. LEFT JOIN LATERAL, чтобы клиент
-- без заказов (Жанна) не потерялся (у неё top.* = NULL). У кого заказов больше
-- трёх (Анна — 5), лишние отсекаются; у кого меньше — берутся все, сколько есть.
-- Внешний ORDER BY выстраивает заказы клиента от дорогого к дешёвому.
SELECT c.name       AS customer,
       top.product,
       top.revenue
FROM customers AS c
LEFT JOIN LATERAL (
    SELECT pr.name               AS product,
           pr.price * o.quantity AS revenue
    FROM orders   AS o
    JOIN products AS pr ON pr.id = o.product_id
    WHERE o.customer_id = c.id            -- корреляция: заказы этого клиента
    ORDER BY revenue DESC
    LIMIT 3                               -- top-3 внутри группы
) AS top ON true
ORDER BY c.name, top.revenue DESC NULLS LAST;
