-- Задача 1. Состав каждого заказа одной строкой: товары через запятую, по алфавиту.
SET search_path TO lab009;

-- string_agg склеивает названия товаров заказа в одну строку. ORDER BY p.name
-- ВНУТРИ агрегата делает список детерминированным (без него порядок не определён).
-- Заодно считаем число позиций и суммарное количество единиц в заказе.
SELECT
    o.id                                        AS заказ,
    o.ordered_at                                AS дата,
    count(*)                                    AS позиций,
    sum(oi.qty)                                 AS единиц,
    string_agg(p.name, ', ' ORDER BY p.name)    AS товары
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products    p  ON p.id = oi.product_id
GROUP BY o.id, o.ordered_at
ORDER BY o.id;
