-- Задача 12. Собрать строки в JSON: jsonb_agg (массив) и jsonb_object_agg (объект).
SET search_path TO lab017;

-- jsonb_agg(expr ORDER BY ...) собирает значения группы в JSON-МАССИВ.
-- ORDER BY внутри агрегата ОБЯЗАТЕЛЕН — иначе порядок элементов массива не
-- определён (детерминизм; та же логика, что у array_agg в lab009).
-- Здесь: по категории — массив товаров (объектов) от дорогих к дешёвым.
SELECT
    category,
    jsonb_agg(
        jsonb_build_object('name', name, 'price', price)
        ORDER BY price DESC, id
    ) AS products_json
FROM products
GROUP BY category
ORDER BY category;

-- jsonb_object_agg(key, value ORDER BY ...) собирает пары в JSON-ОБЪЕКТ
-- (прайс-лист «название → цена»). Ключи в jsonb всё равно отсортируются по
-- своим правилам, но ORDER BY внутри решает, чьё значение победит при дубле
-- ключа, и делает результат предсказуемым.
SELECT jsonb_object_agg(name, price ORDER BY name) AS price_list
FROM products
WHERE category = 'books';
