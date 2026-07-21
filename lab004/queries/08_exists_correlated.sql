-- Задача 8. Клиенты, купившие хоть что-то дороже 20 000 ₽ (коррелированный EXISTS).
SET search_path TO lab004;

-- EXISTS отвечает "вернул ли подзапрос хотя бы одну строку". Подзапрос
-- КОРРЕЛИРОВАННЫЙ: условие o.customer_id = c.id связывает его с текущей внешней
-- строкой-клиентом — концептуально подзапрос выполняется для каждого клиента.
-- В SELECT подзапроса пишут 1 (SELECT 1): важен лишь факт наличия строки, а не
-- её содержимое. Дорогие покупки (>20 000 ₽) есть только у Анны (Смартфон) и
-- Бориса (Ноутбук).
SELECT c.id, c.name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    WHERE o.customer_id = c.id
      AND p.price > 20000
)
ORDER BY c.id;
