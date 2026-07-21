-- Задача 2. Товары категории 'electronics' дешевле 10 000 ₽, которые есть в наличии.
SET search_path TO lab001;

SELECT name, price, in_stock
FROM products
WHERE category = 'electronics'
  AND price < 10000
  AND in_stock > 0;
