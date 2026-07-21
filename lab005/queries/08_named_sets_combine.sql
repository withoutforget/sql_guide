-- Задача 8. Крупные покупатели (выше средней траты), которые ещё и покупали книги.
SET search_path TO lab005;

-- CTE удобно использовать как ИМЕНОВАННЫЕ НАБОРЫ и потом их комбинировать. Здесь
-- три шага: customer_revenue (траты по клиентам) -> big_spenders (выше средней
-- траты, цепочка на предыдущий CTE) -> book_buyers (кто покупал книги, отдельный
-- набор). Финал оставляет тех, кто и в big_spenders, и в book_buyers — это
-- пересечение двух наборов (приёмы IN/EXISTS из lab004; тот же смысл, что
-- INTERSECT из lab003). Крупные покупатели: Анна, Борис, Егор; из них книги брала
-- только Анна — она и в ответе.
WITH
    customer_revenue AS (
        SELECT o.customer_id,
               SUM(p.price * o.quantity) AS total
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY o.customer_id
    ),
    big_spenders AS (
        SELECT customer_id
        FROM customer_revenue
        WHERE total > (SELECT AVG(total) FROM customer_revenue)
    ),
    book_buyers AS (
        SELECT DISTINCT o.customer_id
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        WHERE p.category_id = 2                 -- Книги
    )
SELECT c.id, c.name
FROM customers AS c
WHERE c.id IN (SELECT customer_id FROM big_spenders)
  AND c.id IN (SELECT customer_id FROM book_buyers)
ORDER BY c.id;
