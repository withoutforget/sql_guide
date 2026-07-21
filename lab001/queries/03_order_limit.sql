-- Задача 3. Топ-3 самых дорогих товаров (название и цена по убыванию цены).
SET search_path TO lab001;

SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 3;
