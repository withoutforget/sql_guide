-- Задача 11. Товары и их доля в выручке своей категории (предварительная свёртка в CTE).
SET search_path TO lab005;

-- Частый рабочий приём: сначала СВЕРНУТЬ заказы до нужного уровня в CTE, а потом
-- присоединить справочные поля — чтобы агрегат не "раздувался" при join. Два CTE:
--   product_rev  — выручка по каждому товару (свёртка заказов по товару);
--   category_rev — выручка по каждой категории (знаменатель для доли).
-- Финал соединяет их со справочниками products/categories и считает долю товара
-- ВНУТРИ его категории. Видно, например, что Смартфон — 59.9% всей Электроники, а
-- Кофеварка — 51.4% Дома. Строим "витрину" из готовых агрегатов, а не мешаем
-- агрегацию с детализацией.
WITH
    product_rev AS (
        SELECT o.product_id,
               SUM(p.price * o.quantity) AS revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY o.product_id
    ),
    category_rev AS (
        SELECT p.category_id,
               SUM(p.price * o.quantity) AS revenue
        FROM orders   AS o
        JOIN products AS p ON p.id = o.product_id
        GROUP BY p.category_id
    )
SELECT cat.name AS category,
       p.name   AS product,
       pr.revenue,
       ROUND(pr.revenue * 100.0 / cr.revenue, 1) AS pct_of_category
FROM product_rev  AS pr
JOIN products     AS p   ON p.id = pr.product_id
JOIN categories   AS cat ON cat.id = p.category_id
JOIN category_rev AS cr  ON cr.category_id = p.category_id
ORDER BY cat.name, pr.revenue DESC;
