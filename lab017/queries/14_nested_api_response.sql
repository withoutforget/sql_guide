-- Задача 14. 🔥 Собрать вложенный API-ответ по каждому заказу из его позиций.
SET search_path TO lab017;

-- Реальная задача backend-разработчика: отдать по каждому заказу документ
--   {order_id, customer, total, items:[{product, qty, subtotal}]},
-- где items пересобран из позиций с ВЫЧИСЛЯЕМЫМ полем subtotal, а total — сумма
-- этих subtotal. Приёмы этой лабы собираются вместе:
--   • LATERAL + jsonb_array_elements — развернуть позиции заказа (задача 8);
--   • ->>/приведения — вытащить и посчитать qty, price (задача 3, lab013);
--   • jsonb_agg(... ORDER BY ...) — собрать позиции обратно в JSON-массив
--     (детерминизм: сортируем по subtotal, задача 12);
--   • jsonb_build_object — обернуть всё в итоговый объект (задача 2);
--   • jsonb_pretty — детерминированный человекочитаемый вывод.
SELECT o.id,
       jsonb_pretty(
           jsonb_build_object(
               'order_id', o.id,
               'customer', o.customer,
               'total',    agg.total,
               'items',    agg.items
           )
       ) AS response
FROM orders o
CROSS JOIN LATERAL (
    SELECT
        SUM((it ->> 'qty')::int * (it ->> 'price')::numeric) AS total,
        jsonb_agg(
            jsonb_build_object(
                'product',  it ->> 'product',
                'qty',      (it ->> 'qty')::int,
                'subtotal', (it ->> 'qty')::int * (it ->> 'price')::numeric
            )
            ORDER BY (it ->> 'qty')::int * (it ->> 'price')::numeric DESC,
                     it ->> 'product'
        ) AS items
    FROM jsonb_array_elements(o.items) AS it
) AS agg
ORDER BY o.id;
