-- Задача 8. «Взорвать» массив позиций заказа в строки и посчитать сумму заказа.
SET search_path TO lab017;

-- jsonb_array_elements(arr) — set-returning функция: по строке на каждый элемент
-- JSON-массива (см. разворачивание в lab006). Ставим её в FROM через LATERAL,
-- чтобы развернуть массив items КАЖДОГО заказа. Дальше — обычный SQL: приводим
-- qty и price к числам и группируем, считая сумму заказа SUM(qty * price).
SELECT
    o.id,
    o.customer,
    count(*)                                             AS positions,
    SUM((it ->> 'qty')::int * (it ->> 'price')::numeric) AS order_total
FROM orders o,
     LATERAL jsonb_array_elements(o.items) AS it
GROUP BY o.id, o.customer
ORDER BY o.id;
