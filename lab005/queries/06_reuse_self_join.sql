-- Задача 6. Пары клиентов из одного города: кто потратил больше (self-join промежуточного результата).
SET search_path TO lab005;

-- CTE можно присоединить к самому себе — как self-join таблицы из lab002, только
-- соединяем не таблицу, а ВЫЧИСЛЕННЫЙ шаг. customer_revenue посчитан один раз, но
-- в FROM появляется дважды (r1 и r2) — две "копии" одного результата. Условие
-- соединения: тот же город и r1 потратил больше r2. Без CTE пришлось бы дважды
-- выписать весь агрегирующий подзапрос. Город и имя кладём прямо в CTE, чтобы не
-- джойнить customers повторно. Ответ: пары внутри Москвы (Егор>Анна, Егор>Вера,
-- Анна>Вера) и Казани (Глеб>Захар).
WITH customer_revenue AS (
    SELECT o.customer_id,
           c.name,
           c.city,
           SUM(p.price * o.quantity) AS total
    FROM orders    AS o
    JOIN products  AS p ON p.id = o.product_id
    JOIN customers AS c ON c.id = o.customer_id
    GROUP BY o.customer_id, c.name, c.city
)
SELECT r1.city,
       r1.name  AS spent_more, r1.total AS more_total,
       r2.name  AS spent_less, r2.total AS less_total
FROM customer_revenue AS r1
JOIN customer_revenue AS r2
     ON r1.city = r2.city          -- один город
    AND r1.total > r2.total        -- первый потратил больше
ORDER BY r1.city, r1.total DESC, r2.total DESC;
