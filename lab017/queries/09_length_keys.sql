-- Задача 9. Длина массива и ключи объекта: jsonb_array_length, jsonb_object_keys.
SET search_path TO lab017;

-- jsonb_array_length(arr) — сколько элементов в JSON-массиве. Сколько позиций
-- в каждом заказе (без разворачивания):
SELECT
    id,
    customer,
    jsonb_array_length(items) AS positions
FROM orders
ORDER BY id;

-- jsonb_object_keys(obj) — set-returning: по строке на каждый ключ верхнего
-- уровня. Соберём для каждого товара число атрибутов и список ключей.
-- Разный набор ключей у разных категорий хорошо виден (разреженность).
SELECT
    p.id,
    p.name,
    count(*)                AS n_attrs,
    jsonb_agg(k ORDER BY k) AS attribute_keys   -- ключи → JSON-массив (детерминизм: ORDER BY)
FROM products p,
     LATERAL jsonb_object_keys(p.attributes) AS k
GROUP BY p.id, p.name
ORDER BY p.id;
