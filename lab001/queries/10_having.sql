-- Задача 10. Категории, в которых больше 2 товаров (фильтр по агрегату — HAVING).
SET search_path TO lab001;

SELECT
    category,
    COUNT(*) AS products_count
FROM products
GROUP BY category
HAVING COUNT(*) > 2
ORDER BY products_count DESC;
