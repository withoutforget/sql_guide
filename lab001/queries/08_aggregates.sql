-- Задача 8. Сводка по всем товарам: количество, суммарный остаток, средняя/мин/макс цена.
SET search_path TO lab001;

SELECT
    COUNT(*)        AS total_products,
    SUM(in_stock)   AS total_units,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price)      AS cheapest,
    MAX(price)      AS most_expensive
FROM products;
