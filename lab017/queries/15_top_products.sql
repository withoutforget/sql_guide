-- Задача 15. 🔥 Аналитика поверх JSON: топ продаваемых товаров по всем заказам.
SET search_path TO lab017;

-- «SQL поверх JSON-логов»: у нас нет нормализованной таблицы позиций — они
-- спрятаны в массивах items КАЖДОГО заказа. Разворачиваем items всех заказов в
-- единый поток строк (jsonb_array_elements + LATERAL, задача 8), а дальше — как
-- по обычной таблице: группируем по товару и считаем продажи и выручку.
-- Детерминизм: тай-брейк по имени товара (units_sold у нескольких товаров = 2).
SELECT
    it ->> 'product'                                     AS product,
    SUM((it ->> 'qty')::int)                             AS units_sold,
    SUM((it ->> 'qty')::int * (it ->> 'price')::numeric) AS revenue,
    count(DISTINCT o.id)                                 AS in_orders
FROM orders o,
     LATERAL jsonb_array_elements(o.items) AS it
GROUP BY it ->> 'product'
ORDER BY units_sold DESC, product;
