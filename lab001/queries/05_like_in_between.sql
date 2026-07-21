-- Задача 5. Книги (по названию начинается с 'Книга') ИЛИ товары ценой от 500 до 1500 ₽.
SET search_path TO lab001;

SELECT name, category, price
FROM products
WHERE name LIKE 'Книга%'
   OR price BETWEEN 500 AND 1500
ORDER BY price;
