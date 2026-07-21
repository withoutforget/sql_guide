-- Задача 2. По каждому клиенту — массив УНИКАЛЬНЫХ категорий, из которых он покупал.
SET search_path TO lab009;

-- array_agg(DISTINCT ...) собирает значения группы в массив, убирая повторы:
-- клиент мог купить много товаров одной категории — в списке она будет один раз.
-- При DISTINCT сортировать внутри агрегата можно только по тому же выражению.
-- Для наглядности рядом — общий список купленных товаров (уже без DISTINCT).
SELECT
    c.name                                              AS клиент,
    count(DISTINCT p.category)                          AS разных_категорий,
    array_agg(DISTINCT p.category ORDER BY p.category)  AS категории,
    string_agg(p.name, ', ' ORDER BY p.name)            AS все_товары
FROM customers   c
JOIN orders      o  ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products    p  ON p.id = oi.product_id
GROUP BY c.name
ORDER BY разных_категорий DESC, клиент;
