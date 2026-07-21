-- Задача 9. По каждой категории: число товаров и средняя цена (дороже сверху).
SET search_path TO lab001;

SELECT
    category,
    COUNT(*)             AS products_count,
    ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;
