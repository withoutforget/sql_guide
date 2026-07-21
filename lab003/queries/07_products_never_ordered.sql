-- Задача 7. Товары из каталога, которые ни разу не заказывали (каталог EXCEPT заказанное).
SET search_path TO lab003;

-- Классический приём «есть тут, но нет там» через EXCEPT:
--   первый запрос  — весь каталог (id, name);
--   второй запрос  — id и name товаров, которые реально встречались в заказах
--                    (JOIN orders→products);
--   EXCEPT         — оставит товары каталога, для которых пары в заказах не нашлось.
-- Обе ветки дают по две колонки (id, name) совместимых типов, поэтому сравнение
-- идёт по полной паре. Это альтернатива анти-джойну из lab002 (LEFT JOIN ... IS NULL).
SELECT id, name FROM products
EXCEPT
SELECT p.id, p.name
FROM orders   AS o
JOIN products AS p  ON p.id = o.product_id
ORDER BY id;
