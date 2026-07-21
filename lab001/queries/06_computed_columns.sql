-- Задача 6. Стоимость складского запаса по каждому товару (цена × остаток), с алиасом.
SET search_path TO lab001;

SELECT
    name,
    price,
    in_stock,
    price * in_stock AS stock_value
FROM products
WHERE in_stock > 0
ORDER BY stock_value DESC;
