-- Задача 13. 🔥 Какую долю выручки клиента дают его 3 крупнейших заказа (top-N на группу + агрегация).
SET search_path TO lab006;

-- Изюм: сначала берём top-N НА ГРУППУ через LATERAL (как в задаче 9), а потом
-- АГРЕГИРУЕМ полученные строки — «сумма трёх крупнейших заказов клиента» и её доля
-- в его полной выручке. Это то, ради чего собираются LATERAL, CTE и агрегаты вместе.
-- Шаги (цепочка CTE):
--   ШАГ 1 (customer_total) — полная выручка каждого клиента (обычный GROUP BY);
--   ШАГ 2 (top3)          — для каждого клиента через JOIN LATERAL ... LIMIT 3
--                           достаём его 3 самых дорогих заказа и СУММИРУЕМ их;
--   ФИНАЛ — делим сумму топ-3 на полную выручку → доля «крупных» покупок, %.
-- У кого заказов ≤ 3 (Борис, Вера, Глеб), топ-3 = все заказы → доля 100%. У кого
-- заказов больше (Анна, Дарья, Егор) — доля ниже 100%: часть выручки вне топ-3.
-- Клиенты без заказов (Жанна) сюда не попадают: JOIN LATERAL без пары их отсекает.
-- Оконные функции (lab010) сделали бы это иначе; здесь их нельзя — только LATERAL.
WITH
    customer_total AS (
        SELECT o.customer_id,
               SUM(p.price * o.quantity) AS total_revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY o.customer_id
    ),
    top3 AS (
        SELECT c.id                 AS customer_id,
               COUNT(*)             AS top_n,
               SUM(t.revenue)       AS top3_revenue
        FROM customers AS c
        JOIN LATERAL (
            SELECT p.price * o.quantity AS revenue
            FROM orders   AS o
            JOIN products AS p ON p.id = o.product_id
            WHERE o.customer_id = c.id
            ORDER BY revenue DESC
            LIMIT 3
        ) AS t ON true
        GROUP BY c.id
    )
SELECT c.name,
       t3.top_n,
       t3.top3_revenue,
       ct.total_revenue,
       ROUND(100.0 * t3.top3_revenue / ct.total_revenue, 1) AS top3_share_pct
FROM top3 AS t3
JOIN customer_total AS ct ON ct.customer_id = t3.customer_id
JOIN customers      AS c  ON c.id = t3.customer_id
ORDER BY top3_share_pct, ct.total_revenue DESC;
