-- Задача 7. Доля каждой категории в общей выручке, % (CTE сравнивается со своим же агрегатом).
SET search_path TO lab005;

-- Ещё один способ переиспользовать CTE: сравнить его строки с его же агрегатом.
-- category_revenue стоит и в FROM (строки категорий), и внутри скалярного
-- подзапроса (SELECT SUM(revenue) FROM category_revenue) — это общий знаменатель,
-- один на все строки. Так получаем долю каждой категории. Электроника — 60.75%,
-- Дом — 25.45%, дальше Книги/Игрушки/Спорт. Суммарно доли дают 100%.
WITH category_revenue AS (
    SELECT p.category_id,
           SUM(p.price * o.quantity) AS revenue
    FROM orders   AS o
    JOIN products AS p ON p.id = o.product_id
    GROUP BY p.category_id
)
SELECT cat.name,
       cr.revenue,
       ROUND(cr.revenue * 100.0 / (SELECT SUM(revenue) FROM category_revenue), 2) AS pct_of_total
FROM category_revenue AS cr
JOIN categories AS cat ON cat.id = cr.category_id
ORDER BY cr.revenue DESC;
