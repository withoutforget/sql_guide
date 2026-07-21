-- Задача 9. Выручка по категориям: сумма проданного и число проданных позиций (JOIN + GROUP BY).
SET search_path TO lab002;

-- INNER JOIN: в отчёт попадают только категории, где были продажи
-- (категории «Спорт» и «Сад» без заказов сюда не войдут — это ожидаемо).
SELECT
    cat.name                  AS category,
    SUM(p.price * o.quantity) AS revenue,
    SUM(o.quantity)           AS units_sold,
    COUNT(o.id)               AS order_lines
FROM categories AS cat
JOIN products   AS p  ON p.category_id = cat.id
JOIN orders     AS o  ON o.product_id  = p.id
GROUP BY cat.id, cat.name
ORDER BY revenue DESC;
