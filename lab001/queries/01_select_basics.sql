-- Задача 1. Выбрать название, категорию и цену всех товаров.
SET search_path TO lab001;

SELECT name, category, price
FROM products;
