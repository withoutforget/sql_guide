-- Задача 5. Разбить клиентов на квартили по сумме трат (NTILE(4)).
SET search_path TO lab010;

-- Сначала CTE spend сворачивает заказы в сумму трат по каждому клиенту (обычный
-- GROUP BY). Затем ntile(4) OVER (ORDER BY total_spent DESC) делит 7 клиентов на 4
-- корзины ПРИМЕРНО поровну: 7 = 4·1 + 3, остаток 3 раздаётся первым корзинам, поэтому
-- размеры 2,2,2,1 (Q1 — самые щедрые, Q4 — самый скромный). NTILE смотрит на ПОЗИЦИЮ
-- строки в порядке, а не на само значение.
WITH spend AS (
    SELECT cu.id, cu.name, cu.city,
           sum(p.price * o.qty) AS total_spent
    FROM orders    AS o
    JOIN products  AS p  ON p.id  = o.product_id
    JOIN customers AS cu ON cu.id = o.customer_id
    GROUP BY cu.id, cu.name, cu.city
)
SELECT
    name                                          AS клиент,
    city                                          AS город,
    total_spent                                   AS потрачено,
    ntile(4) OVER (ORDER BY total_spent DESC)     AS квартиль
FROM spend
ORDER BY total_spent DESC;
