-- Задача 3. Клиенты, потратившие больше среднего по клиентам, и на сколько (CTE использован дважды).
SET search_path TO lab005;

-- Здесь один и тот же промежуточный результат нужен ДВАЖДЫ: как источник строк
-- клиентов И чтобы посчитать по нему же среднюю трату. Именно это derived table
-- (lab004) не умеет — пришлось бы дублировать подзапрос. CTE per_customer
-- объявлен один раз, а сослались на него три раза: в FROM и в двух скалярных
-- подзапросах (SELECT AVG(total) FROM per_customer). Среднее по клиентам = 17165;
-- выше него — Егор (34640), Анна (30550), Борис (21980). Вера (15660) чуть ниже
-- среднего и не проходит — пограничный случай.
WITH per_customer AS (
    SELECT o.customer_id,
           SUM(p.price * o.quantity) AS total
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY o.customer_id
)
SELECT c.name,
       pc.total,
       ROUND(pc.total - (SELECT AVG(total) FROM per_customer), 2) AS diff_from_avg
FROM per_customer AS pc
JOIN customers AS c ON c.id = pc.customer_id
WHERE pc.total > (SELECT AVG(total) FROM per_customer)
ORDER BY pc.total DESC;
