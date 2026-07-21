-- Задача 9. Клиенты, не купившие ни одной книги (коррелированный NOT EXISTS, анти-соединение).
SET search_path TO lab004;

-- NOT EXISTS истинно, когда подзапрос вернул 0 строк: "не существует ни одного
-- заказа книги у этого клиента". Это анти-соединение — тот же вопрос, что
-- LEFT JOIN ... IS NULL в lab002 и EXCEPT в lab003, только через подзапрос.
-- Важно: NOT EXISTS NULL-безопасен (в отличие от NOT IN из задачи 5).
-- Книг не покупали: Борис, Глеб, Егор и Захар (Захар вообще без заказов).
SELECT c.id, c.name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    WHERE o.customer_id = c.id
      AND p.category_id = 2          -- книги
)
ORDER BY c.id;
