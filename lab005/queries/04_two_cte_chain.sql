-- Задача 4. Категории с выручкой выше средней выручки по категориям (цепочка из двух CTE).
SET search_path TO lab005;

-- Многошаговая аналитика "шаг за шагом":
--   ШАГ 1 (category_revenue) — выручка по каждой категории;
--   ШАГ 2 (avg_revenue)      — среднее ПО РЕЗУЛЬТАТУ шага 1 (ссылка на предыдущий CTE!).
-- Второй CTE строится на первом — это цепочка. Ссылаться можно только "назад".
-- Главный запрос использует оба шага. Средняя выручка по 5 категориям = 27464 ₽;
-- выше неё только Электроника (83420) и Дом (34950).
WITH
    category_revenue AS (
        SELECT p.category_id,
               SUM(p.price * o.quantity) AS revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY p.category_id
    ),
    avg_revenue AS (
        SELECT AVG(revenue) AS avg_rev
        FROM category_revenue
    )
SELECT cat.name,
       cr.revenue,
       ROUND((SELECT avg_rev FROM avg_revenue), 2) AS avg_over_categories
FROM category_revenue AS cr
JOIN categories AS cat ON cat.id = cr.category_id
WHERE cr.revenue > (SELECT avg_rev FROM avg_revenue)
ORDER BY cr.revenue DESC;
