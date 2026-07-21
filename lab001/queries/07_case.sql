-- Задача 7. Пометить каждый товар: 'нет в наличии' / 'мало' (<10) / 'достаточно'.
SET search_path TO lab001;

SELECT
    name,
    in_stock,
    CASE
        WHEN in_stock = 0            THEN 'нет в наличии'
        WHEN in_stock < 10          THEN 'мало'
        ELSE                             'достаточно'
    END AS stock_status
FROM products
ORDER BY in_stock;
